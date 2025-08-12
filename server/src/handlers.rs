// src/handlers.rs
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use crate::{models::{User, CreateUser, UpdateUser}, AppState};

pub async fn list_users(
    State(state): State<AppState>,
) -> Result<Json<Vec<User>>, (StatusCode, String)> {
    let users = sqlx::query_as::<_, User>("SELECT id, name, email FROM users ORDER BY id")
        .fetch_all(&state.pool)
        .await
        .map_err(internal)?;
    Ok(Json(users))
}

pub async fn create_user(
    State(state): State<AppState>,
    Json(payload): Json<CreateUser>,
) -> Result<Json<User>, (StatusCode, String)> {
    let res = sqlx::query("INSERT INTO users (name, email) VALUES (?, ?)")
        .bind(&payload.name)
        .bind(&payload.email)
        .execute(&state.pool)
        .await
        .map_err(internal)?;
    let id = res.last_insert_rowid();

    let user = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_one(&state.pool)
        .await
        .map_err(internal)?;
    Ok(Json(user))
}

pub async fn get_user(
    Path(id): Path<i64>,
    State(state): State<AppState>,
) -> Result<Json<User>, (StatusCode, String)> {
    match sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_one(&state.pool)
        .await
    {
        Ok(user) => Ok(Json(user)),
        Err(sqlx::Error::RowNotFound) => Err((StatusCode::NOT_FOUND, "User not found".into())),
        Err(e) => Err(internal(e)),
    }
}

pub async fn update_user(
    Path(id): Path<i64>,
    State(state): State<AppState>,
    Json(payload): Json<UpdateUser>,
) -> Result<Json<User>, (StatusCode, String)> {
    sqlx::query(
        "UPDATE users
         SET name = COALESCE(?, name),
             email = COALESCE(?, email)
         WHERE id = ?",
    )
    .bind(payload.name)
    .bind(payload.email)
    .bind(id)
    .execute(&state.pool)
    .await
    .map_err(internal)?;

    let user = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_one(&state.pool)
        .await
        .map_err(internal)?;
    Ok(Json(user))
}

pub async fn delete_user(
    Path(id): Path<i64>,
    State(state): State<AppState>,
) -> Result<StatusCode, (StatusCode, String)> {
    let rows = sqlx::query("DELETE FROM users WHERE id = ?")
        .bind(id)
        .execute(&state.pool)
        .await
        .map_err(internal)?
        .rows_affected();

    if rows == 0 {
        return Err((StatusCode::NOT_FOUND, "User not found".into()));
    }
    Ok(StatusCode::NO_CONTENT)
}

fn internal<E: std::fmt::Display>(e: E) -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
}

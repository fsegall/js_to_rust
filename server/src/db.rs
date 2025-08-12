use sqlx::{sqlite::SqlitePoolOptions, SqlitePool};

use crate::models::Result;

#[derive(Clone)]
pub struct AppState {
    pub pool: SqlitePool,
}

pub async fn init_db(database_url: &str) -> Result<SqlitePool> {
    let pool = SqlitePoolOptions::new()
        .max_connections(5)
        .connect(database_url)
        .await?;

    // tabela mínima (para demo). Em produção, use migrações sqlx::migrate!
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users (
            id   INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        );
        "#,
    )
    .execute(&pool)
    .await?;

    Ok(pool)
}

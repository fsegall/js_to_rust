# Chapter 13 — Final Project: CRUD Server with Rust, Axum, and SQLite (Axum 0.7)

In this chapter, we’ll consolidate what you’ve learned by building a real project: a fully‑featured **CRUD** server using **Rust**, the **Axum** framework, and **SQLite**.

Our goal is to **migrate the logic of a traditional Express.js server** to Rust — showing that you can write modern, safe, high‑performance APIs with static typing and zero runtime overhead.

---

## Project overview -  Source code: https://github.com/fsegall/js_to_rust

### What we’ll build

* RESTful endpoints: `GET`, `POST`, `PUT`, `DELETE`.
* Persistence with SQLite.
* Strongly typed structs and enums.
* Error handling with `Result` and conversion to HTTP responses.
* Modular, scalable architecture.

### Stack comparison

| Component  | JavaScript (Express)      | Rust (Axum)                |
| ---------- | ------------------------- | -------------------------- |
| Framework  | Express                   | Axum                       |
| Database   | SQLite (`sqlite3`)        | SQLite (`sqlx`)            |
| Routing    | `app.get()`, `app.post()` | `Router::new().route(...)` |
| Middleware | Custom functions          | `tower` middleware         |
| Typing     | Dynamic                   | Static (structs + enums)   |

---

## Chapter structure

1. **Project setup**: dependencies, layout, and SQLite
2. **Express version**: a minimal JavaScript CRUD
3. **Axum version**: step‑by‑step rewrite in Rust
4. **Side‑by‑side comparison**: safety and performance in Rust
5. **Testing & usage**: `curl`, validations, and logging
6. **Wrap‑up**: benefits and trade‑offs of Rust on the backend

---

## 13.1 — Setup: Axum + SQLite

Create a new Rust project with Cargo and add the required dependencies.

### Step 1: create the project

```bash
cargo new axum_crud_project
cd axum_crud_project
```

### Step 2: add dependencies to `Cargo.toml`

> **Axum 0.7**: we use the current API with `axum::serve` (no `into_make_service`).

```toml
[package]
name = "axum_crud_project"
version = "0.1.0"
edition = "2021"

[dependencies]
axum = "0.7"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sqlx = { version = "0.7", features = ["sqlite", "runtime-tokio-rustls"] }
tower = "0.4"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["fmt", "env-filter"] }
```

### Step 3: folder structure

```
src/
├── main.rs          # entry point
├── db.rs            # SQLite setup and connection pool
├── handlers.rs      # route logic
├── models.rs        # data types and errors
└── routes.rs        # route composition
```

> We’ll keep things modular for reuse and easier testing.

---

## 13.2 — Reference: Express.js version (JavaScript)

Before the Rust version, here’s a minimal CRUD with Express and SQLite **including `name` and `email`** (to stay consistent with the Rust version):

```js
const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const app = express();
app.use(express.json());

const db = new sqlite3.Database(":memory:");
db.serialize(() => {
  db.run("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE)");
});

app.get("/users", (req, res) => {
  db.all("SELECT id, name, email FROM users ORDER BY id", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

app.get("/users/:id", (req, res) => {
  db.get("SELECT id, name, email FROM users WHERE id = ?", [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: "not found" });
    res.json(row);
  });
});

app.post("/users", (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: "name and email are required" });
  db.run("INSERT INTO users(name, email) VALUES(?, ?)", [name, email], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id: this.lastID, name, email });
  });
});

app.put("/users/:id", (req, res) => {
  const { name, email } = req.body;
  db.run(
    "UPDATE users SET name = COALESCE(?, name), email = COALESCE(?, email) WHERE id = ?",
    [name ?? null, email ?? null, req.params.id],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ updated: this.changes });
    }
  );
});

app.delete("/users/:id", (req, res) => {
  db.run("DELETE FROM users WHERE id = ?", [req.params.id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ deleted: this.changes });
  });
});

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
```

That’s the functionality we’ll reproduce with Axum.

---

## 13.3 — Booting a minimal Axum server (Axum 0.7)

> **Important change (0.6 → 0.7):** use `tokio::net::TcpListener` and `axum::serve(listener, app)`. We no longer use `into_make_service()`.

```rust
use axum::{Router, routing::get};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(|| async { "Hello from Axum!" }));

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("Listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

---

## 13.4 — `models.rs`

Data models, input/output types, and the application error converted into an HTTP response.

```rust
// src/models.rs
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use axum::{http::StatusCode, response::{IntoResponse, Response}, Json};
use serde_json::json;
use thiserror::Error;

#[derive(Debug, Serialize, FromRow)]
pub struct User {
    pub id: i64,
    pub name: String,
    pub email: String,
}

#[derive(Debug, Deserialize)]
pub struct NewUser {
    pub name: String,
    pub email: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateUser {
    pub name: Option<String>,
    pub email: Option<String>,
}

#[derive(Debug, Error)]
pub enum AppError {
    #[error("not found")]
    NotFound,
    #[error(transparent)]
    Sqlx(#[from] sqlx::Error),
    #[error("invalid input: {0}")]
    BadRequest(String),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, msg) = match &self {
            AppError::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            AppError::Sqlx(_) => (StatusCode::INTERNAL_SERVER_ERROR, "database error".to_string()),
            AppError::BadRequest(m) => (StatusCode::BAD_REQUEST, m.clone()),
        };
        (status, Json(json!({"error": msg}))).into_response()
    }
}

pub type Result<T> = std::result::Result<T, AppError>;
```

**Notes**

* `FromRow` maps SQLite columns to the struct.
* `AppError` centralizes errors and becomes an HTTP response via `IntoResponse`.

---

## 13.5 — `db.rs`

Database connection and initialization.

```rust
// src/db.rs
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

    // Minimal table (use migrations in production)
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users (
            id     INTEGER PRIMARY KEY AUTOINCREMENT,
            name   TEXT NOT NULL,
            email  TEXT NOT NULL UNIQUE
        )
        "#,
    )
    .execute(&pool)
    .await?;

    Ok(pool)
}
```

---

## 13.6 — `handlers.rs`

Functions that handle each route.

```rust
// src/handlers.rs
use axum::{extract::{Path, State}, http::StatusCode, Json};
use crate::{db::AppState, models::{AppError, Result, User, NewUser, UpdateUser}};

pub async fn list_users(State(state): State<AppState>) -> Result<Json<Vec<User>>> {
    let users = sqlx::query_as::<_, User>("SELECT id, name, email FROM users ORDER BY id")
        .fetch_all(&state.pool)
        .await?;
    Ok(Json(users))
}

pub async fn get_user(Path(id): Path<i64>, State(state): State<AppState>) -> Result<Json<User>> {
    let user = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_optional(&state.pool)
        .await?;

    match user { Some(u) => Ok(Json(u)), None => Err(AppError::NotFound) }
}

pub async fn create_user(State(state): State<AppState>, Json(payload): Json<NewUser>)
    -> Result<(StatusCode, Json<User>)>
{
    if payload.name.trim().is_empty() || payload.email.trim().is_empty() {
        return Err(AppError::BadRequest("name and email are required".into()));
    }

    let result = sqlx::query("INSERT INTO users (name, email) VALUES (?, ?)")
        .bind(&payload.name)
        .bind(&payload.email)
        .execute(&state.pool)
        .await?;

    let id = result.last_insert_rowid();
    let created = User { id, name: payload.name, email: payload.email };
    Ok((StatusCode::CREATED, Json(created)))
}

pub async fn update_user(
    Path(id): Path<i64>,
    State(state): State<AppState>,
    Json(payload): Json<UpdateUser>,
) -> Result<Json<User>> {
    // Partial update with COALESCE
    sqlx::query(
        "UPDATE users SET name = COALESCE(?, name), email = COALESCE(?, email) WHERE id = ?",
    )
    .bind(payload.name)
    .bind(payload.email)
    .bind(id)
    .execute(&state.pool)
    .await?;

    let updated = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_optional(&state.pool)
        .await?;

    match updated { Some(u) => Ok(Json(u)), None => Err(AppError::NotFound) }
}

pub async fn delete_user(Path(id): Path<i64>, State(state): State<AppState>) -> Result<StatusCode> {
    let rows = sqlx::query("DELETE FROM users WHERE id = ?")
        .bind(id)
        .execute(&state.pool)
        .await?
        .rows_affected();

    if rows == 0 { return Err(AppError::NotFound); }

    Ok(StatusCode::NO_CONTENT)
}
```

---

## 13.7 — `routes.rs`

Define routes and build the `Router` (with typed state):

```rust
// src/routes.rs
use axum::{routing::{get, post, put, delete}, Router};
use crate::{db::AppState, handlers};

pub fn app(state: AppState) -> Router {
    Router::new()
        .route("/users", get(handlers::list_users).post(handlers::create_user))
        .route("/users/:id", get(handlers::get_user).put(handlers::update_user).delete(handlers::delete_user))
        .with_state(state)
}
```

> You can also import only `get` and then chain `.post/.put/.delete` as methods.

---

## 13.8 — `main.rs` (final version)

Wires everything together: app state, routes, logging, and server.

```rust
// src/main.rs
mod db;
mod handlers;
mod models;
mod routes;

use std::net::SocketAddr;
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() {
    // simple logging (RUST_LOG=info by default, override via env)
    let _ = fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .try_init();

    // DATABASE_URL, e.g. sqlite://data/axum.db?mode=rwc
    let database_url = std::env::var("DATABASE_URL").unwrap_or_else(|_| "sqlite://data/axum.db?mode=rwc".into());

    let pool = db::init_db(&database_url).await.expect("db init failed");
    let state = db::AppState { pool };

    let app = routes::app(state);

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    tracing::info!("listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.expect("bind failed");
    axum::serve(listener, app).await.expect("server error");
}
```

> **Axum 0.7:** we use `TcpListener` + `axum::serve` (no `into_make_service`).

---

## 13.9 — Quick `curl` tests

Create, list, update, and delete users.

```bash
# create (with name and email)
curl -sS -X POST http://127.0.0.1:3000/users \
  -H 'content-type: application/json' \
  -d '{"name":"Ada Lovelace","email":"ada@calc.org"}' | jq

# list
curl -sS http://127.0.0.1:3000/users | jq

# fetch by id
curl -sS http://127.0.0.1:3000/users/1 | jq

# partial update (name only)
curl -sS -X PUT http://127.0.0.1:3000/users/1 \
  -H 'content-type: application/json' \
  -d '{"name":"Ada L."}' | jq

# delete
curl -i -X DELETE http://127.0.0.1:3000/users/1
```

**Tip:** ensure the DB file exists by using a `data/` folder and setting the URL:

```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
```

---

## 13.10 — Express ↔ Axum comparison and final thoughts

### 13.10.1 Express ↔ Axum comparison

| Topic        | Express (JS)                              | Axum (Rust)                                                    |
| ------------ | ----------------------------------------- | -------------------------------------------------------------- |
| Server boot  | `const app = express(); app.listen(3000)` | `let app = Router::new(); axum::serve(TcpListener, app)`       |
| Routes       | `app.get("/users", handler)`              | `Router::new().route("/users", get(handler))`                  |
| Path params  | `req.params.id`                           | `Path<i64>` in the handler                                     |
| Query params | `req.query`                               | `Query<T>` (with `serde::Deserialize`)                         |
| JSON body    | `app.use(express.json())` + `req.body`    | `Json<T>` (with `serde::Deserialize`)                          |
| Responses    | `res.status(201).json({...})`             | `impl IntoResponse`, `Json(...)`, `StatusCode`                 |
| Middleware   | `app.use(mw)`                             | `tower` layers: `.layer(...)` or `middleware::from_fn`         |
| SQLite       | `sqlite3` callbacks                       | Async `sqlx` (`query`, `query_as`), compile‑time type checking |
| Logging      | `morgan("dev")`                           | `tracing` + `tracing-subscriber`                               |
| Config/env   | `process.env.X`                           | `std::env::var("X")`                                           |
| HTTP tests   | `supertest`/Jest                          | `reqwest` + `#[tokio::test]` (building a `Router`)             |
| Hot reload   | `nodemon`                                 | `cargo watch -x run`                                           |

#### Side‑by‑side examples

Express (GET):

```js
app.get("/users/:id", async (req, res) => {
  const id = Number(req.params.id);
  const row = await getUser(id);
  if (!row) return res.status(404).json({ error: "not found" });
  res.json(row);
});
```

Axum (GET):

```rust
pub async fn get_user(Path(id): Path<i64>, State(state): State<AppState>) -> Result<Json<User>> {
    let user = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_optional(&state.pool)
        .await?;
    user.map(Json).ok_or(AppError::NotFound)
}
```

#### Migration checklist: Express → Axum

1. Define models (`struct`) with `serde` (`Serialize`/`Deserialize`).
2. Create `AppError` and a `Result<T>` alias; implement `IntoResponse`.
3. Configure `SqlitePool` in `db.rs` and initialize the table.
4. Write handlers returning `Result<...>` and use `?`.
5. Build the `Router` in `routes.rs` and inject `AppState` with `.with_state(...)`.
6. Wire everything in `main.rs`, read `DATABASE_URL`.
7. Add `tracing` and, if needed, `tower` middlewares.
8. Test with `curl`/`reqwest`.

### 13.10.2 Final thoughts

* **Safety and predictability:** the compiler prevents entire classes of bugs (wrong types, nulls, silent failures).
* **Performance:** no GC; efficient IO/CPU; `sqlx` and Axum are async with low overhead.
* **Ergonomics:** more verbosity upfront (types, `Result`, ownership), but linear handlers with `?` and `IntoResponse`.
* **Architecture:** separating `models`, `handlers`, `db`, `routes` makes testing and evolution easier.
* **Trade‑offs:** longer compile times and the borrow checker learning curve.

**Next steps**

* Pagination and filters in `/users`.
* Migrations (`sqlx::migrate!`) and indexes.
* Authentication (JWT), CORS, rate‑limiting (`tower` layer).
* Integration tests (`#[tokio::test]` + `reqwest`).
* Observability: `tracing` spans, metrics, `tower-http` for logs.

> Congrats! We’ve wrapped up the CRUD project. From here, you have the practical foundation to design idiomatic APIs in Rust.

---

## Appendix A — `README.md` snippet

````markdown
# Axum CRUD — Final Project (Rust for JS Devs)

Backend: **Axum 0.7 + SQLite (SQLx)**.

## Run
```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
# → Server on http://127.0.0.1:3000
````

## Endpoints

* `GET /users` — list
* `POST /users` — create `{ name, email }`
* `GET /users/:id` — fetch by id
* `PUT /users/:id` — partial update `{ name?, email? }`
* `DELETE /users/:id` — remove

````

## Appendix B — CORS tip (optional)

```toml
# Cargo.toml
tower-http = { version = "0.5", features = ["cors"] }
````

```rust
// in main.rs, before serve()
use tower_http::cors::CorsLayer;
let app = routes::app(state).layer(CorsLayer::permissive());
```

## Appendix C — Axum 0.6 → 0.7 migration (summary)

* **Before (0.6):** `axum::Server::bind(addr).serve(app.into_make_service())`.
* **Now (0.7):** `let listener = TcpListener::bind(addr).await?; axum::serve(listener, app).await?;`.
* Handlers still implement `IntoResponse`/`Result<T, E>`; routing remains with `get/post/put/delete`.

# Chapter 13 — Final Project: CRUD Server with Rust, Axum, and SQLite (Axum 0.7)

In this chapter, we’ll consolidate what you’ve learned by building a real project: a fully‑featured **CRUD** server using **Rust**, the **Axum** framework, and **SQLite**.

Our goal is to **migrate the logic of a traditional Express.js server** to Rust — showing that you can write modern, safe, high‑performance APIs with static typing and zero runtime overhead.

---

## Project overview

### What we’ll build

* RESTful endpoints: `GET`, `POST`, `PUT`, `DELETE`.
* Persistence with SQLite.
* Strongly typed structs and enums.
* Error handling with `Result` and conversion to HTTP responses.
* Modular, scalable architecture.

### Stack comparison

| Component  | JavaScript (Express)      | Rust (Axum)                |
| ---------- | ------------------------- | -------------------------- |
| Framework  | Express                   | Axum                       |
| Database   | SQLite (`sqlite3`)        | SQLite (`sqlx`)            |
| Routing    | `app.get()`, `app.post()` | `Router::new().route(...)` |
| Middleware | Custom functions          | `tower` middleware         |
| Typing     | Dynamic                   | Static (structs + enums)   |

---

## Chapter structure

1. **Project setup**: dependencies, layout, and SQLite
2. **Express version**: a minimal JavaScript CRUD
3. **Axum version**: step‑by‑step rewrite in Rust
4. **Side‑by‑side comparison**: safety and performance in Rust
5. **Testing & usage**: `curl`, validations, and logging
6. **Wrap‑up**: benefits and trade‑offs of Rust on the backend

---

## 13.1 — Setup: Axum + SQLite

Create a new Rust project with Cargo and add the required dependencies.

### Step 1: create the project

```bash
cargo new axum_crud_project
cd axum_crud_project
```

### Step 2: add dependencies to `Cargo.toml`

> **Axum 0.7**: we use the current API with `axum::serve` (no `into_make_service`).

```toml
[package]
name = "axum_crud_project"
version = "0.1.0"
edition = "2021"

[dependencies]
axum = "0.7"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
sqlx = { version = "0.7", features = ["sqlite", "runtime-tokio-rustls"] }
tower = "0.4"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["fmt", "env-filter"] }
```

### Step 3: folder structure

```
src/
├── main.rs          # entry point
├── db.rs            # SQLite setup and connection pool
├── handlers.rs      # route logic
├── models.rs        # data types and errors
└── routes.rs        # route composition
```

> We’ll keep things modular for reuse and easier testing.

---

## 13.2 — Reference: Express.js version (JavaScript)

Before the Rust version, here’s a minimal CRUD with Express and SQLite **including `name` and `email`** (to stay consistent with the Rust version):

```js
const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const app = express();
app.use(express.json());

const db = new sqlite3.Database(":memory:");
db.serialize(() => {
  db.run("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE)");
});

app.get("/users", (req, res) => {
  db.all("SELECT id, name, email FROM users ORDER BY id", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

app.get("/users/:id", (req, res) => {
  db.get("SELECT id, name, email FROM users WHERE id = ?", [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: "not found" });
    res.json(row);
  });
});

app.post("/users", (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: "name and email are required" });
  db.run("INSERT INTO users(name, email) VALUES(?, ?)", [name, email], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.status(201).json({ id: this.lastID, name, email });
  });
});

app.put("/users/:id", (req, res) => {
  const { name, email } = req.body;
  db.run(
    "UPDATE users SET name = COALESCE(?, name), email = COALESCE(?, email) WHERE id = ?",
    [name ?? null, email ?? null, req.params.id],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ updated: this.changes });
    }
  );
});

app.delete("/users/:id", (req, res) => {
  db.run("DELETE FROM users WHERE id = ?", [req.params.id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ deleted: this.changes });
  });
});

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
```

That’s the functionality we’ll reproduce with Axum.

---

## 13.3 — Booting a minimal Axum server (Axum 0.7)

> **Important change (0.6 → 0.7):** use `tokio::net::TcpListener` and `axum::serve(listener, app)`. We no longer use `into_make_service()`.

```rust
use axum::{Router, routing::get};
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(|| async { "Hello from Axum!" }));

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("Listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

---

## 13.4 — `models.rs`

Data models, input/output types, and the application error converted into an HTTP response.

```rust
// src/models.rs
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use axum::{http::StatusCode, response::{IntoResponse, Response}, Json};
use serde_json::json;
use thiserror::Error;

#[derive(Debug, Serialize, FromRow)]
pub struct User {
    pub id: i64,
    pub name: String,
    pub email: String,
}

#[derive(Debug, Deserialize)]
pub struct NewUser {
    pub name: String,
    pub email: String,
}

#[derive(Debug, Deserialize)]
pub struct UpdateUser {
    pub name: Option<String>,
    pub email: Option<String>,
}

#[derive(Debug, Error)]
pub enum AppError {
    #[error("not found")]
    NotFound,
    #[error(transparent)]
    Sqlx(#[from] sqlx::Error),
    #[error("invalid input: {0}")]
    BadRequest(String),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, msg) = match &self {
            AppError::NotFound => (StatusCode::NOT_FOUND, self.to_string()),
            AppError::Sqlx(_) => (StatusCode::INTERNAL_SERVER_ERROR, "database error".to_string()),
            AppError::BadRequest(m) => (StatusCode::BAD_REQUEST, m.clone()),
        };
        (status, Json(json!({"error": msg}))).into_response()
    }
}

pub type Result<T> = std::result::Result<T, AppError>;
```

**Notes**

* `FromRow` maps SQLite columns to the struct.
* `AppError` centralizes errors and becomes an HTTP response via `IntoResponse`.

---

## 13.5 — `db.rs`

Database connection and initialization.

```rust
// src/db.rs
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

    // Minimal table (use migrations in production)
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS users (
            id     INTEGER PRIMARY KEY AUTOINCREMENT,
            name   TEXT NOT NULL,
            email  TEXT NOT NULL UNIQUE
        )
        "#,
    )
    .execute(&pool)
    .await?;

    Ok(pool)
}
```

---

## 13.6 — `handlers.rs`

Functions that handle each route.

```rust
// src/handlers.rs
use axum::{extract::{Path, State}, http::StatusCode, Json};
use crate::{db::AppState, models::{AppError, Result, User, NewUser, UpdateUser}};

pub async fn list_users(State(state): State<AppState>) -> Result<Json<Vec<User>>> {
    let users = sqlx::query_as::<_, User>("SELECT id, name, email FROM users ORDER BY id")
        .fetch_all(&state.pool)
        .await?;
    Ok(Json(users))
}

pub async fn get_user(Path(id): Path<i64>, State(state): State<AppState>) -> Result<Json<User>> {
    let user = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_optional(&state.pool)
        .await?;

    match user { Some(u) => Ok(Json(u)), None => Err(AppError::NotFound) }
}

pub async fn create_user(State(state): State<AppState>, Json(payload): Json<NewUser>)
    -> Result<(StatusCode, Json<User>)>
{
    if payload.name.trim().is_empty() || payload.email.trim().is_empty() {
        return Err(AppError::BadRequest("name and email are required".into()));
    }

    let result = sqlx::query("INSERT INTO users (name, email) VALUES (?, ?)")
        .bind(&payload.name)
        .bind(&payload.email)
        .execute(&state.pool)
        .await?;

    let id = result.last_insert_rowid();
    let created = User { id, name: payload.name, email: payload.email };
    Ok((StatusCode::CREATED, Json(created)))
}

pub async fn update_user(
    Path(id): Path<i64>,
    State(state): State<AppState>,
    Json(payload): Json<UpdateUser>,
) -> Result<Json<User>> {
    // Partial update with COALESCE
    sqlx::query(
        "UPDATE users SET name = COALESCE(?, name), email = COALESCE(?, email) WHERE id = ?",
    )
    .bind(payload.name)
    .bind(payload.email)
    .bind(id)
    .execute(&state.pool)
    .await?;

    let updated = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_optional(&state.pool)
        .await?;

    match updated { Some(u) => Ok(Json(u)), None => Err(AppError::NotFound) }
}

pub async fn delete_user(Path(id): Path<i64>, State(state): State<AppState>) -> Result<StatusCode> {
    let rows = sqlx::query("DELETE FROM users WHERE id = ?")
        .bind(id)
        .execute(&state.pool)
        .await?
        .rows_affected();

    if rows == 0 { return Err(AppError::NotFound); }

    Ok(StatusCode::NO_CONTENT)
}
```

---

## 13.7 — `routes.rs`

Define routes and build the `Router` (with typed state):

```rust
// src/routes.rs
use axum::{routing::{get, post, put, delete}, Router};
use crate::{db::AppState, handlers};

pub fn app(state: AppState) -> Router {
    Router::new()
        .route("/users", get(handlers::list_users).post(handlers::create_user))
        .route("/users/:id", get(handlers::get_user).put(handlers::update_user).delete(handlers::delete_user))
        .with_state(state)
}
```

> You can also import only `get` and then chain `.post/.put/.delete` as methods.

---

## 13.8 — `main.rs` (final version)

Wires everything together: app state, routes, logging, and server.

```rust
// src/main.rs
mod db;
mod handlers;
mod models;
mod routes;

use std::net::SocketAddr;
use tracing_subscriber::{fmt, EnvFilter};

#[tokio::main]
async fn main() {
    // simple logging (RUST_LOG=info by default, override via env)
    let _ = fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .try_init();

    // DATABASE_URL, e.g. sqlite://data/axum.db?mode=rwc
    let database_url = std::env::var("DATABASE_URL").unwrap_or_else(|_| "sqlite://data/axum.db?mode=rwc".into());

    let pool = db::init_db(&database_url).await.expect("db init failed");
    let state = db::AppState { pool };

    let app = routes::app(state);

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    tracing::info!("listening on http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.expect("bind failed");
    axum::serve(listener, app).await.expect("server error");
}
```

> **Axum 0.7:** we use `TcpListener` + `axum::serve` (no `into_make_service`).

---

## 13.9 — Quick `curl` tests

Create, list, update, and delete users.

```bash
# create (with name and email)
curl -sS -X POST http://127.0.0.1:3000/users \
  -H 'content-type: application/json' \
  -d '{"name":"Ada Lovelace","email":"ada@calc.org"}' | jq

# list
curl -sS http://127.0.0.1:3000/users | jq

# fetch by id
curl -sS http://127.0.0.1:3000/users/1 | jq

# partial update (name only)
curl -sS -X PUT http://127.0.0.1:3000/users/1 \
  -H 'content-type: application/json' \
  -d '{"name":"Ada L."}' | jq

# delete
curl -i -X DELETE http://127.0.0.1:3000/users/1
```

**Tip:** ensure the DB file exists by using a `data/` folder and setting the URL:

```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
```

---

## 13.10 — Express ↔ Axum comparison and final thoughts

### 13.10.1 Express ↔ Axum comparison

| Topic        | Express (JS)                              | Axum (Rust)                                                    |
| ------------ | ----------------------------------------- | -------------------------------------------------------------- |
| Server boot  | `const app = express(); app.listen(3000)` | `let app = Router::new(); axum::serve(TcpListener, app)`       |
| Routes       | `app.get("/users", handler)`              | `Router::new().route("/users", get(handler))`                  |
| Path params  | `req.params.id`                           | `Path<i64>` in the handler                                     |
| Query params | `req.query`                               | `Query<T>` (with `serde::Deserialize`)                         |
| JSON body    | `app.use(express.json())` + `req.body`    | `Json<T>` (with `serde::Deserialize`)                          |
| Responses    | `res.status(201).json({...})`             | `impl IntoResponse`, `Json(...)`, `StatusCode`                 |
| Middleware   | `app.use(mw)`                             | `tower` layers: `.layer(...)` or `middleware::from_fn`         |
| SQLite       | `sqlite3` callbacks                       | Async `sqlx` (`query`, `query_as`), compile‑time type checking |
| Logging      | `morgan("dev")`                           | `tracing` + `tracing-subscriber`                               |
| Config/env   | `process.env.X`                           | `std::env::var("X")`                                           |
| HTTP tests   | `supertest`/Jest                          | `reqwest` + `#[tokio::test]` (building a `Router`)             |
| Hot reload   | `nodemon`                                 | `cargo watch -x run`                                           |

#### Side‑by‑side examples

Express (GET):

```js
app.get("/users/:id", async (req, res) => {
  const id = Number(req.params.id);
  const row = await getUser(id);
  if (!row) return res.status(404).json({ error: "not found" });
  res.json(row);
});
```

Axum (GET):

```rust
pub async fn get_user(Path(id): Path<i64>, State(state): State<AppState>) -> Result<Json<User>> {
    let user = sqlx::query_as::<_, User>("SELECT id, name, email FROM users WHERE id = ?")
        .bind(id)
        .fetch_optional(&state.pool)
        .await?;
    user.map(Json).ok_or(AppError::NotFound)
}
```

#### Migration checklist: Express → Axum

1. Define models (`struct`) with `serde` (`Serialize`/`Deserialize`).
2. Create `AppError` and a `Result<T>` alias; implement `IntoResponse`.
3. Configure `SqlitePool` in `db.rs` and initialize the table.
4. Write handlers returning `Result<...>` and use `?`.
5. Build the `Router` in `routes.rs` and inject `AppState` with `.with_state(...)`.
6. Wire everything in `main.rs`, read `DATABASE_URL`.
7. Add `tracing` and, if needed, `tower` middlewares.
8. Test with `curl`/`reqwest`.

### 13.10.2 Final thoughts

* **Safety and predictability:** the compiler prevents entire classes of bugs (wrong types, nulls, silent failures).
* **Performance:** no GC; efficient IO/CPU; `sqlx` and Axum are async with low overhead.
* **Ergonomics:** more verbosity upfront (types, `Result`, ownership), but linear handlers with `?` and `IntoResponse`.
* **Architecture:** separating `models`, `handlers`, `db`, `routes` makes testing and evolution easier.
* **Trade‑offs:** longer compile times and the borrow checker learning curve.

**Next steps**

* Pagination and filters in `/users`.
* Migrations (`sqlx::migrate!`) and indexes.
* Authentication (JWT), CORS, rate‑limiting (`tower` layer).
* Integration tests (`#[tokio::test]` + `reqwest`).
* Observability: `tracing` spans, metrics, `tower-http` for logs.

> Congrats! We’ve wrapped up the CRUD project. From here, you have the practical foundation to design idiomatic APIs in Rust.

---

## Appendix A — `README.md` snippet

````markdown
# Axum CRUD — Final Project (Rust for JS Devs)

Backend: **Axum 0.7 + SQLite (SQLx)**.

## Run
```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
# → Server on http://127.0.0.1:3000
````

## Endpoints

* `GET /users` — list
* `POST /users` — create `{ name, email }`
* `GET /users/:id` — fetch by id
* `PUT /users/:id` — partial update `{ name?, email? }`
* `DELETE /users/:id` — remove

````

## Appendix B — CORS tip (optional)

```toml
# Cargo.toml
tower-http = { version = "0.5", features = ["cors"] }
````

```rust
// in main.rs, before serve()
use tower_http::cors::CorsLayer;
let app = routes::app(state).layer(CorsLayer::permissive());
```

## Appendix C — Axum 0.6 → 0.7 migration (summary)

* **Before (0.6):** `axum::Server::bind(addr).serve(app.into_make_service())`.
* **Now (0.7):** `let listener = TcpListener::bind(addr).await?; axum::serve(listener, app).await?;`.
* Handlers still implement `IntoResponse`/`Result<T, E>`; routing remains with `get/post/put/delete`.


> Next: **Object Oriented Programming (OOP) Without Classes in Rust**

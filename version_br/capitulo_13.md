# Capítulo 13 — Projeto final: Servidor CRUD com Rust, Axum e SQLite (Axum 0.7)

Neste capítulo, vamos consolidar o que você aprendeu construindo um projeto real: um servidor **CRUD** completo usando **Rust**, o framework **Axum** e o banco **SQLite**.

Nosso objetivo é **migrar a lógica de um servidor Express.js** tradicional para Rust — mostrando que é possível escrever APIs modernas, seguras e performáticas com tipagem estática e zero overhead em tempo de execução.

---

## Visão geral do projeto -  Código fonte em: https://github.com/fsegall/js_to_rust

### O que vamos construir

* Endpoints RESTful `GET`, `POST`, `PUT`, `DELETE`.
* Persistência com SQLite.
* Structs e enums fortemente tipados.
* Tratamento de erros com `Result` e conversão para respostas HTTP.
* Arquitetura modular e escalável.

### Comparativo de stack

| Componente | JavaScript (Express)      | Rust (Axum)                |
| ---------- | ------------------------- | -------------------------- |
| Framework  | Express                   | Axum                       |
| Banco      | SQLite (`sqlite3`)        | SQLite (`sqlx`)            |
| Rotas      | `app.get()`, `app.post()` | `Router::new().route(...)` |
| Middleware | Funções personalizadas    | Middleware `tower`         |
| Tipagem    | Dinâmica                  | Estática (structs + enums) |

---

## Estrutura do capítulo

1. **Configuração do projeto**: dependências, layout e SQLite
2. **Versão Express**: CRUD mínimo em JavaScript
3. **Versão Axum**: reescrita passo a passo em Rust
4. **Comparação lado a lado**: segurança e desempenho no Rust
5. **Testes e uso**: `curl`, validações e logging
6. **Fechamento**: benefícios e trade‑offs de Rust no backend

---

## 13.1 — Setup: Axum + SQLite

Crie um novo projeto Rust com Cargo e adicione as dependências necessárias.

### Passo 1: criar o projeto

```bash
cargo new axum_crud_project
cd axum_crud_project
```

### Passo 2: adicionar dependências em `Cargo.toml`

> **Axum 0.7**: usaremos a API atual com `axum::serve` (sem `into_make_service`).

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

### Passo 3: estrutura de pastas

```
src/
├── main.rs          # ponto de entrada
├── db.rs            # setup do SQLite e pool de conexões
├── handlers.rs      # lógica das rotas
├── models.rs        # tipos de dados e erros
└── routes.rs        # composição das rotas
```

> Manteremos tudo modular para facilitar reuso e testes.

---

## 13.2 — Referência: versão Express.js (JavaScript)

Antes da versão em Rust, um CRUD mínimo com Express e SQLite \*\*incluindo ****`name`**** e \*\***`email`** (para manter consistência com a versão Rust):

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

Essa é a funcionalidade que vamos reproduzir com Axum.

---

## 13.3 — Subindo o servidor Axum mínimo (Axum 0.7)

> **Mudança importante (0.6 → 0.7):** use `tokio::net::TcpListener` e `axum::serve(listener, app)`. Não usamos mais `into_make_service()`.

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

Modelos de dados, tipos de entrada/saída e erro da aplicação com conversão para resposta HTTP.

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

**Notas**

* `FromRow` mapeia colunas do SQLite para o `struct`.
* `AppError` centraliza erros e vira resposta HTTP via `IntoResponse`.

---

## 13.5 — `db.rs`

Conexão e inicialização do banco.

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

    // Tabela mínima (use migrações em produção)
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

Funções que tratam cada rota.

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
    // Atualização parcial com COALESCE
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

Define as rotas e monta o `Router` (com estado tipado):

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

> Você também pode importar só `get` e encadear `.post/.put/.delete` como métodos.

---

## 13.8 — `main.rs` (versão final)

Integra tudo: estado da aplicação, rotas, logging e servidor.

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
    // logging simples (RUST_LOG=info por padrão, sobrescreva via env)
    let _ = fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .try_init();

    // DATABASE_URL, ex.: sqlite://data/axum.db?mode=rwc
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

> **Axum 0.7:** repare que usamos `TcpListener` + `axum::serve` (sem `into_make_service`).

---

## 13.9 — Testes rápidos com `curl`

Crie, liste, atualize e remova usuários.

```bash
# criar (com name e email)
curl -sS -X POST http://127.0.0.1:3000/users \
  -H 'content-type: application/json' \
  -d '{"name":"Ada Lovelace","email":"ada@calc.org"}' | jq

# listar
curl -sS http://127.0.0.1:3000/users | jq

# buscar por id
curl -sS http://127.0.0.1:3000/users/1 | jq

# atualizar parcial (só name)
curl -sS -X PUT http://127.0.0.1:3000/users/1 \
  -H 'content-type: application/json' \
  -d '{"name":"Ada L."}' | jq

# remover
curl -i -X DELETE http://127.0.0.1:3000/users/1
```

**Dica:** garanta o arquivo do banco com uma pasta `data/` e setando a URL:

```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
```

---

## 13.10 — Comparação Express ↔ Axum e Considerações finais

### 13.10.1 Comparação Express ↔ Axum

| Tema                      | Express (JS)                              | Axum (Rust)                                                |
| ------------------------- | ----------------------------------------- | ---------------------------------------------------------- |
| Inicialização do servidor | `const app = express(); app.listen(3000)` | `let app = Router::new(); axum::serve(TcpListener, app)`   |
| Rotas                     | `app.get("/users", handler)`              | `Router::new().route("/users", get(handler))`              |
| Path params               | `req.params.id`                           | `Path<i64>` no handler                                     |
| Query params              | `req.query`                               | `Query<T>` (com `serde::Deserialize`)                      |
| Body JSON                 | `app.use(express.json())` + `req.body`    | `Json<T>` (com `serde::Deserialize`)                       |
| Respostas                 | `res.status(201).json({...})`             | `impl IntoResponse`, `Json(...)`, `StatusCode`             |
| Middleware                | `app.use(mw)`                             | `tower` layers: `.layer(...)` ou `middleware::from_fn`     |
| Erros                     | `try/catch`, `next(err)`                  | `Result<T, AppError>` + `?` + `IntoResponse`               |
| Banco SQLite              | `sqlite3` callbacks                       | `sqlx` assíncrono (`query`, `query_as`), checagem de tipos |
| Log                       | `morgan("dev")`                           | `tracing` + `tracing-subscriber`                           |
| Config/env                | `process.env.X`                           | `std::env::var("X")`                                       |
| Testes HTTP               | `supertest`/Jest                          | `reqwest` + `#[tokio::test]` (montando o `Router`)         |
| Hot reload                | `nodemon`                                 | `cargo watch -x run`                                       |

#### Exemplos lado a lado

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

#### Checklist de migração Express → Axum

1. Defina modelos (`struct`) com `serde` (`Serialize`/`Deserialize`).
2. Crie `AppError` e um alias `Result<T>`; implemente `IntoResponse`.
3. Configure `SqlitePool` em `db.rs` e inicialize a tabela.
4. Escreva handlers retornando `Result<...>` e usando `?`.
5. Monte o `Router` em `routes.rs` e injete `AppState` com `.with_state(...)`.
6. Ligue tudo em `main.rs`, leia `DATABASE_URL`.
7. Adicione `tracing` e, se necessário, middlewares de `tower`.
8. Teste com `curl`/`reqwest`.

### 13.10.2 Considerações finais

* **Segurança e previsibilidade:** o compilador evita categorias inteiras de bugs (tipos errados, null, erros silenciosos).
* **Performance:** sem GC, IO/CPU eficientes; `sqlx` e Axum assíncronos e de baixo overhead.
* **Ergonomia:** mais verbosidade no início (tipos, `Result`, ownership), mas handlers lineares com `?` e `IntoResponse`.
* **Arquitetura:** separar `models`, `handlers`, `db`, `routes` facilita testes e evolução.
* **Trade‑offs:** tempos de compilação maiores e curva de aprendizado do borrow checker.

**Próximos passos**

* Paginação e filtros em `/users`.
* Migrações (`sqlx::migrate!`) e índices.
* Autenticação (JWT), CORS, rate‑limit (camada `tower`).
* Testes de integração (`#[tokio::test]` + `reqwest`).
* Observabilidade: spans do `tracing`, métricas, `tower-http` para logs.

\> Parabéns!!! Fechamos o projeto CRUD. A partir daqui, você tem base prática para projetar APIs idiomáticas em Rust.

---

## Anexo A — Snippet de `README.md`

````markdown
# Axum CRUD — Final Project (Rust for JS Devs)

Backend em **Axum 0.7 + SQLite (SQLx)**.

## Rodando
```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
# → Server on http://127.0.0.1:3000
````

## Endpoints

* `GET /users` — lista
* `POST /users` — cria `{ name, email }`
* `GET /users/:id` — busca
* `PUT /users/:id` — atualiza parcial `{ name?, email? }`
* `DELETE /users/:id` — remove

````

## Anexo B — Dica de CORS (opcional)

```toml
# Cargo.toml
tower-http = { version = "0.5", features = ["cors"] }
````

```rust
// no main.rs, antes do serve()
use tower_http::cors::CorsLayer;
let app = routes::app(state).layer(CorsLayer::permissive());
```

## Anexo C — Migração Axum 0.6 → 0.7 (resumo)

* **Antes (0.6):** `axum::Server::bind(addr).serve(app.into_make_service())`.
* **Agora (0.7):** `let listener = TcpListener::bind(addr).await?; axum::serve(listener, app).await?;`.
* Handlers continuam implementando `IntoResponse`/`Result<T, E>`; roteamento permanece com `get/post/put/delete`.

> Next: **Object Oriented Programming (OOP) Sem Classes em Rust**
# Final Project — Axum + SQLx CRUD Server (SQLite) - /server

This folder contains a minimal but production‑shaped HTTP API written in **Rust** using **Axum** and **SQLx** with **SQLite**. It mirrors the Express.js CRUD example from the book and demonstrates typed handlers, explicit error handling, and a simple layered structure.

## Features

* REST endpoints: `GET /users`, `GET /users/:id`, `POST /users`, `PUT /users/:id`, `DELETE /users/:id`
* SQLite persistence via `sqlx`
* Typed request/response payloads with `serde`
* Centralized error type that implements `IntoResponse`
* `tracing` logging and small, modular layout (`models`, `db`, `handlers`, `routes`)

## Prerequisites

* Rust (stable) and Cargo
* SQLite available on your system

## Quickstart

```bash
# 1) Set the DB path (file will be created if missing)
export DATABASE_URL="sqlite://axum.db"

# 2) Run the server
cargo run
# Server will listen on http://127.0.0.1:3000
```

> The app auto‑creates the `users` table on startup for simplicity. For real projects, prefer SQLx migrations.

## API

### Create

```bash
curl -sS -X POST http://localhost:3000/users \
  -H 'content-type: application/json' \
  -d '{"name":"Laura"}' | jq
```

### List

```bash
curl -sS http://localhost:3000/users | jq
```

### Get by id

```bash
curl -sS http://localhost:3000/users/1 | jq
```

### Update

```bash
curl -sS -X PUT http://localhost:3000/users/1 \
  -H 'content-type: application/json' \
  -d '{"name":"Paulo"}' | jq
```

### Delete

```bash
curl -i -X DELETE http://localhost:3000/users/1
```

## Layout

```
src/
├─ db.rs         # SQLite pool + schema bootstrap
├─ handlers.rs   # Route handlers (CRUD)
├─ models.rs     # DTOs, error type, Result alias
├─ routes.rs     # Router wiring
└─ main.rs       # Startup, logging, server
```

## Notes

* Error handling is explicit: handlers return `Result<T, AppError>`; `?` propagates failures; `AppError` implements `IntoResponse`.
* For migrations: create a `migrations/` folder and use `sqlx::migrate!()` at startup. Alternatively, use `sqlx-cli`.
* For production: add middlewares (`tower`/`tower-http`) for CORS, request logging, timeouts, and authentication.

## Troubleshooting

* Missing `DATABASE_URL`: set `export DATABASE_URL="sqlite://axum.db"`.
* SQLite file permissions: ensure the process can create/read/write the file.
* Build errors on Windows: install C++ Build Tools ("Desktop development with C++") and restart the terminal.

## License

MIT (adapt as needed).

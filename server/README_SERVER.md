# Axum CRUD — Final Project (Rust for JS Devs)

Backend - **Axum 0.7 + SQLite (SQLx)**.

## Run
```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
# → Server on http://127.0.0.1:3000
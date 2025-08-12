# Chapter 2 — Setting up your Rust environment

Before writing your first line of Rust, let’s set up a productive and predictable environment.

## 2.1 Install with `rustup`

The recommended way to install Rust is **rustup**, which manages toolchains and components:

* Linux/macOS: run the official rustup install script (from the Rust website).
* Windows: use the rustup installer for Windows.

After installation, close and reopen your terminal so environment variables are refreshed.

### Verify the installation

```bash
rustc --version
cargo --version
rustup --version
```

If all three respond, you’re good to go.

### Select and update the stable toolchain

```bash
rustup default stable
rustup update
```

### Useful components

```bash
rustup component add rustfmt
rustup component add clippy
```

* **rustfmt** formats code automatically.
* **clippy** provides lints to improve readability and avoid pitfalls.

## 2.2 Editor and extension

Use any editor you like, but **VS Code + rust-analyzer** gives you:

* smart autocomplete,
* symbol navigation,
* real-time diagnostics,
* format on save.

Suggested settings (VS Code → *settings.json*):

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "rust-lang.rust-analyzer",
  "rust-analyzer.check.command": "clippy",
  "rust-analyzer.cargo.extraEnv": {
    "RUSTFLAGS": "-Dwarnings"
  }
}
```

> `RUSTFLAGS=-Dwarnings` treats warnings as errors when building from the editor, keeping quality high from day one.

## 2.3 Your first project with Cargo

**Cargo** is Rust’s package manager and build system.

Create a new project:

```bash
cargo new hello_rust
cd hello_rust
```

Initial layout:

```
hello_rust/
├─ Cargo.toml
└─ src/
   └─ main.rs
```

Default `src/main.rs`:

```rust
fn main() {
    println!("Hello, world!");
}
```

Run it:

```bash
cargo run
```

Other useful commands:

```bash
cargo check   # quick type/borrow checking without producing a final binary
cargo build   # compiles to target/debug
cargo test    # runs tests
cargo fmt     # formats code (rustfmt)
cargo clippy  # clippy lints
```

## 2.4 Understanding `Cargo.toml`

`Cargo.toml` plays the role of your `package.json`, describing metadata and dependencies:

```toml
[package]
name = "hello_rust"
version = "0.1.0"
edition = "2021"

[dependencies]
# example: serde = { version = "1", features = ["derive"] }
```

* `[package]` holds project metadata.
* `[dependencies]` lists third-party crates (like npm packages, but resolved via **crates.io**).
* You can also have `[dev-dependencies]` for test-only or example-only dependencies.

## 2.5 Comparing mental models (JS/TS ↔ Rust)

| Task               | JS/TS                    | Rust                                  |
| ------------------ | ------------------------ | ------------------------------------- |
| Create project     | `npm init` / `pnpm init` | `cargo new`                           |
| Install dependency | `npm install package`    | add to `Cargo.toml` and `cargo build` |
| Run app            | `npm run start`          | `cargo run`                           |
| Lint/format        | ESLint / Prettier        | `cargo clippy` / `cargo fmt`          |
| Types              | TypeScript (optional)    | Built-in static typing                |

The workflow will feel familiar: scripts to run, a manifest file, and a package registry. The difference is that the **compiler** participates more, enforcing correctness and performance during edit/compile cycles.

## 2.6 Troubleshooting tips

* **`cargo` not found**: reopen the terminal or ensure `~/.cargo/bin` (Linux/macOS) is on `PATH`.
* **Windows (Build Tools)**: if you hit linker/C toolchain errors, install "Desktop development with C++" (Build Tools) and restart the terminal.
* **Linux permissions**: avoid system package managers if `rustup` is available; keeping everything under `rustup` simplifies updates.

## 2.7 Next step

With your environment ready, let’s start with language fundamentals: working with **variables, types, and functions** in the next chapter.

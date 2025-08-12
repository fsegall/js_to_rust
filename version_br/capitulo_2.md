# Capítulo 2 — Preparando seu ambiente Rust

Antes de escrever sua primeira linha em Rust, vamos preparar o ambiente para que tudo funcione com produtividade e previsibilidade.

## 2.1 Instalação com `rustup`

A forma recomendada de instalar Rust é com o **rustup**, que gerencia versões (toolchains) e componentes:

* Linux/macOS: execute o script oficial de instalação do rustup (site oficial do Rust).
* Windows: use o instalador do rustup para Windows.

Depois da instalação, feche e reabra o terminal para garantir que as variáveis de ambiente foram atualizadas.

### Verifique a instalação

```bash
rustc --version
cargo --version
rustup --version
```

Se os três comandos responderem, você está pronto.

### Selecionar e atualizar a toolchain estável

```bash
rustup default stable
rustup update
```

### Componentes úteis

```bash
rustup component add rustfmt
rustup component add clippy
```

* **rustfmt** formata código automaticamente.
* **clippy** oferece lints (dicas) para melhorar legibilidade e evitar armadilhas.

## 2.2 Editor e extensão

Use qualquer editor, mas a combinação **VS Code + rust-analyzer** oferece:

* autocompletar inteligente,
* navegação por símbolos,
* erros em tempo real,
* formatar ao salvar.

Configurações sugeridas (VS Code → *settings.json*):

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

> `RUSTFLAGS=-Dwarnings` trata *warnings* como erros ao compilar pelo editor, mantendo o padrão alto desde o início.

## 2.3 Seu primeiro projeto com Cargo

O **Cargo** é o *package manager* e sistema de build de Rust.

Crie um projeto novo:

```bash
cargo new hello_rust
cd hello_rust
```

Estrutura inicial:

```
hello_rust/
├─ Cargo.toml
└─ src/
   └─ main.rs
```

Conteúdo padrão de `src/main.rs`:

```rust
fn main() {
    println!("Hello, world!");
}
```

Execute:

```bash
cargo run
```

Outros comandos úteis:

```bash
cargo check   # checa rapidamente tipos/erros sem gerar binário final
cargo build   # compila para target/debug
cargo test    # roda testes
cargo fmt     # formata o código (rustfmt)
cargo clippy  # lints do Clippy
```

## 2.4 Entendendo o `Cargo.toml`

O arquivo `Cargo.toml` cumpre o papel do seu `package.json`, descrevendo metadados e dependências:

```toml
[package]
name = "hello_rust"
version = "0.1.0"
edition = "2021"

[dependencies]
# exemplo: serde = { version = "1", features = ["derive"] }
```

* `[package]` contém metadados do projeto.
* `[dependencies]` lista crates de terceiros (da mesma forma que pacotes npm, mas com resolução via **crates.io**).
* Você também pode ter `[dev-dependencies]` para dependências usadas só em testes e exemplos.

## 2.5 Comparando mental models (JS/TS ↔ Rust)

| Tarefa               | JS/TS                    | Rust                                     |
| -------------------- | ------------------------ | ---------------------------------------- |
| Criar projeto        | `npm init` / `pnpm init` | `cargo new`                              |
| Instalar dependência | `npm install pacote`     | adicione no `Cargo.toml` e `cargo build` |
| Rodar app            | `npm run start`          | `cargo run`                              |
| Lint/format          | ESLint / Prettier        | `cargo clippy` / `cargo fmt`             |
| Tipos                | TypeScript (opcional)    | Tipagem estática integrada               |

A ideia é familiar: scripts para rodar, um arquivo de manifesto e um registrador de pacotes. A diferença é que o **compilador** participa mais, garantindo correção e performance já no ciclo de edição/compilação.

## 2.6 Dicas de solução de problemas

* **`cargo` não encontrado**: reabra o terminal ou garanta que o diretório `~/.cargo/bin` (Linux/macOS) esteja no `PATH`.
* **Windows (Build Tools)**: se receber erros de *linker* ou compilador C, instale “Desktop development with C++” (Build Tools) e reinicie o terminal.
* **Permissões em Linux**: evite instalar via gerenciador do sistema se o `rustup` estiver disponível; manter tudo no `rustup` simplifica atualizações.

## 2.7 Próximo passo

Agora que o ambiente está pronto, vamos começar pelos fundamentos da linguagem: trabalhando com **variáveis, tipos e funções** no próximo capítulo.

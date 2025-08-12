# Introdução

Se você escreve JavaScript ou TypeScript, já carrega os modelos mentais de que precisamos: objetos e protótipos, módulos, promises, tratamento de erros, métodos de array e padrões funcionais. O objetivo deste livro é **traduzir esses modelos mentais de JS/TS para Rust**, não jogar jargão novo. Para cada prática que você já usa, mostramos o equivalente em Rust: objetos → `struct`/`enum`, módulos → crates/módulos, promises → *futures* assíncronas, `try/catch` → `Result<T, E>` + `?`, e *duck typing* ad hoc → **traits** com generics. O formato é leve: trechos curtos, lado a lado, com explicações suficientes para fazer a ponte com a sua intuição.

**O que você fará ao longo do livro**

* Capítulos **1–12**: conceitos em pequenas doses — valores vs. referências, ownership e borrowing (com analogias do dia a dia), *pattern matching*, generics, traits, iteradores, tratamento de erros, módulos e fundamentos de *async*. Em cada passo, há uma comparação **JS → Rust**.
* Capítulo **13**: tudo junto em um projeto prático — uma API HTTP com **Axum** e **SQLx**.
* Capítulo **14** (bônus): POO sem classes em Rust — structs + `impl`, traits e composição no lugar de herança.
* Capítulo **15**: **Tópicos avançados em Rust** — `Fn`/`FnMut`/`FnOnce`, *smart pointers* (`Box`, `Rc`, `RefCell`), padrões avançados de *pattern matching*, `impl Trait` em retornos e organização de código com módulos/visibilidade.

**Por que devs JS costumam gostar de Rust**

* História de *async* familiar (`async/await`) com **erros explícitos** (`Result` + `?`).
* Um compilador que age como um revisor, pegando bugs antes de chegarem à produção.
* Desempenho e previsibilidade sem *garbage collector*.

**Como ler este livro**

* Leia primeiro o snippet em JS e, em seguida, o equivalente em Rust logo abaixo.
* Não lute contra o *borrow checker*; pergunte o que ele quer e refatore. Mostramos os padrões mais úteis.
* Rode os exemplos. Vitórias pequenas se acumulam rápido.

Quando você chegar ao projeto final, Rust deve parecer menos uma linguagem nova e mais um dialeto mais rígido e rápido das ideias que você já usa no dia a dia. As comparações terão cumprido seu papel de **ponte**; a partir daí, você escreverá Rust de forma cada vez mais idiomática, sem precisar traduzir mentalmente a partir de JS.

> **Observação:** ao final do livro há um **apêndice unificado** que aprofunda (1) *duck typing* ad hoc e o modelo **estrutural** do TypeScript versus **traits** em Rust; e (2) os **receptores de método** em Rust (`&self`, `&mut self`, `self`) comparados a `this` (JS/TS) e `self`/`typing.Self` (Python). É uma boa referência rápida para consolidar a ponte JS → Rust.

> Próximo: **Capítulo 1 — Por que Rust? Comparando filosofias**.


# Capítulo 1 — Por que Rust? Comparando filosofias

Antes de entrar em ferramentas ou sintaxe, vale dar um passo atrás e perguntar:

**Por que aprender Rust sendo desenvolvedor JavaScript?**

Rust não veio para “substituir” JavaScript; os dois resolvem problemas diferentes. Entender a filosofia de Rust ajuda você a se adaptar às regras mais rígidas da linguagem e a destravar o seu potencial.

## A promessa de Rust: desempenho com garantias

Rust foi desenhada para responder à pergunta:

> *“É possível ter desempenho de baixo nível **sem** segfaults, condições de corrida de dados (data races) e vazamentos de memória?”*

**O que é “segfault” (falha de segmentação)?**
Em sistemas com memória protegida, cada processo só pode acessar endereços válidos do seu espaço de memória. Um *segmentation fault* acontece quando o programa tenta **ler ou escrever um endereço inválido** (por exemplo, ponteiro nulo/desalocado, acesso fora dos limites de um array, *use-after-free*, *stack overflow* ou tentar executar dados como código). O SO envia o sinal **SIGSEGV** e o processo cai. Em **Rust seguro**, essas classes de erro são prevenidas pelo modelo de **ownership/borrowing**, checagens de limites em *slices* e referências não nulas; ainda assim, código `unsafe` ou FFI mal utilizado podem reintroduzir riscos.

**O que é “data race” (condição de corrida de dados)?**
É quando **duas ou mais threads acessam a mesma região de memória ao mesmo tempo**, **pelo menos uma escreve**, e **não há sincronização** que estabeleça uma ordem (“happens‑before”) entre esses acessos. O resultado é comportamento indefinido: valores corrompidos, travamentos intermitentes, bugs difíceis de reproduzir. Em **Rust seguro**, data races são evitadas pelo sistema de tipos: ou você tem **múltiplas leituras compartilhadas** (`&T`), ou **uma única escrita exclusiva** (`&mut T`). Para compartilhar mutação entre threads, usa‑se **tipos de sincronização** (por exemplo, `Mutex<T>`, `RwLock<T>`, canais) e os *auto‑traits* `Send`/`Sync` garantem segurança na passagem de dados entre threads.

**O que é vazamento de memória?**
Em termos práticos, é quando um processo passa a consumir cada vez mais memória porque **blocos alocados nunca são liberados**. Em linguagens com GC, isso costuma ocorrer quando referências permanecem vivas (por exemplo, em caches ou variáveis globais), impedindo a coleta. Em linguagens com gerenciamento manual, surge ao esquecer de liberar (`free`/`delete`). Em Rust, o modelo de **ownership/borrowing** libera memória **deterministicamente** quando o dono sai de escopo, evitando classes inteiras de vazamentos e de *dangling pointers*. Vazamentos ainda são possíveis (por exemplo, ciclos com `Rc` ou uso deliberado de `std::mem::forget`/`Box::leak`), mas tendem a ser raros e explícitos no design.

Ela entrega:

* **Abstrações de custo zero**, tão rápidas quanto C/C++, com segurança
* **Segurança de memória sem garbage collector**
* **Garantias em tempo de compilação** para concorrência e correção

Para quem vem de JS, a sensação é sair de uma scooter (dinâmica, divertida) para pilotar um caça (estrito, potente, exige treino).

## Diferenças filosóficas: Rust vs JavaScript

| Conceito     | JavaScript                              | Rust                                           |
| ------------ | --------------------------------------- | ---------------------------------------------- |
| Tipagem      | Dinâmica, fraca (TS é opcional)         | Estática, forte, verificada em compilação      |
| Mutabilidade | Tudo mutável salvo `const`              | Tudo imutável salvo `mut`                      |
| Memória      | Coletor de lixo                         | Propriedade (ownership) e empréstimo (borrow)  |
| Erros        | `try/catch`, pode lançar qualquer coisa | `Result<T, E>` e `Option<T>` explícitos        |
| Concorrência | Event loop, `async/await`               | Threads, `async`, passagem de mensagens segura |
| Segurança    | Erros em tempo de execução, coerção     | Segurança em compilação, sem null por padrão   |
| Ferramentas  | Leves (npm, yarn, browser-first)        | Robustas (cargo, crates.io, systems-first)     |

## A grande mudança de mentalidade

O que pode surpreender:

* No Rust, o **compilador é seu parceiro**. Ele bloqueia o build até o código estar correto, o que parece chato no começo, mas rende a longo prazo.
* **Sem `null` ou `undefined`**; use `Option<T>`.
* **Tratamento de erros** não é um fallback de `try/catch`, faz parte do desenho da função.
* **Propriedade de memória** é regida por regras, não por convenções.
* **Concorrência** nasce segura graças ao borrow checker.

Rust ganhou reputação por combinar desempenho, confiabilidade e segurança de memória sem GC. Enquanto JavaScript domina a web pela flexibilidade, Rust oferece a chance de construir aplicações mais rápidas e seguras, especialmente em programação de sistemas, WebAssembly e outros cenários de alto desempenho.

Este livro é para **desenvolvedores JavaScript que querem aprender Rust de forma prática e rápida**, com exemplos lado a lado, destacando diferenças de sintaxe e adaptando seu modelo mental ao compilador e ao sistema de tipos de Rust.

## Para quem é

* Devs frontend ou backend em JS/TS
* Engenheiros de smart contracts vindos de stacks web3
* Builders de hackathon
* Quem quer subir o nível com uma linguagem de baixo nível

## O que você vai aprender

* Fundamentos de Rust (variáveis, funções, controle de fluxo)
* Ownership, borrowing e lifetimes, o núcleo de Rust
* Structs, enums e pattern matching
* Tratamento de erros ao estilo Rust
* Módulos, pacotes e testes
* Como **pensar em Rust** vindo de JS

## Estratégia de aprendizagem

Este é um livro **orientado a projetos**.

* Comparações curtas JS ↔ Rust
* Mini‑exercícios para fixação
* Exemplos simples, porém significativos
* Dicas práticas para migrar o modelo mental de JS para Rust

> Se Rust já te assustou, este capítulo é para você. Vamos suavizar a curva, de forma prática e direta.

Próximo passo: preparar o ambiente de desenvolvimento em Rust.


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


# Capítulo 3 — Variáveis, Tipos e Funções

Rust incentiva você a ser explícito sobre valores, mutabilidade e tipos. Se em JS você costuma mudar estruturas livremente, em Rust o código fica mais previsível: tudo é imutável por padrão e o compilador verifica tipos e contratos antes de rodar.

## 3.1 Declarando variáveis

Em Rust:

* Variáveis são **imutáveis por padrão**
* Use `mut` para torná-las mutáveis

```rust
fn main() {
    let name = "Felipe";     // imutável
    let mut age = 30;         // mutável

    // name = "Phillip";    // ❌ erro: `name` é imutável
    age += 1;                  // ✅ ok, `age` é mutável
}
```

Em JavaScript, a distinção é diferente:

```js
let name = "Felipe";   // mutável
const city = "SP";     // imutável na variável, mas o conteúdo pode variar em objetos
name = "Phillip";      // ✅ permitido com `let`
```

### Constantes

Em Rust, `const` exige **tipo explícito** e é avaliada em tempo de compilação.

```rust
const MAX_USERS: u32 = 1000;
```

### Shadowing

Você pode **sombrear** (redeclaração com `let`) para transformar ou refinar um valor sem torná-lo mutável.

```rust
let input = "42";
let input: i32 = input.parse().unwrap();
// `input` agora é i32, a versão parseada da string
```

## 3.2 Inferência e anotações de tipo

Rust infere tipos na maioria dos casos, mas você pode anotar quando for útil para clareza ou quando o compilador precisar de ajuda.

```rust
let x = 10;           // inferido como i32
let y: i64 = 10;      // anotado
let price = 9.99_f32; // sufixo explícito
```

## 3.3 Tipos primitivos essenciais

|       Categoria | Rust                                     | JS/TS (aproximação)                   |
| --------------: | ---------------------------------------- | ------------------------------------- |
|        Inteiros | `i8..i128`, `u8..u128`, `isize`, `usize` | `number` (inteiro em ponto flutuante) |
| Ponto flutuante | `f32`, `f64`                             | `number`                              |
|        Booleano | `bool`                                   | `boolean`                             |
|           Texto | `char`, `&str`, `String`                 | `string`                              |

> Dica: escolha `i32` e `f64` como padrão, a menos que haja motivo para outro tamanho.

### Strings rápidas

* `&str` é uma **string imutável** em fatia de string
* `String` é **dona** dos dados. Use para construir e modificar

```rust
let s1: &str = "hello";
let mut s2: String = String::from("hello");
s2.push('!');
```

## 3.4 Interpolação e formatação

Em JS:

```js
const name = "Felipe";
console.log(`Hello, ${name}`);
```

Em Rust:

```rust
let name = "Felipe";
println!("Hello, {}", name);
let message = format!("Welcome, {}!", name); // string alocada
```

## 3.5 Funções

Sintaxe básica:

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b // expressão final sem ponto e vírgula é o retorno
}

fn main() {
    let sum = add(2, 3);
    println!("{}", sum);
}
```

Comparando com JS:

```js
function add(a, b) {
  return a + b;
}
const sum = add(2, 3);
console.log(sum);
```

### Expressões vs. instruções

A última **expressão** de uma função em Rust pode retornar sem `return`. Se você colocar `;`, vira **instrução** e não retorna valor.

```rust
fn double(x: i32) -> i32 {
    x * 2
}
```

### Vários valores de retorno

Use **tuplas** ou um **struct** para retornar múltiplos valores com tipo.

```rust
fn min_max(values: &[i32]) -> (i32, i32) {
    (*values.iter().min().unwrap(), *values.iter().max().unwrap())
}

struct Stats { min: i32, max: i32 }
fn stats(values: &[i32]) -> Stats {
    Stats { min: *values.iter().min().unwrap(), max: *values.iter().max().unwrap() }
}
```

Em JS, você provavelmente retornaria um objeto:

```js
function stats(values) {
  return { min: Math.min(...values), max: Math.max(...values) };
}
```

## 3.6 Referências e uma prévia de ownership

Você pode **emprestar** uma referência a um valor sem transferir posse. Isso evita cópias desnecessárias.

```rust
fn len(s: &String) -> usize { s.len() }

fn main() {
    let name = String::from("Felipe");
    let n = len(&name); // empresta uma referência imutável
    println!("{} {}", name, n); // ainda posso usar `name`
}
```

Para modificar através de uma referência, use `&mut` e respeite as regras de empréstimo (uma referência mutável exclusiva ou várias imutáveis, mas não ambas ao mesmo tempo).

```rust
fn shout(s: &mut String) { s.push_str("!!!"); }

fn main() {
    let mut s = String::from("hey");
    shout(&mut s); // passa referência mutável
}
```

> Ownership e lifetimes serão detalhados nos próximos capítulos. Por enquanto, pense em referências como “empréstimos” seguros que o compilador verifica.

## 3.7 Tabela resumo

| Recurso         | JavaScript                  | Rust                            |
| --------------- | --------------------------- | ------------------------------- |
| Variável        | `let`, `const`              | `let`, `let mut`, `const`       |
| Tipos           | Dinâmico (TS opcional)      | Estático, inferido ou explícito |
| Funções         | `function`, arrow functions | `fn`, com anotações de tipo     |
| Template string | `` `Hello, ${name}` ``      | `format!("Hello, {}", name)`    |

## 3.8 Para levar

* Prefira imutabilidade. Use `mut` apenas quando necessário
* Anote tipos para clareza quando a inferência não for óbvia
* Use `format!` e `println!` para interpolar
* Retorne valores com a expressão final e use tuplas/structs quando precisar de múltiplos valores
* Comece a observar quando usar referências (`&T`, `&mut T`) em vez de clones

Próximo: **controle de fluxo e condicionais**. Vamos comparar `if/else` e `switch` com `match` e outras construções idiomáticas de Rust.


# Capítulo 4 — Controle de fluxo e condicionais

Neste capítulo vamos comparar **if/else** e **switch** do JavaScript com as construções idiomáticas de Rust: `if` como expressão, `match` com pattern matching, e os laços `loop`/`while`/`for`. A ideia é prática: mostrar o equivalente em Rust para casos que você já resolve no dia a dia.

## 4.1 `if` como expressão

Em Rust, `if` retorna um valor. Isso permite escrever lógica sem variáveis temporárias.

```rust
let score = 87;
let grade = if score >= 90 {
    "A"
} else if score >= 80 {
    "B"
} else {
    "C"
};
println!("grade: {}", grade);
```

Em JS você faria algo semelhante, mas o `if` não é expressão. Geralmente sairia assim:

```js
const score = 87;
let grade;
if (score >= 90) grade = "A";
else if (score >= 80) grade = "B";
else grade = "C";
console.log(`grade: ${grade}`);
```

> Dica: todos os ramos do `if` em Rust devem produzir **o mesmo tipo**.

## 4.2 `match` vs `switch`

`match` é o primo mais seguro e poderoso do `switch`. Ele exige **exaustividade** e suporta **padrões**.

JS:

```js
switch (status) {
  case 200: msg = "ok"; break;
  case 404: msg = "not found"; break;
  default:  msg = "error";
}
```

Rust:

```rust
let status = 503;
let msg = match status {
    200 => "ok",
    404 => "not found",
    500..=599 => "server error", // intervalo
    _ => "error",                // curinga obrigatório para cobrir o resto
};
```

### Padrões, intervalos e guardas

Você pode combinar padrões, usar intervalos e adicionar **guardas** com `if`:

```rust
let x = 42;
let label = match x {
    0 => "zero",
    1 | 2 | 3 => "small",
    4..=10 => "medium",
    n if n % 2 == 0 => "even",
    _ => "odd",
};
```

### Pattern matching com enums

O ganho de segurança aparece bem com `enum`.

```rust
enum Role { Admin, User(String) }

fn describe(r: Role) -> String {
    match r {
        Role::Admin => "admin".into(),
        Role::User(name) => format!("user {}", name),
    }
}
```

No `switch` de JS, você não tem verificação de exaustividade em tempo de compilação.

## 4.3 `if let` e `while let`: açúcar para padrões simples

Quando você só quer testar um padrão e extrair um valor, `if let` simplifica.

```rust
let maybe_id: Option<i64> = Some(10);
if let Some(id) = maybe_id {
    println!("id = {}", id);
} else {
    println!("sem id");
}
```

`while let` itera enquanto o padrão casa.

```rust
let mut stack = vec![1, 2, 3];
while let Some(top) = stack.pop() {
    println!("{}", top);
}
```

## 4.4 Lidando com `Option`/`Result`

`match` funciona muito bem com `Option` e `Result`. Para fluxos comuns, existem atalhos:

```rust
fn parse_port(s: &str) -> Result<u16, std::num::ParseIntError> {
    let n: u16 = s.parse()?; // `?` propaga o erro automaticamente
    Ok(n)
}
```

* `?` retorna cedo em caso de erro (`Result`), poupando um `match` manual.
* Para `Option`, métodos como `.unwrap_or(default)`, `.map(...)` e `.ok_or(err)` evitam `match` verboso.

## 4.5 Laços: `loop`, `while`, `for`

### `loop`, `break`, `continue` e rótulos

```rust
let mut n = 0;
loop {
    n += 1;
    if n == 3 { continue; }
    if n == 5 { break; }
}
```

Rótulos permitem controlar o laço externo:

```rust
'outer: for x in 0..3 {
    for y in 0..3 {
        if y == 1 { continue 'outer; }
    }
}
```

### `while`

```rust
let mut attempts = 0;
while attempts < 3 {
    attempts += 1;
}
```

### `for` com ranges e iteradores

```rust
for i in 0..3 { /* 0,1,2 */ }
for i in 0..=3 { /* 0,1,2,3 */ }

let items = vec!["a", "b", "c"];
for (i, item) in items.iter().enumerate() {
    println!("{} -> {}", i, item);
}
```

> Em Rust, `for` itera **sobre iteradores**. Use `&v` para emprestar, `&mut v` para modificar e `v.into_iter()` para mover valores.

## 4.6 Tabela: `switch` (JS) vs `match` (Rust)

| Recurso                       | `switch` (JS)     | `match` (Rust)                             |
| ----------------------------- | ----------------- | ------------------------------------------ |
| Exaustividade                 | Não exige         | **Exige** (ou `_` para cobrir o resto)     |
| Padrões                       | Iguais/constantes | Valores, intervalos, padrões compostos     |
| Captura de valores            | Manual            | Por padrão com padrões (ex.: `User(name)`) |
| Queda de caso (*fallthrough*) | Padrão é cair     | Não cai; cada braço é isolado              |
| Verificação em compilação     | Limitada          | Forte, com tipos e padrões                 |

## 4.7 Para levar

* `if` é expressão, então você pode atribuir o resultado direto a uma variável.
* `match` substitui `switch` com segurança e poder de composição.
* `if let`/`while let` simplificam padrões comuns com `Option` e outras estruturas.
* Escolha o laço certo: `loop` para “até eu mandar parar”, `while` para condição, `for` para iteradores/ranges.

> Próximo: **Funções e closures em Rust**. Vamos comparar com as arrow functions do JavaScript e ver como aceitar closures em funções genéricas.


# Capítulo 5 — Funções e Closures em Rust

Funções são um bloco de construção fundamental em Rust e diferem de JavaScript em pontos importantes. Neste capítulo, vemos como **definir**, **usar** e **passar** funções em Rust, além de trabalhar com **closures** (funções anônimas) e entender como capturam variáveis do escopo.

## 5.1 Definindo funções

```rust
fn greet(name: &str) {
    println!("Hello, {}!", name);
}

fn add(a: i32, b: i32) -> i32 {
    a + b // a expressão final (sem ponto e vírgula) é o retorno
}
```

* Funções usam `fn`.
* Parâmetros têm **tipos explícitos**.
* O tipo de retorno vem após `->`.
* A **última expressão** (sem `;`) é o valor retornado.

Em JavaScript:

```js
function add(a, b) {
  return a + b;
}
```

## 5.2 Parâmetros são imutáveis e retornos

Em Rust, parâmetros são imutáveis por padrão. Para permitir mutação, use `mut` na variável e, se necessário, passe uma **referência mutável** `&mut`.

```rust
fn shout(message: &mut String) {
    message.push('!');
}

fn square(x: i32) -> i32 {
    x * x // `return` é opcional quando a última linha é expressão
}
```

> Dica: use referências (`&T`/`&mut T`) para evitar cópias desnecessárias.

## 5.3 Closures (funções anônimas)

Closures em Rust são similares a arrow functions do JS.

```rust
let double = |x| x * 2;        // tipos inferidos
println!("{}", double(5));     // 10

let add = |a: i32, b: i32| -> i32 { a + b }; // tipos anotados
```

### Diferenças em relação a arrow functions

| Conceito          | JavaScript                    | Rust                             |   |          |
| ----------------- | ----------------------------- | -------------------------------- | - | -------- |
| Sintaxe           | `x => x * 2`                  | \`                               | x | x \* 2\` |
| Captura de escopo | Lexical (por referência)      | Empréstimo, mutação ou **move**  |   |          |
| Tipagem           | Dinâmica                      | Estática (inferida ou explícita) |   |          |
| Retorno           | `return` comum                | Última expressão é o retorno     |   |          |
| Mutabilidade      | Variáveis mutáveis por padrão | Mutável só com `mut` / `FnMut`   |   |          |

## 5.4 `Fn`, `FnMut`, `FnOnce` e captura

Closures são classificadas conforme **como capturam** o ambiente:

* `Fn` — leitura (empréstimo imutável)
* `FnMut` — altera estado (empréstimo mutável)
* `FnOnce` — **toma posse** de algo capturado (chamável uma vez)

Exemplos de captura:

```rust
let factor = 3;
let times = |x| x * factor; // lê `factor` (Fn)

let mut count = 0;
let mut inc = || { count += 1; }; // precisa de mut (FnMut)

let s = String::from("hi");
let consume = move || s.len(); // move a posse de `s` para a closure (FnOnce)
```

> Use `move` quando precisar **armazenar** a closure por mais tempo ou enviá‑la para outra thread.

## 5.5 Passando closures como parâmetro

Aceite closures com **parâmetros genéricos** e **trait bounds**.

```rust
fn apply<F>(func: F, val: i32) -> i32
where
    F: Fn(i32) -> i32,
{
    func(val)
}

let triple = |x| x * 3;
println!("{}", apply(triple, 5)); // 15
```

Também é comum aceitar **ponteiros de função**:

```rust
fn apply_fn(func: fn(i32) -> i32, val: i32) -> i32 {
    func(val)
}

fn add1(x: i32) -> i32 { x + 1 }
println!("{}", apply_fn(add1, 5));
```

### `impl Trait` para deixar a assinatura mais simples

```rust
fn apply_simple(func: impl Fn(i32) -> i32, val: i32) -> i32 {
    func(val)
}
```

## 5.6 Retornando closures

O tipo exato de uma closure é anônimo. Para retorná‑la, use **`impl Fn...`** ou um **trait object** (`Box<dyn Fn...>`).

```rust
// compila se a closure não capturar referência com lifetime complexo
fn make_adder(n: i32) -> impl Fn(i32) -> i32 {
    move |x| x + n
}

let add10 = make_adder(10);
println!("{}", add10(5)); // 15

// alternativa com trait object, útil quando precisar de tipos heterogêneos
fn make_predicate() -> Box<dyn Fn(i32) -> bool> {
    Box::new(|x| x % 2 == 0)
}
```

## 5.7 Funções de ordem superior e iteradores

Closures aparecem muito em **iteradores**. Pense em `map`, `filter`, `find`, `any`, `all` como nos métodos de array do JS.

```rust
let nums = vec![1, 2, 3, 4, 5];
let doubled: Vec<_> = nums.iter().map(|n| n * 2).collect();
let evens: Vec<_> = nums.into_iter().filter(|n| n % 2 == 0).collect();
```

> `iter()` empresta; `into_iter()` move; `iter_mut()` permite modificar durante a iteração.

## 5.8 Boas práticas

* Prefira **assinaturas explícitas** quando a inferência não estiver clara.
* Use `move` se for **armazenar** a closure ou enviar para outra thread.
* Escolha o **trait** certo (`Fn`/`FnMut`/`FnOnce`) conforme a captura.
* Para retornar closures, prefira `impl Fn...`; use `Box<dyn Fn...>` quando precisar de **polimorfismo dinâmico**.

> Próximo: **Coleções e laços (Collections and Loops)**.

**Nota:** Voltaremos a `FnMut` e `FnOnce` na seção de *Tópicos Avançados*. Essas traits permitem trabalhar com closures que **mutam** variáveis ou **tomam posse** de valores capturados, úteis para padrões mais complexos.


# Capítulo 6 — Coleções e Laços

Rust oferece vários tipos de coleção — de **arrays de tamanho fixo** a **vetores dinâmicos** e **tuplas**. Iterar sobre essas coleções também é poderoso, com suporte a `for`, `while` e iteradores em estilo funcional.

Se você já trabalha com arrays e objetos em JavaScript, alguma sintaxe vai soar familiar — mas aqui tudo vem com **tipagem forte** e **regras de ownership**.

## 6.1 Arrays e vetores

### Array de tamanho fixo

```rust
let numbers: [i32; 3] = [1, 2, 3];
println!("First: {}", numbers[0]);
```

### Vetor redimensionável (`Vec`)

```rust
let mut scores = vec![90, 85, 72];
scores.push(100);
println!("Last: {}", scores[scores.len() - 1]);
```

Em JavaScript:

```js
const scores = [90, 85, 72];
scores.push(100);
console.log(scores[scores.length - 1]);
```

## 6.2 Tuplas

Tuplas agrupam valores de **tipos diferentes** em uma única estrutura ordenada.

```rust
let user: (&str, u32) = ("Felipe", 34);
println!("Name: {}, Age: {}", user.0, user.1);
```

Em JavaScript (simulando com array):

```js
const user = ["Felipe", 34];
console.log(`Name: ${user[0]}, Age: ${user[1]}`);
```

## 6.3 Laços

### `for`

```rust
for score in &scores {
    println!("Score: {}", score);
}
```

Em JavaScript:

```js
for (const score of scores) {
    console.log(`Score: ${score}`);
}
```

### `while`

```rust
let mut count = 0;
while count < 5 {
    println!("{}", count);
    count += 1;
}
```

## 6.4 Iteradores funcionais

```rust
let doubled: Vec<i32> = scores.iter().map(|x| x * 2).collect();
println!("{:?}", doubled);
```

Em JavaScript:

```js
const doubled = scores.map(x => x * 2);
console.log(doubled);
```

## 6.5 Tabela‑resumo

| Conceito   | JavaScript            | Rust                         |
| ---------- | --------------------- | ---------------------------- |
| Array      | `[1, 2, 3]`           | `[i32; 3]` ou `Vec<i32>`     |
| Tupla      | `['a', 1]`            | `(&str, i32)`                |
| Laço       | `for/of`, `while`     | `for`, `while`, `loop`       |
| Map/filter | `.map()`, `.filter()` | `.iter().map()`, `.filter()` |

> Próximo: **Tipos primitivos e objetos: JavaScript vs Rust** (Capítulo 7).


# Capítulo 7 — Tipos Primitivos e Objetos: JavaScript vs Rust

Entender os blocos fundamentais da linguagem é essencial para escrever código claro e idiomático. Este capítulo explora os **tipos primitivos** e as **estruturas de objeto** em JavaScript e Rust, destacando diferenças e semelhanças.

## 7.1 Tipos primitivos

| Conceito        | JavaScript                 | Rust                                   |
| --------------- | -------------------------- | -------------------------------------- |
| Inteiro         | `Number` (ponto flutuante) | `i32`, `u32`, `i64`, etc.              |
| Ponto flutuante | `Number`                   | `f32`, `f64`                           |
| Booleano        | `true`, `false`            | `bool`                                 |
| String          | `"text"` ou `'text'`       | `String`, `&str`                       |
| Null            | `null`                     | Não usado (veja `Option`)              |
| Undefined       | `undefined`                | Não usado (var desinicializada = erro) |
| Symbol          | `Symbol()`                 | Sem equivalente direto                 |
| BigInt          | `BigInt(123)`              | `i128`, `u128`                         |

**Rust é estaticamente tipada**: você declara (ou deixa o compilador inferir) o tipo exato.

```rust
let age: u32 = 30;
let pi: f64 = 3.14;
let name: &str = "Felipe";
```

Em JavaScript, todos os números são ponto flutuante e as variáveis são dinamicamente tipadas:

```js
let age = 30;
let pi = 3.14;
let name = "Felipe";
```

## 7.2 Strings: `String` vs `&str`

* `String` em Rust é **alocada no heap**, redimensionável e **dona** dos dados.
* `&str` é uma **fatia de string imutável**, geralmente usada como referência emprestada.

Exemplo:

```rust
let owned = String::from("hello");
let borrowed: &str = &owned;
```

Em JS, strings se comportam como valores imutáveis:

```js
const owned = "hello";
```

## 7.3 Objetos vs. structs

JavaScript usa **objetos** como mapas flexíveis chave‑valor:

```js
const user = {
  name: "Laura",
  age: 30
};
```

Rust usa **structs** com campos nomeados e tipos fixos:

```rust
struct User {
    name: String,
    age: u32,
}

let user = User {
    name: String::from("Laura"),
    age: 30,
};
```

Rust impõe verificações em tempo de compilação sobre tipos e estrutura, diferente de JS.

## 7.4 Passagem por valor vs. por referência

### Em JavaScript

* **Primitivos** (números, strings, booleanos) passam **por valor**.
* **Objetos e arrays** passam **por referência**.

```js
let a = 5;
let b = a; // cópia
b += 1;
console.log(a); // 5

let user = { name: "Laura" };
let user2 = user;
user2.name = "Felipe";
console.log(user.name); // "Felipe" — mesma referência
```

### Em Rust

Rust **sempre passa por valor** por padrão — inclusive structs. Para passar por referência, use `&` (empréstimo) ou `&mut` (empréstimo mutável).

```rust
struct User { name: String, age: u32 }

fn modify_name(user: &mut User) {
    user.name = String::from("Felipe");
}

let mut user = User { name: String::from("Laura"), age: 30 };
modify_name(&mut user);
println!("{}", user.name); // "Felipe"
```

### Diferença-chave

| Conceito               | JavaScript                               | Rust                                              |
| ---------------------- | ---------------------------------------- | ------------------------------------------------- |
| Passagem padrão        | Valor (primitivos), referência (objetos) | Sempre por valor; referência só com `&T`/`&mut T` |
| Referências explícitas | ❌ Automático para objetos                | ✅ `&`, `&mut`                                     |
| Ownership              | ❌ Não aplicado                           | ✅ Verificado pelo compilador                      |

## 7.5 Resumo

| Recurso            | JavaScript               | Rust                                |
| ------------------ | ------------------------ | ----------------------------------- |
| Sistema de tipos   | Dinâmico                 | Estático                            |
| Segurança de tipos | Fraca (erros em runtime) | Forte (verificação em compile‑time) |
| Modelagem de dados | Flexível, não tipada     | Rígida, tipada com structs          |
| Memória            | Garbage‑collected        | Ownership + borrowing               |
| Null safety        | Propenso a erros         | Via `Option<T>`                     |

> Próximo: **pattern matching e enums** — a alternativa poderosa de Rust ao `switch` e às *tagged unions* do JavaScript.


# Capítulo 8 — Structs, Enums e Modelagem de Dados

`structs` e `enums` são duas das ferramentas mais poderosas de Rust para organizar e modelar dados — e costumam ser mais expressivas e estritas do que objetos e *unions* em JavaScript.

Este capítulo mostra como definir e usar esses blocos de construção, como eles se relacionam com objetos em JavaScript e como o **pattern matching** amarra tudo com segurança e clareza.

## 8.1 Structs (como objetos em JS)

**Nota:** Alguns conceitos citados — como **borrowing** (referências emprestadas), **ownership** (posse) e **lifetimes** — aparecem aqui por contexto e serão aprofundados nos próximos capítulos.

### Definições rápidas

* **Ownership**: forma de Rust gerenciar memória rastreando quem **possui** um valor.
* **Borrowing**: acessar dados temporariamente sem tomar posse (`&T` ou `&mut T`).
* **Lifetimes**: anotações que dizem ao compilador **por quanto tempo** referências são válidas.

### Nota sobre `&str` vs `String`

Rust tem dois tipos principais para texto:

* `&str` é uma **fatia imutável** de string, frequentemente usada como referência emprestada.
* `String` é uma string **alocada no heap e redimensionável**, que **detém** seus dados.

Em argumentos de função e campos de `struct`, use `String` quando precisar de **posse**; use `&str` quando **emprestar** for suficiente.

Exemplo:

```rust
struct User {
    name: String, // possui o valor do nome
    age: u32,
}
```

Isso significa que a `struct` é **dona** dos dados. Se você usasse `&str`, precisaria gerenciar **lifetimes** explicitamente.

---

Structs definem **tipos próprios**:

```rust
struct User {
    name: String,
    age: u32,
}

fn main() {
    let user = User {
        name: String::from("Laura"),
        age: 28,
    };
    println!("{} is {} years old", user.name, user.age);
}
```

Em JavaScript:

```js
const user = {
  name: "Laura",
  age: 28
};
console.log(`${user.name} is ${user.age} years old`);
```

## 8.2 Inicialização de struct com `..`

Essa sintaxe lembra o *spread* de JS (`...user`), mas com diferenças importantes.

```rust
let user2 = User {
    name: String::from("Paulo"),
    ..user
};
```

**O que acontece:**

* Copia o campo `age` de `user` para `user2` (porque `u32` é `Copy`).
* Substitui `name` por um novo valor.
* **Move** os campos restantes de `user` para `user2`. Como `name: String` **não** é `Copy`, `user` **não** pode mais ser usado.

```rust
println!("{}", user.age); // ❌ erro de compilação: `user` foi movido
```

Em JavaScript:

```js
const user = { name: "Laura", age: 28 };
const user2 = { ...user, name: "Paulo" };
console.log(user.age); // ✅ ainda funciona
```

✅ Em Rust, as **regras de ownership** tornam o manuseio de dados previsível e menos propenso a erros sutis.

## 8.3 Enums (tagged unions com poder)

`enum` define um tipo que pode ser **uma entre várias variantes**:

```rust
enum Status {
    Active,
    Inactive,
    Blocked(String),
}

fn print_status(s: Status) {
    match s {
        Status::Active => println!("Active"),
        Status::Inactive => println!("Inactive"),
        Status::Blocked(reason) => println!("Blocked: {}", reason),
    }
}
```

Em JavaScript (menos seguro):

```js
const status = { type: "Blocked", reason: "Too many attempts" };
if (status.type === "Blocked") {
  console.log(`Blocked: ${status.reason}`);
}
```

## 8.4 Recap de pattern matching

Usar `match` com enums permite lidar com **todas as variantes** de forma segura e **exaustiva**:

```rust
let status = Status::Blocked("Too many attempts".into());
let msg = match status {
    Status::Active => "ok",
    Status::Inactive => "idle",
    Status::Blocked(text) => {
        println!("Blocked: {}", text);
        "blocked"
    }
};
```

**Nota sobre `=>` em `match`:** não é *arrow function* de JS. Em Rust, `=>` associa um **padrão** a uma **expressão/bloco**. É parte da sintaxe de *pattern matching* e garante que cada variante seja tratada explicitamente.

```rust
match some_value {
    Pattern => result,
}
```

Pense em `match` como um `switch` **forte e verificado por tipos**, sem *fallthrough* e com exaustividade obrigatória.

## 8.5 Quando usar `struct` vs `enum`

* Use **`struct`** quando quiser **agrupar dados relacionados**.
* Use **`enum`** quando um valor pode ser **uma entre várias variantes** (com ou sem dados associados).

> Próximo: **Ownership, Borrowing e Lifetimes**: como programadores Rust gerenciam memória sem garbage collector.


# Capítulo 9 — Ownership, Borrowing e Lifetimes

A segurança de memória em Rust nasce de uma ideia central: **ownership**. Diferente do modelo de coleta de lixo do JavaScript, Rust garante segurança **em tempo de compilação**, sem custo de tempo de execução, aplicando regras sobre como os valores são movidos, copiados e referenciados.

## 9.1 Ownership (propriedade)

**O que é “double free”?**
Em linguagens como C/C++, ocorre quando o mesmo bloco de memória é liberado duas vezes. Isso pode causar travamentos, corrupção de memória ou vulnerabilidades.

Rust evita *double free* impondo **ownership** em tempo de compilação: um valor é liberado **uma única vez**, quando seu **único dono** sai de escopo. Se um valor é **movido**, a referência original deixa de ser válida, eliminando o risco de liberar a mesma memória duas vezes.

Todo valor em Rust tem **um único dono** — a variável que o mantém.

```rust
let s = String::from("hello");
```

Quando `s` é criado, ele **possui** a string na memória. Se atribuirmos a outra variável:

```rust
let s1 = String::from("hello");
let s2 = s1; // ownership movido!
```

Após o *move*, `s1` **não é mais válido**. Usá-lo gera erro de compilação:

```rust
println!("{}", s1); // ❌ erro de compilação
```

Isso previne *double free* e erros de memória.

✅ Tipos primitivos (inteiros, bool, etc.) normalmente implementam `Copy`, então **não** são movidos:

```rust
let x = 5;
let y = x; // x continua válido
```

## 9.2 Borrowing (empréstimo)

Em vez de mover um valor, você pode **emprestá-lo**:

```rust
fn print_length(s: &String) {
    println!("Length: {}", s.len());
}

let s = String::from("hello");
print_length(&s); // passa por referência
println!("Still valid: {}", s);
```

Emprestar dá acesso ao valor **sem transferir a posse**.

* `&T` = empréstimo compartilhado (somente leitura)
* `&mut T` = empréstimo mutável (leitura e escrita)

🛑 Não é permitido ter **empréstimos compartilhados e mutáveis ao mesmo tempo** para o mesmo valor.

```rust
let mut s = String::from("hi");
let r1 = &s;
let r2 = &s;
let r3 = &mut s; // ❌ erro de compilação
```

## 9.3 Lifetimes (visão geral)

*Lifetimes* descrevem **por quanto tempo** uma referência é válida. Na maioria dos casos, o compilador **infere** automaticamente. Quando múltiplas referências se relacionam, pode ser necessário **anotar**:

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

Exploraremos *lifetimes* em mais detalhes no capítulo dedicado.

## 9.4 Analogia conceitual com JS

| Conceito    | JavaScript                              | Rust                          |
| ----------- | --------------------------------------- | ----------------------------- |
| GC          | Automático                              | Sem GC — ownership verificado |
| Referências | Qualquer quantidade, a qualquer momento | Empréstimos com regras        |
| Mutação     | Sem restrições fortes                   | Exclusiva via `&mut`          |
| Vazamentos  | Possíveis se não houver cuidado         | Prevenidos pelo compilador    |
| Lifetime    | Implícito, decidido em runtime          | Rastreado em compile‑time     |

> Próximo: expressar a **possibilidade de falha** no sistema de tipos — com `Option<T>` e `Result<T, E>`.


# Capítulo 10 — Tratamento de erros com `Option` e `Result`

Rust não usa exceções. Em vez disso, codifica a **possibilidade** de falha diretamente no sistema de tipos usando dois `enum`s poderosos: `Option<T>` e `Result<T, E>`.

## 10.1 `Option<T>`

**Nota:** `Some` e `None` não são palavras‑chave; são as duas variantes do `enum` `Option<T>` em Rust:

```rust
enum Option<T> {
    Some(T),
    None,
}
```

Quando você escreve `Some(42)` ou `None`, está usando construtores de `enum` para embrulhar (ou representar a ausência de) valores opcionais.

Representa um valor que pode estar presente ou ausente:

```rust
let some_number = Some(42);
let no_number: Option<i32> = None;
```

Esta é a versão de Rust para `null`/`undefined`, mas **verificada pelo tipo**, o que evita a clássica *null pointer exception* (tentar acessar um valor inexistente em tempo de execução):

```rust
fn maybe_double(x: Option<i32>) -> Option<i32> {
    match x {
        Some(n) => Some(n * 2),
        None => None,
    }
}
```

✅ Use `Option<T>` quando um valor **pode não existir**.

## 10.2 `Result<T, E>`

Representa sucesso (`Ok`) ou falha (`Err`):

```rust
fn safe_divide(x: i32, y: i32) -> Result<i32, String> {
    if y == 0 {
        Err("division by zero".to_string())
    } else {
        Ok(x / y)
    }
}
```

✅ Use `Result<T, E>` quando **algo pode dar errado** e você quer **retornar um erro**.

## 10.3 Tratando resultados

Use *pattern matching* com `match`:

```rust
match safe_divide(10, 2) {
    Ok(result) => println!("Result: {}", result),
    Err(e) => println!("Error: {}", e),
}
```

## 10.4 Atalho: `if let`

```rust
let result = Some(42);
if let Some(x) = result {
    println!("Value is {}", x);
}
```

## 10.5 Cuidado: `unwrap`

```rust
let n = Some(5);
println!("{}", n.unwrap()); // panic se for None
```

Use `unwrap` **apenas** quando tiver certeza de que o valor está presente.

## 10.6 Boas práticas

* Prefira `match` ou `if let` para tratamento seguro.
* Evite `unwrap()` fora de protótipos rápidos ou testes.
* Use `.expect("mensagem")` para documentar por que o unwrap é seguro.

## 10.7 Comparação com JavaScript

| Conceito       | JavaScript              | Rust                       |
| -------------- | ----------------------- | -------------------------- |
| null/undefined | Runtime, não verificado | `Option<T>` (compile‑time) |
| try/catch      | Exceções, dinâmicas     | `Result<T, E>` (`enum`)    |
| throw          | Qualquer tipo           | `Err(E)` tipado            |

> Próximo: **Lifetimes (aprofundamento)** — como Rust rastreia a validade de referências entre funções e escopos.


# Capítulo 11 — Lifetimes em Rust (Aprofundamento)

*Lifetimes* são uma das características mais marcantes — e, no começo, intimidadoras — de Rust. Elas existem para garantir **segurança de memória sem garbage collector**, rastreando **por quanto tempo** referências permanecem válidas.

## 11.1 Por que lifetimes existem?

Pense em emprestar um livro: você não pode ficar com ele para sempre; precisa devolvê‑lo antes de o dono precisar. As *lifetimes* fazem isso com **referências**: uma referência **não pode** viver mais do que os dados aos quais aponta.

Em linguagens com GC (como JavaScript e Python), a memória é gerenciada em tempo de execução. Em Rust, **ownership** e **borrowing** são verificados em compilação — e as *lifetimes* são o mecanismo que o compilador usa para checar se todos os empréstimos são válidos.

## 11.2 Lifetimes em assinaturas de função

Você verá *lifetimes* em funções que **retornam referências**:

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

Isto diz:

* `'a` é um **parâmetro de lifetime**.
* `x` e `y` vivem **pelo menos** tanto quanto `'a`.
* O retorno é válido pelo mesmo `'a`.

Em outras palavras, a referência retornada **não** ultrapassa a vida de nenhuma das entradas.

## 11.3 Anotações não mudam o comportamento

*Lifetimes* não alteram a execução do programa — servem **apenas para o compilador**. Quando as referências têm vidas óbvias, Rust costuma **inferir** tudo.

```rust
fn print_ref(x: &str) {
    println!("{}", x);
}
```

Aqui, nenhuma anotação é necessária: o compilador sabe que `x` vive o suficiente durante a chamada.

## 11.4 Quando aparecem erros de lifetime

Você verá erros quando:

* tentar retornar uma referência a um **valor que já saiu de escopo**;
* usar **structs com referências** sem declarar *lifetimes*;
* misturar **empréstimos mutáveis e imutáveis** de forma incompatível.

Exemplo clássico (referência pendurada):

```rust
let r;
{
    let x = 5;
    r = &x; // ❌ `x` não vive o suficiente
}
println!("{}", r); // erro: borrowed value does not live long enough
```

Rust impede referências penduradas **em compilação**.

## 11.5 Regras de *lifetime elision*

Na maioria dos casos, o compilador aplica regras de elisão para evitar anotações verbosas:

1. Cada parâmetro por referência recebe **sua própria** lifetime implícita.
2. Se há **uma** referência de entrada, sua lifetime é atribuída ao **retorno**.
3. Se há `&self`/`&mut self`, o **retorno** recebe a mesma lifetime de `self`.

Por isso, isto compila sem `'a` explícito:

```rust
fn first(x: &str) -> &str { x }
```

## 11.6 Lifetimes em `struct`

Se você quer **armazenar referências** dentro de `structs`, precisa declarar uma lifetime:

```rust
struct Book<'a> {
    title: &'a str,
}

let title = String::from("Rust Book");
let book = Book { title: &title };
```

A `struct` está dizendo: “eu contenho uma referência e **não posso** viver mais do que ela”.

E se `title` for descartado cedo demais?

```rust
let book_ref;
{
    let title = String::from("Rust Book");
    book_ref = Book { title: &title }; // ❌ `title` não vive o suficiente
}
// `title` caiu aqui, mas `book_ref` ainda existe → seria inseguro
```

✅ Para **evitar lifetimes** nesse caso, faça a `struct` **dona** do dado usando `String` em vez de `&str`:

```rust
struct Book { title: String }
```

## 11.7 Lifetimes vs JavaScript (analogia)

| Conceito              | Rust                                   | JavaScript                 |
| --------------------- | -------------------------------------- | -------------------------- |
| Segurança de ref.     | Verificada em compilação (*lifetimes*) | Não é verificada; GC lida  |
| Referência pendurada  | Erro em compilação                     | Pode causar bug em runtime |
| Borrow checker        | Sim                                    | Não                        |
| Vazamentos de memória | Possíveis, porém raros                 | Possíveis                  |

## 11.8 Para levar

* *Lifetimes* garantem que **referências são sempre válidas**.
* Elas evitam referências penduradas e classes inteiras de bugs de memória.
* A maioria é **inferida**; anote apenas nos casos mais complexos (retornos por referência, structs com referências, múltiplas relações entre empréstimos).

> Próximo: **Iteradores e o trait `Iterator`** — composição com `map`, `filter`, `collect` e ergonomia com `Option`/`Result`.


# Capítulo 12 — Iteradores e carregamento sob demanda (Lazy Loading)

Iteradores são um dos pilares da expressividade de Rust — permitem encadear, transformar e consumir sequências de dados com **abstrações de custo zero**.

Neste capítulo, vamos ver como Rust lida com iteração, contrastar com `Array.prototype.map` e geradores do JavaScript, e apresentar o conceito de **carregamento sob demanda** por meio do trait `Iterator`.

## 12.1 Iteração em JavaScript vs Rust

### JavaScript

```js
const nums = [1, 2, 3];
const doubled = nums.map(x => x * 2);
console.log(doubled); // [2, 4, 6]
```

* Métodos como `map`, `filter` e `reduce` **avaliam imediatamente** e retornam novos arrays.

### Rust

```rust
let nums = vec![1, 2, 3];
let doubled: Vec<i32> = nums.iter().map(|x| x * 2).collect();
println!("{:?}", doubled); // [2, 4, 6]
```

* `.iter()` cria um **iterador** (sob demanda).
* `.map(...)` define uma transformação — **ainda não executada**.
* `.collect()` força a avaliação e produz o resultado final.

## 12.2 Carregamento sob demanda em Rust

Iteradores em Rust são avaliados **sob demanda**:

* Nada acontece até você chamar `collect()`, usar um `for`, `sum()`, `count()` etc.
* Isso permite composições eficientes **sem alocações intermediárias**.

```rust
let result: i32 = (1..)
    .map(|x| x * x)
    .filter(|x| x % 2 == 0)
    .take(5)
    .sum();

println!("Sum of first 5 even squares: {}", result); // 120
```

Aqui, `(1..)` é um **intervalo infinito**, e `take(5)` limita a sequência.

## 12.3 Iteradores personalizados

Para criar seu próprio iterador, implemente o trait `Iterator`:

```rust
struct Counter { count: u32 }

impl Counter { fn new() -> Self { Counter { count: 0 } } }

impl Iterator for Counter {
    type Item = u32;
    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;
        if self.count <= 5 { Some(self.count) } else { None }
    }
}

for val in Counter::new() {
    println!("{}", val);
}
```

Esse padrão lembra um gerador: produz valores **sob demanda**.

## 12.4 Comparação: geradores JS vs iteradores Rust

| Recurso              | Geradores (JavaScript)       | Iteradores (Rust)                 |
| -------------------- | ---------------------------- | --------------------------------- |
| Sob demanda          | Sim                          | Sim                               |
| Sintaxe              | `function* () { yield ... }` | `impl Iterator for MeuTipo`       |
| Sequências infinitas | Sim, com cuidado             | Sim, com segurança via `take()`   |
| Ergonomia            | Concisa                      | Um pouco mais verbosa, mais poder |
| Desempenho           | Médio                        | Alto (abstração de custo zero)    |
| Segurança de memória | Sem garantias                | Ownership + lifetimes             |

## 12.5 Resumo

* O trait `Iterator` define sequências **componíveis** avaliadas **sob demanda**.
* Métodos como `.map()`, `.filter()`, `.take()` encadeiam transformações e **só avaliam** quando necessário.
* Você pode definir iteradores próprios implementando `next()`.
* Iteradores são **seguros em memória** e altamente otimizados.

> Próximo: **De Express a Axum: construindo um servidor HTTP**.


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

# Capítulo 14 — POO sem classes em Rust

Muitos desenvolvedores vindos de JavaScript ou outras linguagens orientadas a objetos esperam **classes**, **herança** e **polimorfismo**. Rust segue outro caminho: **não tem classes**, mas oferece ferramentas poderosas para estruturar código com **structs**, **traits** e **composição**.

## 14.1 Structs + `impl` = "tipo" + métodos

Rust separa dados de comportamento de forma explícita.

```rust
struct User {
    name: String,
}

impl User {
    fn greet(&self) {
        println!("Hello, {}!", self.name);
    }
}

let user = User { name: String::from("Laura") };
user.greet();
```

Em TypeScript (análogo usando `type` + função):

```ts
type User = {
  name: string;
  greet: () => void;
};

const user: User = {
  name: "Laura",
  greet() {
    console.log(`Hello, ${this.name}`);
  }
};
```

Observação: em Rust, os métodos vivem em blocos `impl`, não dentro da definição do tipo.

## 14.2 Sem herança; com composição

Rust **não** possui herança. Em vez disso, incentiva **composição** — juntar peças simples para formar comportamentos mais complexos.

```rust
struct Engine;
struct Wheels;

struct Car {
    engine: Engine,
    wheels: Wheels,
}
```

Nada de `Car extends Vehicle`. Você modela agregando componentes e extraindo comportamentos para traits.

## 14.3 Polimorfismo com traits

Traits expressam comportamentos que vários tipos podem implementar — parecidos com `interface` em TypeScript.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;
struct Square;

impl Drawable for Circle {
    fn draw(&self) { println!("Drawing a circle"); }
}

impl Drawable for Square {
    fn draw(&self) { println!("Drawing a square"); }
}

fn render(shape: &dyn Drawable) {
    shape.draw();
}
```

Em TypeScript:

```ts
interface Drawable { draw(): void }

class Circle implements Drawable {
  draw() { console.log("Drawing a circle") }
}
```

Notas úteis

* Você também pode usar **polimorfismo estático** com generics: `fn render<T: Drawable>(shape: &T) { shape.draw(); }` (sem custo de despacho dinâmico).
* `&dyn Trait` usa **despacho dinâmico** (tabela virtual) e é útil quando você precisa de heterogeneidade em tempo de execução.

## 14.4 Lado a lado

| Conceito          | TypeScript            | Rust                     |
| ----------------- | --------------------- | ------------------------ |
| Classe            | Sim                   | Não                      |
| Interface         | Sim                   | Sim (traits)             |
| Herança           | `extends`             | Não (prefira composição) |
| Métodos           | Dentro da classe/tipo | Em blocos `impl`         |
| Polimorfismo      | Via interfaces        | Via traits               |
| Despacho dinâmico | Opcional              | `dyn Trait`              |

## 14.5 Para levar

* Rust **não tem classes**, herança nem `this` implícito.
* Use **structs** para dados, `impl` para métodos e **traits** para comportamento.
* Prefira **composição** a herança.
* Traits + generics oferecem polimorfismo seguro e expressivo.

O modelo de Rust é mais simples e explícito, com menos surpresas — e muito poder quando você internaliza a combinação de structs, traits e composição.

> Próximo: **Tópicos Avançados em Rust**.


# Capítulo 15 — Tópicos avançados em Rust

Este capítulo apresenta recursos poderosos de Rust para quem quer ir além do básico. Se você acompanhou os capítulos anteriores, já entende ownership, borrowing, lifetimes, pattern matching e tratamento de erros.

Agora vamos explorar abstrações mais profundas que aparecem no dia a dia de projetos em Rust.

## 15.1 Traits: `Fn`, `FnMut` e `FnOnce`

Closures em Rust podem capturar variáveis de maneiras diferentes. Dependendo do que capturam e de como usam o ambiente, elas implementam automaticamente um ou mais destes traits:

| Trait    | Forma de captura                | Quando usar                           |
| -------- | ------------------------------- | ------------------------------------- |
| `Fn`     | Empréstimo por referência (`&`) | Leitura apenas                        |
| `FnMut`  | Empréstimo mutável (`&mut`)     | Modificar estado capturado            |
| `FnOnce` | Por valor (move de ownership)   | Consumir valores capturados (uma vez) |

Exemplo:

```rust
fn call_twice<F>(mut f: F)
where
    F: FnMut(),
{
    f();
    f();
}

fn main() {
    let mut count = 0;

    // Captura mutável: implementa FnMut
    let mut increment = || {
        count += 1;
        println!("count = {}", count);
    };

    call_twice(increment);
    println!("final = {}", count);
}
```

Observações:

* `Fn`/`FnMut`/`FnOnce` são **contratos** sobre como a closure interage com o ambiente.
* Você escolhe o bound adequado quando aceita closures em funções genéricas.

### 15.1.1 `FnMut` em Rust vs generators em JavaScript

Closures mutáveis conseguem **preservar estado entre chamadas**, lembrando generators de JS, mas não são a mesma coisa.

| Conceito              | Rust (`FnMut`)                    | JavaScript (`function*` generator) |
| --------------------- | --------------------------------- | ---------------------------------- |
| Estado entre chamadas | Sim, via variáveis capturadas     | Sim, via escopo interno e `yield`  |
| Interface de chamada  | Direta: `f(); f();`               | Iterador: `gen.next()`             |
| Avaliação             | Eager (a menos que você componha) | Lazy por padrão (via `yield`)      |
| Retornos              | Valor de retorno normal           | Sequência de valores com `yield`   |
| Garantias             | Tipos e ownership em compilação   | Verificação apenas em runtime      |

Para iteradores realmente **lazy**, use o trait `Iterator` e adaptadores como `map`, `filter` e `take`.

## 15.2 Smart pointers: `Box`, `Rc` e `RefCell`

Tipos especiais que destravam alocação no heap e padrões mais flexíveis de posse e mutabilidade:

* **`Box<T>`**: coloca um valor no heap. Útil para tipos grandes, recursivos (ex.: árvores) e para **objetos de trait** (`Box<dyn Trait>`).
* **`Rc<T>`**: contagem de referências para **compartilhar ownership** em **thread única**. Clonar um `Rc` incrementa o contador; quando zera, o valor é liberado.
* **`RefCell<T>`**: habilita **mutabilidade interior** com checagem **em tempo de execução**. Permite `borrow()/borrow_mut()` mesmo quando você só tem uma referência imutável ao `RefCell`.

Combinações comuns:

* `Rc<T>` + `RefCell<T>` para grafos/árvores mutáveis em thread única.
* Em cenários multi‑thread, use `Arc<T>` (atômico) e, quando precisar de mutação interna, `Mutex<T>`/`RwLock<T>`.

Atenção: `RefCell` pode causar *panic* em caso de **empréstimos inválidos** em runtime (ex.: dois `borrow_mut()` simultâneos). Ele **não** quebra as regras; apenas as adia do compilador para o runtime.

## 15.3 Dicas de pattern matching

Guardas, bindings e padrões compostos deixam o `match` ainda mais expressivo:

```rust
match some_value {
    Some(x) if x > 5 => println!("grande: {}", x),
    Some(x) => println!("pequeno: {}", x),
    None => println!("sem valor"),
}
```

Outros recursos úteis:

* **Bindings com `@`**: `n @ 10..=20` captura o valor casado.
* **Padrões aninhados**: combine structs, enums e tuplas em um único `match`.
* **`..` para ignorar campos**: útil em structs grandes (ex.: `Point { x, .. }`).

## 15.4 `impl Trait` em tipos de retorno

Quando você quer retornar “**algo que implementa** um trait” sem expor o tipo concreto:

```rust
fn greeter() -> impl Fn(String) -> String {
    |name| format!("Hello, {}!", name)
}
```

Comparando com trait objects:

* `impl Trait` no **retorno** preserva despacho **estático** e evita `Box`. Bom para pipelines e closures simples.
* `Box<dyn Trait>` permite **despacho dinâmico** e tipos heterogêneos, à custa de indireção.

**Object safety**: métodos que consomem `self` por valor geralmente **não** são chamáveis via `dyn Trait`. Alternativas: `self: Box<Self>` no método, ou restringir `Self: Sized` e usar genéricos.

## 15.5 Módulos, visibilidade e organização

Use `mod`, `pub` e `use` para organizar o código:

```rust
mod math {
    pub fn add(x: i32, y: i32) -> i32 { x + y }
}

fn main() {
    println!("{}", math::add(2, 3));
}
```

Boas práticas:

* Estruture o **árvore de módulos** de fora para dentro (API pública) e esconda detalhes de implementação.
* Reexporte com `pub use` quando quiser expor uma “fachada” estável.
* Separe crates em workspaces quando houver limites claros entre domínios.

## 15.6 Pontos de atenção e quando usar cada recurso

* Use `Fn`/`FnMut`/`FnOnce` conforme o **padrão de captura** da closure.
* Prefira `impl Trait` em retornos quando o tipo concreto não importa e você quer **zero overhead**.
* Recorra a `Box<dyn Trait>` para **heterogeneidade** em runtime ou para reduzir código gerado por monomorfização.
* Escolha smart pointers de acordo com o **modelo de posse**: `Box` para heap simples; `Rc`/`Arc` para compartilhamento; `RefCell`/`Mutex`/`RwLock` para mutabilidade interior (com responsabilidade).
* Em `match`, explore guardas e padrões compostos para **exaustividade clara** e menos `if/else` aninhado.

## 15.7 Encerramento

* Traits de função permitem closures flexíveis e seguras.
* Smart pointers viabilizam estruturas ricas mantendo segurança de memória.
* Pattern matching avança de casos simples para modelagem profunda de dados.
* Uma boa árvore de módulos mantém o projeto coeso e evolutivo.

Com esses tópicos avançados, você tem munição para projetar APIs e sistemas idiomáticos em Rust, mantendo **clareza**, **segurança** e **desempenho**.


# Conclusão

Este livro não foi sobre decorar Rust. A ideia central foi **traduzir os modelos mentais que você já usa em JS/TS** para o sistema de tipos e as garantias de compilação de Rust, em passos pequenos e testáveis. A ponte está construída; agora é praticar até escrever Rust de forma natural.

## Panorama do que percorremos

**Capítulos 1–4: valores, tipos e controle de fluxo**
Partimos da intuição de JS e chegamos a **ownership (posse)** e **borrowing (empréstimo)**, vendo por que movimentos são explícitos e cópias são intencionais. Exploramos **pattern matching** para substituir cadeias de `if/else` por `match` exaustivo.

**Capítulos 5–6: funções, closures e coleções**
Vimos funções com tipos explícitos, closures e como iterar sobre **vetores**, **tuplas** e **maps**. Laços (`for`, `while`) convivem com a abordagem funcional de iteradores.

**Capítulos 7–8: tipos e modelagem**
Com **structs** e **enums**, objetos e *unions* do JS viram **modelagem precisa** de estados válidos. O compilador garante exaustividade e consistência.

**Capítulos 9–11: ownership, borrowing e lifetimes**
A base de segurança de memória: empréstimos exclusivos versus compartilhados e quando anotar **lifetimes** para referências em retornos e structs.

**Capítulo 10 (destaque): erros com `Option` e `Result`**
Saímos do `try/catch` para **`Result<T, E>`** com propagação via `?`. Erros viram parte do **contrato** da função, não efeito colateral.

**Capítulo 12: iteradores com *Lazy Loading***
Encadeamos `map`/`filter`/`take` e só materializamos com `collect`, `sum`, `for` — evitando alocações intermediárias desnecessárias.

**Capítulo 13: projeto prático (Axum + SQLx)**
Reescrevemos um CRUD de Express para Axum, com **tipagem estática**, **sqlx** assíncrono e erros tratados de forma explícita.

**Capítulo 14 (bônus): POO sem classes**
Sem herança. Usamos **composição**, `impl` para métodos e **traits** para polimorfismo (estático com genéricos ou dinâmico com `dyn`).

**Capítulo 15: tópicos avançados**
Aprofundamos **`Fn` / `FnMut` / `FnOnce`** (captura e estado em closures), **ponteiros inteligentes** (`Box`, `Rc`, `RefCell`) para estruturas ricas com segurança, **`impl Trait` em retornos** e dicas de *pattern matching* e **organização em módulos/visibilidade**.

## O que deve ficar

* **Modele o domínio em tipos**: enums para estados, structs para dados, traits para comportamento.
* **Deixe o compilador trabalhar a seu favor**: quando compila, uma classe inteira de bugs já caiu.
* **Prefira iteradores e `match`** a laços imperativos com *flags*.
* **Erros como cidadãos de primeira classe**: pense nos tipos de erro e propague cedo com `?`.

## Próximos passos

* Adicione **paginação, validação, autenticação e observabilidade** ao serviço CRUD.
* Troque **SQLite por Postgres**, introduza **migrações** e escreva **testes de integração**.
* Experimente um serviço com **streams** ou **tarefas agendadas** para praticar *async* mais a fundo.
* Aprofunde **lifetimes**, explore **macros**, e pratique **ponteiros inteligentes** em estruturas não‑triviais.

## Nota honesta

Rust não é bala de prata. Você troca um pouco de flexibilidade por **clareza e garantias**. O retorno é código confiável sob carga e um compilador que escala junto com o time.

Use as comparações JS ↔ Rust como **ponte**, não como muleta. À medida que avançar, confie primeiro nos conceitos nativos de Rust — ownership, traits, enums, pattern matching — sem precisar traduzir mentalmente. Quando isso encaixa, você passa a pensar e programar **nativamente em Rust**.

*Happy shipping.*


# Apêndice — Duck typing ad hoc, TypeScript estrutural e receptores em Rust (unificado)

Este apêndice reúne dois tópicos que aparecem ao longo do livro:

1. **Duck typing ad hoc** (JavaScript), **contrato estrutural e estático** (TypeScript) e **contrato nominal e explícito** (Rust via traits)
2. **Receptores de método**: `&self`, `&mut self`, `self` (Rust) comparados a `this` (JS/TS) e `self`/`typing.Self` (Python)

Sem delimitadores YAML e sem regras horizontais.

## Parte 1 — Duck typing ad hoc, TypeScript estrutural e Rust com traits

### 1. Duck typing ad hoc (JS)

**Definição.** “Se parece com um pato e faz ‘quack’, uso como pato”. Em JS, você usa um valor com base no comportamento que ele parece expor, sem um tipo declarado. O “contrato” é implícito e só falha em tempo de execução.

Exemplo:

```js
function render(shape) {
  // contrato implícito: shape deve ter draw()
  shape.draw(); // se não tiver, erro em runtime
}

// checagem manual, opcional
function renderSafe(shape) {
  if (!shape || typeof shape.draw !== "function") {
    throw new Error("shape must implement draw()");
  }
  shape.draw();
}
```

Vantagem: flexível e rápido de escrever. Custo: ausência de garantias; violações só aparecem em produção ou testes.

### 2. TypeScript: contrato estrutural e estático

**Estrutural**: compatibilidade determinada pela forma (campos e assinaturas), não pelo nome do tipo. **Estático**: verificação em tempo de compilação (checker do TS).

```ts
interface Drawable { draw(): void }

function render(s: Drawable) {
  s.draw(); // garantido pelo compilador
}

// qualquer objeto com a mesma forma é compatível
const circle = { draw() { console.log("circle") }, r: 10 };
render(circle); // ok, compatível estruturalmente
```

Observações:

* Não é obrigatório declarar `implements Drawable`; basta ter a forma.
* O TS aponta erros cedo. Em literais, a verificação de propriedades “extras” é mais rígida.
* Tipos com membros `private`/`protected` tendem ao comportamento nominal.

### 3. Rust: contrato nominal e explícito (traits)

Rust não usa duck typing. Utiliza **traits** para expressar capacidades. Compatibilidade é **nominal** (você declara `impl Trait for Tipo`) e a checagem é **estática**.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;

impl Drawable for Circle {
    fn draw(&self) { println!("circle"); }
}

// polimorfismo estático (genéricos)
fn render<T: Drawable>(x: &T) { x.draw(); }

// polimorfismo dinâmico (trait objects)
fn render_dyn(x: &dyn Drawable) { x.draw(); }
```

Por que “nominal”? Porque só quem declara `impl Drawable for Tipo` é aceito como `Drawable`. Ter “a mesma forma” não basta.

### 4. Dinâmico vs estático em Rust: `&dyn Trait` e genéricos

* **Genéricos (`T: Trait`)**: despacho estático (monomorfização). Desempenho excelente.
* **`&dyn Trait`**: despacho dinâmico em runtime (vtable). Útil para heterogeneidade.

Ambos mantêm contratos explícitos via traits; muda apenas como a chamada é resolvida.

### 5. Lado a lado

| Tema                   | JavaScript         | TypeScript (estrutural, estático) | Rust (nominal, explícito)           |
| ---------------------- | ------------------ | --------------------------------- | ----------------------------------- |
| Contrato               | Implícito, por uso | Pela forma (shape)                | Por declaração (`impl Trait for T`) |
| Momento de verificação | Runtime            | Compilação                        | Compilação                          |
| Falhas típicas         | Erro tardio        | Erros cedo, nuances de literais   | Erros cedo, contrato explícito      |
| Polimorfismo           | Livre (ad hoc)     | Estrutural                        | Traits (genéricos ou `dyn`)         |

### 6. Exemplos completos

**JS ad hoc**

```js
function area(shape) { return shape.area(); }
area({ side: 2 }); // TypeError: shape.area is not a function
```

**TS estrutural**

```ts
interface HasArea { area(): number }
function area(s: HasArea) { return s.area() }
const square = { side: 2, area() { return this.side * this.side } };
area(square); // ok
const bad = { side: 2 };
area(bad); // erro: 'area' ausente
```

**Rust com traits**

```rust
trait HasArea { fn area(&self) -> f64; }
struct Square { side: f64 }
impl HasArea for Square { fn area(&self) -> f64 { self.side * self.side } }
fn area<T: HasArea>(s: &T) -> f64 { s.area() }
let sq = Square { side: 2.0 };
println!("{}", area(&sq));
```

### 7. Migração prática

1. Nomeie o comportamento como trait.
2. Defina o contrato mínimo (métodos essenciais).
3. Implemente `impl Trait for Tipo` para cada tipo concreto.
4. Use genéricos para desempenho; `&dyn Trait` para heterogeneidade.
5. Exporte a trait; esconda detalhes em módulos.

### 8. Perguntas frequentes

**“Estrutural e estático” em TypeScript?**
Estrutural: compatível se tem a forma. Estático: checker valida em compilação.

**Por que Rust não usa tipagem estrutural?**
Para manter coerência e autoria clara: quem declara `impl` define a capacidade. Evita colisões.

**Quando usar `&dyn Trait`?**
Coleções heterogêneas, APIs polimórficas em runtime ou para reduzir código gerado.

## Parte 2 — Receptores em Rust vs `this` (JS/TS) vs `self` (Python)

### Visão geral

| Linguagem | Receptor      | Significado                          | Passagem                                      | Quem decide          |
| --------- | ------------- | ------------------------------------ | --------------------------------------------- | -------------------- |
| Rust      | `&self`       | Empréstimo imutável                  | Referência compartilhada                      | Assinatura do método |
|           | `&mut self`   | Empréstimo mutável exclusivo         | Referência exclusiva                          | Assinatura do método |
|           | `self`        | Move/consome o valor                 | Por valor (ownership)                         | Assinatura do método |
| JS/TS     | `this`        | Ponteiro dinâmico para o receptor    | Depende do call‑site (`obj.m()`, `call/bind`) | Local da chamada     |
| Python    | `self`        | Primeiro parâmetro do método         | Passado explicitamente pelo runtime           | Autor do método      |
| Python    | `typing.Self` | Tipo “o próprio tipo” para anotações | Somente estático                              | Autor da assinatura  |

### Exemplos rápidos

**Rust**

```rust
struct Counter { n: i32 }
impl Counter {
    fn peek(&self) -> i32 { self.n }
    fn bump(&mut self) { self.n += 1; }
    fn into_inner(self) -> i32 { self.n }
}
let mut c = Counter { n: 0 };
let _ = c.peek();            // Counter::peek(&c)
c.bump();                    // Counter::bump(&mut c)
let n = c.into_inner();      // move c; não pode usar c depois
```

**JavaScript/TypeScript**

```ts
class Counter { n = 0; peek() { return this.n } bump() { this.n += 1 } }
const c = new Counter();
const f = c.bump;
f();        // erro em strict mode (this === undefined)
f.call(c);  // ok (rebind)
const g = c.bump.bind(c); g(); // ok
```

**Python**

```py
class Counter:
    def __init__(self): self.n = 0
    def peek(self): return self.n
    def bump(self): self.n += 1
c = Counter(); c.peek(); c.bump()
```

### Dicas práticas (JS → Rust)

* Método que apenas lê → `&self`.
* Método que muta → `&mut self`.
* Método que consome/transfere ownership → `self`.
* Não existe `bind` em Rust: a assinatura determina o receptor.

### `dyn Trait` vs genéricos e object safety

* **Genéricos**: `fn render<T: Drawable>(x: &T)` → despacho estático (monomorfização).
* **Trait object**: `fn render(x: &dyn Drawable)` → despacho dinâmico (vtable).
* **Object safety**: métodos que tomam `self` por valor não são chamáveis via `dyn Trait`. Alternativas: `self: Box<Self>` ou restringir `Self: Sized` e usar genéricos.

### Erros comuns ao portar de JS/TS

* Extrair um método e perder o receptor: `const f = obj.m; f();` quebra `this` em JS; em Rust não existe rebind dinâmico.
* Tentar mutar via `&self`: em Rust, só `&mut self` permite mutação.
* Esquecer que `self` move: após consumir `self`, o valor não pode mais ser usado.

### Mapa mental

* `&self` → leitura.
* `&mut self` → escrita com exclusividade.
* `self` → consumo/transferência de ownership.
* Traits definem contratos explícitos; não há `this` dinâmico.



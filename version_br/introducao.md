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

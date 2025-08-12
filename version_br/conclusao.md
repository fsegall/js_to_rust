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

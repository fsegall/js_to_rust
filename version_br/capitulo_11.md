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

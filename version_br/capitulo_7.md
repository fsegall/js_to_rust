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

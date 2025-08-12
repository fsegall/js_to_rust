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

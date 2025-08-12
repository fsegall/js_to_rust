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

# Chapter 5 — Functions and Closures in Rust

Functions are a fundamental building block in Rust, and they differ from JavaScript in important ways. In this chapter, we’ll see how to **define**, **use**, and **pass** functions in Rust, work with **closures** (anonymous functions), and understand how they capture variables from their environment.

## 5.1 Defining functions

```rust
fn greet(name: &str) {
    println!("Hello, {}!", name);
}

fn add(a: i32, b: i32) -> i32 {
    a + b // the final expression (no semicolon) is the return value
}
```

* Functions use `fn`.
* Parameters have **explicit types**.
* The return type comes after `->`.
* The **last expression** (without `;`) is returned.

In JavaScript:

```js
function add(a, b) {
  return a + b;
}
```

## 5.2 Parameters are immutable and returns

In Rust, parameters are immutable by default. To allow mutation, make the local variable `mut` and, if you need to mutate through a reference, pass a **mutable reference** `&mut`.

```rust
fn shout(message: &mut String) {
    message.push('!');
}

fn square(x: i32) -> i32 {
    x * x // `return` is optional when the last line is an expression
}
```

> Tip: use references (`&T`/`&mut T`) to avoid unnecessary copies.

## 5.3 Closures (anonymous functions)

Closures in Rust are similar to JS arrow functions.

```rust
let double = |x| x * 2;        // types inferred
println!("{}", double(5));     // 10

let add = |a: i32, b: i32| -> i32 { a + b }; // annotated types
```

### Differences from arrow functions

| Concept       | JavaScript                      | Rust                                |   |          |
| ------------- | ------------------------------- | ----------------------------------- | - | -------- |
| Syntax        | `x => x * 2`                    | \`                                  | x | x \* 2\` |
| Scope capture | Lexical (by reference)          | Borrow, mutate, or **move**         |   |          |
| Typing        | Dynamic                         | Static (inferred or explicit)       |   |          |
| Return        | Uses `return`                   | Last expression is the return value |   |          |
| Mutability    | Variables are generally mutable | Mutation only with `mut` / `FnMut`  |   |          |

## 5.4 `Fn`, `FnMut`, `FnOnce` and capture

Closures are classified by **how they capture** their environment:

* `Fn` — read only (shared borrow)
* `FnMut` — mutates captured state (mutable borrow)
* `FnOnce` — **takes ownership** of captured values (can be called once)

Capture examples:

```rust
let factor = 3;
let times = |x| x * factor; // reads `factor` (Fn)

let mut count = 0;
let mut inc = || { count += 1; }; // needs mut (FnMut)

let s = String::from("hi");
let consume = move || s.len(); // moves ownership of `s` into the closure (FnOnce)
```

> Use `move` when you need to **store** the closure for longer or send it to another thread.

## 5.5 Passing closures as parameters

Accept closures via **generic parameters** and **trait bounds**.

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

You can also accept **function pointers**:

```rust
fn apply_fn(func: fn(i32) -> i32, val: i32) -> i32 {
    func(val)
}

fn add1(x: i32) -> i32 { x + 1 }
println!("{}", apply_fn(add1, 5));
```

### `impl Trait` for simpler signatures

```rust
fn apply_simple(func: impl Fn(i32) -> i32, val: i32) -> i32 {
    func(val)
}
```

## 5.6 Returning closures

A closure’s concrete type is anonymous. To return one, use **`impl Fn...`** or a **trait object** (`Box<dyn Fn...>`).

```rust
// compiles if the closure doesn’t capture references with complex lifetimes
fn make_adder(n: i32) -> impl Fn(i32) -> i32 {
    move |x| x + n
}

let add10 = make_adder(10);
println!("{}", add10(5)); // 15

// alternative with a trait object; useful for heterogeneous cases
fn make_predicate() -> Box<dyn Fn(i32) -> bool> {
    Box::new(|x| x % 2 == 0)
}
```

## 5.7 Higher‑order functions and iterators

Closures appear everywhere with **iterators**. Think `map`, `filter`, `find`, `any`, `all` like JS array methods.

```rust
let nums = vec![1, 2, 3, 4, 5];
let doubled: Vec<_> = nums.iter().map(|n| n * 2).collect();
let evens: Vec<_> = nums.into_iter().filter(|n| n % 2 == 0).collect();
```

> `iter()` borrows; `into_iter()` moves; `iter_mut()` lets you modify during iteration.

## 5.8 Best practices

* Prefer **explicit signatures** when inference isn’t obvious.
* Use `move` if you will **store** the closure or send it to another thread.
* Choose the right **trait** (`Fn`/`FnMut`/`FnOnce`) based on capture behavior.
* To return closures, prefer `impl Fn...`; use `Box<dyn Fn...>` when you need **dynamic polymorphism**.

> Next: **Collections and Loops**.

**Note:** We’ll revisit `FnMut` and `FnOnce` in *Advanced Topics*. These traits enable working with closures that **mutate** variables or **take ownership** of captured values—useful for more complex patterns.

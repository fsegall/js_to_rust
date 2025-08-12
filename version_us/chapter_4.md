# Chapter 4 — Functions and Closures in Rust

Functions are a fundamental building block in Rust — and they differ from JavaScript in a few key ways. In this chapter, we’ll explore how to define, use, and pass functions in Rust, including closures (Rust's version of anonymous functions).

---

## 🛠 Defining Functions

```rust
fn greet(name: &str) {
    println!("Hello, {}!", name);
}

fn add(a: i32, b: i32) -> i32 {
    a + b // no `return` needed if it's the last expression
}
```

* Functions use `fn`
* Parameters have **explicit types**
* Return type goes after `->` (arrow)
* The final expression (no semicolon) is the return value

🔸 In JavaScript:

```js
function add(a, b) {
  return a + b;
}
```

---

## 🧱 Function Parameters Are Immutable

In Rust:

```rust
fn shout(message: &str) {
    // message.push_str("!"); ❌ won't compile — `&str` is immutable
    println!("{}!", message);
}
```

Unless specified otherwise, all values are immutable. You need `mut` and possibly `&mut` to allow mutation.

---

## 🔁 Returning Values

```rust
fn square(x: i32) -> i32 {
    return x * x; // with return
    // or simply: x * x
}
```

Rust functions don’t require the `return` keyword if the last line is an expression (no semicolon).

---

## 🔄 Closures (Anonymous Functions)

Closures in Rust are like arrow functions in JavaScript:

```rust
let double = |x| x * 2;
println!("{}", double(5)); // prints 10
```

You can also explicitly annotate types:

```rust
let add = |a: i32, b: i32| -> i32 { a + b };
```

---

## 🧠 Differences from JavaScript Arrow Functions

| Concept       | JavaScript            | Rust                               |              |    |   |          |
| ------------- | --------------------- | ---------------------------------- | ------------ | -- | - | -------- |
| Syntax        | `x => x * 2`          | `\|x\| x * 2`                      | `x => x * 2` | \` | x | x \* 2\` |
| Scope capture | Lexical, by reference | Borrow, Mutate, or Move            |              |    |   |          |
| Typing        | Dynamic               | Static, inferred or explicit       |              |    |   |          |
| Return syntax | `return` required     | Last expression is returned        |              |    |   |          |
| Mutability    | All variables mutable | Mutable only with `mut` or `FnMut` |              |    |   |          |

Closures in Rust automatically capture variables from the surrounding scope — but depending on how they’re used, they may be classified as one of three types:

* `Fn` — read-only borrow
* `FnMut` — mutable borrow
* `FnOnce` — takes ownership (can be called once)

---

## 🧪 Passing Closures as Parameters

Sometimes you want to pass a closure or function as an argument to another function. Rust lets you do this with **generic type parameters and trait bounds**.

```rust
fn apply<F>(func: F, val: i32) -> i32
where
    F: Fn(i32) -> i32,
{
    func(val)
}
```

🔍 **Explanation:**

* `F` is a **generic type parameter**, representing *some* type
* `where F: Fn(i32) -> i32` is a **trait bound**, saying: “F must implement the `Fn(i32) -> i32` trait”
* `Fn(i32) -> i32` means: “a function (or closure) that takes an `i32` and returns an `i32`”
* So, this syntax is Rust’s way of working with **first-class functions** — just like passing callbacks in JavaScript

📌 You can rename `apply` to any other valid function name, like `execute`, `run`, or `call`, and it will work the same.

Usage:

```rust
let triple = |x| x * 3;
println!("{}", apply(triple, 5)); // prints 15
```

This is a powerful feature when building generic and composable logic.

Sometimes you want to pass a closure or function as an argument to another function. Rust lets you do this with **generic type parameters and trait bounds**.

```rust
fn apply<F>(func: F, val: i32) -> i32
where
    F: Fn(i32) -> i32,
{
    func(val)
}
```

🔍 **Explanation:**

* `F` is a generic type representing the closure
* `where F: Fn(i32) -> i32` constrains `F` to be any function or closure that:

  * Takes an `i32` as input
  * Returns an `i32`
* Inside the body, `func(val)` calls the passed closure with the value

Usage:

```rust
let triple = |x| x * 3;
println!("{}", apply(triple, 5)); // prints 15
```

This is a powerful feature when building generic and composable logic.

```rust
fn apply<F>(func: F, val: i32) -> i32
where
    F: Fn(i32) -> i32,
{
    func(val)
}

let triple = |x| x * 3;
println!("{}", apply(triple, 5)); // prints 15
```

This is a powerful feature when building generic and composable logic.

---

Up next: Structs, Enums and modeling data in Rust!

---

📝 **Note:** We'll cover `FnMut` and `FnOnce` in the final section of this guide, under *Advanced Topics*. These traits let you work with closures that mutate variables or take ownership — useful for more complex patterns.

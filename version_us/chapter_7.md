# Chapter 7 — Primitive Types and Objects: JavaScript vs Rust

Understanding a language’s building blocks is essential for writing clear, idiomatic code. This chapter explores **primitive types** and **object-like structures** in JavaScript and Rust, highlighting differences and overlaps.

## 7.1 Primitive types

| Concept        | JavaScript                | Rust                                 |
| -------------- | ------------------------- | ------------------------------------ |
| Integer        | `Number` (floating‑point) | `i32`, `u32`, `i64`, etc.            |
| Floating point | `Number`                  | `f32`, `f64`                         |
| Boolean        | `true`, `false`           | `bool`                               |
| String         | `"text"` or `'text'`      | `String`, `&str`                     |
| Null           | `null`                    | Not used (see `Option`)              |
| Undefined      | `undefined`               | Not used (uninitialized is an error) |
| Symbol         | `Symbol()`                | No direct equivalent                 |
| BigInt         | `BigInt(123)`             | `i128`, `u128`                       |

**Rust is statically typed**: you declare (or let the compiler infer) the exact type.

```rust
let age: u32 = 30;
let pi: f64 = 3.14;
let name: &str = "Felipe";
```

In JavaScript, all numbers are floating‑point and variables are dynamically typed:

```js
let age = 30;
let pi = 3.14;
let name = "Felipe";
```

## 7.2 Strings: `String` vs `&str`

* `String` in Rust is **heap‑allocated**, growable, and **owns** its data.
* `&str` is an **immutable string slice**, usually a borrowed view.

Example:

```rust
let owned = String::from("hello");
let borrowed: &str = &owned;
```

In JS, strings behave like immutable values:

```js
const owned = "hello";
```

## 7.3 Objects vs structs

JavaScript uses **objects** as flexible key‑value maps:

```js
const user = {
  name: "Laura",
  age: 30
};
```

Rust uses **structs** with named fields and fixed types:

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

Rust enforces compile‑time checks on field types and structure, unlike JS.

## 7.4 Passing by value vs by reference

### In JavaScript

* **Primitives** (numbers, strings, booleans) are passed **by value**.
* **Objects and arrays** are passed **by reference** (you copy a reference to the same object).

```js
let a = 5;
let b = a; // copy
b += 1;
console.log(a); // 5

let user = { name: "Laura" };
let user2 = user;
user2.name = "Felipe";
console.log(user.name); // "Felipe" — same reference
```

### In Rust

Rust **passes by value** by default — even for structs. To pass by reference, use `&` (borrow) or `&mut` (mutable borrow).

```rust
struct User { name: String, age: u32 }

fn modify_name(user: &mut User) {
    user.name = String::from("Felipe");
}

let mut user = User { name: String::from("Laura"), age: 30 };
modify_name(&mut user);
println!("{}", user.name); // "Felipe"
```

### Key difference

| Concept             | JavaScript                              | Rust                                                |
| ------------------- | --------------------------------------- | --------------------------------------------------- |
| Default passing     | Value (primitives), reference (objects) | Always by value; references only with `&T`/`&mut T` |
| Explicit references | ❌ automatic for objects                 | ✅ `&`, `&mut`                                       |
| Ownership           | ❌ not modeled                           | ✅ enforced by the compiler                          |

## 7.5 Summary

| Feature           | JavaScript              | Rust                         |
| ----------------- | ----------------------- | ---------------------------- |
| Type system       | Dynamic                 | Static                       |
| Type safety       | Weaker (runtime errors) | Strong (compile‑time checks) |
| Data modeling     | Flexible, untyped       | Rigid, typed with structs    |
| Memory management | Garbage‑collected       | Ownership + borrowing        |
| Null safety       | Error‑prone             | Modeled via `Option<T>`      |

> Next: **pattern matching and enums** — Rust’s alternative to `switch` and JS tagged unions.

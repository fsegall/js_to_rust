# Introduction

If you write JavaScript or TypeScript, you already have the mental models we need: objects and prototypes, modules, promises, error handling, array methods, and functional patterns. The goal of this book is to **translate those JS/TS mental models to Rust**, not drown you in new jargon. For every practice you already use, we show the Rust equivalent: objects → `struct`/`enum`, modules → crates/modules, promises → async *futures*, `try/catch` → `Result<T, E>` + `?`, and ad‑hoc duck typing → **traits** with generics. The format is light: short, side‑by‑side snippets with just enough explanation to bridge to your intuition.

**What you’ll do throughout the book**

* Chapters **1–12**: bite‑sized concepts — values vs references, ownership and borrowing (with real‑life analogies), pattern matching, generics, traits, iterators (**on‑demand evaluation**), error handling, modules, and async fundamentals. At each step, we include a **JS → Rust** comparison.
* Chapter **13**: a capstone project — an HTTP API with **Axum** and **SQLx**.
* Chapter **14** (bonus): OOP without classes in Rust — structs + `impl`, traits, and composition instead of inheritance.
* Chapter **15**: **Advanced Topics in Rust** — `Fn`/`FnMut`/`FnOnce`, smart pointers (`Box`, `Rc`, `RefCell`), `impl Trait` in return positions, advanced pattern matching, and module/visibility organization.

**Why JS developers tend to enjoy Rust**

* A familiar async story (`async/await`) with **explicit errors** (`Result` + `?`).
* A compiler that acts like a friendly reviewer, catching bugs before production.
* Performance and predictability without a garbage collector.

**How to read this book**

* Read the JS snippet first, then the Rust equivalent right below it.
* Don’t fight the borrow checker; **ask what it wants** and refactor. We’ll show the common patterns.
* Run the examples. Small wins add up quickly.

By the time you reach the capstone project, Rust should feel less like a brand‑new language and more like a stricter, faster dialect of ideas you already use every day. The comparisons will have done their job as a **bridge**; from there, you’ll write increasingly idiomatic Rust without mentally translating from JS.

> **Note:** At the end of the book there’s a **unified appendix** that dives deeper into (1) ad‑hoc duck typing and TypeScript’s **structural** model versus **traits** in Rust; and (2) Rust’s **method receivers** (`&self`, `&mut self`, `self`) compared to `this` (JS/TS) and `self`/`typing.Self` (Python). It’s a handy quick reference to cement the JS → Rust bridge.

> Next: **Chapter 1 — Why Rust? Comparing philosophies**.


# Chapter 1 — Why Rust? Comparing philosophies

Before we dive into tools or syntax, it’s worth stepping back to ask:

**Why learn Rust if you’re a JavaScript developer?**

Rust wasn’t designed to “replace” JavaScript; they solve different problems. Understanding Rust’s philosophy helps you adapt to its stricter rules and unlock its potential.

## Rust’s promise: performance with guarantees

Rust was designed to answer this question:

> *“Is it possible to get low-level performance **without** segfaults, data races, and memory leaks?”*

**What is a “segfault” (segmentation fault)?**
On protected-memory systems, each process may only access valid addresses in its address space. A segmentation fault happens when a program tries to read or write an **invalid address** (for example, a null or freed pointer, out-of-bounds array access, use-after-free, stack overflow, or attempting to execute data as code). The OS sends **SIGSEGV** and the process crashes. In **safe Rust**, these bug classes are prevented by **ownership/borrowing**, bounds-checked slices, and non-null references; even so, poorly used **`unsafe` code** or FFI can reintroduce risks.

**What is a “data race”?**
A data race occurs when **two or more threads access the same memory region at the same time**, **at least one of them writes**, and **there is no synchronization** establishing a happens-before order. The result is undefined behavior: corrupted values, intermittent crashes, and hard-to-reproduce bugs. In **safe Rust**, data races are prevented by the type system: you either have **multiple shared reads** (`&T`) or **one exclusive mutating access** (`&mut T`). To share mutation across threads, you use **synchronization types** (e.g., `Mutex<T>`, `RwLock<T>`, channels), and the auto-traits `Send`/`Sync` ensure safe cross-thread sharing.

**What is a memory leak?**
In practical terms, it’s when a process keeps consuming more memory because **allocated blocks are never released**. In GC languages, this often happens when references remain alive (e.g., in caches or globals), preventing collection. In manually managed languages, it happens when you forget to free (`free`/`delete`). In Rust, **ownership/borrowing** drops memory **deterministically** when the owner goes out of scope, avoiding whole classes of leaks and *dangling pointers*. Leaks are still possible (e.g., cycles with `Rc`, or deliberate use of `std::mem::forget`/`Box::leak`), but they tend to be rare and explicit by design.

Rust delivers:

* **Zero-cost abstractions**, as fast as C/C++, with safety
* **Memory safety without a garbage collector**
* **Compile-time guarantees** for concurrency and correctness

If you’re coming from JS, it can feel like going from a scooter (nimble, fun) to flying a jet (strict, powerful, requires training).

## Philosophical differences: Rust vs JavaScript

| Concept     | JavaScript                             | Rust                                     |
| ----------- | -------------------------------------- | ---------------------------------------- |
| Typing      | Dynamic, weak (TS is optional)         | Static, strong, compile-time checked     |
| Mutability  | Everything mutable except `const`      | Everything immutable unless `mut`        |
| Memory      | Garbage collector                      | Ownership (owning) and borrowing         |
| Errors      | `try/catch`, can throw anything        | Explicit `Result<T, E>` and `Option<T>`  |
| Concurrency | Event loop, `async/await`              | Threads, async, safe message passing     |
| Safety      | Runtime errors, coercions              | Compile-time safety, no null by default  |
| Tooling     | Lightweight (npm, yarn, browser-first) | Robust (cargo, crates.io, systems-first) |

## The big mindset shift

What may surprise you:

* In Rust, the **compiler is your partner**. It blocks the build until the code is correct. Annoying at first, it pays off over time.
* **No `null` or `undefined`**; use `Option<T>`.
* **Error handling** isn’t a `try/catch` fallback; it’s part of the function’s design.
* **Memory ownership** is governed by rules, not conventions.
* **Concurrency** starts safer thanks to the borrow checker.

Rust has a reputation for combining performance, reliability, and memory safety without a GC. While JavaScript dominates the web with flexibility, Rust lets you build faster, safer systems—especially for systems programming, WebAssembly, and other high-performance domains.

This book is for **JavaScript developers who want to learn Rust quickly and practically**, with side-by-side examples that highlight syntax differences and map your mental model to Rust’s compiler and type system.

## Who it’s for

* Frontend or backend devs in JS/TS
* Smart-contract engineers coming from web3 stacks
* Hackathon builders
* Anyone who wants to level up with a low-level language

## What you’ll learn

* Rust fundamentals (variables, functions, control flow)
* Ownership, borrowing, and lifetimes — Rust’s core
* Structs, enums, and pattern matching
* Rust-style error handling
* Modules, packages, and tests
* How to **think in Rust** coming from JS

## Learning strategy

This is a **project-oriented** book.

* Short JS ↔ Rust comparisons
* Mini-exercises for practice
* Simple but meaningful examples
* Practical tips to migrate your JS mental model to Rust

> If Rust has intimidated you before, this chapter is for you. We’ll smooth the curve with practical, no-nonsense guidance.

Next step: set up your Rust development environment.


# Chapter 2 — Setting up your Rust environment

Before writing your first line of Rust, let’s set up a productive and predictable environment.

## 2.1 Install with `rustup`

The recommended way to install Rust is **rustup**, which manages toolchains and components:

* Linux/macOS: run the official rustup install script (from the Rust website).
* Windows: use the rustup installer for Windows.

After installation, close and reopen your terminal so environment variables are refreshed.

### Verify the installation

```bash
rustc --version
cargo --version
rustup --version
```

If all three respond, you’re good to go.

### Select and update the stable toolchain

```bash
rustup default stable
rustup update
```

### Useful components

```bash
rustup component add rustfmt
rustup component add clippy
```

* **rustfmt** formats code automatically.
* **clippy** provides lints to improve readability and avoid pitfalls.

## 2.2 Editor and extension

Use any editor you like, but **VS Code + rust-analyzer** gives you:

* smart autocomplete,
* symbol navigation,
* real-time diagnostics,
* format on save.

Suggested settings (VS Code → *settings.json*):

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

> `RUSTFLAGS=-Dwarnings` treats warnings as errors when building from the editor, keeping quality high from day one.

## 2.3 Your first project with Cargo

**Cargo** is Rust’s package manager and build system.

Create a new project:

```bash
cargo new hello_rust
cd hello_rust
```

Initial layout:

```
hello_rust/
├─ Cargo.toml
└─ src/
   └─ main.rs
```

Default `src/main.rs`:

```rust
fn main() {
    println!("Hello, world!");
}
```

Run it:

```bash
cargo run
```

Other useful commands:

```bash
cargo check   # quick type/borrow checking without producing a final binary
cargo build   # compiles to target/debug
cargo test    # runs tests
cargo fmt     # formats code (rustfmt)
cargo clippy  # clippy lints
```

## 2.4 Understanding `Cargo.toml`

`Cargo.toml` plays the role of your `package.json`, describing metadata and dependencies:

```toml
[package]
name = "hello_rust"
version = "0.1.0"
edition = "2021"

[dependencies]
# example: serde = { version = "1", features = ["derive"] }
```

* `[package]` holds project metadata.
* `[dependencies]` lists third-party crates (like npm packages, but resolved via **crates.io**).
* You can also have `[dev-dependencies]` for test-only or example-only dependencies.

## 2.5 Comparing mental models (JS/TS ↔ Rust)

| Task               | JS/TS                    | Rust                                  |
| ------------------ | ------------------------ | ------------------------------------- |
| Create project     | `npm init` / `pnpm init` | `cargo new`                           |
| Install dependency | `npm install package`    | add to `Cargo.toml` and `cargo build` |
| Run app            | `npm run start`          | `cargo run`                           |
| Lint/format        | ESLint / Prettier        | `cargo clippy` / `cargo fmt`          |
| Types              | TypeScript (optional)    | Built-in static typing                |

The workflow will feel familiar: scripts to run, a manifest file, and a package registry. The difference is that the **compiler** participates more, enforcing correctness and performance during edit/compile cycles.

## 2.6 Troubleshooting tips

* **`cargo` not found**: reopen the terminal or ensure `~/.cargo/bin` (Linux/macOS) is on `PATH`.
* **Windows (Build Tools)**: if you hit linker/C toolchain errors, install "Desktop development with C++" (Build Tools) and restart the terminal.
* **Linux permissions**: avoid system package managers if `rustup` is available; keeping everything under `rustup` simplifies updates.

## 2.7 Next step

With your environment ready, let’s start with language fundamentals: working with **variables, types, and functions** in the next chapter.


# Chapter 3 — Variables, Types, and Functions

Rust encourages you to be explicit about values, mutability, and types. If in JS you freely change structures, in Rust code tends to be more predictable: everything is immutable by default and the compiler checks types and contracts before it runs.

## 3.1 Declaring variables

In Rust:

* Variables are **immutable by default**
* Use `mut` to make them mutable

```rust
fn main() {
    let name = "Felipe";     // immutable
    let mut age = 30;         // mutable

    // name = "Phillip";    // ❌ error: `name` is immutable
    age += 1;                  // ✅ ok, `age` is mutable
}
```

In JavaScript, the distinction is different:

```js
let name = "Felipe";   // mutable
const city = "SP";     // binding is immutable, but object contents may change
name = "Phillip";      // ✅ allowed with `let`
```

### Constants

In Rust, `const` requires an **explicit type** and is evaluated at compile time.

```rust
const MAX_USERS: u32 = 1000;
```

### Shadowing

You can **shadow** (redeclare with `let`) to transform or refine a value without making it mutable.

```rust
let input = "42";
let input: i32 = input.parse().unwrap();
// `input` is now i32, the parsed version of the string
```

## 3.2 Type inference and annotations

Rust infers types in most cases, but you can annotate when it helps clarity or when the compiler needs a hint.

```rust
let x = 10;           // inferred as i32
let y: i64 = 10;      // annotated
let price = 9.99_f32; // explicit suffix
```

## 3.3 Essential primitive types

| Category       | Rust                                     | JS/TS (approx.)                    |
| -------------- | ---------------------------------------- | ---------------------------------- |
| Integers       | `i8..i128`, `u8..u128`, `isize`, `usize` | `number` (IEEE‑754 floating value) |
| Floating point | `f32`, `f64`                             | `number`                           |
| Boolean        | `bool`                                   | `boolean`                          |
| Text           | `char`, `&str`, `String`                 | `string`                           |

> Tip: default to `i32` and `f64` unless you have a reason to choose a different size.

### Quick string notes

* `&str` is an **immutable string slice** (borrowed view)
* `String` **owns** its data. Use it to build and modify

```rust
let s1: &str = "hello";
let mut s2: String = String::from("hello");
s2.push('!');
```

## 3.4 Interpolation and formatting

In JS:

```js
const name = "Felipe";
console.log(`Hello, ${name}`);
```

In Rust:

```rust
let name = "Felipe";
println!("Hello, {}", name);
let message = format!("Welcome, {}!", name); // allocated string
```

## 3.5 Functions

Basic syntax:

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b // last expression without semicolon is the return value
}

fn main() {
    let sum = add(2, 3);
    println!("{}", sum);
}
```

Compared to JS:

```js
function add(a, b) {
  return a + b;
}
const sum = add(2, 3);
console.log(sum);
```

### Expressions vs. statements

The final **expression** in a Rust function may return without `return`. If you add a `;`, it becomes a **statement** and returns `()`.

```rust
fn double(x: i32) -> i32 {
    x * 2
}
```

### Multiple return values

Use **tuples** or a **struct** to return multiple typed values.

```rust
fn min_max(values: &[i32]) -> (i32, i32) {
    (*values.iter().min().unwrap(), *values.iter().max().unwrap())
}

struct Stats { min: i32, max: i32 }
fn stats(values: &[i32]) -> Stats {
    Stats { min: *values.iter().min().unwrap(), max: *values.iter().max().unwrap() }
}
```

In JS, you’d likely return an object:

```js
function stats(values) {
  return { min: Math.min(...values), max: Math.max(...values) };
}
```

## 3.6 References and a preview of ownership

You can **borrow** a reference to a value without transferring ownership. This avoids unnecessary copies.

```rust
fn len(s: &String) -> usize { s.len() }

fn main() {
    let name = String::from("Felipe");
    let n = len(&name); // borrow an immutable reference
    println!("{} {}", name, n); // `name` is still usable
}
```

To modify through a reference, use `&mut` and respect the borrowing rules (one exclusive mutable reference or many immutable ones, but not both at the same time).

```rust
fn shout(s: &mut String) { s.push_str("!!!"); }

fn main() {
    let mut s = String::from("hey");
    shout(&mut s); // pass a mutable reference
}
```

> Ownership and lifetimes will be covered in the next chapters. For now, think of references as safe “loans” the compiler verifies.

## 3.7 Summary table

| Feature         | JavaScript                  | Rust                         |
| --------------- | --------------------------- | ---------------------------- |
| Variable        | `let`, `const`              | `let`, `let mut`, `const`    |
| Types           | Dynamic (TS optional)       | Static, inferred or explicit |
| Functions       | `function`, arrow functions | `fn`, with type annotations  |
| Template string | `` `Hello, ${name}` ``      | `format!("Hello, {}", name)` |

## 3.8 Takeaways

* Prefer immutability; use `mut` only when necessary
* Add type annotations for clarity when inference isn’t obvious
* Use `format!` and `println!` for interpolation
* Return values via the final expression; use tuples/structs for multiple values
* Start noticing when to use references (`&T`, `&mut T`) instead of clones

Next: **control flow and conditionals**. We’ll compare `if/else` and `switch` with `match` and other idiomatic Rust constructs.


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


# Chapter 6 — Collections and Loops

Rust offers several collection types—from **fixed-size arrays** to **growable vectors** and **tuples**. Iterating over these collections is also powerful, with `for`, `while`, and functional-style iterators.

If you already work with arrays and objects in JavaScript, some syntax will feel familiar—only here you get **strong typing** and **ownership rules**.

## 6.1 Arrays and vectors

### Fixed-size array

```rust
let numbers: [i32; 3] = [1, 2, 3];
println!("First: {}", numbers[0]);
```

### Growable vector (`Vec`)

```rust
let mut scores = vec![90, 85, 72];
scores.push(100);
println!("Last: {}", scores[scores.len() - 1]);
```

In JavaScript:

```js
const scores = [90, 85, 72];
scores.push(100);
console.log(scores[scores.length - 1]);
```

## 6.2 Tuples

Tuples group values of **different types** into a single ordered structure.

```rust
let user: (&str, u32) = ("Felipe", 34);
println!("Name: {}, Age: {}", user.0, user.1);
```

In JavaScript (simulated with an array):

```js
const user = ["Felipe", 34];
console.log(`Name: ${user[0]}, Age: ${user[1]}`);
```

## 6.3 Loops

### `for`

```rust
for score in &scores {
    println!("Score: {}", score);
}
```

In JavaScript:

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

## 6.4 Functional iterators

```rust
let doubled: Vec<i32> = scores.iter().map(|x| x * 2).collect();
println!("{:?}", doubled);
```

In JavaScript:

```js
const doubled = scores.map(x => x * 2);
console.log(doubled);
```

## 6.5 Summary table

| Concept    | JavaScript            | Rust                         |
| ---------- | --------------------- | ---------------------------- |
| Array      | `[1, 2, 3]`           | `[i32; 3]` or `Vec<i32>`     |
| Tuple      | `['a', 1]`            | `(&str, i32)`                |
| Loop       | `for/of`, `while`     | `for`, `while`, `loop`       |
| Map/filter | `.map()`, `.filter()` | `.iter().map()`, `.filter()` |

> Next: **Primitive Types and Objects: JavaScript vs Rust** (Chapter 7).


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


# Chapter 8 — Structs, Enums, and Data Modeling

`struct`s and `enum`s are two of Rust’s most powerful tools for organizing and modeling data — and they’re often more expressive and stricter than JavaScript objects and unions.

This chapter shows how to define and use these building blocks, how they relate to JavaScript objects, and how **pattern matching** ties everything together with safety and clarity.

## 8.1 Structs (like objects in JS)

Note: A few concepts appear here for context — **borrowing** (references), **ownership**, and **lifetimes**. We’ll go deeper in the next chapters.

### Quick definitions

* **Ownership**: how Rust manages memory by tracking who **owns** a value.
* **Borrowing**: temporarily accessing data without taking ownership (`&T` or `&mut T`).
* **Lifetimes**: annotations that tell the compiler **how long** references are valid.

### Note on `&str` vs `String`

Rust has two primary text types:

* `&str` is an **immutable string slice**, often used as a borrowed reference.
* `String` is a **heap‑allocated, growable** string that **owns** its data.

In function arguments and struct fields, use `String` when you need **ownership**; use `&str` when **borrowing** is enough.

Example:

```rust
struct User {
    name: String, // owns the name value
    age: u32,
}
```

This means the struct fully **owns** its data. If you used `&str`, you’d need to manage **lifetimes** explicitly.

Structs define **custom data types**:

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

In JavaScript:

```js
const user = {
  name: "Laura",
  age: 28
};
console.log(`${user.name} is ${user.age} years old`);
```

## 8.2 Struct initialization with `..`

This syntax resembles JS spread (`...user`), but with important differences.

```rust
let user2 = User {
    name: String::from("Paulo"),
    ..user
};
```

What happens:

* Copies the `age` field from `user` into `user2` (because `u32` is `Copy`).
* Overrides `name` with a new value.
* **Moves** the remaining fields from `user` into `user2`. Since `name: String` is **not** `Copy`, `user` can **no longer** be used.

```rust
println!("{}", user.age); // ❌ compile error: `user` was moved
```

In JavaScript:

```js
const user = { name: "Laura", age: 28 };
const user2 = { ...user, name: "Paulo" };
console.log(user.age); // ✅ still works
```

Rust’s **ownership rules** make data handling predictable and prevent subtle bugs.

## 8.3 Enums (tagged unions with power)

An `enum` defines a type that can be **one of several variants**:

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

In JavaScript (less safe):

```js
const status = { type: "Blocked", reason: "Too many attempts" };
if (status.type === "Blocked") {
  console.log(`Blocked: ${status.reason}`);
}
```

## 8.4 Pattern‑matching recap

Using `match` with enums lets you handle **all variants** safely and **exhaustively**:

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

Note on `=>` in `match`: this is **not** a JS arrow function. In Rust, `=>` associates a **pattern** with an **expression or block**. It’s part of the pattern‑matching syntax and ensures each variant is handled explicitly.

```rust
match some_value {
    Pattern => result,
}
```

Think of `match` as a type‑checked, no‑fallthrough `switch` with required exhaustiveness.

## 8.5 When to use `struct` vs `enum`

* Use a **`struct`** when you want to **group related data**.
* Use an **`enum`** when a value can be **one of several variants** (with or without associated data).

> Next: **Ownership, Borrowing, and Lifetimes** — how Rust programmers manage memory without a garbage collector.


# Chapter 9 — Ownership, Borrowing, and Lifetimes

Memory safety in Rust comes from one central idea: **ownership**. Unlike JavaScript’s garbage‑collected model, Rust guarantees safety **at compile time**—with no runtime overhead—by enforcing rules on how values are moved, copied, and referenced.

## 9.1 Ownership

**What is a “double free”?**
In C/C++‑style languages, it happens when the same block of memory is freed twice. This can lead to crashes, memory corruption, or security issues.

Rust prevents double frees by enforcing **ownership** at compile time: a value is freed **exactly once**, when its **single owner** goes out of scope. If a value is **moved**, the original variable becomes invalid, eliminating the risk of freeing the same memory twice.

Every value in Rust has **one owner**—the variable that holds it.

```rust
let s = String::from("hello");
```

When `s` is created, it **owns** the heap allocation. If we assign it to another variable:

```rust
let s1 = String::from("hello");
let s2 = s1; // ownership moved!
```

After the move, `s1` is **no longer valid**. Using it is a compile‑time error:

```rust
println!("{}", s1); // ❌ compile error
```

This prevents double frees and related memory bugs.

✅ Primitive types (integers, bool, etc.) usually implement `Copy`, so they **do not** move:

```rust
let x = 5;
let y = x; // x remains valid
```

## 9.2 Borrowing

Instead of moving a value, you can **borrow** it:

```rust
fn print_length(s: &String) {
    println!("Length: {}", s.len());
}

let s = String::from("hello");
print_length(&s); // pass by reference
println!("Still valid: {}", s);
```

Borrowing gives access **without transferring ownership**.

* `&T` = shared borrow (read‑only)
* `&mut T` = mutable borrow (read/write)

You cannot have **mutable and shared borrows at the same time** of the same value:

```rust
let mut s = String::from("hi");
let r1 = &s;
let r2 = &s;
let r3 = &mut s; // ❌ compile error
```

## 9.3 Lifetimes (overview)

*Lifetimes* describe **how long** a reference is valid. Most of the time, the compiler **infers** them. When multiple references relate to each other, you may need to **annotate**:

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

We’ll explore lifetimes in more detail later.

## 9.4 Conceptual analogy with JS

| Concept    | JavaScript                   | Rust                       |
| ---------- | ---------------------------- | -------------------------- |
| GC         | Automatic                    | No GC — ownership enforced |
| References | Any number, any time         | Borrowing with rules       |
| Mutation   | Few restrictions             | Exclusive via `&mut`       |
| Leaks      | Possible without care        | Prevented by the compiler  |
| Lifetime   | Implicit, decided at runtime | Tracked at compile time    |

> Next: express the **possibility of failure** in the type system—with `Option<T>` and `Result<T, E>`.


# Chapter 10 — Error Handling with `Option` and `Result`

Rust does not use exceptions. Instead, it encodes the **possibility** of failure directly in the type system with two powerful enums: `Option<T>` and `Result<T, E>`.

## 10.1 `Option<T>`

**Note:** `Some` and `None` are not keywords; they are the two variants of Rust’s `Option<T>` enum:

```rust
enum Option<T> {
    Some(T),
    None,
}
```

When you write `Some(42)` or `None`, you are using enum constructors to wrap a value or represent its absence.

Represents a value that might be present or absent:

```rust
let some_number = Some(42);
let no_number: Option<i32> = None;
```

This is Rust’s alternative to `null`/`undefined`, but **checked by the type system**, which prevents the classic null‑pointer surprise at runtime:

```rust
fn maybe_double(x: Option<i32>) -> Option<i32> {
    match x {
        Some(n) => Some(n * 2),
        None => None,
    }
}
```

✅ Use `Option<T>` when a value **might not exist**.

## 10.2 `Result<T, E>`

Represents success (`Ok`) or failure (`Err`):

```rust
fn safe_divide(x: i32, y: i32) -> Result<i32, String> {
    if y == 0 {
        Err("division by zero".to_string())
    } else {
        Ok(x / y)
    }
}
```

✅ Use `Result<T, E>` when **something can go wrong** and you want to **return an error**.

## 10.3 Handling results

Use pattern matching with `match`:

```rust
match safe_divide(10, 2) {
    Ok(result) => println!("Result: {}", result),
    Err(e) => println!("Error: {}", e),
}
```

## 10.4 Shortcut: `if let`

```rust
let result = Some(42);
if let Some(x) = result {
    println!("Value is {}", x);
}
```

## 10.5 Caution: `unwrap`

```rust
let n = Some(5);
println!("{}", n.unwrap()); // panics if None
```

Use `unwrap` **only** when you are certain the value is present.

## 10.6 Best practices

* Prefer `match` or `if let` for safe handling.
* Avoid `unwrap()` outside quick prototypes or tests.
* Use `.expect("message")` to document why an unwrap is safe.

## 10.7 Compared to JavaScript

| Concept        | JavaScript          | Rust                       |
| -------------- | ------------------- | -------------------------- |
| null/undefined | Runtime, unchecked  | `Option<T>` (compile‑time) |
| try/catch      | Exceptions, dynamic | `Result<T, E>` enum        |
| throw          | Any type            | Typed `Err(E)`             |

> Next: **Lifetimes (deep dive)** — how Rust tracks the validity of references across functions and scopes.


# Chapter 11 — Lifetimes in Rust (Deep Dive)

*Lifetimes* are one of Rust’s most distinctive—and, at first, intimidating—features. They exist to ensure **memory safety without a garbage collector** by tracking **how long** references remain valid.

## 11.1 Why lifetimes exist

Think of borrowing a book: you can’t keep it forever; you must return it before the owner needs it. Lifetimes do the same for **references**: a reference **must not** outlive the data it points to.

In GC languages (like JavaScript or Python), memory is managed at runtime. In Rust, **ownership** and **borrowing** are checked at compile time—and lifetimes are the mechanism the compiler uses to verify that all borrows are valid.

## 11.2 Lifetimes in function signatures

You’ll see lifetimes in functions that **return references**:

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

This says:

* `'a` is a **lifetime parameter**.
* `x` and `y` live **at least** as long as `'a`.
* The return value is valid for the same `'a`.

In other words, the returned reference **will not** outlive either input.

## 11.3 Annotations don’t change behavior

Lifetimes don’t affect how the program runs—they are **for the compiler only**. When reference lifetimes are obvious, Rust often **infers** everything.

```rust
fn print_ref(x: &str) {
    println!("{}", x);
}
```

No annotation is needed here: the compiler knows `x` lives long enough during the call.

## 11.4 When lifetime errors appear

You’ll see errors when you:

* try to return a reference to a **value that has gone out of scope**;
* use **structs with references** without declaring lifetimes;
* mix **mutable and immutable borrows** in incompatible ways.

Classic dangling-reference example:

```rust
let r;
{
    let x = 5;
    r = &x; // ❌ `x` does not live long enough
}
println!("{}", r); // error: borrowed value does not live long enough
```

Rust prevents dangling references **at compile time**.

## 11.5 Lifetime elision rules

To avoid verbose annotations, the compiler applies elision rules in most cases:

1. Each reference parameter gets **its own** inferred lifetime.
2. If there is **one** input reference, its lifetime is assigned to the **output**.
3. If `&self`/`&mut self` is present, the **output** gets the same lifetime as `self`.

That’s why this compiles without an explicit `'a`:

```rust
fn first(x: &str) -> &str { x }
```

## 11.6 Lifetimes in structs

If you want to **store references** inside `struct`s, you must declare a lifetime:

```rust
struct Book<'a> {
    title: &'a str,
}

let title = String::from("Rust Book");
let book = Book { title: &title };
```

The struct says: “I contain a reference and **must not** live longer than it.”

What if `title` is dropped too early?

```rust
let book_ref;
{
    let title = String::from("Rust Book");
    book_ref = Book { title: &title }; // ❌ `title` does not live long enough
}
// `title` is dropped here, but `book_ref` would still exist → unsafe
```

✅ To **avoid lifetimes** here, make the struct **own** the data by using `String` instead of `&str`:

```rust
struct Book { title: String }
```

## 11.7 Lifetimes vs JavaScript (analogy)

| Concept             | Rust                                | JavaScript                |
| ------------------- | ----------------------------------- | ------------------------- |
| Reference safety    | Checked at compile time (lifetimes) | Not enforced (GC handles) |
| Dangling references | Compile-time error                  | Can cause runtime bugs    |
| Borrow checker      | Yes                                 | No                        |
| Memory leaks        | Possible, but rare                  | Possible                  |

## 11.8 Takeaways

* Lifetimes ensure **references are always valid**.
* They prevent dangling references and entire classes of memory bugs.
* Most lifetimes are **inferred**; annotate only in the trickier cases (returning references, structs with references, multiple interrelated borrows).

> Next: **Iterators and the `Iterator` trait**—composition with `map`, `filter`, `collect`, plus ergonomics with `Option`/`Result`.


# Chapter 12 — Iterators and Lazy Loading (On‑Demand Evaluation)

Iterators are one of Rust’s most expressive tools. They let you chain, transform, and consume data sequences with **zero‑cost abstractions**.

In this chapter, we’ll see how Rust handles iteration, contrast it with JavaScript’s `Array.prototype.map` and generators, and introduce the idea of **on‑demand evaluation** via the `Iterator` trait.

## 12.1 Iteration in JavaScript vs Rust

### JavaScript

```js
const nums = [1, 2, 3];
const doubled = nums.map(x => x * 2);
console.log(doubled); // [2, 4, 6]
```

* Methods like `map`, `filter`, and `reduce` **eagerly evaluate** and return new arrays.

### Rust

```rust
let nums = vec![1, 2, 3];
let doubled: Vec<i32> = nums.iter().map(|x| x * 2).collect();
println!("{:?}", doubled); // [2, 4, 6]
```

* `.iter()` creates an **iterator** (on‑demand).
* `.map(...)` defines a transformation — **not executed yet**.
* `.collect()` forces evaluation and produces the final result.

## 12.2 On‑Demand Evaluation in Rust

Rust iterators are **evaluated on demand**:

* Nothing happens until you call `collect()`, use a `for` loop, or call consumers like `sum()` or `count()`.
* This enables efficient pipelines **without intermediate allocations**.

```rust
let result: i32 = (1..)
    .map(|x| x * x)
    .filter(|x| x % 2 == 0)
    .take(5)
    .sum();

println!("Sum of first 5 even squares: {}", result); // 120
```

Here, `(1..) `is an **infinite range**, and `take(5)` limits the sequence.

## 12.3 Custom Iterators

To build your own iterator, implement the `Iterator` trait:

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

This feels like a generator: values are produced **on demand**.

## 12.4 Comparison: JS Generators vs Rust Iterators

| Feature            | JavaScript Generators        | Rust Iterators                     |
| ------------------ | ---------------------------- | ---------------------------------- |
| On‑demand          | Yes                          | Yes                                |
| Syntax             | `function* () { yield ... }` | `impl Iterator for MyType`         |
| Infinite sequences | Yes, with care               | Yes, with `take()` for safety      |
| Ergonomics         | Concise                      | A bit more boilerplate, more power |
| Performance        | Medium                       | High (zero‑cost abstraction)       |
| Memory safety      | No guarantees                | Ownership + lifetimes              |

## 12.5 Summary

* The `Iterator` trait defines **composable** sequences evaluated **on demand**.
* Methods like `.map()`, `.filter()`, `.take()` chain transformations and **only evaluate** when needed.
* You can define custom iterators by implementing `next()`.
* Iterators are **memory‑safe** and highly optimized.

> Next: **From Express to Axum: building an HTTP server**.


# Chapter 13 — Final Project: CRUD Server with Rust, Axum, and SQLite (Axum 0.7)

In this chapter, we’ll consolidate what you’ve learned by building a real project: a fully‑featured **CRUD** server using **Rust**, the **Axum** framework, and **SQLite**.

Our goal is to **migrate the logic of a traditional Express.js server** to Rust — showing that you can write modern, safe, high‑performance APIs with static typing and zero runtime overhead.

---

## Project overview -  Source code: https://github.com/fsegall/js_to_rust

### What we’ll build

* RESTful endpoints: `GET`, `POST`, `PUT`, `DELETE`.
* Persistence with SQLite.
* Strongly typed structs and enums.
* Error handling with `Result` and conversion to HTTP responses.
* Modular, scalable architecture.

### Stack comparison

| Component  | JavaScript (Express)      | Rust (Axum)                |
| ---------- | ------------------------- | -------------------------- |
| Framework  | Express                   | Axum                       |
| Database   | SQLite (`sqlite3`)        | SQLite (`sqlx`)            |
| Routing    | `app.get()`, `app.post()` | `Router::new().route(...)` |
| Middleware | Custom functions          | `tower` middleware         |
| Typing     | Dynamic                   | Static (structs + enums)   |

---

## Chapter structure

1. **Project setup**: dependencies, layout, and SQLite
2. **Express version**: a minimal JavaScript CRUD
3. **Axum version**: step‑by‑step rewrite in Rust
4. **Side‑by‑side comparison**: safety and performance in Rust
5. **Testing & usage**: `curl`, validations, and logging
6. **Wrap‑up**: benefits and trade‑offs of Rust on the backend

---

## 13.1 — Setup: Axum + SQLite

Create a new Rust project with Cargo and add the required dependencies.

### Step 1: create the project

```bash
cargo new axum_crud_project
cd axum_crud_project
```

### Step 2: add dependencies to `Cargo.toml`

> **Axum 0.7**: we use the current API with `axum::serve` (no `into_make_service`).

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

### Step 3: folder structure

```
src/
├── main.rs          # entry point
├── db.rs            # SQLite setup and connection pool
├── handlers.rs      # route logic
├── models.rs        # data types and errors
└── routes.rs        # route composition
```

> We’ll keep things modular for reuse and easier testing.

---

## 13.2 — Reference: Express.js version (JavaScript)

Before the Rust version, here’s a minimal CRUD with Express and SQLite **including `name` and `email`** (to stay consistent with the Rust version):

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

That’s the functionality we’ll reproduce with Axum.

---

## 13.3 — Booting a minimal Axum server (Axum 0.7)

> **Important change (0.6 → 0.7):** use `tokio::net::TcpListener` and `axum::serve(listener, app)`. We no longer use `into_make_service()`.

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

Data models, input/output types, and the application error converted into an HTTP response.

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

**Notes**

* `FromRow` maps SQLite columns to the struct.
* `AppError` centralizes errors and becomes an HTTP response via `IntoResponse`.

---

## 13.5 — `db.rs`

Database connection and initialization.

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

    // Minimal table (use migrations in production)
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

Functions that handle each route.

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
    // Partial update with COALESCE
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

Define routes and build the `Router` (with typed state):

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

> You can also import only `get` and then chain `.post/.put/.delete` as methods.

---

## 13.8 — `main.rs` (final version)

Wires everything together: app state, routes, logging, and server.

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
    // simple logging (RUST_LOG=info by default, override via env)
    let _ = fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .try_init();

    // DATABASE_URL, e.g. sqlite://data/axum.db?mode=rwc
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

> **Axum 0.7:** we use `TcpListener` + `axum::serve` (no `into_make_service`).

---

## 13.9 — Quick `curl` tests

Create, list, update, and delete users.

```bash
# create (with name and email)
curl -sS -X POST http://127.0.0.1:3000/users \
  -H 'content-type: application/json' \
  -d '{"name":"Ada Lovelace","email":"ada@calc.org"}' | jq

# list
curl -sS http://127.0.0.1:3000/users | jq

# fetch by id
curl -sS http://127.0.0.1:3000/users/1 | jq

# partial update (name only)
curl -sS -X PUT http://127.0.0.1:3000/users/1 \
  -H 'content-type: application/json' \
  -d '{"name":"Ada L."}' | jq

# delete
curl -i -X DELETE http://127.0.0.1:3000/users/1
```

**Tip:** ensure the DB file exists by using a `data/` folder and setting the URL:

```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
```

---

## 13.10 — Express ↔ Axum comparison and final thoughts

### 13.10.1 Express ↔ Axum comparison

| Topic        | Express (JS)                              | Axum (Rust)                                                    |
| ------------ | ----------------------------------------- | -------------------------------------------------------------- |
| Server boot  | `const app = express(); app.listen(3000)` | `let app = Router::new(); axum::serve(TcpListener, app)`       |
| Routes       | `app.get("/users", handler)`              | `Router::new().route("/users", get(handler))`                  |
| Path params  | `req.params.id`                           | `Path<i64>` in the handler                                     |
| Query params | `req.query`                               | `Query<T>` (with `serde::Deserialize`)                         |
| JSON body    | `app.use(express.json())` + `req.body`    | `Json<T>` (with `serde::Deserialize`)                          |
| Responses    | `res.status(201).json({...})`             | `impl IntoResponse`, `Json(...)`, `StatusCode`                 |
| Middleware   | `app.use(mw)`                             | `tower` layers: `.layer(...)` or `middleware::from_fn`         |
| SQLite       | `sqlite3` callbacks                       | Async `sqlx` (`query`, `query_as`), compile‑time type checking |
| Logging      | `morgan("dev")`                           | `tracing` + `tracing-subscriber`                               |
| Config/env   | `process.env.X`                           | `std::env::var("X")`                                           |
| HTTP tests   | `supertest`/Jest                          | `reqwest` + `#[tokio::test]` (building a `Router`)             |
| Hot reload   | `nodemon`                                 | `cargo watch -x run`                                           |

#### Side‑by‑side examples

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

#### Migration checklist: Express → Axum

1. Define models (`struct`) with `serde` (`Serialize`/`Deserialize`).
2. Create `AppError` and a `Result<T>` alias; implement `IntoResponse`.
3. Configure `SqlitePool` in `db.rs` and initialize the table.
4. Write handlers returning `Result<...>` and use `?`.
5. Build the `Router` in `routes.rs` and inject `AppState` with `.with_state(...)`.
6. Wire everything in `main.rs`, read `DATABASE_URL`.
7. Add `tracing` and, if needed, `tower` middlewares.
8. Test with `curl`/`reqwest`.

### 13.10.2 Final thoughts

* **Safety and predictability:** the compiler prevents entire classes of bugs (wrong types, nulls, silent failures).
* **Performance:** no GC; efficient IO/CPU; `sqlx` and Axum are async with low overhead.
* **Ergonomics:** more verbosity upfront (types, `Result`, ownership), but linear handlers with `?` and `IntoResponse`.
* **Architecture:** separating `models`, `handlers`, `db`, `routes` makes testing and evolution easier.
* **Trade‑offs:** longer compile times and the borrow checker learning curve.

**Next steps**

* Pagination and filters in `/users`.
* Migrations (`sqlx::migrate!`) and indexes.
* Authentication (JWT), CORS, rate‑limiting (`tower` layer).
* Integration tests (`#[tokio::test]` + `reqwest`).
* Observability: `tracing` spans, metrics, `tower-http` for logs.

> Congrats! We’ve wrapped up the CRUD project. From here, you have the practical foundation to design idiomatic APIs in Rust.

---

## Appendix A — `README.md` snippet

````markdown
# Axum CRUD — Final Project (Rust for JS Devs)

Backend: **Axum 0.7 + SQLite (SQLx)**.

## Run
```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
# → Server on http://127.0.0.1:3000
````

## Endpoints

* `GET /users` — list
* `POST /users` — create `{ name, email }`
* `GET /users/:id` — fetch by id
* `PUT /users/:id` — partial update `{ name?, email? }`
* `DELETE /users/:id` — remove

````

## Appendix B — CORS tip (optional)

```toml
# Cargo.toml
tower-http = { version = "0.5", features = ["cors"] }
````

```rust
// in main.rs, before serve()
use tower_http::cors::CorsLayer;
let app = routes::app(state).layer(CorsLayer::permissive());
```

## Appendix C — Axum 0.6 → 0.7 migration (summary)

* **Before (0.6):** `axum::Server::bind(addr).serve(app.into_make_service())`.
* **Now (0.7):** `let listener = TcpListener::bind(addr).await?; axum::serve(listener, app).await?;`.
* Handlers still implement `IntoResponse`/`Result<T, E>`; routing remains with `get/post/put/delete`.

# Chapter 13 — Final Project: CRUD Server with Rust, Axum, and SQLite (Axum 0.7)

In this chapter, we’ll consolidate what you’ve learned by building a real project: a fully‑featured **CRUD** server using **Rust**, the **Axum** framework, and **SQLite**.

Our goal is to **migrate the logic of a traditional Express.js server** to Rust — showing that you can write modern, safe, high‑performance APIs with static typing and zero runtime overhead.

---

## Project overview

### What we’ll build

* RESTful endpoints: `GET`, `POST`, `PUT`, `DELETE`.
* Persistence with SQLite.
* Strongly typed structs and enums.
* Error handling with `Result` and conversion to HTTP responses.
* Modular, scalable architecture.

### Stack comparison

| Component  | JavaScript (Express)      | Rust (Axum)                |
| ---------- | ------------------------- | -------------------------- |
| Framework  | Express                   | Axum                       |
| Database   | SQLite (`sqlite3`)        | SQLite (`sqlx`)            |
| Routing    | `app.get()`, `app.post()` | `Router::new().route(...)` |
| Middleware | Custom functions          | `tower` middleware         |
| Typing     | Dynamic                   | Static (structs + enums)   |

---

## Chapter structure

1. **Project setup**: dependencies, layout, and SQLite
2. **Express version**: a minimal JavaScript CRUD
3. **Axum version**: step‑by‑step rewrite in Rust
4. **Side‑by‑side comparison**: safety and performance in Rust
5. **Testing & usage**: `curl`, validations, and logging
6. **Wrap‑up**: benefits and trade‑offs of Rust on the backend

---

## 13.1 — Setup: Axum + SQLite

Create a new Rust project with Cargo and add the required dependencies.

### Step 1: create the project

```bash
cargo new axum_crud_project
cd axum_crud_project
```

### Step 2: add dependencies to `Cargo.toml`

> **Axum 0.7**: we use the current API with `axum::serve` (no `into_make_service`).

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

### Step 3: folder structure

```
src/
├── main.rs          # entry point
├── db.rs            # SQLite setup and connection pool
├── handlers.rs      # route logic
├── models.rs        # data types and errors
└── routes.rs        # route composition
```

> We’ll keep things modular for reuse and easier testing.

---

## 13.2 — Reference: Express.js version (JavaScript)

Before the Rust version, here’s a minimal CRUD with Express and SQLite **including `name` and `email`** (to stay consistent with the Rust version):

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

That’s the functionality we’ll reproduce with Axum.

---

## 13.3 — Booting a minimal Axum server (Axum 0.7)

> **Important change (0.6 → 0.7):** use `tokio::net::TcpListener` and `axum::serve(listener, app)`. We no longer use `into_make_service()`.

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

Data models, input/output types, and the application error converted into an HTTP response.

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

**Notes**

* `FromRow` maps SQLite columns to the struct.
* `AppError` centralizes errors and becomes an HTTP response via `IntoResponse`.

---

## 13.5 — `db.rs`

Database connection and initialization.

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

    // Minimal table (use migrations in production)
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

Functions that handle each route.

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
    // Partial update with COALESCE
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

Define routes and build the `Router` (with typed state):

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

> You can also import only `get` and then chain `.post/.put/.delete` as methods.

---

## 13.8 — `main.rs` (final version)

Wires everything together: app state, routes, logging, and server.

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
    // simple logging (RUST_LOG=info by default, override via env)
    let _ = fmt()
        .with_env_filter(EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new("info")))
        .try_init();

    // DATABASE_URL, e.g. sqlite://data/axum.db?mode=rwc
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

> **Axum 0.7:** we use `TcpListener` + `axum::serve` (no `into_make_service`).

---

## 13.9 — Quick `curl` tests

Create, list, update, and delete users.

```bash
# create (with name and email)
curl -sS -X POST http://127.0.0.1:3000/users \
  -H 'content-type: application/json' \
  -d '{"name":"Ada Lovelace","email":"ada@calc.org"}' | jq

# list
curl -sS http://127.0.0.1:3000/users | jq

# fetch by id
curl -sS http://127.0.0.1:3000/users/1 | jq

# partial update (name only)
curl -sS -X PUT http://127.0.0.1:3000/users/1 \
  -H 'content-type: application/json' \
  -d '{"name":"Ada L."}' | jq

# delete
curl -i -X DELETE http://127.0.0.1:3000/users/1
```

**Tip:** ensure the DB file exists by using a `data/` folder and setting the URL:

```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
```

---

## 13.10 — Express ↔ Axum comparison and final thoughts

### 13.10.1 Express ↔ Axum comparison

| Topic        | Express (JS)                              | Axum (Rust)                                                    |
| ------------ | ----------------------------------------- | -------------------------------------------------------------- |
| Server boot  | `const app = express(); app.listen(3000)` | `let app = Router::new(); axum::serve(TcpListener, app)`       |
| Routes       | `app.get("/users", handler)`              | `Router::new().route("/users", get(handler))`                  |
| Path params  | `req.params.id`                           | `Path<i64>` in the handler                                     |
| Query params | `req.query`                               | `Query<T>` (with `serde::Deserialize`)                         |
| JSON body    | `app.use(express.json())` + `req.body`    | `Json<T>` (with `serde::Deserialize`)                          |
| Responses    | `res.status(201).json({...})`             | `impl IntoResponse`, `Json(...)`, `StatusCode`                 |
| Middleware   | `app.use(mw)`                             | `tower` layers: `.layer(...)` or `middleware::from_fn`         |
| SQLite       | `sqlite3` callbacks                       | Async `sqlx` (`query`, `query_as`), compile‑time type checking |
| Logging      | `morgan("dev")`                           | `tracing` + `tracing-subscriber`                               |
| Config/env   | `process.env.X`                           | `std::env::var("X")`                                           |
| HTTP tests   | `supertest`/Jest                          | `reqwest` + `#[tokio::test]` (building a `Router`)             |
| Hot reload   | `nodemon`                                 | `cargo watch -x run`                                           |

#### Side‑by‑side examples

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

#### Migration checklist: Express → Axum

1. Define models (`struct`) with `serde` (`Serialize`/`Deserialize`).
2. Create `AppError` and a `Result<T>` alias; implement `IntoResponse`.
3. Configure `SqlitePool` in `db.rs` and initialize the table.
4. Write handlers returning `Result<...>` and use `?`.
5. Build the `Router` in `routes.rs` and inject `AppState` with `.with_state(...)`.
6. Wire everything in `main.rs`, read `DATABASE_URL`.
7. Add `tracing` and, if needed, `tower` middlewares.
8. Test with `curl`/`reqwest`.

### 13.10.2 Final thoughts

* **Safety and predictability:** the compiler prevents entire classes of bugs (wrong types, nulls, silent failures).
* **Performance:** no GC; efficient IO/CPU; `sqlx` and Axum are async with low overhead.
* **Ergonomics:** more verbosity upfront (types, `Result`, ownership), but linear handlers with `?` and `IntoResponse`.
* **Architecture:** separating `models`, `handlers`, `db`, `routes` makes testing and evolution easier.
* **Trade‑offs:** longer compile times and the borrow checker learning curve.

**Next steps**

* Pagination and filters in `/users`.
* Migrations (`sqlx::migrate!`) and indexes.
* Authentication (JWT), CORS, rate‑limiting (`tower` layer).
* Integration tests (`#[tokio::test]` + `reqwest`).
* Observability: `tracing` spans, metrics, `tower-http` for logs.

> Congrats! We’ve wrapped up the CRUD project. From here, you have the practical foundation to design idiomatic APIs in Rust.

---

## Appendix A — `README.md` snippet

````markdown
# Axum CRUD — Final Project (Rust for JS Devs)

Backend: **Axum 0.7 + SQLite (SQLx)**.

## Run
```bash
mkdir -p data
export DATABASE_URL="sqlite://data/axum.db?mode=rwc"
RUST_LOG=info cargo run
# → Server on http://127.0.0.1:3000
````

## Endpoints

* `GET /users` — list
* `POST /users` — create `{ name, email }`
* `GET /users/:id` — fetch by id
* `PUT /users/:id` — partial update `{ name?, email? }`
* `DELETE /users/:id` — remove

````

## Appendix B — CORS tip (optional)

```toml
# Cargo.toml
tower-http = { version = "0.5", features = ["cors"] }
````

```rust
// in main.rs, before serve()
use tower_http::cors::CorsLayer;
let app = routes::app(state).layer(CorsLayer::permissive());
```

## Appendix C — Axum 0.6 → 0.7 migration (summary)

* **Before (0.6):** `axum::Server::bind(addr).serve(app.into_make_service())`.
* **Now (0.7):** `let listener = TcpListener::bind(addr).await?; axum::serve(listener, app).await?;`.
* Handlers still implement `IntoResponse`/`Result<T, E>`; routing remains with `get/post/put/delete`.


> Next: **Object Oriented Programming (OOP) Without Classes in Rust**


# Chapter 14 — OOP Without Classes in Rust

Many developers coming from JavaScript or other object-oriented languages expect classes, inheritance, and polymorphism. Rust takes a different path. It **does not have classes**, but still offers powerful tools for structuring and organizing code using **structs**, **traits**, and **composition**.

---

## Structs + `impl` = Like `type` + methods

Rust separates data and behavior clearly:

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

In TypeScript:

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

🔸 In Rust, behavior (`greet`) is defined in an `impl` block — not embedded directly.

---

## No Inheritance, Only Composition

Rust does **not support inheritance**. Instead, it encourages **composition** — building complex behavior by combining simpler pieces.

```rust
struct Engine;
struct Wheels;

struct Car {
    engine: Engine,
    wheels: Wheels,
}
```

No `Car extends Vehicle`. Instead, you build with reusable pieces.

---

## Polymorphism with Traits

Rust uses **traits** to express behavior across types — similar to `interface` in TypeScript or Java.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;
struct Square;

impl Drawable for Circle {
    fn draw(&self) {
        println!("Drawing a circle");
    }
}

impl Drawable for Square {
    fn draw(&self) {
        println!("Drawing a square");
    }
}

fn render(shape: &dyn Drawable) {
    shape.draw();
}
```

In TypeScript:

```ts
interface Drawable {
  draw(): void;
}

class Circle implements Drawable {
  draw() {
    console.log("Drawing a circle");
  }
}
```

**Polymorphism** is possible — but through *interfaces + dynamic dispatch*.


## 🔄 Side-by-side Comparison

| Concept           | TypeScript        | Rust                      |
| ----------------- | ----------------- | ------------------------- |
| Class             | Yes               | Not supported             |
| Interface         | Yes               | Traits                    |
| Inheritance       | With `extends`    | Use composition instead   |
| Method definition | Inside class/type | Inside `impl` block       |
| Polymorphism      | via interfaces    | via traits                |
| Dynamic dispatch  | Optional          | with `dyn Trait`          |


## Key Takeaways

* Rust **does not have classes**, inheritance, or `this`
* Use **structs for data**, `impl` for methods, and **traits for behavior**
* Composition is preferred over inheritance
* Traits + generics enable safe and powerful polymorphism

Rust’s model is simpler, safer, and more explicit — giving you control without surprises.

> Coming from JavaScript or OOP? Rust’s model might feel different — but once you get used to it, it’s incredibly powerful.

> Next: **Advanced Topics in Rust**

# Chapter 15 — Advanced Topics in Rust

This chapter introduces powerful Rust features for developers ready to go beyond the basics. If you’ve followed along so far, you now understand ownership, borrowing, lifetimes, pattern matching, and error handling.

Now we explore deeper abstractions that power real-world Rust development.


## Traits: `Fn`, `FnMut`, and `FnOnce`

Closures in Rust can capture variables in different ways:

| Trait    | Capture type    | Use case                  |
| -------- | --------------- | ------------------------- |
| `Fn`     | by reference    | Read-only closures        |
| `FnMut`  | by mutable ref  | Modify captured variables |
| `FnOnce` | by value (move) | Consume captured values   |

Example:

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

    // A closure that mutably captures and modifies `count`
    let mut increment = || {
        count += 1;
        println!("Count is now: {}", count);
    };

    call_twice(increment);
    println!("Final count: {}", count);
}
```

This closure captures the variable `count` by mutable reference and implements `FnMut`.


### Rust `FnMut` Closures vs JavaScript Generators

Rust's mutable closures can preserve state and act similarly to JavaScript generators:

| Concept             | Rust (`FnMut`)                    | JavaScript (`function*` generator) |
| ------------------- | --------------------------------- | ---------------------------------- |
| State between calls | via captured vars                 | via internal scope + `yield`     |
| Call interface      | Manual (`f()`, `f()`)             | Iterator (`gen.next()`)            |
| Lazy evaluation     | (eager unless wrapped manually)   | (yield-based, lazy by default)   |
| Return values       | Optional / explicit               | Sequence via `yield`               |
| Ownership & safety  | Compile-time guarantees           | Runtime only                       |

Note: Rust closures are **not lazy iterators**, but when used with `FnMut`, they **carry state and mutate it across calls**, like simplified state machines.

We'll explore lazy evaluation and iterators in future examples with `Iterator`, `map`, and custom generators.

Closures in Rust can capture variables in different ways:

| Trait    | Capture type    | Use case                  |
| -------- | --------------- | ------------------------- |
| `Fn`     | by reference    | Read-only closures        |
| `FnMut`  | by mutable ref  | Modify captured variables |
| `FnOnce` | by value (move) | Consume captured values   |

Example:

```rust
fn call_twice<F>(mut f: F)
where
    F: FnMut(),
{
    f();
    f();
}
```

Closures automatically implement one or more of these traits depending on what they capture. You’ll often use them as trait bounds when accepting closures as arguments.


## Smart Pointers: `Box`, `Rc`, and `RefCell`

Rust offers special types to manage heap allocation and dynamic behavior:

* `Box<T>`: Allocate data on the heap
* `Rc<T>`: Reference counting for shared ownership
* `RefCell<T>`: Enables interior mutability (checked at runtime)

These unlock more complex data structures like trees and graphs.


## Pattern Matching Tips

Advanced matching includes:

```rust
match some_value {
    Some(x) if x > 5 => println!("Large value: {}", x),
    Some(_) => println!("Small value"),
    None => println!("No value"),
}
```

You can use `@`, `..`, and nested patterns to match deeply structured data.


## `impl Trait` in Return Types

To return something that implements a trait without specifying the exact type:

```rust
fn get_greeter() -> impl Fn(String) -> String {
    |name| format!("Hello, {}!", name)
}
```


## Modules, Visibility, and Organization

Use `mod`, `pub`, and `use` to organize code:

```rust
mod math {
    pub fn add(x: i32, y: i32) -> i32 {
        x + y
    }
}

fn main() {
    println!("{}", math::add(2, 3));
}
```

## Takeaways

* Traits like `FnMut` and `FnOnce` allow more flexible closures
* Smart pointers enable complex memory-safe structures
* Pattern matching is expressive and powerful
* Modules help organize larger codebases

With these advanced topics, you now have the tools to design idiomatic Rust APIs and systems with **clarity**, **safety**, and **performance**.

# Conclusion

This book wasn’t about memorizing Rust. The central idea was to **translate the mental models you already use in JS/TS** into Rust’s type system and compile‑time guarantees—through small, testable steps. The bridge is built; now it’s practice until writing Rust feels natural.

## What we covered

**Early chapters: values, types, and control flow**
We started from JS intuition and arrived at **ownership** and **borrowing**, seeing why moves are explicit and copies are intentional. We replaced chains of `if/else` with **exhaustive `match`**.

**Functions, closures, and collections**
We covered functions with explicit types, closures, and how to iterate over **vectors**, **tuples**, and **maps**. Traditional loops (`for`, `while`) sit alongside the functional style of iterators.

**Types and data modeling**
With **structs** and **enums**, JS objects and unions became **precise models of valid states**. The compiler enforces exhaustiveness and consistency.

**Generics, traits, and modules**
Instead of “anything,” we use **type parameters** with zero runtime cost. **Traits** replace ad‑hoc duck typing with **explicit capabilities**, and **modules/crates** organize code with clear visibility and dependencies.

**Ownership, borrowing, and lifetimes**
The foundation of memory safety: exclusive vs shared borrows, and when to annotate **lifetimes** for references in returns and structs.

**Errors with `Option` and `Result`**
We moved from `try/catch` to **`Result<T, E>`** with propagation via `?`. Errors become part of a function’s **contract**, not a side effect.

**Iterators with lazy loading**
We composed `map`/`filter`/`take` and only materialized results with `collect`, `sum`, or `for`. No unnecessary intermediate allocations.

**Practical project: Axum + SQLx**
We rewrote an Express CRUD in Axum with **static typing**, async **sqlx**, and explicit error handling.

**Bonus: OOP without classes**
No inheritance. We used **composition**, `impl` for methods, and **traits** for polymorphism (static with generics or dynamic with `dyn`).

**Advanced Topics in Rust**
We explored closures classified by `Fn`/`FnMut`/`FnOnce`, smart pointers like `Box`/`Rc`/`RefCell`, expressive pattern matching, `impl Trait` in return position, and module organization for larger codebases.

## What should stick

* **Model your domain with types**: enums for states, structs for data, traits for behavior.
* **Let the compiler work for you**: if it compiles, a whole class of bugs is already gone.
* **Prefer iterators and `match`** over imperative loops with boolean flags.
* **Errors are first‑class**: design error types and propagate early with `?`.

## Next steps

* Add **pagination, validation, authentication, and observability** to the CRUD service.
* Swap **SQLite for Postgres**, introduce **migrations**, and write **integration tests**.
* Try a service with **streams** or **scheduled tasks** to deepen async practice.
* Go deeper on **lifetimes**, explore **macros** when it makes sense.

## An honest note

Rust isn’t a silver bullet. You trade some flexibility for **clarity and guarantees**. The payoff is reliable code under load and a compiler that scales with your team.

Use the JS ↔ Rust comparisons as a **bridge**, not a crutch. As you advance, lean on Rust’s native concepts—ownership, traits, enums, pattern matching—without mental translation. Once that clicks, you’ll think and program **natively in Rust**.

*Happy shipping.*


# Appendix — Ad‑hoc Duck Typing, Structural TypeScript, and Method Receivers in Rust (Unified)

This appendix brings together two cross‑cutting topics from the book:

1. **Ad‑hoc duck typing** (JavaScript), **structural & static contracts** (TypeScript), and **nominal & explicit contracts** (Rust via traits)
2. **Method receivers**: `&self`, `&mut self`, `self` (Rust) compared with `this` (JS/TS) and `self`/`typing.Self` (Python)

No YAML delimiters and no horizontal rules.

## Part 1 — Ad‑hoc Duck Typing, Structural TS, and Rust with Traits

### 1) Ad‑hoc duck typing (JS)

**Definition.** “If it looks like a duck and quacks like a duck, use it as a duck.” In JS, you use a value based on the behavior it appears to expose, without a declared type. The “contract” is implicit and only fails at runtime.

Example:

```js
function render(shape) {
  // implicit contract: shape must have draw()
  shape.draw(); // if not, runtime error
}

// optional manual check
function renderSafe(shape) {
  if (!shape || typeof shape.draw !== "function") {
    throw new Error("shape must implement draw()");
  }
  shape.draw();
}
```

Pros: flexible and quick to write. Cost: no guarantees; violations surface in production or tests.

### 2) TypeScript: structural and static contracts

**Structural:** compatibility is determined by shape (members and signatures), not by the type’s name. **Static:** the TS checker verifies at compile time.

```ts
interface Drawable { draw(): void }

function render(s: Drawable) {
  s.draw(); // guaranteed by the checker
}

// any object with the same shape is compatible
const circle = { draw() { console.log("circle") }, r: 10 };
render(circle); // OK, structurally compatible
```

Notes:

* You don’t need `implements Drawable`; having the shape is enough.
* TS reports errors early. With object literals, “excess property” checks are stricter.
* Types with `private`/`protected` members behave more nominally.

### 3) Rust: nominal and explicit contracts (traits)

Rust doesn’t use duck typing. It uses **traits** to express capabilities. Compatibility is **nominal** (you explicitly write `impl Trait for Type`) and checking is **static**.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;

impl Drawable for Circle {
    fn draw(&self) { println!("circle"); }
}

// static dispatch (generics)
fn render<T: Drawable>(x: &T) { x.draw(); }

// dynamic dispatch (trait objects)
fn render_dyn(x: &dyn Drawable) { x.draw(); }
```

Why “nominal”? Only types for which you declare `impl Drawable for Type` are accepted as `Drawable`. Merely having the same shape is not enough.

### 4) Dynamic vs static in Rust: `&dyn Trait` and generics

* **Generics (`T: Trait`)**: static dispatch (monomorphization). Excellent performance.
* **Trait objects (`&dyn Trait` / `Box<dyn Trait>`)**: dynamic dispatch via a vtable. Useful for heterogeneity.

Both keep explicit contracts via traits; they differ only in **how** the call is resolved.

### 5) Side‑by‑side

| Topic             | JavaScript          | TypeScript (structural, static) | Rust (nominal, explicit)            |
| ----------------- | ------------------- | ------------------------------- | ----------------------------------- |
| Contract          | Implicit, by usage  | By shape                        | By declaration (`impl Trait for T`) |
| When it’s checked | Runtime             | Compile time                    | Compile time                        |
| Typical failures  | Late runtime errors | Early errors, literal nuances   | Early errors, explicit contract     |
| Polymorphism      | Ad‑hoc              | Structural                      | Traits (generics or `dyn`)          |

### 6) Complete examples

**JS ad‑hoc**

```js
function area(shape) { return shape.area(); }
area({ side: 2 }); // TypeError: shape.area is not a function
```

**TS structural**

```ts
interface HasArea { area(): number }
function area(s: HasArea) { return s.area() }
const square = { side: 2, area() { return this.side * this.side } };
area(square); // ok
const bad = { side: 2 };
area(bad); // error: 'area' is missing
```

**Rust with traits**

```rust
trait HasArea { fn area(&self) -> f64; }
struct Square { side: f64 }
impl HasArea for Square { fn area(&self) -> f64 { self.side * self.side } }
fn area<T: HasArea>(s: &T) -> f64 { s.area() }
let sq = Square { side: 2.0 };
println!("{}", area(&sq));
```

### 7) Practical migration

1. Name the behavior as a trait.
2. Define the minimum contract (essential methods).
3. Implement `impl Trait for Type` for each concrete type.
4. Prefer generics for performance; use `&dyn Trait` for heterogeneity.
5. Expose the trait; hide details inside modules.

### 8) FAQ

**“Structural and static” in TypeScript?**
Structural: compatible if it has the shape. Static: the checker validates at compile time.

**Why doesn’t Rust use structural typing?**
To keep coherence and clear authorship: the type’s author opts in by writing `impl`. This avoids accidental collisions.

**When should I use `&dyn Trait`?**
Heterogeneous collections, runtime‑polymorphic APIs, or to reduce code bloat from monomorphization.

## Part 2 — Receivers in Rust vs `this` (JS/TS) vs `self` (Python)

### Overview

| Language | Receiver      | Meaning                         | Passing                                       | Who decides      |
| -------- | ------------- | ------------------------------- | --------------------------------------------- | ---------------- |
| Rust     | `&self`       | Immutable borrow                | Shared reference                              | Method signature |
|          | `&mut self`   | Exclusive mutable borrow        | Exclusive reference                           | Method signature |
|          | `self`        | Move/consume the value          | By value (ownership)                          | Method signature |
| JS/TS    | `this`        | Dynamic pointer to the receiver | Depends on call site (`obj.m()`, `call/bind`) | The call site    |
| Python   | `self`        | First method parameter          | Passed explicitly by the runtime              | Method author    |
| Python   | `typing.Self` | “This type” for annotations     | Static only                                   | Signature author |

### Quick examples

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
let n = c.into_inner();      // moves c; cannot use c afterwards
```

**JavaScript/TypeScript**

```ts
class Counter { n = 0; peek() { return this.n } bump() { this.n += 1 } }
const c = new Counter();
const f = c.bump;
f();        // error in strict mode (this === undefined)
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

### Practical tips (JS → Rust)

* Read‑only method → `&self`.
* Mutating method → `&mut self`.
* Consuming/ownership‑transferring method → `self`.
* There is no `bind` in Rust: the **signature** fixes the receiver.

### `dyn Trait` vs generics and object safety

* **Generics:** `fn render<T: Drawable>(x: &T)` → static dispatch (monomorphization).
* **Trait object:** `fn render(x: &dyn Drawable)` → dynamic dispatch (vtable).
* **Object safety:** methods taking `self` by value are not callable via `dyn Trait`. Alternatives: `self: Box<Self>` or restrict with `Self: Sized` and use generics where consumption is needed.

### Common pitfalls when porting from JS/TS

* Extracting a method and losing the receiver: `const f = obj.m; f();` breaks `this` in JS; Rust has no dynamic rebind.
* Trying to mutate via `&self`: only `&mut self` allows mutation, and it requires exclusive borrowing.
* Forgetting that `self` moves: after consuming `self`, the value cannot be used.

### Pocket mental map

* `&self` → read‑only method.
* `&mut self` → write/update with exclusivity.
* `self` → consume/transfer ownership.
* Traits define **explicit contracts**; there is no dynamic `this`.



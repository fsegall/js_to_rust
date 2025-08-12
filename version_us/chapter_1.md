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

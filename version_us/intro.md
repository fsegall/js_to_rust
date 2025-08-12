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

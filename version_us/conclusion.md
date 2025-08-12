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

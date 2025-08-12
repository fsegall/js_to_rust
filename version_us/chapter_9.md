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

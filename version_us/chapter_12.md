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

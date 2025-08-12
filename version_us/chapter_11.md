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

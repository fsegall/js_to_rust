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

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
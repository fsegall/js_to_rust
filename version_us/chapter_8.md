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

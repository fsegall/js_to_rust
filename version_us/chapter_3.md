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

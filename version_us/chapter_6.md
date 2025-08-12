# Chapter 6 — Collections and Loops

Rust offers several collection types—from **fixed-size arrays** to **growable vectors** and **tuples**. Iterating over these collections is also powerful, with `for`, `while`, and functional-style iterators.

If you already work with arrays and objects in JavaScript, some syntax will feel familiar—only here you get **strong typing** and **ownership rules**.

## 6.1 Arrays and vectors

### Fixed-size array

```rust
let numbers: [i32; 3] = [1, 2, 3];
println!("First: {}", numbers[0]);
```

### Growable vector (`Vec`)

```rust
let mut scores = vec![90, 85, 72];
scores.push(100);
println!("Last: {}", scores[scores.len() - 1]);
```

In JavaScript:

```js
const scores = [90, 85, 72];
scores.push(100);
console.log(scores[scores.length - 1]);
```

## 6.2 Tuples

Tuples group values of **different types** into a single ordered structure.

```rust
let user: (&str, u32) = ("Felipe", 34);
println!("Name: {}, Age: {}", user.0, user.1);
```

In JavaScript (simulated with an array):

```js
const user = ["Felipe", 34];
console.log(`Name: ${user[0]}, Age: ${user[1]}`);
```

## 6.3 Loops

### `for`

```rust
for score in &scores {
    println!("Score: {}", score);
}
```

In JavaScript:

```js
for (const score of scores) {
    console.log(`Score: ${score}`);
}
```

### `while`

```rust
let mut count = 0;
while count < 5 {
    println!("{}", count);
    count += 1;
}
```

## 6.4 Functional iterators

```rust
let doubled: Vec<i32> = scores.iter().map(|x| x * 2).collect();
println!("{:?}", doubled);
```

In JavaScript:

```js
const doubled = scores.map(x => x * 2);
console.log(doubled);
```

## 6.5 Summary table

| Concept    | JavaScript            | Rust                         |
| ---------- | --------------------- | ---------------------------- |
| Array      | `[1, 2, 3]`           | `[i32; 3]` or `Vec<i32>`     |
| Tuple      | `['a', 1]`            | `(&str, i32)`                |
| Loop       | `for/of`, `while`     | `for`, `while`, `loop`       |
| Map/filter | `.map()`, `.filter()` | `.iter().map()`, `.filter()` |

> Next: **Primitive Types and Objects: JavaScript vs Rust** (Chapter 7).

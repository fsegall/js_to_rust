# Chapter 14 — OOP Without Classes in Rust

Many developers coming from JavaScript or other object-oriented languages expect classes, inheritance, and polymorphism. Rust takes a different path. It **does not have classes**, but still offers powerful tools for structuring and organizing code using **structs**, **traits**, and **composition**.

---

## Structs + `impl` = Like `type` + methods

Rust separates data and behavior clearly:

```rust
struct User {
    name: String,
}

impl User {
    fn greet(&self) {
        println!("Hello, {}!", self.name);
    }
}

let user = User { name: String::from("Laura") };
user.greet();
```

In TypeScript:

```ts
type User = {
  name: string;
  greet: () => void;
};

const user: User = {
  name: "Laura",
  greet() {
    console.log(`Hello, ${this.name}`);
  }
};
```

🔸 In Rust, behavior (`greet`) is defined in an `impl` block — not embedded directly.

---

## No Inheritance, Only Composition

Rust does **not support inheritance**. Instead, it encourages **composition** — building complex behavior by combining simpler pieces.

```rust
struct Engine;
struct Wheels;

struct Car {
    engine: Engine,
    wheels: Wheels,
}
```

No `Car extends Vehicle`. Instead, you build with reusable pieces.

---

## Polymorphism with Traits

Rust uses **traits** to express behavior across types — similar to `interface` in TypeScript or Java.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;
struct Square;

impl Drawable for Circle {
    fn draw(&self) {
        println!("Drawing a circle");
    }
}

impl Drawable for Square {
    fn draw(&self) {
        println!("Drawing a square");
    }
}

fn render(shape: &dyn Drawable) {
    shape.draw();
}
```

In TypeScript:

```ts
interface Drawable {
  draw(): void;
}

class Circle implements Drawable {
  draw() {
    console.log("Drawing a circle");
  }
}
```

**Polymorphism** is possible — but through *interfaces + dynamic dispatch*.


## 🔄 Side-by-side Comparison

| Concept           | TypeScript        | Rust                      |
| ----------------- | ----------------- | ------------------------- |
| Class             | Yes               | Not supported             |
| Interface         | Yes               | Traits                    |
| Inheritance       | With `extends`    | Use composition instead   |
| Method definition | Inside class/type | Inside `impl` block       |
| Polymorphism      | via interfaces    | via traits                |
| Dynamic dispatch  | Optional          | with `dyn Trait`          |


## Key Takeaways

* Rust **does not have classes**, inheritance, or `this`
* Use **structs for data**, `impl` for methods, and **traits for behavior**
* Composition is preferred over inheritance
* Traits + generics enable safe and powerful polymorphism

Rust’s model is simpler, safer, and more explicit — giving you control without surprises.

> Coming from JavaScript or OOP? Rust’s model might feel different — but once you get used to it, it’s incredibly powerful.

> Next: **Advanced Topics in Rust**
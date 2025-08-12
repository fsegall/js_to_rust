# Appendix — Ad‑hoc Duck Typing, Structural TypeScript, and Method Receivers in Rust (Unified)

This appendix brings together two cross‑cutting topics from the book:

1. **Ad‑hoc duck typing** (JavaScript), **structural & static contracts** (TypeScript), and **nominal & explicit contracts** (Rust via traits)
2. **Method receivers**: `&self`, `&mut self`, `self` (Rust) compared with `this` (JS/TS) and `self`/`typing.Self` (Python)

No YAML delimiters and no horizontal rules.

## Part 1 — Ad‑hoc Duck Typing, Structural TS, and Rust with Traits

### 1) Ad‑hoc duck typing (JS)

**Definition.** “If it looks like a duck and quacks like a duck, use it as a duck.” In JS, you use a value based on the behavior it appears to expose, without a declared type. The “contract” is implicit and only fails at runtime.

Example:

```js
function render(shape) {
  // implicit contract: shape must have draw()
  shape.draw(); // if not, runtime error
}

// optional manual check
function renderSafe(shape) {
  if (!shape || typeof shape.draw !== "function") {
    throw new Error("shape must implement draw()");
  }
  shape.draw();
}
```

Pros: flexible and quick to write. Cost: no guarantees; violations surface in production or tests.

### 2) TypeScript: structural and static contracts

**Structural:** compatibility is determined by shape (members and signatures), not by the type’s name. **Static:** the TS checker verifies at compile time.

```ts
interface Drawable { draw(): void }

function render(s: Drawable) {
  s.draw(); // guaranteed by the checker
}

// any object with the same shape is compatible
const circle = { draw() { console.log("circle") }, r: 10 };
render(circle); // OK, structurally compatible
```

Notes:

* You don’t need `implements Drawable`; having the shape is enough.
* TS reports errors early. With object literals, “excess property” checks are stricter.
* Types with `private`/`protected` members behave more nominally.

### 3) Rust: nominal and explicit contracts (traits)

Rust doesn’t use duck typing. It uses **traits** to express capabilities. Compatibility is **nominal** (you explicitly write `impl Trait for Type`) and checking is **static**.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;

impl Drawable for Circle {
    fn draw(&self) { println!("circle"); }
}

// static dispatch (generics)
fn render<T: Drawable>(x: &T) { x.draw(); }

// dynamic dispatch (trait objects)
fn render_dyn(x: &dyn Drawable) { x.draw(); }
```

Why “nominal”? Only types for which you declare `impl Drawable for Type` are accepted as `Drawable`. Merely having the same shape is not enough.

### 4) Dynamic vs static in Rust: `&dyn Trait` and generics

* **Generics (`T: Trait`)**: static dispatch (monomorphization). Excellent performance.
* **Trait objects (`&dyn Trait` / `Box<dyn Trait>`)**: dynamic dispatch via a vtable. Useful for heterogeneity.

Both keep explicit contracts via traits; they differ only in **how** the call is resolved.

### 5) Side‑by‑side

| Topic             | JavaScript          | TypeScript (structural, static) | Rust (nominal, explicit)            |
| ----------------- | ------------------- | ------------------------------- | ----------------------------------- |
| Contract          | Implicit, by usage  | By shape                        | By declaration (`impl Trait for T`) |
| When it’s checked | Runtime             | Compile time                    | Compile time                        |
| Typical failures  | Late runtime errors | Early errors, literal nuances   | Early errors, explicit contract     |
| Polymorphism      | Ad‑hoc              | Structural                      | Traits (generics or `dyn`)          |

### 6) Complete examples

**JS ad‑hoc**

```js
function area(shape) { return shape.area(); }
area({ side: 2 }); // TypeError: shape.area is not a function
```

**TS structural**

```ts
interface HasArea { area(): number }
function area(s: HasArea) { return s.area() }
const square = { side: 2, area() { return this.side * this.side } };
area(square); // ok
const bad = { side: 2 };
area(bad); // error: 'area' is missing
```

**Rust with traits**

```rust
trait HasArea { fn area(&self) -> f64; }
struct Square { side: f64 }
impl HasArea for Square { fn area(&self) -> f64 { self.side * self.side } }
fn area<T: HasArea>(s: &T) -> f64 { s.area() }
let sq = Square { side: 2.0 };
println!("{}", area(&sq));
```

### 7) Practical migration

1. Name the behavior as a trait.
2. Define the minimum contract (essential methods).
3. Implement `impl Trait for Type` for each concrete type.
4. Prefer generics for performance; use `&dyn Trait` for heterogeneity.
5. Expose the trait; hide details inside modules.

### 8) FAQ

**“Structural and static” in TypeScript?**
Structural: compatible if it has the shape. Static: the checker validates at compile time.

**Why doesn’t Rust use structural typing?**
To keep coherence and clear authorship: the type’s author opts in by writing `impl`. This avoids accidental collisions.

**When should I use `&dyn Trait`?**
Heterogeneous collections, runtime‑polymorphic APIs, or to reduce code bloat from monomorphization.

## Part 2 — Receivers in Rust vs `this` (JS/TS) vs `self` (Python)

### Overview

| Language | Receiver      | Meaning                         | Passing                                       | Who decides      |
| -------- | ------------- | ------------------------------- | --------------------------------------------- | ---------------- |
| Rust     | `&self`       | Immutable borrow                | Shared reference                              | Method signature |
|          | `&mut self`   | Exclusive mutable borrow        | Exclusive reference                           | Method signature |
|          | `self`        | Move/consume the value          | By value (ownership)                          | Method signature |
| JS/TS    | `this`        | Dynamic pointer to the receiver | Depends on call site (`obj.m()`, `call/bind`) | The call site    |
| Python   | `self`        | First method parameter          | Passed explicitly by the runtime              | Method author    |
| Python   | `typing.Self` | “This type” for annotations     | Static only                                   | Signature author |

### Quick examples

**Rust**

```rust
struct Counter { n: i32 }
impl Counter {
    fn peek(&self) -> i32 { self.n }
    fn bump(&mut self) { self.n += 1; }
    fn into_inner(self) -> i32 { self.n }
}
let mut c = Counter { n: 0 };
let _ = c.peek();            // Counter::peek(&c)
c.bump();                    // Counter::bump(&mut c)
let n = c.into_inner();      // moves c; cannot use c afterwards
```

**JavaScript/TypeScript**

```ts
class Counter { n = 0; peek() { return this.n } bump() { this.n += 1 } }
const c = new Counter();
const f = c.bump;
f();        // error in strict mode (this === undefined)
f.call(c);  // ok (rebind)
const g = c.bump.bind(c); g(); // ok
```

**Python**

```py
class Counter:
    def __init__(self): self.n = 0
    def peek(self): return self.n
    def bump(self): self.n += 1
c = Counter(); c.peek(); c.bump()
```

### Practical tips (JS → Rust)

* Read‑only method → `&self`.
* Mutating method → `&mut self`.
* Consuming/ownership‑transferring method → `self`.
* There is no `bind` in Rust: the **signature** fixes the receiver.

### `dyn Trait` vs generics and object safety

* **Generics:** `fn render<T: Drawable>(x: &T)` → static dispatch (monomorphization).
* **Trait object:** `fn render(x: &dyn Drawable)` → dynamic dispatch (vtable).
* **Object safety:** methods taking `self` by value are not callable via `dyn Trait`. Alternatives: `self: Box<Self>` or restrict with `Self: Sized` and use generics where consumption is needed.

### Common pitfalls when porting from JS/TS

* Extracting a method and losing the receiver: `const f = obj.m; f();` breaks `this` in JS; Rust has no dynamic rebind.
* Trying to mutate via `&self`: only `&mut self` allows mutation, and it requires exclusive borrowing.
* Forgetting that `self` moves: after consuming `self`, the value cannot be used.

### Pocket mental map

* `&self` → read‑only method.
* `&mut self` → write/update with exclusivity.
* `self` → consume/transfer ownership.
* Traits define **explicit contracts**; there is no dynamic `this`.

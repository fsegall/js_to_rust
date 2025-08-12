# Capítulo 14 — POO sem classes em Rust

Muitos desenvolvedores vindos de JavaScript ou outras linguagens orientadas a objetos esperam **classes**, **herança** e **polimorfismo**. Rust segue outro caminho: **não tem classes**, mas oferece ferramentas poderosas para estruturar código com **structs**, **traits** e **composição**.

## 14.1 Structs + `impl` = "tipo" + métodos

Rust separa dados de comportamento de forma explícita.

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

Em TypeScript (análogo usando `type` + função):

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

Observação: em Rust, os métodos vivem em blocos `impl`, não dentro da definição do tipo.

## 14.2 Sem herança; com composição

Rust **não** possui herança. Em vez disso, incentiva **composição** — juntar peças simples para formar comportamentos mais complexos.

```rust
struct Engine;
struct Wheels;

struct Car {
    engine: Engine,
    wheels: Wheels,
}
```

Nada de `Car extends Vehicle`. Você modela agregando componentes e extraindo comportamentos para traits.

## 14.3 Polimorfismo com traits

Traits expressam comportamentos que vários tipos podem implementar — parecidos com `interface` em TypeScript.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;
struct Square;

impl Drawable for Circle {
    fn draw(&self) { println!("Drawing a circle"); }
}

impl Drawable for Square {
    fn draw(&self) { println!("Drawing a square"); }
}

fn render(shape: &dyn Drawable) {
    shape.draw();
}
```

Em TypeScript:

```ts
interface Drawable { draw(): void }

class Circle implements Drawable {
  draw() { console.log("Drawing a circle") }
}
```

Notas úteis

* Você também pode usar **polimorfismo estático** com generics: `fn render<T: Drawable>(shape: &T) { shape.draw(); }` (sem custo de despacho dinâmico).
* `&dyn Trait` usa **despacho dinâmico** (tabela virtual) e é útil quando você precisa de heterogeneidade em tempo de execução.

## 14.4 Lado a lado

| Conceito          | TypeScript            | Rust                     |
| ----------------- | --------------------- | ------------------------ |
| Classe            | Sim                   | Não                      |
| Interface         | Sim                   | Sim (traits)             |
| Herança           | `extends`             | Não (prefira composição) |
| Métodos           | Dentro da classe/tipo | Em blocos `impl`         |
| Polimorfismo      | Via interfaces        | Via traits               |
| Despacho dinâmico | Opcional              | `dyn Trait`              |

## 14.5 Para levar

* Rust **não tem classes**, herança nem `this` implícito.
* Use **structs** para dados, `impl` para métodos e **traits** para comportamento.
* Prefira **composição** a herança.
* Traits + generics oferecem polimorfismo seguro e expressivo.

O modelo de Rust é mais simples e explícito, com menos surpresas — e muito poder quando você internaliza a combinação de structs, traits e composição.

> Próximo: **Tópicos Avançados em Rust**.

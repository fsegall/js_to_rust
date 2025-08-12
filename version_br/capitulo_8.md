# Capítulo 8 — Structs, Enums e Modelagem de Dados

`structs` e `enums` são duas das ferramentas mais poderosas de Rust para organizar e modelar dados — e costumam ser mais expressivas e estritas do que objetos e *unions* em JavaScript.

Este capítulo mostra como definir e usar esses blocos de construção, como eles se relacionam com objetos em JavaScript e como o **pattern matching** amarra tudo com segurança e clareza.

## 8.1 Structs (como objetos em JS)

**Nota:** Alguns conceitos citados — como **borrowing** (referências emprestadas), **ownership** (posse) e **lifetimes** — aparecem aqui por contexto e serão aprofundados nos próximos capítulos.

### Definições rápidas

* **Ownership**: forma de Rust gerenciar memória rastreando quem **possui** um valor.
* **Borrowing**: acessar dados temporariamente sem tomar posse (`&T` ou `&mut T`).
* **Lifetimes**: anotações que dizem ao compilador **por quanto tempo** referências são válidas.

### Nota sobre `&str` vs `String`

Rust tem dois tipos principais para texto:

* `&str` é uma **fatia imutável** de string, frequentemente usada como referência emprestada.
* `String` é uma string **alocada no heap e redimensionável**, que **detém** seus dados.

Em argumentos de função e campos de `struct`, use `String` quando precisar de **posse**; use `&str` quando **emprestar** for suficiente.

Exemplo:

```rust
struct User {
    name: String, // possui o valor do nome
    age: u32,
}
```

Isso significa que a `struct` é **dona** dos dados. Se você usasse `&str`, precisaria gerenciar **lifetimes** explicitamente.

---

Structs definem **tipos próprios**:

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

Em JavaScript:

```js
const user = {
  name: "Laura",
  age: 28
};
console.log(`${user.name} is ${user.age} years old`);
```

## 8.2 Inicialização de struct com `..`

Essa sintaxe lembra o *spread* de JS (`...user`), mas com diferenças importantes.

```rust
let user2 = User {
    name: String::from("Paulo"),
    ..user
};
```

**O que acontece:**

* Copia o campo `age` de `user` para `user2` (porque `u32` é `Copy`).
* Substitui `name` por um novo valor.
* **Move** os campos restantes de `user` para `user2`. Como `name: String` **não** é `Copy`, `user` **não** pode mais ser usado.

```rust
println!("{}", user.age); // ❌ erro de compilação: `user` foi movido
```

Em JavaScript:

```js
const user = { name: "Laura", age: 28 };
const user2 = { ...user, name: "Paulo" };
console.log(user.age); // ✅ ainda funciona
```

✅ Em Rust, as **regras de ownership** tornam o manuseio de dados previsível e menos propenso a erros sutis.

## 8.3 Enums (tagged unions com poder)

`enum` define um tipo que pode ser **uma entre várias variantes**:

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

Em JavaScript (menos seguro):

```js
const status = { type: "Blocked", reason: "Too many attempts" };
if (status.type === "Blocked") {
  console.log(`Blocked: ${status.reason}`);
}
```

## 8.4 Recap de pattern matching

Usar `match` com enums permite lidar com **todas as variantes** de forma segura e **exaustiva**:

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

**Nota sobre `=>` em `match`:** não é *arrow function* de JS. Em Rust, `=>` associa um **padrão** a uma **expressão/bloco**. É parte da sintaxe de *pattern matching* e garante que cada variante seja tratada explicitamente.

```rust
match some_value {
    Pattern => result,
}
```

Pense em `match` como um `switch` **forte e verificado por tipos**, sem *fallthrough* e com exaustividade obrigatória.

## 8.5 Quando usar `struct` vs `enum`

* Use **`struct`** quando quiser **agrupar dados relacionados**.
* Use **`enum`** quando um valor pode ser **uma entre várias variantes** (com ou sem dados associados).

> Próximo: **Ownership, Borrowing e Lifetimes**: como programadores Rust gerenciam memória sem garbage collector.

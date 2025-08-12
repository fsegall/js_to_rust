# Capítulo 4 — Controle de fluxo e condicionais

Neste capítulo vamos comparar **if/else** e **switch** do JavaScript com as construções idiomáticas de Rust: `if` como expressão, `match` com pattern matching, e os laços `loop`/`while`/`for`. A ideia é prática: mostrar o equivalente em Rust para casos que você já resolve no dia a dia.

## 4.1 `if` como expressão

Em Rust, `if` retorna um valor. Isso permite escrever lógica sem variáveis temporárias.

```rust
let score = 87;
let grade = if score >= 90 {
    "A"
} else if score >= 80 {
    "B"
} else {
    "C"
};
println!("grade: {}", grade);
```

Em JS você faria algo semelhante, mas o `if` não é expressão. Geralmente sairia assim:

```js
const score = 87;
let grade;
if (score >= 90) grade = "A";
else if (score >= 80) grade = "B";
else grade = "C";
console.log(`grade: ${grade}`);
```

> Dica: todos os ramos do `if` em Rust devem produzir **o mesmo tipo**.

## 4.2 `match` vs `switch`

`match` é o primo mais seguro e poderoso do `switch`. Ele exige **exaustividade** e suporta **padrões**.

JS:

```js
switch (status) {
  case 200: msg = "ok"; break;
  case 404: msg = "not found"; break;
  default:  msg = "error";
}
```

Rust:

```rust
let status = 503;
let msg = match status {
    200 => "ok",
    404 => "not found",
    500..=599 => "server error", // intervalo
    _ => "error",                // curinga obrigatório para cobrir o resto
};
```

### Padrões, intervalos e guardas

Você pode combinar padrões, usar intervalos e adicionar **guardas** com `if`:

```rust
let x = 42;
let label = match x {
    0 => "zero",
    1 | 2 | 3 => "small",
    4..=10 => "medium",
    n if n % 2 == 0 => "even",
    _ => "odd",
};
```

### Pattern matching com enums

O ganho de segurança aparece bem com `enum`.

```rust
enum Role { Admin, User(String) }

fn describe(r: Role) -> String {
    match r {
        Role::Admin => "admin".into(),
        Role::User(name) => format!("user {}", name),
    }
}
```

No `switch` de JS, você não tem verificação de exaustividade em tempo de compilação.

## 4.3 `if let` e `while let`: açúcar para padrões simples

Quando você só quer testar um padrão e extrair um valor, `if let` simplifica.

```rust
let maybe_id: Option<i64> = Some(10);
if let Some(id) = maybe_id {
    println!("id = {}", id);
} else {
    println!("sem id");
}
```

`while let` itera enquanto o padrão casa.

```rust
let mut stack = vec![1, 2, 3];
while let Some(top) = stack.pop() {
    println!("{}", top);
}
```

## 4.4 Lidando com `Option`/`Result`

`match` funciona muito bem com `Option` e `Result`. Para fluxos comuns, existem atalhos:

```rust
fn parse_port(s: &str) -> Result<u16, std::num::ParseIntError> {
    let n: u16 = s.parse()?; // `?` propaga o erro automaticamente
    Ok(n)
}
```

* `?` retorna cedo em caso de erro (`Result`), poupando um `match` manual.
* Para `Option`, métodos como `.unwrap_or(default)`, `.map(...)` e `.ok_or(err)` evitam `match` verboso.

## 4.5 Laços: `loop`, `while`, `for`

### `loop`, `break`, `continue` e rótulos

```rust
let mut n = 0;
loop {
    n += 1;
    if n == 3 { continue; }
    if n == 5 { break; }
}
```

Rótulos permitem controlar o laço externo:

```rust
'outer: for x in 0..3 {
    for y in 0..3 {
        if y == 1 { continue 'outer; }
    }
}
```

### `while`

```rust
let mut attempts = 0;
while attempts < 3 {
    attempts += 1;
}
```

### `for` com ranges e iteradores

```rust
for i in 0..3 { /* 0,1,2 */ }
for i in 0..=3 { /* 0,1,2,3 */ }

let items = vec!["a", "b", "c"];
for (i, item) in items.iter().enumerate() {
    println!("{} -> {}", i, item);
}
```

> Em Rust, `for` itera **sobre iteradores**. Use `&v` para emprestar, `&mut v` para modificar e `v.into_iter()` para mover valores.

## 4.6 Tabela: `switch` (JS) vs `match` (Rust)

| Recurso                       | `switch` (JS)     | `match` (Rust)                             |
| ----------------------------- | ----------------- | ------------------------------------------ |
| Exaustividade                 | Não exige         | **Exige** (ou `_` para cobrir o resto)     |
| Padrões                       | Iguais/constantes | Valores, intervalos, padrões compostos     |
| Captura de valores            | Manual            | Por padrão com padrões (ex.: `User(name)`) |
| Queda de caso (*fallthrough*) | Padrão é cair     | Não cai; cada braço é isolado              |
| Verificação em compilação     | Limitada          | Forte, com tipos e padrões                 |

## 4.7 Para levar

* `if` é expressão, então você pode atribuir o resultado direto a uma variável.
* `match` substitui `switch` com segurança e poder de composição.
* `if let`/`while let` simplificam padrões comuns com `Option` e outras estruturas.
* Escolha o laço certo: `loop` para “até eu mandar parar”, `while` para condição, `for` para iteradores/ranges.

> Próximo: **Funções e closures em Rust**. Vamos comparar com as arrow functions do JavaScript e ver como aceitar closures em funções genéricas.

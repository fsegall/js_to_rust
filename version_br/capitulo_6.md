# Capítulo 6 — Coleções e Laços

Rust oferece vários tipos de coleção — de **arrays de tamanho fixo** a **vetores dinâmicos** e **tuplas**. Iterar sobre essas coleções também é poderoso, com suporte a `for`, `while` e iteradores em estilo funcional.

Se você já trabalha com arrays e objetos em JavaScript, alguma sintaxe vai soar familiar — mas aqui tudo vem com **tipagem forte** e **regras de ownership**.

## 6.1 Arrays e vetores

### Array de tamanho fixo

```rust
let numbers: [i32; 3] = [1, 2, 3];
println!("First: {}", numbers[0]);
```

### Vetor redimensionável (`Vec`)

```rust
let mut scores = vec![90, 85, 72];
scores.push(100);
println!("Last: {}", scores[scores.len() - 1]);
```

Em JavaScript:

```js
const scores = [90, 85, 72];
scores.push(100);
console.log(scores[scores.length - 1]);
```

## 6.2 Tuplas

Tuplas agrupam valores de **tipos diferentes** em uma única estrutura ordenada.

```rust
let user: (&str, u32) = ("Felipe", 34);
println!("Name: {}, Age: {}", user.0, user.1);
```

Em JavaScript (simulando com array):

```js
const user = ["Felipe", 34];
console.log(`Name: ${user[0]}, Age: ${user[1]}`);
```

## 6.3 Laços

### `for`

```rust
for score in &scores {
    println!("Score: {}", score);
}
```

Em JavaScript:

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

## 6.4 Iteradores funcionais

```rust
let doubled: Vec<i32> = scores.iter().map(|x| x * 2).collect();
println!("{:?}", doubled);
```

Em JavaScript:

```js
const doubled = scores.map(x => x * 2);
console.log(doubled);
```

## 6.5 Tabela‑resumo

| Conceito   | JavaScript            | Rust                         |
| ---------- | --------------------- | ---------------------------- |
| Array      | `[1, 2, 3]`           | `[i32; 3]` ou `Vec<i32>`     |
| Tupla      | `['a', 1]`            | `(&str, i32)`                |
| Laço       | `for/of`, `while`     | `for`, `while`, `loop`       |
| Map/filter | `.map()`, `.filter()` | `.iter().map()`, `.filter()` |

> Próximo: **Tipos primitivos e objetos: JavaScript vs Rust** (Capítulo 7).

# Capítulo 12 — Iteradores e carregamento sob demanda (Lazy Loading)

Iteradores são um dos pilares da expressividade de Rust — permitem encadear, transformar e consumir sequências de dados com **abstrações de custo zero**.

Neste capítulo, vamos ver como Rust lida com iteração, contrastar com `Array.prototype.map` e geradores do JavaScript, e apresentar o conceito de **carregamento sob demanda** por meio do trait `Iterator`.

## 12.1 Iteração em JavaScript vs Rust

### JavaScript

```js
const nums = [1, 2, 3];
const doubled = nums.map(x => x * 2);
console.log(doubled); // [2, 4, 6]
```

* Métodos como `map`, `filter` e `reduce` **avaliam imediatamente** e retornam novos arrays.

### Rust

```rust
let nums = vec![1, 2, 3];
let doubled: Vec<i32> = nums.iter().map(|x| x * 2).collect();
println!("{:?}", doubled); // [2, 4, 6]
```

* `.iter()` cria um **iterador** (sob demanda).
* `.map(...)` define uma transformação — **ainda não executada**.
* `.collect()` força a avaliação e produz o resultado final.

## 12.2 Carregamento sob demanda em Rust

Iteradores em Rust são avaliados **sob demanda**:

* Nada acontece até você chamar `collect()`, usar um `for`, `sum()`, `count()` etc.
* Isso permite composições eficientes **sem alocações intermediárias**.

```rust
let result: i32 = (1..)
    .map(|x| x * x)
    .filter(|x| x % 2 == 0)
    .take(5)
    .sum();

println!("Sum of first 5 even squares: {}", result); // 120
```

Aqui, `(1..)` é um **intervalo infinito**, e `take(5)` limita a sequência.

## 12.3 Iteradores personalizados

Para criar seu próprio iterador, implemente o trait `Iterator`:

```rust
struct Counter { count: u32 }

impl Counter { fn new() -> Self { Counter { count: 0 } } }

impl Iterator for Counter {
    type Item = u32;
    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;
        if self.count <= 5 { Some(self.count) } else { None }
    }
}

for val in Counter::new() {
    println!("{}", val);
}
```

Esse padrão lembra um gerador: produz valores **sob demanda**.

## 12.4 Comparação: geradores JS vs iteradores Rust

| Recurso              | Geradores (JavaScript)       | Iteradores (Rust)                 |
| -------------------- | ---------------------------- | --------------------------------- |
| Sob demanda          | Sim                          | Sim                               |
| Sintaxe              | `function* () { yield ... }` | `impl Iterator for MeuTipo`       |
| Sequências infinitas | Sim, com cuidado             | Sim, com segurança via `take()`   |
| Ergonomia            | Concisa                      | Um pouco mais verbosa, mais poder |
| Desempenho           | Médio                        | Alto (abstração de custo zero)    |
| Segurança de memória | Sem garantias                | Ownership + lifetimes             |

## 12.5 Resumo

* O trait `Iterator` define sequências **componíveis** avaliadas **sob demanda**.
* Métodos como `.map()`, `.filter()`, `.take()` encadeiam transformações e **só avaliam** quando necessário.
* Você pode definir iteradores próprios implementando `next()`.
* Iteradores são **seguros em memória** e altamente otimizados.

> Próximo: **De Express a Axum: construindo um servidor HTTP**.

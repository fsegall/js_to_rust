# Capítulo 10 — Tratamento de erros com `Option` e `Result`

Rust não usa exceções. Em vez disso, codifica a **possibilidade** de falha diretamente no sistema de tipos usando dois `enum`s poderosos: `Option<T>` e `Result<T, E>`.

## 10.1 `Option<T>`

**Nota:** `Some` e `None` não são palavras‑chave; são as duas variantes do `enum` `Option<T>` em Rust:

```rust
enum Option<T> {
    Some(T),
    None,
}
```

Quando você escreve `Some(42)` ou `None`, está usando construtores de `enum` para embrulhar (ou representar a ausência de) valores opcionais.

Representa um valor que pode estar presente ou ausente:

```rust
let some_number = Some(42);
let no_number: Option<i32> = None;
```

Esta é a versão de Rust para `null`/`undefined`, mas **verificada pelo tipo**, o que evita a clássica *null pointer exception* (tentar acessar um valor inexistente em tempo de execução):

```rust
fn maybe_double(x: Option<i32>) -> Option<i32> {
    match x {
        Some(n) => Some(n * 2),
        None => None,
    }
}
```

✅ Use `Option<T>` quando um valor **pode não existir**.

## 10.2 `Result<T, E>`

Representa sucesso (`Ok`) ou falha (`Err`):

```rust
fn safe_divide(x: i32, y: i32) -> Result<i32, String> {
    if y == 0 {
        Err("division by zero".to_string())
    } else {
        Ok(x / y)
    }
}
```

✅ Use `Result<T, E>` quando **algo pode dar errado** e você quer **retornar um erro**.

## 10.3 Tratando resultados

Use *pattern matching* com `match`:

```rust
match safe_divide(10, 2) {
    Ok(result) => println!("Result: {}", result),
    Err(e) => println!("Error: {}", e),
}
```

## 10.4 Atalho: `if let`

```rust
let result = Some(42);
if let Some(x) = result {
    println!("Value is {}", x);
}
```

## 10.5 Cuidado: `unwrap`

```rust
let n = Some(5);
println!("{}", n.unwrap()); // panic se for None
```

Use `unwrap` **apenas** quando tiver certeza de que o valor está presente.

## 10.6 Boas práticas

* Prefira `match` ou `if let` para tratamento seguro.
* Evite `unwrap()` fora de protótipos rápidos ou testes.
* Use `.expect("mensagem")` para documentar por que o unwrap é seguro.

## 10.7 Comparação com JavaScript

| Conceito       | JavaScript              | Rust                       |
| -------------- | ----------------------- | -------------------------- |
| null/undefined | Runtime, não verificado | `Option<T>` (compile‑time) |
| try/catch      | Exceções, dinâmicas     | `Result<T, E>` (`enum`)    |
| throw          | Qualquer tipo           | `Err(E)` tipado            |

> Próximo: **Lifetimes (aprofundamento)** — como Rust rastreia a validade de referências entre funções e escopos.

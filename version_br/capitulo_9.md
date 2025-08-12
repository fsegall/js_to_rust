# Capítulo 9 — Ownership, Borrowing e Lifetimes

A segurança de memória em Rust nasce de uma ideia central: **ownership**. Diferente do modelo de coleta de lixo do JavaScript, Rust garante segurança **em tempo de compilação**, sem custo de tempo de execução, aplicando regras sobre como os valores são movidos, copiados e referenciados.

## 9.1 Ownership (propriedade)

**O que é “double free”?**
Em linguagens como C/C++, ocorre quando o mesmo bloco de memória é liberado duas vezes. Isso pode causar travamentos, corrupção de memória ou vulnerabilidades.

Rust evita *double free* impondo **ownership** em tempo de compilação: um valor é liberado **uma única vez**, quando seu **único dono** sai de escopo. Se um valor é **movido**, a referência original deixa de ser válida, eliminando o risco de liberar a mesma memória duas vezes.

Todo valor em Rust tem **um único dono** — a variável que o mantém.

```rust
let s = String::from("hello");
```

Quando `s` é criado, ele **possui** a string na memória. Se atribuirmos a outra variável:

```rust
let s1 = String::from("hello");
let s2 = s1; // ownership movido!
```

Após o *move*, `s1` **não é mais válido**. Usá-lo gera erro de compilação:

```rust
println!("{}", s1); // ❌ erro de compilação
```

Isso previne *double free* e erros de memória.

✅ Tipos primitivos (inteiros, bool, etc.) normalmente implementam `Copy`, então **não** são movidos:

```rust
let x = 5;
let y = x; // x continua válido
```

## 9.2 Borrowing (empréstimo)

Em vez de mover um valor, você pode **emprestá-lo**:

```rust
fn print_length(s: &String) {
    println!("Length: {}", s.len());
}

let s = String::from("hello");
print_length(&s); // passa por referência
println!("Still valid: {}", s);
```

Emprestar dá acesso ao valor **sem transferir a posse**.

* `&T` = empréstimo compartilhado (somente leitura)
* `&mut T` = empréstimo mutável (leitura e escrita)

🛑 Não é permitido ter **empréstimos compartilhados e mutáveis ao mesmo tempo** para o mesmo valor.

```rust
let mut s = String::from("hi");
let r1 = &s;
let r2 = &s;
let r3 = &mut s; // ❌ erro de compilação
```

## 9.3 Lifetimes (visão geral)

*Lifetimes* descrevem **por quanto tempo** uma referência é válida. Na maioria dos casos, o compilador **infere** automaticamente. Quando múltiplas referências se relacionam, pode ser necessário **anotar**:

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

Exploraremos *lifetimes* em mais detalhes no capítulo dedicado.

## 9.4 Analogia conceitual com JS

| Conceito    | JavaScript                              | Rust                          |
| ----------- | --------------------------------------- | ----------------------------- |
| GC          | Automático                              | Sem GC — ownership verificado |
| Referências | Qualquer quantidade, a qualquer momento | Empréstimos com regras        |
| Mutação     | Sem restrições fortes                   | Exclusiva via `&mut`          |
| Vazamentos  | Possíveis se não houver cuidado         | Prevenidos pelo compilador    |
| Lifetime    | Implícito, decidido em runtime          | Rastreado em compile‑time     |

> Próximo: expressar a **possibilidade de falha** no sistema de tipos — com `Option<T>` e `Result<T, E>`.

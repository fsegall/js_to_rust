# Capítulo 15 — Tópicos avançados em Rust

Este capítulo apresenta recursos poderosos de Rust para quem quer ir além do básico. Se você acompanhou os capítulos anteriores, já entende ownership, borrowing, lifetimes, pattern matching e tratamento de erros.

Agora vamos explorar abstrações mais profundas que aparecem no dia a dia de projetos em Rust.

## 15.1 Traits: `Fn`, `FnMut` e `FnOnce`

Closures em Rust podem capturar variáveis de maneiras diferentes. Dependendo do que capturam e de como usam o ambiente, elas implementam automaticamente um ou mais destes traits:

| Trait    | Forma de captura                | Quando usar                           |
| -------- | ------------------------------- | ------------------------------------- |
| `Fn`     | Empréstimo por referência (`&`) | Leitura apenas                        |
| `FnMut`  | Empréstimo mutável (`&mut`)     | Modificar estado capturado            |
| `FnOnce` | Por valor (move de ownership)   | Consumir valores capturados (uma vez) |

Exemplo:

```rust
fn call_twice<F>(mut f: F)
where
    F: FnMut(),
{
    f();
    f();
}

fn main() {
    let mut count = 0;

    // Captura mutável: implementa FnMut
    let mut increment = || {
        count += 1;
        println!("count = {}", count);
    };

    call_twice(increment);
    println!("final = {}", count);
}
```

Observações:

* `Fn`/`FnMut`/`FnOnce` são **contratos** sobre como a closure interage com o ambiente.
* Você escolhe o bound adequado quando aceita closures em funções genéricas.

### 15.1.1 `FnMut` em Rust vs generators em JavaScript

Closures mutáveis conseguem **preservar estado entre chamadas**, lembrando generators de JS, mas não são a mesma coisa.

| Conceito              | Rust (`FnMut`)                    | JavaScript (`function*` generator) |
| --------------------- | --------------------------------- | ---------------------------------- |
| Estado entre chamadas | Sim, via variáveis capturadas     | Sim, via escopo interno e `yield`  |
| Interface de chamada  | Direta: `f(); f();`               | Iterador: `gen.next()`             |
| Avaliação             | Eager (a menos que você componha) | Lazy por padrão (via `yield`)      |
| Retornos              | Valor de retorno normal           | Sequência de valores com `yield`   |
| Garantias             | Tipos e ownership em compilação   | Verificação apenas em runtime      |

Para iteradores realmente **lazy**, use o trait `Iterator` e adaptadores como `map`, `filter` e `take`.

## 15.2 Smart pointers: `Box`, `Rc` e `RefCell`

Tipos especiais que destravam alocação no heap e padrões mais flexíveis de posse e mutabilidade:

* **`Box<T>`**: coloca um valor no heap. Útil para tipos grandes, recursivos (ex.: árvores) e para **objetos de trait** (`Box<dyn Trait>`).
* **`Rc<T>`**: contagem de referências para **compartilhar ownership** em **thread única**. Clonar um `Rc` incrementa o contador; quando zera, o valor é liberado.
* **`RefCell<T>`**: habilita **mutabilidade interior** com checagem **em tempo de execução**. Permite `borrow()/borrow_mut()` mesmo quando você só tem uma referência imutável ao `RefCell`.

Combinações comuns:

* `Rc<T>` + `RefCell<T>` para grafos/árvores mutáveis em thread única.
* Em cenários multi‑thread, use `Arc<T>` (atômico) e, quando precisar de mutação interna, `Mutex<T>`/`RwLock<T>`.

Atenção: `RefCell` pode causar *panic* em caso de **empréstimos inválidos** em runtime (ex.: dois `borrow_mut()` simultâneos). Ele **não** quebra as regras; apenas as adia do compilador para o runtime.

## 15.3 Dicas de pattern matching

Guardas, bindings e padrões compostos deixam o `match` ainda mais expressivo:

```rust
match some_value {
    Some(x) if x > 5 => println!("grande: {}", x),
    Some(x) => println!("pequeno: {}", x),
    None => println!("sem valor"),
}
```

Outros recursos úteis:

* **Bindings com `@`**: `n @ 10..=20` captura o valor casado.
* **Padrões aninhados**: combine structs, enums e tuplas em um único `match`.
* **`..` para ignorar campos**: útil em structs grandes (ex.: `Point { x, .. }`).

## 15.4 `impl Trait` em tipos de retorno

Quando você quer retornar “**algo que implementa** um trait” sem expor o tipo concreto:

```rust
fn greeter() -> impl Fn(String) -> String {
    |name| format!("Hello, {}!", name)
}
```

Comparando com trait objects:

* `impl Trait` no **retorno** preserva despacho **estático** e evita `Box`. Bom para pipelines e closures simples.
* `Box<dyn Trait>` permite **despacho dinâmico** e tipos heterogêneos, à custa de indireção.

**Object safety**: métodos que consomem `self` por valor geralmente **não** são chamáveis via `dyn Trait`. Alternativas: `self: Box<Self>` no método, ou restringir `Self: Sized` e usar genéricos.

## 15.5 Módulos, visibilidade e organização

Use `mod`, `pub` e `use` para organizar o código:

```rust
mod math {
    pub fn add(x: i32, y: i32) -> i32 { x + y }
}

fn main() {
    println!("{}", math::add(2, 3));
}
```

Boas práticas:

* Estruture o **árvore de módulos** de fora para dentro (API pública) e esconda detalhes de implementação.
* Reexporte com `pub use` quando quiser expor uma “fachada” estável.
* Separe crates em workspaces quando houver limites claros entre domínios.

## 15.6 Pontos de atenção e quando usar cada recurso

* Use `Fn`/`FnMut`/`FnOnce` conforme o **padrão de captura** da closure.
* Prefira `impl Trait` em retornos quando o tipo concreto não importa e você quer **zero overhead**.
* Recorra a `Box<dyn Trait>` para **heterogeneidade** em runtime ou para reduzir código gerado por monomorfização.
* Escolha smart pointers de acordo com o **modelo de posse**: `Box` para heap simples; `Rc`/`Arc` para compartilhamento; `RefCell`/`Mutex`/`RwLock` para mutabilidade interior (com responsabilidade).
* Em `match`, explore guardas e padrões compostos para **exaustividade clara** e menos `if/else` aninhado.

## 15.7 Encerramento

* Traits de função permitem closures flexíveis e seguras.
* Smart pointers viabilizam estruturas ricas mantendo segurança de memória.
* Pattern matching avança de casos simples para modelagem profunda de dados.
* Uma boa árvore de módulos mantém o projeto coeso e evolutivo.

Com esses tópicos avançados, você tem munição para projetar APIs e sistemas idiomáticos em Rust, mantendo **clareza**, **segurança** e **desempenho**.

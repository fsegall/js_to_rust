# Apêndice — Duck typing ad hoc, TypeScript estrutural e receptores em Rust (unificado)

Este apêndice reúne dois tópicos que aparecem ao longo do livro:

1. **Duck typing ad hoc** (JavaScript), **contrato estrutural e estático** (TypeScript) e **contrato nominal e explícito** (Rust via traits)
2. **Receptores de método**: `&self`, `&mut self`, `self` (Rust) comparados a `this` (JS/TS) e `self`/`typing.Self` (Python)

Sem delimitadores YAML e sem regras horizontais.

## Parte 1 — Duck typing ad hoc, TypeScript estrutural e Rust com traits

### 1. Duck typing ad hoc (JS)

**Definição.** “Se parece com um pato e faz ‘quack’, uso como pato”. Em JS, você usa um valor com base no comportamento que ele parece expor, sem um tipo declarado. O “contrato” é implícito e só falha em tempo de execução.

Exemplo:

```js
function render(shape) {
  // contrato implícito: shape deve ter draw()
  shape.draw(); // se não tiver, erro em runtime
}

// checagem manual, opcional
function renderSafe(shape) {
  if (!shape || typeof shape.draw !== "function") {
    throw new Error("shape must implement draw()");
  }
  shape.draw();
}
```

Vantagem: flexível e rápido de escrever. Custo: ausência de garantias; violações só aparecem em produção ou testes.

### 2. TypeScript: contrato estrutural e estático

**Estrutural**: compatibilidade determinada pela forma (campos e assinaturas), não pelo nome do tipo. **Estático**: verificação em tempo de compilação (checker do TS).

```ts
interface Drawable { draw(): void }

function render(s: Drawable) {
  s.draw(); // garantido pelo compilador
}

// qualquer objeto com a mesma forma é compatível
const circle = { draw() { console.log("circle") }, r: 10 };
render(circle); // ok, compatível estruturalmente
```

Observações:

* Não é obrigatório declarar `implements Drawable`; basta ter a forma.
* O TS aponta erros cedo. Em literais, a verificação de propriedades “extras” é mais rígida.
* Tipos com membros `private`/`protected` tendem ao comportamento nominal.

### 3. Rust: contrato nominal e explícito (traits)

Rust não usa duck typing. Utiliza **traits** para expressar capacidades. Compatibilidade é **nominal** (você declara `impl Trait for Tipo`) e a checagem é **estática**.

```rust
trait Drawable {
    fn draw(&self);
}

struct Circle;

impl Drawable for Circle {
    fn draw(&self) { println!("circle"); }
}

// polimorfismo estático (genéricos)
fn render<T: Drawable>(x: &T) { x.draw(); }

// polimorfismo dinâmico (trait objects)
fn render_dyn(x: &dyn Drawable) { x.draw(); }
```

Por que “nominal”? Porque só quem declara `impl Drawable for Tipo` é aceito como `Drawable`. Ter “a mesma forma” não basta.

### 4. Dinâmico vs estático em Rust: `&dyn Trait` e genéricos

* **Genéricos (`T: Trait`)**: despacho estático (monomorfização). Desempenho excelente.
* **`&dyn Trait`**: despacho dinâmico em runtime (vtable). Útil para heterogeneidade.

Ambos mantêm contratos explícitos via traits; muda apenas como a chamada é resolvida.

### 5. Lado a lado

| Tema                   | JavaScript         | TypeScript (estrutural, estático) | Rust (nominal, explícito)           |
| ---------------------- | ------------------ | --------------------------------- | ----------------------------------- |
| Contrato               | Implícito, por uso | Pela forma (shape)                | Por declaração (`impl Trait for T`) |
| Momento de verificação | Runtime            | Compilação                        | Compilação                          |
| Falhas típicas         | Erro tardio        | Erros cedo, nuances de literais   | Erros cedo, contrato explícito      |
| Polimorfismo           | Livre (ad hoc)     | Estrutural                        | Traits (genéricos ou `dyn`)         |

### 6. Exemplos completos

**JS ad hoc**

```js
function area(shape) { return shape.area(); }
area({ side: 2 }); // TypeError: shape.area is not a function
```

**TS estrutural**

```ts
interface HasArea { area(): number }
function area(s: HasArea) { return s.area() }
const square = { side: 2, area() { return this.side * this.side } };
area(square); // ok
const bad = { side: 2 };
area(bad); // erro: 'area' ausente
```

**Rust com traits**

```rust
trait HasArea { fn area(&self) -> f64; }
struct Square { side: f64 }
impl HasArea for Square { fn area(&self) -> f64 { self.side * self.side } }
fn area<T: HasArea>(s: &T) -> f64 { s.area() }
let sq = Square { side: 2.0 };
println!("{}", area(&sq));
```

### 7. Migração prática

1. Nomeie o comportamento como trait.
2. Defina o contrato mínimo (métodos essenciais).
3. Implemente `impl Trait for Tipo` para cada tipo concreto.
4. Use genéricos para desempenho; `&dyn Trait` para heterogeneidade.
5. Exporte a trait; esconda detalhes em módulos.

### 8. Perguntas frequentes

**“Estrutural e estático” em TypeScript?**
Estrutural: compatível se tem a forma. Estático: checker valida em compilação.

**Por que Rust não usa tipagem estrutural?**
Para manter coerência e autoria clara: quem declara `impl` define a capacidade. Evita colisões.

**Quando usar `&dyn Trait`?**
Coleções heterogêneas, APIs polimórficas em runtime ou para reduzir código gerado.

## Parte 2 — Receptores em Rust vs `this` (JS/TS) vs `self` (Python)

### Visão geral

| Linguagem | Receptor      | Significado                          | Passagem                                      | Quem decide          |
| --------- | ------------- | ------------------------------------ | --------------------------------------------- | -------------------- |
| Rust      | `&self`       | Empréstimo imutável                  | Referência compartilhada                      | Assinatura do método |
|           | `&mut self`   | Empréstimo mutável exclusivo         | Referência exclusiva                          | Assinatura do método |
|           | `self`        | Move/consome o valor                 | Por valor (ownership)                         | Assinatura do método |
| JS/TS     | `this`        | Ponteiro dinâmico para o receptor    | Depende do call‑site (`obj.m()`, `call/bind`) | Local da chamada     |
| Python    | `self`        | Primeiro parâmetro do método         | Passado explicitamente pelo runtime           | Autor do método      |
| Python    | `typing.Self` | Tipo “o próprio tipo” para anotações | Somente estático                              | Autor da assinatura  |

### Exemplos rápidos

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
let n = c.into_inner();      // move c; não pode usar c depois
```

**JavaScript/TypeScript**

```ts
class Counter { n = 0; peek() { return this.n } bump() { this.n += 1 } }
const c = new Counter();
const f = c.bump;
f();        // erro em strict mode (this === undefined)
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

### Dicas práticas (JS → Rust)

* Método que apenas lê → `&self`.
* Método que muta → `&mut self`.
* Método que consome/transfere ownership → `self`.
* Não existe `bind` em Rust: a assinatura determina o receptor.

### `dyn Trait` vs genéricos e object safety

* **Genéricos**: `fn render<T: Drawable>(x: &T)` → despacho estático (monomorfização).
* **Trait object**: `fn render(x: &dyn Drawable)` → despacho dinâmico (vtable).
* **Object safety**: métodos que tomam `self` por valor não são chamáveis via `dyn Trait`. Alternativas: `self: Box<Self>` ou restringir `Self: Sized` e usar genéricos.

### Erros comuns ao portar de JS/TS

* Extrair um método e perder o receptor: `const f = obj.m; f();` quebra `this` em JS; em Rust não existe rebind dinâmico.
* Tentar mutar via `&self`: em Rust, só `&mut self` permite mutação.
* Esquecer que `self` move: após consumir `self`, o valor não pode mais ser usado.

### Mapa mental

* `&self` → leitura.
* `&mut self` → escrita com exclusividade.
* `self` → consumo/transferência de ownership.
* Traits definem contratos explícitos; não há `this` dinâmico.

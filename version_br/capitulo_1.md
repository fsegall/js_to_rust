# Capítulo 1 — Por que Rust? Comparando filosofias

Antes de entrar em ferramentas ou sintaxe, vale dar um passo atrás e perguntar:

**Por que aprender Rust sendo desenvolvedor JavaScript?**

Rust não veio para “substituir” JavaScript; os dois resolvem problemas diferentes. Entender a filosofia de Rust ajuda você a se adaptar às regras mais rígidas da linguagem e a destravar o seu potencial.

## A promessa de Rust: desempenho com garantias

Rust foi desenhada para responder à pergunta:

> *“É possível ter desempenho de baixo nível **sem** segfaults, condições de corrida de dados (data races) e vazamentos de memória?”*

**O que é “segfault” (falha de segmentação)?**
Em sistemas com memória protegida, cada processo só pode acessar endereços válidos do seu espaço de memória. Um *segmentation fault* acontece quando o programa tenta **ler ou escrever um endereço inválido** (por exemplo, ponteiro nulo/desalocado, acesso fora dos limites de um array, *use-after-free*, *stack overflow* ou tentar executar dados como código). O SO envia o sinal **SIGSEGV** e o processo cai. Em **Rust seguro**, essas classes de erro são prevenidas pelo modelo de **ownership/borrowing**, checagens de limites em *slices* e referências não nulas; ainda assim, código `unsafe` ou FFI mal utilizado podem reintroduzir riscos.

**O que é “data race” (condição de corrida de dados)?**
É quando **duas ou mais threads acessam a mesma região de memória ao mesmo tempo**, **pelo menos uma escreve**, e **não há sincronização** que estabeleça uma ordem (“happens‑before”) entre esses acessos. O resultado é comportamento indefinido: valores corrompidos, travamentos intermitentes, bugs difíceis de reproduzir. Em **Rust seguro**, data races são evitadas pelo sistema de tipos: ou você tem **múltiplas leituras compartilhadas** (`&T`), ou **uma única escrita exclusiva** (`&mut T`). Para compartilhar mutação entre threads, usa‑se **tipos de sincronização** (por exemplo, `Mutex<T>`, `RwLock<T>`, canais) e os *auto‑traits* `Send`/`Sync` garantem segurança na passagem de dados entre threads.

**O que é vazamento de memória?**
Em termos práticos, é quando um processo passa a consumir cada vez mais memória porque **blocos alocados nunca são liberados**. Em linguagens com GC, isso costuma ocorrer quando referências permanecem vivas (por exemplo, em caches ou variáveis globais), impedindo a coleta. Em linguagens com gerenciamento manual, surge ao esquecer de liberar (`free`/`delete`). Em Rust, o modelo de **ownership/borrowing** libera memória **deterministicamente** quando o dono sai de escopo, evitando classes inteiras de vazamentos e de *dangling pointers*. Vazamentos ainda são possíveis (por exemplo, ciclos com `Rc` ou uso deliberado de `std::mem::forget`/`Box::leak`), mas tendem a ser raros e explícitos no design.

Ela entrega:

* **Abstrações de custo zero**, tão rápidas quanto C/C++, com segurança
* **Segurança de memória sem garbage collector**
* **Garantias em tempo de compilação** para concorrência e correção

Para quem vem de JS, a sensação é sair de uma scooter (dinâmica, divertida) para pilotar um caça (estrito, potente, exige treino).

## Diferenças filosóficas: Rust vs JavaScript

| Conceito     | JavaScript                              | Rust                                           |
| ------------ | --------------------------------------- | ---------------------------------------------- |
| Tipagem      | Dinâmica, fraca (TS é opcional)         | Estática, forte, verificada em compilação      |
| Mutabilidade | Tudo mutável salvo `const`              | Tudo imutável salvo `mut`                      |
| Memória      | Coletor de lixo                         | Propriedade (ownership) e empréstimo (borrow)  |
| Erros        | `try/catch`, pode lançar qualquer coisa | `Result<T, E>` e `Option<T>` explícitos        |
| Concorrência | Event loop, `async/await`               | Threads, `async`, passagem de mensagens segura |
| Segurança    | Erros em tempo de execução, coerção     | Segurança em compilação, sem null por padrão   |
| Ferramentas  | Leves (npm, yarn, browser-first)        | Robustas (cargo, crates.io, systems-first)     |

## A grande mudança de mentalidade

O que pode surpreender:

* No Rust, o **compilador é seu parceiro**. Ele bloqueia o build até o código estar correto, o que parece chato no começo, mas rende a longo prazo.
* **Sem `null` ou `undefined`**; use `Option<T>`.
* **Tratamento de erros** não é um fallback de `try/catch`, faz parte do desenho da função.
* **Propriedade de memória** é regida por regras, não por convenções.
* **Concorrência** nasce segura graças ao borrow checker.

Rust ganhou reputação por combinar desempenho, confiabilidade e segurança de memória sem GC. Enquanto JavaScript domina a web pela flexibilidade, Rust oferece a chance de construir aplicações mais rápidas e seguras, especialmente em programação de sistemas, WebAssembly e outros cenários de alto desempenho.

Este livro é para **desenvolvedores JavaScript que querem aprender Rust de forma prática e rápida**, com exemplos lado a lado, destacando diferenças de sintaxe e adaptando seu modelo mental ao compilador e ao sistema de tipos de Rust.

## Para quem é

* Devs frontend ou backend em JS/TS
* Engenheiros de smart contracts vindos de stacks web3
* Builders de hackathon
* Quem quer subir o nível com uma linguagem de baixo nível

## O que você vai aprender

* Fundamentos de Rust (variáveis, funções, controle de fluxo)
* Ownership, borrowing e lifetimes, o núcleo de Rust
* Structs, enums e pattern matching
* Tratamento de erros ao estilo Rust
* Módulos, pacotes e testes
* Como **pensar em Rust** vindo de JS

## Estratégia de aprendizagem

Este é um livro **orientado a projetos**.

* Comparações curtas JS ↔ Rust
* Mini‑exercícios para fixação
* Exemplos simples, porém significativos
* Dicas práticas para migrar o modelo mental de JS para Rust

> Se Rust já te assustou, este capítulo é para você. Vamos suavizar a curva, de forma prática e direta.

Próximo passo: preparar o ambiente de desenvolvimento em Rust.

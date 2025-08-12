# Rust for JS Devs — Build Guide

This repo contains both the **PT‑BR** and **EN** versions of the book.
Use the commands below to concatenate chapter files and generate EPUBs with **Pandoc**.

## Prerequisites

* [Pandoc](https://pandoc.org/) installed and available on your `PATH`
* Folder layout:

  * `version_br/` (PT‑BR chapter `.md` files)
  * `final_version_br/` (`metadata.yaml`, `cover_br.jpg`)
  * `version_us/` (EN chapter `.md` files)
  * `final_version_us/` (`metadata.yaml`, `cover.jpeg` or `cover.png`)

---

## Manual build — PT‑BR

```bash
# 1) Concatenate PT‑BR chapters into a single manuscript
cat \
  version_br/introducao.md \
  version_br/capitulo_1.md \
  version_br/capitulo_2.md \
  version_br/capitulo_3.md \
  version_br/capitulo_4.md \
  version_br/capitulo_5.md \
  version_br/capitulo_6.md \
  version_br/capitulo_7.md \
  version_br/capitulo_8.md \
  version_br/capitulo_9.md \
  version_br/capitulo_10.md \
  version_br/capitulo_11.md \
  version_br/capitulo_12.md \
  version_br/capitulo_13.md \
  version_br/capitulo_14.md \
  version_br/capitulo_15.md \
  version_br/conclusao.md \
  version_br/apendice.md \
  > final_version_br/manuscrito.md

# 2) Generate PT‑BR EPUB
pandoc \
  --from=markdown \
  --to=epub3 \
  --toc --toc-depth=2 \
  --metadata-file=final_version_br/metadata.yaml \
  --epub-cover-image=final_version_br/cover_br.jpg \
  -o final_version_br/book.epub \
  final_version_br/manuscrito.md
```

## Manual build — EN

```bash
# 1) Concatenate EN chapters into a single manuscript
cat \
  version_us/intro.md \
  version_us/chapter_1.md \
  version_us/chapter_2.md \
  version_us/chapter_3.md \
  version_us/chapter_4.md \
  version_us/chapter_5.md \
  version_us/chapter_6.md \
  version_us/chapter_7.md \
  version_us/chapter_8.md \
  version_us/chapter_9.md \
  version_us/chapter_10.md \
  version_us/chapter_11.md \
  version_us/chapter_12.md \
  version_us/chapter_13.md \
  version_us/chapter_14.md \
  version_us/chapter_15.md \
  version_us/conclusion.md \
  version_us/appendix.md \
  > final_version_us/manuscript.md

# 2) Generate EN EPUB
pandoc \
  --from=markdown \
  --to=epub3 \
  --toc --toc-depth=2 \
  --metadata-file=final_version_us/metadata.yaml \
  --epub-cover-image=final_version_us/cover.jpeg \
  -o final_version_us/book.epub \
  final_version_us/manuscript.md
```

---

## Automated build — Makefile

A `Makefile` is included to build both languages in one go.

```bash
# Build both PT‑BR and EN
make
# or
make all

# Build only PT‑BR
make br

# Build only EN
make en

# Clean generated outputs
make clean
```

**What it does:**

* Concatenates chapters in the correct order
* Writes merged manuscripts to:

  * `final_version_br/manuscrito.md`
  * `final_version_us/manuscript.md`
* Invokes Pandoc with each language’s metadata and cover image

> Tip: You can set `PANDOC_BIN` if Pandoc isn’t on your PATH, e.g. `make PANDOC_BIN=/usr/local/bin/pandoc`.

---

## Troubleshooting

* **`pandoc: command not found`** — Install Pandoc and ensure it’s on your `PATH`.
* **Wrong cover path** — Confirm `--epub-cover-image` points to the actual cover file in `final_version_*`.
* **Chapter order issues** — The `cat` order defines the book order. Adjust if you rename or add chapters.
* **Metadata errors** — Validate `metadata.yaml` (proper YAML) and double‑check `title`, `author`, and `lang`.
* **Encoding / headings run together** — Ensure each chapter ends with a trailing newline. (The Makefile adds spacing when concatenating.)

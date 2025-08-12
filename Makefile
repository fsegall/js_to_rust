# -----------------------------------------------------------------------------
# Makefile — Build both PT-BR and EN books (manuscripts + EPUB via Pandoc)
#
# Usage:
#   make          # build both languages
#   make br       # build only PT-BR
#   make en       # build only EN
#   make clean    # remove generated manuscripts and EPUBs
# -----------------------------------------------------------------------------

# ---- Tools -------------------------------------------------------------------
PANDOC ?= pandoc

# ---- Directories --------------------------------------------------------------
BR_DIR       := version_br
EN_DIR       := version_us
BR_OUT_DIR   := final_version_br
EN_OUT_DIR   := final_version_us

# ---- Output paths -------------------------------------------------------------
BR_MANUSCRIPT := $(BR_OUT_DIR)/manuscrito.md
EN_MANUSCRIPT := $(EN_OUT_DIR)/manuscript.md
BR_EPUB       := $(BR_OUT_DIR)/book.epub
EN_EPUB       := $(EN_OUT_DIR)/book.epub

# ---- Optional assets (metadata + cover) --------------------------------------
BR_META   := $(BR_OUT_DIR)/metadata.yaml
BR_COVER  := $(BR_OUT_DIR)/cover_br.jpg
EN_META   := $(firstword $(wildcard $(EN_OUT_DIR)/metadata.yaml $(EN_OUT_DIR)/book-metadata.yaml))
EN_COVER  := $(firstword $(wildcard $(EN_OUT_DIR)/cover.jpeg $(EN_OUT_DIR)/cover.png))

# ---- Chapter lists (order matters) -------------------------------------------
BR_FILES := \
	introducao.md \
	capitulo_1.md \
	capitulo_2.md \
	capitulo_3.md \
	capitulo_4.md \
	capitulo_5.md \
	capitulo_6.md \
	capitulo_7.md \
	capitulo_8.md \
	capitulo_9.md \
	capitulo_10.md \
	capitulo_11.md \
	capitulo_12.md \
	capitulo_13.md \
	capitulo_14.md \
	capitulo_15.md \
	conclusao.md \
	apendice.md

EN_FILES := \
	intro.md \
	chapter_1.md \
	chapter_2.md \
	chapter_3.md \
	chapter_4.md \
	chapter_5.md \
	chapter_6.md \
	chapter_7.md \
	chapter_8.md \
	chapter_9.md \
	chapter_10.md \
	chapter_11.md \
	chapter_12.md \
	chapter_13.md \
	chapter_14.md \
	chapter_15.md \
	conclusion.md \
	appendix.md

# ---- Phony targets ------------------------------------------------------------
.PHONY: all br en clean check_pandoc ensure_dirs

# Build both languages
all: br en

# Build only PT-BR
br: $(BR_EPUB)

# Build only EN
en: $(EN_EPUB)

# Ensure pandoc is available
check_pandoc:
	@command -v $(PANDOC) >/dev/null 2>&1 || { \
		echo "Error: 'pandoc' not found on PATH. Please install it."; exit 1; }

# Ensure output folders exist
ensure_dirs:
	@mkdir -p "$(BR_OUT_DIR)" "$(EN_OUT_DIR)"

# ---- Manuscript rules ---------------------------------------------------------

# PT-BR manuscript: concatenate chapters with blank lines between files
$(BR_MANUSCRIPT): check_pandoc ensure_dirs $(addprefix $(BR_DIR)/,$(BR_FILES))
	@echo ">> Building PT-BR manuscript -> $@"
	@: > "$@"
	@for f in $(addprefix $(BR_DIR)/,$(BR_FILES)); do \
		cat "$$f" >> "$@"; \
		printf "\n\n" >> "$@"; \
	done

# EN manuscript: concatenate chapters with blank lines between files
$(EN_MANUSCRIPT): check_pandoc ensure_dirs $(addprefix $(EN_DIR)/,$(EN_FILES))
	@echo ">> Building EN manuscript -> $@"
	@: > "$@"
	@for f in $(addprefix $(EN_DIR)/,$(EN_FILES)); do \
		cat "$$f" >> "$@"; \
		printf "\n\n" >> "$@"; \
	done

# ---- EPUB rules ---------------------------------------------------------------

# PT-BR EPUB via Pandoc (uses metadata/cover if present)
$(BR_EPUB): $(BR_MANUSCRIPT)
	@echo ">> Generating PT-BR EPUB -> $@"
	@META_OPT=""; COVER_OPT=""; \
	[ -f "$(BR_META)" ]  && META_OPT="--metadata-file $(BR_META)" || echo "Warning: PT-BR metadata not found: $(BR_META)"; \
	[ -f "$(BR_COVER)" ] && COVER_OPT="--epub-cover-image $(BR_COVER)" || echo "Warning: PT-BR cover not found: $(BR_COVER)"; \
	$(PANDOC) --from=markdown --to=epub3 --toc --toc-depth=2 $$META_OPT $$COVER_OPT -o "$@" "$(BR_MANUSCRIPT)"

# EN EPUB via Pandoc (supports metadata.yaml or book-metadata.yaml; cover.jpeg or cover.png)
$(EN_EPUB): $(EN_MANUSCRIPT)
	@echo ">> Generating EN EPUB -> $@"
	@META_OPT=""; COVER_OPT=""; \
	if [ -n "$(EN_META)" ] && [ -f "$(EN_META)" ]; then META_OPT="--metadata-file $(EN_META)"; else echo "Warning: EN metadata not found."; fi; \
	if [ -n "$(EN_COVER)" ]; then COVER_OPT="--epub-cover-image $(EN_COVER)"; else echo "Warning: EN cover not found (cover.jpeg/cover.png)."; fi; \
	$(PANDOC) --from=markdown --to=epub3 --toc --toc-depth=2 $$META_OPT $$COVER_OPT -o "$@" "$(EN_MANUSCRIPT)"

# ---- Cleanup ------------------------------------------------------------------
clean:
	@echo ">> Cleaning generated files"
	@rm -f "$(BR_MANUSCRIPT)" "$(EN_MANUSCRIPT)" "$(BR_EPUB)" "$(EN_EPUB)"

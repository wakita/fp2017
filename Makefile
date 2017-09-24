# GNU Makefile

.SUFFIXES: .html .md .pdf
.DEFAULT: html
all: html

SLIDES   := $(basename $(notdir $(wildcard slide/*-*.md)))
MD       := $(addprefix slide/,     $(addsuffix .md,   $(SLIDES)))
HTML_TMP := $(addprefix docs/tmp/,  $(addsuffix .html, $(SLIDES)))
HTML     := $(addprefix docs/html/, $(addsuffix .html, $(SLIDES)))
PDF      := $(addprefix pdf/,       $(addsuffix .pdf,  $(SLIDES)))

clean:
	rm -rf $(HTML_TMP)
	rm -f $(HTML) $(PLAIN)

veryclean: clean
	rm -f $(MD)
	rm -f .depend
	bin/depend

# Markdown -> HTML is achieved in two-stages.
html: docs/index.html $(HTML)

docs/index.html: slide/index.md
	pandoc --to html --standalone --output $@ $^

docs/html/%.html: slide/%.md docs/dev/kw.js
	$(eval slide := $(basename $(notdir $@)))
	$(eval md    := $(addprefix slide/,     $(addsuffix .md,   $(slide))))
	$(eval html1 := $(addprefix docs/tmp/,  $(addsuffix .html, $(slide))))
	$(eval html2 := $(addprefix docs/html/, $(addsuffix .html, $(slide))))

	@# Firstly, Pandoc generates a temporary HTML file:
	@# slide/*.md -> tmp/*.html
	@echo "pandoc:    $(md) => $(html1)"
	@pandoc docs/dev/slide.yaml $(md) \
	  --to=revealjs --slide-level=2 \
	  --standalone \
	  --output=$(html1) \
 	  -V revealjs-url=lib/reveal.js-3.5.0 \
 	  -V theme=solarized \
	  --smart

	@# Then, PhantomJS is used to patch the temporary HTML and finishes it.
	@# tmp/*.html -> ../*.html
	@echo "phantomjs: $(html1) => $(html2)"
	@phantomjs docs/dev/phantom.js $(slide)
	@echo

pdf: $(PDF)

pdf/%.pdf: docs/%.html
	$(eval slide := $(basename $(notdir $@)))
	$(eval pdf := $(addprefix pdf/, $(addsuffix .pdf, $(slide))))
	$(eval url := $(addprefix http://localhost:8081/, $(addsuffix .html, $(slide))))

	decktape $(url) $(pdf)

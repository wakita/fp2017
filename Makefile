# GNU Makefile

.SUFFIXES: .html .md .pdf
.DEFAULT: html
all: html

SLIDES   := $(basename $(notdir $(wildcard slide/*-*.md)))
STML_TMP := $(addprefix docs/tmp/,  $(addsuffix .html, $(SLIDES)))
STML     := $(addprefix docs/html/, $(addsuffix .html, $(SLIDES)))
PDF      := $(addprefix pdf/,       $(addsuffix .pdf,  $(SLIDES)))

PAGE     := $(basename $(notdir $(wildcard page/*.md)))
PTML     := $(addprefix docs/, $(addsuffix .html, $(PAGE)))

clean:
	rm -f $(STML_TMP) $(STML) $(PTML) $(PDF)

# Markdown -> HTML is achieved in two-stages.
html: server $(STML) $(PTML)

docs/%.html: page/%.md
	@echo "pandoc: $^ => $@"
	@pandoc $^ \
	  --to html \
	  --standalone \
	  --output $@ \
          --css=/fp2017/lib/reveal.js-3.5.0/css/theme/solarized.css \
	  --css=/fp2017/lib/kw.css \
	  --css=/fp2017/lib/kw-page.css \
	  --mathjax \
	  --smart

STML_DEV = docs/dev/kw.js docs/dev/phantom.js docs/dev/slide.yaml

docs/html/%.html: $(STML_DEV) slide/%.md
	$(eval slide := $(basename $(notdir $@)))
	$(eval md    := $(addprefix slide/,     $(addsuffix .md,   $(slide))))
	$(eval html1 := $(addprefix docs/tmp/,  $(addsuffix .html, $(slide))))
	$(eval html2 := $(addprefix docs/html/, $(addsuffix .html, $(slide))))

	@# Firstly, Pandoc generates a temporary HTML file:
	@# slide/*.md -> tmp/*.html
	@echo "pandoc:    $(md) => $(html1)"
	pandoc docs/dev/slide.yaml $(md) \
	  --to=revealjs --slide-level=2 \
	  --template=lib/default.revealjs \
	  --standalone \
	  --output=$(html1) \
 	  -V revealjs-url=/fp2017/lib/reveal.js-3.5.0 \
 	  -V theme=solarized \
	  -V slideNumber=true \
	  -V width=1280 -V height=1024 \
	  --css=/fp2017/lib/kw.css \
	  --mathjax \
	  --smart

	@# Then, PhantomJS is used to patch the temporary HTML and finishes it.
	@echo "phantomjs: $(html1) => $(html2)"
	@phantomjs docs/dev/phantom.js $(slide) $(html2)
	@echo

docs/assignment/%.html: assignment/%.md
	@echo "pandoc: $^ => $@"
	@pandoc $^ \
	  --to html \
	  --standalone \
	  --output $@ \
          --css=/fp2017/lib/reveal.js-3.5.0/css/theme/solarized.css \
	  --css=/fp2017/lib/kw.css \
	  --css=/fp2017/lib/kw-page.css \
	  --mathjax \
	  --smart

pdf: $(PDF)

pdf/%.pdf: docs/%.html
	$(eval slide := $(basename $(notdir $@)))
	$(eval pdf := $(addprefix pdf/, $(addsuffix .pdf, $(slide))))
	$(eval url := $(addprefix http://localhost:8080/, $(addsuffix .html, $(slide))))

	decktape $(url) $(pdf)

server:
	wget --quiet --spider "http://localhost:8080/fp2017/" || (cd $(HOME)/Sites; php -S localhost:8080 &)

shutdown:
	killall php

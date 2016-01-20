SHELL    = /bin/bash

DOCS     = Intro_slide.html         Intro_exercise.pdf \
           BuildOpenIFS_slide.html  BuildOpenIFS_exercise.pdf \
           RunOpenIFS_slide.html    RunOpenIFS_exercise.pdf
FUN_pdf  = org-latex-export-to-pdf
FUN_html = org-reveal-export-to-html

vpath %.org  src
vpath %.html doc
vpath %.pdf  doc
vpath %.bash bin

define compile
emacs $1 --batch -u $(USER) -f $(FUN_$2) -f org-babel-tangle --kill
rm -f $(1:.org=.tex)
mv $(1:.org=.$2) doc/
endef

.PHONY : all

all : $(DOCS)

%.html : %.org
	$(call compile,$<,html)
%.pdf  : %.org
	$(call compile,$<,pdf)

makefile : Intro_exercise.org
	emacs $< --batch -u $(USER) -f org-babel-tangle --kill

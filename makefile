
ROOTDIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SCRATCH := $(CURDIR)/build
SHELL    = /bin/bash

DOCS     = Intro_slide.html         Intro_exercise.pdf \
           BuildOpenIFS_slide.html  BuildOpenIFS_exercise.pdf \
           RunOpenIFS_slide.html    RunOpenIFS_exercise.pdf
SRC_EXT  = $(addprefix $(SCRATCH)/, \
           $(notdir $(wildcard $(ROOTDIR)/src/*.tex $(ROOTDIR)/src/*.svg)))
FUN_pdf  = org-latex-export-to-pdf
FUN_html = org-reveal-export-to-html

vpath %.org  $(ROOTDIR)/src

define emacs_conf
(setq org-src-preserve-indentation t)
(add-to-list 'load-path "$(ROOTDIR)/org-reveal")
(require 'ox-reveal)
(setq org-reveal-root "file://$(ROOTDIR)/reveal.js")
endef

define compile
cp -f $1 $(SCRATCH)/
cd $(SCRATCH); emacs $(notdir $1) -L $(CURDIR) -l emacs_conf.el --batch -f $(FUN_$2) -f org-babel-tangle --kill
mv $(SCRATCH)/$(notdir $(1:.org=.$2)) $(CURDIR)/
rm -f $(SCRATCH)/$(basename $(notdir $1)).*
endef

.PHONY : all

all : $(DOCS)

%.html : %.org $(SRC_EXT) emacs_conf.el | $(SCRATCH)
	$(call compile,$<,html)
%.pdf  : %.org $(SRC_EXT) emacs_conf.el | $(SCRATCH)
	$(call compile,$<,pdf)

$(SCRATCH) :
	mkdir -p $@
$(SRC_EXT) : | $(SCRATCH)
	ln -sf $(ROOTDIR)/src/$(notdir $@) $@
emacs_conf.el :
	$(file >$@,$(emacs_conf))

makefile : Intro_exercise.org
	emacs $< -q -Q --batch --eval '(setq org-src-preserve-indentation t)' -f org-babel-tangle --kill

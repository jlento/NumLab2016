ROOTDIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHELL    = /bin/bash

HTML    := Intro_slide.html BuildOpenIFS_slide.html RunOpenIFS_slide.html
PDF     := Intro_exercise.pdf BuildOpenIFS_exercise.pdf \
        RunOpenIFS_exercise.pdf
include script.list     # Defines SCRIPTS (computed from HTML and PDF)

DEPS    := $(HTML:.html=.d) $(PDF:.pdf=.d)
SRC_EXT := $(notdir $(wildcard $(ROOTDIR)/src/*.tex $(ROOTDIR)/src/*.svg))

vpath %.org $(ROOTDIR)/src

define emacs-export-conf
(setq org-src-preserve-indentation t)

;; Setup reveal.js
(setq org-src-preserve-indentation t)
(add-to-list 'load-path "$(ROOTDIR)/org-reveal")
(require 'ox-reveal)
(setq org-reveal-root "file://$(ROOTDIR)/reveal.js")

;; Write the exports to current directory instead of the source directory
(defadvice org-export-output-file-name (before org-add-export-dir activate)
  "Modifies org-export to place exported files in a different directory"
  (setq pub-dir (getenv "PWD")))
endef

.PHONY : all deps clean

all : $(HTML) $(PDF) $(SCRIPTS)

%.html : %.org $(SRC_EXT) | emacs-export-conf.el
	emacs $< -L $(CURDIR) -l emacs-export-conf.el --batch -f org-reveal-export-to-html --kill

%.pdf  : %.org $(SRC_EXT) | emacs-export-conf.el
	emacs $< -L $(CURDIR) -l emacs-export-conf.el --batch -f org-latex-export-to-pdf --kill

$(SCRIPTS) :
	emacs $< --batch --eval '(setq org-src-preserve-indentation t)' -f org-babel-tangle --kill

$(SRC_EXT) :
	ln -sf $(ROOTDIR)/src/$@

emacs-export-conf.el : $(ROOTDIR)/makefile
	$(file >$@,$(emacs-export-conf))

script.list : $(patsubst %.org,%.d,$(notdir $(wildcard $(ROOTDIR)/src/*.org)))
	echo SCRIPTS = $$(sed 's/:.*//' $^ | uniq) > $@

%.d : %.org
	echo $$(sed -rn "s,(^#\+.* :tangle *)([^ ]+)(.*),$(dir $<)\2,;s,\.\./,,p" $< | uniq) : $(notdir $<) > $@ 

include $(DEPS)

clean :
	rm -f *.d script.list *.pdf *.tex *.html emacs-export-conf.el

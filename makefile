ROOTDIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHELL    = /bin/bash

HTML := Intro_slide.html BuildOpenIFS_slide.html RunOpenIFS_slide.html
PDF  := Intro_exercise.pdf BuildOpenIFS_exercise.pdf \
        RunOpenIFS_exercise.pdf

vpath %.org $(ROOTDIR)/src

.PHONY : all deps clean

all : $(HTML) $(PDF)

%.html : %.org | emacs-export-conf.el
	emacs $< -L $(CURDIR) -l emacs-export-conf.el --batch \
            -f org-babel-tangle \
            -f org-reveal-export-to-html

%.pdf  : %.org | emacs-export-conf.el
	emacs $< -L $(CURDIR) -l emacs-export-conf.el --batch \
            -f org-babel-tangle \
            -f org-latex-export-to-pdf

DEPS = $(HTML:.html=.d) $(PDF:.pdf=.d)

deps : $(DEPS)

$(DEPS) : %.d : %.org
	$(cook-deps)

%.html %.pdf : %.d

%.bash :
	emacs $< --eval '(setq org-src-preserve-indentation t)' --batch \
            -f org-babel-tangle

%.tex %.svg :
	ln -sf $(ROOTDIR)/src/$@

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

$(ROOTDIR)/makefile : Intro_exercise.org
	emacs $< --eval '(setq org-src-preserve-indentation t)' --batch \
            -f org-babel-tangle --kill

emacs-export-conf.el : $(ROOTDIR)/makefile
	$(file >$@,$(emacs-export-conf))

exercise_header.tex : graybox.tex
	ln -sf $(ROOTDIR)/src/$@

clean :
	rm -f *.d script.list *.pdf *.svg *.tex *.html emacs-export-conf.el

define emacs-export-conf
(setq org-src-preserve-indentation t)

;; Setup reveal.js
(add-to-list 'load-path "$(ROOTDIR)/org-reveal")
(require 'ox-reveal)
(setq org-reveal-root "file://$(ROOTDIR)/reveal.js")

;; Write the exports to current directory instead of the source directory
(defadvice org-export-output-file-name (before org-add-export-dir activate)
  "Modifies org-export to place exported files in a different directory"
  (setq pub-dir (getenv "PWD")))
endef

define cook-deps
sed -rn -e 's,(^#\+.* :tangle *(\.\./)*)([^ ]+)(.*),$(ROOTDIR)/\3,p' $< \
    | uniq | paste -sd ' ' - \
    | sed -r 's,^.+$$,& : $(notdir $<),' > $@
sed -rn -e 's/(.*\[[f]ile:)([^]]*)(.*)/\2/p' \
        -e 's,(.*\\input\{)(.*\.tex)(\}.*),\2,p' $< \
    | uniq | paste -sd ' ' - \
    | sed -r 's,^.+$$,$(notdir $<) : &,' >> $@
endef

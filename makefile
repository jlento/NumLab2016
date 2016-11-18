ROOTDIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHELL    = /bin/bash

HTML := Intro_slide.html BuildOpenIFS_slide.html RunOpenIFS_slide.html
PDF  := Intro_exercise.pdf BuildOpenIFS_exercise.pdf \
        RunOpenIFS_exercise.pdf

EMACS_CONF := $(ROOTDIR)/org-export.el
ORG_REVEAL := $(ROOTDIR)/org-reveal
REVEAL_JS  := $(ROOTDIR)/reveal.js

EMACS_FLAGS = -l $(EMACS_CONF) --batch -f org-babel-tangle
export ORG_REVEAL REVEAL_JS

vpath %.org $(ROOTDIR)/src

.PHONY : all deps clean

all : $(HTML) $(PDF)

%.html : %.org
	emacs $< $(EMACS_FLAGS) -f org-reveal-export-to-html

%.pdf  : %.org
	emacs $< $(EMACS_FLAGS) -f org-latex-export-to-pdf

DEPS = $(HTML:.html=.d) $(PDF:.pdf=.d)

deps : $(DEPS)

%.d : %.org
	$(cook-deps)

%.html %.pdf : %.d

%.bash :
	emacs $< $(EMACS_FLAGS)

%.tex %.svg :
	ln -sf $(ROOTDIR)/src/$@

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

$(ROOTDIR)/makefile : $(ROOTDIR)/Intro_exercise.org
	emacs $< --eval '(setq org-src-preserve-indentation t)' --batch \
            -f org-babel-tangle --kill

exercise_header.tex : graybox.tex

clean :
	rm -f *.d script.list *.pdf *.svg *.tex *.html

define cook-deps
sed -rn -e 's,(^#\+.* :tangle *(\.\./)*)([^ ]+)(.*),$(ROOTDIR)/\3,p' $< \
    | uniq | paste -sd ' ' - \
    | sed -r 's,^.+$$,& : $(notdir $<),' > $@
sed -rn -e 's/(.*\[[f]ile:)([^]]*)(.*)/\2/p' \
        -e 's,(.*\\input\{)(.*\.tex)(\}.*),\2,p' $< \
    | uniq | paste -sd ' ' - \
    | sed -r 's,^.+$$,$(notdir $<) : &,' >> $@
endef

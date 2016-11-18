(setq org-src-preserve-indentation t)

;; Setup reveal.js
(when (getenv "ORG_REVEAL")
  (add-to-list 'load-path (getenv "ORG_REVEAL")))
(require 'ox-reveal)
(when (getenv "REVEAL_JS")
  (setq org-reveal-root (concat "file://" (getenv "REVEAL_JS"))))

;; Write the exports to current directory instead of the source directory
(defadvice org-export-output-file-name (before org-add-export-dir activate)
  "Modifies org-export to place exported files in a different directory"
  (setq pub-dir (getenv "PWD")))

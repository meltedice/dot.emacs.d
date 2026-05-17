;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "magit" "20260516.2126"
  "A Git porcelain inside Emacs."
  '((emacs         "28.1")
    (compat        "31.0")
    (cond-let      "0.2")
    (llama         "1.0")
    (magit-section "4.5")
    (seq           "2.24")
    (transient     "0.13")
    (with-editor   "3.4"))
  :url "https://github.com/magit/magit"
  :commit "0a78ce71b03a56eacb8f2fd4452bb314c1049664"
  :revdesc "0a78ce71b03a"
  :keywords '("git" "tools" "vc")
  :authors '(("Marius Vollmer" . "marius.vollmer@gmail.com")
             ("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev"))
  :maintainers '(("Jonas Bernoulli" . "emacs.magit@jonas.bernoulli.dev")
                 ("Kyle Meyer" . "kyle@kyleam.com")))

;;; encodings

;; Regexp: http://flex.ee.uec.ac.jp/texi/emacs-jp/emacs-jp_53.html
;; \' は空の文字列にマッチしますが，バッファの最後にあるものにだけです．
;; shift_jis-dos / utf-8-unix / utf-8 / euc-jp
(modify-coding-system-alist 'file "\\.html\\'" 'utf-8-unix)
;;(modify-coding-system-alist 'file "\\.htm\\'"  'shift_jis)
;;(modify-coding-system-alist 'file "\\.\\(pl\\|cgi\\|pm\\|t\\)\\(\\.~BASE~\\|:magit-ediff\\*\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(php\\|mdl\\|inc\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(rb\\|erb\\|yml\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\ChangeLog\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(txt\\|log\\|org\\)\\'" 'utf-8-unix)

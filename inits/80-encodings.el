;;; encodings --- encodings settings

;; Regexp: http://flex.ee.uec.ac.jp/texi/emacs-jp/emacs-jp_53.html
;; \' は空の文字列にマッチしますが，バッファの最後にあるものにだけです．
;; shift_jis-dos / utf-8-unix / utf-8 / euc-jp
;;; Commentary:

;;; Code:
(modify-coding-system-alist 'file ".*\\'" 'utf-8-unix) ;; default

;;(modify-coding-system-alist 'file "\\.html\\'" 'utf-8-unix)
;;(modify-coding-system-alist 'file "\\.htm\\'"  'shift_jis)
;;(modify-coding-system-alist 'file "\\.\\(pl\\|cgi\\|pm\\|t\\)\\(\\.~BASE~\\|:magit-ediff\\*\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(php\\|mdl\\|inc\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8) ;; 'utf-8-unix
(modify-coding-system-alist 'file "\\.\\(rb\\|erb\\|yml\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\ChangeLog\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(md\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(org\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(txt\\|log\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.ctp\\(\\.~BASE~\\|\\)\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.\\(html?\\|slim\\|haml\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.\\(css?\\|sass\\|scss\\|less\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.\\(js\\|jsx\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)
(modify-coding-system-alist 'file "\\.\\(lock\\)\\(\\.~BASE~\\|\\)\\'" 'utf-8-unix)

;;; 80-encodings.el ends here

;;; modes

;;; Cask
(add-to-list 'auto-mode-alist '("Cask\\'" . emacs-lisp-mode))
(setq auto-mode-alist (cons '("\\.\\(text\\|md\\|mdt\\)\\'" . markdown-mode) auto-mode-alist))

;;; Textile mode
;; http://www.emacswiki.org/emacs/TextileMode
;; http://dev.nozav.org/textile-mode.html
;; http://www.textism.com/tools/textile/
;; http://hobix.com/textile/
(add-to-list 'auto-mode-alist '("\\.textile\\'" . textile-mode))

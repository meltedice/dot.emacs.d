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

;;; Coffee mode
(defun coffee-custom ()
  "coffee-mode-hook"
  (and (set (make-local-variable 'tab-width) 2)
       (set (make-local-variable 'coffee-tab-width) 2))
  )
(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))

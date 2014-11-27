;;; modes

(add-to-list 'auto-mode-alist '("Cask\\'" . emacs-lisp-mode))
(setq auto-mode-alist (cons '("\\.\\(text\\|md\\|mdt\\)\\'" . markdown-mode) auto-mode-alist))

;;; modes

;;; Cask
(add-to-list 'auto-mode-alist '("Cask\\'" . emacs-lisp-mode))

;;; Text
(setq auto-mode-alist (cons '("\\.\\(text\\|md\\|mdt\\)\\'" . markdown-mode) auto-mode-alist))
(autoload 'apib-mode "apib-mode" "Major mode for editing API Blueprint files" t)
(add-to-list 'auto-mode-alist '("\\.apib\\'" . apib-mode))

;;; Textile mode
;; http://www.emacswiki.org/emacs/TextileMode
;; http://dev.nozav.org/textile-mode.html
;; http://www.textism.com/tools/textile/
;; http://hobix.com/textile/
(add-to-list 'auto-mode-alist '("\\.textile\\'" . textile-mode))

;;; Shell-script mode
;; Ref: https://keramida.wordpress.com/2008/08/08/tweaking-shell-script-indentation-in-gnu-emacs/
(defun sh-mode-custom ()
  (setq sh-basic-offset 2
        sh-indentation 2))
(add-hook 'sh-mode-hook 'sh-mode-custom)

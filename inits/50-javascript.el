;;; modes

;;; Coffee mode
(defun coffee-custom ()
  "coffee-mode-hook"
  (and (set (make-local-variable 'tab-width) 2)
       (set (make-local-variable 'coffee-tab-width) 2))
  )
(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))

;;; JavaScript
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-jsx-mode))

;;; JSX mode
;; (add-to-list 'auto-mode-alist '("\\.jsx\\'" . jsx-mode))
;; (autoload 'jsx-mode "jsx-mode" "JSX mode" t)
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))

(add-hook 'js2-mode-hook 'flycheck-mode)
(add-hook 'js2-jsx-mode-hook 'flycheck-mode)

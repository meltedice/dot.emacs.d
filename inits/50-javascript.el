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
;; TODO: http://codewinds.com/blog/2015-04-02-emacs-flycheck-eslint-jsx.html

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-jsx-mode))

;;; JSX mode
;; (add-to-list 'auto-mode-alist '("\\.jsx\\'" . jsx-mode))
;; (autoload 'jsx-mode "jsx-mode" "JSX mode" t)
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))

(require 'flycheck)
(flycheck-add-mode 'javascript-eslint 'js2-jsx-mode)
(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-disabled-checkers '(javascript-jshint javascript-jscs))
    ))

(add-hook 'js2-mode-hook 'flycheck-mode)
(add-hook 'js2-jsx-mode-hook 'flycheck-mode)

(add-hook 'js2-mode-hook
          #'(lambda ()
              (setq js2-basic-offset 2
                    indent-tabs-mode nil)
              ))

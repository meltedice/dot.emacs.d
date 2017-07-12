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
;;; npm install -g eslint babel-eslint eslint-plugin-react
;;; cd ~/
;;; wget https://raw.githubusercontent.com/yannickcr/eslint-plugin-react/master/.eslintrc

;;; js2/js2-jsx mode
;; https://github.com/mooz/js2-mode/issues/292#issuecomment-155541237
(defun js2-mode-custom ()
   (setq js2-mode-show-parse-errors nil)     ;; disable js2-mode syntax check
   (setq js2-mode-show-strict-warnings nil)  ;; disable js2-mode syntax check
   (setq js-switch-indent-offset 2)          ;; indent offset for `case`
   )
(add-hook 'js2-mode-hook 'js2-mode-custom)
(add-hook 'js2-jsx-mode-hook 'js2-mode-custom)
;; (autoload 'jsx-mode "jsx-mode" "JSX mode" t)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-jsx-mode))
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

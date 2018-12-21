;;; javscript-related-modes --- javascript related modes settings

;; Author: ice <meltedise@gmail.com>
;; Created:
;; Version:
;; Package-Requires:
;;; Commentary:

;;; Code:

;;; Coffee mode
(defun coffee-custom ()
  "coffee-mode-hook"
  (and (set (make-local-variable 'tab-width) 2)
       (set (make-local-variable 'coffee-tab-width) 2))
  )
(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))

;; FIXME: ruby-mode-hook breaks rjsx-mode and js2-mode behavior after type `{`
;; Work around is following:
;; M-: (remove-hook 'post-self-insert-hook 'electric-layout-post-self-insert-function)

;;; JavaScript
;; TODO: http://codewinds.com/blog/2015-04-02-emacs-flycheck-eslint-jsx.html
;;; npm install -g eslint babel-eslint eslint-plugin-react
;;; cd ~/
;;; wget https://raw.githubusercontent.com/yannickcr/eslint-plugin-react/master/.eslintrc

;;; js2/js2-jsx mode
;; https://github.com/mooz/js2-mode/issues/292#issuecomment-155541237
(defun js2-mode-custom ()
  (setq indent-tabs-mode nil)
  (setq js2-basic-offset 2)
  (setq js2-mode-show-parse-errors nil)     ;; disable js2-mode syntax check
  (setq js2-mode-show-strict-warnings nil)  ;; disable js2-mode syntax check
  (setq js-switch-indent-offset 2)          ;; indent offset for `case`
  (electric-pair-mode t)
  )
(add-hook 'js2-mode-hook 'js2-mode-custom)
(add-hook 'js2-jsx-mode-hook 'js2-mode-custom)
;; ;; (autoload 'jsx-mode "jsx-mode" "JSX mode" t)
;; (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-jsx-mode))
;; (add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))

;;; rjsx-mode
;; https://github.com/felipeochoa/rjsx-mode
;; https://joppot.info/2017/04/07/3734
(add-to-list 'auto-mode-alist '(".*\\.\\(js\\|flow\\)\\'" . rjsx-mode))
;; (add-to-list 'auto-mode-alist '("components\\/.*\\.js\\'" . rjsx-mode))
;; (add-to-list 'auto-mode-alist '("containers\\/.*\\.js\\'" . rjsx-mode))
(defun rjsx-mode-custom ()
  (setq indent-tabs-mode nil)
  (setq js-indent-level 2)
  (setq js2-strict-missing-semi-warning nil)
  (setq js2-mode-show-parse-errors nil)     ;; disable js2-mode syntax check
  (setq js2-mode-show-strict-warnings nil)  ;; disable js2-mode syntax check
  (setq js-switch-indent-offset 2)          ;; indent offset for `case`
  (electric-pair-mode t)
  ;; https://emacs.stackexchange.com/questions/33536/how-to-edit-jsx-react-files-in-emacs
  (defadvice js-jsx-indent-line (after js-jsx-indent-line-after-hack activate)
    "Workaround sgml-mode and follow airbnb component style."
    (save-excursion
      (beginning-of-line)
      (if (looking-at-p "^ +\/?> *$")
          (delete-char sgml-basic-offset))))
  )
(add-hook 'rjsx-mode-hook 'rjsx-mode-custom)

;; flowtype: https://github.com/an-sh/flow-minor-mode
(add-hook 'js2-mode-hook 'flow-minor-enable-automatically)
;; (add-hook 'js2-mode-hook 'flow-minor-mode)

;; TypeScript: https://github.com/ananthakumaran/typescript.el
;; https://www.emacswiki.org/emacs/TypeScript
(add-to-list 'auto-mode-alist '("\\.\\(ts\\|tsx\\)\\'" . typescript-mode))
;; TODO: tss.el
;; TODO: tide

;;; flycheck
(require 'flycheck)
;; (flycheck-add-mode 'javascript-eslint 'js2-jsx-mode)
(flycheck-add-mode 'javascript-eslint 'rjsx-mode)
(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-disabled-checkers '(javascript-jshint javascript-jscs))
    ))

;; (add-hook 'js2-mode-hook 'flycheck-mode)
;; (add-hook 'js2-jsx-mode-hook 'flycheck-mode)
(add-hook 'rjsx-mode-hook 'flycheck-mode)

(require 'flycheck-flow)
;; (with-eval-after-load 'flycheck
;;   (flycheck-add-mode 'javascript-flow 'flow-minor-mode)
;;   (flycheck-add-mode 'javascript-eslint 'flow-minor-mode)
;;   (flycheck-add-next-checker 'javascript-flow 'javascript-eslint))
;;
;; FIXME: Doesn't work...
;; (flycheck-add-mode 'javascript-flow 'flow-minor-mode)
;; (flycheck-add-mode 'javascript-eslint 'flow-minor-mode)
;; (flycheck-add-next-checker 'javascript-flow 'javascript-eslint)
(flycheck-add-mode 'javascript-flow 'rjsx-mode)
(flycheck-add-mode 'javascript-eslint 'rjsx-mode)
(flycheck-add-next-checker 'javascript-flow 'javascript-eslint)

(defun flycheck-javascript-flow-auto-disable ()
  "Workaround: Disable javacript-flow if not flow-minor-mode"
  (require 'flow-minor-mode)
  (if (and (flow-minor-configured-p)
             (flow-minor-tag-present-p))
      (flycheck-disable-checker 'javascript-flow t) ;; enable
      (flycheck-disable-checker 'javascript-flow))) ;; disable

;; (add-hook 'js2-mode-hook 'flycheck-javascript-flow-auto-disable)
(add-hook 'rjsx-mode-hook 'flycheck-javascript-flow-auto-disable)

;;; M-x flycheck-verify-setup

(require 'prettier-js)
;; (setq prettier-js-command "eslint") ;; "prettier"
;; (setq prettier-js-args '("--fix")) ;; '()
(setq prettier-js-command "prettier-eslint") ;; "prettier"
;; (add-hook 'js2-mode-hook 'prettier-js-mode)
;; (add-hook 'web-mode-hook 'prettier-js-mode)
(add-hook 'rjsx-mode-hook 'prettier-js-mode)

;;; 50-javascript.el ends here

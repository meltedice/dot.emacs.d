;;; Web mode

;; See: http://umi-uyura.hatenablog.com/entry/2015/05/13/214629

(add-to-list 'auto-mode-alist '("\\.ctp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;; (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.js\\'"  . web-mode))

(defun web-mode-custom ()
  "Customize Web mode."
  (setq web-mode-attr-indent-offset nil)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-sql-indent-offset 2)
  (setq indent-tabs-mode nil)
  (setq tab-width 2)
  (setq web-mode-engines-alist
        '(("php" . "\\.ctp\\'"))
        )
  )
(add-hook 'web-mode-hook 'web-mode-custom)

;; ;; npm install -g jsxhint
;; (require 'flycheck)
;; (flycheck-define-checker jsxhint-checker
;;   "A JSX syntax and style checker based on JSXHint."
;;   :command ("jsxhint" source)
;;   :error-patterns
;;   ((error line-start (1+ nonl) ": line " line ", col " column ", " (message) line-end))
;;   :modes (web-mode))
;; (add-hook 'web-mode-hook
;;           (lambda ()
;;             ;; (when (equal web-mode-content-type "jsx")
;;             (when (or (equal web-mode-content-type "jsx") (equal web-mode-content-type "javascript"))
;;               ;; enable flycheck
;;               (flycheck-select-checker 'jsxhint-checker)
;;               (flycheck-mode))))

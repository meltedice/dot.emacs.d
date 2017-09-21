;;; flymake


(add-hook 'after-init-hook #'global-flycheck-mode)


;; (custom-set-faces
;;  '(flymake-errline ((((class color)) (:underline "red"))))
;;  '(flymake-warnline ((((class color)) (:underline "yellow")))))

(setq flymake-no-changes-timeout 5)
(setq flymake-start-syntax-check-on-newline nil)

(setq flycheck-checker-error-threshold 1000) ; default 400
(setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)) ; default '(save idle-change new-line mode-enabled)
(setq flycheck-idle-change-delay 5) ; default 0.5


(add-hook 'flymake-mode-hook
          '(lambda ()
             ;; (setq flymake-gui-warnings-enabled nil)
             ;; (require 'flymake-cursor)
             ;; (require 'rfringe)
             ))

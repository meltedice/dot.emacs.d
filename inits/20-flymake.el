;;; flymake


(add-hook 'after-init-hook #'global-flycheck-mode)


;; (custom-set-faces
;;  '(flymake-errline ((((class color)) (:underline "red"))))
;;  '(flymake-warnline ((((class color)) (:underline "yellow")))))


(setq flycheck-checker-error-threshold 1000) ; default 400


(add-hook 'flymake-mode-hook
          '(lambda ()
             ;; (setq flymake-gui-warnings-enabled nil)
             ;; (require 'flymake-cursor)
             ;; (require 'rfringe)
             ))

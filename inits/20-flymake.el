;;; flymake --- flymake and flycheck settings

;; Author: ice <meltedise@gmail.com>
;; Created:
;; Version:
;; Package-Requires:
;;; Commentary:

;;; Code:

(add-hook 'after-init-hook #'global-flycheck-mode)

;; (custom-set-faces
;;  '(flymake-errline ((((class color)) (:underline "red"))))
;;  '(flymake-warnline ((((class color)) (:underline "yellow")))))

(add-hook 'flymake-mode-hook
          '(lambda ()
             ;; (setq flymake-gui-warnings-enabled nil)
             ;; (require 'flymake-cursor)
             ;; (require 'rfringe)
             (setq flymake-no-changes-timeout 5)
             (setq flymake-start-syntax-check-on-newline nil)

             (setq flycheck-checker-error-threshold 1000) ; default 400
             ;; default '(save idle-change new-line mode-enabled)
             (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled))
             (setq flycheck-idle-change-delay 5) ; default 0.5
             ))

;;; 20-flymake.el ends here

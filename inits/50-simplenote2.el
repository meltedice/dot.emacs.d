;;; simplenote2 --- simplenote2 settings

;; Author: ice <meltedise@gmail.com>
;; Created:
;; Version:
;; Package-Requires:
;;; Commentary:

;; https://github.com/alpha22jp/simplenote2.el

;; Add following line into ~/.authinfo
;; machine app.simplenote.com login my^email-address-here password my-password-here

;;; Code:

(if (locate-library "simplenote2")
    (progn
      (require 'simplenote2)
      (require 'netrc)
      (let* ((credentials (netrc-credentials "app.simplenote.com"))
             (login (nth 0 credentials))
             (password (nth 1 credentials)))
        (setq simplenote2-email login)
        (setq simplenote2-password password))
      (simplenote2-setup)
      (setq simplenote2-notes-mode 'markdown-mode)
      ))

;;; 50-simplenote2.el ends here

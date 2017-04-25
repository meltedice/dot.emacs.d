;;; simplenote2
;; https://github.com/alpha22jp/simplenote2.el

;; Add following line into ~/.authinfo
;; machine app.simplenote.com login my^email-address-here password my-password-here

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

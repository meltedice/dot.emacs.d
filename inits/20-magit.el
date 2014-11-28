;;; magit

(autoload 'ediff-magit-ediff-working-tree "magit-ediff" nil t)
(autoload 'ediff-magit-ediff              "magit-ediff" nil t)
(add-hook 'magit-mode-hook '(lambda ()
                              (load "magit-ediff")
                              (define-key magit-mode-map (kbd "\C-cd") 'magit-ediff-working-tree)
                              (define-key magit-mode-map (kbd "\C-cD") 'magit-ediff)
                              ))

;; (global-set-key "\C-ce" 'ediff-magit-ediff-working-tree)
;; (global-set-key "\C-cE" 'ediff-magit-ediff)
;; (global-set-key "\C-xE" 'ediff-magit-ediff-working-tree)

;;; magit

(autoload 'ediff-magit-ediff-working-tree "ediff-magit-ediff" nil t)
(autoload 'ediff-magit-ediff              "ediff-magit-ediff" nil t)
(add-hook 'magit-mode-hook '(lambda ()
                              (load "ediff-magit-ediff")
                              (define-key magit-mode-map (kbd "\C-cd") 'magit-ediff-working-tree)
                              (define-key magit-mode-map (kbd "\C-cD") 'magit-ediff)
                              ))

;; (global-set-key "\C-ce" 'ediff-magit-ediff-working-tree)
;; (global-set-key "\C-cE" 'ediff-magit-ediff)
;; (global-set-key "\C-xE" 'ediff-magit-ediff-working-tree)

;;; magit

;; (autoload 'ediff-magit-ediff-working-tree "ediff-magit-ediff" nil t)
;; (autoload 'ediff-magit-ediff              "ediff-magit-ediff" nil t)
;; (add-hook 'magit-mode-hook
;;           '(lambda ()
;;              (load "ediff-magit-ediff")
;;              (define-key magit-mode-map (kbd "\C-cd") 'magit-ediff-working-tree)
;;              (define-key magit-mode-map (kbd "\C-cD") 'magit-ediff)
;;              ;; To avoid `'.../index.lock': File exists.`
;;              (remove-hook 'find-file-hooks 'vc-find-file-hook)
;;              (remove-hook 'find-file-hooks 'vc-refresh-state)
;;              ;; magit/lisp/git-commit.el
;;              (setq git-commit-setup-hook
;;                    '(git-commit-save-message
;;                      git-commit-setup-changelog-support
;;                      git-commit-turn-on-auto-fill
;;                      git-commit-propertize-diff)
;;                    )
;;              ))

;; (eval-after-load "dired"
;;           '(lambda ()
;;              (remove-hook 'find-file-hooks 'vc-find-file-hook)
;;              (remove-hook 'find-file-hooks 'vc-refresh-state)
;;              ))

;; (global-set-key "\C-ce" 'ediff-magit-ediff-working-tree)
;; (global-set-key "\C-cE" 'ediff-magit-ediff)
;; (global-set-key "\C-xE" 'ediff-magit-ediff-working-tree)

;;; Autosave

(setq auto-save-list-file-prefix (expand-file-name (concat dot-emacs-dir ".autosave/")))

;; Backup file
(setq make-backup-files t)
(setq backup-directory-alist
      (cons (cons "\\.*$" (expand-file-name (concat dot-emacs-dir ".backup")))
            backup-directory-alist))

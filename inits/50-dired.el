;;; dired


;;; dired-x
(add-hook 'dired-load-hook
          (function (lambda ()
                      (load "dired-x"))))


;;; ignore files
;; default: "^\\.?#\\|^\\.$\\|^\\.\\.$"
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\.git$\\|^\\.svn$\\|^CVS$"))
(add-hook 'dired-mode-hook
          (lambda ()
            (setq dired-omit-files-p t)))


;;; dired-ediff

;; http://www.emacswiki.org/emacs/DavidBoon
(defun dired-ediff-marked-files ()
  "Run ediff on marked ediff files."
  (interactive)
  (set 'marked-files (dired-get-marked-files))
  (when (= (safe-length marked-files) 2)
    (ediff-files (nth 0 marked-files) (nth 1 marked-files)))

  (when (= (safe-length marked-files) 3)
    (ediff3 (buffer-file-name (nth 0 marked-files))
            (buffer-file-name (nth 1 marked-files))
            (buffer-file-name (nth 2 marked-files)))))
;;(define-key dired-mode-map "E"    'dired-ediff-marked-files)

(defun elscreen-dired-ediff-marked-files ()
  "Run ediff on marked ediff files with elscreen."
  (interactive)
  (set 'marked-files (dired-get-marked-files))

  (let ((screen (elscreen-create-internal)))
    (if screen
        (elscreen-goto screen)))

  (when (= (safe-length marked-files) 2)
    (ediff-files (nth 0 marked-files) (nth 1 marked-files)))

  (when (= (safe-length marked-files) 3)
    (ediff3 (buffer-file-name (nth 0 marked-files))
            (buffer-file-name (nth 1 marked-files))
            (buffer-file-name (nth 2 marked-files)))))
(define-key dired-mode-map "E"    'elscreen-dired-ediff-marked-files)

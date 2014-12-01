;;; *scratch*

;;; *scratch*バッファを C-x C-sで保存時には*scratch*バッファを作成してくれる
;; C-x k で kill すると，*scratch*バッファの内容をすべて消してくれる
(defun my-make-scratch (&optional arg)
  (interactive)
  (progn
    ;; "*scratch*" を作成して buffer-list に放り込む
    (set-buffer (get-buffer-create "*scratch*"))
    (funcall initial-major-mode)
    (erase-buffer)
    (when (and initial-scratch-message (not inhibit-startup-message))
      (insert initial-scratch-message))
    (or arg (progn (setq arg 0)
                   (switch-to-buffer "*scratch*")))
    (cond ((= arg 0) (message "*scratch* is cleared up."))
          ((= arg 1) (message "another *scratch* is created")))))

(defun my-buffer-name-list ()
  (mapcar (function buffer-name) (buffer-list)))

;;; *scratch* バッファで kill-buffer したら内容を消去するだけにする
(add-hook 'kill-buffer-query-functions
          (function (lambda ()
                      (if (string= "*scratch*" (buffer-name))
                          (progn (my-make-scratch 0) nil)
                        t))))

;;; *scratch* バッファの内容を保存したら *scratch* バッファを新しく作る
(add-hook 'after-save-hook
          (function (lambda ()
                      (unless (member "*scratch*" (my-buffer-name-list))
                        (my-make-scratch 1)))))


;;; *scratch* の内容を autosave する
;; http://www.bookshelf.jp/soft/meadow_29.html

;; Dropbox ディレクトリーが存在すればそちらに保存
(defvar scratch-dirname
  (if (file-directory-p "~/Dropbox/Emacs")
      "~/Dropbox/Emacs"
    (if (file-directory-p "~/Dropbox/Share/Emacs")
        "~/Dropbox/Share/Emacs"
      "~/.emacs.d")))

(defvar scratch-filename
  (concat scratch-dirname "/.scratch"
          (if hostname-short
              (concat "-" (downcase hostname-short))
            ""))
  "Filename to save *scratch* buffer when closing emacs.")

(defvar scratch-save-buffer-option 'default
  "Save *scratch* buffer option
'force-save       : force save
'force-donot-save : force do not save
'default          : if *scratch* is modified save *scratch* buffer, else do not save.")

(defun scratch-donot-save-buffer ()
  "Force to do not save *scratch* buffer."
  (interactive)
  (setq scratch-save-buffer-option 'force-donot-save))

(defun scratch-save-buffer-p ()
  "Return t to save, nil not to save."
  (cond ((eq scratch-save-buffer-option 'force-save)       t)
        ((eq scratch-save-buffer-option 'force-donot-save) nil)
        (t (with-current-buffer "*scratch*" (buffer-modified-p)))
        ))

(defun scratch-save-buffer ()
  "Save *scratch* buffer into file."
  (interactive)
  (let ((str (progn
               (set-buffer (get-buffer "*scratch*"))
               (buffer-substring-no-properties (point-min) (point-max))))
        (buf))
    (if (get-file-buffer (expand-file-name scratch-filename))
        (setq buf (get-file-buffer (expand-file-name scratch-filename)))
      (setq buf (find-file-noselect scratch-filename)))
    (set-buffer buf)
    (erase-buffer)
    (insert str)
    (save-buffer)
    (set-buffer-modified-p nil)))

(defadvice save-buffers-kill-emacs
  (before save-scratch-buffer activate)
  (when (scratch-save-buffer-p)
    (scratch-save-buffer)))

(defun scratch-load ()
  "Load *scratch* from a file."
  (interactive)
  (when (file-exists-p scratch-filename)
    (set-buffer (get-buffer "*scratch*"))
    (erase-buffer)
    (insert-file-contents scratch-filename)
    (set-buffer-modified-p nil)
    (message "loaded *scratch* from %s" scratch-filename)))

(defalias 'scratch-reload 'scratch-load)

(scratch-load)


;;; *scratch* で C-x C-s したときに scratch-save-buffer で保存するように
(defun save-buffer-wrapper-for-scratch ()
  (interactive)
  (if (string= (buffer-name) "*scratch*")
      (scratch-save-buffer)
    (save-buffer)))

(add-hook 'lisp-interaction-mode-hook
          (lambda ()
            (local-set-key "\C-x\C-s" 'save-buffer-wrapper-for-scratch))
            )

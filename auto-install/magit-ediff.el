;; -*- Mode: Emacs-Lisp -*-
;;
;; magit-ediff.el 
;;
(defconst magit-ediff-version "0.0.1 (May 16, 2010)")
;;
;; Author:   ice <meltedise@gmail.com>
;; Created:  Oct 2, 2009
;; Revised:  May 16, 2010

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; ediff for magit
;; almost just copy & paste of psvn.el 

(require 'magit)

(defun magit-section-info-canon-name (info)
  "info : (magit-section-info (magit-current-section))"
  (if (listp info)
      (cadr info)
    info))

(defun magit-file-get-other-version (git-name)
  (let* ((buf (get-buffer-create (concat "*" git-name ":magit-ediff*"))))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
	(erase-buffer)
	(unless (= (call-process "git" nil buf nil "show" git-name)
		   0)
          (error "Failed git show %s" git-name))
        (when t
          (set-buffer-modified-p nil)
          (setq buffer-read-only t)
          )))
    buf))

;; http://www.kernel.org/pub/software/scm/git/docs/git-rev-parse.html
;; A colon, optionally followed by a stage number (0 to 3) and a colon, followed by a path; this names a blob object in the index at the given path.
;; Missing stage number (and the colon that follows it) names a stage 0 entry.
;; During a merge, stage 1 is the common ancestor, stage 2 is the target branch's version (typically the current branch), and stage 3 is the version from the branch being merged. 
(defun magit-ediff (rev)
  (interactive (list (magit-read-rev "EDiff")))
  (let* ((section (magit-current-section))
         (info (magit-section-info section))
         (type (magit-section-type section))
         (canon-name (magit-section-info-canon-name info))
         (git-name (concat (or rev ":0") ":" canon-name))
         (buf (find-file-noselect canon-name))
         (other-buf (magit-file-get-other-version git-name))
         (ediff-after-quit-destination-buffer (current-buffer))
         ;;(magit-transient-buffers (list buf other-buf))
         (magit-transient-buffers (list other-buf)) ;; do not delete working file buffer
         (startup-hook '(magit-ediff-startup-hook))
         )
    (ediff-buffers other-buf buf startup-hook)
    ))

(defun magit-ediff-working-tree (rev)
  (interactive (list (magit-read-rev "EDiff with (default HEAD)")))
  (magit-ediff (or rev "HEAD")))

(defun magit-ediff-startup-hook ()
  (add-hook 'ediff-after-quit-hook-internal
            `(lambda ()
               (magit-ediff-exit-hook
                ',ediff-after-quit-destination-buffer ',magit-transient-buffers))
            nil 'local))

(defcustom magit-status-ediff-delete-temporary-files nil
  "*Whether to delete temporary ediff files. If set to ask, ask the user"
  :type '(choice (const t)
                 (const nil)
                 (const ask))
  :group 'magit)

(defun magit-ediff-exit-hook (magit-buf tmp-bufs)
  (dolist (tb tmp-bufs)
    (when (and tb (buffer-live-p tb))
      (let* ((win (get-buffer-window tb t)))
        (when (and win (> (count-windows) 1)
                   (delete-window win))))
      (kill-buffer tb)))
  ;; switch back to the *magit* buffer
  (when (and magit-buf (buffer-live-p magit-buf)
             (not (get-buffer-window magit-buf t)))
    (ignore-errors (switch-to-buffer magit-buf))))


;;(defun magit-git-string (fmt &rest args)
;;  (magit-shell (magit-format-git-command fmt args)))

;; Use existing buffer for magit-ediff
(defun ediff-magit-ediff (rev)
  (interactive (list (magit-read-rev "EDiff")))
  (let* ((section (magit-current-section))
         (info (magit-section-info section))
         (type (magit-section-type section))
         (canon-name (magit-section-info-canon-name info))
         (git-name (concat (or rev ":0") ":" canon-name))
         (buf (find-file-noselect canon-name))
         (other-buf (magit-file-get-other-version git-name))
         (ediff-after-quit-destination-buffer (current-buffer))
         ;;(magit-transient-buffers (list buf other-buf))
         (magit-transient-buffers (list other-buf)) ;; do not delete working file buffer
         (startup-hook '(magit-ediff-startup-hook))
         )
    (ediff-buffers other-buf buf startup-hook)
    ))

(defun ediff-magit-ediff-working-tree (rev)
  (interactive (list (magit-read-rev "EDiff with (default HEAD)")))
  (ediff-magit-ediff (or rev "HEAD")))


;;; git-ls-files shows paths from .git directory path

;;; git-ls-files for one file
(defun magit-ls-file (filename)
  (if (file-regular-p filename)
    (let* ((default-directory (magit-get-top-dir (file-name-directory filename))))
      (magit-git-string "ls-files %s" filename))))

;;; git-ls-files for files
(defun magit-ls-files (file-or-dir-name)
  (let* ((default-directory (magit-get-top-dir (file-name-directory file-or-dir-name)))
         (files (magit-git-string "ls-files %s" file-or-dir-name)))
    (if files
        (split-string files))))

;; Use existing buffer for magit-ediff
(defun ediff-magit-ediff (rev)
  (interactive (list (magit-read-rev "EDiff")))
  (let* ((filename (buffer-file-name))
         (git-name (concat (or rev ":0") ":" (magit-ls-file filename)))
         (buf (find-file-noselect filename))
         (other-buf (magit-file-get-other-version git-name))
         (ediff-after-quit-destination-buffer (current-buffer))
         ;;(magit-transient-buffers (list buf other-buf))
         (magit-transient-buffers (list other-buf)) ;; do not delete working file buffer
         (startup-hook '(magit-ediff-startup-hook))
         )
    (ediff-buffers other-buf buf startup-hook)
    ))

(defun ediff-magit-ediff-working-tree (rev)
  (interactive (list (magit-read-rev "EDiff with (default HEAD)")))
  (ediff-magit-ediff (or rev "HEAD")))

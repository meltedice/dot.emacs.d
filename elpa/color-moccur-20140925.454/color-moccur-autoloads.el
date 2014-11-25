;;; color-moccur-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (or (file-name-directory #$) (car load-path)))

;;;### (autoloads nil "color-moccur" "color-moccur.el" (21578 511
;;;;;;  0 0))
;;; Generated autoloads from color-moccur.el

(autoload 'occur-by-moccur "color-moccur" "\
Use this instead of occur.
Argument REGEXP regexp.
Argument ARG whether buffers which is not related to files are searched.

\(fn REGEXP ARG)" t nil)

(autoload 'moccur-grep-find "color-moccur" "\


\(fn DIR INPUTS)" t nil)

(autoload 'dired-do-moccur "color-moccur" "\
Show all lines of all buffers containing a match for REGEXP.
The lines are shown in a buffer named *Moccur*.
It serves as a menu to find any of the occurrences in this buffer.
\\[describe-mode] in that buffer will explain how.

\(fn REGEXP ARG)" t nil)

(autoload 'grep-buffers "color-moccur" "\
*Run `grep` PROGRAM to match EXPRESSION (with optional OPTIONS) on all visited files.

\(fn)" t nil)

(autoload 'search-buffers "color-moccur" "\
*Search string of all buffers.

\(fn REGEXP ARG)" t nil)

(eval-after-load "color-moccur"
  '(progn
     ;; moccur-edit is installed via auto-install
     (require 'moccur-edit)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(git\\|svn\\)/.+" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.rsync_cache/.+" t)
     (add-to-list 'dmoccur-exclusion-mask "/tmp/.+" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(jpg\\|jpeg\\|gif\\|png\\|bmp\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(mp3\\|mp4\\|m4a\\|oga\\|mpeg\\|mpg\\|avi\\|flv\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(xls\\|xlst\\|doc\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(class\\|jar\\|war\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.log$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.sqlite3$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.sqlite3\." t)
     (add-to-list 'dmoccur-exclusion-mask "/assets/html/" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.tree$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.csv$" t)
     (add-to-list 'dmoccur-exclusion-mask "[0-9]+\\.[0-9]+$" t)
     (add-to-list 'dmoccur-exclusion-mask "/build/iphone/" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.ipa$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.json$" t)
     (add-to-list 'dmoccur-exclusion-mask "/build/" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.fseventsd/.*" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.fseventsd" t)
     (add-to-list 'dmoccur-exclusion-mask "/doc/api/.*" t)))
     
;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; color-moccur-autoloads.el ends here

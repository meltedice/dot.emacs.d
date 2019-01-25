;;; macOS
;; migemo

;;; Refs:
;; * http://emacs.rubikitch.com/migemo/
;; * http://nagayasu-shinya.com/emacs-cmigemo-windows/
;; * https://www.kaoriya.net/software/cmigemo/
;; * http://timestalker.hatenablog.com/entry/2018/01/22/111700

;;; Install cmigemo
;; brew install cmigemo

(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
(setq migemo-command "cmigemo")
(setq migemo-options '("-q" "--emacs"))
(setq migemo-user-dictionary nil)
(setq migemo-coding-system 'utf-8)
(setq migemo-regex-dictionary nil)
(load-library "migemo")
(migemo-init)

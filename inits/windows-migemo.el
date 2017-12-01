;;; Windows 10
;; migemo

;;; Refs:
;; * http://emacs.rubikitch.com/migemo/
;; * http://nagayasu-shinya.com/emacs-cmigemo-windows/
;; * https://www.kaoriya.net/software/cmigemo/

;;; Download C/Migemo
;; https://www.kaoriya.net/software/cmigemo/ (64bit)
;; Extract zip file into C:\cmigemo-default-win64
;; `dict` directory should be like this: C:\cmigemo-default-win64\dict
;; Add C:\cmigemo-default-win64 to environment variable PATH

(require 'migemo)
(setq migemo-dictionary "C:/cmigemo-default-win64/dict/cp932/migemo-dict")
;; (setq migemo-dictionary "C:/cmigemo-default-win64/dict/utf-8/migemo-dict")
(setq migemo-command "cmigemo")
(setq migemo-options '("-q" "--emacs" "-i" "\a"))
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)
;; (setq migemo-coding-system 'utf-8-unix)
(setq migemo-coding-system 'cp932-unix)
(load-library "migemo")
(migemo-init)

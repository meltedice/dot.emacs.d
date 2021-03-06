;;; ruby --- ruby-mode settings

;; Author: ice <meltedise@gmail.com>
;; Created:
;; Version:
;; Package-Requires:
;;; Commentary:

;;; Code:

;; FIXME: This breaks rjsx-mode and js2-mode behavior after type `{`
;; Work around is following:
;; M-: (remove-hook 'post-self-insert-hook 'electric-layout-post-self-insert-function)

(defun ruby-mode-custom ()
  ;; http://gongo.hatenablog.com/entry/2016/02/10/092956
  ;; To avoid following flycheck error message
  ;; invalid multibyte char (US-ASCII)
  (setenv "LC_ALL" "ja_JP.UTF-8")
  ;; (setenv "LANG" "ja_JP.UTF-8")

  (require 'ruby-block)
  (ruby-block-mode t)
  (setq ruby-block-highlight-toggle t)

  (ruby-end-mode t)
  (ruby-electric-mode t)
  (setq ruby-electric-expand-delimiters-list nil)

  (abbrev-mode 1)
  ;; (electric-pair-mode t)
  (electric-indent-mode t)
  (electric-layout-mode t)

  (setq comment-style 'indent)

  (setq ruby-insert-encoding-magic-comment nil) ;; Don't insert "# coding: utf-8"
  )
(add-hook 'ruby-mode-hook 'ruby-mode-custom)

;;; 50-ruby.el ends here

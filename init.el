;; -*- coding: utf-8 -*-

;; Emacs package system
;; M-x package-list-packages
(require 'package)
(setq package-user-dir
      (concat (file-name-directory load-file-name) "elpa"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)
;;(require 'melpa)

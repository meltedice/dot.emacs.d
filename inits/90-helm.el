;; -*- coding: utf-8 -*-

;;; helm

(when (require 'helm-config nil t)
  (helm-mode 1)

  ;; disable helm completition
  (custom-set-variables '(helm-ff-auto-update-initial-value nil))
  ;; disable helm on find-file
  (add-to-list 'helm-completing-read-handlers-alist '(find-file . nil))
  )

;; -*- coding: utf-8 -*-

;;; theme
;; (load-theme 'purple-haze t)
;; (load-theme 'adwaita t)
;; (load-theme 'tango-dark t)
;; (load-theme 'matrix t)
(require 'matrix-on-ice-theme)
(load-theme 'matrix-on-ice t)

;;; apply theme to new frame (like: C-x 5 b)
;; http://stackoverflow.com/questions/3035919/cant-apply-color-theme-to-one-frame-in-emacs
(defun apply-color-theme (frame)
  "Apply color theme to a frame based on whether its a 'real'
   window or a console window."
  (select-frame frame)
  (load-theme 'matrix t)
  (load-theme 'matrix-on-ice t)
  )

(add-hook 'after-make-frame-functions 'apply-color-theme)

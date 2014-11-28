;;; History


;;; redo+.el
(when (require 'redo+ nil t)
  (global-set-key (kbd "C-M-/") 'redo)
  (setq undo-no-redo t) ; 過去のundoがredoされないようにする
  (setq undo-limit 600000)
  (setq undo-strong-limit 900000))


;;; undohist
(when (require 'undohist nil t)
  (setq undohist-directory (concat dot-emacs-dir ".undohist"))
  (undohist-initialize))


;;; undo-tree
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))


;;; point-undo
(when (require 'point-undo nil t)
  (define-key global-map [f5] 'point-undo)
  (define-key global-map [f6] 'point-redo))

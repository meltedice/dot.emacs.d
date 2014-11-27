;;; Keybindings

(keyboard-translate ?\C-h ?\C-?) ; (global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-ch" 'help-command)
;; (global-set-key "\C-xh" 'mark-whole-buffer)
(global-set-key "\C-xg" 'goto-line)
(global-set-key "\C-xl" 'linum-mode)
(global-set-key "\C-c+" 'text-scale-increase)
(global-set-key "\C-c-" 'text-scale-decrease)
(global-set-key "\M-o"  'other-window) ;; 'other-window-or-split
(global-set-key "\C-x\C-d" 'delete-region)
(global-set-key "\C-ci"    'indent-region)
(global-set-key "\C-cc"    'comment-region)
(global-set-key "\C-cu"    'uncomment-region)
(global-set-key "\M-o"     'other-window-or-split)
(global-set-key "\M-/"     'redo) ;; Undo C-/  Redo M-/
(global-set-key "\C-a"     'intelli-home-2) ;; based on intelli-home
(global-set-key (kbd "C-M-/") 'redo)
(define-key global-map [f5] 'point-undo)
(define-key global-map [f6] 'point-redo)

;; yank-pop-summary
(define-key "\M-y"    'yank-pop-forward)
(define-key "\C-\M-y" 'yank-pop-backward)

(define-key "\C-x\C-j" 'skk-mode) ;; overwrite dired-x keybind

;;; C-t prefix
(defvar ctl-t-map (make-sparse-keymap)
  "Keymap for C-t prefix key.")
(global-set-key "\C-t" ctl-t-map)
(define-key minibuffer-local-map "\C-t" 'undefined)

(global-set-key "\C-tm"    'moccur-grep-find)
(global-set-key "\C-t\C-m" 'moccur-grep-find)

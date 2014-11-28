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

;; C-, と C-. で buffer をサクサク切り替える
(global-set-key [?\C-,] 'my-grub-buffer)
(global-set-key [?\C-.] 'my-bury-buffer)

;; yank-pop-summary
(global-set-key "\M-y"    'yank-pop-forward)
(global-set-key "\C-\M-y" 'yank-pop-backward)

(global-set-key "\C-x\C-j" 'skk-mode) ;; overwrite dired-x keybind

;; Quote region
(global-set-key "\C-c\"" 'quote-region-by)
(global-set-key "\C-c'"  'quote-region-by)
(global-set-key "\C-c`"  'quote-region-by)
(global-set-key "\C-c/"  'quote-region-by)
(global-set-key "\C-c!"  'quote-region-by)
(global-set-key "\C-c|"  'quote-region-by)
(global-set-key "\C-c%"  'quote-region-by)
(global-set-key "\C-c("  'quote-region-by)
(global-set-key "\C-c{"  'quote-region-by)
(global-set-key "\C-c["  'quote-region-by)
(global-set-key "\C-c<"  'quote-region-by)
(global-set-key "\C-c)"  'quote-region-by)
(global-set-key "\C-c}"  'quote-region-by)
(global-set-key "\C-c]"  'quote-region-by)
(global-set-key "\C-c>"  'quote-region-by)

;; magit + ediff
(global-set-key "\C-cd" 'magit-ediff-working-tree)
(global-set-key "\C-cD" 'magit-ediff)
;; (global-set-key "\C-ce" 'ediff-magit-ediff-working-tree)
;; (global-set-key "\C-cE" 'ediff-magit-ediff)
;; (global-set-key "\C-xE" 'ediff-magit-ediff-working-tree)


;;; C-t prefix
(defvar ctl-t-map (make-sparse-keymap)
  "Keymap for C-t prefix key.")
(global-set-key "\C-t" ctl-t-map)
(define-key minibuffer-local-map "\C-t" 'undefined)

(global-set-key "\C-t\C-t" 'window-toggle-division)
(global-set-key "\C-t\C-s" 'swap-screen)
(global-set-key "\C-tm"    'moccur-grep-find)
(global-set-key "\C-t\C-m" 'moccur-grep-find)

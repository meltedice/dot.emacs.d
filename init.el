;; -*- coding: utf-8 -*-


;;; Stop to load default.el
(setq inhibit-default-init t)

;;; Change colors while loading...
(set-background-color "black")
(set-foreground-color "#7eff00")

;;; Blink cursor
(blink-cursor-mode t)
;;;(blink-cursor-mode nil) ;; Stop blinking (nil or 0))

;;; Beep sound
(setq visible-bell t) ; No sound but blink screen
;; (set-message-beep 'asterisk) ; 'asterisk 'exclamation 'hand 'question 'ok nil

;;; Set buffer name and fine name on title
(setq frame-title-format "%b : %f - emacs")

;;; Hide tool bar
(cond (window-system (tool-bar-mode 0)))

;;; Show date time in mode line : yyyy/mm/dd(aa) hh:mm
(setq display-time-string-forms
      '((let ((system-time-locale "C"))
          (format-time-string "%Y-%m-%d(%a) %R" now)))) ; "%a, %b %d, %R, %Y" "%Y/%m/%d(%a) %R"
(display-time)

;;; Show current function in mode line
(which-function-mode 1)

;; (global-font-lock-mode t)


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


;;; Emacs package system
;; M-x package-list-packages
;; 【Enter ↵】 Describe the package under cursor. (describe-package)
;; 【i】 mark for installation. (package-menu-mark-install)
;; 【u】 unmark. (package-menu-mark-unmark)
;; 【d】 mark for deletion (removal of a installed package). (package-menu-mark-delete)
;; 【x】 for “execute” (start install/uninstall of marked items). (package-menu-execute)
;; 【r】 refresh the list from server. (package-menu-refresh)
(require 'package)
(setq package-user-dir
      (concat (file-name-directory load-file-name) "elpa"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)
;;(require 'melpa)

;; Auto install elisp packages
(mapc
 (lambda (package)
   (or (package-installed-p package)
       (package-install package)))
 '(
   ;; Installed packages here
   ))

;; -*- coding: utf-8 -*-

(setq dot-emacs-dir (file-name-directory load-file-name))

;;; Get path from shell
(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.

This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

;;; load-path
(setq load-path
      (append
       (list
        "/usr/local/share/emacs/site-lisp/"
        ;; (expand-file-name "~/.emacs.d/...")
        ;; (concat dot-emacs-dir "dir-name")
        ) load-path))

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

;;; Enable upcase/downcase region
(put 'upcase-region   'disabled nil)
(put 'downcase-region 'disabled nil)

;;; yes/no -> y/n
(fset 'yes-or-no-p 'y-or-n-p)

;;; delete -> trash
(setq delete-by-moving-to-trash t)


;;; Basic Keybindings
;; Write keybindings into inits/99-keybindings.el
(keyboard-translate ?\C-h ?\C-?) ; (global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-ch" 'help-command)
;; (global-set-key "\C-xh" 'mark-whole-buffer)
(global-set-key "\C-xg" 'goto-line)
(global-set-key "\C-xl" 'linum-mode)
(global-set-key "\C-c+" 'text-scale-increase)
(global-set-key "\C-c-" 'text-scale-decrease)
(global-set-key "\C-x\C-d" 'delete-region)


;;; Emacs package system
;; M-x package-list-packages
;; 【Enter ↵】 Describe the package under cursor. (describe-package)
;; 【i】 mark for installation. (package-menu-mark-install)
;; 【u】 unmark. (package-menu-mark-unmark)
;; 【d】 mark for deletion (removal of a installed package). (package-menu-mark-delete)
;; 【x】 for “execute” (start install/uninstall of marked items). (package-menu-execute)
;; 【r】 refresh the list from server. (package-menu-refresh)
;; (require 'package)
;; (setq package-user-dir (concat dot-emacs-dir "elpa"))
;; (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
;; (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; (package-initialize)
;;(require 'melpa)

;; Auto install elisp packages
;; (mapc
;;  (lambda (package)
;;    (or (package-installed-p package)
;;        (package-install package)))
;;  '(
;;    ;; Installed packages here
;;    ))


;;; Cask
;; brew install cask
(require 'cask) ;; load from /usr/local/share/emacs/site-lisp/
(cask-initialize)


;;; auto-install
(setq auto-install-directory (concat dot-emacs-dir "auto-install"))
(add-to-list 'load-path auto-install-directory)
(require 'auto-install)
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)


;;; Loads ~/.emacs.d/inits/*.el
;;
;; Platform    Subplatform         Prefix          Example
;; Windows                         windows-        windows-fonts.el
;;             Meadow              meadow-         meadow-commands.el
;; Mac OS X    Carbon Emacs        carbon-emacs-   carbon-emacs-applescript.el
;;             Cocoa Emacs         cocoa-emacs-    cocoa-emacs-plist.el
;; GNU/Linux                       linux-          linux-commands.el
;; All         Non-window system   nw-             nw-key.el
;;
(init-loader-load)

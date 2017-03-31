;; -*- coding: utf-8 -*-

;;; Stop to load default.el
(setq inhibit-default-init t)

;;; Hide tool bar
(cond (window-system (tool-bar-mode 0)))

;;; Stop startup screen
(setq inhibit-startup-screen t)

;;; Set path to .emacs.d
(setq dot-emacs-dir (file-name-directory load-file-name))

;;; load-path
(setq load-path
      (append
       (list
        (expand-file-name "~/.cask/")
        "/usr/local/share/emacs/site-lisp/"
        "/usr/local/share/emacs/site-lisp/cask/"
        ;; (expand-file-name "~/.emacs.d/...")
        ;; (concat dot-emacs-dir "dir-name")
        ) load-path))

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

;; Disable region highlight
(setq-default transient-mark-mode nil)

;; Common programming mode configurations
(setq c-basic-offset 4)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(setq indent-tabs-mode nil)
(show-paren-mode 1)
(line-number-mode 1)
(column-number-mode 1)


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

;;; Get path from shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;;; auto-install
(setq auto-install-directory (concat dot-emacs-dir "auto-install"))
(add-to-list 'load-path auto-install-directory)
(require 'auto-install)
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)


;; linum-mode for global
(eval-after-load 'linum
  (progn
    ;; (setq defcustom linum-disable-starred-buffers nil)
    (setq linum-disabled-modes-list
          ;; '(eshell-mode wl-summary-mode compilation-mode org-mode text-mode dired-mode doc-view-mode image-mode)
          '(eshell-mode compilation-mode dired-mode image-mode))
    (setq linum-format "%3d ")))
(require 'linum-off)
(global-linum-mode 1)


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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ag-group-matches nil)
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(init-loader-show-log-after-init (quote error-only))
 '(package-selected-packages (quote (package-build shut-up epl git commander f dash s))))
(init-loader-load (concat dot-emacs-dir "inits/" "platforms/"))
(init-loader-load (concat dot-emacs-dir "inits/"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ediff-current-diff-B ((t (:background "DarkOrchid4"))))
 '(ediff-current-diff-C ((t (:background "DarkOrchid4"))))
 '(ediff-even-diff-A ((t (:background "blue4"))))
 '(ediff-even-diff-B ((t (:background "dark blue"))))
 '(ediff-even-diff-C ((t (:background "dark blue"))))
 '(ediff-odd-diff-A ((t (:background "dark blue"))))
 '(ediff-odd-diff-B ((t (:background "dark blue"))))
 '(ediff-odd-diff-C ((t (:background "dark blue")))))

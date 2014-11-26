;; -*- coding: utf-8 -*-

(setq dot-emacs-dir (file-name-directory load-file-name))

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
(setq package-user-dir (concat dot-emacs-dir "elpa"))
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


;;; get path from shell
(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.

This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)


;;; auto-install
(setq auto-install-directory (concat dot-emacs-dir "auto-install"))
(add-to-list 'load-path auto-install-directory)
(require 'auto-install)
(auto-install-update-emacswiki-package-name t)
(auto-install-compatibility-setup)

;;; auto-installed elisp configurations
(eval-after-load "color-moccur"
  '(progn
     ;; moccur-edit is installed via auto-install
     (require 'moccur-edit)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(git\\|svn\\)/.+" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.rsync_cache/.+" t)
     (add-to-list 'dmoccur-exclusion-mask "/tmp/.+" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(jpg\\|jpeg\\|gif\\|png\\|bmp\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(mp3\\|mp4\\|m4a\\|oga\\|mpeg\\|mpg\\|avi\\|flv\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(xls\\|xlst\\|doc\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.\\(class\\|jar\\|war\\)$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.log$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.sqlite3$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.sqlite3\." t)
     (add-to-list 'dmoccur-exclusion-mask "/assets/html/" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.tree$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.csv$" t)
     (add-to-list 'dmoccur-exclusion-mask "[0-9]+\\.[0-9]+$" t)
     (add-to-list 'dmoccur-exclusion-mask "/build/iphone/" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.ipa$" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.json$" t)
     (add-to-list 'dmoccur-exclusion-mask "/build/" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.fseventsd/.*" t)
     (add-to-list 'dmoccur-exclusion-mask "\\.fseventsd" t)
     (add-to-list 'dmoccur-exclusion-mask "/doc/api/.*" t)))

;;; Cask
;; brew install cask
(require 'cask) ;; load from /usr/local/share/emacs/site-lisp/
(cask-initialize)

;;; Temporarily font configuration for Mac OS X
;; http://d.hatena.ne.jp/kazu-yamamoto/20140625/1403674172
(when (memq window-system '(mac ns))
  (global-set-key [s-mouse-1] 'browse-url-at-mouse)
  (let* ((size 14)
	 (jpfont "Hiragino Maru Gothic ProN")
	 (asciifont "Monaco")
	 (h (* size 10)))
    (set-face-attribute 'default nil :family asciifont :height h)
    (set-fontset-font t 'katakana-jisx0201 jpfont)
    (set-fontset-font t 'japanese-jisx0208 jpfont)
    (set-fontset-font t 'japanese-jisx0212 jpfont)
    (set-fontset-font t 'japanese-jisx0213-1 jpfont)
    (set-fontset-font t 'japanese-jisx0213-2 jpfont)
    (set-fontset-font t '(#x0080 . #x024F) asciifont))
  (setq face-font-rescale-alist
	'(("^-apple-hiragino.*" . 1.2)
	  (".*-Hiragino Maru Gothic ProN-.*" . 1.2)
	  (".*osaka-bold.*" . 1.2)
	  (".*osaka-medium.*" . 1.2)
	  (".*courier-bold-.*-mac-roman" . 1.0)
	  (".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
	  (".*monaco-bold-.*-mac-roman" . 0.9)
	  ("-cdac$" . 1.3)))
  ;; C-x 5 2 Use above configuration with new window.
  (setq frame-inherited-parameters '(font tool-bar-lines)))

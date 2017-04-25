;; -*- coding: utf-8 -*-

;;; Stop to load default.el
(setq inhibit-default-init t)

;;; Hide tool bar
(cond (window-system (tool-bar-mode 0)))

;;; Stop startup screen
(setq inhibit-startup-screen t)

;;; HOME
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;;; Set path to .emacs.d
(setq dot-emacs-dir (file-name-directory load-file-name))

;;; load-path
(setq load-path
      (append
       (list
        ;; (expand-file-name "~/.cask/")
        ;; "/usr/local/share/emacs/site-lisp/"
        ;; "/usr/local/share/emacs/site-lisp/cask/"
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


;;; El-Get
(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

;;; Packages via El-Get
;;(source gnu)
;;(source org)
;;(source melpa)
;;(source marmalade)

(el-get-bundle tarao/el-get-lock)
(el-get-lock)

;;(el-get-bundle cask)
(el-get-bundle dash)
(el-get-bundle epl)
(el-get-bundle f)
(el-get-bundle package-build)
(el-get-bundle s)
(el-get-bundle shut-up)
(el-get-bundle exec-path-from-shell)
(el-get-bundle auto-install)

;; color-moccur.el 2.71 on melpa doesn't work. Points wrong lines. So use 2.73 on bookshelf.
;; (el-get-bundle color-moccur) ; M-x auto-install-from-url http://www.bookshelf.jp/elc/color-moccur.el
(el-get-bundle color-moccur)
;; (el-get-bundle moccur-edit)  ; M-x install-elisp-from-emacswiki moccur-edit.el
(el-get-bundle ag)
(el-get-bundle wgrep)
(el-get-bundle wgrep-ag)
;; (el-get-bundle wgrep-helm)

(el-get-bundle magit)
;; (el-get-bundle git-blame) ;; no-op?
(el-get-bundle gitignore-mode)

(el-get-bundle init-loader)

(el-get-bundle pallet)

(el-get-bundle redo+)
(el-get-bundle undo-tree)
(el-get-bundle undohist)
(el-get-bundle point-undo)

(el-get-bundle key-chord)

(el-get-bundle dired+)
;;(el-get-bundle diredx-grep)
;;(el-get-bundle wdired) ;; already bundled and this el-getted one doesn't work on Windows10
(el-get-bundle dired-sort)
(el-get-bundle bf-mode)
;; https://github.com/Fuco1/dired-hacks
(el-get-bundle dired-hacks-utils)
(el-get-bundle dired-subtree)
(el-get-bundle dired-details)
;; (el-get-bundle dired-filter)
;; (el-get-bundle dired-narrow)
;; (el-get-bundle dired-ranger)
;; (el-get-bundle dired-open)

(el-get-bundle elscreen :type git :url "git@github.com:knu/elscreen.git")
(el-get-bundle linum-off)

(el-get-bundle auto-highlight-symbol)
(el-get-bundle yasnippet)

(el-get-bundle yaml-mode)
(el-get-bundle markdown-mode)
(el-get-bundle textile-mode)

(el-get-bundle php-mode)

(el-get-bundle haml-mode)
(el-get-bundle slim-mode)
(el-get-bundle sass-mode)
(el-get-bundle scss-mode)
(el-get-bundle less-css-mode)
(el-get-bundle rhtml-mode)
(el-get-bundle rspec-mode)
(el-get-bundle web-mode)

;; (el-get-bundle rinari)
(el-get-bundle projectile)
(el-get-bundle projectile-rails)
(el-get-bundle robe)

(el-get-bundle js2-mode)
(el-get-bundle js3-mode)
(el-get-bundle coffee-mode)
(el-get-bundle jsx-mode)

;;; ruby
(el-get-bundle ruby-additional)
(el-get-bundle ruby-block)
(el-get-bundle ruby-electric)
(el-get-bundle ruby-end)
(el-get-bundle ruby-hash-syntax)
(el-get-bundle ruby-interpolation)
(el-get-bundle ruby-refactor)
(el-get-bundle ruby-tools)

;;; flymake
(el-get-bundle flymake)
(el-get-bundle flycheck)
(el-get-bundle flymake-cursor)
(el-get-bundle rfringe)
(el-get-bundle flymake-coffee)
(el-get-bundle flymake-css)
(el-get-bundle flymake-gjshint)
(el-get-bundle flymake-haml)
(el-get-bundle flymake-json)
(el-get-bundle flymake-less)
(el-get-bundle flymake-ruby)
(el-get-bundle flymake-shell)
(el-get-bundle flymake-yaml)

;; ;;; helm
;; (el-get-bundle helm)

(el-get-bundle ido-vertical-mode)
(el-get-bundle ido-ubiquitous)
(el-get-bundle smex)

(el-get-bundle simplenote2)

;;; theme
(el-get-bundle purple-haze-theme)
(el-get-bundle replace-colorthemes :type git :url "git@github.com:emacs-jp/replace-colorthemes.git")

;;; auto-install'ed

;;; M-x auto-install-from-emacswiki grep-edit.el
;; M-x grep
;; M-x lgrep
;; M-x rgrep
;;; M-x auto-install-from-url http://www.bookshelf.jp/elc/color-moccur.el
;;; M-x auto-install-from-emacswiki moccur-edit.el

;;; requirements (Mac OS X)
;; brew install ag

;;; El-Get ---------------------------------------- end


;;; Cask
;; brew install cask
;;(require 'cask) ;; load from /usr/local/share/emacs/site-lisp/
;;(cask-initialize)

;;; Get path from shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;;; auto-install
(setq auto-install-directory (concat dot-emacs-dir "auto-install"))
(add-to-list 'load-path auto-install-directory)
(require 'auto-install)
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
(init-loader-load (concat dot-emacs-dir "inits/" "platforms/"))
(init-loader-load (concat dot-emacs-dir "inits/"))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ag-group-matches nil)
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(init-loader-show-log-after-init (quote error-only))
 '(package-selected-packages (quote (package-build shut-up epl git commander f dash s))))
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

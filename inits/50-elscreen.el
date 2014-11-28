;; -*- coding: utf-8 -*-

;;; elscreen

;;; Hide [X]
(setq elscreen-tab-display-kill-screen nil)
;;; Hide [<->]
(setq elscreen-tab-display-control nil)
;;; Tab nickname
(setq elscreen-buffer-to-nickname-alist
      '(("^dired-mode$" .
         (lambda ()
           (format "Dired(%s)" dired-directory)))
        ("^Info-mode$" .
         (lambda ()
           (format "Info(%s)" (file-name-nondirectory Info-current-file))))
        ("^mew-draft-mode$" .
         (lambda ()
           (format "Mew(%s)" (buffer-name (current-buffer)))))
        ("^mew-" . "Mew")
        ("^irchat-" . "IRChat")
        ("^liece-" . "Liece")
        ("^lookup-" . "Lookup")))
(setq elscreen-mode-to-nickname-alist
      '(("[Ss]hell" . "shell")
        ("compilation" . "compile")
        ("-telnet" . "telnet")
        ("dict" . "OnlineDict")
        ("*WL:Message*" . "Wanderlust")))


;;; Boot elscreen
(elscreen-start)

(elscreen-set-prefix-key "\C-z")
(require 'elscreen-dired)
(require 'elscreen-dnd)
(require 'elscreen-ext)    ;; my custom elisp in auto-install
(require 'elscreen-magit)  ;; my custom elisp in auto-install
(require 'elscreen-moccur) ;; my custom elisp in auto-install


;;; keymaps
(define-key elscreen-map "l"       'elscreen-select-and-goto)
(define-key elscreen-map "g"       'elscreen-select-and-goto)
(define-key elscreen-map "\C-]"    'elscreen-anything)
(define-key elscreen-map "]"       'elscreen-anything)
(define-key elscreen-map "\C-m"    'elscreen-moccur-grep-find)

;;; C-z C-z prefix
(defvar elscreen-another-map (make-sparse-keymap)
  "Keymap for C-z C-z prefix key.")
(global-set-key "\C-z\C-z" elscreen-another-map)
(define-key elscreen-another-map "\C-f"    'elscreen-another-find-file-map)

;;; C-z C-z C-f prefix
(defvar elscreen-another-find-file-map (make-sparse-keymap)
  "Keymap for C-z C-z C-f prefix key.")
(global-set-key "\C-z\C-z\C-f" elscreen-another-find-file-map)
(define-key elscreen-another-find-file-map "0"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "1"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "2"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "3"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "4"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "5"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "6"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "7"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "8"    'elscreen-find-file-on)
(define-key elscreen-another-find-file-map "9"    'elscreen-find-file-on)

;;; C-z C-z b prefix
(defvar elscreen-another-find-buffer-map (make-sparse-keymap)
  "Keymap for C-z C-z b prefix key.")
(global-set-key "\C-z\C-zb" elscreen-another-find-buffer-map)
(global-set-key "\C-z\C-z\C-b" elscreen-another-find-buffer-map)
(define-key elscreen-another-find-buffer-map "0"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "1"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "2"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "3"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "4"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "5"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "6"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "7"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "8"    'elscreen-find-buffer-on)
(define-key elscreen-another-find-buffer-map "9"    'elscreen-find-buffer-on)

;;; C-z C-z M-x prefix
(defvar elscreen-another-m-x-map (make-sparse-keymap)
  "Keymap for C-z C-z M-x prefix key.")
(global-set-key "\C-z\C-z\M-x" elscreen-another-m-x-map)
(define-key elscreen-another-m-x-map "0"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "1"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "2"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "3"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "4"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "5"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "6"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "7"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "8"    'elscreen-execute-extended-command-directly-on)
(define-key elscreen-another-m-x-map "9"    'elscreen-execute-extended-command-directly-on)

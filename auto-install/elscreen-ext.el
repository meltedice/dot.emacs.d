;; -*- Mode: Emacs-Lisp -*-
;;
;; elscreen-ext.el
;;
(defconst elscreen-ext-version "0.1.0 (Mar 15, 2010)")
;;
;; elscreen extentions
;;
;; Author:   ice <meltedise@gmail.com>
;; Created:  March 15, 2010
;; Revised:  March 15, 2010

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

(provide 'elscreen-ext)
(require 'elscreen)

;;; command-symbol に function の symbol を渡して、elscreen 内でコマンドを実行
;; 例:
;; (elscreen-execute-extended-command-directly 'anything)
(defun elscreen-execute-extended-command-directly (command-symbol)
  "execute command-symbol in Elscreen"
  (interactive)
  (let ((target-screen))
    (if (setq target-screen (elscreen-create-internal 'noerror))
        (elscreen-goto target-screen)
      (select-window (split-window)))
    (command-execute command-symbol t)))
;; こっちでもいいっぽい
;; (defun elscreen-execute-extended-command-directly (command-symbol)
;;   "execute command-symbol in Elscreen"
;;   (interactive)
;;   (let ((window-configuration (current-window-configuration))
;; 	(buffer nil))
;;     (command-execute command-symbol t)
;;     (unless (eq major-mode 'magit-mode)
;;       (setq buffer (current-buffer))
;;       (set-window-configuration window-configuration)
;;       (elscreen-find-and-goto-by-buffer buffer t))))

;;; elscreen-create-internal の screen 番号指定版
(defun elscreen-create-internal-on (screen &optional noerror)
  "Create a new screen on specified screen.
If NOERROR is not nil, no message is displayed in mini buffer
when error is occurred."
  (cond
   ((or (< screen 0) (>= screen 10))
    (unless noerror
      (elscreen-message "Screen number is : 0 <= screen <= 10"))
    nil)
   (t
    (elscreen-set-window-configuration        ;; removable? (ice)
     (elscreen-get-current-screen)            ;; removable? (ice)
     (elscreen-current-window-configuration)) ;; removable? (ice)
    (elscreen-set-window-configuration
     screen (elscreen-default-window-configuration))
    (elscreen-append-screen-to-history screen)
    (elscreen-notify-screen-modification 'force)
    (run-hooks 'elscreen-create-hook)
    screen)))

;;; elscreen-create の screen 番号指定版
(defun elscreen-create-on (screen)
  "Create a new screen and switch to it."
  (interactive "NCreate screen number: ")
  (let ((created-screen (elscreen-create-internal-on screen)))
    (if created-screen
        (elscreen-goto created-screen))))
;;; aliases
(defun elscreen-create-on-0 () (interactive) (elscreen-create-on 0))
(defun elscreen-create-on-1 () (interactive) (elscreen-create-on 1))
(defun elscreen-create-on-2 () (interactive) (elscreen-create-on 2))
(defun elscreen-create-on-3 () (interactive) (elscreen-create-on 3))
(defun elscreen-create-on-4 () (interactive) (elscreen-create-on 4))
(defun elscreen-create-on-5 () (interactive) (elscreen-create-on 5))
(defun elscreen-create-on-6 () (interactive) (elscreen-create-on 6))
(defun elscreen-create-on-7 () (interactive) (elscreen-create-on 7))
(defun elscreen-create-on-8 () (interactive) (elscreen-create-on 8))
(defun elscreen-create-on-9 () (interactive) (elscreen-create-on 9))

;;; screen number を読み込む
(defun elscreen-read-screen-number ()
  (read-number "Screen number: " (elscreen-get-current-screen)))

;;; filename を読み込む
(defun elscreen-read-file-name-for ()
  (read-file-name "Find file in the screen: " nil nil))

;;; last-command-event からの数値取得を試みて、ダメなら訪ねる
(defun elscreen-last-command-event-or-read-screen-number ()
  (let ((last-char (string last-command-event)))
    (if (string-match "^[0-9]$" (string last-command-event))
        (string-to-number last-char)
      (elscreen-read-screen-number))))

;;; 指定した screen に find file
(defun elscreen-find-file-on (screen filename)
  "Edit file FILENAME on secified screen.
Switch to a screen visiting file FILENAME,
creating one if none already exists."
  (interactive (list
                (elscreen-last-command-event-or-read-screen-number)
                (elscreen-read-file-name-for)))
  (elscreen-create-on screen)
  (find-file-noselect filename))

(defalias 'elscreen-find-file-on-0 'elscreen-find-file-on)
(defalias 'elscreen-find-file-on-9 'elscreen-find-file-on)

;;; 指定した screen にバッファーを開く / 最後に入力されたキーから screen を取得
(defun elscreen-find-buffer-on (screen &optional buffer create noselect)
  "Go to the specified screen that has the window with buffer BUFFER."
  (interactive (list (elscreen-last-command-event-or-read-screen-number)))
  (let* ((prompt "Go to the screen with specified buffer: ")
         (create (or create (interactive-p)))
         (buffer-name (or (and (bufferp buffer) (buffer-name buffer))
                          (and (stringp buffer) buffer)
                          (and (featurep 'iswitchb)
                               (iswitchb-read-buffer prompt))
                          (read-buffer prompt)))
         (buffer (get-buffer-create buffer-name)))
    (elscreen-create-on screen)
    (switch-to-buffer buffer t)
    screen))
(defalias 'elscreen-find-buffer-on-0 'elscreen-find-buffer-on)
(defalias 'elscreen-find-buffer-on-9 'elscreen-find-buffer-on)

;;; M-x 用コマンド名を読み込む
(defun elscreen-completing-read ()
  (interactive "P")
  (let ((prefix-key (key-description elscreen-prefix-key)))
    (intern
     (completing-read
      ;; Note: this has the hard-wired
      ;;  "C-u" and "M-x" string bug in common
      ;;  with all Emacs's.
      ;; (i.e. it prints C-u and M-x regardless of
      ;; whether some other keys were actually bound
      ;; to `execute-extended-command' and
      ;; `universal-argument'.
      (cond ((eq prefix-arg '-)
             (format "- %s M-x " prefix-key))
            ((equal prefix-arg '(4))
             (format "C-u %s M-x " prefix-key))
            ((integerp prefix-arg)
             (format "%d %s M-x "
                     prefix-arg prefix-key))
            ((and (consp prefix-arg)
                  (integerp (car prefix-arg)))
             (format "%d %s M-x "
                     (car prefix-arg) prefix-key))
            (t
             (format "%s M-x " prefix-key)))
      obarray 'commandp t nil
      (static-if elscreen-on-xemacs
          'read-command-history
        'extended-command-history)))))

;;; command-symbol に function の symbol を渡して、elscreen 内でコマンドを実行
;; FIXME 動くけど、画面がちらついたり何か様子が変
(defun elscreen-execute-extended-command-directly-on (screen command-symbol)
  "execute command-symbol in Elscreen"
  (interactive (list
                (elscreen-last-command-event-or-read-screen-number)
                (elscreen-completing-read)))
  (elscreen-create-on screen)
  (command-execute command-symbol t)
  screen)


;; ;;; C-z C-z prefix
;; (defvar elscreen-another-map (make-sparse-keymap)
;;   "Keymap for C-z C-z prefix key.")
;; (global-set-key "\C-z\C-z" elscreen-another-map)
;; (define-key elscreen-another-map "\C-f"    'elscreen-another-find-file-map)

;; ;;; C-z C-z C-f prefix
;; (defvar elscreen-another-find-file-map (make-sparse-keymap)
;;   "Keymap for C-z C-z C-f prefix key.")
;; (global-set-key "\C-z\C-z\C-f" elscreen-another-find-file-map)
;; (define-key elscreen-another-find-file-map "0"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "1"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "2"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "3"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "4"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "5"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "6"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "7"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "8"    'elscreen-find-file-on)
;; (define-key elscreen-another-find-file-map "9"    'elscreen-find-file-on)

;; ;;; C-z C-z b prefix
;; (defvar elscreen-another-find-buffer-map (make-sparse-keymap)
;;   "Keymap for C-z C-z b prefix key.")
;; (global-set-key "\C-z\C-zb" elscreen-another-find-buffer-map)
;; (global-set-key "\C-z\C-z\C-b" elscreen-another-find-buffer-map)
;; (define-key elscreen-another-find-buffer-map "0"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "1"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "2"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "3"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "4"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "5"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "6"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "7"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "8"    'elscreen-find-buffer-on)
;; (define-key elscreen-another-find-buffer-map "9"    'elscreen-find-buffer-on)

;; ;;; C-z C-z M-x prefix
;; (defvar elscreen-another-m-x-map (make-sparse-keymap)
;;   "Keymap for C-z C-z M-x prefix key.")
;; (global-set-key "\C-z\C-z\M-x" elscreen-another-m-x-map)
;; (define-key elscreen-another-m-x-map "0"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "1"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "2"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "3"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "4"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "5"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "6"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "7"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "8"    'elscreen-execute-extended-command-directly-on)
;; (define-key elscreen-another-m-x-map "9"    'elscreen-execute-extended-command-directly-on)

;;; environments --- environment variables helper functions
;; -*- coding: utf-8 -*-

;; Author: ice <meltedise@gmail.com>
;; Created:
;; Version:
;; Package-Requires:
;;; Commentary:

;;; env helper functions

;;; GUI Emacs on Mac OS X
;; "GNU Emacs 23.3.1 (x86_64-apple-darwin, NS apple-appkit-1038.35)
;; of 2011-03-10 on black.porkrind.org"
;;; CUI Emacs on Mac OS X
;; "GNU Emacs 23.3.1 (x86_64-apple-darwin11.2.0)
;;  of 2011-12-18 on tokoyuki.local"

;;; Code:
;;; GUI を使ってる環境なら nil いがいが返るはず
;; (defconst gui-p (string-match "Lucid\\|XEmacs\\|GTK\\+\\|Carbon" (version))
;;   "Non nil if using Emacs with GUI.")
;; (defconst gui-p (cond ((string-match "Lucid\\|XEmacs\\|GTK\\+\\|Carbon" (version)) t)
;;                       ((string-match "apple-appkit" (version)) nil)
;;                       (t nil))
;;   "Non nil if using Emacs with GUI.")
(defconst gui-p window-system
  "Non nil if using Emacs with GUI.")
(defun gui-p ()
  "Non nil if using Emacs with GUI."
  gui-p)
(defun gui? ()
  "Non nil if using Emacs with GUI."
  gui-p)

;;; OS の判別
(defconst win32? (string-match "nt5\\." system-configuration))
(defun win32? () win32?)
(defconst mac?   (string-match "darwin" system-configuration))
(defun mac? () mac?)
(defconst unix?  (not (or win32? mac?)))
(defun unix? () unix?)

;;; hostname には hostname が入る UNIX の hostname コマンドを呼び出してるだけ Win32 は無視
(defvar hostname nil)
(cond (unix?
       (setq hostname
             (with-temp-buffer
               (call-process "hostname" nil t nil)
               (car (split-string (buffer-string) "[\n]+" t)))))
      (mac?
       (setq hostname
             (with-temp-buffer
               (call-process "hostname" nil t nil)
               (car (split-string (buffer-string) "[\n]+" t)))))
        )
(defun hostname ()
  "Return HOSTNAME."
  hostname)

(defvar hostname-short nil)
(setq hostname-short (car (split-string hostname "\\." t)))
(defun hostname-short () hostname-short)

(defconst cat-etc-issue
  (let ((etc-issue "/etc/issue"))
    (if (not (file-exists-p etc-issue))
        ""
      (with-temp-buffer
        (call-process "cat" nil t nil etc-issue)
        (car (split-string (buffer-string) "[\n]+" t))))))
(defun cat-etc-issue () cat-etc-issue)
;; (cat-etc-issue)
;; => "Ubuntu 9.10 \\n \\l"
;; => "CentOS release 5.3 (Final)"

(defun linux-distribution ()
  (car (split-string (cat-etc-issue) "\s" t)))
;; (linux-distribution)
;; => "Ubuntu"
;; => "CentOS"

(defun linux-distribution-version ()
  (cond (ubuntu?
         (cadr (split-string (cat-etc-issue) "\s" t)))
        (centos?
          (caddr (split-string (cat-etc-issue) "\s" t)))
          ))
;; (linux-distribution-version)
;; => "9.10"
;; => "5.3"

(defconst ubuntu?
  (string= (linux-distribution) "Ubuntu"))
(defun ubuntu? () ubuntu?)

(defconst centos?
  (string= (linux-distribution) "CentOS"))
(defun centos? () centos?)


;;; which
;; command-name が見つかれば path を返す
;; command-name が見つからなければ "" を返す
(defun which (command-name)
  "Run *which* command with COMMAND-NAME."
  (car (split-string
        (with-output-to-string
          (with-current-buffer standard-output
            (apply 'call-process "which" nil t nil (list command-name))))
        "\n")))
;;; which?
;; command-name が見つかれば path を返す
;; command-name が見つからなければ nil を返す
(defun which? (command-name)
  "Run *which* command with COMMAND-NAME."
  (let ((result (which command-name)))
    (cond ((string= result "") nil)
          ((string-match (concat ": no " command-name " in \(") result) nil)
          (t result))))

;;; where
;; command-name が見つかれば path を返す
;; command-name が見つからなければ "" を返す
(defun where (command-name)
  "Run *where* command with COMMAND-NAME."
  (car (split-string
        (with-output-to-string
          (with-current-buffer standard-output
            (apply 'call-process "where" nil t nil (list command-name))))
        "\n")))
;;; where?
;; command-name が見つかれば path を返す
;; command-name が見つからなければ nil を返す
(defun where? (command-name)
  "Run *where* command with COMMAND-NAME."
  (let ((result (where command-name)))
    (cond ((string= result "") nil)
          ((string-match (concat command-name " not found") result) nil)
          (t result))))

;;; 00-environments.el ends here

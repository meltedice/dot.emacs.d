;; -*- Mode: Emacs-Lisp -*-
;;
;; elscreen-moccur.el 
;;
(defconst elscreen-anything-version "0.1.0 (Mar 15, 2010)")
;;
;; Author:   ice <meltedise@gmail.com>
;; Created:  Apr 12, 2010
;; Revised:  Apr 12, 2010

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

(provide 'elscreen-moccur)
(require 'elscreen)
(require 'elscreen-ext)

;;; Code:

;;; moccur-grep-find を Elscreen 内で実行
;; elscreen-ext 内の elscreen-execute-extended-command-directly を使用
(defun elscreen-moccur-grep-find ()
  (interactive)
  (elscreen-execute-extended-command-directly 'moccur-grep-find))

;;(define-key elscreen-map "\C-m"       'elscreen-moccur-grep-find)
;;(define-key elscreen-map "m"          'elscreen-moccur-grep-find)

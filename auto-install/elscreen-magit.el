;; -*- Mode: Emacs-Lisp -*-
;;
;; elscreen-magit.el 
;;
(defconst elscreen-magit-version "0.1.0 (Oct 2, 2009)")
;;
;; Author:   ice <meltedise@gmail.com>
;; Created:  Oct 2, 2009
;; Revised:  Oct 2, 2009

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

(provide 'elscreen-magit)
(require 'elscreen)


;;; Code:

(defadvice magit-visit-item (around elscreen-magit-visit-item activate)
  (let ((window-configuration (current-window-configuration))
	(buffer nil))
    ad-do-it
    (unless (eq major-mode 'magit-mode)
      (setq buffer (current-buffer))
      (set-window-configuration window-configuration)
      (elscreen-find-and-goto-by-buffer buffer t))))

;; (defadvice magit-ediff (around elscreen-magit-ediff activate)
;;   (let ((window-configuration (current-window-configuration))
;; 	(buffer nil))
;;     ad-do-it
;;     (unless (eq major-mode 'magit-mode)
;;       (setq buffer (current-buffer))
;;       (set-window-configuration window-configuration)
;;       (elscreen-find-and-goto-by-buffer buffer t))))

;; (defadvice magit-ediff-working-tree (around elscreen-magit-ediff-working-tree activate)
;;   (let ((window-configuration (current-window-configuration))
;; 	(buffer nil))
;;     ad-do-it
;;     (unless (eq major-mode 'magit-mode)
;;       (setq buffer (current-buffer))
;;       (set-window-configuration window-configuration)
;;       (elscreen-find-and-goto-by-buffer buffer t))))

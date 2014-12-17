;;; Mac OS X
;; cocoa-emacs-*: http://emacsformacosx.com/ 24.4

(setq default-file-name-coding-system 'utf-8-unix)

(set-default-coding-systems 'utf-8-unix)


;;; Window size
(setq initial-frame-alist
      (append (list
               ;;'(width . 110)
               '(width . 120)
               '(height . 35)
               )
              initial-frame-alist))
(setq default-frame-alist initial-frame-alist)


;;; Window Color and Alpha
(when (eq window-system 'mac)
 (add-hook 'window-setup-hook
           (lambda ()
             ;; (setq mac-autohide-menubar-on-maximize nil)
             (set-frame-parameter nil 'fullscreen nil)
             ))

 (defun mac-toggle-max-window ()
   (interactive)
   (if (frame-parameter nil 'fullscreen)
     (set-frame-parameter nil 'fullscreen nil)
     (set-frame-parameter nil 'fullscreen 'fullboth))
   ))

(global-set-key "\C-cm" 'mac-toggle-max-window)

(defun mac-toggle-window-alpha ()
 (interactive)
 (if (eq (frame-parameter nil 'alpha) 100)
     (set-frame-parameter nil 'alpha 90)
   (set-frame-parameter nil 'alpha 100)))

(global-set-key "\C-cp" 'mac-toggle-window-alpha)

;;; dired


;;; dired-x
(add-hook 'dired-load-hook
          (function (lambda () (load "dired-x"))))

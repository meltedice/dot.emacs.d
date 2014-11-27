;;; tramp

;; C-x C-f /sudo:hostname:/
;; C-x C-f /ssh:hostname:/

;; (require 'tramp)
(eval-after-load "tramp"
  '(progn
     (add-to-list 'tramp-default-proxies-alist
                  '(nil "\\`root\\'" "/ssh:%h:"))))

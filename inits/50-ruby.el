;;; ruby

(add-hook 'ruby-mode-hook
          (lambda ()
            (require 'ruby-block)
            (ruby-block-mode t)
            (setq ruby-block-highlight-toggle t)

            (ruby-end-mode t)
            ;; (ruby-electric-mode t)

            (abbrev-mode 1)
            (electric-pair-mode t)
            (electric-indent-mode t)
            (electric-layout-mode t)

            (setq comment-style 'indent)
            ))
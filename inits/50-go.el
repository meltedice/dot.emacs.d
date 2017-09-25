;;; golang --- golang settings

;; Author: ice <meltedise@gmail.com>
;; Created:
;; Version:
;; Package-Requires:
;;; Commentary:

;; See: http://emacs-jp.github.io/programming/golang.html
;; See: http://qiita.com/nijojin/items/ff08e81a15fcee802d30

;; % go get -u github.com/nsf/gocode
;; % go get -v github.com/rogpeppe/godef
;; % go get golang.org/x/tools/cmd/goimports

;; C-c C-a go-import-add
;; C-c C-j godef-jump
;; C-c C-d godef-describe

;;; Code:

(with-eval-after-load 'go-mode
  (require 'go-autocomplete)
  (add-hook 'go-mode-hook 'go-eldoc-setup)
  (add-hook 'go-mode-hook
            (lambda ()
              (setq tab-width 4)
              ))
  (add-hook 'before-save-hook 'gofmt-before-save)
  (define-key go-mode-map (kbd "M-.") 'godef-jump)
  (define-key go-mode-map (kbd "M-,") 'pop-tag-mark)
  )

;;; 50-go.el ends here

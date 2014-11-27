;;; ddskk
;; wget http://openlab.ring.gr.jp/skk/maintrunk/ddskk-15.2.tar.gz
;; tar xfz ddskk-15.2.tar.gz
;; cd ddskk-15.2/
;; make what-where EMACS=/usr/local/bin/emacs-24.4
;; make install EMACS=/usr/local/bin/emacs-24.4
;; make clean
;; make what-where EMACS=/Applications/Emacs.app/Contents/MacOS/Emacs
;; make install EMACS=/Applications/Emacs.app/Contents/MacOS/Emacs
(setq skk-user-directory "~/.emacs.d/ddskk/") ; ディレクトリ指定
(when (require 'skk-autoloads nil t)
  ;; C-x C-j で skk モードを起動
  ;; (global-set-key "\C-x\C-j" 'skk-mode)
  (define-key global-map (kbd "C-x C-j") 'skk-mode)
  (global-set-key "\C-xj" 'skk-auto-fill-mode)
  (global-set-key "\C-xt" 'skk-tutorial)

  ;; SKK を起動していなくても、いつでも skk-isearch を使う
  (add-hook 'isearch-mode-hook 'skk-isearch-mode-setup)
  (add-hook 'isearch-mode-end-hook 'skk-isearch-mode-cleanup)

  ;; Org mode のときだけ句読点を変更したい
  (add-hook 'org-mode-hook
            (lambda ()
              (require 'skk)
              (setq skk-kutouten-type 'en)))

  ;; 文章系のバッファを開いた時には自動的に英数モード(「SKK」モード)に入る
  (let ((function #'(lambda ()
                      (require 'skk)
                      (skk-latin-mode-on))))
    (dolist (hook '(find-file-hooks
                    ;; …
                    mail-setup-hook
                    message-setup-hook
                    wl-draft-mode-hook))
      (add-hook hook function)))

  ;; .skk を自動的にバイトコンパイル
  (setq skk-byte-compile-init-file t))

;;; Windows 10
;; windows-*: https://github.com/chuntaro/NTEmacs64

 (set-language-environment "UTF-8")
 (setq default-input-method "W32-IME")
 (setq-default w32-ime-mode-line-state-indicator "[--]")
 (setq w32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
 (w32-ime-initialize)

 (add-hook 'w32-ime-on-hook '(lambda () (set-cursor-color "coral4")))
 ;; (add-hook 'w32-ime-off-hook '(lambda () (set-cursor-color "green")))

 ;; ミニバッファに移動した際は最初に日本語入力が無効な状態にする
 (add-hook 'minibuffer-setup-hook 'deactivate-input-method)

 ;; isearch に移行した際に日本語入力を無効にする
 (add-hook 'isearch-mode-hook '(lambda ()
                                 (deactivate-input-method)
                                 (setq w32-ime-composition-window (minibuffer-window))))
 (add-hook 'isearch-mode-end-hook '(lambda () (setq w32-ime-composition-window nil)))

 ;; helm 使用中に日本語入力を無効にする
 (advice-add 'helm :around '(lambda (orig-fun &rest args)
                              (let ((select-window-functions nil)
                                    (w32-ime-composition-window (minibuffer-window)))
                                (deactivate-input-method)
                                (apply orig-fun args))))

;;; Frame size
(setq initial-frame-alist
      (append (list
               ;;'(width . 110)
               '(width . 170)
               '(height . 45)
               )
              initial-frame-alist))
(setq default-frame-alist initial-frame-alist)

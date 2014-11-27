;;; key-chord

;; 2つのキー同時押しで発動する設定
(when (require 'key-chord nil t)
  (setq key-chord-two-keys-delay 0.1)
  (key-chord-mode 1)
  (key-chord-define-global "jk" 'view-mode))

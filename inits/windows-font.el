;;; Font configuration for Windows 10
;; http://xiuxing.blog.jp/archives/8346924.html

(set-default-font "MeiryoKe_Console 10")
(set-fontset-font (frame-parameter nil 'font)
                  'japanese-jisx0208
                  '("MeiryoKe_Console" . "unicode-bmp")
                  ;; '("Ricty Diminished" . "unicode-bmp")
                  )

(set-fontset-font (frame-parameter nil 'font)
                  'katakana-jisx0201
                  '("MeiryoKe_Console" . "unicode-bmp")
                  ;; '("Ricty Diminished" . "unicode-bmp")
                  )

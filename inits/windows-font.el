;;; Font configuration for Windows 10
;; http://xiuxing.blog.jp/archives/8346924.html

;;; OK
;; (set-default-font "MeiryoKe_Console 10")
;; (set-fontset-font (frame-parameter nil 'font)
;;                   'japanese-jisx0208
;;                   '("MeiryoKe_Console" . "unicode-bmp")
;;                   ;; '("Ricty Diminished" . "unicode-bmp")
;;                   )
;; (set-fontset-font (frame-parameter nil 'font)
;;                   'katakana-jisx0201
;;                   '("MeiryoKe_Console" . "unicode-bmp")
;;                   ;; '("Ricty Diminished" . "unicode-bmp")
;;                   )

;;; NG
;;; http://qiita.com/melito/items/238bdf72237290bc6e42
;; 全角と半角で横幅が合わなくてズレる...
;; (set-face-attribute 'default nil :family "Inconsolata" :height 110)
;; ;; (set-face-attribute 'default nil :family "Consolas" :height 104)
;; (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "MeiryoKe_Console"))
;; (setq face-font-rescale-alist '(("MeiryoKe_Console" . 1.08)))

;;; NG
;; 全角と半角で横幅が合わなくてズレる...
;; (set-face-attribute 'default nil :family "MeiryoKe_Console")
;; (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "MeiryoKe_Console"))
;; (setq face-font-rescale-alist '(("MeiryoKe_Console" . 1.08)))

;;; OK
;; (set-default-font "MeiryoKe_Console 10")
;; (set-fontset-font nil 'japanese-jisx0208 '("MeiryoKe_Console" . "unicode-bmp"))
;; (set-fontset-font nil 'katakana-jisx0201'("MeiryoKe_Console" . "unicode-bmp"))

;;; OK
;; (set-default-font "Ricty Diminished 14")
;; (set-fontset-font nil 'japanese-jisx0208 '("Ricty Diminished" . "unicode-bmp"))
;; (set-fontset-font nil 'katakana-jisx0201 '("Ricty Diminished" . "unicode-bmp"))

;;; OK
(set-default-font "Ricty Discord 14")
(set-fontset-font nil 'japanese-jisx0208 '("Ricty Discord" . "unicode-bmp"))
(set-fontset-font nil 'katakana-jisx0201 '("Ricty Discord" . "unicode-bmp"))

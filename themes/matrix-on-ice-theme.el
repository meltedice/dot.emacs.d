;;; matrix-on-ice-theme.el --- Green-on-black Matrix-flavored theme -*- lexical-binding: t; -*-

;;; Commentary:

;; Local custom theme (Emacs 標準 deftheme、外部パッケージなし)。
;;
;; ── 設計方針: 最小忠実版(A)──
;;
;; 旧 ~/.emacs.d で使われていた auto-install 版の matrix-on-ice-theme.el は
;; `custom-theme-set-faces' で elscreen タブ用の 4 face しか触っていない。
;; ユーザーが「matrix-on-ice の見た目」と認識していた残り(mode-line / link
;; / outline-* / markdown-* / font-lock-*)は実はすべて Emacs 既定値で、
;; テーマ由来ではなかった。
;;
;; よって本ファイルも「default の bg/fg だけ指定して残りは Emacs 既定に
;; 任せる」最小構成で旧の見た目を忠実に再現する。具体的には:
;;   - default :background "black"   (旧 (set-background-color "black") 相当)
;;   - default :foreground "#7eff00" (旧 (set-foreground-color "#7eff00") 相当)
;;
;; 旧では (set-background-color ...) / (set-foreground-color ...) を介して
;; frame パラメータを設定していたが、本実装は default face を介して同じ
;; 視覚効果を出す(theme として disable-theme で綺麗に剥がせる利点)。
;;
;; これにより:
;;   - mode-line          → Emacs 既定の明るいグレー+黒文字+3D ボタン枠
;;   - link / markdown-link-face → Emacs 既定(暗背景下では cyan 系)
;;   - outline-* / markdown-header-* → Emacs 既定(ピンク赤系の太字 等)
;;   - font-lock-*        → Emacs 既定の多彩な配色
;; いずれも旧 Emacs 29.x で見ていた matrix-on-ice の見た目と一致する。
;;
;; Fonts (family / height) はここでは設定しない。M-x my-font-preset と
;; 直交させるため。

;;; Code:

(deftheme matrix-on-ice
  "Minimal black + #7eff00 placeholder, faithful to legacy matrix-on-ice.")

(custom-theme-set-faces
 'matrix-on-ice
 '(default ((t (:background "black" :foreground "#7eff00")))))

(provide-theme 'matrix-on-ice)

;;; matrix-on-ice-theme.el ends here

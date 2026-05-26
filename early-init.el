;;; early-init.el --- Pre-frame initialization -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs 27+ では init.el よりも早く、かつ GUI フレームが生成される前に
;; 読み込まれる。ここで default-frame-alist に配色を仕込んでおくと、
;; 「OS デフォルトの明色フレームが一瞬描画されてからユーザー設定で
;; 上書きされる」フラッシュ(目のチカチカ)を完全に防げる。
;;
;; ここで適用するのは旧 ~/.emacs.d/init.el 冒頭の「起動時の仮配色」
;;   (set-background-color "black")
;;   (set-foreground-color "#7eff00")
;; の現代版。旧設定では init.el 1 行目で set-{background,foreground}-color
;; を呼んでいたが、それでも GUI フレーム生成後の上書きだったためフラッシュ
;; が残っていた。本実装は default-frame-alist 経由なので、最初のフレーム
;; がこの配色で「生まれる」=フラッシュなし。
;;
;; テーマ本体(wheatgrass)は従来どおり init.el で (load-theme ...) する。
;; 起動時の遷移は「仮配色(緑/黒)→ wheatgrass」となり、旧設定と同じ流れ
;; を再現する(目的は OS 既定の明色フレームを描画させないこと)。
;;
;; 注意:
;;   - daemon 起動でも early-init.el は呼ばれる。emacsclient -c で開いた
;;     最初の GUI フレームも default-frame-alist を読むため有効。
;;   - 端末(emacs -nw)では default-frame-alist の background-color は
;;     端末の設定が優先される(本設定は harmless)。

;;; Code:

(push '(background-color . "black")   default-frame-alist)
(push '(foreground-color . "#7eff00") default-frame-alist)

(provide 'early-init)
;;; early-init.el ends here

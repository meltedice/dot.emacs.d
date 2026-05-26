;;; early-init.el --- Pre-frame initialization -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs 27+ では init.el よりも早く、かつ GUI フレームが生成される前に
;; 読み込まれる。最終的に使うテーマ(wheatgrass、Emacs 同梱)をここで
;; 先読みしておくと、フレームがそのテーマの配色で「生まれる」ため、
;; OS デフォルトの明色が一瞬描画されるフラッシュ(目のチカチカ)が
;; 完全に消える。
;;
;; 旧 ~/.emacs.d/init.el 冒頭の
;;   (set-background-color "black")
;;   (set-foreground-color "#7eff00")
;; (起動時の「仮配色」)が達成しようとしていた目的(=明色フラッシュを
;; 抑えてから本テーマを当てる)を、本リビルドでは最終テーマを直接 early
;; に当てることで中間色を挟まずに実現する。旧設定では「仮配色(緑/黒)
;; → matrix-on-ice」の 2 段遷移だったが、本実装では遷移そのものを無くす。
;;
;; wheatgrass は Emacs 同梱のテーマのため、package-initialize より前
;; (= early-init.el の時点)でも load-theme 可能。
;;
;; 注意: early-init.el は Emacs が user-emacs-directory から自動で
;; 読む。本リポジトリを user-emacs-directory として認識させる起動経路
;; (例: emacs --init-directory ~/.emacs.d.30.2-1、Emacs 29+)が前提。
;; この経路を取らない場合 early-init.el は読まれず、フラッシュ防止は
;; 効かない(init.el 側に同じ load-theme をフォールバックで残してある)。

;;; Code:

(load-theme 'wheatgrass t)

(provide 'early-init)
;;; early-init.el ends here

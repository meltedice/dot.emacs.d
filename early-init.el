;;; early-init.el --- Pre-frame initialization -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs 27+ では init.el よりも早く、かつ GUI フレームが生成される前に
;; 読み込まれる。最終的に使うテーマ(matrix-on-ice、本リポジトリ
;; themes/ 配下の自前 deftheme)をここで先読みしておくと、フレームが
;; そのテーマの配色で「生まれる」ため、OS デフォルトの明色が一瞬描画
;; されるフラッシュ(目のチカチカ)が完全に消える。
;;
;; 旧 ~/.emacs.d/init.el 冒頭の
;;   (set-background-color "black")
;;   (set-foreground-color "#7eff00")
;; が達成しようとしていた目的(=明色フラッシュを抑えてから本テーマを
;; 当てる)を、本リビルドでは最終テーマを直接 early に当てることで
;; 中間色を挟まずに実現する。
;;
;; matrix-on-ice は本リポジトリの themes/ 配下にある自前 deftheme
;; (外部パッケージ非依存)。package-initialize より前(= early-init.el
;; の時点)でも、custom-theme-load-path に themes/ を足せば load-theme
;; 可能。
;;
;; 注意: early-init.el は Emacs が user-emacs-directory から自動で読む。
;; 本リポジトリを user-emacs-directory として認識させる起動経路
;; (例: emacs --init-directory ~/.emacs.d.30.2-1、Emacs 29+)が前提。
;; この経路を取らない場合 early-init.el は読まれず、フラッシュ防止は
;; 効かない(init.el 側に同じ load-theme をフォールバックで残してある)。

;;; Code:

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(load-theme 'matrix-on-ice t)

(provide 'early-init)
;;; early-init.el ends here

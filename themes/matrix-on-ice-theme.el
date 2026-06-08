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
;;
;; ── タブの色(tab-bar)──
;;
;; 例外として tab-bar の 3 face だけは指定する(旧 matrix-on-ice-theme.el が
;; elscreen タブ用 face を設定していたのと同じ「テーマがタブ色を持つ」方式)。
;; 配色はユーザーが M-: で試行して決めた値:
;;   tab-bar-tab          → bg black  / fg #7eff00 / bold   (現在=アクティブタブ。
;;                          matrix-on-ice 本体色=黒地に緑字で「点灯」して見える)
;;   tab-bar-tab-inactive → bg Gray50 / fg black   / normal (他=非アクティブタブ)
;;   tab-bar              → bg Gray50 / fg black            (バー地=タブ間・左右)
;; アクティブ(黒地・緑字)と非アクティブ(中灰地・黒字)が明確に見分けられる
;; (matrix-on-ice の黒背景下では既定だと両者が紛らわしかった)。バー地と非
;; アクティブタブを同じ Gray50 にし、アクティブだけをテーマ色で際立たせる構成。

;;; Code:

(deftheme matrix-on-ice
  "Minimal black + #7eff00 placeholder, faithful to legacy matrix-on-ice.")

(custom-theme-set-faces
 'matrix-on-ice
 '(default ((t (:background "black" :foreground "#7eff00"))))
 ;; タブ(ユーザーが M-: で決定した配色。アクティブのみテーマ色で際立たせる)
 '(tab-bar              ((t (:background "Gray50" :foreground "black"))))
 '(tab-bar-tab          ((t (:background "black"  :foreground "#7eff00" :weight bold))))
 '(tab-bar-tab-inactive ((t (:background "Gray50" :foreground "black" :weight normal))))
 ;; ── ediff の差分配色(現代化版 B)──
 ;;
 ;; Emacs 既定の ediff face は明背景前提で、本テーマ(黒地+緑字 #7eff00)では
 ;; current-diff-B(既定 bg #335533)や fine-diff-B(#22aa22)が「緑地に緑字」に
 ;; なり判読不能だった。旧 ~/.emacs.d は current-B/C を紫・even/odd を紺に塗って
 ;; 回避していたが current-A / fine-* は未指定で行内差分の緑on緑が残っていた。
 ;; ここでは緑字とぶつからない色相に統一して再設計する:
 ;;   バッファ A = 青系 / B = 紫系 / C = 琥珀系 / Ancestor(マージ祖先)= 灰系
 ;;   コンテキスト(even/odd)= 暗め控えめ → current(注目ハンク)= 鮮やか
 ;;   fine(行内の実変更)= 最も明るく前景も明示し「変わった文字」を際立たせる
 ;; region 系は既定同様 :extend t(行末まで伸長)、fine は文字単位(:extend なし)。
 ;;
 ;; --- バッファ A(青系)---
 '(ediff-even-diff-A    ((t (:background "#12233f" :extend t))))
 '(ediff-odd-diff-A     ((t (:background "#18345c" :extend t))))
 '(ediff-current-diff-A ((t (:background "#1f4f96" :extend t))))
 '(ediff-fine-diff-A    ((t (:background "#2f74d6" :foreground "white" :weight bold))))
 ;; --- バッファ B(紫系)---
 '(ediff-even-diff-B    ((t (:background "#2a1640" :extend t))))
 '(ediff-odd-diff-B     ((t (:background "#3c2160" :extend t))))
 '(ediff-current-diff-B ((t (:background "#5c2d8c" :extend t))))
 '(ediff-fine-diff-B    ((t (:background "#9040c8" :foreground "white" :weight bold))))
 ;; --- バッファ C(琥珀系。3-way / magit-ediff-stage の worktree 列など)---
 '(ediff-even-diff-C    ((t (:background "#3a2810" :extend t))))
 '(ediff-odd-diff-C     ((t (:background "#54380f" :extend t))))
 '(ediff-current-diff-C ((t (:background "#8a5510" :extend t))))
 '(ediff-fine-diff-C    ((t (:background "#c07a12" :foreground "black" :weight bold))))
 ;; --- Ancestor(灰系。マージ競合解決時の共通祖先バッファ)---
 '(ediff-even-diff-Ancestor    ((t (:background "#242424" :extend t))))
 '(ediff-odd-diff-Ancestor     ((t (:background "#313131" :extend t))))
 '(ediff-current-diff-Ancestor ((t (:background "#4a4a4a" :extend t))))
 '(ediff-fine-diff-Ancestor    ((t (:background "#6f6f6f" :foreground "white" :weight bold)))))

(provide-theme 'matrix-on-ice)

;;; matrix-on-ice-theme.el ends here

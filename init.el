;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; 旧 ~/.emacs.d(init-loader + inits/NN-*.el 構成)からキーバインド設定を
;; 移植したもの。主流の単一 init.el 構成に再編した。
;;
;; 方針:
;;   - 素の Emacs 組み込みコマンドへのバインドはそのまま有効。
;;   - この設定にまだ移植していない elisp(外部パッケージ / 旧 inits の
;;     カスタム関数)に依存するものは、移植した上でコメントアウトしてある。
;;     依存先を各見出し・各行に明記した。該当機能を移植したらコメントを外す。
;;   - linum は Emacs 29 で廃止されたため display-line-numbers-mode に置換。

;;; Code:


;;; ============================================================
;;;  パッケージ管理(package.el + use-package、Emacs 30 同梱)
;;; ============================================================
;; 方針: elpa/ を git 管理して別マシンへ移植・復元する。
;;   - elpa/<pkg>/ のソース(*.el)はコミットする(上流が消えても復元可能)
;;   - *.elc / eln-cache / elpa/archives は再生成物なので .gitignore で除外
;;   - 新マシンは clone するだけ。elpa/ に実体があるためネット不要で起動できる
;;   - 新規パッケージ追加時のみ: M-x package-refresh-contents → 導入
;;   - git からのみ入手のパッケージは use-package :vc(Emacs 30 標準)を使う
;;       例: (use-package foo :vc (:url "https://github.com/user/foo"))

(require 'package)
(setq package-user-dir (locate-user-emacs-file "elpa"))
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t        ; 各 use-package で自動導入
      use-package-expand-minimally t)


;;; ============================================================
;;;  環境変数(GUI/デーモンでシェルの PATH 等を継承)
;;; ============================================================
;; Finder/Dock から起動した GUI Emacs はシェルの PATH を継承しないため、
;; exec-path-from-shell でログインシェルの環境を取り込む。
;; ログイン・非対話(-l のみ)を使う:
;;   - 非対話なので iTerm2 のシェル統合エスケープや fortune が混入しない
;;   - ~/.local/bin(pipx: grip 等)はログイン非対話 zsh で既に PATH 上
(use-package exec-path-from-shell
  :if (or (memq window-system '(mac ns)) (daemonp))
  :init (setq exec-path-from-shell-arguments '("-l"))
  :config (exec-path-from-shell-initialize))


;;; ============================================================
;;;  基本設定(旧 init.el より移植。現在も有効なもの)
;;; ============================================================

;; default.el を読み込まない
(setq inhibit-default-init t)

;; 起動画面を出さない
(setq inhibit-startup-screen t)

;; ツールバー非表示(旧: (cond (window-system (tool-bar-mode 0))))
(tool-bar-mode -1)

;; *eval* などでリストを省略せず全部表示
(setq eval-expression-print-length nil)
(setq eval-expression-print-level nil)

;; カーソル点滅
(blink-cursor-mode 1)

;; ベルは鳴らさず画面フラッシュ
(setq visible-bell t)

;; タイトルバーに buffer 名とファイル名
(setq frame-title-format "%b : %f - emacs")

;; モードライン時刻表示の書式(display-time 自体は未有効)
(setq display-time-string-forms
      '((let ((system-time-locale "C"))
          (format-time-string "%Y-%m-%d(%a) %R" now))))

;; org-mode のタイムスタンプ等を英語表記に
(setq system-time-locale "C")

;; モードラインに現在の関数名
(which-function-mode 1)

;; upcase/downcase-region を有効化(確認ダイアログを出さない)
(put 'upcase-region   'disabled nil)
(put 'downcase-region 'disabled nil)

;; 削除はゴミ箱へ
(setq delete-by-moving-to-trash t)

;; yes/no -> y/n(旧: (fset 'yes-or-no-p 'y-or-n-p) の Emacs 28+ 等価)
(setq use-short-answers t)

;; リージョンをハイライトしない(旧来挙動を明示的に維持)
(setq-default transient-mark-mode nil)

;; プログラミング共通
(setq c-basic-offset 4)
(setq tab-width 4)
(setq-default indent-tabs-mode nil)
(show-paren-mode 1)
(line-number-mode 1)
(column-number-mode 1)

;; 行頭で C-k すると行末までと改行を一度に kill-ring へ
;; (旧 inits/50-edit.el: "C-k at beginning of line, kill whole line including \\n")
(setq kill-whole-line t)

;; 行番号表示: prog-mode のみ
;; (旧 global-linum-mode は linum が Emacs 29 で廃止のため置換)
(setq-default display-line-numbers-width 3) ; 旧 linum-format "%3d " 相当
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;;; テーマ
;; 旧 init.el は起動時プレースホルダ配色
;;   (set-background-color "black") / (set-foreground-color "#7eff00")
;; を置いたあとパッケージ製テーマ matrix-on-ice を適用していた。
;; matrix-on-ice はパッケージのため、Emacs 同梱の暗色テーマで代替する。
;; 同梱テーマで最も Matrix(緑/黒)に近いのは wheatgrass。
(load-theme 'wheatgrass t)
;; 差し替え候補(上行をコメントアウトして下のいずれかを有効化):
;; (load-theme 'modus-vivendi t)  ; モダンで視認性の高い暗色テーマ
;; (load-theme 'wombat t)
;; (load-theme 'tango-dark t)
;; (load-theme 'deeper-blue t)
;; (load-theme 'misterioso t)
;; (load-theme 'manoj-dark t)


;;; ============================================================
;;;  Keybindings: 組み込み(有効)
;;; ============================================================

(keyboard-translate ?\C-h ?\C-?) ; (global-set-key "\C-h" 'delete-backward-char)
(global-set-key "\C-ch" 'help-command)
;; (global-set-key "\C-xh" 'mark-whole-buffer)
(global-set-key "\C-xg" 'goto-line)

;; 旧: (global-set-key "\C-xl" 'linum-mode) ; linum は Emacs 29 で廃止
(global-set-key "\C-xl" 'display-line-numbers-mode)

(global-set-key "\C-c+" 'text-scale-increase)
(global-set-key "\C-c-" 'text-scale-decrease)
(global-set-key "\M-o"  'other-window) ;; 旧: 'other-window-or-split(下記コメント参照)
(global-set-key "\C-x\C-d" 'delete-region)
(global-set-key "\C-ci"    'indent-region)
(global-set-key "\C-cc"    'comment-region)
(global-set-key "\C-cu"    'uncomment-region)

;; org は Emacs 同梱。org-agenda は autoload されるので単体で有効。
(global-set-key (kbd "C-c a") 'org-agenda)

;;; C-t プレフィックス(キーマップ定義自体は組み込みのみ)
(defvar ctl-t-map (make-sparse-keymap)
  "Keymap for C-t prefix key.")
(global-set-key "\C-t" ctl-t-map)
(define-key minibuffer-local-map "\C-t" 'undefined)


;;; ============================================================
;;;  macOS (Cocoa / NS)
;;; ============================================================

(when (eq system-type 'darwin)
  ;; --- NS ポート組み込み設定(有効) ---
  (setq mac-pass-control-to-system nil)
  (setq mac-pass-command-to-system nil)
  (setq mac-pass-option-to-system nil)
  (when (fboundp 'mac-add-ignore-shortcut)
    (mac-add-ignore-shortcut '(control)))

  ;; option <-> command の入れ替え
  (setq ns-command-modifier   'meta)
  (setq ns-alternate-modifier 'super)
  (setq mac-option-modifier   'super) ;; not in use?

  ;; macOS High Sierra 以降: ¥ を \ として扱う
  (define-key global-map [?\¥] [?\\])
  (define-key global-map [?\s-¥] [?\\])
  (define-key global-map [?\C-¥] [?\C-\\])
  (define-key global-map [?\M-¥] [?\M-\\])
  (define-key global-map [?\C-\M-¥] [?\C-\M-\\])

  ;; browse-url-at-mouse は組み込み(有効)
  (when (memq window-system '(mac ns))
    (global-set-key [s-mouse-1] 'browse-url-at-mouse))

  ;; --- フレーム/ウィンドウ(旧 inits/cocoa-emacs-config.el より復元) ---
  ;; 初期フレームサイズ(GUI 時のみ、旧: width 120 / height 35)
  (when (display-graphic-p)
    (push '(width  . 120) default-frame-alist)
    (push '(height . 35)  default-frame-alist))

  ;; 最大化トグル: 旧 mac-toggle-max-window 相当。Window(Frame) を画面に
  ;; 合わせる挙動(maximized)= メニューバー/Dock を残してフレームを作業
  ;; 領域いっぱいに最大化。macOS ネイティブフルスクリーン(別 Space)や
  ;; fullboth は不採用(ユーザー希望)。
  (defun mac-toggle-max-window ()
    "Toggle the selected frame between maximized and normal size."
    (interactive)
    (if (frame-parameter nil 'fullscreen)
        (set-frame-parameter nil 'fullscreen nil)
      (set-frame-parameter nil 'fullscreen 'maximized)))
  (global-set-key (kbd "C-c m") 'mac-toggle-max-window)

  ;; 透明度トグル: 組み込み代替が無いため旧 mac-toggle-window-alpha を
  ;; 忠実移植(外部パッケージ非依存・alpha 100⇔90)。
  (defun mac-toggle-window-alpha ()
    "Toggle the selected frame's alpha between 100 and 90."
    (interactive)
    (if (eq (frame-parameter nil 'alpha) 100)
        (set-frame-parameter nil 'alpha 90)
      (set-frame-parameter nil 'alpha 100)))
  (global-set-key (kbd "C-c p") 'mac-toggle-window-alpha)
  )

;;; macOS 連携メモ(旧 cocoa-emacs-keybindings.el より。設定ではなく覚書)
;;
;; Karabiner:
;;   - Semicolon -> Return(修飾なし時) / Control+Semicolon -> Semicolon
;;   - EISUU -> Control_L / KANA -> Control_L
;;   - Underscore(Ro) -> Backslash(¥)
;;
;; iTerm2(emacs -nw 用。Terminal.app は command=meta が扱いづらい):
;;   - Left/Right option key: Normal -> +Esc
;;   - Cmd+f/b/d を Esc+f / Esc+b / Esc+d の Escape Sequence に
;;   - Scrollback Buffer: Unlimited scrollback


;;; ============================================================
;;;  フォント(比較用プリセット切替: M-x my-font-preset)
;;; ============================================================
;; 旧 inits/cocoa-emacs-font.el の復元検討。どれを常用するか目視で
;; 決められるよう、4 プリセットを M-x my-font-preset で即時切替できる。
;; 起動時は my-font-default-preset(現在 "stock-modern")を GUI 時に
;; 自動適用する。他プリセットは引き続き M-x で随時比較可能。
;; 旧 init.el の (setq use-default-font-for-symbols nil)(↓ 等の記号を
;; fontset 側=全角で出す)は全プリセット共通で維持。
(setq use-default-font-for-symbols nil)

(defvar my-font-height 140
  "default フェイスの :height(140 = 14pt、旧設定踏襲)。")

(defun my-font--clear-jp-fontset ()
  "前プリセットが設定した日本語/Latin fontset 上書きを解除する。"
  (dolist (s '(katakana-jisx0201 japanese-jisx0208 japanese-jisx0212
               japanese-jisx0213-1 japanese-jisx0213-2))
    (set-fontset-font t s nil))
  (set-fontset-font t '(#x80 . #x24F) nil))

(defun my-font--faithful-old ()
  "旧設定を忠実復元: Monaco + Hiragino Maru ProN + rescale(レガシ含む)。"
  (my-font--clear-jp-fontset)
  (set-face-attribute 'default nil :family "Monaco" :height my-font-height)
  (dolist (s '(katakana-jisx0201 japanese-jisx0208 japanese-jisx0212
               japanese-jisx0213-1 japanese-jisx0213-2))
    (set-fontset-font t s "Hiragino Maru Gothic ProN"))
  (set-fontset-font t '(#x80 . #x24F) "Monaco")
  (setq face-font-rescale-alist
        '(("^-apple-hiragino.*" . 1.2)
          (".*-Hiragino Maru Gothic ProN-.*" . 1.2)
          (".*osaka-bold.*" . 1.2)
          (".*osaka-medium.*" . 1.2)
          (".*courier-bold-.*-mac-roman" . 1.0)
          (".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
          (".*monaco-bold-.*-mac-roman" . 0.9)
          ("-cdac$" . 1.3))))

(defun my-font--stock-modern ()
  "ストック現代化: Menlo + Hiragino Kaku ProN + 最小 rescale。"
  (my-font--clear-jp-fontset)
  (set-face-attribute 'default nil :family "Menlo" :height my-font-height)
  (dolist (s '(katakana-jisx0201 japanese-jisx0208
               japanese-jisx0213-1 japanese-jisx0213-2))
    (set-fontset-font t s "Hiragino Kaku Gothic ProN"))
  (setq face-font-rescale-alist '((".*Hiragino.*" . 1.2))))

(defun my-font--udev-gothic ()
  "CJK 同梱 1 本: UDEV Gothic(要 brew install --cask font-udev-gothic)。"
  (my-font--clear-jp-fontset)
  (setq face-font-rescale-alist nil)
  (set-face-attribute 'default nil :family "UDEV Gothic" :height my-font-height))

(defun my-font--plemol-jp ()
  "CJK 同梱 1 本: PlemolJP(要 brew install --cask font-plemol-jp)。"
  (my-font--clear-jp-fontset)
  (setq face-font-rescale-alist nil)
  (set-face-attribute 'default nil :family "PlemolJP" :height my-font-height))

(defconst my-font-presets
  '(("faithful-old" . my-font--faithful-old)
    ("stock-modern" . my-font--stock-modern)
    ("udev-gothic"  . my-font--udev-gothic)
    ("plemol-jp"    . my-font--plemol-jp))
  "プリセット名 → 適用関数。")

(defun my-font-preset (name)
  "フォントプリセット NAME を即時適用(目視比較用)。
未インストールフォントは既定にフォールバックする点に注意。"
  (interactive
   (list (completing-read "Font preset: "
                          (mapcar #'car my-font-presets) nil t)))
  (funcall (cdr (assoc name my-font-presets)))
  (message "Font preset: %s → 実フォント family=%s height=%s"
           name (face-attribute 'default :family) (face-attribute 'default :height)))

(defvar my-font-default-preset "stock-modern"
  "起動時に GUI フレームへ自動適用するプリセット名。
M-x my-font-preset で随時切替可能(これは既定値のみ)。")

(defun my-font-apply-default (&optional frame)
  "FRAME(なければ選択フレーム)が GUI なら既定プリセットを適用。"
  (when (display-graphic-p frame)
    (with-selected-frame (or frame (selected-frame))
      (my-font-preset my-font-default-preset))))

;; 通常起動は即適用。daemon/emacsclient は最初の GUI フレーム生成時に適用。
(if (daemonp)
    (add-hook 'after-make-frame-functions #'my-font-apply-default)
  (my-font-apply-default))

;;; ============================================================
;;;  タブ(旧 elscreen の代替: 組み込み tab-bar-mode)
;;; ============================================================
;; elscreen は未メンテで新しい Emacs で動作しないため、Emacs 27+ 同梱の
;; tab-bar-mode に置換。各タブ = ウィンドウ構成(作業セット)で elscreen
;; と同じモデル。操作は旧 elscreen の C-z プレフィックスを踏襲しつつ、
;; 標準の C-x t 系も併用可。

(tab-bar-mode 1)
(tab-bar-history-mode 1)               ; タブ単位のレイアウト undo/redo
(setq tab-bar-show 1                   ; タブ1個でも常に表示
      tab-bar-new-tab-choice "*scratch*"
      tab-bar-tab-hints t              ; タブに番号を表示
      tab-bar-close-button-show nil)
;; 新規タブ「+」ボタンを出さない
;; (旧 tab-bar-new-button-show は Emacs 28.1 で廃止 → tab-bar-format で制御)
(setq tab-bar-format '(tab-bar-format-history
                       tab-bar-format-tabs
                       tab-bar-separator))

;; 旧 elscreen 風 C-z プレフィックス(標準は suspend-frame だが踏襲)
(defvar elscreen-like-tab-map (make-sparse-keymap)
  "elscreen 風タブ操作プレフィックス (C-z)。")
(global-set-key (kbd "C-z") elscreen-like-tab-map)
(define-key elscreen-like-tab-map (kbd "c")   #'tab-new)        ; 新規
(define-key elscreen-like-tab-map (kbd "C-c") #'tab-new)
(define-key elscreen-like-tab-map (kbd "k")   #'tab-close)      ; 閉じる
(define-key elscreen-like-tab-map (kbd "C-k") #'tab-close)
(define-key elscreen-like-tab-map (kbd "n")   #'tab-next)       ; 次へ
(define-key elscreen-like-tab-map (kbd "C-n") #'tab-next)
(define-key elscreen-like-tab-map (kbd "p")   #'tab-previous)   ; 前へ
(define-key elscreen-like-tab-map (kbd "C-p") #'tab-previous)
(define-key elscreen-like-tab-map (kbd "C-z") #'tab-recent)     ; 直前タブへ
(define-key elscreen-like-tab-map (kbd "a")   #'tab-recent)
(define-key elscreen-like-tab-map (kbd "'")   #'tab-bar-switch-to-tab) ; 名前で選択
(define-key elscreen-like-tab-map (kbd "r")   #'tab-rename)     ; 改名
(define-key elscreen-like-tab-map (kbd "b")   #'tab-bar-history-back)
(define-key elscreen-like-tab-map (kbd "f")   #'tab-bar-history-forward)
;; C-z 1..9 で番号のタブへ
(dotimes (i 9)
  (define-key elscreen-like-tab-map (kbd (number-to-string (1+ i)))
    (let ((n (1+ i)))
      (lambda () (interactive) (tab-bar-select-tab n)))))


;;; ============================================================
;;;  メジャーモード(use-package で移植)
;;; ============================================================

;;; Markdown
(use-package markdown-mode
  :mode (("\\.md\\'"             . markdown-mode)
         ("\\.markdown\\'"       . markdown-mode)
         ("\\.\\(text\\|mdt\\)\\'" . markdown-mode)
         ("README\\.md\\'"       . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t))

;; 目次生成: M-x markdown-toc-generate-toc
(use-package markdown-toc
  :after markdown-mode)

;; grip-mode: GitHub と同じ見た目で Markdown をライブプレビュー。
;;
;; 【外部コマンド grip のインストール】
;;   Homebrew の Python は PEP 668(外部管理)のため `pip install grip` /
;;   `pip3 install grip` は拒否される。CLI ツールなので pipx を使う:
;;       pipx install grip          ; -> ~/.local/bin/grip(隔離 venv)
;;   ※ `pip` という名前のコマンドは無い。pipx も無ければ `brew install pipx`。
;;   ※ GUI Emacs で PATH を通すため上の exec-path-from-shell が必要
;;     (~/.local/bin はログインシェルの PATH 上)。
;;   更新: pipx upgrade grip / 削除: pipx uninstall grip
;;
;; 【使い方】
;;   - Markdown バッファで C-c C-c g    : grip-mode を ON/OFF
;;     (markdown-mode-command-map の "g"。素の grip-mode コマンドでも可)
;;   - ON にするとローカルに描画サーバが立ち、ブラウザで GitHub 風表示。
;;     バッファ保存に追従して自動更新される。
;;   - 認証なしだと GitHub API のレート制限あり。多用するなら
;;     ~/.authinfo 等でトークンを設定(grip-github-user/grip-github-password)。
(use-package grip-mode
  :after markdown-mode
  :bind (:map markdown-mode-command-map
              ("g" . grip-mode)))


;;; ============================================================
;;;  Git / 差分(magit, ediff)
;;; ============================================================

;; ediff(組み込み・旧 inits/50-ediff.el より移植)
;;   - 上下分割ではなく左右分割
;;   - control を別フレームにせず単一フレーム内に表示(plain)
;; 旧 DavidBoon cleanup スニペット(ウィンドウ構成をレジスタ ?b に退避し
;; 終了時に復元 + ediff-cleanup-mess 除去ハック)は移植しない:
;; Emacs 30 の ediff は終了時にウィンドウ構成を自前で復元するため不要
;; (現代簡易版を採用、ユーザー確認済み)。
(use-package ediff
  :ensure nil                           ; 組み込み
  :custom
  (ediff-split-window-function #'split-window-horizontally)
  (ediff-window-setup-function #'ediff-setup-windows-plain))

;; magit(Git クライアント)
;;   旧 inits/20-magit.el は全行コメントアウトで実働設定なし。当時の
;;   自作 ediff-magit-ediff(auto-install)依存と .git/index.lock 回避
;;   ハックは、現代 magit 組み込みの magit-ediff に置き換わり不要。
;;   キー割当(ユーザー確認済み):
;;     - C-x g→goto-line(既存・移植済み)はそのまま維持
;;     - magit-status は C-c g(C-c <英字> はユーザー予約領域で衝突最小)
;;     - 旧 CLAUDE.md キーバインド表の C-c d / C-c D → magit-ediff も
;;       現代コマンド(working-tree / dwim)で移植
(use-package magit
  :bind (("C-c g" . magit-status)
         ("C-c d" . magit-ediff-show-working-tree)
         ("C-c D" . magit-ediff-dwim)))


;;; ============================================================
;;;  未移植: カスタム関数依存
;;;  (旧 inits/50-window.el, 50-edit.el, 50-edit-helper.el,
;;;   50-view-mode.el を移植したらコメントを外す)
;;; ============================================================

;; --- 50-window.el: ウィンドウ操作 ---
;; (global-set-key "\M-o"     'other-window-or-split)
;; (global-set-key [C-tab]    'other-window-or-split)
;; (global-set-key [f2]       'swap-screen)
;; (global-set-key [S-f2]     'swap-screen-with-cursor)
;; (global-set-key "\C-x\C-^" 'toggle-enlarge-window-auto-direction)
;; (global-set-key "\C-^"     'enlarge-window-auto)
;; (global-set-key "\C-t\C-t" 'window-toggle-division)
;; (global-set-key "\C-t\C-s" 'swap-screen)
;; C-, と C-. で buffer をサクサク切り替える
;; (global-set-key [?\C-,] 'my-grub-buffer)
;; (global-set-key [?\C-.] 'my-bury-buffer)

;; --- 50-edit.el ---
;; (global-set-key "\C-a" 'intelli-home-2) ;; based on intelli-home
;; (global-set-key "\C-w" 'kill-region-or-backward-kill-word)
;; (define-key minibuffer-local-completion-map "\C-w" 'kill-region-or-backward-kill-word)

;; --- 50-edit-helper.el: Quote region (quote-region-by) ---
;; (global-set-key "\C-c\"" 'quote-region-by)
;; (global-set-key "\C-c'"  'quote-region-by)
;; (global-set-key "\C-c`"  'quote-region-by)
;; (global-set-key "\C-c/"  'quote-region-by)
;; (global-set-key "\C-c!"  'quote-region-by)
;; (global-set-key "\C-c|"  'quote-region-by)
;; (global-set-key "\C-c%"  'quote-region-by)
;; (global-set-key "\C-c("  'quote-region-by)
;; (global-set-key "\C-c{"  'quote-region-by)
;; (global-set-key "\C-c["  'quote-region-by)
;; (global-set-key "\C-c<"  'quote-region-by)
;; (global-set-key "\C-c)"  'quote-region-by)
;; (global-set-key "\C-c}"  'quote-region-by)
;; (global-set-key "\C-c]"  'quote-region-by)
;; (global-set-key "\C-c>"  'quote-region-by)

;; --- 50-view-mode.el: view-mode の pager 風キーマップ ---
;; define-many-keys / pager-keybind / view-mode-hook0 はカスタム定義。
;; (add-hook 'view-mode-hook 'view-mode-hook0)
;; (define-key view-mode-map " " 'scroll-up)


;;; ============================================================
;;;  未移植: 外部パッケージ依存
;;;  (該当パッケージを導入したらコメントを外す)
;;; ============================================================

;; --- redo+(Emacs 28+ は組み込み undo-redo も検討可)---
;; (global-set-key "\M-/"      'redo) ;; Undo C-/  Redo M-/
;; (global-set-key (kbd "C-M-/") 'redo)

;; --- point-undo ---
;; (define-key global-map [f5] 'point-undo)
;; (define-key global-map [f6] 'point-redo)

;; --- yank-pop-summary(旧 auto-install)---
;; (global-set-key "\M-y"    'yank-pop-forward)
;; (global-set-key "\C-\M-y" 'yank-pop-backward)

;; --- ddskk ---
;; (global-set-key "\C-x\C-j" 'skk-mode) ;; overwrite dired-x keybind

;; --- magit / ediff ---
;; (global-set-key "\C-cd" 'magit-ediff-working-tree)
;; (global-set-key "\C-cD" 'magit-ediff)
;; (global-set-key "\C-ce" 'ediff-magit-ediff-working-tree)
;; (global-set-key "\C-cE" 'ediff-magit-ediff)
;; (global-set-key "\C-xE" 'ediff-magit-ediff-working-tree)

;; --- color-moccur ---
;; (global-set-key "\C-tm"    'moccur-grep-find)
;; (global-set-key "\C-t\C-m" 'moccur-grep-find)

;; --- undo-tree ---
;; (define-key undo-tree-map (kbd "\C-_") 'undefined)

;; --- key-chord(2つのキー同時押し)---
;; (when (require 'key-chord nil t)
;;   (setq key-chord-two-keys-delay 0.1)
;;   (key-chord-mode 1)
;;   (key-chord-define-global "jk" 'view-mode))

;; --- elscreen(廃止気味。参考)---
;; (global-set-key "\C-z\C-m" 'elscreen-moccur-grep-find)
;; (global-set-key "\C-zm"    'elscreen-moccur-grep-find)

;; --- helm(旧設定では無効化済み。参考)---
;; (global-set-key "\M-x"     'helm-M-x)
;; (global-set-key "\C-x\C-f" 'helm-find-files)
;; (define-key helm-read-file-map  (kbd "C-w") 'kill-region-or-backward-kill-word)
;; (define-key helm-c-read-file-map (kbd "TAB") 'helm-execute-persistent-action)


;;; ============================================================
;;;  未移植: モジュール別キーマップ
;;;  (各メジャーモード/パッケージを移植したらコメントを外す。
;;;   その際は with-eval-after-load でマップ確定後に束ねるのが主流)
;;; ============================================================

;; --- dired 関連(旧 50-dired.el)---
;;   r            : wdired-change-to-wdired-mode            (組み込み wdired)
;;   E            : elscreen-dired-ediff-marked-files       (elscreen)
;;   i / <tab>    : dired-subtree-insert / -remove          (dired-subtree)
;;   C-x n n / ^  : dired-subtree-narrow / -up-dwim         (dired-subtree)
;;   s S a A      : direx-grep:*                            (direx-grep)
;;   K            : direx-k                                 (dired-k)
;;   C-x C-j      : direx-project:jump-to-project-root-other-window (direx)
;; (with-eval-after-load 'dired
;;   (define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)
;;   (define-key dired-mode-map "E" 'elscreen-dired-ediff-marked-files)
;;   (define-key dired-mode-map (kbd "i") 'dired-subtree-insert)
;;   (define-key dired-mode-map (kbd "<tab>") 'dired-subtree-remove)
;;   (define-key dired-mode-map (kbd "C-x n n") 'dired-subtree-narrow)
;;   (define-key dired-mode-map (kbd "^") 'dired-subtree-up-dwim))
;; (with-eval-after-load 'direx
;;   (define-key direx:direx-mode-map (kbd "s") 'direx-grep:grep-item)
;;   (define-key direx:direx-mode-map (kbd "S") 'direx-grep:grep-item-from-root)
;;   (define-key direx:direx-mode-map (kbd "a") 'direx-grep:show-all-item-at-point)
;;   (define-key direx:direx-mode-map (kbd "A") 'direx-grep:show-all-item)
;;   (define-key direx:direx-mode-map (kbd "K") 'direx-k))
;; (global-set-key "\C-x\C-j" 'direx-project:jump-to-project-root-other-window)

;; --- go-mode(旧 50-go.el)---
;; (with-eval-after-load 'go-mode
;;   (define-key go-mode-map (kbd "M-.") 'godef-jump)
;;   (define-key go-mode-map (kbd "M-,") 'pop-tag-mark))


(provide 'init)
;;; init.el ends here

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
;;;  バッファ操作(旧 inits/50-window.el の一部)
;;; ============================================================
;; 高速バッファ切替 C-, / C-.。
;; 旧 my-grub-buffer / my-bury-buffer は自作再帰 my-visible-buffer +
;; 手書き無視リストで「特殊バッファを飛ばして次のバッファへ」を実現して
;; いた。現在の Emacs はこの用途専用の組み込み next-buffer /
;; previous-buffer を持ち、スキップ対象も変数で指定できる(実機検証で
;; 旧挙動を再現できることを確認)。よって自作関数は移植せず組み込みへ。
;;
;;   - スペース始まりの内部バッファは next/previous-buffer が自動でスキップ
;;     (旧 my-visible-buffer の (aref bufn 0) 判定が不要に)。
;;   - 名前で飛ばしたい特殊バッファは switch-to-prev-buffer-skip-regexp に
;;     完全一致アンカー付き正規表現で列挙(next/previous 双方に効く)。
;;     旧 my-ignore-buffer-list 相当。廃れた Mew 用 "*Mew completions*"
;;     は除外。*scratch* / *Messages* は旧リストにも無く巡回対象のまま。
;;   - 順序はウィンドウ単位の履歴(各ウィンドウが前後を自前で記憶)。
;;     旧のグローバル (buffer-list) 順とは異なるが、現代の標準挙動。
;; 注意: C-, / C-. は端末(emacs -nw)では送出できない環境がある
;;       (旧設定も同じキー・同条件)。
(setq switch-to-prev-buffer-skip-regexp
      '("\\`\\*Help\\*\\'"
        "\\`\\*Compile-Log\\*\\'"
        "\\`\\*Completions\\*\\'"
        "\\`\\*Shell Command Output\\*\\'"
        "\\`\\*Apropos\\*\\'"
        "\\`\\*Buffer List\\*\\'"))
(global-set-key (kbd "C-,") #'previous-buffer)  ; 旧 my-grub-buffer 相当(戻る)
(global-set-key (kbd "C-.") #'next-buffer)      ; 旧 my-bury-buffer 相当(進む)


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

;; git-modes(gitignore / gitconfig / gitattributes 3 点セット。Magit 系)
;;   旧 init.el は (el-get-bundle gitignore-mode) のみ(設定なし)。
;;   .gitignore 等を fundamental-mode でなく専用モードで開き、# コメント
;;   や否定 ! を色付け。Git 動作には不要だが、稀に手編集するファイルほど
;;   モード支援があると安心(ユーザー要望)。標準パターン(.gitignore /
;;   .gitconfig / .gitattributes / .gitmodules / .git/config /
;;   info/exclude 等)は git-modes の autoload が auto-mode-alist へ
;;   自動登録。追加で .dockerignore など *ignore 系も gitignore-mode に。
(use-package git-modes
  :mode (("\\.dockerignore\\'"    . gitignore-mode)
         ("\\.eslintignore\\'"    . gitignore-mode)
         ("\\.prettierignore\\'"  . gitignore-mode)
         ("\\.npmignore\\'"       . gitignore-mode)
         ("\\.stylelintignore\\'" . gitignore-mode)))


;;; ============================================================
;;;  Undo / 履歴(旧 inits/50-history.el の移植・取捨選択)
;;; ============================================================
;; 旧構成は redo+ / undo-tree / undohist / point-undo の 4 外部 elisp。
;; 現代の組み込み機能で置換できるものは置換し、有用なものだけ導入する。

;; --- redo+ → 組み込み undo-redo(Emacs 28+)で代替 ---
;; 旧: (el-get-bundle redo+) + (global-set-key (kbd "C-M-/") 'redo)
;; redo+ は未保守の EmacsWiki コード。Emacs 28+ 同梱の `undo-redo` が
;; 同等の「直前の undo を取り消す(= redo)」を提供するため不採用。
;; キーは旧 redo+ と同じ C-M-/ を踏襲。
(global-set-key (kbd "C-M-/") 'undo-redo)
;; 旧 50-history.el は併せて undo メモリ上限の引き上げと
;;   (setq undo-no-redo t) を行っていた。これらは redo+ ではなく
;; 組み込み変数。既定(undo-limit 160000 / undo-strong-limit 240000 /
;; undo-no-redo nil)から変えたい場合のみ下記を有効化(現状は既定):
;; (setq undo-limit 600000)
;; (setq undo-strong-limit 900000)
;; (setq undo-no-redo t)

;; --- undohist: undo 履歴の永続化(導入) ---
;; ファイル単位の undo 履歴をディスク保存し、バッファ kill や Emacs
;; 再起動後の再オープンでも undo 履歴を復元する。組み込み代替なし。
;; 旧: undohist-directory = dot-emacs-dir/.undohist。新構成では
;; user-emacs-directory 配下の .undohist(.gitignore で除外済み)。
;; undohist-initialize がディレクトリを自動生成しフックを登録する。
(use-package undohist
  :config
  (setq undohist-directory (locate-user-emacs-file ".undohist"))
  (undohist-initialize))

;; --- undo-tree: 導入見送り ---
;; 分岐 undo + ツリー可視化。動作はするが巨大ファイルで重く、履歴破損の
;; 不具合歴もある。単純な redo は上記 undo-redo で足りるため見送り。
;; 将来、分岐 undo の可視化が欲しくなったら軽量な `vundo`(組み込み
;; undo をそのまま使い可視化のみ追加)を第一候補に検討する。

;; --- point-undo(F5/F6): 導入見送り、組み込み mark ring で代用 ---
;; 旧 point-undo はカーソル位置の undo/redo(未保守 EmacsWiki)。
;; 組み込みの mark ring で同等のことができる:
;;   - C-SPC C-SPC          : 現在位置をマークに積む(移動の起点を記録)
;;   - C-u C-SPC            : ローカル mark ring を遡り過去の位置へ戻る
;;                            (連打で順次戻る。set-mark-command-repeat-pop
;;                             を t にすると 1 回目以降 C-SPC のみで連続)
;;   - C-x C-SPC            : global-mark-ring を遡る(バッファ跨ぎ)
;;   - また検索/編集の多くは自動でマークを積むため、戻り先の起点になる。
;; より point-undo に近い体験が必要になったら `point-history` 等を別途検討。
;; (setq set-mark-command-repeat-pop t) ; 好みで有効化可


;;; ============================================================
;;;  ファイルの自動保存・バックアップ(旧 inits/50-autosave-backup.el)
;;; ============================================================
;; Emacs が編集中に自動生成する一時ファイルを user-emacs-directory 配下の
;; 専用ディレクトリへ集約し、編集対象のディレクトリに散らからないようにする。
;;
;;   ① auto-save 本体  #file#         -> .autosave/
;;   ② auto-save 索引  saves-PID-HOST -> .autosave/   (recover-session 用)
;;   ③ バックアップ    file~          -> .backup/
;;   ④ undo 履歴       (undohist)     -> .undohist/   (上記「Undo / 履歴」で集約済み)
;;
;; 旧 50-autosave-backup.el は ② と ③ のみ集約し、① auto-save 本体は
;; 散らばったままだった。本設定は ① も含めて集約する(ユーザー選択)。
;; 出力先 3 つはいずれも .gitignore で除外済み。

(defvar my-autosave-dir (locate-user-emacs-file ".autosave/")
  "auto-save 関連ファイル(#file# 本体・saves 索引)の集約先。")
(defvar my-backup-dir (locate-user-emacs-file ".backup/")
  "バックアップファイル(file~)の集約先。")

;; ディレクトリを用意。Emacs は #file# の出力先を自動作成しないため必須
;; (backup-directory-alist 先は自動作成されるが、作法統一のため両方作る)。
(dolist (d (list my-autosave-dir my-backup-dir))
  (unless (file-directory-p d)
    (make-directory d t)))

;; ① auto-save 本体: 旧設定に無かった集約。末尾の t = UNIQUIFY、
;;    元のフルパスをファイル名へ畳み込み、別ディレクトリの同名ファイル
;;    どうしの衝突を防ぐ。
(setq auto-save-file-name-transforms
      `((".*" ,my-autosave-dir t)))

;; ② auto-save リスト索引(M-x recover-session 用)。
;;    旧は .autosave/PID-HOST、本設定は saves- 接頭辞付き(Emacs 既定流)。
(setq auto-save-list-file-prefix (expand-file-name "saves-" my-autosave-dir))

;; ③ バックアップ: make-backup-files は既定 t。旧は対象正規表現に
;;    "\\.*$"(全ファイルに一致する変則表記)を使用 → 現代慣用の "."
;;    に置換(意味は同じ「全ファイル」)。世代管理(version-control /
;;    delete-old-versions / backup-by-copying 等)は旧設定にも無く、
;;    今回の集約スコープ外(必要なら別途追加)。
(setq make-backup-files t)
(setq backup-directory-alist
      (cons (cons "." my-backup-dir) backup-directory-alist))


;;; ============================================================
;;;  編集支援(旧 inits/50-edit.el, 50-edit-helper.el の移植・取捨選択)
;;; ============================================================

;; --- スマート行頭 C-a(旧 intelli-home-2 を忠実移植)---
;; 行頭以外で C-a → 行頭へ。行頭で C-a → 最初の非空白文字へ。
(defun my-smart-home ()
  "行頭でなければ行頭へ、行頭なら最初の非空白文字へ(旧 intelli-home-2)。"
  (interactive)
  (if (= (point) (line-beginning-position))
      (beginning-of-line-text)
    (beginning-of-line)))
(global-set-key (kbd "C-a") #'my-smart-home)

;; --- C-w: 選択時 kill / 無選択時 単語削除(旧 50-edit.el 忠実)---
;; 本設定は transient-mark-mode nil を維持しており、旧と同じく
;; `mark-active' 判定でよい(選択を可視化しない旧来挙動)。
(defun kill-region-or-backward-kill-word (&optional arg)
  "選択中は kill-region、無選択は backward-kill-word(旧 50-edit.el 忠実)。"
  (interactive "p")
  (if mark-active
      (kill-region (mark) (point))
    (backward-kill-word (or arg 1))))
(global-set-key (kbd "C-w") #'kill-region-or-backward-kill-word)
(define-key minibuffer-local-completion-map
            (kbd "C-w") #'kill-region-or-backward-kill-word)

;; --- リージョン囲み(旧 quote-region-by を忠実移植)---
;; 選択範囲を、押した記号/括弧で囲む。括弧類は対応閉じ括弧を補完。
;; 代替メモ: 組み込み `electric-pair-mode' を有効化すると、リージョン
;; 選択中に開き括弧/クォートを打つだけで自動で囲める(Emacs 24+ 標準)。
;; 本機能(下記 + C-c 記号バインド)を使わなくなったら
;; `(electric-pair-mode 1)' へ移行すれば自作関数とバインドは不要になる。
;; ここではユーザー選択に従い忠実移植を採用し electric-pair は有効化しない。
(defvar quote-region-quoter-alist
  '(("(" . ")") ("{" . "}") ("[" . "]") ("<" . ">"))
  "開き → 閉じ の対応。括弧以外は同じ記号で前後を囲む。")

(defun quote-region-by (s e)
  "リージョン S..E を、直前に押した記号(`last-command-event')で囲む。"
  (interactive "r")
  (let* ((str (buffer-substring-no-properties s e))
         (original-point (point))
         (quoter (string last-command-event))
         (quoter-begin (let ((p (rassoc quoter quote-region-quoter-alist)))
                         (if p (car p) quoter)))
         (quoter-end   (let ((p (assoc quoter quote-region-quoter-alist)))
                         (if p (cdr p) quoter)))
         (quoted-str   (concat quoter-begin str quoter-end)))
    (delete-region s e)
    (insert quoted-str)
    (goto-char (+ original-point (length quoter-begin) (length quoter-end)))))

(dolist (k '("\C-c\"" "\C-c'" "\C-c`" "\C-c/" "\C-c!" "\C-c|" "\C-c%"
             "\C-c(" "\C-c{" "\C-c[" "\C-c<" "\C-c)" "\C-c}" "\C-c]" "\C-c>"))
  (global-set-key k #'quote-region-by))

;; --- 行折り返しトグル(組み込み)---
;; 旧 inits/50-edit.el の自作 walk-windows ラッパは不採用(組み込み
;; `toggle-truncate-lines' を shadow していた)。組み込みをそのまま使う。
;; 旧はキー未割当のため、新規に C-c $(未使用を確認)に割当。
;; 行を折り返して表示したい場合は M-x visual-line-mode(組み込み)。
(global-set-key (kbd "C-c $") #'toggle-truncate-lines)

;; --- キルリング閲覧 M-y(組み込み yank-from-kill-ring, Emacs 28+)---
;; 旧 yank-pop-summary(未保守・MELPA 不在)は不採用。組み込みの
;; `yank-from-kill-ring' が補完 UI で kill-ring を一覧選択でき、旧機能の
;; 最も近い代替。通常の M-y(yank 直後の yank-pop)も従来どおり動く。
(when (fboundp 'yank-from-kill-ring)
  (global-set-key (kbd "M-y") #'yank-from-kill-ring))

;; --- 二度押し C-g でマーク解除(旧 defadvice を advice-add で現代化)---
;; transient-mark-mode nil 維持下で、短時間に C-g を 2 回押すと mark を
;; 解除する(旧 inits/50-edit.el 相当。旧 `defadvice' は非推奨のため
;; `advice-add' で書き直し)。閾値 0.3 秒は旧踏襲。
(defvar my-keyboard-quit-lasttime (float-time)
  "前回 `keyboard-quit' 実行時刻(float-time)。")
(defconst my-keyboard-quit-double-threshold 0.3
  "この秒数以内に C-g 2 回で mark を解除する。")
(defun my-keyboard-quit-clear-mark (&rest _)
  "短時間に二度 C-g されたら mark を解除する(`keyboard-quit' :before)。"
  (let ((tm (float-time)))
    (when (> my-keyboard-quit-double-threshold
             (- tm my-keyboard-quit-lasttime))
      (set-marker (mark-marker) nil)
      (setq deactivate-mark t)
      (setq mark-active nil)
      (message "Mark killed"))
    (setq my-keyboard-quit-lasttime tm)))
(advice-add 'keyboard-quit :before #'my-keyboard-quit-clear-mark)

;; --- シンボルハイライト & 一括 rename(symbol-overlay)---
;; 旧 auto-highlight-symbol(未保守・~2015 停止)の現代後継。
;; prog-mode で同一シンボルを自動ハイライトし、移動/一括 rename も可。
(use-package symbol-overlay
  :hook (prog-mode . symbol-overlay-mode)
  :bind (("M-i"  . symbol-overlay-put)
         ("M-n"  . symbol-overlay-jump-next)
         ("M-p"  . symbol-overlay-jump-prev)
         ("<f7>" . symbol-overlay-rename)
         ("<f8>" . symbol-overlay-remove-all)))


;;; ============================================================
;;;  ビューモード(ページャ)— 旧 inits/50-view-mode.el / 20-key-chord.el
;;; ============================================================
;; 旧 50-view-mode.el は 4 機能の複合体。調査のうえ取捨選択した:
;;   - view-read-only は現役 → 移植(下記 ①)。
;;   - 「書込不可ファイルを view で開く」find-file advice は冗長 → 不採用。
;;     view-read-only t だけで chmod 444 等が view-mode 自動 ON になる
;;     ことを実機確認済み(旧 defadvice は現代では不要)。
;;   - 「書込不可なら view を抜けない」advice → 不採用(ユーザー選択)。
;;     view を抜けても buffer-read-only のままで編集は防がれる。
;;   - 自作 vi 風 pager-keybind ×24 → 忠実移植は不能。依存先が
;;     point-undo(本リビルドで採用見送り)/ bm(未移植)/
;;     win-delete-current-window-and-squeeze(旧設定にも定義なし)で、
;;     かつ現代 view-mode-map の有用な既定(e=View-exit, n/p=検索反復
;;     ほか)を潰す。よって最小 vi サブセットのみ移植(ユーザー選択)。

;; ① 書込不可・読取専用ファイルを開いたら view-mode を自動 ON。
(setq view-read-only t)

;; ② 最小 vi サブセットを view-mode-map に追加。現代 view-mode-map で
;;    未割当のキーのみ使い、有用な既定は温存する。h のみ既定の
;;    describe-mode を上書きするが(C-h m で代替可)、ページャの左移動
;;    として vi 風に割当。旧 pager-keybind は h/l=単語移動だったが、
;;    本来の vi に合わせ h/l=文字移動へ現代化。J/K の 1 行スクロールは
;;    組み込みコマンド scroll-up-line / scroll-down-line を使用
;;    (旧は無名 lambda)。
(with-eval-after-load 'view
  (define-key view-mode-map (kbd "h") #'backward-char)
  (define-key view-mode-map (kbd "j") #'next-line)
  (define-key view-mode-map (kbd "k") #'previous-line)
  (define-key view-mode-map (kbd "l") #'forward-char)
  (define-key view-mode-map (kbd "J") #'scroll-up-line)
  (define-key view-mode-map (kbd "K") #'scroll-down-line))

;; ③ key-chord: "jk" 同時押しで view-mode をトグル(旧 20-key-chord.el)。
;;    chord の組み込み代替は無く、key-chord は MELPA で保守継続中
;;    (2025 更新)のためそのまま採用。旧 (require 'key-chord nil t) は
;;    use-package 化。
(use-package key-chord
  :config
  (setq key-chord-two-keys-delay 0.1)
  (key-chord-mode 1)
  (key-chord-define-global "jk" #'view-mode))


;;; ============================================================
;;;  ファイル管理(dired)— 旧 inits/50-dired.el の組み込み完結分
;;; ============================================================
;; 旧構成のうち「組み込みで完結する」ものを移植。dired-subtree /
;; dired-preview / treemacs 等のパッケージ系は別途(未着手)。
;; 旧 defadvice・elscreen 依存は現代化(advice-add / 非依存化)。
;;
;; キーバインド一覧(本セクションで定義):
;;   C-x C-j        : dired-jump            現ファイルの dir を dired で開く
;;   C-x C-p        : find-file-at-point    カーソル位置のパス/URL を開く
;;   dired 内 r     : wdired-change-to-wdired-mode  一括リネーム(C-x C-q も可)
;;   dired 内 E     : dired-ediff-marked-files      マーク 2→ediff / 3→ediff3
;;   dired 内 (     : dired-hide-details-mode       詳細列の表示トグル(組み込み既定)
;;   dired 内 M-x dired-omit-mode は hook で自動 ON(.git/.svn/CVS 非表示)
;;
;; コンパイル時に dired 系シンボルを解決し byte-compile 警告を抑止
;; (実行時の挙動は with-eval-after-load で従来どおり遅延)。
(eval-when-compile
  (require 'dired)
  (require 'dired-x)
  (require 'find-dired))
(declare-function dired-get-marked-files "dired")
(declare-function dired-omit-mode "dired-x")
(declare-function wdired-change-to-wdired-mode "wdired")

;; --- マーク 2/3 ファイルを ediff(旧 dired-ediff-marked-files)---
;; 旧 active 版は elscreen 依存。elscreen 非依存の単純版を移植。
;; defun はトップレベル(byte-compile 警告回避。dired-get-marked-files は
;; 呼び出し時に dired がロード済みのため declare-function で宣言)。
(defun dired-ediff-marked-files ()
  "マークした 2 個を ediff、3 個を ediff3(旧 50-dired.el 簡易版)。"
  (interactive)
  (let ((fs (dired-get-marked-files)))
    (cond ((= (length fs) 2)
           (ediff-files (nth 0 fs) (nth 1 fs)))
          ((= (length fs) 3)
           (ediff3 (nth 0 fs) (nth 1 fs) (nth 2 fs)))
          (t (user-error "ediff には 2 個または 3 個マークしてください")))))

;; --- dired-x: 不要ファイル非表示(.git/.svn/CVS)+ wdired + ediff キー ---
;; 旧 dired-omit-files-p は obsolete。マイナーモード dired-omit-mode を
;; dired-mode-hook で有効化するのが現行作法(挙動は旧と同じ)。
;; wdired は組み込み。dired の r は既定未割当のため衝突なし
;; (標準の C-x C-q→wdired も併用可)。
(with-eval-after-load 'dired
  (require 'dired-x)
  (setq dired-omit-files
        (concat dired-omit-files "\\|^\\.git$\\|^\\.svn$\\|^CVS$"))
  (add-hook 'dired-mode-hook #'dired-omit-mode)
  (define-key dired-mode-map "r" #'wdired-change-to-wdired-mode)
  (define-key dired-mode-map "E" #'dired-ediff-marked-files))

;; --- 詳細表示トグル(旧 dired-details → 組み込み)---
;; dired-details パッケージは不要。組み込み dired-hide-details-mode が
;; 完全代替で、既定どおり詳細表示・( でトグル(旧 initially-hide nil 相当)。
;; 追加設定なし(自動で隠したくなったら dired-mode-hook に
;;  #'dired-hide-details-mode を足す)。

;; --- C-x C-j: dired-jump(旧 direx-project の組み込み代替)---
;; dired-x の dired-jump。現ファイルのディレクトリを dired で開く。
;; 旧 direx(未保守)は不採用。常駐ツリーが要れば将来 treemacs/
;; dired-sidebar を別途検討。
(global-set-key (kbd "C-x C-j") #'dired-jump)

;; --- find-dired 系のバッファ名ユニーク化(旧 defadvice→advice-add)---
;; 複数回実行時の単一バッファ上書きを防ぐ。dir/引数 を名前に含める。
(advice-add 'find-dired :after
            (lambda (dir args &rest _)
              (rename-buffer (format "*Find* <%s %s>" dir args) t)))
(advice-add 'find-name-dired :after
            (lambda (dir pattern &rest _)
              (rename-buffer (format "*FindName* <%s %s>" dir pattern) t)))
(advice-add 'find-grep-dired :after
            (lambda (dir regexp &rest _)
              (rename-buffer (format "*FindGrep* <%s %s>" dir regexp) t)))

;; --- ファイル名/URL を文脈で開く(ffap、軽量採用)---
;; 旧 (ffap-bindings) は C-x C-f 系を全置換するが、誤爆回避のため
;; 別キー C-x C-p に find-file-at-point のみ割当(ユーザー選択)。
(global-set-key (kbd "C-x C-p") #'find-file-at-point)


;;; ============================================================
;;;  ファイル管理(dired)拡張: パッケージ
;;;  (旧 dired-subtree / bf-mode / direx 系の代替・後継)
;;; ============================================================

;; --- dired-subtree: dired 上でサブディレクトリをツリー展開 ---
;; 旧 inits/50-dired.el の `i`(insert)/ `<tab>`(remove)/ `C-x n n`
;; (narrow)/ `^`(up-dwim)を踏襲しつつ、新方針(ユーザー選択)で
;;   <tab>       : 展開/折りたたみのトグル(insert と remove の統合)
;;   <backtab>   : ツリー全段を順にサイクル(全展開→部分→全折)
;; に整理。`i` は組み込み `dired-maybe-insert-subdir' を温存する。
;; その他コマンド(narrow / up-dwim / mark-subtree 等)は M-x から。
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<tab>"     . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)))

;; --- dired-sidebar: dired をサイドバー化(旧 direx 常駐ツリーの代替)---
;; direx(未保守)の常駐ディレクトリツリーの後継。dired-sidebar は内部で
;; 通常の dired バッファを使うため、本設定で既に整えた dired 機能
;; (dired-x omit / wdired=r / ediff=E / dired-subtree=<tab> 等)がその
;; ままサイドバーでも使える。`C-x C-n` で開閉トグル(組み込み既定の
;; `set-goal-column' を shadow する、ユーザー選択)。
;;
;; テーマは `ascii' を選択(icons/nerd/vscode-icons は all-the-icons 等の
;; 別パッケージ + フォント導入が前提。導入したら theme を変更可能)。
(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :commands (dired-sidebar-toggle-sidebar)
  :custom
  (dired-sidebar-theme 'ascii)
  (dired-sidebar-use-custom-font nil))

;; --- dired-preview: dired でカーソル下ファイルを自動プレビュー ---
;; 旧 bf-mode(未保守 / 入手困難)の現代後継。GNU ELPA、保守継続
;; (Protesilaos Stavrou)。dired バッファに入ると `dired-preview-mode'
;; が ON になり、カーソル移動に追従して右ペインに中身を表示する。
;; 表示までの遅延 `dired-preview-delay'(既定 0.7s)、無効化したい
;; 拡張子 `dired-preview-ignored-extensions-regexp' などをカスタマイズ可。
;; 全バッファで常時 ON にしたい場合は `dired-preview-global-mode' に
;; 切り替える。
(use-package dired-preview
  :hook (dired-mode . dired-preview-mode))


;;; ============================================================
;;;  プロジェクト管理(組み込み project.el / Emacs 28+)
;;; ============================================================
;; 旧 find-file-in-project(外部パッケージ)の代替。Emacs 28+ 同梱の
;; project.el が「カレントプロジェクト(VCS ルートで自動判定)内の
;; ファイル一覧」をネイティブに提供し、`.gitignore' を自動尊重する。
;;
;; 主なキー(`C-x p' プレフィックス、組み込み既定):
;;   C-x p f : project-find-file       ; プロジェクト内ファイル検索(旧 find-file-in-project 相当)
;;   C-x p p : project-switch-project  ; プロジェクト切替
;;   C-x p d : project-find-dir
;;   C-x p g : project-find-regexp     ; プロジェクト内 grep
;;   C-x p r : project-query-replace-regexp
;;   C-x p s : project-shell
;;   C-x p e : project-eshell
;;   C-x p ! : project-shell-command
;;   C-x p k : project-kill-buffers
;;   C-x p b : project-switch-to-buffer
;;
;; project.el は autoload 済みのため、ここでは追加設定なしで利用可能。
;; プロジェクト判定の追加ヒント(.project ファイル等)を入れたい場合は
;; `project-vc-extra-root-markers' を設定する(現状は VCS 判定のみで十分)。
;; (setq project-vc-extra-root-markers '(".project" "package.json"))


;;; ============================================================
;;;  検索 — migemo(ローマ字のまま日本語を検索)
;;; ============================================================
;; 旧 inits/cocoa-emacs-migemo.el の移植。ローマ字(ASCII)入力のまま
;; 日本語(ひらがな/カタカナ/漢字)をインクリメンタル検索できる。
;; 変換エンジンは外部の cmigemo(C 実装)。
;;
;; ── 新マシン setup: cmigemo の導入手順 ───────────────────────────
;;   macOS (Apple Silicon / Intel 共通):
;;     brew install cmigemo
;;       → バイナリ: /opt/homebrew/bin/cmigemo (Intel は /usr/local/bin)
;;       → 辞書:   /opt/homebrew/share/migemo/utf-8/migemo-dict
;;                 (Intel は /usr/local/share/migemo/utf-8/migemo-dict)
;;   Debian / Ubuntu:
;;     sudo apt install cmigemo
;;       → バイナリ: /usr/bin/cmigemo
;;       → 辞書:   /usr/share/cmigemo/utf-8/migemo-dict
;;   Windows:
;;     KaoriYa 配布の C/Migemo を入手し PATH 追加。
;;       https://www.kaoriya.net/software/cmigemo/
;;     辞書の場所(例): C:\cmigemo-default-win64\dict\utf-8\migemo-dict
;;     (旧 inits/windows-migemo.el は cp932 辞書を使っていたが、現代は
;;      utf-8 推奨。本セクションは Windows 設定は同梱しない)
;;   その他 (Arch / Nix / source build 等):
;;     上流 https://github.com/koron/cmigemo を参照。
;;
;; 上記 4 つの代表的な辞書パスは my-migemo-dictionary が
;; 実行時に先頭から順に file-exists-p し、見つかったものを採用する。
;; cmigemo バイナリ or 辞書がどれも見つからないマシンでは
;; use-package :if が偽となり migemo 関連は全体スキップされる。
;; ─────────────────────────────────────────────────────────────────
;;
;; 方針(Option A): 検索 UI は刷新せず、組み込み isearch をローマ字対応に
;; するのみ。migemo-init 後は通常の C-s / C-r がそのまま日本語にヒットし、
;; 検索中 M-m で migemo の ON/OFF をトグルできる。swiper 等の補完系
;; 検索 UI への移行(Option B)は CLAUDE.md「検索・grep・補完 UI」を参照。
;;
;; 移植上の現代化:
;;   - 旧 init.el の (el-get-bundle migemo) → use-package + elpa/ vendoring。
;;   - 旧 macOS 設定は辞書を /usr/local/...(Intel Homebrew)に固定して
;;     いた。Apple Silicon は /opt/homebrew/...。別マシンへの移植性の
;;     ため、実在する辞書を実行時に候補から選ぶ(ホーム絶対パス不使用)。
;;   - cmigemo バイナリ or 辞書が無いマシンでは use-package :if で全体を
;;     スキップ(旧 (migemo-init) 無条件呼び出しのエラーを回避)。
(defvar my-migemo-dictionary
  (seq-find #'file-exists-p
            '("/opt/homebrew/share/migemo/utf-8/migemo-dict"  ; macOS Apple Silicon
              "/usr/local/share/migemo/utf-8/migemo-dict"     ; macOS Intel
              "/usr/share/cmigemo/utf-8/migemo-dict"          ; Linux 等
              "/usr/share/migemo/utf-8/migemo-dict"))
  "実在する cmigemo 辞書ファイルのパス。見つからなければ nil。")

(declare-function migemo-init "migemo")  ; :config の migemo-init を byte-compile に既知化

(use-package migemo
  :if (and (executable-find "cmigemo") my-migemo-dictionary)
  :demand t
  :init
  (setq migemo-command          "cmigemo"
        migemo-options          '("-q" "--emacs")
        migemo-dictionary       my-migemo-dictionary
        migemo-user-dictionary  nil
        migemo-regex-dictionary nil
        migemo-coding-system    'utf-8)
  :config
  (migemo-init))


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
;; 高速バッファ切替 C-, / C-. は組み込み next/previous-buffer で
;; 上記「バッファ操作」セクションへ移植済み。

;; --- 50-edit.el / 50-edit-helper.el ---
;; intelli-home-2(C-a)/ kill-region-or-backward-kill-word(C-w)/
;; quote-region-by(C-c 記号 ×15)/ 二度押し C-g マーク解除 は上記
;; 「編集支援」セクションへ移植済み。

;; --- 50-view-mode.el ---
;; 上記「ビューモード(ページャ)」セクションへ移植済み(view-read-only +
;; 最小 vi サブセット)。旧 pager-keybind / define-many-keys /
;; view-mode-hook0、および find-file / view-mode-exit への defadvice は
;; 調査のうえ不採用(冗長・依存先未移植・現代既定の破壊)。


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
;; 不採用。組み込み yank-from-kill-ring(M-y)へ「編集支援」で移植済み。

;; --- auto-highlight-symbol ---
;; 不採用。現代後継 symbol-overlay を「編集支援」で use-package 移植済み。

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
;; 上記「ビューモード(ページャ)」セクションへ use-package で移植済み
;; (jk → view-mode)。

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
;; すべて上記「ファイル管理(dired)」/「ファイル管理(dired)拡張: パッケージ」
;; セクションへ移植済み(組み込み分 + dired-subtree / dired-sidebar /
;; dired-preview)。direx(未保守)は dired-sidebar で代替済み。

;; --- go-mode(旧 50-go.el)---
;; (with-eval-after-load 'go-mode
;;   (define-key go-mode-map (kbd "M-.") 'godef-jump)
;;   (define-key go-mode-map (kbd "M-,") 'pop-tag-mark))


(provide 'init)
;;; init.el ends here

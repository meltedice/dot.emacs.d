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
;; 採用テーマ: matrix-on-ice(本リポジトリ themes/ 配下の自前 deftheme。
;; 外部パッケージ非依存)。旧 ~/.emacs.d で auto-install されていた
;; matrix-on-ice の名前を引き継ぎ、旧の最小忠実版として default の bg/fg
;; (黒+#7eff00)だけを指定する。mode-line / link / outline-* / font-lock
;; 等は Emacs 既定のまま=旧 Emacs 29.x 環境の見え方を保つ。
;;
;; 起動時は early-init.el で GUI フレーム生成前に load 済み。下記は
;; early-init.el が走らなかった起動経路用のフォールバック(冪等)。
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(unless (custom-theme-enabled-p 'matrix-on-ice)
  (load-theme 'matrix-on-ice t))


;;; ============================================================
;;;  組み込み UX(セッション永続化・操作補助)
;;; ============================================================
;; いずれも Emacs 同梱(外部パッケージ不要)。多くの設定で定番だが本リビルドに
;; 未導入だったものをまとめて有効化。生成される per-machine の状態ファイル
;; (.recentf / .savehist / .saveplace)は .gitignore で除外する。

;; --- recentf: 最近開いたファイルの履歴 ---
;; C-x C-r で履歴から補完選択して開く(既定の find-file-read-only を上書き。
;; 読取専用で開く用途は view-read-only / view-mode 側で代替済み)。
(setq recentf-save-file       (locate-user-emacs-file ".recentf"))
(setq recentf-max-saved-items 300)
(setq recentf-max-menu-items  30)
(setq recentf-exclude
      (list (regexp-quote (expand-file-name "elpa/" user-emacs-directory))
            "\\.recentf\\'" "\\.savehist\\'" "\\.saveplace\\'"
            "/\\.git/" "/COMMIT_EDITMSG\\'" "\\.gz\\'"))
(recentf-mode 1)
(global-set-key (kbd "C-x C-r") #'recentf-open) ; Emacs 29+ の補完版

;; --- savehist: ミニバッファ・M-x 等の入力履歴をセッション間で永続化 ---
;; (将来 vertico 系に刷新する際もそのまま土台として使える)
(setq savehist-file   (locate-user-emacs-file ".savehist"))
(setq history-length  1000)
(savehist-mode 1)

;; --- save-place: ファイルごとに前回のカーソル位置を復元 ---
(setq save-place-file (locate-user-emacs-file ".saveplace"))
(save-place-mode 1)

;; --- which-key: キー入力途中で後続キー候補をエコーエリアに表示 ---
;; (Emacs 30 で本体同梱。プレフィックスキー C-z / C-t / C-c 等の確認に有用)
(setq which-key-idle-delay 0.8)
(which-key-mode 1)

;; --- auto-revert: 外部で変更されたファイル/dired を自動再読込 ---
;; (git のブランチ切替・pull やフォーマッタ実行後の追従に有用)
(setq global-auto-revert-non-file-buffers t) ; dired/Buffer-list 等も対象
(global-auto-revert-mode 1)

;; --- delete-selection: アクティブなリージョンを入力文字で置換 ---
;; 本設定は transient-mark-mode が nil のため、リージョンは「アクティブ
;; (ハイライト)」のときしか delete-selection の対象にならない。
;;   - 単一 C-SPC: マークを置くだけ(非アクティブ)→ region-active-p nil
;;                 → 発火しない。文字入力はカーソル位置に普通に挿入される。
;;   - C-SPC 2度押し: 一時的 transient-mark-mode(lambda)でリージョンが
;;                 アクティブ化 → region-active-p t → 入力で選択範囲を置換。
;; よって実質「選択がハイライトされている時だけ置換」という挙動になる
;; (shift 選択 / マウスドラッグ / C-x C-x の再アクティブ化も同様に対象)。
(delete-selection-mode 1)

;; --- repeat-mode: 同種コマンドを 1 キーで連打可能に(Emacs 28+) ---
;; 例) C-x o o o…(other-window)、C-x { / } から ^ v < > でウィンドウリサイズ、
;;     C-x C-+ / C-- で文字サイズの連続調整 など。
(repeat-mode 1)


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

;; M-o: ウィンドウが 1 つなら分割してから移動、2 つ以上なら次のウィンドウへ移動。
;; 旧 inits/50-window.el の other-window-or-split を移植(ユーザー判断で復活)。
;; 分割方向は旧の split-window-horizontally(左右固定)から split-window-sensibly
;; (フレームの縦横比で左右/上下を自動選択)へ現代化(B 案)。C-tab には割当てない。
(defun my-other-window-or-split ()
  "Move to the next window; if only one window, split the frame first.
When there is a single window, split it via `split-window-sensibly'
(left/right or top/bottom chosen from the frame's geometry) and then
move into the new window.  With two or more windows, just move to the
next one."
  (interactive)
  (when (one-window-p)
    (split-window-sensibly))
  (other-window 1))
(global-set-key "\M-o" #'my-other-window-or-split) ;; 旧 other-window-or-split 相当

;; フレーム内のウィンドウ配置を時計回りに 90° 回転する
;; (M-x my-rotate-windows-clockwise / C-t r。バインドは C-t プレフィックス
;;  定義の直後を参照。repeat-mode 対応で C-t r のあと r 連打で回り続ける)。
;; 分割ツリーを再帰変換する: 左右分割 → 上下分割(順序維持: 左→上)、
;; 上下分割 → 左右分割(順序反転: 上→右)。分割比率は回転後の軸へ引き継ぐ。
;; 例)  A|B  →  A/B(A が上)  →  B|A  →  B/A  → …
;;      (A|B)/C  →  C|(A/B)  →  C/(B|A)  → …
;; 単純に回転できない構成(専用ウィンドウ・サイドウィンドウ、回転後に
;; 最小サイズを割る場合等)は途中で error にし、元の配置に復元する。
(defun my-rotate-windows--capture (node)
  "`window-tree' の NODE を回転用の仕様リストに再帰変換する。
リーフは (leaf BUFFER POINT START SELECTED-P)、内部ノードは
\(split VERTICAL (FRACTION . CHILD)...) を返す。FRACTION は
分割軸方向に子が占めるサイズ比(合計 1.0)。"
  (if (windowp node)
      (progn
        (when (window-dedicated-p node)
          (user-error "Cannot rotate: dedicated window (%s)" (window-buffer node)))
        (when (window-parameter node 'window-side)
          (user-error "Cannot rotate: side window (%s)" (window-buffer node)))
        ;; atomic window(window-make-atom で束ねた分割不可グループ)。dedicated /
        ;; side と違い leaf にフラグが立つだけなので、これを弾かないと回転で
        ;; delete-other-windows + 再分割によって atom が無言で解体される
        ;; (batch で再現済み)。「回転できない構成はエラーで中止」の契約を守る。
        (when (window-parameter node 'window-atom)
          (user-error "Cannot rotate: atomic window (%s)" (window-buffer node)))
        (list 'leaf (window-buffer node) (window-point node)
              (window-start node) (eq node (selected-window))))
    (let* ((vertical (car node))            ; t = 上下分割 / nil = 左右分割
           (edges (cadr node))
           (total (if vertical
                      (- (nth 3 edges) (nth 1 edges))
                    (- (nth 2 edges) (nth 0 edges)))))
      (cons 'split
            (cons vertical
                  (mapcar
                   (lambda (child)
                     (let* ((cedges (if (windowp child) (window-edges child) (cadr child)))
                            (csize (if vertical
                                       (- (nth 3 cedges) (nth 1 cedges))
                                     (- (nth 2 cedges) (nth 0 cedges)))))
                       (cons (/ (float csize) total)
                             (my-rotate-windows--capture child))))
                   (cddr node)))))))

(defun my-rotate-windows--rotate (spec)
  "回転規則を SPEC に再帰適用する。
左右分割 → 上下分割(順序維持: 左→上)/ 上下分割 → 左右分割(順序反転: 上→右)。"
  (if (eq (car spec) 'leaf)
      spec
    (let ((vertical (cadr spec))
          (children (mapcar (lambda (fc)
                              (cons (car fc) (my-rotate-windows--rotate (cdr fc))))
                            (cddr spec))))
      (cons 'split
            (cons (not vertical)
                  (if vertical (reverse children) children))))))

(defun my-rotate-windows--build (spec win)
  "SPEC を WIN に再帰展開する。選択すべきウィンドウを返す(該当なしなら nil)。"
  (pcase spec
    (`(leaf ,buffer ,point ,start ,selected)
     (set-window-buffer win buffer)
     (set-window-start win start)
     (set-window-point win point)
     (and selected win))
    (`(split ,vertical . ,children)
     (let ((selected nil)
           (remaining 1.0))
       ;; 先頭の子から順に、残り領域から自分の比率ぶんを split で切り出す
       (while (cdr children)
         (let* ((fraction (caar children))
                (total (if vertical (window-total-height win) (window-total-width win)))
                (size (round (* total (/ fraction remaining))))
                (rest (split-window win size (if vertical 'below 'right))))
           (setq selected (or (my-rotate-windows--build (cdar children) win) selected))
           (setq remaining (- remaining fraction)
                 win rest
                 children (cdr children))))
       (or (my-rotate-windows--build (cdar children) win) selected)))))

(defun my-rotate-windows-clockwise ()
  "フレーム内のウィンドウ配置を時計回りに 90° 回転する。
選択ウィンドウ(同じバッファのウィンドウ)は回転後も選択を維持する。
回転できない構成ではエラーにし、元の配置に復元する。"
  (interactive)
  (let ((tree (car (window-tree))))
    (if (windowp tree)
        (message "There is only one window, nothing to rotate")
      (let ((spec (my-rotate-windows--rotate (my-rotate-windows--capture tree)))
            (wc (current-window-configuration)))
        (condition-case err
            (progn
              (delete-other-windows)
              (let ((selected (my-rotate-windows--build spec (selected-window))))
                (when selected (select-window selected))))
          (error
           (set-window-configuration wc)
           (signal (car err) (cdr err))))))))

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

;; C-t r = ウィンドウ配置を時計回りに 90° 回転(my-rotate-windows-clockwise)。
;; 旧 C-t 配下(ウィンドウ操作プレフィックス)の空き枠に配置。r = rotate。
;; repeat-mode 対応: :repeat t が map 内コマンドに repeat-map プロパティを付与するため、
;; C-t r のあとは r 単打で連続回転(4 回で一周)。C-g / 他キーで抜ける。
(defvar-keymap my-rotate-windows-repeat-map
  :doc "Repeat map for `my-rotate-windows-clockwise' (C-t r then r r ...)."
  :repeat t
  "r" #'my-rotate-windows-clockwise)
(define-key ctl-t-map "r" #'my-rotate-windows-clockwise)


;;; ============================================================
;;;  コマンドロガー(押したキーと対応するコマンドをファイルに記録)
;;; ============================================================
;; 通常のテキスト入力以外のコマンドを、実行のたびに「時刻・キー・コマンド名・
;; メジャーモード」の 1 行として記録する。キー入力(C-x C-s 等)や M-x 起動の
;; コマンドを対象に、後から grep / 集計して「どのキー・コマンドをよく使うか」を
;; 分析できる。組み込みのみ・依存なし。
;;
;;   使い方: M-x my-command-log-mode でトグル(グローバルマイナーモード)。
;;           本 init では下部で (my-command-log-mode 1) を呼び起動時から常時記録する
;;           (ユーザー要望)。一時的に止めたい時は M-x my-command-log-mode でトグル。
;;   ログ:   my-command-log-file-format を format-time-string で展開したファイル。
;;           %Y-%m を含むため月ごとに別ファイル(.command-log-YYYY-MM)へローテーション。
;;           .gitignore 除外(per-machine)。
;;   除外:   my-command-log-exclude-commands。テキスト入力系コマンドを除外し、
;;           打った本文をログに残さない(下記変数の docstring 参照)。
;;
;; 設計: post-command-hook は毎コマンド走るため、そこでは行を変数へ push するだけに
;;       し、実際のディスク書き込みはアイドルタイマー + kill-emacs + モード無効化時に
;;       まとめて行う(毎コマンドの I/O を避ける)。クラッシュ時は未フラッシュ分を
;;       取りこぼすが、使い方分析用途のため許容(ユーザー判断)。

(defvar my-command-log-file-format
  (expand-file-name ".command-log-%Y-%m" user-emacs-directory)
  "コマンドログの保存先(`format-time-string' で展開)。
%Y-%m を含むため月ごとに別ファイル(.command-log-YYYY-MM)へローテーションされる。
per-machine、.gitignore 除外。")

(defvar my-command-log-exclude-commands
  '(self-insert-command
    org-self-insert-command
    isearch-printing-char
    quoted-insert
    xterm-paste
    ;; ターミナル系(シェルにタイプした文字。パスワード等の漏洩を防ぐ)。
    vterm--self-insert
    vterm--self-insert-meta
    term-send-raw
    term-send-raw-meta)
  "ログに残さないコマンドのリスト。
テキスト入力系(通常の self-insert / org の self-insert / isearch のタイプ文字 /
C-q quoted-insert / 貼り付け / vterm・term のシェル入力)を除外し、打った本文を
ログに残さない。これは denylist なので、上記以外にもモード固有の self-insert 相当
コマンド(電気的挿入 c-electric-* 等)や、ノイズの多い移動系(next-line 等)を
減らしたい場合は必要に応じて足す。")

(defvar my-command-log-flush-idle-delay 5
  "この秒数アイドルすると、貯めたログ行をまとめてファイルへ書き出す。")

(defvar my-command-log-pending-max 2000
  "未フラッシュ行がこの数に達したら、アイドルを待たず即フラッシュする。
アイドルが長く来ない連続操作(マクロ大量実行等)でメモリに溜め込みすぎない上限。")

(defvar my-command-log--pending nil
  "未フラッシュのログ行(push で先頭=新しい順に積み、フラッシュ時に reverse)。")

(defvar my-command-log--timer nil
  "フラッシュ用のアイドルタイマー。")

(defvar my-command-log--write-warned nil
  "書き込み失敗を一度警告したら t になり、以後は警告を繰り返さない。")

(defun my-command-log--record ()
  "直前に実行したコマンドの 1 行を `my-command-log--pending' に積む。
`post-command-hook' 用。テキスト入力・除外コマンド・無名コマンドは記録しない。
ここではディスク書き込みをせず(アイドル時にまとめて flush)、エラーは握りつぶす。"
  (ignore-errors
    (let ((cmd this-command))
      (when (and cmd
                 (symbolp cmd)
                 (not (memq cmd my-command-log-exclude-commands)))
        (let* ((keys (this-command-keys))
               (desc (unless (seq-empty-p keys) (key-description keys)))
               ;; M-x 起動は this-command-keys が "M-x <名前> RET" に展開されるので
               ;; キー列は "M-x" に畳む(どのコマンドかは次のコマンド名の列に残る)。
               (keydesc (cond ((null desc) "-")
                              ((string-prefix-p "M-x " desc) "M-x")
                              (t desc)))
               (line (format "%s\t[%s]\t%s\t(%s)\n"
                             (format-time-string "%Y-%m-%d %H:%M:%S")
                             keydesc cmd major-mode)))
          (push line my-command-log--pending)
          ;; アイドルが来ない連続操作でもメモリに溜め込みすぎないよう、
          ;; 上限を超えたら即フラッシュする。
          (when (>= (length my-command-log--pending) my-command-log-pending-max)
            (my-command-log--flush)))))))

(defun my-command-log--flush ()
  "貯めた `my-command-log--pending' をまとめて当月のログファイルへ追記する。
書き込みに成功したときだけ pending をクリアし、失敗時は保持して次回リトライする
(失敗の警告は一度だけ)。"
  (when my-command-log--pending
    (condition-case err
        (progn
          ;; reverse は非破壊(古い順に連結)。失敗しても pending を壊さない。
          (write-region (apply #'concat (reverse my-command-log--pending))
                        nil (format-time-string my-command-log-file-format)
                        'append 'no-message)
          (setq my-command-log--pending nil))     ; 成功時のみクリア
      (error
       (unless my-command-log--write-warned
         (setq my-command-log--write-warned t)
         (message "my-command-log: ログ書き込みに失敗しました(以後この警告は出しません): %s"
                  (error-message-string err)))))))

(define-minor-mode my-command-log-mode
  "非テキスト入力コマンドをログファイルに記録するグローバルマイナーモード。"
  :global t
  :lighter " CmdLog"
  :group 'convenience
  (if my-command-log-mode
      (progn
        (add-hook 'post-command-hook #'my-command-log--record)
        (add-hook 'kill-emacs-hook #'my-command-log--flush)
        ;; 二重有効化(init 再読込等で (my-command-log-mode 1) が再実行される)でも
        ;; 古いタイマーを取りこぼさないよう、既存があれば必ず cancel してから作る。
        (when (timerp my-command-log--timer)
          (cancel-timer my-command-log--timer))
        (setq my-command-log--timer
              (run-with-idle-timer my-command-log-flush-idle-delay t
                                   #'my-command-log--flush)))
    (remove-hook 'post-command-hook #'my-command-log--record)
    (remove-hook 'kill-emacs-hook #'my-command-log--flush)
    (when (timerp my-command-log--timer)
      (cancel-timer my-command-log--timer)
      (setq my-command-log--timer nil))
    ;; 無効化時に未フラッシュ分を書き出す
    (my-command-log--flush)))

;; 起動時から常時記録する(ユーザー要望)。止めたい時は M-x my-command-log-mode。
(my-command-log-mode 1)


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
;; 決められるよう、5 プリセットを M-x my-font-preset で即時切替できる。
;; 起動時は my-font-default-preset(現在 "stock-modern-fixed")を GUI 時に
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

(defun my-font--menlo-hiragino (latin-family jp-family)
  "LATIN-FAMILY(Menlo 系)+ JP-FAMILY(ヒラギノ系)+ 最小 rescale の共通部。
stock-modern / stock-modern-fixed / stock-modern-fixed-v1 で family だけ差し替える。"
  (my-font--clear-jp-fontset)
  (set-face-attribute 'default nil :family latin-family :height my-font-height)
  (dolist (s '(katakana-jisx0201 japanese-jisx0208
                                 japanese-jisx0213-1 japanese-jisx0213-2))
    (set-fontset-font t s jp-family))
  (setq face-font-rescale-alist '((".*Hiragino.*" . 1.2))))

(defun my-font--stock-modern ()
  "ストック現代化: Menlo + Hiragino Kaku ProN(macOS 同梱そのまま)+ 最小 rescale。
素の Hiragino は hhea.lineGap=500 を Emacs(macfont.m)が ascent/descent に
加算するため、日本語を含む行だけ 16px→20px に伸びて後続行が下にズレる(実測)。
ズレを解消した版は stock-modern-fixed。"
  (my-font--menlo-hiragino "Menlo" "Hiragino Kaku Gothic ProN"))

;; ---- 行高ズレ解消版(派生フォント。tools/make-emacs-fonts.py で ~/Library/Fonts/ に生成)
;; Emacs の画面行の高さ = 行内フォントの ascent 最大 + descent 最大。Menlo は
;; 14px で 13/3=16px、素のヒラギノは 16px で 16/4=20px(lineGap 由来)なので
;; 混在行だけ伸びる。派生フォントは字形を変えず hhea/OS2 の縦メトリクスだけを
;; 揃えたもの。派生フォントが無いマシンでは message を出して stock-modern
;; (素の Menlo + ヒラギノ)に fallback する。
(defconst my-font-latin-menlo-emacs "Menlo Emacs"
  "Menlo 派生(14px で ascent 16 / descent 4 = 20px)の family 名。")
(defconst my-font-jp-hiragino-emacs2 "Hiragino Kaku Gothic ProN Emacs2"
  "ヒラギノ派生 v2(16px で ascent 16 / descent 4 = 20px)の family 名。")
(defconst my-font-jp-hiragino-emacs "Hiragino Kaku Gothic ProN Emacs"
  "ヒラギノ派生 v1(16px で ascent 12 / descent 2 = 14px)の family 名。比較用。")

(defun my-font--derived-or-fallback (latin jp)
  "派生フォント LATIN / JP が両方あればその組、無ければ素の Menlo + ヒラギノを返す。"
  (let ((missing (seq-remove (lambda (f) (find-font (font-spec :family f))) (list latin jp))))
    (if (null missing)
        (list latin jp)
      (message "my-font: %s が未生成のため stock-modern に fallback(tools/make-emacs-fonts.py 参照)"
               (string-join missing " / "))
      (list "Menlo" "Hiragino Kaku Gothic ProN"))))

(defun my-font--stock-modern-fixed ()
  "stock-modern の行高ズレ解消版(v2): Menlo Emacs + Hiragino Kaku ProN Emacs2。
両フォントとも「上 16 / 下 4 = 20px」= 元の日本語行と同じ寸法に揃えてあるので、
改行の有無・折り返しに関係なく全行 20px になり、全角の上下 2px の余裕が
カーソル箱の内側に入る(実測)。行ピッチ 20px は line-spacing 0 で得る。"
  (apply #'my-font--menlo-hiragino
         (my-font--derived-or-fallback my-font-latin-menlo-emacs
                                       my-font-jp-hiragino-emacs2)))

(defun my-font--stock-modern-fixed-v1 ()
  "比較用の旧版(v1): 素の Menlo + Hiragino Kaku ProN Emacs(ascender 880→760)。
改行を含む行は 16px に揃うが、折り返した日本語のみの行は 14px になり、
全角の字形上端(14px)が行上端(13px)より 1px はみ出してカーソル箱の上が
欠けて見える。v2 で解消したため比較用途のみ。"
  (apply #'my-font--menlo-hiragino
         (my-font--derived-or-fallback "Menlo" my-font-jp-hiragino-emacs)))

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
  '(("faithful-old"          . my-font--faithful-old)
    ("stock-modern"          . my-font--stock-modern)
    ("stock-modern-fixed"    . my-font--stock-modern-fixed)
    ("stock-modern-fixed-v1" . my-font--stock-modern-fixed-v1)
    ("udev-gothic"           . my-font--udev-gothic)
    ("plemol-jp"             . my-font--plemol-jp))
  "プリセット名 → 適用関数。")

;; Powerline 私用領域(PUA)グリフを Powerline 対応フォントで描くための割当。
;; powerlevel10k 等が使う区切り U+E0B0 / ブランチ記号 U+E0A0 は Menlo 等の通常
;; フォントに無く(use-default-font-for-symbols nil でも fontset 未割当)、放置すると
;; vterm 内の p10k プロンプトが別フォント(例: Hannotate TC の漢字)で化ける。
;; Powerline パッチ版 "Ricty for Powerline"(システム導入済み)を PUA 域へ prepend する。
;; ★ 既定 fontset(t)ではなく「選択フレームの fontset(nil)」へ入れる。t だと一度
;;   自動フォールバックで確定したフレーム側エントリに握りつぶされて効かない(実証済)。
;;   プリセット切替で fontset が作り直されても効くよう my-font-preset から都度呼ぶ。
(defun my-font--apply-powerline-glyphs ()
  "選択フレームの fontset で Powerline 域(U+E0A0..E0D4)を割当(GUI 時のみ)。"
  (when (and (display-graphic-p)
             (find-font (font-spec :family "Ricty for Powerline")))
    (set-fontset-font nil '(#xe0a0 . #xe0d4) "Ricty for Powerline" nil 'prepend)))

(defun my-font-preset (name)
  "フォントプリセット NAME を即時適用(目視比較用)。
未インストールフォントは既定にフォールバックする点に注意。"
  (interactive
   (list (completing-read "Font preset: "
                          (mapcar #'car my-font-presets) nil t)))
  (funcall (cdr (assoc name my-font-presets)))
  (my-font--apply-powerline-glyphs)     ; プリセット切替でも Powerline グリフを再割当
  (message "Font preset: %s → 実フォント family=%s height=%s"
           name (face-attribute 'default :family) (face-attribute 'default :height)))

(defvar my-font-default-preset "stock-modern-fixed"
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

;; 行間(各行の下に足す余白。整数 = px、小数 = 行高に対する割合)。
;; stock-modern-fixed(v2)は行の余裕をフォントの ascent/descent 側に持たせて
;; 全行 20px にしてあるため、ここは 0(= 行ピッチ 20px、v1 + line-spacing 4 と同じ)。
;; line-spacing の余白はカーソル箱の外側に付くので、箱の内側の余裕は作れない。
;; バッファローカル変数なので setq-default で既定値を変える。
(setq-default line-spacing 0)

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
      tab-bar-new-tab-to 'rightmost    ; 新規タブは末尾に追加(旧 elscreen 風)
      tab-bar-tab-hints t              ; タブに番号を表示
      tab-bar-close-button-show nil)
;; 新規タブ「+」ボタンを出さない
;; (旧 tab-bar-new-button-show は Emacs 28.1 で廃止 → tab-bar-format で制御)
(setq tab-bar-format '(tab-bar-format-history
                       tab-bar-format-tabs
                       tab-bar-separator))

;; 旧 elscreen の C-z b(elscreen-find-and-goto-by-buffer)相当。
;; 指定バッファが既にどれかのタブで表示中ならそのタブ(+そのウィンドウ)へ
;; 移動し、どのタブにも無ければ新しいタブを作ってそこに開く。
;; 組み込み tab-bar-get-buffer-tab(バッファを表示しているタブを返す)を利用。
(defun my-tab-find-buffer (buffer-or-name)
  "BUFFER-OR-NAME を表示しているタブへ移動、無ければ新タブで開く。"
  (interactive
   (list (read-buffer "Buffer (タブ移動 / 無ければ新タブ): "
                      (other-buffer (current-buffer)))))
  (let* ((buffer (get-buffer-create buffer-or-name))
         (tab (tab-bar-get-buffer-tab buffer)))
    (if tab
        ;; 既存タブで表示中 → そのタブへ切替し、当該ウィンドウを選択
        ;; (tab-bar-get-buffer-tab の戻り値に 0 始まりの index が入る。
        ;;  tab-bar-select-tab は 1 始まりのため 1+ する)
        (progn
          (tab-bar-select-tab (1+ (alist-get 'index tab)))
          (when-let ((win (get-buffer-window buffer)))
            (select-window win)))
      ;; どのタブにも無い → 新タブを作って開く
      (tab-bar-new-tab)
      (switch-to-buffer buffer))))

;; 旧 elscreen の C-z f(elscreen-find-file)相当。
;; 新しいタブを作り、そこでファイルを開く(C-z C-b の my-tab-find-buffer と対)。
(defun my-tab-find-file (filename)
  "新しいタブを作って FILENAME を開く(旧 elscreen の C-z f = elscreen-find-file 相当)。"
  (interactive (list (read-file-name "Find file (新タブで開く): ")))
  (tab-bar-new-tab)
  (find-file filename))

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
;; C-z C-b = 指定バッファのタブへ移動 / 無ければ新タブで開く
;;   (旧 elscreen の C-z b = elscreen-find-and-goto-by-buffer 相当。
(define-key elscreen-like-tab-map (kbd "C-b") #'my-tab-find-buffer)
;; タブ構成の undo/redo(履歴)
(define-key elscreen-like-tab-map (kbd "b")   #'tab-bar-history-back)
(define-key elscreen-like-tab-map (kbd "f")   #'tab-bar-history-forward)
;; C-z C-f = 新しいタブでファイルを開く(旧 elscreen の C-z f = elscreen-find-file 相当)
;;   (C-z f は tab-bar-history-forward(redo)のまま据え置き、新タブ open は C-z C-f)
(define-key elscreen-like-tab-map (kbd "C-f") #'my-tab-find-file)
;; C-z 1..9 で番号のタブへ
(dotimes (i 9)
  (define-key elscreen-like-tab-map (kbd (number-to-string (1+ i)))
              (let ((n (1+ i)))
                (lambda () (interactive) (tab-bar-select-tab n)))))

;; C-z C-s = 現在のタブと直前に選択していたタブの位置(内容)を入れ替える
;; (旧 elscreen デフォルトの C-z C-s = elscreen-swap 相当。elscreen 同様、
;;  交換後は元のタブ位置に留まる = 直前タブの内容が目の前に来る。
;;  自分の作業に戻るには C-z C-z(tab-recent)。もう一度 C-z C-s で元に戻る)
(defun my-tab-swap-with-recent ()
  "現在のタブと直前に選択していたタブの位置を入れ替える(旧 elscreen-swap 相当)。"
  (interactive)
  (let* ((tabs (funcall tab-bar-tabs-function))
         (current-index (tab-bar--current-tab-index tabs))
         (recent-index (tab-bar--tab-index-recent 1 tabs)))
    (if (null recent-index)
        (message "There is only one tab, cannot swap")
      (let ((tmp (nth current-index tabs)))
        (setf (nth current-index tabs) (nth recent-index tabs))
        (setf (nth recent-index tabs) tmp))
      (tab-bar-tabs-set tabs)
      (tab-bar-select-tab (1+ current-index)))))
(define-key elscreen-like-tab-map (kbd "C-s") #'my-tab-swap-with-recent)

;; C-z < / C-z > = 現在タブを左/右へ1つ移動(組み込み tab-bar-move-tab-backward / tab-move)。
;; repeat-mode 対応: 一度押した後は < / > 連打で連続移動(組み込み既定の M / m も可)。
(define-key elscreen-like-tab-map (kbd "<") #'tab-bar-move-tab-backward)
(define-key elscreen-like-tab-map (kbd ">") #'tab-move)
(define-key tab-bar-move-repeat-map (kbd "<") #'tab-bar-move-tab-backward)
(define-key tab-bar-move-repeat-map (kbd ">") #'tab-move)

;; C-z j = 現在のタブと直前に選択していたタブを1つのタブに統合する
;; (旧 elscreen デフォルトの C-z j = elscreen-link 相当)。現在のウィンドウを
;; 左右に分割し、右側に直前タブのバッファを表示して、直前タブを閉じる。
;; elscreen-link 同様、双方のタブがウィンドウ1つだけの時に限り動作し、
;; 統合後は持ってきた側(右)のウィンドウを選択する。
;; (elscreen-link の分割は上下だったが、左右分割に変更(ユーザー指定)。)
(defun my-tab-link ()
  "直前に選択していたタブのバッファを右側に持ってきて統合し、そのタブを閉じる。
現在のタブ・直前のタブともウィンドウが1つだけの時に限り動作する
(旧 elscreen の `C-z j' = elscreen-link 相当)。"
  (interactive)
  (let* ((tabs (funcall tab-bar-tabs-function))
         (recent-index (tab-bar--tab-index-recent 1 tabs))
         (current-number (1+ (tab-bar--current-tab-index tabs))))
    (cond
     ((null recent-index)
      (user-error "There is only one tab, no tab to link"))
     ((not (one-window-p 'nomini))
      (user-error "Current tab must have exactly one window"))
     (t
      (tab-bar-select-tab (1+ recent-index))
      (if (not (one-window-p 'nomini))
          (progn
            (tab-bar-select-tab current-number)
            (user-error "Recent tab must have exactly one window"))
        (let ((buffer (current-buffer))
              ;; 直前タブ上で閉じる → recency で自動的に元のタブへ戻る
              (tab-bar-close-tab-select 'recent))
          (tab-bar-close-tab)
          (select-window (split-window-right))
          (switch-to-buffer buffer)))))))
(define-key elscreen-like-tab-map (kbd "j") #'my-tab-link)


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
  (markdown-fontify-code-blocks-natively t)
  ;; ``` を 3 つ打った時に GFM コードブロックを自動挿入し言語を尋ねる
  ;; electric 挙動を無効化(markdown-electric-backquote を素の ` 挿入に戻す)。
  (markdown-gfm-use-electric-backquote nil)
  :config
  ;; C-c - (markdown-insert-hr = 水平線 --- 挿入) を外す(誤爆防止)。
  ;; C-c C-s - と M-x markdown-insert-hr からは引き続き呼べる。
  ;; gfm-mode-map は markdown-mode-map を親に持つので README(gfm-mode)でも効く。
  ;; 第 3 引数 t = 定義自体を除去(nil 上書きではない)。C-c - はグローバル未割当。
  (keymap-unset markdown-mode-map "C-c -" t))

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


;;; YAML (.yml / .yaml — CI / k8s / Ansible / Compose で頻出)
;;
;; Emacs 30 同梱の yaml-ts-mode(tree-sitter ベース、正確なパース)を
;; 優先採用。ただし:
;;   - YAML の tree-sitter grammar は同梱されていない。1 度だけ
;;       M-x treesit-install-language-grammar RET yaml RET
;;     をマシン上で実行して導入する(treesit-language-source-alist に
;;     下記で取得元を登録済み)。grammar の compile に C コンパイラと
;;     git が必要(macOS は Xcode Command Line Tools で揃う)。
;;   - 同梱モードは auto-mode-alist に自動登録されていない。
;;
;; grammar が未導入のマシンでも起動が壊れないよう、yaml-mode(MELPA、
;; 2026-04 更新で保守継続)を fallback として vendor。my-yaml-mode-dispatch
;; が visit 時に grammar の有無を見て ts-mode / 旧 mode を自動切替する
;; (grammar を後から入れて再 visit すれば自動で ts-mode に上がる)。
;;
;; LSP: eglot に既定で
;;   ((yaml-ts-mode yaml-mode) "yaml-language-server" "--stdio")
;; が登録されているため、yaml-language-server が PATH 上にあれば
;; eglot-ensure フックで自動起動・スキーマ検証(GitHub Actions / k8s /
;; Compose ほか)・補完が利く。新マシン setup の install 手順は
;; README.md「新マシンセットアップ」参照(volta install or pnpm add -g)。
(use-package yaml-mode :defer t)

(with-eval-after-load 'treesit
  (add-to-list 'treesit-language-source-alist
               '(yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(defun my-yaml-mode-dispatch ()
  "Pick `yaml-ts-mode' if YAML grammar is available, else `yaml-mode'.
`auto-mode-alist' で .yml / .yaml に登録するので、ファイル visit 時に
毎回判定される(grammar を後から入れた場合も再 visit だけで ts-mode に
切替わる)。"
  (if (and (fboundp 'treesit-language-available-p)
           (treesit-language-available-p 'yaml))
      (yaml-ts-mode)
    (yaml-mode)))

(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . my-yaml-mode-dispatch))

;; eglot 起動を YAML モードに hook(yaml-language-server が PATH に無ければ
;; eglot は静かにスキップする)。
(add-hook 'yaml-ts-mode-hook #'eglot-ensure)
(add-hook 'yaml-mode-hook    #'eglot-ensure)


;;; JavaScript / TypeScript (.js, .mjs, .cjs, .jsx, .ts, .tsx, .json)
;;
;; Emacs 30 同梱の tree-sitter 系メジャーモード(js-ts-mode /
;; typescript-ts-mode / tsx-ts-mode / json-ts-mode)を優先採用。grammar
;; が無いマシンでも安全に動くよう legacy mode を fallback に置く設計。
;;
;; ── mode dispatcher の方針 ─────────────────────────────────────
;;   .js / .mjs / .cjs   → js-ts-mode (grammar 有り) / js-mode (組み込み)
;;   .ts                  → typescript-ts-mode / typescript-mode (MELPA fallback)
;;   .tsx                 → tsx-ts-mode / typescript-mode (同)
;;   .jsx                 → tsx-ts-mode / typescript-mode  ★ ユーザー選択:
;;                          JSX も TS+JSX = TSX として一括扱い(現代の主流)
;;   .json                → json-ts-mode / js-json-mode (組み込み)
;; ファイル visit 時に dispatcher が grammar の有無を判定するため、grammar
;; を後から入れて再 visit すれば自動で ts-mode に上がる(YAML と同じ設計)。
;;
;; ── tree-sitter grammar ───────────────────────────────────────
;; 4 種類を treesit-language-source-alist に登録。各マシンで 1 度だけ:
;;   M-x treesit-install-language-grammar RET javascript RET
;;   M-x treesit-install-language-grammar RET typescript RET
;;   M-x treesit-install-language-grammar RET tsx RET
;;   M-x treesit-install-language-grammar RET json RET
;; (typescript / tsx は同一 repo の異なるサブディレクトリ)。
;; いずれの scanner も C(scanner.c)のみで C++ scanner は無いため、
;; YAML で必要だった c++ ビルドの workaround は要らない。
;; Apple Silicon でアーキ不一致が出た場合の手動 build は README 参照。
;;
;; ── LSP ───────────────────────────────────────────────────────
;; eglot 既定の eglot-server-programs に
;;   ((js-mode js-ts-mode tsx-ts-mode typescript-ts-mode typescript-mode)
;;    "typescript-language-server" "--stdio")
;; が登録済み。typescript-language-server (volta install) が PATH 上に
;; あれば各 mode で自動起動・補完・診断。
;;
;; ── format-on-save ────────────────────────────────────────────
;; apheleia を global 有効化。JS / TS / TSX / JSX / JSON / CSS /
;; Markdown / YAML 等の各種フォーマッタ(主に prettier、volta install
;; 済み)を保存時に自動適用する。フォーマッタが PATH に無い mode では
;; 何もしない(silent skip)。

;; TS / TSX の fallback mode(grammar 無いマシン用)
(use-package typescript-mode :defer t)

;; format-on-save(grammar の有無と無関係に global 有効化)
(use-package apheleia
  :config (apheleia-global-mode 1))

;; grammar 取得元の登録
(with-eval-after-load 'treesit
  (dolist (entry '((javascript "https://github.com/tree-sitter/tree-sitter-javascript")
                   (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                               "master" "typescript/src")
                   (tsx        "https://github.com/tree-sitter/tree-sitter-typescript"
                               "master" "tsx/src")
                   (json       "https://github.com/tree-sitter/tree-sitter-json")))
    (add-to-list 'treesit-language-source-alist entry)))

;; dispatcher 関数群
(defun my-js-mode-dispatch ()
  "Pick `js-ts-mode' if javascript grammar is available, else `js-mode'."
  (if (and (fboundp 'treesit-language-available-p)
           (treesit-language-available-p 'javascript))
      (js-ts-mode)
    (js-mode)))

(defun my-typescript-mode-dispatch ()
  "Pick `typescript-ts-mode' if grammar is available, else `typescript-mode'."
  (if (and (fboundp 'treesit-language-available-p)
           (treesit-language-available-p 'typescript))
      (typescript-ts-mode)
    (typescript-mode)))

(defun my-tsx-mode-dispatch ()
  "Pick `tsx-ts-mode' if grammar is available, else `typescript-mode'.
.tsx / .jsx の両方で使う(JSX も TS+JSX = TSX として扱う)。"
  (if (and (fboundp 'treesit-language-available-p)
           (treesit-language-available-p 'tsx))
      (tsx-ts-mode)
    (typescript-mode)))

(defun my-json-mode-dispatch ()
  "Pick `json-ts-mode' if json grammar is available, else `js-json-mode'."
  (if (and (fboundp 'treesit-language-available-p)
           (treesit-language-available-p 'json))
      (json-ts-mode)
    (js-json-mode)))

;; auto-mode-alist 登録(add-to-list は先頭挿入のため組み込みの
;; \\.js[mx]?\\' エントリより優先される)。
(add-to-list 'auto-mode-alist '("\\.[mc]?js\\'" . my-js-mode-dispatch))
(add-to-list 'auto-mode-alist '("\\.ts\\'"      . my-typescript-mode-dispatch))
(add-to-list 'auto-mode-alist '("\\.tsx\\'"     . my-tsx-mode-dispatch))
(add-to-list 'auto-mode-alist '("\\.jsx\\'"     . my-tsx-mode-dispatch))
(add-to-list 'auto-mode-alist '("\\.json\\'"    . my-json-mode-dispatch))

;; eglot 起動フック(JS/TS 系の主・fallback すべて)。
;; typescript-language-server が PATH に無ければ eglot は静かにスキップ。
(dolist (hook '(js-mode-hook
                js-ts-mode-hook
                typescript-ts-mode-hook
                tsx-ts-mode-hook
                typescript-mode-hook))
  (add-hook hook #'eglot-ensure))

;; インデント幅: JS/TS はスペース 2 を既定に(prettier の既定・一般的な
;; プロジェクト慣習に合わせる。indent-tabs-mode は大域設定で既に nil)。
;; いずれも defcustom の大域変数で、setq した値は以後の新規バッファに既定と
;; して効く(defcustom はロード時に既存値を上書きしないため先 setq で安全)。
;;   - js-indent-level                 : js-mode / js-ts-mode (.js/.mjs/.cjs)
;;   - typescript-ts-mode-indent-offset: typescript-ts-mode / tsx-ts-mode (.ts/.tsx/.jsx)
;;   - typescript-indent-level         : typescript-mode (MELPA fallback)
(setq js-indent-level 2)
(setq typescript-ts-mode-indent-offset 2)
(setq typescript-indent-level 2)


;;; zsh / zprezto 設定ファイル → sh-mode + zsh シェル指定
;;
;; 対象:
;;   - 基本: ~/.zshrc / ~/.zshenv / ~/.zprofile / ~/.zlogin / ~/.zlogout
;;     (+ .local 派生)
;;   - zprezto: ~/.zpreztorc、~/.zprezto/runcoms/*(zshrc / zshenv /
;;     zprofile / zlogin / zlogout / zpreztorc、いずれも拡張子なし)
;;   - 拡張子: *.zsh(zprezto modules の init.zsh 等)
;;
;; Emacs 30 既定では .zshrc 等は sh-mode には行くが、`sh-shell' は system
;; 依存(macOS は bash になることがある)。`[[ ]]' / `${(P)var}' / `setopt'
;; / `autoload -U' といった zsh 固有構文を正しく font-lock させるため、
;; 専用 dispatcher で sh-mode 起動後に `sh-set-shell' で zsh を明示する。
;; `.zpreztorc' / runcoms/* は既定で auto-mode-alist にも無いので同時に登録。
(declare-function sh-set-shell "sh-script")  ; byte-compile に既知化

(defun my-zsh-script-mode ()
  "Enter `sh-mode' and set `sh-shell' to zsh.
For zsh init files (.zshrc, .zshenv, ~/.zprezto/runcoms/*, etc.) that
don't carry a #! shebang -- ensures zsh-flavored font-lock and indent.
NO-QUERY-FLAG=t / INSERT-FLAG=nil で query 抑止+shebang 不挿入。"
  (sh-mode)
  (sh-set-shell "zsh" t nil))

(dolist (re '("/\\.zshrc\\(\\.local\\)?\\'"
              "/\\.zshenv\\(\\.local\\)?\\'"
              "/\\.zprofile\\(\\.local\\)?\\'"
              "/\\.zlogin\\(\\.local\\)?\\'"
              "/\\.zlogout\\(\\.local\\)?\\'"
              "/\\.zpreztorc\\'"
              "/\\.zprezto/runcoms/[^/.]+\\'"
              "\\.zsh\\'"))
  (add-to-list 'auto-mode-alist (cons re #'my-zsh-script-mode)))


;;; direnv の .envrc → sh-mode + bash シェル指定
;;
;; .envrc は direnv の設定ファイルで、中身は bash スクリプト(direnv の
;; stdlib `export` / `layout` / `use` / `source_env` / `[[ ]]' 等を使う)。
;; 拡張子が無いため既定では fundamental-mode になり色付けもインデントも
;; 効かない。bash として編集できるよう sh-mode を割り当て、zsh と同様に
;; `sh-set-shell' で bash を明示して font-lock を bash 方言に固定する。
;; ここで足すのは「.envrc を編集するモード」のみ。direnv が設定する環境
;; 変数を Emacs 内のバッファへ反映する統合(envrc / direnv パッケージ)は
;; 別機能のため導入しない(必要になったら別途検討)。
(defun my-envrc-mode ()
  "Enter `sh-mode' and set `sh-shell' to bash for direnv .envrc files.
.envrc は shebang を持たないため、bash 方言の font-lock / indent を
得るよう明示する。NO-QUERY-FLAG=t / INSERT-FLAG=nil で query 抑止+
shebang 不挿入。"
  (sh-mode)
  (sh-set-shell "bash" t nil))

(add-to-list 'auto-mode-alist '("/\\.envrc\\(\\.local\\)?\\'" . my-envrc-mode))


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

;; diff-hl(VCS の未コミット変更をフリンジ表示)
;;   git 等で追跡中のファイルを編集すると、各行の変更(追加/変更/削除)を
;;   バッファ左端フリンジに色付き表示。magit とは補完関係(magit=コミット/
;;   差分閲覧、diff-hl=編集中の行レベル可視化)。
;;   - global-diff-hl-mode: 全ファイルで ON(ただし ~/ob/ 配下は除外。下記)
;;   - diff-hl-flydiff-mode: 保存前でもライブに更新
;;   - magit 連携フック: stage/commit 後にフリンジ表示を自動更新
;;   - dired 連携: dired のファイル一覧にも変更状態を表示
;;   キーは diff-hl 既定の C-x v 配下(diff-hl-mode-map)をそのまま使用:
;;     C-x v [ / ]  前/次のハンクへ
;;     C-x v *      そのハンクの変更内容をポップアップ表示
;;     C-x v n      そのハンクだけ HEAD に戻す(diff-hl-revert-hunk)
;;     C-x v S      そのハンクをステージ(diff-hl-stage-dwim)
;;     C-x v =      diff-hl-diff-goto-hunk(組み込み vc-diff を remap。
;;                  diff-hl-mode のバッファ内のみ。diff 表示の役割は維持)
;;   端末(-nw、フリンジ無し)では M-x diff-hl-margin-mode でマージン表示に。
(use-package diff-hl
  :demand t                               ; :hook で遅延化されるのを上書きし
                                        ; 起動時にロード→global mode を有効化
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode         . diff-hl-dired-mode))
  :config
  ;; ~/ob/(Obsidian vault)配下では diff-hl を無効化する。
  ;;   例: ~/worklog.md は vault 内ファイルへの symlink で、Emacs は truename
  ;;   (~/ob/Main/Journals/...)で開くため git 配下と認識される。すると編集の
  ;;   たびに diff-hl-flydiff が同期 git diff を起動し、初回コールド時に一瞬
  ;;   固まる。ジャーナルに git ガターは不要なのでバッファ単位で OFF にする。
  ;;   diff-hl-flydiff-update は (not diff-hl-mode) で即 return するため、
  ;;   diff-hl-mode を切れば flydiff の git 起動も止まる。
  (defun my-diff-hl-disable-under-ob ()
    "Turn off `diff-hl-mode' for files under ~/ob/ (Obsidian vault)."
    (when (and diff-hl-mode              ; ON にされた時だけ作用(再帰防止ガード)
               buffer-file-name
               (string-prefix-p
                (file-name-as-directory
                 (file-truename (expand-file-name "ob" "~")))
                (file-truename buffer-file-name)))
      (diff-hl-mode -1)))
  (add-hook 'diff-hl-mode-hook #'my-diff-hl-disable-under-ob)
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))

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

;; --- undo-tree: 導入見送り(代わりに vundo を採用)---
;; 分岐 undo + ツリー可視化。動作はするが巨大ファイルで重く、履歴破損の
;; 不具合歴もある。そのため undo-tree 自体は不採用とし、分岐の可視化は
;; 軽量な `vundo`(組み込み undo をそのまま使い、可視化 UI だけ足す)で行う。

;; --- vundo: undo 履歴の分岐をツリー表示して行き来 ---
;; 組み込み undo は線形に巻き戻すが、分岐した過去状態へ移りたいときに
;; vundo でツリーを表示し視覚的に移動できる。組み込み undo をそのまま
;; 可視化するだけなので undo-tree のような履歴破損がなく軽量。
;; C-x u を既定 undo(C-/ や C-_ と重複)から vundo に置換。
;; vundo バッファ内: f/b=次/前の状態へ、n/p=分岐の上下、d=diff、q=終了、
;;   RET=その状態で確定。
(use-package vundo
  :bind ("C-x u" . vundo))

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
;;;  *scratch* 永続化(旧 inits/50-scratch.el)
;;; ============================================================
;; *scratch* バッファをディスクに保存して起動時に復元する。
;;   - 起動時: 保存ファイルから *scratch* に読込。
;;   - Emacs 終了時: 変更があれば保存(advice-add で save-buffers-kill-emacs)。
;;   - *scratch* で C-x C-s: 専用の保存関数で書き出す。
;;   - *scratch* を kill-buffer: 実際には削除せず内容クリアにすり替え。
;;   - 別ファイル save 後に *scratch* が消えていたら自動再生成。
;;
;; 保存先は user-emacs-directory(= init.el のあるディレクトリ)直下の
;; ".scratch-<hostname>"。旧設定は Dropbox 配下を優先していたが現在は
;; Dropbox を使っていないためシングルマシン用途として emacs home に
;; 集約(ユーザー指示)。マシン間の取り違え防止のため hostname suffix は
;; 旧仕様どおり付ける(将来マシンが増えても混線しない)。`.scratch*`
;; パターンで .gitignore 除外済み。
;;
;; 現代化:
;;   - 旧 (defadvice save-buffers-kill-emacs ...) → advice-add :before。
;;   - 旧 find-file-noselect + erase + insert + save-buffer の保存処理は
;;     write-region 一発に簡略化(*scratch* 用の中間バッファを作らない)。
;;   - 旧 scratch-dirname の Dropbox 分岐は削除。
;;   - 旧 hostname-short(`inits/00-environments.el` 由来、未移植)への
;;     依存を解消し、`(system-name)` をドットで分割して先頭=短い
;;     ホスト名を小文字化する純組み込みロジックに置換。
;;   - 命名規則を my-* に統一(旧 scratch-* / my-make-scratch が混在)。

(defun my-scratch--short-hostname ()
  "Return the local short hostname, downcased.
`(system-name)' の FQDN 先頭部分を切り出して小文字化する。取得不能なら
空文字列。旧 `hostname-short' ヘルパの置換(`inits/00-environments.el'
未移植のため自前で実装)。"
  (let ((h (or (system-name) "")))
    (downcase (or (car (split-string h "[.]")) ""))))

(defvar my-scratch-file
  (let* ((host (my-scratch--short-hostname))
         (name (if (string-empty-p host)
                   ".scratch"
                 (concat ".scratch-" host))))
    (expand-file-name name user-emacs-directory))
  "*scratch* の永続化ファイルパス。Emacs 終了時に保存、起動時に復元。
hostname suffix 付き(将来複数マシンに展開した際の混線防止)。")

(defvar my-scratch-save-option 'default
  "*scratch* を Emacs 終了時に保存するかの判定モード。
- `force-save'       : 必ず保存
- `force-donot-save' : 必ず保存しない
- `default'          : *scratch* が buffer-modified なら保存、無変更なら省略")

(defun my-scratch-donot-save ()
  "今セッションの Emacs 終了時に *scratch* を保存しない設定にする。"
  (interactive)
  (setq my-scratch-save-option 'force-donot-save))

(defun my-scratch-save-p ()
  "*scratch* を保存すべきなら non-nil。"
  (pcase my-scratch-save-option
    ('force-save       t)
    ('force-donot-save nil)
    (_ (and (get-buffer "*scratch*")
            (with-current-buffer "*scratch*" (buffer-modified-p))))))

(defun my-make-scratch (&optional arg)
  "*scratch* バッファを再生成 / クリアする。
ARG = 0(または nil)で内容クリアして switch、ARG = 1 で別の *scratch* を
作るだけ(switch しない)。"
  (interactive)
  (with-current-buffer (get-buffer-create "*scratch*")
    (funcall initial-major-mode)
    (erase-buffer)
    (when (and initial-scratch-message (not inhibit-startup-message))
      (insert initial-scratch-message))
    (set-buffer-modified-p nil))
  (cond
   ((or (null arg) (eq arg 0))
    (switch-to-buffer "*scratch*")
    (message "*scratch* is cleared up."))
   ((eq arg 1)
    (message "another *scratch* is created"))))

(defun my-scratch-save ()
  "*scratch* の内容を `my-scratch-file' に書き出す。"
  (interactive)
  (when-let* ((buf (get-buffer "*scratch*")))
    (with-current-buffer buf
      (write-region (point-min) (point-max) my-scratch-file nil 'silent)
      (set-buffer-modified-p nil))))

(defun my-scratch-load ()
  "`my-scratch-file' があれば *scratch* に読み込む。"
  (interactive)
  (when (file-exists-p my-scratch-file)
    (with-current-buffer (get-buffer-create "*scratch*")
      (erase-buffer)
      (insert-file-contents my-scratch-file)
      (set-buffer-modified-p nil))
    (message "loaded *scratch* from %s" my-scratch-file)))

(defalias 'my-scratch-reload 'my-scratch-load)

;; 起動時に保存ファイルから読込(*scratch* バッファは Emacs 起動初期に
;; 既に作られているので get-buffer-create で取り直して上書きする)。
(my-scratch-load)

;; *scratch* で kill-buffer は内容クリアにすり替え。
(add-hook 'kill-buffer-query-functions
          (lambda ()
            (if (string= "*scratch*" (buffer-name))
                (progn (my-make-scratch 0) nil)
              t)))

;; 別ファイル save 後に *scratch* が消えていたら自動再生成。
(add-hook 'after-save-hook
          (lambda ()
            (unless (get-buffer "*scratch*")
              (my-make-scratch 1))))

;; Emacs 終了時に *scratch* を保存(旧 defadvice → advice-add)。
(advice-add 'save-buffers-kill-emacs :before
            (lambda (&rest _)
              (when (my-scratch-save-p)
                (my-scratch-save))))

;; *scratch* で C-x C-s は `my-scratch-save'(他のバッファは通常通り)。
(defun my-scratch-save-buffer-wrapper ()
  "*scratch* なら `my-scratch-save'、それ以外は通常の `save-buffer'。"
  (interactive)
  (if (string= (buffer-name) "*scratch*")
      (my-scratch-save)
    (save-buffer)))
(add-hook 'lisp-interaction-mode-hook
          (lambda ()
            (local-set-key (kbd "C-x C-s") #'my-scratch-save-buffer-wrapper)))


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

;; --- 括弧の深さ色分け(rainbow-delimiters)---
;; ネストした括弧 () [] {} を深さごとに色分けして対応関係を見やすくする。
;; lisp 系で特に有用だが prog-mode 全般で無害なため prog-mode 共通で有効化。
;; (show-paren-mode との併用可: show-paren は対応 1 組の強調、rainbow は全階層)
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; --- 意味単位での選択範囲の拡大/縮小(expand-region)---
;; C-= を押すごとに「単語 → 文字列 → 括弧内 → 式 → 行 → 関数 …」と
;; 意味のまとまり単位でリージョンを段階的に拡大する。拡大ループ中は
;; - で 1 段縮小、0 で最初に戻す。multiple-cursors と好相性
;; (選択を広げてから C->/C-c C-< 等で増殖させる使い方)。
;; transient-mark-mode nil でもリージョンをアクティブ化するため、
;; delete-selection-mode(入力で置換)もそのまま効く。
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; --- ヘルプバッファの強化(helpful)---
;; 組み込み describe-* の上位互換。docstring に加えてソース埋め込み・変数の
;; 現在値・呼び出し元・付与された advice / symbol property・edebug/trace 等を
;; 1 画面で表示する(deadgrep と同じ Wilfred Hughes 作)。
;;
;; キー方針(ユーザー確認済み): 本設定は C-h を backspace(DEL)に
;; keyboard-translate 済みで、ヘルプの入口は C-c h(= help-command = help-map)
;; と <f1>。そのため help-map 内の f/v/k/o だけを helpful 版へ差し替える。
;; これで C-c h f / <f1> f 等が helpful になり、C-h→DEL や入口キーには触れない。
;; 他の help 既定(C-c h F = Info-goto-emacs-command-node 等)は温存。
(use-package helpful
  :bind (:map help-map
              ("f" . helpful-callable)    ; was describe-function(関数+マクロ)
              ("v" . helpful-variable)    ; was describe-variable
              ("k" . helpful-key)         ; was describe-key
              ("o" . helpful-symbol)))    ; was describe-symbol

;; --- Multi-cursor: multiple-cursors + 拡張 3 つ ---
;; 複数カーソルを同時に持って並列編集する(VS Code / Sublime 風)。
;; 旧設定では未使用、本リビルドで新規追加。
;;
;; ## 構成
;;   - multiple-cursors (本命): 実カーソルを複数化、ほぼ全 Emacs コマンドが
;;     並列実行される
;;   - mc-extras: cycle / rectangle 連動 等の追加コマンド集
;;   - phi-search: multiple-cursors と互換性のある isearch 代替
;;                 (mc モード中だけ C-s/C-r が phi-search に切替わる)
;;   - iedit: 別パラダイム — シンボルの全出現を overlay で同時編集
;;
;; ## 主なキーバインド
;;   --- mc カーソル増殖の入口(global)---
;;   C-S-c C-S-c   mc/edit-lines               選択範囲の各行先頭に cursor
;;   C->           mc/mark-next-like-this      現選択 (or word) と同じ語の
;;                                             次の出現に cursor 追加
;;   C-<           mc/mark-previous-like-this  前の出現に追加
;;   C-c C-<       mc/mark-all-like-this       全出現に一気に
;;   C-c C-S-l     mc/edit-lines               同上の alias(2 ストローク版)
;;
;;   --- mc-extras / mc/insert-* ---
;;   C-c C-n       mc/insert-numbers           各 cursor 位置に 0,1,2,...
;;   C-c C-l       mc/insert-letters           各 cursor 位置に a,b,c,...
;;
;;   --- mc 終了 ---
;;   C-g                 全 cursor を解除
;;   RET                 mc を抜けて通常の cursor 1 個に戻る
;;
;;   --- mc モード中の検索(phi-search 自動切替)---
;;   C-s / C-r           通常時は isearch、mc モード中は phi-search に切替
;;
;;   --- iedit ---
;;   C-;                 iedit-mode (point 上のシンボル全出現を同時編集)
;;                       同じキーで終了
;;
;; ## 補助ファイル
;;   mc は「ユーザーが許可した一回限り/全体実行コマンドのリスト」を
;;   .mc-lists.el に保存する。本リビルドでは user-emacs-directory 配下に
;;   集約し、.gitignore で除外(per-machine 状態のため)。
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C-c C-S-l"   . mc/edit-lines)        ; 上の alias(2 ストローク)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-c C-n"     . mc/insert-numbers)
         ("C-c C-l"     . mc/insert-letters))
  :custom
  (mc/list-file (expand-file-name ".mc-lists.el" user-emacs-directory)))

(use-package mc-extras :after multiple-cursors)

(use-package phi-search
  :after multiple-cursors
  :config
  ;; mc モード中だけ C-s / C-r を phi-search に切替(mc/keymap は
  ;; cursor が複数の間だけ有効になる minor keymap)。
  (with-eval-after-load 'multiple-cursors-core
    (define-key mc/keymap (kbd "C-s") #'phi-search)
    (define-key mc/keymap (kbd "C-r") #'phi-search-backward)))

(use-package iedit
  :bind (("C-;" . iedit-mode)))


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
;;;  Diagnostics 基盤: flymake + eglot(両方 Emacs 同梱)
;;; ============================================================
;; 旧 `flycheck` + 各 `flymake-*` チェッカ群の現代代替。
;;   - `flymake` (Emacs 26+) は警告表示フレームワーク。バッファ内
;;     ハイライト + fringe マーカで diagnostics を出す。
;;   - `eglot` (Emacs 29+) は LSP クライアント。各言語サーバの警告を
;;     flymake をディスプレイとして表示する。
;; どちらも autoload 済みのため追加 elpa 不要。
;;
;; 設計方針:
;;   - 各メジャーモードへの eglot 起動は **当該メジャーモードのセクション**
;;     で `(add-hook '<lang>-(ts-)mode-hook #'eglot-ensure)` を足す形に
;;     統一(YAML セクションで実証済)。今後 JS/TS / PHP / Lua 等を
;;     移植する時も同じ。本セクションは「土台」だけ持つ。
;;   - flymake は **elisp 編集中だけ常時 on**。`prog-mode` 全般へ push
;;     すると backend を持たないモードでも minor mode が走るため避ける。
;;     LSP 連動が必要な言語では eglot が起動時に flymake-mode も
;;     enable してくれる(eglot 既定挙動)。
;;   - diagnostic 間の移動: flymake は `next-error` フレームワークに
;;     登録されるため、**組み込み `M-g n` / `M-g p`** (next-error /
;;     previous-error)で前後の警告へジャンプ可。専用キーは追加しない
;;     (symbol-overlay の M-n / M-p と衝突しない)。
;;   - `C-h .` (display-local-help) でカーソル位置の diagnostic 詳細表示。

;; elisp 編集中の byte-compile 警告 / checkdoc をリアルタイム表示。
(add-hook 'emacs-lisp-mode-hook #'flymake-mode)

(with-eval-after-load 'eglot
  ;; 最後のバッファが閉じたら eglot サーバを自動 shutdown
  ;; (サーバプロセスが残らないようリソース節約)。
  (setq eglot-autoshutdown t))


;;; ============================================================
;;;  バッファ内補完 UI(corfu + cape)
;;; ============================================================
;; corfu: completion-at-point(CAPF)の候補を、点の位置にポップアップ表示する
;;   現代版の補完 UI(company の後継)。eglot(LSP)の補完もそのまま corfu に出る。
;; cape: CAPF を増やす拡張。dabbrev(開いているバッファ内の語)やファイルパス等の
;;   汎用補完源をフォールバックとして足す。
;; ミニバッファ補完は global-corfu-mode の対象外(既定)。将来 vertico を入れても
;;   棲み分けるため衝突しない。補完スタイルに orderless を入れると corfu とミニ
;;   バッファの双方に効く(現状は Emacs 既定スタイルのまま)。
(use-package corfu
  :custom
  (corfu-auto t)                  ; 入力に応じて自動でポップアップ(手動派は nil に)
  (corfu-auto-delay 0.2)          ; ポップアップ表示までの遅延(秒)
  (corfu-auto-prefix 2)           ; 2 文字以上入力で自動発火
  (corfu-cycle t)                 ; 候補の末尾↔先頭を循環移動
  (corfu-quit-no-match 'separator) ; 候補ゼロでも separator 入力中は閉じない
  :init
  (global-corfu-mode)             ; 全バッファ(ミニバッファ除く)で有効化
  (corfu-popupinfo-mode)          ; 選択中候補の説明を遅延ポップアップ表示
  (corfu-history-mode)            ; 確定履歴順で候補をソート(savehist と連携)
  :config
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package cape
  :init
  ;; 末尾に追加(add-hook の APPEND=t)。各メジャーモード固有 / eglot の CAPF を
  ;; 優先させ、dabbrev・file はフォールバックとして後ろに置く。
  (add-hook 'completion-at-point-functions #'cape-dabbrev t)  ; 開いている語
  (add-hook 'completion-at-point-functions #'cape-file t))    ; ファイルパス


;;; ============================================================
;;;  ミニバッファ補完 UI(vertico + orderless + marginalia + consult)
;;; ============================================================
;; corfu(バッファ内補完)と対になる「ミニバッファ側」の刷新スタック。
;; 旧 ivy / counsel / swiper / smex の現代代替(CLAUDE.md「Option B」)。
;;   - vertico:    M-x / C-x C-f / C-x b 等の候補を縦型リストで表示する UI
;;   - orderless:  スペース区切りで部分一致を AND 絞り込みする補完スタイル
;;                 (corfu のバッファ内補完にも同時に効く)
;;   - marginalia: 候補の右に注釈(コマンドのキー/docstring、変数の値、
;;                 ファイル属性など)を表示
;;   - consult:    completing-read を使う高機能コマンド群(行検索/バッファ
;;                 切替/grep/imenu/flymake 等)。多くがプレビュー付き
;; ミニバッファ履歴は既に有効な savehist-mode が永続化する。
;; C-s(isearch+migemo)と M-y(yank-from-kill-ring)は従来方針を尊重し不変更。

(use-package vertico
  :custom (vertico-cycle t)             ; 候補の末尾↔先頭を循環
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (("C-x b"   . consult-buffer)          ; 強化版バッファ切替(+ recentf 等)
         ("C-x p b" . consult-project-buffer)  ; プロジェクト内バッファ
         ("M-g g"   . consult-goto-line)       ; 行ジャンプ(プレビュー付)
         ("M-g M-g" . consult-goto-line)
         ("M-g i"   . consult-imenu)           ; 関数/見出しへジャンプ
         ("M-g f"   . consult-flymake)         ; diagnostics 一覧へ
         ("M-s l"   . consult-line)            ; バッファ内 行検索(swiper 相当)
         ("M-s r"   . consult-ripgrep)         ; プロジェクト grep(要 rg)
         ("M-s d"   . consult-find))           ; ファイル名で検索
  :init
  ;; xref(eglot の定義ジャンプ等)の結果一覧も consult UI で表示
  (setq xref-show-xrefs-function       #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (setq consult-narrow-key "<"))               ; 絞り込みソース切替キー

;; --- embark: 候補/対象への文脈アクション(右クリック相当)---
;; ミニバッファ候補やカーソル下の対象(ファイル/シンボル/URL/バッファ 等)に
;; 「定義へ/削除/kill/ブラウズ/別ウィンドウで開く…」等を一覧から実行する。
;; vertico/consult と好相性。embark-consult を入れると consult 結果バッファ
;; からも同じアクション + プレビューが効く。
;; キー: 定番の C-. / C-; は既存(next-buffer / iedit)で使用済みのため
;;       C-c . / C-c ; に割当(衝突回避、ユーザー確認済み)。
(use-package embark
  :bind (("C-c ." . embark-act)          ; 対象にアクションを実行
         ("C-c ;" . embark-dwim)         ; 既定アクションを実行(dwim)
         (:map help-map ("B" . embark-bindings)))) ; C-c h B / <f1> B: キー一覧

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; --- avy: 画面内の任意位置へ数キーでジャンプ ---
;; 表示中の文字/単語/行に、入力に応じたヒントキーが割り振られ、それを打つと
;; 一気にカーソル移動する(マウスや長距離移動の代替)。
;; キーはいずれも空きを確認済み(C-: / C-' / M-g w / M-g l)。
(use-package avy
  :bind (("C-:"   . avy-goto-char-timer)   ; 文字列を打つと候補が絞られてジャンプ
         ("C-'"   . avy-goto-char-2)        ; 連続 2 文字でジャンプ
         ("M-g w" . avy-goto-word-1)        ; 単語の先頭へジャンプ
         ("M-g l" . avy-goto-line)))        ; 行頭へジャンプ(consult-goto-line とは別系統)


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
;;;  検索 — deadgrep(高速 grep + 結果を直接編集)
;;; ============================================================
;; 旧 inits/50-ag.el(ag.el + wgrep-ag)の置換移植。調査の結果:
;;   - `ag.el' は 2020 以降更新が止まっており、推奨できない。
;;   - 検索バイナリは `ag' → `rg'(ripgrep)が事実上の現代標準。
;;   - 現代の対応する front-end は `deadgrep'(ag.el と同じ
;;     Wilfred Hughes 作・保守継続中)。検索→結果バッファ→
;;     インライン編集 という旧 UX を素直に置き換えられる。
;;   - 一括編集は `wgrep' + `wgrep-deadgrep' で旧 wgrep-ag の役割を担う。
;;
;; ── 新マシン setup: ripgrep のインストール ────────────────────
;;   macOS:           brew install ripgrep      (rg 本体)
;;   Debian / Ubuntu: sudo apt install ripgrep
;;   Arch:            sudo pacman -S ripgrep
;;   その他: https://github.com/BurntSushi/ripgrep#installation
;; rg が無いマシンでは use-package :if が偽となり deadgrep/wgrep-deadgrep
;; 関連は全体スキップされる(起動エラーにはならない)。
;; ─────────────────────────────────────────────────────────────────
;;
;; 使い方:
;;   M-x deadgrep <RET> <パターン>  で検索。結果バッファに飛ぶ。
;;   結果バッファ内:
;;     n / p   次/前のマッチへ
;;     RET     ファイルを開く
;;     g       再検索
;;     r       wgrep モードに入る(旧 ag.el の `wgrep-enable-key "r"' 忠実)
;;       → 文字列を編集 → C-c C-c でファイルへ反映
;;       (wgrep-auto-save-buffer t により保存も自動)
;;
;; 旧 50-ag.el との対応:
;;   ag-highlight-search t   → deadgrep 既定でハイライト ON
;;   ag-reuse-buffers nil    → deadgrep 既定で検索ごとに別バッファ
;;   wgrep-auto-save-buffer t → そのまま設定(下記)
;;   wgrep-enable-key "r"     → そのまま設定(下記)

(use-package deadgrep
  :if (executable-find "rg")
  :commands (deadgrep))

(use-package wgrep
  :defer t
  :init
  (setq wgrep-auto-save-buffer t   ; 旧 50-ag.el 忠実
        wgrep-enable-key       "r"))

(use-package wgrep-deadgrep
  :if (executable-find "rg")
  :after deadgrep
  :hook (deadgrep-finished . wgrep-deadgrep-setup))


;;; ============================================================
;;;  検索・置換 チートシート(旧 color-moccur / moccur-edit の代替メモ)
;;; ============================================================
;; 旧 inits/20-color-moccur.el(color-moccur + moccur-edit)は
;; 移植しない方針(CLAUDE.md チェックリスト参照):
;;   - color-moccur: MELPA 2014-12 以降更新なし、事実上停止
;;   - moccur-edit:  MELPA から消失して入手不能
;;   - 主用途(再帰ファイル grep+結果編集)は deadgrep + wgrep-deadgrep
;;     で移植済み(上のセクション)
;;   - 残る用途は現代 Emacs の組み込みで完全代替可能
;; 用途別の代替コマンドを以下にメモする(設定不要、autoload 済み)。
;;
;; ── 単一バッファ内の正規表現 occur ──
;;   M-s o                    `occur'(同 M-x occur)
;;   ↑ 現バッファで該当行を結果バッファに集約
;;
;; ── 複数バッファ横断検索(旧 moccur / C-u moccur 相当)──
;;   M-x multi-occur                  ← 任意のバッファを対話で選んで一括 occur
;;   M-x multi-occur-in-matching-buffers
;;       ← バッファ名の正規表現でフィルタしてから一括 occur
;;
;; ── occur 結果バッファ内で編集(旧 moccur-edit 相当)──
;;   occur 結果バッファに移動して:
;;     e            ← `occur-edit-mode'(編集モード ON)
;;     編集する
;;     C-c C-c      ← 編集をソースバッファに反映して edit-mode を抜ける
;;     C-c C-k      ← 編集を破棄して抜ける
;;   反映後はソースバッファが「変更済み」状態になるだけで自動 save
;;   されない。各バッファで C-x s 等で別途保存。
;;
;; ── 再帰ファイル grep(旧 moccur-grep-find / moccur-grep、C-t m 相当)──
;;   M-x deadgrep                     ← ripgrep バックエンド、上の deadgrep
;;                                       セクション参照。結果バッファ内 r
;;                                       で wgrep モード → C-c C-c で反映
;;
;; ── dired でマーク済みファイル群に検索(旧 dired-do-moccur 相当)──
;;   dired バッファで:
;;     m            ← ファイルをマーク
;;     A            ← `dired-do-find-regexp'(マーク済みファイル群に正規表現
;;                    検索、xref バッファに表示)
;;     Q            ← `dired-do-find-regexp-and-replace'(マーク済みファイル
;;                    群で正規表現置換)
;;
;; ── プロジェクト範囲の検索/置換(関連)──
;;   C-x p g                  `project-find-regexp'(project.el)
;;   C-x p r                  `project-query-replace-regexp'
;;   xref 結果バッファで E    `xref-query-replace-in-results'(一括置換)
;;
;; ── 旧 dmoccur-exclusion-mask(.git/.svn/画像/build/coverage 等)──
;;   deadgrep(rg)は .gitignore を自動尊重するため、明示の除外マスクは
;;   原則不要。プロジェクト固有の追加除外は .ignore / .rgignore に記述。


;;; ============================================================
;;;  未移植: カスタム関数依存
;;;  (旧 inits/50-window.el, 50-edit.el, 50-edit-helper.el,
;;;   50-view-mode.el を移植したらコメントを外す)
;;; ============================================================

;; --- 50-window.el: ウィンドウ操作 ---
;; M-o の other-window-or-split は移植済み(上の Keybindings セクション参照、
;; my-other-window-or-split / split-window-sensibly 版)。C-tab には割当てない。
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
;; 不採用(CLAUDE.md チェックリスト参照)。主用途の再帰ファイル grep
;; +結果編集は deadgrep + wgrep-deadgrep へ移植済み。代替コマンド早見表は
;; 上記「検索・置換 チートシート」セクションを参照。

;; --- undo-tree ---
;; (define-key undo-tree-map (kbd "\C-_") 'undefined)

;; --- key-chord(2つのキー同時押し)---
;; 上記「ビューモード(ページャ)」セクションへ use-package で移植済み
;; (jk → view-mode)。

;; --- elscreen(廃止気味。参考)---
;; 旧 elscreen 配下の moccur 連動コマンド(C-z m / C-z C-m)も
;; color-moccur 不採用に伴い廃止。タブ切替は組み込み tab-bar-mode へ
;; 移植済み(上の「タブ」セクション)。

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


;;; ============================================================
;;;  AI エージェント連携: agent-shell (ACP / Claude)
;;; ============================================================
;; Claude 等の AI コーディングエージェントを Emacs バッファから対話操作する
;; フロントエンド。モデル実行は外部 ACP アダプタ claude-agent-acp に委譲。
;; 依存 acp / shell-maker は use-package が自動導入(elpa/ を git 管理)。
;;
;; ── 事前セットアップ(ターミナルで1回、詳細は README) ──────────
;;   volta install @agentclientprotocol/claude-agent-acp
;;   which claude-agent-acp           ; ~/.volta/bin に入ることを確認
;;   (:login t はサブスク認証。Claude Code で一度ログイン済みであること)
;; ── 認証 ───────────────────────────────────────────────
;;   :login t = サブスクリプション(claude ログイン)を再利用。
;;   ★ API キーを init.el に直書きしない(git に乗る)。鍵を使う場合のみ
;;     auth-source 経由の lambda 形式にする(下のコメント参照)。
;; ── claude-agent-acp が無いマシンでは :if で全体スキップ(起動エラーなし) ──

(use-package agent-shell
  :if (executable-find "claude-agent-acp")
  :commands (agent-shell)              ; 起動はグローバルキー無し = M-x agent-shell
  :config
  ;; サブスクリプション認証(鍵を書かない・推奨)
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))

  ;; (任意) API キーを使う場合の例。リテラル直書きは厳禁。auth-source 経由:
  ;; (setq agent-shell-anthropic-authentication
  ;;       (agent-shell-anthropic-make-authentication
  ;;        :api-key (lambda () (auth-source-pick-first-password
  ;;                             :host "api.anthropic.com"))))

  ;; (任意) PATH で解決できない場合はアダプタの絶対パスを明示:
  ;; (setq agent-shell-anthropic-claude-acp-command
  ;;       (list (expand-file-name "claude-agent-acp" "~/.volta/bin")))

  ;; (任意・隔離寄せ) ファイル読み書き能力を切る(devcontainer 運用時など):
  ;; (setq agent-shell-text-file-capabilities nil)
  )


;;; ============================================================
;;;  ターミナル: vterm (libvterm ベースの Emacs 内ターミナル)
;;; ============================================================
;; eat は issue #262(全角/罫線連続で O(n^2) ハング、Claude Code バナーで再現)
;; のため不採用、vterm を採用。ネイティブモジュール(vterm-module)を使うため
;; 初回 M-x vterm 時にローカルビルドが走る(要 cmake/libtool/C コンパイラ、README 参照)。
;; PATH は上部の exec-path-from-shell が GUI/daemon に取り込み済み。
;; claude 等は vterm が起動する対話 zsh(~/.config/zsh/.zshrc の alias)が解決。
;; ディレクトリ追跡(基準5)は zsh 側スニペットが前提(README 参照)。
(use-package vterm
  :if module-file-suffix              ; モジュール非対応ビルドでは安全スキップ
  :commands (vterm)
  :custom
  (vterm-max-scrollback 10000)        ; 上限 100000
  (vterm-kill-buffer-on-exit t)
  :config
  (unless (getenv "SHELL")            ; SHELL 優先、未設定時のみ /bin/zsh
    (setq vterm-shell "/bin/zsh")))


;;; ============================================================
;;;  外部プロジェクト統合: worklog (Workday Log 入力補助)
;;; ============================================================
;; 別プロジェクト ~/cm/meltedice/worklog/ で作成した
;; integrations/emacs/worklog.el を lisp/worklog.el にそのままコピーして
;; 取り込んだもの(無改変)。worklog ファイル(日付セクション内のログ行)の
;; 行末で RET → 改行 + 現在の勤務日・時刻 prefix を自動挿入。
;; 詳細・仕様は lisp/worklog.el 冒頭の Commentary を参照。
;; load-path 追加は eval-and-compile で包む(コンパイル時にも評価)。
;; こうしないと init.el 全体を byte-compile した際、コンパイル時には
;; この add-to-list が実行されず、直後の (require 'worklog) が lisp/ を
;; 見つけられず失敗する(実行時=逐次 load では順に実行され問題ない)。
;; ※ load 時の挙動は従来と不変(eval-and-compile は実行時にも評価する)。
(eval-and-compile
  (add-to-list 'load-path (locate-user-emacs-file "lisp")))
(require 'worklog)

;; worklog を開いたら worklog-mode を自動 ON。
;; 実ファイルは ~/ob/Main/Journals/worklog-<YYYY>.md だが、実運用では
;; symlink "worklog.md" 経由で開く。find-file-visit-truename は nil(既定)の
;; ため buffer-file-name は symlink 名(worklog.md)になる(batch で実証済)。
;; よって symlink 名・実体名どちらでも拾えるよう、worklog.md と
;; worklog-<YYYY>.md(年4桁サフィックス)の両方にだけマッチさせる。
;; フェーズ2(Alfred)が worklog.md に直接書き込むため、auto-revert-mode で
;; 外部変更を自動取り込みし、未保存バッファとの競合を緩和する。
(add-hook 'find-file-hook
          (lambda ()
            (when (and buffer-file-name
                       (string-match-p "/worklog\\(?:-[0-9]\\{4\\}\\)?\\.md\\'"
                                       buffer-file-name))
              (worklog-mode 1)
              (auto-revert-mode 1))))


(provide 'init)
;;; init.el ends here

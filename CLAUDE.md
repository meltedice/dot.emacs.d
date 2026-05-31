# CLAUDE.md — Emacs 30.2-1 設定リビルド

> **ユーザー向けの使い方は [README.md](README.md) を参照**(キーバインド早見表、新マシンセットアップ手順、機能ごとの使い方、`*scratch*` 永続化やテーマの設計、フォントプリセット、macOS 固有設定など)。本ファイルは Claude / 開発側のメタ情報(方針・移植進捗・設計判断のトレーサビリティ)に絞る。

## このリポジトリについて

`~/.emacs.d.30.2-1/` は **Emacs 30.2-1 用に作り直し中**の設定ディレクトリ。
旧設定 `~/.emacs.d/`(Emacs 29.x 昇格時にいろいろ壊れたまま)から、機能を
段階的に移植している。

- **移植元の基準**: `~/.emacs.d/` の **git HEAD = `1529d6d` "update elisp packages"(2020-06-22, branch `disabling-...-29.3`)**。
  ローカル作業ツリーには `.disabled` 化などの未コミット変更があるが、本ドキュメントと移植は **HEAD を正**とする(HEAD では `50-elscreen.el` / `50-javascript.el` 等も有効)。
- **このドキュメントの役割**: 旧設定が「どんな機能を持っていたか」の機能カタログ + 各機能について「採用 / 不採用 / どう現代化したか」の判断記録。
  細かい変数設定ではなく、機能単位でまとめてある。移植の参照に使う。
  ユーザー向けの「使い方」は [README.md](README.md) を参照。

## 作業方針・指示の傾向(セッション間で踏襲)

過去セッションで確立した、このユーザー/プロジェクトの進め方。別セッションでも
これに従うこと。

### コミュニケーション・進め方
- **日本語**でやり取りする。
- **決めるのはユーザー**。実装前に選択肢を比較表で提示し、推奨を1つ明示し、
  確認を取ってから着手する。先に説明・必要なら ASCII モックアップを示し、
  「説明 → 選び直してもらう」を厭わない。
- 旧式・非推奨の設定は**黙って変えない**。調査のうえ現状と代替案を提案する。
- 結果は誠実に報告(検証出力・スキップ・失敗をそのまま)。ミスは隠さず、
  原因と巻き戻しを明示する(例: noclobber 事故 → `git reset` で完全復旧)。

### 移植の方針
- 旧 `~/.emacs.d`(HEAD 基準)から機能単位で移植。**主流・標準・管理しやすい**
  方式を優先(単一 `init.el`、`use-package`、`package.el`、組み込み代替)。
  例: elscreen→`tab-bar-mode`、linum→`display-line-numbers`、
  matrix-on-ice→自前 `themes/matrix-on-ice-theme.el`(deftheme で最小忠実
  再実装、外部パッケージ非依存)、el-get→package.el+use-package。
- 未移植の elisp(外部パッケージ/旧 inits のカスタム関数)に依存する
  キーバインド等は、**移植したうえでコメントアウトし依存先を明記**。
  該当機能を移植したらコメントを外す運用。
- 本ファイルの**移植チェックリスト(`[x]`/`[ ]`/`[-]`)を都度更新**する。

### 検証(必須)
- 検証用 Emacs は **`/Applications/Emacs-30.2-1.app/Contents/MacOS/Emacs`
  (GNU Emacs 30.2)**。`/Applications/Emacs.app` は 29.x なので使わない。
- `init.el` を変更したら毎回バッチで load / byte-compile し、結果を報告。
  パッケージ未導入時の検証は `package-installed-p`/`package-install` を
  スタブして実施。

### Git・コミット
- **コミットはユーザーが明示したときだけ**。push しない。
- メッセージは英語、「要約 + 箇条書き変更リスト」、末尾に
  `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`。
- 手書き config と vendored 依存(`elpa/`)は別コミットに分ける。
- **コミット前に必ず、ホームディレクトリ絶対パス(シェルの `$HOME` を実行時展開して得る。値はリポジトリに書かない)の混入をスキャン**し、
  混入があれば中止。混入なしを確認してからコミット。

### プライバシー(厳守)
- ホームディレクトリ絶対パス(`$HOME` の実体)を **git 履歴に残さない**。
- マシンローカル設定 `.claude/settings.local.json` は**未追跡 + `.gitignore`**。
  これは harness が自動再生成し名前入りパスを含むが、ローカル専用なので
  内容は変えず追跡から外すだけでよい。
- `elpa/` 等を追跡する前に名前/ホーム絶対パスの混入を必ず確認。

### パッケージ運用
- `package.el` + `use-package`(`use-package-always-ensure t`)。git のみの
  パッケージは `use-package :vc`。
- `elpa/` のソースを git 管理(別マシン・上流リンク切れでも復元可)。
  再生成物(`*.elc`/`elpa/archives`/`eln-cache`/`package-quickstart.el`)は
  `.gitignore` で除外。導入後は `elpa/<pkg>/` をコミット。

### シェル環境の注意(別セッションでハマりやすい点)
- シェルは **zsh**。`noclobber` 有効 → 既存ファイルへの `>` は失敗/プロンプト。
  `>|`・`/bin/cp -f`・`git checkout <ref> -- path` を使う。
- `cp` は `cp -i` エイリアス(対話)。スクリプトでは `/bin/cp` を使う。
- `timeout`/`gtimeout` なし。`mapfile` は bash 専用(zsh では使わない)。
- 重い処理はバックグラウンド実行。git コミットメッセージは
  `-F <file>` でファイル渡し(クォート事故回避)。
- `pip`/`pip3` は PEP 668(Homebrew Python 外部管理)で `install` 不可。
  CLI ツールは **`pipx install`**(無ければ `brew install pipx`)。
  GUI Emacs で `~/.local/bin` 等を解決するには `exec-path-from-shell`。
- Node のグローバル CLI / LSP サーバ(ユーザー方針 — 素の `npm install -g` / `npx` は使わない):
  - **本マシンは volta が global を管理しているため第一選択は `volta install <pkg>`**。
    volta シム下では `pnpm add -g` がブロックされるうえ、`volta uninstall pnpm` で
    シムを外すと他プロジェクトの volta-pinned pnpm を壊しうるため、シム除去
    アプローチは取らない(本リポジトリで検証済)。
  - volta が無い別マシンに展開する場合は **`pnpm add -g <pkg>`** / **`pnpm dlx <pkg>`**(旧 `npm install -g` / `npx` の代替)を使う。
  - 例(volta 環境):
      `volta install typescript-language-server typescript`
      `volta install yaml-language-server`
      `volta install prettier`
    例(volta なし環境):同名パッケージを `pnpm add -g` で。
  - 回答・コミット内で Node CLI 導入を勧める時は volta か pnpm の上記表記を使う(素の npm/npx は書かない)。

## 旧設定のアーキテクチャ

- `init.el`: 基本設定 + パッケージ宣言 + ローダ起動。
- **パッケージ管理**: [el-get](https://github.com/dimitri/el-get)(`el-get-bundle` + `el-get-lock`)。
  加えて `auto-install`(emacswiki 等から取得した自作/野良 elisp を `auto-install/` に格納)。
  `package.el` / Cask は init.el にコメントとして残るのみ(未使用)。
- **設定ローダ**: [init-loader](https://github.com/emacs-jp/init-loader)。`inits/` 内を
  ファイル名の数値プレフィックス順にロード(`00-` → `20-` → `50-` → `80-` → `90-` → `99-`)。
  さらにプラットフォーム別プレフィックス(`cocoa-emacs-`, `windows-`, `linux-`, `nw-`, `carbon-emacs-`, `meadow-` / `platforms/`)で OS 別ファイルを出し分け。
- **環境判定ヘルパ**(`inits/00-environments.el`): GUI 判定、OS 判定
  (`win32?` / `mac?` / `unix?` / `ubuntu?` / `centos?`)、`hostname`、`which`/`where` ラッパ。
- `exec-path-from-shell` で macOS の GUI Emacs にシェル PATH を取り込み。

> 新設定(本リポジトリ)は init-loader 構成を廃し、**主流の単一 `init.el`** に
> 再編する方針。詳細は末尾「現在の移植状況」を参照。

---

## 機能リスト(移植チェックリスト)

凡例:
- `[x]` **移植済み** — 本リポジトリの `init.el` に反映済み
- `[ ]` **未移植** — 今後移植予定
- `[-]` **移植しない / 廃止** — 理由を併記。原機能を別手段に置き換えた場合は「代替」と明記

### 基盤・全体
- [-] 旧パッケージ管理(el-get / el-get-lock / auto-install) — 旧構成は不採用
- [x] パッケージ管理基盤 — **package.el + use-package**(Emacs 30 同梱)で**移植済み**。`elpa/` を git 管理し別マシンへ移植・復元(上流リンク切れでも実体を抱える方針、`.gitignore` 調整済)。git のみのパッケージは `use-package :vc`
- [-] init-loader による分割設定ロード — 主流の単一 `init.el` 構成へ再編したため不採用
- [-] 環境判定ユーティリティ(OS/GUI/hostname/which) — **移植しない**(調査済み)。組み込みの `display-graphic-p`(GUI 判定)/ `system-type`(OS 判定)/ `(system-name)`(ホスト名)/ `executable-find`(which 相当)で完全代替。実際 `*scratch*` 永続化(`my-scratch--short-hostname`)で `(system-name)` を直接利用している
- [x] シェル PATH 取り込み — `exec-path-from-shell`(GUI/デーモン時、ログイン非対話 `-l`)で**移植済み**。GUI Emacs でも `~/.local/bin`(pipx: grip 等)を解決
- [x] 基本 UX(ツールバー非表示、起動画面抑止、`yes/no`→`y/n`、削除→ゴミ箱、ベルは画面フラッシュ、タイトルバー書式、関数名/行桁番号のモードライン表示、インデント既定)

### 編集支援
- [x] 賢い行頭移動 — **移植済み**。自作 `my-smart-home`(C-a、旧 `intelli-home-2` 忠実: 行頭以外→行頭 / 行頭→最初の非空白)。組み込み API のみ・パッケージ非依存
- [x] リージョン囲み `quote-region-by` — **移植済み**(旧忠実・C-c 記号 ×15)。代替として組み込み `electric-pair-mode` をコメント併記(未有効化、ユーザー選択は忠実移植)
- [x] `kill-region-or-backward-kill-word`(C-w: 選択時 kill / 無選択時 単語削除) — **移植済み**(旧忠実・`mark-active` 判定、`transient-mark-mode nil` 維持と整合。minibuffer-local-completion-map にも割当)
- [x] 二度押し C-g でマーク解除 — **移植済み**。旧非推奨 `defadvice` を `advice-add :before` で現代化(閾値 0.3 秒踏襲)
- [x] 行折り返しトグル — **移植済み**。組み込み `toggle-truncate-lines` を `C-c $` に割当(旧自作 walk-windows ラッパは組み込みを shadow するため不採用)。折返し表示は `visual-line-mode` をコメント案内
- [-] UTF-8 コメント挿入(`-*- coding: utf-8 -*-`) — **移植しない**(obsolete: Emacs 30 既定 UTF-8、coding cookie は不要な場面が大半)
- [x] `kill-whole-line` — 行頭 C-k で行末+改行を kill(`(setq kill-whole-line t)`、組み込み)で**移植済み**
- [x] キルリング閲覧 — **移植済み**。組み込み `yank-from-kill-ring`(Emacs 28+、M-y)。旧 `yank-pop-summary`(未保守・MELPA 不在)は不採用
- [x] シンボルハイライト & 一括リネーム — **移植済み**。`use-package symbol-overlay`(旧 `auto-highlight-symbol` 未保守の現代後継)。`prog-mode` で自動ハイライト、`M-i`/`M-n`/`M-p`/`F7`(rename)/`F8`。`elpa/` へ vendoring
- [-] スニペット展開(yasnippet) — **移植しない**(ユーザー判断)。将来必要なら `yasnippet`(+`yasnippet-snippets`)または軽量 `tempel` を再検討
- [x] キーコード同時押し(key-chord: `jk` で view-mode) — **移植済み**。`use-package key-chord`(MELPA、2025 更新で保守継続。chord の組み込み代替なし)。`key-chord-two-keys-delay` 0.1、`jk` 同時押しで `view-mode` トグル(旧 `20-key-chord.el` 忠実)。旧 `(require 'key-chord nil t)` は use-package 化。`elpa/` へ vendoring

### Undo / 履歴
- [x] `redo+`(リドゥ、C-M-/) — **組み込み `undo-redo`(Emacs 28+)で代替移植済み**。未保守 EmacsWiki の redo+ は不採用。キーは旧踏襲の `C-M-/`。旧 `undo-limit`/`undo-strong-limit`/`undo-no-redo` は組み込み変数としてコメントで残置(既定のまま、必要時に有効化)
- [-] `undo-tree`(分岐 undo) — **導入見送り**(ユーザー判断)。巨大ファイルで重く履歴破損歴あり、単純 redo は `undo-redo` で足りる。将来分岐 undo の可視化が要れば軽量 `vundo` を第一候補
- [x] `undohist`(undo 履歴の永続化) — **移植済み**。`use-package undohist`、`undohist-directory` = `user-emacs-directory/.undohist`(`.gitignore` 除外済)、`undohist-initialize` がディレクトリ自動生成 + フック登録。組み込み代替なしのため導入
- [-] `point-undo`(カーソル位置の undo/redo, F5/F6) — **導入見送り**(ユーザー判断)。組み込み mark ring(`C-SPC C-SPC` / `C-u C-SPC` / `C-x C-SPC` / `set-mark-command-repeat-pop`)で代用。使い方を init.el にコメント記載。近い体験が要れば将来 `point-history` 検討

### ウィンドウ・バッファ・画面
- [ ] バッファ入替 `swap-screen` / `swap-screen-with-cursor`(F2 / S-F2)
- [x] 高速バッファ切替 `my-grub-buffer` / `my-bury-buffer`(C-, / C-.) — **組み込み `previous-buffer` / `next-buffer` で代替移植済み**。旧自作再帰 `my-visible-buffer` + 手書き `my-ignore-buffer-list` は、現代 Emacs のこの用途専用組み込み(`next-buffer`/`previous-buffer` + `switch-to-prev-buffer-skip-regexp`)で完全に置換可能なことを実機検証で確認(調査のうえ Option 1 をユーザー選択)。`C-,`→`previous-buffer`(戻る)/ `C-.`→`next-buffer`(進む)。スペース始まり内部バッファは組み込みが自動スキップ。`switch-to-prev-buffer-skip-regexp` に旧無視リスト相当(`*Help*`/`*Compile-Log*`/`*Completions*`/`*Shell Command Output*`/`*Apropos*`/`*Buffer List*`、完全一致アンカー付き)を設定。廃れた Mew 用 `*Mew completions*` は除外。`*scratch*`/`*Messages*` は旧リストにも無く巡回対象のまま。順序はウィンドウ単位履歴(旧グローバル順から現代標準へ)
- [ ] 縦横分割トグル `window-toggle-division`、`other-window-or-split`(C-tab)
- [ ] 自動方向ウィンドウ拡大 `enlarge-window-auto`(C-^)
- [-] 画面タブ管理 `elscreen` — 未メンテでパッケージ不採用。組み込み `tab-bar-mode` + `tab-bar-history-mode`(C-z プレフィックス踏襲)で**代替移植済み**
- [x] ページャ `view-mode` 拡張(旧 `inits/50-view-mode.el`) — **取捨選択して移植済み**。調査の結果、旧 4 機能のうち現代でも妥当なものだけ採用(ユーザー選択)。**採用**: ① `view-read-only t`(読取専用/書込不可ファイルを開くと自動 `view-mode`。実機検証で chmod 444 が `view-mode` 自動 ON を確認)、② 最小 vi サブセット(`view-mode-map` に `h`/`j`/`k`/`l`=文字移動・`J`/`K`=`scroll-up-line`/`scroll-down-line`。`e`(View-exit)・`n`/`p`(検索反復)等の有用な既定は温存)。**不採用**: 「書込不可ファイルを view で開く」`find-file` advice(①が兼ねるため冗長)、「書込不可なら view を抜けない」advice(`buffer-read-only` で保護済み・obsolete 関数依存)、自作 vi 風 `pager-keybind` ×24(忠実移植不能 — `point-undo`=採用見送り / `bm`=未移植 / `win-delete-current-window-and-squeeze`=旧設定にも定義なし に依存、かつ現代既定を破壊)
- [ ] `C-t` / `C-z` の独自プレフィックスキーマップ(`C-t` 定義のみ済、配下バインドは未)

### ファイル管理(dired 系)
- [x] dired-x(omit で .git/.svn/CVS 非表示) — **移植済み**。`with-eval-after-load 'dired` で `dired-omit-files` に追加、`dired-mode-hook` で `dired-omit-mode` 有効化(旧 obsolete な `dired-omit-files-p` を現行マイナーモードへ)
- [x] `wdired`(dired 上で一括リネーム) — **移植済み**。組み込み wdired を `r` に割当(旧忠実、`C-x C-q` も併用可)
- [x] マーク 2/3 ファイルを ediff `dired-ediff-marked-files` — **移植済み**。elscreen 非依存の単純版を自作 defun(トップレベル + `declare-function`)で `E` に割当
- [x] `find-dired` 系のバッファ名をユニーク化 — **移植済み**。旧 `defadvice` ×3 を `advice-add :after` で現代化(find-dired / find-name-dired / find-grep-dired)
- [x] ファイルを名前で開く `ffap`(組み込み) — **移植済み**(軽量採用)。`(ffap-bindings)` 全置換は誤爆回避で不採用、`find-file-at-point` を `C-x C-p` に割当(ユーザー選択)
- [x] `C-x C-j` — **移植済み**。旧 `direx-project`(未保守)の組み込み代替として dired-x の `dired-jump` を割当
- [-] `dired-details` — **不採用**。組み込み `dired-hide-details-mode`(既定 `(` トグル・詳細表示)が完全代替のため設定追加なし(旧 initially-hide nil 相当)
- [x] `dired-subtree`(サブディレクトリのインライン展開) — **移植済み**。`use-package dired-subtree`(MELPA、依存 `dired-hacks-utils` 自動導入)。キーは新方針で整理: dired 内 `<tab>` = `dired-subtree-toggle`(insert と remove の統合)/ `<backtab>`(S-TAB) = `dired-subtree-cycle`(全段サイクル)。旧 `i` は組み込み `dired-maybe-insert-subdir` を温存。その他コマンド(narrow / up-dwim / mark-subtree 等)は M-x から
- [x] `bf-mode` → `dired-preview` で**代替移植済み**。`use-package dired-preview`(GNU ELPA・Protesilaos Stavrou 保守)。`dired-mode-hook` で `dired-preview-mode` を ON、カーソル移動に追従して右ペインに自動プレビュー。表示遅延は `dired-preview-delay`(既定 0.7s)、全バッファ常時 ON が要れば `dired-preview-global-mode` へ
- [x] `direx` + `direx-grep` → `dired-sidebar` で**代替移植済み**。`use-package dired-sidebar`(MELPA、内部で `dired-subtree` を利用)。`C-x C-n` で開閉トグル(組み込み既定 `set-goal-column` を shadow、ユーザー選択)。サイドバーは通常 dired のため既移植の dired-x omit / wdired=r / ediff=E / dired-subtree=`<tab>` がそのまま使える。テーマは `ascii`(`icons`/`nerd`/`vscode-icons` は all-the-icons 等の別パッケージが前提のため不採用)。`direx-grep` 相当は組み込み `project-find-regexp`(`C-x p g`)で代替
- [x] プロジェクト内検索 `find-file-in-project` → 組み込み `project.el`(`C-x p f`)で**代替移植済み**。Emacs 28+ 同梱の `project-find-file` がカレント VCS ルートを自動判定し `.gitignore` を尊重(設定不要、autoload 済み)。あわせて `C-x p g`(project-find-regexp)/ `C-x p r`(project-query-replace-regexp)/ `C-x p p`(switch-project)等の標準キーが利用可能
- [-] `dired-sort` / `dired+` — **不採用**。ソートは組み込み `s`/`C-u s` で足りる(簡便化は将来 `dired-quick-sort` 任意)。dired+ は EmacsWiki 由来・重厚で現代 dired が機能吸収
- [-] `dired-k`(git 状態表示) — 旧設定で `.git/index.lock` 問題により無効化済み。移植しない(git 状態が要れば将来 `diff-hl-dired`)

### 検索・grep・補完 UI
- [-] `color-moccur` + `moccur-edit`(横断検索 → 結果を直接編集、除外マスク多数) — **移植しない**(調査のうえユーザー判断)。理由: ① `color-moccur` は MELPA で 2014-12 以降更新なし(事実上停止)、② `moccur-edit` は MELPA から消失し入手不能、③ **主用途の再帰ファイル grep+編集(旧 `C-t m`/`moccur-grep-find`)は `deadgrep` + `wgrep-deadgrep` で移植済み**(rg バックエンドに刷新)、④ buffer 横断検索は組み込み `multi-occur` / `multi-occur-in-matching-buffers` で完全代替、⑤ 結果バッファでの編集→ソース反映は組み込み `occur-edit-mode`(`e` で edit、`C-c C-c` で反映)で代替、⑥ dired マーク済みファイル群の検索/置換は組み込み `dired-do-find-regexp`(`A`)/ `dired-do-find-regexp-and-replace`(`Q`)で代替、⑦ `dmoccur-exclusion-mask` 相当は rg の `.gitignore` 自動尊重で原則不要。用途別の代替コマンド早見表は `init.el` の「検索・置換 チートシート」セクション参照(設定不要・autoload 済み)
- [x] `ag.el` + `wgrep-ag`(ag 検索 → `r` で結果を一括編集) — **`deadgrep` + `wgrep` + `wgrep-deadgrep` で代替移植済み**。調査の結果、旧 `ag.el` は 2020 以降更新が止まっており(MELPA `20201031`)推奨できない。検索バイナリ `ag` → **`rg`(ripgrep)が現代の事実上標準**、front-end は `ag.el` の自然な後継である **`deadgrep`**(同じ Wilfred Hughes 作・保守継続、MELPA `20241210`)を採用。`M-x deadgrep` で検索 → リッチな結果バッファ →(旧忠実の)`r` キーで wgrep モード → 編集 → `C-c C-c` でファイル反映(`wgrep-auto-save-buffer t` で自動保存)。旧 50-ag.el の `wgrep-auto-save-buffer t` / `wgrep-enable-key "r"` はそのまま忠実移植。`ag-highlight-search t` / `ag-reuse-buffers nil` は deadgrep の既定挙動と一致するため設定不要。新マシン setup: 外部バイナリ `rg` の導入が必要(下記ブロック参照)。rg が無いマシンでは `use-package :if` で全体スキップ

> **新マシン setup: ripgrep のインストール手順は [README.md「新マシンセットアップ → ripgrep」](README.md#ripgrepdeadgrep--wgrep-deadgrep-のエンジン) を参照**。`rg` 未導入マシンでは `use-package :if` で `deadgrep` / `wgrep-deadgrep` 全体がスキップされ起動エラーにはならない(`init.el` 該当セクションコメント参照)。
- [x] `migemo`(ローマ字のまま日本語インクリメンタル検索、cmigemo) — **移植済み(Option A)**。`use-package migemo`(MELPA `20250616`、保守継続)。調査の結果、この用途で migemo を置き換える定番ツールは現在も存在せず妥当と判断。検索 UI は刷新せず**組み込み `isearch` をローマ字対応にするのみ**(`migemo-init` 後は通常の `C-s`/`C-r` が日本語にヒット、検索中 `M-m` で migemo トグル)。エンジンは外部 `cmigemo`(導入手順は下記ブロック参照)。旧 `cocoa-emacs-migemo.el` の現代化: 旧 `(el-get-bundle migemo)`→use-package + `elpa/` vendoring、辞書パスは旧 Intel 固定 `/usr/local/...` から実行時候補選択(Apple Silicon `/opt/homebrew/...` 等、ホーム絶対パス不使用)、cmigemo/辞書が無いマシンは `use-package :if` で全体スキップ

> **新マシン setup: cmigemo のインストール手順は [README.md「新マシンセットアップ → cmigemo」](README.md#cmigemoローマ字日本語-isearch-のエンジン) を参照**。`init.el` の `my-migemo-dictionary` が代表的な辞書パス候補を実行時に探索する。`cmigemo` バイナリ or 辞書がどれも見つからないマシンでは `use-package :if` で migemo 関連が全体スキップされ起動エラーにはならない(`init.el` 該当セクションコメント参照)。

- [-] `ivy` / `counsel` / `swiper`(補完 UI、C-s/C-c g/j/k 等) — **移植しない**(調査済み)。旧パッケージは前世代スタック。現代主流の **`vertico` + `consult` + `orderless` + `marginalia`**(下記「参考: Option B」)へ将来刷新する方針。旧 ivy 系の忠実移植は実施しない
- [-] `smex`(M-x 履歴) — **移植しない**(調査済み)。**`vertico` + 組み込み `savehist-mode`** で完全代替可能(M-x 履歴・頻度順表示)。Option B の刷新時に同時対応
- [-] `ido` — 旧設定で関連コードはコメントアウト(無効)。移植しない
- [-] `helm` — `90-helm.el.disabled` として無効。移植しない

> **参考: 検索/補完 UI 現代化(Option B、将来検討)** — 旧 `ivy`/`counsel`/`swiper` は前世代スタック。現行主流は **`vertico`(補完 UI)+ `consult`(`consult-line`=swiper 相当ほか)+ `orderless`(絞り込み)+ `marginalia`(注釈)**。今回 migemo は Option A(`isearch` のみ)で導入したが、Option B として上記スタックへ刷新する場合、migemo はそのスタックとも併用できる(`consult-line` 連携、`orderless` に migemo マッチスタイルを組み込むレシピあり)。`ivy`/`counsel`/`swiper`/`smex` の各 `[ ]` を移植する際は、旧パッケージの忠実移植ではなく Option B(vertico 系)での代替を第一候補に検討する。`smex`(M-x 履歴)は `vertico` + `savehist` で代替可。

### Git / 差分
- [x] `magit`(Git クライアント) — `use-package magit` で**移植済み**。旧 `inits/20-magit.el` は全行コメントアウトで実働設定なし(自作 ediff-magit-ediff / index.lock ハックは現代 magit 組み込みの magit-ediff に置換され不要)。キー: `C-c g`→magit-status(`C-x g`→goto-line は維持)、`C-c d`/`C-c D`→magit-ediff working-tree/dwim
- [x] `ediff`(組み込み、旧 `inits/50-ediff.el`) — **移植済み**(左右分割 + plain ウィンドウ)。旧 DavidBoon cleanup スニペットは**移植しない**(現代 ediff が終了時にウィンドウ構成を自前復元、ユーザー確認済み)。旧 `custom-set-faces` の diff 配色 8 フェイスも**移植しない**(wheatgrass 既定配色を使用)
- [x] `gitignore-mode` — **移植済み**。`git-modes` パッケージ(Magit 系、`gitignore-mode` / `gitconfig-mode` / `gitattributes-mode` 3 点)を `use-package` で導入。標準パターン(`.gitignore` / `.gitconfig` / `.gitattributes` / `.gitmodules` / `.git/config` / `info/exclude` 等)はパッケージ autoload が `auto-mode-alist` 自動登録。追加で `.dockerignore` / `.eslintignore` / `.prettierignore` / `.npmignore` / `.stylelintignore` も `gitignore-mode` に割当。旧 `(el-get-bundle gitignore-mode)` 相当 + 拡充

### 言語・メジャーモード(いずれもパッケージ依存、未移植)
- [-] **Go**: go-mode + go-autocomplete + go-eldoc、保存時 gofmt、godef-jump(M-.) — **移植しない**(現状の常用言語ではないためユーザー判断で保留)。将来必要時は組み込み **`go-ts-mode`(Emacs 29+)+ `eglot`**(LSP)+ `apheleia`(gofmt)の薄い 5-10 行構成で再導入推奨。`go-autocomplete` / `go-eldoc` / `godef-jump` は eglot が全部担当
- [-] **Ruby**: ruby-mode + ruby-block/ruby-end/ruby-electric ほか、rspec-mode、projectile-rails、robe、rhtml-mode — **移植しない**(同上、ユーザー判断)。将来は `ruby-ts-mode`(Emacs 29+)+ `eglot`(ruby-lsp / sorbet 等)で。`robe` / `ruby-block` 等の補助系は eglot+ts-mode で大半不要
- [ ] **JavaScript / TypeScript**: rjsx-mode、js2-mode、typescript-mode、tide、flow-minor-mode、prettier-js、coffee-mode、json-mode — **推奨移行先(調査済み)**: 組み込み **`typescript-ts-mode` / `tsx-ts-mode` / `js-ts-mode` / `json-ts-mode`(すべて Emacs 29+ 同梱)+ `eglot`**(LSP、typescript-language-server を `volta install typescript-language-server typescript`(volta 環境)/ `pnpm add -g typescript-language-server typescript`(volta なし)で導入)。`tide` / `js2-mode` / `rjsx-mode` は eglot+ts-mode で代替、`flow` / `coffee-mode` は終息で不採用、`prettier-js` は `apheleia`(format-on-save)で代替。`json-mode` は `json-ts-mode` 同梱
- [-] **Web**: web-mode(`.html`/`.ctp`、インデント 2、php エンジン) — **移植しない**(同上、ユーザー判断)。HTML だけなら組み込み `mhtml-mode`、`.ctp`(CakePHP)を今も書くなら web-mode を別途検討
- [-] **PHP**: php-mode / **Lua**: lua-mode / **GraphQL**: graphql-mode(`.graphql`/`.gql`) — **移植しない**(同上、ユーザー判断)。将来は各 `*-ts-mode`(PHP は GNU ELPA `php-ts-mode`、Lua は `lua-ts-mode`、GraphQL は `graphql-ts-mode` 等)+ eglot を第一候補に
- [x] **Markdown**: `markdown-mode`(+ `gfm-mode` for README)。補助 `markdown-toc`(目次)/ `grip-mode`(GitHub 風プレビュー、要 `pip install grip`)を use-package で**移植済み**
- [ ] **YAML**: `yaml-mode` または組み込み `yaml-ts-mode`(Emacs 29+、tree-sitter)— 使用頻度高(CI/k8s/Ansible/GitHub Actions)。`yaml-ts-mode` が同梱で利用可能、grammar は `treesit-install-language-grammar` で導入。`auto-mode-alist` 登録のみで動く最小構成
- [-] **マークアップ/データ(残り)**: textile-mode / apib-mode / haml-mode / slim-mode / sass-mode / scss-mode / less-css-mode / shell-script(zsh) — **移植しない**(現状の常用ではないためユーザー判断)。zsh ファイルは組み込み `sh-mode` で十分。haml/slim/sass/scss/less は使用言語が変わった場合に個別追加。textile/apib は事実上廃れ
- [ ] **org-mode**: アジェンダ(C-c a)、`kanban.org`、完了時刻記録 — 組み込み。`C-c a` バインドのみ済。**推奨移行先(調査済み)**: 組み込み org の小さな設定足し込みで完了する(`(setq org-agenda-files '("~/path/to/kanban.org" ...))` / `(setq org-log-done 'time)` で完了時刻自動記録 / `org-todo-keywords` / `org-capture-templates` / `org-refile-targets` 等)。外部パッケージは不要、5-15 行規模
- [-] プロジェクト管理 `projectile` — **移植しない**(調査済み)。組み込み `project.el`(`C-x p f`/`g`/`r`/`p`/`d` ほか)で**移植済み**=同等以上に代替できる。`projectile-rails` 等の言語固有プラグインが必要になったら個別検討

### シンタックスチェック
- [ ] `flycheck`(グローバル)/ `flymake` / 各種 `flymake-*` チェッカ群 — パッケージ依存。**推奨移行先: 下記の「`flymake`(組み込み)+ `eglot`(組み込み) による diagnostics」**(調査済み)。`flycheck` 自体の忠実移植は不要、現代は flymake + eglot 経由の LSP diagnostics が主流
- [ ] **`flymake`(組み込み・Emacs 26+)+ `eglot`(組み込み・Emacs 29+)による diagnostics** — 旧 `flycheck` の現代代替。各言語 LSP の警告を flymake が表示。設定は `prog-mode` フックで `flymake-mode` を有効化+ eglot を必要に応じて起動するだけの最小構成。言語固有 checker(`flymake-eslint` 等)は eglot がカバーできない場合のみ補完導入
- [-] JS/TS: eslint + `flycheck-flow`(flow)+ prettier 連携(jshint/jscs は無効) — **移植しない**(調査済み)。Flow は TypeScript に敗北して終息、jshint/jscs は ESLint に統合済み、prettier 連携は **`apheleia`(format-on-save)**または LSP 経由が現代的。eslint 連携は eglot(LSP)で吸収。下記 JavaScript/TypeScript エントリ参照

### 文字コード・フォント・表示
- [-] 拡張子別 coding-system 設定(`80-encodings.el`)— **移植しない**(調査済み)。Emacs 30 既定 UTF-8 で大半の場面が不要。Shift_JIS 等の特定ファイル群を継続的に扱う運用が出てきたら個別追加
- [x] macOS フォント — **移植済み**(比較用プリセット方式)。`M-x my-font-preset` で 4 プリセット即時切替: `faithful-old`(旧 Monaco+Hiragino Maru ProN+rescale 忠実)/ `stock-modern`(Menlo+Hiragino Kaku ProN)/ `udev-gothic` / `plemol-jp`(CJK 同梱 1 本、`brew install --cask font-udev-gothic` / `font-plemol-jp` 導入済)。**起動時デフォルト = `stock-modern`**(`my-font-default-preset`、GUI 時自動適用、daemon は after-make-frame-functions)
- [x] 全角記号フォント対応(`use-default-font-for-symbols nil`) — **移植済み**(全プリセット共通で維持)
- [-] 行番号 `linum-off` + `global-linum-mode` — **linum は Emacs 29 で廃止**。`display-line-numbers`(prog-mode のみ、幅3)で**代替移植済み**
- [x] テーマ `matrix-on-ice` — **`themes/matrix-on-ice-theme.el` に自前 `deftheme` で再実装し採用**。旧 `~/.emacs.d/auto-install/matrix-on-ice-theme.el` は実装上 elscreen タブ用 4 face しか触っておらず、旧環境で見えていた「matrix-on-ice の色」の大半は **Emacs 既定の face 値**(モードライン=灰色 3D ボタン、リンク=cyan、見出し=ピンク赤太字、font-lock=多彩色)だった事実を batch で実機確認。本リビルドはその事実に従い **「`default` の bg/fg(黒 + #7eff00)だけ指定、他は Emacs 既定に任せる」最小忠実構成** で再現。`custom-theme-load-path` に `themes/` を追加(`early-init.el` と `init.el` の両方、`add-to-list` は冪等)、`(load-theme 'matrix-on-ice t)` を `early-init.el` で先読み、`init.el` に `(unless (custom-theme-enabled-p 'matrix-on-ice) ...)` フォールバック。外部パッケージ非依存
- [x] 起動時の明色フラッシュ防止(旧「起動時の緑/黒 仮配色」の現代化) — **`early-init.el` で `matrix-on-ice` を先読み**する方式で移植済み(ユーザー要望: 目のチカチカ防止)。旧 `~/.emacs.d/init.el` 冒頭の `(set-background-color "black") / (set-foreground-color "#7eff00")` は init.el 1 行目で呼んでもフレーム生成後の上書きでフラッシュが残っていた。本リビルドでは Emacs 27+ の `early-init.el`(GUI フレーム生成前に走る)で `(load-theme 'matrix-on-ice t)` を直接呼ぶ方式に統一。フレームが最初から採用テーマの配色で生まれるためフラッシュが完全消滅し、旧の「仮配色(緑/黒)→ matrix-on-ice」のような中間色遷移も発生しない(旧の意図を旧より綺麗に達成)。`init.el` 側にも `(unless (custom-theme-enabled-p 'matrix-on-ice) (load-theme ...))` のフォールバックを残してある。注意: `early-init.el` は Emacs が `user-emacs-directory` 配下から自動で読むため、起動時に `--init-directory ~/.emacs.d.30.2-1`(Emacs 29+)等で本リポジトリを `user-emacs-directory` として認識させる必要がある

### macOS 固有
- [x] 修飾キー(command=meta、option=super)、`¥`→`\`、ignore-shortcut
- [x] Karabiner / iTerm2 連携の運用メモ(コメントとして移植)
- [x] フレームサイズ既定、全画面トグル(C-c m)、ウィンドウ透明度トグル(C-c p) — **移植済み**。初期サイズ width 120 / height 35 は macOS GUI のみ `default-frame-alist`。`C-c m` は `mac-toggle-max-window`(`fullscreen` ⇔ `maximized`)= メニューバー/Dock を残しフレームを作業領域いっぱいに最大化(これが元の体感に一致。`fullboth`/macOS ネイティブフルスクリーン/組み込み `toggle-frame-fullscreen` は不採用、ユーザー希望)。`C-c p` は旧 `mac-toggle-window-alpha`(alpha 100⇔90)を忠実移植(組み込み代替なし・パッケージ非依存)
- [x] migemo(cmigemo) — **移植済み**。詳細は「検索・grep・補完 UI」の `migemo` 項目を参照(macOS は `brew install cmigemo`、辞書は Apple Silicon `/opt/homebrew/...` を実行時選択)

### その他
- [x] `*scratch*` 永続化(旧 `inits/50-scratch.el`) — **移植済み**。保存先は `user-emacs-directory/.scratch-<hostname>`(旧 Dropbox 優先の分岐は現在 Dropbox 未使用のためユーザー指示で除去、ただし将来マシンが増えても混線しないよう **hostname suffix は旧仕様どおり維持**)。挙動: ① 起動時に `my-scratch-load` が `*scratch*` へ復元、② Emacs 終了時に `advice-add :before save-buffers-kill-emacs` で `my-scratch-save`(`my-scratch-save-p` が判定、`my-scratch-donot-save` で当該セッションのみ抑止可)、③ `*scratch*` 上の `C-x C-s` は `lisp-interaction-mode-hook` でローカル上書きして専用保存関数に、④ `kill-buffer-query-functions` で `*scratch*` 削除を内容クリアにすり替え、⑤ 別ファイル save 後の `after-save-hook` で `*scratch*` 消失時の自動再生成。現代化: 旧 `defadvice` を `advice-add` に、`find-file-noselect`+`save-buffer` 経由を `write-region` 一発に、旧 `hostname-short`(`inits/00-environments.el` 由来・未移植)依存を `(system-name)` をドット分割した先頭の小文字化で代替(`my-scratch--short-hostname`)、命名を `my-*` 統一(旧 `scratch-*` / `my-make-scratch` 混在を解消)。保存ファイルは `.scratch*` パターンで `.gitignore` 既存除外
- [x] autosave / backup / undohist のディレクトリ集約(`.autosave` / `.backup` / `.undohist`) — **移植済み**。Emacs が編集中に作る一時ファイルを `user-emacs-directory` 配下の専用ディレクトリへ集約: ① auto-save 本体 `#file#` → `.autosave/`(`auto-save-file-name-transforms`、UNIQUIFY t)、② auto-save 索引 `saves-PID-HOST` → `.autosave/`(`auto-save-list-file-prefix`)、③ バックアップ `file~` → `.backup/`(`backup-directory-alist`、対象は現代慣用の `"."`)、④ undo 履歴 → `.undohist/`(undohist、移植済み)。**旧 `50-autosave-backup.el` は ②③ のみ集約し ① は散らかしていた**ため、① も集約する方針(ユーザー選択)。出力先は起動時に `make-directory` で明示作成。3 ディレクトリは `.gitignore` 除外済み。バックアップ世代管理(`version-control`/`delete-old-versions`/`backup-by-copying`)は旧設定にも無く集約スコープ外(必要なら別途)
- [-] `simplenote2`(Simplenote とメモ同期、`~/.authinfo` 認証) — **移植しない**(ユーザー判断)。Simplenote 自体を現在常用していないため。MELPA パッケージも 2020 前後で更新停滞。将来再開する場合は denote / org-roam / Obsidian 等の現代代替の検討余地あり
- [-] `tramp`(`/sudo:` `/ssh:`、root は ssh 経由 proxy) — **移植しない**(ユーザー判断)。`tramp` は組み込み・autoload 済みで設定ゼロのまま `C-x C-f /ssh:user@host:/path` / `/sudo::/etc/foo` が動作する(=実質既に「移植済み」)。旧の root-via-ssh proxy(`tramp-default-proxies-alist`)が必要になった時点で 5 行程度追記すれば良い

---

## キーバインド体系

**キーバインド早見表は [README.md「キーバインド早見表」](README.md#キーバインド早見表) に集約**しているのでそちらを参照(ユーザー向け = 移植済みのバインドのみ)。本ファイルでは「未移植」「不採用」のメモを補足としてここに残す:

- `M-o` / `C-tab` — `other-window-or-split`(未移植・カスタム関数依存。旧 `inits/50-window.el`)
- `F2` / `S-F2` — `swap-screen` / `swap-screen-with-cursor`(未移植・同上)
- `C-^` / `C-x C-^` — `enlarge-window-auto` / `toggle-enlarge-window-auto-direction`(未移植・同上)
- `F5` / `F6` — 旧 `point-undo`(採用見送り → 組み込み mark ring `C-u C-SPC` 等で代用)
- `C-c j/k` — 旧 counsel git-grep / ag(未移植。`C-c g` は magit に割当済みのため counsel 移植時は別キーへ)
- `C-t …` — ウィンドウ操作プレフィックス(旧 `C-t m` の moccur 系は color-moccur 不採用のため空き、配下バインドは未移植)

---

## 現在の移植状況(本リポジトリ)

`init.el`(単一ファイル構成)に以下を移植済み:

- **基本設定**: 旧 init.el の現役設定(ツールバー/起動画面/`use-short-answers`/
  ゴミ箱削除/関数名表示/インデント既定 など)。
  `linum`→`display-line-numbers`(prog-mode のみ)、`transient-mark-mode nil` は維持、
  テーマは自前 `themes/matrix-on-ice-theme.el`(旧 `matrix-on-ice` を deftheme で
  最小忠実再実装)。`early-init.el` で先読みして起動フラッシュ防止。
- **キーバインド**: 組み込みコマンド向けは有効。未移植の elisp(外部パッケージ /
  旧 inits のカスタム関数)依存のものは移植のうえコメントアウトし、依存先を明記。
- **macOS 設定**: NS 修飾キー、`¥`→`\`、Karabiner/iTerm2 メモ。

- **パッケージ管理基盤**: package.el + use-package(Emacs 30 同梱)。
  `elpa/` を git 管理(`.gitignore` で再生成物のみ除外)。新マシンは clone のみで
  ネット不要起動、上流が消えても復元可。git のみは `use-package :vc`。
- **タブ**: 旧 elscreen を `tab-bar-mode` + `tab-bar-history-mode` で代替(C-z プレフィックス踏襲)。

**未移植(今後の作業対象)**: 上記「機能リスト」の各パッケージ依存機能・
カスタム関数群(dired/window/edit/view-mode/検索/Git/各言語モード 等)。
各機能を `use-package` 化して移植する際、対応するキーバインドのコメントを外していく運用。

> 検証用 Emacs: `/Applications/Emacs-30.2-1.app/Contents/MacOS/Emacs`(GNU Emacs 30.2)。
> `/Applications/Emacs.app` は 29.x なので使わない。

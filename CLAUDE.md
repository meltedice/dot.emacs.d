# CLAUDE.md — Emacs 30.2-1 設定リビルド

## このリポジトリについて

`~/.emacs.d.30.2-1/` は **Emacs 30.2-1 用に作り直し中**の設定ディレクトリ。
旧設定 `~/.emacs.d/`(Emacs 29.x 昇格時にいろいろ壊れたまま)から、機能を
段階的に移植している。

- **移植元の基準**: `~/.emacs.d/` の **git HEAD = `1529d6d` "update elisp packages"(2020-06-22, branch `disabling-...-29.3`)**。
  ローカル作業ツリーには `.disabled` 化などの未コミット変更があるが、本ドキュメントと移植は **HEAD を正**とする(HEAD では `50-elscreen.el` / `50-javascript.el` 等も有効)。
- **このドキュメントの役割**: 旧設定が「どんな機能を持っていたか」の機能カタログ。
  細かい変数設定ではなく、機能単位でまとめてある。移植の参照に使う。

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
- [ ] 環境判定ユーティリティ(OS/GUI/hostname/which)
- [x] シェル PATH 取り込み — `exec-path-from-shell`(GUI/デーモン時、ログイン非対話 `-l`)で**移植済み**。GUI Emacs でも `~/.local/bin`(pipx: grip 等)を解決
- [x] 基本 UX(ツールバー非表示、起動画面抑止、`yes/no`→`y/n`、削除→ゴミ箱、ベルは画面フラッシュ、タイトルバー書式、関数名/行桁番号のモードライン表示、インデント既定)

### 編集支援
- [ ] 賢い行頭移動 `intelli-home-2`(C-a)
- [ ] リージョン囲み `quote-region-by`(各種記号で選択範囲を囲む)
- [ ] `kill-region-or-backward-kill-word`(C-w: 選択時は kill、無選択時は単語削除)
- [ ] 二度押し C-g でマーク解除
- [ ] 行折り返しトグル、`kill-whole-line`、UTF-8 コメント挿入
- [ ] キルリング閲覧 `yank-pop-summary`(M-y / C-M-y) — パッケージ依存
- [ ] シンボルハイライト & 一括リネーム(auto-highlight-symbol) — パッケージ依存
- [ ] スニペット展開(yasnippet) — パッケージ依存
- [ ] キーコード同時押し(key-chord: `jk` で view-mode) — パッケージ依存

### Undo / 履歴
- [ ] `redo+`(リドゥ、C-M-/) — パッケージ依存。Emacs 28+ 組み込み `undo-redo` で代替検討可
- [ ] `undo-tree`(分岐 undo) — パッケージ依存
- [ ] `undohist`(undo 履歴の永続化) — パッケージ依存
- [ ] `point-undo`(カーソル位置の undo/redo, F5/F6) — パッケージ依存

### ウィンドウ・バッファ・画面
- [ ] バッファ入替 `swap-screen` / `swap-screen-with-cursor`(F2 / S-F2)
- [ ] 高速バッファ切替 `my-grub-buffer` / `my-bury-buffer`(C-, / C-.)
- [ ] 縦横分割トグル `window-toggle-division`、`other-window-or-split`(C-tab)
- [ ] 自動方向ウィンドウ拡大 `enlarge-window-auto`(C-^)
- [-] 画面タブ管理 `elscreen` — 未メンテでパッケージ不採用。組み込み `tab-bar-mode` + `tab-bar-history-mode`(C-z プレフィックス踏襲)で**代替移植済み**
- [ ] ページャ `view-mode` 拡張(vi 風キーバインド、読取専用ファイルを自動 view、書込不可なら view を抜けない)
- [ ] `C-t` / `C-z` の独自プレフィックスキーマップ(`C-t` 定義のみ済、配下バインドは未)

### ファイル管理(dired 系)
- [ ] dired-x(omit で .git/.svn 等を非表示)
- [ ] `wdired`(dired 上で一括リネーム) — 組み込みだが dired モジュール一式として未移植
- [ ] `dired-subtree` / `dired-details` / `dired-sort` / `dired+` — パッケージ依存
- [ ] `bf-mode`(dired でファイル内容プレビュー) — パッケージ依存
- [ ] ディレクトリツリー `direx` + `direx-grep` — パッケージ依存
- [ ] `find-dired` 系のバッファ名をユニーク化
- [ ] マーク 2/3 ファイルを ediff `dired-ediff-marked-files`
- [ ] ファイルを名前で開く `ffap`(組み込み)
- [ ] プロジェクト内検索 `find-file-in-project`(build/coverage/dist/node_modules 除外) — パッケージ依存
- [-] `dired-k`(git 状態表示) — 旧設定で `.git/index.lock` 問題により無効化済み。移植しない

### 検索・grep・補完 UI
- [ ] `color-moccur` + `moccur-edit`(横断検索 → 結果を直接編集、除外マスク多数) — パッケージ依存
- [ ] `ag.el` + `wgrep-ag`(ag 検索 → `r` で結果を一括編集) — パッケージ依存
- [ ] `migemo`(ローマ字のまま日本語インクリメンタル検索、cmigemo) — パッケージ依存
- [ ] `ivy` / `counsel` / `swiper`(補完 UI、C-s/C-c g/j/k 等) — パッケージ依存
- [ ] `smex`(M-x 履歴) — パッケージ依存
- [-] `ido` — 旧設定で関連コードはコメントアウト(無効)。移植しない
- [-] `helm` — `90-helm.el.disabled` として無効。移植しない

### Git / 差分
- [ ] `magit`(Git クライアント) — パッケージ依存
- [ ] `ediff`(左右分割・plain ウィンドウ・終了時クリーンアップ・配色カスタム) — 組み込み、未移植
- [ ] `gitignore-mode` — パッケージ依存

### 言語・メジャーモード(いずれもパッケージ依存、未移植)
- [ ] **Go**: go-mode + go-autocomplete + go-eldoc、保存時 gofmt、godef-jump(M-.)
- [ ] **Ruby**: ruby-mode + ruby-block/ruby-end/ruby-electric ほか、rspec-mode、projectile-rails、robe、rhtml-mode
- [ ] **JavaScript / TypeScript**: rjsx-mode、js2-mode、typescript-mode、tide、flow-minor-mode、prettier-js、coffee-mode、json-mode
- [ ] **Web**: web-mode(`.html`/`.ctp`、インデント 2、php エンジン)
- [ ] **PHP**: php-mode / **Lua**: lua-mode / **GraphQL**: graphql-mode(`.graphql`/`.gql`)
- [x] **Markdown**: `markdown-mode`(+ `gfm-mode` for README)。補助 `markdown-toc`(目次)/ `grip-mode`(GitHub 風プレビュー、要 `pip install grip`)を use-package で**移植済み**
- [ ] **マークアップ/データ(残り)**: textile-mode、yaml-mode、apib-mode、haml/slim/sass/scss/less、shell-script(zsh 系)
- [ ] **org-mode**: アジェンダ(C-c a)、`kanban.org`、完了時刻記録 — 組み込み。`C-c a` バインドのみ済
- [ ] プロジェクト管理 `projectile` — パッケージ依存

### シンタックスチェック
- [ ] `flycheck`(グローバル)/ `flymake` / 各種 `flymake-*` チェッカ群 — パッケージ依存。flymake は組み込み版あり
- [ ] JS/TS: eslint + `flycheck-flow`(flow)+ prettier 連携(jshint/jscs は無効)

### 文字コード・フォント・表示
- [ ] 拡張子別 coding-system 設定(`80-encodings.el`)
- [ ] macOS フォント(Monaco + Hiragino Maru Gothic ProN、rescale 調整)
- [ ] 全角記号フォント対応(`use-default-font-for-symbols nil`)
- [-] 行番号 `linum-off` + `global-linum-mode` — **linum は Emacs 29 で廃止**。`display-line-numbers`(prog-mode のみ、幅3)で**代替移植済み**
- [-] テーマ `matrix-on-ice`(auto-install)+ 起動時の緑/黒 仮配色 — パッケージのため不採用。同梱テーマ `wheatgrass` で**代替移植済み**

### macOS 固有
- [x] 修飾キー(command=meta、option=super)、`¥`→`\`、ignore-shortcut
- [x] Karabiner / iTerm2 連携の運用メモ(コメントとして移植)
- [ ] フレームサイズ既定、全画面トグル(C-c m)、ウィンドウ透明度トグル(C-c p) — カスタム関数、未移植(`init.el` にコメントで配置済)
- [ ] migemo(cmigemo) — パッケージ依存

### その他
- [ ] `*scratch*` 永続化(Dropbox 優先で保存、kill 時クリアして再生成、起動時ロード)
- [ ] autosave / backup / undohist のディレクトリ集約(`.autosave` / `.backup` / `.undohist`)
- [ ] `simplenote2`(Simplenote とメモ同期、`~/.authinfo` 認証) — パッケージ依存
- [ ] `tramp`(`/sudo:` `/ssh:`、root は ssh 経由 proxy) — 組み込み、未移植

---

## キーバインド体系(主要なもの)

| キー | 機能 | 依存 |
|---|---|---|
| `C-h` | backspace(help は `C-c h`) | 組み込み |
| `C-a` | `intelli-home-2`(賢い行頭) | カスタム |
| `C-w` | 選択時 kill / 無選択時 単語削除 | カスタム |
| `C-,` / `C-.` | バッファ前後切替 | カスタム |
| `M-o` | `other-window-or-split` | カスタム |
| `C-tab` | `other-window-or-split` | カスタム |
| `F2` / `S-F2` | バッファ入替 | カスタム |
| `C-^` / `C-x C-^` | ウィンドウ自動拡大 / 方向トグル | カスタム |
| `M-/` `C-M-/` | redo | redo+ |
| `F5` / `F6` | point-undo / point-redo | point-undo |
| `M-y` / `C-M-y` | yank-pop 前後 | yank-pop-summary |
| `C-c "` `'` `` ` `` `(` `[` … | リージョン囲み | カスタム |
| `C-s` | swiper | ivy/swiper |
| `C-c g/j/k` | counsel git/git-grep/ag | counsel |
| `C-c d` / `C-c D` | magit-ediff | magit |
| `C-t …` | ウィンドウ/moccur プレフィックス | カスタム/color-moccur |
| `C-z …` | elscreen プレフィックス | elscreen |
| `C-x C-j` | direx プロジェクトルート | direx |
| `jk`(同時押し) | view-mode | key-chord |
| `C-c a` | org-agenda | 組み込み(org) |
| `C-c m` / `C-c p`(mac) | 全画面 / 透明度トグル | カスタム |

---

## 現在の移植状況(本リポジトリ)

`init.el`(単一ファイル構成)に以下を移植済み:

- **基本設定**: 旧 init.el の現役設定(ツールバー/起動画面/`use-short-answers`/
  ゴミ箱削除/関数名表示/インデント既定 など)。
  `linum`→`display-line-numbers`(prog-mode のみ)、`transient-mark-mode nil` は維持、
  テーマは同梱 `wheatgrass`(`matrix-on-ice` の代替)。
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

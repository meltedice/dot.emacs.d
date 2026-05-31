# .emacs.d.30.2-1

Emacs 30.2-1 用の個人設定。旧 `~/.emacs.d`(Emacs 29.x 昇格時にいろいろ壊れた)から、機能を段階的に移植して作り直したもの。

- **主流の単一 `init.el`** 構成(旧 init-loader + `inits/NN-*.el` から再編)
- **`package.el` + `use-package`**(Emacs 30 同梱)、`elpa/` を git 管理(別マシン・上流リンク切れでも復元可)
- **組み込み代替を優先**(elscreen → `tab-bar-mode`、linum → `display-line-numbers`、`color-moccur` → `multi-occur` / `occur-edit-mode` 等)
- **テーマは自前 `themes/matrix-on-ice-theme.el`**(旧 `matrix-on-ice` を deftheme で最小忠実再実装、外部パッケージ非依存)

開発方針・移植進捗・設計判断のトレーサビリティは [CLAUDE.md](CLAUDE.md) を参照。

---

## 目次

- [起動](#起動)
- [新マシンセットアップ](#新マシンセットアップ)
- [キーバインド早見表](#キーバインド早見表)
- [機能と使い方](#機能と使い方)
  - [編集](#編集)
  - [シンボルハイライト・リネーム](#シンボルハイライトリネーム)
  - [Undo / 履歴](#undo--履歴)
  - [バッファ・ウィンドウ](#バッファウィンドウ)
  - [タブ](#タブ)
  - [ファイル管理(dired)](#ファイル管理dired)
  - [プロジェクト](#プロジェクト)
  - [検索 — isearch + migemo](#検索--isearch--migemo)
  - [検索 — 再帰 grep + 結果編集(deadgrep)](#検索--再帰-grep--結果編集deadgrep)
  - [検索・置換 — occur 系(組み込み)](#検索置換--occur-系組み込み)
  - [Git / 差分](#git--差分)
  - [`*scratch*` 永続化](#scratch-永続化)
  - [テーマ](#テーマ)
  - [フォント](#フォント)
  - [Markdown](#markdown)
  - [macOS 固有](#macos-固有)
  - [自動保存 / バックアップ / undo 履歴の集約](#自動保存--バックアップ--undo-履歴の集約)

---

## 起動

Emacs に本ディレクトリを `user-emacs-directory` として認識させる。Emacs 29+ なら `--init-directory` が最も標準的:

```sh
emacs --init-directory ~/.emacs.d.30.2-1
```

他の選択肢:

- `~/.emacs.d` を本ディレクトリへの symlink にする
- `HOME` をラップする起動スクリプトを作る

`early-init.el` を経由する起動経路でないと、起動時の明色フラッシュ防止が効かない(下記「テーマ」参照)。

---

## 新マシンセットアップ

Emacs パッケージは `elpa/` を git で抱えているのでクローンするだけで完結する(ネット不要・上流リンク切れに耐える)。一方、**外部の依存(バイナリ・辞書・フォント)は別途各 OS で入れる必要がある**。導入されていない機能は `use-package :if` で自動スキップされるので起動エラーにはならない。

### cmigemo(ローマ字日本語 isearch のエンジン)

| OS | コマンド | 辞書パス |
|---|---|---|
| **macOS (Apple Silicon / Intel)** | `brew install cmigemo` | Apple Silicon: `/opt/homebrew/share/migemo/utf-8/migemo-dict` / Intel: `/usr/local/share/migemo/utf-8/migemo-dict` |
| **Debian / Ubuntu** | `sudo apt install cmigemo` | `/usr/share/cmigemo/utf-8/migemo-dict` |
| **Windows** | [KaoriYa 配布版](https://www.kaoriya.net/software/cmigemo/) の ZIP を展開し PATH 追加 | 例: `C:\cmigemo-default-win64\dict\utf-8\migemo-dict` |
| その他 (Arch / Nix / source build) | 上流: <https://github.com/koron/cmigemo> | |

辞書は `init.el` の `my-migemo-dictionary` が起動時に上記候補から実在するものを自動選択する。

### ripgrep(`deadgrep` / `wgrep-deadgrep` のエンジン)

| OS | コマンド |
|---|---|
| **macOS** | `brew install ripgrep` |
| **Debian / Ubuntu** | `sudo apt install ripgrep` |
| **Arch** | `sudo pacman -S ripgrep` |
| その他 (Fedora / Nix / Windows / source) | <https://github.com/BurntSushi/ripgrep#installation> |

### フォント(任意 — `M-x my-font-preset` で切替)

`stock-modern`(既定)と `faithful-old` は macOS 同梱フォントのみで動くため追加導入不要。下記 2 つを使いたい場合のみ導入:

```sh
brew install --cask font-udev-gothic
brew install --cask font-plemol-jp
```

未導入のままプリセットを選んだ場合は Emacs の既定フォントへフォールバックする。

### Markdown ライブプレビュー(任意 — `grip-mode` が使用)

```sh
pipx install grip
# または
pip install grip
```

GUI Emacs が `~/.local/bin` を見つけられるよう `exec-path-from-shell` を導入済み(本リビルドで自動)。

### YAML tree-sitter grammar(`.yml` / `.yaml` を扱う場合)

`yaml-ts-mode`(Emacs 同梱、tree-sitter ベース)で開くには **YAML grammar を 1 度だけ導入**する。Emacs 内で:

```
M-x treesit-install-language-grammar RET yaml RET
```

`init.el` の `treesit-language-source-alist` に取得元(`ikatyang/tree-sitter-yaml`)を登録済みなので、追加入力なしでビルド・導入される。**前提**: C コンパイラと `git`(macOS は Xcode Command Line Tools、Linux は `build-essential` + `git`)。

未導入のまま `.yml` を開いても `yaml-mode`(MELPA、`elpa/` に vendored)が fallback として動く。grammar を後から入れた場合は再 visit するだけで `yaml-ts-mode` に切替わる。

#### Apple Silicon 固有: アーキ不一致警告が出た場合

`M-x treesit-install-language-grammar RET yaml RET` を Apple Silicon の Emacs.app(arm64)で実行すると、`*Warnings*` バッファに大量のエラーが出たうえで grammar が読まれない、というケースが起きうる。核心の 1 行はこれ:

```
(mach-o file, but is an incompatible architecture
 (have 'x86_64', need 'arm64e' or 'arm64e.v1' or 'arm64' or 'arm64'))
```

= **Emacs は arm64 で動いているのに、ビルドされた `.dylib` が x86_64** で `dlopen` が拒否されている。`ARCHFLAGS` 等を設定していなくても、子プロセスチェーンのどこかで x86_64 にフォールバックされて起こるパターン(macOS の universal binary 周りの挙動)。

**対処: arm64 を明示して手動ビルドし、既存の x86_64 dylib を置き換える**。シェルで一括:

```sh
# 既存の x86_64 dylib を削除
rm -f ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-yaml.dylib

# tree-sitter-yaml を一時 clone
rm -rf /tmp/ts-yaml
git clone --depth=1 https://github.com/ikatyang/tree-sitter-yaml /tmp/ts-yaml
cd /tmp/ts-yaml

# arm64 を明示してビルド。tree-sitter-yaml の scanner は C++(scanner.cc)で
# 書かれており、内部で schema.generated.cc を #include している。
# C++ コンパイラ (/usr/bin/c++) で parser.c と scanner.cc を一緒にリンクする。
mkdir -p ~/.emacs.d.30.2-1/tree-sitter
/usr/bin/c++ -arch arm64 -shared -fPIC -O2 -I src \
  src/parser.c src/scanner.cc \
  -o ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-yaml.dylib

# 確認(arm64 と出れば成功)
file ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-yaml.dylib
```

Emacs 内で `(treesit-language-available-p 'yaml)` が `t` を返せば完了(`M-:` で評価)。

**他の grammar も同じ症状なら**: 一般化のポイントは(1)`/usr/bin/c++ -arch arm64` で C++ link、(2)その grammar の `src/scanner.{c,cc}` を確認して C/C++ の別に応じて適切なコンパイラを使う、(3)`schema.generated.cc` のような追加 `.cc` は通常 `scanner.cc` の中で `#include` されているので個別には渡さない(渡すと重複定義)。

### JavaScript / TypeScript / JSON tree-sitter grammar

JS/TS/TSX/JSON を `*-ts-mode` で開きたい場合、4 種類の grammar を入れる。Emacs 内で:

```
M-x treesit-install-language-grammar RET javascript RET
M-x treesit-install-language-grammar RET typescript RET
M-x treesit-install-language-grammar RET tsx RET
M-x treesit-install-language-grammar RET json RET
```

(typescript と tsx は同一 repo `tree-sitter/tree-sitter-typescript` のサブディレクトリ。`init.el` で `treesit-language-source-alist` に取得元を登録済み)。

未導入のままでも legacy mode(`js-mode` / `js-json-mode` / `typescript-mode`)に fallback して動く。後から grammar を入れた場合は再 visit で `*-ts-mode` に切替わる(dispatcher 設計)。

**Apple Silicon でアーキ不一致が出た場合**: これら 4 grammar の scanner はすべて C(`scanner.c` のみ、C++ scanner 無し)なので、YAML より単純な手順で済む。例えば javascript の場合:

```sh
rm -f ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-javascript.dylib
rm -rf /tmp/ts-js
git clone --depth=1 https://github.com/tree-sitter/tree-sitter-javascript /tmp/ts-js
cd /tmp/ts-js
/usr/bin/cc -arch arm64 -shared -fPIC -O2 -I src \
  src/parser.c src/scanner.c \
  -o ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-javascript.dylib
file ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-javascript.dylib  # arm64 と出れば OK
```

typescript / tsx は repo 内の `typescript/src` / `tsx/src` サブディレクトリを `-I` と source 指定に使う:

```sh
# typescript の場合(tsx は typescript→tsx に読み替え)
rm -rf /tmp/ts-ts
git clone --depth=1 https://github.com/tree-sitter/tree-sitter-typescript /tmp/ts-ts
cd /tmp/ts-ts/typescript      # tsx の場合は /tmp/ts-ts/tsx
/usr/bin/cc -arch arm64 -shared -fPIC -O2 -I src \
  src/parser.c src/scanner.c \
  -o ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-typescript.dylib
                                       # tsx の場合は libtree-sitter-tsx.dylib
```

json は parser.c のみ(scanner 無し)なので一番単純:

```sh
rm -rf /tmp/ts-json
git clone --depth=1 https://github.com/tree-sitter/tree-sitter-json /tmp/ts-json
cd /tmp/ts-json
/usr/bin/cc -arch arm64 -shared -fPIC -O2 -I src src/parser.c \
  -o ~/.emacs.d.30.2-1/tree-sitter/libtree-sitter-json.dylib
```

各 `(treesit-language-available-p '<name>)` が `t` になれば OK。

### Node LSP / Formatter(任意)

JS/TS / YAML を eglot 経由の LSP で書く場合、本マシンは **volta 管理**のため `volta install` で導入する(volta が無い別マシンは `pnpm add -g` を使う。素の `npm install -g` / `npx` は不採用):

```sh
# JS/TS LSP(eglot 既定で typescript-ts-mode / tsx-ts-mode / js-ts-mode に登録済)
volta install typescript-language-server typescript

# YAML LSP(eglot 既定で yaml-ts-mode / yaml-mode に登録済。GitHub Actions /
#         k8s / Compose スキーマの自動検出+補完が利く)
volta install yaml-language-server

# format-on-save(apheleia と組合せ、任意)
volta install prettier
```

導入後、GUI Emacs を再起動するか `M-x exec-path-from-shell-initialize` で PATH を取り直す → `(executable-find "yaml-language-server")` 等が絶対パスを返せば OK。eglot が hook で自動起動する。

---

## キーバインド早見表

| キー | 機能 | 依存 |
|---|---|---|
| `C-h` | backspace(help は `C-c h`) | 組み込み |
| `C-a` | 賢い行頭(`my-smart-home`、行頭以外 → 行頭 → 最初の非空白) | カスタム |
| `C-w` | 選択時 `kill-region` / 無選択時 単語削除 | カスタム |
| `C-c $` | 行折り返しトグル(`toggle-truncate-lines`) | 組み込み |
| `C-c "` `'` `` ` `` `(` `[` …(15 種) | リージョン囲み(`quote-region-by`) | カスタム |
| `M-y` | `yank-from-kill-ring`(kill-ring 補完選択) | 組み込み |
| `C-g` ×2(0.3 秒以内) | マーク解除 + リージョン解除 | カスタム |
| `M-i` / `M-n` / `M-p` / `F7` / `F8` | symbol-overlay put / next / prev / rename / remove-all | symbol-overlay |
| `C-M-/` | redo(`undo-redo`、Emacs 28+) | 組み込み |
| `C-,` / `C-.` | 前/次のバッファ(特殊バッファは skip-regexp で除外) | 組み込み |
| `jk` 同時押し | `view-mode` トグル | key-chord |
| view-mode 内 `h`/`j`/`k`/`l` / `J`/`K` | 文字移動 / 1 行スクロール | 組み込み (view) |
| `C-x x g` | `revert-buffer-quick`(ディスクの内容で読み直し) | 組み込み |
| `C-c g` | `magit-status` | magit |
| `C-c d` / `C-c D` | `magit-ediff-working-tree` / `magit-ediff` (dwim) | magit |
| `C-s` / `C-r` | `isearch`(migemo でローマ字 → 日本語) | 組み込み + migemo |
| isearch 中 `M-m` | migemo の ON/OFF トグル | migemo |
| `M-x deadgrep` | 再帰 grep(ripgrep) | deadgrep |
| deadgrep 結果バッファ内 `r` | wgrep モード(編集 → `C-c C-c` でファイル反映) | wgrep / wgrep-deadgrep |
| `M-s o` | `occur`(現バッファ) | 組み込み |
| occur 結果バッファ内 `e` | `occur-edit-mode`(編集 → `C-c C-c` でソース反映) | 組み込み |
| `C-x C-j` | `dired-jump` | 組み込み (dired-x) |
| `C-x C-p` | `find-file-at-point`(ffap 軽量採用) | 組み込み |
| `C-x C-n` | `dired-sidebar-toggle-sidebar` | dired-sidebar |
| dired `<tab>` / `<backtab>` | `dired-subtree-toggle` / `dired-subtree-cycle` | dired-subtree |
| dired `r` / `E` | wdired / マーク 2〜3 個を ediff | 組み込み / カスタム |
| dired `A` / `Q` | マーク済みファイル群に regex 検索 / 置換 | 組み込み |
| `C-x p f` / `g` / `r` / `p` / `d` 等 | project.el(find-file / find-regexp / query-replace / switch / find-dir 等) | 組み込み |
| `C-z c` / `C-z C-z` / `C-z 0` / `n` / `p` / `u` / `f` / `1`..`9` | tab-bar(new / recent / close / next / prev / undo / redo / 番号ジャンプ) | 組み込み |
| `C-c a` | `org-agenda` | 組み込み (org) |
| `C-c m` / `C-c p`(macOS) | フレーム最大化トグル / 透明度トグル | カスタム |

---

## 機能と使い方

### 編集

- **スマート行頭 `C-a`** — 行の途中で押すと行頭へ、行頭で押すと最初の非空白文字へ(旧 `intelli-home-2` 忠実)。
- **`C-w`** — 選択中なら `kill-region`、選択なしなら直前の単語を削除。`transient-mark-mode nil` 環境にあわせた振る舞い。
- **リージョン囲み `C-c "` 等(15 種)** — 選択範囲を `"..."` 等で囲む。`C-c (` で `(...)`、`C-c [` で `[...]`、`` C-c ` `` で `` `...` `` ほか。
- **`C-c $`** — `toggle-truncate-lines` で行折り返しトグル。
- **`C-g` 二度押し(0.3 秒以内)** — マーク + リージョンをまとめて解除(旧 `defadvice` を現代 `advice-add` 化)。
- **`M-y`** — `yank-from-kill-ring`(Emacs 28+)。kill-ring を補完選択で貼り付け。

### シンボルハイライト・リネーム

`symbol-overlay`(旧 `auto-highlight-symbol` の現代後継、`prog-mode` で自動 ON)。

- **`M-i`** — 現在位置のシンボルをハイライト/解除。
- **`M-n` / `M-p`** — 次/前のハイライト位置に移動。
- **`F7`** — ハイライト中のシンボルを一括リネーム。
- **`F8`** — 全ハイライト解除。

### Undo / 履歴

- **`C-/` / `C-_`** — undo。
- **`C-M-/`** — redo(組み込み `undo-redo`、Emacs 28+。旧 `redo+` の代替)。
- **`undohist`** — undo 履歴は `.undohist/` 配下に自動保存され、ファイルを開き直しても継続できる。

> 旧 `point-undo`(カーソル位置 undo)は導入見送り。組み込み mark ring(`C-SPC C-SPC` でマーク push、`C-u C-SPC` で pop、`C-x C-SPC` で global mark)で代用。

### バッファ・ウィンドウ

- **`C-,` / `C-.`** — 前/次のバッファに切替。`*Help*` / `*Compile-Log*` / `*Completions*` / `*Shell Command Output*` / `*Apropos*` / `*Buffer List*` は `switch-to-prev-buffer-skip-regexp` で自動スキップ(`*scratch*` / `*Messages*` は巡回対象)。スペース始まりの内部バッファは組み込みが自動スキップ。
- **`jk` 同時押し** → `view-mode` トグル(key-chord、`key-chord-two-keys-delay 0.1`)。
- **view-mode 内のキー**:
  - `h` / `j` / `k` / `l` — 文字単位の移動(true-vi 風)
  - `J` / `K` — 1 行スクロール(`scroll-up-line` / `scroll-down-line`)
  - `e` — view を抜ける(`View-exit`、組み込みの既定を温存)
  - `n` / `p` — 検索反復(同)
  - `SPC` — ページ送り(同)
- **`C-x x g`** — `revert-buffer-quick`(ディスクの内容で読み直し)。未変更なら無確認、変更ありなら y/n 1 回(Emacs 28+ 既定)。

### タブ

`tab-bar-mode` + `tab-bar-history-mode`。旧 elscreen の `C-z` プレフィックスを踏襲。

| キー | 機能 |
|---|---|
| `C-z c` | `tab-bar-new-tab`(新タブ、初期バッファは `*scratch*`) |
| `C-z C-z` | `tab-recent`(直前のタブへ) |
| `C-z 0` | `tab-bar-close-tab` |
| `C-z n` / `C-z p` | 次 / 前のタブ |
| `C-z u` | `tab-bar-history-back`(タブ構成 undo) |
| `C-z f` | `tab-bar-history-forward`(redo) |
| `C-z r` | `tab-bar-rename-tab` |
| `C-z 1` .. `C-z 9` | 番号でタブにジャンプ |

### ファイル管理(dired)

- **`C-x C-j`** — `dired-jump`(現バッファのファイルがあるディレクトリの dired に飛ぶ。旧 direx の代替)。
- **`C-x C-p`** — `find-file-at-point`(ffap、軽量採用。`ffap-bindings` は誤爆回避で不採用)。
- **`C-x C-n`** — `dired-sidebar-toggle-sidebar`(常駐ツリー)。

dired バッファ内:

| キー | 機能 |
|---|---|
| `<tab>` | `dired-subtree-toggle`(サブディレクトリをインライン展開/折りたたみ) |
| `<backtab>` (Shift-Tab) | `dired-subtree-cycle`(全段サイクル) |
| `i` | `dired-maybe-insert-subdir`(組み込み)。旧仕様温存 |
| `r` | `wdired-change-to-wdired-mode`(一括リネーム編集)。`C-x C-q` も併用可 |
| `E` | マーク 2〜3 個のファイルを ediff |
| `A` | `dired-do-find-regexp`(マーク済みファイル群に regex 検索、xref バッファ) |
| `Q` | `dired-do-find-regexp-and-replace`(マーク済みで regex 置換) |
| `(` | `dired-hide-details-mode`(詳細表示トグル) |

挙動:

- `.git` / `.svn` / `CVS` は `dired-omit-mode` で常時非表示
- カーソル移動で**ファイル内容を右ペインに自動プレビュー**(`dired-preview`、遅延 `dired-preview-delay` 既定 0.7 秒)
- `find-dired` / `find-name-dired` / `find-grep-dired` の結果バッファ名は引数を含んでユニーク化(複数回実行で上書きされない)

### プロジェクト

組み込み `project.el`(Emacs 28+)。VCS ルートを自動判定し `.gitignore` を尊重。

| キー | 機能 |
|---|---|
| `C-x p f` | プロジェクト内ファイルを検索して開く |
| `C-x p g` | `project-find-regexp` |
| `C-x p r` | `project-query-replace-regexp` |
| `C-x p p` | プロジェクト切替 |
| `C-x p d` | プロジェクト root の dired |
| `C-x p ?` | 全コマンド一覧 |

xref 結果バッファで `E` を押すと `xref-query-replace-in-results`(検索結果を横断して一括置換)。

### 検索 — isearch + migemo

- **`C-s` / `C-r`** — 通常の `isearch`。`migemo-init` 後はローマ字入力が自動的に日本語にもヒットする(`kensaku` で 検索/研削/献策…、`nihongo` で 日本語/にほんご…)。
- **isearch 中 `M-m`** — migemo の ON/OFF トグル。

cmigemo バイナリ or 辞書が無いマシンでは `use-package :if` で全体スキップされ、`C-s` は素の isearch として動く。

### 検索 — 再帰 grep + 結果編集(deadgrep)

- **`M-x deadgrep`** — ripgrep ベースの再帰検索。プロンプトに正規表現とディレクトリ。
- 結果バッファに**側面フィルタ**(検索種別 / 大文字小文字 / ディレクトリ)が出る。
- 結果バッファ内のキー:
  - **`r`** — wgrep モードに入る(旧 `wgrep-enable-key "r"` を踏襲)
  - 編集する
  - **`C-c C-c`** — ファイルに反映(`wgrep-auto-save-buffer t` で自動保存)

`rg` が PATH に無いマシンでは `use-package :if` でスキップ。

### 検索・置換 — occur 系(組み込み)

旧 `color-moccur` + `moccur-edit` の置き換え。すべて autoload 済み(設定不要)。

| 用途 | コマンド |
|---|---|
| 現バッファで正規表現 occur | `M-s o`(または `M-x occur`) |
| 複数バッファ横断 | `M-x multi-occur`(対話で選択) |
| バッファ名 regex でフィルタして一括 | `M-x multi-occur-in-matching-buffers` |
| occur 結果バッファで編集 → ソース反映 | 結果バッファで `e`(`occur-edit-mode`)→ 編集 → `C-c C-c`(反映) / `C-c C-k`(破棄) |
| dired マーク済みで検索 / 置換 | `A` / `Q`(上述) |
| project 範囲検索 / 置換 | `C-x p g` / `C-x p r` |
| xref 結果で一括置換 | xref バッファで `E`(`xref-query-replace-in-results`) |

詳細チートシートは `init.el` の「検索・置換 チートシート」セクション参照。

### Git / 差分

- **`C-c g`** — `magit-status`。
- **`C-c d`** — `magit-ediff-working-tree`(ワーキングツリー差分)。
- **`C-c D`** — `magit-ediff`(dwim)。
- **`gitignore-mode` 等** — `.gitignore` / `.gitconfig` / `.gitattributes` / `.gitmodules` / `.git/config` / `info/exclude` / `.dockerignore` / `.eslintignore` / `.prettierignore` / `.npmignore` / `.stylelintignore` で自動シンタックス。
- **`ediff`** — 終了時のウィンドウ復元は現代 ediff 任せ(旧 DavidBoon cleanup スニペットは不採用)。

### コード診断 / LSP — `flymake` + `eglot`(両方 Emacs 同梱)

旧 `flycheck` の現代代替。**追加 elpa 不要**(両方 autoload 済み)。

| キー / コマンド | 機能 |
|---|---|
| **`M-g n`** | `next-error`(次の diagnostic にジャンプ。flymake は next-error に登録される)|
| **`M-g p`** | `previous-error`(前の diagnostic にジャンプ)|
| **`C-h .`** | `display-local-help`(カーソル位置の diagnostic 詳細表示)|
| `M-x flymake-show-buffer-diagnostics` | 現バッファの diagnostic 一覧 |
| `M-x flymake-show-project-diagnostics` | プロジェクト全体の diagnostic 一覧 |
| `M-x eglot-rename` | LSP リネーム(symbol 単位) |
| `M-x eglot-format-buffer` | LSP の format 機能でバッファ整形 |
| `M-x eglot-find-implementation` | 実装ジャンプ |
| `M-.` / `M-,` | xref-find-definitions / pop(eglot 経由で LSP go-to-definition / 戻る) |

### モード別動作

- **elisp**: `emacs-lisp-mode-hook` で `flymake-mode` を on。byte-compile 警告と checkdoc 警告がリアルタイム表示される(eglot 不要、組み込みバックエンドで完結)。
- **YAML(`yaml-ts-mode` / `yaml-mode`)**: `eglot-ensure` で `yaml-language-server`(volta install)が自動起動。GitHub Actions / Kubernetes / Compose / Ansible のスキーマ自動検出 + 補完 + 警告。
- **その他の言語**: 移植時に当該メジャーモードのセクションへ `(add-hook '<lang>-(ts-)mode-hook #'eglot-ensure)` を足す(YAML と同じパターン)。

設計の意図(`prog-mode` 全体への flymake 押し付けは避ける、eglot サーバは自動 shutdown 等)は `init.el` の「Diagnostics 基盤」セクションコメント参照。

### `*scratch*` 永続化

`*scratch*` バッファをディスクに保存して起動時に復元する。

- **保存先**: `user-emacs-directory/.scratch-<hostname>`(hostname は `(system-name)` を実行時解決)。`.gitignore` で除外済み(`.scratch*`)。
- **起動時**: 自動で `my-scratch-load` がファイルから `*scratch*` へ復元。
- **Emacs 終了時**: 変更があれば自動保存(`advice-add :before save-buffers-kill-emacs`)。
- **`*scratch*` 内で `C-x C-s`**: 通常の `save-buffer` ではなく `my-scratch-save` で永続化ファイルへ書込(`lisp-interaction-mode-hook` でローカル上書き)。
- **`C-x k` で `*scratch*` を kill**: 実際には削除されず内容クリアにすり替え(`kill-buffer-query-functions`)。
- **`after-save-hook`**: 別ファイル save 後に `*scratch*` が消えていれば自動再生成。

コマンド:

| コマンド | 役割 |
|---|---|
| `M-x my-make-scratch` | `*scratch*` を内容クリア / 再生成 |
| `M-x my-scratch-save` | 手動で書き出し |
| `M-x my-scratch-load` / `M-x my-scratch-reload` | 手動でファイルから読み直し |
| `M-x my-scratch-donot-save` | 今セッション 1 回限り、次回 Emacs 終了時の保存を抑止 |

### テーマ

自前テーマ `themes/matrix-on-ice-theme.el`(旧 `~/.emacs.d/auto-install/matrix-on-ice-theme.el` の名前を引き継ぎつつ、`deftheme` で**最小忠実再実装**したもの。外部パッケージ非依存)。

- **設計方針**: `default` の bg/fg(`#000000` + `#7eff00`)だけ指定し、それ以外の face は **Emacs 既定に任せる**。旧 `matrix-on-ice` も実は elscreen タブ用の 4 face しか触っておらず、ユーザーが「matrix-on-ice の色」と認識していたものの大半は Emacs 既定だった事実をふまえた構成(モードライン=明るいグレー+3D ボタン、リンク=cyan、見出し=ピンク赤太字、font-lock=多彩色)。
- **起動時の明色フラッシュ防止**: `early-init.el` が GUI フレーム生成前に `(load-theme 'matrix-on-ice t)` を呼び、フレームが採用テーマの配色で生まれる(`init.el` 側には `(unless (custom-theme-enabled-p 'matrix-on-ice) ...)` のフォールバックあり)。
- **テーマファイル検索パス**: `themes/` を `custom-theme-load-path` に `add-to-list`(`early-init.el` / `init.el` 両方で冪等に追加)。

### フォント

`M-x my-font-preset` で 4 プリセット即時切替(目視比較用)。

| プリセット | Latin | CJK | 外部導入 |
|---|---|---|---|
| `faithful-old` | Monaco | Hiragino Maru Gothic ProN | macOS 同梱 |
| `stock-modern`(既定) | Menlo | Hiragino Kaku Gothic ProN | macOS 同梱 |
| `udev-gothic` | UDEV Gothic(CJK 同梱 1 本) | (同) | `brew install --cask font-udev-gothic` |
| `plemol-jp` | PlemolJP(CJK 同梱 1 本) | (同) | `brew install --cask font-plemol-jp` |

- サイズは `my-font-height = 140`(= 14pt)固定で揃えてある。
- 起動時の既定プリセットは `my-font-default-preset`(現在 `"stock-modern"`)で制御。
- `daemon` 起動の場合は最初の GUI フレーム生成時に自動適用(`after-make-frame-functions`)。
- `use-default-font-for-symbols nil` を全プリセット共通で維持(`↓` などの記号を fontset 経由 = 全角で表示)。

### Markdown

- `.md` / `.markdown` / `.text` / `.mdt` は `markdown-mode`、`README.md` は `gfm-mode`。
- code block は **言語別 font-lock で着色**(`markdown-fontify-code-blocks-natively t`)。
- **目次生成**: `M-x markdown-toc-generate-toc`(`markdown-toc` パッケージ)。
- **GitHub プレビュー**: `markdown-mode-command-map` 配下に `grip-mode` をバインド(`grip` コマンドが必要、上述)。

### YAML

- `.yml` / `.yaml` を visit すると `my-yaml-mode-dispatch` が走り、**tree-sitter grammar があれば `yaml-ts-mode`、無ければ `yaml-mode`(MELPA、fallback)** に自動で切替わる。grammar 取得は `M-x treesit-install-language-grammar RET yaml RET` を 1 度だけ(上述)。
- **LSP** — `yaml-language-server` が PATH 上にあれば `eglot` が hook で自動起動し、**GitHub Actions / Kubernetes / Docker Compose / Ansible 等のスキーマ自動検出 + 補完 + 警告** が利く。導入は上述「Node LSP / Formatter」参照。
- LSP 起動の有無は mode-line / `M-x eglot-events-buffer` で確認可。

### JavaScript / TypeScript

| 拡張子 | grammar 有り(主) | grammar 無し(fallback)|
|---|---|---|
| `.js` / `.mjs` / `.cjs` | `js-ts-mode` | `js-mode`(組み込み)|
| `.ts` | `typescript-ts-mode` | `typescript-mode`(MELPA、`elpa/` に vendored)|
| `.tsx` | `tsx-ts-mode` | `typescript-mode`(同)|
| `.jsx` | `tsx-ts-mode`(JSX も TSX 扱い)| `typescript-mode`(同)|
| `.json` | `json-ts-mode` | `js-json-mode`(組み込み)|

- visit 時に `my-*-mode-dispatch` が走り `treesit-language-available-p` で grammar の有無を判定して自動切替(YAML と同じ設計)。grammar 取得は「新マシンセットアップ → JavaScript / TypeScript / JSON tree-sitter grammar」参照。
- **LSP** — `typescript-language-server`(volta install)が PATH 上にあれば `eglot` が**5 つの mode すべて(js-mode / js-ts-mode / typescript-ts-mode / tsx-ts-mode / typescript-mode)**で自動起動し、補完・定義ジャンプ(`M-.`)・診断(`M-g n` / `M-g p`)が利く。
- **format-on-save** — `apheleia-global-mode` を有効化済み。保存時に **`prettier`**(volta install)が自動で整形(JS/TS/TSX/JSX/JSON/CSS/Markdown 等、apheleia が知っている全 mode)。フォーマッタが PATH に無い mode は silent skip。
  - 一時的に format-on-save を止めたい場合: `M-x apheleia-mode`(buffer-local トグル)
  - グローバルに止めたい場合: `M-x apheleia-global-mode`(toggle)

### macOS 固有

- 修飾キー: `⌘` = meta、`⌥` = super
- `¥` → `\`
- **`C-c m`** — `mac-toggle-max-window`(`fullscreen` ⇔ `maximized`、メニューバー/Dock を残してフレーム最大化。`fullboth` / macOS ネイティブフルスクリーンは不採用)
- **`C-c p`** — 透明度トグル(alpha 100 ⇔ 90、旧 `mac-toggle-window-alpha` 忠実)
- 初期フレームサイズ: width 120 / height 35
- GUI / daemon で `exec-path-from-shell` がシェル PATH を継承(`~/.local/bin` 等を解決)

### 自動保存 / バックアップ / undo 履歴の集約

Emacs が編集中に作る一時ファイルを `user-emacs-directory` 配下に集約:

| 種別 | 保存先 | 制御変数 |
|---|---|---|
| auto-save 本体 (`#file#`) | `.autosave/` | `auto-save-file-name-transforms`(UNIQUIFY t) |
| auto-save 索引 (`saves-PID-HOST`) | `.autosave/` | `auto-save-list-file-prefix` |
| バックアップ (`file~`) | `.backup/` | `backup-directory-alist` |
| undo 履歴 | `.undohist/` | `undohist`(`undohist-initialize`) |

3 ディレクトリは `.gitignore` で除外済み。

---

## 開発側ドキュメント

このリポジトリの開発方針・移植進捗・設計判断のトレーサビリティは [CLAUDE.md](CLAUDE.md) に集約。

- 旧 `~/.emacs.d` HEAD(`1529d6d`)を基準とした移植チェックリスト([x] / [ ] / [-])
- 各機能の「現代化のポイント」と「採用 / 不採用」の判断記録
- パッケージ運用方針(`elpa/` の git 管理、再生成物の除外、`use-package :vc` 等)
- セッション間で踏襲する作業方針・コミュニケーションスタイル
- 検証用 Emacs バイナリの指定(`/Applications/Emacs-30.2-1.app`)

詳細チートシート(旧 `color-moccur` の代替コマンド早見表など)は `init.el` の該当セクションコメントを参照。

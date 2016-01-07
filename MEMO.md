
## color-moccur

    ;;; moccur
    ;; http://www.bookshelf.jp/cgi-bin/goto.cgi?file=meadow&node=moccur%20install
    ;;(load "moccur") ;; color-moccur に含まれるらしい
    ;; http://www.bookshelf.jp/cgi-bin/goto.cgi?file=meadow&node=color-moccur%20install
    ;; * M-x moccur : ファイルバッファのみを検索 (正規表現)
    ;; * C-u M-x moccur : すべてのバッファを検索 (正規表現)
    ;; * M-x dmoccur : 指定したディレクトリ下のファイルを検索 (正規表現)
    ;; * C-u M-x dmoccur : あらかじめ指定しておいたディレクトリ下のファイルを検索できる (正規表現)
    ;; * M-x moccur-grep : grep のようにファイルを検索 (正規表現)
    ;; * M-x moccur-grep-find : grep+find のようにファイルを検索 (正規表現)
    ;; * M-x search-buffers : すべてのバッファを全文検索．
    ;; * M-x grep-buffers : 開いているファイルを対象に grep ．
    ;; * バッファリストで M-x Buffer-menu-moccur : m でマークをつけたバッファのみを対象に検索
    ;; * dired で M-x dired-do-moccur : m でマークをつけたファイルのみを対象に検索
    ;; * moccur の結果でs:一致したバッファのみで再検索
    ;; * moccur の結果でu:一つ前の条件で検索 
    ;;(load "color-moccur")
    (require 'color-moccur)
    ;; http://www.bookshelf.jp/cgi-bin/goto.cgi?file=meadow&node=edit%20moccur
    ;; * 検索する
    ;;   dmoccur や moccur ， moccur-grep ， moccur-grep-find などで検索して結果を表示させます．
    ;; * 編集モードに入る
    ;;   結果が表示されたところで，r(あるいはC-c C-i か C-x C-q でもいい) とします．すると，バッファが編集できるようになります．
    ;; * 編集する
    ;;   後は編集するだけです．編集すると，編集した箇所には色がつきます．
    ;; * 編集を適用する
    ;;   C-x C-s (あるいは C-c C-c か C-c C-f でも可能) とすると，色がついている変更のみが適用されます．
    ;;   バッファの保存はしませんので，各ファイルを確認してから保存してください．変更した行には色がつきますので，比較的発見しやすいと思います．
    ;; * 一部の変更のみ適用したくない
    ;;   適用したくない部分をリージョンで選択し，C-c C-r とします．そうすると，色が消えて，この変更は適用されなくなります．
    ;; * すべての変更を破棄する
    ;;   すべての変更を適用したくない時には，C-x k(あるいは C-c C-k か C-c k か C-c C-u でも可能) とします．これで，すべての変更は無効になります． 
    ;;(load "moccur-edit")

## Keybindings

    ;; C-x h a 入力した文字列が含まれているコマンドのリストを表示
    ;; C-x h b 現在のキーの割当表を表示する
    ;; C-x h k キーバインドが実行するコマンドの説明
    ;; C-x h w 入力したコマンドを実行するキーを表示
    ;; C-x h f 入力した関数の説明
    ;; C-x h v 入力した変数の説明

    ;; M-x follow-mode   C-x 3 とかで分割したフレームを１つのフレームみたいに連動してスクロールするようにする

    ;; http://www.bookshelf.jp/soft/meadow_42.html#SEC640
    ;; C-M-f, C-M-b : 現在のインデントで，式単位で移動
    ;; C-M-n, C-M-p : 対応する括弧に移動する
    ;; C-M-u, C-M-d : インデントを 1 つ上がる (下がる)
    ;; M-a, M-e     : 文単位で移動
    ;; C-M-a, C-M-e : 関数単位での移動
    ;; C-M-SPC      : 式をリージョンで選択
    ;; C-M-k        : 式を切り取る
    ;; C-M-h        : 関数全体をリージョンで選択します．
    ;; C-M-\        : リージョン内を再インデント

    ;; さらに，全体がどうなっているのか知りたい時には，C-x $ (set-selective-display) が便利です．
    ;; これは，C-u 3 C-x $のように，引数を与えて使います．
    ;; こうすると， 3 文字以上字下げされているものは表示されなくなります．そのため，全体を見回すのに便利です．
    ;; 再度，C-x $とすると，隠れていた部分を元に戻すことができます． 

    ;; C-x [   C-x ]  でページ移動ができる。異動先は ^L があるところ
    ;; C-q C-L で入力した ^L は emacs のページング処理用らしい

    ;; M-x highlight-changes-mode  :  変更箇所の色を変えてくれる

    ;; C-u NUM C-x r n a
    ;;   レジスタ a に NUM をセット (NUM は数値)
    ;;   例： C-u 7 C-x r n c
    ;;   レジスタ c に 7 をセット
    ;; C-x r i a
    ;;   レジスタ a を挿入
    ;; C-x r + a
    ;;   レジスタ a をインクリメント

    ;; GNU Emacs マニュアル Registers 8.7 ブックマーク
    ;; http://www.geocities.co.jp/SiliconValley-Oakland/3432/man/emacs/emacs-ja_11.html
    ;; C-x r m RET
    ;;   訪問先のファイルのポイント位置にブックマークを設定する。
    ;; C-x r m bookmark RET
    ;;   ポイント位置に、bookmarkという名前のブックマークを設定する（bookmark-set）。
    ;; C-x r b bookmark RET
    ;;   名前がbookmarkであるブックマークに移動する（bookmark-jump）。
    ;; C-x r l
    ;;   すべてのブックマークを一覧表示する（list-bookmarks）。
    ;; M-x bookmark-save
    ;;   現在のすべてのブックマークの値をデフォルトのブックマークファイルに保存する。

    ;; 28.3 キーボードマクロ 
    ;; http://www.geocities.co.jp/SiliconValley-Oakland/3432/man/emacs/emacs-ja_31.html
    ;; C-x (
    ;;     キーボードマクロの定義を開始する（start-kbd-macro）。 
    ;; C-x )
    ;;     キーボードマクロの定義を終了する（end-kbd-macro）。 
    ;; C-x e
    ;;     もっとも最近のキーボードマクロを実行する（call-last-kbd-macro）。 
    ;; C-u C-x (
    ;;     もっとも最近のキーボードマクロを再実行したうえで、その定義にキーを追加する。 
    ;; C-x q
    ;;     キーボードマクロの実行中にこの場所に到達したら、実行の確認を求める（kbd-macro-query）。 
    ;; M-x name-last-kbd-macro
    ;;     もっとも最近に定義したキーボードマクロに（現在のEmacsセッションだけで有効な）コマンド名を与える。 
    ;; M-x insert-kbd-macro
    ;;     キーボードマクロの定義をLispコードとしてバッファに挿入する。 
    ;; C-x C-k
    ;;     まえに定義したキーボードマクロを編集する（edit-kbd-macro）。 
    ;; M-x apply-macro-to-region-lines
    ;;     リージョン内の各行に対して、最後に定義したキーボードマクロを実行する。 

    ;; M-x linum-mode
    ;; C-x l
    ;;     行番号を表示する

    ;; M-x dired
    ;; b   bf-mode カーソル移動でファイルの中身を表示 b で開始して b で終了

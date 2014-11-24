
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

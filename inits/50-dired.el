;;; dired


;;; dired-x
(add-hook 'dired-load-hook
          (function (lambda ()
                      (load "dired-x"))))


;;; ignore files
;; default: "^\\.?#\\|^\\.$\\|^\\.\\.$"
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\.git$\\|^\\.svn$\\|^CVS$"))
(add-hook 'dired-mode-hook
          (lambda ()
            (setq dired-omit-files-p t)))


;;; dired-ediff

;; http://www.emacswiki.org/emacs/DavidBoon
(defun dired-ediff-marked-files ()
  "Run ediff on marked ediff files."
  (interactive)
  (set 'marked-files (dired-get-marked-files))
  (when (= (safe-length marked-files) 2)
    (ediff-files (nth 0 marked-files) (nth 1 marked-files)))

  (when (= (safe-length marked-files) 3)
    (ediff3 (buffer-file-name (nth 0 marked-files))
            (buffer-file-name (nth 1 marked-files))
            (buffer-file-name (nth 2 marked-files)))))
;;(define-key dired-mode-map "E"    'dired-ediff-marked-files)

(defun elscreen-dired-ediff-marked-files ()
  "Run ediff on marked ediff files with elscreen."
  (interactive)
  (set 'marked-files (dired-get-marked-files))

  (let ((screen (elscreen-create-internal)))
    (if screen
        (elscreen-goto screen)))

  (when (= (safe-length marked-files) 2)
    (ediff-files (nth 0 marked-files) (nth 1 marked-files)))

  (when (= (safe-length marked-files) 3)
    (ediff3 (buffer-file-name (nth 0 marked-files))
            (buffer-file-name (nth 1 marked-files))
            (buffer-file-name (nth 2 marked-files)))))
(define-key dired-mode-map "E"    'elscreen-dired-ediff-marked-files)


;;; bf-mode
;; http://www.bookshelf.jp/soft/meadow_25.html
;; dired でファイルの内容を別ウィンドウに表示させるマイナーモード
;;
;; dired を表示し，b とします．これで， bf-mode を起動できます．再度，b でオフになります．
;; オンになった状態で，n，pでカーソルを移動すると，別ウィンドウにそのファイルの内容が表示されます．
;; SPCとS-SPCでスクロールできます．
;; bf-mode-html-with-w3m が t なら w3m で表示できます．生の HTML を見たい時には j とします．
;;
(require 'bf-mode)
;; 別ウィンドウに表示するサイズの上限
(setq bf-mode-browsing-size 10)
;; 別ウィンドウに表示しないファイルの拡張子
(setq bf-mode-except-ext '("\\.exe$" "\\.com$" "\\.sys$"
                           "\\.zip$" "\\.gz$" "\\.elc$"))
;; 容量がいくつであっても表示して欲しいもの
(setq bf-mode-force-browse-exts
      (append '("\\.texi$" "\\.el$")
              bf-mode-force-browse-exts))
;; html は w3m で表示する
(setq bf-mode-html-with-w3m t)
;; 圧縮されたファイルを表示
(setq bf-mode-archive-list-verbose t)
;; ディレクトリ内のファイル一覧を表示
(setq bf-mode-directory-list-verbose t)

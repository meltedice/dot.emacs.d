;;; dired

;;; dired-x
(add-hook 'dired-load-hook
          (lambda ()
            ;;; ignore files
            ;; default: "^\\.?#\\|^\\.$\\|^\\.\\.$"
            (setq dired-omit-files
                  (concat dired-omit-files "\\|^\\.git$\\|^\\.svn$\\|^CVS$"))
            (load "dired-x")))


(add-hook 'dired-mode-hook
          (lambda ()
            (setq dired-omit-files-p t)))


;;; wdired - dired 上で一括リネームできる
;; C-x d              dired
;; r                  rename モード
;; ファイル名を編集
;; C-x C-s or C-c C-c で変更を適用
;; C-c C-k            で変更を破棄
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)


;; ;; default
;; ;; (setq find-ls-option
;; ;;       (if (eq system-type 'berkeley-unix)
;; ;;           '("-ls" . "-gilsb")
;; ;;         '("-exec ls -ld {} \\;" . "-ld")))
;; ;; -h option を付けるとインデントが乱れる
;; (setq find-ls-option
;;       (cond ((eq system-type 'berkeley-unix)
;;              '("-ls | sort -k 9" . "-gilsb | sort -k 9"))
;;             ((ubuntu?)
;;              '("-exec ls -ld {} \\; | sort -k 8" . "-ld | sort -k 8"))
;;             ((centos?)
;;              '("-exec ls -ld {} \\; | sort -k 9" . "-ld | sort -k 9"))
;;             (t
;;              '("-exec ls -ld {} \\; | sort -k 9" . "-ld | sort -k 9"))))

;;; /bin/ls -l
;;; Ubuntu
;;drwxr-xr-x  4 you you   4096 2010-04-21 00:39 gtd
;;; CentOS
;;drwxr-xr-x  7 ice ice 4096 Feb 24 06:09 apps
;;; Mac OS X
;;drwxr-xr-x  21 ice   staff   714B Apr 16 16:55 gtd

;;; find-dired したときのバッファ名を変える。複数回実行時にバッファが上書きされるのを防ぐ。
(defadvice find-dired (around multi-find-dired (dir pattern) activate)
  ad-do-it
  (rename-buffer (format "*Find* <%s %s>" dir pattern)))

;;; find-dired したときのバッファ名を変える。複数回実行時にバッファが上書きされるのを防ぐ。
(defadvice find-name-dired (around multi-find-name-dired (dir pattern) activate)
  ad-do-it
  (rename-buffer (format "*FindName* <%s %s>" dir pattern)))

;;; find-dired したときのバッファ名を変える。複数回実行時にバッファが上書きされるのを防ぐ。
(defadvice find-grep-dired (around multi-find-grep-dired (dir regexp) activate)
  ad-do-it
  (rename-buffer (format "*FindGrep* <%s %s>" dir regexp)))


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
(setq bf-mode-browsing-size 1000) ;; kb
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

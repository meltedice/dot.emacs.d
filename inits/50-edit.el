;;; Edit

;;; yank-pop-summary
(autoload 'yank-pop-forward "yank-pop-summary" nil t)
(autoload 'yank-pop-backward "yank-pop-summary" nil t)


;;; C-k at beginning of line, kill whole line including "\n"
(setq kill-whole-line t)


;;; mark が設定されていないときは単語削除、それ以外は kill-region
;; http://d.akinori.org/?date=20070703
(defun kill-region-or-backward-kill-word (&optional arg)
  "Kill a region or a word backward."
  (interactive)
  (if mark-active
      (kill-region (mark) (point))
    (backward-kill-word (or arg 1))))
(define-key minibuffer-local-completion-map "\C-w" 'kill-region-or-backward-kill-word)
(global-set-key "\C-w" 'kill-region-or-backward-kill-word)


;;; C-g で mark を殺す
;; transient-mark-mode が ON の時のような挙動をする
;; see http://www.bookshelf.jp/texi/elisp-manual/21-2-8/jp/elisp_31.html#SEC474
(defun kill-mark ()
  "Kill mark."
  (set-marker (mark-marker) nil)
  (setq deactivate-mark t)
  (setq mark-active nil))

(defvar keyboard-quit-lasttime (float-time)
  "Timestamp (float-time) of last C-g.")

(defvar keyboard-quit-double-c-g-threshold-msec 0.3
  "Threshold (ms) for double C-g to clear mark.")

(defadvice keyboard-quit (before my-keyboard-quit activate)
  "When double C-g whithin `keyboard-quit-double-c-g-threshold-msec`, kill-mark."
  (let* ((tm (float-time)))
    (when (> keyboard-quit-double-c-g-threshold-msec (- tm keyboard-quit-lasttime))
      (kill-mark)
      (message "Mark killed")))
  (setq keyboard-quit-lasttime (float-time)))


;;; intelli-home を改造して C-a の時のカーソル位置の挙動を変更した
;; 行頭以外の C-a で、行頭へ
;; 行頭での   C-a で、最初の空白文字列以外の出現箇所へ
(defun intelli-home-2 ()
  "User method to toggle between 1st text and ZERO column"
  (interactive)
  (catch 'ret
    (let ((pos (point))
          (blpos (line-beginning-position)))

      ;; If at begin of line
      (if (= blpos pos)
          (progn
            (beginning-of-line-text)
            (throw 'ret t)))

      (beginning-of-line)
      (throw 'ret t))))

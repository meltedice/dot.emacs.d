;;; Edit

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

;;; yes/no -> y/n

;; (fset 'yes-or-no-p 'y-or-n-p)
;; (defalias 'yes-or-no-p 'y-or-n-p)

(defun auto-answer-yes-or-no-p (prompt)
  "PROMPT user with a yes-or-no question."
  (cond ((string-match "buffer-undo-list is not empty\\. Do you want to recover now\\?" prompt) t)
        ;; ((string-match "prompt regexp expression here" prompt) t)
        (t (y-or-n-p prompt))))

(defalias 'yes-or-no-p 'auto-answer-yes-or-no-p)

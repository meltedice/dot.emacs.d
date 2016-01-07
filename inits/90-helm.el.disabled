;; -*- coding: utf-8 -*-

;;; helm

(when (require 'helm-config nil t)
  (helm-mode 1)

  ;; disable helm completition
  (custom-set-variables '(helm-ff-auto-update-initial-value nil))
  ;; disable helm on find-file
  (add-to-list 'helm-completing-read-handlers-alist '(find-file . nil))
  (add-to-list 'helm-completing-read-handlers-alist '(find-dired . nil))

  ;; http://d.hatena.ne.jp/a_bicky/20140104/1388822688#20140104f1

  ;; Emulate `kill-line' in helm minibuffer
  (setq helm-delete-minibuffer-contents-from-point t)
  (defadvice helm-delete-minibuffer-contents (before helm-emulate-kill-line activate)
    "Emulate `kill-line' in helm minibuffer"
    (kill-new (buffer-substring (point) (field-end))))

  (defadvice helm-ff-kill-or-find-buffer-fname (around execute-only-if-exist activate)
    "Execute command only if CANDIDATE exists"
    (when (file-exists-p candidate)
      ad-do-it))

  (defadvice helm-ff-transform-fname-for-completion (around my-transform activate)
    "Transform the pattern to reflect my intention"
    (let* ((pattern (ad-get-arg 0))
           (input-pattern (file-name-nondirectory pattern))
           (dirname (file-name-directory pattern)))
      (setq input-pattern (replace-regexp-in-string "\\." "\\\\." input-pattern))
      (setq ad-return-value
            (concat dirname
                    (if (string-match "^\\^" input-pattern)
                        ;; '^' is a pattern for basename
                        ;; and not required because the directory name is prepended
                        (substring input-pattern 1)
                      (concat ".*" input-pattern))))))
  )

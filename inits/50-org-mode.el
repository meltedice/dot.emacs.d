;;; org-mode

;; (global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

;; (setq org-todo-keywords
;;       '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)" "SOMEDAY(s)")))
;; (setq org-todo-keywords
;;       '((sequence "TODO(t)" "NEXT(n)" "ACTIVE(a)" WAIT(w) "|" "DONE(d)")))

;; (setq org-agenda-custom-commands
;;       '(("a" "Agenda and TODO"
;;          ((agenda "")
;;           (alltodo "")))))
(setq org-agenda-columns-add-appointments-to-effort-sum t)
(setq org-agenda-files '("kanban.org"))

(setq org-log-done 'time)

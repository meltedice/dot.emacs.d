;;; ag.el + wgrep.el


;;; ag
;; (setq default-process-coding-system 'utf-8-unix)
(require 'ag)
(setq ag-highlight-search t)
(setq ag-reuse-buffers nil)

;;; wgrep
(add-hook 'ag-mode-hook
          '(lambda ()
             (require 'wgrep-ag)
             (setq wgrep-auto-save-buffer t)
             (setq wgrep-enable-key "r")
             (wgrep-ag-setup)))

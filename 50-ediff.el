;;; ediff

;;; cleanup after ediff
;; http://www.emacswiki.org/emacs/DavidBoon

(defvar my-ediff-bwin-config t "Window configuration before ediff. default nil.")

(defcustom my-ediff-bwin-reg ?b
  "*Register to be set up to hold `my-ediff-bwin-config' configuration.")

(add-hook 'ediff-before-setup-hook
          (lambda ()
            "Function to be called before any buffers or window setup for ediff."
            (remove-hook 'ediff-quit-hook 'ediff-cleanup-mess)
            (window-configuration-to-register my-ediff-bwin-reg)))

(add-hook 'ediff-after-setup-windows-hook
          (lambda ()
            "setup hook used to remove the `ediff-cleanup-mess' function. It causes errors."
            (remove-hook 'ediff-quit-hook 'ediff-cleanup-mess)))

(add-hook 'ediff-quit-hook
          (lambda ()
            "Function to be called when ediff quits."
            (remove-hook 'ediff-quit-hook 'ediff-cleanup-mess)
            (ediff-cleanup-mess)
            (jump-to-register my-ediff-bwin-reg)))

;;; Keybindings for Mac OS X

(setq mac-pass-control-to-system nil)
(setq mac-pass-command-to-system nil)
(setq mac-pass-option-to-system nil)

(when (fboundp 'mac-add-ignore-shortcut)
  (mac-add-ignore-shortcut '(control)))

;;; Swap option <-> command
(setq ns-command-modifier   'meta)
(setq ns-alternate-modifier 'super)
(setq mac-option-modifier   'super) ;; not in use?

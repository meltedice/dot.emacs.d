;;; Keybindings for Mac OS X

;; Use command key as meta key

(setq mac-pass-control-to-system nil)
(setq mac-pass-command-to-system nil)
(setq mac-pass-option-to-system nil)

(when (fboundp 'mac-add-ignore-shortcut)
  (mac-add-ignore-shortcut '(control)))

;;; Swap option <-> command
(setq ns-command-modifier   'meta)
(setq ns-alternate-modifier 'super)
(setq mac-option-modifier   'super) ;; not in use?

;;; Karabiner
;;
;; ## Change Key
;;
;; * Change Semicolon(;) Key
;;     * v Semicolon to Return (when there are not any modifiers)
;;       (+ Control+Semicolon to Semicolon)
;; * For Japanese
;;     * Change EISUU Key
;;         * EISUU to Control_L
;;     * Change KANA Key
;;         * KANA to Control_L
;;     * Change Underscore(Ro) Key
;;         * Underscore(Ro) to Backslash(¥)

;;; for emacs -nw
;; On Terminal.app, its hard to use command key as meta.
;; So switch to use iTerm2.app

;;; iTerm2
;;
;; ## Profiles
;;
;; Select Default -> Other Actions... Duplicate Profile
;; Select duplicated profile
;; Set as Default
;;
;; ### Keys
;;
;; * Left option key acts as:  Normal -> +Esc
;; * Right option key acts as: Normal -> +Esc
;;
;; ## Keys
;;
;; * Left option key:   Left Option   -> Left Command
;; * Right option key:  Right Option  -> Right Command
;; * Left command key:  Left Command  -> Left Option
;; * Right command key: Right Command -> Right Option
;; * +
;;     Keyboard Shortcut: Option + f
;;     Action: Send Escape Sequence
;;     Esc+ f
;; * +
;;     Keyboard Shortcut: Option + b
;;     Action: Send Escape Sequence
;;     Esc+ b
;; * +
;;     Keyboard Shortcut: Option + d
;;     Action: Send Escape Sequence
;;     Esc+ d

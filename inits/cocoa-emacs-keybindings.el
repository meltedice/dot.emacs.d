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
;; ### Keys
;;
;; * Left option key acts as:  Normal -> +Esc
;; * Right option key acts as: Normal -> +Esc
;;
;; ## Keys
;;
;; * +
;;     Keyboard Shortcut: Command + f
;;     Action: Send Escape Sequence
;;     Esc+ f
;; * +
;;     Keyboard Shortcut: Command + b
;;     Action: Send Escape Sequence
;;     Esc+ b
;; * +
;;     Keyboard Shortcut: Command + d
;;     Action: Send Escape Sequence
;;     Esc+ d
;;
;; ## Profiles
;;
;; Select Default -> Other Actions... Duplicate Profile
;; Select duplicated profile
;; Set as Default
;;
;; ### Text
;;
;; Regular Font:   12pt Monaco -> 16pt Osaka-等幅
;; Non-ASCII Font: 12pt Monaco -> 16pt Osaka-等幅
;;
;; ### Terminal
;;
;; Scrollback Buffer: v Unlimited scrollback
;;

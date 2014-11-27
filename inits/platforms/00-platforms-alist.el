
;;; Loads ~/.emacs.d/inits/*.el
;;
;; Platform    Subplatform         Prefix          Example
;; Windows                         windows-        windows-fonts.el
;;             Meadow              meadow-         meadow-commands.el
;; Mac OS X    Carbon Emacs        carbon-emacs-   carbon-emacs-applescript.el
;;             Cocoa Emacs         cocoa-emacs-    cocoa-emacs-plist.el
;; GNU/Linux                       linux-          linux-commands.el
;; All         Non-window system   nw-             nw-key.el
;;

(setq my-init-loader-platform-alist '())

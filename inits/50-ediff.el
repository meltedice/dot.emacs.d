;;; ediff

;; ediff を window の上下分割画面から、左右分割画面にする
(setq ediff-split-window-function 'split-window-horizontally)

;; ediff の control-frame を小さい別 frame に表示せずに、minibuffer の下の window に表示する
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;; Window


;;; バッファを入れ替える
(defun swap-screen()
  "Swap two screen,leaving cursor at current window."
  (interactive)
  (let ((thiswin (selected-window))
        (nextbuf (window-buffer (next-window))))
    (set-window-buffer (next-window) (window-buffer))
    (set-window-buffer thiswin nextbuf)))
(global-set-key [f2] 'swap-screen)

;;; バッファを入れ替える
(defun swap-screen-with-cursor()
  "Swap two screen,with cursor in same buffer."
  (interactive)
  (let ((thiswin (selected-window))
        (thisbuf (window-buffer)))
    (other-window 1)
    (set-window-buffer thiswin (window-buffer))
    (set-window-buffer (selected-window) thisbuf)))
(global-set-key [S-f2] 'swap-screen-with-cursor)


;;; バッファを C-, C-. でどんどん切り替える(移動しないバッファを指定)
(setq my-ignore-buffer-list
      '("*Help*" "*Compile-Log*" "*Mew completions*" "*Completions*"
        "*Shell Command Output*" "*Apropos*" "*Buffer List*"))

(defun my-visible-buffer (blst)
  (let ((bufn (buffer-name (car blst))))
    (if (or (= (aref bufn 0) ? ) (member bufn my-ignore-buffer-list))
        (my-visible-buffer (cdr blst)) (car blst))))

(defun my-grub-buffer ()
  (interactive)
  (switch-to-buffer (my-visible-buffer (reverse (buffer-list)))))

(defun my-bury-buffer ()
  (interactive)
  (bury-buffer)
  (switch-to-buffer (my-visible-buffer (buffer-list))))


;;; ウィンドウ 2 分割時に、縦分割<->横分割
;; http://www.bookshelf.jp/soft/meadow_30.html#SEC401
(defun window-toggle-division ()
  "C-x 2 window <-> C-x 3 window"
  (interactive)
  (unless (= (count-windows 1) 2)
    ;;(error "ウィンドウが 2 分割されていません。"))
    (error "didn't split window into 2 windows"))
  (let (before-height (other-buf (window-buffer (next-window))))
    (setq before-height (window-height))
    (delete-other-windows)
    (if (= (window-height) before-height)
        (split-window-vertically)
      (split-window-horizontally)
      )
    (switch-to-buffer-other-window other-buf)
    (other-window -1)))
(defalias 'toggle-window-division 'window-toggle-division)
;;(global-set-key "\C-t\C-t" 'window-toggle-division)

;;; http://d.hatena.ne.jp/rubikitch/20100210/emacs
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))
(global-set-key [C-tab] 'other-window-or-split)

;;; Split window
(defun two-windows-p ()
  "Return non-nil if two windows exist."
  (= 2 (count-windows)))

(defun windows-edges ()
  "Return current frame windows window-edges."
  (let ((window-edges-list))
    (walk-windows (lambda (w)
                    (setq window-edges-list
                          (append window-edges-list (list (window-edges w))))))
    window-edges-list))

(defun split-window-vertically-p ()
  "Return t if window is split vertically."
  (let ((v nil))
    (walk-windows
     (lambda (w)
       (if (< 1 (cadr (window-edges w))) ;; usually 0 but elscreen uses 1
           (setq v t))))
        v))

(defun split-window-horizontally-p ()
  "Return t if window is split horizontally."
  (let ((v nil))
    (walk-windows
     (lambda (w)
       (if (< 0 (car (window-edges w)))
           (setq v t))))
        v))

(defvar enlarge-window-auto-default-horizontal 'vertical
  "default enlarge direction enlarge-window-auto.
`horizontal' or `vertical'")

(defun toggle-enlarge-window-auto-direction ()
  "toggle enlarge window direction horizontal<-> virtical."
  (interactive)
  (if (eq enlarge-window-auto-default-horizontal 'horizontal)
      (setq enlarge-window-auto-default-horizontal 'vertical)
    (setq enlarge-window-auto-default-horizontal 'horizontal)))

(global-set-key "\C-x\C-^" 'toggle-enlarge-window-auto-direction)

;;; 2 つに分割されているときは、自動で window を広げる方向を判断してくれる
(defun enlarge-window-auto ()
  "enlarge window horizontally or virtically."
  (interactive)
  (if (two-windows-p)
      (if (split-window-vertically-p)
          (enlarge-window 1 nil) ;; vertical
        (enlarge-window 1 t)) ;; horizontal
    (enlarge-window 1 (eq enlarge-window-auto-default-horizontal 'horizontal))))

(global-set-key "\C-^" 'enlarge-window-auto)

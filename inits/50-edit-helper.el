;;; Edit Helper

;;; insert utf-8 mark
(defun insert-coding-utf-8 ()
  "Insert utf-8 mark"
  (interactive)
  (insert "-*- coding: utf-8 -*-"))


;;; Quote region by characters
(defvar quote-region-quoter-alist
  '(("(" . ")") ("{" . "}") ("[" . "]") ("<" . ">")))

(defun quote-region-by (s e)
  "Quote region by last command character."
  (interactive "r")
    (let* ((str (buffer-substring-no-properties s e))
           (original-point (point))
           (quoter (string last-command-event))
           (quoter-begin (let ((quoter-pair (rassoc quoter quote-region-quoter-alist)))
                           (if quoter-pair (car quoter-pair) quoter)))
           (quoter-end   (let ((quoter-pair (assoc quoter quote-region-quoter-alist)))
                           (if quoter-pair (cdr quoter-pair) quoter)))
           (quoted-str   (concat quoter-begin str quoter-end)))
      (delete-region s e)
      (insert quoted-str)
      (goto-char (+ original-point (length quoter-begin) (length quoter-end)))))

(global-set-key "\C-c\"" 'quote-region-by)
(global-set-key "\C-c'"  'quote-region-by)
(global-set-key "\C-c`"  'quote-region-by)
(global-set-key "\C-c/"  'quote-region-by)
(global-set-key "\C-c!"  'quote-region-by)
(global-set-key "\C-c|"  'quote-region-by)
(global-set-key "\C-c%"  'quote-region-by)
(global-set-key "\C-c("  'quote-region-by)
(global-set-key "\C-c{"  'quote-region-by)
(global-set-key "\C-c["  'quote-region-by)
(global-set-key "\C-c<"  'quote-region-by)
(global-set-key "\C-c)"  'quote-region-by)
(global-set-key "\C-c}"  'quote-region-by)
(global-set-key "\C-c]"  'quote-region-by)
(global-set-key "\C-c>"  'quote-region-by)

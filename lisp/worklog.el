;;; integrations/emacs/worklog.el --- Workday Log の入力補助 (Emacs) -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Workday Log（勤務時間の使途記録）を Obsidian の worklog ファイル
;; (`~/ob/Main/Journals/worklog-<YYYY>.md') に書くときの入力補助。
;;
;; ログ行の形式:
;;   - YYYY-MM-DD HH:MM context:activity コメント
;;   例: - 2026-06-15 09:00 jl:dev 作業開始
;;
;; このフェーズ1では、ログ行の行末で RET を押すと、改行して
;; 「現在の勤務日・現在時刻」の prefix（`- YYYY-MM-DD HH:MM '、末尾
;; スペース込み）を自動挿入する。context:activity 以降は手入力する。
;;
;; 勤務日の境界 = 05:00〜翌04:59。深夜〜早朝(00:00〜04:59)の作業は
;; 前日の勤務日に属し、時刻は 24時超え表記(24:00〜28:59)で書く。
;; 勤務日ルールの正本は `docs/spec.md'。`worklog--now-prefix' の挙動は
;; worklog.py の `format_now_prefix'（フェーズ2で実装予定）と一致を保つこと。
;;
;; 有効化スニペット（init.el 等に追記）:
;;
;;   (add-to-list 'load-path "~/path/to/worklog/integrations/emacs")
;;   (require 'worklog)
;;   ;; worklog.md / worklog-<YYYY>.md を開いたら自動で有効化したい場合の例:
;;   (add-hook 'find-file-hook
;;             (lambda ()
;;               (when (and buffer-file-name
;;                          (string-match-p "/worklog\\(?:-[0-9]\\{4\\}\\)?\\.md\\'"
;;                                          buffer-file-name))
;;                 (worklog-mode 1)
;;                 ;; フェーズ2（Alfred）が worklog.md に直接書き込むため、
;;                 ;; 外部変更を自動取り込みして未保存バッファとの競合を緩和する。
;;                 (auto-revert-mode 1))))
;;
;; もしくはバッファで手動: M-x worklog-mode

;;; Code:

(defconst worklog--log-line-regexp
  "^- [0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\} [0-9]\\{2,\\}:[0-9]\\{2\\} "
  "ログ行の行頭プレフィックスにマッチする正規表現。
`- YYYY-MM-DD HH:MM ' の形（HH は24時超え表記もあるため2桁以上）。")

(defun worklog--now-prefix (&optional time)
  "TIME（既定 `current-time'）の勤務日・時刻からログ行 prefix を返す純関数。

戻り値は `- YYYY-MM-DD HH:MM ' 形式の文字列（末尾スペース込み）。

勤務日の日付は (TIME − 5時間) の年月日。表示時は実時刻の時が 5 未満なら
24 を足す(24:00〜28:59 表記)、それ以外はそのまま。分はそのまま。

勤務日ルールの正本は `docs/spec.md'。worklog.py の `format_now_prefix'
（フェーズ2で実装予定）と挙動一致を保つこと。"
  (let* ((time (or time (current-time)))
         (now (decode-time time))
         (hour (nth 2 now))
         (min (nth 1 now))
         ;; 勤務日 = 実時刻から5時間引いた日付。
         (wd (decode-time (time-subtract time (seconds-to-time (* 5 3600)))))
         (year (nth 5 wd))
         (month (nth 4 wd))
         (day (nth 3 wd))
         ;; 表示時: 0〜4時は 24〜28 に繰り上げて前日勤務日に続ける。
         (disp-hour (if (< hour 5) (+ hour 24) hour)))
    (format "- %04d-%02d-%02d %02d:%02d " year month day disp-hour min)))

(defun worklog-newline ()
  "ログ行の行末なら改行して現在時刻の prefix を挿入する。

現在行が `worklog--log-line-regexp' にマッチし、かつ point が行末
(`eolp')のときだけ、改行後に `worklog--now-prefix' の prefix を挿入する
（point は挿入した prefix の末尾に残る）。条件を満たさなければ通常の改行。"
  (interactive)
  (if (and (eolp)
           (save-excursion
             (beginning-of-line)
             (looking-at-p worklog--log-line-regexp)))
      (progn
        (newline)
        (insert (worklog--now-prefix)))
    (newline)))

(defvar worklog-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") #'worklog-newline)
    (define-key map [return] #'worklog-newline)
    map)
  "`worklog-mode' のキーマップ。")

;;;###autoload
(define-minor-mode worklog-mode
  "Workday Log の worklog 入力補助マイナーモード。

有効時、ログ行の行末で RET を押すと改行して現在の勤務日・時刻の
prefix を自動挿入する。"
  :lighter " WL"
  :keymap worklog-mode-map)

(provide 'worklog)

;;; worklog.el ends here

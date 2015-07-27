(deftheme matrix-on-ice
  "Created 2015-07-27.")

(custom-theme-set-faces
 'matrix-on-ice
 '(elscreen-tab-other-screen-face ((((type x w32 mac) (class color)) (:foreground "Gray50" :background "Gray85")) (((class color)) (:underline (:color foreground-color :style line) :foreground "black" :background "GreenYellow"))))
 '(elscreen-tab-current-screen-face ((((class color)) (:foreground "black" :background "white")) (t (:underline (:color foreground-color :style line)))))
 '(elscreen-tab-background-face ((((type x w32 mac) (class color)) (:background "Gray50")) (((class color)) (:background "black"))))
 '(elscreen-tab-control-face ((((type x w32 mac) (class color)) (:underline (:color "Gray50" :style line) :foreground "black" :background "white")) (((class color)) (:underline (:color foreground-color :style line) :foreground "black" :background "white")) (t (:underline (:color foreground-color :style line))))))

;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'matrix-on-ice)

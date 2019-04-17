;;; Graphql mode
(defun graphql-custom ()
  "graphql-mode-hook"
  (and (set (make-local-variable 'tab-width) 2)
       (set (make-local-variable 'graphql-tab-width) 2))
  )
(add-hook 'graphql-mode-hook
  '(lambda() (graphql-custom)))
(add-to-list 'auto-mode-alist '(".*\\.\\(graphql\\|gql\\)\\'" . graphql-mode))

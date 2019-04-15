;; color-moccur
(when (require 'color-moccur nil t)
  ;; assign occur-by-moccur to "M-o"
  (define-key global-map (kbd "M-o") 'occer-by-moccur)
  ;; and search with space
  (setq moccur-split-word t)
  ;; exclusino file
  (add-to-list 'dmoccur-exclusion-mask "¥¥.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$"))

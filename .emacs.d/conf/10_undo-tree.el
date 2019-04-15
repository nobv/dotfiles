;; undo-tree
(when (require 'undo-tree nil t)
  ;; assign redo to "C-'"
  (define-key global-map (kbd "C-'") 'undo-tree-redo)
  (global-undo-tree-mode))

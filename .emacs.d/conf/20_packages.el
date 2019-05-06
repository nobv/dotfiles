;;;; Generic

;;; auto-save-buffers-enhanced
(use-package auto-save-buffers-enhanced
  :ensure t
  :config
  (setq auto-save-buffers-interval 3)
  (auto-save-buffers-enhanced t))

;;; exec-path-from-shell
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-envs '("PATH" "GOROOT" "GOPATH"))))


;;;; Helm

;;; helm
(use-package helm
  :ensure t
  :defer t)

;;; helm-descbinds
(use-package helm-descbinds
  :ensure t
  :config
  (helm-descbinds-mode))


;;;; Complition

;;; company
(use-package company
  :ensure t
  :defer t
  :config
  (global-company-mode))


;;;; Undo/Redo

;;; undo-tree
(use-package undo-tree
  :ensure t
  :bind (("C-'" . undo-tree-redo))
  :init
  (global-undo-tree-mode))

;;; undohist
(use-package undohist
  :ensure t
  :config
  (undohist-initialize))


;;;; Search/Replace/Grep

;;; wgrep
(use-package wgrep
  :ensure t
  :defer t)


;;;; Check

;;; flycheck
(use-package flycheck
  :ensure t)

;;;; Git


;;;; UI

;;; minimap
(use-package minimap
  :ensure t
  :commands
  (minimap-buffer-name minimap-create minimap-kill)
  :custom
  (minimap-window-location 'right)
  (minimap-update-delay 0.2)
  (minimap-minimum-width 20)
  :bind
  ("M-t p" . toggle-minimap)
  :preface
  (defun toggle-minimap ()
    "Toggle minimap for current buffer."
    (interactive)
    (if (null minimap-bufname)
        (minimap-create)
      (minimap-kill)))
  :config
  (custom-set-faces
   '(minimap-active-region-background
     ((((background dark)) (:background "#555555555555"))
      (t (:background "#C847D8FEFFFF"))) :group 'minimap)))



;;;; High-Lights

;;; paren
 (use-package paren
    :ensure nil
    :hook
    (after-init . show-paren-mode)
    :custom-face
    (show-paren-match ((nil (:background "#44475a" :foreground "#cccccc"))))
    :custom
    (show-paren-style 'mixed)
    (show-paren-when-point-inside-paren t)
    (show-paren-when-point-in-periphery t)
    :config
    (set-face-underline-p 'show-paren-match-expression "darkgreen"))


;;; color-moccur
(use-package color-moccur
  :ensure t
  :defer t
  :bind (("M-o" . occer-by-moccur))  
  :config
  ;; and search with space
  (setq moccur-split-word t)
  ;; exclusino file
  (add-to-list 'dmoccur-exclusion-mask "¥¥.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$"))

;;; moccur-edit
(use-package moccur-edit
  :ensure t
  :config
  ;; when end of edit, auto save those files
  (defadvice moccur-edit-change-file
      (after save-after-moccur-dedit-buffer activate)
    (save-buffer)))

;;; elscreen
(use-package elscreen
  :ensure t
  :config
  (setq elscreen-prefix-key (kbd "C-z")))

;;; multi-term
(use-package multi-term
  :ensure t
  :config
  (setq multi-term-program "/bin/zsh"))

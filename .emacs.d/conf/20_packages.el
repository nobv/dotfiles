;;; company
(use-package company
  :ensure t
  :defer t
  :config
  (global-company-mode))

;;; auto-complete
(use-package auto-complete
  :disabled t
  :bind (("M-TAB" . auto-complete))
  :config
  (ac-config-default)
  (setq ac-use-menu-map t)
  (setq ac-ignore-case nil))

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

;;; flycheck
(use-package flycheck
  :ensure t)

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

;;; helm
(use-package helm
  :ensure t
  :defer t)

;;; wgrep
(use-package wgrep
  :ensure t
  :defer t)

;;; auto-save-buffers-enhanced
(use-package auto-save-buffers-enhanced
  :ensure t
  :config
  (setq auto-save-buffers-interval 3)
  (auto-save-buffers-enhanced t))

;;; exec-path-from-shell
(use-package exec-path-from-shell
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "GOROOT" "GOPATH"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

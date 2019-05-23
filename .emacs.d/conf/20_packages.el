;;;; Generic

;;; auto-save-buffers-enhanced
;; (use-package auto-save-buffers-enhanced
;;   :ensure t
;;   :config
;;   (setq auto-save-buffers-interval 3)
;;   (auto-save-buffers-enhanced t))

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
  :ensure t
  :init (global-flycheck-mode))

;;; golangci-lint
(use-package flycheck-golangci-lint
  :ensure t
  :hook (go-mode . flycheck-golangci-lint-setup))

;;; posframe
(use-package posframe
  :ensure t)

;;; flymake-posframe
(use-package flymake-posframe
  :ensure t
  :load-path "~/src/src/github.com/Ladicle/flymake-posframe"
  :hook (flymake-mode . flymake-posframe-mode))

;;;; Git

(use-package magit
  :ensure t
  :custom
  (magit-auto-revert-mode nil)
  :bind
  ("M-g s" . magit-status))

;;;git-gutter
;; (use-package git-gutter
;;   :ensure t
;;   :custom
;;   (git-gutter:modified-sign "~")		; 
;;   (git-gutter:added-sign    "+")		; 
;;   (git-gutter:deleted-sign  "-")		; 
;;   :custom-face
;;   (git-gutter:modified ((t (:foreground "#f1fa8c" :background "#f1fa8c"))))
;;   (git-gutter:added    ((t (:foreground "#50fa7b" :background "#50fa7b"))))
;;   (git-gutter:deleted  ((t (:foreground "#ff79c6" :background "#ff79c6"))))
;;   :config
;;   (global-git-gutter-mode t))

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
  ;; :bind
  ;; ("M-t p" . toggle-minimap)
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

;;; hide mode line
;; (use-package hide-mode-line
;;    :hook
;;    ((neotree-mode imenu-list-minor-mode minimap-mode) . hide-mode-line-mode))

;;; neotree
(use-package neotree
  :after
  projectile
  :commands
  (neotree-show neotree-hide neotree-dir neotree-find)
  :custom
  (neo-theme 'nerd)
  :bind
  ("<f8>" . neotree-current-dir-toggle)
  ("<f9>" . neotree-projectile-toggle)
  :preface
  (defun neotree-projectile-toggle ()
    (interactive)
    (let ((project-dir
           (ignore-errors
           ;;; Pick one: projectile or find-file-in-project
             (projectile-project-root)
             ))
          (file-name (buffer-file-name))
          (neo-smart-open t))
      (if (and (fboundp 'neo-global--window-exists-p)
               (neo-global--window-exists-p))
          (neotree-hide)
        (progn
          (neotree-show)
          (if project-dir
              (neotree-dir project-dir))
          (if file-name
              (neotree-find file-name))))))
  (defun neotree-current-dir-toggle ()
    (interactive)
    (let ((project-dir
           (ignore-errors
             (ffip-project-root)
             ))
          (file-name (buffer-file-name))
          (neo-smart-open t))
      (if (and (fboundp 'neo-global--window-exists-p)
               (neo-global--window-exists-p))
          (neotree-hide)
        (progn
          (neotree-show)
          (if project-dir
              (neotree-dir project-dir))
          (if file-name
              (neotree-find file-name)))))))

;;; modeline
(use-package telephone-line
  :ensure t
  :config
  (telephone-line-mode 1))

;;;; high-Lights

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

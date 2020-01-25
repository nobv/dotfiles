;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here


;;; UI
;; full screen
;;(set-frame-parameter nil 'fullscreen 'fullboth)

;; theme
(use-package! doom-themes
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)
  :config
  (load-theme 'doom-one t)
  (setq doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

;; fonts
(setq
  doom-font (font-spec :family "Source Code Pro" :size 14))

;;; modeline
(setq doom-modeline-buffer-file-name-style 'truncate-all)

;;; soft wrapping
(global-visual-line-mode t)


;;; Emacs
;; Dired
(after! dired
  :config
  (add-hook 'dired-mode-hook 'dired-hide-details-mode))


;;; Tools
;; projectile
;;projectile-project-search-path '("~/src/src/github.com/nobv/"))


;;; Lang
;; Go
;; (after! flycheck-golangci-lint
;;   :config
;;   (setq flycheck-golangci-lint-fast t)
;;   (setq-default flycheck-disabled-checkers '(go-gofmt
;;                                              go-golint
;;                                              go-vet
;;                                              go-build
;;                                              go-test
;;                                              go-errcheck))
;;  )

;; Rust
(setq lsp-rust-server 'rust-analyzer)

;; org
(setq org-directory "~/Google Drive File Stream/My Drive/me/sync/org/")
(after! org
  (defconst notes (concat org-directory "notes.org"))
  (add-to-list 'org-capture-templates
               '("n" "Note"
                 entry
                 (file+headline notes "Note")
                 "* %U %^G %?\n %i\n "
                 :empty-lines 1 :kill-buffer t)))

(use-package! org-bullets
  :custom (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ""))
  :hook (org-mode . org-bullets-mode))

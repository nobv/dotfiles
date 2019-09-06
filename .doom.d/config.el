;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;;
;;; UI

(def-package! doom-themes
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)
  :config
  (load-theme 'doom-dracula t)
  (setq doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

;; fonts
(setq
  doom-font (font-spec :family "Source Code Pro" :size 13))

;;; modeline
(setq doom-modeline-buffer-file-name-style 'truncate-all)

;;;
;;; Tools

;; projectile
;;projectile-project-search-path '("~/src/src/github.com/nobv/"))

;;; flycheck
;; (setq-default flycheck-disabled-checkers
;;              '(
;;                ;;go-gofmt
;;                ;;go-golint
;;                ;;go-vet
;;                ;;go-build
;;                ;;go-test
;;                go-errcheck
;;                go-unconvert
;;                go-megacheck
;;                ;;lsp-ui
;;                ;;go-staticcheck
;;                ))

;; flychk-golangci-lint
(def-package! flycheck-golangci-lint
  :hook (go-mode . flycheck-golangci-lint-setup)
  :config
  (setq flycheck-golangci-lint-fast t)
  (setq-default flycheck-disabled-checkers '(go-gofmt
                                     go-golint
                                     go-vet
                                     go-build
                                     go-test
                                     go-errcheck)))


;;
;;; Lang

;;; go
;;(add-hook! go-mode)

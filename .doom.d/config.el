;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;; flycheck disable
(setq-default flycheck-disabled-checkers
              '(
                ;;go-gofmt
                ;;go-golint
                ;;go-vet
                ;;go-build
                ;;go-test
                go-errcheck
                go-unconvert
                go-megacheck
                ;;lsp-ui
                ;;go-staticcheck
                ))
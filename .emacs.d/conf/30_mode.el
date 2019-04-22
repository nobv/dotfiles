(use-package go-mode
  :ensure t
  :defer t
  :mode
  ("\\.go$" . go-mode)
  :commands
  (go-mode)
  :bind
  (:map go-mode-map
	("M-." . godef-jump)
	("C-c C-r" . go-remove-unused-imports)
	("C-c i" . go-goto-imports)
	("C-c d" . godoc)
	("C-c l" . golint))
  :init
  (add-hook 'go-mode-hook
	    (lambda ()
	      (setq tab-width 4)
	      (setq c-basic-offset 4)
	      (setq indent-tabs-mode t)
	      (if (not (string-match "go" compile-command))
		  (set (make-local-variable 'compile-command)
		       "go-generate && go build -v && go test -v && go vet"))
	      (company-mode)
	      (go-eldoc-setup)
	      (go-guru-hl-identifier-mode)))
  :config
  ;; use packages
  (use-package company
    :ensure t)
  (use-package company-go
    :ensure t)
  (use-package go-eldoc
    :ensure t)
  (use-package flycheck-golangci-lint
    :ensure t
    :hook (go-mode . flycheck-golangci-lint-setup))
  (use-package go-guru
    :ensure t)
  ;; set
  (setenv "GO111MODULE" "on")
  
  (setq godef-command "godef")
  (setq gofmt-command "goimports")
  (setq company-go-show-annotation t)
  ;; flychack settings
  (flycheck-mode)
  (setq flycheck-check-syntax-automatically t)
  (add-to-list 'company-backends '(company-go :with company-dabbrev-code))
  (setq company-transformers '(company-sort-by-backend-importance))
  (add-hook 'before-save-hook 'gofmt-before-save))

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-envs '("PATH" "GOROOT" "GOPATH")))

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

;; emoji
;;(use-package! emojify
;;  :config
;;  (add-hook 'after-init-hook #'global-emojify-mode))

;;; Emacs

;; Dired
(after! dired
  :config
  (add-hook 'dired-mode-hook 'dired-hide-details-mode))


;;; Tools

;; projectile
;;projectile-project-search-path '("~/src/src/github.com/nobv/"))


;;; Lang
(use-package! org
  :hook
    ;; (kill-emacs . org-clock-out-and-save-when-exit)
    (org-clock-in .
                (lambda ()
                  (setq org-mode-line-string (task-clocked-time))
                  (run-at-time 0 60 '(lambda ()
                                       (setq org-mode-line-string (task-clocked-time))
                                       (force-mode-line-update)))
                  (force-mode-line-update))))

;; Go
(after! flycheck-golangci-lint
  :config
  (setq flycheck-golangci-lint-fast t)
  ;; (setq-default flycheck-disabled-checkers '(go-gofmt
  ;;                                            go-golint
  ;;                                            go-vet
  ;;                                            go-build
  ;;                                            go-test
  ;;                                            go-errcheck))
 )

;; Rust
(after! rustic
  (setq lsp-rust-server 'rust-analyzer))

;;; org
(setq org-directory "~/Google Drive File Stream/My Drive/me/sync/org/")

(after! org-capture
  (defconst notes (concat org-directory "notes.org"))
  (defconst tasks (concat org-directory "tasks.org"))
  (defconst bookmarks (concat org-directory "bookmarks.org"))
  (defconst books (concat org-directory "books.org"))
  (defconst wiki-dir (concat org-directory "wiki/"))

  (add-to-list 'org-capture-templates
               '("i" "Inbox"
                 entry
                 (file+headline notes "Inbox")
                 "* %?\n   Entered on %U"
                 :empty-lines 1 :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("t" "Add an private task/event/schedule."
                 entry
                 (file+olp tasks "Tasks" "2019" "Private")
                 "** TODO %?\n   SCHEDULED: <%(org-read-date)>\n"
                 :empty-lines 1 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("T" "Add an work task/event/schedule."
                 entry
                 (file+olp tasks "Tasks" "2019" "Work")
                 "** TODO %?\n   SCHEDULED: <%(org-read-date)>\n"
                 :empty-lines 1 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("b" "Bookmarks"
                 item
                 (file+headline bookmarks "Bookmarks")
                 "- %?\n"
                 :prepend t :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("b" "Books"
                 entry
                 (file+headline books "Inbox")
                 "* %?\n   Entered on %U"
                 :empty-lines 1 :kill-buffer t)))

(use-package! org-bullets
  :custom (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ""))
  :hook (org-mode . org-bullets-mode))

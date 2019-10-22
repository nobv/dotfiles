;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;;; UI

;; full screen
(set-frame-parameter nil 'fullscreen 'fullboth)

;; theme
(def-package! doom-themes
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
(def-package! emojify
  :config
  (add-hook 'after-init-hook #'global-emojify-mode))

;;; Emacs

;; Dired
(after! dired
  :config
  (add-hook 'dired-mode-hook 'dired-hide-details-mode))


;;; Tools

;; projectile
;;projectile-project-search-path '("~/src/src/github.com/nobv/"))

;; org-pomodoro
(def-package! org-pomodoro
  :custom
  (org-pomodoro-ask-upon-killing t)
  (org-pomodoro-format "%s") ;;     
  (org-pomodoro-short-break-format "%s")
  (org-pomodoro-long-break-format  "%s")
  :custom-face
  (org-pomodoro-mode-line ((t (:foreground "#ff5555"))))
  (org-pomodoro-mode-line-break   ((t (:foreground "#50fa7b"))))
  :hook
  (org-pomodoro-started . (lambda () (notifications-notify
                                      :title "org-pomodoro"
                                      :body "Let's focus for 25 minutes!")))
  (org-pomodoro-finished . (lambda () (notifications-notify
                                       :title "org-pomodoro"
                                       :body "Well done! Take a break.")))
  :config
  (when (eq system-type 'darwin)
    (setq alert-default-style 'osx-notifier))
  (require 'alert)
  :bind (:map org-agenda-mode-map
          ("p" . org-pomodoro)))


;;; Lang

;; Go
(def-package! flycheck-golangci-lint
  :hook (go-mode . flycheck-golangci-lint-setup)
  :config
  (setq flycheck-golangci-lint-fast t)
  (setq-default flycheck-disabled-checkers '(go-gofmt
                                             go-golint
                                             go-vet
                                             go-build
                                             go-test
                                             go-errcheck))
  (use-package! go-rename)
  (use-package! go-tag
    :config
    ;; (setq go-tag-args (list "-transform" "camelcase"))

    (map! :map go-mode-map
          :localleader
          "a" #'go-tag-add))
  )

;;; org
(setq org-directory "~/Google Drive File Stream/My Drive/me/sync/org/")

(after! org-capture
  (defconst notes (concat org-directory "notes.org"))
  (defconst tasks (concat org-directory "tasks.org"))
  (defconst bookmarks (concat org-directory "bookmarks.org"))
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
                 :prepend t :kill-buffer t)))

(def-package! org-bullets
  :custom (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ""))
  :hook (org-mode . org-bullets-mode))

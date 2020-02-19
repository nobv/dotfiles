;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here


;;; UI
;; full screen
(set-frame-parameter nil 'fullscreen 'fullboth)

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

;; Rust
(after! rustic
  (setq rustic-lsp-server 'rust-analyzer))

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

;; org
(setq org-directory "~/Google Drive File Stream/My Drive/me/org/")
(after! org
  (defconst notes (concat org-directory "notes.org"))
  (defconst snippets (concat org-directory "snippets.org"))
  (defconst task (concat org-directory "tasks.org"))
  (defconst projects (concat org-directory "projects.org"))

  (setq org-capture-templates
        '(("n" "Notes")))

  (add-to-list 'org-capture-templates
               '("p"
                 "Projects"
                 entry
                 (file+headline projects "Projects")
                 "* TODO %^{Description} [%]
:PROPERTIES:
:SUBJECT: %^{subject}
:GOAL:    %^{goal}
:END:
:RESOURCES:
:END:
+ REQUIREMENTS:
  %^{requirements}
+ NOTES:
  %?
\** TODO %^{task1}"))

  (add-to-list 'org-capture-templates
               '("nn"
                 "Note"
                 entry
                 (file+headline notes "Note")
                 "* %^{description} %^G\n
:PROPERTIES:
:CREATED:    %U
:END:

+ NOTES:
  %?"
                 :empty-lines 1 :kill-buffer t))

  (add-to-list 'org-capture-templates
               '("ns"
                 "Snippet Note"
                 entry
                 (file+headline snippets "Index")
                 "* %^{description} %^G\n
:PROPERTIES:
:SOURCE:  %^{source|command|code|usage}
:END:
#+BEGIN_SRC %^{lang}
%?
#+END_SRC
"))

  (add-to-list 'org-capture-templates
               '("nr"
                 "Snippet Note from region"
                 entry
                 (file+headline snippets "Index")
                 "* %^{description} %^G\n
:PROPERTIES:
:SOURCE:  %^{source|command|code|usage}
:END:
#+BEGIN_SRC %^{lang}
%i
#+END_SRC
%?
")))

(use-package! org-bullets
  :custom (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ""))
  :hook (org-mode . org-bullets-mode))

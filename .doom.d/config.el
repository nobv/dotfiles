;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;;; General
;; enable tab indent
(setq-default indent-tabs-mode t)


;;; UI
;; full screen
;; (set-frame-parameter nil 'fullscreen 'fullboth)
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; theme
(use-package! doom-themes
	:custom
	(doom-themes-enable-italic t)
	(doom-themes-enable-bold t)
	:config
	;; (load-theme 'doom-one t)
	(load-theme 'doom-dracula t)
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

;;; battery
;; (display-battery-mode t)

;;; time
;; (display-time-mode t)

;;; line-numbers
(setq display-line-numbers-type nil)

;;; Emacs
;; Dired
(after! dired
	:config
	(add-hook 'dired-mode-hook 'dired-hide-details-mode))


;;; Tools
;; projectile
;;projectile-project-search-path '("~/src/src/github.com/nobv/"))

;; lsp
;; https://www.reddit.com/r/DoomEmacs/comments/kaoxwy/how_can_i_enable_lspuidocmode_by_default/
(after! lsp-ui
  (setq lsp-ui-doc-enable t))

;; Rust
;; (after! rustic
;;   (setq rustic-lsp-server 'rust-analyzer))

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

;; React
;; (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

;; org
;; (setq org-directory "~/Google Drive File Stream/My Drive/me/org/")
;; (after! org
;; 	(defconst inbox (concat org-directory "inbox.org"))
;; 	(defconst notes (concat org-directory "notes.org"))
;; 	(defconst snippets (concat org-directory "snippets.org"))
;; 	;; (defconst task (concat org-directory "tasks.org"))
;; 	(defconst projects (concat org-directory "projects.org"))

;; 	(setq org-capture-templates
;; 				'(("s" "Snippets")))

;; 	(add-to-list 'org-capture-templates
;; 							 '("p"
;; 								 "Projects"
;; 								 entry
;; 								 (file+headline projects "Projects")
;; 								 "* PROJ %^{project name} [0%]
;; :PROPERTIES:
;; :SUBJECT: %^{subject}
;; :GOAL:    %^{goal}
;; :END:
;; :RESOURCES:
;; :END:

;; + REQUIREMENTS:
;; 	%^{requirements}

;; + NOTES:

;; + References

;; \** [ ] Inbox [0%]\n

;; \** [ ] Anytime [0%]\n

;; \** [ ] Someday [0%]\n

;; \** [ ] Projects [0%]\n
;; \*** %^{task name} [0%]\n
;; 	- %?"
;; 								 :empty-lines 1 :kill-buffer t))

;; 	(add-to-list 'org-capture-templates
;; 							 '("n"
;; 								 "Note"
;; 								 entry
;; 								 (file+headline notes "Inbox")
;; 								 "* %^{description} %^G
;; :PROPERTIES:
;; :CREATED:    %U
;; :END:

;; + NOTES:
;; 	%?"
;; 								 :empty-lines 1 :kill-buffer t))

;; 	(add-to-list 'org-capture-templates
;; 							 '("i" "Inbox"
;; 								 entry
;; 								 (file+headline inbox "Inbox")
;; 								 "* %?\n"
;; 								 :empty-lines 1 :kill-buffer t))


;; 	(add-to-list 'org-capture-templates
;; 							 '("ss"
;; 								 "Snippet"
;; 								 entry
;; 								 (file+headline snippets "Index")
;; 								 "* %^{description} %^G
;; :PROPERTIES:
;; :SOURCE:  %^{type|command|code|usage}
;; :END:

;; + NOTES:
;; 	%?

;; + REFERENCES

;; #+BEGIN_SRC %^{lang}
;; %?
;; #+END_SRC
;; "))

;; 	(add-to-list 'org-capture-templates
;; 							 '("sr"
;; 								 "Snippet from region"
;; 								 entry
;; 								 (file+headline snippets "Index")
;; 								 "* %^{description} %^G
;; :PROPERTIES:
;; :SOURCE:  %^{type|command|code|usage}

;; + NOTES:
;; 	%^{note}

;; + References

;; #+BEGIN_SRC %^{lang}
;; %i
;; #+END_SRC
;; %?
;; ")))

;; (use-package! org-bullets
;; 	:custom (org-bullets-bullet-list '("" "" "" "" "" "" "" "" "" ""))
;; 	:hook (org-mode . org-bullets-mode))

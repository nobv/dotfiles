;; [[file:doom.org::*Fonts][Fonts:1]]
(setq
 doom-font (font-spec :family "Hasklig" :size 14))
;; Fonts:1 ends here

;; [[file:doom.org::*Theme][Theme:2]]
(setq doom-theme 'doom-dracula)
;; (setq doom-theme 'spacemacs-dark)
;; Theme:2 ends here

;; [[file:doom.org::*Line numbers][Line numbers:1]]
(setq display-line-numbers-type 'relative)
;; (setq doom-theme 'spacemacs-dark)
;; Line numbers:1 ends here

;; [[file:doom.org::*anaconda][anaconda:1]]
(setq conda-env-home-directory (expand-file-name "~/.anyenv/envs/pyenv/versions/anaconda3-2021.05"))
(setq conda-anaconda-home (expand-file-name "~/.anyenv/envs/pyenv/versions/anaconda3-2021.05"))
;; anaconda:1 ends here

;; [[file:doom.org::*pylint][pylint:1]]
(setq-default flycheck-disabled-checkers '(python-pylint))
;; pylint:1 ends here

;; [[file:doom.org::*black][black:2]]
(after! python
  :config
  (add-hook! 'python-mode-hook #'python-black-on-save-mode)
  ;; Feel free to throw your own personal keybindings here
  (map! :leader :desc "Black Buffer" "m b b" #'python-black-buffer)
  (map! :leader :desc "Black Region" "m b r" #'python-black-region)
  (map! :leader :desc "Black Statement" "m b s" #'python-black-statement))
;; black:2 ends here

;; [[file:doom.org::*isort][isort:1]]
(after! python
  :config
  (add-hook! 'before-save-hook #'py-isort-before-save))
;; isort:1 ends here

;; [[file:doom.org::*\[\[https:/emacs-lsp.github.io/lsp-mode/page/main-features/\]\[Main features - LSP Mode - LSP support for Emacs\]\]][[[https://emacs-lsp.github.io/lsp-mode/page/main-features/][Main features - LSP Mode - LSP support for Emacs]]:1]]
(after! lsp-ui
  (setq lsp-ui-doc-enable t
        lsp-headerline-breadcrumb-enable t
        lsp-headerline-breadcrumb-segments '(project path-up-to-project file symbol) ;; project, file, path-up-to-project and symbols
        lsp-ui-doc-max-height 30
        lsp-ui-doc-max-width 150
        lsp-lens-enable t
        lsp-ui-sideline-enable t
        lsp-ui-doc-position 'top) ;; top, bottom or at-point
  )
;; [[https://emacs-lsp.github.io/lsp-mode/page/main-features/][Main features - LSP Mode - LSP support for Emacs]]:1 ends here

;; [[file:doom.org::*org-auto-tangle][org-auto-tangle:2]]
(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))
;; org-auto-tangle:2 ends here

;; [[file:doom.org::*+lookup/definition-other-window][+lookup/definition-other-window:1]]
;; (dolist (fn '(definition references))
;;   (fset (intern (format "+lookup/%s-other-window" fn))
;;         (lambda (identifier &optional arg)
;;           "TODO"
;;           (interactive (list (d)
;;           (let ((pt (point)))
;;             (switch-to-buffer-other-window (current-buffer))
;;             (goto-char pt)
;;             (funcall (intern (format "+lookup/%s" fn)) identifier arg)))))
;; (define-key evil-normal-state-map "gow" '+lookup/definition-other-window)
;; +lookup/definition-other-window:1 ends here

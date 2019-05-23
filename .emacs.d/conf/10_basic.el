;;;; general

;;;
(fset 'yes-or-no-p 'y-or-n-p)

;;; ignore ring-gell
(setq ring-bell-function 'ignore)

;;;; appearance

;;; show line number
(global-linum-mode t)

;;; disable-tool-bar
(tool-bar-mode 0)

;;; disable scroll-bar-mode
(scroll-bar-mode 0)

;;; theme
(use-package monokai-theme
  :ensure t
  :config
  (load-theme 'monokai))
;; (use-package solarized-theme
;;   :ensure t
;;   :config
;;   (load-theme 'solarized-dark))

;;; fonts
(set-face-attribute 'default nil
		    :family "Cica"
		    :height 140)

;;; for japanese
;;(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-file-coding-system 'utf-8)


;;;; mode-line

;;; show column
(column-number-mode t)

;;; show file size
(size-indication-mode t)

;;; show clock
(setq display-time-day-and-date t)
(setq display-time24hr-format t)
(display-time-mode t)
;; show battery
(display-battery-mode t)


;;;; files

;;; aggregate buckup files and auto save files to ~/.emacs.d/backups
(add-to-list 'backup-directory-alist
	     (cons ".""~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*",(expand-file-name "~/.emacs.d/backups/")t)))

;;; don't create lock file
(setq create-lockfiles nil)

;;; read again automatically
(global-auto-revert-mode t)

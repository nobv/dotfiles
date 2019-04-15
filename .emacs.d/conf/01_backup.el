;; change backup files destination to tmporary directory
(setq backup-directory-alist
      `((".*".,temporary-file-directory)))
;; change auto save destination to temporary directory
(setq auto-save-file-name-transforms
      `((".*",temporary-file-directory t)))
;; aggregate buckup files and auto save files to ~/.emacs.d/backups
(add-to-list 'backup-directory-alist
	     (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/")

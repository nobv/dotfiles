;;;;; load path function
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	      (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))
;; add directory to load path 
(add-to-load-path "elisp" "conf" "public_repos")


;;;;; ensure to use package.el
(require 'package)
(add-to-list
 'package-archives
 '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))
(add-to-list
 'package-archives
 '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list
 'package-archives
 '("org" . "http://orgmode.org/elpa/"))
(package-initialize)
(package-refresh-contents)

;;;;; ensure to use use-package
(when (not (package-installed-p 'use-package))
  (package-install 'use-package))
(require 'use-package)

;;;;; init-loader
(use-package init-loader
	     :ensure t
	     :config
	     (init-loader-load "~/.emacs.d/conf"))

;;;;; change tha place for custom
;; make custom file into another file
(setq custom-file (locate-user-emacs-file "custom.el"))
;; when not exsits custom file, create custom file
(unless (file-exists-p custom-file)
  (write-region "" nil cusotm-file))
;; load custom file
(load custom-file)

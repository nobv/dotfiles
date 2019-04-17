;; load path function
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

;; enable package.el
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

;; update package
;; (package-refresh-contents)

;; install package list
(defvar installing-package-list
  '(
    ;; loader
    init-loader
    ;; helm
    helm
    ;; grep
    wgrep
    ;; moccur
    color-moccur
    moccur-edit
    ;; edit
    auto-complete
    ;; lint
    flycheck
    ;; undo
    undohist
    undo-tree
    ;; git
    magit
    ;; go
    go-mode
    go-autocomplete
    ;; environment
    elscreen
    exec-path-from-shell
    multi-term
    ;; theme
    solarized-theme
    monokai-theme
    gruvbox-theme
    ))

;; install packages
(unless package-archive-contents (package-refresh-contents))
(dolist (package installing-package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; make custom file into another file
(setq custom-file (locate-user-emacs-file "custom.el"))
;; when not exsits custom file, create custom file
(unless (file-exists-p custom-file)
  (write-region "" nil cusotm-file))
;; load custom file
(load custom-file)

;; init-loader
(require 'init-loader)
(setq init-loader-show-log-after-init t)
(init-loader-load "~/.emacs.d/conf")

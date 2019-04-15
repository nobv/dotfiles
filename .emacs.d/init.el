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
(package-reflesh-contents)

;; install package list
(defvar installing-package-list
  '(
    init-loader
    helm
    auto-complete
    color-moccur
    moccur-edit
    wgrep
    undohist
    elscreen
    go-mode
    company-go
    ))

;; install packages
(dolist (package installing-package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; init-loader
(require 'init-loader)
(init-loader-load "~/.emacs.d/conf")


;; Helm
(require 'helm-config)

;; auto-complete
(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default)
  (setq ac-use-menu-map t)
  (setq ac-ignore-case nil))

;; color-moccur
(when (require 'color-moccur nil t)
  ;; assign occur-by-moccur to "M-o"
  (define-key global-map (kbd "M-o") 'occer-by-moccur)
  ;; and search with space
  (setq moccur-split-word t)
  ;; exclusino file
  (add-to-list 'dmoccur-exclusion-mask "¥¥.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$"))

;; moccur-edit
(require 'moccur-edit nil t)
;; when end of edit, auto save those files
(defadvice moccur-edit-change-file
    (after save-after-moccur-dedit-buffer activate)
  (save-buffer))

;; wgrep
(require 'wgrep nil t)q

;; undohist
(when (require 'undohist nil t)
  (undohist-initialize))

;; undo-tree
(when (require 'undo-tree nil t)
  ;; assign redo to "C-'"
  (define-key global-map (kbd "C-'") 'undo-tree-redo)
  (global-undo-tree-mode))

;; multi-term
(when (require 'multi-term nil t)
  (setq multi-term-program "/bin/zsh"))

;; go-mode
(require 'go-mode-load)

;; go-autocomplete
(require 'go-autocomplete)
(require 'auto-complete-config)
(ac-config-default)
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH"))

;; make custom file into another file
(setq custom-file (locate-user-emacs-file "custom.el"))
;; when not exsits custom file, create custom file
(unless (file-exists-p custom-file)
  (write-region "" nil cusotm-file))
;; load custom file
(load custom-file)


;; for mac
(when (eq system-type 'darwin)
  (setq file-name-coding-system 'utf-8-hfs)
  (require 'ucs-normalize)
  (setq locale-coding-system 'utf-8-hfs))

;;
(when window-system
  (tool-bar-mode 0)
  (scroll-bar-mode 0))

;; ----------
;; mode-line
;; ----------

;; show column
(column-number-mode t)
;; show file size
(size-indication-mode t)
;; show clock
(setq display-time-day-and-date t)
(setq display-time24hr-format t)
(display-time-mode t)
;; show battery
(display-battery-mode t)

;; show
(defun count-lines-and-chars ()
  (fi mark-active
      (format "(%dlines,%dchars)"
	      (count-lines (regiobn-beginning) (region-end))
	      (-(region-end) (region-beginning)))
      ""))
(add-to-list 'default-mode-line-format
	     '(:eval(count-lines-and-chars)))

;; show line number
(global-linum-mode t)

;;
(setq backup-directory-alist
      `((".*".,temporary-file-directory)))
;;
(setq auto-save-file-name-transforms
      `((".*",temporary-file-directory t)))

;; --------
;; Assign
;; --------

(global-set-key (kbd "C-m") 'newline-and-indent)
(define-key global-map (kbd "C-x ?") 'help-command)
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
(define-key global-map (kbd "C-t") 'other-window)


;; -------- 
;; Replace
;; --------

(define-key key-translation-map (kbd "C-h")
  (kbd "<DEL>"))

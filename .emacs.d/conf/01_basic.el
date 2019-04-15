;; for mac
(when (eq system-type 'darwin)
  (setq file-name-coding-system 'utf-8-hfs)
  (require 'ucs-normalize)
  (setq locale-coding-system 'utf-8-hfs))

;;
(when window-system
  (tool-bar-mode 0)
  (scroll-bar-mode 0))

;; read again automatically
(global-auto-revert-mode t)

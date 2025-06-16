;;;;; Emacs server
(use-package server
  :ensure t
  :init
  (server-mode 1)
  :config
  (unless (server-running-p)
    (server-start))
  (defun iconify-emacs-when-server-is-done()
    (unless server-clients (iconify-frame)))
  ;; confirm to kill
  (setq confirm-kill-emacs 'yes-or-no-p))

;;;;; Emacs server
(use-package server
  :ensure t
  :config
  (unless (server-runnning-p)
    (server-start))
  (defun iconify-emacs-when-server-is-done()
    (unless server-clients (iconify-frame)))
  ;; confirm to kill
  (setq confirm-kill-emacs 'yes-or-no-p))


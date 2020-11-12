;;; packages.el --- purescript-ex layer packages file for Spacemacs.

(defconst purescript-ex-packages
  '(
    purescript-mode
    ))

(defun purescript-ex/post-init-purescript-mode ()
    (add-hook 'before-save-hook (lambda () (when (eq 'purescript-mode major-mode)
                                             (lsp-format-buffer)))))

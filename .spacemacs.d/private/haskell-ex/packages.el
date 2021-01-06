;;; packages.el --- haskell-ex layer packages file for Spacemacs.

(defconst haskell-ex-packages
  '(
    haskell-mode
    ))

(defun haskell-ex/post-init-haskell-mode ()
  (add-hook 'before-save-hook (lambda () (when (eq 'haskell-mode major-mode)
                                           (lsp-format-buffer)))))


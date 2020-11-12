;;; package.el ---

(defconst go-ex-packages
  '(
    go-mode
    ))

(defun go-ex/pre-init-dap-mode ()
  (pcase (spacemacs//go-backend)
    (`lsp (add-to-list 'spacemacs--dap-supported-modes 'go-mode)))

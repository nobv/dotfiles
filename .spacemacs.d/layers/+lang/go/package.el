;;; package.el ---


(defun go/pre-init-dap-mode ()
  (pcase (spacemacs//go-backend)
    (`lsp (add-to-list 'spacemacs--dap-supported-modes 'go-mode)))

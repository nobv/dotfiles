;;; packages.el --- web-ex layer packages file for Spacemacs.


(defconst web-ex-packages
  '(
    web-mode
    ))

(defun web-ex/post-init-web-mode ()
  (set-web-mode-indent 2)
)

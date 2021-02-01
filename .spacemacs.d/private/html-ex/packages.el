;;; packages.el --- html-ex layer packages file for Spacemacs.


(defconst html-ex-packages
  '(
    web-mode
    ))

(defun html-ex/post-init-web-mode ()
 (set-html-mode-indent 2))

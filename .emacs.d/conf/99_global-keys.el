;; --------
;; Assign
;; --------

(global-set-key (kbd "C-m") 'newline-and-indent)
(define-key global-map (kbd "C-x ?") 'help-command)
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
(define-key global-map (kbd "C-t") 'other-window)
(global-set-key (kbd "C-x g") 'magit-status)

;; hel,
(define-key global-map (kbd "C-h f") 'helm-for-files)

;; -------- 
;; Replace
;; --------

;;(define-key key-translation-map (kbd "C-h")
;;  (kbd "<DEL>"))



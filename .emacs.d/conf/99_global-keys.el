;; --------
;; Assign
;; --------

(global-set-key (kbd "C-m") 'newline-and-indent)
(global-set-key (kbd "C-x ?") 'help-command)
(global-set-key (kbd "C-c l") 'toggle-truncate-lines)
(global-set-key (kbd "C-t") 'other-window)
(global-set-key (kbd "C-x g") 'magit-status)

;; helm
(define-key global-map (kbd "C-h f") 'helm-for-files)

;; -------- 
;; Replace
;; --------

;;(define-key key-translation-map (kbd "C-h")
;;  (kbd "<DEL>"))



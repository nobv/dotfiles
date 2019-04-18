;; ----------------------------------------
;; theme
;; ----------------------------------------
;; (load-theme 'solarized-dark)
(load-theme 'monokai)

;; ----------------------------------------
;; fonts
;; ----------------------------------------
(set-face-attribute 'default nil
		    :family "Cica"
		    :height 160)

;; ----------------------------------------
;; other
;; ----------------------------------------

;; show line number
(global-linum-mode t)

;; paren-mode
 (show-paren-mode 0)
(setq show-paren-delay 0)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match nil)
(set-face-underline-p 'show-paren-match-expression "syan"k)

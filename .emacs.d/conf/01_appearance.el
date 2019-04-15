;; ----------------------------------------
;; theme
;; ----------------------------------------
;; (load-theme 'solarized-dark)
(load-theme 'monokai)

;; ----------------------------------------
;; fonts
;; ----------------------------------------
(set-face-attribute 'default nil
		    :family "Hack Regular Nerd Font Complete"
		    :height 150)

;; ----------------------------------------
;; other
;; ----------------------------------------

;; show line number
(global-linum-mode t)

;; paren-mode
 (show-paren-mode t)
(setq show-paren-delay 0)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match nil)
(set-face-underline-p 'show-paren-match-expression "syan")

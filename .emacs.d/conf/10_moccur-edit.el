;; moccur-edit
(require 'moccur-edit nil t)
;; when end of edit, auto save those files
(defadvice moccur-edit-change-file
    (after save-after-moccur-dedit-buffer activate)
  (save-buffer))

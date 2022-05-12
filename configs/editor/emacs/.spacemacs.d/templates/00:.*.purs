module ${1:`(if (not buffer-file-name) "Module"
(let ((name (file-name-sans-extension (buffer-file-name))))
(if (search "src/" name)
(replace-regexp-in-string "/" "." (car (last (split-string name "src/"))))
(file-name-nondirectory name))))`} where

import Prelude

$0
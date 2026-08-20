; Window isolate and restore:
;   1. enable winner mode
;   2. focus on one window and C-x 1
;   3. C-c left to undo deletion
; Use elisp-autofmt to format this file
; To search marked text, first copy it with C-Spc then M-w or yank, then C-s to search and C-y to paste
; To set mark, press C-SPC twice (mark + selection then deselect). To set bookmark (similar to mark in vim)
; To delete words without moving cursor, use M-d. To select forward without moving cursor, C-SPC then C-M-SPC. C-d to delete and forward. M-\ to remove surrounding spaces.
; M-m to jump back to indentation 
; Use package-refresh-contents to fetch latest package information
; Use C-x o to rotate between windows

; remove some ui components
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-tab-line-mode 1)
(setq-default project-mode-line t)
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil) ; tab to space
(setq-default evil-shift-width 4)
(setq evil-ex-search-smart-case t)
; make files up-to-date
(global-auto-revert-mode 1)
; set this so you dont need to type yes and no
(defalias 'yes-or-no-p 'y-or-n-p)
; cursor
(setq-default cursor-type 'box)
(blink-cursor-mode 1)
; window focus
(keymap-global-set "C-c l" 'windmove-right)
(keymap-global-set "C-c h" 'windmove-left)
(keymap-global-set "C-c k" 'windmove-up)
(keymap-global-set "C-c j" 'windmove-down)
(keymap-global-set "C-c C-l" 'load-file)
; line number
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
; eshell
(with-eval-after-load 'em-prompt
  (set-face-attribute 'eshell-prompt nil :foreground "#8BD5CA"))

(require 'package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

; remove warning messages while installing packages
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))
(use-package magit :ensure t)
(use-package elisp-autofmt :ensure t)
; smartparens
(use-package
 smartparens
 :ensure t
 :config
 (require 'smartparens-config)
 (smartparens-global-mode t))
; git gutter
(use-package
 git-gutter
 :ensure t
 :hook ((prog-mode org-mode) . git-gutter-mode)
 :config (setq git-gutter:update-interval 0.02))
(use-package
 git-gutter-fringe
 :ensure t
 :config
 (define-fringe-bitmap 'git-gutter-fr:added [224]
   nil
   nil
   '(center repeated))
 (define-fringe-bitmap 'git-gutter-fr:modified [224]
   nil
   nil
   '(center repeated))
 (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240]
   nil nil 'bottom))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer isn open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'prot/keyboard-quit-dwim)

(let ((mono-spaced-font "Iosevka")
      (proportionately-spaced-font "Sans"))
  (set-face-attribute 'default nil :family mono-spaced-font :height 100)
  (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
  (set-face-attribute 'variable-pitch nil :family proportionately-spaced-font :height 1.0))
; theme
(load-theme 'myDarkTheme t)
; mode line
(defun mode-line-percent-position ()
  "cursor position percentage"
  (concat
   " "
   (format "%.1f%%"
           (* 100
              (/ (float (- (point) (point-min)))
                 (max 1 (- (point-max) (point-min))))))))
(defface cursor-position-face
  '((t :background "#B8C0E0" :foreground "black"))
  "cursor position face")
(setq-default mode-line-format
              '((:propertize "▓" face (:foreground "#7E55B3"))
                (:propertize
                 " Ɛ " face
                 (:background
                  "#7E55B3"
                  :foreground "#F9FAFB"
                  :weight bold))
                (:propertize "▓▒" face (:foreground "#7E55B3"))
                              " "
                (:propertize
                 (""
                  mode-line-mule-info
                  mode-line-client
                  mode-line-modified
                  mode-line-remote
                  mode-line-window-dedicated)
                 display (min-width (6.0)))
                "%e"
                mode-line-front-space
                mode-line-frame-identification
                (:propertize
                 mode-line-buffer-identification
                 face
                 (:weight bold :foreground "#C678DD"))
                " "
                (project-mode-line project-mode-line-format)
                (vc-mode vc-mode)
                " "
                mode-line-modes
                mode-line-misc-info
                ;; Right-aligned section with position
                (:eval
                 (propertize
                  " "
                  'display
                  `((space
                     :align-to
                     (-
                      right
                      ,(+ (length
                           (format-mode-line
                            (concat
                             (mode-line-percent-position) "% %l:%c")))
                          4))))))
                (:propertize "░▒▓" face (:foreground "#B8C0E0"))
                (:eval
                 (propertize (concat (mode-line-percent-position) "%")
                             'face 'cursor-position-face))
                (:eval
                 (propertize " %l:%c " 'face 'cursor-position-face))
                (:propertize "▓" face (:foreground "#B8C0E0"))))
; ligature
(use-package
 ligature
 :ensure t
 :config
 (ligature-set-ligatures
  't
  '("<|"
    "|>"
    "<|>"
    "||"
    "|="
    "||-"
    "-|"
    "-||"
    "=="
    "!="
    "<="
    ">="
    "==="
    "!=="
    "=!="
    "<==>"
    "==>"
    "<===>"
    "===>"
    "<=>"
    "<=="
    "=="
    "->"
    "<-"
    "<-->"
    "-->"
    "<--->"
    "--->"
    "<->"
    "<--"
    "--"
    ".."
    "..."
    "..<"
    "::"
    ":::"
    ":="
    ":<"
    "!!"
    "?:"
    "??"
    "?."
    "?="
    "?!"
    "<>"
    "<<"
    ">>"
    "<<<"
    ">>>"
    "<->"
    "<=>"
    "<!--"
    "&&"
    "||"
    ":="
    "^="
    "++"
    "--"
    "+>"
    "<+"
    "+++"
    "--+"
    "+++"))
 (global-ligature-mode t))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(elisp-autofmt git-gutter git-gutter-fringe ligature magit
                   smartparens)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)

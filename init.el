(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(require 'use-package)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)

(require 'server)

(unless (server-running-p)
  (server-start))

(use-package gcmh
  :straight t
  :diminish
  :init (setq gc-cons-threshold (* 80 1024 1024))
  :hook (emacs-startup . gcmh-mode))

(use-package exec-path-from-shell
  :straight t
  :config
  (exec-path-from-shell-initialize))

(use-package no-littering
  :straight t
  :init
  (setq make-backup-files nil)
  (setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))
  (setq no-littering-etc-directory "~/.cache/emacs/etc/"
	no-littering-var-directory "~/.cache/emacs/var/"
	auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
      (convert-standard-filename
	(expand-file-name  "eln-cache/" no-littering-var-directory)))))

(straight-use-package
 '(nano-emacs :type git :host github :repo "rougier/nano-emacs"))

(require 'nano-theme-dark)
(require 'nano-faces)
(require 'nano-theme)
(require 'nano-modeline)
(require 'nano-splash)
(require 'nano-layout)

(defun nano-theme-set-dark ()
  "Apply dark Nano theme base."
  ;; Colors from Nord theme at https://www.nordtheme.com
  (setq frame-background-mode     'dark)
  (setq nano-color-foreground "#ECEFF4") ;; Snow Storm 3  / nord  6
  (setq nano-color-background "#2E3440") ;; Polar Night 0 / nord  0
  (setq nano-color-highlight  "#3B4252") ;; Polar Night 1 / nord  1
  (setq nano-color-critical   "#EBCB8B") ;; Aurora        / nord 11
  (setq nano-color-salient    "#81A1C1") ;; Frost         / nord  9
  (setq nano-color-strong     "#ECEFF4") ;; Snow Storm 3  / nord  6
  (setq nano-color-popout     "#D08770") ;; Aurora        / nord 12
  (setq nano-color-subtle     "#434C5E") ;; Polar Night 2 / nord  2
  (setq nano-color-faded      "#677691") ;;
  ;; to allow for toggling of the themes.
  (setq nano-theme-var "dark"))

(nano-theme-set-dark)
(nano-faces)
(nano-theme)

(setq inhibit-startup-message t)
(set-fringe-mode 10)        ; Give some breathing room
(setopt use-short-answers t)
(tooltip-mode -1)           ; Disable tooltips
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell nil)

(column-number-mode)
(setq display-line-numbers 'relative)
(display-line-numbers-mode 0)

(defvar bp/default-font-size 150)
(defvar bp/default-variable-font-size 150)

;; Set frame transparency
(set-frame-parameter nil 'alpha-background 90) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 90)) 
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

   ;; Disable line numbers for some modes
   (dolist (mode '(org-mode-hook
                   term-mode-hook
                   shell-mode-hook
                   treemacs-mode-hook
                   eshell-mode-hook))
     (add-hook mode (lambda ()
		      (display-line-numbers-mode 0)
		      (electric-pair-mode -1))))
(add-hook 'prog-mode-hook (lambda ()
			    (display-line-numbers-mode 1)
			    (electric-pair-mode +1)))

(use-package diminish)

(set-face-attribute 'nano-face-default nil
                    :family "Roboto Mono" :weight 'light :height 140)
(set-face-attribute 'nano-face-strong nil
                    :family "Roboto Mono" :weight 'regular)
(set-face-attribute 'nano-face-faded nil
                    :family "Victor Mono" :weight 'semilight :slant 'italic)
(set-fontset-font t 'unicode
		     (font-spec :name "Inconsolata Light" :size 16) nil)
(set-fontset-font t '(#xe000 . #xffdd)
		     (font-spec :name "RobotoMono Nerd Font" :size 12) nil)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

 ;; (use-package nerd-icons)
 ;; (use-package doom-modeline
 ;;   :straight t
 ;;   :init (doom-modeline-mode 1)
 ;;   :config
 ;;   (setq doom-modeline-height 36))

  (use-package general
    :after evil
    :config
    (general-create-definer bp/leader-keys
        :keymaps '(normal insert visual emacs)
        :prefix "SPC"
        :global-prefix "C-SPC")


    (bp/leader-keys
        "SPC" '(execute-extended-command :wk "Execute Command")
        "." '(find-file :wk "Find file")
        "u" '(universal-argument :wk "Universal argument"))


    (bp/leader-keys
        "p" '(projectile-command-map :wk "Projectile"))


    (bp/leader-keys
        "b" '(:ignore t :wk "Buffers")
        "b w" '(consult-buffer :wk "Switch to buffer")
        "b k" '(kill-current-buffer :wk "Kill current buffer")
        "b K" '(kill-some-buffers :wk "Kill multiple buffers")
        "b n" '(next-buffer :wk "Next buffer")
        "b p" '(previous-buffer :wk "Previous buffer")
        "b r" '(revert-buffer :wk "Reload buffer")
        "b R" '(rename-buffer :wk "Rename buffer")
        "b s" '(save-buffer :wk "Save buffer"))

    (bp/leader-keys
        "f" '(:ignore t :wk "Files")    
        "f c" '((lambda () (interactive)
                (find-file "~/src/emacs-vanilla/config.org")) 
            :wk "Open emacs config.org")
        "f e" '((lambda () (interactive)
                (dired "~/src/emacs-vanilla/")) 
            :wk "Open user-emacs-directory in dired")
        "f d" '(find-grep-dired :wk "Search for string in files in DIR")
        "f i" '((lambda () (interactive)
                (find-file "~/src/emacs-vanilla/init.el")) 
            :wk "Open emacs init.el")
        "f j" '(consult-find :wk "Jump to a file below current directory")
        "f l" '(consult-locate :wk "Locate a file")
        "f r" '(consult-recent-file :wk "Find recent files")
        "f u" '(sudo-edit-find-file :wk "Sudo find file")
        "f U" '(sudo-edit :wk "Sudo edit file"))

    (bp/leader-keys
      "s" '(:ignore t :wk "Search")
      "s s" '(consult-ripgrep :wk "Search string")
      "s m" '(consult-imenu :wk "Find in Menu"))

    (bp/leader-keys
        "h" '(:ignore t :wk "Help")
        "h a" '(apropos :wk "Apropos")
        "h b" '(describe-bindings :wk "Describe bindings")
        "h c" '(describe-char :wk "Describe character under cursor")
        "h d" '(:ignore t :wk "Emacs documentation")
        "h d a" '(about-emacs :wk "About Emacs")
        "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
        "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
        "h d m" '(info-emacs-manual :wk "The Emacs manual")
        "h d n" '(view-emacs-news :wk "View Emacs news")
        "h d o" '(describe-distribution :wk "How to obtain Emacs")
        "h d p" '(view-emacs-problems :wk "View Emacs problems")
        "h d t" '(view-emacs-todo :wk "View Emacs todo")
        "h d w" '(describe-no-warranty :wk "Describe no warranty")
        "h e" '(view-echo-area-messages :wk "View echo area messages")
        "h f" '(helpful-callable :wk "Describe function")
        "h F" '(describe-face :wk "Describe face")
        "h g" '(describe-gnu-project :wk "Describe GNU Project")
        "h i" '(info :wk "Info")
        "h I" '(describe-input-method :wk "Describe input method")
        "h k" '(helpful-key :wk "Describe key")
        "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
        "h L" '(describe-language-environment :wk "Describe language environment")
        "h m" '(describe-mode :wk "Describe mode")
        "h r" '(:ignore t :wk "Reload")
        "h r r" '((lambda () (interactive)
                (load-file "~/src/emacs-vanilla/init.el"))
                :wk "Reload emacs config")
        "h t" '(load-theme :wk "Load theme")
        "h v" '(helpful-variable :wk "Describe variable")
        "h w" '(where-is :wk "Prints keybinding for command if set")
        "h x" '(helpful-command :wk "Display full documentation for command"))
 
    (bp/leader-keys
      "l" '(:ignore t :wk "LSP")
      "l t" '(:ignore t :wk "Typescript")
      "l t r" '(tide-rename-symbol :wk "Rename Symbol")
      "l t f" '(tide-references :wk "Find references")
      "l t i" '(tide-organize-imports :wk "Organize Imports"))
    
    (bp/leader-keys
        "w" '(:ignore t :wk "Windows/Words")
        ;; Window splits
        "w c" '(evil-window-delete :wk "Close window")
        "w n" '(evil-window-new :wk "New window")
        "w s" '(evil-window-split :wk "Horizontal split window")
        "w v" '(evil-window-vsplit :wk "Vertical split window")
        ;; Window motions
        "w h" '(evil-window-left :wk "Window left")
        "w j" '(evil-window-down :wk "Window down")
        "w k" '(evil-window-up :wk "Window up")
        "w l" '(evil-window-right :wk "Window right")
        "w w" '(evil-window-next :wk "Goto next window")
        ;; Move Windows
        "w H" '(buf-move-left :wk "Buffer move left")
        "w J" '(buf-move-down :wk "Buffer move down")
        "w K" '(buf-move-up :wk "Buffer move up")
        "w L" '(buf-move-right :wk "Buffer move right")
        ;; Words
        "w d" '(downcase-word :wk "Downcase word")
        "w u" '(upcase-word :wk "Upcase word")
        "w =" '(count-words :wk "Count words/lines for buffer"))

    (bp/leader-keys
        "t" '(:ignore t :wl "Toggles")
        "t e" '(treemacs :wk "Toggle Explorer")))

(with-eval-after-load 'evil-maps
    (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
    (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
    (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
    (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right))

  (use-package evil
      :init      ;; tweak evil's configuration before loading it
      (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
	    evil-want-keybinding nil
	    evil-vsplit-window-right t
	    evil-split-window-below t
            evil-want-C-u-scroll t
	    evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
      (evil-mode))

  (use-package evil-collection
    :after evil
    :config
    (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
    (evil-collection-init))

  (with-eval-after-load 'evil-maps
    (define-key evil-motion-state-map (kbd "SPC") nil)
    (define-key evil-motion-state-map (kbd "RET") nil)
    (define-key evil-motion-state-map (kbd "TAB") nil))
  ;; Setting RETURN key in org-mode to follow links
    (setq org-return-follows-link  t)

(use-package evil-nerd-commenter
  :straight t
  :bind (("M-/" . evilnc-comment-or-uncomment-lines)
	 ("C-M-/" . evilnc-comment-or-uncomment-html-tag)))

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

  (setq org-src-preserve-indentation t)

  (defun bp/org-font-setup ()
    ;; Replace list hyphen with dot
    (font-lock-add-keywords 'org-mode
                            '(("^ *\\([-]\\) "
                               (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

    ;; Set faces for heading levels
    (dolist (face '((org-level-1 . 1.5)
                    (org-level-2 . 1.4)
                    (org-level-3 . 1.3)
                    (org-level-4 . 1.2)
                    (org-level-5 . 1.1)
                    (org-level-6 . 1.0)
                    (org-level-7 . 1.0)
                    (org-level-8 . 1.0)))
      (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

    ;; Ensure that anything that should be fixed-pitch in Org files appears that way
    (set-face-attribute 'org-block nil    :foreground nil :background nano-color-highlight :inherit 'fixed-pitch)
    (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
    (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
    (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
    (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
    (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

  (use-package org-bullets
    :hook (org-mode . org-bullets-mode)
    :custom
    (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;;;;; Ligatures & Pretty Symbols
(defun bp/org-prettify-symbols ()
  "Beautify Org Checkbox Symbol"
  (setq prettify-symbols-alist
        (mapcan (lambda (x) (list x (cons (upcase (car x)) (cdr x))))
                '(("#+begin_src" . ?)
                  ("#+end_src" . ?)
                  ("#+begin_example" . ?)
                  ("#+end_example" . ?)
                  ("#+begin_quote" . ?)
                  ("#+end_quote" . ?)
                  (":END:" . ?󰑀)
                  ("#+header:" . ?󱍞)
                  ("#+name:" . ?󰑕)
                  ("#+results:" . ? )
                  ("#+call:" . ? )
                  (":properties:" . ? )
                  (":logbook:" . ? ))))
  (prettify-symbols-mode))

(add-hook 'org-mode-hook #'bp/org-prettify-symbols)

(defun bp/org-mode-setup ()
  (global-corfu-mode -1)
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . bp/org-mode-setup)
  :config
   (bp/org-font-setup))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

(use-package vertico-posframe
  :hook (vertico-mode . vertico-posframe-mode))

(use-package vertico
  :init
  (vertico-mode)
  (setq vertico-count 20)
  (setq vertico-resize t)
  (setq vertico-cycle t))

;; Persist history over Emacs restarts.Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  :init
  (marginalia-mode))

(use-package consult) 

(use-package vertico-directory
  :after vertico
  :straight nil
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package corfu
  :straight t
  :config
  (set-face-attribute 'corfu-default nil :background nano-color-background)
  (set-face-attribute 'corfu-current nil :background nano-color-highlight)
  (set-face-attribute 'corfu-bar nil :background nano-color-faded)
  :general
   (:keymaps 'corfu-map
   :states 'insert
   "<tab>" #'corfu-next
   "<backtab>" #'corfu-previous
   "<escape>" #'corfu-quit
   "<return>" #'corfu-insert
   "M-d" #'corfu-show-documentation
   "M-l" #'corfu-show-location)
  :init
  (global-corfu-mode))

(use-package cape
  :straight t
  :bind (("C-c c p" . completion-at-point) ;; capf
         ("C-c c t" . complete-tag)        ;; etags
         ("C-c c d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c c h" . cape-history)
         ("C-c c f" . cape-file)
         ("C-c c k" . cape-keyword)
         ("C-c c s" . cape-elisp-symbol)
         ("C-c c e" . cape-elisp-block)
         ("C-c c a" . cape-abbrev)
         ("C-c c l" . cape-line)
         ("C-c c w" . cape-dict)
         ("C-c c :" . cape-emoji)
         ("C-c c \\" . cape-tex)
         ("C-c c _" . cape-tex)
         ("C-c c ^" . cape-tex)
         ("C-c c &" . cape-sgml)
         ("C-c c r" . cape-rfc1345))
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block))

(use-package emacs
  :init
  (setq completion-cycle-threshold 3)
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)
  (setq tab-always-indent 'complete))

(use-package olivetti
  :hook (org-mode . olivetti-mode)
  :config
  (setq olivetti-body-width 120))

(use-package treemacs-nerd-icons
  :straight t)
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-follow-after-init t
          treemacs-recenter-after-file-follow t
          treemacs-width 40
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-eldoc-display nil
          treemacs-collapse-dirs (if (executable-find "python") 3 0)
          treemacs-silent-refresh t
          treemacs-eldoc-display t
          treemacs-silent-filewatch t
          treemacs-change-root-without-asking t
          treemacs-sorting 'alphabetic-asc
          treemacs-show-hidden-files t
          treemacs-never-persist nil
          treemacs-is-never-other-window t
          treemacs-user-mode-line-format 'none))
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  :general
  (:keymaps 'treemacs-mode-map
   "C-l"     'evil-window-right	    
   "SPC w l" 'evil-window-right
   "SPC t e" 'treemacs))

(use-package treemacs-evil
  :after (treemacs evil)
  :straight t)

(use-package rainbow-mode
  :straight t
  :hook ((web-mode org-mode) . rainbow-mode))

(setq
 display-buffer-alist
 `(
   ("^\\*\\([Hh]elp\\|Apropos\\)"
    display-buffer-in-side-window
    (side . right)
    (slot . 0)
    (window-width . fit-window-to-buffer))
   ))

(use-package tree-sitter
  :commands (treesit-install-language-grammar bp/treesit-install-all-languages)
  :init
  (setq treesit-language-source-alist
   '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
     (c . ("https://github.com/tree-sitter/tree-sitter-c"))
     (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
     (css . ("https://github.com/tree-sitter/tree-sitter-css"))
     (go . ("https://github.com/tree-sitter/tree-sitter-go"))
     (html . ("https://github.com/tree-sitter/tree-sitter-html"))
     (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
     (json . ("https://github.com/tree-sitter/tree-sitter-json"))
     (lua . ("https://github.com/Azganoth/tree-sitter-lua"))
     (make . ("https://github.com/alemuller/tree-sitter-make"))
     (ocaml . ("https://github.com/tree-sitter/tree-sitter-ocaml" "ocaml/src" "ocaml"))
     (python . ("https://github.com/tree-sitter/tree-sitter-python"))
     (php . ("https://github.com/tree-sitter/tree-sitter-php"))
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (ruby . ("https://github.com/tree-sitter/tree-sitter-ruby"))
     (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
     (sql . ("https://github.com/m-novikov/tree-sitter-sql"))
     (toml . ("https://github.com/tree-sitter/tree-sitter-toml"))
     (zig . ("https://github.com/GrayJack/tree-sitter-zig"))))
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
  (defun bp/treesit-install-all-languages ()
    "Install all languages specified by `treesit-language-source-alist'."
    (interactive)
    (let ((languages (mapcar 'car treesit-language-source-alist)))
      (dolist (lang languages)
	      (treesit-install-language-grammar lang)
	      (message "`%s' parser was installed." lang)
	      (sit-for 0.75)))))


(use-package tree-sitter-langs
  :straight t
  :after tree-sitter)

(use-package lsp-mode
  :straight t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((lsp-mode . lsp-enable-which-key-integration)
	 (tsx-ts-mode . lsp-deferred)
	 (typescript-ts-mode . lsp-deferred))
  :commands lsp lsp-deferred
  :config
    (setq lsp-headerline-breadcrumb-enable nil)) 

(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-doc-enable t))

(with-eval-after-load 'lsp-ui
  (setq lsp-ui-peek-fontify 'always)
  (set-face-attribute 'lsp-ui-peek-header nil
		      :background nano-color-subtle
		      :foreground nano-color-foreground
		      :weight 'bold)
  (set-face-attribute 'lsp-ui-peek-footer nil :inherit 'lsp-ui-peek-header)
  (set-face-attribute 'lsp-ui-peek-list   nil :background nano-color-background)
  (set-face-attribute 'lsp-ui-peek-peek   nil :inherit 'lsp-ui-peek-list)
  (set-face-attribute 'lsp-ui-peek-selection nil :background nano-color-background :foreground nano-color-salient)
  (set-face-attribute 'lsp-ui-peek-filename nil :foreground nano-color-popout)
  (set-face-attribute 'lsp-ui-peek-highlight nil :background nano-color-highlight)
  (set-face-attribute 'error nil :background nano-color-critical :foreground nano-color-subtle))

(add-to-list 'auto-mode-alist '("\\.tsx?\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts?\\'" . typescrip-ts-mode))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1))

(use-package tide
  :straight t
  :config
  (add-hook 'tsx-ts-mode-hook #'setup-tide-mode))

(use-package prettier-js
  :straight t
  :hook ((web-mode tsx-ts-mode js-ts-mode javascript-mode typescript-mode) . prettier-js-mode))

(use-package flycheck
  :straight t
  :config
  (global-flycheck-mode))

(with-eval-after-load 'flycheck
    (flycheck-add-mode 'javascript-eslint 'typescriptreact-mode))

(use-package embark
  :straight t

  :bind
  (("M-," . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings

  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :straight t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package helpful
  :straight t
  :commands (helpful-callable helpful-variable helpful-command helpful-key))

(use-package git-gutter
  :straight t
  :config
  (global-git-gutter-mode +1)
  (custom-set-variables
   '(git-gutter:modified-sign "@@") ;; two space
   '(git-gutter:added-sign "++")    ;; multiple character is OK
   '(git-gutter:deleted-sign "--"))

  (set-face-foreground 'git-gutter:modified nano-color-critical) ;; background color
  (set-face-foreground 'git-gutter:added nano-color-salient)
  (set-face-foreground 'git-gutter:deleted nano-color-popout))

(use-package magit
  :straight t)

(bp/leader-keys
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-dispatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file"))

(use-package markdown-mode
  :straight t)

(use-package projectile
  :straight t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (setq projectile-project-search-path '("~/src/" "~/.config/"))
  (setq projectile-globally-ignored-directories '("straight" "eln-cache")))

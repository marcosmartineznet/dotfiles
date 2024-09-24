;; -*- lexical-binding: t; -*-
;; This is mostly a one-file version of https://github.com/flyingmachine/emacs-for-clojure
;; BOOTSTRAPING
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-always-ensure t)

(eval-when-compile
  (require 'use-package))

(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)

;; * UI

;; These customizations change the way emacs looks and disable/enable
;; some user interface elements. Some useful customizations are
;; commented out, and begin with the line "CUSTOMIZE". These are more
;; a matter of preference and may require some fiddling to match your
;; preferences
(set-frame-font "JetBrainsMono Nerd Font 12" nil t)

(tooltip-mode -1)                 ;; disable tooltips
(tool-bar-mode -1)                ;; the toolbar is pretty ugly
(scroll-bar-mode -1)              ;; disable visible scrollbar
(blink-cursor-mode 0)             ;; turn off blinking cursor. distracting!
(setq create-lockfiles nil)       ;; no need for ~ files when editing
(fset 'yes-or-no-p 'y-or-n-p)     ;; changes all yes/no questions to y/n type
(setq inhibit-startup-message t)  ;; go straight to scratch buffer on startup
(setq ring-bell-function 'ignore) ;; turn off audible bell

;; show full path in title bar
(setq-default frame-title-format "%b (%f)")

;; initial frame height and width
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 100))

(set-face-attribute 'default nil :height 140)

;; on a Mac, don't pop up font menu
(when (string-equal system-type "darwin") 'ok

  (global-set-key (kbd "s-t") '(lambda () (interactive))))
(use-package all-the-icons)

(use-package doom-modeline
  :config (doom-modeline-mode t))

;; https://github.com/doomemacs/themes/tree/screenshots
(use-package doom-themes
  :config (when (not custom-enabled-themes)
            (load-theme 'doom-acario-dark t)))


;; These settings relate to how emacs interacts with your operating system
(setq ;; makes killing/yanking interact with the clipboard
      x-select-enable-clipboard t

      ;; I'm actually not sure what this does but it's recommended?
      x-select-enable-primary t

      ;; Save clipboard strings into kill ring before replacing them.
      ;; When one selects something in another program to paste it into Emacs,
      ;; but kills something in Emacs before actually pasting it,
      ;; this selection is gone unless this variable is non-nil
      save-interprogram-paste-before-kill t

      ;; Shows all options when running apropos. For more info,
      ;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Apropos.html
      apropos-do-all t

      ;; Mouse yank commands yank at point instead of at click.
      mouse-yank-at-point t)

;; * NAVIGATION

;; These customizations make it easier for you to navigate files,
;; switch buffers, and choose options from the minibuffer.

(use-package which-key
  :init (setq which-key-idle-delay 0.2)
  :config (which-key-mode))

;; ivy is the completion framework. This makes M-x much more usable.
;; Installing counsel brings ivy and swiper as dependencies
;; swiper is a powerful search-within-a-buffer capability.
;; https://github.com/abo-abo/swiper
(use-package counsel
  :init (setq ivy-use-virtual-buffers t
              ivy-re-builders-alist '((t . ivy--regex-ignore-order))
              ivy-count-format "%d/%d ")
  :bind (("C-s" . swiper)
         ("C-x C-f" . counsel-find-file)
         ("C-x C-b" . counsel-switch-buffer)
         ("M-x" . counsel-M-x))
  :config (ivy-mode))

'(setup (:package counsel)
  (ivy-mode)
  (:option ivy-use-virtual-buffers t
           ivy-re-builders-alist '((t . ivy--regex-ignore-order))
           ivy-count-format "%d/%d ")
  (:global "C-s" swiper
           "s-f" swiper
           "C-x C-f" counsel-find-file
           "C-x C-b" counsel-switch-buffer
           "M-x" counsel-M-x))

;; ivy-rich-mode adds docstrings and additional metadata
;; in the ivy picker minibuffer
(use-package ivy-rich
  :after ivy
  :config (ivy-rich-mode))

;; * PROJECTS

;; https://projectile.mx/
(use-package projectile
  :bind ("C-c p" . projectile-command-map)
  :config (projectile-mode 1))

;; counsel-projectile integrates projectile with
;; counsel's browse-and-select UI
(use-package counsel-projectile
  :after (counsel projectile))

;; * GIT

;; https://magit.vc/manual/magit/
(use-package magit
  :pin melpa
  :bind ("C-c gs" . magit-status))

(global-set-key (kbd "<leader>g") '("git" . (keymap)))

;; * FILETREE

;; treemacs is a tree layout file explorer
;; https://github.com/Alexander-Miller/treemacs

(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once))

(use-package treemacs-magit
  :after (treemacs magit))


;; * EDITING

;; Enable Evil

(use-package evil
  :init (setq evil-want-keybinding nil
              evil-want-C-u-scroll t)
  (evil-mode 1))
  :config

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Customizations relating to editing a buffer.

;; Key binding to use "hippie expand" for text autocompletion
;; http://www.emacswiki.org/emacs/HippieExpand
(global-set-key (kbd "M-/") 'hippie-expand)

;; Lisp-friendly hippie expand
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

;; Highlights matching parenthesis
(show-paren-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; line numbers
(global-display-line-numbers-mode 1)
;; but not everywhere
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Don't use hard tabs
(setq-default indent-tabs-mode nil)

;; shell scripts
(setq-default sh-basic-offset 2
              sh-indentation 2)

;; When you visit a file, point goes to the last place where it
;; was when you previously visited the same file.
;; http://www.emacswiki.org/emacs/SavePlace
(save-place-mode 1)
;; keep track of saved places in ~/.emacs.d/places
(setq save-place-file (concat user-emacs-directory "places"))

;; Emacs can automatically create backup files. This tells Emacs to
;; put all backups in ~/.emacs.d/backups. More info:
;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Backup-Files.html
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory
                                               "backups"))))
(setq auto-save-default nil)

;; comments
(defun toggle-comment-on-line ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))
(global-set-key (kbd "C-;") 'toggle-comment-on-line)

;; use 2 spaces for tabs
(defun die-tabs ()
  (interactive)
  (set-variable 'tab-width 2)
  (mark-whole-buffer)
  (untabify (region-beginning) (region-end))
  (keyboard-quit))

;; fix weird os x kill error
(defun ns-get-pasteboard ()
  "Returns the value of the pasteboard, or nil for unsupported formats."
  (condition-case nil
      (ns-get-selection-internal 'CLIPBOARD)
    (quit nil)))

;; EDITING-ELISP

;; https://www.emacswiki.org/emacs/ParEdit
(use-package paredit
  :hook ((emacs-lisp-mode
          ;; eval-expression-minibuffer-setup
          ielm-mode lisp-mode
          lisp-interaction-mode
          scheme-mode
          clojure-mode
          cider-mode
          cider-repl-mode) . paredit-mode))

'(setup turn-on-eldoc-mode
  (:hook-into emacs-lisp-mode
	 lisp-interaction-mode
	 iel-mode))

;; https://github.com/Fanael/rainbow-delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; * SETUP-CLOJURE

;; See:  https://clojure-lsp.io/
;; also: https://emacs-lsp.github.io/lsp-mode/
'(setup (:package lsp-mode lsp-ui lsp-ivy lsp-treemacs)
  (:hook lsp-enable-which-key-integration)
  (:bind "M-<f7>" lsp-find-references))

;; clojure-mode is (naturally) the major mode for editing
;; Clojure and ClojureScript. subword-mode allows words
;; in camel case to be treated as separate words for
;; movement and editing commands.
;; https://github.com/clojure-emacs/clojure-mode
;; subword-mode is useful for working with camel-case tokens,
;; like names of Java classes (e.g. JavaClassName)
(use-package clojure-mode)

;; CIDER is a whole interactive development environment for
;; Clojure. There is a ton of functionality here, so be sure
;; to check out the excellent documentation at
;; https://docs.cider.mx/cider/index.html
(use-package cider
 :init (setq cider-show-error-buffer t
             cider-auto-select-error-buffer t
             cider-repl-history-file (concat user-emacs-directory "cider-history")
             cider-repl-pop-to-buffer-on-connect t
             cider-repl-wrap-history t)
 :bind (:map cider-repl-mode-map
             ("C-c u" . cider-user-ns)
             ("C-M-r" . cider-refresh)))

;; company provides auto-completion for CIDER
;; see https://docs.cider.mx/cider/usage/code_completion.html
(use-package company
  :hook ((prog-mode cider-mode cider-repl-mode) . company-mode))

;; hydra provides a nice looking menu for commands
;; to see what's available, use M-x and the prefix cider-hydra
;; https://github.com/clojure-emacs/cider-hydra
(use-package cider-hydra
  :after cider
  :hook ((cider-mode
          cider-repl-mode
          clojure-mode) . cider-hydra-mode))

;; additional refactorings for CIDER
;; e.g. add missing libspec, extract function, destructure keys
;; https://github.com/clojure-emacs/clj-refactor.el
(use-package clj-refactor
  :after clojure-mode
  :init
  (defun custom-clojure-mode-hook ()
    (message "Custom clojure mode hook initiated...")
    (clj-refactor-mode 1)
    (yas-minor-mode 1)
    (cljr-add-keybindings-with-prefix "C-c C-n"))
  (add-hook 'clojure-mode-hook #'custom-clojure-mode-hook))

;; Use clojure mode for other extensions
(add-to-list 'auto-mode-alist '("\\.boot$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.cljs.*$" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.edn.*$" . clojure-mode))
(add-to-list 'auto-mode-alist '("lein-env" . enh-ruby-mode))

;; these help me out with the way I usually develop web apps
(defun cider-start-http-server ()
  (interactive)
  (cider-load-buffer)
  (let ((ns (cider-current-ns)))
    (cider-repl-set-ns ns)
    (cider-interactive-eval (format "(println '(def server (%s/start))) (println 'server)" ns))
    (cider-interactive-eval (format "(def server (%s/start)) (println server)" ns))))

(defun cider-refresh ()
  (interactive)
  (cider-interactive-eval (format "(user/reset)")))

(defun cider-user-ns ()
  (interactive)
  (cider-repl-set-ns "user"))

;; TREESITTER

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (clojure "https://github.com/sogaiu/tree-sitter-clojure")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

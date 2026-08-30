;;; post-init.el --- DESCRIPTION -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
;; User info
(setq user-full-name "Eugene Mah"
      user-mail-address "eugenemah@gmail.com"
      user-login-name "eugenem")
(setenv "SHELL" "/bin/fish")

;; General settings
(setq calendar-week-start-day 1)                ; Calendar week starts Monday
(setq display-time-day-and-date t
      display-time-24hr-format t)
(setq require-final-newline t
      use-short-answers t)
(setq visible-bell t)

;; Electric-pair options
(setq electric-pair-preserve-balance t
      electric-pair-delete-adjacent-pairs t)

(prefer-coding-system 'utf-8)
(setq mode-line-position-column-line-format '("%l:%C"))
;; Set the maximum level of syntax highlighting for Tree-sitter modes
(setq treesit-font-lock-level 4)

(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(add-hook 'text-mode-hook 'auto-fill-mode)

;; Constrain vertical cursor movement to lines within the buffer
(setq dired-movement-style 'bounded-files)

;; Dired buffers: Automatically hide file details (permissions, size,
;; modification date, etc.) and all the files in the `dired-omit-files' regular
;; expression for a cleaner display.
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; Hide files from dired
(setq dired-omit-files (concat "\\`[.]\\'"
                               "\\|\\(?:\\.js\\)?\\.meta\\'"
                               "\\|\\.\\(?:elc|a\\|o\\|pyc\\|pyo\\|swp\\|class\\)\\'"
                               "\\|^\\.DS_Store\\'"
                               "\\|^\\.\\(?:svn\\|git\\)\\'"
                               "\\|^\\.ccls-cache\\'"
                               "\\|^__pycache__\\'"
                               "\\|^\\.project\\(?:ile\\)?\\'"
                               "\\|^flycheck_.*"
                               "\\|^flymake_.*"))
(add-hook 'dired-mode-hook #'dired-omit-mode)

;; dired: Group directories first
(with-eval-after-load 'dired
  (let ((args "--group-directories-first -ahlv"))
    (when (or (eq system-type 'darwin) (eq system-type 'berkeley-unix))
      (if-let* ((gls (executable-find "gls")))
          (setq insert-directory-program gls)
        (setq args nil)))
    (when args
      (setq dired-listing-switches args))))

;; Backup settings
(setopt backup-directory-alist '(("." . "~/.config/emacs/backups"))
        delete-old-versions t
        version-control t
        vc-make-backup-files t
        auto-save-timeout 120
        auto-save-file-name-transforms '((".*" "~/.config/emacs/auto-save-list" t)))

;; Enables visual indication of minibuffer recursion depth after initialization.
(minibuffer-depth-indicate-mode 1)

;; This ensures that pressing Enter will insert a new line and indent it.
(global-set-key (kbd "RET") #'newline-and-indent)

;; Mouse button bindings
(keymap-global-set "<mouse-2>" 'mark-whole-buffer)    ; wheel button
(keymap-global-set "<mouse-6>" 'backward-word)        ; thumb wheel up
(keymap-global-set "<mouse-7>" 'forward-word)         ; thumb wheel down
(keymap-global-set "<mouse-8>" 'scroll-up-command)    ; forward thumb button
(keymap-global-set "<mouse-9>" 'scroll-down-command)  ; back thumb button
(keymap-global-set "<mouse-10>" 'list-buffers)

;; Fonts
(defvar em/default-font-size 110)
(defvar em/default-variable-font-size 110)
(add-to-list 'default-frame-alist '(font . "Fira Code"))
(set-face-attribute 'default nil
		            :font "Fira Code"
                    :weight 'normal
		            :height em/default-font-size)
(set-face-attribute 'fixed-pitch nil
		            :font "Fira Code"
                    :weight 'normal
		            :height em/default-font-size)
(set-face-attribute 'variable-pitch nil
	                :font "Cantarell"
	                :height em/default-variable-font-size
	                :weight 'normal)

;; Activate modes
(electric-pair-mode 1)                            ; Enable electric-pair mode
(display-time-mode 1)                             ; Display time in the mode line
(abbrev-mode 1)                                   ; Enable abbrev mode
(column-number-mode 1)                            ; Show column numbers
(show-paren-mode 1)                               ; Highlight matching parens
(global-display-line-numbers-mode 1)

;; The Emacs server allows external programs such as `emacsclient' to connect to
;; a single running instance of Emacs. This makes it possible to open files in
;; the existing session rather than starting a new Emacs process each time.
;;
;; Once the server is running, the `emacsclient' command can be used in the
;; terminal to open files in the active Emacs session. For example, running the
;; following command opens the file in the existing Emacs frame without blocking
;; the terminal process.
;;   emacsclient -n filename.txt
;;
(use-package server
  :ensure nil
  :if (not (daemonp))
  :preface
  (defun my-server-start ()
    "Start the Emacs server if no server process is currently active."
    (unless (server-running-p)
      (server-start)))
  :init
  ;; Defer starting the server until after Emacs has finished initializing
  (add-hook 'emacs-startup-hook #'my-server-start))

;; Native compilation enhances Emacs performance by converting Elisp code into
;; native machine code, resulting in faster execution and improved
;; responsiveness.
;;
;; Ensure adding the following compile-angel code at the very beginning
;; of your `~/.emacs.d/post-init.el` file, before all other packages.
(use-package compile-angel
  :demand t
  :config
  ;; Set `compile-angel-verbose' to nil to disable compile-angel messages.
  ;; (When set to nil, compile-angel won't show which file is being compiled.)
  (setq compile-angel-verbose t)

  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this push to `compile-angel-excluded-files'
  ;; and compile your pre/post-init files, ensure you understand the
  ;; implications and thoroughly test your code. For example, if you're using
  ;; the `use-package' macro, you'll need to explicitly add:
  ;; (eval-when-compile (require 'use-package))
  ;; at the top of your init file.
  (push "/init.el" compile-angel-excluded-files)
  (push "/early-init.el" compile-angel-excluded-files)
  (push "/pre-init.el" compile-angel-excluded-files)
  (push "/post-init.el" compile-angel-excluded-files)
  (push "/pre-early-init.el" compile-angel-excluded-files)
  (push "/post-early-init.el" compile-angel-excluded-files)

  ;; A local mode that compiles .el files whenever the user saves them.
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files prior to loading them via `load' or
  ;; `require'. Additionally, it compiles all packages that were loaded before
  ;; the mode `compile-angel-on-load-mode' was activated.
  (compile-angel-on-load-mode 1))

;; Delete selected text upon insertion
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

;; Use doom modeline
(use-package doom-modeline
  :ensure t
  :custom
  (doom-modeline-time-icon nil)
  (doom-modeline-time-live-icon nil)
  (doom-modeline-column-zero-based nil)
  :hook (after-init . doom-modeline-mode))

;; Set up for utility packages
(use-package ligature
  :demand t
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable all Cascadia and Fira Code ligatures in programming modes
  (ligature-set-ligatures
   'prog-mode '(;; == === ==== => =| =>>=>=|=>==>> ==< =/=//=// =~
                ;; =:= =!=
                ("=" (rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
                ;; ;; ;;;
                (";" (rx (+ ";")))
                ;; && &&&
                ("&" (rx (+ "&")))
                ;; !! !!! !. !: !!. != !== !~
                ("!" (rx (+ (or "=" "!" "\." ":" "~"))))
                ;; ?? ??? ?:  ?=  ?.
                ("?" (rx (or ":" "=" "\." (+ "?"))))
                ;; %% %%%
                ("%" (rx (+ "%")))
                ;; |> ||> |||> ||||> |] |} || ||| |-> ||-||
                ;; |->>-||-<<-| |- |== ||=||
                ;; |==>>==<<==<=>==//==/=!==:===>
                ("|" (rx (+ (or ">" "<" "|" "/" ":" "!" "}" "\]" "-" "=" ))))
                ;; \\ \\\ \/
                ("\\" (rx (or "/" (+ "\\"))))
                ;; ++ +++ ++++ +>
                ("+" (rx (or ">" (+ "+"))))
                ;; :: ::: :::: :> :< := :// ::=
                (":" (rx (or ">" "<" "=" "//" ":=" (+ ":"))))
                ;; // /// //// /\ /* /> /===:===!=//===>>==>==/
                ("/" (rx (+ (or ">"  "<" "|" "/" "\\" "\*" ":" "!" "="))))
                ;; .. ... .... .= .- .? ..= ..<
                ("\." (rx (or "=" "-" "\?" "\.=" "\.<" (+ "\."))))
                ;; -- --- ---- -~ -> ->> -| -|->-->>->--<<-|
                ("-" (rx (+ (or ">" "<" "|" "~" "-"))))
                ;; *> */ *)  ** *** ****
                ("*" (rx (or ">" "/" ")" (+ "*"))))
                ;; www wwww
                ("w" (rx (+ "w")))
                ;; <> <!-- <|> <: <~ <~> <~~ <+ <* <$ </  <+> <*>
                ;; <$> </> <|  <||  <||| <|||| <- <-| <-<<-|-> <->>
                ;; <<-> <= <=> <<==<<==>=|=>==/==//=!==:=>
                ;; << <<< <<<<
                ("<" (rx (+ (or "\+" "\*" "\$" "<" ">" ":" "~"  "!" "-"  "/" "|" "="))))
                ;; >: >- >>- >--|-> >>-|-> >= >== >>== >=|=:=>>
                ;; >> >>> >>>>
                (">" (rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
                ;; #: #= #! #( #? #[ #{ #_ #_( ## ### #####
                ("#" (rx (or ":" "=" "!" "(" "\?" "\[" "{" "_(" "_" (+ "#"))))
                ;; ~~ ~~~ ~=  ~-  ~@ ~> ~~>
                ("~" (rx (or ">" "=" "-" "@" "~>" (+ "~"))))
                ;; __ ___ ____ _|_ __|____|_
                ("_" (rx (+ (or "_" "|"))))
                ;; Fira code: 0xFF 0x12
                ("0" (rx (and "x" (+ (in "A-F" "a-f" "0-9")))))
                ;; Fira code:
                "Fl"  "Tl"  "fi"  "fj"  "fl"  "ft"
                ;; The few not covered by the regexps.
                "{|"  "[|"  "]#"  "(*"  "}#"  "$>"  "^="))
  :hook (prog-mode . global-ligature-mode))

;; Rainbow-delimiters
(use-package rainbow-delimiters
  :demand t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :ensure nil
  :init
  (setq which-key-idle-delay 1.5)
  (setq which-key-idle-secondary-delay 0.25)
  (setq which-key-add-column-padding 1)
  (setq which-key-max-description-length 40)
  :config
  (which-key-setup-side-window-right-bottom)
  (which-key-mode 1))

;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(use-package autorevert
  :ensure nil
  :init
  ;; (setq auto-revert-verbose t)
  (setq auto-revert-interval 3)
  (setq auto-revert-remote-files nil)
  (setq auto-revert-use-notify t)
  (setq auto-revert-avoid-polling nil)
  (global-auto-revert-mode 1))

;; Recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(use-package recentf
  :ensure nil
  :init
  (setq recentf-auto-cleanup (if (daemonp) 300 'never))
  (setq recentf-exclude
        (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
              "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
              "\\.7z$" "\\.rar$"
              "COMMIT_EDITMSG\\'"
              "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
              "-autoloads\\.el$" "autoload\\.el$"))
  ;; Enable `recentf-mode'
  (recentf-mode 1)

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90))

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(use-package savehist
  :ensure nil
  :init
  (setq savehist-file "~/.config/emacs/savehist")
  (setq history-delete-duplicates t
        history-length 50)
  (setq savehist-autosave-interval 600
        savehist-save-minibuffer-history t
        savehist-additional-variables '(kill-ring
                                        search-ring
                                        regexp-search-ring))
  (savehist-mode 1))

;; Enable `auto-save-mode' to prevent data loss. Use `recover-file' or
;; `recover-session' to restore unsaved changes.
(setq auto-save-default t
      auto-save-interval 300 ; Trigger an auto-save after 300 keystrokes
      auto-save-timeout 30   ; Trigger an auto-save 30 seconds of idle time.
      )

;; Corfu enhances in-buffer completion by displaying a compact popup with
;; current candidates, positioned either below or above the point. Candidates
;; can be selected by navigating up or down.
(use-package corfu
  :init
  (setq text-mode-ispell-word-completion nil)
  ;; Hide commands in M-x which do not apply to the current mode.
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (setq tab-always-indent 'complete)

  (global-corfu-mode 1))

;; Cape, or Completion At Point Extensions, extends the capabilities of
;; in-buffer completion. It integrates with Corfu or the default completion UI,
;; by providing additional backends through completion-at-point-functions.
(use-package cape
  :commands (cape-dabbrev cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;; Vertico provides a vertical completion interface, making it easier to
;; navigate and select from completion candidates (e.g., when `M-x` is pressed).
(use-package vertico
  :init
  ;; (setq vertico-scroll-margin 0) ;; Different scroll margin
  ;; (setq vertico-count 20) ;; Show more candidates
  ;; (setq vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  (vertico-mode 1))

;; Vertico leverages Orderless' flexible matching capabilities, allowing users
;; to input multiple patterns separated by spaces, which Orderless then
;; matches in any order against the candidates.
(use-package orderless
  :init
  (setq completion-styles '(orderless basic))
  (setq completion-category-overrides '((file (styles partial-completion))))
  ;; Emacs 31: partial-completion behaves like substring
  (setq completion-pcm-leading-wildcard t))

;; Marginalia allows Embark to offer you preconfigured actions in more contexts.
;; In addition to that, Marginalia also enhances Vertico by adding rich
;; annotations to the completion candidates displayed in Vertico's interface.
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode 1))

;; Embark integrates with Consult and Vertico to provide context-sensitive
;; actions and quick access to commands based on the current selection, further
;; improving user efficiency and workflow within Emacs. Together, they create a
;; cohesive environment for managing completions and interactions.
(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult)

;; Consult offers a suite of commands for efficient searching, previewing, and
;; interacting with buffers, file contents, and more, improving various tasks.

(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

;; Flycheck
(use-package flycheck
  :custom
  (flycheck-idle-change-delay 1)
  (flycheck-error-list-minimum-level 'warning)
  :hook (after-init . global-flycheck-mode))

;; Highlight uncommitted changes using diff-hl
(use-package diff-hl
  :commands (diff-hl-mode
             global-diff-hl-mode)
  :hook (prog-mode . diff-hl-mode)
  :init
  (setq diff-hl-flydiff-delay 0.4)  ; Faster
  (setq diff-hl-show-staged-changes nil)  ; Realtime feedback
  (setq diff-hl-update-async t)  ; Do not block Emacs
  (setq diff-hl-global-modes '(not pdf-view-mode image-mode)))

;; Magit
(use-package magit
  :custom
  (magit-credential-cache-daemon-socket nil)
  (magit-refresh-status-buffer nil)
  (magit-auto-revert-mode t)
  (magit-define-global-key-bindings t)
  :bind
  ("C-c C-g s" . magit-status)
  ("C-c C-g d" . magit-diff)
  ("C-c C-g D" . magit-diff-unstaged)
  ("C-c C-g S" . magit-stage)
  ("C-c C-g U" . magit-unstage)
  ("C-c C-g c" . magit-commit)
  ("C-c C-g p" . magit-push)
  ("C-c C-g P" . magit-pull)
  ("C-c C-g f" . magit-fetch)
  ("C-c C-g l" . magit-log)
  ("C-c C-g b" . magit-branch)
  ("C-c C-g t" . magit-tag))

;; Org mode
(use-package org
  :commands (org-mode org-version)
  :mode
  ("\\.org\\'" . org-mode)
  :init
  (setq org-startup-indented t
        org-adapt-indentation nil)
  :custom
  (org-directory "~/org/")
  (org-agenda-files (list "~/org/todo.org"))
  (org-default-notes-file "~/org/notes.org")
  (org-archive-location "~/org/archive/")
  (org-enable-github-support t)
  (org-enable-journal-support t)
  (org-log-done 'time-date)
  (org-startup-truncated nil)
  (org-use-speed-commands t)
  (org-return-follows-link t)
  (org-tag-alist '(("WORK" . ?W)
                   ("home" . ?h)
                   ("lab" . ?l)
                   ("research" . ?r)
                   ("dogs" . ?d)
                   ("radioclub" . ?C)))
  (org-capture-templates '(("t" "Todo"
                            entry (file+headline "todo.org" "Tasks")
                            "** TODO %?\n %i\n %a")
                           ("a" "Appointment"
                            entry (file+headline "todo.org" "Calendar")
                            "** APPT %^{Description} %^g\n %?\n Added: %U")
                           ("j" "Journal entry"
                            entry (file+olp+datetree "~/org/journal/journal.org")
                            "* %?\nEntered on %U\n %i\n %a")
                           ("n" "Notes"
                            entry (file+olp+datetree "notes.org")
                            "* %^{Description} %^g %?\n Added: %U")
                           ("s" "Scractchpad"
                            entry (file+olp+datetree "scratchpad.org" "Scratchpad")
                            "** %^{Description} %^g %?\n Added: %U")
                           ("l" "Lab book"
                            entry (file+olp+datetree "PhD/notes.org")
                            "* %U\n %?\n %i\n %a"))))

;; Programming modes
;; tree-sitter
(setq treesit-language-source-alist
      '((arduino "https://github.com/tree-sitter-grammars/tree-sitter-arduino")
        (bash "https://github.com/tree-sitter/tree-sitter-bash")
        (c "https://github.com/tree-sitter/tree-sitter-c")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (java "https://github.com/tree-sitter/tree-sitter-java")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (jsdoc "https://github.com/tree-sitter/tree-sitter-jsdoc")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (julia "https://github.com/tree-sitter/tree-sitter-julia")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src")
        (phpdoc "https://github.com/claytonrcarter/tree-sitter-phpdoc")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(setq major-mode-remap-alist
      '((bash-mode . bash-ts-mode)
        (c-mode . c-ts-mode)
        (cmake-mode . cmake-ts-mode)
        (cpp-mode . cpp-ts-mode)
        (css-mode . css-ts-mode)
        (go-mode . go-ts-mode)
        (java-mode . java-ts-mode)
        (javascript-mode . javascript-ts-mode)
        (json-mode . json-ts-mode)
        (markdown-mode . markdown-ts-mode)
        (php-mode . php-ts-mode)
        (python-mode . python-ts-mode)
        (rust-mode . rust-ts-mode)
        (toml-mode . toml-ts-mode)
        (yaml-mode . yaml-ts-mode)))

(setq treesit-load-name-override-list '((gomod "libtree-sitter-go")))

;; Set up the Language Server Protocol (LSP) servers using Eglot.
(use-package eglot
  :ensure nil
  :commands (eglot-ensure
             eglot-rename
             eglot-format-buffer)
  :init
  (setq eglot-autoshutdown t
        eglot-events-buffer-config '(:size 0 :format short)
        eglot-sync-connect nil
        lsp-phpactor-path "~/bin/phpactor")
  :config
  ;; Initialization options for Intelephense
  ;; (setq-default eglot-workspace-configuration
  ;;               '((:intelephense
  ;;                  :files (:maxSize 5000000)
  ;;                  :environment (:phpVersion "8.5")
  ;;                  :format (:enable t))))
  ;; (setq eglot-connect-timeout 60
  ;;       eglot-events-buffer-size 0)
  ;; Configure Eglot to enable or disable certain options for the pylsp server
  ;; in Python development. (Note that a third-party tool,
  ;; https://github.com/python-lsp/python-lsp-server, must be installed),
  (setq-default eglot-workspace-configuration
                `(:pylsp (:plugins
                          (;; Fix imports and syntax using `eglot-format-buffer`
                           :isort (:enabled t)
                           :autopep8 (:enabled t)

                           ;; Syntax checkers (works with Flymake)
                           :pylint (:enabled t)
                           :pycodestyle (:enabled t)
                           :flake8 (:enabled t)
                           :pyflakes (:enabled t)
                           :pydocstyle (:enabled t)
                           :mccabe (:enabled t)

                           :yapf (:enabled :json-false)
                           :rope_autoimport (:enabled :json-false)))))
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("C-c f" . eglot-format-buffer)
              ("M-." . xref-find-definitions)
              ("M-," . xref-go-back))
  :hook
  (php-mode . eglot-ensure)
  (php-ts-mode . eglot-ensure)
  (python-mode . eglot-ensure)
  (python-ts-mode . eglot-ensure))
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(php-mode . ("phpactor" "language-server")))
  (add-to-list 'eglot-server-programs
               '(php-ts-mode . ("phpactor" "language-server"))))

;; Enables automatic indentation of code while typing
(use-package aggressive-indent
  :commands aggressive-indent-mode
  :hook
  (emacs-lisp-mode . aggressive-indent-mode))

;; Highlights function and variable definitions in Emacs Lisp mode
(use-package highlight-defined
  :commands highlight-defined-mode
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

;; Prevent parenthesis imbalance
(use-package paredit
  :commands paredit-mode
  :hook
  (emacs-lisp-mode . paredit-mode)
  :config
  (define-key paredit-mode-map (kbd "RET") nil))

;; Displays visible indicators for page breaks
(use-package page-break-lines
  :commands (page-break-lines-mode
             global-page-break-lines-mode)
  :hook
  (emacs-lisp-mode . page-break-lines-mode))

;; Provides functions to find references to functions, macros, variables,
;; special forms, and symbols in Emacs Lisp
(use-package elisp-refs
  :commands (elisp-refs-function
             elisp-refs-macro
             elisp-refs-variable
             elisp-refs-special
             elisp-refs-symbol))
;; A file and project explorer for Emacs that displays a structured tree
;; layout, similar to file browsers in modern IDEs. It functions as a sidebar
;; in the left window, providing a persistent view of files, projects, and
;; other elements.
(use-package treemacs
  :commands (treemacs
             treemacs-select-window
             treemacs-delete-other-windows
             treemacs-select-directory
             treemacs-bookmark
             treemacs-find-file
             treemacs-find-tag)

  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag))

  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))

  :config
  (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
        treemacs-deferred-git-apply-delay        0.5
        treemacs-directory-name-transformer      #'identity
        treemacs-display-in-side-window          t
        treemacs-eldoc-display                   'simple
        treemacs-file-event-delay                2000
        treemacs-file-extension-regex            treemacs-last-period-regex-value
        treemacs-file-follow-delay               0.2
        treemacs-file-name-transformer           #'identity
        treemacs-follow-after-init               t
        treemacs-expand-after-init               t
        treemacs-find-workspace-method           'find-for-file-or-pick-first
        treemacs-git-command-pipe                ""
        treemacs-goto-tag-strategy               'refetch-index
        treemacs-header-scroll-indicators        '(nil . "^^^^^^")
        treemacs-hide-dot-git-directory          t
        treemacs-indentation                     2
        treemacs-indentation-string              " "
        treemacs-is-never-other-window           nil
        treemacs-max-git-entries                 5000
        treemacs-missing-project-action          'ask
        treemacs-move-files-by-mouse-dragging    t
        treemacs-move-forward-on-expand          nil
        treemacs-no-png-images                   nil
        treemacs-no-delete-other-windows         t
        treemacs-project-follow-cleanup          nil
        treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
        treemacs-position                        'left
        treemacs-read-string-input               'from-child-frame
        treemacs-recenter-distance               0.1
        treemacs-recenter-after-file-follow      nil
        treemacs-recenter-after-tag-follow       nil
        treemacs-recenter-after-project-jump     'always
        treemacs-recenter-after-project-expand   'on-distance
        treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
        treemacs-project-follow-into-home        nil
        treemacs-show-cursor                     nil
        treemacs-show-hidden-files               t
        treemacs-silent-filewatch                nil
        treemacs-silent-refresh                  nil
        treemacs-sorting                         'alphabetic-asc
        treemacs-select-when-already-in-treemacs 'move-back
        treemacs-space-between-root-nodes        t
        treemacs-tag-follow-cleanup              t
        treemacs-tag-follow-delay                1.5
        treemacs-text-scale                      nil
        treemacs-user-mode-line-format           nil
        treemacs-user-header-line-format         nil
        treemacs-wide-toggle-width               70
        treemacs-width                           35
        treemacs-width-increment                 1
        treemacs-width-is-initially-locked       t
        treemacs-workspace-switch-cleanup        nil)

  ;; The default width and height of the icons is 22 pixels. If you are
  ;; using a Hi-DPI display, uncomment this to double the icon size.
  ;; (treemacs-resize-icons 44)

  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)

  ;;(when treemacs-python-executable
  ;;  (treemacs-git-commit-diff-mode t))

  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))

  (treemacs-hide-gitignored-files-mode nil))

;; Fish shell
(use-package fish-mode
  :commands fish-mode
  :mode("\\.fish\\'" . fish-mode)
  :custom
  (fish-enable-auto-indent t))

;; The markdown-mode package provides a major mode for Emacs for syntax
;; highlighting, editing commands, and preview support for Markdown documents.
;; It supports core Markdown syntax as well as extensions like GitHub Flavored
;; Markdown (GFM).
(use-package markdown-mode
  :commands (gfm-mode
             gfm-view-mode
             markdown-mode
             markdown-view-mode)
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind
  (:map markdown-mode-map
        ("C-c C-e" . markdown-do)))

;; php-ts-mode
(use-package php-ts-mode
  :ensure nil
  :mode ("\\.php\\'" "\\.phtml\\'")
  :hook (php-ts-mode . eglot-ensure))
(use-package reformatter
  :ensure t
  :config
  (reformatter-define php-cs-fix
                      :program "/usr/bin/php-cs-fixer"
                      :args (list "fix" "--using-cache=no" "-"))
  :hook
  (php-mode . php-cs-fixer-on-save-mode)
  (php-ts-mode . php-cs-fix-on-save-mode))
(use-package flymake-phpstan
  :ensure t
  :hook
  (php-mode . flymake-phpstan-turn-on)
  (php-ts-mode . flymake-phpstan-turn-on))

;; Define a minor mode to hold some of my keybindings
(define-minor-mode em-keymaps-mode
  "Personal keybindings."
  :init-value nil
  :global t
  :keymap (let ((map (make-sparse-keymap)))
            ;; Emacs frame-related keybindings
            (define-key map (kbd "C-c C-f d") 'delete-frame)
            (define-key map (kbd "C-c C-f n") 'make-frame)
            (define-key map (kbd "C-c C-f o") 'other-frame)
            (define-key map (kbd "C-c C-f l") 'lower-frame)
            (define-key map (kbd "C-c C-f r") 'raise-frame)
            ;; Org-mode keybindings
            (define-key map (kbd "C-c l") #'org-store-link)
            (define-key map (kbd "C-c a") #'org-agenda)
            (define-key map (kbd "C-c c") #'org-capture)
            (define-key map (kbd "C-c .") #'org-time-stamp)
            (define-key map (kbd "C-c ,") #'org-time-stamp-inactive)
            ;; EasyPG interface for GPG
            (define-key map (kbd "C-c M-e l") 'epa-list-keys)
            (define-key map (kbd "C-c M-e L") 'epa-list-secret-keys)
            (define-key map (kbd "C-c M-e v") 'epa-verify-region)
            (define-key map (kbd "C-c M-e V") 'epa-verify-file)
            (define-key map (kbd "C-c M-e d") 'epa-decrypt-region)
            (define-key map (kbd "C-c M-e D") 'epa-decrypt-file)
            (define-key map (kbd "C-c M-e e") 'epa-encrypt-region)
            (define-key map (kbd "C-c M-e E") 'epa-encrypt-file)
            (define-key map (kbd "C-c M-e s") 'epa-sign-region)
            (define-key map (kbd "C-c M-e S") 'epa-sign-file)
            ;; Other keybindings
            (define-key map (kbd "C-c ;") 'comment-or-uncomment-region)
            (define-key map (kbd "<escape>") 'keyboard-escape-quit)
            (define-key map (kbd "C-c C-a") 'mark-whole-buffer)
            (define-key map (kbd "C-c C-p") 'mark-paragraph)
            map))
(add-hook 'after-init-hook 'em-keymaps-mode)
(em-keymaps-mode 1)

(provide 'post-init)
;;; post-init.el ends here

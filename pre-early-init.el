;;; pre-early--init.el --- DESCRIPTION -*- no-byte-compile: t; lexical-binding: t; -*-
(setq debug-on-error t)

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes")
(load-theme 'tron-legacy t)
(setq tron-legacy-theme-vivid-cursor t)

;; Set frame transparency
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

;; Start emacs frame maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

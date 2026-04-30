;; verilog-auto-config.el - user config loaded before verilog-batch-auto

(setq-default indent-tabs-mode nil)
(add-hook 'verilog-mode-hook (lambda () (setq indent-tabs-mode nil)))

(setq verilog-indent-level 4)
(setq verilog-indent-level-module 4)
(setq verilog-indent-level-declaration 4)

(setq verilog-auto-wire-comment nil)
(setq verilog-auto-inst-column 20)

;; Case-insensitive module file lookup: try original name, then lowercase
(defun name-case-fix (orig-fun module &rest args)
  (or (apply orig-fun module args)
      (apply orig-fun (downcase module) args)))
(advice-add 'verilog-library-filenames :around #'name-case-fix)

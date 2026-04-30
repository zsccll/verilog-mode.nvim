# verilog-mode.nvim

Vim/Neovim plugin integrating Emacs verilog-mode for Verilog and SystemVerilog files. Primarily targets Neovim; Vim 8.1+ is supported but may be dropped in a future release.

## Requirements

| | Minimum | Notes |
|---|---|---|
| Vim | 8.1 | Sync execution, no output window |
| Neovim | 0.7 | Async output window; press `<CR>` to close and apply |
| Emacs | 23+ | verilog-mode built-in |

## Installation

### lazy.nvim
```lua
{ 'zsccll/verilog-mode.nvim', ft = { 'verilog', 'systemverilog' } }
```

### vim-plug
```vimscript
Plug 'zsccll/verilog-mode.nvim', {'for': ['verilog', 'systemverilog']}
```

**[Emacs](https://www.gnu.org/software/emacs/download.html) must be in PATH** (or set `g:VerilogModeEmacsPath`).

## Usage

| Key | Description |
|-----|-------------|
| `<leader>a` | Expand autos (`verilog-batch-auto`) |
| `<leader>d` | Delete autos (`verilog-batch-delete-auto`) |

In Neovim, a split window shows Emacs output. Press `<CR>` to close it and apply changes.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `g:VerilogModeAddKey` | `<leader>a` | Key for expand autos |
| `g:VerilogModeDeleteKey` | `<leader>d` | Key for delete autos |
| `g:VerilogModeEmacsPath` | `''` | Path to Emacs executable; empty means search in PATH |
| `g:VerilogModeEmacsDefault` | `1` | `1`: use Emacs built-in verilog-mode; `0`: use `g:VerilogModeFile` |
| `g:VerilogModeFile` | `~/.elisp/verilog-mode.el` | Path to custom [verilog-mode.el](https://github.com/veripool/verilog-mode/releases) (only when `EmacsDefault=0`) |
| `g:VerilogModeUseScript` | `1` | Load an Emacs config script before processing |
| `g:VerilogModeScriptPath` | `~/.emacs` | Path to Emacs config script |
| `g:VerilogModeTrace` | `0` | `1`: write Emacs output to `verilog_emacs.log` in the file's directory |

### Custom Emacs config

The plugin ships with `verilog-auto-config.el` (spaces, indent 4, case-insensitive lookup). Point `g:VerilogModeScriptPath` to it:

```vimscript
let g:VerilogModeUseScript = 1
let g:VerilogModeScriptPath = '~/.config/nvim/verilog-auto-config.el'
```

### Lowercase filenames with uppercase module names

verilog-mode's filename lookup is case-sensitive. Use a `.f` filelist to bypass it:

```systemverilog
// Local Variables:
// verilog-library-flags:("-f" "./filelist.f")
// End:
```

```
./sub_sv_2.sv
./sub_sv_4.sv
```

### Windows

```vimscript
let g:VerilogModeEmacsDefault = 0
let g:VerilogModeFile = 'D:/emacs/site-lisp/verilog-mode.el'
```

## Acknowledgements

- [verilog_emacsauto.vim](https://github.com/vim-scripts/verilog_emacsauto.vim) by Vim — original plugin this project is based on
- [verilog-mode](https://github.com/veripool/verilog-mode) by Wilson Snyder et al. — the Emacs verilog-mode that does the actual AUTO expansion

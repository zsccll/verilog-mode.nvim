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

| Key / Command | Description |
|-----|-------------|
| `<leader>a` | Expand AUTOs in the current file |
| `<leader>d` | Delete generated AUTO sections |
| `<leader>i` | Inject AUTO markers into legacy files |
| `:VerilogDiffAuto` | Open vimdiff comparing current file against re-expanded result |
| `:VerilogBatchIndent` | Reformat the current file |
| `:VerilogStripWS` | Strip trailing whitespace from all lines |

In Neovim, a split window shows Emacs output. Press `<CR>` to close it and apply changes.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `g:VerilogModeAddKey` | `<leader>a` | Key for expand autos |
| `g:VerilogModeDeleteKey` | `<leader>d` | Key for delete autos |
| `g:VerilogModeInjectKey` | `<leader>i` | Key for inject autos |
| `g:VerilogModeEmacsPath` | `''` | Path to Emacs executable; empty means search in PATH |
| `g:VerilogModeEmacsDefault` | `1` | `1`: use Emacs built-in verilog-mode; `0`: use `g:VerilogModeFile` |
| `g:VerilogModeFile` | `~/.elisp/verilog-mode.el` | Path to custom [verilog-mode.el](https://github.com/veripool/verilog-mode/releases) (only when `EmacsDefault=0`) |
| `g:VerilogModeUseScript` | `1` | Load an Emacs config script before processing |
| `g:VerilogModeScriptPath` | `~/.emacs` | Path to Emacs config script |
| `g:VerilogModeTrace` | `0` | `1`: write Emacs output to `verilog_emacs.log` in the file's directory |
| `g:VerilogModeStripInlineComments` | `0` | `1`: strip `// Templated` and `// Implicit .*` comments after expansion |
| `g:VerilogModeStripAutoComments` | `0` | `1`: also strip `// Outputs`/`// Inputs`/`// Inouts` headers and `// Beginning of automatic...`/`// End of automatics` block markers |
| `g:VerilogModeLibraryFiles` | `[]` | `.f` file paths used for module lookup |

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

You can also configure filelists globally without adding Local Variables to each source file:

```vimscript
let g:VerilogModeLibraryFiles = ['$CFG_DIR/DUT.f']
```

Multiple filelists are supported:

```vimscript
let g:VerilogModeLibraryFiles = [
      \ '$CFG_DIR/DUT.f',
      \ '$CFG_DIR/common.f',
      \]
```

When set, these filelists are used for module lookup without requiring Local Variables in each source file. If a source file already defines `verilog-library-flags`, that per-file setting takes priority. Missing filelists are skipped with a warning.

### Windows

```vimscript
let g:VerilogModeEmacsDefault = 0
let g:VerilogModeFile = 'D:/emacs/site-lisp/verilog-mode.el'
```

## Acknowledgements

- [verilog_emacsauto.vim](https://github.com/vim-scripts/verilog_emacsauto.vim) by Vim — original plugin this project is based on
- [verilog-mode](https://github.com/veripool/verilog-mode) by Wilson Snyder et al.

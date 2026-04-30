" Vim filetype plugin for using emacs verilog-mode
" Last Change: 2026 04/30
" Author: zsccll
" License: This file is placed in the public domain.

if exists("loaded_verilog_mode_nvim")
   finish
endif
let loaded_verilog_mode_nvim = 1

if get(g:, 'VerilogModeEmacsPath', '') ==# ''
   if !executable('emacs')
      echohl WarningMsg | echom "VerilogMode: emacs not found in PATH, plugin disabled" | echohl None
      finish
   endif
elseif !executable(expand(get(g:, 'VerilogModeEmacsPath', '')))
   echohl WarningMsg | echom "VerilogMode: emacs not found at '" . g:VerilogModeEmacsPath . "', plugin disabled" | echohl None
   finish
endif

function! s:InitVar(var, value)
    if !exists(a:var)
        exec 'let '.a:var.'='.string(a:value)
    endif
endfunction

let s_DefaultPath = expand("$HOME") . "/.elisp/verilog-mode.el"

call s:InitVar('g:VerilogModeAddKey', '<leader>a')
call s:InitVar('g:VerilogModeDeleteKey', '<leader>d')
call s:InitVar('g:VerilogModeFile', s_DefaultPath)
call s:InitVar('g:VerilogModeTrace', 0)
call s:InitVar('g:VerilogModeEmacsDefault', 1)
call s:InitVar('g:VerilogModeUseScript', 1)
call s:InitVar('g:VerilogModeScriptPath', '~/.emacs')
call s:InitVar('g:VerilogModeEmacsPath', '')
call s:InitVar('g:VerilogModeStripInlineComments', 0)
call s:InitVar('g:VerilogModeStripAutoComments', 0)

try
    if g:VerilogModeAddKey != ""
        exec 'nnoremap <silent><unique> ' g:VerilogModeAddKey '<Plug>VerilogEmacsAutoAdd'
    endif
catch /^Vim\%((\a\+)\)\=:E227/
endtry

try
    if g:VerilogModeDeleteKey != ""
        exec 'nnoremap <silent><unique> ' g:VerilogModeDeleteKey '<Plug>VerilogEmacsAutoDelete'
    endif
catch /^Vim\%((\a\+)\)\=:E227/
endtry

noremap <unique> <script> <Plug>VerilogEmacsAutoAdd    <SID>Add
noremap <unique> <script> <Plug>VerilogEmacsAutoDelete <SID>Delete
noremap <SID>Add    :call <SID>Add()<CR>
noremap <SID>Delete :call <SID>Delete()<CR>
noremap <SID>EN_Default :call <SID>EN_Default()<CR>
noremap <SID>Dis_Default :call <SID>Dis_Default()<CR>

" add menu items for gvim
noremenu <script> Verilog-Mode.AddAuto    <SID>Add
noremenu <script> Verilog-Mode.DeleteAuto <SID>Delete
noremenu <script> Verilog-Mode.EN_Default_Mode <SID>EN_Default
noremenu <script> Verilog-Mode.Dis_Default_Mode <SID>Dis_Default

let s:is_win = has('win16') || has('win32') || has('win64')

function! s:RunEmacs(cmd, logfile)
   if a:logfile != ''
      if s:is_win
         call system(a:cmd . " >" . shellescape(a:logfile) . " 2>&1")
      elseif &shell =~# 'csh'
         call system(a:cmd . " >& " . shellescape(a:logfile))
      else
         call system("/bin/sh -c " . shellescape(a:cmd . " >" . a:logfile . " 2>&1"))
      endif
   else
      call system(a:cmd)
   endif
endfunction

if has('nvim')
lua << EOF
local M = {}
function M.run(cmd, srcbuf, tmpfile, expandtab_save, logfile)
   local out_buf = vim.api.nvim_create_buf(false, true)
   vim.bo[out_buf].bufhidden = 'wipe'
   vim.bo[out_buf].modifiable = false
   vim.cmd('botright 12split')
   vim.api.nvim_win_set_buf(0, out_buf)
   local out_win = vim.api.nvim_get_current_win()
   vim.wo[out_win].number = false
   vim.wo[out_win].wrap = false

   local collected = {}
   local function append(lines)
      local last = vim.api.nvim_buf_line_count(out_buf)
      vim.api.nvim_buf_set_lines(out_buf, last, last, false, lines)
      if vim.api.nvim_win_is_valid(out_win) then
         vim.api.nvim_win_set_cursor(out_win, {vim.api.nvim_buf_line_count(out_buf), 0})
      end
      if logfile ~= '' then vim.list_extend(collected, lines) end
   end

   vim.bo[out_buf].modifiable = true
   vim.fn.jobstart({'sh', '-c', cmd}, {
      stdout_buffered = false, stderr_buffered = false,
      on_stdout = function(_, data) if data then append(data) end end,
      on_stderr = function(_, data) if data then append(data) end end,
      on_exit = function(_, code)
         if logfile ~= '' then vim.fn.writefile(collected, logfile) end
         append({'', '--- Done (exit ' .. code .. ') --- Press <CR> to close ---'})
         vim.bo[out_buf].modifiable = false
         vim.keymap.set('n', '<CR>', function()
            if vim.api.nvim_win_is_valid(out_win) then
               vim.api.nvim_win_close(out_win, true)
            end
            vim.schedule(function()
               vim.api.nvim_set_current_buf(srcbuf)
               local newcontent = vim.fn.VerilogModeStripAutoComments(vim.fn.readfile(vim.fn.fnameescape(tmpfile)))
               if expandtab_save >= 0 then
                  vim.cmd('retab')
                  vim.bo.tabstop = expandtab_save
               end
               vim.api.nvim_buf_set_lines(srcbuf, 0, -1, false, newcontent)
               vim.fn.delete(tmpfile)
               vim.cmd('write!')
               vim.cmd('redraw!')
            end)
         end, {buffer = out_buf, nowait = true})
      end,
   })
end
package.loaded['verilog_mode'] = M
EOF
endif

function s:EN_Default()
   let g:VerilogModeEmacsDefault = 1
   echo "set default mode"
endfunction

function s:Dis_Default()
   let g:VerilogModeEmacsDefault = 0
   echo "set file mode"
endfunction

function s:GetScriptArgs()
   if g:VerilogModeUseScript
      if filereadable(expand(g:VerilogModeScriptPath))
         let l:path = expand(g:VerilogModeScriptPath)
         if s:is_win
            let l:path = substitute(l:path, '\\', '/', 'g')
         endif
         return " -l " . shellescape(l:path)
      else
         echohl WarningMsg | echom "VerilogMode: script file not found: " . g:VerilogModeScriptPath | echohl None
      endif
   endif
   return ""
endfunction

function! s:StripAutoComments(lines)
    if !g:VerilogModeStripInlineComments && !g:VerilogModeStripAutoComments
        return a:lines
    endif
    let l:result = []
    for l:line in a:lines
        if g:VerilogModeStripInlineComments
            let l:line = substitute(l:line, '\s*\/\/ Templated\(\s.*\)\?$', '', '')
            let l:line = substitute(l:line, '\s*\/\/ Implicit .*$', '', '')
        endif
        if g:VerilogModeStripAutoComments
            if l:line =~# '^\s*\/\/ \(Outputs\|Inputs\|Inouts\)\s*$'
                continue
            endif
            if l:line =~# '^\s*\/\/ \(Beginning of automatic\|End of automatics\)'
                continue
            endif
        endif
        call add(l:result, l:line)
    endfor
    return l:result
endfunction

function! VerilogModeStripAutoComments(lines)
    return s:StripAutoComments(a:lines)
endfunction

function! s:ApplyTmpFile(bufnr, tmpfile, expandtab_save)
   execute 'buffer ' . a:bufnr
   let l:newcontent = s:StripAutoComments(readfile(fnameescape(a:tmpfile), ''))
   if a:expandtab_save >= 0
      retab
      let &tabstop = a:expandtab_save
   endif
   call setline(1, l:newcontent)
   if line('$') > len(l:newcontent)
      call deletebufline('%', len(l:newcontent) + 1, line('$'))
   endif
   call delete(a:tmpfile)
   w! %
   redraw!
endfunction

function s:RunAuto(action)
   let l:expandtab_save = (a:action ==# 'add' && &expandtab) ? &tabstop : -1
   if a:action ==# 'add' && &expandtab | let &tabstop = 8 | endif
   let l:tmpfile = expand("%:p:h") . "/." . expand("%:p:t")
   silent! call writefile(getline(1, "$"), fnameescape(l:tmpfile), '')
   let l:script_args = s:GetScriptArgs()
   let l:emacs_exe = g:VerilogModeEmacsPath !=# '' ? shellescape(expand(g:VerilogModeEmacsPath)) : 'emacs'
   let l:emacs_cmd = l:emacs_exe . " -batch --no-site-file "
   if !g:VerilogModeEmacsDefault
      if !filereadable(expand(g:VerilogModeFile))
         echohl ErrorMsg | echom "VerilogMode: verilog-mode.el not found: " . g:VerilogModeFile | echohl None
         return
      endif
      let l:emacs_cmd .= "-l " . g:VerilogModeFile . " "
   endif
   let l:batch_fn = a:action ==# 'add' ? 'verilog-batch-auto' : 'verilog-batch-delete-auto'
   let l:emacs_cmd .= l:script_args . " " . shellescape(l:tmpfile, 1) . " -f " . l:batch_fn
   let l:logfile = g:VerilogModeTrace ? expand("%:p:h") . "/verilog_emacs.log" : ''
   if has('nvim')
      call luaeval('require("verilog_mode").run(_A[1],_A[2],_A[3],_A[4],_A[5])',
               \ [l:emacs_cmd, bufnr('%'), l:tmpfile, l:expandtab_save, l:logfile])
   else
      call s:RunEmacs(l:emacs_cmd, l:logfile)
      call s:ApplyTmpFile(bufnr('%'), l:tmpfile, l:expandtab_save)
   endif
endfunction

function s:Add()
   call s:RunAuto('add')
endfunction

function s:Delete()
   call s:RunAuto('delete')
endfunction

function VerilogEmacsAutoFoldLevel(l)
   if (getline(a:l-1)=~'\/\*A\S*\*\/' && getline(a:l)=~'\/\/ \(Outputs\|Inputs\|Inouts\|Beginning\)')
      return 1
   endif
   if (getline(a:l-1)=~'\(End of automatics\|);\)')
      return 0
   endif
   return '='
endfunction

function! VerilogEmacsAutoAdd()
    call s:Add()
endfunction

function! VerilogEmacsAutoDelete()
    call s:Delete()
endfunction

if has('nvim')
lua << EOF
vim.api.nvim_create_user_command('VerilogBatchAuto',
  function() vim.fn.VerilogEmacsAutoAdd() end,
  { desc = 'Verilog: expand autos (verilog-batch-auto)' })
vim.api.nvim_create_user_command('VerilogBatchDeleteAuto',
  function() vim.fn.VerilogEmacsAutoDelete() end,
  { desc = 'Verilog: delete autos (verilog-batch-delete-auto)' })
EOF
endif

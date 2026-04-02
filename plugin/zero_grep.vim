" plugin/zero_grep.vim - Word getter commands and mappings (legacy Vimscript)
" Maintainer: Phong Nguyen

if has('nvim') || exists('g:loaded_zero_grep')
    finish
endif

" Use Vim9script implementation if available, otherwise fall back to legacy
if has('vim9script')
    " Add vim9/ subdirectory to runtimepath so vim9/autoload/zero_grep.vim
    " is found when the Vim9script plugin sources it via 'import autoload'
    let s:vim9dir = fnamemodify(resolve(expand('<sfile>:p')), ':h:h') .. '/vim9'
    if &runtimepath !~# s:vim9dir
        execute 'set runtimepath^=' . fnameescape(s:vim9dir)
    endif
    unlet! s:vim9dir
    source <sfile>:p:h:h/vim9/plugin/zero_grep.vim
    finish
endif

let g:loaded_zero_grep = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" ============================================================================
" Functions
" ============================================================================
function! g:FileTypeArgs(...) abort
    return zero_grep#filetype#Args(...)
endfunction

function! g:DumbJumpCword(...) abort
    return zero_grep#dumb_jump#Cword(...)
endfunction

function! g:DumbJumpCwordArgs(...) abort
    return zero_grep#dumb_jump#CwordArgs(...)
endfunction

function! g:CCword() abort
    return zero_grep#CCword()
endfunction

function! g:Cword() abort
    return zero_grep#Cword()
endfunction

function! g:Word() abort
    return zero_grep#Word()
endfunction

function! g:Vword() abort
    return zero_grep#Vword()
endfunction

function! g:Pword() abort
    return zero_grep#Pword()
endfunction

function! g:ShellCCword() abort
    return zero_grep#ShellCCword()
endfunction

function! g:ShellCword() abort
    return zero_grep#ShellCword()
endfunction

function! g:ShellWord() abort
    return zero_grep#ShellWord()
endfunction

function! g:ShellVword() abort
    return zero_grep#ShellVword()
endfunction

function! g:ShellPword() abort
    return zero_grep#ShellPword()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

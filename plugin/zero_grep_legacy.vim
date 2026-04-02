" plugin/zero_grep_legacy.vim - Word getter commands and mappings (legacy Vimscript)
" Maintainer: Phong Nguyen

if has('vim9script') || has('nvim') || exists('g:loaded_zero_grep')
    finish
endif

let g:loaded_zero_grep = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" ============================================================================
" Functions
" ============================================================================
function! g:FileTypeArgs(...) abort
    return zero_grep#legacy#filetype#Args(...)
endfunction

function! g:DumbJumpCword(...) abort
    return zero_grep#legacy#dumb_jump#Cword(...)
endfunction

function! g:DumbJumpCwordArgs(...) abort
    return zero_grep#legacy#dumb_jump#CwordArgs(...)
endfunction

function! g:CCword() abort
    return zero_grep#legacy#CCword()
endfunction

function! g:Cword() abort
    return zero_grep#legacy#Cword()
endfunction

function! g:Word() abort
    return zero_grep#legacy#Word()
endfunction

function! g:Vword() abort
    return zero_grep#legacy#Vword()
endfunction

function! g:Pword() abort
    return zero_grep#legacy#Pword()
endfunction

function! g:ShellCCword() abort
    return zero_grep#legacy#ShellCCword()
endfunction

function! g:ShellCword() abort
    return zero_grep#legacy#ShellCword()
endfunction

function! g:ShellWord() abort
    return zero_grep#legacy#ShellWord()
endfunction

function! g:ShellVword() abort
    return zero_grep#legacy#ShellVword()
endfunction

function! g:ShellPword() abort
    return zero_grep#legacy#ShellPword()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

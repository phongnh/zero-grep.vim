" plugin/zero_grep.vim - Word getter commands and mappings
" Maintainer: Phong Nguyen

if has('nvim') || exists('g:loaded_zero_grep')
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

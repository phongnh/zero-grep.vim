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
function! g:FileTypeOpts(...) abort
    return zero_grep#legacy#filetype#Opts(...)
endfunction

" ============================================================================
" Commands
" ============================================================================

" Raw word getters
command! ZeroGrepCCword         echo zero_grep#legacy#CCword()
command! ZeroGrepCword          echo zero_grep#legacy#Cword()
command! ZeroGrepWord           echo zero_grep#legacy#Word()
command! -range ZeroGrepVword   echo zero_grep#legacy#Vword()
command! ZeroGrepPword          echo zero_grep#legacy#Pword()

let &cpoptions = s:save_cpo
unlet s:save_cpo

" plugin/zero_grep.vim - Word getter commands and mappings (Vim9script)
" Maintainer: Phong Nguyen

if !has('vim9script') || has('nvim') || exists('g:loaded_zero_grep')
    finish
endif

vim9script

g:loaded_zero_grep = 1

import autoload 'zero_grep.vim' as ZeroGrep

# ============================================================================
# Commands
# ============================================================================

# Raw word getters
command! ZeroGrepCCword         echo ZeroGrep.CCword()
command! ZeroGrepCword          echo ZeroGrep.Cword()
command! ZeroGrepWord           echo ZeroGrep.Word()
command! -range ZeroGrepVword   echo ZeroGrep.Vword()
command! ZeroGrepPword          echo ZeroGrep.Pword()

# Context-aware insert helpers (for use in <C-R>= mappings)
command! ZeroGrepInsertCCword   <C-R>=ZeroGrep.InsertCCword()<CR>
command! ZeroGrepInsertCword    <C-R>=ZeroGrep.InsertCword()<CR>
command! ZeroGrepInsertWord     <C-R>=ZeroGrep.InsertWord()<CR>
command! ZeroGrepInsertVword    <C-R>=ZeroGrep.InsertVword()<CR>
command! ZeroGrepInsertPword    <C-R>=ZeroGrep.InsertPword()<CR>

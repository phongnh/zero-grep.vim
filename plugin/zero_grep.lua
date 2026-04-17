-- plugin/zero_grep.lua - Word getter commands and mappings (Neovim Lua)
-- Maintainer: Phong Nguyen

if not vim.fn.has("nvim") or vim.g.loaded_zero_grep then
  return
end
vim.g.loaded_zero_grep = 1

require("zero_grep").setup()

-- ============================================================================
-- Functions
-- ============================================================================
vim.cmd([[
function! g:CCword() abort
    return v:lua.require("zero_grep").ccword()
endfunction

function! g:Cword() abort
    return v:lua.require("zero_grep").cword()
endfunction

function! g:Word() abort
    return v:lua.require("zero_grep").word()
endfunction

function! g:Vword() abort
    return v:lua.require("zero_grep").vword()
endfunction

function! g:Pword() abort
    return v:lua.require("zero_grep").pword()
endfunction

function! g:ShellCCword() abort
    return v:lua.require("zero_grep").shell_ccword()
endfunction

function! g:ShellCword() abort
    return v:lua.require("zero_grep").shell_cword()
endfunction

function! g:ShellWord() abort
    return v:lua.require("zero_grep").shell_word()
endfunction

function! g:ShellVword() abort
    return v:lua.require("zero_grep").shell_vword()
endfunction

function! g:ShellPword() abort
    return v:lua.require("zero_grep").shell_pword()
endfunction
]])

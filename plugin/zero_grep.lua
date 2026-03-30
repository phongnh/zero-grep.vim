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
function! g:FileTypeArgs(...) abort
    let l:tool = get(a:, 1, '')
    return v:lua.require("zero_grep.filetype").args(l:tool)
endfunction

function! g:DumbJumpCword(...) abort
    let l:lf = get(a:, 1, '')
    return v:lua.require("zero_grep.dumb_jump").cword(l:ft)
endfunction

function! g:DumbJumpCwordArgs(...) abort
    let l:lf = get(a:, 1, '')
    return v:lua.require("zero_grep.dumb_jump").cword_args(l:ft)
endfunction

function! g:Word() abort
    return v:lua.require("zero_grep").Word()
endfunction

function! g:Vword() abort
    return v:lua.require("zero_grep").Vord()
endfunction

function! g:Pword() abort
    return v:lua.require("zero_grep").Pword()
endfunction

function! g:ShellWord() abort
    return v:lua.require("zero_grep").shell_Word()
endfunction

function! g:ShellVword() abort
    return v:lua.require("zero_grep").shell_Vword()
endfunction

function! g:ShellPword() abort
    return v:lua.require("zero_grep").shell_Pword()
endfunction
]])

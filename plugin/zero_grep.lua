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
    return luaeval('require("zero_grep.filetype").args(_A[1])', [l:tool])
endfunction

function! g:DumbJumpCword(...) abort
    let l:ft = get(a:, 1, '')
    return luaeval('require("zero_grep.dumb_jump").cword(_A[1])', [l:ft])
endfunction

function! g:DumbJumpCwordArgs(...) abort
    let l:ft = get(a:, 1, '')
    return luaeval('require("zero_grep.dumb_jump").cword_args(_A[1])', [l:ft])
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

-- lua/zero_grep.lua - Core word getters and context-aware dispatch (Neovim Lua)
-- Maintainer: Phong Nguyen

local M = {}

-- ============================================================================
-- Escape Characters per Context
-- ============================================================================

local GREP_ESCAPE_CHARS = "^$.*+?()[]{}|-"
local SUBSTITUTE_ESCAPE_CHARS = "^$.*\\/~[]"
local SHELL_ESCAPE_CHARS = "\\^$.*+?()[]{}|-"
local LEADERF_ESCAPE_CHARS = '\\^$.*+?()[]{}|-"'

-- ============================================================================
-- Setup
-- ============================================================================

function M.setup()
  -- Placeholder for future g:zero_grep_* options
end

-- ============================================================================
-- Escape Helpers
-- ============================================================================

local function vim_escape(text, chars)
  -- Replicate Vim's escape() function
  local result = text
  for i = 1, #chars do
    local c = chars:sub(i, i)
    -- escape the pattern char itself for gsub
    local escaped_c = c:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
    result = result:gsub(escaped_c, "\\" .. c)
  end
  return result
end

local function grep_escape(text)
  local t = text:gsub("#", "\\\\#")
  t = vim_escape(t, GREP_ESCAPE_CHARS)
  return vim.fn.shellescape(t)
end

local function substitute_escape(text)
  local t = vim_escape(text, SUBSTITUTE_ESCAPE_CHARS)
  return t:gsub("\n", "\\n")
end

local function shell_escape(text)
  return vim.fn.shellescape(vim_escape(text, SHELL_ESCAPE_CHARS))
end

local function leaderf_escape(text)
  return vim.fn.shellescape(vim_escape(text, LEADERF_ESCAPE_CHARS))
end

-- ============================================================================
-- Raw Word Getters
-- ============================================================================

function M.ccword()
  return "\\b" .. vim.fn.expand("<cword>") .. "\\b"
end

function M.cword()
  return vim.fn.expand("<cword>")
end

function M.word()
  return vim.fn.expand("<cWORD>")
end

function M.vword()
  if vim.fn.exists("*getregion") == 1 then
    local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"))
    return vim.trim(#lines > 0 and lines[1] or "")
  end
  local line = vim.fn.getline("'<")
  local _b1, l1, c1, _o1 = unpack(vim.fn.getpos("'<"))
  local _b2, l2, c2, _o2 = unpack(vim.fn.getpos("'>"))
  if l1 ~= l2 then
    return vim.trim(line:sub(c1))
  end
  return vim.trim(line:sub(c1, c2))
end

function M.pword()
  local search = vim.fn.getreg("/")
  if search == "" or search == "\n" then
    return ""
  end
  return search:gsub("^\\<(.+)\\>$", "\\b%1\\b")
end

-- ============================================================================
-- Context-Namespaced Escape Functions
-- ============================================================================

-- grep

function M.grep_escape(text)
  return grep_escape(text)
end

function M.grep_ccword()
  return grep_escape(M.ccword())
end

function M.grep_cword()
  return grep_escape(M.cword())
end

function M.grep_word()
  return grep_escape(M.word())
end

function M.grep_vword()
  return grep_escape(M.vword())
end

function M.grep_pword()
  return grep_escape(M.pword())
end

-- substitute

function M.substitute_escape(text)
  return substitute_escape(text)
end

function M.substitute_ccword()
  return "\\<" .. M.cword() .. "\\>"
end

function M.substitute_cword()
  return M.cword()
end

function M.substitute_word()
  return substitute_escape(M.word())
end

function M.substitute_vword(whole_word)
  local t = substitute_escape(M.vword())
  return whole_word and ("\\<" .. t .. "\\>") or t
end

function M.substitute_pword()
  return substitute_escape(M.pword())
end

-- shell

function M.shell_escape(text)
  return shell_escape(text)
end

function M.shell_ccword()
  return vim.fn.shellescape(M.ccword())
end

function M.shell_cword()
  return vim.fn.shellescape(M.cword())
end

function M.shell_word()
  return shell_escape(M.word())
end

function M.shell_vword()
  return shell_escape(vim.fn.trim(M.vword()))
end

function M.shell_pword()
  return shell_escape(vim.fn.trim(M.pword()))
end

-- leaderf
-- LeaderF uses its own regex engine; escape chars include '"' in addition to
-- the shell set. ccword and cword are passed as plain shellescape (no regex
-- boundaries) because LeaderF handles word matching internally.

function M.leaderf_escape(text)
  return leaderf_escape(text)
end

function M.leaderf_ccword()
  return vim.fn.shellescape(M.ccword())
end

function M.leaderf_cword()
  return vim.fn.shellescape(M.cword())
end

function M.leaderf_word()
  return leaderf_escape(M.word())
end

function M.leaderf_vword()
  return leaderf_escape(trim(M.vword()))
end

function M.leaderf_pword()
  return leaderf_escape(trim(M.pword()))
end

-- file type
function M.file_type_args(tool, ft)
  return require("zero_grep.filetype").args(tool, ft)
end

-- dumb_jump
function M.dumb_jump_cword(ft)
  return require("zero_grep.dumb_jump").cword(ft)
end

function M.dumb_jump_cword_args(ft)
  return require("zero_grep.dumb_jump").cword(ft)
end

-- ============================================================================
-- Context Detection
-- ============================================================================

local function is_substitute_command(cmd)
  return cmd:match("^%%?[sS]ubstitute?/") ~= nil
    or cmd:match("^%%?s/") ~= nil
    or cmd:match("^%%?S/") ~= nil
    or cmd:match("^%%?Subvert/") ~= nil
    or cmd:match("^silent!?%s+[cl][fd][od]o%s+[sS]") ~= nil
    or cmd:match("^[cl][fd][od]o%s+[sS]") ~= nil
end

local function is_grep_command(cmd)
  return cmd:match("^[BL]?[Gg]rep%s") ~= nil
    or cmd:match("^lgrep%s") ~= nil
    or cmd:match("^Gc?l?grep!?%s") ~= nil
    or cmd:match("^Git!?%s+grep%s") ~= nil
end

local function is_grepper_git_command(cmd)
  return cmd:match("^GrepperGit%s") ~= nil
end

local function is_grepper_command(cmd)
  return cmd:match("^[SLPT]?Grepper%s") ~= nil or cmd:match("^GrepperRg%s") ~= nil
end

local function is_leaderf_command(cmd)
  return cmd:match("^Leaderf%s") ~= nil or cmd:match("^LF%s") ~= nil
end

local function is_input_command()
  return vim.fn.getcmdtype() == "@"
end

-- ============================================================================
-- Context-Aware Insert Functions (for <C-R>= mappings)
-- ============================================================================

function M.insert_ccword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_ccword()
  elseif is_grepper_git_command(cmd) then
    return M.dumb_jump_cword()
  elseif is_grepper_command(cmd) then
    return M.dumb_jump_cword()
  elseif is_grep_command(cmd) then
    return M.grep_ccword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_ccword()
  else
    return M.shell_ccword()
  end
end

function M.insert_cword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_cword()
  elseif is_grepper_git_command(cmd) then
    return M.dumb_jump_cword()
  elseif is_grepper_command(cmd) then
    return M.dumb_jump_cword()
  elseif is_grep_command(cmd) then
    return M.grep_ccword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_cword()
  elseif is_input_command() then
    return M.shell_cword()
  else
    return M.cword()
  end
end

function M.insert_word()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_word()
  elseif is_grepper_git_command(cmd) or is_grepper_command(cmd) then
    return M.dumb_jump_cword()
  elseif is_grep_command(cmd) then
    return M.grep_word()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_word()
  else
    return M.shell_word()
  end
end

function M.insert_vword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_vword()
  elseif is_grep_command(cmd) then
    return M.grep_vword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_vword()
  elseif is_input_command() then
    return M.shell_vword()
  else
    return M.vword()
  end
end

function M.insert_pword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_pword()
  elseif is_grep_command(cmd) then
    return M.grep_pword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_pword()
  else
    return M.shell_pword()
  end
end

return M

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

function M.CCword()
  return "\\b" .. vim.fn.expand("<cword>") .. "\\b"
end

function M.Cword()
  return vim.fn.expand("<cword>")
end

function M.Word()
  return vim.fn.expand("<cWORD>")
end

function M.Vword()
  local reg_save = vim.fn.getreg('"')
  local regtype_save = vim.fn.getregtype('"')
  vim.cmd("normal! gvy")
  local selection = vim.fn.getreg('"')
  vim.fn.setreg('"', reg_save, regtype_save)
  return selection == "\n" and "" or selection
end

function M.Pword()
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

function M.grep_CCword()
  return grep_escape(M.CCword())
end

function M.grep_Cword()
  return grep_escape(M.Cword())
end

function M.grep_Word()
  return grep_escape(M.Word())
end

function M.grep_Vword()
  return grep_escape(M.Vword())
end

function M.grep_Pword()
  return grep_escape(M.Pword())
end

-- substitute

function M.substitute_escape(text)
  return substitute_escape(text)
end

function M.substitute_CCword()
  return "\\<" .. M.Cword() .. "\\>"
end

function M.substitute_Cword()
  return M.Cword()
end

function M.substitute_Word()
  return substitute_escape(M.Word())
end

function M.substitute_Vword(whole_word)
  local t = substitute_escape(M.Vword())
  return whole_word and ("\\<" .. t .. "\\>") or t
end

function M.substitute_Pword()
  return substitute_escape(M.Pword())
end

-- shell

function M.shell_escape(text)
  return shell_escape(text)
end

function M.shell_CCword()
  return vim.fn.shellescape(M.CCword())
end

function M.shell_Cword()
  return vim.fn.shellescape(M.Cword())
end

function M.shell_Word()
  return shell_escape(M.Word())
end

function M.shell_Vword()
  return shell_escape(vim.fn.trim(M.Vword()))
end

function M.shell_Pword()
  return shell_escape(vim.fn.trim(M.Pword()))
end

-- leaderf
-- LeaderF uses its own regex engine; escape chars include '"' in addition to
-- the shell set. CCword and Cword are passed as plain shellescape (no regex
-- boundaries) because LeaderF handles word matching internally.

function M.leaderf_escape(text)
  return leaderf_escape(text)
end

function M.leaderf_CCword()
  return vim.fn.shellescape(M.CCword())
end

function M.leaderf_Cword()
  return vim.fn.shellescape(M.Cword())
end

function M.leaderf_Word()
  return leaderf_escape(M.Word())
end

function M.leaderf_Vword()
  return leaderf_escape(trim(M.Vword()))
end

function M.leaderf_Pword()
  return leaderf_escape(trim(M.Pword()))
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

local dumb_jump -- lazy-loaded to avoid circular require

local function get_dumb_jump()
  if not dumb_jump then
    dumb_jump = require("zero_grep.dumb_jump")
  end
  return dumb_jump
end

function M.insert_CCword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_CCword()
  elseif is_grepper_git_command(cmd) then
    return get_dumb_jump().git_Cword()
  elseif is_grepper_command(cmd) then
    return get_dumb_jump().rg_Cword()
  elseif is_grep_command(cmd) then
    return M.grep_CCword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_CCword()
  else
    return M.shell_CCword()
  end
end

function M.insert_Cword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_Cword()
  elseif is_grepper_git_command(cmd) then
    return get_dumb_jump().git_Cword()
  elseif is_grepper_command(cmd) then
    return get_dumb_jump().rg_Cword()
  elseif is_grep_command(cmd) then
    return M.grep_CCword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_Cword()
  elseif is_input_command() then
    return M.shell_Cword()
  else
    return M.Cword()
  end
end

function M.insert_Word()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_Word()
  elseif is_grepper_git_command(cmd) or is_grepper_command(cmd) then
    return get_dumb_jump().rg_Cword()
  elseif is_grep_command(cmd) then
    return M.grep_Word()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_Word()
  else
    return M.shell_Word()
  end
end

function M.insert_Vword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_Vword()
  elseif is_grep_command(cmd) then
    return M.grep_Vword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_Vword()
  elseif is_input_command() then
    return M.shell_Vword()
  else
    return M.Vword()
  end
end

function M.insert_Pword()
  local cmd = vim.fn.getcmdline()
  if is_substitute_command(cmd) then
    return M.substitute_Pword()
  elseif is_grep_command(cmd) then
    return M.grep_Pword()
  elseif is_leaderf_command(cmd) then
    return M.leaderf_Pword()
  else
    return M.shell_Pword()
  end
end

return M

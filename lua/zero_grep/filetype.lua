-- lua/zero_grep/filetype.lua - Filetype-aware rg/git grep helpers (Neovim Lua)
-- Maintainer: Phong Nguyen
--
-- Wraps word getters with rg -t / git grep -- glob filetype filtering.
-- Filetype data and opts builders live in require('zero_grep.dumb_jump').

local M = {}

local zg = require("zero_grep")
local dj = require("zero_grep.dumb_jump")

-- ============================================================================
-- Private Helpers
-- ============================================================================

local function rg_opts(keyword, ft)
  local type_opts = dj.rg_filetype_args(ft)
  local pat = vim.fn.shellescape(keyword)
  if type_opts ~= "" then
    return type_opts .. " " .. pat
  end
  return pat
end

local function git_opts(keyword, ft)
  local file_opts = dj.git_filetype_args(ft)
  local pat = vim.fn.shellescape(keyword)
  if file_opts ~= "" then
    return pat .. " " .. file_opts
  end
  return pat
end

-- ============================================================================
-- Public API — rg
-- ============================================================================

function M.rg_CCword(ft)
  return rg_opts(zg.CCword(), ft)
end

function M.rg_Cword(ft)
  return rg_opts(zg.Cword(), ft)
end

function M.rg_Word(ft)
  return rg_opts(zg.Word(), ft)
end

function M.rg_Vword(ft)
  return rg_opts(zg.Vword(), ft)
end

-- ============================================================================
-- Public API — git grep
-- ============================================================================

function M.git_CCword(ft)
  return git_opts(zg.CCword(), ft)
end

function M.git_Cword(ft)
  return git_opts(zg.Cword(), ft)
end

function M.git_Word(ft)
  return git_opts(zg.Word(), ft)
end

function M.git_Vword(ft)
  return git_opts(zg.Vword(), ft)
end

return M

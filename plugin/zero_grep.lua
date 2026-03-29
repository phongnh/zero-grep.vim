-- plugin/zero_grep.lua - Word getter commands and mappings (Neovim Lua)
-- Maintainer: Phong Nguyen

if not vim.fn.has("nvim") or vim.g.loaded_zero_grep then
  return
end
vim.g.loaded_zero_grep = 1

local zero_grep = require("zero_grep")

zero_grep.setup()

-- ============================================================================
-- Commands
-- ============================================================================

-- Raw word getters
vim.api.nvim_create_user_command("ZeroGrepCCword", function()
  print(zero_grep.CCword())
end, {})

vim.api.nvim_create_user_command("ZeroGrepCword", function()
  print(zero_grep.Cword())
end, {})

vim.api.nvim_create_user_command("ZeroGrepWord", function()
  print(zero_grep.Word())
end, {})

vim.api.nvim_create_user_command("ZeroGrepVword", function()
  print(zero_grep.Vword())
end, { range = true })

vim.api.nvim_create_user_command("ZeroGrepPword", function()
  print(zero_grep.Pword())
end, {})

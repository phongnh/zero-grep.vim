-- lua/zero_grep/dumb_jump.lua - Dumb Jump definitions (Neovim Lua)
-- Maintainer: Phong Nguyen
--
-- Language regular expressions ported from:
-- https://github.com/jacktasia/dumb-jump/blob/master/dumb-jump.el

local M = {}

local PLACEHOLDER = "KEYWORD"

-- stylua: ignore
local DEFINITIONS = {
  c = {
    "\\bKEYWORD(\\s|\\))*\\((\\w|[,&*.<>:]|\\s)*(\\))\\s*(const|->|\\{|$)|typedef\\s+(\\w|[(*]|\\s)+KEYWORD(\\)|\\s)*\\(",
    "\\b(?!(class\\b|struct\\b|return\\b|else\\b|delete\\b))(\\w+|[,>])([*&]|\\s)+KEYWORD\\s*(\\[(\\d|\\s)*\\])*\\s*([=,(){;]|:\\s*\\d)|#define\\s+KEYWORD\\b",
    "\\b(class|struct|enum|union)\\b\\s*KEYWORD\\b\\s*(final\\s*)?(:(([\\s*\\w+\\s*::]*\\s*\\w*\\s*<?[\\s*\\w+\\s*::]*\\w+>?\\s*,*)+))?((\\{|$))|\\}\\s*KEYWORD\\b\\s*;",
  },
  cpp = {
    "\\bKEYWORD(\\s|\\))*\\((\\w|[,&*.<>:]|\\s)*(\\))\\s*(const|->|\\{|$)|typedef\\s+(\\w|[(*]|\\s)+KEYWORD(\\)|\\s)*\\(",
    "\\b(?!(class\\b|struct\\b|return\\b|else\\b|delete\\b))(\\w+|[,>])([*&]|\\s)+KEYWORD\\s*(\\[(\\d|\\s)*\\])*\\s*([=,(){;]|:\\s*\\d)|#define\\s+KEYWORD\\b",
    "\\b(class|struct|enum|union)\\b\\s*KEYWORD\\b\\s*(final\\s*)?(:(([\\s*\\w+\\s*::]*\\s*\\w*\\s*<?[\\s*\\w+\\s*::]*\\w+>?\\s*,*)+))?((\\{|$))|\\}\\s*KEYWORD\\b\\s*;",
  },
  python = {
    "\\s*\\bKEYWORD\\b(\\s*:[^=\\n]+)?\\s*=[^=\\n]+",
    "\\s*\\bKEYWORD\\b(\\s*:[^=]+)?\\s*=[^=]+",
    "def\\s*KEYWORD\\b\\s*\\(",
    "class\\s*KEYWORD\\b\\s*\\(?",
  },
  ruby = {
    "^\\s*((\\w+[.])* \\w+,\\s*)*KEYWORD(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)",
    "(^|[^\\w.])((private|public|protected)\\s+)?def\\s+(\\w+(::|[.]))*KEYWORD($|[^\\w|:])",
    "(^|\\W)define(_singleton|_instance)?_method(\\s|[(])\\s*:KEYWORD($|[^\\w|:])",
    "(^|[^\\w.])class\\s+(\\w*::)*KEYWORD($|[^\\w|:])",
    "(^|[^\\w.])module\\s+(\\w*::)*KEYWORD($|[^\\w|:])",
    "(^|\\W)alias(_method)?\\W+KEYWORD(\\W|$)",
  },
  crystal = {
    "^\\s*((\\w+[.])*\\w+,\\s*)*KEYWORD(,\\s*(\\w+[.])*\\w+)*\\s*=([^=>~]|$)",
    "(^|[^\\w.])((private|public|protected)\\s+)?def\\s+(\\w+(::|[.]))*KEYWORD($|[^\\w|:])",
    "(^|[^\\w.])class\\s+(\\w*::)*KEYWORD($|[^\\w|:])",
    "(^|[^\\w.])module\\s+(\\w*::)*KEYWORD($|[^\\w|:])",
    "(^|[^\\w.])struct\\s+(\\w*::)*KEYWORD($|[^\\w|:])",
    "(^|[^\\w.])alias\\s+(\\w*::)*KEYWORD($|[^\\w|:])",
  },
  shell = {
    "function\\s*KEYWORD\\s*",
    "KEYWORD\\(\\)\\s*\\{",
    "\\bKEYWORD\\s*=\\s*",
  },
  sh = {
    "function\\s*KEYWORD\\s*",
    "KEYWORD\\(\\)\\s*\\{",
    "\\bKEYWORD\\s*=\\s*",
  },
  bash = {
    "function\\s*KEYWORD\\s*",
    "KEYWORD\\(\\)\\s*\\{",
    "\\bKEYWORD\\s*=\\s*",
  },
  zsh = {
    "function\\s*KEYWORD\\s*",
    "KEYWORD\\(\\)\\s*\\{",
    "\\bKEYWORD\\s*=\\s*",
  },
  dart = {
    "\\bKEYWORD\\s*\\([^()]*\\)\\s*[{]",
    "class\\s*KEYWORD\\s*[\\(\\{]",
  },
  fennel = {
    "\\((local|var)\\s+KEYWORD($|[^a-zA-Z0-9\\?\\*-])",
    "\\(fn\\s+KEYWORD($|[^a-zA-Z0-9\\?\\*-])",
    "\\(macro\\s+KEYWORD($|[^a-zA-Z0-9\\?\\*-])",
  },
  go = {
    "\\s*\\bKEYWORD\\s*=[^=\\n]+",
    "\\s*\\bKEYWORD\\s*:=\\s*",
    "func\\s+\\([^\\)]*\\)\\s+KEYWORD\\s*\\(",
    "func\\s+KEYWORD\\s*\\(",
    "type\\s+KEYWORD\\s+struct\\s+\\{",
  },
  javascript = {
    "(service|factory)\\(['\"]KEYWORD['\"]",
    "\\bKEYWORD\\s*[=:]\\s*\\([^\\)]*\\)\\s+=>",
    "\\bKEYWORD\\s*\\([^()]*\\)\\s*[{]",
    "class\\s*KEYWORD\\s*[\\(\\{]",
    "class\\s*KEYWORD\\s+extends",
    "\\s*\\bKEYWORD\\s*=[^=\\n]+",
    "\\bfunction\\b[^\\(]*\\(\\s*[^\\)]*\\bKEYWORD\\b\\s*,?\\s*\\)?",
    "function\\s*KEYWORD\\s*\\(",
    "\\bKEYWORD\\s*:\\s*function\\s*\\(",
    "\\bKEYWORD\\s*=\\s*function\\s*\\(",
  },
  javascriptreact = {
    "(service|factory)\\(['\"]KEYWORD['\"]",
    "\\bKEYWORD\\s*[=:]\\s*\\([^\\)]*\\)\\s+=>",
    "\\bKEYWORD\\s*\\([^()]*\\)\\s*[{]",
    "class\\s*KEYWORD\\s*[\\(\\{]",
    "class\\s*KEYWORD\\s+extends",
    "\\s*\\bKEYWORD\\s*=[^=\\n]+",
    "\\bfunction\\b[^\\(]*\\(\\s*[^\\)]*\\bKEYWORD\\b\\s*,?\\s*\\)?",
    "function\\s*KEYWORD\\s*\\(",
    "\\bKEYWORD\\s*:\\s*function\\s*\\(",
    "\\bKEYWORD\\s*=\\s*function\\s*\\(",
  },
  typescript = {
    "(service|factory)\\(['\"]KEYWORD['\"]",
    "\\bKEYWORD\\s*[=:]\\s*\\([^\\)]*\\)\\s+=>",
    "\\bKEYWORD\\s*\\([^()]*\\)\\s*[{]",
    "class\\s*KEYWORD(\\s*<[^>]*>)?\\s*[\\(\\{]",
    "class\\s*KEYWORD(\\s*<[^>]*>)?\\s+extends",
    "(export\\s+)?interface\\s+KEYWORD\\b",
    "(export\\s+)?type\\s+KEYWORD\\b",
    "(export\\s+)?enum\\s+KEYWORD\\b",
    "(declare\\s+)?namespace\\s+KEYWORD\\b",
    "(export\\s+)?module\\s+KEYWORD\\b",
    "function\\s*KEYWORD\\s*\\(",
    "\\bKEYWORD\\s*:\\s*function\\s*\\(",
    "\\bKEYWORD\\s*=\\s*function\\s*\\(",
    "\\s*\\bKEYWORD\\s*=[^=\\n]+",
    "\\bfunction\\b[^\\(]*\\(\\s*[^\\)]*\\bKEYWORD\\b\\s*,?\\s*\\)?",
  },
  typescriptreact = {
    "(service|factory)\\(['\"]KEYWORD['\"]",
    "\\bKEYWORD\\s*[=:]\\s*\\([^\\)]*\\)\\s+=>",
    "\\bKEYWORD\\s*\\([^()]*\\)\\s*[{]",
    "class\\s*KEYWORD(\\s*<[^>]*>)?\\s*[\\(\\{]",
    "class\\s*KEYWORD(\\s*<[^>]*>)?\\s+extends",
    "(export\\s+)?interface\\s+KEYWORD\\b",
    "(export\\s+)?type\\s+KEYWORD\\b",
    "(export\\s+)?enum\\s+KEYWORD\\b",
    "(declare\\s+)?namespace\\s+KEYWORD\\b",
    "(export\\s+)?module\\s+KEYWORD\\b",
    "function\\s*KEYWORD\\s*\\(",
    "\\bKEYWORD\\s*:\\s*function\\s*\\(",
    "\\bKEYWORD\\s*=\\s*function\\s*\\(",
    "\\s*\\bKEYWORD\\s*=[^=\\n]+",
    "\\bfunction\\b[^\\(]*\\(\\s*[^\\)]*\\bKEYWORD\\b\\s*,?\\s*\\)?",
  },
  hcl = {
    "(variable|output|module)\\s*\"KEYWORD\"\\s*\\{",
    "(data|resource)\\s*\"\\w+\"\\s*\"KEYWORD\"\\s*\\{",
  },
  lua = {
    "\\s*\\bKEYWORD\\s*=[^=\\n]+",
    "\\bfunction\\b[^\\(]*\\(\\s*[^\\)]*\\bKEYWORD\\b\\s*,?\\s*\\)?",
    "function\\s*KEYWORD\\s*\\(",
    "function\\s*.+[.:]KEYWORD\\s*\\(",
    "\\bKEYWORD\\s*=\\s*function\\s*\\(",
    "\\b.+\\.KEYWORD\\s*=\\s*function\\s*\\(",
  },
  rust = {
    "\\blet\\s+(\\([^=\\n]*)?(mut\\s+)?KEYWORD([^=\\n]*\\))?(:\\s*[^=\\n]+)?\\s*=\\s*[^=\\n]+",
    "\\bconst\\s+KEYWORD:\\s*[^=\\n]+\\s*=[^=\\n]+",
    "\\bstatic\\s+(mut\\s+)?KEYWORD:\\s*[^=\\n]+\\s*=[^=\\n]+",
    "\\bfn\\s+.+\\s*\\((.+,\\s+)?KEYWORD:\\s*[^=\\n]+\\s*(,\\s*.+)*\\)",
    "(if|while)\\s+let\\s+([^=\\n]+)?(mut\\s+)?KEYWORD([^=\\n\\(]+)?\\s*=\\s*[^=\\n]+",
    "struct\\s+[^\\n{]+[{][^}]*(\\s*KEYWORD\\s*:\\s*[^\\n},]+)[^}]*}",
    "enum\\s+[^\\n{]+\\s*[{][^}]*\\bKEYWORD\\b[^}]*}",
    "\\bfn\\s+KEYWORD\\s*\\(",
    "\\bmacro_rules!\\s+KEYWORD",
    "struct\\s+KEYWORD\\s*[{\\(]?",
    "trait\\s+KEYWORD\\s*[{]?",
    "\\btype\\s+KEYWORD([^=\\n]+)?\\s*=[^=\\n]+;",
    "impl\\s+((\\w+::)*\\w+\\s+for\\s+)?(\\w+::)*KEYWORD\\s+[{]?",
    "mod\\s+KEYWORD\\s*[{]?",
    "\\benum\\s+KEYWORD\\b\\s*[{]?",
  },
  elixir = {
    "\\bdef(p)?\\s+KEYWORD\\s*[ ,\\(]",
    "\\s*KEYWORD\\s*=[^=\\n]+",
    "defmodule\\s+(\\w+\\.)*KEYWORD\\s+",
    "defprotocol\\s+(\\w+\\.)*KEYWORD\\s+",
  },
  erlang = {
    "^KEYWORD\\b\\s*\\(",
    "\\s*KEYWORD\\s*=[^:=\\n]+",
    "^-module\\(KEYWORD\\)",
  },
  sql = {
    "(CREATE|create)\\s+(.+?\\s+)?(FUNCTION|function|PROCEDURE|procedure)\\s+KEYWORD\\s*\\(",
    "(CREATE|create)\\s+(.+?\\s+)?(TABLE|table)(\\s+(IF NOT EXISTS|if not exists))?\\s+KEYWORD\\b",
    "(CREATE|create)\\s+(.+?\\s+)?(VIEW|view)\\s+KEYWORD\\b",
    "(CREATE|create)\\s+(.+?\\s+)?(TYPE|type)\\s+KEYWORD\\b",
  },
  zig = {
    "fn\\s+KEYWORD\\b",
    "(var|const)\\s+KEYWORD\\b",
  },
  protobuf = {
    "message\\s+KEYWORD\\s*\\{",
    "enum\\s+KEYWORD\\s*\\{",
  },
}

-- stylua: ignore
local RG_FILETYPES = {
  c        = { "*.[chH]", "*.[chH].in", "*.cats" },
  cpp      = { "*.[ChH]", "*.[ChH].in", "*.[ch]pp", "*.[ch]pp.in", "*.[ch]xx", "*.[ch]xx.in", "*.cc", "*.cc.in", "*.hh", "*.hh.in", "*.inl" },
  crystal  = { "*.cr", "*.ecr", "Projectfile", "shard.yml" },
  css      = { "*.css", "*.scss" },
  dart     = { "*.dart" },
  elixir   = { "*.eex", "*.ex", "*.exs", "*.heex", "*.leex", "*.livemd" },
  erlang   = { "*.erl", "*.hrl" },
  fennel   = { "*.fnl" },
  go       = { "*.go" },
  hcl      = { "*.hcl", "*.tf", "*.tfvars" },
  html     = { "*.ejs", "*.htm", "*.html" },
  js       = { "*.cjs", "*.js", "*.jsx", "*.mjs", "*.vue" },
  json     = { "*.json", "*.sarif", "composer.lock" },
  lua      = { "*.lua" },
  make     = { "*.mak", "*.mk", "Makefile.*", "[Mm]akefile", "[Mm]akefile.am", "[Mm]akefile.in" },
  markdown = { "*.markdown", "*.md", "*.mdown", "*.mdwn", "*.mdx", "*.mkd", "*.mkdn" },
  protobuf = { "*.proto" },
  py       = { "*.py", "*.pyi" },
  ruby     = { "*.gemspec", "*.rake", "*.rb", "*.rbw", ".irbrc", "Gemfile", "Rakefile", "config.ru" },
  rust     = { "*.rs" },
  sh       = { "*.bash", "*.bashrc", "*.env", "*.ksh", "*.sh", "*.zsh", ".bashrc", ".profile", ".zshrc" },
  sql      = { "*.psql", "*.sql" },
  tf       = { "*.terraform.lock.hcl", "*.tf", "*.tfvars" },
  toml     = { "*.toml", "Cargo.lock" },
  ts       = { "*.cts", "*.mts", "*.ts", "*.tsx" },
  vim      = { "*.vim", ".vimrc", "vimrc" },
  xml      = { "*.dtd", "*.rng", "*.xhtml", "*.xml", "*.xsd", "*.xsl", "*.xslt" },
  yaml     = { "*.yaml", "*.yml" },
  zig      = { "*.zig" },
}

local RG_FILETYPE_MAP = {
  javascript = "js",
  javascriptreact = "js",
  typescript = "ts",
  typescriptreact = "ts",
  python = "py",
  sh = "sh",
  bash = "sh",
  zsh = "sh",
}

-- ============================================================================
-- Private Helpers
-- ============================================================================

local function get_filetype(ft)
  if ft and ft ~= "" then
    return ft
  end
  local vft = vim.bo.filetype
  return vft ~= "" and vft or vim.bo.buftype
end

local function get_regexes(ft)
  local filetype = get_filetype(ft)
  return DEFINITIONS[filetype] or {}
end

local function build_pattern(keyword, ft)
  local patterns = {}
  for _, regex in ipairs(get_regexes(ft)) do
    local pat = regex:gsub(PLACEHOLDER, keyword)
    table.insert(patterns, "(" .. pat .. ")")
  end
  if #patterns > 0 then
    return '"(' .. table.concat(patterns, "|") .. ')"'
  end
  return vim.fn.shellescape("\\b" .. keyword .. "\\b")
end

local function build_pattern_args(keyword, ft)
  local args = {}
  for _, regex in ipairs(get_regexes(ft)) do
    local pat = regex:gsub(PLACEHOLDER, keyword)
    table.insert(args, "-e " .. vim.fn.shellescape(pat))
  end
  if #args > 0 then
    return table.concat(args, " ")
  end
  return string.format("'\\b%s\\b'", keyword)
end

local function rg_filetype_opts(ft)
  local filetype = get_filetype(ft)
  filetype = RG_FILETYPE_MAP[filetype] or filetype
  local opts = {}
  if filetype ~= "" and RG_FILETYPES[filetype] then
    table.insert(opts, "-t " .. filetype)
  else
    local ext = vim.fn.expand("%:e")
    if ext ~= "" then
      table.insert(opts, "-g " .. vim.fn.shellescape(string.format("*.{%s}", ext)))
    end
  end
  return opts
end

local function git_filetype_opts(ft)
  local filetype = get_filetype(ft)
  filetype = RG_FILETYPE_MAP[filetype] or filetype
  local opts = {}
  if filetype ~= "" and RG_FILETYPES[filetype] then
    table.insert(opts, "--")
    for _, glob in ipairs(RG_FILETYPES[filetype]) do
      table.insert(opts, vim.fn.shellescape(glob))
    end
  else
    local ext = vim.fn.expand("%:e")
    if ext ~= "" then
      table.insert(opts, "--")
      table.insert(opts, vim.fn.shellescape(string.format("*.{%s}", ext)))
    end
  end
  return opts
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Returns the compiled dumb-jump PCRE pattern for <cword>.
--- Format: "(pat1|pat2|...)" ready to pass to rg -P / git grep -P
function M.Cword(ft)
  return build_pattern(vim.fn.expand("<cword>"), ft)
end

--- Returns multiple -e args for grep -E (no PCRE required)
function M.CwordArgs(ft)
  return build_pattern_args(vim.fn.expand("<cword>"), ft)
end

--- rg: -s -t <type> "(patterns)"
function M.rg_Cword(ft)
  local type_opts = table.concat(rg_filetype_opts(ft), " ")
  local pattern = M.Cword(ft)
  if type_opts ~= "" then
    return "-s " .. type_opts .. " " .. pattern
  end
  return "-s " .. pattern
end

--- git grep: "(patterns)" -- '*.ext' ...
function M.git_Cword(ft)
  local file_opts = table.concat(git_filetype_opts(ft), " ")
  local pattern = M.Cword(ft)
  if file_opts ~= "" then
    return pattern .. " " .. file_opts
  end
  return pattern
end

function M.rg_filetype_args(ft)
  return table.concat(rg_filetype_opts(ft), " ")
end

function M.git_filetype_args(ft)
  return table.concat(git_filetype_opts(ft), " ")
end

return M

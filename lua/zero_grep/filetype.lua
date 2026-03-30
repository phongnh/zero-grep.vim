-- lua/zero_grep/filetype.lua - Filetype-aware rg/git grep helpers (Neovim Lua)
-- Maintainer: Phong Nguyen
--
-- Fieltype args builder with rg -t / git grep -- glob filetype filtering.

local M = {}

-- rg --type-list
-- stylua: ignore start
local RG_FILETYPES = {
    c             = { '*.[chH]', '*.[chH].in', '*.cats' },
    cmake         = { '*.cmake', 'CMakeLists.txt' },
    config        = { '*.cfg', '*.conf', '*.config', '*.ini' },
    cpp           = { '*.[ChH]', '*.[ChH].in', '*.[ch]pp', '*.[ch]pp.in', '*.[ch]xx', '*.[ch]xx.in', '*.cc', '*.cc.in', '*.hh', '*.hh.in', '*.inl' },
    crystal       = { '*.cr', '*.ecr', 'Projectfile', 'shard.yml' },
    css           = { '*.css', '*.scss' },
    csv           = { '*.csv' },
    dart          = { '*.dart' },
    diff          = { '*.diff', '*.patch' },
    docker        = { '*Dockerfile*' },
    dockercompose = { 'docker-compose.*.yml', 'docker-compose.yml' },
    elixir        = { '*.eex', '*.ex', '*.exs', '*.heex', '*.leex', '*.livemd' },
    elm           = { '*.elm' },
    erb           = { '*.erb' },
    erlang        = { '*.erl', '*.hrl' },
    fennel        = { '*.fnl' },
    fish          = { '*.fish' },
    go            = { '*.go' },
    graphql       = { '*.graphql', '*.graphqls' },
    groovy        = { '*.gradle', '*.groovy' },
    h             = { '*.h', '*.hh', '*.hpp' },
    haml          = { '*.haml' },
    html          = { '*.ejs', '*.htm', '*.html' },
    js            = { '*.cjs', '*.js', '*.jsx', '*.mjs', '*.vue' },
    json          = { '*.json', '*.sarif', 'composer.lock' },
    jsonl         = { '*.jsonl' },
    jupyter       = { '*.ipynb', '*.jpynb' },
    log           = { '*.log' },
    lua           = { '*.lua' },
    make          = { '*.mak', '*.mk', 'Makefile.*', '[Gg][Nn][Uu]makefile', '[Gg][Nn][Uu]makefile.am', '[Gg][Nn][Uu]makefile.in', '[Mm]akefile', '[Mm]akefile.am', '[Mm]akefile.in' },
    man           = { '*.[0-9][cEFMmpSx]', '*.[0-9lnpx]' },
    markdown      = { '*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn' },
    md            = { '*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn' },
    pod           = { '*.pod' },
    protobuf      = { '*.proto' },
    py            = { '*.py', '*.pyi' },
    python        = { '*.py', '*.pyi' },
    rdoc          = { '*.rdoc' },
    readme        = { '*README', 'README*' },
    ruby          = { '*.gemspec', '*.rake', '*.rb', '*.rbw', '.irbrc', 'Gemfile', 'Rakefile', 'config.ru' },
    rust          = { '*.rs' },
    sass          = { '*.sass', '*.scss' },
    sh            = { '*.bash', '*.bashrc', '*.csh', '*.cshrc', '*.env', '*.ksh', '*.kshrc', '*.sh', '*.tcsh', '*.zsh', '.bash_login', '.bash_logout', '.bash_profile', '.bashrc', '.cshrc', '.env', '.kshrc', '.login', '.logout', '.profile', '.tcshrc', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc', 'bash_login', 'bash_logout', 'bash_profile', 'bashrc', 'profile', 'zlogin', 'zlogout', 'zprofile', 'zshenv', 'zshrc' },
    slim          = { '*.skim', '*.slim', '*.slime' },
    sql           = { '*.psql', '*.sql' },
    svelte        = { '*.svelte', '*.svelte.ts' },
    svg           = { '*.svg' },
    tf            = { '*.terraform.lock.hcl', '*.terraformrc', '*.tf', '*.tf.json', '*.tfrc', '*.tfvars', '*.tfvars.json', 'terraform.rc' },
    toml          = { '*.toml', 'Cargo.lock' },
    ts            = { '*.cts', '*.mts', '*.ts', '*.tsx' },
    txt           = { '*.txt' },
    typescript    = { '*.cts', '*.mts', '*.ts', '*.tsx' },
    v             = { '*.v', '*.vsh' },
    vim           = { '*.vim', '.gvimrc', '.vimrc', '_gvimrc', '_vimrc', 'gvimrc', 'vimrc' },
    vimscript     = { '*.vim', '.gvimrc', '.vimrc', '_gvimrc', '_vimrc', 'gvimrc', 'vimrc' },
    vue           = { '*.vue' },
    xml           = { '*.dtd', '*.rng', '*.sch', '*.xhtml', '*.xjb', '*.xml', '*.xml.dist', '*.xsd', '*.xsl', '*.xslt' },
    yacc          = { '*.y' },
    yaml          = { '*.yaml', '*.yml' },
    zig           = { '*.zig' },
    zsh           = { '*.zsh', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc', 'zlogin', 'zlogout', 'zprofile', 'zshenv', 'zshrc' },
}

local RG_FILETYPE_MAP = {
    python          = 'py',
    javascript      = 'js',
    javascriptreact = 'js',
    typescript      = 'ts',
    typescriptreact = 'ts',
}
-- stylua: ignore end

-- ============================================================================
-- Private Helpers
-- ============================================================================

local function get_filetype(ft)
  if ft and ft ~= "" then
    return ft
  end
  local filetype = vim.bo.filetype
  filetype = filetype ~= "" and filetype or vim.bo.buftype
  return RG_FILETYPE_MAP[filetype] or filetype
end

local function detect_grep_tool(tool)
  if tool == "git" or vim.fn.stridx(vim.fn.getcmdprompt(), "git") == 0 or vim.fn.stridx(vim.o.grepprg, "git") == 0 then
    return "git"
  end
  return "rg"
end

-- ============================================================================
-- Public API
-- ============================================================================

function M.rg_filetype_args(ft)
  local filetype = get_filetype(ft)
  local args = {}
  if filetype ~= "" and RG_FILETYPES[filetype] then
    table.insert(args, "-t " .. filetype)
  else
    local ext = vim.fn.expand("%:e")
    if ext ~= "" then
      table.insert(args, "-g " .. vim.fn.shellescape(string.format("*.{%s}", ext)))
    end
  end
  return args
end

function M.git_filetype_args(ft)
  local filetype = get_filetype(ft)
  local args = {}
  if filetype ~= "" and RG_FILETYPES[filetype] then
    table.insert(args, "--")
    for _, glob in ipairs(RG_FILETYPES[filetype]) do
      table.insert(args, vim.fn.shellescape(glob))
    end
  else
    local ext = vim.fn.expand("%:e")
    if ext ~= "" then
      table.insert(args, "--")
      table.insert(args, vim.fn.shellescape(string.format("*.{%s}", ext)))
    end
  end
  return args
end

function M.args(tool, ft)
  tool = tool or ""
  ft = ft or ""
  if detect_grep_tool(tool) == "git" then
    return table.concat(M.git_filetype_args(ft), " ")
  else
    return table.concat(M.rg_filetype_args(ft), " ")
  end
end

return M

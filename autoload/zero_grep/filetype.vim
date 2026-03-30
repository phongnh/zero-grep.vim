vim9script

# autoload/zero_grep/filetype.vim - Filetype-aware rg/git grep helpers (Vim9script)
# Maintainer: Phong Nguyen
#
# Fieltype args builder with rg -t / git grep -- glob filetype filtering.

# rg --type-list
const RG_FILETYPES: dict<list<string>> = {
    'c':             ['*.[chH]', '*.[chH].in', '*.cats'],
    'cmake':         ['*.cmake', 'CMakeLists.txt'],
    'config':        ['*.cfg', '*.conf', '*.config', '*.ini'],
    'cpp':           ['*.[ChH]', '*.[ChH].in', '*.[ch]pp', '*.[ch]pp.in', '*.[ch]xx', '*.[ch]xx.in', '*.cc', '*.cc.in', '*.hh', '*.hh.in', '*.inl'],
    'crystal':       ['*.cr', '*.ecr', 'Projectfile', 'shard.yml'],
    'css':           ['*.css', '*.scss'],
    'csv':           ['*.csv'],
    'dart':          ['*.dart'],
    'diff':          ['*.diff', '*.patch'],
    'docker':        ['*Dockerfile*'],
    'dockercompose': ['docker-compose.*.yml', 'docker-compose.yml'],
    'elixir':        ['*.eex', '*.ex', '*.exs', '*.heex', '*.leex', '*.livemd'],
    'elm':           ['*.elm'],
    'erb':           ['*.erb'],
    'erlang':        ['*.erl', '*.hrl'],
    'fennel':        ['*.fnl'],
    'fish':          ['*.fish'],
    'go':            ['*.go'],
    'graphql':       ['*.graphql', '*.graphqls'],
    'groovy':        ['*.gradle', '*.groovy'],
    'h':             ['*.h', '*.hh', '*.hpp'],
    'haml':          ['*.haml'],
    'html':          ['*.ejs', '*.htm', '*.html'],
    'js':            ['*.cjs', '*.js', '*.jsx', '*.mjs', '*.vue'],
    'json':          ['*.json', '*.sarif', 'composer.lock'],
    'jsonl':         ['*.jsonl'],
    'jupyter':       ['*.ipynb', '*.jpynb'],
    'log':           ['*.log'],
    'lua':           ['*.lua'],
    'make':          ['*.mak', '*.mk', 'Makefile.*', '[Gg][Nn][Uu]makefile', '[Gg][Nn][Uu]makefile.am', '[Gg][Nn][Uu]makefile.in', '[Mm]akefile', '[Mm]akefile.am', '[Mm]akefile.in'],
    'man':           ['*.[0-9][cEFMmpSx]', '*.[0-9lnpx]'],
    'markdown':      ['*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn'],
    'md':            ['*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn'],
    'pod':           ['*.pod'],
    'protobuf':      ['*.proto'],
    'py':            ['*.py', '*.pyi'],
    'python':        ['*.py', '*.pyi'],
    'rdoc':          ['*.rdoc'],
    'readme':        ['*README', 'README*'],
    'ruby':          ['*.gemspec', '*.rake', '*.rb', '*.rbw', '.irbrc', 'Gemfile', 'Rakefile', 'config.ru'],
    'rust':          ['*.rs'],
    'sass':          ['*.sass', '*.scss'],
    'sh':            ['*.bash', '*.bashrc', '*.csh', '*.cshrc', '*.env', '*.ksh', '*.kshrc', '*.sh', '*.tcsh', '*.zsh', '.bash_login', '.bash_logout', '.bash_profile', '.bashrc', '.cshrc', '.env', '.kshrc', '.login', '.logout', '.profile', '.tcshrc', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc', 'bash_login', 'bash_logout', 'bash_profile', 'bashrc', 'profile', 'zlogin', 'zlogout', 'zprofile', 'zshenv', 'zshrc'],
    'slim':          ['*.skim', '*.slim', '*.slime'],
    'sql':           ['*.psql', '*.sql'],
    'svelte':        ['*.svelte', '*.svelte.ts'],
    'svg':           ['*.svg'],
    'tf':            ['*.terraform.lock.hcl', '*.terraformrc', '*.tf', '*.tf.json', '*.tfrc', '*.tfvars', '*.tfvars.json', 'terraform.rc'],
    'toml':          ['*.toml', 'Cargo.lock'],
    'ts':            ['*.cts', '*.mts', '*.ts', '*.tsx'],
    'txt':           ['*.txt'],
    'typescript':    ['*.cts', '*.mts', '*.ts', '*.tsx'],
    'v':             ['*.v', '*.vsh'],
    'vim':           ['*.vim', '.gvimrc', '.vimrc', '_gvimrc', '_vimrc', 'gvimrc', 'vimrc'],
    'vimscript':     ['*.vim', '.gvimrc', '.vimrc', '_gvimrc', '_vimrc', 'gvimrc', 'vimrc'],
    'vue':           ['*.vue'],
    'xml':           ['*.dtd', '*.rng', '*.sch', '*.xhtml', '*.xjb', '*.xml', '*.xml.dist', '*.xsd', '*.xsl', '*.xslt'],
    'yacc':          ['*.y'],
    'yaml':          ['*.yaml', '*.yml'],
    'zig':           ['*.zig'],
    'zsh':           ['*.zsh', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc', 'zlogin', 'zlogout', 'zprofile', 'zshenv', 'zshrc'],
}

# Map vim filetype to rg filetype
# - key: vim filetype 
# - value: rg filetype
const RG_FILETYPE_MAP: dict<string> = {
    'python':          'py',
    'javascript':      'js',
    'javascriptreact': 'js',
    'typescript':      'ts',
    'typescriptreact': 'ts',
}

export def RgFileTypeArgs(ft: string = ''): list<string>
    var filetype = empty(ft) ? (&filetype !=# '' ? &filetype : &buftype) : ft
    filetype = get(RG_FILETYPE_MAP, filetype, filetype)
    var args: list<string> = []
    if !empty(filetype) && has_key(RG_FILETYPES, filetype)
        args->add('-t ' .. filetype)
    else
        const ext = expand('%:e')
        if !empty(ext)
            args->add('-g ' .. shellescape(printf('*.{%s}', ext)))
        endif
    endif
    return args
enddef

export def GitFileTypeArgs(ft: string = ''): list<string>
    var filetype = empty(ft) ? (&filetype !=# '' ? &filetype : &buftype) : ft
    filetype = get(RG_FILETYPE_MAP, filetype, filetype)
    var args: list<string> = []
    if !empty(filetype) && has_key(RG_FILETYPES, filetype)
        args->add('--')
        for glob in RG_FILETYPES[filetype]
            args->add(shellescape(glob))
        endfor
    else
        const ext = expand('%:e')
        if !empty(ext)
            args->add('--')
            args->add(shellescape(printf('*.{%s}', ext)))
        endif
    endif
    return args
enddef

def DetectGrepTool(tool: string = ''): string
    if tool ==# 'git' || stridx(getcmdprompt(), 'git') == 0 || stridx(&grepprg, 'git') == 0
        return 'git'
    endif
    return 'rg'
enddef

export def Args(tool: string = '', ft: string = ''): string
    if DetectGrepTool(tool) ==# 'git'
        return join(GitFileTypeArgs(ft), ' ')
    else
        return join(RgFileTypeArgs(ft), ' ')
    endif
enddef

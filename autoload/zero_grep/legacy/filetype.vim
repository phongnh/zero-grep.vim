" autoload/zero_grep/filetype.vim - Filetype-aware rg/git grep helpers (Legacy Vim)
" Maintainer: Phong Nguyen
"
" Fieltype opts builder with rg -t / git grep -- glob filetype filtering.

" rg --type-list
let s:rg_filetypes = {
            \ 'c': ['*.[chH]', '*.[chH].in', '*.cats'],
            \ 'cmake': ['*.cmake', 'CMakeLists.txt'],
            \ 'config': ['*.cfg', '*.conf', '*.config', '*.ini'],
            \ 'cpp': ['*.[ChH]', '*.[ChH].in', '*.[ch]pp', '*.[ch]pp.in', '*.[ch]xx', '*.[ch]xx.in', '*.cc', '*.cc.in', '*.hh', '*.hh.in', '*.inl'],
            \ 'crystal': ['*.cr', '*.ecr', 'Projectfile', 'shard.yml'],
            \ 'css': ['*.css', '*.scss'],
            \ 'csv': ['*.csv'],
            \ 'dart': ['*.dart'],
            \ 'diff': ['*.diff', '*.patch'],
            \ 'docker': ['*Dockerfile*'],
            \ 'dockercompose': ['docker-compose.*.yml', 'docker-compose.yml'],
            \ 'elixir': ['*.eex', '*.ex', '*.exs', '*.heex', '*.leex', '*.livemd'],
            \ 'elm': ['*.elm'],
            \ 'erb': ['*.erb'],
            \ 'erlang': ['*.erl', '*.hrl'],
            \ 'fennel': ['*.fnl'],
            \ 'fish': ['*.fish'],
            \ 'go': ['*.go'],
            \ 'graphql': ['*.graphql', '*.graphqls'],
            \ 'groovy': ['*.gradle', '*.groovy'],
            \ 'h': ['*.h', '*.hh', '*.hpp'],
            \ 'haml': ['*.haml'],
            \ 'html': ['*.ejs', '*.htm', '*.html'],
            \ 'js': ['*.cjs', '*.js', '*.jsx', '*.mjs', '*.vue'],
            \ 'json': ['*.json', '*.sarif', 'composer.lock'],
            \ 'jsonl': ['*.jsonl'],
            \ 'jupyter': ['*.ipynb', '*.jpynb'],
            \ 'log': ['*.log'],
            \ 'lua': ['*.lua'],
            \ 'make': ['*.mak', '*.mk', 'Makefile.*', '[Gg][Nn][Uu]makefile', '[Gg][Nn][Uu]makefile.am', '[Gg][Nn][Uu]makefile.in', '[Mm]akefile', '[Mm]akefile.am', '[Mm]akefile.in'],
            \ 'man': ['*.[0-9][cEFMmpSx]', '*.[0-9lnpx]'],
            \ 'markdown': ['*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn'],
            \ 'md': ['*.markdown', '*.md', '*.mdown', '*.mdwn', '*.mdx', '*.mkd', '*.mkdn'],
            \ 'pod': ['*.pod'],
            \ 'protobuf': ['*.proto'],
            \ 'py': ['*.py', '*.pyi'],
            \ 'python': ['*.py', '*.pyi'],
            \ 'rdoc': ['*.rdoc'],
            \ 'readme': ['*README', 'README*'],
            \ 'ruby': ['*.gemspec', '*.rake', '*.rb', '*.rbw', '.irbrc', 'Gemfile', 'Rakefile', 'config.ru'],
            \ 'rust': ['*.rs'],
            \ 'sass': ['*.sass', '*.scss'],
            \ 'sh': ['*.bash', '*.bashrc', '*.csh', '*.cshrc', '*.env', '*.ksh', '*.kshrc', '*.sh', '*.tcsh', '*.zsh', '.bash_login', '.bash_logout', '.bash_profile', '.bashrc', '.cshrc', '.env', '.kshrc', '.login', '.logout', '.profile', '.tcshrc', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc', 'bash_login', 'bash_logout', 'bash_profile', 'bashrc', 'profile', 'zlogin', 'zlogout', 'zprofile', 'zshenv', 'zshrc'],
            \ 'slim': ['*.skim', '*.slim', '*.slime'],
            \ 'sql': ['*.psql', '*.sql'],
            \ 'svelte': ['*.svelte', '*.svelte.ts'],
            \ 'svg': ['*.svg'],
            \ 'tf': ['*.terraform.lock.hcl', '*.terraformrc', '*.tf', '*.tf.json', '*.tfrc', '*.tfvars', '*.tfvars.json', 'terraform.rc'],
            \ 'toml': ['*.toml', 'Cargo.lock'],
            \ 'ts': ['*.cts', '*.mts', '*.ts', '*.tsx'],
            \ 'txt': ['*.txt'],
            \ 'typescript': ['*.cts', '*.mts', '*.ts', '*.tsx'],
            \ 'v': ['*.v', '*.vsh'],
            \ 'vim': ['*.vim', '.gvimrc', '.vimrc', '_gvimrc', '_vimrc', 'gvimrc', 'vimrc'],
            \ 'vimscript': ['*.vim', '.gvimrc', '.vimrc', '_gvimrc', '_vimrc', 'gvimrc', 'vimrc'],
            \ 'vue': ['*.vue'],
            \ 'xml': ['*.dtd', '*.rng', '*.sch', '*.xhtml', '*.xjb', '*.xml', '*.xml.dist', '*.xsd', '*.xsl', '*.xslt'],
            \ 'yacc': ['*.y'],
            \ 'yaml': ['*.yaml', '*.yml'],
            \ 'zig': ['*.zig'],
            \ 'zsh': ['*.zsh', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc', 'zlogin', 'zlogout', 'zprofile', 'zshenv', 'zshrc'],
            \ }

" Map vim filetype to rg filetype
" - key: vim filetype 
" - value: rg filetype
let s:rg_filetype_mappings = {
            \ 'python':          'py',
            \ 'javascript':      'js',
            \ 'javascriptreact': 'js',
            \ 'typescript':      'ts',
            \ 'typescriptreact': 'ts',
            \ }

function! zero_grep#legacy#filetype#RgFileTypeOpts(...) abort
    let l:ft = get(a:, 1, '')
    let l:ft = empty(l:ft) ? (&filetype !=# '' ? &filetype : &buftype) : l:ft
    let l:ft = get(s:rg_filetype_mappings, l:ft, l:ft)
    let l:opts = []
    if !empty(l:ft) && has_key(s:rg_filetypes, l:ft)
        call add(l:opts, '-t ' .. l:ft)
    else
        let l:ext = expand('%:e')
        if !empty(l:ext)
            call add(l:opts, '-g ' .. shellescape(printf('*.{%s}', l:ext)))
        endif
    endif
    return l:opts
endfunction

function! zero_grep#legacy#filetype#GitFileTypeOpts(...) abort
    let l:ft = get(a:, 1, '')
    let l:ft = empty(l:ft) ? (&filetype !=# '' ? &filetype : &buftype) : l:ft
    let l:ft = get(s:rg_filetype_mappings, l:ft, l:ft)
    let l:opts = []
    if !empty(l:ft) && has_key(s:rg_filetypes, l:ft)
        call add(l:opts, '--')
        for l:ext in s:rg_filetypes[l:ft]
            call add(l:opts, shellescape(l:ext))
        endfor
    else
        let l:ext = expand('%:e')
        if !empty(l:ext)
            call add(l:opts, '--')
            call add(l:opts, shellescape(printf('*.{%s}', l:ext)))
        endif
    endif
    return l:opts
endfunction

function! s:detect_tool() abort
    if stridx(getcmdprompt(), 'git') == 0 || stridx(&grepprg, 'git') == 0
        return 'git'
    endif
    return 'rg'
endfunction

function! zero_grep#legacy#filetype#Opts(...) abort
    let l:tool = get(a:, 1, '')
    let l:grepprg = empty(l:tool) ? s:detect_tool() : l:tool
    if l:grepprg ==# 'git'
        return join(zero_grep#legacy#filetype#GitFileTypeOpts(), ' ')
    else
        return join(zero_grep#legacy#filetype#RgFileTypeOpts(), ' ')
    endif
endfunction

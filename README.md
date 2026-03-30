# zero-grep.vim

Context-aware word extraction for Vim / Neovim — provides **CCword**, **Cword**, **Word**, **Vword**, and **Pword** with automatic escaping tuned to the active command context (`:substitute`, `:grep`, shell, Grepper, LeaderF, or Dumb Jump).

## What it provides

| Getter  | Source           | Description                                      |
|---------|------------------|--------------------------------------------------|
| CCword  | `<cword>`        | Word under cursor with `\b...\b` word boundaries |
| Cword   | `<cword>`        | Bare word under cursor                           |
| Word    | `<cWORD>`        | WORD (space-delimited token) under cursor        |
| Vword   | visual selection | Currently selected text                          |
| Pword   | `@/` register    | Last search pattern (normalised to `\b...\b`)    |

Each getter is available in four escape contexts:

| Context      | Escaping                                                          |
|--------------|-------------------------------------------------------------------|
| `grep`       | Regex-escaped + `shellescape()` (for `:grep`, `Ggrep`, …)         |
| `substitute` | Vim substitute-safe (`^$.*\/~[]`), newlines → `\n`                |
| `shell`      | `shellescape()` + minimal regex escape (`\^$.*+?()[]{}|-`)        |
| `leaderf`    | `shellescape()` + LeaderF regex escape (`\^$.*+?()[]{}|-"`)       |

An additional **dumb_jump** module builds language-aware PCRE patterns from the [Dumb Jump](https://github.com/jacktasia/dumb-jump) rule set, used with Grepper/rg and `git grep`.

## Auto-dispatch (`<C-R>=` mappings)

The `Insert*` functions inspect the current command line and return the appropriate flavour automatically:

```vim
" Vim9script / legacy Vimscript
cnoremap <expr> <C-R><C-W>  zero_grep#InsertCCword()
cnoremap <expr> <C-R>w      zero_grep#InsertCword()
cnoremap <expr> <C-R><C-A>  zero_grep#InsertWord()
cnoremap <expr> <C-R>/      zero_grep#InsertPword()
" visual mode
xnoremap <expr> <C-R>v      zero_grep#InsertVword()
```

```lua
-- Neovim Lua
local zg = require('zero_grep')
vim.keymap.set('c', '<C-R><C-W>', zg.insert_ccword, { expr = true })
vim.keymap.set('c', '<C-R>w',     zg.insert_cword,  { expr = true })
vim.keymap.set('c', '<C-R><C-A>', zg.insert_word,   { expr = true })
vim.keymap.set('c', '<C-R>/',     zg.insert_pword,  { expr = true })
vim.keymap.set('x', '<C-R>v',     zg.insert_vword,  { expr = true })
```

### Context detection order

For each `Insert*` function the command line is matched in this priority order:

1. `:s/`, `:substitute/`, `:S/`, `:Subvert/`, `cfdo s/`, etc. → substitute escaping
2. `GrepperGit ` → dumb_jump pattern (used as git grep `-P` argument)
3. `Grepper `, `GrepperRg `, `SGrepper `, etc. → dumb_jump pattern (used as rg `-P` argument)
4. `:grep`, `:Grep`, `:LGrep`, `:BGrep`, `Ggrep`, `Git grep`, etc. → grep escaping
5. `Leaderf `, `LF ` → LeaderF escaping
6. `@` cmdtype (i.e. `input()`) → shell escaping *(Cword / Vword only)*
7. fallback → bare word *(Cword / Vword)* or shell escaping *(CCword / Word / Pword)*

**LeaderF notes:**
- `CCword` and `Cword` use only `shellescape()` (no regex-escape prefix); LeaderF handles word boundaries internally.
- `Word`, `Vword`, and `Pword` use the full LeaderF escape (`escape(text, '\^$.*+?()[]{}|-"')` then `shellescape()`).
- `Vword` and `Pword` are trimmed of surrounding whitespace before escaping.

## Structure

```
plugin/
  zero_grep.vim          ← loaded by Vim (has vim9script, !nvim)
  zero_grep_legacy.vim   ← loaded by legacy Vim (!vim9script, !nvim)
  zero_grep.lua          ← loaded by Neovim
autoload/
  zero_grep.vim          ← Vim9script core + context dispatch
  zero_grep/
    legacy.vim           ← legacy Vimscript core + context dispatch
    dumb_jump.vim        ← Vim9script Dumb Jump patterns
    filetype.vim         ← Vim9script filetype-aware rg/git grep args
    legacy/
      dumb_jump.vim      ← legacy Dumb Jump patterns
      filetype.vim       ← legacy filetype-aware rg/git grep args
lua/
  zero_grep.lua          ← Neovim core + context dispatch
  zero_grep/
    dumb_jump.lua        ← Neovim Dumb Jump patterns
    filetype.lua         ← Neovim filetype-aware rg/git grep args
```

## API reference

### Global VimL functions

All three implementations (Vim9script, legacy, Neovim) expose the same set of global functions:

```vim
g:CCword()           " → '\bword\b'   (Neovim only)
g:Cword()            " → 'word'       (Neovim only)
g:Word()             " → 'WORD'
g:Vword()            " → 'selection'
g:Pword()            " → '\bpattern\b'

g:ShellCCword()      " → shellescape('\bword\b')   (Neovim only)
g:ShellCword()       " → shellescape('word')        (Neovim only)
g:ShellWord()        " → shell-escaped WORD
g:ShellVword()       " → shell-escaped visual selection (trimmed)
g:ShellPword()       " → shell-escaped last pattern (trimmed)

g:DumbJumpCword()          " → dumb-jump PCRE pattern for <cword>
g:DumbJumpCwordArgs()      " → dumb-jump -e args for <cword>
g:FileTypeArgs([tool])     " → filetype filter args for rg or git grep
```

### Raw getters (Vim9script autoload)

```vim
zero_grep#CCword()   " → '\bword\b'
zero_grep#Cword()    " → 'word'
zero_grep#Word()     " → 'WORD'
zero_grep#Vword()    " → 'selection'
zero_grep#Pword()    " → '\bpattern\b'
```

### Contextual escape (Vim9script autoload)

```vim
zero_grep#GrepEscapeText(text)
zero_grep#GrepCCword()          zero_grep#GrepCword()
zero_grep#GrepWord()            zero_grep#GrepVword()
zero_grep#GrepPword()

zero_grep#SubstituteEscapeText(text)
zero_grep#SubstituteCCword()    zero_grep#SubstituteCword()
zero_grep#SubstituteWord()      zero_grep#SubstituteVword([whole_word])
zero_grep#SubstitutePword()

zero_grep#ShellEscapeText(text)
zero_grep#ShellCCword()         zero_grep#ShellCword()
zero_grep#ShellWord()           zero_grep#ShellVword()
zero_grep#ShellPword()

zero_grep#LeaderfEscapeText(text)
zero_grep#LeaderfCCword()       zero_grep#LeaderfCword()
zero_grep#LeaderfWord()         zero_grep#LeaderfVword()
zero_grep#LeaderfPword()
```

### Context-aware insert (Vim9script autoload)

```vim
zero_grep#InsertCCword()
zero_grep#InsertCword()
zero_grep#InsertWord()
zero_grep#InsertVword()
zero_grep#InsertPword()
```

### Dumb Jump (Vim9script autoload)

```vim
zero_grep#dumb_jump#Cword([ft])      " "(pat1|pat2|...)" — PCRE for rg -P / git grep -P
zero_grep#dumb_jump#CwordArgs([ft])  " -e 'pat1' -e 'pat2' ... — extended regex args
```

Falls back to `shellescape('\bword\b')` when no rules exist for the current filetype.

### Filetype args (Vim9script autoload)

Returns `-t <type>` (rg) or `-- '*.ext' ...` (git grep) derived from the current buffer's filetype. Auto-detects the tool from `grepprg` or the command prompt when `tool` is omitted.

```vim
zero_grep#filetype#RgFileTypeArgs([ft])    " → list<string>
zero_grep#filetype#GitFileTypeArgs([ft])   " → list<string>
zero_grep#filetype#Args([tool], [ft])      " → string  (joined, tool auto-detected)
```

Supported filetypes include: c, cpp, crystal, css, dart, elixir, erlang, fennel, go, hcl, javascript, javascriptreact, lua, python, ruby, rust, sh/bash/zsh/shell, sql, typescript, typescriptreact, zig, and more. See `autoload/zero_grep/filetype.vim` for the full list.

### Neovim Lua

```lua
local zg = require('zero_grep')
local dj = require('zero_grep.dumb_jump')
local ft = require('zero_grep.filetype')

-- Raw getters
zg.ccword()   zg.cword()   zg.word()   zg.vword()   zg.pword()

-- Contextual escape
zg.grep_escape(text)
zg.grep_ccword()    zg.grep_cword()    zg.grep_word()
zg.grep_vword()     zg.grep_pword()

zg.substitute_escape(text)
zg.substitute_ccword()    zg.substitute_cword()    zg.substitute_word()
zg.substitute_vword([whole_word])                  zg.substitute_pword()

zg.shell_escape(text)
zg.shell_ccword()    zg.shell_cword()    zg.shell_word()
zg.shell_vword()     zg.shell_pword()

zg.leaderf_escape(text)
zg.leaderf_ccword()    zg.leaderf_cword()    zg.leaderf_word()
zg.leaderf_vword()     zg.leaderf_pword()

-- Context-aware insert (for keymaps)
zg.insert_ccword()   zg.insert_cword()   zg.insert_word()
zg.insert_vword()    zg.insert_pword()

-- Dumb Jump
dj.cword([ft])        -- "(pat1|pat2|...)"
dj.cword_args([ft])   -- "-e 'pat1' -e 'pat2' ..."

-- Filetype args
ft.rg_filetype_args([ft])    -- { "-t lua" }
ft.git_filetype_args([ft])   -- { "--", "'*.lua'" }
ft.args([tool], [ft])        -- "-t lua"  (joined string, tool auto-detected)

-- Convenience wrappers on zg
zg.file_type_args([tool], [ft])   -- delegates to ft.args()
zg.dumb_jump_cword([ft])          -- delegates to dj.cword()
zg.dumb_jump_cword_args([ft])     -- delegates to dj.cword_args()
```

## Requirements

- Vim ≥ 9.0 (Vim9script), or Vim ≥ 8.0 (legacy Vimscript), **or** Neovim ≥ 0.7

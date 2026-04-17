# zero-grep.vim

Context-aware word extraction for Vim / Neovim — provides **CCword**, **Cword**, **Word**, **Vword**, and **Pword** with automatic escaping tuned to the active command context (`:substitute`, `:grep`, shell, Grepper, or LeaderF).

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

## Auto-dispatch (`<C-R>=` mappings)

The `Insert*` functions inspect the current command line and return the appropriate flavour automatically:

```vim
" Vim9script (vim9/autoload/zero_grep.vim) / legacy Vimscript (autoload/zero_grep.vim)
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
2. `:grep`, `:Grep`, `:LGrep`, `:BGrep`, `Ggrep`, `Git grep`, etc. → grep escaping
3. `Leaderf rg`, → LeaderF escaping
4. `@` cmdtype (i.e. `input()`) → shell escaping *(Cword / Vword only)*
5. fallback → bare word *(Cword / Vword)* or shell escaping *(CCword / Word / Pword)*

**LeaderF notes:**
- `CCword` and `Cword` use only `shellescape()` (no regex-escape prefix); LeaderF handles word boundaries internally.
- `Word`, `Vword`, and `Pword` use the full LeaderF escape (`escape(text, '\^$.*+?()[]{}|-"')` then `shellescape()`).
- `Vword` and `Pword` are trimmed of surrounding whitespace before escaping.

## Structure

```
plugin/
  zero_grep.vim          ← Vim entry point (!nvim): sources vim9/plugin/zero_grep.vim
                           when vim9script is available, otherwise loads legacy autoload
  zero_grep.lua          ← Neovim entry point
autoload/                ← legacy Vimscript
  zero_grep.vim          ← legacy core + context dispatch
vim9/                    ← Vim9script
  plugin/
    zero_grep.vim        ← Vim9script plugin entry point
  autoload/
    zero_grep.vim        ← Vim9script core + context dispatch
lua/                     ← Neovim Lua
  zero_grep.lua          ← Neovim core + context dispatch
```

## API reference

### Global VimL functions

All three implementations (Vim9script, legacy, Neovim) expose the same set of global functions:

```vim
g:CCword()           " → '\bword\b'
g:Cword()            " → 'word'
g:Word()             " → 'WORD'
g:Vword()            " → 'selection'
g:Pword()            " → '\bpattern\b'

g:ShellCCword()      " → shellescape('\bword\b')
g:ShellCword()       " → shellescape('word')
g:ShellWord()        " → shell-escaped WORD
g:ShellVword()       " → shell-escaped visual selection (trimmed)
g:ShellPword()       " → shell-escaped last pattern (trimmed)
```

### Raw getters (Vim9script / legacy autoload)

The `zero_grep#` autoload namespace is shared. When Vim9script is available, functions are loaded from `vim9/autoload/zero_grep.vim`; otherwise from `autoload/zero_grep.vim`.

```vim
zero_grep#CCword()   " → '\bword\b'
zero_grep#Cword()    " → 'word'
zero_grep#Word()     " → 'WORD'
zero_grep#Vword()    " → 'selection'
zero_grep#Pword()    " → '\bpattern\b'
```

### Contextual escape (Vim9script / legacy autoload)

The escape-text helper names differ between implementations. All other contextual functions share the same name across both.

| Vim9script (`vim9/autoload/`)      | Legacy (`autoload/`)          |
|------------------------------------|-------------------------------|
| `zero_grep#GrepEscapeText(text)`   | `zero_grep#GrepEscape(text)`  |
| `zero_grep#SubstituteEscapeText(text)` | `zero_grep#SubstituteEscape(text)` |
| `zero_grep#ShellEscapeText(text)`  | `zero_grep#ShellEscape(text)` |
| `zero_grep#LeaderfEscapeText(text)` | `zero_grep#LeaderfEscape(text)` |

The following are identical in both implementations:

```vim
zero_grep#GrepCCword()          zero_grep#GrepCword()
zero_grep#GrepWord()            zero_grep#GrepVword()
zero_grep#GrepPword()

zero_grep#SubstituteCCword()    zero_grep#SubstituteCword()
zero_grep#SubstituteWord()      zero_grep#SubstituteVword([whole_word])
zero_grep#SubstitutePword()

zero_grep#ShellCCword()         zero_grep#ShellCword()
zero_grep#ShellWord()           zero_grep#ShellVword()
zero_grep#ShellPword()

zero_grep#LeaderfCCword()       zero_grep#LeaderfCword()
zero_grep#LeaderfWord()         zero_grep#LeaderfVword()
zero_grep#LeaderfPword()
```

### Context-aware insert (Vim9script / legacy autoload)

```vim
zero_grep#InsertCCword()
zero_grep#InsertCword()
zero_grep#InsertWord()
zero_grep#InsertVword()
zero_grep#InsertPword()
```

### Neovim Lua

```lua
local zg = require('zero_grep')

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
```

## Requirements

- Vim ≥ 9.0 (Vim9script), or Vim ≥ 8.0 (legacy Vimscript), **or** Neovim ≥ 0.7

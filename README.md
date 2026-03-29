# zero-grep.vim

Context-aware word extraction for Vim / Neovim — provides **CCword**, **Cword**, **Word**, **Vword**, and **Pword** with automatic escaping tuned to the active command context (`:substitute`, `:grep`, shell, Grepper, LeaderF, or Dumb Jump).

## What it provides

| Getter  | Source            | Description                                      |
|---------|-------------------|--------------------------------------------------|
| CCword  | `<cword>`         | Word under cursor with `\b...\b` word boundaries |
| Cword   | `<cword>`         | Bare word under cursor                           |
| Word    | `<cWORD>`         | WORD (space-delimited token) under cursor        |
| Vword   | visual selection  | Currently selected text                          |
| Pword   | `@/` register     | Last search pattern (normalised to `\b...\b`)    |

Each getter is available in four escape contexts:

| Context      | Escaping                                                         |
|--------------|------------------------------------------------------------------|
| `grep`       | Regex-escaped + `shellescape()` (for `:grep`, `Ggrep`, …)       |
| `substitute` | Vim substitute-safe (`^$.*\/~[]`), newlines → `\n`               |
| `shell`      | `shellescape()` + minimal regex escape (`\^$.*+?()[]{}|-`)       |
| `leaderf`    | `shellescape()` + LeaderF regex escape (`\^$.*+?()[]{}|-"`)      |

An additional **dumb_jump** module builds language-aware PCRE patterns from the [Dumb Jump](https://github.com/jacktasia/dumb-jump) rule set, used with Grepper/rg and `git grep`.

## Auto-dispatch (`<C-R>=` mappings)

The `Insert*` functions inspect the current command line and return the appropriate flavour automatically:

```vim
" In your vimrc (Vim9script / legacy / Neovim — same API surface)
cnoremap <expr> <C-R><C-W>  zero_grep#InsertCCword()
cnoremap <expr> <C-R>w      zero_grep#InsertCword()
cnoremap <expr> <C-R><C-A>  zero_grep#InsertWord()
" visual mode — insert visual selection context-aware
xnoremap <expr> <C-R>v      zero_grep#InsertVword()
cnoremap <expr> <C-R>/      zero_grep#InsertPword()
```

> For Neovim Lua users replace `zero_grep#InsertCCword()` with
> `require('zero_grep').insert_CCword()` (and so on).

### Context detection order

For each `Insert*` function the command line is matched in this priority order:

1. `:s/`, `:substitute/`, `cfdo s/` → substitute escaping
2. `GrepperGit ` → dumb_jump git pattern
3. `Grepper `, `GrepperRg `, etc. → dumb_jump rg pattern
4. `:grep`, `Ggrep`, `Git grep`, etc. → grep escaping
5. `Leaderf `, `LF ` → LeaderF escaping
6. `@` cmdtype (i.e. `input()`) → shell escaping  *(Cword / Vword only)*
7. fallback → bare word  *(Cword / Vword)* or shell escaping  *(CCword / Word / Pword)*

**LeaderF notes:**
- `CCword` and `Cword` use only `shellescape()` (no regex-escape prefix); LeaderF handles word boundaries internally.
- `Word`, `Vword`, and `Pword` use the full LeaderF escape (`escape(text, '\^$.*+?()[]{}|-"')` then `shellescape()`).
- `Vword` and `Pword` are trimmed of surrounding whitespace before escaping.

## Structure

```
plugin/
  zero_grep.vim          ← loaded by Vim9script Vim  (!nvim, has vim9script)
  zero_grep_legacy.vim   ← loaded by legacy Vim      (!nvim, !vim9script)
  zero_grep.lua          ← loaded by Neovim
autoload/
  zero_grep.vim          ← Vim9script core + context dispatch
  zero_grep/
    legacy.vim           ← legacy Vimscript core + context dispatch
    dumb_jump.vim        ← Vim9script Dumb Jump patterns + rg/git helpers
    dumb_jump/
      legacy.vim         ← legacy Dumb Jump patterns + rg/git helpers
lua/
  zero_grep.lua          ← Neovim core + context dispatch
  zero_grep/
    dumb_jump.lua        ← Neovim Dumb Jump patterns + rg/git helpers
```

## API reference

### Raw getters (Vim9script autoload)

```vim
zero_grep#CCword()   → '\bword\b'
zero_grep#Cword()    → 'word'
zero_grep#Word()     → 'WORD'
zero_grep#Vword()    → 'selection'
zero_grep#Pword()    → '\bpattern\b'
```

### Contextual escape (Vim9script autoload)

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

### Dumb Jump (Vim9script autoload)

```vim
zero_grep#dumb_jump#Cword()          " "(pat1|pat2|...)"
zero_grep#dumb_jump#CwordArgs()      " -e 'pat1' -e 'pat2' ...
zero_grep#dumb_jump#RgCword()        " -s -t lua "(pats)"
zero_grep#dumb_jump#GitCword()       " "(pats)" -- '*.lua'
```

### Neovim Lua

```lua
local zg = require('zero_grep')
local dj = require('zero_grep.dumb_jump')

zg.CCword()  zg.Cword()  zg.Word()  zg.Vword()  zg.Pword()
zg.grep_CCword()    zg.grep_Cword()    ...
zg.substitute_CCword()              ...
zg.shell_CCword()                   ...
zg.leaderf_CCword() zg.leaderf_Cword() zg.leaderf_Word()
zg.leaderf_Vword()  zg.leaderf_Pword()

zg.insert_CCword()  -- context-aware, for <C-R>= keymaps

dj.Cword()       dj.CwordArgs()
dj.rg_Cword()    dj.git_Cword()
```

## Requirements

- Vim ≥ 8.0 (legacy) or Vim ≥ 9.0 (Vim9script), **or** Neovim ≥ 0.7

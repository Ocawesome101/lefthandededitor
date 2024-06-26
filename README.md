# LeftHandedEditor

A simple text editor written in pure Lua.

Partially an experiment in making an editor primarily controlled by the left
hand (i.e. navigated with WASD).  I'm left-handed, so this makes sense.

A few keybinds operate on a "cut buffer." Every cut/copy operation appends to
this buffer, so `X` and then `10` is equivalent to `x` 10 times.

Lowercase commands work in insert mode when accompanied by `ctrl`, e.g. `e`
becomes `Ctrl-E`.

Uppercase commands may only be used while not in insert mode.

Keys:
  - `w`/`W` move 1/5 lines up
  - `s`/`S` move 1/5 lines down
  - `a`/`A` move 1/5 chars right
  - `d`/`D` move 1/5 chars left
  - `e` toggle insert mode
  - `i` scroll up 5 lines
  - `k` scroll down 5 lines
  - `I` jump to line 1
  - `K` jump to last line
  - `u` unindent by two spaces
  - `o` indent by two spaces
  - `j` jump to col 1
  - `l` jump to last col
  - `q` quit if saved
  - `Q` quit unconditionally (needs double-press)
  - `r` jump to line N
  - `c`/`C` copy 1 line/copy N lines
  - `x`/`X` cut 1 line/cut N lines
  - `v` paste contents of cut buffer, and clear it
  - `V` paste contents of cut buffer
  - `m` insert blank line (equivalent to 'Return')
  - `z` remove last line of cut buffer
  - `Z` clear cut buffer
  - `t` save file
  - `T` save file (always prompt for fname)


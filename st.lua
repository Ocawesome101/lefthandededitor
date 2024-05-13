local s = require'syntax'
print(s.setHighlightFrom('s.lua'))

local str = "local x = \"\\\\\\\"\" -- test"

print(s.h(str))
print(s.highlight(str, 1, #str))


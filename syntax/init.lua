-- basic syntax highlighter

local M = {}

-- highlight all of `line', returning the parts between indices `s' and `e'
function M.highlight(line, s, e)
  if not M.h then
    return line:sub(s, e)
  end

  -- VT100 highlight strings will change the apparent length of the line,
  -- so surround in `\255' so we can find the intended substring
  line = line:sub(1,e).."\255"..line:sub(e+1)
  line = line:sub(1,s-1).."\255"..line:sub(s)

  local highlighted = M.h(line)
  return highlighted:match("\255(.+)\255") or (line:gsub("\255",""))
end

local SYNTAX = os.getenv("HOME").."/.local/share/le/syntax/?.lua"

function M.setHighlightFrom(fname)
  local ext = fname:match("%.(.+)$")
  if not ext then
    return
  end

  local f, err = loadfile(SYNTAX:gsub("%?", ext), "t")
  if not f then
    return nil, err
  end

  local ok
  ok, err = pcall(f)
  if ok and err then M.h = err end

  return ok, err
end

return M


#!/usr/bin/env lua

local termio = require("termio")

local w, h = termio.getTermSize()
local buf = {}
local cbuf = {}
local drawn = {}

local st = {line=1,col=1,scroll=0,hscroll=0,fname="",
  save=false,stat=""}

local function draw()
  for i=1, h do
    if i == h or not drawn[i] then
      drawn[i] = true
      termio.setCursor(1, i)
      if buf[i+st.scroll] then
        io.write("\27[2K",buf[i+st.scroll]:sub(1+st.hscroll,w+st.hscroll))
      else
        io.write("\27[2K~")
      end
    end
  end

  local stat = string.format("\27[30;47m%s %sL:%d/%d,C:%d \27[39;49m",
    st.stat, st.save and " " or "*", st.line, #buf, #cbuf)
  termio.setCursor(w-#stat+17, h)
  io.write(stat)
  termio.setCursor(st.col-st.hscroll, st.line-st.scroll)
end

if arg[1] then
  st.fname = arg[1]
  st.save = true
  local h = io.open(arg[1], "r")
  if h then
    for line in h:lines() do
      buf[#buf+1] = line
    end
    h:close()
  end
end

buf[1] = buf[1] or ""

local function clear()
  for i=1, h do drawn[i] = false end
end

local function gscroll()
  st.line = math.max(1, math.min(#buf, st.line))
  st.col = math.max(1, math.min(#buf[st.line]+1, st.col))

  while st.line <= st.scroll do
    clear()
    st.scroll = math.max(0, st.scroll - 5)
  end
  while st.line - h > st.scroll do
    clear()
    st.scroll = st.scroll + 5
  end

  while st.col < st.hscroll do
    clear()
    st.hscroll = math.max(0, st.hscroll - 5)
  end
  while st.col - w > st.hscroll do
    clear()
    st.hscroll = st.hscroll + 5
  end
end

local function scroll(n)
  st.line = st.line + n
  gscroll()
end

local function prompt(t, num)
  termio.setCursor(1,1)
  io.write("\27[2K"..t)
  local np = io.read()
  drawn[1] = false
  return tonumber(np) or ((not num) and #np > 0 and np)
end

local function hscroll(n)
  st.col = st.col + n
  gscroll()
end

local function insert(k)
  st.stat = "(^E)"
  st.save = false
  st.quit = false
  drawn[st.line-st.scroll] = false
  local cl = buf[st.line]
  if k == "backspace" then
    if st.col > #cl and #cl > 0 then
      cl = cl:sub(1,-2)
    elseif st.col > 1 then
      cl = cl:sub(1,st.col-2)..cl:sub(st.col)
    end

    st.col = st.col - 1

  else

    if st.col > #cl then
      cl = cl .. k
    elseif st.col == 1 then
      cl = k .. cl
    else
      cl = cl:sub(1,st.col-1)..k..cl:sub(st.col)
    end

    st.col = st.col + #k
  end

  buf[st.line] = cl

  gscroll()
end

local function cut(n, cl)
  st.save = false
  st.quit = false
  clear()
  for i=1, n do
    cbuf[#cbuf+1] = buf[st.line+i-1]
    gscroll()
  end
  if cl then
    for i=1, n do
      table.remove(buf, st.line)
    end
  end
end

local function paste(cl)
  st.save = false
  st.quit = false
  clear()
  for i=#cbuf, 1, -1 do
    table.insert(buf, st.line+1, cbuf[i])
    if cl then cbuf[i] = nil end
  end
end

local function save()
  if #st.fname == 0 then st.fname = prompt("fname? ", true) or st.fname end
  if #st.fname > 0 then
    local h, err = io.open(st.fname, "w")
    if h then
      for i=1, #buf do
        h:write(buf[i],"\n")
      end
      h:close()
      st.stat = "Saved"
      st.save = true
    else
      st.stat = err
    end
  else
    st.stat = "!NO SAVE"
  end
end

local function find(pat, s, e)
  for i=s, e do
    local ok, err = pcall(string.find, buf[i], pat)
    if ok and err then return i end
  end
end

local function after(text)
  table.insert(buf, st.line+1, text)
  st.line = st.line + 1
  for i=st.line-st.scroll, h do drawn[i] = false end
  st.col = 1
end

local function mvmt(k)
  if k == "w" then
    scroll(-1)
  elseif k == "W" then
    scroll(-5)
  elseif k == "s" then
    scroll(1)
  elseif k == "S" then
    scroll(5)
  elseif k == "d" then
    hscroll(1)
  elseif k == "D" then
    hscroll(5)
  elseif k == "a" then
    hscroll(-1)
  elseif k == "A" then
    hscroll(-5)
  elseif k == "j" then
    st.col = 1
  elseif k == "l" then
    st.col = #buf[st.line] + 1
  elseif k == "I" then
    st.line = 1
    clear()
  elseif k == "K" then
    st.line = #buf
    clear()
  elseif k == "i" then
    st.scroll = math.max(0, st.scroll - 5)
    if st.line > st.scroll + h then st.line = st.line - 5 end
    clear()
  elseif k == "k" then
    st.scroll = math.min(#buf-h, st.scroll + 5)
    if st.line < st.scroll then st.line = st.line + 5 end
    clear()
  elseif k == "q" then
    if not st.save then
      st.stat = "unsaved! t=save"
    else
      io.write("\27[2J\27[1;1H")
      io.flush()
      os.exit()
    end
  elseif k == "Q" then
    if not (st.save or st.quit) then
      st.stat = "unsaved! t=save Q=quit"
      st.quit = true
    else
      io.write("\27[2J\27[1;1H")
      io.flush()
      os.exit()
    end
  elseif k == "e" then
    st.insert = not st.insert
    if st.insert then
      st.stat = "(^E)"
    else
      st.stat = ""
    end
  elseif k == "f" or k == "/" then
    local tofind = prompt("find? ")
    if find then
      local found = find(tofind, st.line+1, #buf) or find(tofind, 1, st.line)
      if found then st.line = found end
    end
  elseif k == "p" then
    local text = buf[st.line]:sub(st.col)
    buf[st.line] = buf[st.line]:sub(1, st.col-1)
    after(text)
  elseif k == "r" then
    st.line = prompt("nline? ") or st.line
  elseif k == "c" then
    cut(1)
  elseif k == "C" then
    local count = prompt("nline? ")
    if count then cut(count) end
  elseif k == "x" then
    cut(1, true)
  elseif k == "X" then
    local count = prompt("nline? ")
    if count then cut(count, true) end
  elseif k == "v" then
    paste(true)
  elseif k == "V" then
    paste()
  elseif k == "m" then
    after("")
  elseif k == "z" then
    cbuf[#cbuf] = nil
  elseif k == "Z" then
    for i=1, #cbuf do
      cbuf[i] = nil
    end
  elseif k == "t" then
    pcall(save)
  elseif k == "T" then
    st.fname = prompt("fname? ", true) or st.fname
    pcall(save)
  end
end

local function getinput()
  local k, f = termio.readKey()

  if f.ctrl or not st.insert then
    mvmt(k)
  else
    insert(k)
  end
end

while true do
  if #buf[#buf] > 0 then
    buf[#buf+1] = ""
  end
  gscroll()

  draw()
  getinput()
end


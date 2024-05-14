-- lua syntax file

local classes = {
  {name = "whitespace", "^[ \t\r\f\n\v]*$"},
  {name = "number", "^[0-9]+$", "^0x[0-9a-fA-F]+$"},
  {name = "word", "^[a-zA-Z0-9_]+$"},
  {name = "parens", "^[()]$"},
  {name = "special", "^[=%-%+%*&%^%%#~|%[%](){};,%.:<>]+$"},
}

local colors = {
  number = 95,
  special = 94,
  string = 93,
  boolean = 95,
  parens = 96,
  comment = 90,
}

local keywords = {
  word = {
    {
      color = 91,
      "local", "function", "while", "do", "for", "in", "if", "then",
      "elseif", "else", "end", "and", "or", "not", "return", "break", "goto"
    },
    {
      color = 95,
      "true", "false",
    },
    {
      color = 96,
      "string", "table", "coroutine", "require", "loadfile", "dofile", "load",
      "utf8", "io", "package", "print", "assert", "_G", "tostring", "tonumber",
      "rawget", "rawset", "error", "pcall", "xpcall"
    },
  },
}

local function color(word, col)
  local cstr = string.format("\27[%dm", col)
  return cstr .. word:gsub("\255", "\255"..cstr)
end

local function find(t, item)
  for i=1, #t do
    for j=1, #t[i] do
      t.color = t[i].color
      if t[i][j] == item then return true end
    end
  end
end

local function procword(word, class)
  --print(word, class.name)
  local check = word:gsub("\255", "")
  if #check == 0 then return word end
  if not (class and class.name) then return word end
  if keywords[class.name] and find(keywords[class.name], check) then
    return color(word, keywords[class.name].color)
  elseif colors[class.name] then
    return color(word, colors[class.name])
  else
    return color(word, 37)
  end
end

local function matches(word, class)
  for i=1, #class do
    if word:match(class[i]) then
      return true
    end
  end
end

return function(line)
  local out = ""

  local str = false
  local comment = false
  local word = ""
  local class
  for c in line:gmatch(".") do
    if c == "\255" then
      word = word .. c
    elseif c:match("[\"']") and (str == c or not str) then
      if str == c and (word:sub(-1) ~= "\\" or word:sub(-2) == "\\\\") then
        word = word .. c
        str = false
        out = out .. procword(word, {name="string"})
        word = ""
      elseif not str then
        str = c
        if #word > 0 then out = out .. procword(word, class) end
        word = c
      else
        word = word .. c
      end
    elseif str then
      word = word .. c
    elseif comment then
      word = word .. c
    elseif word:gsub("\255", "") == "--" then
      comment = true
      class = {name = "comment"}
      word = word .. c
    else
      local matchword = word:gsub("\255","")
      for i=1, #classes do
        if matches(c, classes[i]) and not matches(matchword, classes[i]) then
          out = out .. procword(word, class or classes[i])
          word = ""
          class = classes[i]
          break
        end
      end
      word = word .. c
    end
  end

  --print(comment, class.name, word)
  if #word > 0 then out = out .. procword(word, class) end

  return out or line
end


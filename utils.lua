local json = require("JSON")
local JSON = require("dkjson")

function is_chat_msg(msg)
  if msg.to.type == 'chat' then
    return true
  end
  return false
end


function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function stringSplit(str,sep)
  local splitted = {}
  for i in string.gmatch(str,"%d") do
    table.insert(splitted,i)
  end
  return splitted
end

-- Removes spaces
function string:trim()
  return self:gsub("^%s*(.-)%s*$", "%1")
end


function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  for filename in popen('ls -a "'..directory..'"'):lines() do
    i = i + 1
    t[i] = filename
  end
  return t
end


-- Returns the name of the sender
function get_name(msg)
  local name = msg.from.first_name
  if name == nil then
    name = msg.from.id
  end
  return name
end


function file_exists(name)
  local f = io.open(name,"r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end


function string:isempty()
  return self == nil or self == ''
end


function string:isblank()
  self = self:trim()
  return self:isempty()
end


-- Returns true if String starts with Start
function string:starts(text)
  return text == string.sub(self,1,string.len(text))
end

function load_data(filename)
	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data
end

function save_data(filename, data)
	local s = json:encode_pretty(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()
end

function match_pattern(pattern,text,lower_case)
  if text then
    local matches = {}
    if lower_case then
      matches = { string.match(text:lower(), pattern) }
    else
      matches = { string.match(text, pattern) }
    end
      if next(matches) then
        return matches
      end
  end
  -- nil
end

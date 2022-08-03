local charset = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
function generateId(length)
  local len = length or 16
	local ret = {}
	local r
	for i = 1, len do
		r = math.random(1, #charset)
		table.insert(ret, charset:sub(r, r))
	end
	return table.concat(ret)
end

function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function keys(t)
  local keyset={}
  local n=1

  for k,v in pairs(t) do
    keyset[n]=k
    n=n+1
  end
  return keyset
end

function length(t)
  local i = 0
  for k,v in pairs(t) do
    if v then i = i+1 end
  end
  return i
end

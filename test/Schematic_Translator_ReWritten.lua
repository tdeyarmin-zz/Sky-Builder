
---- NBT Tag Values -----------------------------------------------------------

local tagEnd = 0
local tagByte = 1
local tagShort = 2
local tagInt = 3
local tagLong = 4
local tagFloat = 5
local tagDouble = 6
local tagByteArray = 7
local tagString = 8
local tagList = 9
local tagCompound = 10

-------------------------------------------------------------------------------

--Variables and Tables
local blocks = { }
local damages = { }
local x, y, z = 0, 0, 0
local height = 0
local index = 1
abort = nil

local tArgs = { ... }
--[[ Check for user arguments. If more or less than one exist abort]]
if #tArgs ~= 1 then
  print("Usage: build <g-unzipped schematic file>")
  return
end

local fileName = tArgs[1]
-- Check if file exists if not abort
if not fs.exists(fileName) then
  print("File does not exist")
  return
end

-- Open file in readBytes 'mode'
h = fs.open(fileName, "rb")

--

-- function to resize an array
function resizeTable(t,i)
    setmetatable(t,{__len=function() return i end})
end

function readbyte(h)
  local b = h.read()

  if not b then
    error('readbyte', 2)
    abort = 1
  end
  return b
end

function discardBytes(h, n)
  for i = 1,n do
    readbyte(h)
    if (i % 1000) == 0 then
  end
  end
end

function readname(h)
  local n1 = readbyte(h)
  local n2 = readbyte(h)

  if(n1 == nil or n2 == nil) then
    return ""
  end

  local n = n1*256 + n2

  local str = ""
  for i=1,n do
    local c = readbyte(h)
    if c == nil then
      return
    end
    str = str .. string.char(c)
  end
  return str
end

function parse(a, h, containsName)
  print(a)
  if a==0 then
    return
  end

  local name
  if containsName then
    name = readname(h)
  end

  if a==tagByte then
    discardBytes(h, 1)

  elseif a==tagShort then
    local i1 = readbyte(h)
    local i2 = readbyte(h)
    local i = i1*256 + i2
    if(name=="Height") then
      height = i
    elseif (name=="Length") then
      length = i
    elseif (name=="Width") then
      width = i
    end

  elseif a==tagInt then
    discardBytes(h, 4)

  elseif a==tagLong then
    discardBytes(h,8)

  elseif a==tagFloat then
    discardBytes(h,4)

  elseif a==tagDouble then
    discardBytes(h,8)

  elseif a==tagByteArray then
    local i1 = readbyte(h)
    local i2 = readbyte(h)
    local i3 = readbyte(h)
    local i4 = readbyte(h)
    -- Convert signed int (32bit) to decimal
    local i = (i1*256*256*256) + (i2*256*256) + (i3*256) + i4
    print(i1 .. " " .. i2 .. " " .. i3 .. " " .. i4 .. " " .. i)

    local yieldTimer = os.startTimer(9.8)

    if name == "Blocks" then
      print('b')
      print(i)
      -- Set table size to prevent rehashing
      resizeTable(blocks,i)

      for i = 1, i do
        print(i)
        local id = readbyte(h)
        if id > 0 then
          local b = {
            id = id
          }
          blocks[i] = b
          --assignCoord(b)
        else
          --assignCoord()
        end
        if (i % 1000) == 0 then
          os.queueEvent("fakeEvent")
          os.pullEvent()
        end

        --[[ timer
        yield = yield + 1
        if yield == 45000 then
        os.queueEvent("fakeEvent")
        os.pullEvent()
      end]]

      end

    elseif name == "Data" then
      print('d')
      -- Set table size to prevent rehashing
      resizeTable(damages,i)
      for i = 1, i do
        local dmg = readbyte(h)
        if dmg > 0 then
          damages[i] = dmg
        end
        if (i % 1000) == 0 then
        end
      end
    else
      print('db')
      discardBytes(h,i)
    end

  elseif a==tagString then
    local i1 = readbyte(h)
    local i2 = readbyte(h)
    local i = i1*256 + i2
    discardBytes(h,i)

  elseif a==tagList then
        local type = readbyte(h)
        local i1 = readbyte(h)
    local i2 = readbyte(h)
    local i3 = readbyte(h)
    local i4 = readbyte(h)
    local i = i1*256*256*256 + i2*256*256 + i3*256 + i4
    --print(type .. " " .. i1 .. " " .. i2 .. " " .. i3 .. " " .. i4 .. " " .. i)
    for j=1,i do
      --print(i)
      --print(type)
      parse(type, h, false)
    end

  elseif a > 11 then
    error('invalid tag')
    abort = 1
  end
end

local a = 0
while (a ~= nil) do
  a = h.read()
  print(a)
  parse(a, h, true)
end

if (a == nil) then
  print("Finished")
end

if abort then
  h.close()
end

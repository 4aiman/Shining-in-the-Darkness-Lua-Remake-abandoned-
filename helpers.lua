
old_newImage =  love.graphics.newImage
function love.graphics.newImage(...)
   local test = old_newImage(...)
   test:setFilter("nearest","nearest",0,0)
   return test
end


local debug_text = {}
local debug_timer = 5
function add_debug_mesage(text, color)
   debug_text[text]={timer=debug_timer, color = color}
end

function debug_message_update(dt)
   for k,v in pairs (game.debug_text) do
       debug_text[k].timer=debug_text[k].timer - dt
       if debug_text[k].timer < 0 then debug_text[k] = nil end
   end
end


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            if orig_key~="gamedef" then
               copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


__POSTPONED = {}

function update_timers(dt)
   for k,v in pairs(__POSTPONED) do
       v.ttl = v.ttl-dt
       if v.ttl<0 then
          v.func(v.args)
          __POSTPONED[k] = nil
       end
   end
end

function after(dt, func, ...)
   __POSTPONED[#__POSTPONED+1] = {ttl = dt, func = func, args = ...}
end


-- UTF-8 Reference:
-- 0xxxxxxx - 1 byte UTF-8 codepoint (ASCII character)
-- 110yyyxx - First byte of a 2 byte UTF-8 codepoint
-- 1110yyyy - First byte of a 3 byte UTF-8 codepoint
-- 11110zzz - First byte of a 4 byte UTF-8 codepoint
-- 10xxxxxx - Inner byte of a multi-byte UTF-8 codepoint

function chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- This function can return a substring of a UTF-8 string, properly handling
-- UTF-8 codepoints.  Rather than taking a start index and optionally an end
-- index, it takes the string, the starting character, and the number of
-- characters to select from the string.

function utf8sub(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
  end

  local currentIndex = startIndex

  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return str:sub(startIndex, currentIndex - 1)
end



function clamp(v)
    if v < 000 then return 000 end
    if v > 255 then return 255 end
    return math.floor(v + 0.5)
end

function rotate_hue(color, degrees)
    local matrix = {[0]={1,0,0}, [1]={0,1,0}, [2]={0,0,1}}
    local cosA = math.cos(math.rad(degrees))
    local sinA = math.sin(math.rad(degrees))
    local sqrt = math.sqrt

    matrix[0][0] = cosA + (1.0 - cosA) / 3.0
    matrix[0][1] = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA
    matrix[0][2] = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA
    matrix[1][0] = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA
    matrix[1][1] = cosA + 1./3.*(1.0 - cosA)
    matrix[1][2] = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA
    matrix[2][0] = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA
    matrix[2][1] = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA
    matrix[2][2] = cosA + 1./3. * (1.0 - cosA)

    local r,g,b = color[1],color[2],color[3]

    local rx = r * matrix[0][0] + g * matrix[0][1] + b * matrix[0][2]
    local gx = r * matrix[1][0] + g * matrix[1][1] + b * matrix[1][2]
    local bx = r * matrix[2][0] + g * matrix[2][1] + b * matrix[2][2]
    return clamp(rx), clamp(gx), clamp(bx)
end


function imageColorShift(img, degrees, sat)
    local image = img--:getData()
    print(image)
    local r, g, b, a
    local w, h = image:getDimensions()
    for i=0, w-1, 1 do
        for j=0, h-1, 1 do
            r, g, b ,a = image:getPixel(i, j)
            r, g, b = rotate_hue({r,g,b}, degrees)
            r,g,b = clamp(r+sat), clamp(g+sat), clamp(b+sat)
            image:setPixel(i, j, r, g, b, a)
        end
    end
    return love.graphics.newImage(img)
end

local sel = love.graphics.newImage('gfx/sel.png')

love.graphics.pretty_print = function(text,x,y,s,c,sho,ad, sym)
   if sym then
      local W = menu.font:getWidth(text)
      local W1 = menu.font:getWidth(sym[1])
      local W2 = menu.font:getWidth(sym[2])
      local X1 = x-20*game.scaley
      local X2 = x-3*game.scaley
       if not s then s = 1 end
       love.graphics.setColor(0, 0, 0)
       for i=-1,1 do
           for j=-1,1 do
               love.graphics.print(sym[1],math.sin(game.sin_timer)*10*game.scaley+ X1+i*s/2,y+j*s/2)
           end
       end
       for i=-1,1 do
           for j=-1,1 do
               love.graphics.print(sym[2],-math.sin(game.sin_timer)*10*game.scaley+W+X2+i*s/2,y+j*s/2)
           end
       end

       if not c then
          love.graphics.setColor(255, 255, 255)
       else
          love.graphics.setColor(c[1], c[2], c[3])
       end
       love.graphics.print(sym[1],math.sin(game.sin_timer)*10*game.scaley+ X1,y)
       love.graphics.print(sym[2],-math.sin(game.sin_timer)*10*game.scaley+W+X2,y)
       love.graphics.setColor(255, 255, 255)
   end

   if sho then
      if ad then
         love.graphics.setColor( 0, 255, 0)
      else
         love.graphics.setColor( 255, 0, 0)
      end
      local H = menu.font:getHeight(text)
      local W = menu.font:getWidth(text)
      love.graphics.draw(sel, x, y, 0, W/100, H/25)
   end

   if not s then s = 1 end
   love.graphics.setColor(0, 0, 0)
   for i=-1,1 do
       for j=-1,1 do
           love.graphics.print(text,x+i*s/2,y+j*s/2)
       end
   end

   if not c then
      love.graphics.setColor(255, 255, 255)
   else
      love.graphics.setColor(c[1], c[2], c[3])
   end
   love.graphics.print(text,x,y)
   love.graphics.setColor(255, 255, 255)
end


local next=next
local type=type
local tostring=tostring

local format=string.format

local sort=table.sort
local concat=function(tbl,sep)
    tbl2 = {}
    for k,v in pairs(tbl) do
        if k and v then
           tbl2[k] = v
        end
    end
    return table.concat(tbl2,sep)
end

serialize = function(t, ind)
   if not ind then ind = '' end
   local TYPE=type(t)
   if TYPE=="boolean" or TYPE=="number" then
      return tostring(t)
   elseif TYPE=="string" then
      return format("%q",t)
   elseif TYPE=="table" then
      local ret={}
      local r_v={}
      local n=0
      for i,v in next,t do
         local sv=serialize(v,ind..'\t')
         if sv~=nil then
            ret[#ret+1]=ind.."["..serialize(i).."]="..sv
            n=n+1
         end
      end
      return "{\n"..concat(ret,",\n").."\n}"
   else
      return --"&"..TYPE.."="..format("%q",tostring(t))
   end
end


table_print = function(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\",", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\",", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

to_string = function( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

function round(val, num)
   if not num then num = 2 end
   local n = 1
   for i=1, n do n = n*10 end
   if type(val)~="number" then return 0 end
   return math.floor((val+0.5)*n)/n
end

function round2(val, num)
   if not num then num = 2 end
   local n = 1
   for i=1, n do n = n*10 end
   if type(val)~="number" then return 0 end
   return math.floor((val)*n)/n
end

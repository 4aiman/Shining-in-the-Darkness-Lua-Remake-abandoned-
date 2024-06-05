os.execute("cls")
bit = require("luabit")
inspect = require("inspect")


OOZE_FileName = "OOZE.BIN"
OOZE_File = io.open(OOZE_FileName,"rb")
OOZEData = {}

print(OOZE_File)
for OOZEoffset = 0, 23 do
OOZEData[OOZEoffset] = OOZE_File:read(1)
end

	local oba = bit.band
	function bit.band(n,m) 
	   local res = oba(n,m)
	   io.write("\t("..string.rep(" ", 3-string.len(n))..n.." & "..string.rep(" ", 3-string.len(m))..m..") = "..string.rep(" ", 3-string.len(res))..res)
	   return res
	end


function set(k,v,n)
   _G[k] = v
   io.write(string.rep("\t",n or 0).."\t"..k.."\t"..tostring(v).."\n")
end

set("ModelB", bit.band(OOZEData[0]:byte(), 252) / 4, 3)

set("ColorF", bit.band(OOZEData[0]:byte(), 3) * 64 + bit.band(OOZEData[1]:byte(), 252) / 4)
if bit.band(ColorF, 128) > 0 then set("Flipud", true,3) else set("Flipud", false, 3) end
if bit.band(ColorF,  64) > 0 then set("Fliplr", true,3) else set("Fliplr", false,3) end
if bit.band(ColorF,  32) > 0 then set("chy", true,3)    else set("chy", false,3) end
if bit.band(ColorF,  16) > 0 then set("chb", true,3)    else set("chb",false,3) end
if bit.band(ColorF,   8) > 0 then set("chuer", true,3)  else set("chuer", false,3) end


set("Color", bit.band(ColorF, 7),3)
set("Un5s0", bit.band(OOZEData[1]:byte(),    3)*   8 +bit.band(OOZEData[2]:byte(),224)/32)
set("Dark R",bit.band(OOZEData[2]:byte(),   31)*   4 +bit.band(OOZEData[3]:byte(),192)/64)
set("EXP",   bit.band(OOZEData[3]:byte(),   63)*  64 +bit.band(OOZEData[4]:byte(),252)/ 4)
set("Gold",  bit.band(OOZEData[4]:byte(),    3)*1024 +bit.band(OOZEData[6]:byte(),192)/64 +(OOZEData[5]:byte())*4)
set("Drop",  bit.band(OOZEData[6]:byte(),   63)*   2 +bit.band(OOZEData[7]:byte(),128)/128	)
set("Rate",  bit.band(OOZEData[7]:byte(),  112)/16,3)
set("Regen", bit.band(OOZEData[7]:byte(),   12)/4,3)
set("Dodge", bit.band(OOZEData[7]:byte(),    3),3)
set("HP",    bit.band(OOZEData[9]:byte(),  192) / 64 + OOZEData[8]:byte() * 4,3)
set("MP",    bit.band(OOZEData[9]:byte(),   63) *  16 + bit.band(OOZEData[10]:byte(), 240) / 16)
set("Ag",    bit.band(OOZEData[10]:byte(),  15) *  64 + bit.band(OOZEData[11]:byte(), 252) / 4)
set("Att",   bit.band(OOZEData[11]:byte(),   3) * 256 + OOZEData[12]:byte(),3)
set("Def",   bit.band(OOZEData[14]:byte(), 192) / 64 + OOZEData[13]:byte()*4 ,3)

set("Fire  R", bit.band(OOZEData[14]:byte(),  48) / 16,3)
set("Ice   R", bit.band(OOZEData[14]:byte(),  12) /  4,3)
set("Bolt  R", bit.band(OOZEData[14]:byte(),   3),3)
set("Wind  R", bit.band(OOZEData[15]:byte(), 192) / 64,3)
set("Burst R", bit.band(OOZEData[15]:byte(),  48) / 16,3)
set("Slow R",  bit.band(OOZEData[15]:byte(),  12) / 4,3)
set("MuddleR", bit.band(OOZEData[15]:byte(),   3),3)
set("Sleep R", bit.band(OOZEData[16]:byte(), 192) / 64,3)
set("ScreenR", bit.band(OOZEData[16]:byte(),  48) / 16,3)
set("DesoulR", bit.band(OOZEData[16]:byte(),  12) / 4,3)
set("Actions", bit.band(OOZEData[16]:byte(),   3),3)
if bit.band(OOZEData[17]:byte(), 128) > 0 then set("2Attack", true,3) else set("2Attack", false,3) end
if bit.band(OOZEData[17]:byte(),  64) > 0 then set("Uf2", true,3) else set("Uf2", false,3) end

set("StronAI", bit.band(OOZEData[17]:byte(), 48) / 16,3)
set("Weak AI", bit.band(OOZEData[17]:byte(), 12) /  4,3)
set("Action1", bit.band(OOZEData[17]:byte(), 3) * 64 + bit.band(OOZEData[18]:byte(), 252) / 4)
set("Action2", bit.band(OOZEData[18]:byte(), 3) * 64 + bit.band(OOZEData[19]:byte(), 252) / 4)
set("Action3", bit.band(OOZEData[19]:byte(), 3) * 64 + bit.band(OOZEData[20]:byte(), 252) / 4)
set("Action4", bit.band(OOZEData[20]:byte(), 3) * 64 + bit.band(OOZEData[21]:byte(), 252) / 4)
set("Action5", bit.band(OOZEData[21]:byte(), 3) * 64 + bit.band(OOZEData[22]:byte(), 252) / 4)
set("Action6", bit.band(OOZEData[22]:byte(), 3) * 64 + bit.band(OOZEData[23]:byte(), 252) / 4)


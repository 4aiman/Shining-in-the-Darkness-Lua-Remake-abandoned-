os.execute("chcp 65001")
os.execute("cls")
local bit = require("luabit")
local inspect = require("inspect")
local compressor = require("LibCompress")


local MapNames = {"1st Floor","2nd Floor","3rd Floor","4th Floor","5th Floor","Cave of Wisdom","Wisdom Underground","Cave of Truth","Cave of Truth","Cave of Strength","Strength+Courage Underground","Cave of Courage"};
local AttackNames = {"Rock Throw", "Blaze 1", "Blaze 2", "Blaze 3", "Blaze 4", "Freeze 1", "Freeze 2", "Freeze 3", "Freeze 4", "Bolt 1", "Bolt 2", "Bolt 3", "Blast 1", "Blast 2", "Blast 3", "Burst 1", "Burst 2", "Burst 3", "Quick 1", "Quick 2", "Slow 1", "Slow 2", "Muddle 1", "Muddle 2", "Sleep 1", "Sleep 2", "Screen 1", "Desoul 1", "Heal 1", "Heal 2", "Heal 3", "Revive 2", "Attack (poison)", "Lunge (poison)", "Poison Powder", "Lash Out (poison)", "Attack (paralysis)", "Lunge (paralysis)", "Paralyzing Powder", "Paralyzing Mist", "Attack (sleep)", "Sleep Powder", "Sleep Mist", "Attack (normal)", "Attack (critical 1)", "Attack (critical 2)", "Attack (hero)", "Attack (hero)", "Attack (hero)", "Attack (hero)", "Attack (hero)", "Scorching Hot Air", "Crimson Flames", "White-Hot Gas", "Icy Breath", "Freezing Cloud", "Freezing Gas", "Defend (shield)", "Defend (robe)", "Defend (muscles)", "Watch Warily", "Wait", "Wary Eyes", "Flee", "Back Away", "Eerie Dance",  "One Massive Force", "Unleash Their Flames", "Strange Aura", "Concentration", "Help! (same type)", "Help! (same area)", "Help! (Dreampuff)", "Help! (Fungoids)", "Help! (Meat Zombie)", "Explode",  "Fission", "Sticky Web", "Kick Out (normal)", "Kick Out (critical)", "Heal 1", "Heal 2", "Heal 3", "Lunge (normal)", "Lash Out (normal)", "Wing Flap", "Savage Wing Flap", "Boulder Throw", "Bloodshot Eyes", "Ball of Flame", "Desoul 2", "Howl in Pain", "Attack (instant kill)", "Arrow", "Demonbreath 2", "Demonbreath 1", "Attack (Dark Knight)", "Bolt 3 (Dark Sol)", "Attack (Dark Sol 2)", "Blaze 3 (Dark Sol 2)", "Bolt 3 (Dark Sol 2)", "Attack (Dark Sol 3)", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "Rock Throw", "Blaze 1", "Blaze 2", "Blaze 3", "Blaze 4", "Freeze 1", "Freeze 2", "Freeze 3", "Freeze 4", "Bolt 1", "Bolt 2", "Bolt 3", "Blast 1", "Blast 2", "Blast 3", "Burst 1", "Burst 2", "Burst 3", "Quick 1", "Quick 2", "Slow 1", "Slow 2", "Muddle 1", "Muddle 2", "Sleep 1", "Sleep 2", "Screen 1", "Desoul 1", "Heal 1", "Heal 2", "Heal 3", "Revive 2", "Attack (poison)", "Lunge (poison)", "Poison Powder", "Lash Out (poison)", "Attack (paralysis)", "Lunge (paralysis)", "Paralyzing Powder", "Paralyzing Mist", "Attack (sleep)", "Sleep Powder", "Sleep Mist", "Attack (normal)", "Attack (critical 1)", "Attack (critical 2)", "Attack (hero)", "Attack (hero)", "Attack (hero)", "Attack (hero)", "Attack (hero)", "Scorching Hot Air", "Crimson Flames", "White-Hot Gas", "Icy Breath", "Freezing Cloud", "Freezing Gas", "Defend (shield)", "Defend (robe)", "Defend (muscles)", "Watch Warily", "Wait",  "Wary Eyes", "Flee",  "Back Away", "Eerie Dance", "One Massive Force", "Unleash Their Flames", "Strange Aura", "Concentration", "Help! (same type)", "Help! (same area)", "Help! (Dreampuff)", "Help! (Fungoids)", "Help! (Meat Zombie)", "Explode", "Fission", "Sticky Web", "Kick Out (normal)", "Kick Out (critical)", "Heal 1", "Heal 2", "Heal 3", "Lunge (normal)", "Lash Out (normal)", "Wing Flap", "Savage Wing Flap", "Boulder Throw", "Bloodshot Eyes", "Ball of Flame", "Desoul 2", "Howl in Pain", "Attack (instant kill)", "Arrow", "Demonbreath 2", "Demonbreath 1", "Attack (Dark Knight)", "Bolt 3 (Dark Sol)", "Attack (Dark Sol 2)", "Blaze 3 (Dark Sol 2)", "Bolt 3 (Dark Sol 2)", "Attack (Dark Sol 3)"}


-- https://gist.github.com/fernandohenriques/12661bf250c8c2d8047188222cab7e28
function hex2rgb (hex)
	local hex = hex:gsub("#","")
	if hex:len() == 3 then
	  return (tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255
	else
	  return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
	end
end

local glyphs = ' 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\',!?-*/.()":#'

local colors = {
  [1] = {hex2rgb("000000")},
  [2] = {hex2rgb("e0e0e0")},
  [3] = {hex2rgb("606060")},
  [4] = {hex2rgb("a0a0a0")},
  [5] = {hex2rgb("60a060")},
  [6] = {hex2rgb("406040")},
  [7] = {hex2rgb("A08000")},
  [8] = {hex2rgb("e0e000")},
  [9] = {hex2rgb("e00000")},
 [10] = {hex2rgb("600000")},
 [11] = {hex2rgb("a00000")},
 [12] = {hex2rgb("e0c060")},
 [13] = {hex2rgb("808000")},
 [14] = {hex2rgb("404000")},
 [15] = {hex2rgb("000000")},
 [16] = {hex2rgb("0000e0")},
}

colors[1] = {0,0,0,0}

local MapAddresses = {}

local EnemyTiles = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}

local ROM = {}

function to_number(value)
  return value and 1 or 0
end

function ROM:load(filename)	
    print ("Loading ROM: ".. filename)
	self.filename = filename
	self.file, self.err = io.open(filename,"rb")
	self.filesize = self.file:seek("end")
	print ("Size: ".. self.filesize)
	self.file:seek("set")
	self.enemy_maps = {}	
	self.maps = {}
	self.data = {}
	self.enemies = {}
	self.items = {}
	self.total_chests = 129
	self.total_stairs = 19
	self.total_items  = 127  -- there are 127 items (0-126), data goes further, but it's enemy data
	self.total_enemies = 177 -- there are 126 of them (0-125), but the data goes further, so why not?
	for offset = 1, ROM.filesize do ROM.data[offset] = ROM.file:read(1) end
	
	self.map_names = MapNames
	print ("Loading maps (".. #self.map_names..")")
	
    self:load_maps()
	print ("Loading stairs (".. self.total_stairs..")*2")
	self:load_stairs()
	print ("Loading items (".. self.total_items..")")
	self:load_item_icons()
	self:load_items()
	print ("Loading items (".. self.total_chests..")")
	self:load_chests()
	print ("Loading enemies (".. self.total_enemies..")")
	self:load_enemies()	
	print("Done")   

	
end

function ROM:load_chests()
	
	local chests = {}
	local Spacer = 1
	
	for I = 0, self.total_chests do	    
        chests[Spacer] = chests[Spacer]  or {}
		local ItemNum = ""
		if self.data[33990 + I]:byte() < 128 then
			local Offset = self.data[33990 + I]:byte()
			chests[Spacer][#chests[Spacer]+1] = self.items[Offset+1]
		elseif self.data[33990 + I]:byte() < 255 then
			local C = self.data[33990 + I]:byte() - 128
			local Iname = ""
			if     C == 0 then
				Iname = 50
			elseif C == 1 then
				Iname = 100
			elseif C == 2 then
				Iname = 200
			elseif C == 3 then
				Iname = 300
			elseif C == 4 then
				Iname = 500
			elseif C == 5 then
				Iname = 1000
			elseif C == 6 then
				Iname = 2000
			elseif C == 7 then
				Iname = self.enemies[124]
			elseif C == 8 then
				Iname = self.enemies[123]
			elseif C == 9 then
				Iname = self.enemies[122]
			else
				Iname = "UNKNOWN=" + string.char(C)
			end
			chests[Spacer][#chests[Spacer]+1] = Iname
		else
			Spacer = Spacer + 1
		end
	end
	
	-- chests contain actual tables of items/enemies or a number in case of gold
	-- items can be distingueshed from enemies by checking chests[i].actions or any other field
	-- if type(chests[i]) == number - it's gold
	-- else do that check and spawn enemy if needed
	self.chests = chests
end

function ROM:load_maps()   
	for map_id = 1, #self.map_names do
	    local doors = {}
		local temp = {}
		local offset = 612075 --612074
		local z, repeat_, repeat_val = 0,0,0;	
		local c = 1;
		local x,y
		
		local enemy_table = {}

		local map_start_ofset = 16777216 * ROM.data[offset + (map_id-1) * 4 + 0]:byte() + 
								   65536 * ROM.data[offset + (map_id-1) * 4 + 1]:byte() + 
								     256 * ROM.data[offset + (map_id-1) * 4 + 2]:byte() + 
								           ROM.data[offset + (map_id-1) * 4 + 3]:byte() +1
		
		local additional_offset = map_start_ofset + 129 
		--print("map_start_ofset ", map_start_ofset)
		--print("additional_offset ", additional_offset)
		--print("ROM.data[map_start_ofset]",self.data[map_start_ofset])
		
		local data = {}
		
		for y = 1, 32 do
			z = 16777216 * ROM.data[map_start_ofset + (y-1) * 4 + 0]:byte() + 
				   65536 * ROM.data[map_start_ofset + (y-1) * 4 + 1]:byte() + 
				     256 * ROM.data[map_start_ofset + (y-1) * 4 + 2]:byte() + 
				           ROM.data[map_start_ofset + (y-1) * 4 + 3]:byte() 
			for x=1, 32 do
				if bit.band(z,1) == 0 then
				   data[33-x] = data[33-x] or {}
				   data[33-x][y] = 192
				else
				   data[33-x] = data[33-x] or {}
				   data[33-x][y] = 1
				end
				z = bit.rshift(z, 1)
			end
		end

		for y = 1, 32 do
			for x = 1, 32 do
				temp[c] = 0
				if (data[x][y] == 1) then
					if (repeat_ == 0) then
						temp[c] = bit.band(ROM.data[additional_offset]:byte(), 191)
						if (bit.band(ROM.data[additional_offset]:byte(), 64) > 0) then
							repeat_val = temp[c];
							additional_offset = additional_offset +1;
							repeat_ = ROM.data[additional_offset]:byte();
						end
						additional_offset = additional_offset +1;
					else					    
						temp[c] = repeat_val;
						repeat_ = repeat_ -1;
					end
					c = c + 1
				end
			end
		end
			
		c = 1;          
		if (ROM.data[map_start_ofset + 128]:byte() == 0) then
			for x= 1, 32 do
				for y = 1, 32 do
					if (data[y][x] == 1) then
						data[y][x] = temp[c];
						c = c+1
					end
				end
			end
		else
			for y = 1, 32 do
				for x = 1, 32 do
					if (data[y][x] == 1) then 
						data[y][x] = temp[c];
						c = c+1
					end
				end
			end
		end
	
		io.write("layout, ")
		-- map's enemy data
		for i = 1, 16 do
			enemy_table[i] = ROM.data[additional_offset]:byte();
			additional_offset = additional_offset + 1;
			
		end
		local enemy_offset = additional_offset;	
		
		local D2, D1, D0 = 0,0,0;
		local done = false
		local additional_offset = 0;
		local XEMap = {}
		local YEMap = {}
		local enemy_map = {}
		
		c = 0;
			for x = 1, 32 do
				for y = 1, 32 do
					XEMap[x] = XEMap[x] or {}
					if (bit.band(data[x][y], 64) == 0) then
						XEMap[x][y] = c;
						c = c+1;
					else				    
						XEMap[x][y] = -1;
					end
				end
			end
				
			c = 0;
			for y = 1, 32 do
				for x = 1, 32 do
					YEMap[x] = YEMap[x] or {}
					if (bit.band(data[x][y], 64) == 0) then 
						YEMap[x][y] = c;
						c = c+1;
					else				    
						YEMap[x][y] = -1;
					end
				end
			end
			
			
			 if (ROM.data[enemy_offset]:byte() == 1) then 
				 for x = 1, 32 do
					 for y = 1, 32 do
						 enemy_map[x] = enemy_map[x] or {}
						 if (XEMap[x][y] == -1) then 						 
							 enemy_map[x][y] = 255;
						 else
							 D2 = 0;
							 done = false;
							 D0 = XEMap[x][y];
							 additional_offset = enemy_offset + 1;
							 
							 while (not done) do						 
									D1 = ROM.data[additional_offset]:byte();
									if (D1 > 127) then
										D2 = D2 + bit.band(D1, 127);
										additional_offset = additional_offset + 1;
									end
									if (D2 >= D0) then
										done = true;
									else
										D2 = D2 + 1;
										additional_offset = additional_offset + 1;
									end
							 end
							 D0 = bit.band(ROM.data[additional_offset]:byte(), 15);
							 enemy_map[x][y] = D0;
						 end                            
				     end
				 end
			 else
			  	 for y = 1, 32 do
					 for x = 1, 32 do
					 	 enemy_map[x] = enemy_map[x] or {}
						 if (YEMap[x][y] == -1) then
						 	enemy_map[x][y] = 255;
						 else
							D2 = 0;
							done = false;                      
							additional_offset = enemy_offset + 1;
							while (not done) do							
						  		  D1 = ROM.data[additional_offset]:byte();
								  if (D1 > 127) then
									 D2 = D2 + bit.band(D1, 127);
									 additional_offset = additional_offset + 1;
								  end
								  if (D2 >= (YEMap[x][y])) then 
									 done = true;
								  else
									 D2 = D2 + 1;
									 additional_offset = additional_offset + 1;
								  end
							end
							D0 = bit.band(ROM.data[additional_offset]:byte(), 15);
							enemy_map[x][y] = D0;
						 end
					 end
				 end
			 end
			   

	   io.write("enemies, ")
	   
	   local objects = {}
	   
	   for y = 1, 32 do
	       --print()
		   for x = 1, 32 do
		       --io.write(string.rep(" ",3- string.len(data[x][y]))..(data[x][y]).." ")
		       -- if #objects[ID] is 0, there's no objects of that type!			    
				if     data[x][y] == 010 then
					   objects[010] = objects[010] or {type="moss"} 
					   objects[010][#objects[010]+1] = {y,x}
				elseif data[x][y] == 014 then
					   objects[014] = objects[014] or {type="puddle"} 
					   objects[014][#objects[014]+1] = {y,x}
				elseif data[x][y] == 028 then
					   objects[028] = objects[028] or {type="torch1"} 
					   objects[028][#objects[028]+1] = {y,x}
				elseif data[x][y] == 134 then
					   objects[134] = objects[134] or {type="chest"} 
					   objects[134][#objects[134]+1] = {y,x}
				elseif data[x][y] == 129 then
					   objects[129] = objects[129] or {type="greendoor"} 
					   objects[129][#objects[129]+1] = {y,x}
					   doors[#doors+1] = {y,x}
				elseif data[x][y] == 130 then
					   objects[130] = objects[130] or {type="greydoor"} 
					   objects[130][#objects[130]+1] = {y,x}
					   doors[#doors+1] = {y,x}
				elseif data[x][y] == 150 then
					   objects[150] = objects[150] or {type="angelwall"} 
					   objects[150][#objects[150]+1] = {y,x}
					   doors[#doors+1] = {y,x}
				elseif data[x][y] == 131 then
					   objects[131] = objects[131] or {type="jaildoor"} 
					   objects[131][#objects[131]+1] = {y,x}
					   doors[#doors+1] = {y,x}
				elseif data[x][y] == 009 then
					   objects[009] = objects[009] or {type="spinner"} 
					   objects[009][#objects[009]+1] = {y,x}
				elseif data[x][y] == 144 then
					   objects[144] = objects[144] or {type="goldfountain"} 
					   objects[144][#objects[144]+1] = {y,x}
				elseif data[x][y] == 029 then
					   objects[029] = objects[029] or {type="groundtorch"} 
					   objects[029][#objects[029]+1] = {y,x}
				elseif data[x][y] == 132 then
					   objects[132] = objects[132] or {type="stairsup"} 
					   objects[132][#objects[132]+1] = {y,x}
				elseif data[x][y] == 008 then
					   objects[008] = objects[008] or {type="floorhole"} 
					   objects[008][#objects[008]+1] = {y,x}
				elseif data[x][y] == 007 then
					   objects[007] = objects[007] or {type="floortrap"} 
					   objects[007][#objects[007]+1] = {y,x}
				elseif data[x][y] == 027 or data[x][y] == 155 or data[x][y] == 151 then -- CHECK HOW walls on LVLs 3/4 is diferent!
					   objects[027] = objects[027] or {type="fakewall"} 
					   objects[027][#objects[027]+1] = {y,x}
				elseif data[x][y] == 147 then
					   objects[147] = objects[147] or {type="sentinel"} 
					   objects[147][#objects[147]+1] = {y,x}
				elseif data[x][y] == 139 then
					   objects[139] = objects[139] or {type="onewaydoor"} 
					   objects[139][#objects[139]+1] = {y,x}
					   doors[#doors+1] = {y,x}
				elseif data[x][y] == 133 then
					   objects[133] = objects[133] or {type="stairsdown"} 
					   objects[133][#objects[133]+1] = {y,x}
				elseif data[x][y] == 143 then
					   objects[143] = objects[143] or {type="fountain1"} 
					   objects[143][#objects[143]+1] = {y,x}
				elseif data[x][y] == 020 then
					   objects[020] = objects[020] or {type="ceilinghole"} 
					   objects[020][#objects[020]+1] = {y,x}
				elseif data[x][y] == 021 then
					   objects[021] = objects[021] or {type="special"} 
					   objects[021][#objects[021]+1] = {y,x}
				elseif data[x][y] == 146 then
					   objects[146] = objects[146] or {type="dropping wall"}  -- a wall drops before you if you try to walk
					   objects[146][#objects[146]+1] = {y,x}
					   doors[#doors+1] = {y,x} -- NOT a door, but should work as an inverted cell door ;)
				elseif data[x][y] == 152 then
					   objects[152] = objects[152] or {type="spirit fountain"} 
					   objects[152][#objects[152]+1] = {y,x}
				elseif data[x][y] == 54 then
					   objects[54] = objects[54] or {type="darksol fight"} 
					   objects[54][#objects[54]+1] = {y,x}
				elseif data[x][y] == 54 then
					   objects[23] = objects[23] or {type="false idol indent"} 
					   objects[23][#objects[23]+1] = {y,x}
				end
				
				if  data[x][y]~=192 
				and data[x][y]~=000 
				and data[x][y]~=042 -- see moss
				and data[x][y]~=046 -- see puddle
				and data[x][y]~=060 -- see torch
				and data[x][y]~=033 -- see green door
				and data[x][y]~=034 -- see grey door
				and data[x][y]~=038 -- see chest
				and data[x][y]~=035 -- see cell door
				and data[x][y]~=041 -- see spinner
				and data[x][y]~=048 -- see gold fountain
				and data[x][y]~=061 -- see ground torch
				and data[x][y]~=036 -- see stairs up
				and data[x][y]~=040 -- see floor hole
				and data[x][y]~=039 -- see floor trap
				and data[x][y]~=059 -- see fakewall
				and data[x][y]~=051 -- see sentinel
				and data[x][y]~=043 -- see one way door
				and data[x][y]~=037 -- see stairs down
				and data[x][y]~=047 -- see fountain
				and data[x][y]~=052 -- see ceiling hole
				and data[x][y]~=053 -- see special (truth orb, etc)
				and data[x][y]~=055 -- see special 2
				and data[x][y]~=057 -- see special 2 \___ level 4 mystery, there's NOTHING in ANY version of the game (that loads)
				and data[x][y]~=025 -- see special 2 /
				and data[x][y]~=050 -- see falling wall 				
				and data[x][y]~=056 -- see spirit fountain
				then
				   objects.total = (objects.total or 0 )+1
				end
				
				local count2 = 0
				for id, obj in pairs(objects) do
				    if type(obj) == "table" then
					   count2 = count2+#obj
					end
				end
				objects.total2 = count2
		   end
	   end
	   --print()
	   
	   io.write("objects ("..objects.total..") ",objects.total2)
	   
	   self.enemy_maps[map_id] = enemy_map
	   self.maps[map_id] = data
	   self.maps[map_id].id = map_id
	   self.maps[map_id].objects = objects
	   self.maps[map_id].name = self.map_names[map_id]
	   self.maps[map_id].enemy_table =  enemy_table
	   self.maps[map_id].enemy_map =  enemy_map	   
	   self.maps[map_id].doors =  doors
	   io.write(".\n")
	   
	   
	end 
end

function ROM:load_stairs()
   self.stairs = {}
   local stairs_offset = 24901 -- again, +1, since Lua is 1-based
   for current_offset = 0, self.total_stairs-1 do
       -- forth	   
       self.stairs[#self.stairs+1] = {
                                      ROM.data[stairs_offset + current_offset * 6 + 2]:byte()+1, -- starting floor (+1 for 1-based Lua)
                                      ROM.data[stairs_offset + current_offset * 6 + 1]:byte()+1, -- starting x position
                                      ROM.data[stairs_offset + current_offset * 6 + 0]:byte()+1, -- statring y position
                                      ROM.data[stairs_offset + current_offset * 6 + 5]:byte()+1, -- target floor
                                      ROM.data[stairs_offset + current_offset * 6 + 4]:byte()+1, -- target x position
                                      ROM.data[stairs_offset + current_offset * 6 + 3]:byte()+1, -- target y position
	                                 }
   local stair = self.stairs[#self.stairs]
   print(stair[1], stair[2], stair[3], stair[4], stair[5], stair[6])

	   -- back
       self.stairs[#self.stairs+1] = {
                                      ROM.data[stairs_offset + current_offset * 6 + 5]:byte()+1, -- target floor
                                      ROM.data[stairs_offset + current_offset * 6 + 4]:byte()+1, -- target x position
                                      ROM.data[stairs_offset + current_offset * 6 + 3]:byte()+1, -- target y position
                                      ROM.data[stairs_offset + current_offset * 6 + 2]:byte()+1, -- starting floor
                                      ROM.data[stairs_offset + current_offset * 6 + 1]:byte()+1, -- starting x position
                                      ROM.data[stairs_offset + current_offset * 6 + 0]:byte()+1, -- statring y position
	                                 }
   local stair = self.stairs[#self.stairs]
   print(stair[1], stair[2], stair[3], stair[4], stair[5], stair[6])
   end      

   -- Dark Kobold's editors (yes, both; of any version; INCLUDING v09 ;p ) have a typo/error here
   -- stairs offset starts at 24900, not 24902
   -- and the format is different: CORDINATES-floor to COORDINATES-floor 
  
end

function ROM.map_char(char)
   local r = char
   if r >= 1 and r <=  9 then r = r + 19 end
   if r == 63 then r = 11 end
   if r == 67 then r = 17 end
   if r == 00 then r = 4 end
   if r == 28 then r = 114-28 end
   if r == 29 then r = 115-28 end
   if r == 70 then r = 46 - 28 end
   return r + 28
end

function ROM:load_item_icons()

   local Offset = 933864+1
   local item_icons = {}
   local item_icon_addresses = {}
   local item_icon_image_data = {}
   local off = 1   
   local items_count = self.total_items
   
   for id = 1, items_count do           
       local ioff = 1   
       local Off = Offset + (id-1) * 192
       local canvas = love.image.newImageData(16,32)
	   local image = {}
	   for x = 1, 8*4* 3 do -- 3 = rows in final image
		   for y = 1, 8*4* 2 do -- 4 = cols in final image
		       local off = Off + bit.lshift(x, 5) + bit.lshift(y,2) --( basically, Offset +4)
			   image[ioff] = bit.rshift(ROM.data[off]:byte(), 4)
			   image[ioff+1] = bit.band(ROM.data[off]:byte(), 15)
			   off = off + 1
			   image[ioff+2] = bit.rshift(ROM.data[off]:byte(), 4)		   
			   image[ioff+3] = bit.band(ROM.data[off]:byte(), 15)
			   off = off + 1
			   image[ioff+4] = bit.rshift(ROM.data[off]:byte(), 4)		   
			   image[ioff+5] = bit.band(ROM.data[off]:byte(), 15)
			   off = off + 1
			   image[ioff+6] = bit.rshift(ROM.data[off]:byte(), 4)
			   image[ioff+7] = bit.band(ROM.data[off]:byte(), 15)
			   ioff = ioff + 8
		   end
	   end
	   local off = 1
	   for xx = 0, 2 do -- 3 = rows in final image
		   for yy = 0, 1 do -- 4 = cols in final image
			   for y = 0, 7 do
				   for x = 0, 7 do				   
					   local color = colors[(image[off] or 0)+1]
					   love.graphics.setColor(color)
					   canvas:setPixel(x+yy*8, y+xx*8, color[1], color[2], color[3], 1 )
					   off = off + 1
				   end
			   end	   

		   end
	   end
	   item_icons[id] = love.graphics.newImage(canvas)	   
	   item_icon_image_data[id] = canvas
	   item_icon_addresses[id] = Off
   end

   ROM.item_icons = item_icons
   ROM.item_icon_image_data = item_icon_image_data
   ROM.item_icon_addresses = item_icon_addresses   
end

function ROM:load_items()
    -- the OG code didn't work for me. Dunno what I ported wrong...
	-- Anyway, item names are split into 2 tables:
	-- at 27108 and at 28123 (using +1, since lua's 1-based)
	-- 1st byte is the length of a substring (works for both parts)
	-- then N bytes of data that needs some conversion (ALL HAIL ROMHACKING TBL FILES!!!)
	-- add READ BYTES count to the starting OFFset
	-- rince and repeat
	
	
    local off  = 27109
	local of2  = 28124 
	for item_id = 1, self.total_items do
	    local item_name=""
	    -- 1st part
	    local namelen = self.data[off]:byte()  
		local tmp = {}
		local tmp2 = {}
		for i = 1, namelen-1 do
		    local char = self.map_char(self.data[off+i]:byte())			
	        tmp[#tmp+1] = string.char(char)
		end
		off = off + namelen
		
		-- 2nd part
		local namelen2 = self.data[of2]:byte()
		for i = 1, namelen2-1 do
		    local char = self.map_char(self.data[of2+i]:byte())
			if char == 0 then char = 4 end
	        tmp[#tmp+1] = string.char(char)
		end
		of2 = of2 + namelen2
		item_name=table.concat(tmp,"")
		

    -- merged with above to have 1 loop
	-- name data details hold true
	
	    local data = self.data[8 * item_id + 4644]:byte()
        local Cursed    = false
		local Arm       = false
		local Weap      = false
		local Helm      = false
		local Shld      = false
		local GroupAtt  = false
		local BattleUse = false
		local OutUse    = false
		local HEquip    = false
		local MEquip    = false
		local PEquip    = false
		local Unknown1  = false
		local Unknown2  = false

		-- 10100001 means: cused, not out, yes in, ???, no group attack, ???, type 0->3 (3 =helm, 2= shield, 1= arm, 0=weap)
		if bit.band(data, 128)  > 0 then Cursed    = true end
		if bit.band(data,  64)  > 1 then OutUse    = true end
		if bit.band(data,  32)  > 1 then BattleUse = true end
		if bit.band(data,  16)  > 0 then Unknown1  = true end
		if bit.band(data,   8)  > 0 then GroupAtt  = true end
		if bit.band(data,   4)  > 0 then Unknown2  = true end
		if bit.band(data,   3) == 3 then Helm      = true end
		if bit.band(data,   3) == 2 then Shld      = true end
		if bit.band(data,   3) == 1 then Arm       = true end
		if bit.band(data,   3) == 0 then Weap      = true end

		data = self.data[1 + 8 * item_id + 4644]:byte()
		
		if bit.band(data, 1) > 0 then HEquip = true end
		if bit.band(data, 2) > 0 then MEquip = true end
		if bit.band(data, 4) > 0 then PEquip = true end
		
		SpecialEff = math.floor(self.data[1 + 8 * item_id + 4644]:byte() / 8)
		Cost       = 256 * self.data[2 + 8 * item_id + 4644]:byte() + 
		                   self.data[3 + 8 * item_id + 4644]:byte()
		Mod1Value  = self.data[4 + 8 * item_id + 4644]:byte()
		Mod2Value  = self.data[6 + 8 * item_id + 4644]:byte()
		ModVal1    = self.data[5 + 8 * item_id + 4644]:byte()
		ModVal2    = self.data[7 + 8 * item_id + 4644]:byte()
		
		if     Mod1Value == 128 then Mod1 = "Weapon Factor"
		elseif Mod1Value == 129 then Mod1 = "Armor Factor"
		elseif Mod1Value ==   0 then Mod1 = "(none)"
		elseif Mod1Value == 144 then Mod1 = "Critical %"
		elseif Mod1Value == 145 then Mod1 = "# Attacks"
		else   Mod1 = "Unknown - " .. Mod1Value end

		if     Mod2Value == 128 then Mod2 = "Weapon Factor"
		elseif Mod2Value == 129 then Mod2 = "Armor Factor"
		elseif Mod2Value ==   0 then Mod2 = "(none)"
		elseif Mod2Value == 144 then Mod2 = "Critical %"
		elseif Mod2Value == 145 then Mod2 = "# Attacks"
		else Mod2 = "Unknown - " .. Mod2Value end
		
		data = {
		  id = item_id,
		  name = item_name,
		  cost = Cost,
		  cursed = Cursed,
		  type =  {Weap, Helm, Arm, Shld, weapon = Weap, armor = Arm, helmet = Helm, shield = Shld},
		  group_attack = GroupAtt,
		  usability = {BattleUse, OutUse, battle = BattleUse, outside = OutUse},
		  equip = {HEquip, MEquip, PEquip, hiro=HEquip, milo = MEquip, pyra = PEquip},
		  effect = SpecialEff,
		  modifiers = {{Mod1Value, ModVal1, Mod1, Mod1Value = ModVal1}, {Mod2Value, ModVal2, Mod2, Mod2Value = ModVal2}},
		  ['equipable?'] = Unknown1,
		  alchemist_item = Unknown2,
		  bits = Bits,
		  
		}
		
		self.items[item_id] = data
		
	end
	
end

function ROM:load_enemies()
    -- same as with item names, length, then N bytes. ONE part. Phew.	
	-- again +1 to 28657 for 1-based Lua
    local name_offset = 28658
	local enemy_offset = 216858
	for enemy_id =0, self.total_enemies do
	    local enemy_name = ""
	    local namelen = self.data[name_offset]:byte()  
		local tmp = {}
		for i = 1, namelen-1 do
		    local char = self.map_char(self.data[name_offset+i]:byte())						
	        tmp[#tmp+1] = string.char(char)			
		end
		name_offset = name_offset + namelen
		enemy_name=table.concat(tmp,"")
		
		local ModelBox  = bit.band(self.data[enemy_offset + 24 * enemy_id]:byte(), 252) / 4
		local ColorFlip = bit.band(self.data[enemy_offset + 24 * enemy_id]:byte(), 3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 1]:byte(), 252) / 4
		local Flipud    = false
		local Fliplr    = false
		local chy 	    = false
		local chb       = false
		local chuer     = false		
 
		if bit.band(ColorFlip, 128) > 0 then Flipud = true end
		if bit.band(ColorFlip,  64) > 0 then Fliplr = true end
		if bit.band(ColorFlip,  32) > 0 then chy    = true end
		if bit.band(ColorFlip,  16) > 0 then chb    = true end
		if bit.band(ColorFlip,   8) > 0 then chuer  = true end
		
		local Color  = bit.band(ColorFlip, 7)
		local Un5s0  = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 1]:byte(),   3) *    8 + 
		               bit.band(self.data[enemy_offset+ 24 * enemy_id+ 2]:byte(), 224) /   32
		local Un7s0  = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 2]:byte(),  31) *    4 + 
		               bit.band(self.data[enemy_offset+ 24 * enemy_id+ 3]:byte(), 192) /   64
		local EXP    = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 3]:byte(),  63) *   64 + 
					   bit.band(self.data[enemy_offset+ 24 * enemy_id+ 4]:byte(), 252) /    4
		local Gold   = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 4]:byte(),   3) * 1024 + 
		               bit.band(self.data[enemy_offset+ 24 * enemy_id+ 6]:byte(), 192) /   64 + 
					           (self.data[enemy_offset+ 24 * enemy_id+ 5]:byte()) * 4
		local Drop   = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 6]:byte(),  63) *    2 + 
		               bit.band(self.data[enemy_offset+ 24 * enemy_id+ 7]:byte(), 128) /  128	
		local Rate   = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 7]:byte(), 112) /   16
		local RateT  = "1/" .. tostring(math.pow(2, (10 - Rate)))
		local RateV  = 1/math.pow(2, (10 - Rate))
		local Regen  = bit.band(self.data[enemy_offset+ 24 * enemy_id+ 7]:byte(), 12) / 4
		local RegenL = Regen * 50
		local Un2s01 = bit.band(self.data[enemy_offset+ 24 * enemy_id + 7]:byte(), 3)
		local HP     = self.data[enemy_offset+ 24 * enemy_id + 8]:byte() * 4 + bit.band(self.data[enemy_offset + 24 * enemy_id + 9]:byte(), 192) / 64
		local MP     = bit.band(self.data[enemy_offset + 24 * enemy_id  + 9]:byte(), 63) *  16 + bit.band(self.data[enemy_offset + 24 * enemy_id + 10]:byte(), 240) / 16
		local Ag     = bit.band(self.data[enemy_offset + 24 * enemy_id + 10]:byte(), 15) *  64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 11]:byte(), 252) /  4
		local Att    = bit.band(self.data[enemy_offset + 24 * enemy_id + 11]:byte(),  3) * 256 + self.data[enemy_offset + 24 * enemy_id + 12]:byte()
		local Def    = self.data[enemy_offset + 24 * enemy_id + 13]:byte() * 4 + bit.band(self.data[enemy_offset + 24 * enemy_id + 14]:byte(), 192) / 64

		local Un2s1  = bit.band(self.data[enemy_offset + 24 * enemy_id + 14]:byte(),  48) / 16
		local Un2s2  = bit.band(self.data[enemy_offset + 24 * enemy_id + 14]:byte(),  12) /  4
		local Un2s3  = bit.band(self.data[enemy_offset + 24 * enemy_id + 14]:byte(),   3)
		local Un2s4  = bit.band(self.data[enemy_offset + 24 * enemy_id + 15]:byte(), 192) / 64
		local Un2s5  = bit.band(self.data[enemy_offset + 24 * enemy_id + 15]:byte(),  48) / 16
		local Un2s6  = bit.band(self.data[enemy_offset + 24 * enemy_id + 15]:byte(),  12) /  4
		local Un2s7  = bit.band(self.data[enemy_offset + 24 * enemy_id + 15]:byte(),   3)
		local Un2s8  = bit.band(self.data[enemy_offset + 24 * enemy_id + 16]:byte(), 192) / 64
		local Un2s9  = bit.band(self.data[enemy_offset + 24 * enemy_id + 16]:byte(),  48) / 16
		local Un2s10 = bit.band(self.data[enemy_offset + 24 * enemy_id + 16]:byte(),  12) /  4
		local Un2s11 = bit.band(self.data[enemy_offset + 24 * enemy_id + 16]:byte(),   3)
		
		local Uf1 = false
		local Uf2 = false
		if bit.band(self.data[enemy_offset + 24 * enemy_id + 17]:byte(), 128) > 0 then Uf1 = true end
		if bit.band(self.data[enemy_offset + 24 * enemy_id + 17]:byte(),  64) > 0 then Uf2 = true end
		
		local Un2s12 = bit.band(self.data[enemy_offset + 24 * enemy_id + 17]:byte(), 48) / 16 + 1 -- +1, Lua thing )_)
		local Un2s13 = bit.band(self.data[enemy_offset + 24 * enemy_id + 17]:byte(), 12) /  4 + 1
		local Un8s1  = bit.band(self.data[enemy_offset + 24 * enemy_id + 17]:byte(),  3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 18]:byte(), 252) / 4 + 1
		local Un8s2  = bit.band(self.data[enemy_offset + 24 * enemy_id + 18]:byte(),  3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 19]:byte(), 252) / 4 + 1
		local Un8s3  = bit.band(self.data[enemy_offset + 24 * enemy_id + 19]:byte(),  3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 20]:byte(), 252) / 4 + 1
		local Un8s4  = bit.band(self.data[enemy_offset + 24 * enemy_id + 20]:byte(),  3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 21]:byte(), 252) / 4 + 1
		local Un8s5  = bit.band(self.data[enemy_offset + 24 * enemy_id + 21]:byte(),  3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 22]:byte(), 252) / 4 + 1
		local Un8s6  = bit.band(self.data[enemy_offset + 24 * enemy_id + 22]:byte(),  3) * 64 + bit.band(self.data[enemy_offset + 24 * enemy_id + 23]:byte(), 252) / 4 + 1
			
		self.enemies[enemy_id+1] = {
			--name = Iname:lower():gsub(Iname:lower():sub(1,1), Iname:sub(1,1):upper()),		
			id = enemy_id+1,
			name = enemy_name,
			sprite_id = ModelBox,
			flip = {Fliplr, Flipud, horizontal = Fliplr, vertical = Flipud}, 
			color_id = Color,
			hue = {chy, chb, chuer, yellow = chy, red = chb, blue = chuer },
			dodge_ability = Un2s01, -- in (0-3) range		
			number_of_actions = Un2s11,
			resist = {fire = Un2s1, -- in (0-3) range		
				   ice = Un2s2, 
				   lightning = Un2s3, 
				   wind = Un2s4, 
				   burst = Un2s5, 
				   slow = Un2s6, 
				   muddle = Un2s7, 
				   sleep = Un2s8, 
				   screen = Un2s9,
				   desoul = Un2s10,
				   darkness = Un7s0}, -- 0 = vulnerable, 32/96 = immune 1.2
			strong_party_ai = Un2s12, -- 0 = use 1st attack type, 1 = loop through all attacks, 2= random1 , 3 = random2
			weak_party_ai = Un2s13, -- same four as in strong
			two_attacks = Uf1,   --random
			unknown_flag2 = Uf2, -- dark knight, tortolyde, killwave, kromeball, crystal ooze, brimstone, ragnarok, deathpaw, gargoyle, lancerot, mandagora, deathbringer, living armor, necromancer, troll (65) and down
			actions = {Un8s1, Un8s2, Un8s3, Un8s4, Un8s5, Un8s6}, -- IDs of possible attacks/actions
			exp = EXP,
			gold = Gold,
			--drop = self.items[Drop], -- unnecessary, but it auto-nils if there's no drop outside of datas table			
			drop_id = Drop,		
			drop_rate = RateV,
			drop_rate_text = RateT,
			drop_rate_val = Rate,
			regen = {type= Regen, value = RegenL},
			max_hp = HP,
			max_mp = MP,
			base_agility = AG,
			base_attack = Att,
			base_defence = Def,		
		}
		
	end
end

function ROM:get_bits(byt) 
   local byte = byt
   local tmp = {}
   for i = 1, 8 do
       tmp[9-i] = bit.band(byte, 1)
	   --print(bit.band(byte, 1))
	   byte = bit.rshift(byte,1)
   end
   return tmp   
end

function ROM:get_bytes(bi) 
   local bit = bi   
   local byte = 0
   for i = 1, 8 do
       byte = byte+2^bit[9-i]	   
   end
   return byte
end

function ROM:get_letter(Offset)
	--[[ 
	2bpp = 2 bytes per pixel planar
	given this:
	78 00 84 00 
	84 00 84 00 
	84 00 84 00 
	84 00 84 00 
	84 00 84 00 
	78 00 00 00 
	00 00 00 00                                      

	we decode that to this:
	01111000 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	10000100 00000000
	01111000 00000000
	00000000 00000000
	00000000 00000000
	00000000 00000000

	I have TWO planes which should be "merged" together to get a color
	now, seeing that the 2nd one is just a bunch of zeroes, it's not going to add anything to the sum

	so I need to read a byte, then convert it to bits
	then I read a second byte and also convert it to bits
	then I sum those up and display a pixel from colors_2bpp_planar[SUM_OF_BITS_VALUE]

	]]

	local letter = {}
	local limit = 8
	local width = 3
	for i = 0, 13 do 
		local bit1 = self:get_bits(self.data[Offset+i*2]:byte())	
		local bit2 = self:get_bits(self.data[Offset+i*2+1]:byte())
		local bit3 = {}
		if bit1[1]+bit2[1] == 2 then
		   bit2[1] = 0
		   bit2[9] = 0
		   bit1[9] = 1
		   limit = 9		
		end		
		bit2[9] = bit2[9] or 0
		bit1[9] = bit1[9] or 0
		for j = 1, limit do 
		    if (bit1[j] or 0)>0 then
			   width = math.max(j,width)
			end
			bit3[j] = bit1[j]+bit2[j]
			letter[#letter+1] = colors[bit3[j]+1]			
		end				
	end
	letter.limit = limit
	letter.width = width
    return letter
end

function ROM:generate_font1()
	local Offset = 987340+1
	local length = glyphs:len()
	local imagedata = love.image.newImageData(10*length, 14)		
	local glyph_offset = 1
	for i = 1, glyphs:len() do	
	    local glyph = self:get_letter(Offset+(i-1)*28)		
		for j=1, #glyph do		    
		    local color = glyph[j]
            local r, g, b, a = color[1], color[2], color[3], color[4]
			imagedata:setPixel(glyph_offset-1,0,1,0,1,1)
			imagedata:setPixel(glyph_offset+math.fmod((j-1),glyph.limit), math.floor((j-1)/glyph.limit), r,g,b,a)
		end
		glyph_offset = glyph_offset+glyph.width+1+1		
	end	
	imagedata:setPixel(glyph_offset-1,0,1,0,1,1)
	return love.graphics.newImageFont(imagedata, glyphs), imagedata
end

return ROM

--[[
io.write("\n")
for i = 1, #ROM.maps do
    for j = 1, #ROM.maps[i].enemy_table do
        io.write(ROM.maps[i].enemy_table[j].. "\t")
	end
	io.write(ROM.maps[i].name.."\n")
end


io.write("\n")
for i = 1, 32 do
	for j = 1, 32 do
	    if ROM.maps[1][j][i] == 192 then
		   io.write("🟥")
		else
		   io.write("  ")
		end
	end
	io.write("\n")
end
]]
--while true do end
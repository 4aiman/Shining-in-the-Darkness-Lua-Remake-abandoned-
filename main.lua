
-- Color multipler
local COLOR_MUL = love._version >= "11.0" and 1 or 255

function gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or (1 * COLOR_MUL)}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end

local black_gradient  = gradientMesh("vertical", {0,0,0,0.8}, {0,0,0,0.8}, {0,0,0,0.8}, {0,0,0,0.6}, {0,0,0,0.0})
local white_gradient  = gradientMesh("vertical", {1,1,1,0.8}, {1,1,1,0.8}, {1,1,1,0.8}, {1,1,1,0.0})
local blue_gradient   = gradientMesh("vertical", {0,0.1,0.6,0.8}, {0,0.1,0.6,0.8}, {0,0.1,0.6,0.8}, {0,0.1,0.6,0.0})
local yellow_gradient = gradientMesh("vertical", {0.6,0.6,0,0.8}, {0.6,0.6,0,0.8}, {0.6,0.6,0,0.8}, {0.6,0.6,0,0.0})
local red_gradient    = gradientMesh("vertical", {0.6,0.1,0,0.8}, {0.6,0.1,0,0.8}, {0.6,0.1,0,0.8}, {0.6,0.1,0,0.0})

local console = require ("lovedebug")

local DEBUG = true and false
local draw_ui = true and false

local w = 1280
local h = 720
local aspect_ratio = 16/9
local GabrielaRegular36 = love.graphics.newFont("assets/fonts/Gabriela-Regular.ttf",36)
local OpenGOST36        = love.graphics.newFont("assets/fonts/OpenGostTypeA-Regular.ttf",36)
local OpenGOST72        = love.graphics.newFont("assets/fonts/OpenGostTypeA-Regular.ttf",72)
local world_scale = 1
local ROM
local wall_texture  = {"master.png"} -- ONE per "level"
local wall_model    = {"path", "bottomless", "topless"}
local wall_textures = {} -- will contain actual images; for production can be image data Kappa
local models = {}
local torch_strength = 0.5
local torch_color = {1,0.7,0}
local object_models = {}
local view_distance = 6
local current_location = {x = 0, y = 0, z = 0, dirx = 0, dirz = -1}
local door_timer
local just_stopped = true -- this breaks current_location if set to false, need to sync that with stating_pos
local level_name_timer = 0

	
--local color = {1,1,1}       -- party torch light color
local color = {1,0.7,0}       -- party torch light color
local ambientcolor = {1,1,1}  -- global ambient color
local ambient_strength = 0.1  -- global ambient strength
local hand_torch_strength = 4


local match = string.match
function string.trim(s)
   return match(s,'^()%s*$') and '' or match(s,'^%s*(.*%S)')
end

function to_number(value)
  return value and 1 or 0
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
-----------
local image_cache = {}
local dfont = love.graphics.getFont()
local ogni = love.graphics.newImage
function love.graphics.newImage(filename,t)
   
   local file
   if type(filename) == "userdata" then
      file = true
   else
      file = love.filesystem.getInfo(filename or "easteregg.png")
   end
   
   if file then 
      if not image_cache[filename] then 
	     image_cache[filename] = ogni(filename)
	  end
	     
	  return image_cache[filename]	  
   end

   
   local canvas = love.graphics.newCanvas(128,128)
   local font = love.graphics.getFont()
   
   love.graphics.setCanvas(canvas)   
   love.graphics.setFont(dfont)
   
   love.graphics.setColor(math.max(0,math.random()-0.2), math.max(0,math.random()-0.2), math.max(0,math.random()-0.2))   
   --if t then love.graphics.setColor(0,0,1) print ("test") end
   love.graphics.rectangle("fill",0,0,128,128)
   love.graphics.setColor(0,0,0)
   love.graphics.print( filename or "no texture", 128, 10, 0,1,2)
   love.graphics.setColor(1,1,1)
   love.graphics.print( filename or "no texture", 128, 10, 0,1,2)
   love.graphics.setCanvas()   
   love.graphics.setFont(font)  
   return canvas
end
-----------


local g3d 
local canvas = love.graphics.newCanvas()
local current_level = {}
local moving = nil


--local OGL = require("OGL")
local inspect = require "inspect"

local enemies = require("data.enemies")
local items   = require("data.items")
local objects = require("data.objects")

local encounter_rate = 0.2
local state = "dungeon"
local enemies3d = {}


for i in ipairs(items) do
    items[i].icon = love.graphics.newImage("assets/items/".. i .. ".png")
end


--local xbrz = require("xbrz")
--xbrz.scaleXBRZ(obj)
local menu_level = 0
-- A adds a level
-- B subtracts a level
-- can move only with 4 == 0
-- on picking target the menu level goes to 0
local menu_selected_index = 0
local menu_option_mode = nil
local menu_type_selecor = {village = 1, dungeon = 2, battle = 3, shop = 4, smith = 5, church=6}

local menu = {} -- a thing to draw

local menu_system = { name = "base menu", 
  [1] = {name = "Village menu", id = 1,
         [1] = {name = "Enter", id = 1, },  -- enters a building
         [4] = {name = "Magic", id = 4, },  -- opens up magic menu    (pick user)
         [2] = {name = "Items", id = 2,   -- opens up inventory     (pick user)
		        [1] = {name = "Use" ,  id = 1,}, 
		        [4] = {name = "Give" , id = 4,},
		        [2] = {name = "Equip", id = 2,},
		        [3] = {name = "Drop",  id = 3,},
		 },  
         [3] = {name = "Status", id = 3, action = "person status"}, -- opens up status window (pick user)  -- can R1 L1	
		}, 
  [2] = {name = "Stanby menu",   id = 1,
         [1] = {name = "Search", id = 1, },  -- searches the place in front of you, opens chests, gives info on items (do I need this?)
         [4] = {name = "Magic",  id = 4, },  -- opens up magic menu (same cast thing, but magic should be labeled: "out_of_battle_use = true")
         [2] = {name = "Items",  id = 2,     -- opens up items menu (same as regular menu)
		        [1] = {name = "Use",   id = 1, action = "item drop"}, 
		        [4] = {name = "Give",  id = 4, action = "person give"},
		        [2] = {name = "Equip", id = 2, action = "person equip"},
		        [3] = {name = "Drop",  id = 3, action = "item drop"},
		 },  
         [3] = {name = "Status", id = 3, action = "person status"}, -- same status window, can r1 l1
		},
  [3] = {name = "Battle menu", id = 1,    -- if in battle you have to set a target. Can't heal enemies
         [1] = {name = "Attack", id = 1, action = "enemy group pick"}, -- pick whom, if counter<3 then show the same menu
         [4] = {name = "Magic",  id = 4, action = "magic person pick"},  -- pick what, then whom
         [2] = {name = "Items",  id = 2, action = "item pick"},  -- picks an item
         [3] = {name = {[1]="Run", [2]="Defend", [3]="Defend",}, id = 3,},
		},
  [4] = {name = "Shop menu", id = 1,  
         [1] = {name = "Buy",   id = 1,},
         [4] = {name = "Deals", id = 4,},
         [2] = {name = "Sell",  id = 2,},
         [3] = {name = "-",     id = 3,},      -- should be exit, but..
		},
  [5] = {name = "Blacksmith menu", id = 1,
         [1] = {name = "",      id = 1,},
         [4] = {name = "Forge", id = 4,},
         [2] = {name = "Fix",   id = 2,},
         [3] = {name = "",      id = 3,},
		},
  [6] = {name = "Priest menu",    id = 1,
         [1] = {name = "Revive",  id = 1,},
         [4] = {name = "Cure",    id = 4,},
         [2] = {name = "Promote", id = 2,},
         [3] = {name = "Status",  id = 3,},
		},
}

for i=1, 6 do 
	menu_system[i].parent = menu_system
	for j = 1, 4 do
		menu_system[i][j].parent = menu_system[i]
		for k = 1, 4 do
		    ((menu_system[i][j] or {})[k] or {}).parent = menu_system[i][j]
		end
	end
end


-- HalOO VennOh
-- Hallo Venner
-- Hallo Kompiser

function menu_control(dt)
   -- do nothing if below zero, preserve no menu   
   if menu_lock then return end
   if menu_level<=0 then 
      menu_level = 0 	  
      menu = {} 
	  menu_option_mode = nil
   end
   
   -- controls selection of 4 options:
	  if not menu_option_mode then
	      local og_menu = menu
		  if menu_level>0 then		  
		     --print(type(menu[menu_selected_index]), menu_last_change, menu.name, (menu.parent or {name="stub"}).name)
			 if menu.name then
			    if menu_last_change < 0 then
                   menu_selected_index = menu.id or 1				
				   menu = (menu.parent or {})				   
				   print(menu.id, 1)
				else
				   -- going INTO a menu				   
				   menu = (menu or menu_system)[menu_selected_index]
				   local item = (menu or menu_system)[menu_selected_index] 
				   if item == nil then
				       print('There are better ways to do this, but screw that!')
				       print('Will be checking for what to do RIGHT in here.')
				       print('Probably still be polling the "action" field,')
				       print('but all the functions will be called from here (open_inventory, open_magiclist, etc)')
					   menu_lock = true -- will prevent choosing stuff until needed 
					   -- THIS branch crashes the game ATM
					   
					   prev_state = state
					   state = menu.action
					   min_menu_level = menu_level
					   
					   print(prev_state, state)
					   
				   end
				   	 menu_selected_index = 1
				end
			 else
				menu = menu_system[menu_type_selecor[state]]
				menu_selected_index = 1
			 end			 
		  else
			  menu = {} --
		  end
		  
		  if menu ~= og_menu then
		     menu_option_mode = true
		  end
	  end
      menu_selection_cooldown = 0.2
	
   
   -- controls auto menu pop-up
   if state == "battle" and old_state~="battle" then   
      print("into battle")
      menu_level = 1
	  menu = menu_system[3]
	  menu_option_mode = true	  
   end
   
   
   if state ~= "battle" and old_state=="battle" then   
      print("outta battle")
      menu = {}
	  menu_level = 0
	  menu_option_mode = nil
   end
   
  -- print(menu.name, menu_level, menu_last_change or "")
   
   old_state = state   
end

menu_level = 0
state = "dungeon"


local party = {}

local character = {
  name = "",
  level = 1,
  magic = {},
  items = {}, -- equipped ones here as well
  exp = 0,
  max_hp = 0,
  max_mp = 0,
  hp = 0,
  mp = 0,
  iq = 0,
  speed = 0,
  luck = 0,
  attack = 0,
  defence = 0,
  weapon = 0, -- use these 2 to sum up weapon & armor stats
  armor = 0,  -- will be neat to use during rendering of statistics
}

function check_level_gain(c)
   if c.level == 99 then return 0 end -- MY GOD, how STUPID it was to forget c.!!! COuldn't get levels ONLY if I'm in level99 labirynth
   local counter = 0
   local threshold = c.exp_table[c.level+1]
   while c.exp >= threshold do
         counter = counter + 1
   end
   return counter
end

function create_character(data)
   local tmp = {}
   for k,v in pairs(character) do
	   --print(k,v, data[k], counter)
       tmp[k] = data[k] or v -- make sure I can use named AND unnames params
   end
   
   local counter = 0
   for k,v in pairs(data) do
       counter = counter + 1
	   --print(k,v, data[k], counter)
       tmp[k] = data[k] or data[counter] or v -- make sure I can use named AND unnames params
   end

   table.insert(party,tmp)
   --print("----------")
   return tmp
end

function update_character(c, data)
   local counter = 0
   for k,v in pairs(c) do
       counter = counter + 1
       c[k] = data[k] or data[counter] or v -- override stat if needed, will usualy be like update_character(c, {weapon = c.attack+item.attack})
   end
   return tmp
end

function get_forward(direction) 
   -- direction is needed if we press "back" and walk 
   local direction = direction or 1
   local xtobe = (g3d.camera.position[1] + world_scale*6*direction*math.sin(g3d.camera.direction))/(world_scale*6)
   local ztobe = (g3d.camera.position[3] + world_scale*6*direction*math.cos(g3d.camera.direction))/(world_scale*6)
   -- grey magic
   return math.floor(xtobe+0.5), math.floor(ztobe+0.5), xtobe, ztobe
end

function check_forward(direction)
   local free = true
   local direction = direction or 1
   local xtobe, ztobe = get_forward(direction)   
   local cell = (current_level.layout[ztobe] or {})[xtobe] or 192
   local block = (current_level[ztobe] or {})[xtobe] or {}
   --print((block.model_info or {}).door)
   if cell == 192 
   or ((block.model_info or {}).door and direction < 0) 
   or (cell == 132 and direction < 0) 
   or (cell == 133 and direction < 0) 
   then free = nil end 
   return DEBUG or free, cell
end

function get_closest_door(x,z)
   local res
   local distance = math.huge
   for _, door in ipairs(current_level.layout.doors) do
	  current_distance = math.sqrt((door[1]-x)*(door[1]-x)+(door[2]-z)*(door[2]-z))
	  --print(door[1],door[2], current_distance, distance)
      if current_distance < distance then
	     distance = current_distance
	     res = door
	  end
   end
   return res, distance
end

function update_doors(dt)
   local opened_door_count = 0
   local x, z = current_location.x, current_location.z
   local fx, fz = get_forward()
   for _, door in ipairs(current_level.layout.doors) do
      
	  local xoffset, zoffset = door[1], door[2]
      local door_instance = (current_level[zoffset] or {})[xoffset]	  
	  if door_instance then 	  
  	     if (fx == door[1] and fz == door[2]) or (x == door[1] and z  == door[2]) then 
		    door_instance.door_timer_grow = -1			
		 else 
		    --if door_instance.opened then -- dump ROM data, edit it? put all keys into KEY items
		       door_instance.door_timer_grow =  1			
			--end
		 end
		-- print(_, door[1], door[2], door_instance.door_timer_grow or 1)
	  
		  door_instance.door_timer = (door_instance.door_timer or 0) - dt* door_instance.door_timer_grow
		  if door_instance.door_timer <= 0 then 
		     door_instance.door_timer = 0 
		  elseif door_instance.door_timer >= 1.95 then 
		         door_instance.door_timer = 1.95 
		  else
		     if not ((x == door[1] and z == door[2])) then
		        opened_door_count = opened_door_count + 1
			 end
		  end
				 
		  
			 if not ((fx == door[1] and fz == door[2]) or (x == door[1] and z == door[2])) then
				-- increase opened doors counter for ONLY those which are not directly ahead or at the same position
				
			 end
		  
	  end
      
   end
   return opened_door_count
end

function math.sign(number)
   if number > 0 then
      return 1
   elseif number < 0 then
      return -1
   else
      return 0
   end
end

function update_controls(dt)
    -- can't go anywhere untill ALL of the doors are closed , except the one ahead of you and the one you're standing in

    ------- engine controls
	if love.keyboard.isScancodeDown("q") then
	   menu_lock = false
	end
	
	------- battle controls
    if state == "battle" then
	----------- auto-resets battles 
		   state = "dungeon"
		   menu_level = 0
    ---------
		if love.keyboard.isScancodeDown("e") then
		   state = "dungeon"
		   menu_level = 0
		   print("--")
		end	
	end

	local opened_doors_count = update_doors(dt)
	--print("opened doors:",opened_doors_count, state)	
	if opened_doors_count > 0 then return end
 

	------- move controls 
    if moving or state == "battle" or menu_level>0 then return end		
	
    if love.keyboard.isScancodeDown("w") or love.keyboard.isScancodeDown("up") then
	   moving = {dir =  1, dist = world_scale*6} -- dir +/-1 + dist on movement, dir +/-1 + angle on turning
	   if not check_forward() then  moving = nil end
    end
    if love.keyboard.isScancodeDown("s") or love.keyboard.isScancodeDown("down") then
	   moving = {dir = -1, dist = world_scale*6} -- dir +/-1 + dist on movement, dir +/-1 + angle on turning
	   if not check_forward(-1) then  print("nope") moving = nil end
    end

    if love.keyboard.isScancodeDown("a") or love.keyboard.isScancodeDown("left") then
	   moving = {dir = -1, angle = math.pi/2} -- dir +/-1 + dist on movement, dir +/-1 + angle on turning
    end
    if love.keyboard.isScancodeDown("d") or love.keyboard.isScancodeDown("right") then
	   moving = {dir =  1, angle = math.pi/2} -- dir +/-1 + dist on movement, dir +/-1 + angle on turning
    end
	
	
end

function love.keypressed(k,s,r)

  console.keypressed(key, scancode, isrepeat)

	if s == "f12" then
	   if not screenshot_timer then
	      love.graphics.captureScreenshot(os.date("%m %d %Y @ %H-%M ")..".png")
	      --love.graphics.captureScreenshot("test.png")
		  screenshot_timer = 0.2
	   end
	end
	
	
    if k == "space" then
	   g3d.camera.position[2] = g3d.camera.position[2] - 1
	   g3d.camera.lookInDirection(g3d.camera.position[1],g3d.camera.position[2],g3d.camera.position[3])
	end
    if k == "lshift" then
	   g3d.camera.position[2] = g3d.camera.position[2] + 1
	   g3d.camera.lookInDirection(g3d.camera.position[1],g3d.camera.position[2],g3d.camera.position[3])
	end


      if not menu_lock then

       if     love.keyboard.isScancodeDown("w") then
	          menu_selected_index = 1
       elseif love.keyboard.isScancodeDown("a") then
	          menu_selected_index = 4
       elseif love.keyboard.isScancodeDown("s") then
	          menu_selected_index = 3
       elseif love.keyboard.isScancodeDown("d") then
	          menu_selected_index = 2
	   end      

		  if love.keyboard.isScancodeDown("left") then
			 menu_level = menu_level - 1		 
			 menu_option_mode = nil
			 menu_last_change = -1			
		  end
		  if love.keyboard.isScancodeDown("down") then	   
			 menu_level = menu_level + 1
			 menu_option_mode = nil
			 menu_last_change = 1
	         	 
		  end
	  else  -- NOT main menu, but still some sort of a menu
	     
	     if state == "person status" then
		    if old_state ~= state then menu_selected_index = 1 end
		    
			  if love.keyboard.isScancodeDown("left") then
				 menu_level = menu_level -1 
				 print(min_menu_level, menu_level)
				 if min_menu_level == menu_level +1 then				    
				    menu_option_mode = nil
				    menu_last_change = -1
				    menu_lock = nil
				    state = prev_state
				    prev_state = nil					
				 end
			  end

			  if love.keyboard.isScancodeDown("down") then				 
				 state = "person status show"
				 person = menu_selected_index
				 -- this needs to stop any other menu interaction but going back.
				 -- regardless of what is  to be pressed
			  end

		   if     love.keyboard.isScancodeDown("w") then
				  menu_selected_index = menu_selected_index - 1
				  print("-1")
		   end
		   if love.keyboard.isScancodeDown("s") then
				  menu_selected_index = menu_selected_index + 1
				  print("+1")
		   end      

		   if menu_selected_index <1 then 
		      menu_selected_index = #party
			  print("max") 
		   end
		   if menu_selected_index >#party then 
		      menu_selected_index = 1 
			  print("one")
		   end		   
		   
		   print(menu_selected_index)

		 elseif state == "person status show" then
		    if s~="f12" then
		       state = "person status"
			end 
		 end	     
		 
	  
	  end
	  

end

function guess_rotation(layout,x,y)
   -- return a NUMBER
   -- left, right, top, bottom holes are:
   -- 1     2      4    8
   
   local holes = 0
   
   if (layout[x] or {})[y] ~=192 then -- we're in a corridor (or something)
      if ((layout[x] or {})[y-1] or 192) ~= 192 then
	     holes = holes + 4
	  end
	  if ((layout[x] or {})[y+1] or 192) ~= 192 then
	     holes = holes + 8
	  end
	  if ((layout[x-1] or {})[y] or 192) ~= 192 then
		 holes = holes + 1
	  end

	  if ((layout[x+1] or {})[y] or 192) ~= 192 then
		 holes = holes + 2
	  end
   
   --[[
   local holes = 0
   
   if layout[x][y] >0 then
	  if (layout[x][y-1] or 0) > 0 then
		  holes = holes + 1
	  end
	  if (layout[x][y+1] or 0) > 0 then
	     holes = holes + 2
	  end
	  if ((layout[x-1] or {})[y] or 0) > 0 then
		 holes = holes + 4
	  end

	  if ((layout[x+1] or {})[y] or 0) > 0 then
		 holes = holes + 8
	  end
      ]]

--[[
HOLES (passages, North = top):
 1   left                  cc0000 
 2   right                 008000  
 3   left right            cc8000   
 4              top        0000cc     
 5   left       top        cc00cc   
 6        right top        0080cc    
 7   left right top        cc80cc   
 8                  bottom 333333
 9   left           bottom ff3333
10        right     bottom 33b333
11   left right     bottom ffb333
12              top bottom 3333ff
13   left       top bottom ff33ff
14        right top bottom 33b3ff
15   left right top bottom ffb3ff

--strangely enough, something BROKE and now lef-right is cc7Foo :/
-- had to add math.ceil to fix it.
-- but then b2 turned into b3
-- on one hand it's better to avoid more math.*
-- on the other - consistency matters, and it DID break once, so..
-- it's loading time only and not THAT bad anyway
]]
   end
   return holes
end

function holes_to_submodel(holes)
   local submodel, rotation = 0, {0,0,0} -- defaults to full box w/o rotation
    if holes == 01 then submodel = 1 rotation = {0,  math.pi/1, 0} end
    if holes == 02 then submodel = 1 rotation = {0,          0, 0} end
    if holes == 03 then submodel = 2 rotation = {0,          0, 0} end
    if holes == 04 then submodel = 1 rotation = {0, -math.pi/2, 0} end
    if holes == 05 then submodel = 5 rotation = {0,  math.pi/1, 0} end
    if holes == 06 then submodel = 5 rotation = {0, -math.pi/2, 0} end
    if holes == 07 then submodel = 3 rotation = {0,  math.pi/1, 0} end
    if holes == 08 then submodel = 1 rotation = {0,  math.pi/2, 0} end
    if holes == 09 then submodel = 5 rotation = {0,  math.pi/2, 0} end
    if holes == 10 then submodel = 5 rotation = {0,          0, 0} end
    if holes == 11 then submodel = 3 rotation = {0,          0, 0} end
    if holes == 12 then submodel = 2 rotation = {0,  math.pi/2, 0} end
    if holes == 13 then submodel = 3 rotation = {0,  math.pi/2, 0} end
    if holes == 14 then submodel = 3 rotation = {0, -math.pi/2, 0} end
    if holes == 15 then submodel = 4 rotation = {0,          0, 0} end   
   return submodel, rotation
end

function load_textures()
   -- stores ALL wall textures
   wall_textures = {}   
   for i=1, #ROM.maps do
       wall_textures[i] = love.graphics.newImage("assets/textures/".. (wall_texture[i] or wall_texture[1])) -- at least ONE should be specified
   end
end   

function load_models()
    for model_id, model_path in ipairs(wall_model) do	
		models[model_id] = {}
		-- assume path models have 6 variants
		for i = 0, 5 do  
		    -- i = # of holes
		    -- order is: orange, purple, blue, red, top, bottom
		    -- for some objects some of the models are irrelevant
		    -- EVERY model SHOULD share THE SAME orientation, thus THE SAME rotation, guessed from the level layout data
		    -- right now, DESPITE having multiple versions of a tile, rotation and model are hardcoded in the level data :(
		    -- -Y up, Z = forward
		    local filler = ""
		    if i>0 then 
				filler = "."..string.rep("0",3-string.len(i)) .. i
		    end
		    local model = "assets/models/"..model_path.. filler .. ".obj"
		    local info = love.filesystem.getInfo(model)
			-- still, check if file really exists. Dunno what to do if it isn't, but oh, well...
			if info then 
				models[model_id][i] = g3d.newModel(model, nil, nil, nil, {world_scale*3,world_scale*2,world_scale*3}, nil, true)		  
				models[model_id][i].name = model_path
				models[model_id][i]:makeNormals()
			end
	    end
	end
end

function load_object_models()
   for object_id, model_info in pairs(objects) do
       -- store ALL info from "objects.lua" in object_models[object_id]
	   -- model = model_info, REAL vertices are in model_info.model
	   model_info.id = object_id
	   model_info.center = model_info.center or 2.3
	   object_models[object_id] = object_models[object_id] or model_info
	   object_models[object_id].id = object_id
       local model_path = model_info.model
	   --[[
	     0-5 holes determine orientation, but I don't know it here, just preparing
		 (model_info.count or 1) shows if model shoud be loaded twice and mirrored... can I do this in Lua? by moving all points as needed? meh, just load those twice >:)
	   ]]
       
	   for i = 0, 5 do -- I'll ALLWAYS have 5 models (or copies/proxies/pointers/whatever)
	       -- ok, let's ASSUME there's IS ".obj" part in model_info.model
		   -- if will be the same for all 6 variants
		   object_models[object_id][i] = {}
	       local full_model_path = "assets/models/"..model_path	   
		   local full_texture_path = "assets/textures/"..model_info.texture
		   --print(full_texture_path)
           -- but if it's not there, replace old path with a new one(s)
	       if not model_path:find(".obj") then
		      local filler = ""
			  if i>0 then 
			     filler = "."..string.rep("0",3-string.len(i)) .. i
		      end
		      full_model_path = "assets/models/"..model_path.. filler .. ".obj"
		   end
	   
		   -- now I have the correct path
		   local info = love.filesystem.getInfo(full_model_path)
		   -- check if it's there and load
		   if info then
			     -- welp, I CAN load a model, but what if it's paired? 
				 -- Dang...
				 -- let's load it ONCE, but store new positions/rotations/scales... it'll work, right?
				 model_info.translation = model_info.translation or {model_info.x, model_info.y, model_info.z}
				 local model3d = g3d.newModel(full_model_path, 
				                              full_texture_path, 
								 			  model_info.translation, 
											  model_info.rotation, 
											  {world_scale*3*(model_info.scale or 1), world_scale*2*(model_info.scale or 1), world_scale*3*(model_info.scale or 1)}, 
											  model_info.flipU or false, 
											  model_info.flipV or true)
				 if model_info.invert_normales then model3d:makeNormals(true) end
				 -- now model3d stores the model we can rotate etc
			     -- actually, if it's not paired, then just assign -_- 
				 -- also, I need only ONE of the couple if 2<i<5 ... 
				 -- but it's complicated, so I won't load anything at all :p
				 
				 -- anyway, we don't need 2 models, just some rotations ;)
				 object_models[object_id][i].model = model3d
		   end
	   end
   end
end


function load_level(id)
    local level = {}
    local point_light_count = (#(ROM.maps[id].objects[28] or {}) + #(ROM.maps[id].objects[29] or {}))*2 +  -- torches x2, they're paired
							  #(ROM.maps[id].objects[143] or {}) + -- fountains
							  #(ROM.maps[id].objects[144] or {}) + -- gold fountains
							  #(ROM.maps[id].objects[14] or {})    -- puddles
    local objects_total = ROM.maps[id].objects.total
   
    level.layout = ROM.maps[id] 
    level.name = level.layout.name
	level.id = level.layout.id
    
	--if id == 1 then 
	   level.start_pos = {31,17}
    --end

	for i = 1, #level.layout do
	    --print()
	    for j = 1, #level.layout[i] do
		    
			level[i]    = level[i] or {}
			level[i][j] = level[i][j] or {}
			
			local cell3d = level[i][j]
			local cell = level.layout[i][j]
			local holes = guess_rotation(level.layout, i, j)
			local submodel, rotation = holes_to_submodel(holes)						
			
			--if cell == 192 then
			--   cell = 0
			--end

			--io.write(string.rep(" ",3-string.len(cell))..cell.." ")
			--print(i,j, holes)
			
			if cell == 192 then
			   cell = 0
			else
			   cell = 1
			end
			
			--io.write(cell)
			
			if cell > 0 then
			   cell3d.box      = cell3d.box      or models[cell][submodel] 
			   cell3d.rotation = cell3d.rotation or rotation 
			   --cell3d.box.mesh:setTexture(wall_textures[id])
			   cell3d.holes = holes -- can be used for orienting other object via simple table lookup
			   cell3d.submodel = submodel -- can be used for orienting other object via simple table lookup			   
			end
		end
		
	end
	print()
	-- ADD OBJECT MODELS FROM objects!!!

	
	print(level.layout.name .. " has ".. objects_total .. " objects total")
	print(level.layout.name .. " has ".. point_light_count .. " light sources total")


	local shader = love.filesystem.read("lighting.frag")
	-- reserve 10 more point lights than needed, just in case
	shader = shader:gsub("#define LIGHTS <LIGHTS_COUNT>", "#define LIGHTS ".. point_light_count+10) 	
	-- store the shader in the level var
    local lightingShader = love.graphics.newShader("g3d/g3d.vert", shader)
	level.lightingShader = lightingShader
    
	local light_source = 1
    -- and iteraet AGAIN to set static point lights
	for object_type_id, objects_ in pairs(level.layout.objects) do	    	
	    if type(objects_) == "table" then -- I have some other fields there which are numbers -_-		   
			for object_id, object in ipairs(objects_) do		    
			    if object_models[object_type_id] then -- I don't have ALL the models (and I won't, cause I don't need thoes seeThing ones)				    					
					local x, y = object[2], object[1]
					local cell = level[x][y]					
					local model_info = object_models[object_type_id] 					
					local second_model_info = object_models[-object_type_id]
					local required_box = model_info.requires or 1							
					
					local submodel = cell.submodel or 0
					local couples = {}
					local holes = cell.holes
					local center = model_info.center or 2.3
					--local holes = level[object[2]][object[1]].holes
					--print(inspect(couples))
					if object_id == 132 then
					  -- print(x,y)
					end

                    
                    cell.box = models[required_box][submodel]	
					cell.model_info = model_info					
					cell.model = model_info[submodel] --cell.model_info.model
					
					
					 if second_model_info then
					    cell.second_model = second_model_info[submodel]
					 end
					

					if (model_info.count or 1) > 1 then 					   
					   -- "holes" contain the correct rotation.
					   -- so.. I can use that to rotate both models in the couple accordingly
					   -- and rotate each accordingly
					   -- I DON'T NEED any processing in load_object_models, that would be innacurate anyway
					   -- meaning THIS v CAN BE SIMPLIFIED
					   local pos1 = {x=model_info.x or 0, y=model_info.y or 0, z=model_info.z or 0}
					   local pos2 = {x=model_info.x or 0, y=model_info.y or 0, z=model_info.z or 0}
					   local rot1 = {x=model_info.rotation_x or 0, y=model_info.rotation_y or 0, z=model_info.rotation_z or 0}
					   local rot2 = {x=model_info.rotation_x or 0, y=model_info.rotation_y or 0, z=model_info.rotation_z or 0}
						if     holes ==  0 then
						elseif holes ==  1 or holes ==  2 or holes ==  3 then -- left & right
							   pos1.x = pos1.x - center
							   pos2.x = pos2.x + center
							   rot1.y = rot1.y - math.pi/2
							   rot2.y = rot2.y + math.pi/2
						elseif holes ==  4 or holes == 8 or holes == 12 then -- top
							   pos1.z = pos1.z - center
							   pos2.z = pos2.z + center
							   rot1.y = rot1.y + math.pi
							   rot2.y = rot2.y + 0
						elseif holes ==  5 then -- left & top
							   pos1.z = pos1.z + center
							   pos2.x = pos2.x + center
							   rot1.y = rot1.y + 0--0
							   rot2.y = rot2.y + math.pi/2
						elseif holes ==  6 then -- right & top
							   pos1.z = pos1	.z - center
							   pos2.x = pos2.x + center
							   rot1.y = rot1.y + math.pi
							   rot2.y = rot2.y + math.pi/2
						elseif holes ==  7 then -- left & right & top
							   pos1.x = pos1.x + center
							   pos2.x = math.huge
							   rot1.y = rot1.y + math.pi/2 --(may be -rot)
							   rot2.y = rot2.y + 0--0
						elseif holes ==  8 then -- bottom
							   pos1.x = pos1.x - center
							   pos2.x = pos2.x + center
							   rot1.y = rot1.y + 0--0
							   rot2.y = rot2.y + 0--rot2.y + math.pi
						elseif holes ==  9 then -- left & bottom
							   pos1.x = pos1.x - center
							   pos2.z = pos2.z + center
							   rot1.y = rot1.y - math.pi/2
							   rot2.y = rot2.y + 0--0
						elseif holes == 10 then -- right & bottom
							   pos1.x = pos1.x - center
							   pos2.z = pos2.z - center
							   rot1.y = rot1.y - math.pi/2
							   rot2.y = rot2.y - math.pi
						elseif holes == 11 then -- left & right & bottom
							   pos1.x = pos1.x - center
							   pos2.x = math.huge
							   rot1.y = rot1.y - math.pi/2
							   rot2.y = rot2.y + 0--0
						elseif holes == 12 then -- top & bottom
							   pos1.x = pos1.x - center
							   pos2.x = pos2.x + center
							   rot1.y = rot1.y + 0--0
							   rot2.y = rot2.y + 0--rot2.y + math.pi ?
						elseif holes == 13 then -- left & top & bottom
							   pos1.z = pos1.z + center
							   pos2.x = math.huge
							   rot1.y = rot1.y + 0--0
							   rot2.y = rot2.y + 0--0
						elseif holes == 14 then -- right & top & bottom
							   pos1.z = pos1.z - center
							   pos2.x = math.huge
							   rot1.y = rot1.y + math.pi
							   rot2.y = rot2.y + 0--0
						elseif holes == 15 then -- letf & right & top & bottom
							   pos1.x = math.huge
							   pos2.x = math.huge
							   rot1.y = rot1.y + 0--0
							   rot2.y = rot2.y + 0--0
						end
					    couples.pos1 = pos1
					    couples.pos2 = pos2
					    couples.rot1 = rot1
					    couples.rot2 = rot2
						cell.couples = couples
						--print(inspect(cell.couples))
					end

					--print(light_source)
					if    object_type_id == 14 then		-- puddles are lit 
                        
						lightingShader:send("pointLights[" .. light_source .. "].position", {y*world_scale*6, 1.5, x*world_scale*6})
						lightingShader:send("pointLights[" .. light_source .. "].color",    {0.5,0.5,1})
						lightingShader:send("pointLights[" .. light_source .. "].strength", 2)		
						lightingShader:send("pointLights[" .. light_source .. "].max_distance", 4)
						light_source = light_source + 1
					elseif object_type_id == 143 then	-- fountains are lit
						lightingShader:send("pointLights[" .. light_source .. "].position", {y*world_scale*6, 0, x*world_scale*6})
						lightingShader:send("pointLights[" .. light_source .. "].color",    {0.5,0.5,1})
						lightingShader:send("pointLights[" .. light_source .. "].strength", 2)		
						lightingShader:send("pointLights[" .. light_source .. "].max_distance", 4)
						light_source = light_source + 1
					elseif object_type_id == 144 then	-- GOLD fountains are lit
						lightingShader:send("pointLights[" .. light_source .. "].position", {y*world_scale*6, 0, x*world_scale*6})
						lightingShader:send("pointLights[" .. light_source .. "].color",    {1,1,0.5})
						lightingShader:send("pointLights[" .. light_source .. "].strength", 2)		
						lightingShader:send("pointLights[" .. light_source .. "].max_distance", 4)
						light_source = light_source + 1
					elseif object_type_id == 28 or object_type_id == 29 then
					   -- print(model_info.name .. " requires ".. (model_info.requires or 1), x, y, world_scale, y*world_scale*6)
					   
						local pos1 = {x = y*world_scale*6+cell.couples.pos1.x, y = 0+cell.couples.pos1.y-1, z = cell.couples.pos1.z+x*world_scale*6}
						local pos2 = {x = y*world_scale*6+cell.couples.pos2.x, y = 0+cell.couples.pos2.y-1, z = cell.couples.pos2.z+x*world_scale*6}						

						--print(table.concat({pos1.x/6, pos1.y, pos1.z/6},","))
						lightingShader:send("pointLights[" .. light_source .. "].position", {pos1.x, pos1.y, pos1.z})
						lightingShader:send("pointLights[" .. light_source .. "].color",    torch_color)
						lightingShader:send("pointLights[" .. light_source .. "].strength", torch_strength/2)	
						lightingShader:send("pointLights[" .. light_source .. "].max_distance", 18)		
						light_source = light_source + 1
						lightingShader:send("pointLights[" .. light_source .. "].position", {pos2.x, pos2.y, pos2.z})
						lightingShader:send("pointLights[" .. light_source .. "].color",    torch_color)
						lightingShader:send("pointLights[" .. light_source .. "].strength", torch_strength/2)	
						lightingShader:send("pointLights[" .. light_source .. "].max_distance", 18)		
						light_source = light_source + 1
					end
				end
			end
		end
	end
   

   level_name_timer_on = 1
   return level
end

function love.load(arg)
    ROM = require("sitd")
	
	ROM:load("assets/OG_ROM/SHININGD_UE.GEN")
	ROM.font1 = ROM:generate_font1()
	ROM.font1:setFilter("nearest")
   
    love.graphics.setDefaultFilter("nearest", "nearest", 16)
	
    g3d = require "g3d"
	
    --test_models()
	g3d.camera.up = {0,-1, 0}


	create_character( require ("data/characters/Hiro") )
	create_character( require ("data/characters/Milo") )
	create_character( require ("data/characters/Pyra") )
	
	party[1].hp = 1
	party[2].hp = 0
	-- I need this to change things via effects.lua
	party.camera = g3d.camera

	love.window.setMode(w, h, {depth=16})
	love.window.setVSync( false )-- yeah, don't forget this, cause 98% on 1660S in NOT good XD
	g3d.camera.aspectRatio = aspect_ratio
    g3d.camera.updateProjectionMatrix()
	g3d.camera.direction = - math.pi/2 + 4* math.pi
	
    load_textures()
    load_models()
	load_object_models()
	current_level = load_level(1)

	for i = 1, #enemies do
	    enemies3d[i] = g3d.newModel("assets/models/".."enemy_plane.obj", "assets/upscaled_sitd/"..i..".png",  {0,0,0})
	end

    Timer = 0
    --print(current_level.start_pos[1], current_level.start_pos[2], current_level.start_pos[1]*6, current_level.start_pos[2]*6, get_forward())
	--os.exit()
	
	g3d.camera.lookInDirection(current_level.start_pos[1]*world_scale*6, 0, current_level.start_pos[2]*world_scale*6, -math.pi/2)

	print( love.graphics.getRendererInfo( ))



end

function math.sign(number)
    return number >= 0 and 1 or -1
end

function handle_stairs(dt)

   for id, stair in ipairs(ROM.stairs) do              
       
       local x, z = math.floor(current_location.x+0.5),  math.floor(current_location.z +0.5)
	   local floor = current_level.id
	      --print(table.concat(stair, ", "), x, stair[2], z, stair[3], floor, stair[1] == floor, x == stair[2], z == stair[3])

	   if  stair[1] == floor
	   and x == stair[2]
	   and z == stair[3]
	   then
	       print(id)
	       moving = nil
	       if floor ~= stair[4] then		      
	          current_level = load_level(stair[4])
		   end
		   print(inspect(stair), current_level.name or floor, id)
		   --print(stair[5]+current_location.dirz, 0, stair[6]+current_location.dirx)
		   -- +current_location.dirx
		   -- +current_location.dirz
		   --[[
		   local xtb, ztb = get_forward()
		   local block_ahead = (current_level.layout[ztb] or {})[xtb]
		   while block_ahead == 192 do
		         
		         g3d.camera.direction = g3d.camera.direction + math.pi/2
				 xtb, ztb = get_forward()
				 block_ahead = (current_level.layout[ztb] or {})[xtb]
				 current_location = {x=math.ceil(g3d.camera.position[1]/6 -0.5), y=math.ceil(g3d.camera.position[2]/4 -0.5), z=math.ceil(g3d.camera.position[3]/6 -0.5)}
				 current_location.dirx = xtb - current_location.x
				 current_location.dirz = ztb - current_location.z
		   end ]]
		   --g3d.camera.lookInDirection((stair[5]+current_location.dirx)*world_scale*6, 0, (stair[6]+current_location.dirz)*world_scale*6)
		   print("teleporting to level", stair[4], "to", stair[5]+current_location.dirx,stair[6]+current_location.dirz)
		   g3d.camera.lookInDirection((stair[5]+current_location.dirx)*world_scale*6, 0, (stair[6]+current_location.dirz)*world_scale*6)
		   
		   if block_ahead == 192 then
		      moving = {dir =  1, angle = math.pi/2}		      
		   end
		   
		   break
	   end
   
   end
end

function love.update(dt)

    Timer = Timer + dt

	
	
	
	
	if state == "battle" then
	   --print("battle")
	else
	   if just_stopped then
			local xtb, ztb = get_forward()
			current_location = {x=math.ceil(g3d.camera.position[1]/6 -0.5), y=math.ceil(g3d.camera.position[2]/4 -0.5), z=math.ceil(g3d.camera.position[3]/6 -0.5)}
			current_location.dirx = xtb - current_location.x
			current_location.dirz = ztb - current_location.z
			local door, dist = get_closest_door(current_location.x,current_location.z)			
			local block_ahead = (current_level.layout[ztb] or {})[xtb]
			local block_afoot = (current_level.layout[current_location.z] or {})[current_location.x]
			local object_ahead = objects[block_ahead] or {}
			local object_afoot = objects[block_afoot] or {}
			if object_ahead.door then object_ahead.door_timer = 1 end
			if object_afoot.door then object_afoot.door_timer = 1 end			   
			-- now, we need to update ALL doors every tick and make them CLOSE depending on the timer
			-- maybe even disabling any input untill the door has closed
			--print(door[1], door[2], dist, current_location.x,current_location.z)
			handle_stairs()
			--just_stopped = false -- ?			
		end
		if moving then


		   if moving.dist then -- means we're walking
			  local speed = 15
			  local dist = math.min(moving.dist, dt * speed)

             
			 g3d.camera.position[1] = g3d.camera.position[1] + dist*moving.dir*math.sin(g3d.camera.direction)
			 g3d.camera.position[3] = g3d.camera.position[3] + dist*moving.dir*math.cos(g3d.camera.direction)
			 g3d.camera.lookInDirection(g3d.camera.position[1],g3d.camera.position[2],g3d.camera.position[3])

			  moving.dist = moving.dist - dist
			  if moving.dist <=0 then
				 moving = nil
				 just_stopped = true
				 if moving == nil then
				   --print("moving = nil")
				   if check_forward() then
					  chance = math.random()
					  --print("ch")
					  if chance<encounter_rate then -- need to di this only when stopped after movement (see below) | set var just_stopped and run this test then!
						 --just_stopped = false
						 --state = "battle"
						 --menu_level = 1
					  end
				   end
				 end  
			  end


		   elseif moving.angle then -- means we're turning
			  local speed = 7.5
			  local angle = dt * speed
			   
			  if moving.angle < angle then
			     angle = moving.angle
				 moving.angle = 0
			  else
			     moving.angle = moving.angle - angle
			  end
			  g3d.camera.direction = g3d.camera.direction+ angle*moving.dir
			  
			  if g3d.camera.direction > math.pi*4 then g3d.camera.direction = g3d.camera.direction - math.pi*2 end
			  if g3d.camera.direction < math.pi*2 then g3d.camera.direction = g3d.camera.direction + math.pi*2 end
			  g3d.camera.lookInDirection(nil,nil,nil, g3d.camera.direction)

			  
			  if moving.angle <=0 then
				 moving = nil			
                 just_stopped = true				 
				 
				 if moving == nil then
				   --print("moving = nil")
				   if check_forward() then
					  chance = math.random()
					  --print("ch")
					  if chance<encounter_rate then -- need to di this only when stopped after movement (see below) | set var just_stopped and run this test then!
						 --just_stopped = false
						 --state = "battle"
						 --menu_level = 1
					  end
				   end
				 end  
			  end

		   end
		end
	end
 

	update_controls(dt)
	menu_control(dt)

   if level_name_timer_on then
      level_name_timer_on = level_name_timer_on - dt
	  if level_name_timer_on <=0 then 
	     level_name_timer_on = nil
		 level_name_timer = 2
	  end
   end
		 
   if level_name_timer then
	  level_name_timer = level_name_timer - dt
	  if level_name_timer <= 0 then level_name_timer = nil end
   end

    -- shaders need to be processed *last*, as I may change the current level
	--------------------------------------------------------
	-- setting [2] to -3 causes ceiling to NOT be lit (normals stuff)
	current_level.lightingShader:send("lightPosition", {g3d.camera.position[1],-g3d.camera.position[2]-1,g3d.camera.position[3]})
	current_level.lightingShader:send("viewPos", {g3d.camera.position[1],g3d.camera.position[2],g3d.camera.position[3]})
	--color = rotate_hue(color,1)
	current_level.lightingShader:send("lightColor", color)
	current_level.lightingShader:send("ambientLightColor", ambientcolor)
	current_level.lightingShader:send("ambient", ambient_strength)
	current_level.lightingShader:send("torchStrength", hand_torch_strength * (1-math.random()/50)*3)
	----g3d.shader:send("isCanvasEnabled", true)
    g3d.camera.updateViewMatrix(current_level.lightingShader)
    g3d.camera.updateProjectionMatrix(current_level.lightingShader)
	--------------------------------------------------------

   
end

local test = love.graphics.newImage("abcdefghijklmnopqrstuvwxyz", true)

function draw_minimap()
    love.graphics.setCanvas(canvas)
	love.graphics.clear()

    
	for i = 1, #current_level do
	    for j = 1, #current_level[i] do
		    if current_level.layout[i][j] ~= 192 then
			   --love.graphics.setColor(current_level[i][j].color)
			   love.graphics.setColor(0,0,0)
		       love.graphics.rectangle("fill", (i)*5-1, (j)*5-1, 7, 7)
			   love.graphics.setColor(0.2,0.2,0)
		       love.graphics.rectangle("fill", g3d.camera.position[3]/6*5-1, g3d.camera.position[1]/6*5-1, 7, 7)
			end
		end
	end
	for i = 1, #current_level do
	    for j = 1, #current_level[i] do
		    if current_level.layout[i][j] ~= 192 then
			   --love.graphics.setColor(current_level[i][j].color)
			   love.graphics.setColor(1,1,1)
		       love.graphics.rectangle("fill", (i)*5, (j)*5, 5, 5)
			   love.graphics.setColor(0.8,0,0)
		       love.graphics.rectangle("fill", g3d.camera.position[3]/6*5, g3d.camera.position[1]/6*5, 5, 5)
			   
			end
		end
	end
	
	local _,_, fx,fz = get_forward()
	love.graphics.setColor(0.0,0.4,0)
	love.graphics.rectangle("fill", fz*5, fx*5, 5, 5)
	
	local dxz = get_closest_door(current_location.x, current_location.z)
	if dxz then -- not evry floor has doors
	   love.graphics.setColor(0.0,0,0.4)
	   love.graphics.rectangle("fill", dxz[2]*5, dxz[1]*5, 5, 5)
	end


    for id, stair in ipairs(ROM.stairs) do
	    if stair[1] == current_level.id then
		   love.graphics.setLineWidth(1)
	       love.graphics.setColor(0.4,0,0.4)
		   
	       love.graphics.line(stair[3]*5,  stair[2]*5,    (stair[3]+1)*5, (stair[2]+1)*5)
	       love.graphics.line(stair[3]*5, (stair[2]+1)*5, (stair[3]+1)*5, (stair[2])*5)	       
	    end
	end

	--love.graphics.setColor(1.0,0.4,0.4)
	--love.graphics.line(dxz[2]*5, dxz[1]*5,fz*5, fx*5)
	
	love.graphics.setColor(1,1,1)
	love.graphics.setCanvas()
	love.graphics.draw(canvas)

end

function love.graphics.printb(...)
   love.graphics.print(...)
   arg[2] = (arg[2] or 0) + 1
   love.graphics.print(...)
   arg[2] = (arg[2] or 0) -1
   love.graphics.print(...)
end

function love.draw()
--draw_minimap()
--if true then return end

love.graphics.setFont(OpenGOST36)
    love.graphics.setColor(1,1,1) 
	local door_near = false
	--print("----- draw -------")
	for i = 1, #current_level do
	    for j = 1, #current_level[i] do		    
		    if (math.abs(g3d.camera.position[3]/6 - i) < view_distance) and (math.abs(g3d.camera.position[1]/6 - j) < view_distance) then -- don't draw too far			    
				local cell = current_level.layout[i][j]
				if cell ~=192 then -- it's a corridor!               
				   local block = current_level[i][j]
				   if block.box then			  			   
				      if block.box.mesh then
					     block.box.mesh:setTexture(wall_textures[current_level.id])
					  else
					     print("no mesh @",i,j)
					  end
					  
					  if block.model then
					     
					     local couples = block.couples
						 
						 if not block.model_info.replace_model then						    
							block.box:setTransform({j*world_scale*6,0,i*world_scale*6}, block.rotation)
							block.box:draw(current_level.lightingShader)
						 end

					     if couples then
						    
							--[[
							if block.model_info.id == 129 or
							   block.model_info.id == 130 or
							   block.model_info.id == 139 or
							   block.model_info.id == 150 then
							   local lever = 0
							   if (math.abs(current_location.x - j) + math.abs(current_location.z - i) < 2) then
							       lever = 1
							   end	
						    block.model.model:setTransform(
							 { j*world_scale*6+ couples.pos2.x+
							   lever*math.cos( block.rotation[2])*
							             (-math.cos((door_timer or 0))*
										 (block.model_info.center or 0) + (block.model_info.center or 0)),
                                0+couples.pos2.y,
								i*world_scale*6+couples.pos2.z+
							   lever*math.sin( block.rotation[2])*
							             (-math.sin((door_timer or 0))*
										 (block.model_info.center or 0) + (block.model_info.center or 0)),
								}, 
								{couples.rot2.x,couples.rot2.y,couples.rot2.z})
							]]
							local offsetx = (block.door_timer or 0)/2* -math.cos(block.rotation[2])*block.model_info.center*2
							local offsetz = (block.door_timer or 0)/2* -math.sin(block.rotation[2])*block.model_info.center*2
							block.model.model:setTransform({j*world_scale*6+ couples.pos1.x+offsetx,0+couples.pos1.y,i*world_scale*6+couples.pos1.z+offsetz}, {couples.rot1.x,couples.rot1.y,couples.rot1.z})
						    block.model.model:draw(current_level.lightingShader)

							block.model.model:setTransform({j*world_scale*6+ couples.pos2.x-offsetx,0+couples.pos2.y,i*world_scale*6+couples.pos2.z-offsetz}, {couples.rot2.x,couples.rot2.y,couples.rot2.z})
							--block.model.model:setTransform({j*world_scale*6+couples.pos2.x,0+couples.pos2.y,i*world_scale*6+couples.pos2.z}, {couples.rot2.x,couples.rot2.y,couples.rot2.z})
						    block.model.model:draw(current_level.lightingShader)

						 else -- NO couples
						    local rotation = {block.rotation[1]+(block.model_info.rotation_x or 0), block.rotation[2]+(block.model_info.rotation_y or 0), block.rotation[3]+(block.model_info.rotation_z or 0)}
							local position = {(block.model_info.x or 0)*world_scale*6+j*world_scale*6, (block.model_info.y or 0)*world_scale*4+0, (block.model_info.z or 0)*world_scale*6+i*world_scale*6}
							
						    block.model.model:setTransform(position, rotation) 
						    block.model.model:draw(current_level.lightingShader)
							if block.second_model then
								block.second_model.model:setTransform({j*world_scale*6,0,i*world_scale*6})
								block.second_model.model:draw(current_level.lightingShader)
							end
						 end
						 --print(inspect(block.model_info), block.model.setTransform)
					  else				     
						 block.box:setTransform({j*world_scale*6,0,i*world_scale*6}, block.rotation)
						 block.box:draw(current_level.lightingShader)
					  end
				   else
					  print(block.holes, i,j)
				   end
				else
				   --print("no box at", i,j)
				end
			end
		end
	end
	
	if state == "battle" then	
	   local fx,fy = get_forward()
	   enemies3d[1]:setTransform({fx*world_scale*6,2,fy*world_scale*6}, {0, g3d.camera.direction, 0}, {1,1,1})
	   enemies3d[1]:draw()
	end
	
	
	if state == "person status" then	   
	   for i = 1, #party do		   	      
	       if party[i].joined then -- draw only if joined
		   
			   love.graphics.setColor(0,0.1,0.6,0.8)
			   love.graphics.rectangle("fill", 10, 10 + 205*(i-1), w-20, 200, 8)		   
			   love.graphics.setColor(1,1,1)
			   
			   if menu_selected_index == i then 
				  love.graphics.setColor(1,0,0)
				  
			   end			   
			   love.graphics.rectangle("line", 10, 10 + 205*(i-1), w-20, 200, 8)
		   end
       end
	   
	end
	
	
	if state == "person status show" then	   
	   local char = party[person]
	   love.graphics.setColor(0,0.1,0.6,0.8)
	   love.graphics.rectangle("fill", 10, 10 , w-20, 700, 8)		   
	   love.graphics.setColor(1,1,1)
	   love.graphics.rectangle("line", 10, 10 , w-20, 700, 8)
       
	   love.graphics.print(char.name, 20+(200-OpenGOST36:getWidth(char.name))/2, 30)
	   local imw, imh = party[person].portrait:getDimensions()
	   love.graphics.draw(party[person].portrait, 20, 20, 0, 240/imw, 680/imh)

	   love.graphics.rectangle("line",20, 20, 240, 680)
	   
	   love.graphics.printb("LEVEL",   270, 20)
	   love.graphics.printb("HP",      270, 50)
	   love.graphics.printb("MP",      270, 80)
	   love.graphics.printb("ATTACK",  270, 110)
	   love.graphics.printb("DEFENCE", 270, 140)
	   
	   
	   love.graphics.print(char.level,   470, 20)
	   love.graphics.print(char.hp .. " / " .. char.max_hp ,  470, 50)
	   love.graphics.print(char.mp .. " / " .. char.max_mp,   470, 80)
	   love.graphics.print(char.attack,  470, 110)
	   love.graphics.print(char.defence, 470, 140)


	   love.graphics.printb("SPEED",  670, 20)
	   love.graphics.printb("LUCK",   670, 50)
	   love.graphics.printb("IQ",     670, 80)
	   love.graphics.printb("WEAPON", 670, 110)
	   love.graphics.printb("ARMOR",  670, 140)
	   
	   
	   love.graphics.print(char.speed,  870, 20)
	   love.graphics.print(char.luck,   870, 50)
	   love.graphics.print(char.iq,     870, 80)
	   love.graphics.print(char.weapon, 870, 110)
	   love.graphics.print(char.armor,  870, 140)
	   
	   
	   love.graphics.printb("EXPERIENCE",     270, 170)
	   love.graphics.print(char.exp .. " points, " .. char.exp_table[char.level+1] .. " points more till level ".. char.level+1,  470, 170)
	   
	   -- speed
	   -- luck 
	   -- weapon
	   -- armor
	   -- iq
	   
	   love.graphics.printb("ITEMS",     270, 230)
	   
	   
	   for _, id in ipairs(char.items or {}) do
	      local xoff, yoff = 270+40+ math.floor((_-1)/5)*250, 270+ (_-1)*45  - math.modf((_-1) / 5)*5*45
		  
	      local item = items[id]
	      local imw, imh = item.icon:getDimensions()
		  local tw, th = OpenGOST36:getWidth("eq"), OpenGOST36:getHeight("eq")
	      love.graphics.print(items[id].name, xoff, yoff)
		  love.graphics.draw(items[id].icon, xoff-40, yoff+1, 0, 36/imw, 36/imh)
		  love.graphics.setColor(0,0,0, 0.8)
		  love.graphics.rectangle("fill", xoff-tw*0.5-2-5, yoff-th*0.5+45-5,tw*0.5+4,th*0.5, 4)
		  love.graphics.setColor(1,1,1)
		  love.graphics.printb("eq", xoff-tw*0.5-5, yoff-th*0.5+45-5,0,0.5)
	   end

--[[
	   love.graphics.printb("MAGIC",     270, 500)
	   
	   for _, id in ipairs(char.items or {}) do
	      local item = items[id]
	      local imw, imh = magic.icon:getDimensions()
	      love.graphics.print(magic[id].name, 270+40, 500+ (_-1)*45)	      
		  love.graphics.draw(magic[id].icon, 270, 500+ (_-1)*45+1, 0, 36/imw, 36/imh)
	   end
	   
	   ]]
	   
	   --[[
level 1 10      10
defence 0       10      50
name Hiro       10      90
max_hp 10       10      130
armor 0 10      170
hp 2    10      210
luck 0  10      250
speed 0 10      290
iq 0    10      330
items table: 0x2c84c490 10      370
max_mp 0        10      410
exp 0   10      450
magic table: 0x2c84c468 10      490
attack 0        10      530
mp 0    10      570
weapon 0        10      610
	   
	   ]]
	   
	end

	love.graphics.print((moving or {}).dist or "", 250, 700,0,0.5)
	--love.graphics.print(math.floor(math.deg(g3d.camera.direction) or 0 + 0.5) , 100, 700,0,0.5)
	--love.graphics.print(math.cos(g3d.camera.direction) .. " " .. math.sin(g3d.camera.direction) , 100, 700,0,0.5)
	

	--print(current_location.dirx, current_location.dirz, xtb, ztb)
	love.graphics.print((current_location.dirx or "") .. " " .. (current_location.dirz or "") , 900, 700,0,0.5)

   if state == "dungeon" then
       
	   love.graphics.push()
	   if draw_ui then 
	       love.graphics.draw(black_gradient, 0, 0, 0, w, 150)
		   for i = 1, #party do
		       --love.graphics.setBlendMode("add")
			   love.graphics.setColor(1,1,1,0.5)
			   love.graphics.setBlendMode("add","alphamultiply")
			   
			   if party[i].hp <= 0 then
			      love.graphics.draw(red_gradient,(w-900)/2+(i-1)*300, 0, 0, 280, 120)
				  --love.graphics.setColor(0.6,0.6,0,0.4)
			   elseif party[i].hp/party[i].max_hp <= 0.3 then
			      love.graphics.draw(yellow_gradient,(w-900)/2+(i-1)*300, 0, 0, 280, 120)
				  --love.graphics.setColor(0.6,0.1,0,0.4)
			   else
			      love.graphics.draw(blue_gradient,(w-900)/2+(i-1)*300, 0, 0, 280, 120)

			   end
			   
			   
			   
			   
			   if i< #party then
			      --love.graphics.setBlendMode("lighten","premultiplied")
				  love.graphics.setColor(1,1,1,0.5)
			      love.graphics.draw(white_gradient, (w-900)/2+(i-1)*300+290, 0, 0, 3, 150)   
				  --
			   end
			   love.graphics.setBlendMode("alpha")
			   love.graphics.setColor(1,1,1,1)
			   

			   --love.graphics.setColor(1,1,1,0.8)
			   --love.graphics.setLineWidth(8)
			   --love.graphics.rectangle("line", (w-900)/2+(i-1)*300, 10+10, 280, 100, 8)
			   --love.graphics.setColor(0.5,0.5,0.5,0.8)
			   --love.graphics.setLineWidth(4)
			   --love.graphics.rectangle("line", (w-900)/2+4+(i-1)*300, 10+10+4, 280-8, 100-8, 8)		   

			   local namew = OpenGOST36:getWidth(party[i].name)*0.7
			   local namex = ((w-900)/2+(i-1)*300)+(280-namew)/2

			   --love.graphics.setColor(0,0,0)
			   --love.graphics.rectangle("fill", namex - 20, 10-5, namew+40, 30, 5 )

			   love.graphics.setColor(1,1,1,0.8)
			   love.graphics.print(party[i].name, namex, 10-5, 0, 0.72)

			   love.graphics.setColor(0,0,0,0.8)
			   love.graphics.printb("HP", (w-900)/2+4+(i-1)*300+8+2, 3+10+10+4+4+2,    0, 0.72)
			   love.graphics.printb("MP", (w-900)/2+4+(i-1)*300+8+2, 3+10+10+4+4+25+2, 0, 0.72)
			   love.graphics.printb("LV", (w-900)/2+4+(i-1)*300+8+2, 3+10+10+4+4+50+2, 0, 0.72)
			   love.graphics.setColor(1,1,1,0.8)
			   love.graphics.printb("HP", (w-900)/2+4+(i-1)*300+8, 3+10+10+4+4, 0, 0.72)
			   love.graphics.printb("MP", (w-900)/2+4+(i-1)*300+8, 3+10+10+4+4+25, 0, 0.72)
			   love.graphics.printb("LV", (w-900)/2+4+(i-1)*300+8, 3+10+10+4+4+50, 0, 0.72)

			   love.graphics.setColor(0,0,0,0.8)
			   love.graphics.print(party[i].hp,    (w-900)/2+4+(i-1)*300+8+2+60, 3+10+10+4+4+2,    0, 0.72)
			   love.graphics.print(party[i].hp,    (w-900)/2+4+(i-1)*300+8+2+60, 3+10+10+4+4+25+2, 0, 0.72)
			   love.graphics.print(party[i].level, (w-900)/2+4+(i-1)*300+8+2+60, 3+10+10+4+4+50+2, 0, 0.72)
			   love.graphics.setColor(1,1,1,0.8)
			   love.graphics.print(party[i].hp,    (w-900)/2+4+(i-1)*300+8+60, 3+10+10+4+4,    0, 0.72)
			   love.graphics.print(party[i].hp,    (w-900)/2+4+(i-1)*300+8+60, 3+10+10+4+4+25, 0, 0.72)
			   love.graphics.print(party[i].level, (w-900)/2+4+(i-1)*300+8+60, 3+10+10+4+4+50, 0, 0.72)

		   end
	   end
	   love.graphics.pop()
	   draw_minimap()
   end
   
   
	  local lo = current_level.layout
	  local lx = current_location.x
	  local ly = current_location.z
	  --print(lx,ly)
	  love.graphics.setFont(ROM.font1)
	  
      love.graphics.print("state: "..(state or "no state") .. " ".. (chance or ""), 10, 700)
      love.graphics.print("menu level: "..menu_level, 10, 680)
      love.graphics.print("x/y: "..lx .. " - ".. ly, 10, 650)
      --love.graphics.print(g3d.camera.position[1]/world_scale .. " - ".. g3d.camera.position[3]/world_scale, 300, 650,0,0.5)

	  local _, __ = check_forward()
	  local ___, ____ = get_forward()
      love.graphics.print("forward: "..table.concat({___, ____} or {}, "; "), 100, 650)
      love.graphics.print("check forward: "..tostring(_) .. " " .. __, 300, 650)
      --love.graphics.print(guess_rotation(lo,ly,lx).."\t"..lo[ly][lx], 600, 650,0,0.5)
	  local font = love.graphics.getFont()
	  local xoff = 10

      
	  
	  for k,v in ipairs(menu or {}) do
	  
		  i = math.pi/2 * k -math.pi
		  local text = v.name
		  if type(text) == "table" then 
		     text = text[1]
		  end

	      if menu_selected_index == k then 
			 love.graphics.setColor(1,0,0)
		  else 	
		     love.graphics.setColor(1,1,1) 
		  end
		  
		 -- circle menu
		  love.graphics.circle("line", 100+math.cos(i)*50,600+math.sin(i)*50, 32)		  
		  love.graphics.printf(text, 100+math.cos(i)*50-32, 600+math.sin(i)*50-13, 64, "center")
		 --end
		  
	  end
	  
	  love.graphics.printf(love.timer.getFPS(), 1100, 10, 170, "right", 0,1)


	   if not door_near then 
		  door_timer = nil
	   end
	   
	   
	   --if level_name_timer then
	   love.graphics.setFont(OpenGOST72)	   
	   love.graphics.setFont(ROM.font1)
	   
	      love.graphics.setColor(0,0,0,math.min(0.4,(level_name_timer or 1-(level_name_timer_on or 1))*0.4))
	      love.graphics.rectangle("fill",0, h/2-30, w, 100)
		  love.graphics.setColor(1,1,1,(level_name_timer or 1-(level_name_timer_on or 1)))
	      love.graphics.printf(current_level.name, 0-1.5*w, h/2, w, "center",0,4)
	   --end
	   love.graphics.setColor(1,1,1)
	   
	   console.draw()
	   
end



function love.mousemoved(x,y, dx,dy)
    g3d.camera.firstPersonLook(-dx,dy)
end

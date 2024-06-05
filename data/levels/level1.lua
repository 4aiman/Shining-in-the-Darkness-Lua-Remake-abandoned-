--[[
map: 
  0 - void
  1 - space

objects:
  {x, y, objectID}
  if that's a chest then an additional "itemID" is used
  if that's a hazzard - an additional "effectID" is used

items:
  {ID, name, description, price, broken?, type, euquippable by}
]]


local level = {}

local objects = require("data.objects")

level.name = "Level 1";

-- 1 = common wall
-- 2,3,etc = alt.walls

level.layout = {
{1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,1},
{1,0,0,1,0,1,1,1,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,0,0,1},
{1,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,1},
{1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0,1},
{1,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,1,1,1,0,1,0,1,1,1,1,0,1,1,1},
{1,1,0,1,1,1,0,1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,0,0,0,1,0,1,0,0},
{1,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1},
{1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,0},
{1,1,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,1,1,1,1,1,1},
{1,1,0,1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,0,1,1,1,1,0,1,0,1,0,0,1},
{0,0,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,0,1,0,1,1,0,1},
{1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,1,0,1,1,0,1},
{1,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,1,0,1,0,0,1,0,1},
{1,1,1,1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1},
{1,0,0,1,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,1},
{1,0,1,1,0,1,1,0,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,0,1},
{0,0,1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,0},
{1,0,1,1,0,1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1},
{1,0,0,1,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1},
{1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0,1,1,1,0,1,0,1,0,1,0,1,0,1},
{1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1},
{1,1,1,1,0,1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1},
{0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0,0,1},
{1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1},
{1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0},
{1,0,1,1,1,1,1,1,0,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,0,1,0,1},
{1,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,0,1},
{1,1,1,1,1,1,0,1,1,1,0,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,1,1,1,1},
{1,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,1},
{1,1,1,1,0,1,1,1,1,2,1,1,1,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
}

-- all chests on a givel level; item 0 is money
level.chests = { 
               --      x,      z,     id, amount
				{     30,     18,      0,    200}
			   }

-- all level effects; 
-- effects.lua should contain all effects with a single parametr "party"
-- ^ that should be sufficient to change ANYTHING about the player, including ViewDir, but I"ll need to recode that to include camera into "party"
level.effects = {
 -- x, z, effect id
 
}


level.objects = {
    {
    x=30,                --x
    z=18,                --z
	id=0,                --id of an object model (optional, optional for completely hidden objects)
	item={2},            --id of an item (optional, probably if a chest); can be an ID or *an array* of IDs
	one_by_one = false,  -- if present, the spot has to be searched multiple times to get al the items
	amount = 200,        -- gives this much items with "item" ID  upon inspection
	lightsource = 6,    -- if present, it glows, use numbers for light "strength" (optinal)
                         --	1 = 100% of a "natural" amount set in shader (optimized for torches), can be however low or high, but in %%
						 -- also, this will be assigned a dedicated ID for the shader
						 -- the ID then will be stored in the level layout to send proper stuff on updates to proper ID
	effect = 1,          -- effect ID triggered upon inspection (!) if no inspection rewuired, then see level.effects to apply this
	                     -- also, let's say that 1st inspection gives an item (if there's one) and THEN apllies an effect
	color = {1,0.8,0},     -- color, ALWAYS vec3; shader stuff, optional
	solid = false,       -- if present, makes this part untraversable
	
	},
	--puddles
	{ x = 08, z = 04, object = objects[15]}, 
	{ x = 20, z = 04, object = objects[15]}, 
	{ x = 30, z = 10, object = objects[15]}, 
	{ x = 01, z = 16, object = objects[15]}, 
	{ x = 10, z = 16, object = objects[15]}, 
	{ x = 09, z = 25, object = objects[15]}, 
	{ x = 18, z = 24, object = objects[15]}, 
	{ x = 30, z = 24, object = objects[15]}, 
	
	--chests
	{ x = 01, z = 10, object = objects[03]}, 
	{ x = 07, z = 23, object = objects[03]}, 
	{ x = 16, z = 14, object = objects[03]}, 
	{ x = 16, z = 30, object = objects[03]}, 
	{ x = 18, z = 18, object = objects[03]}, 
	{ x = 22, z = 04, object = objects[03]}, 
	{ x = 21, z = 14, object = objects[03]}, 
	{ x = 20, z = 24, object = objects[03]}, 
	{ x = 20, z = 26, object = objects[03]}, 
	{ x = 20, z = 28, object = objects[03]}, 
	{ x = 28, z = 08, object = objects[03]}, 
	{ x = 30, z = 04, object = objects[03]}, 
	
	-- moss
	{ x = 4, z = 13, object = objects[14]}, 
	{ x = 4, z = 14, object = objects[14]}, 
	{ x = 4, z = 15, object = objects[14]}, 
	
	{ x = 30, z = 18, object = objects[11], rotation = {math.pi,math.pi,0}}, -- test down stairs
	{ x = 31, z = 18, y=-2, lightsource = 10, color={-1,-1,-1}}, -- test down stairs (make it dark)
	
}

-- a common texture for the walls
level.wall_texture = {"master.png", "master.png", "master.png"}
-- a common model for the walls; I use prefixes, as I need at least 7 types of walls for a basic labirynth
-- 5 = -x in blender = forward/north
-- 6 = x in blender = back/south
-- 2 = -y in blender = left/west
-- 4 = y in blender = right/east
-- 1 = z in blender = top
-- 3 = -z in blender = bottom
-- need to export with -Z forward, -Y up

level.wall_model = {"path", "bottomless", "topless"}

-- alternative models, by ID; use wll_model if this doesn't exist
level.alt_wall_models = {}

-- just IDs of enemies, can then load their stats and textures by this ID from another file
-- table is needed to define spawn areas; can be multiple (x1, x2, z1, z2)
-- Basically, if ID exists, then we can load the enemy in.
-- I still can load everyone in, but this is needed to determine where each of them can be found
-- I NEED to use pairs to read this
                 --id      -- ranges
level.enemies = {[001] = { {0,0,30,30},
                     }, 
                 [002] = {},
				 [005] = {},
				}

-- starting position for a level; can be used to teleport to by using angel wings or stuss like that
level.start_pos = {30,16}

return level
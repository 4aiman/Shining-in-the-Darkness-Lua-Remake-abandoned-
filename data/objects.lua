-- requires is IS of a required path type:
-- 1 = normal, 2 = bottomless, 3 = topless
--
-- y > 0 to get things lower 
-- y < 0 to get things higher
-- omit y to get normal behaviour

local objects = {
   --[-01] = {name = "Wall"},
   --[000] = {name = "Corridor"},
   [028] = {name="Torch",         texture="master.png", model="torch_wall.obj", y = -0.5, count = 2, center=2.5},
   [134] = {name="Chest",         texture="master.png", model="chest.obj", scale = 2, y=-0.5},
   [029] = {name="Ground Torch",  texture="master.png", model="torch_ground.obj", y = 1.5, count = 2, center = 2.5},
   [009] = {name="Spinner",       texture="master.png", model="spinner.obj"},
   [132] = {name="Stairs Up",     texture="master.png", model="stairs.obj", requires=3, invert_normales=false},
   [133] = {name="Stairs Down",   texture="master.png", model="stairs_down.obj", requires=2, y = 1, invert_normales=false, rotation_y=math.pi, replace_model = true},
 --[012] = {name="Floor Trap",    texture="master.png", model="bottomless"},
 --[013] = {name="Floor Hole",    texture="master.png", model=""},
   [010] = {name="Moss", 		  texture="master.png", model="moss.obj"},
   [014] = {name="Puddle", 		  texture="master.png", model="puddle.obj", requires=2},
 --[016] = {name="Ceiling Hole",  texture="master.png", model=""},
   [131] = {name="Cell Door",     texture="master.png", model="cell_door.obj", drop_down = 1},
 --[018] = {name="Chest",         texture="master.png", model="chest.obj"},
 --[019] = {name="Fake Wall",     texture="master.png", model=""},

   [143] = {name="Fountain",      texture="master.png", model="fountain.obj", invert_normales=true},
  [-143] = {name="Fountain_water",texture="master.png", model="fountain_water.obj", invert_normales=true},
   [144] = {name="Gold Fountain", texture="master.png", model="fountain_gold.obj",  invert_normales=true},
  [-144] = {name="Fountain_water",texture="master.png", model="fountain_water.obj", invert_normales=true},

   [129] = {name="Green Door",    texture="master.png", model="green_door.obj",   count = 2, center = 1.5, rotation_y=math.pi, door = true},
   [130] = {name="Grey Door",     texture="master.png", model="grey_door.obj",    count = 2, center = 1.5, rotation_y=math.pi, door = true},
   [139] = {name="One Way Door",  texture="master.png", model="one_way_door.obj", count = 2, center = 1.5, rotation_y=math.pi, door = true, one_way = true},
   [150] = {name="Angel Door",    texture="master.png", model="angel_door.obj",   count = 2, center = 1.5, rotation_y=math.pi, door = true },
   -- replacements?
   [003+1000000] = {name="Chest", texture="master.png", model="chest_open.obj", scale = 2},
}return objects
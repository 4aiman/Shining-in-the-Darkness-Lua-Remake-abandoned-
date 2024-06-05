## Shining in the Darkness Ramake [abandoned]

Made in 2021 in hopes of stirring some interest towards the game.

Built in Lua upon g3d engine made for love2d framework.

Released under MIT if applicable (code, models, some of the textures textures)

### How to use:

- navigate to assets/OG_ROM and put there a ROM file from Steam
- get love2d engine
- run `love .` in the repo folder

Movement: `W`, `A`, `S`, `D`, Mouse
Menus (bugged): `left`, `down`, `right`. Only "status" works. Don't press `up` ;p
Screenshots: F12

### It crashes!

- If it says something about missing files - I forgot to put them here. Contact me.
- If it complains about too many something in shaders - you won't be able to run the "game" unless there are less shader units required. 
GTX1660S should handle it. GT1030 may not. It can be fixed, but hte project is [abandoned]


### Files

Here and there sprinkled some files. Some usefull, some useless, some need to be replaced.

- sitd.lua - reads the OG rROM and extracts maps, items, enemy data. Can't read encounter data, so no battles.
- OOZE.lua - an example of how to read enemy data, including moves in battles.
- notes.txt - some addresses in ROM, in Russian, amy provide some insight on the structure of the ROM
- new 3.txt - info, dumped from online sources: enemy data (contains errors), sprite properties, resistance values explanation, per-enemy battle moves listm effect ids, enemy zone levels (the part I failed to read from the ROM), cheat codes, leveling up tables, some conversations from SFC, modifier explanation, hidden items and dialogues 
- trans.txt - notes on translation, in Russian, may provide some insight on the structure of the ROM
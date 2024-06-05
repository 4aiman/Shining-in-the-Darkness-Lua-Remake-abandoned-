game.helpers     = require 'helpers'

controls = {}

local old_kbdisdown = love.keyboard.isDown
love.keyboard.isDown = function(key,...)
   if key and key~=" " then
      return old_kbdisdown(key,...) or love.keyboard.isScancodeDown(key,...)
   end
end


function controls:setScreenSize(w,h,dw,dh, font)
   self.width=w
   self.height = h
   self.dwidth = dw
   self.dheight = dh
   self.scaley = h/dh
   self.scalex = w/dw
   self.pxs = 1 --love.window.getDPIScale()
   self.font = font
   self.buttons = {
       left     = {left = 05*self.pxs,             top = self.dheight - 60*self.pxs, right = 25*self.pxs,             bottom = self.dheight-40*self.pxs,             sym="<" },
       right    = {left = 50*self.pxs,             top = self.dheight - 60*self.pxs, right = 70*self.pxs,             bottom = self.dheight-40*self.pxs,             sym=">" },
       up       = {left = 28*self.pxs,             top = self.dheight - 85*self.pxs, right = 48*self.pxs,             bottom = self.dheight-65*self.pxs,             sym="^" },
       down     = {left = 28*self.pxs,             top = self.dheight - 35*self.pxs, right = 48*self.pxs,             bottom = self.dheight-15*self.pxs,             sym="v" },
       action1  = {left = self.dwidth-70*self.pxs, top = self.dheight - 35*self.pxs, right = self.dwidth-50*self.pxs, bottom = self.dheight-15*self.pxs , float = 1, sym="A"},
       action2  = {left = self.dwidth-30*self.pxs, top = self.dheight - 35*self.pxs, right = self.dwidth-10*self.pxs, bottom = self.dheight-15*self.pxs , float = 1, sym="B"},
       action3  = {left = self.dwidth-70*self.pxs, top = self.dheight - 65*self.pxs, right = self.dwidth-50*self.pxs, bottom = self.dheight-45*self.pxs , float = 1, sym="X"},
       action4  = {left = self.dwidth-30*self.pxs, top = self.dheight - 65*self.pxs, right = self.dwidth-10*self.pxs, bottom = self.dheight-45*self.pxs , float = 1, sym="Y"},
       action5  = {left = self.dwidth-30*self.pxs, top = 10*self.pxs,                right = self.dwidth-10*self.pxs, bottom = 30*self.pxs,               float = 1, sym="I"},
   }
   --controls.font = love.graphics.newFont(16)
end

function controls:set_game(gamedef)
   self.gamedef = gamedef
   local offset = 0
   local ww, wh = love.window.getMode()
   self.offset = (ww/gamedef.scaley - gamedef.default_window_width)/2
end

function controls:enableButtons(buttons)
   self.enabledButtons={}
   for k,v in ipairs(buttons) do
       self.enabledButtons[v]=true
   end
end

function controls:touch_collision(x, y, left, top, right, bottom)
   local res = (y > top*self.gamedef.scaley and
                y < bottom*self.gamedef.scaley and
                x-self.offset*self.gamedef.scaley > left*self.gamedef.scaley and
                x-self.offset*self.gamedef.scaley < right*self.gamedef.scaley)
   return res
end

function controls.setMode(mode)
   controls.mode = mode
   if mode == "menu" then
      controls.enableButtons({'up','down','left','right','action1','action2','action3','action4', 'action5'})
   elseif mode == "game" then
      controls.enableButtons({'down','left','right','action1'})
   end
end


local lastbutton = ""
controls.enabledButtons={}

function controls:clear()
   for k,v in pairs(self.buttons) do
       if self.enabledButtons[k] then
          self['moving_'..k]=false
       end
   end
end

function controls:update(dt, keys)
    if not keys then print("no keys no gains") return end
    if self.hidden then return end
    if self.gamedef.controls_suppressed then self:clear() return end
    local s = ""
    for k,v in pairs(self.gamedef.keys) do
        if v then
           s = s..k..", "
        end
    end
    lastbutton = s
    self.pressed_buttons_list = s

    if love.keyboard.isDown('escape') or lastbutton:find('escape') then self.escape = true else self.escape = false end

      self.not_pressed = {}
      if not (self.not_pressed.mouse_left    or self.not_pressed.touch_left    or self.not_pressed.kbd_left    or self.not_pressed.left_str)    then self.moving_left = false self.x1 = true end
      if not (self.not_pressed.mouse_right   or self.not_pressed.touch_right   or self.not_pressed.kbd_right   or self.not_pressed.right_str)   then self.moving_right = false self.x2 = true end
      if not (self.not_pressed.mouse_down    or self.not_pressed.touch_down    or self.not_pressed.kbd_down    or self.not_pressed.down_str)    then self.moving_down = false self.x2 = true end
      if not (self.not_pressed.mouse_up      or self.not_pressed.touch_up      or self.not_pressed.kbd_up      or self.not_pressed.up_str)      then self.moving_up = false self.x2 = true end
      if not (self.not_pressed.mouse_action1 or self.not_pressed.touch_action1 or self.not_pressed.kbd_action1 or self.not_pressed.action1_str) then self.action1 = false self.moving_action1 = false end
      if not (self.not_pressed.mouse_action2 or self.not_pressed.touch_action2 or self.not_pressed.kbd_action2 or self.not_pressed.action2_str) then self.action2 = false self.moving_action2 = false end
      if not (self.not_pressed.mouse_action3 or self.not_pressed.touch_action3 or self.not_pressed.kbd_action3 or self.not_pressed.action3_str) then self.action3 = false self.moving_action3 = false end
      if not (self.not_pressed.mouse_action4 or self.not_pressed.touch_action4 or self.not_pressed.kbd_action4 or self.not_pressed.action4_str) then self.action4 = false self.moving_action4 = false end
      if not (self.not_pressed.mouse_action5 or self.not_pressed.touch_action5 or self.not_pressed.kbd_action5 or self.not_pressed.action5_str) then self.action5 = false self.moving_action5 = false end

      -- переменная со столкновениями, проверки только внутри условий, так что может быть и nil
      local collision
      self.moving_down = nil
      self.moving_left = nil
      self.moving_right = nil
      self.moving_action1 = nil
      self.moving_action2 = nil
      self.moving_action3 = nil
      self.moving_action4 = nil
      self.moving_action5 = nil
      self.moving_up = nil

      -- HW контролы
      if love.system.getOS()=="Android" then
         if lastbutton:find('down')   then self.moving_down = true else self.not_pressed.down_str = true end
         if lastbutton:find('left')   then self.moving_left = true else self.not_pressed.left_str = true end
         if lastbutton:find('right')  then self.moving_right = true else self.not_pressed.right_str = true end

         if self.mode=="game" then
            if lastbutton:find('up')     then self.moving_action1 = true else self.not_pressed.action1_str = true end
         elseif self.mode=="menu" then
            if lastbutton:find('up')     then self.moving_up = true else self.not_pressed.up_str = true end
         end
      end
      -- мыша
      local touch = {x= love.mouse.getX(), y= love.mouse.getY()}
      if love.mouse.isDown(1) then
         if self:touch_collision(touch.x, touch.y, self.buttons.left.left,self.buttons.left.top,self.buttons.left.right,self.buttons.left.bottom) then  self.moving_left = true else self.not_pressed.mouse_left=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.right.left,self.buttons.right.top,self.buttons.right.right,self.buttons.right.bottom) then  self.moving_right = true else self.not_pressed.mouse_right=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.up.left,self.buttons.up.top,self.buttons.up.right,self.buttons.up.bottom) then  self.moving_up = true else self.not_pressed.mouse_ru=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.down.left,self.buttons.down.top,self.buttons.down.right,self.buttons.down.bottom) then  self.moving_down = true else self.not_pressed.mouse_down=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.action1.left,self.buttons.action1.top,self.buttons.action1.right,self.buttons.action1.bottom) then  self.moving_action1=true self.action1 = true else self.not_pressed.mouse_action1=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.action2.left,self.buttons.action2.top,self.buttons.action2.right,self.buttons.action2.bottom) then  self.moving_action2=true self.action2 = true else self.not_pressed.mouse_action2=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.action3.left,self.buttons.action3.top,self.buttons.action3.right,self.buttons.action3.bottom) then  self.moving_action3=true self.action3 = true else self.not_pressed.mouse_action3=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.action4.left,self.buttons.action4.top,self.buttons.action4.right,self.buttons.action4.bottom) then  self.moving_action4=true self.action4 = true else self.not_pressed.mouse_action4=true end
         if self:touch_collision(touch.x, touch.y, self.buttons.action5.left,self.buttons.action5.top,self.buttons.action5.right,self.buttons.action5.bottom) then  self.moving_action5=true self.action5 = true else self.not_pressed.mouse_action5=true end
      end

      -- тач
      self.touches = {}
      if love.touch then
          local touches = love.touch.getTouches()
          for k,v in pairs(touches) do
              local touch = {}
              touch.x, touch.y = love.touch.getPosition(v)
              if self:touch_collision(touch.x, touch.y, self.buttons.left.left,self.buttons.left.top,self.buttons.left.right,self.buttons.left.bottom) then  self.moving_left = true else self.not_pressed.touch_left=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.right.left,self.buttons.right.top,self.buttons.right.right,self.buttons.right.bottom) then  self.moving_right = true  else self.not_pressed.touch_right=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.up.left,self.buttons.up.top,self.buttons.up.right,self.buttons.up.bottom) then  self.moving_up = true else self.not_pressed.mouse_ru=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.down.left,self.buttons.down.top,self.buttons.down.right,self.buttons.down.bottom) then  self.moving_down = true  else self.not_pressed.touch_down=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.action1.left,self.buttons.action1.top,self.buttons.action1.right,self.buttons.action1.bottom) then  self.moving_action1=true self.action1 = true else self.not_pressed.touch_action1=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.action2.left,self.buttons.action2.top,self.buttons.action2.right,self.buttons.action2.bottom) then  self.moving_action2=true self.action2 = true else self.not_pressed.touch_action2=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.action3.left,self.buttons.action3.top,self.buttons.action3.right,self.buttons.action3.bottom) then  self.moving_action3=true self.action3 = true else self.not_pressed.touch_action3=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.action4.left,self.buttons.action4.top,self.buttons.action4.right,self.buttons.action4.bottom) then  self.moving_action4=true self.action4 = true else self.not_pressed.touch_action4=true end
              if self:touch_collision(touch.x, touch.y, self.buttons.action5.left,self.buttons.action5.top,self.buttons.action5.right,self.buttons.action5.bottom) then  self.moving_action5=true self.action5 = true else self.not_pressed.touch_action5=true end
          end
       end

      -- клава (повтор проверки ниже ради удобочитаемости)
      if keys.up and love.keyboard.isDown(keys.up) then self.moving_up   = true else self.not_pressed.kbd_up  =true end
      if keys.down and love.keyboard.isDown(keys.down) then self.moving_down = true else self.not_pressed.kbd_down=true end
      if keys.left and love.keyboard.isDown(keys.left) then self.moving_left=true else self.not_pressed.kbd_left = true end
      if keys.right and love.keyboard.isDown(keys.right) then self.moving_right=true else self.not_pressed.kbd_right = true end
      if keys.action1 and love.keyboard.isDown(keys.action1) then self.moving_action1=true else self.not_pressed.kbd_action1 = true end
      if keys.action2 and love.keyboard.isDown(keys.action2) then self.moving_action2=true else self.not_pressed.kbd_action2 = true end
      if keys.action3 and love.keyboard.isDown(keys.action3) then self.moving_action3=true else self.not_pressed.kbd_action3 = true end
      if keys.action4 and love.keyboard.isDown(keys.action4) then self.moving_action4=true else self.not_pressed.kbd_action4 = true end
      if keys.action5 and love.keyboard.isDown(keys.action5) then self.moving_action5=true else self.not_pressed.kbd_action5 = true end



      if self.moving_action1 then self.action1 = true else self.action1 = false end
      if self.moving_action2 then self.action2 = true else self.action2 = false end
      if self.moving_action3 then self.action3 = true else self.action3 = false end
      if self.moving_action4 then self.action4 = true else self.action4 = false end
      if self.moving_action5 then self.action5 = true else self.action5 = false end

      -- если только что нажали поворот - поворачиваем
      if self.action1 and not self.action1_pressed then self.can_action1=true else self.can_action1=false  end
      if self.action2 and not self.action2_pressed then self.can_action2=true else self.can_action2=false  end
      if self.action3 and not self.action3_pressed then self.can_action3=true else self.can_action3=false  end
      if self.action4 and not self.action4_pressed then self.can_action4=true else self.can_action4=false  end
      if self.action5 and not self.action5_pressed then self.can_action5=true else self.can_action5=false  end

      -- запоминает, держим ли мы кнопку "поворот". Да, сначала поворачиваем, а потом запоминаем!
      if self.action1 then self.action1_pressed = true else self.action1_pressed = false end
      if self.action2 then self.action2_pressed = true else self.action2_pressed = false end
      if self.action3 then self.action3_pressed = true else self.action3_pressed = false end
      if self.action4 then self.action4_pressed = true else self.action4_pressed = false end
      if self.action5 then self.action5_pressed = true else self.action5_pressed = false end


end


function love.gamepadpressed(joystick, button)
    lastbutton = button
end

function controls:draw(tx,ty)
   --print(tx,ty)
   if self.hidden then return end
   if love.system.getOS()~="Android" then return end
      local font = love.graphics.getFont()
      love.graphics.setFont(self.font or font)
      love.graphics.push()
    --  love.graphics.translate(-tx, -ty)

      --love.graphics.print(self.pressed_buttons_list or "", 25, 70)
      love.graphics.setLineWidth(0.5*self.gamedef.scaley)
      for k,v in pairs(self.buttons) do
          local r,g,b,a = 255,255,255
          if self.enabledButtons[k] then
             r,g,b,a = 255, 255, 255
             if self['moving_'..k] then
                r,g,b,a = 055, 205, 055
             end
             if not v.float then
                a = 55
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("fill", v.left, v.top, (v.right-v.left), (v.bottom-v.top), 4, 4, 1 )
                a = nil
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("line", v.left, v.top, (v.right-v.left), (v.bottom-v.top), 4, 4, 1 )
                love.graphics.print(v.sym, (v.left+7), v.top+4)
             else
                a = 55
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("fill", v.left, v.top, (v.right-v.left), (v.bottom-v.top), 4, 4, 1 )
                a = nil
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("line", v.left, v.top, (v.right-v.left), (v.bottom-v.top), 4, 4, 1 )
                love.graphics.print(v.sym, v.left +7, v.top+4)
             end
          end
      end
      love.graphics.setColor(255, 255, 255)
      -- functions.print("Input: "..lastbutton, 10, 10, self.scaley)
      love.graphics.setFont(font)
      love.graphics.pop()
   --end

end

return deepcopy(controls)

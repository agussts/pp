local module = {}

local collisions = require("collisions")

module.name = "player"
module.version = "0.1.0"
module.controls = {
    [{"x", -1}] = "a",
    [{"x", 1}] = "d",
    [{"y", -1}] = "w",
    [{"y", 1}] = "s"
}

module.new = function(sprite)
    local self = setmetatable({}, { __index = module })

    self.sprite = sprite
    self.collision = collisions.new("box", 0,0, sprite:getWidth(), sprite:getHeight())
    self.speed = 500

    self.collision.visualized = true

    return self
end

function module:UpdateInput()
   local input = {}

   for i, v in pairs(self.controls) do
       if love.keyboard.isDown(v) then
        self.collision["speed"..string.upper(i[1])] = i[2] * self.speed 
        print(self.collision.speedX, self.collision.speedY)
       end
   end
   return input
end

return module
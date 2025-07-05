local module = {}

local collisions = require("collisions")

module.name = "player"
module.controls = {
    [{"X", -1}] = "a",
    [{"X", 1}] = "d",
    [{"Y", -1}] = "w",
    [{"Y", 1}] = "s"
}

module.new = function(sprite)
    local self = setmetatable({}, { __index = module })

    self.sprite = sprite
    self.collision = collisions.new("box", 0,0, sprite:getWidth(), sprite:getHeight())
    self.collision.player = true
    self.speed = 500

    self.collision.visualized = true

    return self
end

function module:UpdateInput()
    self.collision.speedX = 0
    self.collision.speedY = 0
    for i, v in pairs(module.controls) do
       if love.keyboard.isDown(v) then
        print(tostring(v).. " is down")
        self.collision["speed"..i[1]] = i[2] * self.speed 
        print(self.collision.speedX, self.collision.speedY)
       end
   end
end

return module
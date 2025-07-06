local module = {}

local collisions = require("collisions")

module.name = "player"
module.controls = {
    [{"X", -1}] = "a",
    [{"X", 1}] = "d",
    [{"Y", -1}] = "w",
    [{"Y", 1}] = "s"
}

module.new = function(spriteName)
    local self = setmetatable({}, { __index = module })

    self.sprite = love.graphics.newImage(spriteName)
    self.collision = collisions.new("box", 0,0, self.sprite:getWidth(), self.sprite:getHeight())
    self.collision.tags = { "player" }
    self.speed = 500
    return self
end

function module:UpdateInput()
    self.collision.speedX = 0
    self.collision.speedY = 0
    for i, v in pairs(module.controls) do
       if love.keyboard.isDown(v) then
        self.collision["speed"..i[1]] = i[2] * self.speed 
       end
   end
end

return module
local module = {}

local collisions = require("libs.collisions")
local timer      = require("libs.timer")

module.name = "player"
module.controlsMovement = {
    [{"X", -1}] = "a",
    [{"X", 1}] = "d",
    [{"Y", -1}] = "w",
    [{"Y", 1}] = "s"
}
module.otherControls = {
    ["dash"] = "space"
}

module.new = function(spriteName, width, height)
    local self = setmetatable({}, { __index = module })

    self.sprite = love.graphics.newImage(spriteName)
    self.collision = collisions.new("box", 0,0, width, height)
    self.collision.tags = { "player" }
    self.health = 100
    self.collision.link = self
    self.speed = 250
    return self
end

function module:UpdateInput()
    self.collision.speedX = 0
    self.collision.speedY = 0
    for i, v in pairs(module.controlsMovement) do
       if love.keyboard.isDown(v) then
        self.collision["speed"..i[1]] = i[2] * self.speed 
       end
   end
    
end

return module
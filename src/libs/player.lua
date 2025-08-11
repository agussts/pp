---
--@classmod player

local module = {}

local collisions = require("src.libs.collisions")
local timer      = require("src.libs.timer")
local udim2      = require("src.guis.udim2")

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
    self.collision = collisions.new("box")
    self.collision.position = udim2.new(0, 0, 0, 0)
    self.collision.size = udim2.new(width, 0, height, 0)
    self.collision:AddTag("player")
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
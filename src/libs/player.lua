---
--@classmod player

local module = {}

local collisions = require("src.libs.collisions")
local udim2      = require("src.guis.udim2")

module.name = "player"
module.controlsMovement = {
    [{"X", -1}] = "PLEFT",
    [{"X", 1}] = "PRIGHT",
    [{"Y", -1}] = "PUP",
    [{"Y", 1}] = "PDOWN"
}

--module.otherControls = {
--    ["dash"] = "PDASH",
--    ["back"] = "PBACK"
--}

module.new = function(spriteName, width, height)
    local self = setmetatable({}, { __index = module })

    self.sprite = Animation.new(spriteName, 32, 32, 3, 3, 0.1)
    self.size = udim2.new(width, 0, height, 0)
    self.collision = collisions.new("box")
    self.collision.position = udim2.new(0, 0, 0, 0)
    self.collision.size = udim2.new(width * 0.8, 0, height * 0.8, 0)
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
        if Config.SavedConfigs[v] == nil then goto continue end
        if love.keyboard.isDown(Config.SavedConfigs[v]) then
            self.collision["speed"..i[1]] = i[2] * self.speed
        end
    end
    ::continue::
end

return module
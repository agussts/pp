local enemy = {}
local collisions = require("libs.collisions")
local timer      = require("libs.timer")

local addedEnemies = {}

enemy.getEnemies = function()
    return addedEnemies
end
enemy.new = function(spritePath, width, height)
    local self = setmetatable({}, { __index = enemy })
    self.sprite = love.graphics.newImage(spritePath)
    self.collision = collisions.new("box", 0, 0, width, height)
    self.collision.link = self
    self.cd = 1
    self.timer = timer.new(self.cd)
    self.collision.onHit = (function (collider)
        if not self.timer:check() then return end
        for _,v in pairs(collider.tags) do
            if v == "player" then
                self.timer:reset()
                collider.link.health = collider.link.health - self.damage
                love.audio.newSource("assets/sfx/hitHurtPlayer.wav", "static"):play()
            end
        end
    end)
    self.collision.tags = {"enemy"}
    self.health = 100
    self.damage = 10
    table.insert(addedEnemies, self)
    return self
end

return enemy
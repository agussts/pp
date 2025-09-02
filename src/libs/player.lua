---
-- Modulo para manejar al jugador.
--@classmod player

local module = {}

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

---
-- Crea al jugador
--@param spriteName (string) El nombre del sprite del jugador
--@param width (number) El ancho del jugador
--@param height (number) La altura del jugador
--@return (player) El nuevo jugador creado
--@usage local player = Player.new("assets/sprites/player.png", 32, 32)
module.new = function(spriteName, width, height)
    local self = setmetatable({}, { __index = module })

    self.sprite = Animation.new(spriteName, 32, 32, 3, 3, 0.1)
    self.size = UDim2.new(width, 0, height, 0)
    self.collision = Collisions.new("box")
    self.collision.position = UDim2.new(0, 0, 0, 0)
    self.collision.size = UDim2.new(width, 0, height, 0)
    self.collision:AddTag("player")
    self.health = 100
    self.collision.link = self
    self.speed = 250
    return self
end


function module:Update(dt)
    self.sprite:update(dt)
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
---
-- Modulo para manejar al jugador.
--@classmod player

local player = {}

player.controlsMovement = {
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
player.new = function(spriteName)
    local self = setmetatable({}, { __index = player })

    self.sprite = Animation.new(spriteName, 32, 32, 3, 3, 0.1)
    self.sprite.anchor = {.5, .5}
    self.collision = Collisions.new("box")
    self.collision.anchor = {.5, .5}
    self.collision.position = UDim2.new(0, 0, 0, 0)
    self.collision.size = UDim2.new(.04, 0, .075, 0)
    self.collision:AddTag("player")
    self.health = 100
    self.collision.link = self
    self.speed = 250

    self.flash = 0
    self.flashDur = .1
    return self
end


function player:update(dt)
    self.sprite:update(dt)
    self.collision.speedX = 0
    self.collision.speedY = 0
    for i, v in pairs(player.controlsMovement) do
        if Config.SavedConfigs[v] == nil then goto continue end
        if love.keyboard.isDown(Config.SavedConfigs[v]) then
            self.collision["speed"..i[1]] = i[2] * self.speed
        end
        ::continue::
    end
    
end

function player:Damage(dmg)
    if self._destroying then return end
    self.health = self.health - dmg
    print("health: ".. self.health, "damage: ".. dmg)
    self.flash = 1
    Timer.after(self.flashDur, function ()
        self.flash = 0
    end):addToGroup(PlayingTimers)

    if self.health <= 0 and not self._dead then
        self._dead = true
        Transition.play(function ()
            Gamestate = "playing"
            Scene.reload()
        end)
    end
end

function player:draw()
    local x,y = self.collision.position:toPixels()
    self.sprite:draw(x - self.sprite.gridWidth, y - self.sprite.gridHeight)
end

return player
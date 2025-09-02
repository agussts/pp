---
-- Modulo para manegar enemigos.
-- Muy basico de momento, no contiene casi nada.
--@classmod enemy

local enemy = {}

local addedEnemies = {}

---
-- Obtiene todos los enemigos
--@return (table) Una tabla con todos los enemigos
enemy.getEnemies = function()
    return addedEnemies
end

---
-- Crea un nuevo enemigo
--@return (enemy) El nuevo enemigo creado
--@usage local myEnemy = Enemy.new("assets/sprites/enemy.png", 32, 32)
enemy.new = function(spritePath, width, height)
    local self = setmetatable({}, { __index = enemy })
    self.sprite = love.graphics.newImage(spritePath)
    self.collision = Collisions.new("box")
    self.collision.position = UDim2.new(0, 0, 0, 0)
    self.collision.size = UDim2.new(width, 0, height, 0)
    self.collision.link = self
    self.cd = 1
    self.timer = Timer.new(self.cd)
    self.timer:addToGroup(PlayingTimers)
    self.collision.onHit = (function (collider)
        if not self.timer:check() then return end
        for i,v in pairs(collider.tags) do
            if v == "hitbox" then return end
        end
        for _,v in pairs(collider.tags) do
            if v == "player" then
                self.timer:reset()
                collider.link.health = collider.link.health - self.damage
                love.audio.newSource("assets/sfx/hitHurtPlayer.wav", "static"):play()
            end
        end
    end)
    self.collision:AddTag("enemy")
    self.health = 100
    self.damage = 10
    table.insert(addedEnemies, self)
    return self
end



return enemy
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
--@usage local myEnemy = Enemy.new(myEnemyAnimation, 32, 32)
enemy.new = function(spriteAnim, width, height)
    local self = setmetatable({}, { __index = enemy })
    self.sprite = spriteAnim or Animation.new("assets/sprites/slungus.png", 223, 226, 1, 1, 1)
    self.collision = Collisions.new("box")
    self.collision.position = UDim2.new(0, 0, 0, 0)
    self.collision.size = UDim2.new(width, 0, height, 0)
    self.collision.link = self
    self.cd = 1
    self.timer = Timer.new(self.cd)
    self.timer:addToGroup(PlayingTimers)
    self.collision.onHit:Connect(function (collider)
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

function enemy:follow(targetUDim2)
    local targetX = targetUDim2.x.offset + (targetUDim2.x.scale * love.graphics.getWidth())
    local targetY = targetUDim2.y.offset + (targetUDim2.y.scale * love.graphics.getHeight())
    local selfX = self.collision.position.x.offset + (self.collision.position.x.scale * love.graphics.getWidth()) + (self.collision.size.x.offset / 2)
    local selfY = self.collision.position.y.offset + (self.collision.position.y.scale * love.graphics.getHeight()) + (self.collision.size.y.offset / 2)
    local angle = math.atan2(targetY - selfY, targetX - selfX)
    local speed = 100
    local vx = math.cos(angle) * speed
    local vy = math.sin(angle) * speed
    self.collision.position = UDim2.new(0, self.collision.position.x.offset + vx * love.timer.getDelta(), 0, self.collision.position.y.offset + vy * love.timer.getDelta())
end

function enemy:draw()
    local x,y = self.collision.position:toPixels()
    local w,h = self.collision.size:toPixels()
    self.sprite:draw(x, y, w, h)
end

function enemy:Destroy()
    self.collision:Destroy()
    for i,v in pairs(addedEnemies) do
        if v == self then
            table.remove(addedEnemies, i)
            break
        end
    end
    self = nil
end

return enemy
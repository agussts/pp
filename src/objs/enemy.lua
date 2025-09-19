---
-- Modulo para manegar enemigos.
--@classmod enemy

local enemy = {}

local addedEnemies = {}

local audios = {
    die = love.audio.newSource("assets/sfx/die.wav", "static")
}

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
    self.collision.anchor = {.5, .5}
    self.collision.link = self

    self.explosion = Animation.new("assets/sprites/explosion-Sheet.png", 64, 36, 3, 3, .025)
    self.explosion.anchor = {.5, .5}
    self.explosion:Pause()
    self.explosion.loop = false
    self.explosion.visible = false

    self.flash = 0 -- intensidad [0..1]
    self.flashDur = .1

    self.attackCd = 1
    self.timer = Timer.new(self.attackCd)
    self.timer:addToGroup(PlayingTimers)
    self.collision.onHit:Connect(function (collider)
        if not self.timer:check() then return end

        if collider:HasTag("hitbox") then return end
        if collider:HasTag("player") and collider:HasTag("box") then
            self.timer:reset()
            collider.link:Damage(self.damage)
            love.audio.newSource("assets/sfx/hitHurtPlayer.wav", "static"):play()
        end
    end)

    self.collision:AddTag("enemy")
    self.followTarget = nil
    self.health = 100
    self.damage = 10
    self.speed = 150
    table.insert(addedEnemies, self)
    return self
end

---
-- Hace que el enemigo siga el UDim2 dado
--@param UDim2 El UDim2 que el enemigo sigue
function enemy:follow(targetUDim2)
    if self._destroying then return end
    self.followTarget = targetUDim2
end

---
-- Le hace daño al enemigo
function enemy:Damage(dmg)
    if self._destroying then return end
    self.health = self.health - dmg
    self.flash = 1
    Timer.after(self.flashDur, function ()
        self.flash = 0
    end):addToGroup(PlayingTimers)

    if self.health <= 0 then
        self.explosion.visible = true
        self.sprite.visible = false
        self.collision:Destroy()
        self.explosion:Play()
        audios.die:clone():play()
        self.explosion.OnFinish:Connect(function ()
            self:Destroy()
        end)
    end
end

---
-- Dibuja el enemigo
function enemy:draw()
    if self._destroying then return end
    local x,y = self.collision.position:toPixels()
    if self.flash > 0 then
        love.graphics.setShader(Shaders.flash)
        Shaders.flash:send("u_flash", self.flash)
    end
    self.sprite:draw(x - self.sprite.gridWidth, y - self.sprite.gridHeight)
    love.graphics.setShader()
    self.explosion:draw(x - self.sprite.gridWidth, y - self.sprite.gridHeight)
end

---
-- Destruye el enemigo
function enemy:Destroy()
    self._destroying = true
    for i,v in pairs(addedEnemies) do
        if v == self then
            table.remove(addedEnemies, i)
            break
        end
    end
    for _,v in pairs(self) do
        if type(v) == "table" and v.Destroy then v:Destroy() end
        v = nil
    end
    self = nil
end

---
-- Actualiza la animacion y velocidad del enemigo
--@param dt Delta time
function enemy:update(dt)
    if self._destroying then return end
    if self.followTarget ~= nil and type(self.followTarget) == "table" and self.followTarget.toPixels then
        local enemyX, enemyY = self.collision.position:toPixels()
        local targetX, targetY = self.followTarget:toPixels()
        local dx = targetX - enemyX
        local dy = targetY - enemyY
        local distance = math.sqrt(dx*dx + dy*dy)
        
        local xSpeed = (dx / distance) * self.speed
        local ySpeed = (dy / distance) * self.speed

        self.collision.speedX = xSpeed
        self.collision.speedY = ySpeed
    end

    self.sprite:update(dt)
    self.explosion:update(dt)
end

---
-- Obtiene todos los enemigos
--@return (table) Una tabla con todos los enemigos
enemy.getEnemies = function()
    return addedEnemies
end

return enemy
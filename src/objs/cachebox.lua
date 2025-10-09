-- Caja caché rompible: al destruirse, ejecuta un callback (p.ej. spawnear un Shard).
-- Se daña con proyectiles porque la pistola llama otherCollider.link:Damage(1) si existe health.

local CacheBox = {}
CacheBox.__index = CacheBox

function CacheBox.new(posScale, sizeScale, onOpenCb)
    local self = setmetatable({}, CacheBox)

    -- Visual simple usando una anim estática (puedes cambiar sprite)
    self.sprite = Animation.new("assets/sprites/xblock.png", 38, 21, 1, 1, 1)
    self.sprite:Pause()

    -- Colisión sólida (bloquea)
    self.collision = Collisions.new("box")
    self.collision.position = posScale or UDim2.fromScale(0.5, 0.5)
    self.collision.size     = sizeScale or UDim2.fromScale(0.06, 0.10)
    self.collision.anchor   = {0.5, 0.5}
    self.collision.link     = self

    -- Estado
    self.health   = 3
    self._openCb  = onOpenCb
    self._dead    = false

    return self
end

function CacheBox:Damage(dmg)
    if self._dead then return end
    self.health = self.health - (dmg or 1)
    self.sprite.color = {1, 0.7, 0.7, 1}
    Timer.after(0.08, function() self.sprite.color = {1,1,1,1} end):addToGroup(PlayingTimers)
    if self.health <= 0 then
        self._dead = true
        -- Ejecuta el callback (p.ej. spawnear Shard)
        if self._openCb then self._openCb() end
        self:Destroy()
    end
end

function CacheBox:update(dt)
    self.sprite:update(dt)
end

function CacheBox:draw()
    local x, y = self.collision.position:toPixels()
    self.sprite:draw(x, y)
end

function CacheBox:Destroy()
    if self.collision then self.collision:Destroy() end
    self.collision = nil
    self.sprite = nil
end

return CacheBox

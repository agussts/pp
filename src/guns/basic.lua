---
-- Pistola basica, tambien la base de otras pistolas
--@classmod basicGun

local gun = {}

local audios = {
    hit   = love.audio.newSource("assets/sfx/hitHurt.wav", "static"),
    boxhit= love.audio.newSource("assets/sfx/blip.wav", "static"),
    shoot = love.audio.newSource("assets/sfx/shoot.wav", "static")
}

function gun.new()
    local self = setmetatable({}, { __index = gun })
    self.name         = "Basic Gun"
    self.damage       = 15
    self.fireRate     = 0.2
    self.lastFireTime = 0
    self.speed        = 500
    self.rechargeTime = 2
    self.bullets      = {}
    self._seq         = 0      -- id incremental por instancia (antes era global)  <-- añadido
    self.tags         = { "gun", "projectile" }
    return self
end

function gun:update(dt)
    -- Usar pairs: la tabla puede tener “agujeros” cuando borramos balas
    for _, bullet in pairs(self.bullets) do
        if bullet.update then bullet:update(dt) end
    end

    if love.mouse.isDown(1) then
        local x,y = Player.collision.position:toPixels()
        self:Fire(x, y)
    end

    if self.lastFireTime > 0 then
        self.lastFireTime = self.lastFireTime - dt
        if self.lastFireTime < 0 then self.lastFireTime = 0 end
    end
end

function gun:draw()
    -- IMPORTANTE: usar pairs en vez de ipairs para no cortar en el primer nil  <-- cambio clave
    for _, bullet in pairs(self.bullets) do
        if bullet.draw then bullet:draw() end
    end
end

--- Dispara la pistola
-- @param x (number) posicion X (px) desde donde se dispara
-- @param y (number) posicion Y (px) desde donde se dispara
function gun:Fire(x, y)
    if self.lastFireTime > 0 then return end
    self._seq = self._seq + 1
    local id = self._seq

    -- sprite de la bala
    local anim = Animation.new("assets/sprites/bullet-Sheet.png", 5, 5, 2, 1, 0.5)
    anim.anchor = {0.5, 0.5}

    local bullet = Block.new(anim, 0, 0, 0.02, 0.03)
    self.bullets[id] = bullet

    local collider = bullet.collision
    collider:ChangeType("hitbox")
    collider.anchor = {0.5, 0.5}

    -- Etiquetas de la bala (projectile)
    for _, tag in ipairs(self.tags) do
        collider:AddTag(tag)
    end
    collider.link = self

    -- Dirección hacia el mouse en coordenadas de mundo
    local mouseX, mouseY = Camera.screenToWorld(love.mouse:getPosition())
    local dx = mouseX - x
    local dy = mouseY - y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist == 0 then dist = 1 end

    collider.position = UDim2.new(0, x, 0, y) 
    collider.position:toScale()
    collider.speedX = (dx / dist) * self.speed
    collider.speedY = (dy / dist) * self.speed
    collider.enabled = true

    -- Conexión de impacto
    local destroyed = false  -- evita doble destroy por timer y por impacto  <-- añadido
    local hitConn
    hitConn = collider.onHit:Connect(function (other)
        if destroyed then return end
        -- Ignora player y otros proyectiles
        if other:HasTag("player") or other:HasTag("projectile") then return end

        -- Daño a entidades con :Damage
        if other.link and other.link.Damage then
            other.link:Damage(self.damage)
        end

        -- SFX según tag
        if other:HasTag("enemy") then
            audios.hit:clone():play()
        elseif other:HasTag("box") or other:HasTag("world") then
            audios.boxhit:clone():play()
        end

        -- Destruir bala
        destroyed = true
        if hitConn and hitConn.Disconnect then hitConn:Disconnect() end
        self.bullets[id] = nil
        bullet:Destroy()
    end)

    -- Cadencia y SFX
    self.lastFireTime = self.fireRate
    audios.shoot:clone():play()

    -- Autodestrucción de seguridad
    Timer.after(8, function()
        if destroyed then return end
        destroyed = true
        if hitConn and hitConn.Disconnect then hitConn:Disconnect() end
        self.bullets[id] = nil
        if bullet and bullet.Destroy then bullet:Destroy() end
    end):addToGroup(PlayingTimers)
end

return gun

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

local audios = {
    dmged =  love.audio.newSource("assets/sfx/hitHurtPlayer.wav", "static"),
    dash = love.audio.newSource("assets/sfx/dash.wav", "static")
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
    self.health = World.player.health or 100
    self.maxHealth = 100
    self.collision.link = self
    self.speed = 250
    self.invulnerable = false

    self.isDashing = false
    self._dashCooldown = 0
    self._dashHitbox = nil

    self.flash = 0
    self.flashDur = .1
    return self
end

-- Crea (si no existe) el hitbox de daño que sigue al jugador durante el dash
function player:_ensureDashHitbox()
    if self._dashHitbox and self._dashHitbox._alive then return end
    local hb = Collisions.new("hitbox", true)
    hb._alive = true
    hb.link = self
    hb.anchor = {.5, .5}
    hb.size = self.collision.size * 1.3
    hb:AddTag("player")
    hb:AddTag("projectile")
    hb:AddTag("dash")

    -- Al tocar enemigos, hacer daño
    hb.onHit:Connect(function(other)
        if other:HasTag("enemy") and other.link and other.link.Damage then
            other.link:Damage(1) -- puedes subir/bajar el daño del dash
        end
    end)

    self._dashHitbox = hb
end

-- Inicia el dash si no está en cooldown
function player:Dash()
    if self.isDashing or (self._dashCooldown or 0) > 0 then return end

    audios.dash:clone():play()
    self.isDashing = true
    self.invulnerable = true

    -- no atravesar paredes: ¡mantenemos BOX!
    -- pero ignoramos empuje contra enemigos durante el dash
    self.collision.blockFilter = function(_, other)
        -- no bloquear con enemigos durante dash
        if other:HasTag("enemy") then return false end
        return true
    end

    -- Aumenta velocidad
    self.speed = (self.speed or 250) * 3

    -- Hitbox ofensivo que “sigue” al jugador
    self:_ensureDashHitbox()

    -- Timer para finalizar dash
    Timer.after(.3, function()
        -- volver a normal
        if self._destroying then return end
        self.isDashing = false
        self.invulnerable = false

        self.speed = (self.speed or 250) / 3
        self.collision.blockFilter = nil -- vuelve a bloquear enemigos normalmente

        -- apagar hitbox ofensivo
        if self._dashHitbox and self._dashHitbox._alive then
            self._dashHitbox:Destroy()
        end
        self._dashHitbox = nil

        -- cooldown
        self._dashCooldown = .01
    end):addToGroup(PlayingTimers)
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

     -- actualizar hitbox de dash para que siga al jugador
    if self._dashHitbox and self._dashHitbox._alive then
        self._dashHitbox.position = self.collision.position
    end

    -- cooldown
    if (self._dashCooldown or 0) > 0 then
        self._dashCooldown = math.max(0, self._dashCooldown - dt)
    end
end

function player:Damage(dmg)
    if self._destroying or self.invulnerable then return end
    audios.dmged:clone():play()

    self.health = self.health - dmg
    print("health: ".. self.health, "damage: ".. dmg)
    World.player.health = self.health
    self.flash = 1
    Timer.after(self.flashDur, function ()
        self.flash = 0
    end):addToGroup(PlayingTimers)

    if self.health <= 0 and not self._dead then
        self._dead = true
        Transition.play(function ()
            Gamestate = "playing"
            World.player.health = self.maxHealth
            Scene.reload()
        end)
    end
end

function player:draw()
    if self._destroying then return end
    local x,y = self.collision.position:toPixels()
    if self.flash > 0 then
        love.graphics.setShader(Shaders.flash)
        Shaders.flash:send("u_flash", self.flash)
    end
    self.sprite:draw(x, y)
    love.graphics.setShader()
end

return player
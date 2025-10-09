---
-- Coleccionable "Data Shard".
-- Al tocarlo el jugador, incrementa Player.shards y se destruye.
-- @classmod Shard

local audios = {
    pickup = love.audio.newSource("assets/sfx/pickup.wav", "static")
}

local Shard = {}
Shard.__index = Shard

-- opcional: pequeño “bobbing” visual
local BOB_SPEED = 2.2
local BOB_PIX   = 5
---
-- Crea una nueva instancia de Shard
-- @tparam UDim2 pos posición en escala
-- @tparam[opt] string spritePath ruta del sprite (1x1 frame)
-- @treturn Shard
function Shard.new(pos, spritePath, id)
    local self = setmetatable({}, Shard)
    self.id = id

    -- Visual (puedes cambiar por Animation.new si tienes sheet)
    self.sprite = Animation.new(spritePath or "assets/sprites/shard.png", 25, 25, 1, 1, 1)
    self.sprite:Pause()
    self.sprite.anchor = {.5, .5}

    -- Colisión: hitbox (no bloquea)
    self.collision = Collisions.new("hitbox")
    self.collision.position = pos or UDim2.fromScale(.5,.5)
    self.collision.size     = UDim2.fromScale(0.02, 0.06)
    self.collision.anchor   = {.5, .5}
    self.collision:AddTag("shard")
    self.collision.link = self

    -- Estado
    self._destroying = false
    self._t = 0

    -- Recolecta al tocar jugador
    self._conn = self.collision.onHit:Connect(function(other)
        if self._destroying then return end
        if other:HasTag("player") then
            self:Collect()
        end
    end)

    return self
end

function Shard:Collect()
    if self._busy then return end
    self._busy = true

    MathQuiz.start({
        rounds = 3,      -- cuántas preguntas
        timePer = 25,    -- segundos por pregunta
        onWin = function()
            World.onShardCollected(self.id)
            self:Destroy()
        end,
        onLose = function()
            -- opcional: feedback y permitir reintento
            -- Ej: pequeña vibración, sonido, etc.
            self._busy = false
        end
    })
end

function Shard:update(dt)
    function Shard:update(dt)
    if self._destroying then return end
        self._t = self._t + dt

        -- bobbing vertical
        local x,y = self.collision.position:toPixels()
        local off = math.sin(self._t * 2.2) * 5
        self._drawX, self._drawY = x, y + off

        -- brillo sutil (alpha)
        local a = 0.85 + 0.15 * math.sin(self._t * 3.0)
        self.sprite.color = {1, 1, 1, a} -- añadido
    end
end

function Shard:draw()
    if self._destroying then return end
    local x = self._drawX or select(1, self.collision.position:toPixels())
    local y = self._drawY or select(2, self.collision.position:toPixels())
    --self.sprite:draw(x - self.sprite.gridWidth/2, y - self.sprite.gridHeight/2)
    self.sprite:draw(x, y)
end

function Shard:Destroy()
    if self._conn then self._conn:Disconnect() end
    if self.collision and self.collision.Destroy then self.collision:Destroy() end
    self.collision = nil
    self.sprite = nil
    self._destroying = true
end

return Shard

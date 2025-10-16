--- ProximityHum: zumbido/loop con volumen según cercanía (en escala UDim2).
-- Depende de: Timer, UDim2, Player (posición en UDim2), PlayingTimers.
-- Uso:
--   local hum = ProximityHum.new(UDim2.fromScale(1.1, 0.4), { sound="assets/sfx/shard_hum.wav", maxDistScale=0.35 })
--   hum:setPos(UDim2.fromScale(1.2, 0.4))
--   hum:setEnabled(false)       -- fade a 0, sigue vivo
--   hum:stopAndDestroy()        -- fade a 0 y destruye al llegar a silencio
-- @classmod ProximityHum

local ProximityHum = {}
ProximityHum.__index = ProximityHum

--- Crea un hum de proximidad.
-- @tparam UDim2 pos posición en escala (centro de la “fuente”)
-- @tparam string sound ruta del sonido (loop)
-- @tparam number maxDistScale distancia máxima en escala (0.3 = 30% ancho pantalla)
-- @tparam number maxVol volumen máximo (0-1)
-- @tparam number smooth suavizado (10-20 recomendado)
-- @treturn ProximityHum
function ProximityHum.new(pos, sound, maxDistScale, maxVol, smooth)
    local self = setmetatable({}, ProximityHum)

    self.pos = pos or UDim2.fromScale(.5,.5)
    self.maxDist = maxDistScale or 0.3   -- distancia “plana” en escala (no px)
    self.maxVol  = maxVol or 0.8
    self.smooth  = smooth or 10
    self.enabled = true
    self._pendingDestroy = false
    self._vol = 0

    local sfxPath = sound or "assets/sfx/shardhum.wav"
    self._src = love.audio.newSource(sfxPath, "static")
    self._src:setLooping(true)
    self._src:setVolume(0)
    self._src:play()

    Timer.every(0.1, function() 
        if Gamestate ~= "playing" and self._src then self._src:setVolume(0) return end
        self:_update(0.1) 
    end)
    return self
end
    --- Hace fade a 0 y destruye al llegar a silencio.
function ProximityHum:stopAndDestroy()
    self.enabled = false
    self._pendingDestroy = true
end

    -- distancia en “escala” (plana) entre dos UDim2
local function distScale(a, b)
    local dx = (a.x.scale - b.x.scale)
    local dy = (a.y.scale - b.y.scale)
    return math.sqrt(dx*dx + dy*dy)
end

function ProximityHum:_update(dt)
    if not self._src then return end

    -- Objetivo de volumen según distancia en escala
    local target = 0
    if self.enabled and Player and Player.collision and Player.collision.position then
        local d = distScale(self.pos, Player.collision.position)
        if d < self.maxDist then
        local t = 1 - (d / self.maxDist) -- 1 cerca, 0 lejos
        t = math.max(0, math.min(1, t)) ^ 1.2
        target = self.maxVol * t
        else
        target = 0
        end
    end

    -- Lerp suave de volumen
    self._vol = self._vol + (target - self._vol) * math.min(1, dt * self.smooth)
    self._src:setVolume(self._vol)

    -- Si estamos en “apagar y destruir”, haz fade a 0 y destruye
    if self._pendingDestroy and self._vol <= 0.01 then
        self:Destroy()
    end
end

function ProximityHum:Destroy()
    if self._tick then self._tick:Destroy() end
    self._tick = nil
    if self._src then
        self._src:stop()
        self._src = nil
    end
end

return ProximityHum

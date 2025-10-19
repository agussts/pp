-- HUD minimal de shards (3 slots), sin outline, bloqueados = oscurecidos.
-- Usa ONLY scale, es persistente y se auto-actualiza con el evento "shard_collected".

local ShardsIconHUD = {}
ShardsIconHUD.__index = ShardsIconHUD
ShardsIconHUD._singleton = nil --evita duplicados

-- Orden “respectivo”: izquierda=basural, centro=datacenter, derecha=CDN.
local SLOT_IDS = { "trash1", "dc_shard", "cdn_shard" }

-- Layout (todo en escala de pantalla)
local ICON_W = 0.15
local ICON_H = 0.32
local GAP_S    = 0.02     -- separación entre iconos
local MARGIN_X = 0.02     -- margen desde borde derecho
local MARGIN_Y = 0.04     -- margen desde borde inferior

-- Apariencia
local SPRITE   = "assets/sprites/shard.png"
local TINT_DIM = {0.25, 0.25, 0.25, 1.0}  -- silueta oscurecida

-- Pulso (al desbloquear)
local PULSE_UP     = 1.15
local PULSE_IN_S   = 5.0
local PULSE_OUT_S  = 3.8

-- Helpers
local function isCollected(id)
  return World and World.shards and World.shards.collectedIds and World.shards.collectedIds[id] == true
end

-- Construye un slot sencillo con dos imágenes (normal y “dim”)
local function newSlot(parent, idxFromRight)
  local wrap = Frame.new()
  wrap:setParent(parent)
  wrap.anchorPoint = {1,1}
  wrap.bgColor     = {0,0,0,0}
  wrap.size        = UDim2.fromScale(ICON_W, ICON_H)
  wrap.position    = UDim2.fromScale(1 - (idxFromRight-1)*(ICON_W + GAP_S), 1)

  local img = ImageLabel.new(SPRITE)
  img:setParent(wrap)
  img.anchorPoint = {0.5, 0.5}
  img.position    = UDim2.fromScale(0.5, 0.5)
  img.size        = UDim2.fromScale(1, 1)
  img.zIndex      = 2

  local dim = ImageLabel.new(SPRITE)
  dim:setParent(wrap)
  dim.anchorPoint = {0.5, 0.5}
  dim.position    = UDim2.fromScale(0.5, 0.5)
  dim.size        = UDim2.fromScale(1, 1)
  dim.imageColor  = TINT_DIM
  dim.zIndex      = 1

  return {
    wrap = wrap,
    img  = img,
    dim  = dim,
    scale = 1.0,
    pulsing = false,
    goingUp = true,
    setScale = function(self, s)
      self.scale = s
      -- Escalamos la imagen; el wrap queda fijo para que el layout no “salte”
      self.img.size = UDim2.fromScale(s, s)
      self.dim.size = UDim2.fromScale(s, s)
    end,
    setUnlocked = function(self, unlocked)
      self.img.visible = unlocked
      self.dim.visible = not unlocked
    end,
    startPulse = function(self)
      self.pulsing = true
      self.goingUp = true
      self:setScale(1.0)
    end,
    updatePulse = function(self, dt)
      if not self.pulsing then return end
      if self.goingUp then
        local s = self.scale + (PULSE_UP - self.scale) * math.min(1, PULSE_IN_S * dt)
        if s >= PULSE_UP - 0.01 then s = PULSE_UP; self.goingUp = false end
        self:setScale(s)
      else
        local s = self.scale - (self.scale - 1.0) * math.min(1, PULSE_OUT_S * dt)
        if s <= 1.01 then s = 1.0; self.pulsing = false end
        self:setScale(s)
      end
    end
  }
end

-- Crea raíz y slots
local function buildUI(self)
  local n = #SLOT_IDS
  local totalW = n*ICON_W + (n-1)*GAP_S

  self.root = Frame.new()
  self.root:setPersistent(true)
  self.root.bgColor     = {0,0,0,0}
  self.root.anchorPoint = {1,1}
  self.root.zIndex      = 30
  self.root.size        = UDim2.fromScale(totalW, ICON_H)
  self.root.position    = UDim2.fromScale(1 - MARGIN_X, 1 - MARGIN_Y)

  self.slots = {}
  for i, id in ipairs(SLOT_IDS) do
    print(i, id)
    local slot = newSlot(self.root, i)
    slot._id = id
    table.insert(self.slots, slot)
  end
end

-- Refresca visibilidad y detecta qué slot se desbloqueó para pulse
local function refresh(self)
  for _, s in ipairs(self.slots) do
    local has = isCollected(s._id)
    local was = self._prev[s._id] == true
    s:setUnlocked(has)
    if (not was) and has then s:startPulse() end
    self._prev[s._id] = has
  end
end

-- ===== API =====
function ShardsIconHUD.new()
  if ShardsIconHUD._singleton then return ShardsIconHUD._singleton end --evita duplicados
  local self = setmetatable({}, ShardsIconHUD)
  self._prev = {}     -- snapshot para detectar unlocks
  buildUI(self)
  refresh(self)

  -- Escucha el progreso global y refresca.
  -- Nota: tu World.onShardCollected dispara (collected, needed), no id.
  self._conn = Connect("shard_collected", function()
    refresh(self)
  end)

  ShardsIconHUD._singleton = self --evita duplicados
  return self
end

function ShardsIconHUD:update(dt)
  for _, s in ipairs(self.slots) do
    s:updatePulse(dt or 0)
  end
end

function ShardsIconHUD:Destroy()
  if self._conn and self._conn.Disconnect then self._conn:Disconnect() end
  self._conn = nil
  if self.root and self.root.Destroy then self.root:Destroy() end
  self.root = nil
  self.slots = nil
  self._prev = nil
end

return ShardsIconHUD

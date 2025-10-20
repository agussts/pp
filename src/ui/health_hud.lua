-- HUD de Vida (corazones) – simple, solo scale. Persistente.

local HealthHUD = {}
HealthHUD.__index = HealthHUD
HealthHUD._singleton = nil

-- Layout (en escala)
local HEART_W   = 0.072
local HEART_H   = .4
local GAP_S     = 0.010
local MARGIN_X  = 0.02
local MARGIN_Y  = 0.02

local NUM_HEARTS_UI = 10                  -- fijo: 10 corazones
local ICON_FULL = "assets/sprites/heart.png"
local TINT_DIM  = {0.18, 0.18, 0.18, 1.0}

-- ---- helpers ----
local function getHP()
  local p = rawget(_G, "Player")
  if not p then return 0, 100 end
  local hp   = p.health or 0
  local maxh = p.maxHealth or hp
  hp   = math.max(0, math.floor(hp))
  maxh = math.max(1, math.floor(maxh))
  return hp, maxh
end

local function fullHearts(hp, maxHP, nHearts)
  local per = math.max(1, maxHP / nHearts)
  return math.max(0, math.min(nHearts, math.floor(hp / per + 1e-6)))
end

local function ensureFlashOverlay(self)
  if self.flashFx and self.flashFx.Destroy then
    self.flashFx:Destroy()
  end
  self.flashFx = Frame.new()
  self.flashFx:setParent(self.bar)     -- mismo padre que los corazones
  self.flashFx.anchorPoint = {0,1}
  self.flashFx.position    = UDim2.fromScale(0, 1)
  self.flashFx.size        = UDim2.fromScale(1, 1)  -- cubre toda la barra
  self.flashFx.bgColor     = {0.8, 0, 0, 0}         -- alpha lo controlas en update
  self.flashFx.zIndex      = 100
  self.flashFx.visible     = true
  self._flash = self._flash or 0
end


-- ---- construcción UI ----
local function buildUI(self)
  self.root = Frame.new()
  self.root:setPersistent(true)
  self.root.anchorPoint = {0,1}
  self.root.bgColor     = {0,0,0,0}
  self.root.zIndex      = 40

  -- container de corazones
  self.bar = Frame.new()
  self.bar:setParent(self.root)
  self.bar.anchorPoint = {0,0}
  self.bar.bgColor     = {0,0,0,0}
  self.bar.zIndex      = 41

  -- etiqueta HP
  self.label = Textlabel.new("")
  self.label:setParent(self.root)
  self.label.anchorPoint = {0,0}
  self.label.textColor   = {1,1,1,1}
  if Fonts and Fonts.VT323 then self.label.font = Fonts.VT323 end
end

local function layout(self)
  local n = self.nHearts
  local totalW = n*HEART_W + (n-1)*GAP_S

  -- root pegado abajo-izquierda
  self.root.size     = UDim2.fromScale(totalW, HEART_H + 0.05)
  self.root.position = UDim2.fromScale(MARGIN_X, 1 - MARGIN_Y + .11)  -- esquina inferior izq

  -- barra de corazones al fondo del root
  self.bar.anchorPoint = {0,1}
  self.bar.size        = UDim2.fromScale(totalW, HEART_H)
  self.bar.position    = UDim2.fromScale(0, 1)

  -- label encima de la barra
  self.label.anchorPoint = {.375,1}
  self.label.size        = UDim2.fromScale(totalW, 0.05)
  self.label.position    = UDim2.fromScale(0, 1 - HEART_H - 0.065)

  -- al final de layout(self)
    if self.flashFx then
        self.flashFx.anchorPoint = {0,1}
        self.flashFx.position    = UDim2.fromScale(0, 1)
        self.flashFx.size        = UDim2.fromScale(1, 1)
    end
end


local function makeHearts(self)
  self.slots = {}
  for i=1, self.nHearts do
    local wrap = Frame.new()
    wrap:setParent(self.bar)
    wrap.anchorPoint = {0,0}
    wrap.bgColor     = {0,0,0,0}
    wrap.size        = UDim2.fromScale(HEART_W, HEART_H)
    local x = (i-1) * (HEART_W + GAP_S)
    wrap.position    = UDim2.fromScale(x, 0)

    local full = ImageLabel.new(ICON_FULL)
    full:setParent(wrap)
    full.anchorPoint = {0.5,0.5}
    full.position    = UDim2.fromScale(0.5,0.5)
    full.size        = UDim2.fromScale(1,1)
    full.zIndex      = 2

    local dim = ImageLabel.new(ICON_FULL)
    dim:setParent(wrap)
    dim.anchorPoint = {0.5,0.5}
    dim.position    = UDim2.fromScale(0.5,0.5)
    dim.size        = UDim2.fromScale(1,1)
    dim.imageColor  = TINT_DIM
    dim.zIndex      = 1

    table.insert(self.slots, {wrap=wrap, full=full, dim=dim})
  end
end

local function refresh(self)
  local hp, maxHP = getHP()

  -- 10 corazones fijos, pero si cambia el total reconstruimos (por si el HUD se creó antes)
  if not self.nHearts then
    self.nHearts = NUM_HEARTS_UI
    makeHearts(self)
    layout(self)
  end

  local full = fullHearts(hp, maxHP, self.nHearts)
  for i,s in ipairs(self.slots) do
    s.full.visible = (i <= full)
    s.dim.visible  = (i >  full)
  end
  self.label.text = ("HP %d/%d"):format(hp, maxHP)

  -- flash si bajó vida
  if self._lastHP and hp < self._lastHP then
    self._flash = 0.22
  end
  self._lastHP = hp
end

-- ---- API ----
function HealthHUD.new()
  if HealthHUD._singleton then return HealthHUD._singleton end
  local self = setmetatable({}, HealthHUD)
  buildUI(self)
  self.nHearts = NUM_HEARTS_UI
  makeHearts(self)
  ensureFlashOverlay(self)
  layout(self)
  refresh(self)

  HealthHUD._singleton = self
  return self
end

function HealthHUD:update(dt)
  refresh(self)

  -- flash overlay solo en el rectángulo de corazones
  if self._flash and self._flash > 0 then
    self._flash = math.max(0, self._flash - (dt or 0))
    local a = 0.35 * (self._flash / 0.22)
    self.flashFx.bgColor = {0.8, 0, 0, a}
  else
    self.flashFx.bgColor = {0.8, 0, 0, 0}
  end
end

function HealthHUD:Destroy()
  if self.root and self.root.Destroy then self.root:Destroy() end
  self.root, self.bar, self.label, self.slots, self.flashFx = nil, nil, nil, nil, nil
  HealthHUD._singleton = nil
end

return HealthHUD

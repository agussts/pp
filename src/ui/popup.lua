-- Popups: notificaciones breves con texto y (opcional) ícono.
-- - Todo en UDim2 scale; animaciones con Timer (sin update externo).
-- - Cola secuencial (no se solapan).
-- - Se autocierra: entra, sube, baja y desaparece (fade + pequeño slide).
-- Opciones:
--   text (req), icon (op), duration (op), tone (info|ok|warn|error), corner (bl|br|tl|tr).
-- Uso:
--   local Popups = require("src.ui.popup")
--   Popups.show{ text="Access token acquired!", icon="assets/sprites/token.png", tone="ok", corner="bl" }

local Popups = {}
Popups.__index = Popups

local _singleton = nil

-- Layout (escala)
local W  = 0.25
local H  = 0.12
local MX = 0.02
local MY = 0.05
local GAP= 0.015 -- fuera de pantalla

-- Tiempos
local T_IN      = 0.20    -- slide-in
local T_BOB_UP  = 0.14    -- subir
local T_BOB_DN  = 0.18    -- bajar
local T_FADE    = 0.22    -- desvanecer/slide-out
local HOLD_S    = 1    -- pausa breve antes del bob (sensación de lectura)
local BLANK_PATH = "assets/sprites/blank.png"
local BLANK_TEX  = love.graphics.newImage(BLANK_PATH)


-- Amplitud del bob (en escala)
local BOB_DY = 0.03

-- Paletas
local TONES = {
  info  = { bg={0,0,0,0.80},       fg={1,1,1,1} },
  ok    = { bg={0.10,0.35,0.10,0.85}, fg={1,1,1,1} },
  warn  = { bg={0.35,0.25,0.05,0.85}, fg={1,1,1,1} },
  error = { bg={0.35,0.08,0.08,0.88}, fg={1,1,1,1} },
}

local function lerp(a, b, t) return a + (b - a) * t end
local function colerp(a, b, t)
  return { lerp(a[1],b[1],t), lerp(a[2],b[2],t), lerp(a[3],b[3],t), lerp(a[4],b[4],t) }
end

local function xyForCorner(corner)
  if corner == "br" then
    return {ax=1, ay=1}, {inPos={1-MX, 1-MY}, outPos={1-MX, 1+GAP}}, -1
  elseif corner == "tl" then
    return {ax=0, ay=0}, {inPos={MX, MY}, outPos={MX, -GAP}},  1
  elseif corner == "tr" then
    return {ax=1, ay=0}, {inPos={1-MX, MY}, outPos={1-MX, -GAP}}, 1
  else -- "bl"
    return {ax=0, ay=1}, {inPos={MX, 1-MY}, outPos={MX, 1+GAP}}, -1
  end
end

local function ensureTG(self)
  if not self._tg then
    self._tg = Timer.group.new()
  end
  return self._tg
end

-- Crea/actualiza icono si hay path; lo oculta o destruye si no hay.
-- Borra o asigna el icono de forma segura (evita “fantasmas”)
local function setIcon(self, iconPath)
  -- crea el ImageLabel si no existe
  if not self.icon then
    self.icon = ImageLabel.new(BLANK_PATH)  -- inicializa con blank
    self.icon:setParent(self.box)
    self.icon.anchorPoint = {0, 0.5}
    self.icon.position    = UDim2.fromScale(0.08, 0.5)
    self.icon.size        = UDim2.fromScale(0.22, 0.76)
    self.icon.zIndex      = (self.text and (self.text.zIndex or 1) or 1)
  end

  local hasIcon = (iconPath ~= nil and iconPath ~= "")
  if hasIcon then
    -- icono real
    self.icon.image = love.graphics.newImage(iconPath)
    self.icon.visible = true
  else
    -- icono “vacío”: 1px transparente
    self.icon.image = BLANK_TEX
    self.icon.visible = true   -- visible da igual: es transparente
  end
  return hasIcon
end


-- Ajusta el rect del texto según haya icono visible o no (evita solapados)
local function layoutTextForIcon(self, hasIcon)
  local leftPad = hasIcon and 0.36 or 0.06
  if self.text then
    self.text.position = UDim2.fromScale(leftPad, 0.5)
    self.text.size     = UDim2.fromScale(1 - leftPad - 0.06, 0.78)
  end
end


local function ensureSingleton(holdTime)
  if _singleton then 
    _singleton.root.visible = true
    _singleton.box.visible = true
    _singleton.box:applyStyle(Border, { thicknessPx=2, color={1,1,1,0.7}, insetPx=0, zOffset=1 })
    _singleton.icon.visible = true
    _singleton.text.visible = true
    return _singleton 
  end
  local self = setmetatable({}, Popups)
  self.queue = {}
  self.showing = false
  self._tg = Timer.group.new()
  self.holdTime = holdTime

  self.root = Frame.new()
  self.root:setPersistent(true)
  self.root.bgColor = {0,0,0,0}
  self.root.size = UDim2.fromScale(W, H)
  self.root.zIndex = 500
  self.root.visible = false

  self.box = Frame.new()
  self.box:setParent(self.root)
  self.box.size = UDim2.fromScale(1,1)
  self.box.position = UDim2.fromScale(0.5,0.5)
  self.box.anchorPoint = {0.5,0.5}
  self.box.bgColor = {0,0,0,0.85}
  self.box.visible = true
  if Border and self.box.applyStyle then
    self.box:applyStyle(Border, { thicknessPx=2, color={1,1,1,0.7}, insetPx=0, zOffset=1 })
  end

  self.icon = ImageLabel.new("assets/sprites/blank.png")
  self.icon:setParent(self.box)
  self.icon.visible = false
  self.icon.size = UDim2.fromScale(0.22, 0.80)
  self.icon.position = UDim2.fromScale(0.14, 0.5)
  self.icon.anchorPoint = {0.5, 0.5}
  self.icon.zIndex = 501
  self.icon.visible = true

  self.text = PrintfLabel.new("")
  self.text:setParent(self.box)
  self.text.align = "left"
  self.text.position = UDim2.fromScale(0.36, 0.5)
  self.text.size     = UDim2.fromScale(0.60, 0.78)
  self.text.anchorPoint = {0, 0.5}
  self.text.textColor = {1,1,1,1}
  self.text.visible = true
  if Fonts and Fonts.VT323small then self.text.font = Fonts.VT323small end
  self.text.zIndex = 502

  _singleton = self
  return self
end

local function applyTone(self, tone)
  local t = TONES[tone or "info"] or TONES.info
  self._bgFrom = {t.bg[1], t.bg[2], t.bg[3], 0.0}
  self._bgTo   = t.bg
  self._fgCol  = t.fg
  self.box.bgColor    = self._bgFrom
  self.text.textColor = self._fgCol
  self.icon.imageColor= {1,1,1,1}
end

local function setCorner(self, corner)
  local anchor, pos, bobSign = xyForCorner(corner)
  self.root.anchorPoint = {anchor.ax, anchor.ay}
  self._inPos  = pos.inPos
  self._outPos = pos.outPos
  self._bobSign = bobSign  -- +1 (desde top) / -1 (desde bottom)
  self.root.position = UDim2.fromScale(self._outPos[1], self._outPos[2])
end

local function configure(self, opt)
  self.text.text = tostring(opt.text or "")
  local hasIcon = setIcon(self, opt.icon)
  layoutTextForIcon(self, hasIcon)
  applyTone(self, opt.tone)
  setCorner(self, opt.corner or "bl")
  self._duration = tonumber(opt.duration) or (T_IN + HOLD_S + T_BOB_UP + T_BOB_DN + T_FADE)
end



-- ========== Animación (enter → bob up → bob down → fade out) ==========
local function animateIn(self, onDone)
  self.root.visible = true
  local t = 0
  local tick
  tick = Timer.every(1/60, function()
    t = math.min(1, t + (1/60)/T_IN)
    local x = lerp(self._outPos[1], self._inPos[1], t)
    local y = lerp(self._outPos[2], self._inPos[2], t)
    self.root.position = UDim2.fromScale(x, y)
    self.box.bgColor = colerp(self._bgFrom, self._bgTo, t)
    if t >= 1 then tick:Destroy(); if onDone then onDone() end end
  end)
  tick:addToGroup(ensureTG(self))
end

local function holdBrief(self, onDone)
  Timer.after(self.holdTime, function()
    if onDone then onDone() end
  end):addToGroup(ensureTG(self))
end

local function animateBobUp(self, onDone)
  local baseY = self._inPos[2]
  local targetY = baseY + self._bobSign * (-BOB_DY)  -- “sube” hacia el centro de pantalla
  local t = 0
  local tick
  tick = Timer.every(1/60, function()
    t = math.min(1, t + (1/60)/T_BOB_UP)
    local y = lerp(baseY, targetY, t)
    self.root.position = UDim2.fromScale(self._inPos[1], y)
    if t >= 1 then tick:Destroy(); if onDone then onDone() end end
  end)
  tick:addToGroup(ensureTG(self))
end

local function animateBobDown(self, onDone)
  local topY  = (self.root.position and self.root.position.y and self.root.position.y.scale) or self._inPos[2]
  local baseY = self._inPos[2]
  local t = 0
  local tick
  tick = Timer.every(1/60, function()
    t = math.min(1, t + (1/60)/T_BOB_DN)
    local y = lerp(topY, baseY, t)
    self.root.position = UDim2.fromScale(self._inPos[1], y)
    if t >= 1 then tick:Destroy(); if onDone then onDone() end end
  end)
  tick:addToGroup(ensureTG(self))
end

local function animateFadeOut(self, onDone)
  -- desvanecer y deslizar levemente hacia afuera
  local fromPos = { self._inPos[1], self._inPos[2] }
  local toPos   = { self._outPos[1], self._outPos[2] }
  local fromCol = { self.box.bgColor[1], self.box.bgColor[2], self.box.bgColor[3], self.box.bgColor[4] }
  local toCol   = { self._bgTo[1], self._bgTo[2], self._bgTo[3], 0.0 }

  local t = 0
  local tick
  tick = Timer.every(1/60, function()
    t = math.min(1, t + (1/60)/T_FADE)
    local x = lerp(fromPos[1], toPos[1], t)
    local y = lerp(fromPos[2], toPos[2], t)
    self.root.position = UDim2.fromScale(x, y)
    self.box.bgColor   = colerp(fromCol, toCol, t)
    if t >= 1 then
      tick:Destroy()
      self.root.visible = false
      if onDone then onDone() end
    end
  end)
  tick:addToGroup(ensureTG(self))
end

function Popups.destroy()
  if not Popups._inst then return end
  local self = Popups._inst

  if self._tg then self._tg:Destroy() end
  self._tg = nil

  if self.root and self.root.Destroy then self.root:Destroy() end
  self.root = nil
  self.queue = nil
  self.showing = false

  Popups._inst = nil
end

function Popups._onPopupFinished(self)
  self.showing = false
  for i,v in pairs(self) do
    if type(v) == "table" and v.setParent then
      v:clearStyles()
      v.visible = false
    end
  end
  if #self.queue > 0 then 
    Popups.show(table.remove(self.queue,1)) 
  end
end

-- API
function Popups.show(opt)
  opt = opt or {}
  local self = ensureSingleton(opt.holdTime or HOLD_S)

  if self.showing then
    table.insert(self.queue, opt)
    return
  end

  self.showing = true
  configure(self, opt)

  animateIn(self, function()
    holdBrief(self, function()
      animateFadeOut(self, function()
        -- FINALIZAR sin destruir la instancia
        self.showing = false
        self.root.visible = false

        -- if #self.queue > 0 then
        --   local nextOpt = table.remove(self.queue, 1)
        --   Popups.show(nextOpt)         -- muestra el siguiente
        -- end
        Popups._onPopupFinished(self)
      end)
    end)
  end)
end


return Popups

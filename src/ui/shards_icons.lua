-- HUD de shards con “pulse” al desbloquear y secuencia final:
-- inflar + blanquear (shader) + pop (anim opcional) + mensaje final.
-- Todo en scale. Persistente. Depende de: Frame, ImageLabel, Textlabel, Timer, Connect, World, Shaders, Animation, AnimationLabel.

local ShardsIconHUD = {}
ShardsIconHUD.__index = ShardsIconHUD
ShardsIconHUD._singleton = nil

-- Orden respectivo (ajústalo si quieres otro mapping)
local SLOT_IDS = { "trash1", "dc_shard", "cdn_shard" }

-- Layout (escala)
local ICON_W = 0.16
local ICON_H = 0.36
local GAP_S    = 0.02
local MARGIN_X = 0.02
local MARGIN_Y = 0.04
local COUNTER_H = 0.10   -- <<--- ALTO extra para el texto "Shards: X/3"

local SPRITE   = "assets/sprites/shard.png"
local TINT_DIM = {0.05, 0.05, 0.05, 1.0}

-- Pulso al desbloquear
local PULSE_UP     = 1.15
local PULSE_IN_S   = 5.0
local PULSE_OUT_S  = 3.8

-- Final sequence
local FINAL_DELAY_S     = 2.0
local FINAL_INFLATE_S   = 0.9
local FINAL_SCALE_UP    = 1.35
local FINAL_STAGGER_S   = 0.08
local FINAL_MSG         = "Go back with '???'"

-- VFX pop: se usa si existe la sheet. Por defecto “blink.png”.
local POP_SHEET   = "assets/sprites/blink.png"
local POP_W, POP_H, POP_CX, POP_CY, POP_DT = 27, 27, 3, 3, 0.04

local function fileExists(path)
  return love.filesystem.getInfo(path) ~= nil
end

local function isCollected(id)
  return World and World.shards and World.shards.collectedIds and World.shards.collectedIds[id] == true
end

local function allCollected()
  for _, id in ipairs(SLOT_IDS) do
    if not isCollected(id) then return false end
  end
  return true
end

-- NUEVO: helper para contador
local function getCounts()
  local c = 0
  for _, id in ipairs(SLOT_IDS) do
    if isCollected(id) then c = c + 1 end
  end
  local n = (World and World.shards and World.shards.needed) or #SLOT_IDS
  return c, n
end

-- Slot (img normal + dim). El blanqueo se hace con shader sobre la img normal.
local function newSlot(parent, idxFromLeft)
  local wrap = Frame.new()
  wrap:setParent(parent)
  wrap.anchorPoint = {-3,1}
  wrap.bgColor     = {0,0,0,0}
  wrap.size        = UDim2.fromScale(ICON_W, ICON_H)
  local x = (idxFromLeft-1)*(ICON_W + GAP_S)
  wrap.position    = UDim2.fromScale(x, 1)

  local img = ImageLabel.new(SPRITE)
  img:setParent(wrap)
  img.anchorPoint = {0.5, 0.5}
  img.position    = UDim2.fromScale(0.5, 0.5)
  img.size        = UDim2.fromScale(1, 1)
  img.zIndex      = 3

  local dim = ImageLabel.new(SPRITE)
  dim:setParent(wrap)
  dim.anchorPoint = {0.5, 0.5}
  dim.position    = UDim2.fromScale(0.5, 0.5)
  dim.size        = UDim2.fromScale(1, 1)
  dim.imageColor  = TINT_DIM
  dim.zIndex      = 2

  if Shaders and Shaders.whiten then
    img.shader = Shaders.whiten
    if img.setShaderUniform then img:setShaderUniform("u_white", 0.0) end
  end

  return {
    id   = nil,
    wrap = wrap,
    img  = img,
    dim  = dim,

    scale = 1.0,
    pulsing = false,
    goingUp = true,

    -- final seq
    f_state = "idle",   -- idle | inflate | popped | done
    f_t     = 0,
    f_wait  = 0,
    popAL   = nil,
    _popSpawned = false,

    setScale = function(self, s)
      self.scale = s
      self.img.size = UDim2.fromScale(s, s)
      self.dim.size = UDim2.fromScale(s, s)
    end,

    setUnlocked = function(self, unlocked)
      self.img.visible   = unlocked
      self.dim.visible   = not unlocked
      if self.img.shader and self.img.setShaderUniform then
        self.img:setShaderUniform("u_white", 0.0)
      end
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
    end,

    startFinal = function(self, stagger)
      self.f_state = "inflate"
      self.f_t     = 0
      self.f_wait  = math.max(0, stagger or 0)
      self._popSpawned = false
      self:setScale(1.0)
      self.img.visible = true
      self.dim.visible = false
      if self.img.shader and self.img.setShaderUniform then
        self.img:setShaderUniform("u_white", 0.0)
      end
    end,

    updateFinal = function(self, dt)
      if self.f_state == "idle" or self.f_state == "done" then return end

      if self.f_wait > 0 then
        self.f_wait = math.max(0, self.f_wait - dt)
        return
      end

      if self.f_state == "inflate" then
        self.f_t = math.min(1, self.f_t + (dt / FINAL_INFLATE_S))
        local s  = 1 + (FINAL_SCALE_UP - 1)*self.f_t
        self:setScale(s)
        if self.img.shader and self.img.setShaderUniform then
          self.img:setShaderUniform("u_white", self.f_t)
        end

        if self.f_t >= 1 then
          self.f_state = "popped"
          self.img.visible = false
          self.dim.visible = false

          if not self._popSpawned and fileExists(POP_SHEET) and Animation and AnimationLabel then
            self._popSpawned = true
            local anim = Animation.new(POP_SHEET, POP_W, POP_H, POP_CX, POP_CY, POP_DT)
            anim.loop = false
            anim.anchor = {0.5, 0.5}

            local pop = AnimationLabel.new(anim, { fit="contain", scale=1.2, play=true })
            pop:setParent(self.wrap)
            pop.position = UDim2.fromScale(0.3, 0.3)
            pop.size     = UDim2.fromScale(.5, .5)
            pop.zIndex   = (self.img.zIndex or 2) + 1

            pop.OnFinish:Connect(function()
              pop:Destroy()
              self.f_state = "done"
            end)
            self.popAL = pop
          else
              self.f_state = "done"
          end
        end

      elseif self.f_state == "popped" then
        self.popAL.update(dt)
      end
    end
  }
end

-- NUEVO: actualizador del contador
local function updateCountLabel(self)
  if not self.countLbl then return end
  local c, n = getCounts()
  self.countLbl.text = ("Shards: %d/%d"):format(c, n)
end

local function buildUI(self)
  local n = #SLOT_IDS
  local totalW = n*ICON_W + (n-1)*GAP_S

  self.root = Frame.new()
  self.root:setPersistent(true)
  self.root.bgColor     = {0,0,0,0}
  self.root.anchorPoint = {1,1}
  self.root.zIndex      = 30
  -- <<--- Aumentamos alto para el texto
  self.root.size        = UDim2.fromScale(totalW, ICON_H + COUNTER_H)
  self.root.position    = UDim2.fromScale(1 - MARGIN_X, 1 - MARGIN_Y)

  -- <<--- Label de contador arriba de los iconos
  self.countLbl = Textlabel.new("")
  self.countLbl:setParent(self.root)
  self.countLbl.anchorPoint = {0.5, 0}
  self.countLbl.position    = UDim2.fromScale(0.75, 0.45)
  self.countLbl.size        = UDim2.fromScale(1, COUNTER_H)
  self.countLbl.textColor   = {1,1,1,1}
  if Fonts and Fonts.VT323 then self.countLbl.font = Fonts.VT323 end
  self.countLbl.zIndex      = 31

  self.slots = {}
  for i, id in ipairs(SLOT_IDS) do
    local slot = newSlot(self.root, i)
    slot.id = id
    table.insert(self.slots, slot)
  end

  self.finalMsg = nil
end

local function refresh(self)
  for _, s in ipairs(self.slots) do
    local has = isCollected(s.id)
    local was = self._prev[s.id] == true
    s:setUnlocked(has)
    if (not was) and has then s:startPulse() end
    self._prev[s.id] = has
  end
  -- <<--- refrescar contador junto con iconos
  updateCountLabel(self)
end

local function triggerFinal(self)
  if self._finalSeq or self._finalDone then return end
  self._finalSeq = true

  Timer.after(FINAL_DELAY_S, function()
    for i, s in ipairs(self.slots) do
      s:startFinal((i-1)*FINAL_STAGGER_S)
    end
  end):addToGroup(PlayingTimers)
end

local function maybeShowFinalMsg(self)
  if self._shownFinalMsg then return end
  if self._finalDone then return end
  for _, s in ipairs(self.slots) do
    if s.f_state ~= "done" then return end
  end

  for _, s in ipairs(self.slots) do
    s.wrap.visible = false
  end

  -- <<--- ocultar contador para no tapar el mensaje final
  if self.countLbl then self.countLbl.visible = false end

  self.finalMsg = Textlabel.new(self._finalTextOverride or FINAL_MSG)
  self.finalMsg.position = UDim2.fromScale(0.1, .8)
  self.finalMsg.size     = UDim2.fromScale(1, 1)
  self.finalMsg:setParent(self.root)
  self.finalMsg.anchorPoint = {0,0.5}
  self.finalMsg.textColor= {1,1,1,1}
  self.finalMsg.zIndex   = 31
  if Fonts and Fonts.VT323 then self.finalMsg.font = Fonts.VT323 end

  self._shownFinalMsg = true
end

function ShardsIconHUD.new(opts)
  if ShardsIconHUD._singleton then return ShardsIconHUD._singleton end
  local self = setmetatable({}, ShardsIconHUD)
  self._prev = {}
  self._finalSeq  = false
  self._finalDone = false
  if opts and type(opts.finalText)=="string" then
    self._finalTextOverride = opts.finalText
  end

  buildUI(self)
  refresh(self)

  -- Evento: en tu World.onShardCollected se emiten (collected, needed).
  self._conn = Connect("shard_collected", function(id, collected, needed)
    refresh(self)
    if collected >= needed then
      triggerFinal(self)
    end
  end)

  if allCollected() then
    triggerFinal(self)
  end

  ShardsIconHUD._singleton = self
  return self
end

function ShardsIconHUD:update(dt)
  dt = dt or 0

  for _, s in ipairs(self.slots) do
    s:updatePulse(dt)
  end

  if self._finalSeq and not self._finalDone then
    for _, s in ipairs(self.slots) do
      s:updateFinal(dt)
    end
    maybeShowFinalMsg(self)
  end
end

function ShardsIconHUD:Destroy()
  if self._conn and self._conn.Disconnect then self._conn:Disconnect() end
  self._conn = nil
  if self.finalMsg and self.finalMsg.Destroy then self.finalMsg:Destroy() end
  if self.root and self.root.Destroy then self.root:Destroy() end
  self.root = nil
  self.slots = nil
  self._prev = nil
  self._finalSeq = nil
  self._finalDone = nil
  ShardsIconHUD._singleton = nil
end

return ShardsIconHUD

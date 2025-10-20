-- src/features/cdn_catwalks.lua
local CDN = {}
CDN.__index = CDN

local function newState()
  return {
    started = false,
    tearingDown = false,

    gateIn  = nil,
    gateOut = nil,

    -- runtime
    paths = {},         -- {k, col, sx,sy,sw,sh, ax,ay}
    spawns = {},        -- {pos, kind}
    displayPos = nil,

    -- math
    V = 2,
    op = "add",         -- "mul"|"add"|"sub"

    -- ui
    hudRoot = nil,
    hudLbl  = nil,
    hintLbl = nil,

    -- visuals
    visOpenCol  = {0.15, 0.95, 0.35, 0.1},   -- verde (abierto)
    visClosedCol= {1.00, 0.20, 0.20, 0.2},   -- rojo  (cerrado)
    visBorder   = {1,1,1,0.35},               -- borde sutil
    visBorderPx = 2,
    showVis     = true,
  }
end

local function applyOp(op, a, b)
  if op == "mul" then return a * b
  elseif op == "add" then return a + b
  elseif op == "sub" then return a - b
  else return a end
end

-- set -> sorted array
local function sortedKeys(set)
  local t = {}
  for k,_ in pairs(set) do table.insert(t, k) end
  table.sort(t, function(a,b)
    local na, nb = tonumber(a), tonumber(b)
    if na and nb then return na < nb else return tostring(a) < tostring(b) end
  end)
  return t
end

local function computeOpenSet(st)
  local openSet = {}
  for _,p in ipairs(st.paths) do
    if p.k ~= 0 and (st.V % p.k) == 0 then
      openSet[tostring(p.k)] = true
    end
  end
  return openSet
end

local function updateHUD(st)
  if not st.hudLbl then return end
  local openSet = computeOpenSet(st)
  local divs = sortedKeys(openSet)
  local openTxt = (#divs > 0) and table.concat(divs, ",") or "—"
  local v = st.V
  if v > 1e8 then v = "BIG" end
  st.hudLbl.text = ("V = %s   Operator = %s   Open Roads: %s"):format(v, st.op, openTxt)
end

local function setHint(st, msg, t)
  if not st.hintLbl then return end
  st.hintLbl.text = msg or ""
  if msg and msg ~= "" and t then
    Timer.after(t, function() if st and st.hintLbl then st.hintLbl.text="" end end):addToGroup(PlayingTimers)
  end
end

local function recomputePaths(st)
  for _,p in ipairs(st.paths) do
    local open = (p.k ~= 0) and ((st.V % p.k) == 0)
    p.col.enabled = not open  -- collider bloquea cuando NO está abierto
  end
  updateHUD(st)
end

local function buildHUD(st)
  st.hudRoot = Frame.new()
  st.hudRoot:setPersistent(true)
  st.hudRoot.size = UDim2.fromScale(1,1)
  st.hudRoot.bgColor = {0,0,0,0}

  st.hudLbl = Textlabel.new("")
  st.hudLbl:setParent(st.hudRoot)
  st.hudLbl.size = UDim2.fromScale(0.8, 0.06)
  st.hudLbl.anchorPoint = {0,0}
  st.hudLbl.position = st.displayPos or UDim2.fromScale(0.02, 0.02)
  st.hudLbl.textColor = {1,1,1,1}
  if Fonts and Fonts.VT323 then st.hudLbl.font = Fonts.VT323 end

  st.hintLbl = Textlabel.new("")
  st.hintLbl:setParent(st.hudRoot)
  st.hintLbl.position = UDim2.fromScale(0.02, 0.08)
  st.hintLbl.size     = UDim2.fromScale(0.8, 0.05)
  st.hintLbl.anchorPoint = {0,0}
  st.hintLbl.textColor= {1,0.9,0.5,1}
  if Fonts and Fonts.VT323 then st.hintLbl.font = Fonts.VT323 end

  updateHUD(st)
end

function CDN.attach(scene, map)
  local self = setmetatable({}, CDN)
  scene._cdn = self
  self.scene = scene
  self.map   = map
  self.st    = newState()
  local st = self.st

  -- factories
  local F = {}

  F["cdn_start"] = function(o, scn)
    local prompt = ProxPrompt.new("Press [%s] to start")
    prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
    prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
    prompt.collision.anchor   = {0,0}
    prompt.Triggered:Connect(function()
      if not World.shards.active then
            Popup.show{
                text = "You need an access token.",
                tone = "warn",
                corner = "bl"
            }
            return
        end
      st.started = not st.started
      Teach.chain("tut_cdn_intro", {
        { text="Stand on a number plate.", hold=2.0, inPosScale={0.15,0.18} },
        { text="Make an answer divisible by the gate.", hold=2.5, inPosScale={0.20,0.28} },
        { text="Matching paths open together!", hold=2.2, inPosScale={0.22,0.38} },
      })
      if st.gateIn then
        st.gateIn.collision.enabled = not st.gateIn.collision.enabled
        local enabled = st.gateIn.collision.enabled
        if enabled then st.gateIn.sprite:GoToFrame(1) else st.gateIn.sprite:GoToFrame(2) end
      end
      if st.gateOut then
        st.gateOut.collision.enabled = not st.gateOut.collision.enabled
        local enabled = st.gateOut.collision.enabled
        if enabled then st.gateOut.sprite:GoToFrame(1) else st.gateOut.sprite:GoToFrame(2) end
      end
      setHint(st, "Elige operador y números. Abre caminos con múltiplos.", 3)
      recomputePaths(st)
    end)
    return prompt
  end

  -- Cartel / Letrero que abre un diálogo de ayuda
  if Config.SavedConfigs.HELP_SIGNS then
    F["cdn_sign"] = function(o)
      -- Props opcionales desde Tiled:
      --   script   = clave en WrittenDialogues (string). Ej: "tut_cdn_sign_basic"
      --   label    = texto del prompt. Por defecto "Press [%s] to read"
      local scriptKey = (o.props and o.props.script) or "tut_cdn_sign_basic"
      local label     = (o.props and o.props.label)  or "Press [%s] to read"

      local prompt = ProxPrompt.new(label)
      prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
      prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
      prompt.collision.anchor   = {0,0}

      prompt.Triggered:Connect(function()
        -- Evita abrir si ya estás en diálogo, si tu sistema lo necesita
        if Dialogue and WrittenDialogues and WrittenDialogues[scriptKey] then
          Dialogue.start(WrittenDialogues[scriptKey], 42)
        end
      end)

      return prompt
    end
    F["cdn_signpost"] = function (o)
      local anim = Animation.new("assets/sprites/sign.png", 44, 44, 1, 1, 1)
      anim.anchor = {.5,.5}
      anim:Pause()
      local signBlock = Block.new(anim, o.sx, o.sy)
      signBlock.collision.anchor = {0,0}
      signBlock.collision.enabled = false
      return signBlock
    end
  end

  F["cdn_gate_in"] = function(o)
    local anim = Animation.new("assets/sprites/spikes-Sheet.png", 44, 22, 2, 1, .05)
    anim.loop = false
    anim:Pause()
    local g = Block.new(anim, o.sx, o.sy, o.sw, o.sh)
    st.gateIn = g
    return g
  end

  F["cdn_gate_out"] = function(o)
    local anim = Animation.new("assets/sprites/spikes-Sheet.png", 44, 22, 2, 1, .05)
    anim.loop = false
    anim.reversed = true
    anim:Pause()
    anim:GoToFrame(2)
    local g = Block.new(anim, o.sx, o.sy, o.sw, o.sh)
    g.collision.enabled = false
    st.gateOut = g
    return g
  end

  F["cdn_path"] = function(o)
    local k = (o.props and tonumber(o.props.k)) or 2
    local col = Collisions.new("box")
    col.position = UDim2.fromScale(o.sx, o.sy)
    col.size     = UDim2.fromScale(o.sw, o.sh)
    col:AddTag("cdn_path")
    -- NO tocamos anchor del collider; solo lo leemos (si existe) para dibujar bien
    local ax, ay = 0.5, 0.5
    if col.anchor then ax, ay = col.anchor[1] or 0.5, col.anchor[2] or 0.5 end

    table.insert(st.paths, {
      k   = k,
      col = col,
      sx  = o.sx, sy = o.sy, sw = o.sw, sh = o.sh,
      ax  = ax, ay = ay
    })
    return col
  end

  F["cdn_plate_op"] = function(o)
    local op = (o.props and o.props.op) or "mul"
    local prompt = ProxPrompt.new("Set op → "..op.." [%s]")
    prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
    prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
    prompt.collision.anchor   = {0,0}
    prompt.Triggered:Connect(function()
      if not st.started then return end
      st.op = op
      setHint(st, "Operador: "..op, 1.5)
      updateHUD(st)
    end)
    return prompt
  end

  F["cdn_plate_num"] = function(o)
    local val = (o.props and tonumber(o.props.val)) or 2
    local prompt = ProxPrompt.new("Apply "..val.." [%s]")
    prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
    prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
    prompt.collision.anchor   = {0,0}
    prompt.Triggered:Connect(function()
      if not st.started then return end
      st.V = applyOp(st.op, st.V, val)
      if st.V < 1 then st.V = 1 end
      setHint(st, ("V ← %d"):format(st.V), 1.2)
      recomputePaths(st)
    end)
    return prompt
  end

  F["cdn_reset"] = function(o)
    local prompt = ProxPrompt.new("Reset V [%s]")
    prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
    prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
    prompt.collision.anchor   = {0,0}
    prompt.Triggered:Connect(function()
      if not st.started then return end
      st.V, st.op = 2, "add"
      setHint(st, "Reinicio", 1)
      recomputePaths(st)
    end)
    return prompt
  end

  F["cdn_display"] = function(o)
    st.displayPos = UDim2.fromScale(o.sx, o.sy)
    return nil
  end

  F["cdn_spawn"] = function(o)
    table.insert(st.spawns, {UDim2.fromScale(o.sx, o.sy), (o.props and o.props.kind) or "antivirus"})
    return nil
  end

  -- Spawnear todo
  map:spawnObjects(F, scene)

  -- HUD al final (posición ya resuelta)
  buildHUD(st)
  recomputePaths(st) -- por si V ya abre algo
  return self
end

function CDN.update(self, dt)
  -- (Si quieres efectos/sonidos por caminos abiertos, hazlo aquí)
end

function CDN.draw(self)
  -- Visual de caminos: rectángulos rojo/verde según bloqueado/abierto
  local st = self.st
  if not st or not st.showVis then return end

  local w, h = love.graphics.getDimensions()
  local prevR,prevG,prevB,prevA = love.graphics.getColor()

  for _,p in ipairs(st.paths) do
    local open = (p.k ~= 0) and ((st.V % p.k) == 0)
    local col  = open and st.visOpenCol or st.visClosedCol

    local px = (p.sx - (p.ax or 0.5) * p.sw) * w
    local py = (p.sy - (p.ay or 0.5) * p.sh) * h
    local pw = (p.sw) * w
    local ph = (p.sh) * h

    love.graphics.setColor(col)
    love.graphics.rectangle("fill", px, py, pw, ph)

    -- borde sutil
    love.graphics.setColor(st.visBorder)
    love.graphics.setLineWidth(st.visBorderPx)
    love.graphics.rectangle("line", px, py, pw, ph)
  end

  love.graphics.setColor(prevR, prevG, prevB, prevA)
end

function CDN.detach(self)
  local st = self.st
  if not st then return end
  st.tearingDown = true
  if st.gateIn then st.gateIn:Destroy() end
  if st.gateOut then st.gateOut:Destroy() end
  for _,p in ipairs(st.paths) do if p.col then p.col:Destroy() end end
  if st.hudRoot and st.hudRoot.Destroy then st.hudRoot:Destroy() end
  self.st = nil
end

return CDN

-- src/features/cdn.lua
local CDN = {}
CDN.__index = CDN

local function newState()
  return {
    started = false,
    tearingDown = false,

    gateIn  = nil,
    gateOut = nil,

    -- runtime
    paths = {},         -- {k, col}
    spawns = {},        -- {pos, kind}
    shardPos = nil,
    upgPos   = nil,
    displayPos = nil,

    -- math
    V = 2,
    op = "add",         -- "mul"|"add"|"sub"

    -- ui
    hudRoot = nil,
    hudLbl  = nil,
    hintLbl = nil,
  }
end

local function applyOp(op, a, b)
  if op == "mul" then return a * b
  elseif op == "add" then return a + b
  elseif op == "sub" then return a - b
  else return a end
end

local function updateHUD(st)
  if not st.hudLbl then return end
  local divs = {}
  table.sort(divs)
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
    local open = (st.V % p.k) == 0
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
  st.hudLbl.size = UDim2.fromScale(0.7, 0.06)
  st.hudLbl.anchorPoint = {0,0}

  if st.displayPos then
    st.hudLbl.position = st.displayPos
  else
    st.hudLbl.position = UDim2.fromScale(0.02, 0.02)
  end
  st.hudLbl.textColor = {1,1,1,1}
  if Fonts and Fonts.VT323 then st.hudLbl.font = Fonts.VT323 end

  st.hintLbl = Textlabel.new("")
  st.hintLbl:setParent(st.hudRoot)
  st.hintLbl.position = UDim2.fromScale(0.02, 0.08)
  st.hintLbl.size = UDim2.fromScale(0.7, 0.05)
  st.hintLbl.anchorPoint = {0,0}
  st.hintLbl.textColor = {1,0.9,0.5,1}
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
    prompt.Triggered:Once(function()
      if st.started then return end
      st.started = true
      if st.gateIn  then st.gateIn.enabled  = false end
      if st.gateOut then st.gateOut.enabled = true  end
      setHint(st, "Elige operador y números. Abre caminos con múltiplos.", 3)
      recomputePaths(st)
    end)
    return prompt
  end

  F["cdn_gate_in"] = function(o)
    local g = Collisions.new("box")
    g.position = UDim2.fromScale(o.sx, o.sy)
    g.size     = UDim2.fromScale(o.sw, o.sh)
    st.gateIn = g
    return g
  end

  F["cdn_gate_out"] = function(o)
    local g = Collisions.new("box")
    g.position = UDim2.fromScale(o.sx, o.sy)
    g.size     = UDim2.fromScale(o.sw, o.sh)
    g.enabled  = false
    st.gateOut = g
    return g
  end

  F["cdn_path"] = function(o)
    local k = (o.props and tonumber(o.props.k)) or 2
    local col = Collisions.new("box")
    col.position = UDim2.fromScale(o.sx, o.sy)
    col.size     = UDim2.fromScale(o.sw, o.sh)
    col:AddTag("cdn_path")
    table.insert(st.paths, {k=k, col=col})
    return col
  end

  F["cdn_plate_op"] = function(o)
    local op = (o.props and o.props.op) or "mul"
    local prompt = ProxPrompt.new("Set op → "..op.. " [%s]")
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
    local prompt = ProxPrompt.new("Apply "..val.. " [%s]")
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
      st.V, st.op = 2, "mul"
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

  F["cdn_shard"] = function(o) st.shardPos = UDim2.fromScale(o.sx,o.sy) end
  F["cdn_upgrade"] = function(o) st.upgPos = UDim2.fromScale(o.sx,o.sy) end

  -- Spawnear todo
  map:spawnObjects(F, scene)

  -- HUD al final (posición ya resuelta)
  buildHUD(st)
  recomputePaths(st) -- por si V=1 ya abre algo
  return self
end

function CDN.update(self, dt)
  -- (si quieres efectos/sonidos por caminos abiertos, puedes hacerlo aquí)
end

function CDN.draw(self)
  -- visual opcional: contornear caminos abiertos/cerrados
  -- (dejado vacío para no contaminar tu draw stack)
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

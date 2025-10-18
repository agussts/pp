-- src/features/cdntiled.lua
-- Catwalks que aparecen si el tick cumple regla de múltiplos
-- Tiled (Object Layer, clases):
--   cdn_start        : rect   (inicia puzzle) props: mode=("timer"|"manual"), period=seg, start=entero
--   cdn_step         : rect   (botón/prompt para avanzar tick en modo manual)
--   cdn_catwalk      : rect   props: div=entero (aparece si tick % div == 0), invert=bool (opcional)
--   cdn_gate_in      : rect   (bloquea entrada; se desactiva al empezar)
--   cdn_gate_out     : rect   (bloquea salida; se activa al empezar)
--   cdn_shard        : point/rect (dónde aparece el shard al cruzar)
--   cdn_upgrade      : point/rect (pos upgrade opcional)
--
-- Flujo: al activar cdn_start, se abre gate_in, se cierra gate_out y empieza el clock
-- El jugador atraviesa catwalks que aparecen por múltiplos. Al tocar cdn_shard, recolecta.
-- (o puedes dejar el shard ya visible; depende de tu diseño)

local CDN = {}
CDN.__index = CDN

local function newState()
  return {
    started    = false,
    mode       = "timer",  -- "timer" | "manual"
    period     = 1.2,
    tick       = 0,
    tacc       = 0,
    tearing    = false,

    gateIn  = nil,
    gateOut = nil,

    startPrompt = nil,
    stepPrompts = {},

    catwalks = {},  -- {col, div, invert, color, active}
    shardPos = nil,
    shardObj = nil,
    upgPos   = nil,
  }
end

local function _ud(o)
  return UDim2.fromScale(o.sx, o.sy), UDim2.fromScale(o.sw, o.sh)
end

local function setCatwalkActive(seg, act)
  seg.active = not not act
  if seg.col then seg.col.enabled = seg.active end
end

local function refreshCatwalks(st)
  for _, seg in ipairs(st.catwalks) do
    local ok = (st.tick % seg.div == 0)
    if seg.invert then ok = not ok end
    setCatwalkActive(seg, ok)
  end
end

local function spawnShard(st)
  if st.shardObj or not st.shardPos then return end
  st.shardObj = Shard.new(st.shardPos, "assets/sprites/shard.png", "cdn_shard")
end

-- ==============================
-- API
-- ==============================
function CDN.attach(scene, map)
  local self = setmetatable({}, CDN)
  self.scene = scene
  self.map   = map
  self.st    = newState()
  scene._cdn = self

  local st = self.st

  local factory = {}

  factory["cdn_start"] = function(o, scn)
    local pos, size = _ud(o)
    if o.props then
      if o.props.mode == "manual" then st.mode = "manual" end
      if tonumber(o.props.period) then st.period = tonumber(o.props.period) end
      if tonumber(o.props.start)  then st.tick   = math.floor(o.props.start) end
    end
    local prompt = ProxPrompt.new("Press [%s] to start")
    prompt.collision.position = pos
    prompt.collision.size     = size
    prompt.collision.anchor   = {0,0}
    st.startPrompt = prompt

    prompt.Triggered:Once(function()
      if st.started then return end
      st.started = true
      -- abrir/cerrar gates
      if st.gateIn  then st.gateIn.enabled  = false end
      if st.gateOut then st.gateOut.enabled = true  end
      -- refrescar estado inicial de catwalks
      refreshCatwalks(st)
    end)
    return prompt
  end

  factory["cdn_step"] = function(o)
    -- Sólo útil si st.mode == "manual", pero lo dejamos creado siempre.
    local prompt = ProxPrompt.new("Press [%s] to step")
    prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
    prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
    prompt.collision.anchor = {0,0}
    table.insert(st.stepPrompts, prompt)

    prompt.Triggered:Connect(function()
      if not st.started then return end
      if st.mode ~= "manual" then return end
      st.tick = st.tick + 1
      refreshCatwalks(st)
    end)
    return prompt
  end

  factory["cdn_catwalk"] = function(o)
    local pos, size = _ud(o)
    local div    = (o.props and tonumber(o.props.div)) or 2
    local invert = (o.props and (o.props.invert == true or o.props.invert == "true")) or false

    local c = Collisions.new("box")
    c.position = pos
    c.size     = size
    c:AddTag("catwalk")

    local seg = { col = c, div = math.max(1, math.floor(div)), invert = invert, active = false }
    table.insert(st.catwalks, seg)

    -- inician apagadas hasta que empiece el puzzle/refresco
    setCatwalkActive(seg, false)
    return c
  end

  factory["cdn_gate_in"] = function(o)
    local c = Collisions.new("box")
    c.position = UDim2.fromScale(o.sx, o.sy)
    c.size     = UDim2.fromScale(o.sw, o.sh)
    st.gateIn  = c
    return c
  end

  factory["cdn_gate_out"] = function(o)
    local c = Collisions.new("box")
    c.position = UDim2.fromScale(o.sx, o.sy)
    c.size     = UDim2.fromScale(o.sw, o.sh)
    c.enabled  = false -- cerrado al inicio
    st.gateOut = c
    return c
  end

  factory["cdn_shard"] = function(o)
    st.shardPos = UDim2.fromScale(o.sx, o.sy)
    return nil
  end

  -- Spawnea todo desde el mapa:
  map:spawnObjects(factory, scene)

  -- Estado inicial de catwalks según tick
  refreshCatwalks(st)

  return self
end

function CDN.update(self, dt)
  local st = self.st
  if not st then return end

  -- prompts
  if st.startPrompt then st.startPrompt:update() end
  for _,p in ipairs(st.stepPrompts) do p:update() end

  if not st.started then return end

  if st.mode == "timer" then
    st.tacc = st.tacc + dt
    if st.tacc >= st.period then
      st.tacc = st.tacc - st.period
      st.tick = st.tick + 1
      refreshCatwalks(st)
    end
  end

  -- shard opcional: spawnéalo de una vez al empezar, o al llegar a alguna zona
  -- aquí lo dejamos "al empezar el puzzle"
  if not st.shardObj and st.shardPos then
    spawnShard(st)
  end

  -- actualizar shard si existe (para bobbing/alpha interna del objeto)
  if st.shardObj and st.shardObj.update then
    st.shardObj:update(dt)
  end
end

function CDN.draw(self)
  local st = self.st
  if not st then return end

  -- Dibujar catwalks de forma simple (rectángulo translúcido)
  for _, seg in ipairs(st.catwalks) do
    local x, y, w, h = seg.col:_getRenderRect()
    if seg.active then
      love.graphics.setColor(0.2, 1.0, 0.8, 0.6)
    else
      love.graphics.setColor(0.3, 0.3, 0.3, 0.15)
    end
    love.graphics.rectangle("fill", x, y, w, h)

    -- borde
    love.graphics.setColor(0.8, 1.0, 1.0, seg.active and 0.9 or 0.25)
    love.graphics.rectangle("line", x, y, w, h)
  end
  love.graphics.setColor(1,1,1,1)

  if st.shardObj and st.shardObj.draw then
    st.shardObj:draw()
  end
end

function CDN.detach(self)
  local st = self.st
  if not st then return end
  st.tearing = true

  if st.startPrompt then st.startPrompt:Destroy() end
  for _,p in ipairs(st.stepPrompts) do if p.Destroy then p:Destroy() end end

  if st.gateIn  then st.gateIn:Destroy()  end
  if st.gateOut then st.gateOut:Destroy() end

  for _,seg in ipairs(st.catwalks) do
    if seg.col then seg.col:Destroy() end
  end

  if st.shardObj and st.shardObj.Destroy then st.shardObj:Destroy() end

  self.st = nil
end

return CDN

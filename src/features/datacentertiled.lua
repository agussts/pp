-- src/features/datacenter_from_tiled.lua
-- Data Center (desde Tiled) – usa servernode.lua si existe, y corrige lectura de objetos.
-- Tipos de objeto Tiled esperados:
--   • player_spawn         (point/rect)
--   • dc_pad               (rect)    props: hp, points, respawn
--   • dc_spawn             (point/rect)
--   • dc_barrier           (rect)    props: id="hall"|"exit", enabled=true/false
--   • dc_start             (rect)    props: message="Press [E] to start"
--   • dc_shard             (point/rect)
--
-- Cómo se usa en la escena:
--   local DC = require("src.features.datacenter_from_tiled")
--   self.map = TiledLite.load("assets/maps/datacenter_room.lua", { collisionLayers={"Colliders"} })
--   Player = PlayerModule.new("assets/sprites/player-Sheet.png")
--   DC.attach(self, self.map)
--   ...
--   scene.update = function(self, dt) DC.update(self, dt) end
--   scene.draw   = function(self)     DC.draw(self)   end
--   scene.unload = function(self)     DC.detach(self) end

local M = {}

-- ===================== Parámetros (tuneables) ===============================
local TARGET_SCORE   = 40
local BONUS_SCORE    = 80
local HEAT_MAX       = 100
local HEAT_DECAY     = 2
local HEAT_ON_SERVER = 18
local HEAT_MULT      = 3.0
local RESPAWN_DEF    = 6.0
local ENEMY_BASE_SPD = 150
local ENEMY_SPD_PERW = 20
local ENEMY_LAYER    = -4.5
local SERVER_LAYER   = -5
local SHARD_LAYER    = -4.8
local PAD_W          = 0.05
local PAD_H          = 0.08

-- ====================== Utils ==============================================
local function clamp(v,a,b) return math.max(a, math.min(b, v)) end

local function propGet(tbl, key)
  local p = tbl and tbl.properties
  if not p then return nil end
  if p[1] and type(p[1])=="table" and p[1].name then
    for _,x in ipairs(p) do if x.name==key then return x.value end end
  else
    return p[key]
  end
  return nil
end

local function toScale(xpx, ypx)
  local W, H = Config.IdealResolution.width, Config.IdealResolution.height
  return xpx / W, ypx / H
end

-- ====================== HUD =================================================
local function buildHUD(self)
  local box = Frame.new()
  box.size = UDim2.fromScale(0.42, 0.15)
  box.position = UDim2.fromScale(0.02, 0.02)
  box.anchorPoint = {0,0}
  box.bgColor = {0,0,0,0.55}
  box.zIndex = 80

  local title = Textlabel.new("DATA HALL")
  title:setParent(box); title.position = UDim2.fromScale(0.04, 0.14)
  title.size = UDim2.fromScale(0.92, 0.28); title.anchorPoint = {0,0}
  title.textColor = {1,1,1,1}; title.zIndex = 81
  if Fonts and Fonts.VT323 then title.font = Fonts.VT323 end

  local score = Textlabel.new("Score: 0/0  (x1.00)")
  score:setParent(box); score.position = UDim2.fromScale(0.04, 0.50)
  score.size = UDim2.fromScale(0.92, 0.24); score.anchorPoint = {0,0}
  score.textColor = {1,1,1,1}; score.zIndex = 81
  if Fonts and Fonts.VT323 then score.font = Fonts.VT323 end

  local heatL = Textlabel.new("Heat")
  heatL:setParent(box); heatL.position = UDim2.fromScale(0.04, 0.78)
  heatL.size = UDim2.fromScale(0.18, 0.2); heatL.anchorPoint = {0,0}
  heatL.textColor = {1,1,1,1}; heatL.zIndex = 81
  if Fonts and Fonts.VT323 then heatL.font = Fonts.VT323 end

  local hb = Frame.new(); hb:setParent(box)
  hb.position = UDim2.fromScale(0.21, 0.80); hb.size = UDim2.fromScale(0.74, 0.14)
  hb.anchorPoint = {0,0}; hb.bgColor = {1,1,1,0.12}; hb.zIndex = 80

  local bar = Frame.new(); bar:setParent(hb)
  bar.position = UDim2.fromScale(0,0); bar.size = UDim2.fromScale(0,1)
  bar.anchorPoint = {0,0}; bar.bgColor = {1,0.3,0.25,0.9}; bar.zIndex = 81

  self._dcHud = {box=box, title=title, score=score, bar=bar}
end

local function hudRefresh(self)
  if not self._dcHud then return end
  local r = clamp(self._dc.heat / HEAT_MAX, 0, 1)
  local mult = 1 + HEAT_MULT * r
  self._dcHud.bar.size = UDim2.fromScale(r, 1)
  self._dcHud.score.text = string.format("Score: %d/%d  (x%.2f)", self._dc.score, TARGET_SCORE, mult)
end

local function hudDestroy(self)
  if not self._dcHud then return end
  if self._dcHud.box and self._dcHud.box.Destroy then self._dcHud.box:Destroy() end
  self._dcHud = nil
end

-- ====================== ServerNode adapter =================================
-- Usa tu servernode.lua si existe; si no, cae a un fallback mínimo.

local ServerNode = (function()
  local candidates = {
    "src.features.servernode",
    "src.objs.servernode",
    "src.entities.servernode",
    "src.servernode",
    "servernode",
  }
  for _, path in ipairs(candidates) do
    local ok, mod = pcall(require, path)
    if ok and type(mod)=="table" then return mod end
  end
  return nil
end)()

-- Fallback simple por si no existe servernode.lua
local function fallbackServerNew(sx, sy, opt, onDestroyed)
  local anim = Animation.new("assets/sprites/server-Sheet.png", 32, 32, 2, 1, 0.45)
  anim.anchor = {.5,.5}
  local c = Collisions.new("box")
  c.position = UDim2.fromScale(sx, sy)
  c.size = UDim2.fromScale(opt.w or PAD_W, opt.h or PAD_H)
  c.anchor = {.5,.5}
  c:AddTag("box")
  local S = {
    sprite = anim, collision = c, worldLayer = SERVER_LAYER,
    health = tonumber(opt.hp or 60),
    points = tonumber(opt.points or 10),
    respawn = tonumber(opt.respawn or RESPAWN_DEF),
  }
  c.link = S
  function S:Damage(d)
    self.health = self.health - (d or 0)
    if self.health <= 0 and not self._dead then
      self._dead = true
      if onDestroyed then onDestroyed(self) end
      self:Destroy()
    end
  end
  function S:update(dt) self.sprite:update(dt) end
  function S:draw() local x,y = self.collision.position:toPixels(); self.sprite:draw(x,y) end
  function S:Destroy() self._destroying=true; if self.collision and self.collision.Destroy then self.collision:Destroy() end end
  return S
end

local function spawnServerUsingAdapter(pad, onDestroyed)
  if ServerNode then
    -- Intentamos varias firmas comunes sin romper:
    -- 1) ServerNode.new(sx, sy, {w=,h=,hp=,points=,respawn=,onDestroyed=fn})
    local ok, obj = pcall(function()
      return ServerNode.new(pad.sx, pad.sy, {
        w=pad.w, h=pad.h, hp=pad.hp, points=pad.points, respawn=pad.respawn,
        onDestroyed = onDestroyed
      })
    end)
    if ok and obj then return obj end

    -- 2) ServerNode.new(UDim2.fromScale, width, height, propsTable)
    ok, obj = pcall(function()
      return ServerNode.new(UDim2.fromScale(pad.sx, pad.sy), pad.w, pad.h, {
        hp=pad.hp, points=pad.points, respawn=pad.respawn, onDestroyed=onDestroyed
      })
    end)
    if ok and obj then return obj end

    -- 3) ServerNode.spawn(table) style
    if ServerNode.spawn then
      ok, obj = pcall(function()
        return ServerNode.spawn({
          x=pad.sx, y=pad.sy, w=pad.w, h=pad.h,
          hp=pad.hp, points=pad.points, respawn=pad.respawn,
          onDestroyed=onDestroyed
        })
      end)
      if ok and obj then return obj end
    end

    -- 4) Si el servernode emite señal OnDestroyed en vez de callback:
    ok, obj = pcall(function()
      local s = ServerNode.new(pad.sx, pad.sy, pad.w, pad.h, pad.hp or 60, pad.points or 10, pad.respawn or RESPAWN_DEF)
      if s and s.OnDestroyed and s.OnDestroyed.Connect then
        s.OnDestroyed:Connect(function() if onDestroyed then onDestroyed(s) end end)
      end
      return s
    end)
    if ok and obj then return obj end
  end
  -- Fallback:
  return fallbackServerNew(pad.sx, pad.sy, pad, onDestroyed)
end

-- ====================== Enemigos / Barreras =================================
local function spawnEnemyAt(sx, sy, wave)
  local e = EnemyModule.new(nil, 0.0625, 0.11)
  e.collision.position = UDim2.fromScale(sx, sy)
  e.worldLayer = ENEMY_LAYER
  e.speed = math.min(300, ENEMY_BASE_SPD + ENEMY_SPD_PERW * (wave or 1))
  if Player and Player.collision then e:follow(Player.collision.position) end
  return e
end

local function newBarrier(x, y, w, h)
  local c = Collisions.new("box")
  c.position = UDim2.fromScale(x, y)
  c.size = UDim2.fromScale(w, h)
  c.anchor = {0,0}
  c:AddTag("world")
  return c
end

-- ====================== Lectura de OBJETOS (¡corregido!) ====================
local function readObjectsFromTiledLite(mapTl)
  -- OJO: las capas del mapa original están en mapTl.data.layers
  local objs = {}
  local data = mapTl.data
  for _, L in ipairs(data.layers or {}) do
    if L.type == "objectgroup" then
      for _, o in ipairs(L.objects or {}) do
        -- normaliza props
        o.props = {}
        if o.properties then
          if o.properties[1] and o.properties[1].name then
            for _, p in ipairs(o.properties) do o.props[p.name] = p.value end
          else
            for k,v in pairs(o.properties) do o.props[k] = v end
          end
        end
        table.insert(objs, o)
      end
    end
  end
  return objs
end

-- ====================== Lógica principal ====================================
function M.attach(scene, map)
  scene._dc = {
    started = false,
    score = 0,
    heat  = 0,
    wave  = 1,
    pads  = {},
    spawns = {},
    enemies = {},
    barriers = {},
    shardPad = nil,
    shard = nil,
    upgradeGiven = false,
  }

  local objs = readObjectsFromTiledLite(map)
  -- Colocar objetos
  for _, o in ipairs(objs) do
    local t = o.type or o.class or ""
    local sx, sy = toScale(o.x, o.y)
    local sw, sh = toScale(o.width or 0, o.height or 0)

    if t == "player_spawn" then
      scene.playerspawn = UDim2.fromScale(sx, sy)
      -- si ya existe el Player, colócalo ahora mismo
      if Player and Player.collision then
        Player.collision.position = scene.playerspawn
      end

    elseif t == "dc_pad" then
      table.insert(scene._dc.pads, {
        sx=sx, sy=sy, w=(sw>0 and sw or PAD_W), h=(sh>0 and sh or PAD_H),
        hp=tonumber(o.props.hp or 60), points=tonumber(o.props.points or 10),
        respawn=tonumber(o.props.respawn or RESPAWN_DEF),
        current=nil, t=0
      })

    elseif t == "dc_spawn" then
      table.insert(scene._dc.spawns, {sx=sx, sy=sy})

    elseif t == "dc_barrier" then
      local id = o.props.id or "hall"
      local enabled = (o.props.enabled ~= false)
      local b = enabled and newBarrier(sx, sy, sw, sh) or nil
      scene._dc.barriers[id] = {rect={x=sx,y=sy,w=sw,h=sh}, collider=b}

    elseif t == "dc_start" then
      local msg = o.props.message or "Press [%s] to start"
      scene._dc.startPrompt = ProxPrompt.new(msg)
      -- centrado en el rect
      local cx, cy = sx + sw*0.5, sy + sh*0.5
      scene._dc.startPrompt.collision.position = UDim2.fromScale(cx, cy)
      scene._dc.startPrompt.collision.size     = UDim2.fromScale(sw, sh)
      scene._dc.startPrompt.collision.anchor   = {0.5,0.5}
      scene._dc._startConn = scene._dc.startPrompt.Triggered:Once(function()
        local bh = scene._dc.barriers["hall"]
        if bh and bh.collider and bh.collider.Destroy then bh.collider:Destroy() end
        scene._dc.barriers["hall"].collider = nil

        local be = scene._dc.barriers["exit"]
        if be and not be.collider then
          be.collider = newBarrier(be.rect.x, be.rect.y, be.rect.w, be.rect.h)
        end
        --love.audio.newSource("assets/sfx/powerup.wav","static"):play()
        scene._dc.started = true
      end)

    elseif t == "dc_shard" then
      scene._dc.shardPad = {sx=sx, sy=sy}
    end
  end

  -- Spawnear servidores iniciales con callback
  for _, pad in ipairs(scene._dc.pads) do
    pad.current = spawnServerUsingAdapter(pad, function(S)
      local r = clamp(scene._dc.heat / HEAT_MAX, 0, 1)
      local mult = 1 + HEAT_MULT * r
      scene._dc.score = scene._dc.score + math.floor(S.points * mult + 0.5)
      scene._dc.heat  = clamp(scene._dc.heat + HEAT_ON_SERVER, 0, HEAT_MAX)
      local base  = math.max(1, math.floor(S.points / 12))
      local extra = math.floor((scene._dc.wave-1)/2)
      local count = base + extra + love.math.random(0,1)
      if #scene._dc.spawns > 0 then
        for i=1, count do
          local sp = scene._dc.spawns[love.math.random(1, #scene._dc.spawns)]
          table.insert(scene._dc.enemies, spawnEnemyAt(sp.sx, sp.sy, scene._dc.wave))
        end
      end
      pad.current = nil
      pad.t = pad.respawn
    end)
    -- si tu servernode maneja internamente collision/worldLayer, ignora:
    if pad.current then pad.current.worldLayer = pad.current.worldLayer or SERVER_LAYER end
  end

  buildHUD(scene)

  -- Abre salida cuando recolectes un shard
  scene._dc._shardConn = Connect("shard_collected", function()
    local be = scene._dc.barriers["exit"]
    if be and be.collider and be.collider.Destroy then
      be.collider:Destroy()
      be.collider = nil
    end
  end)
end

function M.update(scene, dt)
  if not scene._dc then return end

  -- HEAT/oleada
  scene._dc.heat = clamp(scene._dc.heat - HEAT_DECAY * dt, 0, HEAT_MAX)
  scene._dc.wave = math.max(1, math.floor(scene._dc.score / 25) + 1)

  if scene._dc.startPrompt then scene._dc.startPrompt:update() end

  -- servidores y respawn
  for _, pad in ipairs(scene._dc.pads) do
    if pad.current and pad.current.update then
      pad.current:update(dt)
    elseif pad.t and pad.t > 0 then
      pad.t = pad.t - dt
      if pad.t <= 0 then
        pad.current = spawnServerUsingAdapter(pad, function(S)
          local r = clamp(scene._dc.heat / HEAT_MAX, 0, 1)
          local mult = 1 + HEAT_MULT * r
          scene._dc.score = scene._dc.score + math.floor(S.points * mult + 0.5)
          scene._dc.heat  = clamp(scene._dc.heat + HEAT_ON_SERVER, 0, HEAT_MAX)
          local base  = math.max(1, math.floor(S.points / 12))
          local extra = math.floor((scene._dc.wave-1)/2)
          local count = base + extra + love.math.random(0,1)
          if #scene._dc.spawns > 0 then
            for i=1, count do
              local sp = scene._dc.spawns[love.math.random(1, #scene._dc.spawns)]
              table.insert(scene._dc.enemies, spawnEnemyAt(sp.sx, sp.sy, scene._dc.wave))
            end
          end
          pad.current = nil
          pad.t = pad.respawn
        end)
      end
    end
  end

  -- enemigos
  for i = #scene._dc.enemies, 1, -1 do
    local e = scene._dc.enemies[i]
    if e and not e._destroying then
      if Player and Player.collision and e.followTarget ~= Player.collision.position then
        e:follow(Player.collision.position)
      end
      if e.update then e:update(dt) end
    else
      table.remove(scene._dc.enemies, i)
    end
  end

  -- shard si alcanzaste meta
  if (not scene._dc.shard) and scene._dc.shardPad
     and scene._dc.score >= TARGET_SCORE
     and World.shards.active and not World.shards.done
  then
    scene._dc.shard = Shard.new(
      UDim2.fromScale(scene._dc.shardPad.sx, scene._dc.shardPad.sy),
      "assets/sprites/shard.png",
      "dc_room"
    )
    scene._dc.shard.worldLayer = SHARD_LAYER
  end

  -- mejora si superas BONUS_SCORE
  if (not scene._dc.upgradeGiven) and (scene._dc.score >= BONUS_SCORE) then
    if Gun then
      Gun.damage   = (Gun.damage or 10) + 6
      Gun.fireRate = math.max(0.2, (Gun.fireRate or 0.5) * 0.8)
      love.audio.newSource("assets/sfx/powerup.wav","static"):play()
    end
    scene._dc.upgradeGiven = true
  end

  hudRefresh(scene)
end

function M.draw(scene)
  if not scene._dc then return end
  for _, pad in pairs(scene._dc.pads) do
    if pad.current and pad.current.draw then pad.current:draw() end
  end
  for _, e in pairs(scene._dc.enemies) do
    if e.draw then print("drawing enemy") e:draw() end
  end
  if scene._dc.shard and scene._dc.shard.draw then scene._dc.shard:draw() end
end

function M.detach(scene)
  if not scene._dc then return end
  if scene._dc.startPrompt then scene._dc.startPrompt:Destroy() end
  scene._dc.startPrompt = nil
  -- barreras
  for _, b in pairs(scene._dc.barriers) do
    if b.collider and b.collider.Destroy then b.collider:Destroy() end
    b.collider = nil
  end
  -- servidores
  for _, pad in ipairs(scene._dc.pads) do
    if pad.current and pad.current.Destroy then pcall(function() pad.current:Destroy() end) end
    pad.current = nil
  end
  -- enemigos
  for i=#scene._dc.enemies,1,-1 do
    local e = scene._dc.enemies[i]
    if e and e.Destroy then pcall(function() e:Destroy() end) end
    scene._dc.enemies[i] = nil
  end
  -- shard
  if scene._dc.shard and scene._dc.shard.Destroy then pcall(function() scene._dc.shard:Destroy() end) end
  scene._dc.shard = nil
  -- HUD
  hudDestroy(scene)
  scene._dc = nil
end

return M

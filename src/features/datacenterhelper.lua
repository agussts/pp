-- src/features/datacenter.lua
--- Minijuego “Data Center Alley”: servidores, olas, heat y HUD.
-- Integra con EnemyModule/Shard/Guis y (opcionalmente) con TiledLite.
-- Coloca marcadores en Tiled (Lua) para automatizar:
--   • type="dc_zone"        (rect, define área activa)
--   • type="dc_spawn"       (puntos de spawn de enemigos)
--   • type="dc_server"      (servidores; props: points=10, hp=60, layer=-5)
--   • type="dc_shard_pad"   (punto donde spawnea el shard al cumplir meta)
-- Si no hay marcadores, usa un layout por defecto.
--
-- API:
--   local DataCenter = require("src.features.datacenter")
--   DataCenter.attach(scene, scene.map)   -- en scene.load
--   DataCenter.update(scene, dt)          -- en scene.update
--   DataCenter.draw(scene)                -- en scene.draw (dentro Camera.attach)
--   DataCenter.detach(scene)              -- en scene.unload
--
-- @module DataCenter

local DataCenter = {}

-- === helpers internos =======================================================

local function toScale(xpx, ypx)
  local W, H = Config.IdealResolution.width, Config.IdealResolution.height
  return xpx / W, ypx / H
end

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

local function playerScaleXY()
  if not (Player and Player.collision and Player.collision.position) then
    return 0, 0
  end
  return Player.collision.position.x.scale, Player.collision.position.y.scale
end

local function inRect(px, py, rx, ry, rw, rh)
  return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- === HUD sencillo ===========================================================

local function buildHUD(dc)
  local root = Frame.new()
  root.size      = UDim2.fromScale(0.35, 0.14)
  root.position  = UDim2.fromScale(0.02, 0.02)
  root.anchorPoint = {0,0}
  root.bgColor   = {0,0,0,0.55}
  root.zIndex    = 40

  local title = Textlabel.new("DATA CENTER")
  title:setParent(root)
  title.position = UDim2.fromScale(0.04, 0.15)
  title.size     = UDim2.fromScale(0.92, 0.28)
  title.anchorPoint = {0,0}
  title.textColor = {1,1,1,1}
  if Fonts and Fonts.VT323 then title.font = Fonts.VT323 end
  title.zIndex = 41

  local points = Textlabel.new("Points: 0/0")
  points:setParent(root)
  points.position = UDim2.fromScale(0.04, 0.48)
  points.size     = UDim2.fromScale(0.92, 0.22)
  points.anchorPoint = {0,0}
  points.textColor = {1,1,1,1}
  if Fonts and Fonts.VT323 then points.font = Fonts.VT323 end
  points.zIndex = 41

  local wave = Textlabel.new("Wave: 1")
  wave:setParent(root)
  wave.position = UDim2.fromScale(0.70, 0.48)
  wave.size     = UDim2.fromScale(0.26, 0.22)
  wave.anchorPoint = {0,0}
  wave.textColor = {1,1,1,1}
  if Fonts and Fonts.VT323 then wave.font = Fonts.VT323 end
  wave.zIndex = 41

  local heatLabel = Textlabel.new("Heat")
  heatLabel:setParent(root)
  heatLabel.position = UDim2.fromScale(0.04, 0.72)
  heatLabel.size     = UDim2.fromScale(0.18, 0.2)
  heatLabel.anchorPoint = {0,0}
  heatLabel.textColor = {1,1,1,1}
  if Fonts and Fonts.VT323 then heatLabel.font = Fonts.VT323 end
  heatLabel.zIndex = 41

  local barBg = Frame.new()
  barBg:setParent(root)
  barBg.position = UDim2.fromScale(0.21, 0.75)
  barBg.size     = UDim2.fromScale(0.74, 0.14)
  barBg.anchorPoint = {0,0}
  barBg.bgColor  = {1,1,1,0.12}
  barBg.zIndex   = 40

  local bar = Frame.new()
  bar:setParent(barBg)
  bar.position = UDim2.fromScale(0, 0)
  bar.size     = UDim2.fromScale(0, 1)
  bar.anchorPoint = {0,0}
  bar.bgColor  = {1,0.3,0.25,0.9}
  bar.zIndex   = 41

  dc.hud = {
    root = root, points = points, wave = wave, bar = bar,
    destroy = function(self)
      if self.root and self.root.Destroy then self.root:Destroy() end
      self.root, self.points, self.wave, self.bar = nil,nil,nil,nil
    end
  }
end

local function hudRefresh(dc)
  if not dc.hud then return end
  dc.hud.points.text = string.format("Points: %d/%d", dc.score, dc.targetScore or 30)
  dc.hud.wave.text   = string.format("Wave: %d", dc.wave)
  local r = clamp((dc.heat or 0) / (dc.heatMax or 100), 0, 1)
  dc.hud.bar.size    = UDim2.fromScale(r, 1)
end

-- === Factories =============================================================

local function newServer(dc, sx, sy, opt)
  opt = opt or {}
  local anim = Animation.new(opt.sprite or "assets/sprites/server.png", 32, 32, 2, 1, 0.45)
  anim:Pause() -- descomenta si tu sprite no debe animarse
  anim.anchor = {.5, .5}

  local c = Collisions.new("box")
  c.position = UDim2.fromScale(sx, sy)
  c.size     = UDim2.fromScale(opt.w or 0.05, opt.h or 0.08)
  c.anchor   = {.5, .5}
  c:AddTag("box")

  local self = {
    sprite = anim,
    collision = c,
    health = tonumber(opt.hp or 60),
    points = tonumber(opt.points or 10),
    worldLayer = tonumber(opt.layer or -5),
  }
  c.link = self

  function self:Damage(dmg)
    self.health = self.health - (dmg or 0)
    if self.health <= 0 and not self._dead then
      self._dead = true
      -- sumar score/heat y avisar al controlador
      dc.score = dc.score + self.points
      dc.heat  = math.min(dc.heatMax, (dc.heat or 0) + 15)
      dc.destroyedCount = (dc.destroyedCount or 0) + 1
      -- sonido opcional
      love.audio.newSource("assets/sfx/die.wav","static"):play()
      self:Destroy()
    else
      -- pequeño feedback de golpe (shader flash si tienes)
      love.audio.newSource("assets/sfx/blip.wav","static"):play()
    end
  end

  function self:update(dt)
    self.sprite:update(dt)
  end

  function self:draw()
    local x, y = self.collision.position:toPixels()
    self.sprite:draw(x, y)
  end

  function self:Destroy()
    self._destroying = true
    if self.collision and self.collision.Destroy then self.collision:Destroy() end
    self.collision = nil
    self.sprite = nil
  end

  return self
end

local function newEnemyAt(sx, sy, wave)
  local w, h = 0.0625, 0.11
  local e = EnemyModule.new(nil, w, h)
  e.collision.position = UDim2.fromScale(sx, sy)
  e.worldLayer = -4.5
  -- escalar dificultad por wave
  e.speed = math.min(300, 150 + 20 * (wave or 1))
  if Player and Player.collision then
    e:follow(Player.collision.position)
  end
  return e
end

-- === Tiled scanning opcional ===============================================

local function pullMarkersFromMap(map)
  if not map or not map.layers then return nil end
  local out = {
    zone   = nil,
    spawns = {},
    servers= {},
    shardPad = nil
  }

  for _, L in ipairs(map.layers) do
    if L.kind == "objects" and L.data and L.data.objects then
      for _, o in ipairs(L.data.objects) do
        local t = o.type or o.class or ""
        local sx, sy = toScale(o.x, o.y)
        local sw, sh = toScale(o.width or 0, o.height or 0)
        local props = {}
        if o.properties then
          if o.properties[1] and o.properties[1].name then
            for _, p in ipairs(o.properties) do props[p.name] = p.value end
          else
            for k,v in pairs(o.properties) do props[k] = v end
          end
        end

        if t == "dc_zone" then
          out.zone = {sx=sx, sy=sy, sw=sw, sh=sh, props=props}
        elseif t == "dc_spawn" then
          table.insert(out.spawns, {sx=sx, sy=sy, props=props})
        elseif t == "dc_server" then
          table.insert(out.servers, {sx=sx, sy=sy, props=props})
        elseif t == "dc_shard_pad" then
          out.shardPad = {sx=sx, sy=sy, props=props}
        end
      end
    end
  end

  return out
end

-- === Ciclo de vida ==========================================================

--- Adjunta el minijuego a la escena. Si hay marcadores en el mapa, los usa.
-- @tparam table scene La escena (tabla devuelta por tu factory).
-- @tparam[opt] table map  Instancia TiledLite (si la tienes).
function DataCenter.attach(scene, map)
  -- estado principal
  local dc = {
    active = false,
    inZone = false,
    score  = 0,
    targetScore = 30,         -- meta para desbloquear shard
    bonusScore  = 60,         -- meta extra para upgrade arma
    wave   = 1,
    heat   = 0, heatMax = 100,
    heatDecay = 12,           -- por seg
    enemies = {},
    servers = {},
    spawns  = {},
    destroyedCount = 0,
    shardSpawned = false,
    upgradeGiven = false,
    _spawnTimer = 0,
  }

  scene.dc = dc

  -- Buscar marcadores en el mapa (si existen)
  local markers = pullMarkersFromMap(map)

  if markers and markers.zone then
    dc.zone = markers.zone
    if markers.shardPad then dc.shardPad = markers.shardPad end
    for _, sp in ipairs(markers.spawns) do
      table.insert(dc.spawns, {sx=sp.sx, sy=sp.sy})
    end
    for _, sv in ipairs(markers.servers) do
      local s = newServer(dc, sv.sx, sv.sy, {
        points = tonumber(sv.props.points) or 10,
        hp     = tonumber(sv.props.hp)     or 60,
        layer  = tonumber(sv.props.layer)  or -5
      })
      table.insert(dc.servers, s)
    end
    -- parámetros desde props del zone
    dc.targetScore = tonumber(dc.zone.props and dc.zone.props.target) or dc.targetScore
    dc.bonusScore  = tonumber(dc.zone.props and dc.zone.props.upgrade) or dc.bonusScore
  else
    -- fallback sencillo (por si no hay marcadores aún)
    dc.zone = { sx=0.95, sy=0.25, sw=0.5, sh=0.55, props={} }
    dc.shardPad = { sx=1.18, sy=0.42 }
    dc.spawns = {
      {sx=0.98, sy=0.30}, {sx=1.20, sy=0.25}, {sx=1.42, sy=0.60},
    }
    local base = {
      {1.06, 0.32}, {1.10, 0.46}, {1.26, 0.33}, {1.34, 0.52}
    }
    for _, p in ipairs(base) do
      table.insert(dc.servers, newServer(dc, p[1], p[2], {points=12, hp=70}))
    end
  end

  -- HUD
  buildHUD(dc)
  hudRefresh(dc)
end

--- Update del minijuego. Llamar desde scene.update(dt).
function DataCenter.update(scene, dt)
  local dc = scene.dc
  if not dc then return end

  -- Activar solo cuando el player entra en el rectángulo del zone
  local px, py = playerScaleXY()
  if dc.zone then
    dc.inZone = inRect(px, py, dc.zone.sx, dc.zone.sy, dc.zone.sw, dc.zone.sh)
  else
    dc.inZone = true
  end
  dc.active = dc.inZone

  -- heat se disipa con el tiempo
  dc.heat = clamp(dc.heat - dc.heatDecay * dt, 0, dc.heatMax)

  -- wave escala con score (sencillo)
  dc.wave = math.max(1, math.floor((dc.score / 20)) + 1)

  -- actualizar servidores (animación y lógica)
  for i = #dc.servers, 1, -1 do
    local s = dc.servers[i]
    if s and not s._destroying then
      if s.update then s:update(dt) end
    else
      table.remove(dc.servers, i)
    end
  end

  -- actualizar enemigos y reasegurar follow
  for i = #dc.enemies, 1, -1 do
    local e = dc.enemies[i]
    if e and not e._destroying then
      if Player and Player.collision and e.followTarget ~= Player.collision.position then
        e:follow(Player.collision.position)
      end
      if e.update then e:update(dt) end
    else
      table.remove(dc.enemies, i)
    end
  end

  -- spawn de enemigos según heat (solo si activo y hay spawns)
  if dc.active and #dc.spawns > 0 then
    dc._spawnTimer = dc._spawnTimer - dt
    -- intervalo base ~ 1.2s → mínimo 0.35s con heat alto
    local r = clamp(dc.heat / dc.heatMax, 0, 1)
    local interval = 1.2 - 0.85 * r
    if dc._spawnTimer <= 0 then
      local sp = dc.spawns[love.math.random(1, #dc.spawns)]
      table.insert(dc.enemies, newEnemyAt(sp.sx, sp.sy, dc.wave))
      dc._spawnTimer = interval
    end
  end

  -- al destruir suficientes servidores → shard
  if (not dc.shardSpawned) and (dc.score >= dc.targetScore) and World.shards.active and not World.shards.done then
    local sx = (dc.shardPad and dc.shardPad.sx) or px
    local sy = (dc.shardPad and dc.shardPad.sy) or py
    if not World.shards.collectedIds["dc_shard"] then
      dc.shard = Shard.new(UDim2.fromScale(sx, sy), "assets/sprites/shard.png", "dc_shard")
      dc.shard.worldLayer = -4.8
    end
    dc.shardSpawned = true
  end

  -- recompensa extra (upgrade arma) si superas la meta bonus
  if (not dc.upgradeGiven) and (dc.score >= dc.bonusScore) then
    if scene.gun then
      scene.gun.damage = (scene.gun.damage or 10) + 5
      scene.gun.fireRate = math.max(0.2, (scene.gun.fireRate or 0.5) * 0.75)
      love.audio.newSource("assets/sfx/powerup.wav","static"):play()
    end
    dc.upgradeGiven = true
  end

  -- actualizar shard para bobbing si existe
  if dc.shard and dc.shard.update then
    dc.shard:update(dt)
  end

  hudRefresh(dc)
end

--- Dibuja servidores, enemigos y shard. Llamar dentro de Camera.attach().
function DataCenter.draw(scene)
  local dc = scene.dc
  if not dc then return end

  -- servidores (normalmente debajo del player)
  for _, s in ipairs(dc.servers) do
    if s.draw then s:draw() end
  end

  -- enemigos
  for _, e in ipairs(dc.enemies) do
    if e.draw then e:draw() end
  end

  -- shard (si existe)
  if dc.shard and dc.shard.draw then
    dc.shard:draw()
  end
end

--- Limpia todo (HUD, servidores, enemigos, shard). Llamar en scene.unload().
function DataCenter.detach(scene)
  local dc = scene.dc
  if not dc then return end

  if dc.hud then dc.hud:destroy() end

  if dc.shard and dc.shard.Destroy then pcall(function() dc.shard:Destroy() end) end
  dc.shard = nil

  for i = #dc.enemies, 1, -1 do
    local e = dc.enemies[i]
    if e and e.Destroy then pcall(function() e:Destroy() end) end
    dc.enemies[i] = nil
  end

  for i = #dc.servers, 1, -1 do
    local s = dc.servers[i]
    if s and s.Destroy then pcall(function() s:Destroy() end) end
    dc.servers[i] = nil
  end

  scene.dc = nil
end

return DataCenter

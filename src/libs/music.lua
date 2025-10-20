-- src/audio/music.lua
-- Gestor de música minimal para LÖVE (crossfade + intro→loop).
-- Uso:
--   local Music = require("src.audio.music")
--   Music.register("internetscn", { path="assets/music/net.ogg", volume=0.65 })
--   Music.play("internetscn", { fade=1.2 })
--   Music.stop(1.0)

local Music = {}
Music._tracks  = {}
Music._current = nil        -- Source actual
Music._curId   = nil
Music._fadeJob = nil
Music._introSwapJob = nil
Music._targetVol = 1
Music._preMuteVols = setmetatable({}, { __mode = "k" }) -- map Source -> previous volume (weak keys)

-- ---- helpers ----
local function timerAdd(t)
  -- Si tienes grupos, úsalos; si no, el timer igual corre globalmente
  if t.addToGroup then
    if PlayingTimers then t:addToGroup(PlayingTimers)
    elseif PauseMenuTimers then t:addToGroup(PauseMenuTimers) end
  end
end

local function haveActiveTimerEnv()
  -- Si no tienes Timer o no hay ningún grupo activo, devolvemos false
  if not Timer or not Timer.every then return false end
  -- Si existen, asumimos que alguno corre en gameplay (simplificación)
  return true
end

local function killTimer(ref)
  if ref and ref.Destroy then ref:Destroy() end
  return nil
end

local function cfgVolume()
  local cfg = rawget(_G,"Config") and Config.ConfigTable
  local v = (cfg and (cfg.MUSICVOL or cfg.VOLUME)) or 1
  if v < 0 then v = 0 elseif v > 1 then v = 1 end
  return v
end

local function newSrc(path, looping)
  -- Comprobación de archivo
  if not (love.filesystem.getInfo(path)) then
    print("[Music] Archivo no encontrado:", path)
  end
  local s = love.audio.newSource(path, "stream")
  s:setLooping(looping or false)
  s:setVolume(0)
  return s
end

local function crossfade(toSrc, fadeSec, targetVol, fromSrc)
  fadeSec    = math.max(0.01, fadeSec or 1.0)
  targetVol  = targetVol or cfgVolume()

  if fromSrc == toSrc then
    if toSrc then toSrc:setVolume(targetVol) end
    return
  end

  -- Si no tenemos entorno de timers, o estamos en un estado pausado,
  -- reproducimos sin fade para evitar silencio.
  local canFade = haveActiveTimerEnv()
  if not canFade or fadeSec <= 0.05 then
    if fromSrc then fromSrc:stop() end
    toSrc:setVolume(targetVol)
    love.audio.play(toSrc)
    Music._fadeJob = nil
    return
  end

  local from0 = (fromSrc and fromSrc:getVolume()) or 0
  toSrc:setVolume(0)
  love.audio.play(toSrc)

  Music._fadeJob = (Music._fadeJob and Music._fadeJob.Destroy and Music._fadeJob:Destroy()) or nil
  local t = 0
  Music._fadeJob = Timer.every(1/60, function()
    t = math.min(1, t + (1/60)/fadeSec)
    local nv = targetVol * t
    local fv = from0 * (1 - t)
    if toSrc then toSrc:setVolume(nv) end
    if fromSrc then
      if fv <= 0.001 then fromSrc:stop(); fromSrc = nil
      else fromSrc:setVolume(fv) end
    end
    if t >= 1 then
      if Music._fadeJob and Music._fadeJob.Destroy then Music._fadeJob:Destroy() end
      Music._fadeJob = nil
    end
  end)
  timerAdd(Music._fadeJob)
end

local function scheduleIntroSwap(introSrc, loopPath, vol)
  -- Si no hay timers, hacemos swap inmediato al terminar el intro (sincronía best-effort)
  if not haveActiveTimerEnv() then
    introSrc:setLooping(false)
    introSrc:stop()
    local loopSrc = newSrc(loopPath, true)
    loopSrc:setVolume(vol or cfgVolume())
    love.audio.play(loopSrc)
    Music._current = loopSrc
    return
  end

  if Music._introSwapJob and Music._introSwapJob.Destroy then Music._introSwapJob:Destroy() end
  local dur = introSrc:getDuration("seconds")
  if not dur or dur == math.huge or dur ~= dur or dur <= 0 then return end
  Music._introSwapJob = Timer.after(dur-0.01, function()
    if Music._current ~= introSrc then return end
    local loopSrc = newSrc(loopPath, true)
    loopSrc:setVolume(vol or cfgVolume())
    love.audio.play(loopSrc)
    introSrc:stop()
    Music._current = loopSrc
  end)
  timerAdd(Music._introSwapJob)
end

-- ---- API ----
function Music.register(id, def)
  -- def: { path="...", volume=?,  }  -- loopa todo
  --   o  { intro="...", loop="...", volume=? } -- intro→loop
  assert(id and def, "Music.register: id y def requeridos")
  Music._tracks[id] = def
end

function Music.play(id, opt)
  opt = opt or {}
  if not id or id == "none" then return Music.stop(opt.fade) end
  local def = Music._tracks[id] or { path = id }
  local fade = opt.fade or 1.0
  local vol  = (opt.volume ~= nil) and opt.volume or (def.volume or cfgVolume())

  local newSrc_
  if def.intro and def.loop then
    newSrc_ = newSrc(def.intro, false)
  else
    newSrc_ = newSrc(def.path,  true)
  end

  -- Si no hay timers, no intentamos crossfade: play directo y volumen final.
  if not haveActiveTimerEnv() then
    if Music._current then Music._current:stop() end
    newSrc_:setVolume(vol)
    love.audio.play(newSrc_)
    Music._current = newSrc_
    Music._curId   = id
    Music._targetVol = vol
    if def.intro and def.loop then
      -- best-effort: cambiamos al loop justo al terminar (sin timer → swap inmediato)
      newSrc_:stop()
      local loopSrc = newSrc(def.loop, true)
      loopSrc:setVolume(vol)
      love.audio.play(loopSrc)
      Music._current = loopSrc
    end
    return
  end

  crossfade(newSrc_, fade, vol, Music._current)
  Music._current = newSrc_
  Music._curId   = id
  Music._targetVol = vol
  if def.intro and def.loop then
    scheduleIntroSwap(newSrc_, def.loop, vol)
  else
    if Music._introSwapJob and Music._introSwapJob.Destroy then Music._introSwapJob:Destroy() end
    Music._introSwapJob = nil
  end
end

function Music.stop(fade)
  fade = fade or 0.8
  if not Music._current then return end
  local cur = Music._current
  Music._introSwapJob = killTimer(Music._introSwapJob)
  Music._fadeJob = killTimer(Music._fadeJob)

  local from0 = cur:getVolume()
  local t = 0
  Music._fadeJob = Timer.every(1/60, function()
    t = math.min(1, t + (1/60)/fade)
    local v = from0 * (1 - t)
    if v <= 0.001 then
      cur:stop()
      Music._current = nil
      Music._fadeJob = killTimer(Music._fadeJob)
    else
      cur:setVolume(v)
    end
  end)
  timerAdd(Music._fadeJob)
end

-- actualizar volumen si el usuario cambia MUSICVOL en runtime
function Music.refreshVolume()
  if not Music._current then return end
  local v = cfgVolume()
  Music._targetVol = v
  Music._current:setVolume(v)
end
-- opcional: mute/unmute rápido
function Music.setMuted(muted)
  if not Music._current then return end
  if muted then
    Music._preMuteVols[Music._current] = Music._current:getVolume()
    Music._current:setVolume(0)
  else
    local v = Music._preMuteVols[Music._current] or Music._targetVol or cfgVolume()
    Music._current:setVolume(v)
    Music._preMuteVols[Music._current] = nil
  end
end

return Music

-- src/ui/speedrun_timer.lua
-- Singleton simple (sin metatables ni clases). Se auto-inicializa al require.
-- Señales: "speedrun_start" (arranca), "speedrun_stop"/"end_of_demo" (termina).
-- El tiempo corre con Connect("update", ...) -> NO se pausa con PlayingTimers.
-- HUD visible según Config.ConfigTable.SPEEDRUN_HUD (toggle con applyVisibilityFromConfig()).
-- Best time en Config.ConfigTable.SPEEDRUN_BEST_TIME (segundos).

local SpeedrunTimer = {}

-- ===== Estado interno (no metatables) =====
local _running  = false
local _elapsed  = 0
local _ui = { root=nil, timeLbl=nil, bestLbl=nil, bg=nil, all={} }
local _conns = { upd=nil, start=nil, stop=nil, enddemo=nil }

-- ===== Helpers =====
local function fmtTime(sec)
  sec = math.max(0, sec or 0)
  local m = math.floor(sec / 60)
  local s = math.floor(sec % 60)
  local cs = math.floor((sec - math.floor(sec)) * 100 + 0.5)
  return string.format("%02d:%02d.%02d", m, s, cs)
end

local function getBest()
  if Config and Config.ConfigTable and type(Config.ConfigTable.SPEEDRUN_BEST_TIME) == "number" then
    return Config.ConfigTable.SPEEDRUN_BEST_TIME
  end
  return nil
end

local function setBest(v)
  if not (Config and Config.ConfigTable) then return end
  Config.ConfigTable.SPEEDRUN_BEST_TIME = v
  if Config.saveConfig then Config.saveConfig() end
end

local function setVisibleTree(v)
  if not _ui.all then return end
  for _, w in ipairs(_ui.all) do w.visible = v and true or false end
end

local function keep(x) table.insert(_ui.all, x); return x end

local function buildUI()
  if _ui.root then return end

  _ui.root = keep(Frame.new())
  _ui.root:setPersistent(true)
  _ui.root.zIndex = 420
  _ui.root.anchorPoint = {0.5, 0}
  _ui.root.position    = UDim2.fromScale(0.5, 0.02)
  _ui.root.size        = UDim2.fromScale(0.30, 0.10)
  _ui.root.bgColor     = {0,0,0,0}

  _ui.bg = keep(Frame.new())
  _ui.bg:setParent(_ui.root)
  _ui.bg.anchorPoint = {0.5, 0.5}
  _ui.bg.position    = UDim2.fromScale(0.5, 0.5)
  _ui.bg.size        = UDim2.fromScale(1.0, 1.0)
  _ui.bg.bgColor     = {0,0,0,0.25}
  _ui.bg.zIndex      = 421

  _ui.timeLbl = keep(Textlabel.new("00:00.00"))
  _ui.timeLbl:setParent(_ui.root)
  _ui.timeLbl.anchorPoint = {0.5, 0.5}
  _ui.timeLbl.position    = UDim2.fromScale(0.5, 0.40)
  _ui.timeLbl.size        = UDim2.fromScale(1.0, 0.55)
  _ui.timeLbl.textColor   = {1,1,1,1}
  if Fonts and Fonts.VT323 then _ui.timeLbl.font = Fonts.VT323 end
  _ui.timeLbl.zIndex      = 422

  local best = getBest()
  _ui.bestLbl = keep(Textlabel.new(best and ("Best: "..fmtTime(best)) or "Best: --:--.--"))
  _ui.bestLbl:setParent(_ui.root)
  _ui.bestLbl.anchorPoint = {0.5, 0.5}
  _ui.bestLbl.position    = UDim2.fromScale(0.5, 0.82)
  _ui.bestLbl.size        = UDim2.fromScale(1.0, 0.30)
  _ui.bestLbl.textColor   = {1,1,1,0.9}
  if Fonts and Fonts.VT323 then _ui.bestLbl.font = Fonts.VT323 end
  _ui.bestLbl.zIndex      = 422

  local show = (Config and Config.ConfigTable and Config.ConfigTable.SPEEDRUN_HUD) and true or false
  setVisibleTree(show)
end

function SpeedrunTimer._refreshHUD()
  if _ui.timeLbl then _ui.timeLbl.text = fmtTime(_elapsed or 0) end
  local best = getBest()
  if _ui.bestLbl then
    _ui.bestLbl.text = best and ("Best: "..fmtTime(best)) or "Best: --:--.--"
  end
end

local function popupResult(runSec, bestSec)
  if not (Popup and Popup.show) then return end
  Popup.show({
    text  = ("Run: %s\nBest: %s"):format(fmtTime(runSec), bestSec and fmtTime(bestSec) or "--:--.--"),
  })
end

-- ===== Lógica =====
local function onUpdate(dt)
  if _running then
    _elapsed = (_elapsed) + (dt)
    SpeedrunTimer._refreshHUD()
  end
end

local function onStart()
  _elapsed = 0
  _running = true
  SpeedrunTimer._refreshHUD()
end

local function onFinish()
  if not _running then return end
  _running = false
  local run = _elapsed or 0
  local best = getBest()
  popupResult(run, best)
  if (not best) or (run < best) then
    setBest(run)
    best = run
  end
  SpeedrunTimer._refreshHUD()
end

-- ===== API pública (mismos nombres que ya usas) =====
-- Arranca/para manualmente si lo necesitas:
function SpeedrunTimer.start() onStart() end
function SpeedrunTimer.stop()  onFinish() end

-- Compat: si alguien llama update(dt) desde el loop
function SpeedrunTimer.update(dt)
  -- el avance real va por Connect("update"); aquí refrescamos por si acaso
  SpeedrunTimer._refreshHUD()
  onUpdate(dt)
end

-- Mostrar/ocultar HUD según Config (llámalo tras cambiar el checkbox)
function SpeedrunTimer.applyVisibilityFromConfig()
  buildUI()
  local show = (Config and Config.ConfigTable and Config.ConfigTable.SPEEDRUN_HUD) and true or false
  setVisibleTree(show)
  SpeedrunTimer._refreshHUD()
end

-- Destructor opcional
function SpeedrunTimer.Destroy()
  if _conns.start  then Disconnect("speedrun_start", _conns.start)  end
  if _conns.stop   then Disconnect("speedrun_stop",  _conns.stop)   end
  if _conns.enddemo then Disconnect("end_of_demo",   _conns.enddemo) end
  _conns = {}

  if _ui.root and _ui.root.Destroy then _ui.root:Destroy() end
  _ui = { root=nil, timeLbl=nil, bestLbl=nil, bg=nil, all={} }

  _running, _elapsed = false, 0
end

-- Compatibilidad: si en algún lado llaman .new(), no rompe nada.
function SpeedrunTimer.new()
  buildUI()
  return SpeedrunTimer
end

-- ===== Auto-inicialización al require =====
buildUI()
_conns.start   = Connect("speedrun_start", onStart)
_conns.stop    = Connect("speedrun_stop",  onFinish)
_conns.enddemo = Connect("end_of_demo",    onFinish)

return SpeedrunTimer

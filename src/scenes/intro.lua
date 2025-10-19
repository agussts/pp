-- src/scenes/intro.lua
-- Intro tipo “cold open”: textos que faden in/out sobre negro.
-- Usa: Frame/PrintfLabel opcional, pero aquí dibujamos directo para minimizar dependencias.
-- Depende de: Timer, Scene, Transition, Wizard, Fonts (opcional), Connect/Disconnect.

local Wizard = require("src/ui/accessibility_wizard")

return function()
  local scene = {}

  -- === Configurable ===
  local NEXT_SCENE   = "internetscn"   -- a dónde ir tras la intro
  local FADE_IN_S    = 1.0
  local HOLD_S       = 1.0
  local FADE_OUT_S   = 1.0
  local GAP_S        = 0.4             -- pausa entre líneas
  local TEXT_COLOR   = {1,1,1,1}
  local BG_COLOR     = {0,0,0,1}
  local IGNORE_FIRST_PRESS = true

  -- Ajusta el contenido a tu gusto (breve, claro, evocativo)
  local LINES = {
    "You are a tiny virus.",
    "You live inside the internet.",
    "Find three green data shards.",
    "Bring them back to the one who asked."
  }


  -- === Estado ===
  local idx = 0
  local alpha = 0         -- alpha del texto
  local text = ""
  local running = false
  local skipping = false

  local kconn = nil
  local tickIn, tickHold, tickOut, tickGap, tickSkip = nil,nil,nil,nil,nil

  -- Fuente (opcional VT323)
  local font = love.graphics.getFont()
  if Fonts and Fonts.VT323 then font = Fonts.VT323 end

  local function clearTimers()
    local list = {tickIn, tickHold, tickOut, tickGap, tickSkip}
    for _,t in ipairs(list) do if t and t.Destroy then t:Destroy() end end
    tickIn,tickHold,tickOut,tickGap,tickSkip = nil,nil,nil,nil,nil
  end

  local function finish()
    if skipping then return end
    skipping = true
    clearTimers()
    if kconn then kconn:Disconnect()
    kconn = nil end
    if Config.ConfigTable.SEEN_ACC ~= true then
      Config.ConfigTable.SEEN_ACC = true

      Wizard.setOnDone(function ()
        Transition.play(function ()
          Scene.load(NEXT_SCENE)
          Gamestate = "playing"
        end)
      end)
      Wizard.show()
    else
      Transition.play(function ()
          Scene.load(NEXT_SCENE)
          Gamestate = "playing"
        end)
    end
    -- if Transition and Transition.play then
    --   Transition.play(function() Scene.load(NEXT_SCENE) end)
    -- else
    --   Scene.load(NEXT_SCENE)
    -- end
  end

  local function showNextLine()
    if skipping then return end
    idx = idx + 1
    if idx > #LINES then
      finish()
      return
    end

    text = LINES[idx]
    alpha = 0

    -- Fade-in
    local t = 0
    tickIn = Timer.every(1/60, function()
      t = math.min(1, t + (1/60)/FADE_IN_S)
      alpha = t
      if t >= 1 then
        if tickIn and tickIn.Destroy then tickIn:Destroy() end
        tickIn = nil
        -- Hold
        local h = 0
        tickHold = Timer.every(1/60, function()
          h = math.min(HOLD_S, h + 1/60)
          if h >= HOLD_S then
            if tickHold then tickHold:Destroy() end
            tickHold = nil
            -- Fade-out
            local o = 1
            tickOut = Timer.every(1/60, function()
              o = math.max(0, o - (1/60)/FADE_OUT_S)
              alpha = o
              if o <= 0 then
                if tickOut and tickOut.Destroy then tickOut:Destroy() end
                tickOut = nil
                -- Gap
                local g = 0
                tickGap = Timer.every(1/60, function()
                  g = math.min(GAP_S, g + 1/60)
                  if g >= GAP_S then
                    if tickGap and tickGap.Destroy then tickGap:Destroy() end
                    tickGap = nil
                    showNextLine()
                  end
                end)
                tickGap:addToGroup(PlayingTimers)
              end
            end)
            tickOut:addToGroup(PlayingTimers)
          end
        end)
        tickHold:addToGroup(PlayingTimers)
      end
    end)
    tickIn:addToGroup(PlayingTimers)
  end

  function scene.load(self)
    Gamestate = "intro"
    running = true
    if Config.ConfigTable.SEEN_ACC ~= true then
      Wizard.ensure()
    end
    -- tecla para omitir
    kconn = Connect("keyPressed", function()
      if IGNORE_FIRST_PRESS then
         IGNORE_FIRST_PRESS = false
         scene._skipAlpha = 1
         return 
        end
      if not running or skipping then return end
      finish()
    end)

    -- arrancar
    showNextLine()
  end

  function scene.update(self, dt)
    -- nada: toda la animación es por Timer.every
  end

  function scene.draw(self)
    local w,h = love.graphics.getDimensions()
    -- fondo negro
    love.graphics.setColor(BG_COLOR)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- texto central
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    love.graphics.setFont(font)
    local margin = math.floor(w*0.1)
    local y = math.floor(h*0.44)
    love.graphics.printf(text, margin, y, w - margin*2, "center")

    -- hint skip (esquina inferior)
    local a = scene._skipAlpha or 0
    if a > 0 and not skipping then
      love.graphics.setColor(1,1,1,0.66*a)
      local hint = "Press any key to skip"
      local tw   = love.graphics.newText(font, hint)
      local tx   = w - margin - tw:getWidth()
      local ty   = h - math.floor(h*0.12)
      love.graphics.draw(tw, tx, ty)
    end

    love.graphics.setColor(1,1,1,1)
  end

  function scene.unload(self)
    running = false
    clearTimers()
    if kconn then kconn:Disconnect()
    kconn = nil end
  end

  return scene
end

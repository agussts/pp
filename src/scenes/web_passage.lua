-- Escena "web_passage" basada en Tiled: piso blanco (tile layer), fondo negro y colliders.
-- Paso 1: carga mapa, posiciona al jugador y crea muros. (Sin luz/fade aún).

return function ()
  local scene = {}

  -- ---------- helpers ----------
    -- ========= Ajustes (puedes tunear) =========
  local SLOW_RADIUS   = 0.40    -- radio (en escala Y) donde empieza a frenar
  local MIN_FACTOR    = 0.25    -- porcentaje de velocidad mínima al llegar a la luz
  local REACH_TOL     = 0.02    -- umbral para “tocar” la luz
  local FADE_WHITE_S  = 1.0     -- segundos del fade a blanco

  local function loadMap(self)
    -- Ajusta la ruta del .lua exportado por Tiled
    self.map = TiledLite and TiledLite.load("assets/maps/web_passage.lua") or nil
    if not self.map then
      print("[web_passage] WARNING: no se pudo cargar el mapa Tiled.")
      return
    end
  end

  -- ========= Secuencia final =========
  local function triggerEndSequence(st)
    if st._ending then return end
    st._ending = true

    -- congela al jugador
    st._restoreSpeed = st._restoreSpeed or Player.speed
    Player.speed = (st._restoreSpeed or 1) * 0.1

    -- overlay blanco (z alto)
    st._white = Frame.new()
    st._white:setParent(st.glowRoot) -- el contenedor que uses para UI
    st._white.size     = UDim2.fromScale(1,1)
    st._white.position = UDim2.fromScale(0,0)
    st._white.bgColor  = {1,1,1,0}
    st._white.zIndex   = 999

    -- animar a blanco
    local t, tick = 0, nil
    tick = Timer.every(1/60, function()
      t = math.min(1, t + (1/60)/FADE_WHITE_S)
      local c = st._white.bgColor; c[4] = t; st._white.bgColor = c
      if t >= 1 then
        if tick == nil then return end
        tick:Destroy()
        -- corte abrupto a negro y “END OF DEMO”
        Timer.after(0.10, function()
          st._white.bgColor = {0,0,0,1}

          local lbl = Textlabel.new("END OF DEMO")
          lbl:setParent(st._white)
          lbl.anchorPoint = {0.5,0.5}
          lbl.position    = UDim2.fromScale(0.5, 0.5)
          lbl.size        = UDim2.fromScale(1, 0.14)
          lbl.textColor   = {1,1,1,1}
          lbl.zIndex = 9999
          if Fonts and Fonts.VT323 then lbl.font = Fonts.VT323 end
          Connect("keyPressed", function (key)
            if key == "escape" then love.event.quit() end
          end)
        end):addToGroup(PlayingTimers)
      end
    end)
    tick:addToGroup(PlayingTimers)
  end

  local function spawnObjects(self)
    local F = {}

    -- Punto de inicio del jugador
    F["web_start"] = function(o, scn)
      Player = PlayerModule.new("assets/sprites/player-Sheet.png")
      Player.collision.position = UDim2.fromScale(o.sx, o.sy)
      Player.Dash = function() end
      return Player
    end

    -- (Para el paso 2) marcador de “luz” al final
    F["web_goal"] = function(o)
      local goalPos = UDim2.fromScale(o.sx + o.sw/2 , o.sy)
      self.endHitbox = Collisions.new("hitbox")
      self.endHitbox.position = UDim2.fromScale(o.sx, o.sy)
      self.endHitbox.size = UDim2.fromScale(o.sw, o.sh)
      self.endHitbox.onHit:Connect(function (other)
        if other:HasTag("player") then
          triggerEndSequence(self)
        end
      end)
      return goalPos
    end

    F["web_noback"] = function(o)
      local noback = Collisions.new("hitbox")
      noback.position = UDim2.fromScale(o.sx, o.sy)
      noback.size = UDim2.fromScale(o.sw, o.sh)
      noback.onHit:Connect(function (other)
        if other:HasTag("player") then
          Dialogue.start(WrittenDialogues.webattemptexit, 42)
          local pushOut = Collisions.new("box")
          pushOut.anchored = true
          pushOut.anchor = {0,.2}
          pushOut.position = UDim2.fromScale(o.sx, o.sy)
          pushOut.size = UDim2.fromScale(o.sw, o.sh + .03)
          Timer.after(.1, function ()
              pushOut:Destroy()
          end):addToGroup(PlayingTimers)
        end
      end)
      return noback
    end

    self.map:spawnObjects(F, self)
  end

  
  local function spawnExpandingGlow(self)
    -- origen (punto 0) y parámetros
    local centerX = self.goalPos.x.scale
    local y0      = 0                                          -- punto 0 (arriba del brillo)
    local D_MAX   = 0.55                                       -- desplazamiento máx. hacia abajo (escala)
    local LAYERS  = 18                                         -- nº de “capas”
    local COL_W   = 0.11                                       -- ancho columna
    local SLAB_H  = 0.1                                        -- alto de cada losa (no crítico, se superponen)
    local BASE_A  = 0.8                                        -- alpha base de las losas
    local ALPHA_P = 0.7                                        -- curva de atenuación por capa
    local K_EXP   = 3.3                                        -- curva exponencial (densidad: más grande = más capas al inicio)
    local SPEED   = 0.25                                       -- respiracion mas lenta o rapida

    self.glowSlabs = {}
    self._glow = {x=centerX, y0=y0, dmax=D_MAX, k=K_EXP, t=0, speed=SPEED, colw=COL_W, slabH=SLAB_H}

    for i = 1, LAYERS do
      local u = (i-1) / (LAYERS-1)          -- 0..1 índice normalizado (delante→fondo)
      local slab = Frame.new()
      slab:setParent(self.glowRoot)
      slab.anchorPoint = {0.5, 0}           -- ancla arriba (se desplaza hacia abajo)
      slab.size        = UDim2.fromScale(COL_W, SLAB_H)
      slab.position    = UDim2.fromScale(centerX, y0)  -- TODOS nacen en el punto 0
      -- alpha decrece con la “profundidad” para sentir más brillante el origen
      local a = BASE_A * ((1 - u)^ALPHA_P)
      slab.bgColor     = {1,1,1, a}
      slab.zIndex      = 10 + i

      slab._u          = u                  -- guardamos u
      slab._baseAlpha  = a

      table.insert(self.glowSlabs, slab)
    end
  end

  local function updateExpandingGlow(self, dt)
    local g = self._glow
    if not g or not self.glowSlabs then return end

    -- ciclo 0→1→0 usando coseno (ping–pong suave)
    g.t = (g.t + (dt or 0)*g.speed) % 1
    local E = 0.5 * (1 - math.cos(g.t * 2*math.pi))  -- 0..1..0

    -- normalización exponencial: 0..1 con más “peso” cerca de 0
    local denom = math.exp(g.k) - 1

    for _, slab in ipairs(self.glowSlabs) do
      local u = slab._u
      local w = (math.exp(g.k * u) - 1) / denom  -- curva de despliegue (casi nada al inicio, mucho al final)
      local disp = g.dmax * w * E                -- desplazamiento instantáneo

      slab.position = UDim2.fromScale(g.x, g.y0 + disp)

      -- leve respiración de intensidad (no imprescindible)
      local a = slab._baseAlpha * (0.75 + 0.25 * E)
      local c = slab.bgColor; c[4] = a; slab.bgColor = c
    end
  end

  -- ========= Frenado por cercanía + disparador de final =========
  local function updateApproach(st, dt)
    if not Player or not Player.collision or not st.goalPos then return end

    -- lectura robusta de UDim2 (acepta x.scale / X.Scale)
    local gy = (st.goalPos.y and st.goalPos.y.scale) or (st.goalPos.Y and st.goalPos.Y.Scale) or 0.1
    local py = Player.collision.position.y and Player.collision.position.y.scale or gy + 1

    -- distancia vertical “hacia arriba” (el jugador viene desde abajo)
    local dist = math.max(0, py - gy)                    -- 0 cuando está en la luz
    Player.speed = math.max(25, 250 * dist - 40)
  end


  

  -- ---------- escena estándar ----------
  function scene.load(self)
    self.bgA = Background.new("assets/sprites/littledots.png", 64, 64, 0, 0)
    self.bgA:setRepeat(true)
    self.bgA.color = {1,1,1,0.35}
    self.bgB = Background.new("assets/sprites/littledots.png", 64, 64, 0, 0)
    self.bgB:setRepeat(true)
    self.bgB.color = {1,1,1,0.35}

    self.glowTime = 0
    -- Cargar mapa
    loadMap(self)
    self.pulseT = 0
    -- Colocar player y muros desde objetos
    spawnObjects(self)
    spawnExpandingGlow(self)
    self._restoreSpeed = Player.speed

    Music.stop()
  end

  function scene.update(self, dt)
    -- Cámara fija
    local w,h = love.graphics.getDimensions()
    Camera.update(w/2, h/2)

    self.glowTime = self.glowTime + dt

    updateExpandingGlow(self, dt)
    updateApproach(self, dt)
  end
  function scene.draw(self)
    local t = self.glowTime
    self.bgA:setScroll(t, t * 8)
    self.bgA.color[4] = 0.19 - 0.095 * (0.5 + 0.5 * math.sin(t * 0.8))
    self.bgB:setScroll(t * 8, t)
    self.bgB.color[4] = 0.19 + 0.095 * (0.5 + 0.5 * math.sin(t * 0.8))

    self.bgA:drawBackground()
    self.bgB:drawBackground()
  end

  function scene.unload(self)
    if self.glowSlabs then
      for _,slab in ipairs(self.glowSlabs) do if slab.Destroy then slab:Destroy() end end
    end

    if self.glowRoot and self.glowRoot.Destroy then self.glowRoot:Destroy() end

    self.glowSlabs, self.glowRoot = nil, nil
    if self._restoreSpeed then
      Player.speed = self._restoreSpeed
    end
  end

  return scene
end

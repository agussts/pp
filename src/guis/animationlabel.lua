---
-- Widget GUI para dibujar una Animation dentro del sistema de GUI.
-- Hereda de Guis.new() (igual que Textlabel/PrintfLabel).
-- Soporta: fit ("none" | "contain" | "cover"), scale multiplicador y autoPlay.
-- Se actualiza con el evento global "update".
--@classmod AnimationLabel

local AnimationLabel = {}

--- Crea un nuevo AnimationLabel
-- @tparam Animation anim Instancia de Animation ya creada (con :update, :draw, :Play, :Pause y .OnFinish opcional)
-- @tparam[opt] table opt { fit="contain"/"cover"/"none", scale=1.0, play=true }
-- @treturn AnimationLabel instancia
function AnimationLabel.new(anim, opt)
    assert(anim and anim.update and anim.draw, "AnimationLabel.new(anim): 'anim' debe ser una Animation válida")

    opt = opt or {}

    local self = Guis.new()
    self.type   = "animationlabel"
    self.anim   = anim
    self.fit    = opt.fit   or "none"   -- "none" | "contain" | "cover"
    self.scaleM = opt.scale or 1.0
    self._play  = (opt.play ~= false)

    -- Evento de “fin” reemitido (si la anim lo soporta)
    self.OnFinish = Signal.new()
    self._afin = nil
    if self.anim.OnFinish and self.anim.OnFinish.Connect then
        self._afin = self.anim.OnFinish:Connect(function()
            self.OnFinish:Fire()
        end)
    end

    -- Estado inicial de reproducción
    if self._play then self.anim:Play() else self.anim:Pause() end

    -- Conexión de update global (igual patrón que otros GUIs que usan Connect)
    self.update = function(dt)
        if not self.visible then return end
        if self._play then self.anim:update(dt or 0) end
    end

    -- Métodos simples (mismo estilo que otros GUIs)
    function self:play()
        self._play = true
        if self.anim.Play then self.anim:Play() end
    end
    function self:pause()
        self._play = false
        if self.anim.Pause then self.anim:Pause() end
    end
    function self:stop()
        self._play = false
        if self.anim.Pause then self.anim:Pause() end
    end
    function self:setScale(s)
        self.scaleM = tonumber(s) or self.scaleM
    end
    --- Cambia la animación en caliente (desuscribe y re-suscribe OnFinish)
    function self:setAnimation(newAnim, keepPlay)
        assert(newAnim and newAnim.update and newAnim.draw, "setAnimation(newAnim): anim no válida")
        if self._afin then self._afin:Disconnect() self._afin = nil end
        self.anim = newAnim
        if self.anim.OnFinish and self.anim.OnFinish.Connect then
            self._afin = self.anim.OnFinish:Connect(function()
                self.OnFinish:Fire()
            end)
        end
        if keepPlay == false then
            self._play = false
            if self.anim.Pause then self.anim:Pause() end
        else
            self._play = true
            if self.anim.Play then self.anim:Play() end
        end
    end

    -- Dibujo (mismo patrón de Textlabel/PrintfLabel: escala por TrueResolution.scale)
    self.draw = function()
        if not self.visible then return end

        local x, y = self:getRenderPosition()
        local w, h = self:getRenderSize()
        if w <= 0 or h <= 0 then return end

        local scale = (TrueResolution and TrueResolution.scale) or 1
        local sx = x / scale
        local sy = y / scale
        local sw = w / scale
        local sh = h / scale

        -- Medidas base de frame de la animación (para fit)
        local fw = self.anim.gridWidth  or self.anim._frameW or 32
        local fh = self.anim.gridHeight or self.anim._frameH or 32

        local kx, ky = 1, 1
        if self.fit == "contain" then
            local k = math.min(sw / fw, sh / fh)
            kx, ky = k, k
        elseif self.fit == "cover" then
            local k = math.max(sw / fw, sh / fh)
            kx, ky = k, k
        end
        kx = kx * self.scaleM
        ky = ky * self.scaleM

        local cx = sx + sw * 0.5
        local cy = sy + sh * 0.5

        love.graphics.push()
        love.graphics.scale(scale)
        love.graphics.translate(cx, cy)
        love.graphics.scale(kx, ky)
        -- Se espera que la anim tenga anchor {.5,.5}. Dibujamos centrado:
        self.anim:draw(0, 0)
        love.graphics.pop()
    end

    -- Limpieza (libera conexiones y deja Destroy de Guis para el resto)
    local baseDestroy = self.Destroy
    self.Destroy = function(s)
        if s._uconn then Disconnect("update", s._uconn) end
        s._uconn = nil
        if s._afin then s._afin:Disconnect() end
        s._afin = nil
        if baseDestroy then baseDestroy(s) end
    end

    return self
end

return AnimationLabel

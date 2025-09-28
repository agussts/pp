--- ProximityPrompt: muestra un prompt al acercarte y emite una señal al presionar una tecla.
-- Depende de: Guis, Textlabel/PrintfLabel (cualquiera), Frame, Collisions, Signal, UDim2, Connect/Fire.
-- El prompt se activa al detectar la colisión del jugador y se oculta al salir.
-- @module ProximityPrompt

local ProximityPrompt = {}
ProximityPrompt.__index = ProximityPrompt

--- Crea un nuevo prompt de proximidad.
-- @tparam string text Texto a mostrar. Debe contener un `%s` si quieres interpolar la tecla (ej: `"Presiona %s para hablar"`).
-- @tparam string key Tecla que activa la interacción. Si se omite, usa `Config.SavedConfigs.PINTR`.
-- @treturn ProximityPrompt La nueva instancia del prompt.
-- @usage
-- local prompt = ProximityPrompt.new("Presiona %s para interactuar", "e")
-- prompt.Triggered:Connect(function() print("¡Interacción!") end)
function ProximityPrompt.new(text, key)
    local self = setmetatable({}, ProximityPrompt)

    --- Señal que se dispara cuando se presiona la tecla de interacción estando dentro.
    -- @signal Triggered
    self.Triggered = Signal.new()

    -- Colisión (hitbox que no bloquea)
    self.collision = Collisions.new("hitbox")
    self.collision.position = UDim2.fromScale(0.5, 0.5)
    self.collision.size     = UDim2.fromScale(0.06, 0.12)
    self.collision.anchor   = {0.5, 0.5}
    self.collision:AddTag("proximity")

    -- Estado
    self.key     = key or Config.SavedConfigs.PINTR
    if text and type(text) == "string" then
        assert(text:find("%%s") ~= nil, "Must include %s in string to insert key.")
    end
    self.text    = string.format(text, self.key:upper()) or ("Press ["..self.key:upper().."] to interact")
    self._inside = false
    self._keyConn = nil

    -- UI (caja inferior con un label centrado)
    self._ui = {}
    self._ui.box = Frame.new()
    self._ui.box.size = UDim2.fromScale(0.6, 0.12)
    self._ui.box.position = UDim2.fromScale(0.5, 0.88)
    self._ui.box.anchorPoint = {0.5, 0.5}
    self._ui.box.bgColor = {0, 0, 0, 0.55}
    self._ui.box.zIndex = 3
    self._ui.box.visible = false

    self._ui.label = Textlabel.new(self.text)
    self._ui.label:setParent(self._ui.box)
    self._ui.label.position = UDim2.fromScale(0.5, 0.5)
    self._ui.label.size     = UDim2.fromScale(1, 1)
    self._ui.label.anchorPoint = {0.5, 0.5}
    self._ui.label.textColor = {1,1,1,1}
    self._ui.label.zIndex = (self._ui.box.zIndex or 0) + 1
    self._ui.label.visible = false

    return self
end

--- Muestra u oculta la UI del prompt.
-- @tparam boolean show Si es `true`, se muestra; si es `false`, se oculta.
function ProximityPrompt:_showUI(show)
    local vis = not not show
    if self._ui and self._ui.box then
        self._ui.box.visible = vis
        if self._ui.label then
            self._ui.label.visible = vis
        end
        if vis then
            -- Forza layout ahora que es visible,
            -- así no aparece en (0,0) un frame antes.
            self._ui.box:calculateRenderProperties()
        end
    end
end

--- Enlaza la tecla de interacción mientras el jugador está dentro.
function ProximityPrompt:_bindKey()
    if self._keyConn then return end
    self._keyConn = Connect("keyPressed", function(key)
        if not self._inside then return end
        if key ~= self.key then return end
        self.Triggered:Fire(self)
    end)
end

--- Desenlaza la tecla de interacción.
function ProximityPrompt:_unbindKey()
    if not self._keyConn then return end
    self._keyConn:Disconnect()
    self._keyConn = nil
end

--- Actualiza el estado del prompt.
-- Debe llamarse en el `update()` de la escena para detectar si el jugador entra/sale del área.
function ProximityPrompt:update()
    if not Player or not Player.collision then return end

    local collisions = self.collision:check()
    local inside = false
    for _,v in pairs(collisions) do
        if v:HasTag("player") then
            inside = true
            break
        end
    end

    if inside and not self._inside then
        self._inside = true
        self:_showUI(true)
        self:_bindKey()
    elseif (not inside) and self._inside then
        self._inside = false
        self:_showUI(false)
        self:_unbindKey()
    end
end

--- Cambia el texto mostrado en el prompt.
-- @tparam string newText El nuevo texto.
function ProximityPrompt:setText(newText)
    self.text = newText or self.text
    if self._ui and self._ui.label then
        self._ui.label.text = self.text
    end
end

--- Cambia la tecla usada para interactuar.
-- @tparam string newKey La nueva tecla.
function ProximityPrompt:setKey(newKey)
    if newKey and #newKey > 0 then
        self.key = newKey:lower()
        if self.text and self.text:find("%[.-%]") then
            self:setText(self.text:gsub("%[.-%]", "["..self.key:upper().."]", 1))
        end
    end
end

--- Destruye el prompt y limpia recursos asociados (UI, colisión, señales).
function ProximityPrompt:Destroy()
    -- UI
    if self._ui then
        if self._ui.label and self._ui.label.Destroy then self._ui.label:Destroy() end
        if self._ui.box and self._ui.box.Destroy then self._ui.box:Destroy() end
    end
    self._ui = nil

    -- Colisión
    if self.collision and self.collision.Destroy then
        self.collision:Destroy()
    end
    self.collision = nil

    -- Señales
    if self.Triggered then
        self.Triggered.callbacks = {}
    end

    self:_unbindKey()
    self = nil
end

return ProximityPrompt

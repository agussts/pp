--- Sistema de diálogos simple (sin retratos).
--  Pausa el gameplay mientras está activo y reanuda al terminar.
--  Uso:
--    Dialogue.start({
--       { who="Broker", text="Bienvenido a la Dark Web." },
--       { who="Prota",  text="..." },
--    })

local Dialogue = {}
local allDialogues = {}
Dialogue.__index = Dialogue

local function newPrintfLabel()
    local self = Guis.new()
    self.type = "printf_label"
    self.text = ""
    self.color = {1,1,1,1}
    self.align = "left"
    self.font  = love.graphics.getFont()
    self.draw = function ()
        local x,y = self:getRenderPosition()
        local w,h = self:getRenderSize()
        love.graphics.setColor(self.color)
        local f = self.font or love.graphics.getFont()
        love.graphics.printf(self.text, f, x, y, w, self.align)
        love.graphics.setColor(1,1,1,1)
    end
    return self
end

local function buildUI(self)
    self.root = Frame.new()
    self.root.size = UDim2.fromScale(1,1)
    self.root.bgColor = {0,0,0,0}
    self.root.zIndex = 999
    self.root.anchorPoint = {0,0}
    self.root.visible = true

    -- Caja inferior
    self.box = Frame.new()
    self.box:setParent(self.root)
    self.box.size = UDim2.fromScale(1, 0.28)
    self.box.position = UDim2.fromScale(0.5, 0)
    self.box.anchorPoint = {0.5, 0}
    self.box.bgColor = {0,0,0,.8}
    self.box.zIndex = -1

    -- Estilo: borde blanco grueso, por encima de la caja
    self.box:applyStyle(Border, {
        thicknessPx = 3,
        color       = {1,1,1,1},
        zOffset     = 2,     -- va sobre la caja pero bajo el texto
        insetPx     = 0
    })

    -- Nombre
    self.nameText = Textlabel.new("")
    self.nameText:setParent(self.box)
    self.nameText.size = UDim2.fromScale(0.3, 0.25)
    self.nameText.position = UDim2.fromScale(0.02, 0.05)
    self.nameText.anchorPoint = {0,0}
    self.nameText.textColor = {1,1,1,1}
    self.nameText.zIndex = 5
    self.nameText.font = Fonts.VT323

    -- Texto
    self.textLbl = newPrintfLabel()
    self.textLbl:setParent(self.box)
    self.textLbl.size = UDim2.fromScale(0.95, 0.65)
    self.textLbl.position = UDim2.fromScale(0.025, 0.3)
    self.textLbl.anchorPoint = {0,0}
    self.textLbl.color = {1,1,1,1}
    self.textLbl.zIndex = 5
    self.textLbl.font = Fonts.VT323
    
end

function Dialogue.start(script, opts)
    assert(type(script)=="table" and #script>0, "Dialogue.start: script inválido")
    local self = setmetatable({}, Dialogue)
    self.script = script
    self.idx = 1
    self.cps = (opts and opts.cps) or 40
    self.onFinish = opts and opts.onFinish
    self._charIdx = 0
    self._elapsed = 0
    self._fullText = ""
    self._showing = ""
    self._active = true

    if Gamestate == "playing" then
        PlayingTimers:pause()
        Gamestate = "paused"
    end

    buildUI(self)
    self:applyLine(self.script[self.idx])

    self._connection = function(key)
        if key == "space" or key == "return" or key == "kpenter" then
            self:advanceOrSkip()
        end
    end
    Connect("keyPressed", self._connection)

    table.insert(allDialogues, self)
    return self
end

function Dialogue:applyLine(line)
    self._fullText = tostring(line.text or "")
    self._showing = ""
    self._charIdx = 0
    self._elapsed = 0
    self.nameText.text = tostring(line.who or "")
    self.textLbl.text = self._showing
end

function Dialogue:_update(dt)
    if not self._active then return end
    self._elapsed = self._elapsed + dt * self.cps
    local target = math.floor(self._elapsed + 0.0001)
    if target > self._charIdx then
        self._charIdx = math.min(#self._fullText, target)
        self._showing = string.sub(self._fullText, 1, self._charIdx)
        self.textLbl.text = self._showing
    end
end

function Dialogue:advanceOrSkip()
    if not self._active then return end
    if self._charIdx < #self._fullText then
        self._charIdx = #self._fullText
        self._showing = self._fullText
        self.textLbl.text = self._showing
        return
    end
    self.idx = self.idx + 1
    local nextLine = self.script[self.idx]
    if nextLine then
        self:applyLine(nextLine)
    else
        self:finish()
    end
end

function Dialogue:finish()
    if not self._active then return end
    self._active = false
    if self._connection then Disconnect("keyPressed", self._connection) end
    if self.root then self.root:Destroy() end
    Gamestate = "playing"
    if not PlayingTimers.playing then
        PlayingTimers:continue()
    end
    self.root:Destroy()
    self.textLbl = nil
    if self.onFinish then pcall(self.onFinish) end
end

function Dialogue.updateAll(dt)
    for _,dial in ipairs(allDialogues) do
        dial:_update(dt)
    end
end

return Dialogue

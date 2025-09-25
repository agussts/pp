--- PrintfLabel: etiqueta de texto con ajuste automático a la resolución
-- Usa el layout de GUI (Guis.new) y se dibuja con love.graphics.printf
-- Escala visualmente con TrueResolution.scale (no cambia el tamaño del font).
--@classmod PrintfLabel

local PrintfLabel = {}
--- Crea una etiqueta
-- @tparam string text Texto inicial
-- @treturn PrintfLabel instancia
function PrintfLabel.new(text)
    local self = Guis.new()

    -- Contenido
    self.text = text or ""

    -- Apariencia
    self.textColor = {1,1,1,1}
    self.align     = "left"                   -- "left" | "center" | "right"
    self.fontPath  = nil                      -- opcional, si nil usa love.graphics.getFont()
    self.fontSize  = 26                       -- en “pixels” de resolución ideal
    self.font      = love.graphics.getFont()  -- cache del font (si se usa fontPath)

    -- Transform (heredado de Guis)
    -- self.position, self.size, self.anchorPoint, etc.

    --Dibujo
    self.draw = function ()      
        if not self.visible then return end

        local x, y = self:getRenderPosition()
        local w, h = self:getRenderSize()
        if w <= 0 or h <= 0 then return end

        local scale = (TrueResolution and TrueResolution.scale) or 1

        local prevFont = love.graphics.getFont()
        love.graphics.setFont(self.font)

        -- Color
        love.graphics.setColor(self.textColor)

        -- Escala tipo “resolución virtual”
        love.graphics.push()
        love.graphics.scale(scale)

        -- Convertimos a coords del “mundo UI” (resolución ideal)
        local sx = x / scale
        local sy = y / scale
        local sw = w / scale

        local alignMode = self.align
        if alignMode ~= "center" and alignMode ~= "right" then
            alignMode = "left"
        end

        love.graphics.printf(self.text or "", sx, sy, sw, alignMode)

        love.graphics.pop()
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(prevFont)
    end
    return self
end

return PrintfLabel

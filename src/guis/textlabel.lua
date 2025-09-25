---
-- Etiqueta de texto que se muestra en el GUI
-- Usa componentes de GUI
--@classmod textlabel
--@see gui

local textlabel = {}

---
-- Crea un nuevo textlabel
--@param text (string) El texto a mostrar
--@return (textlabel) Instancia del textlabel
--@usage local myLabel = textlabel.new("Hola Mundo")
function textlabel.new(text)
    local self = Guis.new()
    self.text = text
    self.textColor = {1,1,1,1}
    self.font = love.graphics.getFont()
    self.type = "textlabel"

    self.draw = function ()
        if not self.visible then return end
        local x, y = self:getRenderPosition()
        local width, height = self:getRenderSize()
        love.graphics.setColor(self.textColor or {0,0,0,1})
        love.graphics.scale(TrueResolution.scale)
        local font = self.font or love.graphics.getFont()
        font:setFilter("nearest", "nearest", 1)
        local text = love.graphics.newText(font, self.text)
        love.graphics.draw(text, (x + width / 2) / TrueResolution.scale - text:getWidth() / 2, (y + height / 2) / TrueResolution.scale - text:getHeight() / 2)
        love.graphics.setColor(1,1,1,1)
        love.graphics.scale(1 / TrueResolution.scale)
    end
    return self
end

return textlabel
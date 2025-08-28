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
    return self
end

return textlabel
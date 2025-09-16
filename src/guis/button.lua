---
--Boton basico de GUI.
--Usa componentes de Guis.
--@classmod button
--@see gui

local button = {}

---
--Crea un nuevo boton
--@param callback Funcion a llamar cuando se presiona el boton
--@return (button) Instancia del boton
function button.new(callback)
    local self = Guis.new()
    self.callback = callback
    self.whenPressing = function () end
    self.bgColor = {.5,.5,.5,1}
    self.type = "button"

    self.check = function(self, x, y, shouldCallback)
        if shouldCallback == nil then shouldCallback = true end
        local posX, posY = self:getRenderPosition()
        local width, height = self:getRenderSize()
        if x >= posX and x <= posX + width and y >= posY and y <= posY + height then
            if self.callback and shouldCallback then
                self.callback()
            end
            return true
        end
        return false
    end

    self.draw = function ()
        local x, y = self:getRenderPosition()
        local width, height = self:getRenderSize()
        love.graphics.setColor(self.bgColor or {1,1,1,1})
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(1,1,1,1)
    end

    return self
end

return button
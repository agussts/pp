---
--Crea un frame basico.
--Usa componentes de GUI.
--@classmod frame
--@see gui

local frame = {}

---
--Crea un nuevo frame
--@param position Posicion del frame
--@param size Tamaño del frame
--@return (frame) Instancia del frame
--@usage local myFrame = frame.new(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.3, 0.3))
function frame.new(position, size)
    local self = Guis.new()
    self.bgColor = {1,1,1,1}
    self.position = position or UDim2.zero
    self.size = size or UDim2.fromScale(.3, .3)
    self.type = "frame"   
    self.draw = function ()
        local x, y = self:getRenderPosition()
        local width, height = self:getRenderSize()
        love.graphics.setColor(self.bgColor or {1,1,1,1})
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(1,1,1,1)
    end
    return self
end

return frame
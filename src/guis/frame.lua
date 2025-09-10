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
function frame.new(position, size)
    local self = Guis.new()
    self.bgColor = {1,1,1,1}
    self.position = position or UDim2.zero
    self.size = size or UDim2.fromScale(.3, .3)
    self.type = "frame"    
    return self
end

return frame
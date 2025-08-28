---
-- Imagen que se muestra en el GUI
-- Usa componentes de GUI
--@classmod imagelabel
--@see gui

local imagelabel = {}

---
--Crea un nuevo imagelabel
--@param image Ruta de la imagen a mostrar
--@return (imagelabel) Instancia del imagelabel
--@usage local imgLabel = imagelabel.new("assets/sprites/myImage.png")
function imagelabel.new(image)
    local self = Guis.new()
    self.image = love.graphics.newImage(image)
    self.imageColor = {1, 1, 1, 1}
    self.type = "imagelabel"
    return self
end

return imagelabel
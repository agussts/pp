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
    self.shader = nil
    self._shaderUniforms = {}

    self.setShaderUniform = function(self, name, value)
        self._shaderUniforms[name] = value
    end

    self.draw = function ()
        local x, y = self:getRenderPosition()
        local width, height = self:getRenderSize()
        love.graphics.setColor(self.imageColor or {1,1,1,1})

        -- antes de draw:
        local prevShader = love.graphics.getShader()
        if self.shader then
            love.graphics.setShader(self.shader)
            if self._shaderUniforms then
                for i,v in pairs(self._shaderUniforms) do
                    self.shader:send(i, v)
                end
            end
        end
        love.graphics.draw(self.image, x, y, 0, width / self.image:getWidth(), height / self.image:getHeight())
        love.graphics.setColor(1,1,1,1)
        if self.shader then
            love.graphics.setShader(prevShader)
        end
    end
    return self
end

return imagelabel
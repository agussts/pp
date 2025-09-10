---
-- Unidad de medida 2D en la pantalla.
-- Se usa para definir posiciones y tamaños en el GUI.
-- Permite definir una parte proporcional al tamaño del padre (scale) y una parte fija en pixeles (offset).
--@classmod udim2
local udim2 = {}

udim2.__index = udim2

--Suma de dos UDim2
udim2.__add = function (self, other)
    return udim2.new(
        self.x.scale + other.x.scale,
        self.x.offset + other.x.offset,
        self.y.scale + other.y.scale,
        self.y.offset + other.y.offset
    )
end
--Resta de dos UDim2
udim2.__sub = function (self, other)
    return udim2.new(
        self.x.scale - other.x.scale,
        self.x.offset - other.x.offset,
        self.y.scale - other.y.scale,
        self.y.offset - other.y.offset
    )
end
--Multiplicacion de un UDim2 por un escalar
udim2.__mul = function (self, scalar)
    return udim2.new(
        self.x.scale * scalar,
        self.x.offset * scalar,
        self.y.scale * scalar,
        self.y.offset * scalar
    )
end
--Division de un escalar por un UDim2
udim2.__div = function (self, scalar)
    if scalar == 0 then
        error("Division by zero is not allowed.")   
    end
    return udim2.new(
        self.x.scale / scalar,
        self.x.offset / scalar,
        self.y.scale / scalar,
        self.y.offset / scalar
    )
end

--Formatea el UDmim2 a un string legible
udim2.__tostring = function (self)
    return string.format("UDim2(%.2f, %d, %.2f, %d)", self.x.scale, self.x.offset, self.y.scale, self.y.offset)
end

---
--Crea un nuevo UDim2
--@param xScale (number) Escala en X
--@param xOffset (number) Offset en X
--@param yScale (number) Escala en Y
--@param yOffset (number) Offset en Y
--@return (UDim2) Instancia del UDim2
--@usage local myUdim2 = UDim2.new(0.5, 10, 0.5, 10)
function udim2.new(xScale, xOffset, yScale, yOffset)
    local self = setmetatable({}, udim2)
    self.x = {}
    self.y = {}
    self.x.scale = xScale
    self.x.offset = xOffset
    self.y.scale = yScale
    self.y.offset = yOffset
    return self
end

udim2.zero = udim2.new(0, 0, 0, 0)

---
--Transforma la posicion de UDim2 a pixeles propocionalmente al tamaño del padre
--@param parentWidth (number) Ancho del padre en pixeles. Si no se proporciona, se usa el ancho de la pantalla.
--@param parentHeight (number) Alto del padre en pixeles. Si no se proporciona, se usa el alto de la pantalla.
--@return (number, number) Posicion en pixeles (x, y)
--@usage local x, y = myUdim2:toPixels()
function udim2:toPixels(parentWidth, parentHeight)
    if not parentWidth or not parentHeight then
        parentWidth = love.graphics.getWidth()
        parentHeight = love.graphics.getHeight()
    end
    local x = self.x.scale * parentWidth + self.x.offset
    local y = self.y.scale * parentHeight + self.y.offset
    return x, y
end

---
--Transforma la posicion de UDim2 a scale propocionalmente al tamaño del padre
--@param parentWidth (number) Ancho del padre en pixeles. Si no se proporciona, se usa el ancho de la pantalla.
--@param parentHeight (number) Alto del padre en pixeles. Si no se proporciona, se usa el alto de la pantalla.
--@return (number, number) Posicion en scale (x, y)
--@usage local x, y = myUdim2:toScale()
function udim2:toScale(parentWidth, parentHeight)
    if not parentWidth or not parentHeight then
        parentWidth = love.graphics.getWidth()
        parentHeight = love.graphics.getHeight()
    end
    local x =  self.x.offset / parentWidth + self.x.scale
    local y =  self.y.offset / parentHeight + self.y.scale
    return x, y
end

---
--Lo mismo que UDim2:toPixels() (Sin parametros)
--@return (number, number) Posicion en pixeles (x, y)
function udim2:transformToPixels()
    return self:toPixels()
end

---
--Lo mismo que UDim2.new(xScale, 0, yScale, 0)
--@param xScale (number) Escala en X
--@param yScale (number) Escala en Y
--@return (UDim2) Instancia del UDim2
--@usage local myUdim2 = UDim2.fromScale(0.5, 0.5)
function udim2.fromScale(xScale, yScale)
    return udim2.new(xScale, 0, yScale, 0)
end

---
--Lo mismo que UDim2.new(0, xOffset, 0, yOffset)
--@param xOffset (number) Offset en X
--@param yOffset (number) Offset en Y
--@return (UDim2) Instancia del UDim2
--@usage local myUdim2 = UDim2.fromOffset(10, 10)
function udim2.fromOffset(xOffset, yOffset)
    return udim2.new(0, xOffset, 0, yOffset)
end

---
--Clona el UDim2
--@usage local myUdim2Clone = myUdim2:Clone()
--@return (UDim2) Instancia clonada del UDim2
function udim2:Clone()
    return udim2.new(self.x.scale, self.x.offset, self.y.scale, self.y.offset)
end

---
--Interpolacion entre dos udim2.
--Lerp es una abreviacion de Linear Interpolation.
--@param goal (UDim2) El UDim2 al que se quiere llegar
--@param alpha (number) Un valor entre 0 y 1 que indica la interpolacion
--@usage local myUdim2 = myUdim2:Lerp(targetUdim2, 0.5)
function udim2:Lerp(goal, alpha)
    return udim2.new(
        self.x.scale + (goal.x.scale - self.x.scale) * alpha,
        self.x.offset + (goal.x.offset - self.x.offset) * alpha,
        self.y.scale + (goal.y.scale - self.y.scale) * alpha,
        self.y.offset + (goal.y.offset - self.y.offset) * alpha
    )
end

return udim2
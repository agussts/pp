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
    return tostring(self.x.scale), tostring(self.x.offset), tostring(self.y.scale), tostring(self.y.offset)
end

--Crea un nuevo UDim2
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

--Transforma la posicion de UDim2 a pixeles propocionalmente al tamaño del padre
function udim2:toPixels(parentWidth, parentHeight)
    if not parentWidth or not parentHeight then
        parentWidth = love.graphics.getWidth()
        parentHeight = love.graphics.getHeight()
    end
    local x = self.x.scale * parentWidth + self.x.offset
    local y = self.y.scale * parentHeight + self.y.offset
    return x, y
end

--Transforma la posicion de UDim2 a scale propocionalmente al tamaño del padre
function udim2:toScale(parentWidth, parentHeight)
    if not parentWidth or not parentHeight then
        parentWidth = love.graphics.getWidth()
        parentHeight = love.graphics.getHeight()
    end
    local x = self.x.offset / parentWidth + self.x.scale
    local y = self.y.offset / parentHeight + self.y.scale
    return x, y
end

--Transforma la posicion de UDim2 a pixeles en la pantalla
function udim2:transformToPixels()
    return self:toPixels()
end

--Lo mismo que UDim2.new(xScale, 0, yScale, 0)
function udim2.fromScale(xScale, yScale)
    return udim2.new(xScale, 0, yScale, 0)
end

--Lo mismo que UDim2.new(0, xOffset, 0, yOffset)
function udim2.fromOffset(xOffset, yOffset)
    return udim2.new(0, xOffset, 0, yOffset)
end

--Clona el UDim2
function udim2:Clone()
    return udim2.new(self.x.scale, self.x.offset, self.y.scale, self.y.offset)
end

--Interpolacion entre dos udim2.
--Alpha es un valor entre 0 y 1, donde 0 es el inicio y 1 es el final.
--Lerp es una abreviacion de Linear Interpolation.
function udim2:Lerp(goal, alpha)
    return udim2.new(
        self.x.scale + (goal.x.scale - self.x.scale) * alpha,
        self.x.offset + (goal.x.offset - self.x.offset) * alpha,
        self.y.scale + (goal.y.scale - self.y.scale) * alpha,
        self.y.offset + (goal.y.offset - self.y.offset) * alpha
    )
end

---------Metodos depcrecados---------
-------------------------------------

function udim2:offsetToScale()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    self.x.scale = self.x.scale + self.x.offset / screenWidth
    self.y.scale = self.y.scale + self.y.offset / screenHeight
    self.x.offset = 0
    self.y.offset = 0
    return self
end

function udim2:scaleToOffset()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    self.x.offset = self.x.scale * screenWidth
    self.y.offset = self.y.scale * screenHeight
    self.x.scale = 0
    self.y.scale = 0
    return self
end

return udim2
local gui = {}

local addedGuis = {}
local udim2 = require("guis.udim2")
--Crea un nuevo gui
function gui.new()
    local self = setmetatable({}, { __index = gui })
    self.position = udim2.new(0,0,0,0)
    self.size = udim2.new(0,0,0,0)
    self.visible = true
    self.anchorPoint = {0, 0}
    self.parent = nil
    self.zIndex = 0
    table.insert(addedGuis, self)
    return self
end

function gui:getRenderSize()
    if self.parent ~= nil then
        local parentWidth, parentHeight = self.parent:getRenderSize()
        local width, height = self.size:toPixels(parentWidth, parentHeight)
        return width, height
    else
        local width, height = self.size:transformToPixels()
        return width, height
    end
end

function gui:getRenderPosition()
    --Consigue posicion y tamaño en pixeles
    local parentX, parentY = 0, 0
    local parentWidth, parentHeight = love.graphics.getPixelDimensions()

    if self.parent ~= nil then
        parentX, parentY = self.parent:getRenderPosition()
        parentWidth, parentHeight = self.parent:getRenderSize()
    end
    local posX, posY = self.position:toPixels(parentWidth, parentHeight)

    posX = posX + parentX
    posY = posY + parentY
    
    --Aplica el anchor point en la posicion
    --Anchor point es un vector que indica el punto de donde se renderiza el gui
    -- {0, 0} es la esquina superior izquierda
    -- {1, 1} es la esquina inferior derecha
    -- {0.5, 0.5} es el centro del gui
    local sizeX, sizeY = self:getRenderSize()
    local finalX = posX - (self.anchorPoint[1] * sizeX)
    local finalY = posY - (self.anchorPoint[2] * sizeY)

    return finalX, finalY
end

--Da todos los guis añadidos
function gui.getAll()
    return addedGuis
end

function gui:Destroy()
    for i, v in ipairs(addedGuis) do
        if v == self then
            table.remove(addedGuis, i)
            break
        end
    end
end


return gui
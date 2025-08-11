---
--@module gui
--@classmod gui

local gui = {}

local addedGuis = {}
local udim2 = require("guis.udim2")

--Crea un nuevo gui
function gui.new()
    --Propiedades por defecto
    local self = setmetatable({}, { __index = gui })
    self.position = udim2.new(0,0,0,0)
    self.size = udim2.new(0,0,0,0)
    self.visible = true
    self.anchorPoint = {0, 0}
    self.zIndex = 0

    self.parent = nil
    self.children = {}

    --Propiedades de cache para la posicion y tamaño de renderizado
    self._renderX = 0
    self._renderY = 0
    self._renderWidth = 0
    self._renderHeight = 0

    table.insert(addedGuis, self)
    return self
end

function gui:isHovering()
    local mouseX, mouseY = love.mouse.getPosition()
    local x, y = self:getRenderPosition()
    local width, height = self:getRenderSize()

    return mouseX >= x and mouseX <= x + width and mouseY >= y and mouseY <= y + height
end

function gui:getRenderSize()
    return self._renderWidth, self._renderHeight
end

function gui:getRenderPosition()
    return self._renderX, self._renderY
end

function gui:setParent(parentGui)
    --Si el gui ya tiene parent, lo elimina de la lista de hijos del parent
    if self.parent then
        for i, child in ipairs(self.parent.children) do
            if child == self then
                table.remove(self.parent.children, i)
                break
            end
        end
    end

    --Añade el gui al nuevo parent
    self.parent = parentGui
    if parentGui then
        --Añade el gui a la lista de hijos del parent
        table.insert(parentGui.children, self)
    end
end

function gui:calculateRenderProperties()
    --Si no es visible, no calcula la posicion ni el tamaño
    --Esto es para evitar cálculos innecesarios y mejorar el rendimiento
    if not self.visible then
        self._renderX = 0
        self._renderY = 0
        self._renderWidth = 0
        self._renderHeight = 0
        return
    end

    --Define las dimensiones del padre y la posicion
    --Si no tiene padre, usa las dimensiones de la ventana
    local parentX, parentY = 0, 0
    local parentWidth, parentHeight = love.graphics.getDimensions()
    if self.parent then
        parentX, parentY = self.parent:getRenderPosition()
        parentWidth, parentHeight = self.parent:getRenderSize()
    end

    --Calcula el tamaño del gui relativo al padre
    local sizeX, sizeY = self.size:toPixels(parentWidth, parentHeight)
    self._renderWidth = sizeX
    self._renderHeight = sizeY

    --Calcula la posicion del gui relativo al padre
    local posX, posY = self.position:toPixels(parentWidth, parentHeight)
    self._renderX = posX + parentX
    self._renderY = posY + parentY

    --Aplica el anchorPoint para ajustar la posicion
    --El anchorPoint es un valor entre 0 y 1 que indica el punto de anclaje del gui
    self._renderX = self._renderX - (self.anchorPoint[1] * self._renderWidth)
    self._renderY = self._renderY - (self.anchorPoint[2] * self._renderHeight)

    --Hace recursivo para calcular las propiedades de renderizado de los hijos
    --Esto asegura que todos los guis hijos tengan sus propiedades de renderizado actualizadas
    if self.children then
        for _, child in ipairs(self.children) do
            child:calculateRenderProperties()
        end
    end
end

function gui.getTopLevelGuis()
    --Devuelve una lista de guis que no tienen padre
    local topLevelGuis = {}
    for _, gui in ipairs(addedGuis) do
        if gui.parent == nil then
            table.insert(topLevelGuis, gui)
        end
    end
    return topLevelGuis
end

--Da todos los guis añadidos
function gui.getAll()
    return addedGuis
end

--Destruye el gui
function gui:Destroy()
    for i, v in ipairs(addedGuis) do
        if v == self then
            table.remove(addedGuis, i)
            break
        end
    end
end

return gui
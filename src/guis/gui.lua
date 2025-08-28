---
-- Libreria de componentes de GUI
--@classmod gui

local gui = {}

local addedGuis = {}

---
--Crea un nuevo gui
--@return (gui) Instancia del gui
--@usage local baseGui = gui.new()
function gui.new()
    --Propiedades por defecto
    local self = setmetatable({}, { __index = gui })
    self.position = UDim2.new(0,0,0,0)
    self.size = UDim2.new(0,0,0,0)
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

---
-- Determina si el mouse esta sobre el gui
--@return (boolean) Si el mouse esta sobre el gui
--@usage 
-- if gui:isHovering() then 
--  print("El mouse esta sobre el gui")
-- end
function gui:isHovering()
    local mouseX, mouseY = love.mouse.getPosition()
    local x, y = self:getRenderPosition()
    local width, height = self:getRenderSize()

    return mouseX >= x and mouseX <= x + width and mouseY >= y and mouseY <= y + height
end

---
--Devuelve el tamaño del GUI al que se le tiene que renderizar
--@usage local width, height = gui:getRenderSize()
function gui:getRenderSize()
    return self._renderWidth, self._renderHeight
end

---
--Devuelve la posicion del GUI al que se le tiene que renderizar
--@usage local x, y = gui:getRenderPosition()
function gui:getRenderPosition()
    return self._renderX, self._renderY
end

---
-- Establece el padre del GUI
--@param parentGui (gui) El nuevo padre del GUI
--@usage gui:setParent(nuevoPadre)
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

---
-- Calcula las propiedades de renderizado del GUI
--@usage gui:calculateRenderProperties()
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

---
-- Devuelve una lista de guis que no tienen padre
--@return (table) Una lista de guis que no tienen padre
--@usage local topLevelGuis = gui.getTopLevelGuis()
function gui.getTopLevelGuis()
    local topLevelGuis = {}
    for _, gui in ipairs(addedGuis) do
        if gui.parent == nil then
            table.insert(topLevelGuis, gui)
        end
    end
    return topLevelGuis
end

--- Devuelve todos los guis añadidos
--@return (table) Una lista de todos los guis añadidos
--@usage local allGuis = gui.getAll()
function gui.getAll()
    return addedGuis
end

---
--Destruye el gui
--@usage gui:Destroy()
function gui:Destroy()
    for i, v in ipairs(addedGuis) do
        if v == self then
            table.remove(addedGuis, i)
            break
        end
    end
end

return gui
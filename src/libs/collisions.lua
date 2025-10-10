---
-- Modulo de colisiones para detectar choques entre objetos.
--@classmod collisions


local collisions = {}

local addedCollisions = {}
local types = {
    "box",
    "hitbox"
}
local defaultVisualized = true -- TEMPORAL: CAMBIAR A false DESPUES

--- Crea una nueva colisión
--@param type El tipo de colision, puede ser "box" o "hitbox"
--@param enabled Si la colision empieza activada
--@param onHit La funcion que se llama cuando la colision ocurre
--@usage local myCollision = collisions.new("box", true, function(otherCollider)
--@return El collider creado
collisions.new = function(type, enabled)
    local self = setmetatable({}, { __index = collisions })

    self.position = UDim2.new(0, 0, 0, 0)
    self.size = UDim2.new(0, 0, 0, 0)
    self.speedX = 0
    self.speedY = 0
    self.visualized = defaultVisualized
    self.enabled = enabled ~= false
    self.onHit = Signal.new()
    self.color = {1, 1, 1, 1}
    self.link = nil
    self.anchor = {0,0}

    self.tags = {}

    local typeFound = false
    if type == "hitbox" then
        self.color = {1, 0, 0, 1} 
        table.insert(self.tags, "hitbox")
        typeFound = true
    elseif type == "box" then
        self.color = {1, 1, 1, 1} 
        table.insert(self.tags, "box")
        typeFound = true
    end

    if typeFound then
        self.type = type
        table.insert(addedCollisions, self)
        return self
    end

    error("Invalid collision type: " .. tostring(type) .. ". Valid types are: " .. table.concat(types, ", "))
end

function collisions:_getRenderRect()
    local x, y = self.position:toPixels()
    local w, h = self.size:toPixels()
    x = x - self.anchor[1] * w
    y = y - self.anchor[2] * h
    return x, y, w, h
end

---
--Añade una etiqueta al collider
--@param tagName Nombre de la etiqueta a añadir
--@usage myCollision:AddTag("nuevoTag")
function collisions:AddTag(tagName)
    table.insert(self.tags, tagName)
end

---
-- Elimina una etiqueta del collider
--@param tagName Nombre de la etiqueta a quitar
--@usage myCollision:RemoveTag("nuevoTag")
function collisions:RemoveTag(tagName)
    for i,v in pairs(self.tags) do
        if v == tagName then
            table.remove(self.tags, i)
            break
        end
    end
end

---
--Remplaza una etiqueta por otra
--@param tagToReplace Nombre de la etiqueta a reemplazar
--@param replacement Nombre de la nueva etiqueta
--@usage myCollision:ReplaceTag("antiguoTag", "nuevoTag")
function collisions:ReplaceTag(tagToReplace, replacement)
    self:RemoveTag(tagToReplace)
    self:AddTag(replacement)
end

---
-- Devuelve true o false dependiendo si el colider tiene tag pasado
--@param tag Tag a revisar
--@return (boolean) true o false dependiendo de si tiene el tag
function collisions:HasTag(tag)
    for _,v in pairs(self.tags) do
        if v == tag then return true end
    end
    return false
end

---
--Cambia el tipo de colision de un colider
--@param typeName El nuevo tipo de colision, puede ser "box" o "hitbox"
--@usage myCollision:ChangeType("hitbox")
function collisions:ChangeType(typeName) 
    local typeFound = false
    if typeName == "hitbox" then
        self.color = {1, 0, 0, 1} 
        typeFound = true
    elseif typeName == "box" then
        self.color = {1, 1, 1, 1} 
        typeFound = true
    end
    if typeFound then
        self:ReplaceTag(self.type, typeName)
        self.type = typeName
        return
    end

    error("Invalid collision type: " .. tostring(type) .. ". Valid types are: " .. table.concat(types, ", "))
end

---
--Consigue todas las colisiones existentes
--@return Tabla de colisiones
--@usage local allCollisions = collisions.getCollisions()
collisions.getCollisions = function()
    return addedCollisions
end

-- Activa/desactiva el render por defecto para colliders NUEVOS
function collisions.setDefaultVisualized(flag)
    defaultVisualized = not not flag
end

-- Consulta del valor global actual
function collisions.getDefaultVisualized()
    return defaultVisualized
end


---
--Actualiza la posicion del collider segun su velocidad
--@param dt Delta time
--@usage myCollision:UpdateSpeed(dt)
function collisions:UpdateSpeed(dt)
    if not self.enabled then return end
    local x, y = self.position:toPixels()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local sx = screenWidth / Config.IdealResolution.width
    local sy = screenHeight / Config.IdealResolution.height
    x = x + self.speedX * sx * dt
    y = y + self.speedY * sy * dt
    self.position = UDim2.fromOffset(x, y)
    self.position = UDim2.fromScale(self.position:toScale())
end

---
-- Consigue la direccion del collider.
--@return Velocidad X e Y del colider.
--@usage local speedX, speedY = myCollision:getDirection()
function collisions:getDirection()
    return self.speedX, self.speedY
end

---
--Destruye el colider
--@usage myCollision:Destroy()
function collisions:Destroy()
    for i,v in pairs(addedCollisions) do
        if v == self then
            table.remove(addedCollisions, i)
            break
        end
    end
    for _,v in pairs(self) do
        v = nil
    end
    self = nil
end

---
--Consigue todas las colisiones que estan adentro del colider.
--Los "box" colider son los unicos que son repelidos al chocarse con otro, en otras palabras, no se atraviesan.
--Los "hitbox" colider no chocan con otros, son solo areas de deteccion.
--@return Tabla con todas las colisiones entro del colider.
--@usage local hitting = myHitbox:check()
--@usage myCollision:check()
function collisions:check()
    if not self.enabled then return end
    local hitting = {}
    local x, y, width, height = self:_getRenderRect()
    for _, otherCollider in pairs(addedCollisions) do
        if otherCollider == self or not otherCollider.enabled then goto continue end      
        local otherX, otherY, otherWidth, otherHeight = otherCollider:_getRenderRect()
        if x <= otherX + otherWidth
        and x + width >= otherX
        and y <= otherY + otherHeight
        and y + height >= otherY then
            table.insert(hitting, otherCollider)
            self.onHit:Fire(otherCollider)
            if self.type == "box" and otherCollider.type == "box" then
                -- filtro: si cualquiera de los dos decide NO bloquear al otro, no se resuelve el empuje
                local blockA = (not self.blockFilter) or self.blockFilter(self, otherCollider)
                local blockB = (not otherCollider.blockFilter) or otherCollider.blockFilter(otherCollider, self)
                if blockA and blockB then
                    local dx = math.min(x + width, otherX + otherWidth) - math.max(x, otherX)
                    local dy = math.min(y + height, otherY + otherHeight) - math.max(y, otherY)
                    if dx <= 0 or dy <= 0 then goto continue end

                    if dx < dy then
                        if x < otherX then
                            x = otherX - width
                        else
                            x = otherX + otherWidth
                        end
                    else
                        if y < otherY then
                            y = otherY - height
                        else
                            y = otherY + otherHeight
                        end
                        self.speedY = 0 
                    end
                end
            end
        end
        ::continue::
    end
    local storeX = x + self.anchor[1] * width
    local storeY = y + self.anchor[2] * height
    self.position = UDim2.fromOffset(storeX, storeY)
    self.position = UDim2.fromScale(self.position:toScale())
    return hitting
end

function collisions.clearAll()
    for i = #addedCollisions, 1, -1 do
        addedCollisions[i]:Destroy()
    end
end

function collisions:draw()
    if self.visualized and self.enabled then
        local x, y, width, height = self:_getRenderRect()
        love.graphics.setColor(self.color)
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return collisions


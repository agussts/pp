---
-- Modulo de colisiones para detectar choques entre objetos.
--@classmod collisions

local udim2 = require "src.guis.udim2"
local collisions = {}

local addedCollisions = {}
local types = {
    "box",
    "hitbox"
}
--- Crea una nueva colisión
--@param type El tipo de colision, puede ser "box" o "hitbox"
--@param enabled Si la colision empieza activada
--@param onHit La funcion que se llama cuando la colision ocurre
--@usage local myCollision = collisions.new("box", true, function(otherCollider)
--@return collider El collider creado
collisions.new = function(type, enabled, onHit)
    local self = setmetatable({}, { __index = collisions })

    self.position = udim2.new(0, 0, 0, 0)
    self.size = udim2.new(0, 0, 0, 0)
    self.speedX = 0
    self.speedY = 0
    self.visualized = false
    self.enabled = enabled or true
    self.onHit = onHit or function () end
    self.color = {1, 1, 1, 1}
    self.link = nil

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
--@return table Tabla de colisiones
--@usage local allCollisions = collisions.getCollisions()
collisions.getCollisions = function()
    return addedCollisions
end

---
--Actualiza la posicion del collider segun su velocidad
--@param dt Delta time
--@usage myCollision:UpdateSpeed(dt)
function collisions:UpdateSpeed(dt)
    local x, y = self.position:transformToPixels()
    local screenWidth, screenHeight = love.graphics.getPixelDimensions()
    screenWidth = screenWidth / 640
    screenHeight = screenHeight / 360
    x = x + self.speedX * screenWidth * dt
    y = y + self.speedY * screenHeight * dt
    self.position = udim2.new(0, x, 0, y)
    self.position:offsetToScale()
end

---
-- Consigue la direccion del collider.
--@return number, number Velocidad X e Y del colider.
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
    return
end

---
--Consigue todas las colisiones que estan adentro del colider.
--Los "box" colider son los unicos que son repelidos al chocarse con otro, en otras palabras, no se atraviesan.
--Los "hitbox" colider no chocan con otros, son solo areas de deteccion.
--@return table Tabla con todas las colisiones entro del colider.
--@usage local hitting = myHitbox:check()
--@usage myCollision:check()
function collisions:check()
    if not self.enabled then return end
    local hitting = {}
    for _, otherCollider in pairs(addedCollisions) do
        if otherCollider == self then goto continue end

        local x, y = self.position:transformToPixels()
        local width, height = self.size:transformToPixels()
        local otherX, otherY = otherCollider.position:transformToPixels()
        local otherWidth, otherHeight = otherCollider.size:transformToPixels()
        if x <= otherX + otherWidth
        and x + width >= otherX
        and y <= otherY + otherHeight
        and y + height >= otherY then
            table.insert(hitting, otherCollider)
            self.onHit(otherCollider)
            if self.type == "box" and otherCollider.type == "box" then
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
        self.position = udim2.new(0, x, 0, y)
        self.position:offsetToScale()
        ::continue::
    end
    return hitting
end

return collisions


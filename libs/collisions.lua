local collisions = {}

local addedCollisions = {}
local types = {
    "box",
    "hitbox"
}

collisions.new = function(type, x, y, width, height, enabled, onHit)
    local self = setmetatable({}, { __index = collisions })

    self.x = x
    self.y = y
    self.width = width
    self.height = height
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

function collisions:AddTag(tagName)
    table.insert(self.tags, tagName)
end

function collisions:RemoveTag(tagName)
    for i,v in pairs(self.tags) do
        if v == tagName then
            table.remove(self.tags, i)
            break
        end
    end
end

function collisions:ReplaceTag(tagToReplace, replacement)
    self:RemoveTag(tagToReplace)
    self:AddTag(replacement)
end

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

collisions.getCollisions = function()
    return addedCollisions
end

function collisions:UpdateSpeed(dt)
    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt
end

function collisions:getDirection()
    return self.speedX, self.speedY
end

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

function collisions:check()
    if not self.enabled then return end
    local hitting = {}
    for _, otherCollider in pairs(addedCollisions) do
        if otherCollider == self then goto continue end

        if self.x <= otherCollider.x + otherCollider.width 
        and self.x + self.width >= otherCollider.x
        and self.y <= otherCollider.y + otherCollider.height 
        and self.y + self.height >= otherCollider.y then
            table.insert(hitting, otherCollider)
            self.onHit(otherCollider)
            if self.type == "box" and otherCollider.type == "box" then
                local dx = math.min(self.x + self.width, otherCollider.x + otherCollider.width) - math.max(self.x, otherCollider.x)
                local dy = math.min(self.y + self.height, otherCollider.y + otherCollider.height) - math.max(self.y, otherCollider.y)
                if dx <= 0 or dy <= 0 then goto continue end

                if dx < dy then
                    if self.x < otherCollider.x then
                        self.x = otherCollider.x - self.width
                    else
                        self.x = otherCollider.x + otherCollider.width
                    end
                else
                    if self.y < otherCollider.y then
                        self.y = otherCollider.y - self.height
                    else
                        self.y = otherCollider.y + otherCollider.height
                    end
                    self.speedY = 0 
                end
            end
        end
        ::continue::
    end
    return hitting
end

return collisions


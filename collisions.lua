local collisions = {}

local addedCollisions = {}
local types = {
    "box",
    "circle",
    "hitbox"
}


collisions.new = function(type, x, y, width, height)
    local self = setmetatable({}, { __index = collisions })

    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speedX = 0
    self.speedY = 0
    self.visualized = false

    self.tags = {}
    for i,v in pairs(types) do
        if v == type then
            self.type = type
            table.insert(addedCollisions, self)
            print("addedCollisions")
            return self
        end
    end
    error("Invalid collision type: " .. tostring(type) .. ". Valid types are: " .. table.concat(types, ", "))
end

collisions.getCollisions = function()
    return addedCollisions
end

function collisions:UpdateSpeed(dt)
    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY  * dt
end

function collisions:check()
    local hitting = {}
    for _, otherCollider in pairs(addedCollisions) do
        if otherCollider == self then goto continue end

        if self.x <= otherCollider.x + otherCollider.width 
        and self.x + self.width >= otherCollider.x
        and self.y <= otherCollider.y + otherCollider.height
        and self.y + self.height >= otherCollider.y then
            table.insert(hitting, otherCollider)
            if self.type == "box" and otherCollider.type == "box" then
                self.x = self.x + self.speedX * -1
                self.y = self.y + self.speedY * -1
                self.speedX = 0
                self.speedY = 0
            end
        end
        ::continue::
    end
    return hitting
end


return collisions


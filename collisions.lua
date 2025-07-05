local collisions = {}

local Vector2 = require("Vector2")

local addedCollisions = {}
local types = {
    "box",
    "hitbox"
}
local function samesign(a, b)
    return (a >= 0 and b >= 0) or (a < 0 and b < 0)
end

collisions.new = function(type, x, y, width, height)
    local self = setmetatable({}, { __index = collisions })

    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.speedX = 0
    self.speedY = 0
    self.visualized = false
    self.colliding = false

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
    self.y = self.y + self.speedY * dt
end

function collisions:check(dt)
    local hitting = {}
    for _, otherCollider in pairs(addedCollisions) do
        if otherCollider == self then goto continue end

        if self.x <= otherCollider.x + otherCollider.width 
        and self.x + self.width >= otherCollider.x
        and self.y <= otherCollider.y + otherCollider.height 
        and self.y + self.height >= otherCollider.y then
            table.insert(hitting, otherCollider)
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


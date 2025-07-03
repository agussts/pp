local collisions = {}

local addedCollisions = {}

collisions.newBox = function(x, y, width, height)
    local self = setmetatable({}, { __index = collisions })

    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.collisionType = "box"
    table.insert(addedCollisions, self)

    return self
end

function collisions:check()
    local hitting = {}

    for _, otherCollider in pairs(addedCollisions) do
        if self.x < otherCollider.x + otherCollider.width and
           self.x + self.width > otherCollider.x and
           self.y < otherCollider.y + otherCollider.height and
           self.y + self.height > otherCollider.y then
            table.insert(hitting, otherCollider)
        end
    end

    return hitting
end


return collisions


local udim2 = {}

udim2.__index = udim2
udim2.__add = function ()
    
end

function udim2.new(xScale, xOffset, yScale, yOffset)
    local self = setmetatable({}, udim2)
    self.x.scale = xScale
    self.x.offset = xOffset
    self.y.scale = yScale
    self.y.offset = yOffset
end

return udim2
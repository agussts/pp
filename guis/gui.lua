local gui = {}

local addedGuis = {}

function gui.new(x, y, width, height, scale)
    local self = setmetatable({}, { __index = gui })
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 100
    self.visible = true
    table.insert(addedGuis, self)
    return self
    
end

function gui.getAll()
    return addedGuis
end


return gui
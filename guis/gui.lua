local gui = {}

local addedGuis = {}
local udim2 = require("guis.udim2")
--Crea un nuevo gui
function gui.new()
    local self = setmetatable({}, { __index = gui })
    self.position = udim2.new(0,0,0,0)
    self.size = udim2.new(0,0,0,0)
    self.visible = true
    table.insert(addedGuis, self)
    return self
end

--Da todos los guis añadidos
function gui.getAll()
    return addedGuis
end


return gui
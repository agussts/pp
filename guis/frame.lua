---
--@classmod frame
--@see gui

local frame = {}

local gui = require("guis.gui")

function frame.new(position, size)
    local self = gui.new()
    self.bgColor = {1,1,1,1}
    self.type = "frame"    
    return self
end

return frame
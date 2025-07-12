local button = {}

local gui = require("guis.gui")

function button.new(callback)
    local self = gui.new()
    self.callback = callback
    self.bgColor = {.5,.5,.5,1}
    self.type = "button"
    return self
end

return button
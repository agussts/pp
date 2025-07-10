local button = {}

local gui = require("guis.gui")

function button.new(text, x, y, width, height, callback)
    local self = gui.new(x, y, width, height)
    self.text = text
    self.textColor = {1,1,1,1}
    self.callback = callback
    self.bgColor = {.5,.5,.5,1}
    self.type = "button"
    return self
end

return button
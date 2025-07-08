local button = {}

local gui = require("libs.guis.gui")

function button.new(text, x, y, width, height, callback)
    local self = gui.new(x, y, width, height)
    self.text = text
    self.callback = callback
    self.type = "button"
    return self
end

return button
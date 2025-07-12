local textlabel = {}

local gui = require("guis.gui")

function textlabel.new(text)
    local self = gui.new()
    self.text = text
    self.textColor = {1,1,1,1}
    return self
end

return textlabel
---
--@classmod textlabel
--@see gui

local textlabel = {}

local gui = require("src.guis.gui")

function textlabel.new(text)
    local self = gui.new()
    self.text = text
    self.textColor = {1,1,1,1}
    self.font = love.graphics.getFont()
    self.type = "textlabel"
    return self
end

return textlabel
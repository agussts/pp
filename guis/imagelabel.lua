---
--@classmod imagelabel
--@see gui

local imagelabel = {}

local gui = require("guis.gui")

function imagelabel.new(image)
    local self = gui.new()
    self.image = love.graphics.newImage(image)
    self.imageColor = {1, 1, 1, 1}
    self.type = "imagelabel"
    return self
end

return imagelabel
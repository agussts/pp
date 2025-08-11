---
--@module button
--@extends gui
--@classmod button

local button = {}

local gui = require("guis.gui")

function button.new(callback)
    local self = gui.new()
    self.callback = callback
    self.whenPressing = function () end
    self.bgColor = {.5,.5,.5,1}
    self.type = "button"

    self.check = function(self, x, y, shouldCallback)
        if shouldCallback == nil then shouldCallback = true end
        local posX, posY = self:getRenderPosition()
        local width, height = self:getRenderSize()
        if x >= posX and x <= posX + width and y >= posY and y <= posY + height then
            if self.callback and shouldCallback then
                self.callback()
            end
            return true
        end
        return false
    end

    return self
end

return button
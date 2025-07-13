local button = {}

local gui = require("guis.gui")

function button.new(callback)
    local self = gui.new()
    self.callback = callback
    self.bgColor = {.5,.5,.5,1}
    self.type = "button"

    self.check = function(self, x, y)
        local posX, posY = self:getRenderPosition()
        local width, height = self:getRenderSize()
        if x >= posX and x <= posX + width and y >= posY and y <= posY + height then
            if self.callback then
                self.callback()
            end
            return true
        end
        return false
    end

    return self
end

return button
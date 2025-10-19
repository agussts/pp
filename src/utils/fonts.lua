local Fonts = {}

Fonts.VT323 = love.graphics.newFont("assets/fonts/VT323-Regular.ttf", 28)
Fonts.VT323:setFilter("nearest", "nearest", 1)

Fonts.VT323small = love.graphics.newFont("assets/fonts/VT323-Regular.ttf", 18)
Fonts.VT323small:setFilter("nearest", "nearest", 1)

return Fonts
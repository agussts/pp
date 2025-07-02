love.load = function ()
    player = require("player")
    sprite = love.graphics.newImage("ballininsanty.png")
    player = player.new(sprite)
    love.window.setMode(1280, 720, {
        resizable = false,
        vsync = true,
    })
end

love.keypressed = function (key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        local fullscreen = not love.window.getFullscreen()
        love.window.setFullscreen(fullscreen)
    end
end

love.update = function (dt)
    player:UpdateInput()
end

love.draw = function ()
    love.graphics.draw(sprite, player.x, player.y)
end
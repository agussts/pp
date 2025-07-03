love.load = function ()
    PlayerModule = require("player")
    ColliderModule = require("collider")

    Sprite = love.graphics.newImage("ballininsanty.png")
    Player = PlayerModule.new(Sprite)

    Collider = ColliderModule.newBox()
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
    Player:UpdateInput(dt)
     if Player.x < 0 then Player.x = 0 end
        if Player.y < 0 then Player.y = 0 end
        if Player.x > love.graphics.getWidth() - Player.sprite:getWidth() then
            Player.x = love.graphics.getWidth() - Player.sprite:getWidth()
        end
        if Player.y > love.graphics.getHeight() - Player.sprite:getHeight() then
            Player.y = love.graphics.getHeight() - Player.sprite:getHeight()
        end
end

love.draw = function ()
    love.graphics.draw(Sprite, Player.x, Player.y)
    love.graphics.print("Player Position: (" .. Player.x .. ", " .. Player.y .. ")", 10, 10)
end
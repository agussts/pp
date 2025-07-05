love.load = function ()
    PlayerModule = require("player")
    ColliderModule = require("collisions")

    Sprite = love.graphics.newImage("ballininsanty.png")
    Player = PlayerModule.new(Sprite)

    Collider = ColliderModule.new("box", 0,80, 100, 100)
    Collider2 = ColliderModule.new("box", 200,80, 100, 100)
    Touching = false

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
    Collider.speedX = 100
    Collider2.speedX = -100

    for i,v in pairs(ColliderModule.getCollisions()) do
        v:UpdateSpeed(dt)
        v:check()
    end

    Player:UpdateInput()
    --[[ if Player.x < 0 then Player.x = 0 end
        if Player.y < 0 then Player.y = 0 end
        if Player.x > love.graphics.getWidth() - Player.sprite:getWidth() then
            Player.x = love.graphics.getWidth() - Player.sprite:getWidth()
        end
        if Player.y > love.graphics.getHeight() - Player.sprite:getHeight() then
            Player.y = love.graphics.getHeight() - Player.sprite:getHeight()
        end]]
end

love.draw = function ()
    love.graphics.draw(Sprite, Player.collision.x, Player.collision.y)
    love.graphics.print(tostring(Touching), 10, 30)
    love.graphics.rectangle("line", Collider.x, Collider.y, Collider.width, Collider.height)
    love.graphics.rectangle("line", Collider2.x, Collider2.y, Collider2.width, Collider2.height)
    love.graphics.print("Collider Position: (" .. Collider.x .. ", " .. Collider.y .. ")", 10, 70)
    love.graphics.print("Collider2 Position: (" .. Collider2.x .. ", " .. Collider2.y .. ")", 10, 50)
    love.graphics.print("Player Position: (" .. Player.collision.x .. ", " .. Player.collision.y .. ")", 10, 10)
    love.graphics.print(tostring(Collider2.type), 10, 90)
    for i,v in pairs(ColliderModule.getCollisions()) do
        if v.visualized then
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
        end
    end
end
love.load = function ()
    PlayerModule = require("libs.player")
    ColliderModule = require("libs.collisions")
    GunModule = require("Guns.inf")
    Gun = GunModule.new()
    Timer = require("libs.timer")

    Player = PlayerModule.new("ballininsanty.png")

    Collider = ColliderModule.new("box", 500,80, 100, 100)
    --local collidersHit = {}
    Projectile = ColliderModule.new("hitbox", 0, 80, 50, 50, true, function(collider)
        for i,v in pairs(collider.tags) do
            if v == "projectile" then return end
        end
        --for i,v in pairs(collidersHit) do
        --    if v == collider then return end
        --end
       -- table.insert(collidersHit, collider)
        print("Hit collider at: (" .. collider.x .. ", " .. collider.y .. ")")
        Projectile:Destroy()
    end)
    Projectile.tags = {"projectile"}
    Projectile.speedX = 200
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
    Timer.update(dt)
    for _,v in pairs(ColliderModule.getCollisions()) do
        v.visualized = true
        v:UpdateSpeed(dt)
        if v.enabled then
            v:check()
        end
    end

    if Gun.lastFireTime > 0 then
        Gun.lastFireTime = Gun.lastFireTime - dt
    else
        Gun.lastFireTime = 0
    end
    if love.mouse.isDown(1) then
        Gun:Fire(Player.collision.x, Player.collision.y)
    end

    Player:UpdateInput()
end

love.draw = function ()
    love.graphics.draw(Player.sprite, Player.collision.x, Player.collision.y)
    love.graphics.print(tostring(Touching), 10, 30)
    love.graphics.print("Collider Position: (" .. Collider.x .. ", " .. Collider.y .. ")", 10, 70)
    love.graphics.print("Player Position: (" .. Player.collision.x .. ", " .. Player.collision.y .. ")", 10, 10)
    love.graphics.print("Gun Ammo: " .. Gun.ammo, 10, 50)
    for i,v in pairs(ColliderModule.getCollisions()) do
        if v.visualized then
            love.graphics.setColor(v.color)
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
            love.graphics.setColor(1,1,1,1)
        end
    end
end
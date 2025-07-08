love.load = function ()
    PlayerModule = require("libs.player")
    EnemyModule = require("libs.enemy")
    ColliderModule = require("libs.collisions")
    GunModule = require("Guns.dev")
    Gun = GunModule.new()
    Timer = require("libs.timer")

    Resolutions = {
        {width = 640, height = 360},
        {width = 1280, height = 720},
        {width = 1920, height = 1080},
        {width = 2560, height = 1440}
    }
    if love.filesystem.getInfo("%APPDATA%/LOVE/pp/config.ini") == nil then
        love.filesystem.newFile("config.ini")
    end
    Config = love.filesystem.lines("config.ini")
    ConfigTable = {}
    for line in Config do
        local i, v = line:match("^(%S+) = (%S+)$") 
        if v == "true" then 
            v = true
        elseif v == "false" then
            v = false
        elseif tonumber(v) ~= nil then
            v = tonumber(v)
        end
        ConfigTable[i] = v
    end
    Player = PlayerModule.new("assets/sprites/ballininsanty.png", 80, 80)
    Enemy = EnemyModule.new("assets/sprites/slungus.png", 80, 80)
    Enemy.collision.x = 500
    Enemy.collision.y = 100

    Collider = ColliderModule.new("box", 500,80, 100, 100)
    Projectile = ColliderModule.new("hitbox", 0, 80, 50, 50, true, function(collider)
        for i,v in pairs(collider.tags) do
            if v == "projectile" then return end
        end
        print("Hit collider at: (" .. collider.x .. ", " .. collider.y .. ")")
        Projectile:Destroy()
    end)
    Projectile.tags = {"projectile"}
    Projectile.speedX = 200
    
    love.audio.setVolume(ConfigTable.VOLUME)
    local resolution = Resolutions[ConfigTable.RESOLUTION]
    love.window.setMode(resolution.width, resolution.height, {
        borderless = ConfigTable.BORDERLESS,
        resizable = false,
        vsync = ConfigTable.VSYNC,
    })
end


love.keypressed = function (key)
    local lines = {}
    if key == "escape" then
        for i,v in pairs(ConfigTable) do
            table.insert(lines, i .. " = " .. tostring(v))
        end
        love.filesystem.write("config.ini", table.concat(lines, "\n"))
        love.audio.stop()
        love.timer.sleep(.1)
        love.event.quit()
    elseif key == "f11" then
        ConfigTable.BORDERLESS = not ConfigTable.BORDERLESS
        love.window.setMode(1280, 720, {
            borderless = ConfigTable.BORDERLESS,
            resizable = false,
            vsync = ConfigTable.VSYNC
        })
    elseif key == Player.otherControls.dash then
        Player.speed = Player.speed * 3
        Player.dashing = true
        Timer.after(0.5, function()
            Player.speed = Player.speed / 3
        end)
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
    love.graphics.draw(Player.sprite, Player.collision.x, Player.collision.y, 0 , Player.collision.width / Player.sprite:getWidth(), Player.collision.height / Player.sprite:getHeight())
    for _,v in pairs(EnemyModule.getEnemies()) do
        love.graphics.draw(v.sprite, v.collision.x, v.collision.y, 0, v.collision.width / v.sprite:getWidth(), v.collision.height / v.sprite:getHeight())
    end
    love.graphics.print("Player Health: " .. Player.health, 10, 110)
    love.graphics.print("Enemy Health: " .. Enemy.health, 10, 90)
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
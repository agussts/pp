love.load = function ()
    PlayerModule = require("libs.player")
    EnemyModule = require("libs.enemy")
    ColliderModule = require("libs.collisions")
    GunModule = require("Guns.dev")
    Gun = GunModule.new()
    Timer = require("libs.timer")
    Guis = require("libs.guis.gui")


    local configDefaultData = {
        BORDERLESS = false,
        VSYNC = true,
        RESOLUTION = 4,
        VOLUME = 1,
    }

    Resolutions = {
        {width = 16, height = 9, scale = 0.025},
        {width = 320, height = 180, scale = 0.5},
        {width = 640, height = 360, scale = 1},
        {width = 1280, height = 720, scale = 2},
        {width = 1920, height = 1080, scale = 3},
    }
    if love.filesystem.getInfo("config.ini") == nil then
        local data = ""
        for i,v in pairs(configDefaultData) do
            data = data..tostring(i).." = "..tostring(v).."\n"
        end
        love.filesystem.write("config.ini", data)
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
    Player = PlayerModule.new("assets/sprites/ballininsanty.png", 40, 40)
    Enemy = EnemyModule.new("assets/sprites/slungus.png", 40, 40)
    Enemy.collision.x = 500
    Enemy.collision.y = 100

    Collider = ColliderModule.new("box", 250, 40, 50, 50)
    Projectile = ColliderModule.new("hitbox", 0, 40, 25, 25, true, function(collider)
        for i,v in pairs(collider.tags) do
            if v == "projectile" then return end
        end
        print("Hit collider at: (" .. collider.x .. ", " .. collider.y .. ")")
        Projectile:Destroy()
    end)
    Projectile.tags = {"projectile"}
    Projectile.speedX = 200
    
    love.audio.setVolume(ConfigTable.VOLUME)
    function UpdateWindow()
        TrueResolution = Resolutions[ConfigTable.RESOLUTION]
        love.window.setMode(TrueResolution.width, TrueResolution.height, {
            borderless = ConfigTable.BORDERLESS,
            resizable = false,
            vsync = ConfigTable.VSYNC,
        })
    end
    UpdateWindow()
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
        UpdateWindow()
    elseif key == "up" then
        ConfigTable.RESOLUTION = ConfigTable.RESOLUTION + 1
        if ConfigTable.RESOLUTION > #Resolutions then
            ConfigTable.RESOLUTION = 1
        end
        UpdateWindow()
    elseif key == "down" then
        ConfigTable.RESOLUTION = ConfigTable.RESOLUTION - 1
        if ConfigTable.RESOLUTION < 1 then
            ConfigTable.RESOLUTION = #Resolutions
        end
        UpdateWindow()
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
        Gun:Fire(Player.collision.x, Player.collision.y, TrueResolution.scale)
    end

    Player:UpdateInput()
end

love.draw = function ()
    love.graphics.setDefaultFilter("nearest")
    love.graphics.scale(TrueResolution.scale)
    love.graphics.draw(Player.sprite, Player.collision.x, Player.collision.y, 0 , Player.collision.width / Player.sprite:getWidth(), Player.collision.height / Player.sprite:getHeight())
   
    for _,v in pairs(EnemyModule.getEnemies()) do
        love.graphics.draw(v.sprite, v.collision.x, v.collision.y, 0, v.collision.width / v.sprite:getWidth(), v.collision.height / v.sprite:getHeight())
    end

    for i,self in pairs(Guis.getAll()) do
        if self.type == "button" then
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.print(self.text, self.x, self. y)
        end
    end

    love.graphics.print("Player Health: " .. Player.health, 5, 15, 0, .5, .5)
    love.graphics.print("Enemy Health: " .. Enemy.health, 5, 45, 0, .5, .5)
    love.graphics.print("Collider Position: (" .. Collider.x .. ", " .. Collider.y .. ")", 5, 35, 0, .5, .5)
    love.graphics.print("Player Position: (" .. Player.collision.x .. ", " .. Player.collision.y .. ")", 5, 5, 0, .5, .5)
    love.graphics.print("Gun Ammo: " .. Gun.ammo, 5, 25, 0, .5, .5)
    for i,v in pairs(ColliderModule.getCollisions()) do
        if v.visualized then
            love.graphics.setColor(v.color)
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
            love.graphics.setColor(1,1,1,1)
        end
    end
end
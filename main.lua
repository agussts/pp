love.load = function ()
    --Requiere modulos
    PlayerModule = require("libs.player")
    EnemyModule = require("libs.enemy")
    ColliderModule = require("libs.collisions")
    GunModule = require("guns.dev")
    Gun = GunModule.new()
    Timer = require("libs.timer")
    Guis = require("guis.gui")
    Button = require("guis.button")

    --Configuracion Predeterminada
    local configDefaultData = {
        BORDERLESS = false,
        VSYNC = true,
        RESOLUTION = 4,
        VOLUME = 1,
    }
    --Resoluciones que se pueden elijir
    Resolutions = {
        {width = 16, height = 9, scale = 0.025},
        {width = 320, height = 180, scale = 0.5},
        {width = 640, height = 360, scale = 1},
        {width = 1280, height = 720, scale = 2},
        {width = 1920, height = 1080, scale = 3},
    }
    --Crea config.ini si no existe
    if love.filesystem.getInfo("config.ini") == nil then
        local data = ""
        for i,v in pairs(configDefaultData) do
            data = data..tostring(i).." = "..tostring(v).."\n"
        end
        love.filesystem.write("config.ini", data)
    end

    --Saca las lineas de config.ini
    Config = love.filesystem.lines("config.ini")
    ConfigTable = {}
    --Escribe los datos del archivo config.ini a la tabla ConifgTable
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
    --Crea a el jugador y el enemigo
    Player = PlayerModule.new("assets/sprites/maxresdefault.png", 40, 40)
    Enemy = EnemyModule.new("assets/sprites/slungus.png", 40, 40)
    --Posicion del enemigo
    Enemy.collision.x = 500
    Enemy.collision.y = 100

    --Crea un colider de caja
    Collider = ColliderModule.new("box", 250, 40, 50, 50)

    --TEMPORAL: Añade un Projectil
    Projectile = ColliderModule.new("hitbox", 0, 80, 25, 25, true, function(collider)
        for i,v in pairs(collider.tags) do
            if v == "projectile" then return end
        end
        Projectile:Destroy()
    end)
    Projectile:AddTag("projectile")
    Projectile.speedX = 200
    
    love.audio.setVolume(ConfigTable.VOLUME)
    --Actualiza la ventana a los ajustes actuales
    function UpdateWindow()
        TrueResolution = Resolutions[ConfigTable.RESOLUTION]
        love.window.setMode(TrueResolution.width, TrueResolution.height, {
            borderless = ConfigTable.BORDERLESS,
            resizable = false,
            vsync = ConfigTable.VSYNC,
        })
    end
    UpdateWindow()
    --Crea boton
    local width, height = love.graphics.getPixelDimensions()
    ButtonClick = Button.new("hi", width / ( 2 * TrueResolution.scale), height / ( 2 * TrueResolution.scale), 100, 100, function ()
        print("!!")
    end)
    ButtonClick.textColor = {1,0,0,1}
end


love.keypressed = function (key)
    if key == "escape" then
        --Cierra el juego y actualiza los ajustes
        local lines = {}
        for i,v in pairs(ConfigTable) do
            table.insert(lines, i .. " = " .. tostring(v))
        end
        love.filesystem.write("config.ini", table.concat(lines, "\n"))
        love.audio.stop()
        love.timer.sleep(.1)
        love.event.quit()
    elseif key == "f11" then
        --Activa borderless
        ConfigTable.BORDERLESS = not ConfigTable.BORDERLESS
        UpdateWindow()
    elseif key == "up" then
        --Sube la resolucion
        ConfigTable.RESOLUTION = ConfigTable.RESOLUTION + 1
        if ConfigTable.RESOLUTION > #Resolutions then
            ConfigTable.RESOLUTION = 1
        end
        UpdateWindow()
    elseif key == "down" then
        --Baja la resolucion
        ConfigTable.RESOLUTION = ConfigTable.RESOLUTION - 1
        if ConfigTable.RESOLUTION < 1 then
            ConfigTable.RESOLUTION = #Resolutions
        end
        UpdateWindow()
    elseif key == Player.otherControls.dash then
        --Funcionamiento de dash
        Player.speed = Player.speed * 3
        Player.collision:ChangeType("hitbox")
        --Daño del dash
        Player.collision.onHit = function (otherCollider)
            if otherCollider.link ~= nil and otherCollider.link.health ~= nil then
                otherCollider.link.health = otherCollider.link.health - 1
            end
        end
        --Detiene el dash
        Timer.after(0.2, function()
            Player.speed = Player.speed / 3
            Player.collision.onHit = function () end
            Player.collision:ChangeType("box")
        end)
    end
end

love.update = function (dt)
    --Actualiza modulo de timer
    Timer.update(dt)

    --Fisicas de coliders
    for _,v in pairs(ColliderModule.getCollisions()) do
        v.visualized = true
        v:UpdateSpeed(dt)
        if v.enabled then
            v:check()
        end
    end

    --Funcionamiento de la pistola
    if Gun.lastFireTime > 0 then
        Gun.lastFireTime = Gun.lastFireTime - dt
    else
        Gun.lastFireTime = 0
    end
    if love.mouse.isDown(1) then
        Gun:Fire(Player.collision.x, Player.collision.y, TrueResolution.scale)
    end

    --Actualiza el movimiento del jugador
    Player:UpdateInput()
end

love.draw = function ()
    --Ajustes antes de empezar renderizacion
    love.graphics.setDefaultFilter("nearest")
    love.graphics.scale(TrueResolution.scale)

    --Dibuja el jugador
    love.graphics.draw(Player.sprite, Player.collision.x, Player.collision.y, 0 , Player.collision.width / Player.sprite:getWidth(), Player.collision.height / Player.sprite:getHeight())
   
    --Dibuja a los enemigos
    for _,v in pairs(EnemyModule.getEnemies()) do
        love.graphics.draw(v.sprite, v.collision.x, v.collision.y, 0, v.collision.width / v.sprite:getWidth(), v.collision.height / v.sprite:getHeight())
    end

   --TEMPORAL: Dice informacion extra
    love.graphics.print("Player Health: " .. Player.health, 5, 15, 0, .5, .5)
    love.graphics.print("Enemy Health: " .. Enemy.health, 5, 45, 0, .5, .5)
    love.graphics.print("Collider Position: (" .. Collider.x .. ", " .. Collider.y .. ")", 5, 35, 0, .5, .5)
    love.graphics.print("Player Position: (" .. Player.collision.x .. ", " .. Player.collision.y .. ")", 5, 5, 0, .5, .5)
    love.graphics.print("Gun Ammo: " .. Gun.ammo, 5, 25, 0, .5, .5)


    --Dibuja a los coliders que son visibles
    for i,v in pairs(ColliderModule.getCollisions()) do
        if v.visualized then
            love.graphics.setColor(v.color)
            love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
            love.graphics.setColor(1,1,1,1)
        end
    end

    --Dibuja interfaz, tiene que ser al final de la funcion para que se renderize sobre todo
     for _,self in pairs(Guis.getAll()) do
        if self.type == "button" then
            love.graphics.setColor(self.bgColor)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(self.textColor)
            love.graphics.print(self.text, self.x, self. y)
            love.graphics.setColor(1,1,1,1)
        end
    end
end
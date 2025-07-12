love.load = function ()
    --Requiere modulos
    PlayerModule = require("libs.player")
    EnemyModule = require("libs.enemy")
    ColliderModule = require("libs.collisions")
    GunModule = require("guns.dev")
    Gun = GunModule.new()
    Timer = require("libs.timer")
    UDim2 = require("guis.udim2")
    Guis = require("guis.gui")
    Button = require("guis.button")
    Textlabel = require("guis.textlabel")

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
    --Actualiza la ventana a los ajustes actuales
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
    --Crea a el jugador y el enemigo
    Player = PlayerModule.new("assets/sprites/maxresdefault.png", 0.0625, 0.11)
    Enemy = EnemyModule.new("assets/sprites/slungus.png", 0.0625, 0.11)
    Enemy.collision.position = UDim2.new(0.4, 0, 0.13, 0)

    --Crea un colider de caja
    Collider = ColliderModule.new("box")
    Collider.position = UDim2.new(0.2, 0, 0.13, 0)
    Collider.size = UDim2.new(0.08, 0, 0.13, 0)

    --TEMPORAL: Añade un Projectil
    Projectile = ColliderModule.new("hitbox", true, function(collider)
        for i,v in pairs(collider.tags) do
            if v == "projectile" then return end
        end
        Projectile:Destroy()
    end)
    Projectile.position = UDim2.new(0, 0, .11, 0)
    Projectile.size = UDim2.new(0.02, 0, 0.034, 0)
    Projectile:AddTag("projectile")
    Projectile.speedX = 200
    --Crea boton
    ButtonClick = Button.new(function ()
        print("!!")
    end)
    ButtonClick.textColor = {1,0,0,1}
    ButtonClick.position = UDim2.new(.5, 0, .5, 0)
    ButtonClick.size = UDim2.new(.1,0, .1, 0)
    ButtonClick.anchorPoint = {0.5, 0.5}
    --Crea otro boton
    Button2 = Button.new(function ()
        print("button 2 click")
    end)
    Button2.parent = ButtonClick
    Button2.position = UDim2.new(.5, 0, .5, 0)
    Button2.size = UDim2.new(.5, 0, .5, 0)
    Button2.anchorPoint = {0.5, 0.5}
    Button2.bgColor = {0, 1, 0, 1}
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
        local x,y = Player.collision.position:transformToPixels()
        Gun:Fire(x, y)
    end

    --Actualiza el movimiento del jugador
    Player:UpdateInput()
end

love.draw = function ()
    --Ajustes antes de empezar renderizacion
    love.graphics.setDefaultFilter("nearest")
    --love.graphics.scale(TrueResolution.scale)

    --Dibuja el jugador
    local x,y = Player.collision.position:transformToPixels()
    local width, height = Player.collision.size:transformToPixels()
    love.graphics.draw(Player.sprite, x, y, 0 , width / Player.sprite:getWidth(), height / Player.sprite:getHeight())
   
    --Dibuja a los enemigos
    for _,v in pairs(EnemyModule.getEnemies()) do
        local x,y = v.collision.position:transformToPixels()
        local width, height = v.collision.size:transformToPixels()
        love.graphics.draw(v.sprite, x, y, 0, width / v.sprite:getWidth(), height / v.sprite:getHeight())
    end

   --TEMPORAL: Dice informacion extra
    love.graphics.print("Player Health: " .. Player.health, 5, 15, 0, .5, .5)
    love.graphics.print("Enemy Health: " .. Enemy.health, 5, 45, 0, .5, .5)
    love.graphics.print("Collider Position: (" .. Collider.position.x.offset .. ", " .. Collider.position.y.offset .. ")", 5, 35, 0, .5, .5)
    love.graphics.print("Player Position: (" .. Player.collision.position.x.offset .. ", " .. Player.collision.position.y.offset .. ")", 5, 5, 0, .5, .5)
    love.graphics.print("Gun Ammo: " .. Gun.ammo, 5, 25, 0, .5, .5)


    --Dibuja a los coliders que son visibles
    for i,v in pairs(ColliderModule.getCollisions()) do
        if v.visualized then
            love.graphics.setColor(v.color)
            local x,y = v.position:transformToPixels()
            local width, height = v.size:transformToPixels()
            love.graphics.rectangle("line", x, y, width, height)
            love.graphics.setColor(1,1,1,1)
        end
    end

    --Dibuja interfaz, tiene que ser al final de la funcion para que se renderize sobre todo
     for _,self in pairs(Guis.getAll()) do
        if not self.visible then return end
        --Dibuja el fondo del gui
        local x, y = self:getRenderPosition()
        local width, height = self:getRenderSize()
        love.graphics.setColor(self.bgColor or {1,1,1,1})
        love.graphics.rectangle("fill", x, y, width, height)
       -- print("Drawing GUI background at: " .. x .. ", " .. y .. " with size: " .. width .. "x" .. height)
        --Dibuja el texto del gui
        if self.text then
            love.graphics.setColor(self.textColor or {0,0,0,1})
            love.graphics.print(self.text, x + 5, y + 5)
        end
        love.graphics.setColor(1,1,1,1)
    end
end
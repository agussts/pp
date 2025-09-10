--Requiere todos los modulos
require("src.utils.require")  
--Config.init()

PlayingTimers = Timer.group.new()
PauseMenuTimers = Timer.group.new()
PauseMenuTimers:pause()

--Requiere funciones
require("src.utils.pausemenu")
require("src.libs.connections")

love.load = function ()
    --Ajustes antes de empezar renderizacion
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    --Crea a el jugador y el enemigo
    Player = PlayerModule.new("assets/sprites/player-Sheet.png", 0.0625, 0.11)
    Player.collision.position = UDim2.fromScale(.5, .5)
    Enemy = EnemyModule.new("assets/sprites/slungus.png", 0.0625, 0.11)
    Enemy.collision.position = UDim2.new(0.4, 0, 0.13, 0)
    BackgroundA = Background.new("assets/sprites/xthingy.png", 32*6, 18*6, 1,1)
    BackgroundB = Background.new("assets/sprites/xthingy.png", 32*6, 18*6, 1, 1)
    BackgroundA.color = {.2,1,1,0.05}
    BackgroundB.color = {1,.2,1,0.02}

    --Crea un colider de caja
    Collider = Collisions.new("box")
    Collider.position = UDim2.new(0.2, 0, 0.13, 0)
    Collider.size = UDim2.new(0.08, 0, 0.13, 0)
end

love.keypressed = function (key)
    Fire("keyPressed", key)
end

Connect("keyPressed", function (key)
    if Gamestate == "playing" then
        if key == Config.SavedConfigs.PDASH then
            --Funcionamiento de dash
            Player.speed = Player.speed * 3
            Player.collision:ChangeType("hitbox")
            --Daño del dash
            local plrDashConnection = Player.collision.onHit:Connect(function (otherCollider)
                if otherCollider.link ~= nil and otherCollider.link.health ~= nil then
                    otherCollider.link.health = otherCollider.link.health - 1
                end
            end)
            --Detiene el dash
            Timer.after(0.2, function()
                Player.speed = Player.speed / 3
                plrDashConnection:Disconnect()
                Player.collision:ChangeType("box")
            end):addToGroup(PlayingTimers)
        end
    end
    if key == Config.SavedConfigs.PBACK then
        PauseMenu()
    end
end)

love.mousepressed = function (x, y, button)
    if button == 1 then
        --Si se hace click izquierdo, chequea si se hace click en el boton
        for _,self in pairs(Guis.getAll()) do
            if not self.visible then goto continue end
            if self.type == "button" then
                self:check(x, y)
            end
            ::continue::
        end
    end
end


love.update = function (dt)
    --Actualiza modulo de timer
    Timer.update(dt)
    --Actualiza animaciones
    if love.mouse.isDown(1) then
        --Activa funcion de cuando se presiona el boton
        for _,self in pairs(Guis.getAll()) do
            if not self.visible or self.type ~= "button" then goto continue end
            local mouseX, mouseY = love.mouse.getPosition()
            local mouseIn = self:check(mouseX, mouseY, false)
            if mouseIn then
                if self.whenPressing then
                    self.whenPressing()
                end
            end
            ::continue::
        end
    end

    for _, rootGui in pairs(Guis.getTopLevelGuis()) do
        rootGui:calculateRenderProperties()
    end

    if Gamestate == "playing" then
        BackgroundA:setScroll(BackgroundA.scrollX + 50*dt, BackgroundA.scrollY - 25*dt)
        BackgroundB:setScroll(BackgroundB.scrollX - 25*dt, BackgroundB.scrollY + 50*dt)
        BackgroundA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        BackgroundB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        if love.mouse.isDown(1) then
            local x,y = Player.collision.position:transformToPixels()
            Gun:Fire(x, y)
        end

        --Fisicas de coliders
        for _,v in pairs(Collisions.getCollisions()) do
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
        

        --Actualiza el movimiento del jugador
        Player:Update(dt)

        --Actualiza la camara a la posicion del jugador
        local playerX, playerY = Player.collision.position:toPixels()
        Camera.update(playerX, playerY)
    end
end

love.draw = function () 
    local playerX, playerY = Player.collision.position:transformToPixels()
    local width, height = Player.size:transformToPixels()
    
    BackgroundA:draw(Camera.x, Camera.y)
    BackgroundB:draw(Camera.x, Camera.y)
    Camera.attach()
        Player.sprite:draw(playerX, playerY, width, height)
        --Dibuja a los enemigos
        for _,v in pairs(EnemyModule.getEnemies()) do
            local x,y = v.collision.position:transformToPixels()
            local width, height = v.collision.size:transformToPixels()
            love.graphics.draw(v.sprite, x, y, 0, width / v.sprite:getWidth(), height / v.sprite:getHeight())
        end

        --Dibuja a los coliders que son visibles
        for i,v in pairs(Collisions.getCollisions()) do
            if v.visualized then
                love.graphics.setColor(v.color)
                local x,y = v.position:transformToPixels()
                local width, height = v.size:transformToPixels()
                love.graphics.rectangle("line", x, y, width, height)
                love.graphics.setColor(1,1,1,1)
            end
        end
    Camera.detach()

    -- Ordena por zIndex, si son iguales, ordena por el orden de insercion
    local sortedGuis = Guis.getAll()
    
    table.sort(sortedGuis, function(a, b)
        local aZIndex = a.zIndex or 0
        local bZIndex = b.zIndex or 0
        if a.parent ~= nil then aZIndex = a.parent.zIndex + aZIndex end
        if b.parent ~= nil then bZIndex = b.parent.zIndex + bZIndex end
        return aZIndex < bZIndex
    end)

    --Dibuja interfaz, tiene que ser al final de la funcion para que se renderize sobre todo

    for _,self in pairs(sortedGuis) do
        if not self.visible then goto continue end
        local x, y = self:getRenderPosition()
        local width, height = self:getRenderSize()

        --Dibuja el texto si es que tiene
        if self.text then
            love.graphics.setColor(self.textColor or {0,0,0,1})
            love.graphics.scale(TrueResolution.scale)
            local font = self.font or love.graphics.getFont()
            font:setFilter("nearest", "nearest")
            local text = love.graphics.newText(font, self.text)
            love.graphics.draw(text, (x + width / 2) / TrueResolution.scale - text:getWidth() / 2, (y + height / 2) / TrueResolution.scale - text:getHeight() / 2)
            love.graphics.setColor(1,1,1,1)
            love.graphics.scale(1 / TrueResolution.scale)
            goto continue
        end
        --Dibuja la imagen si es que tiene
        if self.image then
            love.graphics.setColor(self.imageColor or {1,1,1,1})
            love.graphics.draw(self.image, x, y, 0, width / self.image:getWidth(), height / self.image:getHeight())
            love.graphics.setColor(1,1,1,1)
            goto continue
        end
        --Dibuja el fondo del gui
        love.graphics.setColor(self.bgColor or {1,1,1,1})
        love.graphics.rectangle("fill", x, y, width, height)
        love.graphics.setColor(1,1,1,1)
        ::continue::
    end
end
--Requiere todos los modulos
require("src.utils.require")  
Config.init()

--Requiere funciones
require("src.utils.pausemenu")
require("src.libs.connections")

love.load = function ()
    --Crea a el jugador y el enemigo
    Player = PlayerModule.new("assets/sprites/maxresdefault.png", 0.0625, 0.11)
    Player.collision.position = UDim2.fromScale(.5, .5)
    Enemy = EnemyModule.new("assets/sprites/slungus.png", 0.0625, 0.11)
    Enemy.collision.position = UDim2.new(0.4, 0, 0.13, 0)

    --Crea un colider de caja
    Collider = ColliderModule.new("box")
    Collider.position = UDim2.new(0.2, 0, 0.13, 0)
    Collider.size = UDim2.new(0.08, 0, 0.13, 0)
end

love.keypressed = function(key)
    Fire("keyPressed", key)
end

Connect("keyPressed", function (key)
    if key == "escape" then
        PauseMenu()
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
        if love.mouse.isDown(1) then
            local x,y = Player.collision.position:transformToPixels()
            Gun:Fire(x, y)
        end

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
        

        --Actualiza el movimiento del jugador
        Player:UpdateInput()

        --Actualiza la camara a la posicion del jugador
        local playerX, playerY = Player.collision.position:toPixels()
        Camera.update(playerX, playerY)
    end
end

love.draw = function ()
    --Ajustes antes de empezar renderizacion
    love.graphics.setDefaultFilter("nearest")
    --Dibuja el jugador
    
    local playerX, playerY = Player.collision.position:transformToPixels()
    local width, height = Player.collision.size:transformToPixels()
    Camera.attach()
        love.graphics.draw(Player.sprite, playerX, playerY, 0 , width / Player.sprite:getWidth(), height / Player.sprite:getHeight())


        --Dibuja a los enemigos
        for _,v in pairs(EnemyModule.getEnemies()) do
            local x,y = v.collision.position:transformToPixels()
            local width, height = v.collision.size:transformToPixels()
            love.graphics.draw(v.sprite, x, y, 0, width / v.sprite:getWidth(), height / v.sprite:getHeight())
        end

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
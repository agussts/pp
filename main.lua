--Requiere todos los modulos
require("src.utils.require")  
--Config.init()

PlayingTimers = Timer.group.new()
PauseMenuTimers = Timer.group.new()
PauseMenuTimers:pause()

local testScene = require("src.scenes.testscene")
local Level2 = require("src.scenes.level2")
local internetscn = require("src.scenes.internetscn")
local darkweb = require("src.scenes.darkweb")
Scene.register("testScene", testScene)
Scene.register("level2", Level2)
Scene.register("internetscn", internetscn)
Scene.register("darkweb", darkweb)

if os.getenv("CI_SMOKETEST") == "1" then
  print("CI smoketest OK, LÖVE "..(love.getVersion()))
  love.event.quit(0)
end

love.load = function ()
    --Ajustes antes de empezar renderizacion
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    Scene.load("internetscn")
    DevTools.init()
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
                    otherCollider.link:Damage(1)
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

    local sceneTable = Scene.get() or {}

    if Gamestate == "playing" then
        for _,v in pairs(Collisions.getCollisions()) do
            v:UpdateSpeed(dt)
            if v.enabled then v:check() end
        end

        for _,v in pairs(sceneTable) do
            if type(v) == "table" then
                if v.update then
                    v:update(dt)
                end
            end
        end

        Scene.update(dt)
    end
    Dialogue.updateAll(dt)
    Transition.update(dt)
    --MathQuiz.updateAll(dt)
end

love.draw = function () 
    local sceneTable = Scene.get() or {}

    Scene.draw()

    Camera.attach()
        for _,v in pairs(sceneTable) do
            if type(v) == "table" then 
                --Si se puede dibujar, que lo dibuje
                if v.draw then
                    if v.position then
                        local x,y = v.position:toPixels()
                        v:draw(x, y)
                    else
                        v:draw()
                    end
                end
            end
        end

        for _,v in pairs(Collisions.getCollisions()) do
            v:draw()
        end
    Camera.detach()
    

    -- Ordena por zIndex, si son iguales, ordena por el orden de insercion
    local sortedGuis = Guis.getAll()
    
    local function effectiveZ(g)
        local z = g.zIndex or 0
        local p = g.parent
        while p do
            z = z + (p.zIndex or 0)
            p = p.parent
        end
        return z
    end

    table.sort(sortedGuis, function(a, b)
        -- local aZIndex = a.zIndex or 0
        -- local bZIndex = b.zIndex or 0
        -- if a.parent ~= nil then aZIndex = a.parent.zIndex + aZIndex end
        -- if b.parent ~= nil then bZIndex = b.parent.zIndex + bZIndex end
        local az, bz = effectiveZ(a), effectiveZ(b)
        if az ~= bz then
            return az < bz
        end
        -- Desempate estable: más viejo primero (o usa un id incremental si tienes)
        return tostring(a) < tostring(b)
    end)

    --Dibuja interfaz, tiene que ser al final de la funcion para que se renderize sobre todo

    for _,self in ipairs(sortedGuis) do
        if self.visible then self:draw() end
    end
    Transition.draw()
end
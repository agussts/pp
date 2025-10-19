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
local datacenter = require("src.scenes.datacenter")
local cdn = require("src.scenes.cdn")
Scene.register("testScene", testScene)
Scene.register("level2", Level2)
Scene.register("internetscn", internetscn)
Scene.register("darkweb", darkweb)
Scene.register("datacenter", datacenter)
Scene.register("cdn", cdn)


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
            if Player and Player.Dash then
                Player:Dash()
            end
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
    
    if ShardsIconsHUD._singleton then
        ShardsIconsHUD._singleton:update(dt)
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
end

love.draw = function () 
    local sceneTable = Scene.get() or {}

    Scene.draw()

    Camera.attach()
        local drawList = {}

        for _, v in pairs(sceneTable) do
            if type(v) == "table" and v.draw and v.visible ~= false then
                -- Excluir explícitamente algún objeto, si quisieras:
                if v._worldDraw ~= false then
                    local layer = v.worldLayer or 0

                    -- ¿Usamos orden por Y?
                    local depthByY = v.depthByY
                    if depthByY == nil then
                        -- Por default, si tiene collision.position, lo tratamos con depth por Y
                        depthByY = (v.collision and v.collision.position and v.collision.position.toPixels) and true or false
                    end

                    local yForDepth = 0
                    if depthByY then
                        if v.getDepthY then
                            yForDepth = tonumber(v:getDepthY()) or 0
                        elseif v.collision and v.collision.position and v.collision.position.toPixels then
                            local _, yp = v.collision.position:toPixels()
                            yForDepth = yp or 0
                        elseif v.position and v.position.toPixels then
                            local _, yp = v.position:toPixels()
                            yForDepth = yp or 0
                        end
                    end

                    drawList[#drawList + 1] = { obj = v, z = layer, y = yForDepth }
                end
            end
        end

        table.sort(drawList, function(a, b)
            if a.z == b.z then return a.y < b.y end
            return a.z < b.z
        end)

        for i = 1, #drawList do
            local o = drawList[i].obj
            -- Llamamos sin (x,y); todos tus objetos usan su propia collision/position
            -- Si tienes alguno que esperaba (x,y), Lua le pasará nils, pero en tu repo los draw no lo necesitan.
            o:draw()
        end
        -- ================================================

        -- Debug de colisiones (si lo usas)
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
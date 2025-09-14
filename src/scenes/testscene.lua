-- src/scenes/level1.lua
local Door = require("src.objs.door")

return function()
    local scene = {}

    scene.load = function(self)
        -- Fondos usando lo que ya tienes
        self.bgA = Background.new("assets/sprites/xthingy.png", 32*6, 18*6, 1,1)
        self.bgB = Background.new("assets/sprites/xthingy.png", 32*6, 18*6, 1,1)
        self.bgA.color = {.2,1,1,0.05}
        self.bgB.color = {1,.2,1,0.02}

        -- Player + enemigo
        Player = PlayerModule.new("assets/sprites/player-Sheet.png", 0.0625, 0.11)
        Player.collision.position = UDim2.fromScale(.5, .5)

        local enemy = EnemyModule.new(nil, 0.0625, 0.11)
        enemy.collision.position = UDim2.new(0.4, 0, 0.13, 0)

        -- Un collider de caja (tu “pared” de ejemplo)
        local box = Collisions.new("box")
        box.position = UDim2.new(0.2, 0, 0.13, 0)
        box.size     = UDim2.new(0.08, 0, 0.13, 0)

        -- Pistola para el player
        Gun = GunModule.new()

        -- Puerta a la otra escena
        self.door = Door.new{
            to = "level2",
            position = UDim2.fromScale(0.8, 0.5),
            size = UDim2.fromScale(0.04, 0.1),
        }
    end

    scene.start = function(self)
        -- setup inicial si hace falta
    end

    scene.update = function(self, dt)
        -- Scroll fondos
        self.bgA:setScroll(self.bgA.scrollX + 50*dt, self.bgA.scrollY - 25*dt)
        self.bgB:setScroll(self.bgB.scrollX - 25*dt, self.bgB.scrollY + 50*dt)
        self.bgA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.bgB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)

        -- Disparo contínuo con click
        if love.mouse.isDown(1) and Gun then
            local x,y = Player.collision.position:transformToPixels()
            Gun:Fire(x, y)
        end

        -- Físicas/colisiones
        for _,v in pairs(Collisions.getCollisions()) do
            v.visualized = true
            v:UpdateSpeed(dt)
            if v.enabled then v:check() end
        end

        -- Gun cooldown
        if Gun.lastFireTime > 0 then
            Gun.lastFireTime = Gun.lastFireTime - dt
        else
            Gun.lastFireTime = 0
        end

        -- Player & cámara
        Player:Update(dt)
        local playerX, playerY = Player.collision.position:toPixels()
        Camera.update(playerX, playerY)
    end

    scene.draw = function(self)
        local playerX, playerY = Player.collision.position:toPixels()
        local width, height = Player.size:toPixels()

        self.bgA:draw(Camera.x, Camera.y)
        self.bgB:draw(Camera.x, Camera.y)

        Camera.attach()
            Player.sprite:draw(playerX, playerY, width, height)
            for _,v in pairs(EnemyModule.getEnemies()) do
                local x,y = v.collision.position:toPixels()
                local w,h = v.collision.size:toPixels()
                v:draw(x, y, w, h)
            end
            for _,v in pairs(Collisions.getCollisions()) do
                v:draw()
            end
        Camera.detach()

        -- GUI (ya lo maneja tu main al final)
    end

    scene.unload = function(self)
        -- Limpieza extra si la hubiera
        if self.door then self.door:Destroy() end
    end

    return scene
end

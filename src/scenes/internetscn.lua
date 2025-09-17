return function()
    local scene = {}

    scene.load = function(self)
        -- Fondos
        self.bgA = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
        self.bgB = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
        self.bgA.color = {1,.2,1,0.05}
        self.bgB.color = {.2,1,1,0.02}

        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        Player.collision.position = UDim2.fromScale(.2, .6)
        self.player = Player
        self.darkwebWindow = {}
        self.darkwebWindow.image = love.graphics.newImage("assets/sprites/windowthing.png")
        self.darkwebWindow.size = UDim2.fromScale(0.35, .35)
        self.darkwebWindow.position = UDim2.fromScale(-.3,0)
        self.darkwebWindow.draw = function(self, x, y, sx, sy)
            love.graphics.draw(self.image, x, y, 0, sx, sy)
        end

        self.darkweb = Animation.new("assets/sprites/darkweb-Sheet.png", 60, 40, 5, 1, .25)
        self.darkweb.position = UDim2.fromScale(-.3,0)
        self.darkweb.size = UDim2.fromScale(0.35, .35)

        self.darkwebDoor = Door.new("darkweb", UDim2.fromScale(-.175, .1), UDim2.fromScale(0.1, .2))

        self.topBlocker = Block.new(nil, -1, -.2, 2.2, 0.1)
        self.bottomBlocker = Block.new(nil, -1, 1, 2.2, 0.1)
        self.leftBlocker = Block.new(nil, -1, -0.1, 0.1, 1.2)
        self.rightBlocker = Block.new(nil, 1.1, -0.1, 0.1, 1.2)

        self.enemy = Antivirus.new()
        self.enemy.collision.position = UDim2.fromScale(.5, .5)
        
        Gun = GunModule.new()
    end

    scene.start = function(self)
        -- setup inicial si hace falta
    end

    scene.update = function(self, dt)
        self.bgA:setScroll(self.bgA.scrollX + 50*dt, self.bgA.scrollY - 25*dt)
        self.bgB:setScroll(self.bgB.scrollX - 25*dt, self.bgB.scrollY + 50*dt)
        self.bgA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.bgB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.darkweb:update(dt)
        self.darkwebWindow.position = UDim2.new(self.darkwebWindow.position.x.scale, 0, math.sin(PlayingTimers:getTimePassed() * 5) / 100, 0)

        if love.mouse.isDown(1) and Gun then
            local x,y = Player.collision.position:toPixels()
            Gun:Fire(x, y)
        end

        self.enemy:follow(Player.collision.position)
        for _,v in pairs(self) do
            if type(v) == "table" then
                if v.update then
                    v:update(dt)
                end
            end
        end

        for _,v in pairs(Collisions.getCollisions()) do
            v:UpdateSpeed(dt)
            if v.enabled then v:check() end
        end

        if Gun.lastFireTime > 0 then
            Gun.lastFireTime = Gun.lastFireTime - dt
        else
            Gun.lastFireTime = 0
        end

        local px,py = Player.collision.position:toPixels()
        Camera.update(px, py)
    end

    scene.draw = function(self)

        self.bgA:draw(Camera.x, Camera.y)
        self.bgB:draw(Camera.x, Camera.y)

        Camera.attach()
            -- local wx, wy = self.darkwebWindow.position:toPixels()
            -- local ww, wh = self.darkwebWindow.size:toPixels()
            -- love.graphics.draw(self.darkwebWindow.image, wx, wy, 0, ww/self.darkwebWindow.image:getWidth(), wh/self.darkwebWindow.image:getHeight())
            -- self.darkweb:draw(wx, 0, ww, wh)

            for i,v in pairs(self) do
                if type(v) == "table" then 
                    --Si se puede dibujar, que lo dibuje
                    if v.draw then
                        if v.position and v.size then
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

        -- GUI (ya lo maneja main.lua al final)
    end

    return scene
end
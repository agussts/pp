return function()
    local scene = {}

    scene.load = function(self)
        self.bgA = Background.new("assets/sprites/xthingy.png", 32*6, 18*6, 1,1)
        self.bgB = Background.new("assets/sprites/xthingy.png", 32*6, 18*6, 1,1)
        -- Colores invertidos para notar el cambio
        self.bgA.color = {1,.2,1,0.05}
        self.bgB.color = {.2,1,1,0.02}

        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        Player.collision.position = UDim2.fromScale(.2, .6)

        Gun = GunModule.new()

        -- Puerta de vuelta a level1
        self.door = Door.new("testScene", UDim2.fromScale(0.1, 0.6), UDim2.fromScale(0.04, 0.1))
    end

    scene.update = function(self, dt)
        self.bgA:setScroll(self.bgA.scrollX + 20*dt, self.bgA.scrollY + 10*dt)
        self.bgB:setScroll(self.bgB.scrollX - 10*dt, self.bgB.scrollY - 20*dt)

        if love.mouse.isDown(1) and Gun then
            local x,y = Player.collision.position:transformToPixels()
            Gun:Fire(x, y)
        end

        for _,v in pairs(Collisions.getCollisions()) do
            v.visualized = true
            v:UpdateSpeed(dt)
            if v.enabled then v:check() end
        end

        if Gun.lastFireTime > 0 then
            Gun.lastFireTime = Gun.lastFireTime - dt
        else
            Gun.lastFireTime = 0
        end

        Player:Update(dt)
        local px,py = Player.collision.position:toPixels()
        Camera.update(px, py)
    end

    scene.draw = function(self)
        local px,py = Player.collision.position:toPixels()

        self.bgA:draw(Camera.x, Camera.y)
        self.bgB:draw(Camera.x, Camera.y)

        Camera.attach()
            Player.sprite:draw(px, py)
            for _,v in pairs(Collisions.getCollisions()) do
                v:draw()
            end
        Camera.detach()
    end

    scene.unload = function(self)
        if self.door then self.door:Destroy() end
    end

    return scene
end

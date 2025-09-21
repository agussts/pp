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
            local x,y = Player.collision.position:toPixels()
            Gun:Fire(x, y)
        end

        if Gun.lastFireTime > 0 then
            Gun.lastFireTime = Gun.lastFireTime - dt
        else
            Gun.lastFireTime = 0
        end

    end

    scene.draw = function(self)

        self.bgA:draw(Camera.x, Camera.y)
        self.bgB:draw(Camera.x, Camera.y)
    end

    scene.unload = function(self)
        if self.door then self.door:Destroy() end
    end

    return scene
end

return function()
    local scene = {}

    scene.load = function(self, payload)
        -- Fondos
        self.bgA = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
        self.bgB = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
        self.bgA.color = {1,.2,1,0.05}
        self.bgB.color = {.2,1,1,0.02}

        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        
        local spawn = UDim2.fromScale(.2, .6)
        if payload ~= nil then
            spawn = payload.spawn
        end
        Player.collision.position = spawn

        self.player = Player
        local windowAnim = Animation.new("assets/sprites/windowthing.png", 106, 83, 1, 1, 1)
        windowAnim.anchor = {.5, .5}
        windowAnim:Pause()
        self.darkwebWindow = Block.new(windowAnim, -.175, .1, .1, .1)
        self.darkwebWindow.collision.enabled = false

        local doorAnim = Animation.new("assets/sprites/darkwebdoor-Sheet.png", 76, 76, 3, 3, .35)
        doorAnim.anchor = {.5, .5}
        doorAnim:addHole(3,3)
        self.darkweb = Block.new(doorAnim, -.175, .1, .1, .1)
        self.darkweb.collision.enabled = false

        self.darkwebDoor = Door.new("darkweb", UDim2.fromScale(-.175, .1), UDim2.fromScale(0.1, .2))
        self.darkwebDoor.collision.anchor = {.5, .5}

        -- Si la misión ya estaba activa al entrar a esta escena, prepara todo:
        if World.shards.active and not World.shards.done then
            self:spawnShardsAndHUD()
        end

        Gun = GunModule.new()
    end

    function scene:spawnShardsAndHUD()
        -- HUD con objetivo
        self.hud = ShardsHUD.new(World.shards.needed)
        -- Spawnear shards en posiciones del mapa (ejemplos)
        self.shards = {}
        for _, def in ipairs(World.getRemainingShardPositions()) do
            local pos, sprite, id = def[1], def[2], def[3]
            table.insert(self.shards, Shard.new(pos, sprite, id))
        end

        -- Marca que ya están vivos en esta escena
        World.shards.spawned = true

        -- Actualiza HUD cuando juntes uno:
        self._colConn = Connect("shard_collected", function(count, needed)
            if self.hud and self.hud.setCount then
                self.hud:setCount(count, needed)
            end
        end)
  end

    scene.update = function(self, dt)
        self.bgA:setScroll(self.bgA.scrollX + 50*dt, self.bgA.scrollY - 25*dt)
        self.bgB:setScroll(self.bgB.scrollX - 25*dt, self.bgB.scrollY + 50*dt)
        self.bgA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.bgB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.darkwebWindow.collision.position = UDim2.new(self.darkwebWindow.collision.position.x.scale, 0, math.sin(PlayingTimers:getTimePassed() * 5) / 100 + .1, 0)

        if self.shards then
            for _,s in ipairs(self.shards) do
                s:update(dt)
            end
        end

        if love.mouse.isDown(1) and Gun then
            local x,y = Player.collision.position:toPixels()
            Gun:Fire(x, y)
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

        self.bgA:drawBackground()
        self.bgB:drawBackground()

        if self.shards then
            Camera.attach()
                for _,s in ipairs(self.shards) do
                    s:draw()
                end
            Camera.detach()
        end
        -- Camera.attach()
        --     for i,v in pairs(self) do
        --         if type(v) == "table" then 
        --             --Si se puede dibujar, que lo dibuje
        --             if v.draw then
        --                 if v.position and v.size then
        --                     local x,y = v.position:toPixels()
        --                     v:draw(x, y)
        --                 else
        --                     v:draw()
        --                 end
        --             end
        --         end
        --     end

        --     for _,v in pairs(Collisions.getCollisions()) do
        --         v:draw()
        --     end
        -- Camera.detach()

        -- GUI (ya lo maneja main.lua al final)
    end

    return scene
end
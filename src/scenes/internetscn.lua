return function()
    local scene = {}

    local function mkBeacon(posUDim2)
        return { pos = posUDim2, t = 0, visible = true }
    end

    scene.load = function(self, payload)
        -- Fondos
        self.bgA = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
        self.bgB = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
        self.bgA.color = {1,.2,1,0.05}
        self.bgB.color = {.2,1,1,0.02}
        self.map = TiledLite.load("assets/maps/test.lua")
        self.map:spawnAll(self)
        self.map.worldLayer = -10

        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        
        local spawn = self.playerspawn
        if payload ~= nil then
            spawn = payload.spawn
        end
        Player.collision.position = spawn

        self.player = Player
        local windowAnim = Animation.new("assets/sprites/windowthing.png", 106, 83, 1, 1, 1)
        windowAnim.anchor = {.5, .5}
        windowAnim:Pause()
        self.darkwebWindow = Block.new(windowAnim, .64, .97, .1, .1)
        self.darkwebWindow.collision.enabled = false
        self.darkwebWindow.worldLayer = -10

        local doorAnim = Animation.new("assets/sprites/darkwebdoor-Sheet.png", 76, 76, 3, 3, .35)
        doorAnim.anchor = {.5, .5}
        doorAnim:addHole(3,3)
        self.darkweb = Block.new(doorAnim, .64, .97, .1, .1)
        self.darkweb.collision.enabled = false
        self.darkweb.worldLayer = -5

        self.darkwebDoor = Door.new("darkweb", UDim2.fromScale(.64, .97), UDim2.fromScale(0.1, 0.2))
        self.darkwebDoor.collision.anchor = {.5, .5}
        

        local anim = Animation.new("assets/sprites/trashdumpbarsf.png", 180, 180, 1, 1, 1)
        anim.anchor = {.5, .5}
        anim:Pause()
        self.trashDumpBarsF = Block.new(anim, 1.1, 0.4)
        self.trashDumpBarsF.collision.enabled = false
        self.trashDumpBarsF.worldLayer = -4

        local anim = Animation.new("assets/sprites/trashdumpbarsb.png", 180, 180, 1, 1, 1)
        anim.anchor = {.5, .5}
        anim:Pause()
        self.trashDumpBarsB = Block.new(anim, 1.1, 0.4)
        self.trashDumpBarsB.collision.enabled = false
        self.trashDumpBarsB.worldLayer = -5.5

        local anim = Animation.new("assets/sprites/trashdumptrash.png", 180, 180, 1, 1, 1)
        anim.anchor = {.5, .5}
        anim:Pause()
        self.trashDumpTrash = Block.new(anim, 1.1, 0.4)
        self.trashDumpTrash.collision.enabled = false
        self.trashDumpTrash.worldLayer = -5

        -- Si la misión ya estaba activa al entrar a esta escena, prepara todo:
        if World.shards.active and not World.shards.done then
            self:spawnShardsAndHUD()
            self.beacons = {
                cache   = mkBeacon(UDim2.fromScale(0.28, 0.53)), -- encima del dumpster
                router  = mkBeacon(UDim2.fromScale(0.52, 0.36)), -- encima del panel
                firewall= mkBeacon(UDim2.fromScale(0.79, 0.60)), -- encima del shard detrás
            }
        end

        Gun = GunModule.new()
        self.gun = Gun
    end

    function scene:spawnShardsAndHUD()
        --- HUD
        self.hud = ShardsHUD.new(World.shards.needed)

        -- Colecciones
        self.cacheBoxes = {}
        self.firewalls  = {}
        self.nodes      = {}
        self.shards     = {}

        local layout = World.getShardHideouts()
        for _,def in ipairs(layout) do
            if not World.shards.collectedIds[def.id] then
                if def.kind == "cachebox" then
                    -- Rompe caja -> aparece Shard que lanza MathQuiz
                    local box = CacheBox.new(def.pos, def.size, function()
                        table.insert(self.shards, Shard.new(def.pos, "assets/sprites/shard.png", def.id))
                    end)
                    table.insert(self.cacheBoxes, box)

                elseif def.kind == "firewall" then
                    local fw = FirewallGate.new(def.gatePos, def.gateSize, 1.6, 0.65)
                    table.insert(self.firewalls, fw)
                    -- Shard visible detrás de la barrera
                    table.insert(self.shards, Shard.new(def.shardPos, "assets/sprites/shard.png", def.id))

                elseif def.kind == "router" then
                    local node = RouterNode.new(def.id, def.pos)
                    table.insert(self.nodes, node)
                end
            end
        end

        World.shards.spawned = true

        -- Actualizar HUD al recolectar
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
        self.darkwebWindow.collision.position = UDim2.new(self.darkwebWindow.collision.position.x.scale, 0, math.sin(PlayingTimers:getTimePassed() * 5) / 100 + .97, 0)

        for _,b in ipairs(self.cacheBoxes or {}) do b:update(dt) end
        for _,f in ipairs(self.firewalls or {})  do f:update(dt) end
        for _,n in ipairs(self.nodes or {})      do n:update(dt) end
        for _,s in ipairs(self.shards or {})     do s:update(dt) end
        for _,b in pairs(self.beacons or {}) do
            if b.visible then b.t = b.t + dt end
        end

        local px,py = Player.collision.position:toPixels()
        Camera.update(px, py)
    end

    scene.draw = function(self)

        self.bgA:drawBackground()
        self.bgB:drawBackground()

        if self.shards then
            Camera.attach()
                for _,f in ipairs(self.firewalls or {})  do f:draw() end
                for _,b in ipairs(self.cacheBoxes or {}) do b:draw() end
                for _,s in ipairs(self.shards or {})     do s:draw() end
                for _,n in ipairs(self.nodes or {})      do n:draw() end
            Camera.detach()
        end
    end
    scene.unload = function (self)
        self.map = nil
    end
    return scene
end
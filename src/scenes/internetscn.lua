return function()
    local scene = {}
    --local DataCenter = require("src.features.datacenterhelper")

    -- Helper minimalista: activa interacción de la pila de basura
    local function setupTrashInteraction(self)
        -- Pos de referencia (desde el bloque central)
        self._trashPos = ((self.trashDumpTrash and self.trashDumpTrash.collision and self.trashDumpTrash.collision.position)
                        or UDim2.fromScale(1.2, 0.4)) - UDim2.fromScale(0, .1)

        -- Función local para ocultar/mostrar las 3 piezas
        local function trashVisible(vis)
            if self.trashDumpTrash and self.trashDumpTrash.sprite then self.trashDumpTrash.sprite.visible = vis end
        end
        -- Antes de limpiar, si la misión está activa: hum de “algo oculto”
        if World.shards.active and not World.shards.collectedIds["trash1"] then
            if not self._trashHum then
                self._trashHum = ProximityHum.new(self._trashPos, "assets/sfx/shardhum.wav", 1, .8, 10)
            end
        end

        -- Si ya estaba limpia: ocultar y (si falta) mostrar shard
        if World.flags.trashCleared then
            if not World.shards.collectedIds["trash1"] then
                self.shards = self.shards or {}
                self._trashShard = self._trashShard or Shard.new(self._trashPos, "assets/sprites/shard.png", "trash1")
                self._trashShard.onCollect:Connect(function ()
                    self._trashHum:stopAndDestroy()
                end)
                self._trashShard.worldLayer = -5.25
                table.insert(self.shards, self._trashShard)
            end
            trashVisible(false)
            return
        end

        -- Si aún no hablaste con "???", no hay interacción (solo decorado)
        if not World.flags.metmvirus then
            trashVisible(true)
            return
        end

        -- Interacción: prompt sencillo
        trashVisible(true)
        self._trashPrompt = ProxPrompt.new("Press [%s] to clear the junk")
        self._trashPrompt.collision.position = self._trashPos
        self._trashPrompt.collision.size     = UDim2.fromScale(0.16, 0.22)
        self._trashPrompt.collision.anchor   = {0.5, 0.5}
        self._trashPrompt.collision.enabled  = true

        local anim = Animation.new("assets/sprites/blink.png", 27, 27, 3, 3, .2)
        anim:addHole(3, 2)
        anim:addHole(3, 3)
        anim.anchor = {.5, .5}
        self.blink = Block.new(anim, self._trashPos.x.scale, self._trashPos.y.scale + .3)
        self.blink.collision.enabled = false

        self._trashPromptConn = self._trashPrompt.Triggered:Once(function()
            if self._trashPrompt then self._trashPrompt:Destroy() end
            self._trashPrompt, self._trashPromptConn = nil, nil
            -- Marcar limpio, ocultar y soltar shard
            World.flags.trashCleared = true
            Camera.shake(5, 1, "XY")
            Timer.after(1, function()
                self.shards = self.shards or {}
                self.trashDumpTrash.sprite:Play()
                if not World.shards.collectedIds["trash1"] then
                    self._trashShard = self._trashShard or Shard.new(self._trashPos, "assets/sprites/shard.png", "trash1")
                    self._trashShard.onCollect:Connect(function ()
                        self._trashHum:stopAndDestroy()
                    end)
                    table.insert(self.shards, self._trashShard)
                end
            end):addToGroup(PlayingTimers)
            self.trashDumpTrash.sprite.OnFinish:Connect(function()
                self.blink:Destroy()
                trashVisible(false)
            end)
        end)
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
        
        self.datacenterDoor = Door.new("datacenter", UDim2.fromScale(1, 6), UDim2.fromScale(0.1, 0.2))
        self.datacenterDoor.collision.anchor = {.5, .5}

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

        local anim = Animation.new("assets/sprites/trashdumptrash-Sheet.png", 180, 180, 3, 2, .1)
        anim.loop = false
        anim.anchor = {.5, .5}
        anim:Pause()
        self.trashDumpTrash = Block.new(anim, 1.1, 0.4)
        self.trashDumpTrash.collision.enabled = false
        self.trashDumpTrash.worldLayer = -5

        -- Si la misión ya estaba activa al entrar a esta escena, prepara todo:
        if World.shards.active and not World.shards.done then
            print("spawn shards")
        end

        Gun = GunModule.new()
        self.gun = Gun
        setupTrashInteraction(self)
        self.cdndoor = Door.new("cdn", UDim2.fromScale(2.3, 2.9), UDim2.fromScale(0.16, 0.22))
        self.cdndoor.collision.anchor = {.5, .5}
    end

    scene.update = function(self, dt)

        self.bgA:setScroll(self.bgA.scrollX + 50*dt, self.bgA.scrollY - 25*dt)
        self.bgB:setScroll(self.bgB.scrollX - 25*dt, self.bgB.scrollY + 50*dt)
        self.bgA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.bgB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
        self.darkwebWindow.collision.position = UDim2.new(self.darkwebWindow.collision.position.x.scale, 0, math.sin(PlayingTimers:getTimePassed() * 5) / 100 + .97, 0)

        if self._trashPrompt then self._trashPrompt:update() end

        local px,py = Player.collision.position:toPixels()
        --DataCenter.update(self, dt)
        Camera.update(px, py)
    end

    scene.draw = function(self)
        self.bgA:drawBackground()
        self.bgB:drawBackground()
       -- Camera.attach() DataCenter.draw(self) Camera.detach()
    end
    scene.unload = function (self)
        --DataCenter.detach(self)
        for _,v in pairs(self) do
            if type(v) == "table" and v.Destroy then v:Destroy() elseif type(v) == "table" and v.Disconnect then v:Disconnect() end
            v = nil
        end
        if self._trashPrompt then self._trashPrompt:Destroy() end
        self._trashPrompt = nil
        if self._trashPromptConn and self._trashPromptConn.Disconnect then
            self._trashPromptConn:Disconnect()
        end
        self._trashPromptConn = nil
        self.map = nil
    end
    return scene
end
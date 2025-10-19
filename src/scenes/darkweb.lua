return function ()
    local scene = {}
    scene.load = function (self)
        self.bg = Background.new("assets/sprites/darkwebbg.png", 640, 360)
        self.bg:setRepeat(false)
        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        Player.collision.position = UDim2.fromScale(.1, .8)
        self.player = Player
        local anim = Animation.new("assets/sprites/mvirus-Sheet.png", 41, 41, 3, 3, .1)
        anim:addHole(3, 3)
        anim.anchor = {.5, .5}
        self.mvirus = Block.new(anim, .575, .7, .06, .1)
        self.mvirus.collision.anchor = {.5, .5}
        self.exit = Door.new("internetscn", UDim2.fromScale(0, .75), UDim2.fromScale(.025, .3), {spawn = UDim2.fromScale(.73, 1)})

        local exitImg = Animation.new("assets/sprites/exit.png", 48, 57, 1, 1, 1)
        exitImg:Pause()
        self.exitSign = Block.new(exitImg, 0, .7, 1, 1)
        self.exitSign.collision.enabled = false

        self.talkMvirus = ProxPrompt.new("Press [%s] to talk")
        self.talkMvirus.collision.position = self.mvirus.collision.position
        self.talkMvirus.collision.size = UDim2.fromScale(.2, .35)

        self._talkConn = self.talkMvirus.Triggered:Connect(function ()
            self:startMVirusDial()
        end)
    end

    function scene:startMVirusDial()
        local script
        if not World.flags.metmvirus then
            -- Primera vez: mensaje completo
            script = WrittenDialogues.mvirusFirst
            local dlg = Dialogue.start(script, 42)
            if dlg == nil then return end
            dlg.onFinish:Connect(function()
                World.flags.metmvirus = true
                self.testShard = Shard.new(UDim2.fromScale(.4, .73), nil, "testShard")
                Connect("shard_collected", function (id)
                    if id == "testShard" and not World.flags.gottestShard then
                        print("got test shard")
                        World.flags.gottestShard = true
                    end
                end)
            end)
        elseif World.flags.metmvirus and not World.flags.gottestShard then
            -- Después de dar el shard de prueba pero no haberlo recolectado
            script = WrittenDialogues.mviruswaitingshard
            Dialogue.start(script, 42)
        elseif World.flags.gottestShard and not World.shards.active then
            -- Despues de recolectar testshar, Iniciar misión shards
            script = WrittenDialogues.mvirusgotesttshard
            local dlg = Dialogue.start(script, 42)
            if dlg == nil then return end
            dlg.onFinish:Connect(function()
                World.startShardsQuest()
            end)
        elseif World.shards.active and not World.shards.done then
            -- Misión en progreso
            script = WrittenDialogues.mviruspostFirst
            Dialogue.start(script, 42)
        elseif World.shards.done then
            -- “Turn-in” (si ya juntaste los 3)
            script = WrittenDialogues.shardsDone
            local dlg = Dialogue.start(script, 42)
            if dlg == nil then return end
            dlg.onFinish:Connect(function()
                -- cerrar misión, dar recompensa, marcar reset/next-step:
                World.shards.active = false
                World.shards.spawned = false 
            end)    
        end
    end

    scene.update = function (self, dt)
        local w, h = love.graphics.getDimensions()
        Camera.update(w/2, h/2)
    end
    scene.start = function (self)

    end
    scene.draw = function (self)
        self.bg:drawBackground()
    end
    return scene
end
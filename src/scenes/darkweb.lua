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
        self.exit = Door.new("internetscn", UDim2.fromScale(0, .75), UDim2.fromScale(.025, .3), {spawn = UDim2.fromScale(-.125, .4)})

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
            dlg.onFinish:Connect(function()
                World.flags.metmvirus = true
                World.startShardsQuest()     -- -> internetscn spawnea shards
            end)
        else
            if World.shards.done then
                -- “Turn-in” (si ya juntaste los 3)
                script = WrittenDialogues.shardsDone
                local dlg = Dialogue.start(script, 42)
                dlg.onFinish:Connect(function()
                    -- cerrar misión, dar recompensa, marcar reset/next-step:
                    World.shards.active = false
                    World.shards.spawned = false 
                end)
            else
                -- Recordatorio corto si ya aceptaste pero no terminaste
                script = WrittenDialogues.mviruspostFirst
                Dialogue.start(script, 42)
            end
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
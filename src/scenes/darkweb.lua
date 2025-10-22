return function ()
    local scene = {}
    scene.load = function (self)
        self.bg = Background.new("assets/sprites/darkwebbg.png", 640, 360)
        self.bg:setRepeat(false)
        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        Player.collision.position = UDim2.fromScale(.1, .8)
        Player.Dash = function () end
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

        self.topBlocker = Collisions.new("box")
        self.topBlocker.anchor = {0,1}
        self.topBlocker.position = UDim2.fromScale(0,0)
        self.topBlocker.size = UDim2.fromScale(1,.1)
        self.topBlocker.anchored = true

        self.bottomBlocker = Collisions.new("box")
        self.bottomBlocker.anchor = {0,0}
        self.bottomBlocker.position = UDim2.fromScale(0,1)
        self.bottomBlocker.size = UDim2.fromScale(1,.1)
        self.bottomBlocker.anchored = true

        self.leftBlocker = Collisions.new("box")
        self.leftBlocker.anchor = {1,0}
        self.leftBlocker.position = UDim2.fromScale(0,0)
        self.leftBlocker.size = UDim2.fromScale(.1, 1)
        self.leftBlocker.anchored = true

        self.rightBlocker = Collisions.new("box")
        self.rightBlocker.anchor = {0,0}
        self.rightBlocker.position = UDim2.fromScale(1,0)
        self.rightBlocker.size = UDim2.fromScale(.1,1)
        self.rightBlocker.anchored = true

        self._talkConn = self.talkMvirus.Triggered:Connect(function ()
            self:startMVirusDial()
        end)
        Music.play("darkweb")
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

                local pos = UDim2.fromScale(.4, .73)

                -- 1) VFX: three quick pulses using blink.png (27x27, 3x3, 0.04)
                local function spawnPulse(delay)
                    Timer.after(delay, function()
                        local an = Animation.new("assets/sprites/blink.png", 27, 27, 3, 3, 0.04)
                        an.loop = false
                        an.anchor = {.5, .5}
                        local fx = Block.new(an, pos.x.scale, pos.y.scale)
                        fx.collision.enabled = false
                        fx.worldLayer = -5.25
                        self["fx"..delay] = fx
                        an.OnFinish:Connect(function() if fx then fx:Destroy() end end)
                    end):addToGroup(PlayingTimers)
                end
                spawnPulse(0.00)
                spawnPulse(0.08)
                spawnPulse(0.16)

                self.testShard = Shard.new(pos, nil, "testShard")

                self.testShard.collision.enabled = false
                self.testShard._alphaMult = 0

                self.doorBlock = Collisions.new("box")
                self.doorBlock.anchored = true
                self.doorBlock.anchor = {0,.1}
                self.doorBlock.position = UDim2.fromScale(0, .75)
                self.doorBlock.size = UDim2.fromScale(.04, .3)

                self.doorPreventer = Collisions.new("hitbox")
                self.doorPreventer.anchor = {0,.15}
                self.doorPreventer.position = UDim2.fromScale(0, .75)
                self.doorPreventer.size = UDim2.fromScale(.05, .35)
                self.doorPreventer.onHit:Connect(function (other)
                    if other:HasTag("player") then
                        Dialogue.start(WrittenDialogues.testshardexittry, 42)
                        self.pushOut = Collisions.new("box")
                        self.pushOut.anchored = true
                        self.pushOut.anchor = {0,.2}
                        self.pushOut.position = UDim2.fromScale(0, .75)
                        self.pushOut.size = UDim2.fromScale(.06, .4)
                        Timer.after(.1, function ()
                            self.pushOut:Destroy()
                        end):addToGroup(PlayingTimers)
                    end
                end)

                self._testHum = ProximityHum.new(pos, "assets/sfx/shardhum.wav", .5, .8, 10)

                Timer.after(0.22, function()
                    local dur = 0.50
                    local t = 0
                    local tick
                    tick = Timer.every(0.016, function()
                        if not self.testShard or self.testShard._destroying then
                            if tick then tick:Destroy() end
                            return
                        end
                        t = t + 0.016
                        local k = math.min(1, t / dur)
                        self.testShard._alphaMult = k
                        if k >= 1 then
                            if tick then tick:Destroy() end
                            self.testShard.collision.enabled = true
                            Camera.shake(1.5, 0.12, "XY")
                        end
                    end)
                    tick:addToGroup(PlayingTimers)
                end):addToGroup(PlayingTimers)

                Connect("shard_collected", function(id)
                    print("collected")
                    if id == "testShard" then
                        self.doorBlock:Destroy()
                        self.doorPreventer:Destroy()
                        self._testHum:stopAndDestroy()
                        if not World.flags.gottestShard then
                            World.flags.gottestShard = true
                        end
                        -- Despues de recolectar testshar, Iniciar misión shards
                        Timer.after(.1, function ()
                            script = WrittenDialogues.mvirusgotesttshard
                            local dlg = Dialogue.start(script, 42)
                            if dlg == nil then return end
                            dlg.onFinish:Connect(function()
                                Popup.show{
                                text   = "Access token acquired.",
                                icon   = "assets/sprites/accesstoken.png",
                                tone   = "ok",
                                corner = "bl" -- bottom-left (no choca con tu Shards HUD)
                                }
                                World.startShardsQuest()
                            end)
                        end):addToGroup(PlayingTimers)
                    end
                end)
            end)

        elseif World.flags.metmvirus and not World.flags.gottestShard then
            -- Después de dar el shard de prueba pero no haberlo recolectado
            script = WrittenDialogues.mviruswaitingshard
            Dialogue.start(script, 42)            
        elseif World.shards.active and not World.shards.done then
            -- Misión en progreso
            script = WrittenDialogues.mviruspostFirst
            Dialogue.start(script, 42)
        elseif World.shards.done and not World.flags.webKey then
            -- Reemplaza tu script/branch existente por esto:
            local script = WrittenDialogues.mvirusTurnIn
            local dlg = Dialogue.start(script, 42)
            if dlg == nil then return end
            dlg.onFinish:Connect(function()
                -- Marca entrega y da la WEB KEY
                World.shards.active  = false
                World.shards.spawned = false
                if not World.flags.webKey then
                    World.flags.webKey = true
                    if Popup and Popup.show then
                        Popup.show({
                            text = "Web key acquiered",
                            icon    = "assets/sprites/webkey.png", -- opcional
                            hold    = 2.0,
                        })
                    end
                end
            end)
        elseif World.flags.webKey then
            Dialogue.start(WrittenDialogues.mvirusAfterTurnIn, 42)
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
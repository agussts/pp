---@diagnostic disable: undefined-field
local DC = {}
DC.__index = DC

local audios = {
    gateOpen = love.audio.newSource("assets/sfx/gateopen.wav", "static")
}

-- ----------------------
-- estado runtime simple
-- ----------------------
local function newState()
return {
    started      = false,
    tearingDown  = false,

    gateIn  = nil,
    gateOut = nil,
    barriers = {},

    pads       = {},    -- {pos,size,hp,points,enemies,heat,respawn}
    servers    = {},    -- ServerNode instancias
    spawns     = {},    -- lista de UDim2 (puntos de spawn enemigo)
    enemies    = {},    -- EnemyModule instancias
    startPrompt = nil,
    upgPos     = nil,
    shardPos   = nil,

    points      = 0,
    heat        = 0,
    heatMul     = 1.0,
    targetPoints= 300,  -- ajusta a gusto
    respawnTime = 6,  -- default si el pad no define
    shardSpawned= false,

    shardObj    = nil,  -- si lo spawneamos
    brokeFirstServer = false,
}
end

local function recalcHeatMul(st)
    st.heatMul = 1.0 + math.min(1.0, st.heat / 100) * 2.0
    if not st._hintHeat40 and st.heat >= 40 then
        st._hintHeat40 = true
        Teach.once("tut_dc_heat40", { text = "Heat x Points = Big score!", hold = 2.2 })
    end
end
local function addHeat(st, h)
    st.heat = math.max(0, st.heat + (h or 0))
    recalcHeatMul(st)
end
local function addPoints(st, base)
    local gained = math.floor((base or 0) * (st.heatMul or 1))
    st.points = st.points + gained
end

-- ----------------------
-- spawnear server en pad
-- ----------------------
local function spawnServerAt(self, pad)
    local st = self.st
    if not st or st.tearingDown or pad.live then return end  -- ya hay uno / saliendo

    -- mata un timer previo si existiera
    if pad.respT and pad.respT.Destroy then pad.respT:Destroy() end
    pad.respT = nil

    local hp      = pad.hp or 40
    local points  = pad.points or 20
    local respawn = pad.respawn or st.respawnTime

    local srv = ServerNode.new(pad.pos, hp, points)
    pad.live = srv
    table.insert(st.servers, srv)

    local onceConn
    onceConn = srv.onDestroyed:Connect(function()
        if onceConn and onceConn.Disconnect then onceConn:Disconnect() end
        Teach.once("tut_dc_first_break", { text = "Nice! Servers respawn—keep going!", hold = 2.2, inPosScale={0.85,0.18}, holdTime = 3 })
        if not st.brokeFirstServer then
            Music.play("datacenter")
        end
        st.brokeFirstServer = true
        pad.live = nil

        -- puntos + heat + HUD
        addPoints(st, points)
        addHeat(st, pad.heat or 10)


        if self.hud and self.hud.setPoints then self.hud:setPoints(st.points, st.targetPoints) end
        if self.hud and self.hud.setHeat   then self.hud:setHeat(st.heat)     end
        Camera.shake(3, .18, "XY")

        -- spawns de enemigos (opcionales)
        if #st.spawns > 0 and (pad.enemies or 0) > 0 then
            for i=1,pad.enemies do
                local sp = st.spawns[math.random(1, #st.spawns)]
                if sp then
                    local posUDim2, kind = sp[1], sp[2]
                    local e
                    if kind == "antivirus" and Antivirus and Antivirus.new then
                        e = Antivirus.new()
                    else
                        e = EnemyModule.new(nil, 0.0625, 0.11)
                    end
                    if e and e.collision then e.collision.position = posUDim2 end
                    if e and e.follow then e:follow(Player.collision.position) end
                    table.insert(st.enemies, e)
                end
            end
        end

        -- respawn con guard de GENERACIÓN (mata cualquier timer viejo)
        local myGen = self.gen
        if not st.tearingDown then
            pad.respT = Timer.after(respawn, function()
                pad.respT = nil
                if st.tearingDown then return end
                if World._dcGen ~= myGen then return end  -- escena nueva => abortar
                if pad.live then return end
                spawnServerAt(self, pad)
            end):addToGroup(PlayingTimers)
        end

        -- shard si llegaste a la meta
        if (not st.shardSpawned) and st.points >= st.targetPoints and not World.shards.collectedIds["dc_shard"] then
            st.shardSpawned = true
            local where = st.shardPos or pad.pos
            st.shardObj = Shard.new(where, "assets/sprites/shard.png", "dc_shard")
        end
    end)

    return srv
end

-- ======================
-- API pública del módulo
-- ======================
function DC.attach(scene, map)
    local self = setmetatable({}, DC)
    scene._dc = self
    self.scene = scene
    self.map   = map
    self.st    = newState()

    World._dcGen = (World._dcGen or 0) + 1
    self.gen = World._dcGen

    self.hud = DCHUD.new()
    self.hud:setVisible(true)
    self.hud:setPoints(0, self.st.targetPoints)
    self.hud:setHeat(0, 1)

    local st = self.st

    -- ---------- factories por class ----------
    local factory = {}

    factory["dc_start"] = function(o, scn)
        local prompt = ProxPrompt.new("Press [%s] to begin")
        prompt.collision.anchor = {0,0}
        prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
        prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
        st.startPrompt = prompt

        prompt.Triggered:Connect(function()
            if not World.shards.active then
                Popup.show{
                    text = "You need an access token.",
                    tone = "warn",
                    corner = "bl"
                }
                return
            end
            --if st.started then return end
            st.started = not st.started
            audios.gateOpen:clone():play()
            Popup.show{
                    text = "Toggled gate with token.",
                    icon = "assets/sprites/accesstoken.png",
                    tone = "info",
                    corner = "bl"
                }
                Teach.chain("tut_dc_after_start", {
                { text = "Break a server to score!", hold = 1.3, inPosScale={0.85,0.28}, holdTime = 3 },
                { text = "Heat rises while you fight." , hold = 1.3, inPosScale={0.85,0.18}, holdTime = 3 },
                { text = "More heat equals more points!"   , hold = 3.3, inPosScale={0.85,0.28}, holdTime = 3 },
                })

            prompt.collision.enabled = false
            -- abrir y cerrar
            if st.gateIn then
                st.gateIn.sprite:Play()
                st.gateIn.sprite.OnFinish:Once(function ()
                    prompt.collision.enabled = true
                    st.gateIn.sprite.reversed = not st.gateIn.sprite.reversed
                    st.gateIn.collision.enabled = not st.gateIn.collision.enabled
                end)
            end
            if st.gateOut then
                st.gateOut.sprite:Play()
                st.gateOut.sprite.OnFinish:Once(function ()
                    st.gateOut.sprite.reversed = not st.gateOut.sprite.reversed
                    st.gateOut.collision.enabled = not st.gateOut.collision.enabled
                end)
            end
        end)

        return prompt
    end

    if Config.SavedConfigs.HELP_SIGNS then
        -- Cartel / Letrero que abre un diálogo de ayuda
        factory["dc_sign"] = function(o)
            -- Props opcionales desde Tiled:
            --   script   = clave en WrittenDialogues (string). Ej: "tut_cdn_sign_basic"
            --   label    = texto del prompt. Por defecto "Press [%s] to read"
            local scriptKey = (o.props and o.props.script) or "tut_dc_sign_basic"
            local label     = (o.props and o.props.label)  or "Press [%s] to read"

            local prompt = ProxPrompt.new(label)
            prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
            prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
            prompt.collision.anchor   = {0,0}

            prompt.Triggered:Connect(function()
            -- Evita abrir si ya estás en diálogo, si tu sistema lo necesita
            if Dialogue and WrittenDialogues and WrittenDialogues[scriptKey] then
                Dialogue.start(WrittenDialogues[scriptKey], 42)
            end
            end)

            return prompt
        end

        factory["dc_signpost"] = function (o)
            local anim = Animation.new("assets/sprites/sign.png", 44, 44, 1, 1, 1)
            anim.anchor = {.5,.5}
            anim:Pause()
            local signBlock = Block.new(anim, o.sx, o.sy)
            signBlock.collision.anchor = {0,0}
            signBlock.collision.enabled = false
            return signBlock
        end
    end

    factory["dc_gate_in"] = function(o)
        local anim = Animation.new("assets/sprites/gateforward-Sheet.png", 44, 32, 2, 2, .05)
        anim.loop = false
        anim:Pause()
        local g = Block.new(anim, o.sx, o.sy, o.sw, o.sh)
        st.gateIn = g
        return g
    end

    factory["dc_gate_out"] = function(o)
        local anim = Animation.new("assets/sprites/gateforward-Sheet.png", 44, 32, 2, 2, .05)
        anim.loop = false
        anim.reversed = true
        anim:Pause()
        anim:GoToFrame(4)
        local g = Block.new(anim, o.sx, o.sy, o.sw, o.sh)
        g.collision.enabled = false
        st.gateOut = g
        return g
    end

    factory["dc_pad"] = function(o)
        local pr = o.props or {}
        table.insert(st.pads, {
            pos     = UDim2.fromScale(o.sx, o.sy),
            size    = UDim2.fromScale(o.sw, o.sh),
            hp      = pr.hp or 40,
            points  = pr.points or 20,
            enemies = pr.enemies or 3,
            heat    = pr.heat or 10,
            respawn = pr.respawn or nil,

            -- >>> NUEVO
            live    = nil,   -- ServerNode vivo en este pad
            respT   = nil,   -- handle del timer de respawn
        })
        return nil
    end




    factory["dc_enemy_spawn"] = function(o)
        local kind = o.props and o.props.kind or nil
        table.insert(st.spawns, {UDim2.fromScale(o.sx, o.sy), kind})
        return nil
    end

    factory["dc_upgrade"] = function(o)
        st.upgPos = UDim2.fromScale(o.sx, o.sy)
        return nil
    end

    factory["dc_shard"] = function(o)
        st.shardPos = UDim2.fromScale(o.sx, o.sy)
        return nil
    end

    map:spawnObjects(factory, scene)
    for _,pad in ipairs(st.pads) do
        spawnServerAt(self, pad)
    end
    if scene.enemyblocker then
        scene.enemyblocker.blockFilter = function (_, other)
            if other:HasTag("enemy") then return true end
            return false
        end
    end
    return self
end

function DC.update(self, dt)
    local st = self.st
    if not st then return end

    if st.started and st.heat > 0 then
        st.heat = math.max(0, st.heat - dt * 2)
        recalcHeatMul(st)
    end
    if self.hud then
        self.hud:setHeat(st.heat, st.heatMul)
    end
    if st.startPrompt then st.startPrompt:update() end

    for _,srv in ipairs(st.servers) do
        if srv.update then srv:update(dt) end
    end
    for _,e in ipairs(st.enemies) do
        if e.update then e:update(dt) e:follow(Player.collision.position) end
    end
    if st.shardObj and st.shardObj.update then
        st.shardObj:update(dt)
    end
end

function DC.draw(self)
    local st = self.st
    if not st then return end

    for _,srv in ipairs(st.servers) do
        if srv.draw then srv:draw() end
    end
    for _,e in ipairs(st.enemies) do
        if e.draw then e:draw() end
    end
    if st.shardObj and st.shardObj.draw then
        st.shardObj:draw()
    end
end

function DC.detach(self)
    local st = self.st
    if not st then return end
    st.tearingDown = true

    -- >>> NUEVO: matar timers/servers por pad
    for _, pad in ipairs(st.pads or {}) do
        if pad.respT and pad.respT.Destroy then pad.respT:Destroy() end
        pad.respT = nil
        if pad.live and pad.live.Destroy then pad.live:Destroy() end
        pad.live = nil
    end

    if self.hud then self.hud:Destroy() end
    self.hud = nil

    if st.startPrompt then st.startPrompt:Destroy() end

    if st.gateIn  then st.gateIn:Destroy()  end

    if st.gateOut then st.gateOut:Destroy() end

    for _,srv in ipairs(st.servers) do if srv.Destroy then srv:Destroy() end end
    -- enemigos y shard no tienen Destroy requerido, pero limpiamos por si acaso
    for _,e in ipairs(st.enemies) do if e.Destroy then e:Destroy() end end
    if st.shardObj and st.shardObj.Destroy then st.shardObj:Destroy() end

    self.st = nil
end

return DC
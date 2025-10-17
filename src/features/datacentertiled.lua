local DC = {}
DC.__index = DC

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
    targetPoints= 100,  -- ajusta a gusto
    respawnTime = 4.5,  -- default si el pad no define
    shardSpawned= false,

    shardObj    = nil,  -- si lo spawneamos
}
end

local function recalcHeatMul(st)
    st.heatMul = 1.0 + math.min(1.0, st.heat / 100) * 0.5
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
    if st.tearingDown then return end
    local hp      = pad.hp or 40
    local points  = pad.points or 20
    local respawn = pad.respawn or st.respawnTime

    local srv = ServerNode.new(pad.pos, hp, points)
    table.insert(st.servers, srv)

    srv.onDestroyed:Connect(function()
        -- puntos + heat
        addPoints(st, points)
        addHeat(st, pad.heat or 10)
        Camera.shake(3, .18, "XY")
        -- spawns enemigos
        for i=1,pad.enemies do
                local randomSpawn = math.random(1, #st.spawns)
            local sp = st.spawns[randomSpawn]
            print(sp[1], sp[2])
            if sp then
                if sp[2] == "antivirus" then
                    local e = Antivirus.new()
                    e.collision.position = sp[1]
                    e:follow(Player.collision.position)
                    table.insert(st.enemies, e)
                end
            end
        end

        -- respawn server
        Timer.after(respawn, function()
        spawnServerAt(self, pad)
        end):addToGroup(PlayingTimers)

        -- shard al alcanzar meta
        if (not st.shardSpawned) and st.points >= st.targetPoints then
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

    local st = self.st

    -- ---------- factories por class ----------
    local factory = {}

    factory["dc_start"] = function(o, scn)
        local prompt = ProxPrompt.new("Press [%s] to begin")
        prompt.collision.position = UDim2.fromScale(o.sx, o.sy)
        prompt.collision.size     = UDim2.fromScale(o.sw, o.sh)
        st.startPrompt = prompt

        prompt.Triggered:Once(function()
            if st.started then return end
            st.started = true

            -- abrir entrada, cerrar salida
            if st.gateIn  then st.gateIn.enabled = false end
            if st.gateOut then st.gateOut.enabled = true end

            -- levantar servidores
            for _,pad in ipairs(st.pads) do
                spawnServerAt(self, pad)
            end
        end)

        return prompt
    end

    factory["dc_gate_in"] = function(o)
        local g = Collisions.new("box")
        g.position = UDim2.fromScale(o.sx, o.sy)
        g.size     = UDim2.fromScale(o.sw, o.sh)
        st.gateIn = g
        return g
    end

    factory["dc_gate_out"] = function(o)
        local g = Collisions.new("box", false)
        g.position = UDim2.fromScale(o.sx, o.sy)
        g.size     = UDim2.fromScale(o.sw, o.sh)
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
        })
        -- pad es lógico; no devolvemos nada con colisión
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

    return self
end

function DC.update(self, dt)
    local st = self.st
    if not st then return end

    if st.started and st.heat > 0 then
        st.heat = math.max(0, st.heat - dt * 2)
        recalcHeatMul(st)
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
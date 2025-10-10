-- TiledLite (Lua): cargador y spawner automático para mapas Tiled exportados como **Lua**.
-- Integra con UDim2/Collisions y tu sistema de cámara (no maneja cámara internamente).
-- Características:
--   • Capas "tilelayer": precompiladas a SpriteBatch. Propiedad de capa opcional: parallax (0..1).
--   • Capas "objectgroup": spawnea objetos automáticamente con fábricas por defecto:
--       - type="player_spawn"  → recoloca/crea Player
--       - type="door"          → Door.new(...), props: to, spawnx, spawny
--       - type="enemy"         → EnemyModule.new(...), props: health, damage, speed
--       - type="shard"         → Shard.new(...), props: id, sprite
--       - type="prop"          → Block con sprite estático (decoración), props: sprite
--   • Si el objeto tiene "name" en Tiled, se asigna como scene[name] para acceso directo.
--   • Colisiones desde layers nombradas en opts.collisionLayers (p.ej. {"Colliders"}).
--
-- Uso mínimo:
--   local TiledLite = require("src.utils.tiledlite")
--   self.map = TiledLite.load("assets/maps/internet01.lua", { collisionLayers = {"Colliders"} })
--   self.map:spawnAll(self)   -- spawnea todo con fábricas por defecto
--   -- draw:
--   self.map:drawParallaxBackground()   -- antes de Camera.attach(), solo si usas parallax<1
--   Camera.attach()
--       self.map:draw()                 -- capas con parallax==1 (mundo)
--   Camera.detach()
--
-- @module TiledLite

local TiledLite = {}
TiledLite.__index = TiledLite

-- ===== Utilidades internas =================================================

local bitlib = rawget(_G, "bit") or rawget(_G, "bit32")

local function band(a, b)
    if bitlib and bitlib.band then return bitlib.band(a, b) end
    local res, bitv = 0, 1
    while a > 0 or b > 0 do
        if (a % 2 == 1) and (b % 2 == 1) then res = res + bitv end
        a = math.floor(a / 2); b = math.floor(b / 2); bitv = bitv * 2
    end
    return res
end

local FLIP_H, FLIP_V, FLIP_D = 0x80000000, 0x40000000, 0x20000000

local function gidDecode(gid)
    local fh = band(gid, FLIP_H) ~= 0
    local fv = band(gid, FLIP_V) ~= 0
    local fd = band(gid, FLIP_D) ~= 0
    local clean = gid
    if fh then clean = clean - FLIP_H end
    if fv then clean = clean - FLIP_V end
    if fd then clean = clean - FLIP_D end
    return clean, fh, fv, fd
end

local function dirname(path)
    return path:match("^(.*)/[^/]-$") or ""
end

local function join(a, b)
    if not a or a == "" then return b end
    return (a .. "/" .. b):gsub("//+", "/")
end

local function toScale(xpx, ypx)
    local W, H = Config.IdealResolution.width, Config.IdealResolution.height
    return xpx / W, ypx / H
end

local function loadLuaMap(path)
    local chunk, err = love.filesystem.load(path)
    assert(chunk, "TiledLite: no se pudo cargar '" .. tostring(path) .. "': " .. tostring(err))
    local ok, data = pcall(chunk)
    assert(ok and type(data) == "table", "TiledLite: el mapa Lua debe retornar una tabla")
    return data, dirname(path)
end

local function getProp(tbl, key)
    local props = tbl and tbl.properties
    if not props then return nil end
    if props[1] and type(props[1]) == "table" and props[1].name then
        for _, p in ipairs(props) do
            if p.name == key then return p.value end
        end
    else
        return props[key]
    end
    return nil
end

local function buildTileset(ts, baseDir)
    local imgPath = ts.image
    if imgPath and baseDir ~= "" then
        imgPath = join(baseDir, imgPath)
    end
    local image = love.graphics.newImage(imgPath)
    image:setFilter("nearest", "nearest", 1)

    local iw, ih = image:getWidth(), image:getHeight()
    local tw, th = ts.tilewidth, ts.tileheight
    local spacing = ts.spacing or 0
    local margin  = ts.margin  or 0
    local cols    = ts.columns
    local total   = ts.tilecount

    local quads = {}
    local rows = math.floor(total / cols + 0.0001)
    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            local id = ts.firstgid + (y * cols + x)
            quads[id] = love.graphics.newQuad(
                margin + x * (tw + spacing),
                margin + y * (th + spacing),
                tw, th, iw, ih
            )
        end
    end

    return {
        image    = image,
        quads    = quads,
        firstgid = ts.firstgid,
        lastgid  = ts.firstgid + total - 1,
        tw = tw, th = th
    }
end

local function screenScale()
    local sw, sh = love.graphics.getDimensions()
    local sx = sw / Config.IdealResolution.width
    local sy = sh / Config.IdealResolution.height
    return sx, sy
end

-- ===== API base (carga y dibujo) ===========================================

--- Carga un mapa de Tiled exportado como **Lua**.
-- @tparam string luaPath
-- @tparam[opt] table opts { collisionLayers={"Colliders"} }
function TiledLite.load(luaPath, opts)
    opts = opts or {}
    local self = setmetatable({}, TiledLite)

    local map, baseDir = loadLuaMap(luaPath)
    self.data = map
    self.tilewidth  = map.tilewidth
    self.tileheight = map.tileheight
    self.mapWpx = map.width  * map.tilewidth
    self.mapHpx = map.height * map.tileheight

    -- tilesets
    self.tilesets = {}
    for _, ts in ipairs(map.tilesets or {}) do
        assert(not ts.source, "TiledLite: usa tilesets embebidos o con 'image' directo en el mapa Lua")
        table.insert(self.tilesets, buildTileset(ts, baseDir))
    end
    self._tsByGid = {}
    for i, ts in ipairs(self.tilesets) do
        table.insert(self._tsByGid, {ts.firstgid, ts.lastgid, i})
    end

    -- capas → spritebatches
    self.layers = {}
    for _, layer in ipairs(map.layers or {}) do
        if layer.type == "tilelayer" then
            local batches = {}
            for i, ts in ipairs(self.tilesets) do
                batches[i] = love.graphics.newSpriteBatch(ts.image, layer.width * layer.height)
            end
            local lw, lh = layer.width, layer.height
            for ly = 0, lh - 1 do
                for lx = 0, lw - 1 do
                    local idx = ly * lw + lx + 1
                    local gid = layer.data[idx]
                    if gid and gid ~= 0 then
                        local clean, fh, fv, fd = gidDecode(gid)
                        if not fd then
                            local tsIndex
                            for _, range in ipairs(self._tsByGid) do
                                if clean >= range[1] and clean <= range[2] then tsIndex = range[3]; break end
                            end
                            if tsIndex then
                                local ts = self.tilesets[tsIndex]
                                local q  = ts.quads[clean]
                                if q then
                                    local x = lx * self.tilewidth  + (layer.offsetx or 0)
                                    local y = ly * self.tileheight + (layer.offsety or 0)
                                    local sx = fh and -1 or 1
                                    local sy = fv and -1 or 1
                                    local ox = fh and self.tilewidth  or 0
                                    local oy = fv and self.tileheight or 0
                                    batches[tsIndex]:add(q, x, y, 0, sx, sy, ox, oy)
                                end
                            end
                        end
                    end
                end
            end
            table.insert(self.layers, {
                kind     = "tiles",
                name     = layer.name or ("layer" .. (#self.layers + 1)),
                opacity  = layer.opacity or 1,
                parallax = tonumber(getProp(layer, "parallax")) or 1,
                batches  = batches,
                data     = layer, -- guardo props de capa por si usas "role"
            })

        elseif layer.type == "objectgroup" then
            table.insert(self.layers, {
                kind = "objects",
                name = layer.name or ("objects" .. (#self.layers + 1)),
                data = layer
            })
        end
    end

    -- colisiones desde capas designadas
    self.collisionLayerNames = opts.collisionLayers or {"Colliders"}
    for _, L in ipairs(self.layers) do
        if L.kind == "objects" then
            for _, tagName in ipairs(self.collisionLayerNames) do
                if L.name == tagName then
                    for _, obj in ipairs(L.data.objects or {}) do
                        if obj.shape == "rectangle" then
                            local sx, sy = toScale(obj.x, obj.y)
                            local sw, sh = toScale(obj.width, obj.height)
                            local c = Collisions.new("box")
                            c.position = UDim2.fromScale(sx, sy)
                            c.size     = UDim2.fromScale(sw, sh)
                            c.anchor   = {0, 0}
                            c:AddTag("world")
                        end
                    end
                end
            end
        end
    end

    return self
end

--- Dibuja (solo capas con parallax==1) dentro de Camera.attach().
function TiledLite:draw()
    local scale = (TrueResolution and TrueResolution.scale) or 1
    love.graphics.push()
    love.graphics.scale(scale, scale)
    for _, L in ipairs(self.layers) do
        if L.kind == "tiles" and (L.parallax or 1) == 1 then
            love.graphics.setColor(1, 1, 1, L.opacity or 1)
            for i, _ in ipairs(self.tilesets) do
                local sb = L.batches[i]
                if sb then love.graphics.draw(sb, 0, 0) end
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    love.graphics.pop()
end

--- Dibuja capas con parallax != 1 como fondos (antes de Camera.attach()).
function TiledLite:drawParallaxBackground()
    local scale = (TrueResolution and TrueResolution.scale) or 1
    local camX, camY = (Camera and Camera.x) or 0, (Camera and Camera.y) or 0
    for _, L in ipairs(self.layers) do
        if L.kind == "tiles" and (L.parallax or 1) ~= 1 then
            local p = L.parallax
            love.graphics.push()
            love.graphics.scale(scale, scale)
            love.graphics.translate(
                math.floor((1 - p) * camX / scale + 0.5),
                math.floor((1 - p) * camY / scale + 0.5)
            )
            love.graphics.setColor(1, 1, 1, L.opacity or 1)
            for i, _ in ipairs(self.tilesets) do
                local sb = L.batches[i]
                if sb then love.graphics.draw(sb, 0, 0) end
            end
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end
    end
end

-- ===== Spawner automático (fábricas por defecto) ===========================

--- Fábricas por defecto internas. Puedes sobreescribir con TiledLite.setDefaultFactory().
local DefaultFactories = {}

-- player_spawn
DefaultFactories.player_spawn = function(o, scn)
    if not Player then
        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        scn.player = Player
    end
    Player.collision.position = UDim2.fromScale(o.sx, o.sy)
    return Player
end

-- door (props: to, spawnx, spawny)
DefaultFactories.door = function(o, scn)
    local to     = (o.props and o.props.to) or "darkweb"
    local spawnX = tonumber(o.props and o.props.spawnx) or 0.2
    local spawnY = tonumber(o.props and o.props.spawny) or 0.6
    local sizeW  = (o.sw and o.sw > 0) and o.sw or 0.06
    local sizeH  = (o.sh and o.sh > 0) and o.sh or 0.12
    local d = Door.new(to, UDim2.fromScale(o.sx, o.sy), UDim2.fromScale(sizeW, sizeH), {
        spawn = UDim2.fromScale(spawnX, spawnY)
    })
    d.collision.anchor = {0.5, 0.5}
    return d
end

-- enemy (props: health, damage, speed)
DefaultFactories.enemy = function(o, scn)
    local w = (o.sw and o.sw > 0) and o.sw or 0.0625
    local h = (o.sh and o.sh > 0) and o.sh or 0.11
    local e
    if o.props then
        if o.props.kind == "antivirus" then
            e = Antivirus.new()
            e.collision.position = UDim2.fromScale(o.sx, o.sy)
        else
            e = EnemyModule.new(nil, w, h)
        end
        e.collision.position = UDim2.fromScale(o.sx, o.sy)
        if o.props.health then e.health = tonumber(o.props.health) or e.health end
        if o.props.damage then e.damage = tonumber(o.props.damage) or e.damage end
        if o.props.speed  then e.speed  = tonumber(o.props.speed)  or e.speed  end
    end
    return e
end

-- shard (props: id, sprite). Respeta quest activa.
DefaultFactories.shard = function(o, scn)
    if not (World.shards.active and not World.shards.done) then return nil end
    local id = o.props and o.props.id
    local sprite = (o.props and o.props.sprite) or "assets/sprites/shard.png"
    local s = Shard.new(UDim2.fromScale(o.sx, o.sy), sprite, id)
    return s
end

-- prop (decoración estática) (props: sprite)
DefaultFactories.prop = function(o, scn)
    local img = (o.props and o.props.sprite) or "assets/sprites/prop.png"
    local wpx = o.width or 16
    local hpx = o.height or 16
    local a = Animation.new(img, wpx, hpx, 1, 1, 1)
    a:Pause()
    a.anchor = {0.5, 0.5}
    local blk = Block.new(a, o.sx, o.sy, (o.sw > 0 and o.sw or 0.01), (o.sh > 0 and o.sh or 0.01))
    blk.collision.enabled = false
    return blk
end

--- Permite registrar/overrides de fábricas por defecto.
function TiledLite.setDefaultFactory(typeName, fn)
    DefaultFactories[typeName] = fn
end

--- Recorre capas de objetos y spawnea usando fábricas (defaults + overrides).
-- @tparam table factories Opcional. Se fusiona con los defaults (override por clave).
function TiledLite:spawnObjects(factories, scene)
    factories = factories or {}
    -- mezcla (override) de defaults con user factories
    local merged = {}
    for k, v in pairs(DefaultFactories) do merged[k] = v end
    for k, v in pairs(factories) do merged[k] = v end

    for _, L in ipairs(self.layers) do
        if L.kind == "objects" then
            for _, obj in ipairs(L.data.objects or {}) do
                local t = obj.type or obj.class or ""
                local f = merged[t]
                if f then
                    obj.sx, obj.sy = toScale(obj.x, obj.y)
                    obj.sw, obj.sh = toScale(obj.width or 0, obj.height or 0)
                    obj.props = {}
                    if obj.properties then
                        if obj.properties[1] and obj.properties[1].name then
                            for _, p in ipairs(obj.properties) do obj.props[p.name] = p.value end
                        else
                            for k, v in pairs(obj.properties) do obj.props[k] = v end
                        end
                    end
                    local inst = f(obj, scene)
                    -- si tiene name en Tiled, asigna a scene[name]
                    if inst and obj.name and scene then
                        scene[obj.name] = inst
                    end
                end
            end
        end
    end
end

--- Llamada “cero código extra” para spawnear TODO con defaults.
-- @tparam table scene La escena receptora (para asignar scene[name])
-- @tparam[opt] table factories Overrides puntuales si quieres cambiar algo.
function TiledLite:spawnAll(scene, factories)
    self:spawnObjects(factories, scene)
end

return TiledLite

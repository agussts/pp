--- TiledLite (Lua): cargador ligero de mapas Tiled exportados como archivo Lua.
-- Integra con UDim2/Collisions/Camera y permite spawnear objetos desde capas.
-- Requisitos en Tiled:
--   • Exporta como **Lua** (el archivo devuelve `return { ... }`)
--   • Mapa ortogonal; tilesets embebidos o con imagen relativa al mapa
--   • Capas de tiles y capas de objetos (rectángulos para colisión/objetos)
--   • Propiedad opcional por capa de tiles: `parallax` (0..1, p.ej. 0.35, 0.7, 1)
--
-- Uso:
--   local TiledLite = require("src.utils.tiledlite")
--   self.map = TiledLite.load("assets/maps/internet01.lua", {
--       collisionLayers = {"Colliders"}
--   })
--   self.map:spawnObjects({
--       shard = function(obj) ... end,
--       door  = function(obj) ... end,
--   })
--   -- En draw:
--   Camera.attach()
--       self.map:draw(Camera.x, Camera.y)
--   Camera.detach()
--
-- @module TiledLite


local TiledLite = {}
TiledLite.__index = TiledLite

-- === Utilidades internas ===================================================

local bitlib = rawget(_G, "bit") or rawget(_G, "bit32")

--- AND bit a prueba de entorno (LuaJIT/bit32 o sin libs)
local function band(a, b)
    if bitlib and bitlib.band then return bitlib.band(a, b) end
    -- fallback simple (lento, pero suficiente para 3 flags)
    local res, bitv = 0, 1
    while a > 0 or b > 0 do
        if (a % 2 == 1) and (b % 2 == 1) then res = res + bitv end
        a = math.floor(a / 2); b = math.floor(b / 2); bitv = bitv * 2
    end
    return res
end

local FLIP_H, FLIP_V, FLIP_D = 0x80000000, 0x40000000, 0x20000000

--- Decodifica flags de Tiled en un GID (flip horizontal/vertical/diagonal).
-- @tparam integer gid
-- @treturn integer clean_gid GID sin flags
-- @treturn boolean flip_h
-- @treturn boolean flip_v
-- @treturn boolean flip_d (no soportado)
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

--- Directorio padre de una ruta (simple).
local function dirname(path)
    return path:match("^(.*)/[^/]-$") or ""
end

--- Une rutas (`a/b`), manejando "//".
local function join(a, b)
    if not a or a == "" then return b end
    return (a .. "/" .. b):gsub("//+", "/")
end

--- Convierte pixeles a escala UDim2 respecto a la **resolución ideal**.
local function toScale(xpx, ypx)
    local W, H = Config.IdealResolution.width, Config.IdealResolution.height
    return xpx / W, ypx / H
end

--- Lee el archivo Lua de Tiled (debe hacer `return { ... }`).
local function loadLuaMap(path)
    local chunk, err = love.filesystem.load(path)
    assert(chunk, "TiledLite: no se pudo cargar '" .. tostring(path) .. "': " .. tostring(err))
    local ok, data = pcall(chunk)
    assert(ok and type(data) == "table", "TiledLite: el mapa Lua debe retornar una tabla")
    return data, dirname(path)
end

--- Obtiene una propiedad de Tiled desde `tbl.properties`.
-- Soporta tanto `{ {name=, value=}, ... }` como `{ name = value, ... }`.
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

--- Construye un tileset (imagen + quads).
local function buildTileset(ts, baseDir)
    local imgPath = ts.image
    if imgPath and baseDir ~= "" then
        imgPath = join(baseDir, imgPath)  -- relativo al mapa
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

-- helper interno: escala de pantalla vs resolución ideal
local function screenScale()
    local sw, sh = love.graphics.getDimensions()
    local sx = sw / Config.IdealResolution.width
    local sy = sh / Config.IdealResolution.height
    return sx, sy
end

-- === API ===================================================================

--- Carga un mapa de Tiled exportado como **Lua**.
-- @tparam string luaPath Ruta (LOVE FS) al archivo .lua exportado por Tiled.
-- @tparam[opt] table opts { collisionLayers={"Colliders"} }
-- @treturn TiledLite instancia del mapa
function TiledLite.load(luaPath, opts)
    opts = opts or {}
    local self = setmetatable({}, TiledLite)

    local map, baseDir = loadLuaMap(luaPath)
    self.data = map
    self.tilewidth  = map.tilewidth
    self.tileheight = map.tileheight
    self.mapWpx = map.width  * map.tilewidth
    self.mapHpx = map.height * map.tileheight

    -- Tilesets
    self.tilesets = {}
    for _, ts in ipairs(map.tilesets or {}) do
        assert(not ts.source, "TiledLite: usa tilesets embebidos o con 'image' directo en el mapa Lua")
        table.insert(self.tilesets, buildTileset(ts, baseDir))
    end

    -- Pre-índice de rango GID → tileset
    self._tsByGid = {}
    for i, ts in ipairs(self.tilesets) do
        table.insert(self._tsByGid, {ts.firstgid, ts.lastgid, i})
    end

    -- Capas
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
                            -- Encuentra tileset
                            local tsIndex = nil
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
                kind = "tiles",
                name = layer.name or ("layer" .. (#self.layers + 1)),
                opacity = layer.opacity or 1,
                parallax = tonumber(getProp(layer, "parallax")) or 1,
                batches = batches,
            })

        elseif layer.type == "objectgroup" then
            table.insert(self.layers, {
                kind = "objects",
                name = layer.name or ("objects" .. (#self.layers + 1)),
                data = layer
            })
        end
    end

    -- Colisiones desde capas designadas
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
                            c.visualized = false
                        end
                    end
                end
            end
        end
    end

    return self
end

--- Recorre capas de objetos y llama a una “factory” por `type`.
-- @tparam table factories Mapa { [type]=function(obj) end, ... }
-- Obj incluye:
--   obj.sx,obj.sy,obj.sw,obj.sh (en escala), obj.props (tabla de propiedades)
function TiledLite:spawnObjects(factories)
    factories = factories or {}
    for _, L in ipairs(self.layers) do
        if L.kind == "objects" then
            for _, obj in ipairs(L.data.objects or {}) do
                local t = obj.type or obj.class or ""
                local f = factories[t]
                if f then
                    obj.sx, obj.sy = toScale(obj.x, obj.y)
                    obj.sw, obj.sh = toScale(obj.width or 0, obj.height or 0)
                    obj.props = {}
                    if obj.properties then
                        if obj.properties[1] and obj.properties[1].name then
                            for _, p in ipairs(obj.properties) do
                                obj.props[p.name] = p.value
                            end
                        else
                            for k, v in pairs(obj.properties) do
                                obj.props[k] = v
                            end
                        end
                    end
                    f(obj)
                end
            end
        end
    end
end

--- Dibuja capas de tiles con parallax por capa (resolución virtual correcta).
-- Dibuja usando coords del mapa (ideal) y las escala a la resolución actual.
-- @tparam[opt=0] number camX  cámara en pixeles **pantalla**
-- @tparam[opt=0] number camY  cámara en pixeles **pantalla**
function TiledLite:drawMap(camX, camY)
    camX, camY = camX or 0, camY or 0

    -- Relación pantalla/ideal: todo el mapa se dibuja escalado a esto.
    local sx, sy = screenScale()

    for _, L in ipairs(self.layers) do
        if L.kind == "tiles" then
            local p = L.parallax or 1

            -- NOTA: tras escalar, cualquier translate debe estar en coords del mapa,
            -- por eso dividimos el offset de cámara (que viene en pixeles de pantalla)
            -- entre la escala.
            love.graphics.push()
            love.graphics.scale(sx, sy)
            love.graphics.translate(
                math.floor((1 - p) * camX / sx + 0.5),
                math.floor((1 - p) * camY / sy + 0.5)
            )

            love.graphics.setColor(1, 1, 1, L.opacity or 1)
            for i, ts in ipairs(self.tilesets) do
                local sb = L.batches[i]
                if sb then
                    -- Ojo: el spritebatch ya fue creado en coords del mapa (ideal),
                    -- NO le pongas escala aquí: ya estamos en un contexto escalado.
                    love.graphics.draw(sb, 0, 0)
                end
            end
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end
    end
end

return TiledLite

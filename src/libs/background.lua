---
-- @classmod Background
-- Sistema de fondos "tileables" con parallax y escalado automático al cambiar la resolución.
-- 
-- Los tamaños de tile (`tileW`, `tileH`) se especifican en **pixeles virtuales**
-- (relativos a `Config.IdealResolution`) y se escalan automáticamente por
-- `TrueResolution.scale` para mantener proporciones al cambiar de resolución.
--
-- Uso básico:
-- ```
-- local bg = Background.new("img.png", 192, 108, 1, 1)
-- bg:setScroll(100, 50)
-- bg:draw(cameraX, cameraY)
-- ```

local Background = {}
Background.__index = Background

--- Clamp entre 0 y 1.
-- @tparam number x Valor a clamplear
-- @treturn number Resultado en [0,1]
local function clamp01(x) return (x < 0 and 0) or (x > 1 and 1) or x end

--- Módulo positivo (para wrap de texturas).
-- @tparam number a Valor
-- @tparam number b Módulo
-- @treturn number a mod b en rango [0,b)
local function tmod(a, b) return a - math.floor(a / b) * b end

--- Crea un nuevo fondo.
-- @tparam string imagePath Ruta a la imagen
-- @tparam[opt] number tileW Ancho del tile en pixeles virtuales
-- @tparam[opt] number tileH Alto del tile en pixeles virtuales
-- @tparam[opt=1] number parallaxX Factor de parallax horizontal (0=fijo, 1=sigue cámara)
-- @tparam[opt=1] number parallaxY Factor de parallax vertical (0=fijo, 1=sigue cámara)
-- @treturn Background Nuevo objeto Background
function Background.new(imagePath, tileW, tileH, parallaxX, parallaxY)
    local self = setmetatable({}, Background)
    self.image = love.graphics.newImage(imagePath)
    self.repeatTex = true
    self.image:setWrap("repeat", "repeat")

    self.imgW, self.imgH = self.image:getWidth(), self.image:getHeight()

    -- @field tileW Ancho del tile en pixeles virtuales
    self.tileW = tileW or self.imgW
    -- @field tileH Alto del tile en pixeles virtuales
    self.tileH = tileH or self.imgH

    -- @field color Color multiplicador {r,g,b,a}
    self.color = {1,1,1,1}
    -- @field parallaxX Parallax horizontal
    self.parallaxX = clamp01(parallaxX or 1)
    -- @field parallaxY Parallax vertical
    self.parallaxY = clamp01(parallaxY or 1)

    -- @field scrollX Scroll manual X (pixeles pantalla)
    -- @field scrollY Scroll manual Y (pixeles pantalla)
    self.scrollX, self.scrollY = 0, 0

    -- @field quad Quad reutilizable para dibujar
    self.quad = love.graphics.newQuad(0, 0, 1, 1, self.imgW, self.imgH)
    return self
end

function Background:setRepeat(enabled)
    self.repeatTex = not not enabled
    self.image:setWrap(enabled and "repeat" or "clamp",
                        enabled and "repeat" or "clamp")
end

--- Cambia el tamaño del tile en pixeles virtuales.
-- @tparam[opt] number tileW Nuevo ancho (nil = mantener)
-- @tparam[opt] number tileH Nuevo alto (nil = mantener)
function Background:setTileSize(tileW, tileH)
    if tileW then self.tileW = tileW end
    if tileH then self.tileH = tileH end
end

--- Establece el scroll manual en pixeles de pantalla.
-- @tparam[opt=0] number px Scroll horizontal en pixeles
-- @tparam[opt=0] number py Scroll vertical en pixeles
function Background:setScroll(px, py)
    if px ~= nil then self.scrollX = px end
    if py ~= nil then self.scrollY = py end
end

--- Configura el parallax.
-- @tparam[opt] number px Factor horizontal (0=fijo, 1=sigue cámara)
-- @tparam[opt] number py Factor vertical (0=fijo, 1=sigue cámara)
function Background:setParallax(px, py)
    if px ~= nil then self.parallaxX = clamp01(px) end
    if py ~= nil then self.parallaxY = clamp01(py) end
end

--- Dibuja el fondo.
-- @tparam[opt=0] number cameraX Posición X de la cámara en pixeles mundo
-- @tparam[opt=0] number cameraY Posición Y de la cámara en pixeles mundo
function Background:drawBackground()
    local winW, winH = love.graphics.getDimensions()
    if not self.repeatTex then
        love.graphics.setColor(self.color)
        -- Escala para llenar pantalla (cover).
        local sx = winW / self.imgW
        local sy = winH / self.imgH
        love.graphics.draw(self.image, 0, 0, 0, sx, sy)
        love.graphics.setColor(1,1,1,1)
        return
    else
        local scale = TrueResolution.scale or 1

        -- 1) Tamaño real del tile en pantalla
        local tileWpx = math.max(1, self.tileW * scale)
        local tileHpx = math.max(1, self.tileH * scale)

        -- 2) Escala del sprite base
        local sx = tileWpx / self.imgW
        local sy = tileHpx / self.imgH

        -- 3) Quad que cubre toda la pantalla
        local quadW = winW / sx
        local quadH = winH / sy

        -- 4) Offset de textura
        local offX = (self.scrollX + (Camera.x or 0) * self.parallaxX) / sx
        local offY = (self.scrollY + (Camera.y or 0) * self.parallaxY) / sy
        offX = tmod(offX, self.imgW)
        offY = tmod(offY, self.imgH)

        self.quad:setViewport(offX, offY, quadW, quadH, self.imgW, self.imgH)

        love.graphics.setColor(self.color)
        love.graphics.draw(self.image, self.quad, 0, 0, 0, sx, sy)
        love.graphics.setColor(1,1,1,1)
    end
end

return Background

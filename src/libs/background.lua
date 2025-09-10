---
-- Fondo con tamaño de tile configurable (en pixeles de pantalla),
-- repetido para cubrir todo el viewport, con soporte de scroll/parallax.

local Background = {}
Background.__index = Background

---
--Crea un nuevo fondo
--@return (background) Instancia del fondo
--@param imagePath ruta de la textura
--@param tileW ancho del tile en pixeles de la pantalla (como de grande se “ve” cada repeticion)
--@param tileH altura del tile en pixeles de la pantalla (como de grande se “ve” cada repeticion)
--@param parallaxX: 0 = fijo a pantalla, 1 = se mueve como la camara
--@param parallaxY: 0 = fijo a pantalla, 1 = se mueve como la camara
--@usage local myBackground = Background.new("assets/sprites/image.png", 200, 150, 0.5, 0.5)
function Background.new(imagePath, tileW, tileH, parallaxX, parallaxY)
    local self = setmetatable({}, Background)
    self.image = love.graphics.newImage(imagePath)
    self.image:setWrap("repeat", "repeat")

    self.imgW = self.image:getWidth()
    self.imgH = self.image:getHeight()

    self.tileW = tileW or self.imgW   -- tamaño deseado del tile en pantalla
    self.tileH = tileH or self.imgH

    self.color = {1,1,1,1}
    self.parallaxX = parallaxX  -- 0 = fijo a pantalla, 1 = sigue camara
    self.parallaxY = parallaxY  -- 0 = fijo a pantalla, 1 = sigue camara

    self.scrollX = 0  -- desplazamiento manual (en pixeles de pantalla)
    self.scrollY = 0

    -- Quad dinamico, se actualiza segun la resolucion actual y la escala objetivo
    self.quad = love.graphics.newQuad(0, 0, 1, 1, self.imgW, self.imgH)

    return self
end

---
-- Cambia tamaño del tile (en pixeles de pantalla)
--@param tileW ancho del tile en pixeles de la pantalla (como de grande se “ve” cada repeticion)
--@param tileH altura del tile en pixeles de la pantalla (como de grande se “ve” cada repeticion)
--@usage myBackground:setTileSize(200, 150)
function Background:setTileSize(tileW, tileH)
    self.tileW = tileW or self.tileW
    self.tileH = tileH or self.tileH
end

---
-- Scroll manual (por ejemplo para animar el fondo)
--@param px desplazamiento en X en pixeles de pantalla
--@param py desplazamiento en Y en pixeles de pantalla
--@usage myBackground:setScroll(100, 50)
function Background:setScroll(px, py)
    self.scrollX = px or self.scrollX
    self.scrollY = py or self.scrollY
    if self.scrollX > self.tileW then self.scrollX = self.scrollX - self.tileW end
    if self.scrollY > self.tileH then self.scrollY = self.scrollY - self.tileH end
end

---
-- Parallax (0 = fijo a pantalla, 1 = se mueve como el mundo/camara)
--@param px parallax en X
--@param py parallax en Y
--@usage myBackground:setParallax(0.5, 0.5)
function Background:setParallax(px, py)
    if px ~= nil then self.parallaxX = px end
    if py ~= nil then self.parallaxY = py end
end

---
-- Dibuja el fondo. cameraX/Y son coordenadas de la camara (en pixeles mundo)
--@param cameraX posicion X de la camara en pixeles mundo
--@param cameraY posicion Y de la camara en pixeles mundo
--@usage myBackground:draw(cameraX, cameraY)
function Background:draw(cameraX, cameraY)
    local winW, winH = love.graphics.getDimensions()

    -- Escala para que el sprite base se vea del tamaño de tile deseado
    -- (dibujar con scale cambia el tamaño en pantalla del tile)
    local scaleX = self.tileW / self.imgW
    local scaleY = self.tileH / self.imgH

    -- El quad necesita tener un tamaño tal que, al multiplicar por escala,
    -- cubra la pantalla completa.
    local quadW = winW / scaleX
    local quadH = winH / scaleY

    -- Offset de textura (en espacio del QUAD, que esta en pixeles de la textura)
    -- Convierte desplazamiento en pantalla a espacio del quad dividiendo por la escala.
    local offX = (self.scrollX or 0) / scaleX
               + (cameraX or 0) * self.parallaxX / scaleX
    local offY = (self.scrollY or 0) / scaleY
               + (cameraY or 0) * self.parallaxY / scaleY

    -- Hace que el offset sea ciclico
    -- Asi evitar numeros enormes con el tiempo:
    local function mod(a, b)
        return a - math.floor(a / b) * b
    end
    offX = mod(offX, self.imgW)
    offY = mod(offY, self.imgH)

    -- Ajusta viewport del quad: (x, y, w, h) en coordenadas de textura
    self.quad:setViewport(offX, offY, quadW, quadH, self.imgW, self.imgH)

    -- Dibujo
    love.graphics.setColor(self.color)
    love.graphics.draw(self.image, self.quad, 0, 0, 0, scaleX, scaleY)
    love.graphics.setColor(1,1,1,1)
end

return Background

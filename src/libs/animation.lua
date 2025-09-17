---
-- Crea una nueva animacion
--@classmod animations
local animations = {}
local addedAnimations = {}
---
--Crea una nueva animacion
--@param imagePath Directorio de la imagen
--@param gridWidth El ancho de cada cuadro
--@param gridHeight El alto de cada cuadro
--@param columns Numero de columnas en la imagen
--@param rows Numero de filas en la imagen
--@param frameDuration Cuanto dura cada cuadro en segundos
--@usage local myAnimation = animations.new("assets/sprites/player-Sheet.png", 32, 32, 3, 3, 0.1)
--@return (animation) La animacion creada
function animations.new(imagePath, gridWidth, gridHeight, columns, rows, frameDuration)
    --Revisa si los parametros son validos
    assert(type(gridWidth) == "number" and gridWidth > 0, "Invalid gridWidth: expected positive number, got " .. tostring(gridWidth))
    assert(type(gridHeight) == "number" and gridHeight > 0, "Invalid gridHeight: expected positive number, got " .. tostring(gridHeight))
    assert(type(columns) == "number" and columns > 0, "Invalid columns: expected positive number, got " .. tostring(columns))
    assert(type(rows) == "number" and rows > 0, "Invalid rows: expected positive number, got " .. tostring(rows))
    assert(type(frameDuration) == "number" and frameDuration > 0, "Invalid frameDuration: expected positive number, got " .. tostring(frameDuration))
    assert(type(imagePath) == "string", "Invalid imagePath: expected string, got " .. tostring(imagePath))

    local self = setmetatable({}, {__index = animations})
    self.sprite = love.graphics.newImage(imagePath)
    self.gridWidth = gridWidth
    self.gridHeight = gridHeight
    self.columns = columns
    self.rows = rows

    self.OnFinish = Signal.new()
    self.OnLoop = Signal.new()

    self.currFrame = 1
    self.elapsedTime = 0
    self.frameDuration = frameDuration
    self.playing = true
    self.loop = true
    self.reversed = false
    self.anchor = {0, 0}
    self.visible = true

    self.quads = {}
    local frameIndex = 1
    for y = 0, rows - 1 do
        for x = 0, columns - 1 do
            local quad = love.graphics.newQuad(x * gridWidth, y * gridHeight, gridWidth, gridHeight, self.sprite:getDimensions())
            self.quads[frameIndex] = {x + 1, y + 1, quad}
            frameIndex = frameIndex + 1
        end
    end
    table.insert(addedAnimations, self)
    return self
end

---
--Reproduce la animacion
--@usage myAnimation:Play()
function animations:Play()
    if self._destroying then return end
    self.playing = true
end

---
--Pausa la animacion
--@usage myAnimation:Pause()
function animations:Pause()
    if self._destroying then return end
    self.playing = false
end

---
--Detiene la animacion
--Tambien ejecuta OnFinish
--@param reset Opcional: Si es true, resetea la animacion al primer frame
--@usage myAnimation:Stop()
function animations:Stop(reset)
    if self._destroying then return end
    self.playing = false
    if reset then
        self:Reset()
    end
    self.OnFinish:Fire()
end

---
--Resetea la animacion al primer frame
--@usage myAnimation:Reset()
function animations:Reset()
    if self._destroying then return end
    self.currFrame = 1
    self.elapsedTime = 0
end

---
--Va a un frame especifico de la animacion
--@param frame El frame al que se quiere ir
--@usage myAnimation:GoToFrame(2)
function animations:GoToFrame(frame)
    if self._destroying then return end
    if frame < 1 or frame > self.columns * self.rows then
        error("Frame out of bounds: " .. tostring(frame))
    end
    self.currFrame = frame
    self.elapsedTime = (frame - 1) * self.frameDuration
end

---
--Actualiza el modulo de animacion
--@param dt Delta time
--@usage myAnimation:update(dt)
function animations:update(dt)
    if not self.playing or self._destroying then return end

    self.elapsedTime = self.elapsedTime + dt
    if self.elapsedTime >= self.frameDuration then
        local framesToAdvance = math.floor(self.elapsedTime / self.frameDuration)
        self.elapsedTime = self.elapsedTime % self.frameDuration

        if self.reversed then
            self.currFrame = self.currFrame - framesToAdvance
            if self.currFrame < 1 then
                if self.loop then
                    self.OnLoop:Fire()
                    self.currFrame = self.columns * self.rows + self.currFrame
                else
                    self.OnFinish:Fire()
                    self.currFrame = 1
                    self.playing = false
                end
            end
        else
            self.currFrame = self.currFrame + framesToAdvance
            if self.currFrame > self.columns * self.rows then
                if self.loop then
                    self.OnLoop:Fire()
                    self.currFrame = (self.currFrame - 1) % (self.columns * self.rows) + 1
                else
                    self.OnFinish:Fire()
                    self.currFrame = self.columns * self.rows
                    self.playing = false
                end
            end
        end
    end
end

---
-- Destruye la animacion
function animations:Destroy()
    self.playing = false
    self._destroying = true
    for i,v in pairs(addedAnimations) do
        if v == self then table.remove(addedAnimations, i) end
    end
    self.OnFinish.callbacks = {}
    self.OnLoop.callbacks = {}
    self = nil
end

---
--Dibuja la animacion
--@param x La posicion x en la pantalla
--@param y La posicion y en la pantalla
--@param width El ancho del dibujo
--@param height La altura del dibujo
--@usage myAnimation:draw()
function animations:draw(x, y)
    if not self.visible or self._destroying then return end
    local quad = self.quads[self.currFrame][3]
    local drawX = x - self.anchor[1] * self.gridWidth
    local drawY = y - self.anchor[2] * self.gridHeight
    love.graphics.draw(self.sprite, quad, drawX, drawY, 0, 3, 3)
end

---
-- Consigue todas las animaciones añadidas
--@return (table) Una tabla con todas las animaciones
function animations.getAllAnimations()
    return addedAnimations
end

return animations
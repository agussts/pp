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
--@param looped Opcional: Si la animacion se repite, si no esta marcado, es true por defecto
--@param reversed Opcional: Si la animacion va al reves, si no esta marcado, es false por defecto
--@usage local myAnimation = animations.new("assets/sprites/player-Sheet.png", 32, 32, 3, 3, 0.1, true, false)
--@return (animation) La animacion creada
function animations.new(imagePath, gridWidth, gridHeight, columns, rows, frameDuration, looped, reversed)
    --Revisa si los parametros son validos
    assert(type(gridWidth) == "number" and gridWidth > 0, "Invalid gridWidth: expected positive number, got " .. tostring(gridWidth))
    assert(type(gridHeight) == "number" and gridHeight > 0, "Invalid gridHeight: expected positive number, got " .. tostring(gridHeight))
    assert(type(columns) == "number" and columns > 0, "Invalid columns: expected positive number, got " .. tostring(columns))
    assert(type(rows) == "number" and rows > 0, "Invalid rows: expected positive number, got " .. tostring(rows))
    assert(type(frameDuration) == "number" and frameDuration > 0, "Invalid frameDuration: expected positive number, got " .. tostring(frameDuration))
    assert(type(imagePath) == "string", "Invalid imagePath: expected string, got " .. tostring(imagePath))

    local self = setmetatable({}, {__index = animations})
    self.image = love.graphics.newImage(imagePath)
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
    self.loop = looped or true
    self.reversed = reversed or false

    self.quads = {}
    local frameIndex = 1
    for y = 0, columns - 1 do
        for x = 0, rows - 1 do
            local quad = love.graphics.newQuad(x * gridWidth, y * gridHeight, gridWidth, gridHeight, self.image:getDimensions())
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
    self.playing = true
end

---
--Pausa la animacion
--@usage myAnimation:Pause()
function animations:Pause()
    self.playing = false
end

---
--Detiene la animacion
--Tambien ejecuta OnFinish
--@param reset Opcional: Si es true, resetea la animacion al primer frame
--@usage myAnimation:Stop()
function animations:Stop(reset)
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
    self.currFrame = 1
    self.elapsedTime = 0
end

---
--Va a un frame especifico de la animacion
--@param frame El frame al que se quiere ir
--@usage myAnimation:GoToFrame(2)
function animations:GoToFrame(frame)
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
    if not self.playing then return end

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
--Dibuja la animacion
--@param x La posicion x en la pantalla
--@param y La posicion y en la pantalla
--@param width El ancho del dibujo
--@param height La altura del dibujo
--@usage myAnimation:draw()
function animations:draw(x, y, width, height)
    local quad = self.quads[self.currFrame][3]
    love.graphics.draw(self.image, quad, x, y, 0, width / self.gridWidth, height / self.gridHeight)
end

---
-- Consigue todas las animaciones añadidas
--@return (table) Una tabla con todas las animaciones
function animations.getAllAnimations()
    return addedAnimations
end

return animations
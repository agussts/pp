---
-- Modulo para manejar temporizadores.
--@classmod timer

local timer = {}
timer.passedTime = 0

local timers = {}
local timersAfter = {}
local timersEvery = {}

timer.group = {}

function timer.group.new()
    local self = setmetatable({}, { __index = timer.group })
    self.timers = {}
    self.playing = true
    self.pauseStart = 0
    self.pauseEnd = 0
    self.pausedTime = 0
    return self
end

function timer.group:addTimer(t)
    assert(t and t.check, "Invalid timer")
    -- si el grupo está en pausa, pausa el timer solo si estaba playing
    if not self.playing and t.playing then
        t:pause()
    end
    table.insert(self.timers, t)
end

function timer.group:pause()
    if not self.playing then return end
    self.playing = false
    self.pauseStart = timer.passedTime or 0
    for _, t in ipairs(self.timers) do
        if t and t.pause then t:pause() end
    end
end

function timer.group:continue()
    if self.playing then return end
    self.playing = true
    self.pauseEnd = timer.passedTime or 0
    local ps = self.pauseStart or self.pauseEnd or 0
    local delta = self.pauseEnd - ps
    if delta > 0 then
        self.pausedTime = (self.pausedTime or 0) + delta
    end
    self.pauseStart = nil
    for _, t in ipairs(self.timers) do
        if t and t.continue then t:continue() end
    end
end


function timer.group:getTimePassed()
    return timer.passedTime - self.pausedTime
end

function timer.addToGroup(timer, group)
    group:addTimer(timer)
end

---
-- Crea un nuevo temporizador
--@param time (number) El tiempo en segundos que durara el temporizador
--@usage myTimer = Timer.new(5)
function timer.new(time)
    local self = setmetatable({}, { __index = timer })
    self._currTime = timer.passedTime or 0
    self.time = time
    self.playing = true
    self._pauseStart = nil
    self._pauseEnd = nil
    self._pauseTime = 0
    table.insert(timers, self)
    return self
end


function timer:addToGroup(group)
    assert(group and group.timers, "Invalid group")
    group:addTimer(self)
end

---
-- Verifica si el temporizador ha terminado.
--@return (boolean) Verdadero si el temporizador ha terminado, falso en caso contrario
--@usage 
-- if myTimer:check() then
--     print("Timer has finished!")
-- end
function timer:check()
    if not self.playing then return false end
    return self.time + self._currTime  + self._pauseTime <= timer.passedTime
end

---
-- Reinicia el temporizador.
--@usage myTimer:reset()
function timer:reset()
    self._currTime = timer.passedTime
end

---
-- Pausa el temporizador.
--@usage myTimer:pause()
function timer:pause()
    if not self.playing then return end
    self.playing = false
    self._pauseStart = timer.passedTime or 0
end

---
-- Despausa el temporizador.
--@usage myTimer:continue()
function timer:continue()
    if self.playing then return end
    self._pauseEnd = timer.passedTime or 0
    -- Defaults defensivos
    local ps = self._pauseStart or self._currTime or self._pauseEnd or 0
    local delta = self._pauseEnd - ps
    if delta > 0 then
        self._pauseTime = (self._pauseTime or 0) + delta
    end
    -- limpiar estado de pausa para la próxima
    self._pauseStart, self._pauseEnd = nil, nil
    self.playing = true
end

---
-- Destruye el temporizador.
--@usage myTimer:Destroy()
function timer:Destroy()
    self:pause()
    self:reset()
    for i,v in pairs(timers) do
        if v == self then
            table.remove(timers, i)
            break
        end
    end
    for i,v in pairs(timersAfter) do
        if v == self then
            table.remove(timersAfter, i)
            break
        end
    end
    for i,v in pairs(timersEvery) do
        if v == self then
            table.remove(timersEvery, i)
            break
        end
    end
    for i,_ in pairs(self) do
        self[i] = nil
    end
    self = nil
end

---
-- Crea un temporizador que se ejecuta una vez después de un tiempo determinado.
--@param time (number) El tiempo en segundos que durara el temporizador
--@param callback (function) La funcion que se ejecutara cuando el temporizador termine
--@usage myTimer = Timer.after(5, function() print("Timer has finished!") end)
--@return (timer) El temporizador creado
function timer.after(time, callback)
    local self = timer.new(time)
    self.callback = callback
    table.insert(timersAfter, self)
    return self
end

---
-- Crea un temporizador que se ejecuta en intervalos regulares.
--@param time (number) El tiempo en segundos entre cada ejecución del temporizador
--@param callback (function) La funcion que se ejecutara cuando el temporizador se active
--@usage myTimer = Timer.every(5, function() print("I get printed every 5 seconds!") end)
--@return (timer) El temporizador creado
function timer.every(time, callback)
    local self = timer.new(time)
    self.callback = callback
    table.insert(timersEvery, self)
    return self
end

---
-- Actualiza todos los temporizadores, tiene que ser usado en love.update(dt)
--@param dt (number) El delta time de love.update
--@usage Timer.update(dt)
function timer.update(dt)
    timer.passedTime = timer.passedTime + dt

    for i,v in pairs(timersEvery) do
        if v.time == nil or not v.playing then goto continue end
        if timer.passedTime >= v.time + v._currTime + v._pauseTime then
            v.callback()
            v:reset()
        end
        ::continue::
    end
    for i,v in pairs(timersAfter) do
        if v.time == nil or not v.playing then goto continue end
        if timer.passedTime >= v.time + v._currTime + v._pauseTime then
            v.callback()
            v:Destroy()
        end
        ::continue::
    end
end

---
-- Obtiene una lista de todos los temporizadores.
--@return (table) Una tabla con todos los temporizadores.
function timer.getTimers()
    return timers
end

return timer
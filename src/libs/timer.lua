---
-- Modulo para manejar temporizadores.
--@classmod timer

local timer = {}
timer.passedTime = 0

local timers = {}
local timersAfter = {}
local timersEvery = {}

---
-- Crea un nuevo temporizador
--@param time (number) El tiempo en segundos que durara el temporizador
--@usage myTimer = Timer.new(5)
function timer.new(time)
    local self = setmetatable({}, { __index = timer })
    self._currTime = timer.passedTime
    self.time = time
    self.playing = true
    self._pauseStart = 0
    self._pauseEnd = 0
    self._pauseTime = 0
    table.insert(timers, self)
    return self
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
    self.playing = false
    self._pauseStart = timer.passedTime
end

---
-- Despausa el temporizador.
--@usage myTimer:continue()
function timer:continue()
    self.playing = true
    self._pauseEnd = timer.passedTime
    self._pauseTime = self._pauseEnd - self._pauseStart
end

---
-- Destruye el temporizador.
--@usage myTimer:Destroy()
function timer:Destroy()
    self:pause()
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
            table.remove(timersAfter, i)
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
        if timer.passedTime >= v.time + v._currTime then
            v.callback()
            v:reset()
        end
    end
    for i,v in pairs(timersAfter) do
        if timer.passedTime >= v.time + v._currTime then
            v.callback()
            v:Destroy()
        end
    end
end

---
-- Obtiene una lista de todos los temporizadores.
--@return (table) Una tabla con todos los temporizadores.
function timer.getTimers()
    return timers
end

return timer
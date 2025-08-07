local timer = {}
timer.passedTime = 0

local timers = {}
local timersAfter = {}
local timersEvery = {}

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

function timer:check()
    if not self.playing then return false end
    return self.time + self._currTime  + self._pauseTime <= timer.passedTime
end

function timer:reset()
    self._currTime = timer.passedTime
end

function timer:pause()
    self.playing = false
    self._pauseStart = timer.passedTime
end

function timer:continue()
    self.playing = true
    self._pauseEnd = timer.passedTime
    self._pauseTime = self._pauseEnd - self._pauseStart
end

function timer:Destroy()
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
    return
end

function timer.after(time, callback, ...)
    local self = timer.new(time)
    self.callback = callback
    self.args = {...}
    table.insert(timersAfter, self)
    return self
end

function timer.every(time, callback, ...)
    local self = timer.new(time)
    self.callback = callback
    self.args = {...}
    table.insert(timersEvery, self)
    return self
end


function timer.update(dt)
    timer.passedTime = timer.passedTime + dt

    for i,v in pairs(timersEvery) do
        if timer.passedTime >= v.time + v._currTime then
            v.callback(unpack(v.args))
            v:reset()
        end
    end
    for i,v in pairs(timersAfter) do
        if timer.passedTime >= v.time + v._currTime then
            v.callback(unpack(v.args))
            v:Destroy()
        end
    end
end

function timer.getTimers()
    return timers
end

return timer
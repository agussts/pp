local timer = {}
timer.passedTime = 0

local timers = {}
local timersAfter = {}

function timer.new(time)
    local self = setmetatable({}, { __index = timer })
    self._currTime = timer.passedTime
    self.time = time
    table.insert(timers, self)
    return self
end

function timer:check()
    return self.time + self._currTime <= timer.passedTime
end

function timer:reset()
    self._currTime = timer.passedTime
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
    for i,_ in pairs(self) do
        self[i] = nil
    end
    return
end

function timer.after(time, callback, ...)
    local self = timer.new(time)
    self.callback = callback
    self.args = {...}
    table.insert(timersAfter, self)
    return self
end

function timer.update(dt)
    timer.passedTime = timer.passedTime + dt
    for i,v in pairs(timersAfter) do
        if timer.passedTime >= v.time + v._currTime then
            v.callback(table.unpack(v.args))
            v:Destroy()
        end
    end
end



return timer
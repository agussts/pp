local timer = {}
timer.passedTime = 0

local timers = {}

function timer.after(time, callback, ...)
    local self = setmetatable({}, { __index = timer })
    self._currTime = timer.passedTime
    self.time = time
    self.callback = callback
    self.args = {...}
    table.insert(timers, self)
    return self
end

function timer.update(dt)
    timer.passedTime = timer.passedTime + dt
    for i,v in pairs(timers) do
        if timer.passedTime >= v.time + v._currTime then
            v.callback(unpack(v.args))
            table.remove(timers, i)
            v = nil
        end
    end
end



return timer
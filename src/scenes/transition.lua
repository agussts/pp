-- src/scene/transition.lua
local Transition = {}

Transition.active = false
Transition.alpha = 0
Transition.speed = 2.2
Transition.onMid = nil
Transition.phase = "idle" -- "out" -> "mid" -> "in"

function Transition.play(doAtMid)
    if Transition.active then return end
    Transition.active = true
    Transition.alpha = 0
    Transition.phase = "out"
    Transition.onMid = doAtMid
end

function Transition.update(dt)
    if not Transition.active then return end

    if Transition.phase == "out" then
        Transition.alpha = math.min(1, Transition.alpha + Transition.speed * dt)
        if Transition.alpha >= 1 then
            Transition.phase = "mid"
            if Transition.onMid then Transition.onMid() end
        end
    elseif Transition.phase == "mid" then
        -- inmediatamente empezamos a volver
        Transition.phase = "in"
    elseif Transition.phase == "in" then
        Transition.alpha = math.max(0, Transition.alpha - Transition.speed * dt)
        if Transition.alpha <= 0 then
            Transition.phase = "idle"
            Transition.active = false
            Transition.onMid = nil
        end
    end
end

function Transition.draw()
    if not Transition.active and Transition.alpha <= 0 then return end
    love.graphics.setColor(0,0,0, Transition.alpha)
    local w,h = love.graphics.getDimensions()
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1,1,1,1)
end

function Transition.isPlaying()
    return Transition.active
end

return Transition

local FirewallGate = {}
FirewallGate.__index = FirewallGate

function FirewallGate.new(posScale, sizeScale, period, openFrac)
    local self = setmetatable({}, FirewallGate)
    self.collision = Collisions.new("box")
    self.collision.position = posScale or UDim2.fromScale(0.7, 0.5)
    self.collision.size     = sizeScale or UDim2.fromScale(0.06, 0.22)
    self.collision.anchor   = {0.5, 0.5}
    self.collision:AddTag("firewall")

    self.period   = period   or 1.6
    self.openFrac = openFrac or 0.6
    self.t        = 0
    self._wasOpen = false
    self._beepOn  = love.audio.newSource("assets/sfx/blip.wav","static")   -- añadido
    self._beepOff = love.audio.newSource("assets/sfx/hitHurt.wav","static")-- añadido

    return self
end

function FirewallGate:update(dt)
    self.t = (self.t + dt) % self.period
    local isOpen = (self.t <= self.period * self.openFrac)
    self.collision.enabled = not isOpen

    if isOpen ~= self._wasOpen then
        self._wasOpen = isOpen
        local s = (isOpen and self._beepOn or self._beepOff):clone()
        s:setVolume(0.4)
        s:play()
    end
end

function FirewallGate:draw()
    local x, y, w, h = self.collision:_getRenderRect()
    local blocking = self.collision.enabled

    if blocking then
        love.graphics.setColor(1, 0.25, 0.25, 0.55) -- rojo semitransp.
        love.graphics.rectangle("fill", x, y, w, h)
        -- rayas diagonales para “peligro”
        love.graphics.setColor(1, 0.1, 0.1, 0.8)
        local step = 8
        for i = -h, w, step do
            love.graphics.line(x+i, y, x+i+ h, y+h)
        end
    else
        love.graphics.setColor(0.3, 1, 0.55, 0.25) -- verde “pasa”
        love.graphics.rectangle("fill", x, y, w, h)
    end
    love.graphics.setColor(1,1,1,1)
end

function FirewallGate:Destroy()
    if self.collision then self.collision:Destroy() end
    self.collision = nil
end

return FirewallGate

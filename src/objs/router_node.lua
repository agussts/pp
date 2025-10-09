-- RouterNode: nodo que "desencriptas" con un quiz. Si ganas, cuenta como shard (sin crear Shard).
-- Buen patrón para variar: aquí el quiz va ANTES de recibir el shard.

local RouterNode = {}
RouterNode.__index = RouterNode

function RouterNode.new(id, posScale)
    local self = setmetatable({}, RouterNode)
    self.id = id

    self.anim = Animation.new("assets/sprites/windowthing.png", 106, 83, 1, 1, 1)
    self.anim:Pause()
    self.anim.anchor = {0.5, 0.5}

    self.pos = posScale or UDim2.fromScale(0.55, 0.45)

    -- Prompt para iniciar
    self.prompt = ProxPrompt.new("Press [%s] to decrypt")
    self.prompt.collision.position = self.pos
    self.prompt.collision.size     = UDim2.fromScale(0.10, 0.16)
    self.prompt.collision.anchor   = {0.5, 0.5}

    self._done = false
    self._conn = self.prompt.Triggered:Connect(function()
        if self._done then return end
        MathQuiz.start({
            rounds  = 3,      -- ajustable
            timePer = 20,
            onWin   = function()
                self._done = true
                if self.prompt then self.prompt:Destroy() end
                -- Marca el shard como recolectado
                World.onShardCollected(self.id)
                -- Satisfacción visual
                Camera.shake(4, 0.25, "XY")
            end,
            onLose  = function()
                -- nada; se puede reintentar
            end
        })
    end)

    return self
end

function RouterNode:update()
    self.prompt:update()
end

function RouterNode:draw()
    function RouterNode:draw()
    local x, y = self.pos:toPixels()
    if self._done then
        self.anim.color = {0.6, 1, 0.6, 1}
    else
        self.anim.color = {1, 1, 1, 1}
    end
    self.anim:draw(x, y)

    -- panel central que “pulsa” para atraer
    if not self._done then
        local w, h = 46, 46
        local pulse = 1 + 0.06 * math.sin((PlayingTimers:getTimePassed() or 0)*6)
        local px, py = x - w/2, y - h/2
        love.graphics.setColor(1, 0.2, 0.2, 0.65)
        love.graphics.rectangle("line", px, py, w*pulse, h*pulse)
        love.graphics.setColor(1,1,1,1)
    end
end

end

function RouterNode:Destroy()
    if self.prompt then self.prompt:Destroy() end
    self.prompt = nil
    self._conn  = nil
end

return RouterNode

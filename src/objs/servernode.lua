--- Servidor destructible del Data Center.
-- Romperlo da puntos y notifica a un callback. Se comporta como "box" (bloquea).
-- Props recomendadas en Tiled:
--   - points (number): puntaje al destruir
--   - hp     (number): vida (por defecto 40)
--   - sprite (string): ruta opcional (1x1 frame o sheet simple)
--   - w,h    (número de pixels de frame si usas sprite custom)
local ServerNode = {}
ServerNode.__index = ServerNode

local audios = {
    serverbreak = love.audio.newSource("assets/sfx/serverbreak.wav", "static"),
    hit = love.audio.newSource("assets/sfx/hitgeneral.wav", "static"),
}

--- Crea un servidor destructible.
-- @tparam UDim2 pos Posición del servidor.
-- @tparam number hp Vida del servidor (default 40).
-- @tparam number points Puntos al destruir (default 20).
-- @treturn ServerNode El servidor creado.
function ServerNode.new(pos, hp, points)
    local self = setmetatable({}, ServerNode)

    self.sprite = Animation.new("assets/sprites/server.png", 32, 38, 1, 1, 1)
    self.sprite:Pause()
    self.sprite.anchor = {.5,.5}

    self.collision = Collisions.new("box")
    self.collision.position = pos or UDim2.fromScale(.5,.5)
    self.collision.size     = UDim2.fromScale(.08, .16)
    self.collision.anchor   = {.5,.5}
    self.collision.link     = self
    self.collision:AddTag("server")

    self.health  = hp or 40
    self.points  = points or 20
    self.onDestroyed = Signal.new()
    self._destroying  = false
    self._flash = 0
    self._flashDur = .1

    return self
end

function ServerNode:Damage(dmg)
    if self._destroying then return end
    self.health = self.health - (dmg or 0)
    self._flash = 1
    audios.hit:clone():play()
    Timer.after(self._flashDur, function() self._flash = 0 end):addToGroup(PlayingTimers)

    if self.health <= 0 then
        self._destroying = true
        audios.serverbreak:clone():play()
        if self.onDestroyed then
            self.onDestroyed:Fire()
        end
        self:Destroy()
    end
end

function ServerNode:update(dt)
    if self._destroying then return end
    self.sprite:update(dt)
end

function ServerNode:draw()
    if self._destroying then return end
    local x,y = self.collision.position:toPixels()
    if self._flash > 0 then
        love.graphics.setShader(Shaders.flash)
        Shaders.flash:send("u_flash", self._flash)
    end
    self.sprite:draw(x, y)
    love.graphics.setShader()
end

function ServerNode:Destroy()
    for i,v in pairs(self) do
        if type(v) == "table" and v.Destroy then
            v:Destroy()
        end
    end
    self.collision = nil
    self.sprite = nil
end

return ServerNode

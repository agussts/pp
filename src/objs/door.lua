-- src/objs/door.lua
local Door = {}
Door.__index = Door

-- args = { to = "level2", position = UDim2, size = UDim2, label = "..." }
function Door.new(to, position, size)
    local self = setmetatable({}, Door)
    assert(type(to)=="string", "to has to be a registered destination scene name")
    self.to = to
    -- Hitbox: no bloquea al jugador, solo detecta contacto
    self.collision = Collisions.new("hitbox")
    self.collision.position = position or UDim2.fromScale(.8, .5)
    self.collision.size     = size     or UDim2.fromScale(.06, .12)
    self.collision:AddTag("door")

    -- Conectar señal de colisión
    self.connection = self.collision.onHit:Connect(function(other)
        if Transition.isPlaying() then return end
        for _, tag in ipairs(other.tags or {}) do
            if tag == "player" then
                Transition.play(function()
                    Scene.load(self.to, { fromDoor = true })
                end)
                break
            end
        end
    end)

    return self
end

function Door:Destroy()
    self.connection:Disconnect()
    self.collision:Destroy()
end

return Door

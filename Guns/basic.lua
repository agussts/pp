local gun = {}
local collisions = require("collisions")

function gun.new()
    local self = setmetatable({}, { __index = gun })
    self.name = "Basic Gun"
    self.damage = 10
    self.ammo = 30
    self.maxAmmo = 30
    self.fireRate = 0.5
    self.lastFireTime = 0
    self.speed = 500
    self.rechargeTime = 2

    self.tags = {"gun", "projectile"}

    return self
end

function gun:Fire(x, y)
    if self.lastFireTime > 0 then
        return
    end
    if self.ammo <= 0 then
        print("Out of ammo!")
        self.lastFireTime = self.rechargeTime
        self.ammo = self.maxAmmo
        print("Reloading... Ammo refilled to " .. self.ammo)
        return
    end
    self.ammo = self.ammo - 1
    local collider
    collider = collisions.new("hitbox", 0, 0, 50, 50, false, function (otherCollider)
        for i,v in pairs(otherCollider.tags) do
            if v == "player" or v == "projectile" then return end
        end
        print("Gun hit collider at:".. otherCollider.type)
        collider:Destroy()
    end)
    collider.tags = self.tags
    print("firing")
    local mouseX, mouseY = love.mouse.getPosition()
    local dx = mouseX - x
    local dy = mouseY - y
    collider.x = x
    collider.y = y
    local distance = math.sqrt(dx*dx + dy*dy)
    collider.speedY = (dy / distance) * self.speed
    collider.speedX = (dx / distance) * self.speed
    print("Collider speed: (" .. collider.speedX .. ", " .. collider.speedY .. ")")
    collider.enabled = true
    self.lastFireTime = self.fireRate
    return
end
return gun
local gun = {}
local collisions = require("libs.collisions")
local timer      = require("libs.timer")
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

function gun:Fire(x, y, scale)
    if self.lastFireTime > 0 then
        return
    end
    if self.ammo <= 0 then
        self.lastFireTime = self.rechargeTime
        self.ammo = self.maxAmmo
        return
    end
    self.ammo = self.ammo - 1
    local collider
    collider = collisions.new("hitbox", 0, 0, 25, 25, false, function (otherCollider)
        for i,v in pairs(otherCollider.tags) do
            if v == "player" or v == "projectile" then return end
        end
        for i,v in pairs(otherCollider.tags) do
            if v == "box" then
                love.audio.newSource("assets/sfx/blip.wav", "static"):play()
            elseif v == "enemy" then
                love.audio.newSource("assets/sfx/hitHurt.wav", "static"):play()
                otherCollider.link.health = otherCollider.link.health - self.damage
            end
        end
        collider:Destroy()
    end)
    collider.tags = self.tags
    local mouseX, mouseY = love.mouse.getPosition()
    mouseX = mouseX / scale
    mouseY = mouseY / scale
    local dx = mouseX - x
    local dy = mouseY - y
    collider.x = x
    collider.y = y
    local distance = math.sqrt(dx*dx + dy*dy)
    collider.speedY = (dy / distance) * self.speed
    collider.speedX = (dx / distance) * self.speed
    collider.enabled = true
    self.lastFireTime = self.fireRate
    love.audio.newSource("assets/sfx/shoot.wav", "static"):play()

    timer.after(8, function()
        collider:Destroy()
    end)
    return
end
return gun
---
-- Pistola basica, tambien la base de otras pistolas
--@classmod basicGun

local gun = {}

local audios = {
    hit = love.audio.newSource("assets/sfx/hitHurt.wav", "static"),
    boxhit = love.audio.newSource("assets/sfx/blip.wav", "static"),
    shoot = love.audio.newSource("assets/sfx/shoot.wav", "static")
}

---
-- Crea una nueva pistola
--@return (basicGun) La nueva pistola creada
--@usage local myGun = Gun.new()
function gun.new()
    local self = setmetatable({}, { __index = gun })
    self.name = "Basic Gun"
    self.damage = 10
    self.ammo = World.gun.ammo
    self.maxAmmo = 30
    self.fireRate = 0.5
    self.lastFireTime = 0
    self.speed = 500
    self.rechargeTime = 2

    self.tags = {"gun", "projectile"}

    return self
end

---
--Dispara la pistola
--@param x (number) La posicion X desde donde se dispara
--@param y (number) La posicion Y desde donde se dispara
--@usage myGun:Fire(100, 200)
function gun:Fire(x, y)
    if self.lastFireTime > 0 then
        return
    end
    if self.ammo <= 0 then
        self.lastFireTime = self.rechargeTime
        self.ammo = self.maxAmmo
        World.gun.ammo = self.maxAmmo
        return
    end
    self.ammo = self.ammo - 1
    World.gun.ammo = self.ammo
    local collider
    collider = Collisions.new("hitbox", true)
    collider.onHit:Connect(function (otherCollider)
        if otherCollider:HasTag("player") or otherCollider:HasTag("projectile") then return end
        if otherCollider:HasTag("enemy") then
            audios.hit:clone():play()
            otherCollider.link:Damage(self.damage)
        elseif otherCollider:HasTag("box") then
            audios.boxhit:clone():play()
        end
        collider:Destroy()
    end)
    
    for _,v in pairs(self.tags) do
        collider:AddTag(v)
    end
    collider.link = self
    local mouseX, mouseY = Camera.screenToWorld(love.mouse:getPosition())
    mouseX = mouseX
    mouseY = mouseY
    local dx = mouseX - x
    local dy = mouseY - y
    collider.position = UDim2.new(0, x, 0, y)
    collider.position:toScale()
    collider.size = UDim2.new(0.04, 0, 0.07, 0)
    local distance = math.sqrt(dx*dx + dy*dy)
    collider.speedY = (dy / distance) * self.speed
    collider.speedX = (dx / distance) * self.speed
    collider.enabled = true
    self.lastFireTime = self.fireRate
    audios.shoot:clone():play()

    Timer.after(8, function()
        collider:Destroy()
    end):addToGroup(PlayingTimers)
end

return gun
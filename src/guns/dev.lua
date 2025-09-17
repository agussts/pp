---
-- Pistola de desarrollo, para pruebas y desarrollo
--@classmod devGun
--@see basicGun

local gun = {}

local basic = require("src.guns.basic")

---
--Crea una nueva pistola de desarrollo
--@return (devGun) La nueva pistola de desarrollo creada
--@usage local myDevGun = DevGun.new()
gun.new = function()
    local self = basic.new()
    self.name = "dev g"
    self.fireRate = .1
    self.damage = 5
    self.ammo = math.huge
    self.maxAmmo = math.huge

    gun.__index = basic

    return self
end

return gun
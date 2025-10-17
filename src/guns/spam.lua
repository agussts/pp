---
-- Pistola de disparo rapido, se basa en basicGun
--@classmod spamGun
--@see basicGun

local gun = {}

local basic = require("src.guns.basic")

---
-- Crea una nueva pistola de disparo rapido
--@return (spamGun) La nueva pistola de disparo rapido creada
--@usage local mySpamGun = SpamGun.new()
gun.new = function()
    local self = basic.new()
    self.name = "Spam Gun"
    self.fireRate = .1
    self.damage = 3

    gun.__index = basic

    return self
end

return gun
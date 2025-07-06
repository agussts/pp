local gun = {}

local basic = require("Guns/basic")

gun.new = function()
    local self = basic.new()
    self.name = "Spam Gun"
    self.fireRate = .1
    self.damage = 3
    self.ammo = 20

    gun.__index = basic

    return self
end

return gun
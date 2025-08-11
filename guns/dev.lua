---
--@module devGun
--@extends basicGun
--@classmod devGun
local gun = {}

local basic = require("Guns.basic")

gun.new = function()
    local self = basic.new()
    self.name = "dev g"
    self.fireRate = .1
    self.damage = 10
    self.ammo = math.huge
    self.maxAmmo = math.huge

    gun.__index = basic

    return self
end

return gun
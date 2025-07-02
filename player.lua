local module = {}

module.name = "player"
module.version = "0.1.0"
module.controls = {
    [{"x", -1}] = "a",
    [{"x", 1}] = "d",
    [{"y", -1}] = "w",
    [{"y", 1}] = "s"
}

module.new = function (sprite)
    local self = setmetatable({}, { __index = module })

    self.x = 0
    self.y = 0
    self.speed = 5
    self.sprite = sprite

    return self
end

function module:UpdateInput()
   local input = {}

   for i, v in pairs(self.controls) do
       if love.keyboard.isDown(v) then
            self[i[1]] = self[i[1]] + self.speed * i[2]
       end
   end
   return input
end
return module
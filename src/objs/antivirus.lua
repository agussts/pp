local antivirus = {}

antivirus.__index = antivirus

function antivirus.new()
   local antivirusSheet = Animation.new("assets/sprites/antivirusv2-Sheet.png", 26, 18, 4, 3, .1)
   antivirusSheet.anchor = {.5, .5}
   local self = EnemyModule.new(antivirusSheet, .05, .08)
   self.health = 50
   self.damage = 5
   return self
end

return antivirus
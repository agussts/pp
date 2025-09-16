local antivirus = {}

antivirus.__index = antivirus

function antivirus.new()
   local self = EnemyModule.new(nil, 30, 30) 
   setmetatable(self, antivirus)
   return self
end

return antivirus
-- src/features/cosmetics.lua
local Cosmetics = {}

-- Player: intenta cubrir anim / sprite habituales
local function applyToPlayer(enabled)
  if not Player then return end
  local s = Shaders and Shaders.rehueGreen
  local val = enabled and 1.0 or 0.0
  local playerDraw = Player.draw
  function Player:draw()
    love.graphics.setShader(s)
    Shaders.rehueGreen:send("u_enabled", val)
    playerDraw(self)
    love.graphics.setShader()
  end
end


function Cosmetics.applyToCurrentPlayer()
  if not Player or not Shaders or not Shaders.rehueGreen then return end
  local s   = Shaders.rehueGreen
  local val = (Config and Config.ConfigTable and Config.ConfigTable.GREEN_MODE) and 1.0 or 0.0

  -- evita re-wrap múltiple
  if Player._greenWrapped then
    s:send("u_enabled", val)
    return
  end

  local prevDraw = Player.draw
  function Player:draw(...)
    love.graphics.setShader(s)
    s:send("u_enabled", val)
    prevDraw(self, ...)
    love.graphics.setShader()
  end
  Player._greenWrapped = true
end

-- Balas: si las dibujas con setColor, cambia el tinte
-- Expón un setter muy simple para que tu bullet system lo use.
local BULLET_RED   = {1.0, 0.2, 0.2, 1.0}
local BULLET_GREEN = {0.2, 1.0, 0.35, 1.0}
local _bulletTint  = BULLET_RED

function Cosmetics.getBulletTint()
  return _bulletTint
end
function Cosmetics.applyGreenMode(enabled)
  applyToPlayer(enabled)
  _bulletTint = enabled and BULLET_GREEN or BULLET_RED
end

return Cosmetics

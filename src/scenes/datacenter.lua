-- src/scenes/datacenter.lua (solo el orden)
return function()
  local scene = {}

  scene.load = function(self, payload)
    self.bgA = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
    self.bgB = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
    self.bgA.color = {1,.2,1,0.05}
    self.bgB.color = {.2,1,1,0.02}

    self.map = TiledLite.load("assets/maps/datacenter.lua", { collisionLayers={"Colliders"} })
    --self.map:spawnAll(self)
    self.map.worldLayer = -10

    self.dc = require("src.features.datacentertiled")
    self.dc.attach(self, self.map)

    -- Player / arma / spawn
    Player = PlayerModule.new("assets/sprites/player-Sheet.png")
    local spawn = (payload and payload.spawn) or self.playerspawn or UDim2.fromScale(1, 2.5)
    Player.collision.position = spawn
    self.player = Player

    Gun = GunModule.new()
    self.gun = Gun
  end

  scene.update = function(self, dt)
    self.bgA:setScroll(self.bgA.scrollX + 30*dt, self.bgA.scrollY - 15*dt)
    self.bgB:setScroll(self.bgB.scrollX - 15*dt, self.bgB.scrollY + 30*dt)
    self.bgA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
    self.bgB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)

    self.dc.update(self, dt)

    local px,py = Player.collision.position:toPixels()
    Camera.update(px, py)
  end

  scene.draw = function(self)
    self.bgA:drawBackground()
    self.bgB:drawBackground()
    Camera.attach()
      self.map:draw()     -- el mapa va abajo
      self.dc.draw(self)  -- servers/enemigos/gates encima
    Camera.detach()
  end

  scene.unload = function(self)
    self.dc.detach(self)
    self.map = nil
  end

  return scene
end

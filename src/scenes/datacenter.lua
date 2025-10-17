-- src/scenes/datacenter_room.lua
return function()
  local scene = {}

  scene.load = function(self, payload)
    -- Fondos (como en tus otras escenas)
    self.bgA = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
    self.bgB = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
    self.bgA.color = {1,.2,1,0.05}
    self.bgB.color = {.2,1,1,0.02}
    self.dc = require("src.features.datacentertiled")

    -- Mapa Tiled (exportado a Lua)
    self.map = TiledLite.load("assets/maps/datacenter.lua", { collisionLayers={"Colliders"} })
    self.map.worldLayer = -10
    self.map:spawnAll(self)
    -- self.map.draw = function ()
        
    -- end

    -- Player
    Player = PlayerModule.new("assets/sprites/player-Sheet.png")
    local spawn = (payload and payload.spawn) or self.playerspawn or UDim2.fromScale(1, 2.5)
    Player.collision.position = spawn
    self.player = Player

    -- Arma
    Gun = GunModule.new()
    self.gun = Gun

    -- Datacenter: lee objetos del mapa y arma todo
    self.dc.attach(self, self.map)
  end

  scene.update = function(self, dt)
    -- Parallax simple (igual que tus otras escenas)
    self.bgA:setScroll(self.bgA.scrollX + 30*dt, self.bgA.scrollY - 15*dt)
    self.bgB:setScroll(self.bgB.scrollX - 15*dt, self.bgB.scrollY + 30*dt)
    self.bgA.color[4] = 0.035 + 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)
    self.bgB.color[4] = 0.035 - 0.015 * math.sin(PlayingTimers:getTimePassed() * 2)

    -- Lógica del Data Center (HEAT, respawns, enemigos, shard…)
    self.dc.update(self, dt)

    -- Cámara
    local px,py = Player.collision.position:toPixels()
    Camera.update(px, py)
  end

  scene.draw = function(self)
    self.bgA:drawBackground()
    self.bgB:drawBackground()
    Camera.attach()
      --self.map:draw()   -- TiledLite ya dibuja en coords de mundo
      self.dc.draw(self)  -- Dibuja pads, enemigos, shard…
    Camera.detach()
  end

  scene.unload = function(self)
    self.dc.detach(self)
    self.map = nil
  end

  return scene
end

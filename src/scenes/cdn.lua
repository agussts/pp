-- src/scenes/cdn.lua
return function()
  local scene = {}

  scene.load = function(self, payload)
    love.graphics.setBackgroundColor(34/255, 32/255, 52/255)

    -- mapa desde Tiled con las clases "cdn_*"
    self.map = TiledLite.load("assets/maps/cdn.lua")
    self.map.worldLayer = -10

    -- jugador
    Player = PlayerModule.new("assets/sprites/player-Sheet.png")
    self.player = Player

    -- (opcional) pistola
    Gun = GunModule.new()

    -- enganchar feature
    self.cdn = require("src.features.cdn_catwalks").attach(self, self.map)
    if World.shards.collectedIds["cdn_shard"] then
      self.shard:Destroy()
    end

    Player.collision.position = self.playerspawn or UDim2.fromScale(.15, .75)
    Player.Dash = function (...) end
  end

  scene.update = function(self, dt)

    local px,py = Player.collision.position:toPixels()
    Camera.update(px, py)

    if self.cdn and self.cdn.update then self.cdn:update(dt) end
  end

  scene.draw = function(self)

    Camera.attach()
      -- dibuja tiles del mapa si quieres aquí
      if self.cdn and self.cdn.draw then self.cdn:draw() end
    Camera.detach()
  end

  scene.unload = function(self)
    love.graphics.setBackgroundColor(0,0,0)
    if self.cdn and self.cdn.detach then self.cdn:detach() end
    self.map = nil
  end

  return scene
end

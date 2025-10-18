-- src/scenes/cdn.lua
return function()
  local scene = {}

  scene.load = function(self, payload)
    self.bgA = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
    self.bgB = Background.new("assets/sprites/xthingy.png", 32*3, 18*3, 1,1)
    self.bgA.color = {1,.2,1,0.04}
    self.bgB.color = {.2,1,1,0.02}

    -- mapa desde Tiled con las clases "cdn_*"
    self.map = TiledLite.load("assets/maps/cdn.lua", { collisionLayers={"Colliders"} })
    self.map.worldLayer = -10

    -- jugador
    Player = PlayerModule.new("assets/sprites/player-Sheet.png")
    self.player = Player

    -- (opcional) pistola
    Gun = GunModule.new()

    -- enganchar feature
    self.cdn = require("src.features.cdn_catwalks").attach(self, self.map)
        Player.collision.position = self.playerspawn or UDim2.fromScale(.15, .75)

  end

  scene.update = function(self, dt)
    self.bgA:setScroll(self.bgA.scrollX + 30*dt, self.bgA.scrollY - 15*dt)
    self.bgB:setScroll(self.bgB.scrollX - 15*dt, self.bgB.scrollY + 30*dt)
    self.bgA.color[4] = 0.03 + 0.01 * math.sin(PlayingTimers:getTimePassed() * 2)
    self.bgB.color[4] = 0.03 - 0.01 * math.sin(PlayingTimers:getTimePassed() * 2)

    local px,py = Player.collision.position:toPixels()
    Camera.update(px, py)

    if self.cdn and self.cdn.update then self.cdn:update(dt) end
  end

  scene.draw = function(self)
    self.bgA:drawBackground()
    self.bgB:drawBackground()

    Camera.attach()
      -- dibuja tiles del mapa si quieres aquí
      if self.cdn and self.cdn.draw then self.cdn:draw() end
    Camera.detach()
  end

  scene.unload = function(self)
    if self.cdn and self.cdn.detach then self.cdn:detach() end
    self.map = nil
  end

  return scene
end

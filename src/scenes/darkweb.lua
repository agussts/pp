return function ()
    local scene = {}
    scene.load = function (self)
        self.bg = Background.new("assets/sprites/darkwebbg.png", 640*2, 360*2, .5, .5)
        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        Player.collision.position = UDim2.fromScale(.5, .5)
        self.player = Player
    end
    scene.update = function (self, dt)

    end
    scene.start = function (self)

    end
    scene.draw = function (self)
        self.bg:draw()
    end
    return scene
end
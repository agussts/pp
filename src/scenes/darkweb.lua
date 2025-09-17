return function ()
    local scene = {}
    scene.load = function (self)
        self.bg = Background.new("assets/sprites/darkwebbg.png", 640, 360, .5, .5)
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
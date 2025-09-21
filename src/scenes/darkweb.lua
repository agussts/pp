return function ()
    local scene = {}
    scene.load = function (self)
        self.bg = Background.new("assets/sprites/darkwebbg.png", 640, 360)
        self.bg:setRepeat(false)
        Player = PlayerModule.new("assets/sprites/player-Sheet.png")
        Player.collision.position = UDim2.fromScale(.1, .8)
        self.player = Player
        local anim = Animation.new("assets/sprites/mvirus-Sheet.png", 41, 41, 3, 3, .1)
        anim:addHole(3, 3)
        anim.anchor = {1.6, 1.6}
        self.mvirus = Block.new(anim, .575, .7, .06, .1)
        self.mvirus.collision.anchor = {.5, .5}
        self.exit = Door.new("internetscn", UDim2.fromScale(0, .75), UDim2.fromScale(.025, .3))
    end
    scene.update = function (self, dt)
        local w, h = love.graphics.getDimensions()
        Camera.update(w/2, h/2)
    end
    scene.start = function (self)

    end
    scene.draw = function (self)
        self.bg:drawBackground()
    end
    return scene
end
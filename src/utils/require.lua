--Requiere modulos
Config = require("src.utils.config_manager")

Signal = require("src.libs.signal")
Timer = require("src.libs.timer")
Collisions = require("src.libs.collisions")
UDim2 = require("src.guis.udim2")
Animation = require("src.libs.animation")
Guis = require("src.guis.gui")

    Button = require("src.guis.button")
    Textlabel = require("src.guis.textlabel")
    Frame = require("src.guis.frame")
    ImageLabel = require("src.guis.imagelabel")

PlayerModule = require("src.objs.player")
EnemyModule = require("src.objs.enemy")
GunModule = require("src.guns.dev")
Gun = GunModule.new()
    
Camera = require("src.libs.camera")
Background = require("src.libs.background")

Scene = require("src.scenes.scene")
Transition = require("src.scenes.transition")
--Requiere modulos
Config = require("src.utils.config_manager")

--Esencial
Signal = require("src.libs.signal")
require("src.libs.connections") -- no necesita variable para identificar, ya que es global
Timer = require("src.libs.timer")
Collisions = require("src.libs.collisions")
UDim2 = require("src.guis.udim2")
Animation = require("src.libs.animation")
Fonts = require("src.utils.fonts")

--GUI
Guis = require("src.guis.gui")

    Button = require("src.guis.button")
    Textlabel = require("src.guis.textlabel")
    Frame = require("src.guis.frame")
    ImageLabel = require("src.guis.imagelabel")
    PrintfLabel = require("src.guis.printf_label")

--UI (no preguntes la diferencia)

ShardsHUD = require("src.ui.shards_hud")
require("src.ui.pausemenu") -- lo mismo que connections.lua

--Styles

    Border = require("src.guis.styles.border")

--Objects
Block = require("src.objs.block")
PlayerModule = require("src.objs.player")
EnemyModule = require("src.objs.enemy")
Antivirus = require("src.objs.antivirus")
Door = require("src.objs.door")
ProxPrompt = require("src.objs.proximityprompt")
Shard = require("src.objs.shard")
CacheBox   = require("src.objs.cachebox")
FirewallGate = require("src.objs.firewall_gate")
RouterNode = require("src.objs.router_node")
ProximityHum = require("src.objs.proximity_hum")


GunModule = require("src.guns.dev")
    
Camera = require("src.libs.camera")
Background = require("src.libs.background")

-- Scenes
Scene = require("src.scenes.scene")
Transition = require("src.scenes.transition")
TiledLite = require("src.libs.tiledlite")

Shaders = require("src.libs.shaders")
Dialogue = require("src.libs.dialogue")
WrittenDialogues = require("src.utils.writtendialogues")

World = require("src.utils.world")

-- Minigames

MathQuiz = require("src.minigames.mathquiz")


DevTools = require("src.utils.devtools")

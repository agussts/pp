-- src/utils/devtools.lua
-- Hotkeys de desarrollo: fáciles de habilitar / deshabilitar.
-- Requiere: connections (Connect/Fire), Collisions, Scene, PlayerModule, Camera, UDim2, etc.

local DevTools = {
    enabled       = true,
    hitboxesOn    = true, -- TEMPORAL: CAMBIAR A false DESPUES
    overlayOn     = false, 
    _overlayGui   = nil,
    _keyConn      = nil,
    _tickTimer    = nil,
}

-- Helpers
local function isModsDown()
    -- Ctrl + Alt como “combo”
    return (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"))
        and (love.keyboard.isDown("lalt")  or love.keyboard.isDown("ralt"))
end

local function toggleHitboxes()
    DevTools.hitboxesOn = not DevTools.hitboxesOn

    -- A) actualizar los colliders EXISTENTES
    for _,c in pairs(Collisions.getCollisions()) do
        c.visualized = DevTools.hitboxesOn
    end

    -- B) fijar el valor por defecto para colliders NUEVOS
    if Collisions.setDefaultVisualized then
        Collisions.setDefaultVisualized(DevTools.hitboxesOn)
    end

    print("[Dev] Hitboxes:", DevTools.hitboxesOn and "ON" or "OFF")
end


local function giveDevGun()
    local DevGun = require("src.guns.dev")
    Gun = DevGun.new()
    print("[Dev] Dev gun entregada.")
end

local function reloadScene()
    if Transition and Transition.isPlaying and Transition.isPlaying() then return end
    if Transition and Transition.play then
        Transition.play(function() Scene.reload() end)
    else
        Scene.reload()
    end
    print("[Dev] Escena recargada.")
end

local function killPlayer()
    if Player and Player.Damage then
        Player:Damage(99999)
        print("[Dev] Player KILL solicitado.")
    end
end

local function ensureOverlay()
    if DevTools._overlayGui then return end
    local box = Frame.new()
    box:setPersistent(true)
    box.position = UDim2.fromScale(0, 0)
    box.size     = UDim2.fromScale(0.28, 0.12)
    box.bgColor  = {0,0,0,0.45}
    box.zIndex   = 1000
    box.visible  = false

    local label = Textlabel.new("")
    label:setParent(box)
    label.position   = UDim2.fromScale(0.02, 0.32)
    label.size       = UDim2.fromScale(0.96, 0.96)
    label.anchorPoint= {0,0}
    label.textColor  = {1,1,1,1}
    label.zIndex     = (box.zIndex or 0) + 1

    DevTools._overlayGui = { box = box, label = label }
end

local function toggleNoclip()
    print("[Dev] Noclip toggled.")
    Player.collision.blockFilter = function ()
        return false
    end
end

local function toggleOverlay()
    ensureOverlay()
    DevTools.overlayOn = not DevTools.overlayOn
    DevTools._overlayGui.box.visible   = DevTools.overlayOn
    DevTools._overlayGui.label.visible = DevTools.overlayOn
    print("[Dev] Overlay:", DevTools.overlayOn and "ON" or "OFF")
end

local function updateOverlayText()
    if not DevTools.overlayOn or not DevTools._overlayGui then return end
    local fps = love.timer.getFPS()
    local px, py = 0, 0
    if Player and Player.collision and Player.collision.position then
        px, py = Player.collision.position.x.scale, Player.collision.position.y.scale
    end
    local collCount = #Collisions.getCollisions()
    local camx, camy = Camera.x or 0, Camera.y or 0
    DevTools._overlayGui.label.text=
        ("FPS: %d\nPlayer: (%.3f, %.3f)\nCamera: (%.1f, %.1f)\nColliders: %d\nHitboxes: %s")
        :format(fps, px, py, camx, camy, collCount, DevTools.hitboxesOn and "ON" or "OFF")
end

-- Key dispatcher
local function onKeyPressed(key)
    if not DevTools.enabled then return end
    if not isModsDown() then return end

    -- Mapa de atajos
    if key == "h" then
        toggleHitboxes()
    elseif key == "g" then
        giveDevGun()
    elseif key == "r" then
        reloadScene()
    elseif key == "k" then
        killPlayer()
    elseif key == "o" then
        toggleOverlay()
    elseif key == "n" then
        toggleNoclip()
    end
end

function DevTools.init()
    if DevTools._keyConn then return end
    ensureOverlay()

    -- Suscribir una sola vez
    DevTools._keyConn = Connect("keyPressed", onKeyPressed)

    -- Refresco “ligero” del overlay (10Hz) usando el sistema de timers que ya tienes
    DevTools._tickTimer = Timer.every(0.1, function()
        updateOverlayText()
    end)
    DevTools._tickTimer:addToGroup(PlayingTimers)

    if Collisions.setDefaultVisualized then
        Collisions.setDefaultVisualized(DevTools.hitboxesOn)
    end
    print("[Dev] Hotkeys activos: Ctrl+Alt como mods, H (hitboxes), G (dev gun), R (reload), K (kill), O (overlay)")
end

function DevTools.shutdown()
    DevTools.enabled = false
    if DevTools._keyConn and DevTools._keyConn.Disconnect then
        DevTools._keyConn:Disconnect()
    end
    DevTools._keyConn = nil

    if DevTools._tickTimer then DevTools._tickTimer:Destroy() end
    DevTools._tickTimer = nil

    if DevTools._overlayGui then
        if DevTools._overlayGui.label and DevTools._overlayGui.label.Destroy then DevTools._overlayGui.label:Destroy() end
        if DevTools._overlayGui.box   and DevTools._overlayGui.box.Destroy   then DevTools._overlayGui.box:Destroy() end
        DevTools._overlayGui = nil
    end
end

return DevTools

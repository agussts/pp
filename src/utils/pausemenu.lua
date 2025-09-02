-- Estados del juego
Gamestates = { "playing", "paused" }
Gamestate = "playing"

-- Estados del menu de pausa
PauseStates = { "menu", "settings", "keybinds" }
PauseState = "menu"

-- Creamos el contenedor principal de la interfaz
local pauseMenuContainer = Frame.new()
pauseMenuContainer.size = UDim2.fromScale(1, 1)
pauseMenuContainer.bgColor = {0, 0, 0, 0.65}
pauseMenuContainer.visible = false
pauseMenuContainer.zIndex = -1

local listThing = Frame.new()
listThing.size = UDim2.fromScale(0.4, 1)
listThing.position = UDim2.fromScale(0.5, 0.5)
listThing.anchorPoint = {0.5, 0.5}
listThing.bgColor = {1, 1, 1, 0}
listThing:setParent(pauseMenuContainer)


-- -------------------------------------------
-- -- Funciones de Gestion de Estado del Menu
-- -------------------------------------------

local menus = {}

local function showMenu(state)
    for _, menu in pairs(menus) do
        for _, gui in pairs(menu) do
            gui.visible = false
        end
    end
    
    local targetMenu = menus[state]
    if targetMenu then
        for _, gui in pairs(targetMenu) do
            gui.visible = true
        end
        PauseState = state
    end
end

-- -------------------------------------------
-- -- Funciones de Ayuda (Helpers)
-- -------------------------------------------

-- Helper para crear un boton con texto
local function createTextButton(parent, position, size, text, callback)
    local btn = Button.new(callback)
    btn:setParent(parent)
    btn.bgColor = {0.3, 0.3, 0.3, 1}
    btn.position = position
    btn.size = size
    btn.anchorPoint = {0.5, 0.5}

    local textlabel = Textlabel.new(text)
    textlabel:setParent(btn)
    textlabel.position = UDim2.fromScale(0.5, 0.5)
    textlabel.size = UDim2.fromScale(1, 1)
    textlabel.anchorPoint = {0.5, 0.5}
    textlabel.textColor = {1, 1, 1, 1}
    textlabel.zIndex = 1

    return btn, textlabel
end


-- Helper para crear un frame con texto
local function createTextFrame(parent, position, size, text)
    local frame = Frame.new()
    frame:setParent(parent)
    frame.position = position
    frame.size = size
    frame.bgColor = {0.3, 0.3, 0.3, 1}

    local textlabel = Textlabel.new(text)
    textlabel:setParent(frame)
    textlabel.position = UDim2.fromScale(0.5, 0.5)
    textlabel.size = UDim2.fromScale(1, 1)
    textlabel.anchorPoint = {0.5, 0.5}
    textlabel.textColor = {1, 1, 1, 1}
    textlabel.zIndex = 1

    return frame, textlabel
end

-- Helper para crear un boton con imagen
local function createImageButton(parent, position, size, imagePath, callback)
    local btn = Button.new(callback)
    btn:setParent(parent)
    btn.position = position
    btn.size = size
    btn.anchorPoint = {0.5, 0.5}
    btn.bgColor = {0 , 0, 0, 0}

    local image = ImageLabel.new(imagePath)
    image:setParent(btn)
    image.position = UDim2.fromScale(0, 0)
    image.size = UDim2.fromScale(1, 1)

    return btn, image
end

local function deepCopy(original)
    local copy = {}
    for i, v in pairs(original) do
        if type(v) == "table" then
            copy[i] = deepCopy(v)
        else
            copy[i] = v
        end
    end
    return copy
end


-- -------------------------------------------
-- -- Menu Principal
-- -------------------------------------------

local function createMainMenu(parent)
    local menu = {}

    local resumeBtn, resumeText = createTextButton(
        parent,
        UDim2.fromScale(0.5, 0.1),
        UDim2.fromScale(0.8, 0.1),
        "Resume",
        function ()
            PauseMenu()
        end
    )
    table.insert(menu, resumeBtn)
    table.insert(menu, resumeText)

    local settingsBtn, settingsText = createTextButton(
        parent,
        UDim2.fromScale(0.5, 0.3),
        UDim2.fromScale(0.8, 0.1),
        "Settings",
        function ()
            showMenu("settings")
        end
    )
    table.insert(menu, settingsBtn)
    table.insert(menu, settingsText)

    local quitBtn, quitText = createTextButton(
        parent,
        UDim2.fromScale(0.5, 0.9),
        UDim2.fromScale(0.8, 0.1),
        "Quit",
        love.event.quit
    )
    table.insert(menu, quitBtn)
    table.insert(menu, quitText)

    return menu
end


-- -------------------------------------------
-- -- Menú de Ajustes
-- -------------------------------------------

local function createSettingsMenu(parent)
    local menu = {}
    local prevConfig = deepCopy(Config.ConfigTable)

    local titleText = Textlabel.new("Settings")
    titleText:setParent(parent)
    titleText.position = UDim2.fromScale(0, 0)
    titleText.size = UDim2.fromScale(1, 0.1)
    titleText.textColor = {1, 1, 1, 1}
    table.insert(menu, titleText)

    -- Boton para acceder a keybinds
    local keybindsBtn, keybindsText = createTextButton(
        parent,
        UDim2.fromScale(0.5, 0.15),
        UDim2.fromScale(0.8, 0.1),
        "Keybinds",
        function ()
            showMenu("keybinds")
        end
    )
    table.insert(menu, keybindsBtn)
    table.insert(menu, keybindsText)

    -- Logica para Checkbox
    local function createCheckBox(pos, text, name)
        local btn
        local btnImg
        btn = Button.new(function ()
            Config.ConfigTable[name] = not Config.ConfigTable[name]
            local newImage = Config.ConfigTable[name] and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png"
            btnImg.image = love.graphics.newImage(newImage)
        end)
        btn:setParent(parent)
        btn.bgColor = {0, 0, 0, 0}
        btn.position = pos
        btn.size = UDim2.fromScale(0.15, 0.1)

        btnImg = ImageLabel.new(Config.ConfigTable[name] and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
        btnImg:setParent(parent)
        btnImg.position = btn.position
        btnImg.size = btn.size * 1.5
        btnImg.anchorPoint = {0, 0.35}
        btnImg.zIndex = 5

        local label = Textlabel.new(text)
        label:setParent(btn)
        label.position = UDim2.fromScale(1.2, 0)
        label.size = UDim2.fromScale(2, 1)
        label.anchorPoint = {0, 0}

        return btn, label, btnImg
    end

    local borderlessCb, borderlessLabel, borderlessImg = createCheckBox(UDim2.fromScale(0.2, 0.25), "Borderless", "BORDERLESS")
    table.insert(menu, borderlessCb)
    table.insert(menu, borderlessLabel)
    table.insert(menu, borderlessImg)

    local vsyncCb, vsyncLabel, vsyncImg = createCheckBox(UDim2.fromScale(0.2, 0.4), "VSync", "VSYNC")
    table.insert(menu, vsyncCb)
    table.insert(menu, vsyncLabel)
    table.insert(menu, vsyncImg)

    --Logica para la Resolucion

    local resolutionText = Textlabel.new("Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height)
    resolutionText:setParent(parent)
    resolutionText.position = UDim2.fromScale(0.2, 0.55)
    resolutionText.size = UDim2.fromScale(0.6, 0.1)
    resolutionText.textColor = {1, 1, 1, 1}
    table.insert(menu, resolutionText)

    local resLeft, resLeftImg = createImageButton(
        parent,
        UDim2.fromScale(0.15, 0.6),
        UDim2.fromScale(0.075, 0.075),
        "assets/sprites/arrow_left.png",
        function ()
            Config.ConfigTable.RESOLUTION = Config.ConfigTable.RESOLUTION - 1
            if Config.ConfigTable.RESOLUTION < 1 then
                Config.ConfigTable.RESOLUTION = #Config.Resolutions
            end
            resolutionText.text = "Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height
        end
    )
    table.insert(menu, resLeft)
    table.insert(menu, resLeftImg)

    local resRight, resRightImg = createImageButton(
        parent,
        UDim2.fromScale(0.85, 0.6),
        UDim2.fromScale(0.075, 0.075),
        "assets/sprites/arrow_right.png",
        function ()
            Config.ConfigTable.RESOLUTION = Config.ConfigTable.RESOLUTION + 1
            if Config.ConfigTable.RESOLUTION > #Config.Resolutions then
                Config.ConfigTable.RESOLUTION = 1
            end
            resolutionText.text = "Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height
        end
    )
    table.insert(menu, resRight)
    table.insert(menu, resRightImg)

    -- Logica para el Slider de Volumen
    local sliderFrame, sliderText = createTextFrame(
        parent,
        UDim2.fromScale(0.5, 0.7),
        UDim2.fromScale(0.9, 0.05),
        "Volume"
    )
    sliderFrame.anchorPoint = {0.5, 0.5}
    sliderFrame.bgColor = {0.5, 0.5, 0.5, 1}
    table.insert(menu, sliderFrame)
    table.insert(menu, sliderText)

    local sliderBtn = Button.new()
    sliderBtn:setParent(sliderFrame)
    sliderBtn.position = UDim2.fromScale(Config.ConfigTable.VOLUME, 0.5)
    sliderBtn.size = UDim2.fromScale(0.15, 2)
    sliderBtn.anchorPoint = {0.5, 0.5}
    sliderBtn.bgColor = {1, 1, 1, 0}

    local sliderImg = ImageLabel.new("assets/sprites/slider.png")
    sliderImg:setParent(sliderBtn)
    sliderImg.size = UDim2.fromScale(1, 1)
    sliderImg.zIndex = 2
    sliderBtn.whenPressing = function ()
        local sliderX, _ = sliderFrame:getRenderPosition()
        local sliderWidth, _ = sliderFrame:getRenderSize()
        local mouseX = love.mouse.getX()
        local x = math.max(sliderX, math.min(mouseX, sliderX + sliderWidth))
        local newScale = (x - sliderX) / sliderWidth
        
        sliderBtn.position = UDim2.fromScale(newScale, 0.5)
        Config.ConfigTable.VOLUME = math.floor(newScale * 100) / 100 -- Redondea a dos decimales
    end
    table.insert(menu, sliderBtn)
    table.insert(menu, sliderImg)


    local backBtn, backText = createTextButton(
        parent,
        UDim2.fromScale(.2, 0.925),
        UDim2.fromScale(0.55, 0.1),
        "Back",
        function ()
            showMenu("menu")
        end
    )
    table.insert(menu, backBtn)
    table.insert(menu, backText)

    local applyBtn, applyText = createTextButton(
        parent,
        UDim2.fromScale(0.8, 0.925),
        UDim2.fromScale(0.55, 0.1),
        "Apply",
        function ()
            Config.saveConfig()
            Config.updateWindow()
            prevConfig = deepCopy(Config.ConfigTable)
            showMenu("menu")
        end
    )
    table.insert(menu, applyBtn)
    table.insert(menu, applyText)

    local revertBtn, revertText = createTextButton(
        parent,
        UDim2.fromScale(0.2, .8),
        UDim2.fromScale(0.55, 0.1),
        "Revert Settings",
        function ()
            sliderBtn.position.x.scale = prevConfig.VOLUME
            borderlessImg.image = love.graphics.newImage(prevConfig.BORDERLESS and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            vsyncImg.image = love.graphics.newImage(prevConfig.VSYNC and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            resolutionText.text = "Resolution: " .. Config.Resolutions[prevConfig.RESOLUTION].width .. "x" .. Config.Resolutions[prevConfig.RESOLUTION].height
            Config.ConfigTable = deepCopy(prevConfig)
        end
    )
    table.insert(menu, revertBtn)
    table.insert(menu, revertText)

    local revertDefaultsBtn, revertDefaultsText = createTextButton(
        parent,
        UDim2.fromScale(0.8, .8),
        UDim2.fromScale(0.55, 0.1),
        "Reset to Default",
        function ()
            sliderBtn.position.x.scale = Config.DefaultConfigs.VOLUME
            borderlessImg.image = love.graphics.newImage(Config.DefaultConfigs.BORDERLESS and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            vsyncImg.image = love.graphics.newImage(Config.DefaultConfigs.VSYNC and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            resolutionText.text = "Resolution: " .. Config.Resolutions[Config.DefaultConfigs.RESOLUTION].width .. "x" .. Config.Resolutions[Config.DefaultConfigs.RESOLUTION].height
            Config.ConfigTable = deepCopy(Config.DefaultConfigs)
        end
    )
    table.insert(menu, revertDefaultsBtn)
    table.insert(menu, revertDefaultsText)

    return menu
end

local function createKeybindsMenu()
    local menu = {}
    local keybindEntries = {}

    local titleText = Textlabel.new("Keybinds")
    titleText.position = UDim2.fromScale(0, 0)
    titleText.size = UDim2.fromScale(1, 0.1)
    titleText.textColor = {1, 1, 1, 1}
    table.insert(menu, titleText)               

    local function createKeybindEntry(actionName, position, text)
        local changeBtn, actionText
        changeBtn, actionText = createTextButton(
            nil,
            position,
            UDim2.fromScale(.3, .1),
            text.. (Config.ConfigTable[actionName] or "None"),
            function ()
                local prevKey = Config.ConfigTable[actionName]
                local function onKeyPress(key)
                    Disconnect("keyPressed", onKeyPress)

                    for i,v in pairs(Config.ConfigTable) do
                        if i ~= actionName and v == key then
                            Config.ConfigTable[i] = nil
                            keybindEntries[i].actionText.text = keybindEntries[i].actionText.text:gsub("..$", " None")
                        end
                    end

                    Config.ConfigTable[actionName] = key
                    actionText.text = text.. key
                end
                Connect("keyPressed", onKeyPress)
                Timer.after(5, function() 
                    if ConnectionExists("keyPressed", onKeyPress) then
                        Disconnect("keyPressed", onKeyPress)
                        print("took too long to press a key, reverting to previous keybind")
                        actionText.text = text .. (prevKey or "None")
                    end
                end):addToGroup(PauseMenuTimers)
            end
        )

        keybindEntries[actionName] = {button = changeBtn, actionText = actionText}
        return changeBtn, actionText
    end
    local leftBtn, leftText = createKeybindEntry("PLEFT", UDim2.fromScale(0.3, 0.2), "Move left: ")
    table.insert(menu, leftBtn)
    table.insert(menu, leftText)

    local rightBtn, rightText = createKeybindEntry("PRIGHT", UDim2.fromScale(0.3, 0.4), "Move right: ")
    table.insert(menu, rightBtn)
    table.insert(menu, rightText)

    local upBtn, upText = createKeybindEntry("PUP", UDim2.fromScale(0.3, 0.6), "Move up: ")
    table.insert(menu, upBtn)
    table.insert(menu, upText)

    local downBtn, downText = createKeybindEntry("PDOWN", UDim2.fromScale(0.3, 0.8), "Move down: ")
    table.insert(menu, downBtn)
    table.insert(menu, downText)

    local dashBtn, dashText = createKeybindEntry("PDASH", UDim2.fromScale(0.7, 0.2), "Dash: ")
    table.insert(menu, dashBtn)
    table.insert(menu, dashText)

    local backBtn, backText = createKeybindEntry("PBACK", UDim2.fromScale(0.7, 0.4), "Back: ")
    table.insert(menu, backBtn)
    table.insert(menu, backText)

    return menu
end
-- Inicialización de los menus
menus.menu = createMainMenu(listThing)
menus.settings = createSettingsMenu(listThing)
menus.keybinds = createKeybindsMenu()
showMenu("")

-- -------------------------------------------
-- -- Funciones Públicas
-- -------------------------------------------

function PauseMenu()
    if Gamestate == "playing" then
        PlayingTimers:pause()
        PauseMenuTimers:continue()
        Gamestate = "paused"
        pauseMenuContainer.visible = true
        showMenu("menu")
    elseif Gamestate == "paused" then
        print("resuming")
        Gamestate = "playing"
        showMenu("")
        PlayingTimers:continue()
        PauseMenuTimers:pause()
        -- local psStatePos = 1
        -- for i,v in pairs(PauseStates) do
        --     if v == PauseState then
        --         psStatePos = i
        --         break
        --     end
        -- end
        -- if psStatePos == 1 then
        --     showMenu("") -- Oculta todos los sub-menus
        -- else
        --     showMenu(PauseStates[psStatePos-1])
        -- end
        pauseMenuContainer.visible = false
    end
end
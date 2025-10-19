-- Estados del juego
Gamestates = { "playing", "paused" , "dialogue" , "intro" }
Gamestate = "playing"

-- Estados del menu de pausa
PauseStates = { "menu", "settings", "keybinds" }
PauseState = "menu"

-- Creamos el contenedor principal de la interfaz
local pauseMenuContainer = Frame.new()
pauseMenuContainer:setPersistent(true)
pauseMenuContainer.size = UDim2.fromScale(1, 1)
pauseMenuContainer.bgColor = {0, 0, 0, 0.65}
pauseMenuContainer.visible = false
pauseMenuContainer.zIndex = 500

local listThing = Frame.new()
listThing.size = UDim2.fromScale(0.4, 1)
listThing.position = UDim2.fromScale(0.5, 0.5)
listThing.anchorPoint = {0.5, 0.5}
listThing.bgColor = {1, 1, 1, 0}
listThing:setParent(pauseMenuContainer)

local otherList = Frame.new()
otherList.size = UDim2.fromScale(1, 1)
otherList.position = UDim2.fromScale(0.5, 0.5)
otherList.anchorPoint = {0.5, 0.5}
otherList.bgColor = {1, 1, 1, 0}
otherList:setParent(pauseMenuContainer)


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

    local accBtn, accText = createTextButton(
        parent,
        UDim2.fromScale(0.5, 0.27),
        UDim2.fromScale(0.8, 0.1),
        "Accessibility",
        function ()
            showMenu("accessibility")
        end
    )
    table.insert(menu, accBtn)
    table.insert(menu, accText)

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

    local borderlessCb, borderlessLabel, borderlessImg = createCheckBox(UDim2.fromScale(0.2, 0.35), "Borderless", "BORDERLESS")
    table.insert(menu, borderlessCb)
    table.insert(menu, borderlessLabel)
    table.insert(menu, borderlessImg)

    local vsyncCb, vsyncLabel, vsyncImg = createCheckBox(UDim2.fromScale(0.2, 0.47), "VSync", "VSYNC")
    table.insert(menu, vsyncCb)
    table.insert(menu, vsyncLabel)
    table.insert(menu, vsyncImg)

    --Logica para la Resolucion

    local resolutionText = Textlabel.new("Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height)
    resolutionText:setParent(parent)
    resolutionText.position = UDim2.fromScale(0.2, 0.57)
    resolutionText.size = UDim2.fromScale(0.6, 0.1)
    resolutionText.textColor = {1, 1, 1, 1}
    table.insert(menu, resolutionText)

    local resLeft, resLeftImg = createImageButton(
        parent,
        UDim2.fromScale(0.15, 0.62),
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
        UDim2.fromScale(0.85, 0.62),
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

local function createKeybindsMenu(parent)
    local menu = {}
    local prevConfig = deepCopy(Config.ConfigTable)
    local keybindEntries = {}

    local titleText = Textlabel.new("Keybinds")
    titleText:setParent(parent)
    titleText.position = UDim2.fromScale(0, 0)
    titleText.size = UDim2.fromScale(1, 0.1)
    titleText.textColor = {1, 1, 1, 1}
    table.insert(menu, titleText)               

    local function createKeybindEntry(actionName, position, text)
        local changeBtn, actionText
        changeBtn, actionText = createTextButton(
            parent,
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

    local rightBtn, rightText = createKeybindEntry("PRIGHT", UDim2.fromScale(0.3, 0.35), "Move right: ")
    table.insert(menu, rightBtn)
    table.insert(menu, rightText)

    local upBtn, upText = createKeybindEntry("PUP", UDim2.fromScale(0.3, 0.5), "Move up: ")
    table.insert(menu, upBtn)
    table.insert(menu, upText)

    local downBtn, downText = createKeybindEntry("PDOWN", UDim2.fromScale(0.3, 0.65), "Move down: ")
    table.insert(menu, downBtn)
    table.insert(menu, downText)

    local dashBtn, dashText = createKeybindEntry("PDASH", UDim2.fromScale(0.7, 0.2), "Dash: ")
    table.insert(menu, dashBtn)
    table.insert(menu, dashText)

    local intrBtn, intrText = createKeybindEntry("PINTR", UDim2.fromScale(0.7, 0.35), "Interact: ")
    table.insert(menu, intrBtn)
    table.insert(menu, intrText)

    local backBtn, backText = createKeybindEntry("PBACK", UDim2.fromScale(0.7, 0.5), "Back: ")
    table.insert(menu, backBtn)
    table.insert(menu, backText)

    local back, bckText = createTextButton(
        parent,
        UDim2.fromScale(.3, 0.925),
        UDim2.fromScale(0.3, 0.1),
        "Back",
        function ()
            showMenu("settings")
        end
    )
    table.insert(menu, back)
    table.insert(menu, bckText)

    local applyBtn, applyText = createTextButton(
        parent,
        UDim2.fromScale(0.7, 0.925),
        UDim2.fromScale(0.3, 0.1),
        "Apply",
        function ()
            Config.saveConfig()
            prevConfig = deepCopy(Config.ConfigTable)
            showMenu("settings")
        end
    )
    table.insert(menu, applyBtn)
    table.insert(menu, applyText)

    local revertBtn, revertText = createTextButton(
        parent,
        UDim2.fromScale(0.3, .8),
        UDim2.fromScale(0.3, 0.1),
        "Revert Settings",
        function ()
            leftText.text = "Move left: "..(prevConfig.PLEFT or "None")
            rightText.text = "Move right: "..(prevConfig.PRIGHT or "None")
            upText.text = "Move up: "..(prevConfig.PUP or "None")
            downText.text = "Move down: "..(prevConfig.PDOWN or "None")
            dashText.text = "Dash: "..(prevConfig.PDASH or "None")
            intrText.text = "Interact: "..(prevConfig.PINTR or "None")
            backText.text = "Back: "..(prevConfig.PBACK or "None")
            Config.ConfigTable = deepCopy(prevConfig)
        end
    )
    table.insert(menu, revertBtn)
    table.insert(menu, revertText)

    local revertDefaultsBtn, revertDefaultsText = createTextButton(
        parent,
        UDim2.fromScale(0.7, .8),
        UDim2.fromScale(0.3, 0.1),
        "Reset to Default",
        function ()
            leftText.text = "Move left: a"
            rightText.text = "Move right: d"
            upText.text = "Move up: w"
            downText.text = "Move down: s"
            dashText.text = "Dash: space"
            intrText.text = "Interact: e"
            backText.text = "Back: escape"
            Config.ConfigTable = deepCopy(Config.DefaultConfigs)
        end
    )
    table.insert(menu, revertDefaultsBtn)
    table.insert(menu, revertDefaultsText)

    return menu
end

local function createAccessibilityMenu(parent)
    local menu = {}

    -- === Defaults planos (si faltan claves) ===
    local FALLBACK_DEFAULTS = {
        HELP_SIGNS    = true,       -- carteles de ayuda visibles
        TEACH = true,       -- Teach.lua activo
        MAUDIENCE = "Kids",     -- "Kids" | "Teens"
        MTHEME    = "NetKids",  -- "NetKids" | "Tech"
    }

    -- asegúrate de que existan en Config.ConfigTable (planas)
    for k, v in pairs(FALLBACK_DEFAULTS) do
        if Config.ConfigTable[k] == nil then
            Config.ConfigTable[k] = v
        end
    end

    -- defaults globales (si tienes Config.DefaultConfigs, úsalo; si no, usa FALLBACK_DEFAULTS)
    local DEFAULTS = (Config.DefaultConfigs and {
        HELP_SIGNS    = (Config.DefaultConfigs.HELP_SIGNS    ~= nil) and Config.DefaultConfigs.HELP_SIGNS    or FALLBACK_DEFAULTS.HELP_SIGNS,
        TEACH = (Config.DefaultConfigs.TEACH ~= nil) and Config.DefaultConfigs.TEACH_ or FALLBACK_DEFAULTS.TEACH,
        MAUDIENCE = Config.DefaultConfigs.MAUDIENCE or FALLBACK_DEFAULTS.MAUDIENCE,
        MTHEME    = Config.DefaultConfigs.MTHEME    or FALLBACK_DEFAULTS.MTHEME,
    }) or FALLBACK_DEFAULTS

    -- snapshot para Revert
    local function takeSnapshot()
        return {
            HELP_SIGNS    = Config.ConfigTable.HELP_SIGNS,
            TEACH = Config.ConfigTable.TEACH,
            MAUDIENCE = Config.ConfigTable.MAUDIENCE,
            MTHEME    = Config.ConfigTable.MTHEME,
        }
    end
    local prevAcc = takeSnapshot()

    -- ===== Título =====
    local titleText = Textlabel.new("Accessibility")
    titleText:setParent(parent)
    titleText.position  = UDim2.fromScale(0, 0)
    titleText.size      = UDim2.fromScale(1, 0.1)
    titleText.textColor = {1, 1, 1, 1}
    table.insert(menu, titleText)

    -- ===== CheckBox helper (mismo estilo que Settings) =====
    local function createCheckBox(pos, text, keyName)
        local btn, btnImg

        btn = Button.new(function ()
            local newVal = not Config.ConfigTable[keyName]
            Config.ConfigTable[keyName] = newVal
            local newImage = newVal and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png"
            btnImg.image = love.graphics.newImage(newImage)
        end)
        btn:setParent(parent)
        btn.bgColor   = {0, 0, 0, 0}
        btn.position  = pos
        btn.size      = UDim2.fromScale(0.15, 0.1)

        btnImg = ImageLabel.new(Config.ConfigTable[keyName] and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
        btnImg:setParent(parent)
        btnImg.position    = btn.position
        btnImg.size        = btn.size * 1.5
        btnImg.anchorPoint = {0, 0.35}
        btnImg.zIndex      = 5

        local label = Textlabel.new(text)
        label:setParent(btn)
        label.position    = UDim2.fromScale(1.2, 0)
        label.size        = UDim2.fromScale(2, 1)
        label.anchorPoint = {0, 0}

        table.insert(menu, btn)
        table.insert(menu, label)
        table.insert(menu, btnImg)
        return btn, label, btnImg
    end

    -- ===== Checkboxes: Help Signs / Teach =====
    local helpBtn, helpLbl, helpImg = createCheckBox(UDim2.fromScale(0.2, 0.18), "Help Signs", "HELP_SIGNS")
    local teachBtn, teachLbl, teachImg = createCheckBox(UDim2.fromScale(0.2, 0.30), "Teach Helper", "TEACH")

    -- ===== Selectores con flechas (como Resolution): Audience / Theme =====
    local function createArrowSelector(yPos, labelText, values, keyName)
        local leftLabel = Textlabel.new(labelText)
        leftLabel:setParent(parent)
        leftLabel.position    = UDim2.fromScale(0, yPos)
        leftLabel.size        = UDim2.fromScale(0.3, 0.1)
        leftLabel.anchorPoint = {0, 0}
        leftLabel.textColor   = {1,1,1,1}
        table.insert(menu, leftLabel)

        local valueText = Textlabel.new("")
        valueText:setParent(parent)
        valueText.position    = UDim2.fromScale(0.6, yPos)
        valueText.size        = UDim2.fromScale(0.2, 0.1)
        valueText.anchorPoint = {0.5, 0}
        valueText.textColor   = {1,1,1,1}
        table.insert(menu, valueText)

        local function refreshValue()
            valueText.text = tostring(Config.ConfigTable[keyName])
        end

        local leftBtn, leftImg = createImageButton(
            parent,
            UDim2.fromScale(0.40, yPos + 0.05),
            UDim2.fromScale(0.075, 0.075),
            "assets/sprites/arrow_left.png",
            function ()
                local cur = Config.ConfigTable[keyName]
                local idx = 1
                for i,v in ipairs(values) do if v==cur then idx=i break end end
                idx = idx - 1
                if idx < 1 then idx = #values end
                Config.ConfigTable[keyName] = values[idx]
                refreshValue()
            end
        )
        table.insert(menu, leftBtn)
        table.insert(menu, leftImg)

        local rightBtn, rightImg = createImageButton(
            parent,
            UDim2.fromScale(0.80, yPos + 0.05),
            UDim2.fromScale(0.075, 0.075),
            "assets/sprites/arrow_right.png",
            function ()
                local cur = Config.ConfigTable[keyName]
                local idx = 1
                for i,v in ipairs(values) do if v==cur then idx=i break end end
                idx = idx + 1
                if idx > #values then idx = 1 end
                Config.ConfigTable[keyName] = values[idx]
                refreshValue()
            end
        )
        table.insert(menu, rightBtn)
        table.insert(menu, rightImg)

        refreshValue()
        return valueText
    end

    local audienceText = createArrowSelector(0.45, "MathQuiz Audience", {"Kids","Teens"}, "MAUDIENCE")
    local themeText = createArrowSelector(0.58, "MathQuiz Theme",    {"NetKids","Tech"}, "MTHEME")

    -- ===== Botones Back / Apply / Revert / Reset =====
    local backBtn, backText = createTextButton(
        parent,
        UDim2.fromScale(.2, 0.925),
        UDim2.fromScale(0.55, 0.1),
        "Back",
        function () showMenu("settings") end
    )
    table.insert(menu, backBtn); table.insert(menu, backText)

    local applyBtn, applyText = createTextButton(
        parent,
        UDim2.fromScale(0.8, 0.925),
        UDim2.fromScale(0.55, 0.1),
        "Apply",
        function ()
            Config.saveConfig()
            HELP_SIGNS    = Config.ConfigTable.HELP_SIGNS
            TEACH = Config.ConfigTable.TEACH
            MAUDIENCE = Config.ConfigTable.MAUDIENCE
            MTHEME    = Config.ConfigTable.MTHEME
            prevAcc = takeSnapshot()
            showMenu("settings")
        end
    )
    table.insert(menu, applyBtn); table.insert(menu, applyText)

    local revertBtn, revertText = createTextButton(
        parent,
        UDim2.fromScale(0.2, .8),
        UDim2.fromScale(0.55, 0.1),
        "Revert Settings",
        function ()
            Config.ConfigTable.HELP_SIGNS    = prevAcc.HELP_SIGNS
            Config.ConfigTable.TEACH = prevAcc.TEACH
            Config.ConfigTable.MAUDIENCE = prevAcc.MAUDIENCE
            Config.ConfigTable.MTHEME    = prevAcc.MTHEME
            helpImg.image = love.graphics.newImage(Config.ConfigTable.HELP_SIGNS and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            teachImg.image = love.graphics.newImage(Config.ConfigTable.HELP_SIGNS and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            audienceText.text = Config.ConfigTable.MAUDIENCE
            themeText.text = Config.ConfigTable.MTHEME
        end
    )
    table.insert(menu, revertBtn); table.insert(menu, revertText)

    local resetBtn, resetText = createTextButton(
        parent,
        UDim2.fromScale(0.8, .8),
        UDim2.fromScale(0.55, 0.1),
        "Reset to Default",
        function ()
            Config.ConfigTable.HELP_SIGNS    = Config.DefaultConfigs.HELP_SIGNS
            Config.ConfigTable.TEACH = Config.DefaultConfigs.TEACH
            Config.ConfigTable.MAUDIENCE = Config.DefaultConfigs.MAUDIENCE
            Config.ConfigTable.MTHEME    = Config.DefaultConfigs.MTHEME
            helpImg.image = love.graphics.newImage(Config.ConfigTable.HELP_SIGNS and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            teachImg.image = love.graphics.newImage(Config.ConfigTable.HELP_SIGNS and "assets/sprites/cbmark.png" or "assets/sprites/cbunmark.png")
            audienceText.text = Config.ConfigTable.MAUDIENCE
            themeText.text = Config.ConfigTable.MTHEME
        end
    )
    table.insert(menu, resetBtn); table.insert(menu, resetText)

    return menu
end



-- Inicialización de los menus
menus.menu = createMainMenu(listThing)
menus.settings = createSettingsMenu(listThing)
menus.keybinds = createKeybindsMenu(otherList)
menus.accessibility = createAccessibilityMenu(listThing)
showMenu("")

-- function PauseMenu_Open(substate)
--     if Gamestate == "dialogue" then return end
--     if Gamestate ~= "paused" then
--         if PlayingTimers and PlayingTimers.pause then PlayingTimers:pause() end
--         if PauseMenuTimers and PauseMenuTimers.continue then PauseMenuTimers:continue() end
--         Gamestate = "paused"
--         pauseMenuContainer.visible = true
--     end
--     showMenu(substate or "menu")
-- end

-- -------------------------------------------
-- -- Funciones Públicas
-- -------------------------------------------

function PauseMenu()
    if Gamestate == "dialogue" or Gamestate == "intro" then print("intro") return end
    print(Gamestate)
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
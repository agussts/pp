require("src.require")

Gamestates = {
        "playing",
        "paused"
    }
Gamestate = Gamestates[1]

local pauseMenuUi = {}

Bg = Frame.new()
Bg.size = UDim2.fromScale(1,1)
Bg.bgColor = {0,0,0,0.65}
Bg.visible = false
Bg.zIndex = -1
table.insert(pauseMenuUi, Bg)

ListThing = Frame.new()
ListThing.size = UDim2.fromScale(0.4, 1)
ListThing.position = UDim2.fromScale(.5, .5)
ListThing.anchorPoint = {.5, .5}
ListThing.bgColor = {1,1,1,0}

Resume = Button.new(function ()
    PauseMenu()
end)

Resume.parent = ListThing
Resume.bgColor = {0.3, 0.3, 0.3, 1}
Resume.position = UDim2.fromScale(0.5, 0.1)
Resume.size = UDim2.fromScale(0.8, 0.1)
Resume.anchorPoint = {0.5, 0.5}
table.insert(pauseMenuUi, Resume)

ResumeText = Textlabel.new()
ResumeText.text = "Resume"
ResumeText.textColor = {1, 1, 1, 1}
ResumeText.parent = ListThing
ResumeText.position = Resume.position
ResumeText.zIndex = 1
table.insert(pauseMenuUi, ResumeText)


Quit = Button.new(function ()
    love.event.quit()
end)
Quit.parent = ListThing
Quit.bgColor = {0.3, 0.3, 0.3, 1}
Quit.position = UDim2.fromScale(0.5, .9)
Quit.size = UDim2.fromScale(0.8, 0.1)
Quit.anchorPoint = {0.5, 0.5}
table.insert(pauseMenuUi, Quit)

QuitText = Textlabel.new()
QuitText.text = "Quit"
QuitText.textColor = {1, 1, 1, 1}
QuitText.parent = ListThing
QuitText.position = Quit.position
QuitText.zIndex = 1
table.insert(pauseMenuUi, QuitText)


local settingsUI = {}

local function createCheckBox(pos, text, marked, callback)
    local self = Button.new()
    self.parent = ListThing
    self.bgColor = {0,0,0,0}
    self.position = pos
    self.size = UDim2.fromScale(0.15, .1)
    table.insert(settingsUI, self)


    local pressed = marked
    local selfImg = ImageLabel.new("assets/sprites/cbunmark.png")

    if pressed then
        selfImg.image = love.graphics.newImage("assets/sprites/cbmark.png")
    else
        selfImg.image = love.graphics.newImage("assets/sprites/cbunmark.png")
    end

    selfImg.parent = ListThing
    selfImg.position = self.position
    selfImg.size = self.size * 1.5
    selfImg.anchorPoint = {0, 0.35}
    selfImg.zIndex = 5
    selfImg.visible = true
    table.insert(settingsUI, selfImg)

    local selfText = Textlabel.new()
    selfText.text = text
    selfText.textColor = {1, 1, 1, 1}
    selfText.parent = ListThing
    selfText.position = self.position + UDim2.fromScale(.2,0)
    selfText.size = self.size
    selfText.zIndex = 1
    table.insert(settingsUI, selfText)

    local selfFrame = Frame.new()
    selfFrame.parent = ListThing
    selfFrame.position = selfText.position
    selfFrame.size = self.size + UDim2.fromScale(0.25, 0)
    selfFrame.bgColor = {.5,.5,.5,1}
    table.insert(settingsUI, selfFrame)

    self.callback = function ()
        pressed = not pressed        
        if pressed then
            selfImg.image = love.graphics.newImage("assets/sprites/cbmark.png")
        else
            selfImg.image = love.graphics.newImage("assets/sprites/cbunmark.png")
        end
        callback()
    end
end

createCheckBox(UDim2.fromScale(.2, .1), "Borderless", Config.ConfigTable.BORDERLESS, function ()
    print(table.concat(Config.ConfigTable, "\n"))
    Config.ConfigTable.BORDERLESS = not Config.ConfigTable.BORDERLESS
end)
createCheckBox(UDim2.fromScale(.2, .3), "VSync", Config.ConfigTable.VSYNC, function ()
    Config.ConfigTable.VSYNC = not Config.ConfigTable.VSYNC
end)

Apply = Button.new(function ()
    print("Applying settings")
    Config.saveConfig()
    Config.updateWindow()
    for _,v in pairs(settingsUI) do
        v.visible = false
    end
    for _,v in pairs(pauseMenuUi) do
        if v == Bg or v == ListThing then goto continue end
        v.visible = true
        ::continue::
    end
end)
Apply.parent = ListThing
Apply.position = UDim2.fromScale(1, 0.9)
Apply.size = UDim2.fromScale(0.7, 0.1)
Apply.anchorPoint = {0.5, 0.5}
table.insert(settingsUI, Apply)

ApplyText = Textlabel.new()
ApplyText.text = "Apply"
ApplyText.textColor = {1, 1, 1, 1}
ApplyText.parent = ListThing
ApplyText.position = Apply.position
ApplyText.zIndex = 1
table.insert(settingsUI, ApplyText)

Back = Button.new(function ()
    for _,v in pairs(settingsUI) do
        v.visible = false
    end
    for _,v in pairs(pauseMenuUi) do
        if v == Bg or v == ListThing then goto continue end
        v.visible = true
        ::continue::
    end
end)
Back.parent = ListThing
Back.position = UDim2.fromScale(0, 0.9)
Back.size = UDim2.fromScale(0.7, 0.1)
Back.anchorPoint = {0.5, 0.5}
table.insert(settingsUI, Back)

BackText = Textlabel.new()
BackText.text = "Back"
BackText.textColor = {1, 1, 1, 1}
BackText.parent = ListThing
BackText.position = Back.position
BackText.zIndex = 1
table.insert(settingsUI, BackText)

for _,v in pairs(settingsUI) do
    v.visible = false
end

Settings = Button.new(function ()
    for _,v in pairs(settingsUI) do
        v.visible = true
    end
    for i,v in pairs(pauseMenuUi) do
        if v == Bg or v == ListThing then goto continue end
        v.visible = false
        ::continue::
    end
end)
Settings.parent = ListThing
Settings.bgColor = {0.3, 0.3, 0.3, 1}
Settings.position = UDim2.fromScale(0.5, 0.3)
Settings.size = UDim2.fromScale(0.8, 0.1)
Settings.anchorPoint = {0.5, 0.5}
table.insert(pauseMenuUi, Settings)

SettingsText = Textlabel.new()
SettingsText.text = "Settings"
SettingsText.textColor = {1, 1, 1, 1}
SettingsText.parent = ListThing
SettingsText.position = Settings.position
SettingsText.zIndex = 1
table.insert(pauseMenuUi, SettingsText)

for _,v in pairs(pauseMenuUi) do
    v.visible = false
end

function PauseMenu()
    if Gamestate == "playing" then
        Gamestate = Gamestates[2]
        for _,v in pairs(pauseMenuUi) do
            v.visible = true
        end
    elseif Gamestate == "paused" then
        Gamestate = Gamestates[1]
        for _,v in pairs(pauseMenuUi) do
            v.visible = false
        end
    end

end
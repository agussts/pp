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

Resume:setParent(ListThing)
Resume.bgColor = {0.3, 0.3, 0.3, 1}
Resume.position = UDim2.fromScale(0.5, 0.1)
Resume.size = UDim2.fromScale(0.8, 0.1)
Resume.anchorPoint = {0.5, 0.5}
table.insert(pauseMenuUi, Resume)

ResumeText = Textlabel.new()
ResumeText.text = "Resume"
ResumeText.textColor = {1, 1, 1, 1}
ResumeText:setParent(ListThing)
ResumeText.position = Resume.position
ResumeText.zIndex = 1
table.insert(pauseMenuUi, ResumeText)


Quit = Button.new(function ()
    love.event.quit()
end)
Quit:setParent(ListThing)
Quit.bgColor = {0.3, 0.3, 0.3, 1}
Quit.position = UDim2.fromScale(0.5, .9)
Quit.size = UDim2.fromScale(0.8, 0.1)
Quit.anchorPoint = {0.5, 0.5}
table.insert(pauseMenuUi, Quit)

QuitText = Textlabel.new()
QuitText.text = "Quit"
QuitText.textColor = {1, 1, 1, 1}
QuitText:setParent(ListThing)
QuitText.position = Quit.position
QuitText.zIndex = 1
table.insert(pauseMenuUi, QuitText)


local settingsUI = {}

SettingsText = Textlabel.new("Settings")
SettingsText:setParent(ListThing)
SettingsText.position = UDim2.fromScale(0, 0)
SettingsText.size = UDim2.fromScale(1, .1)
table.insert(settingsUI, SettingsText)

local function createCheckBox(pos, text, marked, callback)
    local self = Button.new()
    self:setParent(ListThing)
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

    selfImg:setParent(ListThing)
    selfImg.position = self.position
    selfImg.size = self.size * 1.5
    selfImg.anchorPoint = {0, 0.35}
    selfImg.zIndex = 5
    selfImg.visible = true
    table.insert(settingsUI, selfImg)

    local selfText = Textlabel.new()
    selfText.text = text
    selfText.textColor = {1, 1, 1, 1}
    selfText:setParent(ListThing)
    selfText.position = self.position + UDim2.fromScale(.2,0)
    selfText.size = self.size + UDim2.fromScale(0.25, 0)
    selfText.zIndex = 1
    table.insert(settingsUI, selfText)

    local selfFrame = Frame.new()
    selfFrame:setParent(ListThing)
    selfFrame.position = selfText.position
    selfFrame.size = selfText.size
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

local function createImg(gui, imgdir)
    local img = ImageLabel.new(imgdir)
    img:setParent(gui)
    img.size = UDim2.fromScale(1,1)
    img.zIndex = 2
    return img
end


createCheckBox(UDim2.fromScale(.2, .2), "Borderless", Config.ConfigTable.BORDERLESS, function ()
    Config.ConfigTable.BORDERLESS = not Config.ConfigTable.BORDERLESS
end)
createCheckBox(UDim2.fromScale(.2, .35), "VSync", Config.ConfigTable.VSYNC, function ()
    Config.ConfigTable.VSYNC = not Config.ConfigTable.VSYNC
end)

Apply = Button.new(function ()
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
Apply:setParent(ListThing)
Apply.position = UDim2.fromScale(1, 0.9)
Apply.size = UDim2.fromScale(0.7, 0.1)
Apply.anchorPoint = {0.5, 0.5}
table.insert(settingsUI, Apply)

ApplyText = Textlabel.new()
ApplyText.text = "Apply"
ApplyText.textColor = {1, 1, 1, 1}
ApplyText:setParent(ListThing)
ApplyText.position = Apply.position
ApplyText.zIndex = 1
table.insert(settingsUI, ApplyText)

ResolutionText = Textlabel.new()
ResolutionText.text = "Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height
ResolutionText.textColor = {1, 1, 1, 1}
ResolutionText:setParent(ListThing)
ResolutionText.position = UDim2.fromScale(.2, .5)
ResolutionText.size = UDim2.fromScale(.6, .1)
ResolutionText.zIndex = 1
table.insert(settingsUI, ResolutionText)

local SliderFrame = Frame.new()
SliderFrame:setParent(ListThing)
SliderFrame.position = UDim2.fromScale(0.5, 0.7)
SliderFrame.size = UDim2.fromScale(1, 0.05)
SliderFrame.anchorPoint = {0.5, 0.5}
SliderFrame.bgColor = {0.5, 0.5, 0.5, 1}
table.insert(settingsUI, SliderFrame)

Slider = Button.new(function ()
    -- No action needed, just a visual element
end)
Slider:setParent(SliderFrame)
Slider.position = UDim2.fromScale(Config.ConfigTable.VOLUME, .5)
Slider.size = UDim2.fromScale(0.15, 2)
Slider.anchorPoint = {0.5, 0.5}
Slider.bgColor = {1,1,1, 0}
Slider.zIndex = 2
Slider.whenPressing = function ()
    local sliderX, _ = SliderFrame:getRenderPosition()
    local sliderWidth, sliderHeight = SliderFrame:getRenderSize()
    local x = love.mouse.getX()
    if love.mouse.getX() > sliderX + sliderWidth then
        x = sliderX + sliderWidth
    elseif love.mouse.getX() < sliderX then
        x = sliderX
    end
    local diff = x - sliderX
    Slider.position = UDim2.new(0, diff, .5, 0)
    Slider.position = UDim2.fromScale(Slider.position:toScale(sliderWidth, sliderHeight))
    Config.ConfigTable.VOLUME = Slider.position.x.scale
end
table.insert(settingsUI, Slider)

local SliderImg = createImg(Slider, "assets/sprites/slider.png")
table.insert(settingsUI, SliderImg)

ResolutionL = Button.new(function ()
    Config.ConfigTable.RESOLUTION = Config.ConfigTable.RESOLUTION - 1
    if Config.ConfigTable.RESOLUTION < 1 then
        Config.ConfigTable.RESOLUTION = #Config.Resolutions
    end
    ResolutionText.text = "Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height
end)
ResolutionR = Button.new(function ()
    Config.ConfigTable.RESOLUTION = Config.ConfigTable.RESOLUTION + 1
    if Config.ConfigTable.RESOLUTION > #Config.Resolutions then
        Config.ConfigTable.RESOLUTION = 1
    end
    ResolutionText.text = "Resolution: " .. Config.Resolutions[Config.ConfigTable.RESOLUTION].width .. "x" .. Config.Resolutions[Config.ConfigTable.RESOLUTION].height
end)

ResolutionR:setParent(ResolutionText)
ResolutionR.bgColor = {1,1,1, 0}
ResolutionR.position = UDim2.fromScale(1, 0.5)
ResolutionR.size = UDim2.fromScale(0.15, 0.8)
ResolutionR.anchorPoint = {0.5, 0.5}
table.insert(settingsUI, ResolutionR)

ResolutionL:setParent(ResolutionText)
ResolutionL.bgColor = {1,1,1, 0}
ResolutionL.position = UDim2.fromScale(0, 0.5)
ResolutionL.size = UDim2.fromScale(0.15, 0.8)
ResolutionL.anchorPoint = {0.5, 0.5}
table.insert(settingsUI, ResolutionL)

ResolutionLImg = createImg(ResolutionL, "assets/sprites/leftarrow.png")
table.insert(settingsUI, ResolutionLImg)

ResolutionRImg = createImg(ResolutionR, "assets/sprites/rightarrow.png")
table.insert(settingsUI, ResolutionRImg)

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
Back:setParent(ListThing)
Back.position = UDim2.fromScale(0, 0.9)
Back.size = UDim2.fromScale(0.7, 0.1)
Back.anchorPoint = {0.5, 0.5}
table.insert(settingsUI, Back)

BackText = Textlabel.new()
BackText.text = "Back"
BackText.textColor = {1, 1, 1, 1}
BackText:setParent(ListThing)
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
Settings:setParent(ListThing)
Settings.bgColor = {0.3, 0.3, 0.3, 1}
Settings.position = UDim2.fromScale(0.5, 0.3)
Settings.size = UDim2.fromScale(0.8, 0.1)
Settings.anchorPoint = {0.5, 0.5}
table.insert(pauseMenuUi, Settings)

SettingsText = Textlabel.new()
SettingsText.text = "Settings"
SettingsText.textColor = {1, 1, 1, 1}
SettingsText:setParent(ListThing)
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
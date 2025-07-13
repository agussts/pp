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

Settings = Button.new(function ()
    print("settings")
    --for _,v in pairs(pauseMenuUi) do
    --    v.visible = false
    --end
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
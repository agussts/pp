--Carga la configuracion guardada 
--Si no existe, crea el archivo config.ini con los valores por defecto
local ConfigManager = {}

ConfigManager.ConfigTable = {}
ConfigManager.SavedConfigs = {}

ConfigManager.Resolutions = {
    {width = 320, height = 180, scale = 0.5},
    {width = 640, height = 360, scale = 1},
    {width = 1280, height = 720, scale = 2},
    {width = 1920, height = 1080, scale = 3},
}
ConfigManager.DefaultConfigs = {
    BORDERLESS = false,
    VSYNC = true,
    RESOLUTION = 3,
    VOLUME = 1,
    PLEFT = "a",
    PRIGHT = "d",
    PUP = "w",
    PDOWN = "s",
    PDASH = "space",
}

local function tableClone(original)
    local copy = {}
    for i, v in pairs(original) do
        if type(i) == "table" then
            copy[i] = tableClone(v)
        else
            copy[i] = v
        end
    end
    return copy
end

function ConfigManager.init()
    local tempConfigTable = {}

    tempConfigTable = tableClone(ConfigManager.DefaultConfigs)

    --Crea config.ini si no existe
    if love.filesystem.getInfo("config.ini") == nil then
        local data = ""
        for i,v in pairs(ConfigManager.DefaultConfigs) do
            data = data..tostring(i).." = "..tostring(v).."\n"
        end
        love.filesystem.write("config.ini", data)
    end

    --Saca las lineas del archivo config.ini, y sobreescribe variables que ya tenga en tempConfigTable
    local configFile = love.filesystem.lines("config.ini")
    for line in configFile do
        local i, v = line:match("^(%S+) = (%S+)$")
        if v == "true" then
            v = true
        elseif v == "false" then
            v = false
        elseif tonumber(v) ~= nil then
            v = tonumber(v)
        end

        tempConfigTable[i] = v
    end

    --Escribe los datos de tempConfigTable al archivo config.ini
    local data = ""
    for i,v in pairs(tempConfigTable) do
        if type(v) == "boolean" then
            v = v and "true" or "false"
        else
            v = tostring(v)
        end
        data = data..tostring(i).." = "..v.."\n"
    end
    love.filesystem.write("config.ini", data)

    --Escribe los datos del tempConfigTable (que es identico a config.ini) a la tabla ConfigTable
    ConfigManager.ConfigTable = tableClone(tempConfigTable)
    ConfigManager.SavedConfigs = tableClone(tempConfigTable)
    tempConfigTable =  nil
    --Actualiza la ventana a los ajustes actuales
    ConfigManager.updateWindow()
end

--Actualiza la ventana a los ajustes actuales
function ConfigManager.updateWindow()
    love.audio.setVolume(ConfigManager.ConfigTable.VOLUME)
    TrueResolution = ConfigManager.Resolutions[ConfigManager.ConfigTable.RESOLUTION]
    love.window.setMode(TrueResolution.width, TrueResolution.height, {
        borderless = ConfigManager.ConfigTable.BORDERLESS,
        resizable = false,
        vsync = ConfigManager.ConfigTable.VSYNC,
    })
end


--Carga los ajustes de configuracion al archivo para guardar
function ConfigManager.saveConfig()
    ConfigManager.SavedConfigs = {}
    local data = ""
    for i,v in pairs(ConfigManager.ConfigTable) do
        ConfigManager.SavedConfigs[i] = v
        if type(v) == "boolean" then
            v = v and "true" or "false"
        else
            v = tostring(v)
        end
        data = data..tostring(i).." = "..v.."\n"
    end
    love.filesystem.write("config.ini", data)
end

ConfigManager.init()

return ConfigManager
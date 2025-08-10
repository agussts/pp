--Carga la configuracion guardada 
--Si no existe, crea el archivo config.ini con los valores por defecto
local ConfigManager = {}

ConfigManager.ConfigTable = {}
ConfigManager.Resolutions = {
    {width = 320, height = 180, scale = 0.5},
    {width = 640, height = 360, scale = 1},
    {width = 1280, height = 720, scale = 2},
    {width = 1920, height = 1080, scale = 3},
}
ConfigManager.DefaultConfigs = {
    BORDERLESS = false,
    VSYNC = true,
    RESOLUTION = 4,
    VOLUME = 1,
    PLEFT = "a",
    PRIGHT = "d",
    PUP = "w",
    PDOWN = "s",
    PDASH = "space",
}

function ConfigManager.init()
    --Configuracion Predeterminada
    --Resoluciones que se pueden elijir
    
    --Crea config.ini si no existe
    if love.filesystem.getInfo("config.ini") == nil then
        local data = ""
        for i,v in pairs(ConfigManager.DefaultConfigs) do
            data = data..tostring(i).." = "..tostring(v).."\n"
        end
        love.filesystem.write("config.ini", data)
    end

    --Saca las lineas del archivo config.ini
    ConfigFile = love.filesystem.lines("config.ini")

    --Escribe los datos del archivo config.ini a la tabla ConfigTable
    for line in ConfigFile do

        local i, v = line:match("^(%S+) = (%S+)$") 
        if v == "true" then 
            v = true
        elseif v == "false" then
            v = false
        elseif tonumber(v) ~= nil then
            v = tonumber(v)
        end
        
        ConfigManager.ConfigTable[i] = v
    end

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
    local data = ""
    for i,v in pairs(ConfigManager.ConfigTable) do
        v = tostring(v)
        data = data..tostring(i).." = "..v.."\n"
    end
    love.filesystem.write("config.ini", data)
end

return ConfigManager
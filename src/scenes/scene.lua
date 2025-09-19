-- src/scene/scene.lua
local Scene = {}

local registry = {}
local current = nil
local isLoading = false

local function safeCall(fn, ...)
    if type(fn) == "function" then return fn(...) end
end

function Scene.register(name, factory)  -- factory() -> scene table
    assert(type(name)=="string" and type(factory)=="function", "Scene.register(name, factory)")
    registry[name] = factory
end

function Scene.get()
    return current
end

local function resetWorld()
    -- Reset grupos de timers y colecciones globales entre escenas
    PlayingTimers = Timer.group.new()
--  PauseMenuTimers = Timer.group.new()
--  PauseMenuTimers:pause()

    -- Limpiar colecciones
    if Collisions.clearAll then Collisions.clearAll() end
    if Guis.clearNonPersistent then Guis.clearNonPersistent() end
end

function Scene.load(name, payload)
    assert(registry[name], ("Scene '%s' no registrada"):format(name))
    if isLoading then return end
    isLoading = true

    -- Apaga gameplay mientras cargamos
    Gamestate = "paused"

    -- Desmonta escena anterior
    if current and current.unload then
        safeCall(current.unload, current)
    end

    resetWorld()

    -- Crea nueva
    current = registry[name]()
    current.__name = name

    -- Pasada de lifecycle
    safeCall(current.load, current, payload)
    safeCall(current.start, current, payload)

    Gamestate = "playing"
    isLoading = false
end

function Scene.reload(payload)
  assert(current and current.__name, "No hay escena cargada para recargar")
  Scene.load(current.__name, payload)
end

function Scene.update(dt)
    if current and current.update then current:update(dt) end
end

function Scene.draw()
    if current and current.draw then current:draw() end
end

return Scene

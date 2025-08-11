---
--@classmod connections

local connections = {}

-- Conecta una funcion con un evento
function Connect(eventName, callback)
    if not connections[eventName] then
        connections[eventName] = {}
    end
    table.insert(connections[eventName], callback)
end

-- Conecta una funcion con un evento
-- con diferencia que al ser llamado una vez,
-- se desconecta automaticamente
--@param eventName (string) Nombre del evento
function Once(eventName, callback)
    local function wrappedCallback(...)
        callback(...)
        Disconnect(eventName, wrappedCallback)
    end
    Connect(eventName, wrappedCallback)
end

-- Desconecta la funcion del evento
function Disconnect(eventName, callback)
    if connections[eventName] then
        for i, callb in ipairs(connections[eventName]) do
            if callb == callback then
                table.remove(connections[eventName], i)
                return
            end
        end
    end
end

-- Dispara un evento y ejecuta todas las funciones conectadas
function Fire(eventName, ...)
    if connections[eventName] then
        for _, callb in ipairs(connections[eventName]) do
            callb(...)
        end
    end
end
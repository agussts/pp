---Connections
--@classmod connections

local connections = {}

---Connect
-- Conecta una funcion con un evento
--@param eventName Nombre del evento
--@param callback Funcion a conectar
function Connect(eventName, callback)
    if not connections[eventName] then
        connections[eventName] = {}
    end
    table.insert(connections[eventName], callback)
end

---Once
-- Conecta una funcion con un evento
-- con diferencia que al ser llamado una vez,
-- se desconecta automaticamente
--@param eventName Nombre del evento
--@param callback Funcion a conectar
function Once(eventName, callback)
    print("yo")
    local function wrappedCallback(...)
        callback(...)
        Disconnect(eventName, wrappedCallback)
    end
    Connect(eventName, wrappedCallback)
end

---Disconnect
-- Desconecta la funcion del evento
--@param eventName Nombre del evento
--@param callback Funcion a desconectar
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

---Fire
-- Dispara un evento y ejecuta todas las funciones conectadas
--@param eventName Nombre del evento
--@param ... Argumentos a pasar a las funciones conectadas
function Fire(eventName, ...)
    if connections[eventName] then
        for _, callb in ipairs(connections[eventName]) do
            callb(...)
        end
    end
end

---GetConnections
--@return (table) de conexiones
function GetConnections()
    return connections
end
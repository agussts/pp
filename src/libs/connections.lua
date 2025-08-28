---
-- Maneja eventos y conexiones entre funciones y eventos.
-- Funciona a par con signal.
--@see signal
--@module connections

local connections = {}

---
-- Conecta una funcion con un evento
--@param eventName Nombre del evento
--@param callback Funcion a conectar
function Connect(eventName, callback)
    if not connections[eventName] then
        connections[eventName] = {}
    end
    table.insert(connections[eventName], callback)
end

---
-- Conecta una funcion con un evento
-- con diferencia que al ser llamado una vez,
-- se desconecta automaticamente
--@param eventName Nombre del evento
--@param callback Funcion a conectar
function Once(eventName, callback)
    local function wrappedCallback(...)
        callback(...)
        Disconnect(eventName, wrappedCallback)
    end
    Connect(eventName, wrappedCallback)
end

---
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

---
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

---
-- Consigue todas las conexiones de un evento
--@param eventName Nombre del evento
--@return table
function GetConnections(eventName)
    return connections[eventName] or {}
end

---
-- Revisa si existe una conexion entre una funcion y un evento
--@param eventName Nombre del evento
--@param callback Funcion a buscar
--@return boolean
function ConnectionExists(eventName, callback)
    if connections[eventName] then
        for _, callb in ipairs(connections[eventName]) do
            if callb == callback then
                return true
            end
        end
    end
    return false
end

---
--Consigue todas las conexiones registradas
--@return table
function GetAllConnections()
    return connections
end
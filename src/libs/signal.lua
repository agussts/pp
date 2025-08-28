---
-- Clase para manejar señales y eventos.
-- Permite conectar, desconectar y disparar eventos.
-- Funciona a par con connections.
--@see connections
--@classmod signal

local signal = {}

---
-- Crea una nueva instancia de signal
--@return (signal) La nueva instancia de signal
function signal.new()
    local self = setmetatable({}, { __index = signal })
    self.callbacks = {}
    return self
end

---
-- Conecta una funcion a la señal
--@param callback Funcion a conectar
--@return (table) Una tabla con el metodo Disconnect para desconectar de la señal
function signal:Connect(callback)
    table.insert(self.callbacks, callback)

    return setmetatable({}, {
        __index = function(_, key)
            if key == "Disconnect" then
                return function() self:Disconnect(callback) end
            end
        end
    })
end

---
-- Conecta una funcion a la señal, pero se desconecta automaticamente despues de ser llamada una vez
--@param callback Funcion a conectar
function signal:Once(callback)
    local function wrappedCallback(...)
        callback(...)
        self:Disconnect(wrappedCallback)
    end
    self:Connect(wrappedCallback)
end

---
-- Desconecta una funcion de la señal
--@param callback Funcion a desconectar
function signal:Disconnect(callback)
    for i,callb in ipairs(self.callbacks) do
        if callb == callback then
            table.remove(self.callbacks, i)
            return
        end
    end
end

---
-- Dispara la señal, llamando a todas las funciones conectadas
--@param ... Argumentos a pasar a las funciones conectadas
function signal:Fire(...)
    for _,callb in ipairs(self.callbacks) do
        callb(...)
    end
end

return signal
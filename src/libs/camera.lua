---
-- Modulo de camara para gestionar la vista del juego
--@classmod camera


local camera = {}
camera.x = 0
camera.y = 0
camera.shakeOffsetX = 0
camera.shakeOffsetY = 0

---
--Actualiza la camara al objetivo.
--@param targetX La posicion X del objetivo
--@param targetY La posicion Y del objetivo
--@usage camera.update(100, 200)
function camera.update(targetX, targetY)
    camera.x = (targetX - love.graphics.getWidth() / 2) + camera.shakeOffsetX
    camera.y = (targetY - love.graphics.getHeight() / 2) + camera.shakeOffsetY
end

---
--Aplica las transformaciones de la camara
--@usage camera.attach() ... camera.detach()
function camera.attach()
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
end

---
--Restablece las transformaciones de la camara despues de dibujar el mundo.
--Se usa antes de los interfaz para que se queden en la pantalla fijos.
--@usage camera.attach() ... camera.detach()
function camera.detach()
    love.graphics.pop()
end

---
--Convierte coordenadas de la pantalla a las del mundo
--@param screenX La posicion X en la pantalla
--@param screenY La posicion Y en la pantalla
--@usage local mouseX, mouseY = camera.screenToWorld(love.mouse.getPosition())
--@return worldX, worldY Las coordenadas en el mundo
function camera.screenToWorld(screenX, screenY)
    local worldX = screenX + camera.x
    local worldY = screenY + camera.y
    return worldX, worldY
end

---
--Convierte coordenadas del mundo a las de la pantalla
--@param worldX La posicion X en el mundo
--@param worldY La posicion Y en el mundo
--@usage local screenX, screenY = camera.worldToScreen(100, 200)
--@return screenX, screenY Las coordenadas en la pantalla
function camera.worldToScreen(worldX, worldY)
    local screenX = worldX - camera.x
    local screenY = worldY - camera.y
    return screenX, screenY
end

function camera.shake(intensity, time, direction)
    assert(intensity > 0, "Intensity must be greater than 0")
    assert(time > 0, "Time must be greater than 0")
    assert(direction == "X" or direction == "Y" or direction == "XY", "Direction must be 'X', 'Y' or 'XY'")
    local timerEvery
    timerEvery = Timer.every(0.02, function()
        local shakeX, shakeY = 0, 0
        if direction == "X" then
            shakeX = math.random() * intensity * (math.random() > 0.5 and 1 or -1)
        elseif direction == "Y" then
            shakeY = math.random() * intensity * (math.random() > 0.5 and 1 or -1)
        elseif direction == "XY" then
            shakeX = math.random() * intensity * (math.random() > 0.5 and 1 or -1)
            shakeY = math.random() * intensity * (math.random() > 0.5 and 1 or -1)
        end
        camera.shakeOffsetX = shakeX
        camera.shakeOffsetY = shakeY
    end)
    timerEvery:addToGroup(PlayingTimers)
    Timer.after(time, function()
        camera.shakeOffsetX = 0
        camera.shakeOffsetY = 0
        timerEvery:Destroy()
    end):addToGroup(PlayingTimers)
end

return camera
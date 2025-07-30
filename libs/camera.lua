local camera = {}
camera.x = 0
camera.y = 0

--Actualiza la camara al objetivo
function camera.update(targetX, targetY)
    camera.x = targetX - love.graphics.getWidth() / 2
    camera.y = targetY - love.graphics.getHeight() / 2
end

--Aplica las transformaciones de la camara
function camera.attach()
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
end

--Restablece las transformaciones de la camara despues de dibujar el mundo
--Se usa antes de los interfaz para que se queden en la pantalla fijos
function camera.detach()
    love.graphics.pop()
end

--Convierte coordenadas de la pantalla a las del mundo
function camera.screenToWorld(screenX, screenY)
    local worldX = screenX + camera.x
    local worldY = screenY + camera.y
    return worldX, worldY
end

--Convierte coordenadas del mundo a las de la pantalla
function camera.worldToScreen(worldX, worldY)
    local screenX = worldX - camera.x
    local screenY = worldY - camera.y
    return screenX, screenY
end

return camera
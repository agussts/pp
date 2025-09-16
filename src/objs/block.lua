local block = {}

block.__index = block

---
-- Crea un nuevo bloque
--@param x (number) Posicion X en tiles
--@param y (number) Posicion Y en tiles
--@param width (number) Ancho en tiles
--@param height (number) Alto en tiles
--@return (block) Instancia del bloque
--@usage local myBlock = block.new(0, 0, 2, 2)
function block.new(sprite, x, y, width, height)
    local self = setmetatable({}, block)
    self.sprite = sprite or Animation.new("assets/sprites/xblock.png", 38, 21, 1,  1, 1)
    self.sprite:Pause()

    self.collision = Collisions.new("box")
    self.collision.position = UDim2.fromScale(x, y)
    self.collision.size = UDim2.fromScale(width, height)

    return self
end

---
-- Actualiza el bloque
--@param dt Delta time
--@usage myBlock:update(dt)
function block:update(dt)
    self.sprite:update(dt)
end

---
-- Dibuja el bloque
--@usage myBlock:draw()
function block:draw()
    local x, y = self.collision.position:toPixels()
    local width, height = self.collision.size:toPixels()
    self.sprite:draw(x, y, width, height)
end

return block
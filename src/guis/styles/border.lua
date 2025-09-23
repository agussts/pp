-- Estilo: Border
-- Crea 4 frames (top/right/bottom/left) como hijos del GUI objetivo.
-- Opciones:
--   thicknessPx (number) grosor en px (default 2)
--   color       {r,g,b,a} color (default {1,1,1,1})
--   zOffset     (number) z extra sobre el GUI (default 1)
--   insetPx     (number) separa el borde hacia adentro (default 0)

local BorderStyle = {}

local function mkEdge(parent, pos, size, color, z)
    local f = Frame.new()
    f:setParent(parent)
    f.position = pos
    f.size     = size
    f.bgColor  = color
    f.zIndex   = (parent.zIndex or 0) + z
    return f
end

function BorderStyle.apply(targetGui, opts)
    local thickness = math.max(1, tonumber(opts.thicknessPx or 2))
    local color     = opts.color or {1,1,1,1}
    local zOffset   = tonumber(opts.zOffset or 1)
    local inset     = tonumber(opts.insetPx or 0)

    -- Top
    local top = mkEdge(
        targetGui,
        UDim2.new(0, inset, 0, inset),
        UDim2.new(1, -2*inset, 0, thickness),
        color, zOffset
    )

    -- Bottom
    local bottom = mkEdge(
        targetGui,
        UDim2.new(0, inset, 1, -thickness - inset),
        UDim2.new(1, -2*inset, 0, thickness),
        color, zOffset
    )

    -- Left
    local left = mkEdge(
        targetGui,
        UDim2.new(0, inset, 0, inset),
        UDim2.new(0, thickness, 1, -2*inset),
        color, zOffset
    )

    -- Right
    local right = mkEdge(
        targetGui,
        UDim2.new(1, -thickness - inset, 0, inset),
        UDim2.new(0, thickness, 1, -2*inset),
        color, zOffset
    )

    -- handle para remover estilo
    local handle = {}
    function handle:Destroy()
        if top then top:Destroy() end
        if bottom then bottom:Destroy() end
        if left then left:Destroy() end
        if right then right:Destroy() end
    end
    return handle
end

return BorderStyle

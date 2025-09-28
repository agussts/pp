---
-- HUD simple que muestra "Shards: X/Y".
-- Persiste entre escenas.
local ShardsHUD = {}

-- @tparam number totalShards cantidad objetivo (puede cambiarse luego)
function ShardsHUD.new(totalShards)
    local self = {}

    self.total = totalShards or 3

    -- contenedor
    self.root = Frame.new()
    self.root.size = UDim2.fromScale(1,1)
    self.root.bgColor = {0,0,0,0}

    -- etiqueta
    self.label = Textlabel.new("")
    self.label:setParent(self.root)
    self.label.position = UDim2.fromScale(0.02, 0.04)
    self.label.size     = UDim2.fromScale(0.3, 0.08)
    self.label.anchorPoint = {0,0}
    self.label.textColor = {1,1,1,1}
    self.label.zIndex = 20
    -- si usas Fonts.VT323:
    if Fonts and Fonts.VT323 then self.label.font = Fonts.VT323 end

    local function refresh()
        local curr = World.shards.collected or 0
        self.label.text = ("Shards: %d/%d"):format(curr, self.total)
    end

    refresh()

    -- escuchar recolectas
    self._conn = Connect("shard_collected", function()
        refresh()
    end)

    -- API pequeña
    function self:setTotal(n)
        self.total = n or self.total
        refresh()
    end

    function self:Destroy()
        if self._conn then Disconnect("shard_collected", self._conn) end
        if self.label and self.label.Destroy then self.label:Destroy() end
        if self.root and self.root.Destroy then self.root:Destroy() end
    end

    return self
end

return ShardsHUD

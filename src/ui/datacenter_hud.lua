-- src/ui/datacenter_hud.lua
local DCHUD = {}

function DCHUD.new()
    local self = {}
    -- raíz persistente
    self.root = Frame.new()
    self.root.size = UDim2.fromScale(1, 1)
    self.root.bgColor = {0,0,0,0}
    self.root.zIndex = 200

    -- ---------- HEAT BAR (arriba-izquierda) ----------
    self.heatBox = Frame.new()
    self.heatBox:setParent(self.root)
    self.heatBox.position  = UDim2.fromScale(0.02, 0.05)
    self.heatBox.size      = UDim2.fromScale(0.30, 0.05)
    self.heatBox.anchorPoint = {0,0}
    self.heatBox.bgColor   = {0,0,0,0.35}
    self.heatBox.zIndex    = self.root.zIndex + 1

    self.heatFill = Frame.new()
    self.heatFill:setParent(self.heatBox)
    self.heatFill.position = UDim2.fromScale(0, 0)
    self.heatFill.size     = UDim2.fromScale(0, 1)
    self.heatFill.anchorPoint = {0,0}
    self.heatFill.bgColor  = {0.25, 0.9, 0.25, 0.85} -- empezamos verdoso

    self.heatLbl = Textlabel.new("HEAT 0% (x1.00)")
    self.heatLbl:setParent(self.heatBox)
    self.heatLbl.position   = UDim2.fromScale(0.5, 0.5)
    self.heatLbl.size       = UDim2.fromScale(1, 1)
    self.heatLbl.anchorPoint= {0.5, 0.5}
    self.heatLbl.textColor  = {1,1,1,1}
    self.heatLbl.zIndex     = self.heatBox.zIndex + 1
    if Fonts and Fonts.VT323 then self.heatLbl.font = Fonts.VT323 end

    -- ---------- POINTS (arriba-derecha) ----------
    self.pointsLbl = Textlabel.new("Points: 0/0")
    self.pointsLbl:setParent(self.root)
    self.pointsLbl.position   = UDim2.fromScale(0.98, 0.05)
    self.pointsLbl.size       = UDim2.fromScale(0.34, 0.06)
    self.pointsLbl.anchorPoint= {1, 0}
    self.pointsLbl.textColor  = {1,1,1,1}
    self.pointsLbl.zIndex     = self.root.zIndex + 1
    if Fonts and Fonts.VT323 then self.pointsLbl.font = Fonts.VT323 end

    -- ---------- API ----------
    function self:setPoints(p, target)
        self.pointsLbl.text = ("Points: %d/%d"):format(p or 0, target or 0)
    end

    local function lerp(a,b,t) return a + (b-a)*t end

    function self:setHeat(h, mul)
        h = math.max(0, math.min(100, h or 0))
        local t = h/100
        self.heatFill.size = UDim2.fromScale(t, 1)
        self.heatLbl.text = ("HEAT %d%% (x%.2f)"):format(math.floor(h+0.5), mul or 1)

        -- gradiente green -> yellow -> red
        local r = (t < 0.5) and lerp(0.25, 1.0, t*2) or 1.0
        local g = (t < 0.5) and 0.9 or lerp(0.9, 0.2, (t-0.5)*2)
        local b = 0.25
        self.heatFill.bgColor = {r, g, b, 0.9}
    end

    function self:setVisible(v)
        v = not not v
        self.root.visible     = v
        self.heatBox.visible  = v
        self.pointsLbl.visible= v
    end

    function self:Destroy()
        if self.pointsLbl and self.pointsLbl.Destroy then self.pointsLbl:Destroy() end
        if self.heatLbl   and self.heatLbl.Destroy   then self.heatLbl:Destroy() end
        if self.heatFill  and self.heatFill.Destroy  then self.heatFill:Destroy() end
        if self.heatBox   and self.heatBox.Destroy   then self.heatBox:Destroy() end
        if self.root      and self.root.Destroy      then self.root:Destroy() end
    end

    -- valores iniciales
    self:setPoints(0, 0)
    self:setHeat(0, 1)

    return self
end

return DCHUD

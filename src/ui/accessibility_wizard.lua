-- src/ui/accessibility_wizard.lua
-- Wizard de Accesibilidad (pre-creado, singleton, mouse-only).
-- Depende de: Frame, Button, ImageLabel, Textlabel, UDim2, Config, Border (opcional), Fonts (opcional)

local Wizard = {}
Wizard.__index = Wizard
Wizard._inst = nil

-- Z-index altos y consistentes (por encima de casi todo)
local Z_ROOT, Z_PANEL, Z_LABEL, Z_CTRL, Z_DONE = 900, 910, 920, 930, 940

-- Layout compacto y legible
local LAYOUT = {
  TITLE_Y = 0.16,

  CB1_Y   = 0.22,
  CB2_Y   = 0.40,
  LEFT_X  = 0.1,   -- margen izquierdo del grupo checkbox
  CB_SIZE = 2,   -- escala de tamaño de checkbox

  RAD1_Y  = 0.58,   -- fila “Audience”
  RAD2_Y  = 0.72,   -- fila “Theme”
  PILL_W  = 0.22,   -- ancho de cada “pill”
  PILL_H  = 0.1,   -- alto de cada “pill”
  PILL_G  = 0.01,   -- gap horizontal entre “pills”

  DONE_Y  = 0.88,   -- botón Done
}


-- Paths para checkbox
local CB_MARK   = "assets/sprites/cbmark.png"
local CB_UNMARK = "assets/sprites/cbunmark.png"

-- helper: registra y devuelve el nodo para encadenarlo
local function keep(self, node)
  table.insert(self._nodes, node)
  return node
end

-- helper: visibilidad de todo el árbol
local function _setTreeVisible(self, flag)
  if self.root then self.root.visible = flag end
  if self._nodes then
    for _,n in ipairs(self._nodes) do
      if n then n.visible = flag end
    end
  end
end

-- ---------- helpers de estilo ----------
local function pillColors(active)
  if active then
    return {0.62, 0.62, 0.62, 1.0}, {1,1,1,1}
  else
    return {0.26, 0.26, 0.26, 1.0}, {1,1,1,1}
  end
end

-- ---------- construcción de UI ----------
local function buildUI(self)
  self._nodes = {}

  self.root = keep(self, Frame.new())
  self.root:setPersistent(true)
  self.root.zIndex  = LAYOUT.Z_ROOT
  self.root.size    = UDim2.fromScale(1,1)
  self.root.bgColor = {0,0,0,0.65}

  -- Panel
  self.box = keep(self, Frame.new())
  self.box:setParent(self.root)
  self.box.size        = UDim2.fromScale(0.72, 0.72)
  self.box.position    = UDim2.fromScale(0.5, 0.5)
  self.box.anchorPoint = {0.5, 0.5}
  self.box.bgColor     = {0.12,0.12,0.12,1}
  self.box.zIndex      = Z_PANEL
  if self.box.applyStyle and Border then
    self.box:applyStyle(Border, { thicknessPx=3, color={1,1,1,1}, zOffset=2, insetPx=0 })
  end

  -- Título
  self.title = keep(self, Textlabel.new("Accessibility"))
  self.title:setParent(self.box)
  self.title.position = UDim2.fromScale(0.5, 0.12)
  self.title.size     = UDim2.fromScale(0.9, 0.12)
  self.title.anchorPoint = {0.5, 0.5}
  self.title.textColor   = {1,1,1,1}
  self.title.zIndex = Z_LABEL
  if Fonts and Fonts.VT323 then self.title.font = Fonts.VT323 end

  -- ---------- Checkboxes ----------
  local function makeCheckbox(pos, text, cfgKey)
    -- pos: UDim2 con x/y (scale) = punto medio vertical de la fila
    local cbImg = keep(self, ImageLabel.new(
        (Config.ConfigTable[cfgKey] and CB_MARK) or CB_UNMARK
    ))
    cbImg:setParent(self.box)
    cbImg.position    = pos
    cbImg.size        = UDim2.fromScale(.075, .1) * LAYOUT.CB_SIZE
    cbImg.anchorPoint = {0, 0.35}
    cbImg.zIndex      = Z_CTRL

    local btn = keep(self, Button.new(function()
        Config.ConfigTable[cfgKey] = not Config.ConfigTable[cfgKey]
        cbImg.image = love.graphics.newImage(
        Config.ConfigTable[cfgKey] and CB_MARK or CB_UNMARK
        )
    end))
    btn:setParent(self.box)
    btn.bgColor     = {0,0,0,0}
    btn.position    = pos
    btn.size        = (UDim2.fromScale(.075, .1) * LAYOUT.CB_SIZE) / 1.5
    btn.anchorPoint = {0, 0}
    btn.zIndex      = Z_CTRL

    local lbl = keep(self, Textlabel.new(text))
    lbl:setParent(self.box)
    lbl.position    = UDim2.fromScale(pos.x.scale + .1, pos.y.scale)
    lbl.size        = UDim2.fromScale(0.72, 0.12)
    lbl.anchorPoint = {0, 0.35}
    lbl.textColor   = {1,1,1,1}
    lbl.zIndex      = Z_LABEL
    if Fonts and Fonts.VT323 then lbl.font = Fonts.VT323 end

    local function refresh()
        cbImg.image = love.graphics.newImage(
        (Config.ConfigTable[cfgKey] and CB_MARK) or CB_UNMARK
        )
    end

    return { btn=btn, img=cbImg, lbl=lbl, refresh=refresh }
    end


  -- ---------- Radios (dos “pills”) ----------
  local function makePill(pos, text)
    local b = keep(self, Button.new(function() end))
    b:setParent(self.box)
    b.position    = pos
    b.size        = UDim2.fromScale(LAYOUT.PILL_W, LAYOUT.PILL_H)
    b.anchorPoint = {0,0}
    b.bgColor     = {0.26,0.26,0.26,1}
    b.zIndex      = Z_CTRL

    local t = keep(self, Textlabel.new(text))
    t:setParent(b)
    t.position    = UDim2.fromScale(0.5, 0.5)
    t.size        = UDim2.fromScale(1,1)
    t.anchorPoint = {0.5, 0.5}
    t.textColor   = {1,1,1,1}
    t.zIndex      = Z_CTRL + 1
    if Fonts and Fonts.VT323 then t.font = Fonts.VT323 end

    local function setActive(a)
        local bg, col = pillColors(a)
        b.bgColor   = bg
        t.textColor = col
    end

    return b, t, setActive
    end

  local function makeRadio2(titleText, posX, centerY, cfgKey, aText, aValue, bText, bValue, cText, cValue)
    -- Título centrado
    local title = keep(self, Textlabel.new(titleText))
    title:setParent(self.box)
    title.position    = UDim2.fromScale(posX, centerY)
    title.size        = UDim2.fromScale(0.9, 0.10)
    title.anchorPoint = {0.25, 0.5}
    title.textColor   = {1,1,1,1}
    title.zIndex      = Z_LABEL
    if Fonts and Fonts.VT323 then title.font = Fonts.VT323 end

    --local rightX = 0.5 + (LAYOUT.PILL_G) 
    local rightX = posX + LAYOUT.PILL_W + LAYOUT.PILL_G
    local rowY   = centerY + 0.08

    local aBtn, aLbl, setA = makePill(UDim2.fromScale(posX,  centerY + .08), aText)
    local bBtn, bLbl, setB = makePill(UDim2.fromScale(rightX, centerY + .08), bText)
    local cBtn, cLbl, setC
    if cText and cValue then
      cBtn, cLbl, setC = makePill(UDim2.fromScale(rightX, centerY + .19), cText)
    end

    local function refresh()
        local cur = Config.ConfigTable[cfgKey] or aValue
        setA(cur == aValue)
        setB(cur == bValue)
        if setC then
          setC(cur == cValue)
        end
    end
    refresh()
    aBtn.callback = function() Config.ConfigTable[cfgKey] = aValue; refresh() end
    bBtn.callback = function() Config.ConfigTable[cfgKey] = bValue; refresh() end
    if cBtn then
      cBtn.callback = function() Config.ConfigTable[cfgKey] = cValue; refresh() end
    end

    return {
        title = title,
        aBtn=aBtn, aLbl=aLbl,
        bBtn=bBtn, bLbl=bLbl,
        cBtn=cBtn, cLbl=cLbl,
        refresh=refresh
    }
end

  -- Controles concretos
  self._chkSigns = makeCheckbox(UDim2.fromScale(LAYOUT.LEFT_X, LAYOUT.CB1_Y), "Show help signs", "HELP_SIGNS")
  self._chkTeach = makeCheckbox(UDim2.fromScale(LAYOUT.LEFT_X, LAYOUT.CB2_Y), "Enable Teach (hints)", "TEACH")

  self._radAudience = makeRadio2("MathQuiz Audience",
    .05,
    LAYOUT.RAD1_Y,
    "MAUDIENCE",
    "Kids",  "kids",
    "Teens", "teens"
  )

  self._radTheme = makeRadio2("MathQuiz Theme",
    .28 + LAYOUT.PILL_W + LAYOUT.PILL_G,
    LAYOUT.RAD1_Y,
    "MTHEME",
    "NetKids", "netkids",
    "Tech",    "tech",
    "Direct", "direct"
  )

  -- Botón Done
  self.doneBtn = keep(self, Button.new(function()
    if Config.applyAccessibility then Config.applyAccessibility() end
    if Config.saveConfig then Config.saveConfig() end
    self.root.visible = false
    if self.onDone then self.onDone() end
  end))
  self.doneBtn:setParent(self.box)
  self.doneBtn.position    = UDim2.fromScale(0.45, LAYOUT.DONE_Y)
  self.doneBtn.size        = UDim2.fromScale(0.55, 0.12)
  self.doneBtn.anchorPoint = {0.5, 0.5}
  self.doneBtn.bgColor     = {0.35,0.35,0.35,1}
  self.doneBtn.zIndex      = Z_DONE

  local doneLbl = keep(self, Textlabel.new("Done"))
  doneLbl:setParent(self.doneBtn)
  doneLbl.position    = UDim2.fromScale(0.5, 0.5)
  doneLbl.size        = UDim2.fromScale(1,1)
  doneLbl.anchorPoint = {0.5,0.5}
  doneLbl.textColor   = {1,1,1,1}
  doneLbl.zIndex      = Z_DONE + 1
  if Fonts and Fonts.VT323 then doneLbl.font = Fonts.VT323 end

  _setTreeVisible(self, false)
end

-- refresca estado visual desde Config
local function refreshAll(self)
  if self._chkSigns and self._chkSigns.refresh then self._chkSigns.refresh() end
  if self._chkTeach and self._chkTeach.refresh then self._chkTeach.refresh() end
  if self._radAudience and self._radAudience.refresh then self._radAudience.refresh() end
  if self._radTheme and self._radTheme.refresh then self._radTheme.refresh() end
end

-- ---------- API pública ----------
function Wizard.ensure()
  if Wizard._inst then return Wizard._inst end
  local self = setmetatable({}, Wizard)

  -- Defaults por si no existen
  if not Config or not Config.ConfigTable then
    Config = Config or {}
    Config.ConfigTable = Config.ConfigTable or {}
  end
  if Config.initAccessibilityDefaults then
    Config.initAccessibilityDefaults()
  else
    -- valores por defecto “seguro”
    if Config.ConfigTable.HELP_SIGNS == nil       then Config.ConfigTable.HELP_SIGNS = true end
    if Config.ConfigTable.TEACH == nil     then Config.ConfigTable.TEACH = true end
    if not Config.ConfigTable.MAUDIENCE           then Config.ConfigTable.MAUDIENCE = "kids" end
    if not Config.ConfigTable.MTHEME              then Config.ConfigTable.MTHEME    = "netkids" end
  end

  buildUI(self)
  refreshAll(self)

  Wizard._inst = self
  return self
end

function Wizard.show()
  local self = Wizard.ensure()
  _setTreeVisible(self, true)
  -- Traer arriba por si otro overlay subió su zIndex
  self.root.zIndex = Z_ROOT
  self.box.zIndex  = Z_PANEL
  refreshAll(self)
  self.root.visible = true
end

function Wizard.hide()
  local self = Wizard._inst
  if not self then return end
  _setTreeVisible(self, false)
end

function Wizard.destroy()
  local self = Wizard._inst
  if not self then return end
  if self.root and self.root.Destroy then self.root:Destroy() end
  Wizard._inst = nil
end

function Wizard.setOnDone(cb)
  local self = Wizard.ensure()
  self.onDone = function ()
    Wizard.destroy()
    cb()
  end
end

return Wizard

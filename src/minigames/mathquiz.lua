---
-- Minijuego de preguntas matemáticas rápidas.
-- Pausa el gameplay (Gamestate="minigame") y al terminar llama callbacks.
--@module MathQuiz

local MathQuiz = {}
MathQuiz.__index = MathQuiz

-- Helpers de estado de juego (mismo patrón que Dialogue)
local function enterMiniState()
    if PlayingTimers and PlayingTimers.pause then PlayingTimers:pause() end
    if PauseMenuTimers and PauseMenuTimers.continue then PauseMenuTimers:continue() end
    Gamestate = "minigame"
end

local function exitMiniState()
    Gamestate = "playing"
    if PlayingTimers and PlayingTimers.continue then PlayingTimers:continue() end
    if PauseMenuTimers and PauseMenuTimers.pause then PauseMenuTimers:pause() end
end

-- Genera una pregunta simple
local ops = { "+", "-", "x" }
local function makeQuestion()
    local a = love.math.random(2, 9)
    local b = love.math.random(2, 9)
    local op = ops[love.math.random(1, #ops)]
    local txt, ans
    if op == "+" then
        txt = ("%d + %d = ?"):format(a, b)
        ans = a + b
    elseif op == "-" then
        -- evita negativos para que sea simple
        if b > a then a, b = b, a end
        txt = ("%d - %d = ?"):format(a, b)
        ans = a - b
    else
        txt = ("%d × %d = ?"):format(a, b)
        ans = a * b
    end
    return txt, ans
end

--- Crea y muestra el minijuego.
-- @tparam table opt { rounds=3, timePer=10, onWin=function(), onLose=function() }
function MathQuiz.start(opt)
    opt = opt or {}
    local self = setmetatable({}, MathQuiz)

    self.rounds    = opt.rounds or 3
    self.timePer   = opt.timePer or 10
    self.onWin     = opt.onWin
    self.onLose    = opt.onLose

    self.curr      = 1
    self.answer    = ""
    self.timeLeft  = self.timePer
    self.won       = false
    self._active   = true

    enterMiniState()
    self:_buildUI()
    self:_newRound()

    -- entrada por teclado
    self._kconn = Connect("keyPressed", function(key)
        if not self._active then return end
        if key == "backspace" then
            self.answer = self.answer:sub(1, -2)
            self:_refresh()
        elseif key == "return" or key == "kpenter" then
            self:_trySubmit()
        elseif key:match("^%d$") then
            -- solo números 0-9
            if #self.answer < 5 then
                self.answer = self.answer .. key
                self:_refresh()
            end
        end
    end)

    -- timer de cuenta atrás (usa PauseMenuTimers para que siga corriendo en minijuego)
    self._tick = Timer.every(0.1, function()
        if not self._active then return end
        self.timeLeft = math.max(0, self.timeLeft - 0.1)
        if self.timeLeft == 0 then
            self:_failRound()
        end
        self:_refresh()
    end)
    self._tick:addToGroup(PauseMenuTimers)

    return self
end

-- UI
function MathQuiz:_buildUI()
    self.root = Frame.new()
    self.root.size = UDim2.fromScale(1,1)
    self.root.bgColor = {0,0,0,0.65}
    self.root.anchorPoint = {0,0}
    self.root.zIndex = 90

    -- Caja central
    self.box = Frame.new()
    self.box:setParent(self.root)
    self.box.size = UDim2.fromScale(0.6, 0.5)
    self.box.position = UDim2.fromScale(0.5, 0.5)
    self.box.anchorPoint = {0.5, 0.5}
    self.box.bgColor = {0,0,0,0.85}
    self.box.zIndex = 91

    -- (si usas estilos/borde)
    if self.box.applyStyle and Border then
        self.box:applyStyle(Border, {
            thicknessPx = 3,
            color       = {1,1,1,1},
            zOffset     = 2,
            insetPx     = 0
        })
    end

    -- Título
    self.title = Textlabel.new("SHARD STABILIZER")
    self.title:setParent(self.box)
    self.title.position = UDim2.fromScale(0.5, 0.12)
    self.title.size = UDim2.fromScale(0.9, 0.15)
    self.title.anchorPoint = {0.5, 0.5}
    self.title.textColor = {1,1,1,1}
    self.title.zIndex = 95
    self.title.font = Fonts and Fonts.VT323 or self.title.font

    -- Pregunta
    self.question = Textlabel.new("")
    self.question:setParent(self.box)
    self.question.position = UDim2.fromScale(0.5, 0.38)
    self.question.size = UDim2.fromScale(0.9, 0.18)
    self.question.anchorPoint = {0.5, 0.5}
    self.question.textColor = {1,1,1,1}
    self.question.zIndex = 95
    self.question.font = Fonts and Fonts.VT323 or self.question.font

    -- Input
    self.input = Textlabel.new("")
    self.input:setParent(self.box)
    self.input.position = UDim2.fromScale(0.5, 0.58)
    self.input.size = UDim2.fromScale(0.9, 0.14)
    self.input.anchorPoint = {0.5, 0.5}
    self.input.textColor = {1,1,1,1}
    self.input.zIndex = 95
    self.input.font = Fonts and Fonts.VT323 or self.input.font

    -- Info: tiempo / ronda
    self.info = Textlabel.new("")
    self.info:setParent(self.box)
    self.info.position = UDim2.fromScale(0.5, 0.78)
    self.info.size = UDim2.fromScale(0.9, 0.14)
    self.info.anchorPoint = {0.5, 0.5}
    self.info.textColor = {1,1,1,1}
    self.info.zIndex = 95
    self.info.font = Fonts and Fonts.VT323 or self.info.font
end

function MathQuiz:_refresh()
    if not self._active then return end
    self.input.text = ("Answer: %s"):format(self.answer ~= "" and self.answer or "_")
    self.info.text = ("Time: %.1fs   Round: %d/%d"):format(self.timeLeft, self.curr, self.rounds)
end

function MathQuiz:_newRound()
    self.qText, self.qAns = makeQuestion()
    self.timeLeft = self.timePer
    self.answer = ""
    self.question.text = self.qText
    self:_refresh()
end

function MathQuiz:_trySubmit()
    local n = tonumber(self.answer)
    if n == self.qAns then
        if self.curr >= self.rounds then
            self:_finish(true)
        else
            self.curr = self.curr + 1
            self:_newRound()
        end
    else
        self:_failRound()
    end
end

function MathQuiz:_failRound()
    self:_finish(false)
end

function MathQuiz:_finish(success)
    if not self._active then return end
    self._active = false
    if self._kconn then Disconnect("keyPressed", self._kconn) end
    if self._tick then self._tick:Destroy() end

    if self.root then self.root:Destroy() end
    self.root, self.box, self.title, self.question, self.input, self.info = nil,nil,nil,nil,nil,nil

    exitMiniState()

    if success then
        if self.onWin then self.onWin() end
    else
        if self.onLose then self.onLose() end
    end
end

return MathQuiz

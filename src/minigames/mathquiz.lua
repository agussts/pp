---
-- Minijuego **MathQuiz** con problemas narrativos (paquetes/nodos/firewalls) para 8–11 años.
-- Mantiene la API pública:
--
--     MathQuiz.start{ rounds=3, timePer=20, onWin=function, onLose=function }
--
-- Entradas: dígitos 0–9, **Backspace** para borrar, **Enter** para enviar.
-- Calidad de vida:
--   - 2 intentos por ronda (con pista tras el primer error).
--   - Tras acierto/error/tiempo, **espera Enter** para continuar (permite leer bien el feedback).
--   - Dificultad que escala suavemente: de un paso a dos pasos.
--
-- @module MathQuiz

local MathQuiz = {}
MathQuiz.__index = MathQuiz

-- =========================================================
-- Puertas de estado del juego (siguen el patrón usado en Dialogue)
-- =========================================================

---
-- Entra al “estado minijuego”: pausa timers de gameplay y deja activos los de UI.
-- @local
local function enterMiniState()
    if PlayingTimers and PlayingTimers.pause    then PlayingTimers:pause() end
    if PauseMenuTimers and PauseMenuTimers.continue then PauseMenuTimers:continue() end
    Gamestate = "minigame"
end

---
-- Sale del “estado minijuego”: reanuda timers de gameplay y pausa los de UI.
-- @local
local function exitMiniState()
    Gamestate = "playing"
    if PlayingTimers and PlayingTimers.continue then PlayingTimers:continue() end
    if PauseMenuTimers and PauseMenuTimers.pause then PauseMenuTimers:pause() end
end

-- =========================================================
-- Generador de problemas (un paso y dos pasos, con narrativa)
-- =========================================================

local RNG = love.math
local function r(a,b) return RNG.random(a,b) end
local function pick(t) return t[r(1,#t)] end

---
-- Parámetros para acotar números y progresión.
-- @table PRESET
-- @field sumMax  Sumas hasta este valor (aprox. 30)
-- @field subMax  Restas sin negativos (hasta 30)
-- @field mulA    Rango de la primera arista de multiplicación {min, max}
-- @field mulB    Rango de la segunda arista de multiplicación {min, max}
-- @field tweakA  Ajustes pequeños para problemas de dos pasos
local PRESET = {
    sumMax = 30,
    subMax = 30,
    mulA   = {2,5},
    mulB   = {2,6},
    tweakA = {2,5},
}

---
-- Crea un **problema de un paso** (suma, resta o multiplicación) con temática de red.
-- @treturn table problema Tabla con `text` (enunciado), `answer` (número), `hint` (pista breve)
-- @local
local function mk_one_step()
    local kind = pick({"sum","sub","mul"})

    if kind == "sum" then
        local a = r(5, PRESET.sumMax-5)
        local b = r(2, math.min(12, PRESET.sumMax - a))
        return {
            text = ("You collect %d data packets and then find %d more. How many packets in total?"):format(a,b),
            answer = a + b,
            hint = "Add the two amounts."
        }
    end

    if kind == "sub" then
        local a = r(8, PRESET.subMax)
        local b = r(2, math.min(12, a))
        return {
            text = ("A filter removes %d packets from your %d. How many are left?"):format(b,a),
            answer = a - b,
            hint = "Start from the total, then subtract the removed ones."
        }
    end

    local a = r(PRESET.mulA[1], PRESET.mulA[2])
    local b = r(PRESET.mulB[1], PRESET.mulB[2])
    return {
        text = ("You send %d rows with %d packets in each row. How many packets in all?"):format(a,b),
        answer = a * b,
        hint = ("Think %d groups of %d (repeated addition)."):format(a,b)
    }
end

---
-- Crea un **problema de dos pasos** (multiplicar y ajustar, duplicar una suma, etc.).
-- Se mantiene en enteros y con cantidades pequeñas.
-- @treturn table problema Tabla con `text`, `answer`, `hint`
-- @local
local function mk_two_step()
    local shape = pick({"clone_minus","double_sum","sum_then_minus","cycles"})
    if shape == "clone_minus" then
        -- N×K - D
        local n = r(2,5)
        local k = r(3,7)
        local d = r(1, math.min(6, n*k-1))
        return {
            text = ("Each of %d routers clones %d packets. A firewall then drops %d packets. How many get through?"):format(n,k,d),
            answer = n*k - d,
            hint = ("Do %d×%d first, then subtract %d."):format(n,k,d)
        }
    elseif shape == "double_sum" then
        -- 2×(A+B)
        local a = r(3,12)
        local b = r(3,12)
        return {
            text = ("You gather %d packets from Site A and %d from Site B. The encryptor duplicates the total. How many now?"):format(a,b),
            answer = 2*(a+b),
            hint = ("Add first (%d+%d), then double."):format(a,b)
        }
    elseif shape == "sum_then_minus" then
        -- (A+B) - C
        local a = r(6,14)
        local b = r(4,12)
        local c = r(1, math.min(10, a+b-1))
        return {
            text = ("You cache %d and then %d packets. Later a cleanup removes %d. How many remain?"):format(a,b,c),
            answer = a + b - c,
            hint = ("Add the two caches, then subtract %d."):format(c)
        }
    else -- cycles: T × (G×H)
        local t = r(2,3)
        local g = r(2,4)
        local h = r(3,6)
        return {
            text = ("You run %d send cycles. Each cycle sends %d groups with %d packets each. How many packets in total?"):format(t,g,h),
            answer = t * (g*h),
            hint = ("Find groups first (%d×%d), then multiply by %d."):format(g,h,t)
        }
    end
end

---
-- Escala suavemente la dificultad según la ronda.
-- 1ª ronda: ~40% de dos pasos; posteriores suben hasta ~80%.
-- @tparam integer roundIdx Índice de la ronda actual (1..rounds)
-- @treturn table problema Tabla con `text`, `answer`, `hint`
-- @local
local function makeScenario(roundIdx)
    local twoStepChance = math.min(80, 40 + (roundIdx-1)*20)
    if r(1,100) <= twoStepChance then
        return mk_two_step()
    else
        return mk_one_step()
    end
end

-- =========================================================
-- API pública
-- =========================================================

---
-- Inicia el minijuego de matemáticas.
-- @tparam table opt Opciones
-- @tparam[opt=3] integer opt.rounds Cantidad de rondas
-- @tparam[opt=20] number opt.timePer Tiempo por pregunta (segundos)
-- @tparam[opt] function opt.onWin Callback al completar todas las rondas
-- @tparam[opt] function opt.onLose Callback si fallas una ronda o expira el tiempo
-- @treturn MathQuiz Instancia interna (normalmente no la necesitas)
-- @usage
-- MathQuiz.start({
--   rounds = 3,
--   timePer = 20,
--   onWin = function() World.onShardCollected(id) end,
--   onLose = function() end
-- })
function MathQuiz.start(opt)
    opt = opt or {}
    local self = setmetatable({}, MathQuiz)

    self.rounds    = opt.rounds or 3
    self.timePer   = opt.timePer or 20
    self.onWin     = opt.onWin
    self.onLose    = opt.onLose

    self.curr      = 1
    self.answer    = ""
    self.timeLeft  = self.timePer
    self.triesLeft = 2
    self._active   = true
    self._state    = "answering"   -- "answering" | "await"
    self._awaitNextSuccess = false

    enterMiniState()
    self:_buildUI()
    self:_newRound()

    -- Entrada de teclado
    self._kconn = Connect("keyPressed", function(key)
        if not self._active then return end

        if self._state == "await" then
            if key == "return" or key == "kpenter" then
                self:_continueAfterAwait()
            end
            return
        end

        -- Estado de respuesta
        if key == "backspace" then
            self.answer = self.answer:sub(1, -2)
            self:_refresh()
        elseif key == "return" or key == "kpenter" then
            self:_trySubmit()
        elseif key:match("^%d$") then
            if #self.answer < 6 then
                self.answer = self.answer .. key
                self:_refresh()
            end
        end
    end)

    -- Tick de tiempo (solo mientras se responde)
    self._tick = Timer.every(0.1, function()
        if not self._active or self._state ~= "answering" then return end
        self.timeLeft = math.max(0, self.timeLeft - 0.1)
        if self.timeLeft == 0 then
            self:_timeUp()
        end
        self:_refresh()
    end)
    self._tick:addToGroup(PauseMenuTimers)

    return self
end

-- =========================================================
-- Métodos internos/privados (prefijo “_”)
-- =========================================================

---
-- Construye la UI del minijuego (panel, títulos y etiquetas).
-- @within MathQuiz
function MathQuiz:_buildUI()
    self.root = Frame.new()
    self.root.size = UDim2.fromScale(1,1)
    self.root.bgColor = {0,0,0,0.6}
    self.root.zIndex = 180

    self.box = Frame.new()
    self.box:setParent(self.root)
    self.box.size = UDim2.fromScale(0.75, 0.70)
    self.box.position = UDim2.fromScale(0.5, 0.5)
    self.box.anchorPoint = {0.5, 0.5}
    self.box.bgColor = {0,0,0,0.85}
    self.box.zIndex = 181
    if self.box.applyStyle and Border then
        self.box:applyStyle(Border, { thicknessPx=3, color={1,1,1,1}, zOffset=2, insetPx=0 })
    end

    self.title = Textlabel.new("DATA CHECKPOINT")
    self.title:setParent(self.box)
    self.title.position = UDim2.fromScale(0.5, 0.14)
    self.title.size = UDim2.fromScale(0.9, 0.15)
    self.title.anchorPoint = {0.5, 0.5}
    self.title.textColor = {1,1,1,1}
    self.title.font = Fonts and Fonts.VT323 or self.title.font
    self.title.zIndex = 185

    self.story = PrintfLabel.new("")
    self.story:setParent(self.box)
    self.story.position = UDim2.fromScale(0.5, 0.36)
    self.story.size = UDim2.fromScale(0.9, 0.28)
    self.story.anchorPoint = {0.5, 0.5}
    self.story.textColor = {1,1,1,1}
    self.story.font = Fonts and Fonts.VT323 or love.graphics.getFont()
    self.story.align = "center"
    self.story.zIndex = 185

    self.input = Textlabel.new("")
    self.input:setParent(self.box)
    self.input.position = UDim2.fromScale(0.5, 0.58)
    self.input.size = UDim2.fromScale(0.9, 0.12)
    self.input.anchorPoint = {0.5, 0.5}
    self.input.textColor = {1,1,1,1}
    self.input.font = Fonts and Fonts.VT323 or self.input.font
    self.input.zIndex = 185

    self.feedback = Textlabel.new("")
    self.feedback:setParent(self.box)
    self.feedback.position = UDim2.fromScale(0.5, 0.70)
    self.feedback.size = UDim2.fromScale(0.9, 0.10)
    self.feedback.anchorPoint = {0.5, 0.5}
    self.feedback.textColor = {1,1,1,1}
    self.feedback.font = Fonts and Fonts.VT323 or self.feedback.font
    self.feedback.zIndex = 185

    self.continueLbl = Textlabel.new("") -- “Press Enter to continue”
    self.continueLbl:setParent(self.box)
    self.continueLbl.position = UDim2.fromScale(0.5, 0.8)
    self.continueLbl.size = UDim2.fromScale(0.9, 0.10)
    self.continueLbl.anchorPoint = {0.5, 0.5}
    self.continueLbl.textColor = {1,1,1,1}
    self.continueLbl.font = Fonts and Fonts.VT323 or self.continueLbl.font
    self.continueLbl.zIndex = 185
end

---
-- Refresca textos dinámicos: respuesta, “press enter”, cronómetro e info de ronda.
-- @within MathQuiz
function MathQuiz:_refresh()
    if not self._active then return end
    self.input.text = ("Answer: %s"):format(self.answer ~= "" and self.answer or "_")
    self.continueLbl.text = (self._state == "await") and "Press Enter to continue" or ""
    self.infoText = ("Time: %.1fs   Round: %d/%d   Tries: %d"):format(self.timeLeft, self.curr, self.rounds, self.triesLeft)

    if not self.info then
        self.info = Textlabel.new("")
        self.info:setParent(self.box)
        self.info.position = UDim2.fromScale(0.5, 0.90)
        self.info.size = UDim2.fromScale(0.9, 0.08)
        self.info.anchorPoint = {0.5, 0.5}
        self.info.textColor = {1,1,1,1}
        self.info.font = Fonts and Fonts.VT323 or self.info.font
        self.info.zIndex = 185
    end
    self.info.text = self.infoText
end

---
-- Inicia una nueva ronda generando un nuevo enunciado y reseteando contadores.
-- @within MathQuiz
function MathQuiz:_newRound()
    local s = makeScenario(self.curr)
    self.qText, self.qAns, self.qHint = s.text, s.answer, s.hint

    self.timeLeft  = self.timePer
    self.answer    = ""
    self.triesLeft = 2
    self._state    = "answering"
    self._awaitNextSuccess = false

    self.story.text = self.qText
    self.feedback.text = ""
    self.feedback.textColor = {1,1,1,1}
    self:_refresh()
end

---
-- Pequeño destello de color en el panel (feedback visual).
-- @tparam table color RGBA (0..1)
-- @within MathQuiz
function MathQuiz:_flash(color)
    local old = {unpack(self.box.bgColor)}
    self.box.bgColor = color
    Timer.after(0.15, function()
        self.box.bgColor = old
    end):addToGroup(PauseMenuTimers)
end

---
-- Maneja el fin por **tiempo agotado**. Muestra solución y entra en modo “await”.
-- @within MathQuiz
function MathQuiz:_timeUp()
    self._state = "await"
    self.feedback.text = ("Time's up. The correct answer was %d."):format(self.qAns)
    self.feedback.textColor = {1,0.6,0.6,1}
    self:_flash({0.25,0,0,0.9})
    self:_refresh()
    self._awaitNextSuccess = false
end

---
-- Intenta validar la respuesta ingresada.
-- Si acierta: feedback positivo y pasa a “await” esperando Enter.
-- Si falla: resta intentos, muestra pista; con 0 intentos, muestra solución y “await”.
-- @within MathQuiz
function MathQuiz:_trySubmit()
    local n = tonumber(self.answer)
    if n == self.qAns then
        self.feedback.text = "Nice! Correct."
        self.feedback.textColor = {0.6,1,0.6,1}
        self:_flash({0,0.25,0,0.9})
        self._state = "await"
        self._awaitNextSuccess = true
        self:_refresh()
    else
        self.triesLeft = self.triesLeft - 1
        if self.triesLeft > 0 then
            self.feedback.text = ("Almost! Hint: %s"):format(self.qHint or "try again.")
            self.feedback.textColor = {1,0.85,0.6,1}
            self:_flash({0.25,0,0,0.9})
            self.answer = ""
            self:_refresh()
        else
            self.feedback.text = ("Not this time. Correct: %d."):format(self.qAns)
            self.feedback.textColor = {1,0.6,0.6,1}
            self:_flash({0.25,0,0,0.9})
            self._state = "await"
            self._awaitNextSuccess = false
            self:_refresh()
        end
    end
end

---
-- Continúa luego del modo “await” (tras pulsar Enter).
-- Si el último resultado fue correcto, avanza de ronda o finaliza con éxito; si no, termina con derrota.
-- @within MathQuiz
function MathQuiz:_continueAfterAwait()
    if self._awaitNextSuccess then
        if self.curr >= self.rounds then
            self:_finish(true)
        else
            self.curr = self.curr + 1
            self:_newRound()
        end
    else
        self:_finish(false)
    end
end

---
-- Finaliza el minijuego, limpia recursos/UI y llama los callbacks correspondientes.
-- @tparam boolean success `true` si se completaron todas las rondas; `false` si se falló alguna
-- @within MathQuiz
function MathQuiz:_finish(success)
    if not self._active then return end
    self._active = false
    if self._kconn then Disconnect("keyPressed", self._kconn) end
    if self._tick then self._tick:Destroy() end
    if self.root then self.root:Destroy() end
    exitMiniState()

    if success then
        if self.onWin then self.onWin() end
    else
        if self.onLose then self.onLose() end
    end
end

return MathQuiz

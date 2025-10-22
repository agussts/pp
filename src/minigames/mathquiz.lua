---
-- MathQuiz (8–11) — English, internet-flavored story problems.
-- API:
--   MathQuiz.start{ rounds=3, timePer=20, onWin=fn, onLose=fn, audience="kids"| "teens", theme="netkids"|"tech" }
--
-- Inputs: digits 0–9, Backspace to delete, Enter to submit.
-- QoL: 2–3 tries, hints after first miss, Enter to continue between rounds.

local MathQuiz = {}
MathQuiz.__index = MathQuiz

-- ---------- game state gates ----------
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

-- ---------- utils ----------
local RNG = love.math
local function r(a,b) return RNG.random(a,b) end
local function pick(t) return t[RNG.random(1, #t)] end

-- ---------- presets ----------
local PRESETS = {
  kids = {
    sumMax = 15,  -- sums up to ~20
    subMax = 10,  -- no negatives
    mulA   = {2,5},
    mulB   = {2,5},
    tries  = 3,
    defaultTime = 25,
    twoStepByRound = { 10, 25, 40, 55 }, -- % chance of 2-step on rounds 1..N
  },
  teens = {
    sumMax = 30,
    subMax = 30,
    mulA   = {2,6},
    mulB   = {2,7},
    tries  = 2,
    defaultTime = 20,
    twoStepByRound = { 40, 60, 70, 80 },
  }
}

-- ---------- themes (texts) ----------
local THEMES = {
  -- kid-friendly internet words: files, photos, tabs, apps, messages
  netkids = {
    title = "INTERNET CHECKPOINT",
    pressEnter = "Press Enter to continue",
    answerLbl  = "Answer: %s",
    timeInfo   = function(t,cur,tot,tr) return ("Time: %.1fs   Round: %d/%d   Tries: %d"):format(t,cur,tot,tr) end,
    okMsg      = "Nice! Correct.",
    nopeMsg    = "Hint: %s",
    failMsg    = function(ans) return ("Not this time. The correct answer was %d."):format(ans) end,
    timeUpMsg  = function(ans) return ("Time's up. It was %d."):format(ans) end,

    -- one-step text variants
    sumTxt = {
      function(a,b) return ("You download %d files, then %d more. How many files in total?"):format(a,b) end,
      function(a,b) return ("You saved %d photos and later saved %d more. What's the total?"):format(a,b) end,
    },
    subTxt = {
      function(a,b) return ("You have %d photos in the cloud and delete %d. How many are left?"):format(a,b) end,
      function(a,b) return ("You stored %d videos; an app removes %d. How many remain?"):format(a,b) end,
    },
    mulTxt = {
      function(a,b) return ("You open %d tabs, each showing %d pictures. How many pictures altogether?"):format(a,b) end,
      function(a,b) return ("You make %d folders with %d files in each. What's the total files?"):format(a,b) end,
    },
    oneHintSum = "Add the two numbers.",
    oneHintSub = "Start from the total, then subtract the deleted ones.",
    oneHintMul = function(a,b) return ("Think %d groups of %d (repeated addition)."):format(a,b) end,

    -- two-step shapes (each has multiple phrasings)
    two_clone_minus = {
      text = {
        function(n,k,d) return ("You upload %d folders with %d videos in each. An app deletes %d videos. How many are left?"):format(n,k,d) end,
        function(n,k,d) return ("%d devices copy %d photos each, then %d photos are removed. How many remain?"):format(n,k,d) end,
      },
      hint = function(n,k,d) return ("Do %dx%d first, then subtract %d."):format(n,k,d) end
    },
    two_double_sum = {
      text = {
        function(a,b) return ("You save %d messages and then %d more. The app makes a copy of all. How many now?"):format(a,b) end,
        function(a,b) return ("You collect %d stickers and %d more, then duplicate the whole set. What's the total?"):format(a,b) end,
      },
      hint = function(a,b) return ("Add (%d+%d), then double."):format(a,b) end
    },
    two_sum_minus = {
      text = {
        function(a,b,c) return ("You add %d files and %d files, then clean up %d. How many are left?"):format(a,b,c) end,
        function(a,b,c) return ("You gather %d photos and %d photos, then remove %d. What's the total now?"):format(a,b,c) end,
      },
      hint = function(c) return ("Add first, then subtract %d."):format(c) end
    },
    two_cycles = {
      text = {
        function(t,g,h) return ("You run %d sends. Each send has %d groups with %d pictures each. How many pictures total?"):format(t,g,h) end,
        function(t,g,h) return ("There are %d rounds. In each round you send %d packs of %d files. What's the total files?"):format(t,g,h) end,
      },
      hint = function(t,g,h) return ("Find groups (%dx%d), then multiply by %d."):format(g,h,t) end
    },
    two_mul_plus = {
      text = {
        function(n,k,d) return ("%d folders hold %d files each. You then add %d bonus files. How many files now?"):format(n,k,d) end,
      },
      hint = function(n,k,d) return ("Multiply %dx%d, then add %d."):format(n,k,d) end
    },
    two_double_minus = {
      text = {
        function(a,b) return ("You have %d photos. The app makes a copy of all, then %d get corrupted. How many remain?"):format(a,b) end,
      },
      hint = function(a,b) return ("Double %d, then subtract %d."):format(a,b) end
    },
    two_triple_add_small = {
      text = {
        function(a,c) return ("You save three sets of %d files and then add %d more. What's the total?"):format(a,c) end,
      },
      hint = function(a,c) return ("Compute 3x%d, then add %d."):format(a,c) end
    },
    two_sum_times_small = {
      text = {
        function(a,b,c) return ("You gather %d and %d images; a filter sends them %d times. How many images are sent?"):format(a,b,c) end,
      },
      hint = function(a,b,c) return ("Add (%d+%d) first, then multiply by %d."):format(a,b,c) end
    },
  },

  -- neutral, short phrasing
  direct = {
    title = "DATA CHECKPOINT",
    pressEnter = "Press Enter to continue",
    answerLbl  = "Answer: %s",
    timeInfo   = function(t,cur,tot,tr) return ("Time: %.1fs   Round: %d/%d   Tries: %d"):format(t,cur,tot,tr) end,
    okMsg      = "Correct.",
    nopeMsg    = "Hint: %s",
    failMsg    = function(ans) return ("Correct answer: %d."):format(ans) end,
    timeUpMsg  = function(ans) return ("Time's up. %d."):format(ans) end,

    sumTxt = {
      function(a,b) return ("%d arrive, then %d more. Total?"):format(a,b) end,
      function(a,b) return ("Store %d, then %d. Total?"):format(a,b) end,
    },
    subTxt = {
      function(a,b) return ("Have %d, remove %d. Left?"):format(a,b) end,
      function(a,b) return ("%d cached; %d cleared. Left?"):format(a,b) end,
    },
    mulTxt = {
      function(a,b) return ("%d rows x %d each. Total?"):format(a,b) end,
      function(a,b) return ("%d groups of %d. Total?"):format(a,b) end,
    },
    oneHintSum = "Add.",
    oneHintSub = "Subtract.",
    oneHintMul = function(a,b) return ("Think %d groups of %d."):format(a,b) end,

    two_clone_minus = {
      text = {
        function(n,k,d) return ("%dx%d, then -%d. Total?"):format(n,k,d) end,
      },
      hint = function(n,k,d) return ("Multiply then subtract."):format() end
    },
    two_double_sum = {
      text = {
        function(a,b) return ("(%d+%d)x2. Total?"):format(a,b) end,
      },
      hint = function(a,b) return ("Add then double."):format() end
    },
    two_sum_minus = {
      text = {
        function(a,b,c) return ("(%d+%d)-%d. Total?"):format(a,b,c) end,
      },
      hint = function(c) return ("Add then subtract %d."):format(c) end
    },
    two_cycles = {
      text = {
        function(t,g,h) return ("%dx(%dx%d). Total?"):format(t,g,h) end,
      },
      hint = function(t,g,h) return ("Multiply groups then by rounds."):format() end
    },
    two_mul_plus = {
      text = {
        function(n,k,d) return ("(%dx%d)+%d. Total?"):format(n,k,d) end,
      },
      hint = function(n,k,d) return ("Multiply then add."):format() end
    },
    two_double_minus = {
      text = {
        function(a,b) return ("(2x%d)-%d. Total?"):format(a,b) end,
      },
      hint = function(a,b) return ("Double then subtract."):format() end
    },
    two_triple_add_small = {
      text = {
        function(a,c) return ("(3x%d)+%d. Total?"):format(a,c) end,
      },
      hint = function(a,c) return ("Triple then add."):format() end
    },
    two_sum_times_small = {
      text = {
        function(a,b,c) return ("(%d+%d)x%d. Total?"):format(a,b,c) end,
      },
      hint = function(a,b,c) return ("Add then multiply."):format() end
    },
  },
  
  tech = {
  title = "NETWORK CHECKPOINT",
  pressEnter = "Press Enter to continue",
  answerLbl  = "Answer: %s",
  timeInfo   = function(t,cur,tot,tr) return ("Time: %.1fs   Round: %d/%d   Tries: %d"):format(t,cur,tot,tr) end,
  okMsg      = "Nice! Correct.",
  nopeMsg    = "Hint: %s",
  failMsg    = function(ans) return ("Correct answer: %d."):format(ans) end,
  timeUpMsg  = function(ans) return ("Time's up. %d."):format(ans) end,

  -- Un paso con lenguaje de red
  sumTxt = {
    function(a,b) return ("You receive %d packets, then %d more. Total packets?"):format(a,b) end,
    function(a,b) return ("Server A sends %d packets and Server B sends %d. Total?"):format(a,b) end,
  },
  subTxt = {
    function(a,b) return ("Firewall drops %d from your %d packets. How many pass?"):format(b,a) end,
    function(a,b) return ("Cache stores %d; cleanup removes %d. Packets left?"):format(a,b) end,
  },
  mulTxt = {
    function(a,b) return ("Transmit on %d channels with %d packets each. Total?"):format(a,b) end,
    function(a,b) return ("%d rows, %d packets per row. Total packets?"):format(a,b) end,
  },
  oneHintSum = "Combine the amounts.",
  oneHintSub = "Start from total; subtract drops.",
  oneHintMul = function(a,b) return ("Think %d groups of %d (repeated addition)."):format(a,b) end,

  -- Dos pasos con narrativa de red
  two_clone_minus = {
    text = {
      function(n,k,d) return ("%d routers clone %d packets each; firewall blocks %d. How many get through?"):format(n,k,d) end,
    },
    hint = function(n,k,d) return ("Do %d×%d, then subtract %d."):format(n,k,d) end
  },
  two_double_sum = {
    text = {
      function(a,b) return ("You gather %d from node A and %d from node B. Compressor duplicates the total. How many now?"):format(a,b) end,
    },
    hint = function(a,b) return ("Add first (%d+%d), then double."):format(a,b) end
  },
  two_sum_minus = {
    text = {
      function(a,b,c) return ("You buffer %d and %d packets; maintenance removes %d. Packets remaining?"):format(a,b,c) end,
    },
    hint = function(c) return ("Add the buffers, then subtract %d."):format(c) end
  },
  two_cycles = {
    text = {
      function(t,g,h) return ("Run %d send cycles. Each cycle sends %d groups with %d packets each. Total?"):format(t,g,h) end,
    },
    hint = function(t,g,h) return ("Find groups (%d×%d), then multiply by %d."):format(g,h,t) end
  },
  two_mul_plus = {
    text = {
      function(n,k,d) return ("%d clusters with %d packets each, then add %d bonus packets. Total?"):format(n,k,d) end,
    },
    hint = function(n,k,d) return ("Multiply clusters, then add the bonus.") end
  },
  two_double_minus = {
    text = {
      function(a,b) return ("Bandwidth doubles to 2×%d packets, then %d are filtered. Packets left?"):format(a,b) end,
    },
    hint = function(a,b) return ("Double first, then subtract.") end
  },
  two_triple_add_small = {
    text = {
      function(a,c) return ("A booster triples %d packets, then we add %d more. Total?"):format(a,c) end,
    },
    hint = function(a,c) return ("Triple then add.") end
  },
  two_sum_times_small = {
    text = {
      function(a,b,c) return ("Combine %d and %d packets; send this bundle %d times. Total?"):format(a,b,c) end,
    },
    hint = function(a,b,c) return ("Add then multiply.") end
  },
}
}

-- ---------- generators ----------
local function mk_one_step(P, T)
  local kind = pick({"sum","sub","mul"})
  if kind == "sum" then
    local a = r(3, P.sumMax-3)
    local b = r(2, math.min(10, P.sumMax - a))
    return { text = pick(T.sumTxt)(a,b), answer = a+b, hint = T.oneHintSum }
  elseif kind == "sub" then
    local a = r(6, P.subMax)
    local b = r(2, math.min(10, a))
    return { text = pick(T.subTxt)(a,b), answer = a-b, hint = T.oneHintSub }
  else
    local a = r(P.mulA[1], P.mulA[2])
    local b = r(P.mulB[1], P.mulB[2])
    return { text = pick(T.mulTxt)(a,b), answer = a*b, hint = T.oneHintMul(a,b) }
  end
end

local function mk_two_step(P, T)
  local shape = pick({"clone_minus","double_sum","sum_then_minus","cycles","mul_plus","double_minus","triple_add_small","sum_times_small"})
  if shape == "clone_minus" then
    local n = r(2,4); local k = r(2,5); local d = r(1, math.min(5, n*k-1))
    return { text = pick(T.two_clone_minus.text)(n,k,d), answer = n*k - d, hint = T.two_clone_minus.hint(n,k,d) }
  elseif shape == "double_sum" then
    local a = r(2,8); local b = r(2,8)
    return { text = pick(T.two_double_sum.text)(a,b), answer = 2*(a+b), hint = T.two_double_sum.hint(a,b) }
  elseif shape == "sum_then_minus" then
    local a = r(4,10); local b = r(3,8); local c = r(1, math.min(6, a+b-1))
    return { text = pick(T.two_sum_minus.text)(a,b,c), answer = a+b-c, hint = T.two_sum_minus.hint(c) }
  elseif shape == "cycles" then
    local t = r(2,3); local g = r(2,3); local h = r(2,4)
    return { text = pick(T.two_cycles.text)(t,g,h), answer = t*(g*h), hint = T.two_cycles.hint(t,g,h) }
  elseif shape == "mul_plus" then
    local n = r(2,4); local k = r(2,5); local d = r(1,5)
    return { text = pick(T.two_mul_plus.text)(n,k,d), answer = n*k + d, hint = T.two_mul_plus.hint(n,k,d) }
  elseif shape == "double_minus" then
    local a = r(5,12); local b = r(1, math.min(8, 2*a-1))
    return { text = pick(T.two_double_minus.text)(a,b), answer = 2*a - b, hint = T.two_double_minus.hint(a,b) }
  elseif shape == "triple_add_small" then
    local a = r(3,8); local c = r(1,5)
    return { text = pick(T.two_triple_add_small.text)(a,c), answer = 3*a + c, hint = T.two_triple_add_small.hint(a,c) }
  else -- sum_times_small
    local a = r(2,8); local b = r(2,8); local c = r(2,3)
    return { text = pick(T.two_sum_times_small.text)(a,b,c), answer = (a+b)*c, hint = T.two_sum_times_small.hint(a,b,c) }
  end
end

local function makeScenario(roundIdx, P, T)
  local idx = math.min(roundIdx, #P.twoStepByRound)
  local chance = P.twoStepByRound[idx]
  if r(1,100) <= chance then
    return mk_two_step(P, T)
  else
    return mk_one_step(P, T)
  end
end

-- ---------- API ----------
function MathQuiz.start(opt)
  opt = opt or {}
  print(Config.SavedConfigs.MAUDIENCE)
  local audience = Config.SavedConfigs.MAUDIENCE or (opt.audience == "teens") and "teens" or "kids"
  local theme    = Config.SavedConfigs.MTHEME or (opt.theme == "tech") and "tech" or "netkids"
  local P        = PRESETS[audience]
  local T        = THEMES[theme]

  local self = setmetatable({}, MathQuiz)
  self.rounds    = opt.rounds or 3
  self.timePer   = opt.timePer or P.defaultTime
  self.onWin     = opt.onWin
  self.onLose    = opt.onLose

  self.curr      = 1
  self.answer    = ""
  self.timeLeft  = self.timePer
  self.triesBase = P.tries
  self.triesLeft = self.triesBase
  self._active   = true
  self._state    = "answering"
  self._awaitNextSuccess = false
  self._preset   = P
  self._theme    = T

  enterMiniState()
  self:_buildUI()
  self:_newRound()

  self._kconn = Connect("keyPressed", function(key)
    if not self._active then return end
    if self._state == "await" then
      if key=="return" or key=="kpenter" then self:_continueAfterAwait() end
      return
    end
    if key == "backspace" then
      self.answer = self.answer:sub(1,-2); self:_refresh()
    elseif key=="return" or key=="kpenter" then
      self:_trySubmit()
    elseif key:match("^%d$") then
      if #self.answer < 6 then self.answer = self.answer..key; self:_refresh() end
    end
  end)

  self._tick = Timer.every(0.1, function()
    if not self._active or self._state ~= "answering" then return end
    self.timeLeft = math.max(0, self.timeLeft - 0.1)
    if self.timeLeft == 0 then self:_timeUp() end
    self:_refresh()
  end)
  self._tick:addToGroup(PauseMenuTimers)

  return self
end

-- ---------- UI ----------
function MathQuiz:_buildUI()
  local T = self._theme

  self.root = Frame.new()
  self.root.size = UDim2.fromScale(1,1)
  self.root.bgColor = {0,0,0,0.6}
  self.root.zIndex = 180

  self.box = Frame.new()
  self.box:setParent(self.root)
  self.box.size = UDim2.fromScale(0.78, 0.70)
  self.box.position = UDim2.fromScale(0.5, 0.5)
  self.box.anchorPoint = {0.5, 0.5}
  self.box.bgColor = {0,0,0,0.9}
  self.box.zIndex = 181
  if self.box.applyStyle and Border then
    self.box:applyStyle(Border, { thicknessPx=3, color={1,1,1,1}, zOffset=2, insetPx=0 })
  end

  self.title = Textlabel.new(T.title)
  self.title:setParent(self.box)
  self.title.position = UDim2.fromScale(0.5, 0.14)
  self.title.size = UDim2.fromScale(0.9, 0.14)
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

  self.continueLbl = Textlabel.new("")
  self.continueLbl:setParent(self.box)
  self.continueLbl.position = UDim2.fromScale(0.5, 0.8)
  self.continueLbl.size = UDim2.fromScale(0.9, 0.10)
  self.continueLbl.anchorPoint = {0.5, 0.5}
  self.continueLbl.textColor = {1,1,1,1}
  self.continueLbl.font = Fonts and Fonts.VT323 or self.continueLbl.font
  self.continueLbl.zIndex = 185
end

function MathQuiz:_refresh()
  if not self._active then return end
  local T = self._theme
  self.input.text = T.answerLbl:format(self.answer ~= "" and self.answer or "_")
  self.continueLbl.text = (self._state == "await") and T.pressEnter or ""
  local info = T.timeInfo(self.timeLeft, self.curr, self.rounds, self.triesLeft)
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
  self.info.text = info
end

-- ---------- flow ----------
function MathQuiz:_newRound()
  local s = makeScenario(self.curr, self._preset, self._theme)
  self.qText, self.qAns, self.qHint = s.text, s.answer, s.hint
  self.timeLeft  = self.timePer
  self.answer    = ""
  self.triesLeft = self.triesBase
  self._state    = "answering"
  self._awaitNextSuccess = false
  self.story.text = self.qText
  self.feedback.text = ""
  self.feedback.textColor = {1,1,1,1}
  self:_refresh()
end

function MathQuiz:_flash(color)
  local old = {unpack(self.box.bgColor)}
  self.box.bgColor = color
  Timer.after(0.15, function() self.box.bgColor = old end):addToGroup(PauseMenuTimers)
end

function MathQuiz:_timeUp()
  local T = self._theme
  self._state = "await"
  self.feedback.text = T.timeUpMsg(self.qAns)
  self.feedback.textColor = {1,0.6,0.6,1}
  self:_flash({0.25,0,0,0.9})
  self:_refresh()
  self._awaitNextSuccess = false
end

function MathQuiz:_trySubmit()
  local T = self._theme
  local n = tonumber(self.answer)
  if n == self.qAns then
    self.feedback.text = T.okMsg
    self.feedback.textColor = {0.6,1,0.6,1}
    self:_flash({0,0.25,0,0.9})
    self._state = "await"
    self._awaitNextSuccess = true
    self:_refresh()
  else
    self.triesLeft = self.triesLeft - 1
    if self.triesLeft > 0 then
      self.feedback.text = T.nopeMsg:format(self.qHint or "try again")
      self.feedback.textColor = {1,0.85,0.6,1}
      self:_flash({0.25,0,0,0.9})
      self.answer = ""
      self:_refresh()
    else
      self.feedback.text = T.failMsg(self.qAns)
      self.feedback.textColor = {1,0.6,0.6,1}
      self:_flash({0.25,0,0,0.9})
      self._state = "await"
      self._awaitNextSuccess = false
      self:_refresh()
    end
  end
end

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

function MathQuiz:_finish(success)
  if not self._active then return end
  self._active = false
  if self._kconn then Disconnect("keyPressed", self._kconn) end
  if self._tick then self._tick:Destroy() end
  if self.root then self.root:Destroy() end
  exitMiniState()
  if success then
    print("win")
    if self.onWin then self.onWin() end
  else
    print("lose")
    if self.onLose then self.onLose() end
  end
end

return MathQuiz

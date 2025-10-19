-- src/ui/teach.lua
local Teach = {}

local seen = {}  -- volatile in-memory (you can mirror to World.flags if you want)

-- Show a popup once per key. Uses Popups.show() and a small delay queue.
function Teach.once(key, opt)
  if seen[key] or (World.flags and World.flags[key]) or not Config.SavedConfigs.TEACH then return end
  seen[key] = true
  if World.flags then World.flags[key] = true end

  -- sane defaults; keep it short for kids
  opt = opt or {}
  opt.text = opt.text or "Hint"
  opt.icon = opt.icon -- optional path
  opt.hold = opt.hold or 2.0   -- seconds visible
  opt.inPosScale  = opt.inPosScale  or {0.85, 0.20} -- top-rightish
  opt.outPosScale = opt.outPosScale or {1.10, 0.20} -- slides in from right
  opt.holdTime = 3

  Popup.show(opt)
end

-- Convenience: chained hints with short gaps (once per chain key).
function Teach.chain(key, items, gap)
  if seen[key] or (World.flags and World.flags[key]) or not Config.SavedConfigs.TEACH then return end
  seen[key] = true
  if World.flags then World.flags[key] = true end
  local delay = 0
  gap = gap or 0.25
  for i, it in ipairs(items or {}) do
    Timer.after(delay, function() Teach.once(key.."_"..i, it) end):addToGroup(PlayingTimers)
    delay = delay + (it.hold or 2) + gap
  end
end

return Teach

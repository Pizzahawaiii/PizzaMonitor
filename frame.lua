local PWBM = PizzaWorldBuffs_Monitor
local PWB = PizzaWorldBuffs

PWBM.frame = CreateFrame('Frame', 'PizzaWorldBuffs_Monitor_Frame', UIParent)
PWBM.frame:ClearAllPoints()
PWBM.frame:SetPoint('TOP', 0, -50)
PWBM.frame:SetFrameStrata('LOW')
PWBM.frame:SetWidth(200)
PWBM.frame:SetHeight(1)

-- Mouse Drag
PWBM.frame:SetMovable(true)
PWBM.frame:EnableMouse(true)
PWBM.frame:RegisterForDrag('leftButton')
PWBM.frame:SetScript('OnDragStart', function ()
  PWBM.frame:StartMoving()
end)
PWBM.frame:SetScript('OnDragStop', function ()
  PWBM.frame:StopMovingOrSizing()
end)

-- Text
PWBM.frame.text = PWBM.frame:CreateFontString('PizzaWorldBuffs_Monitor_Text', 'DIALOG', 'GameFontWhite')
PWBM.frame.text:SetJustifyH('LEFT')
PWBM.frame.text:SetPoint('CENTER', 0, 0)

local function toTime(seconds)
  local s = math.mod(seconds, 60)
  local minutes = (seconds - s) / 60
  local m = math.mod(minutes, 60)
  local h = (minutes - m) / 60
  return h, m, s
end

local function toTimeString(h, m, s)
  if not h and not m and not s then return 'N/A' end
  if h > 0 then
    return string.format('%d:%d:%.2d', h, m, s)
  else
    return string.format('%d:%.2d', m, s)
  end
  -- return (h > 0 and h .. 'h ' or '') .. (m > 0 and m .. 'm ' or '') .. s .. 's'
end

PWBM.frame:SetScript('OnUpdate', function ()
  -- Throttle this function so it doesn't run on every frame render
  if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

  PWBM.frame.content = '|cffa050ffPizza|rWorldBuffs |cff777777Monitor|r\n'

  local playerCount = 0
  local playerList = ''
  for player, details in pairs(PWBM_seen) do
    local lastSeenAgo = math.floor(GetTime() - details.lastSeen)
    playerList = playerList .. '\n' .. player ..  '|cff777777   v' .. details.version .. '|cffcccccc   ' .. toTimeString(toTime(lastSeenAgo)) .. '|r '
    playerCount = playerCount + 1
  end

  PWBM.frame.content = PWBM.frame.content .. '\nUsers: ' .. playerCount .. '\n' .. playerList

  PWBM.frame.text:SetText(PWBM.frame.content)
  PWBM.frame:SetHeight(PWBM.frame.text:GetHeight() + 10)
  PWBM.frame:SetWidth(PWBM.frame.text:GetWidth() + 10)
end)
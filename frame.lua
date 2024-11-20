local PWBM = PizzaWorldBuffs_Monitor
local PWB = PizzaWorldBuffs

function length(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

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
end

local function toVersionStr(v)
  local major = math.floor(v / 10000)
  local minor = math.floor((v - major * 10000) / 100)
  local patch = v - major * 10000 - minor * 100
  return major .. '.' .. minor .. '.' .. patch
end

local versionCounts = {}
local zoneTentCounts = {}
PWBM.frame:SetScript('OnUpdate', function ()
  -- Throttle this function so it doesn't run on every frame render
  if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

  for v in pairs(versionCounts) do
    versionCounts[v] = nil
  end

  for v in pairs(zoneTentCounts) do
    zoneTentCounts[v] = nil
  end

  PWBM.frame.content = '|cffa050ffPizza|rWorldBuffs |cff777777Monitor|r'

  local playerCount = 0
  local playerList = ''
  for player, details in pairs(PWBM_seen) do
    versionCounts[details.version] = versionCounts[details.version] and versionCounts[details.version] + 1 or 1
    local lastSeenAgo = math.floor(GetTime() - details.lastSeen)
    playerList = playerList .. '\n' .. player ..  '|cff777777   v' .. toVersionStr(details.version) .. '|cffcccccc   ' .. toTimeString(toTime(lastSeenAgo)) .. '|r '
    playerCount = playerCount + 1
  end

  local versions = {}
  for version in pairs(versionCounts) do
    table.insert(versions, version)
  end
  table.sort(versions, function(a, b) return a > b end)

  local versionList = ''
  local maxVersion = 0
  for _, version in pairs(versions) do
    local count = versionCounts[version]
    local percentage = math.floor(count * 100 / playerCount + 0.5)
    versionList = versionList .. '\n|cff777777v' .. toVersionStr(version) .. ':|r ' .. count .. '|cffcccccc (' .. percentage .. '%)|r'
    if tonumber(version) > maxVersion then
      maxVersion = tonumber(version)
    end
  end

  local onMaxVersionCount = 0
  local onMaxVersion = {}
  for player, details in pairs(PWBM_seen) do
    if tonumber(details.version) == maxVersion then
      onMaxVersionCount = onMaxVersionCount + 1
      table.insert(onMaxVersion, player)
    end
  end

  table.sort(onMaxVersion)

  onMaxVersionStr = '\nOn v' .. toVersionStr(maxVersion) .. ':\n'
  for _, player in ipairs(onMaxVersion) do
    onMaxVersionStr = onMaxVersionStr .. '\n' .. player
  end

  local tentCount = 0
  local zoneTentCountsStr = ''
  if PWB_tents then
    for zone, tents in pairs(PWB_tents) do
      if tents then
        local zoneTentCount = 0
        for i = 1, length(tents), 1 do
          if tents[i] then
            tentCount = tentCount + 1
            zoneTentCount = zoneTentCount + 1
          end
        end

        zoneTentCountsStr = zoneTentCountsStr .. zone .. ': ' .. zoneTentCount .. '\n'
      end
    end
  end

  local tentsStr = 'Total Tents: ' .. tentCount .. '\n' .. zoneTentCountsStr

  PWBM.frame.content = PWBM.frame.content .. '\n\nUsers: ' .. playerCount .. '\n' .. versionList .. '\n\n' .. tentsStr -- .. '\n' .. playerList

  PWBM.frame.text:SetText(PWBM.frame.content)
  PWBM.frame:SetHeight(PWBM.frame.text:GetHeight() + 10)
  PWBM.frame:SetWidth(PWBM.frame.text:GetWidth() + 10)
end)

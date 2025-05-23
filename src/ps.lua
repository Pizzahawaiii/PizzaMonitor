PizzaMonitor:RegisterModule('ps', function ()
  PM.ps = CreateFrame('Frame', 'PizzaSlicesMonitor', UIParent)

  function PM.ps.init()
    _G.PizzaMonitor_data.ps = data.ps or {}
    _G.PizzaMonitor_data.ps.seen = data.ps.seen or {}
  end

  local function recordMessage(player, version)
    if data.ps.seen[player] then
      _G.PizzaMonitor_data.ps.seen[player].lastSeen = time()
      _G.PizzaMonitor_data.ps.seen[player].version = version
    else
      _G.PizzaMonitor_data.ps.seen[player] = {
        firstSeen = time(),
        lastSeen = time(),
        version = version,
        messageCount = 1,
      }
    end
  end

  PM.ps:RegisterEvent('CHAT_MSG_CHANNEL')
  PM.ps:SetScript('OnEvent', function ()
    if event == 'CHAT_MSG_CHANNEL' then
      local _, _, source = string.find(arg4, '(%d+)%.')
      local channelName

      if source then
        _, channelName = GetChannelName(source)
      end

      if channelName == 'LFT' then
        local addonName, version = PM.utils.strSplit(arg1, ':')
        if addonName == 'PizzaSlices' then
          if arg2 == UnitName('player') then return end
          recordMessage(arg2, version)
        end
      end
    end
  end)

  -- PM.ps:SetScript('OnUpdate', function ()
  --   -- Throttle this function so it doesn't run on every frame render
  --   if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end
  --
  --   for player, details in pairs(data.ps.seen) do
  --     -- Remove players not seen in 30 days
  --     if time() > details.lastSeen + 2592000 then
  --       _G.PizzaMonitor_data.ps.seen[player] = nil
  --     end
  --   end
  -- end)

  -- Frame
  PM.ps:ClearAllPoints()
  PM.ps:SetPoint('TOP', 0, -50)
  PM.ps:SetFrameStrata('LOW')
  PM.ps:SetWidth(200)
  PM.ps:SetHeight(1)

  -- Mouse Drag
  PM.ps:SetMovable(true)
  PM.ps:EnableMouse(true)
  PM.ps:RegisterForDrag('leftButton')
  PM.ps:SetScript('OnDragStart', function ()
    PM.ps:StartMoving()
  end)
  PM.ps:SetScript('OnDragStop', function ()
    PM.ps:StopMovingOrSizing()
  end)

  -- Text
  PM.ps.text = PM.ps:CreateFontString(PM.ps:GetName() .. 'Text', 'DIALOG', 'GameFontWhite')
  PM.ps.text:SetJustifyH('LEFT')
  PM.ps.text:SetPoint('CENTER', 0, 0)

  local versionCounts = {}
  local zoneTentCounts = {}
  PM.ps:SetScript('OnUpdate', function ()
    -- Throttle this function so it doesn't run on every frame render
    if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

    -- Remove players not seen in 24 hours
    local thresholdHours = 24
    for player, details in pairs(data.ps.seen) do
      if time() > details.lastSeen + (thresholdHours * 60 * 60) then
        _G.PizzaMonitor_data.ps.seen[player] = nil
      end
    end

    for v in pairs(versionCounts) do
      versionCounts[v] = nil
    end

    for v in pairs(zoneTentCounts) do
      zoneTentCounts[v] = nil
    end

    PM.ps.content = '|cffa050ffPizza|rMonitor |cff777777PizzaSlices|r\n\n(Last ' .. thresholdHours .. ' hours)'

    local playerCount = 0
    local playerList = ''
    for player, details in pairs(data.ps.seen) do
      versionCounts[details.version] = versionCounts[details.version] and versionCounts[details.version] + 1 or 1
      local lastSeenAgo = math.floor(time() - details.lastSeen)
      local lastSeenAgoStr = PM.utils.toTimeString(PM.utils.toTime(lastSeenAgo))
      playerList = playerList .. '\n' .. player ..  '|cff777777   v' .. PM.utils.toVersionStr(details.version) .. '|cffcccccc   ' .. lastSeenAgoStr .. '|r '
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
      versionList = versionList .. '\n|cff777777v' .. PM.utils.toVersionStr(version) .. ':|r ' .. count .. '|cffcccccc (' .. percentage .. '%)|r'
      if tonumber(version) > maxVersion then
        maxVersion = tonumber(version)
      end
    end

    local onMaxVersionCount = 0
    local onMaxVersion = {}
    for player, details in pairs(data.ps.seen) do
      if tonumber(details.version) == maxVersion then
        onMaxVersionCount = onMaxVersionCount + 1
        table.insert(onMaxVersion, player)
      end
    end

    table.sort(onMaxVersion)

    onMaxVersionStr = '\nOn v' .. PM.utils.toVersionStr(maxVersion) .. ':\n'
    for _, player in ipairs(onMaxVersion) do
      onMaxVersionStr = onMaxVersionStr .. '\n' .. player
    end

    PM.ps.content = PM.ps.content .. '\n\nUsers: ' .. playerCount .. '\n' .. versionList -- .. '\n\n' .. playerList

    PM.ps.text:SetText(PM.ps.content)
    PM.ps:SetHeight(PM.ps.text:GetHeight() + 10)
    PM.ps:SetWidth(PM.ps.text:GetWidth() + 10)
  end)
end)

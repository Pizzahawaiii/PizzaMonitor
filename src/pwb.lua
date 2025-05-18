PizzaMonitor:RegisterModule('pwb', function ()
  PM.pwb = CreateFrame('Frame', 'PizzaWorldBuffsMonitor', UIParent)

  function PM.pwb.init()
    _G.PizzaMonitor_data.pwb = data.pwb or {}
    _G.PizzaMonitor_data.pwb.seen = data.pwb.seen or {}
  end

  local function recordMessage(player, version)
    if data.pwb.seen[player] then
      _G.PizzaMonitor_data.pwb.seen[player].lastSeen = time()
      _G.PizzaMonitor_data.pwb.seen[player].version = version
      _G.PizzaMonitor_data.pwb.seen[player].messageCount = data.pwb.seen[player].messageCount + 1
    else
      _G.PizzaMonitor_data.pwb.seen[player] = {
        firstSeen = time(),
        lastSeen = time(),
        version = version,
        messageCount = 1,
      }
    end
  end

  PM.pwb:RegisterEvent('CHAT_MSG_CHANNEL')
  PM.pwb:SetScript('OnEvent', function ()
    if event == 'CHAT_MSG_CHANNEL' then
      local _, _, source = string.find(arg4, '(%d+)%.')
      local channelName

      if source then
        _, channelName = GetChannelName(source)
      end

      if channelName == 'LFT' then
        local addonName, version, msg = PM.utils.strSplit(arg1, ':')
        if addonName == 'PWB' or addonName == 'PWB_DMF' or addonName == 'PWB_T' then
          if arg2 == UnitName('player') then return end
          recordMessage(arg2, version)
        end
      end
    end
  end)

  -- Frame
  PM.pwb:ClearAllPoints()
  PM.pwb:SetPoint('TOP', 0, 0)
  PM.pwb:SetFrameStrata('LOW')
  PM.pwb:SetWidth(200)
  PM.pwb:SetHeight(1)

  -- Mouse Drag
  PM.pwb:SetMovable(true)
  PM.pwb:EnableMouse(true)
  PM.pwb:RegisterForDrag('leftButton')
  PM.pwb:SetScript('OnDragStart', function ()
    PM.pwb:StartMoving()
  end)
  PM.pwb:SetScript('OnDragStop', function ()
    PM.pwb:StopMovingOrSizing()
  end)

  -- Text
  PM.pwb.text = PM.pwb:CreateFontString(PM.pwb:GetName() .. 'Text', 'DIALOG', 'GameFontWhite')
  PM.pwb.text:SetJustifyH('LEFT')
  PM.pwb.text:SetPoint('CENTER', 0, 0)

  local versionCounts = {}
  local zoneTentCounts = {}
  PM.pwb:SetScript('OnUpdate', function ()
    -- Throttle this function so it doesn't run on every frame render
    if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

    -- Remove players not seen for 5 minutes
    for player, details in pairs(data.pwb.seen) do
      if time() > details.lastSeen + 300 then
        _G.PizzaMonitor_data.pwb.seen[player] = nil
      end
    end

    for v in pairs(versionCounts) do
      versionCounts[v] = nil
    end

    for v in pairs(zoneTentCounts) do
      zoneTentCounts[v] = nil
    end

    PM.pwb.content = '|cffa050ffPizza|rMonitor |cff777777PizzaWorldBuffs|r'

    local playerCount = 0
    local playerList = ''
    for player, details in pairs(data.pwb.seen) do
      versionCounts[details.version] = versionCounts[details.version] and versionCounts[details.version] + 1 or 1
      local lastSeenAgo = math.floor(GetTime() - details.lastSeen)
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
    for player, details in pairs(data.pwb.seen) do
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

    local tentsStr = ''
    if PWB_tents then
      local tentCount = 0
      local zoneTentCountsStr = ''
      if PWB_tents then
        for zone, tents in pairs(PWB_tents) do
          if tents then
            local zoneTentCount = 0
            for i = 1, PM.utils.length(tents), 1 do
              if tents[i] then
                tentCount = tentCount + 1
                zoneTentCount = zoneTentCount + 1
              end
            end

            zoneTentCountsStr = zoneTentCountsStr .. zone .. ': ' .. zoneTentCount .. '\n'
          end
        end
      end
      tentsStr = 'Total Tents: ' .. tentCount .. '\n' .. zoneTentCountsStr
    end

    PM.pwb.content = PM.pwb.content .. '\n\nUsers: ' .. playerCount .. '\n' .. versionList .. '\n\n' .. tentsStr -- .. '\n' .. playerList

    PM.pwb.text:SetText(PM.pwb.content)
    PM.pwb:SetHeight(PM.pwb.text:GetHeight() + 10)
    PM.pwb:SetWidth(PM.pwb.text:GetWidth() + 10)
  end)
end)

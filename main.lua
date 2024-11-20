PizzaWorldBuffs_Monitor = CreateFrame('Frame', 'PizzaWorldBuffs_Monitor', UIParent)
local PWBM = PizzaWorldBuffs_Monitor
local PWB = PizzaWorldBuffs

local timerStrs = {}

PWBM:RegisterEvent('CHAT_MSG_CHANNEL')
PWBM:RegisterEvent('PLAYER_ENTERING_WORLD')
PWBM:SetScript('OnEvent', function ()
  if event == 'PLAYER_ENTERING_WORLD' then
    PWBM_seen = {}
  end

  if event == 'CHAT_MSG_CHANNEL' then
    local _, _, source = string.find(arg4, '(%d+)%.')
    local channelName

    if source then
      _, channelName = GetChannelName(source)
    end

    -- Sender: arg2
    if channelName == 'LFT' then
      local addonName, version, msg = PWB.utils.strSplit(arg1, ':')
      if addonName == PWB.abbrev then
        local player = arg2

        if player == 'Pizzahawaii' or player == 'Pizzamista' or player == 'Pizzabuffsa' or player == 'Pizzabuffsh' then
          return
        end

        if PWBM_seen[player] then
          PWBM_seen[player].lastSeen = GetTime()
          PWBM_seen[player].version = version
          PWBM_seen[player].messageCount = PWBM_seen[player].messageCount + 1
        else
          PWBM_seen[player] = {
            firstSeen = GetTime(),
            lastSeen = GetTime(),
            version = version,
            messageCount = 1,
          }
        end
      end
    end
  end
end)

PWBM:SetScript('OnUpdate', function ()
  -- Throttle this function so it doesn't run on every frame render
  if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

  for player, details in pairs(PWBM_seen) do
    if GetTime() > details.lastSeen + 300 then
      PWBM_seen[player] = nil
    end
  end
end)

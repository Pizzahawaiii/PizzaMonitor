PizzaMonitor:RegisterModule('lft', function ()
  PM.lft = CreateFrame('Frame', 'LFTMonitor', UIParent)

  function PM.lft.init()
    _G.PizzaMonitor_data.lft = data.lft or {}

    PM.lft.captureStart = time()
    PM.lft.capturing = true
    PM.lft.counts = {
      total = 0,
      addons = {},
    }
  end

  PM.lft:RegisterEvent('CHAT_MSG_CHANNEL')
  PM.lft:SetScript('OnEvent', function ()
    if not PM.lft.capturing then return end

    if event == 'CHAT_MSG_CHANNEL' then
      local _, _, source = string.find(arg4, '(%d+)%.')
      local channelName

      if source then
        _, channelName = GetChannelName(source)
      end

      if channelName == 'LFT' then
        PM.lft.counts.total = PM.lft.counts.total + 1
        local addonName = PM.utils.strSplit(PM.utils.strSplit(arg1, ':'), ',')
        if PM.lft.counts.addons[addonName] then
          PM.lft.counts.addons[addonName] = PM.lft.counts.addons[addonName] + 1
        else
          PM.lft.counts.addons[addonName] = 1
        end
      end
    end
  end)

  -- Frame
  PM.lft:ClearAllPoints()
  PM.lft:SetPoint('TOP', 0, -50)
  PM.lft:SetFrameStrata('LOW')
  PM.lft:SetWidth(200)
  PM.lft:SetHeight(1)

  -- Mouse Drag
  PM.lft:SetMovable(true)
  PM.lft:EnableMouse(true)
  PM.lft:RegisterForDrag('leftButton')
  PM.lft:SetScript('OnDragStart', function ()
    PM.lft:StartMoving()
  end)
  PM.lft:SetScript('OnDragStop', function ()
    PM.lft:StopMovingOrSizing()
  end)

  -- Text
  PM.lft.text = PM.lft:CreateFontString(PM.lft:GetName() .. 'Text', 'DIALOG', 'GameFontWhite')
  PM.lft.text:SetJustifyH('LEFT')
  PM.lft.text:SetPoint('CENTER', 0, 0)

  PM.lft:SetScript('OnUpdate', function ()
    if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

    PM.lft.content = '|cffa050ffPizza|rMonitor |cff777777LFT|r'

    if PM.lft.capturing then
      local capturingSince = time() - PM.lft.captureStart
      local capturingSinceStr = PM.utils.toTimeString(PM.utils.toTime(capturingSince))
      PM.lft.content = PM.lft.content .. '\n\n' .. 'Capturing since: ' .. capturingSinceStr

      local mps = string.format('%.2f', PM.lft.counts.total / capturingSince)
      PM.lft.content = PM.lft.content .. '\n\n' .. 'Total messages: ' .. PM.lft.counts.total
      PM.lft.content = PM.lft.content .. '\n' .. 'Total mps: ' .. mps .. '\n'

      local addons = {}
      for addon, count in pairs(PM.lft.counts.addons) do
        local addonMps = count / capturingSince
        local percentage = count * 100 / PM.lft.counts.total
        table.insert(addons, { name = addon, mps = addonMps, percentage = percentage })
      end

      table.sort(addons, function (a, b) return a.mps > b.mps end)

      for _, addon in ipairs(addons) do
        PM.lft.content = PM.lft.content .. '\n' .. PM.Colors.primary .. addon.name .. PM.Colors.secondary .. ': ' .. string.format('%.2f', addon.mps) .. ' mps ' .. PM.Colors.grey .. '(' .. string.format('%.2f', addon.percentage) .. '%)'
      end
    end

    PM.lft.text:SetText(PM.lft.content)
    PM.lft:SetWidth(PM.lft.text:GetWidth() + 10)
    PM.lft:SetHeight(PM.lft.text:GetHeight() + 10)
  end)
end)

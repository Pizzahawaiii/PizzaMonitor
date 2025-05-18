PizzaMonitor = CreateFrame('Frame', 'PizzaMonitor', UIParent)
local PM = PizzaMonitor

PM.env = {}
PM.modules = {}
PM.moduleNames = {}

PM.Colors = {
  primary = '|cffa050ff',
  secondary = '|cffffffff',
  red = '|cffff462e',
  grey = '|cffaaaaaa',
  green = '|cff00ff98',
}

setmetatable(PM.env, { __index = function (self, key)
  if key == 'T' then return end
  return getfenv(0)[key]
end})

function PM:GetEnv()
  PM.env._G = getfenv(0)
  PM.env.PM = PizzaMonitor
  PM.env.data = PizzaMonitor_data
  return PM.env
end

setfenv(1, PM:GetEnv())

function PM:Print(msg)
  local prefix = PM.Colors.primary .. 'Pizza' .. PM.Colors.secondary .. 'Monitor:|r '
  DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
end

function PM:RegisterModule(name, module)
  if PM.modules[name] then return end
  PM.modules[name] = module
  table.insert(PM.moduleNames, name)
end

function PM:LoadModule(name)
  setfenv(PM.modules[name], PM:GetEnv())
  PM.modules[name]()
end

PM:RegisterEvent('ADDON_LOADED')
PM:SetScript('OnEvent', function ()
  if event == 'ADDON_LOADED' and arg1 == 'PizzaMonitor' then
    _G.PizzaMonitor_data = PizzaMonitor_data or {}

    for _, moduleName in PM.moduleNames do
      PM:LoadModule(moduleName)
    end

    for _, moduleName in PM.moduleNames do
      if PM[moduleName] and PM[moduleName].init then
        PM[moduleName].init()
      end
    end
  end
end)

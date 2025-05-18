PizzaMonitor:RegisterModule('utils', function ()
  PM.utils = {}

  function PM.utils.strSplit(str, delimiter)
    if not str then return nil end
    local delimiter, fields = delimiter or ':', {}
    local pattern = string.format('([^%s]+)', delimiter)
    string.gsub(str, pattern, function(c) fields[table.getn(fields)+1] = c end)
    return unpack(fields)
  end

  function PM.utils.length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
  end

  function PM.utils.toTime(seconds)
    local s = math.mod(seconds, 60)
    local minutes = (seconds - s) / 60
    local m = math.mod(minutes, 60)
    local h = (minutes - m) / 60
    return h, m, s
  end

  function PM.utils.toTimeString(h, m, s)
    if not h and not m and not s then return 'N/A' end
    if h > 0 then
      return string.format('%d:%d:%.2d', h, m, s)
    else
      return string.format('%d:%.2d', m, s)
    end
  end

  function PM.utils.toVersionStr(v)
    local major = math.floor(v / 10000)
    local minor = math.floor((v - major * 10000) / 100)
    local patch = v - major * 10000 - minor * 100
    return major .. '.' .. minor .. '.' .. patch
  end
end)

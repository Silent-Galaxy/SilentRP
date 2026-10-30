-- server.lua
local root = getRootElement()

-- ==========================
-- تنظیمات دیتابیس
-- ==========================
local DB = {
    name = "mta_db",
    host = "127.0.0.1",
    user = "root",
    pass = ""
}

local db = dbConnect("mysql", "dbname="..DB.name..";host="..DB.host, DB.user, DB.pass)
if not db then
    outputError("[SC] Database connection failed.")
    return
end

dbExec(db, "SET NAMES utf8mb4")

-- ==========================
-- ساخت جدول‌های لازم
-- ==========================
dbExec(db, [[CREATE TABLE IF NOT EXISTS `server_control_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_name` varchar(50) NOT NULL,
  `admin_ip` varchar(45) DEFAULT '',
  `action` varchar(50) NOT NULL,
  `target` varchar(100) DEFAULT '',
  `details` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

dbExec(db, [[CREATE TABLE IF NOT EXISTS `server_managed_resources` (
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT 'manual',
  `enabled` tinyint(1) DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

-- ==========================
-- استیت پیش‌فرض
-- ==========================
local S = {
    weather = 1,
    weatherRandom = false,
    temp = 22,
    tempAuto = true,
    naturalTime = true,
    timezone = "iran",
    hour = 12,
    minute = 0,
    second = 0
}

local managed = {}
local adminCache = {}

-- ==========================
-- آب‌وهواها
-- ==========================
local weatherNames = {
    [0] = "Extra Sunny",
    [1] = "Sunny",
    [2] = "Cloudy",
    [3] = "Rainy",
    [4] = "Storm",
    [5] = "Foggy",
    [6] = "Overcast"
}

for i = 0, 22 do
    if not weatherNames[i] then
        weatherNames[i] = "Weather " .. i
    end
end

local weatherTemp = {
    [0] = {28, 35},
    [1] = {22, 30},
    [2] = {15, 24},
    [3] = {10, 18},
    [4] = {5, 14},
    [5] = {8, 16},
    [6] = {12, 20}
}

-- ==========================
-- توابع کمکی
-- ==========================
local function bool(v)
    return v == true or v == 1 or v == "1" or v == "true"
end

local function encode(v)
    if type(v) == "boolean" then
        return v and "1" or "0"
    end
    return tostring(v)
end

local function clampInt(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return math.floor(v)
end

local function clampNum(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function shortText(v, len)
    v = tostring(v or "")
    return v:sub(1, len or 100)
end

-- ==========================
-- ذخیره/خواندن تنظیمات
-- ==========================
local function save(k, v)
    S[k] = v
    dbExec(db, "REPLACE INTO `server_settings` (`setting_key`, `setting_val`) VALUES (?,?)", "sc_"..k, encode(v))
end

local function loadSettings()
    local numericKeys = {
        weather = true,
        temp = true,
        hour = true,
        minute = true,
        second = true
    }

    local boolKeys = {
        weatherRandom = true,
        naturalTime = true,
        tempAuto = true
    }

    local q = dbQuery(db, "SELECT `setting_key`, `setting_val` FROM `server_settings` WHERE `setting_key` LIKE 'sc_%'")
    local r = dbPoll(q, 5000)

    if type(r) ~= "table" then
        return
    end

    for _, row in ipairs(r) do
        local k = row.setting_key:sub(4)
        local v = row.setting_val

        if boolKeys[k] then
            S[k] = bool(v)
        elseif numericKeys[k] then
            S[k] = tonumber(v) or S[k]
        else
            S[k] = v
        end
    end

    S.weather = clampInt(S.weather, 0, 22)
    S.temp = clampNum(S.temp, -50, 70)
    S.hour = clampInt(S.hour, 0, 23)
    S.minute = clampInt(S.minute, 0, 59)
    S.second = clampInt(S.second, 0, 59)

    if S.timezone ~= "iran" and S.timezone ~= "server" then
        S.timezone = "iran"
    end
end

-- ==========================
-- State
-- ==========================
local function getState()
    return {
        weather = S.weather,
        weatherName = weatherNames[S.weather],
        temp = S.temp,
        tempAuto = S.tempAuto,
        weatherRandom = S.weatherRandom,
        naturalTime = S.naturalTime,
        timezone = S.timezone,
        hour = S.hour,
        minute = S.minute,
        second = S.second,
        weathers = weatherNames
    }
end

local function broadcastState()
    triggerClientEvent(root, "sc:state", root, getState())
end

-- ==========================
-- مدیریت ریسورس‌ها
-- ==========================
local function saveResource(name, category, enabled)
    name = shortText(name, 100)
    category = shortText(category or "manual", 50)
    enabled = bool(enabled)

    managed[name] = {
        category = category,
        enabled = enabled
    }

    dbExec(db, "REPLACE INTO `server_managed_resources` (`name`,`category`,`enabled`) VALUES (?,?,?)", name, category, enabled and 1 or 0)
end

local function loadResources()
    managed = {}

    local q = dbQuery(db, "SELECT `name`,`category`,`enabled` FROM `server_managed_resources`")
    local r = dbPoll(q, 5000)

    if type(r) ~= "table" then
        return
    end

    for _, row in ipairs(r) do
        managed[row.name] = {
            category = row.category or "manual",
            enabled = bool(row.enabled)
        }
    end
end

local function discoverResources()
    local ok, elems = pcall(getElementsByType, "resource", root)
    if not ok or type(elems) ~= "table" then
        return
    end

    for _, el in ipairs(elems) do
        local okName, name = pcall(getElementName, el)
        if not okName or type(name) ~= "string" or name == "" then
            okName, name = pcall(getElementID, el)
        end

        if okName and type(name) == "string" and name ~= "" and not managed[name] then
            saveResource(name, "auto", true)
        end
    end
end

local function resourceStatus(name)
    local res = getResourceFromName(name)
    if not res then
        return "missing"
    end

    local ok, state = pcall(getResourceInfo, res, "state")
    if ok and state ~= nil and state ~= false and state ~= "" then
        return tostring(state)
    end

    local okEl, el = pcall(getResourceRootElement, res)
    if okEl and el and isElement(el) then
        return "running"
    end

    return "stopped"
end

local function getResourceList()
    local list = {}

    for name, data in pairs(managed) do
        list[#list + 1] = {
            name = name,
            status = resourceStatus(name),
            category = data.category,
            enabled = data.enabled
        }
    end

    table.sort(list, function(a, b)
        return a.name < b.name
    end)

    return list
end

-- ==========================
-- لاگ‌ها
-- ==========================
local function addLog(player, action, target, details)
    local name, ip = "SYSTEM", ""

    if player and player ~= "SYSTEM" and isElement(player) then
        name = getPlayerName(player) or "?"
        ip = getPlayerIP(player) or ""
    end

    action = shortText(action, 50)
    target = shortText(target, 100)
    details = tostring(details or "")

    dbExec(db, "INSERT INTO `server_control_logs` (`admin_name`,`admin_ip`,`action`,`target`,`details`) VALUES (?,?,?,?,?)", name, ip, action, target, details)

    local row = {
        admin = name,
        action = action,
        target = target,
        details = details,
        time = tostring(os.date("%Y-%m-%d %H:%M:%S") or "")
    }

    if player and player ~= "SYSTEM" and isElement(player) then
        triggerClientEvent(player, "sc:logAdded", player, row)
    end
end

local function getLogs(limit)
    limit = clampInt(limit, 1, 200)

    local q = dbQuery(db, "SELECT `admin_name`, `action`, `target`, `details`, `created_at` FROM `server_control_logs` ORDER BY `id` DESC LIMIT ?", limit)
    local r = dbPoll(q, 5000)

    if type(r) ~= "table" then
        return {}
    end

    local out = {}
    for _, row in ipairs(r) do
        out[#out + 1] = {
            admin = row.admin_name,
            action = row.action,
            target = row.target or "",
            details = row.details or "",
            time = row.created_at
        }
    end

    return out
end

-- ==========================
-- بررسی ادمین
-- ==========================
local function isAdmin(player)
    if not player or not isElement(player) then
        return false
    end

    local acc = getPlayerAccount(player)
    if not acc then
        return false
    end

    local aname = accountGetName(acc)
    if not aname then
        return false
    end

    local cached = adminCache[aname]
    if cached and cached.exp > getTickCount() then
        return cached.val
    end

    local val = false

    for _, gname in ipairs({"Admin", "SuperAdmin"}) do
        local g = aclGetGroup(gname)
        if g then
            local ok, inGroup = pcall(isObjectInACLGroup, "user."..aname, g)
            if ok and inGroup then
                val = true
                break
            end
        end
    end

    if not val then
        local okQ, q = pcall(dbQuery, db, "SELECT `admin_level` FROM `accounts` WHERE `username`=?", aname)
        if okQ and q then
            local r = dbPoll(q, 2000)
            if type(r) == "table" and r[1] then
                local lvl = tonumber(r[1].admin_level)
                if lvl and lvl >= 0 then
                    val = true
                end
            end
        end
    end

    adminCache[aname] = {
        val = val,
        exp = getTickCount() + 60000
    }

    return val
end

-- ==========================
-- ساعت
-- ==========================
local function setWorldClock(h, m, s, persist)
    h = clampInt(h, 0, 23)
    m = clampInt(m, 0, 59)
    s = clampInt(s, 0, 59)

    pcall(setWorldTime, h, m, s)

    S.hour, S.minute, S.second = h, m, s

    if persist ~= false then
        save("hour", h)
        save("minute", m)
        save("second", s)
    end
end

local function getWorldClock()
    local ok, a, b, c = pcall(getWorldTime)

    if ok then
        if type(a) == "table" then
            return clampInt(a.hour, 0, 23), clampInt(a.minute, 0, 59), clampInt(a.second, 0, 59)
        elseif type(a) == "number" then
            return clampInt(a, 0, 23), clampInt(b or 0, 0, 59), clampInt(c or 0, 0, 59)
        end
    end

    return S.hour, S.minute, S.second
end

local function getRealClock()
    local t

    if S.timezone == "iran" then
        t = getRealTime(true) or getRealTime()
    else
        t = getRealTime() or getRealTime(true)
    end

    if type(t) ~= "table" then
        t = {hour = 12, minute = 0, second = 0}
    end

    local h = clampInt(t.hour, 0, 23)
    local m = clampInt(t.minute, 0, 59)
    local s = clampInt(t.second, 0, 59)

    if S.timezone == "iran" then
        -- ایران UTC+3:30
        local total = h * 60 + m + 210
        total = total % 1440
        h = math.floor(total / 60)
        m = total % 60
    end

    return h, m, s
end

-- ==========================
-- دما و هوا
-- ==========================
local function computeTemp(weather, hour)
    local range = weatherTemp[weather] or {10, 25}
    local val = math.random(range[1], range[2])

    if hour < 6 or hour >= 21 then
        val = val - 5
    end

    return clampNum(val, -30, 55)
end

local function applyWeather(id, instant)
    id = clampInt(id, 0, 22)
    S.weather = id

    pcall(setWeather, id, instant ~= false)

    if S.tempAuto then
        local h = getWorldClock()
        S.temp = computeTemp(id, h)
        save("temp", S.temp)
    end

    save("weather", id)
    broadcastState()
end

-- ==========================
-- اکشن ریسورس
-- ==========================
local selfResource = getResourceInfo(getThisResource(), "name") or "server_control_panel"

local function callResourceAction(name, action)
    if name == selfResource and (action == "stop" or action == "disable") then
        return false, "protected"
    end

    local fn

    if action == "start" then
        fn = function()
            local r = startResource(name)
            if r == false then
                r = startResource(name, true)
            end
            return r
        end
    elseif action == "stop" then
        fn = function()
            return stopResource(name)
        end
    elseif action == "disable" then
        fn = function()
            return stopResource(name, true)
        end
    elseif action == "restart" then
        fn = function()
            return restartResource(name)
        end
    else
        return false, "invalid"
    end

    local ok, ret = pcall(fn)
    if not ok then
        return false, "error"
    end

    return ret ~= false, "ok"
end

-- ==========================
-- Event ها
-- ==========================
local events = {
    "sc:requestAccess",
    "sc:setTime",
    "sc:setNaturalTime",
    "sc:setWeather",
    "sc:setWeatherRandom",
    "sc:setTemp",
    "sc:resourceAction",
    "sc:addResource",
    "sc:removeResource",
    "sc:refresh"
}

for _, e in ipairs(events) do
    addEvent(e, true)
end

addEventHandler("sc:requestAccess", root, function()
    if not isAdmin(source) then
        return
    end

    triggerClientEvent(source, "sc:accessGranted", source, getState(), getResourceList(), getLogs(50))
end)

addEventHandler("sc:setTime", root, function(h, m, s)
    if not isAdmin(source) then
        return
    end

    h = clampInt(h, 0, 23)
    m = clampInt(m, 0, 59)
    s = clampInt(s, 0, 59)

    setWorldClock(h, m, s, true)
    addLog(source, "set_time", "", string.format("%02d:%02d:%02d", h, m, s))
    broadcastState()
end)

addEventHandler("sc:setNaturalTime", root, function(enabled, tz)
    if not isAdmin(source) then
        return
    end

    enabled = bool(enabled)
    tz = (tz == "server") and "server" or "iran"

    S.naturalTime = enabled
    S.timezone = tz

    save("naturalTime", enabled)
    save("timezone", tz)

    if enabled then
        local h, m, s = getRealClock()
        setWorldClock(h, m, s, false)
    else
        setWorldClock(S.hour, S.minute, S.second, true)
    end

    addLog(source, "set_natural_time", tz, enabled and "enabled" or "disabled")
    broadcastState()
end)

addEventHandler("sc:setWeather", root, function(id)
    if not isAdmin(source) then
        return
    end

    id = clampInt(id, 0, 22)
    applyWeather(id, true)
    addLog(source, "set_weather", tostring(id), weatherNames[id] or "")
end)

addEventHandler("sc:setWeatherRandom", root, function(enabled)
    if not isAdmin(source) then
        return
    end

    enabled = bool(enabled)
    S.weatherRandom = enabled
    save("weatherRandom", enabled)

    addLog(source, "set_weather_random", "", enabled and "enabled" or "disabled")
    broadcastState()
end)

addEventHandler("sc:setTemp", root, function(temp, auto)
    if not isAdmin(source) then
        return
    end

    temp = clampNum(temp, -50, 70)
    auto = bool(auto)

    S.temp = temp
    S.tempAuto = auto

    save("temp", temp)
    save("tempAuto", auto)

    addLog(source, "set_temp", "", string.format("%.1f C auto=%s", temp, auto and "1" or "0"))
    broadcastState()
end)

addEventHandler("sc:resourceAction", root, function(name, action)
    if not isAdmin(source) then
        return
    end

    name = shortText(name, 100)
    action = tostring(action or "")

    if name == "" then
        return
    end

    local ok, msg = callResourceAction(name, action)

    if msg == "protected" then
        addLog(source, "resource_protected", name, "Cannot stop/disable self resource")
        return
    end

    if msg == "invalid" then
        return
    end

    if managed[name] then
        if action == "start" or action == "restart" then
            managed[name].enabled = true
        elseif action == "disable" then
            managed[name].enabled = false
        end

        saveResource(name, managed[name].category, managed[name].enabled)
    else
        saveResource(name, "manual", action ~= "disable")
    end

    addLog(source, "resource_"..action, name, (ok and "success" or "failed") .. " (" .. tostring(msg) .. ")")
    triggerClientEvent(source, "sc:resources", source, getResourceList())
end)

addEventHandler("sc:addResource", root, function(name, cat)
    if not isAdmin(source) then
        return
    end

    name = shortText(name, 100)
    if name == "" then
        return
    end

    cat = shortText(cat or "manual", 50)

    saveResource(name, cat, true)
    addLog(source, "add_resource", name, cat)
    triggerClientEvent(source, "sc:resources", source, getResourceList())
end)

addEventHandler("sc:removeResource", root, function(name)
    if not isAdmin(source) then
        return
    end

    name = shortText(name, 100)

    managed[name] = nil
    dbExec(db, "DELETE FROM `server_managed_resources` WHERE `name`=?", name)

    addLog(source, "remove_resource", name, "")
    triggerClientEvent(source, "sc:resources", source, getResourceList())
end)

addEventHandler("sc:refresh", root, function()
    if not isAdmin(source) then
        return
    end

    discoverResources()
    triggerClientEvent(source, "sc:accessGranted", source, getState(), getResourceList(), getLogs(50))
end)

-- ==========================
-- ارسال state به پلیر جدید
-- ==========================
addEventHandler("onPlayerJoin", root, function()
    local player = source

    setTimer(function()
        if isElement(player) then
            triggerClientEvent(player, "sc:state", root, getState())
        end
    end, 2000, 1)
end)

-- ==========================
-- Initialize
-- ==========================
loadSettings()
loadResources()
discoverResources()

math.randomseed(getTickCount())

applyWeather(S.weather, true)

if S.naturalTime then
    local h, m, s = getRealClock()
    setWorldClock(h, m, s, false)
else
    setWorldClock(S.hour, S.minute, S.second, true)
end

broadcastState()

-- همگام‌سازی ساعت طبیعی
setTimer(function()
    if S.naturalTime then
        local h, m, s = getRealClock()
        setWorldClock(h, m, s, false)
        broadcastState()
    end
end, 30000, 0)

-- بروزرسانی دما
setTimer(function()
    if S.tempAuto then
        local h = getWorldClock()
        S.temp = computeTemp(S.weather, h)
        save("temp", S.temp)
        broadcastState()
    end
end, 60000, 0)

-- آب‌وهوای رندوم
setTimer(function()
    if S.weatherRandom then
        local ids = {}
        for id in pairs(weatherNames) do
            ids[#ids + 1] = id
        end

        if #ids > 0 then
            local newId = ids[math.random(#ids)]
            applyWeather(newId, true)
            addLog("SYSTEM", "random_weather", tostring(newId), weatherNames[newId] or "")
        end
    end
end, 600000, 0)

-- کشف ریسورس‌های جدید
setTimer(discoverResources, 60000, 0)
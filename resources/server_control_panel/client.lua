-- client.lua
local root = getRootElement()

local win, lblState
local edHour, edMin, edSec, chkNatural, cmbTZ, btnTime, btnSaveTZ
local cmbWeather, chkRandom, btnWeather
local edTemp, chkAutoTemp, btnTemp
local resGrid, logGrid, edRes, edCat
local btnStart, btnStop, btnDisable, btnRestart, btnAdd, btnRemove, btnRefresh, btnClose

local panelState = {}
local weatherItems = {}
local tzItems = {"iran", "server"}

local function toInt(v)
    return math.floor(tonumber(v) or 0)
end

local function isOpen()
    return win and isElement(win)
end

local function closePanel()
    if isOpen() then
        destroyElement(win)
        win = nil
    end
end

local function selectedResource()
    if not resGrid or not isElement(resGrid) then
        return nil
    end

    local row = guiGridListGetSelectedItem(resGrid)
    if row == -1 then
        return nil
    end

    return guiGridListGetItemText(resGrid, row, 0)
end

local function fillResources(list)
    if not resGrid or not isElement(resGrid) then
        return
    end

    guiGridListClear(resGrid)

    for _, r in ipairs(list or {}) do
        local row = guiGridListInsertRow(resGrid)

        guiGridListSetItemText(resGrid, row, 0, tostring(r.name or ""), false, false)
        guiGridListSetItemText(resGrid, row, 1, tostring(r.status or ""), false, false)
        guiGridListSetItemText(resGrid, row, 2, r.enabled and "yes" or "no", false, false)
    end
end

local function fillLogs(list)
    if not logGrid or not isElement(logGrid) then
        return
    end

    guiGridListClear(logGrid)

    for _, r in ipairs(list or {}) do
        local row = guiGridListInsertRow(logGrid)

        guiGridListSetItemText(logGrid, row, 0, tostring(r.admin or ""), false, false)
        guiGridListSetItemText(logGrid, row, 1, tostring(r.action or ""), false, false)
        guiGridListSetItemText(logGrid, row, 2, tostring(r.target or ""), false, false)
        guiGridListSetItemText(logGrid, row, 3, tostring(r.details or ""), false, false)
        guiGridListSetItemText(logGrid, row, 4, tostring(r.time or ""), false, false)
    end
end

local function populateWeathers(weathers)
    if not cmbWeather or not isElement(cmbWeather) or #weatherItems > 0 then
        return
    end

    local ids = {}
    for id in pairs(weathers or {}) do
        ids[#ids + 1] = id
    end

    table.sort(ids)

    for _, id in ipairs(ids) do
        weatherItems[#weatherItems + 1] = id
        guiComboBoxAddItem(cmbWeather, tostring(id) .. " - " .. tostring(weathers[id]))
    end
end

local function updateState(s)
    panelState = s or panelState

    if not isOpen() then
        return
    end

    local wname = panelState.weatherName or (panelState.weathers and panelState.weathers[panelState.weather]) or panelState.weather

    guiSetText(lblState, string.format(
        "Weather: %s | Temp: %.1f C | Time: %02d:%02d:%02d | Natural: %s | Random: %s",
        tostring(wname),
        tonumber(panelState.temp) or 0,
        toInt(panelState.hour),
        toInt(panelState.minute),
        toInt(panelState.second),
        panelState.naturalTime and "ON" or "OFF",
        panelState.weatherRandom and "ON" or "OFF"
    ))

    guiSetText(edHour, string.format("%02d", toInt(panelState.hour)))
    guiSetText(edMin, string.format("%02d", toInt(panelState.minute)))
    guiSetText(edSec, string.format("%02d", toInt(panelState.second)))

    guiCheckBoxSetSelected(chkNatural, panelState.naturalTime and true or false)
    guiComboBoxSetSelectedIndex(cmbTZ, panelState.timezone == "server" and 1 or 0)

    for i, id in ipairs(weatherItems) do
        if id == panelState.weather then
            guiComboBoxSetSelectedIndex(cmbWeather, i - 1)
            break
        end
    end

    guiCheckBoxSetSelected(chkRandom, panelState.weatherRandom and true or false)
    guiSetText(edTemp, string.format("%.1f", tonumber(panelState.temp) or 0))
    guiCheckBoxSetSelected(chkAutoTemp, panelState.tempAuto and true or false)
end

local function onClick(el, fn)
    addEventHandler("onClientGUIClick", el, function(button, cstate)
        if button == "left" and cstate == "down" then
            fn()
        end
    end, false)
end

local function addHandlers()
    onClick(btnTime, function()
        triggerServerEvent("sc:setTime", localPlayer, guiGetText(edHour), guiGetText(edMin), guiGetText(edSec))
    end)

    onClick(btnSaveTZ, function()
        local idx = guiComboBoxGetSelectedIndex(cmbTZ)
        local tz = tzItems[idx + 1] or "iran"
        triggerServerEvent("sc:setNaturalTime", localPlayer, guiCheckBoxGetSelected(chkNatural), tz)
    end)

    onClick(btnWeather, function()
        local idx = guiComboBoxGetSelectedIndex(cmbWeather)
        if idx >= 0 and weatherItems[idx + 1] then
            triggerServerEvent("sc:setWeather", localPlayer, weatherItems[idx + 1])
        end
    end)

    onClick(chkRandom, function()
        triggerServerEvent("sc:setWeatherRandom", localPlayer, guiCheckBoxGetSelected(chkRandom))
    end)

    onClick(btnTemp, function()
        triggerServerEvent("sc:setTemp", localPlayer, guiGetText(edTemp), guiCheckBoxGetSelected(chkAutoTemp))
    end)

    onClick(btnStart, function()
        local name = selectedResource()
        if name then
            triggerServerEvent("sc:resourceAction", localPlayer, name, "start")
        end
    end)

    onClick(btnStop, function()
        local name = selectedResource()
        if name then
            triggerServerEvent("sc:resourceAction", localPlayer, name, "stop")
        end
    end)

    onClick(btnDisable, function()
        local name = selectedResource()
        if name then
            triggerServerEvent("sc:resourceAction", localPlayer, name, "disable")
        end
    end)

    onClick(btnRestart, function()
        local name = selectedResource()
        if name then
            triggerServerEvent("sc:resourceAction", localPlayer, name, "restart")
        end
    end)

    onClick(btnAdd, function()
        triggerServerEvent("sc:addResource", localPlayer, guiGetText(edRes), guiGetText(edCat))
    end)

    onClick(btnRemove, function()
        local name = selectedResource()
        if name then
            triggerServerEvent("sc:removeResource", localPlayer, name)
        end
    end)

    onClick(btnRefresh, function()
        triggerServerEvent("sc:refresh", localPlayer)
    end)

    onClick(btnClose, closePanel)
end

local function createPanel()
    local sx, sy = guiGetScreenSize()

    win = guiCreateWindow((sx - 830) / 2, (sy - 610) / 2, 830, 610, "Server Control Panel", false)
    guiWindowSetSizable(win, false)

    lblState = guiCreateLabel(15, 25, 800, 20, "", false, win)

    -- Time
    guiCreateLabel(15, 55, 50, 20, "Time:", false, win)
    edHour = guiCreateEdit(70, 55, 40, 22, "12", false, win)
    edMin = guiCreateEdit(115, 55, 40, 22, "00", false, win)
    edSec = guiCreateEdit(160, 55, 40, 22, "00", false, win)
    btnTime = guiCreateButton(205, 55, 50, 22, "Set", false, win)

    chkNatural = guiCreateCheckbox(265, 55, 80, 22, "Natural", false, win)
    cmbTZ = guiCreateComboBox(350, 55, 80, 80, "", false, win)
    guiComboBoxAddItem(cmbTZ, "Iran")
    guiComboBoxAddItem(cmbTZ, "Server")
    btnSaveTZ = guiCreateButton(435, 55, 60, 22, "Save", false, win)

    -- Weather
    guiCreateLabel(15, 90, 60, 20, "Weather:", false, win)
    cmbWeather = guiCreateComboBox(80, 90, 180, 240, "", false, win)
    chkRandom = guiCreateCheckbox(270, 90, 80, 22, "Random", false, win)
    btnWeather = guiCreateButton(355, 90, 60, 22, "Set", false, win)

    -- Temp
    guiCreateLabel(15, 125, 60, 20, "Temp C:", false, win)
    edTemp = guiCreateEdit(80, 125, 60, 22, "22", false, win)
    chkAutoTemp = guiCreateCheckbox(150, 125, 60, 22, "Auto", false, win)
    btnTemp = guiCreateButton(215, 125, 60, 22, "Set", false, win)

    -- Resources
    guiCreateLabel(15, 165, 200, 20, "Resources:", false, win)

    resGrid = guiCreateGridList(15, 190, 390, 250, false, win)
    guiGridListAddColumn(resGrid, "Name", 0.45)
    guiGridListAddColumn(resGrid, "Status", 0.30)
    guiGridListAddColumn(resGrid, "Enabled", 0.20)

    edRes = guiCreateEdit(15, 450, 180, 22, "", false, win)
    edCat = guiCreateEdit(200, 450, 100, 22, "manual", false, win)
    btnAdd = guiCreateButton(305, 450, 45, 22, "Add", false, win)
    btnRemove = guiCreateButton(355, 450, 45, 22, "Del", false, win)

    btnStart = guiCreateButton(15, 480, 75, 22, "Start", false, win)
    btnStop = guiCreateButton(95, 480, 75, 22, "Stop", false, win)
    btnDisable = guiCreateButton(175, 480, 75, 22, "Disable", false, win)
    btnRestart = guiCreateButton(255, 480, 75, 22, "Restart", false, win)
    btnRefresh = guiCreateButton(335, 480, 75, 22, "Refresh", false, win)

    -- Logs
    guiCreateLabel(420, 165, 200, 20, "Logs:", false, win)

    logGrid = guiCreateGridList(420, 190, 395, 310, false, win)
    guiGridListAddColumn(logGrid, "Admin", 0.15)
    guiGridListAddColumn(logGrid, "Action", 0.18)
    guiGridListAddColumn(logGrid, "Target", 0.15)
    guiGridListAddColumn(logGrid, "Details", 0.27)
    guiGridListAddColumn(logGrid, "Time", 0.25)

    btnClose = guiCreateButton(745, 510, 70, 25, "Close", false, win)

    addHandlers()
end

-- ==========================
-- Events
-- ==========================
addEvent("sc:accessGranted", true)
addEventHandler("sc:accessGranted", root, function(s, resources, logs)
    if not isOpen() then
        createPanel()
    end

    populateWeathers(s and s.weathers)
    updateState(s)
    fillResources(resources)
    fillLogs(logs)
end)

addEvent("sc:resources", true)
addEventHandler("sc:resources", root, fillResources)

addEvent("sc:state", true)
addEventHandler("sc:state", root, updateState)

addEvent("sc:logAdded", true)
addEventHandler("sc:logAdded", root, function(row)
    if not isOpen() or not logGrid or not isElement(logGrid) then
        return
    end

    local r = guiGridListInsertRow(logGrid)

    guiGridListSetItemText(logGrid, r, 0, tostring(row.admin or ""), false, false)
    guiGridListSetItemText(logGrid, r, 1, tostring(row.action or ""), false, false)
    guiGridListSetItemText(logGrid, r, 2, tostring(row.target or ""), false, false)
    guiGridListSetItemText(logGrid, r, 3, tostring(row.details or ""), false, false)
    guiGridListSetItemText(logGrid, r, 4, tostring(row.time or ""), false, false)
end)

addCommandHandler("scp", function()
    triggerServerEvent("sc:requestAccess", localPlayer)
end)

addEventHandler("onClientResourceStop", root, closePanel)

-- نمایش دما و هوا روی صفحه
addEventHandler("onClientRender", root, function()
    if not panelState or not panelState.temp then
        return
    end

    local sx, sy = guiGetScreenSize()
    local wname = panelState.weatherName or (panelState.weathers and panelState.weathers[panelState.weather]) or panelState.weather
    local txt = string.format("Temp: %.1f C | Weather: %s", tonumber(panelState.temp) or 0, tostring(wname))

    dxDrawText(txt, sx * 0.72, sy * 0.02, sx * 0.99, sy * 0.06, tocolor(255, 255, 255, 220), 1.0, "default", "left", "top", false, false, false)
end)
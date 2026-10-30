local screenW, screenH = guiGetScreenSize()
local browserGUI = nil
local browser = nil
local isPanelOpen = false

local isManualMode = false
local currentGear = 1
local maxGears = 5

-- ساخت مرورگر
addEventHandler("onClientResourceStart", resourceRoot, function()
    browserGUI = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
    guiSetVisible(browserGUI, false)

    browser = guiGetBrowser(browserGUI)
    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/local/ui/index.html")
    end)
end)

function toggleMechanicPanel()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not isPanelOpen then
        if not veh then
            outputChatBox("#FF4444[خطا] #FFFFFFبرای تنظیم خودرو باید سوار ماشین باشید!", 255, 255, 255, true)
            return
        end
        if getVehicleOccupant(veh, 0) ~= localPlayer then
            outputChatBox("#FF4444[خطا] #FFFFFFتنها راننده به تنظیمات خودرو دسترسی دارد.", 255, 255, 255, true)
            return
        end

        isPanelOpen = true
        guiSetVisible(browserGUI, true)
        guiBringToFront(browserGUI) -- انتقال مرورگر به بالاترین لایه کلیک
        showCursor(true)
        guiSetInputMode("no_binds")
        focusBrowser(browser)
        triggerServerEvent("mechanic:requestVehicleFullData", resourceRoot)
    else
        isPanelOpen = false
        guiSetVisible(browserGUI, false)
        showCursor(false)
        guiSetInputMode("allow_binds")
    end
end
bindKey("F4", "down", toggleMechanicPanel)
addCommandHandler("tune", toggleMechanicPanel)
addCommandHandler("mech", toggleMechanicPanel)

addEvent("mechanic:sendFullDataToClient", true)
addEventHandler("mechanic:sendFullDataToClient", root, function(payload)
    if browser then
        executeBrowserJavascript(browser, "initVehicleData(" .. toJSON(payload) .. ");")
    end
end)

addEvent("cef:closePanel", true)
addEventHandler("cef:closePanel", root, function()
    if isPanelOpen then toggleMechanicPanel() end
end)

local function hexToRgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

-- پیش‌نمایش رنگ ثابت
addEvent("cef:livePreviewColors", true)
addEventHandler("cef:livePreviewColors", root, function(colorsJSON)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local colors = fromJSON(colorsJSON)
    if not colors then return end

    local r1, g1, b1 = hexToRgb(colors.c1)
    local r2, g2, b2 = hexToRgb(colors.c2)
    local lr, lg, lb = hexToRgb(colors.light)

    setElementData(veh, "v_anim_color", nil, true)
    setVehicleColor(veh, r1, g1, b1, r2, g2, b2)
    setVehicleHeadLightColor(veh, lr, lg, lb)
end)

-- تغییر حالت رقص نور
addEvent("cef:setDynamicLighting", true)
addEventHandler("cef:setDynamicLighting", root, function(dataJSON)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local data = fromJSON(dataJSON)
    triggerServerEvent("mechanic:serverSetDynamicLight", resourceRoot, data)
end)

addEvent("cef:fixVehicle", true)
addEventHandler("cef:fixVehicle", root, function()
    triggerServerEvent("mechanic:serverFixVehicle", resourceRoot)
end)

addEvent("cef:toggleGodmode", true)
addEventHandler("cef:toggleGodmode", root, function(state)
    triggerServerEvent("mechanic:serverToggleGodmode", resourceRoot, state)
end)

addEvent("cef:saveAllSettings", true)
addEventHandler("cef:saveAllSettings", root, function(dataJSON)
    triggerServerEvent("mechanic:serverSaveAll", resourceRoot, fromJSON(dataJSON))
end)

addEvent("cef:resetHandling", true)
addEventHandler("cef:resetHandling", root, function()
    triggerServerEvent("mechanic:serverResetStock", resourceRoot)
end)

addEvent("cef:saveProfile", true)
addEventHandler("cef:saveProfile", root, function(name, handlingJSON)
    triggerServerEvent("mechanic:serverSaveProfile", resourceRoot, name, fromJSON(handlingJSON))
end)

addEvent("cef:setTransmissionMode", true)
addEventHandler("cef:setTransmissionMode", root, function(mode)
    isManualMode = (mode == "manual")
    if isManualMode then
        outputChatBox("#00FF88[گیربکس] #FFFFFFدنده‌ای دستی فعال شد: #00E5FF[E] دنده بالا #FFFFFFو #00E5FF[Q] معکوس.", 255, 255, 255, true)
    end
end)

bindKey("e", "down", function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not isManualMode or not veh or getVehicleOccupant(veh, 0) ~= localPlayer then return end
    if currentGear < maxGears then
        currentGear = currentGear + 1
        playSoundFrontEnd(41)
    end
end)

bindKey("q", "down", function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not isManualMode or not veh or getVehicleOccupant(veh, 0) ~= localPlayer then return end
    if currentGear > 1 then
        currentGear = currentGear - 1
        playSoundFrontEnd(42)
    end
end)

---------------------------------------------------------------------
-- سیستم رقص نور و رنگ‌های متحرک روان (Client-side Renderer)
---------------------------------------------------------------------
local function hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q end
    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

addEventHandler("onClientRender", root, function()
    local tick = getTickCount()

    -- چرخش رقص نور تمام خودروهای دارای دیتا در صفحه
    for _, veh in ipairs(getElementsByType("vehicle", root, true)) do
        local anim = getElementData(veh, "v_anim_color")
        if anim and anim.pattern and anim.pattern ~= "none" then
            local speed = anim.speed or 1.0
            local r, g, b = 255, 255, 255

            if anim.pattern == "police" then
                local cycle = (tick * speed) % 800
                if cycle < 350 then
                    r, g, b = ((cycle % 120 < 60) and 255 or 0), 0, 0
                elseif cycle >= 400 and cycle < 750 then
                    r, g, b = 0, 0, (((cycle - 400) % 120 < 60) and 255 or 0)
                else
                    r, g, b = 0, 0, 0
                end
            elseif anim.pattern == "rainbow" then
                local hue = ((tick * 0.05 * speed) % 360) / 360
                r, g, b = hsvToRgb(hue, 1, 1)
            elseif anim.pattern == "relax" then
                local t = (math.sin(tick * 0.0018 * speed) + 1) / 2
                r = math.floor(0 * (1 - t) + 138 * t)
                g = math.floor(229 * (1 - t) + 43 * t)
                b = 255
            elseif anim.pattern == "cyberpunk" then
                local t = (math.sin(tick * 0.003 * speed) + 1) / 2
                r = math.floor(255 * (1 - t) + 0 * t)
                g = math.floor(0 * (1 - t) + 240 * t)
                b = math.floor(128 * (1 - t) + 255 * t)
            elseif anim.pattern == "fire" then
                local t = (math.sin(tick * 0.004 * speed) + 1) / 2
                r = 255
                g = math.floor(25 * (1 - t) + 180 * t)
                b = 0
            end

            -- اعمال روی بخش انتخاب شده
            if anim.target == "lights" or anim.target == "both" then
                setVehicleHeadLightColor(veh, r, g, b)
            end
            if anim.target == "body" or anim.target == "both" then
                setVehicleColor(veh, r, g, b, r, g, b)
            end
        end
    end

    -- نمایش هاد دنده در صورت فعال بودن
    local veh = getPedOccupiedVehicle(localPlayer)
    if isManualMode and veh and not isPanelOpen then
        local speedCap = currentGear * (240 / maxGears)
        local vx, vy, vz = getElementVelocity(veh)
        local actualSpeed = (vx^2 + vy^2 + vz^2)^(0.5) * 180

        if actualSpeed > speedCap then
            setElementVelocity(veh, vx * 0.98, vy * 0.98, vz)
        end

        local hudX, hudY = screenW - 140, screenH - 120
        dxDrawRectangle(hudX, hudY, 110, 80, tocolor(10, 15, 23, 220), true)
        dxDrawRectangle(hudX, hudY, 110, 4, tocolor(0, 229, 255, 255), true)
        dxDrawText("GEAR", hudX + 15, hudY + 12, hudX + 95, hudY + 25, tocolor(150, 170, 190, 255), 1.0, "default-bold", "center", "center", false, false, true)
        dxDrawText(tostring(currentGear), hudX + 15, hudY + 30, hudX + 95, hudY + 65, tocolor(0, 229, 255, 255), 2.2, "default-bold", "center", "center", false, false, true)
        dxDrawText("[Q] - [E]", hudX + 10, hudY + 64, hudX + 100, hudY + 76, tocolor(180, 180, 180, 255), 0.8, "default", "center", "center", false, false, true)
    end
end)
local screenW, screenH = guiGetScreenSize()
local knockTimerSeconds, timerActive, medicEnRoute = 0, false, false
local medicGuideText, medicGuideTimer = nil, nil
local gpsBlip = nil
local cadWindow, cadGrid = nil, nil

-- کلید همه‌کاره E
bindKey("e", "down", function()
    triggerServerEvent("server:interactKey", localPlayer)
end)

-- کلید قطع و وصل آژیر آمبولانس
bindKey("k", "down", function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and getElementModel(veh) == 416 then
        setVehicleSirensOn(veh, not getVehicleSirensOn(veh))
    end
end)

addEvent("client:setMedicGuide", true)
addEventHandler("client:setMedicGuide", root, function(txt)
    medicGuideText = txt
    if isTimer(medicGuideTimer) then killTimer(medicGuideTimer) end
    medicGuideTimer = setTimer(function() medicGuideText = nil end, 8000, 1)
end)

addEvent("client:clearGPS", true)
addEventHandler("client:clearGPS", root, function()
    if isElement(gpsBlip) then destroyElement(gpsBlip) gpsBlip = nil end
end)

addEvent("client:routeToHospital", true)
addEventHandler("client:routeToHospital", root, function(x, y, z)
    if isElement(gpsBlip) then destroyElement(gpsBlip) end
    gpsBlip = createBlip(x, y, z, 22, 3, 0, 120, 255, 255, 0, 99999)
end)

-- رندر متن ۳بعدی، تایمر ویلچر و پیام‌ها
addEventHandler("onClientRender", root, function()
    local cx, cy, cz = getCameraMatrix()

    -- الف) نمایش تایمر ۱۵ ثانیه‌ای بالای سر بیمارِ روی ویلچر
    local allPeds = {}
    for _, p in ipairs(getElementsByType("player", root, true)) do table.insert(allPeds, p) end
    for _, p in ipairs(getElementsByType("ped", root, true)) do table.insert(allPeds, p) end

    for _, p in ipairs(allPeds) do
        local timeLeft = getElementData(p, "wheelchairTimer")
        if timeLeft then
            local px, py, pz = getElementPosition(p)
            if getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz) <= 25 then
                local sx, sy = getScreenFromWorldPosition(px, py, pz + 1.25)
                if sx and sy then
                    dxDrawRectangle(sx - 130, sy - 14, 260, 28, tocolor(0, 0, 0, 200))
                    dxDrawText("مراقبت اولیه روی ویلچر: " .. timeLeft .. " ثانیه", sx - 130, sy - 14, sx + 130, sy + 14, tocolor(0, 200, 255), 1.1, "default-bold", "center", "center")
                end
            end
        end
    end

    -- ب) متن سقف آمبولانس‌ها
    for _, veh in ipairs(getElementsByType("vehicle", root, true)) do
        if getElementModel(veh) == 416 then
            local vx, vy, vz = getElementPosition(veh)
            if getDistanceBetweenPoints3D(cx, cy, cz, vx, vy, vz) <= 30 then
                local sx, sy = getScreenFromWorldPosition(vx, vy, vz + 1.55)
                if sx and sy then
                    local status = getElementData(veh, "ambStatus") or "idle"
                    local txt, r, g, b = "[ آمبولانس: آماده‌باش ]", 50, 255, 50
                    if status == "responding" then
                        txt, r, g, b = "[ در حال اعزام به سمت مصدوم ]", 255, 200, 0
                    elseif status == "transporting" then
                        txt, r, g, b = "[ ! حامل بیمار اورژانسی ! ]", 255, 30, 30
                    end
                    dxDrawRectangle(sx - 110, sy - 12, 220, 24, tocolor(0, 0, 0, 190))
                    dxDrawText(txt, sx - 110, sy - 12, sx + 110, sy + 12, tocolor(r, g, b), 1.0, "default-bold", "center", "center")
                end
            end
        end
    end

    -- ج) بنر راهنمای بالای صفحه
    if medicGuideText then
        dxDrawRectangle(screenW/2 - 270, 20, 540, 38, tocolor(10, 40, 90, 230))
        dxDrawText("ماموریت اورژانس: " .. medicGuideText, screenW/2 - 270, 20, screenW/2 + 270, 58, tocolor(255, 255, 255), 1.1, "default-bold", "center", "center")
    end

    -- د) تایمر مصدوم تا امداد اضطراری
    if timerActive then
        local tStr = string.format("%02d:%02d", math.floor(knockTimerSeconds / 60), knockTimerSeconds % 60)
        dxDrawRectangle(screenW/2 - 160, 65, 320, 65, tocolor(0, 0, 0, 210))
        dxDrawText("زمان تا امداد اضطراری: " .. tStr, screenW/2 - 160, 70, screenW/2 + 160, 95, tocolor(255, 50, 50), 1.3, "default-bold", "center", "center")
        dxDrawText(medicEnRoute and "آمبولانس در راه است" or "در انتظار پذیرش...", screenW/2 - 160, 95, screenW/2 + 160, 120, tocolor(255, 255, 255), 1.0, "default", "center", "center")
    end
end)

-- تبلت آمبولانس با کلید H
bindKey("h", "down", function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh or getElementModel(veh) ~= 416 or not getElementData(localPlayer, "medicDuty") then return end
    if isElement(cadWindow) then destroyElement(cadWindow) showCursor(false) cadWindow = nil return end

    showCursor(true)
    cadWindow = guiCreateWindow((screenW - 500)/2, (screenH - 320)/2, 500, 320, "دیسپچ اورژانس", false)
    cadGrid = guiCreateGridList(10, 25, 480, 220, false, cadWindow)
    guiGridListAddColumn(cadGrid, "مصدوم", 0.5)
    guiGridListAddColumn(cadGrid, "منطقه", 0.4)

    local btnGo = guiCreateButton(10, 255, 235, 45, "اعزام (GPS)", false, cadWindow)
    local btnX  = guiCreateButton(255, 255, 235, 45, "بستن", false, cadWindow)

    addEventHandler("onClientGUIClick", btnX, function() destroyElement(cadWindow) showCursor(false) cadWindow = nil end, false)
    addEventHandler("onClientGUIClick", btnGo, function()
        local r = guiGridListGetSelectedItem(cadGrid)
        if r ~= -1 then
            local el = guiGridListGetItemData(cadGrid, r, 1)
            triggerServerEvent("server:dispatchToVictim", localPlayer, el)
            if isElement(gpsBlip) then destroyElement(gpsBlip) end
            gpsBlip = createBlipAttachedTo(el, 41, 3, 255, 0, 0, 255, 0, 99999)
            destroyElement(cadWindow) showCursor(false) cadWindow = nil
        end
    end, false)

    local targets = {}
    for _, el in ipairs(getElementsByType("player")) do table.insert(targets, el) end
    for _, el in ipairs(getElementsByType("ped")) do table.insert(targets, el) end
    for _, el in ipairs(targets) do
        if getElementData(el, "isKnocked") and not getElementData(el, "inAmbulance") and not getElementData(el, "wheelchairTimer") then
            local row = guiGridListAddRow(cadGrid)
            local name = getElementData(el, "isBot") and getElementData(el, "botName") or getPlayerName(el)
            guiGridListSetItemText(cadGrid, row, 1, name, false, false)
            guiGridListSetItemText(cadGrid, row, 2, getZoneName(getElementPosition(el)), false, false)
            guiGridListSetItemData(cadGrid, row, 1, el)
        end
    end
end)

addEvent("client:startKnockTimer", true)
addEventHandler("client:startKnockTimer", root, function(s, acc) knockTimerSeconds, timerActive, medicEnRoute = s, true, acc end)
addEvent("client:stopKnockTimer", true)
addEventHandler("client:stopKnockTimer", root, function() timerActive = false end)
setTimer(function() if timerActive and knockTimerSeconds > 0 then knockTimerSeconds = knockTimerSeconds - 1 end end, 1000, 0)
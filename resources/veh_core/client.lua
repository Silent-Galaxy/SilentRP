local screenW, screenH = guiGetScreenSize()
local browser = nil
local guiBrowser = nil
local panelOpen = false
local flashState = false
local steerDuration = 0
local tempHazardTimer = nil

addEventHandler("onClientResourceStart", resourceRoot, function()
    guiBrowser = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
    browser = guiGetBrowser(guiBrowser)
    guiSetInputMode("allow_binds")

    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/" .. getResourceName(getThisResource()) .. "/html/index.html")
    end)
end)

-- Block Radio completely
addEventHandler("onClientPlayerRadioSwitch", root, function() cancelEvent() end)
addEventHandler("onClientVehicleEnter", root, function(player)
    if player == localPlayer then
        setRadioChannel(0)
        toggleControl("radio_next", false)
        toggleControl("radio_previous", false)
    end
end)
addEventHandler("onClientVehicleExit", root, function(player)
    if player == localPlayer then
        toggleControl("radio_next", true)
        toggleControl("radio_previous", true)
        -- 5 Seconds Hazard on Driver Exit
        if isDriver() then
            triggerTempHazard(source, 5000)
        end
    end
end)

function isDriver()
    local veh = getPedOccupiedVehicle(localPlayer)
    return veh and getVehicleOccupant(veh, 0) == localPlayer
end

-- 5-Second Temp Hazard Function
function triggerTempHazard(veh, duration)
    if not isElement(veh) then return end
    triggerServerEvent("veh:setIndicator", resourceRoot, veh, "hazard")
    if isTimer(tempHazardTimer) then killTimer(tempHazardTimer) end
    tempHazardTimer = setTimer(function(v)
        if isElement(v) and getElementData(v, "indicator") == "hazard" then
            triggerServerEvent("veh:setIndicator", resourceRoot, v, "off")
        end
    end, duration or 5000, 1, veh)
end

-- Keybinds: 1 to 4
bindKey("1", "down", function()
    if isDriver() then
        triggerServerEvent("veh:toggleEngine", resourceRoot, getPedOccupiedVehicle(localPlayer))
    end
end)

bindKey("2", "down", function()
    if isDriver() then
        triggerServerEvent("veh:toggleLights", resourceRoot, getPedOccupiedVehicle(localPlayer))
    end
end)

-- Optimized Handbrake Toggle (One Click)
bindKey("3", "down", function()
    if isDriver() then
        local veh = getPedOccupiedVehicle(localPlayer)
        local current = getElementData(veh, "handbrake") or false
        triggerServerEvent("veh:setHandbrake", resourceRoot, veh, not current)
        playSoundFrontEnd(not current and 40 or 41)
    end
end)

-- Natural Handbrake physics (Skids at speed, freezes on stop, releases instantly)
addEventHandler("onClientRender", root, function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and isDriver() then
        local hb = getElementData(veh, "handbrake")
        if hb then
            local vx, vy, vz = getElementVelocity(veh)
            local speed = ((vx^2 + vy^2 + vz^2)^0.5) * 180
            if speed > 2 then
                setPedControlState(localPlayer, "handbrake", true)
                if isElementFrozen(veh) then setElementFrozen(veh, false) end
            else
                setPedControlState(localPlayer, "handbrake", false)
                if not isElementFrozen(veh) then
                    triggerServerEvent("veh:freeze", resourceRoot, veh, true)
                end
            end
        else
            setPedControlState(localPlayer, "handbrake", false)
        end
    end
end)

bindKey("4", "down", function()
    if getPedOccupiedVehicle(localPlayer) then
        local current = getElementData(localPlayer, "seatbelt") or false
        setElementData(localPlayer, "seatbelt", not current, false)
        playSoundFrontEnd(not current and 40 or 41)
    end
end)

-- Exit Control Check
addEventHandler("onClientVehicleStartExit", root, function(ped)
    if ped ~= localPlayer then return end
    if getElementData(localPlayer, "seatbelt") then
        cancelEvent()
        playSoundFrontEnd(42)
    end
end)

-- Systemic F Command on Speed >= 30 km/h without Seatbelt
setTimer(function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        local vx, vy, vz = getElementVelocity(veh)
        local speed = ((vx^2 + vy^2 + vz^2)^0.5) * 180
        local buckled = getElementData(localPlayer, "seatbelt")
        if speed >= 30 and not buckled then
            setControlState("enter_exit", true)
            setTimer(setControlState, 150, 1, "enter_exit", false)
        end
    end
end, 200, 0)

-- Collision -> 5s Hazard
addEventHandler("onClientVehicleCollision", root, function(hitElement, force)
    if source == getPedOccupiedVehicle(localPlayer) and force and force > 280 then
        triggerTempHazard(source, 5000)
    end
end)

-- Turn Indicators: Q, E, CapsLock
bindKey("q", "down", function()
    if isDriver() then
        steerDuration = 0
        triggerServerEvent("veh:setIndicator", resourceRoot, getPedOccupiedVehicle(localPlayer), "left")
    end
end)

bindKey("e", "down", function()
    if isDriver() then
        steerDuration = 0
        triggerServerEvent("veh:setIndicator", resourceRoot, getPedOccupiedVehicle(localPlayer), "right")
    end
end)

bindKey("capslock", "down", function()
    if isDriver() then
        triggerServerEvent("veh:setIndicator", resourceRoot, getPedOccupiedVehicle(localPlayer), "hazard")
    end
end)

-- Auto Cancel on 1s turning
addEventHandler("onClientRender", root, function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh and isDriver() then
        local ind = getElementData(veh, "indicator")
        if ind == "left" or ind == "right" then
            local isTurning = (ind == "left" and getControlState("vehicle_left")) or (ind == "right" and getControlState("vehicle_right"))
            if isTurning then
                steerDuration = steerDuration + 16.6
                if steerDuration >= 1000 then
                    triggerServerEvent("veh:setIndicator", resourceRoot, veh, "off")
                    steerDuration = 0
                    playSoundFrontEnd(38)
                end
            else
                steerDuration = 0
            end
        else
            steerDuration = 0
        end
    end
end)

-- F1 Panel
bindKey("F1", "down", function()
    if not isDriver() then return end
    panelOpen = not panelOpen
    showCursor(panelOpen)
    if panelOpen then
        guiBringToFront(guiBrowser)
        executeBrowserJavascript(browser, "togglePanel(true);")
    else
        executeBrowserJavascript(browser, "togglePanel(false);")
    end
end)

-- Snug Coronas
local vehicleMarkers = {}

function cleanupVehicleMarkers(veh)
    if vehicleMarkers[veh] then
        for _, m in ipairs(vehicleMarkers[veh].markers) do
            if isElement(m) then destroyElement(m) end
        end
        vehicleMarkers[veh] = nil
    end
end

function updateVehicleIndicators(veh)
    cleanupVehicleMarkers(veh)
    if not isElement(veh) or not isElementStreamedIn(veh) then return end

    local indState = getElementData(veh, "indicator") or "off"
    if indState == "off" then return end

    local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(veh)
    if not minX then return end

    local markers = {}
    local zPos = minZ + (maxZ - minZ) * 0.45
    local inX, inY = 0.02, 0.02

    if indState == "left" or indState == "hazard" then
        local mFL = createMarker(0, 0, 0, "corona", 0.28, 255, 140, 0, 255)
        local mRL = createMarker(0, 0, 0, "corona", 0.28, 255, 140, 0, 255)
        attachElements(mFL, veh, minX + inX, maxY - inY, zPos)
        attachElements(mRL, veh, minX + inX, minY + inY, zPos)
        table.insert(markers, mFL)
        table.insert(markers, mRL)
    end

    if indState == "right" or indState == "hazard" then
        local mFR = createMarker(0, 0, 0, "corona", 0.28, 255, 140, 0, 255)
        local mRR = createMarker(0, 0, 0, "corona", 0.28, 255, 140, 0, 255)
        attachElements(mFR, veh, maxX - inX, maxY - inY, zPos)
        attachElements(mRR, veh, maxX - inX, minY + inY, zPos)
        table.insert(markers, mFR)
        table.insert(markers, mRR)
    end

    vehicleMarkers[veh] = { markers = markers }
end

addEventHandler("onClientElementDataChange", root, function(dataName)
    if getElementType(source) == "vehicle" and dataName == "indicator" then updateVehicleIndicators(source) end
end)
addEventHandler("onClientElementStreamIn", root, function()
    if getElementType(source) == "vehicle" then updateVehicleIndicators(source) end
end)
addEventHandler("onClientElementStreamOut", root, function()
    if getElementType(source) == "vehicle" then cleanupVehicleMarkers(source) end
end)
addEventHandler("onClientElementDestroy", root, function()
    if getElementType(source) == "vehicle" then cleanupVehicleMarkers(source) end
end)

setTimer(function()
    flashState = not flashState
    local myVeh = getPedOccupiedVehicle(localPlayer)

    for veh, data in pairs(vehicleMarkers) do
        if isElement(veh) then
            local alpha = flashState and 255 or 0
            for _, m in ipairs(data.markers) do
                if isElement(m) then setMarkerColor(m, 255, 140, 0, alpha) end
            end
            if veh == myVeh and flashState then playSoundFrontEnd(37) end
        else
            cleanupVehicleMarkers(veh)
        end
    end
end, 380, 0)

-- Door 5s Hazard on open
local lastAnyDoorOpen = false

-- Render HUD
addEventHandler("onClientRender", root, function()
    if not browser then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        local vx, vy, vz = getElementVelocity(veh)
        local speed = math.floor(((vx^2 + vy^2 + vz^2)^0.5) * 180)
        local engine = getVehicleEngineState(veh)
        local lights = getVehicleOverrideLights(veh) == 2
        local handbrake = getElementData(veh, "handbrake") or false
        local indicator = getElementData(veh, "indicator") or "off"
        local seatbelt = getElementData(localPlayer, "seatbelt") or false
        local driver = (getVehicleOccupant(veh, 0) == localPlayer)
        
        local anyDoorOpen = false
        local doorsData = {}
        for d = 0, 5 do
            local isOpen = getVehicleDoorOpenRatio(veh, d) > 0.1
            doorsData[d] = isOpen
            if isOpen then anyDoorOpen = true end
        end

        if anyDoorOpen and not lastAnyDoorOpen and driver then
            triggerTempHazard(veh, 5000)
        end
        lastAnyDoorOpen = anyDoorOpen

        local gear = "D"
        if speed == 0 and handbrake then gear = "P"
        elseif getControlState("brake_reverse") and speed < 2 then gear = "R"
        elseif speed == 0 then gear = "N" end

        executeBrowserJavascript(browser, string.format(
            "updateHUD(%d, %s, %s, %s, '%s', %s, %s, '%s', %s, '%s', %s);",
            speed, tostring(engine), tostring(lights), tostring(handbrake),
            indicator, tostring(seatbelt), tostring(anyDoorOpen), gear,
            tostring(flashState), toJSON(doorsData), tostring(driver)
        ))
    else
        lastAnyDoorOpen = false
        executeBrowserJavascript(browser, "updateHUD(0, false, false, false, 'off', false, false, 'P', false, '[]', false);")
        if panelOpen then
            panelOpen = false
            showCursor(false)
            executeBrowserJavascript(browser, "togglePanel(false);")
        end
    end
end)

-- CEF UI Events
addEvent("cef:doorAction", true)
addEventHandler("cef:doorAction", root, function(doorIdx)
    if isDriver() then
        triggerServerEvent("veh:toggleDoor", resourceRoot, getPedOccupiedVehicle(localPlayer), tonumber(doorIdx))
    end
end)

addEvent("cef:toggleAllDoors", true)
addEventHandler("cef:toggleAllDoors", root, function()
    if isDriver() then
        triggerServerEvent("veh:toggleAllDoors", resourceRoot, getPedOccupiedVehicle(localPlayer))
    end
end)

addEvent("cef:quickAction", true)
addEventHandler("cef:quickAction", root, function(action)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh or not isDriver() then return end
    if action == "engine" then triggerServerEvent("veh:toggleEngine", resourceRoot, veh)
    elseif action == "lights" then triggerServerEvent("veh:toggleLights", resourceRoot, veh)
    elseif action == "handbrake" then
        local current = getElementData(veh, "handbrake") or false
        triggerServerEvent("veh:setHandbrake", resourceRoot, veh, not current)
    elseif action == "hazard" then triggerServerEvent("veh:setIndicator", resourceRoot, veh, "hazard")
    elseif action == "seatbelt" then
        local sb = getElementData(localPlayer, "seatbelt") or false
        setElementData(localPlayer, "seatbelt", not sb, false)
        playSoundFrontEnd(not sb and 40 or 41)
    end
end)

addEvent("cef:closePanel", true)
addEventHandler("cef:closePanel", root, function()
    panelOpen = false
    showCursor(false)
end)

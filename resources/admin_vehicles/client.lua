local browserGUI = nil
local webBrowser = nil
local isPageReady = false

function toggleWebPanel()
    local adminLvl = tonumber(getElementData(localPlayer, "admin_level")) or -1
    if adminLvl < 0 then
        outputChatBox("#FF0000[خطا]#FFFFFF شما دسترسی ادمین ندارید!", 255, 255, 255, true)
        return
    end

    if browserGUI and guiGetVisible(browserGUI) then
        guiSetVisible(browserGUI, false)
        showCursor(false)
        return
    end

    if not browserGUI then
        local screenW, screenH = guiGetScreenSize()
        local w, h = 740, 560
        local x, y = (screenW - w) / 2, (screenH - h) / 2

        browserGUI = guiCreateBrowser(x, y, w, h, true, true, false)
        webBrowser = guiGetBrowser(browserGUI)
        guiSetVisible(browserGUI, false)

        addEventHandler("onClientBrowserCreated", webBrowser, function()
            loadBrowserURL(webBrowser, "http://mta/local/ui/index.html")
        end)
    end

    guiSetVisible(browserGUI, true)
    showCursor(true)
    if isPageReady then
        triggerServerEvent("requestSavedVehiclesList", resourceRoot)
    end
end

bindKey("F6", "down", toggleWebPanel)
addCommandHandler("vehpanel", toggleWebPanel)

addEvent("onWebReady", true)
addEventHandler("onWebReady", root, function()
    isPageReady = true
    triggerServerEvent("requestSavedVehiclesList", resourceRoot)
end)

addEvent("receiveSavedVehiclesList", true)
addEventHandler("receiveSavedVehiclesList", resourceRoot, function(list, currentCar)
    if webBrowser and isPageReady then
        local listJson = toJSON(list, true)
        local carJson = currentCar and toJSON(currentCar, true) or "null"
        executeBrowserJavascript(webBrowser, "updatePanelData(" .. listJson .. ", " .. carJson .. ");")
    end
end)

addEvent("onWebRefreshList", true)
addEventHandler("onWebRefreshList", root, function()
    triggerServerEvent("requestSavedVehiclesList", resourceRoot)
end)

addEvent("onWebSaveCurrentCar", true)
addEventHandler("onWebSaveCurrentCar", root, function()
    triggerServerEvent("onAdminSaveCurrentOccupiedVehicle", resourceRoot)
end)

addEvent("onWebSpawnNew", true)
addEventHandler("onWebSpawnNew", root, function(modelId)
    triggerServerEvent("onAdminCreatePermanentVehicle", resourceRoot, tonumber(modelId))
end)

addEvent("onWebToggleMarker", true)
addEventHandler("onWebToggleMarker", root, function(dbid)
    triggerServerEvent("onAdminToggleMarker", resourceRoot, tonumber(dbid))
end)

addEvent("onWebResetPos", true)
addEventHandler("onWebResetPos", root, function(dbid)
    triggerServerEvent("onAdminResetVehiclePos", resourceRoot, tonumber(dbid))
end)

addEvent("onWebTeleport", true)
addEventHandler("onWebTeleport", root, function(dbid)
    triggerServerEvent("onAdminTeleportToVehicle", resourceRoot, tonumber(dbid))
end)

addEvent("onWebDelete", true)
addEventHandler("onWebDelete", root, function(dbid)
    triggerServerEvent("onAdminDeleteVehicle", resourceRoot, tonumber(dbid))
end)

addEvent("onWebClose", true)
addEventHandler("onWebClose", root, function()
    toggleWebPanel()
end)
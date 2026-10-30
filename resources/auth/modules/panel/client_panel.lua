panelGUI = nil
panelBrowser = nil
isPanelOpen = false

local purgeRemainingSeconds = 0
local isPurgeActive = false

function toggleControlPanel()
    if isElement(authBrowserGUI) then return end

    -- اگر Shift نگه داشته شده باشد، پنل F2 باز نمی‌شود (تا تداخلی با Shift + F2 قوانین ادمین نداشته باشد)
    if getKeyState("lshift") or getKeyState("rshift") then
        return
    end

    isPanelOpen = not isPanelOpen

    if isPanelOpen then
        showCursor(true, true)
        guiSetInputMode("no_binds")

        local screenW, screenH = guiGetScreenSize()
        panelGUI = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
        panelBrowser = guiGetBrowser(panelGUI)

        guiBringToFront(panelGUI)
        guiSetProperty(panelGUI, "AlwaysOnTop", "True")

        addEventHandler("onClientBrowserCreated", panelBrowser, function()
            loadBrowserURL(source, "http://mta/local/ui/panel.html")
        end)

        addEventHandler("onClientBrowserDocumentReady", panelBrowser, function()
            focusBrowser(source)
            triggerServerEvent("panel:requestData", resourceRoot)
        end)
    else
        if isElement(panelGUI) then
            destroyElement(panelGUI)
            panelGUI = nil
            panelBrowser = nil
        end
        showCursor(false)
        guiSetInputMode("allow_binds")
    end
end
bindKey("f2", "down", toggleControlPanel)

addEventHandler("onClientClick", root, function(button, state)
    if isElement(panelBrowser) and state == "down" then
        focusBrowser(panelBrowser)
    end
end)

addEvent("panel:receiveData", true)
addEventHandler("panel:receiveData", root, function(jsonData)
    if panelBrowser then
        executeBrowserJavascript(panelBrowser, string.format("loadDashboardData(%s);", jsonData))
    end
end)

addEvent("panel:receiveAdminUserList", true)
addEventHandler("panel:receiveAdminUserList", root, function(jsonData)
    if panelBrowser then
        executeBrowserJavascript(panelBrowser, string.format("loadAdminUserList(%s);", jsonData))
    end
end)

addEvent("panel:updateSecurity", true)
addEventHandler("panel:updateSecurity", root, function(pass, email, phone, expireDays)
    triggerServerEvent("panel:serverUpdateSecurity", resourceRoot, pass, email, phone, expireDays)
end)

addEvent("panel:adminAction", true)
addEventHandler("panel:adminAction", root, function(targetId, action, reason, adminLvl, perms)
    triggerServerEvent("panel:serverAdminAction", resourceRoot, targetId, action, reason, adminLvl, perms)
end)

addEvent("panel:adminStartGlobalPurge", true)
addEventHandler("panel:adminStartGlobalPurge", root, function()
    triggerServerEvent("panel:serverStartGlobalPurge", resourceRoot)
end)

addEvent("panel:logout", true)
addEventHandler("panel:logout", root, function()
    if isElement(panelGUI) then
        destroyElement(panelGUI)
        panelGUI = nil
        panelBrowser = nil
        isPanelOpen = false
    end
    triggerServerEvent("panel:serverLogout", resourceRoot)
end)

addEvent("auth:startPurgeCountdown", true)
addEventHandler("auth:startPurgeCountdown", root, function(totalSeconds)
    purgeRemainingSeconds = tonumber(totalSeconds) or 300
    isPurgeActive = true
end)

addEventHandler("onClientRender", root, function()
    if not isPurgeActive or purgeRemainingSeconds <= 0 then return end

    local screenW, screenH = guiGetScreenSize()
    local bannerW, bannerH = 460, 50
    local bannerX = (screenW - bannerW) / 2
    local bannerY = 20

    local mins = math.floor(purgeRemainingSeconds / 60)
    local secs = math.floor(purgeRemainingSeconds % 60)
    local timeStr = string.format("%02d:%02d", mins, secs)

    dxDrawRectangle(bannerX, bannerY, bannerW, bannerH, tocolor(180, 20, 20, 225))
    dxDrawRectangle(bannerX, bannerY + bannerH - 3, bannerW, 3, tocolor(255, 255, 255, 200))

    local text = "🚨 هشدار امنیتی: خروج اضطراری کلیه بازیکنان ظرف " .. timeStr .. " دیگر"
    local sub = "اطلاعات شما ذخیره می‌شود. لطفاً در نقطه‌ای امن توقف نمایید."
    dxDrawText(text, bannerX, bannerY + 6, bannerX + bannerW, bannerY + 26, tocolor(255, 255, 255, 255), 1.1, "default-bold", "center", "top")
    dxDrawText(sub, bannerX, bannerY + 28, bannerX + bannerW, bannerY + 48, tocolor(255, 220, 220, 230), 0.9, "default", "center", "top")
end)

setTimer(function()
    if isPurgeActive and purgeRemainingSeconds > 0 then
        purgeRemainingSeconds = purgeRemainingSeconds - 1
        if purgeRemainingSeconds <= 0 then isPurgeActive = false end
    end
end, 1000, 0)

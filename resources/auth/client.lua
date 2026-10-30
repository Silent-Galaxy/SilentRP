local browserGUI = nil
local browser = nil

local panelGUI = nil
local panelBrowser = nil
local isPanelOpen = false

local purgeRemainingSeconds = 0
local isPurgeActive = false

function initModernUI()
    if isElement(browserGUI) then destroyElement(browserGUI) end

    showCursor(true, true)
    fadeCamera(true)
    setCameraMatrix(1448.8, -875.4, 60.5, 1449.1, -876.4, 59.8)

    local screenW, screenH = guiGetScreenSize()
    browserGUI = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
    browser = guiGetBrowser(browserGUI)

    guiBringToFront(browserGUI)
    guiSetProperty(browserGUI, "AlwaysOnTop", "True")
    guiSetInputMode("no_binds")

    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(source, "http://mta/local/ui/index.html")
    end)

    addEventHandler("onClientBrowserDocumentReady", browser, function()
        focusBrowser(source)
    end)
end
addEventHandler("onClientResourceStart", resourceRoot, initModernUI)

addEventHandler("onClientClick", root, function(button, state)
    if isElement(browser) and state == "down" then
        focusBrowser(browser)
    elseif isElement(panelBrowser) and state == "down" then
        focusBrowser(panelBrowser)
    end
end)

addEvent("auth:clientSubmit", true)
addEventHandler("auth:clientSubmit", root, function(user, pass, mode, email, phone, referral, rememberMe, ruleVer)
    if mode == "login" then
        triggerServerEvent("auth:requestLogin", resourceRoot, user, pass, rememberMe)
    elseif mode == "register" then
        triggerServerEvent("auth:requestRegister", resourceRoot, user, pass, email, phone, referral, rememberMe, ruleVer)
    elseif mode == "forgot" then
        triggerServerEvent("auth:requestResetPassword", resourceRoot, user, email, pass)
    end
end)

addEvent("auth:clientAutoLogin", true)
addEventHandler("auth:clientAutoLogin", root, function(user, token)
    triggerServerEvent("auth:requestAutoLogin", resourceRoot, user, token)
end)

addEvent("auth:response", true)
addEventHandler("auth:response", root, function(success, message, token, user)
    if browser then
        local js = string.format("showResponse(%s, %s, %s, %s);", 
            tostring(success), 
            toJSON(message or ""), 
            token and toJSON(token) or "null", 
            user and toJSON(user) or "null"
        )
        executeBrowserJavascript(browser, js)
    end
end)

addEvent("auth:requestServerRulesModal", true)
addEventHandler("auth:requestServerRulesModal", root, function()
    triggerServerEvent("auth:fetchRulesForModal", resourceRoot, "register")
end)

addEvent("auth:openRulesModalClient", true)
addEventHandler("auth:openRulesModalClient", root, function(ruleTable, forAction)
    if browser then
        executeBrowserJavascript(browser, string.format("showRulesModal(%s, %s);", toJSON(ruleTable or {}), toJSON(forAction or "")))
    end
end)

addEvent("auth:clientAcceptUpdatedRules", true)
addEventHandler("auth:clientAcceptUpdatedRules", root, function(ver)
    triggerServerEvent("auth:serverAcceptRules", resourceRoot, ver)
end)

addEvent("auth:loginSuccess", true)
addEventHandler("auth:loginSuccess", root, function()
    if isElement(browserGUI) then
        destroyElement(browserGUI)
        browserGUI = nil
        browser = nil
    end
    showCursor(false)
    guiSetInputMode("allow_binds")
    setCameraTarget(localPlayer)
end)

function toggleControlPanel()
    if isElement(browserGUI) then return end

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

addEvent("panel:adminPublishRules", true)
addEventHandler("panel:adminPublishRules", root, function(title, content)
    triggerServerEvent("panel:serverPublishRules", resourceRoot, title, content)
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

addEvent("auth:showLogin", true)
addEventHandler("auth:showLogin", root, function()
    if isElement(panelGUI) then
        destroyElement(panelGUI)
        panelGUI = nil
        panelBrowser = nil
        isPanelOpen = false
    end
    initModernUI()
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
        if purgeRemainingSeconds <= 0 then
            isPurgeActive = false
        end
    end
end, 1000, 0)
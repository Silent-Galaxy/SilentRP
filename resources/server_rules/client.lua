local rulesGUI = nil
local rulesBrowser = nil
local isBrowserReady = false
local isRulesOpen = false
local currentActiveAction = "view"
local cachedData = nil

local function stringToHex(str)
    return (str:gsub('.', function(c)
        return string.format('%02x', string.byte(c))
    end))
end

local function initBrowserOnce()
    if isElement(rulesGUI) then return end

    local sw, sh = guiGetScreenSize()
    rulesGUI = guiCreateBrowser(0, 0, sw, sh, true, true, false)
    rulesBrowser = guiGetBrowser(rulesGUI)
    guiSetVisible(rulesGUI, false)

    addEventHandler("onClientBrowserCreated", rulesBrowser, function()
        loadBrowserURL(source, "http://mta/local/ui/rules.html")
    end)

    addEventHandler("onClientBrowserDocumentReady", rulesBrowser, function()
        isBrowserReady = true
        if cachedData and isRulesOpen then
            local hexData = stringToHex(toJSON(cachedData.rules or {}, true))
            local code = string.format("receiveRulesHex(%q, %q, %q, %s);", cachedData.mode, hexData, cachedData.forAction, cachedData.isAdmin and "true" or "false")
            executeBrowserJavascript(source, code)
        end
    end)
end
addEventHandler("onClientResourceStart", resourceRoot, initBrowserOnce)

local function closeRulesUI()
    if not isRulesOpen then return end
    isRulesOpen = false

    if isElement(rulesGUI) then
        guiSetVisible(rulesGUI, false)
    end

    triggerServerEvent("rules:serverStopReadingAnim", resourceRoot)
    showCursor(false)
    guiSetInputMode("allow_binds")
end

local function openRulesUI(mode, rawRulesList, forAction, isAdmin)
    initBrowserOnce()

    isRulesOpen = true
    currentActiveAction = forAction or "view"
    cachedData = {
        mode = tostring(mode or "view"),
        rules = rawRulesList or {},
        forAction = tostring(forAction or "view"),
        isAdmin = not not isAdmin
    }

    guiSetVisible(rulesGUI, true)
    guiBringToFront(rulesGUI)
    showCursor(true, true)
    guiSetInputMode("no_binds")
    focusBrowser(rulesBrowser)

    if not isPedDead(localPlayer) and getElementDimension(localPlayer) == 0 then
        triggerServerEvent("rules:serverStartReadingAnim", resourceRoot)
    end

    if isBrowserReady and isElement(rulesBrowser) then
        local hexData = stringToHex(toJSON(cachedData.rules, true))
        local code = string.format("receiveRulesHex(%q, %q, %q, %s);", cachedData.mode, hexData, cachedData.forAction, cachedData.isAdmin and "true" or "false")
        executeBrowserJavascript(rulesBrowser, code)
    end
end

bindKey(RulesConfig.userKey or "f5", "down", function()
    if isRulesOpen then
        closeRulesUI()
    else
        triggerServerEvent("rules:serverRequestRulesData", resourceRoot, "view")
    end
end)

bindKey("f2", "down", function()
    if getKeyState("lshift") or getKeyState("rshift") then
        triggerServerEvent("rules:serverRequestAdminPanel", resourceRoot)
    end
end)

addEvent("rules:clientSyncRulesData", true)
addEventHandler("rules:clientSyncRulesData", root, function(newRulesList, isAdmin)
    if not cachedData then cachedData = {} end
    cachedData.rules = newRulesList or {}
    cachedData.isAdmin = not not isAdmin

    if isRulesOpen and isElement(rulesBrowser) and isBrowserReady then
        local hexData = stringToHex(toJSON(cachedData.rules, true))
        local code = string.format("receiveRulesHex(%q, %q, %q, %s);", cachedData.mode or "view", hexData, cachedData.forAction or "view", cachedData.isAdmin and "true" or "false")
        executeBrowserJavascript(rulesBrowser, code)
    end
end)

addEvent("rules:clientOpenModal", true)
addEventHandler("rules:clientOpenModal", root, function(rulesList, forAction, isAdmin)
    openRulesUI("view", rulesList, forAction, isAdmin)
end)

addEvent("rules:clientOpenAdminEditor", true)
addEventHandler("rules:clientOpenAdminEditor", root, function(rulesList)
    openRulesUI("admin", rulesList, "", true)
end)

addEvent("rules:clientCloseUI", true)
addEventHandler("rules:clientCloseUI", root, function()
    closeRulesUI()
end)

addEvent("rules:clientAcceptAction", true)
addEventHandler("rules:clientAcceptAction", root, function(version, forAction)
    closeRulesUI()
    triggerServerEvent("rules:serverSubmitAcceptance", resourceRoot, version, forAction)
end)

addEvent("rules:clientPublishAction", true)
addEventHandler("rules:clientPublishAction", root, function(title, content)
    triggerServerEvent("rules:serverPublishNewVersion", resourceRoot, title, content)
end)

addEvent("rules:clientUpdateExistingAction", true)
addEventHandler("rules:clientUpdateExistingAction", root, function(targetVer, title, content, makeActive)
    triggerServerEvent("rules:serverUpdateExistingVersion", resourceRoot, targetVer, title, content, makeActive)
end)

addEvent("rules:clientDeleteAction", true)
addEventHandler("rules:clientDeleteAction", root, function(targetVer)
    triggerServerEvent("rules:serverDeleteVersion", resourceRoot, targetVer)
end)

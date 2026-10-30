local screenW, screenH = guiGetScreenSize()
local scoreboardBrowser = nil
local isBrowserReady = false
local isVisible = false
local isLockedOpen = false
local lastRequestTime = 0

local function initScoreboardCEF()
    scoreboardBrowser = createBrowser(screenW, screenH, true, true)
    
    addEventHandler("onClientBrowserCreated", scoreboardBrowser, function()
        loadBrowserURL(scoreboardBrowser, "http://mta/" .. getResourceName(getThisResource()) .. "/html/index.html")
    end)

    addEventHandler("onClientBrowserDocumentReady", scoreboardBrowser, function()
        isBrowserReady = true
        focusBrowser(scoreboardBrowser)
    end)
end
addEventHandler("onClientResourceStart", resourceRoot, initScoreboardCEF)

addEventHandler("onClientRender", root, function()
    if isVisible and scoreboardBrowser and isBrowserReady then
        dxDrawImage(0, 0, screenW, screenH, scoreboardBrowser, 0, 0, 0, tocolor(255, 255, 255, 255), true)
    end
end)

addEvent("scoreboard:receiveSync", true)
addEventHandler("scoreboard:receiveSync", localPlayer, function(data)
    if scoreboardBrowser and isBrowserReady then
        local jsonString = toJSON(data)
        jsonString = jsonString:sub(2, #jsonString - 1)
        executeBrowserJavascript(scoreboardBrowser, "renderData(" .. jsonString .. ");")
    end
end)

local function setScoreboardOpen(state)
    if isVisible == state then return end
    isVisible = state
    
    if isVisible then
        local now = getTickCount()
        if (now - lastRequestTime) > 1500 then
            lastRequestTime = now
            triggerServerEvent("scoreboard:requestSync", localPlayer)
        end
        if scoreboardBrowser and isBrowserReady then
            executeBrowserJavascript(scoreboardBrowser, "toggleView(true);")
        end
    else
        if scoreboardBrowser and isBrowserReady then
            executeBrowserJavascript(scoreboardBrowser, "toggleView(false);")
        end
    end
end

-- پشتیبانی از اسکرول ماوس حین نگه‌داشتن TAB
addEventHandler("onClientKey", root, function(button, press)
    if button == "tab" then
        cancelEvent()
        if isLockedOpen then return end
        setScoreboardOpen(press)
    elseif isVisible and press then
        if button == "mouse_wheel_up" then
            if scoreboardBrowser and isBrowserReady then
                executeBrowserJavascript(scoreboardBrowser, "scrollList(-70);")
            end
        elseif button == "mouse_wheel_down" then
            if scoreboardBrowser and isBrowserReady then
                executeBrowserJavascript(scoreboardBrowser, "scrollList(70);")
            end
        end
    end
end)

addCommandHandler("tab", function()
    isLockedOpen = not isLockedOpen
    setScoreboardOpen(isLockedOpen)
    showCursor(isLockedOpen)
end)
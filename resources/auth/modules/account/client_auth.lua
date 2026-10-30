authBrowserGUI = nil
authBrowser = nil

function initAuthUI()
    if isElement(authBrowserGUI) then destroyElement(authBrowserGUI) end

    showCursor(true, true)
    fadeCamera(true)
    setCameraMatrix(1448.8, -875.4, 60.5, 1449.1, -876.4, 59.8)

    local screenW, screenH = guiGetScreenSize()
    authBrowserGUI = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
    authBrowser = guiGetBrowser(authBrowserGUI)

    guiBringToFront(authBrowserGUI)
    guiSetProperty(authBrowserGUI, "AlwaysOnTop", "True")
    guiSetInputMode("no_binds")

    addEventHandler("onClientBrowserCreated", authBrowser, function()
        loadBrowserURL(source, "http://mta/local/ui/index.html")
    end)

    addEventHandler("onClientBrowserDocumentReady", authBrowser, function()
        focusBrowser(source)
    end)
end
addEventHandler("onClientResourceStart", resourceRoot, initAuthUI)

addEventHandler("onClientClick", root, function(button, state)
    if isElement(authBrowser) and state == "down" then
        focusBrowser(authBrowser)
    end
end)

addEvent("auth:clientSubmit", true)
addEventHandler("auth:clientSubmit", root, function(user, pass, mode, email, phone, referral, rememberMe)
    if mode == "login" then
        triggerServerEvent("auth:requestLogin", resourceRoot, user, pass, rememberMe)
    elseif mode == "register" then
        triggerServerEvent("auth:requestRegister", resourceRoot, user, pass, email, phone, referral, rememberMe)
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
    if authBrowser then
        local js = string.format("showResponse(%s, %s, %s, %s);", 
            tostring(success), 
            toJSON(message or ""), 
            token and toJSON(token) or "null", 
            user and toJSON(user) or "null"
        )
        executeBrowserJavascript(authBrowser, js)
    end
end)

addEvent("auth:loginSuccess", true)
addEventHandler("auth:loginSuccess", root, function()
    if isElement(authBrowserGUI) then
        destroyElement(authBrowserGUI)
        authBrowserGUI = nil
        authBrowser = nil
    end
    showCursor(false)
    guiSetInputMode("allow_binds")
    setCameraTarget(localPlayer)
end)

addEvent("auth:showLogin", true)
addEventHandler("auth:showLogin", root, function()
    if isElement(panelGUI) then
        destroyElement(panelGUI)
        panelGUI = nil
        panelBrowser = nil
        isPanelOpen = false
    end
    initAuthUI()
end)

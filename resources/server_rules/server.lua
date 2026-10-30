local db = nil
local readingProps = {}
local PROP_MODEL = 2894

local function initRulesDB()
    local c = RulesConfig.db
    local conn = string.format("dbname=%s;host=%s;port=%d;charset=%s", c.name, c.host, c.port, c.charset)
    db = dbConnect(c.type, conn, c.user, c.pass)

    if not db then
        outputDebugString("[RULES] Database connection failed!", 1)
        return
    end

    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS server_rules (
            id INT AUTO_INCREMENT PRIMARY KEY,
            version INT NOT NULL DEFAULT 1,
            title VARCHAR(150) NOT NULL DEFAULT 'قوانین و مقررات رسمی سرور',
            content TEXT NOT NULL,
            created_by VARCHAR(50) NOT NULL DEFAULT 'SilentGalaxy',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            is_active TINYINT(1) DEFAULT 1
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end
addEventHandler("onResourceStart", resourceRoot, initRulesDB)

function checkPlayerAdminAccess(player, callback)
    if not isElement(player) or not db then
        if callback then callback(false) end
        return
    end

    local perms = getElementData(player, "admin_perms") or getElementData(player, "permissions")
    local lvl = getElementData(player, "admin_level") or getElementData(player, "admin")

    if (perms and type(perms) == "string" and string.find(perms, "rules")) or (lvl ~= nil and tonumber(lvl) and tonumber(lvl) >= 0) then
        if callback then callback(true, getElementData(player, "account:username") or getPlayerName(player)) end
        return
    end

    local serial = getPlayerSerial(player)
    local accId = getElementData(player, "account:id") or getElementData(player, "id") or 0
    local pName = getPlayerName(player)

    local q = "SELECT id, username, admin_level, admin_perms FROM accounts WHERE serial = ? OR id = ? OR username = ? LIMIT 1"
    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        if res and res[1] then
            local row = res[1]
            local dbLvl = tonumber(row.admin_level)
            local dbPerms = tostring(row.admin_perms or "")

            if (dbLvl and dbLvl >= 0) or string.find(dbPerms, "rules") then
                if callback then callback(true, row.username or pName, row.id) end
                return
            end
        end

        local pAccount = getPlayerAccount(player)
        if pAccount and not isGuestAccount(pAccount) then
            local accName = getAccountName(pAccount)
            local adminGroup = aclGetGroup("Admin")
            if adminGroup and isObjectInACLGroup("user." .. accName, adminGroup) then
                if callback then callback(true, accName, 0) end
                return
            end
        end

        if callback then callback(false) end
    end, db, q, serial, tonumber(accId) or -1, pName)
end

function getAllRulesData(callback)
    if not db then return end
    local query = "SELECT id, version, title, content, created_by, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as created_at, is_active FROM server_rules ORDER BY version DESC"
    dbQuery(function(qh)
        local allRules = dbPoll(qh, 0) or {}
        if callback then callback(allRules) end
    end, db, query)
end

function broadcastRulesUpdate()
    getAllRulesData(function(newRulesList)
        for _, p in ipairs(getElementsByType("player")) do
            checkPlayerAdminAccess(p, function(isAdmin)
                triggerClientEvent(p, "rules:clientSyncRulesData", p, newRulesList, isAdmin)
            end)
        end
    end)
end

-- توابع Export شده که سیستم auth آن را صدا می‌زند
function getActiveRuleVersion()
    if not db then return 1 end
    local q = dbQuery(db, "SELECT version FROM server_rules WHERE is_active = 1 ORDER BY version DESC LIMIT 1")
    local res = dbPoll(q, -1)
    return (res and #res > 0) and tonumber(res[1].version) or 1
end

function openRulesForPlayer(player, forAction)
    if not isElement(player) then return end
    checkPlayerAdminAccess(player, function(isAdmin)
        getAllRulesData(function(rulesList)
            if isElement(player) then
                triggerClientEvent(player, "rules:clientOpenModal", player, rulesList, forAction or "view", isAdmin)
            end
        end)
    end)
end

addEvent("rules:serverRequestRulesData", true)
addEventHandler("rules:serverRequestRulesData", root, function(forAction)
    local player = client
    if not isElement(player) then return end
    openRulesForPlayer(player, forAction or "view")
end)

addEvent("rules:serverStartReadingAnim", true)
addEventHandler("rules:serverStartReadingAnim", root, function()
    local player = client
    if not isElement(player) or isPedDead(player) or isPedInVehicle(player) then return end

    if isElement(readingProps[player]) then
        destroyElement(readingProps[player])
        readingProps[player] = nil
    end

    local x, y, z = getElementPosition(player)
    local prop = createObject(PROP_MODEL, x, y, z)
    setElementDimension(prop, getElementDimension(player))
    setElementInterior(prop, getElementInterior(player))
    setElementCollisionsEnabled(prop, false)

    local boneAttach = getResourceFromName("bone_attach")
    if boneAttach and getResourceState(boneAttach) == "running" then
        exports.bone_attach:attachElementToBone(prop, player, 12, 0.05, 0.05, 0.05, 0, 90, 0)
    else
        attachElements(prop, player, 0.15, 0.35, 0.1, 0, 20, 0)
    end

    readingProps[player] = prop
    setPedAnimation(player, "COP_AMBIENT", "Coplook_think", -1, true, false, false)
end)

addEvent("rules:serverStopReadingAnim", true)
addEventHandler("rules:serverStopReadingAnim", root, function()
    local player = client
    if not isElement(player) then return end

    if isElement(readingProps[player]) then
        destroyElement(readingProps[player])
        readingProps[player] = nil
    end

    setPedAnimation(player, false)
end)

local function cleanupPlayerReading(player)
    if isElement(readingProps[player]) then
        destroyElement(readingProps[player])
        readingProps[player] = nil
    end
end
addEventHandler("onPlayerQuit", root, function() cleanupPlayerReading(source) end)
addEventHandler("onPlayerWasted", root, function() cleanupPlayerReading(source) end)

addEventHandler("onResourceStop", resourceRoot, function()
    for player, prop in pairs(readingProps) do
        if isElement(prop) then destroyElement(prop) end
        if isElement(player) then setPedAnimation(player, false) end
    end
    readingProps = {}
end)

addEvent("rules:serverRequestAdminPanel", true)
addEventHandler("rules:serverRequestAdminPanel", root, function()
    local player = client
    checkPlayerAdminAccess(player, function(isAdmin, adminName)
        if not isAdmin then
            outputChatBox("#FF0000[RULES] #FFFFFFشما دسترسی برای مدیریت قوانین را ندارید!", player, 255, 255, 255, true)
            return
        end

        getAllRulesData(function(rulesList)
            if isElement(player) then
                triggerClientEvent(player, "rules:clientOpenAdminEditor", player, rulesList)
            end
        end)
    end)
end)

addEvent("rules:serverUpdateExistingVersion", true)
addEventHandler("rules:serverUpdateExistingVersion", root, function(targetVer, title, content, makeActive)
    local admin = client
    checkPlayerAdminAccess(admin, function(isAdmin, adminName)
        if not isAdmin or not db then return end
        targetVer = tonumber(targetVer)
        if not targetVer then return end

        if makeActive then
            dbExec(db, "UPDATE server_rules SET is_active = 0")
            dbExec(db, "UPDATE server_rules SET title = ?, content = ?, is_active = 1 WHERE version = ?", title, content, targetVer)
            outputChatBox("#00FF00[RULES] #FFFFFFنسخه " .. targetVer .. " بروزرسانی و فعال گردید.", admin, 255, 255, 255, true)
            outputChatBox("#38BDF8[RULES] #FFFFFFقوانین سرور بروزرسانی شدند (نسخه " .. targetVer .. "). جهت مطالعه کلید #FFFF00F5 #FFFFFFرا بفشارید.", root, 255, 255, 255, true)
        else
            dbExec(db, "UPDATE server_rules SET title = ?, content = ? WHERE version = ?", title, content, targetVer)
            outputChatBox("#00FF00[RULES] #FFFFFFنسخه " .. targetVer .. " در آرشیو بروزرسانی شد.", admin, 255, 255, 255, true)
        end

        broadcastRulesUpdate()
    end)
end)

addEvent("rules:serverDeleteVersion", true)
addEventHandler("rules:serverDeleteVersion", root, function(targetVer)
    local admin = client
    checkPlayerAdminAccess(admin, function(isAdmin)
        if not isAdmin or not db then return end
        targetVer = tonumber(targetVer)
        if not targetVer then return end

        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            if res and #res <= 1 then
                outputChatBox("#FF0000[RULES] #FFFFFFتنها نسخه باقی‌مانده قابل حذف نیست!", admin, 255, 255, 255, true)
                return
            end

            dbExec(db, "DELETE FROM server_rules WHERE version = ?", targetVer)
            dbExec(db, "UPDATE server_rules SET is_active = 1 WHERE version = (SELECT v FROM (SELECT MAX(version) AS v FROM server_rules) AS tmp) AND (SELECT COUNT(*) FROM (SELECT id FROM server_rules WHERE is_active = 1) AS act) = 0")

            outputChatBox("#00FF00[RULES] #FFFFFFنسخه " .. targetVer .. " حذف گردید.", admin, 255, 255, 255, true)
            broadcastRulesUpdate()
        end, db, "SELECT id FROM server_rules")
    end)
end)

addEvent("rules:serverPublishNewVersion", true)
addEventHandler("rules:serverPublishNewVersion", root, function(title, content)
    local admin = client
    checkPlayerAdminAccess(admin, function(isAdmin, adminName, adminAccId)
        if not isAdmin or not db then return end
        adminName = adminName or getElementData(admin, "account:username") or getPlayerName(admin)

        dbQuery(function(qh)
            local res = dbPoll(qh, 0)
            local nextVer = (res and res[1] and tonumber(res[1].max_ver) or 0) + 1

            dbExec(db, "UPDATE server_rules SET is_active = 0")
            dbExec(db, "INSERT INTO server_rules (version, title, content, created_by, is_active) VALUES (?, ?, ?, ?, 1)",
                nextVer, title, content, adminName
            )

            if adminAccId then
                dbExec(db, "UPDATE accounts SET accepted_rules_version = ? WHERE id = ?", nextVer, adminAccId)
            end

            outputChatBox("#00FF00[RULES] #FFFFFFنسخه جدید قوانین (" .. nextVer .. ") ثبت و فعال گردید.", admin, 255, 255, 255, true)
            outputChatBox("#38BDF8[RULES] #FFFFFFقوانین سرور بروزرسانی شدند (نسخه " .. nextVer .. "). فشردن کلید #FFFF00F5 #FFFFFFبرای مطالعه.", root, 255, 255, 255, true)

            broadcastRulesUpdate()
        end, db, "SELECT MAX(version) as max_ver FROM server_rules")
    end)
end)

addEvent("rules:serverSubmitAcceptance", true)
addEventHandler("rules:serverSubmitAcceptance", root, function(ver, forAction)
    local player = client
    if not isElement(player) or not db then return end

    local accId = getElementData(player, "account:id") or getElementData(player, "id")
    ver = tonumber(ver) or 1

    if accId then
        dbExec(db, "UPDATE accounts SET accepted_rules_version = ? WHERE id = ?", ver, accId)
    end

    triggerEvent("rules:onPlayerAcceptedRules", player, ver, forAction)
end)

addCommandHandler(RulesConfig.command, function(player) openRulesForPlayer(player, "view") end)
addCommandHandler(RulesConfig.aliasCommand, function(player) openRulesForPlayer(player, "view") end)

local purgeTimer = nil

addEvent("panel:requestData", true)
addEventHandler("panel:requestData", root, function()
    local player = client
    if not isElement(player) or not db then return end
    local username = getElementData(player, "account:username")
    if not username then return end

    dbQuery(function(qh)
        if not isElement(player) then return end
        local res = dbPoll(qh, 0)
        if not res or #res == 0 then return end
        local uData = res[1]

        dbQuery(function(qhLogs)
            if not isElement(player) then return end
            local logRes = dbPoll(qhLogs, 0) or {}

            dbQuery(function(qhRefs)
                if not isElement(player) then return end
                local refRes = dbPoll(qhRefs, 0) or {}

                local payload = {
                    id = uData.id,
                    username = uData.username,
                    money = uData.money,
                    registered_date = tostring(uData.registered_date or "-"),
                    last_login = tostring(uData.last_login or "-"),
                    email = uData.email or "",
                    phone_number = uData.phone_number or "",
                    email_verified = tonumber(uData.email_verified) or 0,
                    phone_verified = tonumber(uData.phone_verified) or 0,
                    referred_by = uData.referred_by or "",
                    admin_level = tonumber(uData.admin_level) or -1,
                    session_expire_days = tonumber(uData.session_expire_days) or 7,
                    logs = logRes,
                    referrals = refRes
                }

                triggerClientEvent(player, "panel:receiveData", player, toJSON(payload))

                if (tonumber(uData.admin_level) or -1) >= 0 then
                    dbQuery(function(qhAdmin)
                        if not isElement(player) then return end
                        local allUsers = dbPoll(qhAdmin, 0) or {}

                        local onlineAccIds = {}
                        for _, p in ipairs(getElementsByType("player")) do
                            local aid = getElementData(p, "account:id")
                            if aid then onlineAccIds[aid] = true end
                        end

                        for _, u in ipairs(allUsers) do
                            u.is_online = onlineAccIds[u.id] and 1 or 0
                        end

                        triggerClientEvent(player, "panel:receiveAdminUserList", player, toJSON(allUsers))
                    end, db, "SELECT id, username, phone_number, admin_level, is_banned, ban_reason, banned_by, is_muted, mute_reason, admin_perms, accepted_rules_version FROM accounts ORDER BY id DESC LIMIT 80")
                end
            end, db, [[
                SELECT a1.username, a1.registered_date, a1.last_login, a1.money,
                (SELECT COUNT(*) FROM accounts a2 WHERE a2.referred_by = a1.username) AS sub_refs
                FROM accounts a1
                WHERE a1.referred_by = ?
                ORDER BY a1.id DESC
            ]], username)
        end, db, "SELECT ip, serial, login_time, status FROM account_login_logs WHERE account_id = ? ORDER BY id DESC LIMIT 15", uData.id)
    end, db, "SELECT * FROM accounts WHERE username = ?", username)
end)

addEvent("panel:serverUpdateSecurity", true)
addEventHandler("panel:serverUpdateSecurity", root, function(newPass, newEmail, newPhone, expireDays)
    local player = client
    if not isElement(player) or not db then return end
    local username = getElementData(player, "account:username")
    if not username then return end

    dbQuery(function(qh)
        if not isElement(player) then return end
        local res = dbPoll(qh, 0)
        if res and #res > 0 then
            local curr = res[1]

            if newPass and #newPass >= 4 then
                local hash = sha256(newPass)
                dbExec(db, "UPDATE accounts SET password = ? WHERE id = ?", hash, curr.id)
            end

            local setExpire = tonumber(expireDays) or 7

            dbExec(db, "UPDATE accounts SET email = ?, phone_number = ?, session_expire_days = ? WHERE id = ?", 
                newEmail, newPhone, setExpire, curr.id
            )

            outputChatBox("#00FF00[SECURITY] #FFFFFFمشخصات و دوره نشست امنیتی با موفقیت ذخیره شد.", player, 255, 255, 255, true)
            triggerEvent("panel:requestData", player)
        end
    end, db, "SELECT * FROM accounts WHERE username = ?", username)
end)

addEvent("panel:serverLogout", true)
addEventHandler("panel:serverLogout", root, function()
    local player = client
    if not isElement(player) or not db then return end
    local username = getElementData(player, "account:username")

    savePlayerData(player)
    if username then
        dbExec(db, "UPDATE accounts SET remember_token = NULL WHERE username = ?", username)
    end

    removeElementData(player, "account:username")
    removeElementData(player, "account:id")
    removeElementData(player, "admin_level")

    setElementDimension(player, 999)
    setElementFrozen(player, true)

    triggerClientEvent(player, "auth:showLogin", player)
    outputChatBox("#38BDF8[AUTH] #FFFFFFبا موفقیت از حساب خارج شدید.", player, 255, 255, 255, true)
end)

addEvent("panel:serverAdminAction", true)
addEventHandler("panel:serverAdminAction", root, function(targetId, action, reason, adminLvl, perms)
    local admin = client
    if not isPlayerAdmin(admin) or not db then return end

    targetId = tonumber(targetId)
    local adminName = getElementData(admin, "account:username") or "Admin"

    if action == "ban" then
        dbExec(db, "UPDATE accounts SET is_banned = 1, ban_reason = ?, banned_by = ? WHERE id = ?", reason, adminName, targetId)
        outputChatBox("#FF0000[ADMIN] #FFFFFFکاربر #" .. targetId .. " مسدود شد. دلیل: " .. reason, admin, 255, 255, 255, true)
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "account:id") == targetId then kickPlayer(p, admin, "شما مسدود شدید: " .. reason) end
        end
    elseif action == "unban" then
        dbExec(db, "UPDATE accounts SET is_banned = 0, ban_reason = NULL, banned_by = NULL WHERE id = ?", targetId)
        outputChatBox("#00FF00[ADMIN] #FFFFFFکاربر #" .. targetId .. " رفع مسدودیت شد.", admin, 255, 255, 255, true)
    elseif action == "mute" then
        dbExec(db, "UPDATE accounts SET is_muted = 1, mute_reason = ? WHERE id = ?", reason, targetId)
        outputChatBox("#FF0000[ADMIN] #FFFFFFکاربر #" .. targetId .. " در حالت سکوت قرار گرفت.", admin, 255, 255, 255, true)
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "account:id") == targetId then setPlayerMuted(p, true) end
        end
    elseif action == "unmute" then
        dbExec(db, "UPDATE accounts SET is_muted = 0, mute_reason = NULL WHERE id = ?", targetId)
        outputChatBox("#00FF00[ADMIN] #FFFFFFکاربر #" .. targetId .. " از حالت سکوت خارج شد.", admin, 255, 255, 255, true)
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "account:id") == targetId then setPlayerMuted(p, false) end
        end
    elseif action == "save_perms" then
        dbExec(db, "UPDATE accounts SET admin_level = ?, admin_perms = ? WHERE id = ?", tonumber(adminLvl) or -1, perms, targetId)
        outputChatBox("#00FF00[ADMIN] #FFFFFFسطح و دسترسی‌های کاربر #" .. targetId .. " ذخیره شد.", admin, 255, 255, 255, true)
    end

    triggerEvent("panel:requestData", admin)
end)

addEvent("panel:serverStartGlobalPurge", true)
addEventHandler("panel:serverStartGlobalPurge", root, function()
    local admin = client
    if not isPlayerAdmin(admin) or not db then return end

    if isTimer(purgeTimer) then
        outputChatBox("#FF0000[ADMIN] #FFFFFFخروج اضطراری هم‌اکنون فعال است!", admin, 255, 255, 255, true)
        return
    end

    triggerClientEvent(root, "auth:startPurgeCountdown", root, Config.security.purgeCountdown)

    purgeTimer = setTimer(function()
        if db then dbExec(db, "UPDATE accounts SET remember_token = NULL") end
        for _, p in ipairs(getElementsByType("player")) do
            savePlayerData(p)
            removeElementData(p, "account:username")
            removeElementData(p, "account:id")
            removeElementData(p, "admin_level")
            setElementDimension(p, 999)
            setElementFrozen(p, true)
            triggerClientEvent(p, "auth:showLogin", p)
        end
    end, Config.security.purgeCountdown * 1000, 1)
end)

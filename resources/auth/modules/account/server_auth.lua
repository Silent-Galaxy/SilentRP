local pendingRulesLogins = {}

local function spawnConfigPlayer(player, username, x, y, z, rot, skin, money, adminLevel, isMuted)
    if not isElement(player) then return end
    local sp = Config.spawn
    x = tonumber(x) or sp.x
    y = tonumber(y) or sp.y
    z = tonumber(z) or sp.z
    rot = tonumber(rot) or sp.rot
    skin = tonumber(skin) or sp.skin
    money = tonumber(money) or sp.money

    setElementData(player, "account:username", username)
    setElementData(player, "admin_level", tonumber(adminLevel) or -1)
    setPlayerMuted(player, isMuted == 1)

    spawnPlayer(player, x, y, z, rot, skin, 0, 0)
    setElementInterior(player, 0)
    setElementDimension(player, 0)
    setElementFrozen(player, false)

    setPlayerMoney(player, 0)
    givePlayerMoney(player, money)

    fadeCamera(player, true)
    setCameraTarget(player, player)

    outputChatBox("#00FF00[SERVER] #FFFFFFخوش آمدید، " .. username .. "!", player, 255, 255, 255, true)
    outputChatBox("#38BDF8[INFO] #FFFFFFکلید #FFFF00F2 #FFFFFFبرای پنل کاربری | دستور #FFFF00/rules #FFFFFFبرای مشاهده قوانین.", player, 255, 255, 255, true)
end

function savePlayerData(player)
    if not isElement(player) or not db then return end
    local accountName = getElementData(player, "account:username")
    if not accountName then return end

    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)
    local skin = getElementModel(player)
    local money = getPlayerMoney(player)

    dbExec(db, "UPDATE accounts SET x = ?, y = ?, z = ?, rotation = ?, skin = ?, money = ? WHERE username = ?",
        x, y, z, rot, skin, money, accountName
    )
end

local function getActiveRulesVer()
    local res = getResourceFromName("server_rules")
    if res and getResourceState(res) == "running" then
        return tonumber(exports.server_rules:getActiveRuleVersion()) or 1
    end
    return 1
end

addEvent("auth:requestRegister", true)
addEventHandler("auth:requestRegister", root, function(username, password, email, phone, referral, rememberMe)
    local player = client
    if not isElement(player) or not db then return end
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)
    local hashPass = sha256(password)

    local limited, reason = isRateLimited(serial)
    if limited then
        triggerClientEvent(player, "auth:response", player, false, reason)
        return
    end

    dbQuery(function(qhSerial)
        if not isElement(player) then return end
        local serialResult = dbPoll(qhSerial, 0)
        if serialResult and #serialResult > 0 then
            triggerClientEvent(player, "auth:response", player, false, "شما قبلاً با این سیستم حساب ساخته‌اید!")
            return
        end

        dbQuery(function(qhUser)
            if not isElement(player) then return end
            local userResult = dbPoll(qhUser, 0)
            if userResult and #userResult > 0 then
                triggerClientEvent(player, "auth:response", player, false, "این نام کاربری قبلاً ثبت شده است!")
                return
            end

            local startingCash = Config.spawn.money
            local validReferrer = nil

            if referral and #referral >= 3 and referral:lower() ~= username:lower() then
                local refQuery = dbQuery(db, "SELECT id, username FROM accounts WHERE username = ?", referral)
                local refResult = dbPoll(refQuery, -1)
                if refResult and #refResult > 0 then
                    validReferrer = refResult[1].username
                    startingCash = startingCash + Config.referral.starterBonus
                    dbExec(db, "UPDATE accounts SET money = money + ? WHERE id = ?", Config.referral.referrerReward, refResult[1].id)
                end
            end

            local token = rememberMe and generateToken(username, serial) or nil
            local acceptedVer = getActiveRulesVer()
            local sp = Config.spawn

            dbExec(db, [[
                INSERT INTO accounts 
                (username, password, email, phone_number, serial, last_serial, referred_by, money, skin, x, y, z, rotation, remember_token, last_login, admin_level, session_expire_days, accepted_rules_version) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), -1, 7, ?)
            ]], username, hashPass, email, phone, serial, serial, validReferrer, startingCash, sp.skin, sp.x, sp.y, sp.z, sp.rot, token, acceptedVer)

            dbQuery(function(qhNew)
                local newRes = dbPoll(qhNew, 0)
                if newRes and #newRes > 0 then
                    local newId = newRes[1].id
                    if isElement(player) then setElementData(player, "account:id", newId) end
                    logLoginAttempt(newId, ip, serial, "success")
                end
            end, db, "SELECT id FROM accounts WHERE username = ?", username)

            resetLoginAttempts(serial)
            triggerClientEvent(player, "auth:response", player, true, "ثبت‌نام با موفقیت انجام شد!", token, username)
            triggerClientEvent(player, "auth:loginSuccess", player)
            spawnConfigPlayer(player, username, sp.x, sp.y, sp.z, sp.rot, sp.skin, startingCash, -1, 0)

        end, db, "SELECT id FROM accounts WHERE username = ?", username)
    end, db, "SELECT id FROM accounts WHERE serial = ?", serial)
end)

addEvent("auth:requestLogin", true)
addEventHandler("auth:requestLogin", root, function(username, password, rememberMe)
    local player = client
    if not isElement(player) or not db then return end
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)
    local hashPass = sha256(password)

    local limited, reason = isRateLimited(serial)
    if limited then
        triggerClientEvent(player, "auth:response", player, false, reason)
        return
    end

    dbQuery(function(qh)
        if not isElement(player) then return end
        local result = dbPoll(qh, 0)
        if result and #result > 0 then
            local data = result[1]

            if data.is_banned == 1 then
                triggerClientEvent(player, "auth:response", player, false, "حساب مسدود است! دلیل: " .. tostring(data.ban_reason))
                logLoginAttempt(data.id, ip, serial, "failed")
                return
            end

            local userVer = tonumber(data.accepted_rules_version) or 0
            local currentRuleVer = getActiveRulesVer()

            -- اگر قوانین جدید آمده، باز کردن مودال از ریسورس server_rules
            if userVer < currentRuleVer then
                pendingRulesLogins[player] = { data = data, rememberMe = rememberMe, ip = ip, serial = serial }
                local rRes = getResourceFromName("server_rules")
                if rRes and getResourceState(rRes) == "running" then
                    exports.server_rules:openRulesForPlayer(player, "login_update")
                end
                return
            end

            resetLoginAttempts(serial)
            local token = rememberMe and generateToken(username, serial) or nil

            dbExec(db, "UPDATE accounts SET last_serial = ?, serial = ?, last_login = NOW(), remember_token = ? WHERE id = ?", 
                serial, serial, token, data.id
            )

            setElementData(player, "account:id", data.id)
            logLoginAttempt(data.id, ip, serial, "success")

            triggerClientEvent(player, "auth:response", player, true, "ورود با موفقیت انجام شد!", token, username)
            triggerClientEvent(player, "auth:loginSuccess", player)
            spawnConfigPlayer(player, username, data.x, data.y, data.z, data.rotation, data.skin, data.money, data.admin_level, data.is_muted)
        else
            addLoginAttemptFail(serial)
            triggerClientEvent(player, "auth:response", player, false, "نام کاربری یا رمز عبور اشتباه است!")
        end
    end, db, "SELECT * FROM accounts WHERE username = ? AND password = ?", username, hashPass)
end)

-- دریافت تاییدیه قوانین جدید از سمت ریسورس server_rules
addEvent("rules:onPlayerAcceptedRules", false)
addEventHandler("rules:onPlayerAcceptedRules", root, function(ver, forAction)
    local player = source
    if not isElement(player) or not db then return end

    local pending = pendingRulesLogins[player]
    if pending and pending.data then
        local data = pending.data
        local token = pending.rememberMe and generateToken(data.username, pending.serial) or nil

        dbExec(db, "UPDATE accounts SET last_serial = ?, serial = ?, last_login = NOW(), remember_token = ? WHERE id = ?",
            pending.serial, pending.serial, token, data.id
        )

        setElementData(player, "account:id", data.id)
        logLoginAttempt(data.id, pending.ip, pending.serial, "success")
        resetLoginAttempts(pending.serial)

        pendingRulesLogins[player] = nil

        triggerClientEvent(player, "auth:response", player, true, "قوانین تایید و ورود انجام شد!", token, data.username)
        triggerClientEvent(player, "auth:loginSuccess", player)
        spawnConfigPlayer(player, data.username, data.x, data.y, data.z, data.rotation, data.skin, data.money, data.admin_level, data.is_muted)
    end
end)

addEvent("auth:requestAutoLogin", true)
addEventHandler("auth:requestAutoLogin", root, function(username, token)
    local player = client
    if not isElement(player) or not db then return end
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)

    dbQuery(function(qh)
        if not isElement(player) then return end
        local result = dbPoll(qh, 0)
        if result and #result > 0 then
            local data = result[1]

            if data.is_banned == 1 then
                triggerClientEvent(player, "auth:response", player, false, "حساب مسدود است: " .. tostring(data.ban_reason))
                return
            end

            local expireDays = tonumber(data.session_expire_days) or Config.security.defaultExpireDays
            dbQuery(function(qhExp)
                if not isElement(player) then return end
                local expRes = dbPoll(qhExp, 0)
                if expRes and #expRes > 0 and expRes[1].is_expired == 1 then
                    dbExec(db, "UPDATE accounts SET remember_token = NULL WHERE id = ?", data.id)
                    triggerClientEvent(player, "auth:response", player, false, "دوره نشست منقضی شده؛ لطفاً رمز را وارد کنید.")
                    return
                end

                local userVer = tonumber(data.accepted_rules_version) or 0
                local currentRuleVer = getActiveRulesVer()

                if userVer < currentRuleVer then
                    pendingRulesLogins[player] = { data = data, rememberMe = true, ip = ip, serial = serial }
                    local rRes = getResourceFromName("server_rules")
                    if rRes and getResourceState(rRes) == "running" then
                        exports.server_rules:openRulesForPlayer(player, "login_update")
                    end
                    return
                end

                dbExec(db, "UPDATE accounts SET last_serial = ?, serial = ?, last_login = NOW() WHERE id = ?", serial, serial, data.id)
                setElementData(player, "account:id", data.id)
                logLoginAttempt(data.id, ip, serial, "success")

                triggerClientEvent(player, "auth:loginSuccess", player)
                spawnConfigPlayer(player, username, data.x, data.y, data.z, data.rotation, data.skin, data.money, data.admin_level, data.is_muted)
            end, db, "SELECT IF(NOW() > DATE_ADD(last_login, INTERVAL ? DAY), 1, 0) AS is_expired FROM accounts WHERE id = ?", expireDays, data.id)
        else
            triggerClientEvent(player, "auth:response", player, false, "نشست قبلی یافت نشد یا منقضی شده است.")
        end
    end, db, "SELECT * FROM accounts WHERE username = ? AND remember_token = ?", username, token)
end)

addEvent("auth:requestResetPassword", true)
addEventHandler("auth:requestResetPassword", root, function(username, email, newPassword)
    local player = client
    if not isElement(player) or not db then return end
    local hashNewPass = sha256(newPassword)

    dbQuery(function(qh)
        if not isElement(player) then return end
        local result = dbPoll(qh, 0)
        if result and #result > 0 then
            dbExec(db, "UPDATE accounts SET password = ?, remember_token = NULL WHERE username = ? AND email = ?", hashNewPass, username, email)
            triggerClientEvent(player, "auth:response", player, true, "رمز عبور با موفقیت تغییر یافت! اکنون وارد شوید.")
        else
            triggerClientEvent(player, "auth:response", player, false, "نام کاربری و ایمیل تطابق ندارند!")
        end
    end, db, "SELECT id FROM accounts WHERE username = ? AND email = ?", username, email)
end)

addEventHandler("onPlayerQuit", root, function()
    savePlayerData(source)
    pendingRulesLogins[source] = nil
end)

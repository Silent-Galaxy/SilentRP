local db = dbConnect("mysql", "dbname=mta_db;host=127.0.0.1;port=3306;charset=utf8", "root", "")

if db then
    outputDebugString("[AUTH/PANEL] Database connected successfully!", 3)
    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS server_rules (
            id INT AUTO_INCREMENT PRIMARY KEY,
            version INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            created_by VARCHAR(64) NOT NULL DEFAULT 'Admin',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            is_active TINYINT(1) DEFAULT 1
        )
    ]])
    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        if not res or #res == 0 then
            dbExec(db, [[
                INSERT INTO server_rules (version, title, content, created_by, is_active)
                VALUES (1, 'قوانین و مقررات رسمی سرور', '۱. احترام به کلیه بازیکنان و پرسنل سرور الزامی است.\n۲. هرگونه استفاده از چیت و باگ مسدودیت دائم دارد.\n۳. رعایت اصول رول‌پلی در تمام نقاط شهر اجباری است.\n۴. تبلیغات اکیداً ممنوع است.\n۵. رعایت ادب و اخلاق در تمامی بخش‌ها الزامی است.', 'مدیریت سرور', 1)
            ]])
        end
    end, db, "SELECT id FROM server_rules LIMIT 1")
else
    outputDebugString("[AUTH/PANEL] Failed to connect to MySQL database!", 1)
end

local loginAttempts = {}
local purgeTimer = nil

local function isPlayerAdmin(player)
    if not isElement(player) then return false end
    local lvl = getElementData(player, "admin_level")
    return (lvl ~= nil and tonumber(lvl) and tonumber(lvl) >= 0)
end

local function isRateLimited(serial)
    if not serial then return true, "سریال نامعتبر است!" end
    local now = getTickCount()
    if not loginAttempts[serial] then
        loginAttempts[serial] = { count = 0, lastTime = now }
    else
        if now - loginAttempts[serial].lastTime < 500 then return true, "لطفاً کمی صبر کنید..." end
        if loginAttempts[serial].count >= 6 and (now - loginAttempts[serial].lastTime < 25000) then
            return true, "تعداد تلاش ناموفق زیاد! ۲۵ ثانیه منتظر بمانید."
        end
    end
    loginAttempts[serial].lastTime = now
    return false
end

local function resetLoginAttempts(serial)
    if serial and loginAttempts[serial] then
        loginAttempts[serial].count = 0
    end
end

local function addLoginAttemptFail(serial)
    if not serial then return end
    if not loginAttempts[serial] then
        loginAttempts[serial] = { count = 1, lastTime = getTickCount() }
    else
        loginAttempts[serial].count = loginAttempts[serial].count + 1
    end
end

local function logLoginAttempt(accountId, ip, serial, status)
    if not db then return end
    dbExec(db, "INSERT INTO account_login_logs (account_id, ip, serial, status) VALUES (?, ?, ?, ?)", accountId, ip, serial, status)
end

local function generateToken(user, serial)
    return sha256(user .. serial .. getTickCount() .. tostring(math.random(11111, 99999)))
end

local function savePlayerData(player)
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

local function spawnMyPlayer(player, username, x, y, z, rot, skin, money, adminLevel, isMuted)
    if not isElement(player) then return end
    x = tonumber(x) or 1742.8
    y = tonumber(y) or -1863.8
    z = tonumber(z) or 13.6
    rot = tonumber(rot) or 0
    skin = tonumber(skin) or 0
    money = tonumber(money) or 1000

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
    outputChatBox("#38BDF8[INFO] #FFFFFFکلید #FFFF00F2 #FFFFFFرا برای مشاهده مشخصات و پنل فشار دهید.", player, 255, 255, 255, true)
end

addEvent("auth:fetchRulesForModal", true)
addEventHandler("auth:fetchRulesForModal", root, function(forAction)
    local player = client
    if not isElement(player) or not db then return end
    dbQuery(function(qh)
        if not isElement(player) then return end
        local res = dbPoll(qh, 0)
        local rule = (res and #res > 0) and res[1] or {
            version = 1,
            title = "قوانین و مقررات رسمی سرور",
            content = "۱. احترام به کلیه بازیکنان و پرسنل سرور الزامی است.\n۲. استفاده از چیت و باگ مسدودیت دائم دارد.\n۳. رعایت اصول رول‌پلی در تمام نقاط شهر اجباری است.\n۴. تبلیغات اکیداً ممنوع است.",
            created_by = "مدیریت",
            created_at = "هم‌اکنون"
        }
        triggerClientEvent(player, "auth:openRulesModalClient", player, rule, forAction)
    end, db, "SELECT * FROM server_rules WHERE is_active = 1 ORDER BY version DESC LIMIT 1")
end)

addEvent("auth:requestRegister", true)
addEventHandler("auth:requestRegister", root, function(username, password, email, phone, referral, rememberMe, ruleVer)
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

            local startingCash = 1000
            local validReferrer = nil

            if referral and #referral >= 3 and referral:lower() ~= username:lower() then
                local refQuery = dbQuery(db, "SELECT id, username FROM accounts WHERE username = ?", referral)
                local refResult = dbPoll(refQuery, -1)
                if refResult and #refResult > 0 then
                    validReferrer = refResult[1].username
                    startingCash = startingCash + 1500
                    dbExec(db, "UPDATE accounts SET money = money + 5000 WHERE id = ?", refResult[1].id)
                end
            end

            local token = rememberMe and generateToken(username, serial) or nil
            local acceptedVer = tonumber(ruleVer) or 1

            dbExec(db, [[
                INSERT INTO accounts 
                (username, password, email, phone_number, serial, last_serial, referred_by, money, skin, x, y, z, rotation, remember_token, last_login, admin_level, session_expire_days, accepted_rules_version) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, 1742.8, -1863.8, 13.6, 0, ?, NOW(), -1, 7, ?)
            ]], username, hashPass, email, phone, serial, serial, validReferrer, startingCash, token, acceptedVer)

            dbQuery(function(qhNew)
                local newRes = dbPoll(qhNew, 0)
                if newRes and #newRes > 0 then
                    local newId = newRes[1].id
                    if isElement(player) then setElementData(player, "account:id", newId) end
                    logLoginAttempt(newId, ip, serial, "success")
                    dbExec(db, "INSERT IGNORE INTO user_rule_acceptances (account_id, rule_version) VALUES (?, ?)", newId, acceptedVer)
                end
            end, db, "SELECT id FROM accounts WHERE username = ?", username)

            resetLoginAttempts(serial)
            triggerClientEvent(player, "auth:response", player, true, "ثبت‌نام با موفقیت انجام شد!", token, username)
            triggerClientEvent(player, "auth:loginSuccess", player)
            spawnMyPlayer(player, username, 1742.8, -1863.8, 13.6, 0, 0, startingCash, -1, 0)

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

            dbQuery(function(qhRule)
                if not isElement(player) then return end
                local rRes = dbPoll(qhRule, 0)
                if rRes and #rRes > 0 then
                    local activeRule = rRes[1]
                    local userVer = tonumber(data.accepted_rules_version) or 0
                    local currentRuleVer = tonumber(activeRule.version) or 1

                    if userVer < currentRuleVer then
                        setElementData(player, "temp:pending_login", data)
                        triggerClientEvent(player, "auth:openRulesModalClient", player, activeRule, "login_update")
                        return
                    end
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
                spawnMyPlayer(player, username, data.x, data.y, data.z, data.rotation, data.skin, data.money, data.admin_level, data.is_muted)
            end, db, "SELECT * FROM server_rules WHERE is_active = 1 ORDER BY version DESC LIMIT 1")
        else
            addLoginAttemptFail(serial)
            triggerClientEvent(player, "auth:response", player, false, "نام کاربری یا رمز عبور اشتباه است!")
        end
    end, db, "SELECT * FROM accounts WHERE username = ? AND password = ?", username, hashPass)
end)

addEvent("auth:serverAcceptRules", true)
addEventHandler("auth:serverAcceptRules", root, function(ver)
    local player = client
    if not isElement(player) or not db then return end
    local data = getElementData(player, "temp:pending_login")
    if not data then return end

    ver = tonumber(ver) or 1
    dbExec(db, "UPDATE accounts SET accepted_rules_version = ? WHERE id = ?", ver, data.id)
    dbExec(db, "INSERT IGNORE INTO user_rule_acceptances (account_id, rule_version) VALUES (?, ?)", data.id, ver)

    removeElementData(player, "temp:pending_login")
    setElementData(player, "account:id", data.id)
    logLoginAttempt(data.id, getPlayerIP(player), getPlayerSerial(player), "success")

    triggerClientEvent(player, "auth:loginSuccess", player)
    spawnMyPlayer(player, data.username, data.x, data.y, data.z, data.rotation, data.skin, data.money, data.admin_level, data.is_muted)
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

            local expireDays = tonumber(data.session_expire_days) or 7
            dbQuery(function(qhExp)
                if not isElement(player) then return end
                local expRes = dbPoll(qhExp, 0)
                if expRes and #expRes > 0 and expRes[1].is_expired == 1 then
                    dbExec(db, "UPDATE accounts SET remember_token = NULL WHERE id = ?", data.id)
                    triggerClientEvent(player, "auth:response", player, false, "دوره نشست شما پایان یافته است. لطفاً مجدداً رمز را وارد نمایید.")
                    return
                end

                dbQuery(function(qhRule)
                    if not isElement(player) then return end
                    local rRes = dbPoll(qhRule, 0)
                    if rRes and #rRes > 0 then
                        local activeRule = rRes[1]
                        local userVer = tonumber(data.accepted_rules_version) or 0
                        local currentRuleVer = tonumber(activeRule.version) or 1

                        if userVer < currentRuleVer then
                            setElementData(player, "temp:pending_login", data)
                            triggerClientEvent(player, "auth:openRulesModalClient", player, activeRule, "login_update")
                            return
                        end
                    end

                    dbExec(db, "UPDATE accounts SET last_serial = ?, serial = ?, last_login = NOW() WHERE id = ?", serial, serial, data.id)
                    setElementData(player, "account:id", data.id)
                    logLoginAttempt(data.id, ip, serial, "success")

                    triggerClientEvent(player, "auth:loginSuccess", player)
                    spawnMyPlayer(player, username, data.x, data.y, data.z, data.rotation, data.skin, data.money, data.admin_level, data.is_muted)
                end, db, "SELECT * FROM server_rules WHERE is_active = 1 ORDER BY version DESC LIMIT 1")
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

-----------------------------------------------------------------------
-- کنترل پنل F2
-----------------------------------------------------------------------
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

        dbQuery(function(qhRule)
            if not isElement(player) then return end
            local rRes = dbPoll(qhRule, 0)
            local activeRule = (rRes and #rRes > 0) and rRes[1] or {
                version = 1,
                title = "قوانین و مقررات رسمی سرور",
                content = "۱. احترام به کلیه بازیکنان الزامی است.\n۲. چیت و باگ مسدودیت دائم دارد.",
                created_by = "مدیریت",
                created_at = "امروز"
            }

            dbQuery(function(qhAcceptCount)
                if not isElement(player) then return end
                local cRes = dbPoll(qhAcceptCount, 0)
                activeRule.accept_count = cRes and cRes[1] and cRes[1].total or 0

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
                            accepted_rules_version = tonumber(uData.accepted_rules_version) or 0,
                            active_rules = activeRule,
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
            end, db, "SELECT COUNT(*) as total FROM user_rule_acceptances WHERE rule_version = ?", activeRule.version or 1)
        end, db, "SELECT * FROM server_rules WHERE is_active = 1 ORDER BY version DESC LIMIT 1")
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

            outputChatBox("#00FF00[SECURITY] #FFFFFFمشخصات و دوره نشست (هر " .. setExpire .. " روز یک‌بار) با موفقیت ذخیره شد.", player, 255, 255, 255, true)
            triggerEvent("panel:requestData", player)
        end
    end, db, "SELECT * FROM accounts WHERE username = ?", username)
end)

addEvent("panel:serverPublishRules", true)
addEventHandler("panel:serverPublishRules", root, function(title, content)
    local admin = client
    if not isPlayerAdmin(admin) or not db then return end

    local adminName = getElementData(admin, "account:username") or "Admin"

    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        local nextVer = (res and res[1] and tonumber(res[1].max_ver) or 0) + 1

        dbExec(db, "UPDATE server_rules SET is_active = 0")
        dbExec(db, "INSERT INTO server_rules (version, title, content, created_by, is_active) VALUES (?, ?, ?, ?, 1)", 
            nextVer, title, content, adminName
        )

        local adminAccId = getElementData(admin, "account:id")
        if adminAccId then
            dbExec(db, "UPDATE accounts SET accepted_rules_version = ? WHERE id = ?", nextVer, adminAccId)
            dbExec(db, "INSERT IGNORE INTO user_rule_acceptances (account_id, rule_version) VALUES (?, ?)", adminAccId, nextVer)
        end

        outputChatBox("#00FF00[RULES] #FFFFFFنسخه جدید قوانین (" .. nextVer .. ") با موفقیت منتشر شد.", admin, 255, 255, 255, true)
        outputChatBox("#38BDF8[RULES] #FFFFFFقوانین سرور بروزرسانی شدند (نسخه " .. nextVer .. ").", root, 255, 255, 255, true)
    end, db, "SELECT MAX(version) as max_ver FROM server_rules")
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

    triggerClientEvent(root, "auth:startPurgeCountdown", root, 300)

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
    end, 300000, 1)
end)

addEventHandler("onPlayerQuit", root, function()
    savePlayerData(source)
end)
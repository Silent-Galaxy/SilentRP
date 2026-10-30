local loginAttempts = {}

function isRateLimited(serial)
    if not serial then return true, "سریال نامعتبر است!" end
    local now = getTickCount()
    if not loginAttempts[serial] then
        loginAttempts[serial] = { count = 0, lastTime = now }
    else
        if now - loginAttempts[serial].lastTime < Config.security.cooldownMs then
            return true, "لطفاً کمی صبر کنید..."
        end
        if loginAttempts[serial].count >= Config.security.maxAttempts and (now - loginAttempts[serial].lastTime < (Config.security.lockoutSeconds * 1000)) then
            return true, string.format("تعداد تلاش ناموفق زیاد! %d ثانیه منتظر بمانید.", Config.security.lockoutSeconds)
        end
    end
    loginAttempts[serial].lastTime = now
    return false
end

function resetLoginAttempts(serial)
    if serial and loginAttempts[serial] then loginAttempts[serial].count = 0 end
end

function addLoginAttemptFail(serial)
    if not serial then return end
    if not loginAttempts[serial] then
        loginAttempts[serial] = { count = 1, lastTime = getTickCount() }
    else
        loginAttempts[serial].count = loginAttempts[serial].count + 1
    end
end

function generateToken(user, serial)
    return sha256(user .. serial .. getTickCount() .. tostring(math.random(11111, 99999)))
end

function logLoginAttempt(accountId, ip, serial, status)
    if not db then return end
    dbExec(db, "INSERT INTO account_login_logs (account_id, ip, serial, status) VALUES (?, ?, ?, ?)", accountId, ip, serial, status)
end

function isPlayerAdmin(player)
    if not isElement(player) then return false end
    local lvl = getElementData(player, "admin_level")
    return (lvl ~= nil and tonumber(lvl) and tonumber(lvl) >= 0)
end

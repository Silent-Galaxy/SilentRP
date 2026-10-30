local DB_HOST = "127.0.0.1"
local DB_USER = "root"
local DB_PASS = ""
local DB_NAME = "mta_db"
local DB_PORT = 3306

local db = dbConnect("mysql", string.format("dbname=%s;host=%s;port=%d;charset=utf8mb4", DB_NAME, DB_HOST, DB_PORT), DB_USER, DB_PASS, "autoreconnect=1")

function hexToRgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function rgbToHex(r, g, b)
    return string.format("#%.2X%.2X%.2X", r, g, b)
end

function applyFullTuning(veh, data)
    if not isElement(veh) or not data then return end
    
    if data.handling then
        for prop, val in pairs(data.handling) do
            if prop == "driveType" or prop == "engineType" then
                setVehicleHandling(veh, prop, tostring(val))
            else
                setVehicleHandling(veh, prop, tonumber(val))
            end
        end
    end

    if data.colors then
        local r1, g1, b1 = hexToRgb(data.colors.c1 or "#ffffff")
        local r2, g2, b2 = hexToRgb(data.colors.c2 or "#000000")
        local lr, lg, lb = hexToRgb(data.colors.light or "#ffffff")
        setVehicleColor(veh, r1, g1, b1, r2, g2, b2)
        setVehicleHeadLightColor(veh, lr, lg, lb)
    end

    if data.dynamicLighting then
        setElementData(veh, "v_anim_color", data.dynamicLighting, true)
    end

    if data.damageProof ~= nil then
        setVehicleDamageProof(veh, data.damageProof)
    end
end

-- بارگذاری تنظیمات بعد از روشن شدن ریسورس
addEventHandler("onResourceStart", resourceRoot, function()
    if not db then return end
    dbQuery(function(qh)
        local result = dbPoll(qh, 0)
        if result then
            for _, row in ipairs(result) do
                if row.custom_handling and row.custom_handling ~= "" then
                    local package = fromJSON(row.custom_handling)
                    if package then
                        for _, veh in ipairs(getElementsByType("vehicle")) do
                            if getElementData(veh, "dbid") == row.id or getElementData(veh, "id") == row.id then
                                applyFullTuning(veh, package)
                                break
                            end
                        end
                    end
                end
            end
        end
    end, db, "SELECT id, custom_handling FROM server_vehicles WHERE custom_handling IS NOT NULL")
end)

addEvent("mechanic:requestVehicleFullData", true)
addEventHandler("mechanic:requestVehicleFullData", root, function()
    local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    local currentHandling = getVehicleHandling(veh)
    local dbid = getElementData(veh, "dbid") or getElementData(veh, "id") or "Public"
    local accID = getElementData(player, "account:id") or 3

    local r1, g1, b1, r2, g2, b2 = getVehicleColor(veh, true)
    local lr, lg, lb = getVehicleHeadLightColor(veh)
    local colors = {
        c1 = rgbToHex(r1, g1, b1),
        c2 = rgbToHex(r2, g2, b2),
        light = rgbToHex(lr, lg, lb)
    }

    local payload = {
        handling = currentHandling,
        colors = colors,
        dynamicLighting = getElementData(veh, "v_anim_color") or { pattern = "none", target = "lights", speed = 1.0 },
        damageProof = isVehicleDamageProof(veh),
        dbid = dbid,
        profiles = {}
    }

    if db then
        dbQuery(function(qh)
            payload.profiles = dbPoll(qh, 0) or {}
            triggerClientEvent(player, "mechanic:sendFullDataToClient", player, payload)
        end, db, "SELECT id, profile_name, handling_data FROM vehicle_handling_profiles WHERE account_id = ? OR account_id IS NULL", accID)
    else
        triggerClientEvent(player, "mechanic:sendFullDataToClient", player, payload)
    end
end)

-- تعمیر و صاف کردن کامل خودرو
addEvent("mechanic:serverFixVehicle", true)
addEventHandler("mechanic:serverFixVehicle", root, function()
    local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    -- ۱. تعمیر صدمات بدنه و لاستیک‌ها
    fixVehicle(veh)
    setElementHealth(veh, 1000)

    -- ۲. صاف کردن و تراز کردن خودرو روی سطح زمین
    local _, _, rz = getElementRotation(veh)
    local x, y, z = getElementPosition(veh)
    setElementRotation(veh, 0, 0, rz)
    setElementPosition(veh, x, y, z + 0.4)
    setElementVelocity(veh, 0, 0, 0)
    setElementAngularVelocity(veh, 0, 0, 0)

    outputChatBox("#00FF88[مکانیکی] #FFFFFFخودروی شما کاملاً تعمیر و تراز شد!", player, 255, 255, 255, true)
end)

-- تغییر آنی رقص نور
addEvent("mechanic:serverSetDynamicLight", true)
addEventHandler("mechanic:serverSetDynamicLight", root, function(data)
    local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh or not data then return end
    setElementData(veh, "v_anim_color", data, true)
end)

addEvent("mechanic:serverToggleGodmode", true)
addEventHandler("mechanic:serverToggleGodmode", root, function(state)
    local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh then return end
    setVehicleDamageProof(veh, state)
    local msg = state and "#00FF88فعال" or "#FF4444غیرفعال"
    outputChatBox("#00E5FF[مکانیکی] #FFFFFFحالت ضد ضربه کامل: " .. msg, player, 255, 255, 255, true)
end)

addEvent("mechanic:serverSaveAll", true)
addEventHandler("mechanic:serverSaveAll", root, function(package)
    local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh or not package then return end

    applyFullTuning(veh, package)

    local dbid = getElementData(veh, "dbid") or getElementData(veh, "id")
    if db and dbid then
        local jsonHandling = toJSON(package)
        local r1, g1, b1 = hexToRgb(package.colors.c1)
        local r2, g2, b2 = hexToRgb(package.colors.c2)
        local color1Str = string.format("%d,%d,%d,255", r1, g1, b1)
        local color2Str = string.format("%d,%d,%d,255", r2, g2, b2)

        dbExec(db, "UPDATE server_vehicles SET custom_handling = ?, veh_color1 = ?, veh_color2 = ? WHERE id = ?", jsonHandling, color1Str, color2Str, dbid)
        outputChatBox("#00FF88[مکانیکی] #FFFFFFتمامی تغییرات و رقص نور خودرو ذخیره شد.", player, 255, 255, 255, true)
    else
        outputChatBox("#00FF88[مکانیکی] #FFFFFFتنظیمات روی خودرو اعمال شد.", player, 255, 255, 255, true)
    end
end)

addEvent("mechanic:serverResetStock", true)
addEventHandler("mechanic:serverResetStock", root, function()
    local player = client
    local veh = getPedOccupiedVehicle(player)
    if not veh then return end

    local model = getElementModel(veh)
    local original = getOriginalHandling(model)
    for prop, val in pairs(original) do
        setVehicleHandling(veh, prop, val)
    end
    setElementData(veh, "v_anim_color", nil, true)
    setVehicleDamageProof(veh, false)

    local dbid = getElementData(veh, "dbid") or getElementData(veh, "id")
    if db and dbid then
        dbExec(db, "UPDATE server_vehicles SET custom_handling = NULL WHERE id = ?", dbid)
    end
    outputChatBox("#00FF88[مکانیکی] #FFFFFFخودرو به فابریک کارخانه بازگشت.", player, 255, 255, 255, true)
end)

addEvent("mechanic:serverSaveProfile", true)
addEventHandler("mechanic:serverSaveProfile", root, function(name, handlingData)
    local player = client
    local accID = getElementData(player, "account:id") or 3
    if db then
        dbExec(db, "INSERT INTO vehicle_handling_profiles (account_id, profile_name, handling_data) VALUES (?, ?, ?)", accID, name, toJSON(handlingData))
        outputChatBox("#00FF88[مکانیکی] #FFFFFFپروفایل '" .. name .. "' ذخیره شد.", player, 255, 255, 255, true)
    end
end)
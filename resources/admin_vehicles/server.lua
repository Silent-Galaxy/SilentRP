local db = dbConnect("mysql", "dbname=mta_db;host=127.0.0.1;port=3306;charset=utf8mb4", "root", "")
local spawnedVehicles = {}
local adminMarkers = {}
local adminBlips = {}

if db then
    outputDebugString("[MySQL] دیتابیس با موفقیت متصل شد.", 3)
    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS `server_vehicles` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `model` INT NOT NULL,
            `x` FLOAT NOT NULL,
            `y` FLOAT NOT NULL,
            `z` FLOAT NOT NULL,
            `rx` FLOAT NOT NULL,
            `ry` FLOAT NOT NULL,
            `rz` FLOAT NOT NULL,
            `plate` VARCHAR(32) DEFAULT 'IRAN',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

function getAdminLevel(player)
    if not isElement(player) then return -1 end
    return tonumber(getElementData(player, "admin_level")) or -1
end

function loadPlayerAdmin(player)
    if not isElement(player) or not db then return end
    local accountName = ""
    local acc = getPlayerAccount(player)
    local isAclAdmin = false

    if not isGuestAccount(acc) then
        accountName = getAccountName(acc)
        if isObjectInACLGroup("user." .. accountName, aclGetGroup("Admin")) then
            isAclAdmin = true
        end
    else
        accountName = getPlayerName(player)
    end

    dbQuery(function(qh)
        local result = dbPoll(qh, -1)
        local lvl = -1
        if result and #result > 0 then
            lvl = tonumber(result[1].admin_level) or -1
        end

        if lvl < 0 and isAclAdmin then
            lvl = 0
            dbExec(db, "UPDATE `accounts` SET admin_level = 0 WHERE username = ?", accountName)
        end
        setElementData(player, "admin_level", lvl)
    end, db, "SELECT admin_level FROM `accounts` WHERE username = ? LIMIT 1", accountName)
end

addEventHandler("onPlayerLogin", root, function() loadPlayerAdmin(source) end)
addEventHandler("onPlayerJoin", root, function() loadPlayerAdmin(source) end)

-- بارگذاری هوشمند خودروها بدون اسپاون تکراری و بدون انفجار
function loadAllVehicles()
    if not db then return end
    dbQuery(function(qh)
        local result = dbPoll(qh, -1)
        if result then
            for _, row in ipairs(result) do
                local rowId = tonumber(row.id)
                local model = tonumber(row.model)
                local x, y, z = tonumber(row.x), tonumber(row.y), tonumber(row.z)
                local rx, ry, rz = tonumber(row.rx) or 0, tonumber(row.ry) or 0, tonumber(row.rz) or 0

                if model and x and y and z then
                    -- بررسی اینکه آیا خودرو از قبل توسط ریسورس دیگری اسپاون شده یا خیر
                    local existingVeh = false
                    for _, v in ipairs(getElementsByType("vehicle")) do
                        local vDbId = tonumber(getElementData(v, "dbid")) or tonumber(getElementData(v, "veh:id"))
                        if vDbId == rowId then
                            existingVeh = v
                            break
                        else
                            local vx, vy, vz = getElementPosition(v)
                            if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) < 2.0 then
                                existingVeh = v
                                break
                            end
                        end
                    end

                    if isElement(existingVeh) then
                        -- همگام‌سازی خودروی موجود بدون ساخت مجدد تا مانع ترکیدن شود
                        setElementData(existingVeh, "dbid", rowId)
                        setElementData(existingVeh, "veh:id", rowId)
                        setElementData(existingVeh, "isPermanent", true)
                        setElementData(existingVeh, "created_at", tostring(row.created_at))
                        setElementData(existingVeh, "updated_at", tostring(row.updated_at))
                        spawnedVehicles[rowId] = existingVeh
                    else
                        -- فقط در صورتی که هیچ نسخه‌ای وجود نداشت، خودرو ساخته می‌شود
                        local veh = createVehicle(model, x, y, z + 0.15, rx, ry, rz, row.plate or "IRAN")
                        if veh then
                            setElementDimension(veh, 0)
                            setElementInterior(veh, 0)
                            setElementData(veh, "dbid", rowId)
                            setElementData(veh, "veh:id", rowId)
                            setElementData(veh, "isPermanent", true)
                            setElementData(veh, "created_at", tostring(row.created_at))
                            setElementData(veh, "updated_at", tostring(row.updated_at))
                            setVehicleRespawnPosition(veh, x, y, z + 0.15, rx, ry, rz)
                            toggleVehicleRespawn(veh, true)
                            spawnedVehicles[rowId] = veh
                        end
                    end
                end
            end
            outputDebugString("[Vehicles] " .. #result .. " خودرو بررسی و بارگذاری شدند.", 3)
        end
    end, db, "SELECT * FROM `server_vehicles`")
end

addEventHandler("onResourceStart", resourceRoot, function()
    for _, p in ipairs(getElementsByType("player")) do loadPlayerAdmin(p) end
    loadAllVehicles()
end)

-- دریافت اطلاعات برای پنل همراه با بررسی خودروهای فعال
addEvent("requestSavedVehiclesList", true)
addEventHandler("requestSavedVehiclesList", root, function()
    local player = client
    if getAdminLevel(player) < 0 then return end

    dbQuery(function(qh)
        local result = dbPoll(qh, -1)
        local list = {}

        if result then
            for _, row in ipairs(result) do
                local rowId = tonumber(row.id)
                local veh = spawnedVehicles[rowId]

                -- اگر در متغیر لوکال نبود، در کل سرور بگرد تا نسخه تکراری ساخته نشود
                if not isElement(veh) then
                    for _, v in ipairs(getElementsByType("vehicle")) do
                        local vDbId = tonumber(getElementData(v, "dbid")) or tonumber(getElementData(v, "veh:id"))
                        if vDbId == rowId then
                            veh = v
                            break
                        end
                    end

                    if isElement(veh) then
                        spawnedVehicles[rowId] = veh
                    else
                        veh = createVehicle(row.model, row.x, row.y, row.z + 0.15, row.rx, row.ry, row.rz, row.plate or "IRAN")
                        if veh then
                            setElementDimension(veh, 0)
                            setElementInterior(veh, 0)
                            setElementData(veh, "dbid", rowId)
                            setElementData(veh, "veh:id", rowId)
                            setElementData(veh, "isPermanent", true)
                            setVehicleRespawnPosition(veh, row.x, row.y, row.z + 0.15, row.rx, row.ry, row.rz)
                            toggleVehicleRespawn(veh, true)
                            spawnedVehicles[rowId] = veh
                        end
                    end
                end

                table.insert(list, {
                    dbid = rowId,
                    model = tonumber(row.model),
                    created_at = tostring(row.created_at or "ثبت‌شده"),
                    updated_at = tostring(row.updated_at or "ثبت‌شده"),
                    x = math.floor(row.x),
                    y = math.floor(row.y),
                    z = math.floor(row.z)
                })
            end
        end

        local currentCar = false
        local occVeh = getPedOccupiedVehicle(player)
        if occVeh then
            local dbid = getElementData(occVeh, "dbid") or getElementData(occVeh, "veh:id")
            currentCar = {
                model = getElementModel(occVeh),
                dbid = dbid or false,
                isPermanent = getElementData(occVeh, "isPermanent") or false
            }
        end

        triggerClientEvent(player, "receiveSavedVehiclesList", resourceRoot, list, currentCar)
    end, db, "SELECT * FROM `server_vehicles` ORDER BY id DESC")
end)

-- ذخیره یا بروزرسانی مکان
function saveCurrentVehiclePosition(player)
    if getAdminLevel(player) < 0 then return end
    local veh = getPedOccupiedVehicle(player)
    if not veh then
        outputChatBox("#FF0000[خطا]#FFFFFF برای ثبت مکان باید داخل خودرو بنشینید!", player, 255, 255, 255, true)
        return
    end

    local x, y, z = getElementPosition(veh)
    local rx, ry, rz = getElementRotation(veh)
    local model = getElementModel(veh)
    local dbid = getElementData(veh, "dbid") or getElementData(veh, "veh:id")
    local timeNow = os.date("%Y-%m-%d %H:%M:%S")

    if dbid then
        dbExec(db, "UPDATE `server_vehicles` SET x=?, y=?, z=?, rx=?, ry=?, rz=? WHERE id=?", x, y, z, rx, ry, rz, dbid)
        setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
        setElementData(veh, "updated_at", timeNow)
        outputChatBox("#00FF00[بروزرسانی]#FFFFFF موقعیت پارک خودرو #"..dbid.." آپدیت شد.", player, 255, 255, 255, true)
    else
        dbQuery(function(qh)
            local _, _, insertId = dbPoll(qh, -1)
            if insertId then
                setElementData(veh, "dbid", insertId)
                setElementData(veh, "veh:id", insertId)
                setElementData(veh, "isPermanent", true)
                setElementData(veh, "created_at", timeNow)
                setElementData(veh, "updated_at", timeNow)
                setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
                toggleVehicleRespawn(veh, true)
                spawnedVehicles[insertId] = veh
                outputChatBox("#00FF00[ثبت دیتابیس]#FFFFFF این خودرو با موفقیت در دیتابیس ذخیره شد (ID: #"..insertId..")", player, 255, 255, 255, true)
            end
        end, db, "INSERT INTO `server_vehicles` (model, x, y, z, rx, ry, rz, plate) VALUES (?, ?, ?, ?, ?, ?, ?, 'IRAN')", model, x, y, z, rx, ry, rz)
    end
    triggerEvent("requestSavedVehiclesList", player)
end
addEvent("onAdminSaveCurrentOccupiedVehicle", true)
addEventHandler("onAdminSaveCurrentOccupiedVehicle", root, function() saveCurrentVehiclePosition(client) end)
addCommandHandler("park", saveCurrentVehiclePosition)

-- اسپاون خودروی جدید از تب دوم
addEvent("onAdminCreatePermanentVehicle", true)
addEventHandler("onAdminCreatePermanentVehicle", root, function(modelId)
    local player = client
    if getAdminLevel(player) < 0 then return end
    local x, y, z = getElementPosition(player)
    local _, _, rz = getElementRotation(player)
    local veh = createVehicle(modelId, x, y, z + 0.5, 0, 0, rz, "IRAN")
    if veh then
        warpPlayerIntoVehicle(player, veh)
        outputChatBox("#FFFF00[سیستم]#FFFFFF سوار ماشین شدید! آن را به جای دلخواه ببرید و دکمه #00FF00[ثبت موقعیت]#FFFFFF را بزنید.", player, 255, 255, 255, true)
        triggerEvent("requestSavedVehiclesList", player)
    end
end)

-- فلش نئونی روی سقف و علامت در نقشه
addEvent("onAdminToggleMarker", true)
addEventHandler("onAdminToggleMarker", root, function(dbid)
    local player = client
    if getAdminLevel(player) < 0 then return end
    if isElement(adminMarkers[player]) then destroyElement(adminMarkers[player]) end
    if isElement(adminBlips[player]) then destroyElement(adminBlips[player]) end

    local veh = spawnedVehicles[dbid]
    if isElement(veh) then
        local marker = createMarker(0, 0, 0, "arrow", 1.0, 0, 255, 255, 230, player)
        attachElements(marker, veh, 0, 0, 2.5)
        adminMarkers[player] = marker

        local blip = createBlipAttachedTo(veh, 0, 2, 0, 255, 255, 255, 0, 99999.0, player)
        adminBlips[player] = blip
        outputChatBox("#00FFCC[نشانگر]#FFFFFF فلش بالای سقف و علامت نقشه برای خودرو #"..dbid.." فعال شد.", player, 255, 255, 255, true)
    end
end)

-- ریست موقعیت به پارک
addEvent("onAdminResetVehiclePos", true)
addEventHandler("onAdminResetVehiclePos", root, function(dbid)
    local player = client
    if getAdminLevel(player) < 0 then return end
    local veh = spawnedVehicles[dbid]
    if isElement(veh) then
        respawnVehicle(veh)
        outputChatBox("#00FF00[ریست]#FFFFFF خودرو #"..dbid.." به مکان پارک اولیه بازگردانده شد.", player, 255, 255, 255, true)
    end
end)

-- تلپورت
addEvent("onAdminTeleportToVehicle", true)
addEventHandler("onAdminTeleportToVehicle", root, function(dbid)
    local player = client
    if getAdminLevel(player) < 0 then return end
    local veh = spawnedVehicles[dbid]
    if isElement(veh) then
        local x, y, z = getElementPosition(veh)
        setElementPosition(player, x, y, z + 2)
    end
end)

-- حذف از نقشه و MySQL
addEvent("onAdminDeleteVehicle", true)
addEventHandler("onAdminDeleteVehicle", root, function(dbid)
    local player = client
    if getAdminLevel(player) < 0 then return end
    local veh = spawnedVehicles[dbid]
    if isElement(veh) then
        destroyElement(veh)
    end
    spawnedVehicles[dbid] = nil
    dbExec(db, "DELETE FROM `server_vehicles` WHERE id = ?", dbid)
    if isElement(adminMarkers[player]) then destroyElement(adminMarkers[player]) end
    if isElement(adminBlips[player]) then destroyElement(adminBlips[player]) end
    outputChatBox("#FF4444[حذف]#FFFFFF خودرو #"..dbid.." کاملاً از دیتابیس پاک شد.", player, 255, 255, 255, true)
    triggerEvent("requestSavedVehiclesList", player)
end)
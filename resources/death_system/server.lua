local db = nil
local knockTimers, carrierMap = {}, {}

-- مختصات کادر آبی بیمارستان و محل قرارگیری ویلچر
local HOSP_BLUE_ZONE = { x = 1178.5, y = -1324.0, z = 14.1 }
local WHEELCHAIR_POS = { x = 1184.2, y = -1314.5, z = 13.6, rot = 270 }

-- کادر آبی ورودی بیمارستان (Blue Box)
local blueMarker = createMarker(HOSP_BLUE_ZONE.x, HOSP_BLUE_ZONE.y, HOSP_BLUE_ZONE.z - 1, "cylinder", 5.5, 0, 120, 255, 180)

addEventHandler("onResourceStart", resourceRoot, function()
    db = dbConnect("mysql", "dbname=mta_db;host=127.0.0.1;charset=utf8mb4", "root", "")
end)

-- ورود به کادر آبی (سواره با آمبولانس یا پیاده در حال حمل بیمار)
addEventHandler("onMarkerHit", blueMarker, function(hitElement)
    local patient = nil
    local medic = nil
    local veh = nil

    if getElementType(hitElement) == "vehicle" and getElementModel(hitElement) == 416 then
        veh = hitElement
        medic = getVehicleOccupant(veh, 0)
        -- جستجوی بیماری که داخل آمبولانس است
        for _, el in ipairs(getElementsByType("player")) do
            if getElementData(el, "inAmbulance") == veh then patient = el; break end
        end
        if not patient then
            for _, el in ipairs(getElementsByType("ped")) do
                if getElementData(el, "inAmbulance") == veh then patient = el; break end
            end
        end
    elseif getElementType(hitElement) == "player" and carrierMap[hitElement] then
        medic = hitElement
        patient = carrierMap[medic]
        detachElements(patient, medic)
        setPedAnimation(medic, nil)
        carrierMap[medic] = nil
    end

    if patient then
        startWheelchairProcess(patient, medic, veh)
    end
end)

-- پروسه ۱۵ ثانیه‌ای ویلچر و درمان
function startWheelchairProcess(patient, medic, veh)
    -- قطع اتصال قبلی
    if veh then
        detachElements(patient, veh)
        setElementData(patient, "inAmbulance", nil)
        setElementData(veh, "ambStatus", "idle")
        setVehicleSirensOn(veh, false)
    end

    setElementCollisionsEnabled(patient, false)

    -- ۱. ساخت آبجکت ویلچر (Model: 1369)
    local wc = createObject(1369, WHEELCHAIR_POS.x, WHEELCHAIR_POS.y, WHEELCHAIR_POS.z - 0.2, 0, 0, WHEELCHAIR_POS.rot)
    setElementCollisionsEnabled(wc, false)

    -- ۲. نشاندن بیمار روی ویلچر با لباس بیمارستانی
    setElementData(patient, "prevSkin", getElementModel(patient))
    setElementModel(patient, 252)
    attachElements(patient, wc, 0, 0.05, 0.55)
    setPedAnimation(patient, "PED", "SEAT_idle", -1, true, false, false, false)
    setElementFrozen(patient, true)

    -- شروع تایمر ۱۵ ثانیه در کلاینت برای نمایش روی صفحه و بالای ویلچر
    setElementData(patient, "wheelchairTimer", 15)

    if medic then
        triggerClientEvent(medic, "client:clearGPS", medic)
        triggerClientEvent(medic, "client:setMedicGuide", medic, "بیمار روی ویلچر مستقر شد. ۱۵ ثانیه تا ترخیص و مداوا...")
    end

    -- تایمر هر ثانیه برای شمارش معکوس
    local countdownTimer = setTimer(function()
        if isElement(patient) then
            local sec = (getElementData(patient, "wheelchairTimer") or 15) - 1
            if sec > 0 then
                setElementData(patient, "wheelchairTimer", sec)
            end
        end
    end, 1000, 14)

    -- بعد از ۱۵ ثانیه: بلند شدن و پایان درمان
    setTimer(function()
        if isTimer(countdownTimer) then killTimer(countdownTimer) end
        if isElement(patient) then
            setElementData(patient, "wheelchairTimer", nil)
            detachElements(patient, wc)
            if isElement(wc) then destroyElement(wc) end

            setElementCollisionsEnabled(patient, true)
            setElementPosition(patient, WHEELCHAIR_POS.x, WHEELCHAIR_POS.y, WHEELCHAIR_POS.z + 0.3)
            
            -- انیمیشن بلند شدن
            setPedAnimation(patient, "ped", "getup_front", -1, false, false, false, false)

            setTimer(function()
                if isElement(patient) then
                    setPedAnimation(patient, false)
                    setElementFrozen(patient, false)
                    toggleAllControls(patient, true)
                    setElementHealth(patient, 100)

                    -- پس دادن اسکین اولیه
                    local origSkin = getElementData(patient, "prevSkin")
                    if origSkin then setElementModel(patient, origSkin) end

                    cleanUpPatient(patient)
                end
            end, 1800, 1)

            -- ثبت در دیتابیس
            if db then
                local pName = getElementData(patient, "isBot") and getElementData(patient, "botName") or getPlayerName(patient)
                local mName = medic and getPlayerName(medic) or "پرسنل شیفت"
                dbExec(db, "INSERT INTO patient_stats (patient_name, visits_count) VALUES (?, 1) ON DUPLICATE KEY UPDATE visits_count = visits_count + 1", pName)
                if medic then
                    dbExec(db, "INSERT INTO medic_stats (medic_name, rescues_count) VALUES (?, 1) ON DUPLICATE KEY UPDATE rescues_count = rescues_count + 1", mName)
                end
                dbExec(db, "INSERT INTO medical_records (player_name, medic_name, status) VALUES (?, ?, 'treated')", pName, mName)
            end

            if medic then
                triggerClientEvent(medic, "client:setMedicGuide", medic, "بیمار پس از مراقبت اولیه ترخیص شد و لباس خود را تحویل گرفت.")
            end
            if not getElementData(patient, "isBot") then
                outputChatBox("[اورژانس] حال شما کاملاً بهبود یافت و ترخیص شدید.", patient, 0, 255, 0)
            end
        end
    end, 15000, 1)
end

-- تعامل دکمه‌ای هوشمند با کلید E
addEvent("server:interactKey", true)
addEventHandler("server:interactKey", root, function()
    local p = client
    if not getElementData(p, "medicDuty") then
        return triggerClientEvent(p, "client:setMedicGuide", p, "شما در شیفت نیستید! ابتدا /duty بزنید.")
    end

    local px, py, pz = getElementPosition(p)

    -- ۱. اگر بیمار روی دوش است و نزدیک آمبولانس هستیم -> سوار کردن
    if carrierMap[p] then
        local victim = carrierMap[p]
        local amb = nil
        for _, veh in ipairs(getElementsByType("vehicle")) do
            if getElementModel(veh) == 416 and getDistanceBetweenPoints3D(px, py, pz, getElementPosition(veh)) <= 5.0 then
                amb = veh; break
            end
        end

        if amb then
            detachElements(victim, p)
            setPedAnimation(p, nil)
            carrierMap[p] = nil

            attachElements(victim, amb, 0, -1.2, 0.35, 0, 0, 90)
            setElementData(victim, "inAmbulance", amb)
            setElementData(amb, "ambStatus", "transporting")
            setVehicleSirensOn(amb, true)

            triggerClientEvent(p, "client:routeToHospital", p, HOSP_BLUE_ZONE.x, HOSP_BLUE_ZONE.y, HOSP_BLUE_ZONE.z)
            triggerClientEvent(p, "client:setMedicGuide", p, "بیمار داخل خودرو قرار گرفت؛ به کادر آبی بیمارستان بروید.")
            return
        else
            -- زمین گذاشتن
            detachElements(victim, p)
            setElementCollisionsEnabled(victim, true)
            carrierMap[p] = nil
            setPedAnimation(p, nil)
            setPedAnimation(victim, "ped", "KO_shot_stom", -1, false, false, false, true)
            triggerClientEvent(p, "client:setMedicGuide", p, "مصدوم را زمین گذاشتید.")
            return
        end
    end

    -- ۲. برداشتن مصدوم روی دوش
    local targets = {}
    for _, el in ipairs(getElementsByType("player")) do table.insert(targets, el) end
    for _, el in ipairs(getElementsByType("ped")) do table.insert(targets, el) end

    for _, v in ipairs(targets) do
        if v ~= p and getElementData(v, "isKnocked") and not getElementData(v, "inAmbulance") and not getElementData(v, "wheelchairTimer") then
            local vx, vy, vz = getElementPosition(v)
            if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= 3.0 then
                setElementCollisionsEnabled(v, false)
                attachElements(v, p, 0.25, 0.2, 0.65, 0, 90, 0)
                setPedAnimation(v, "ped", "FLOOR_hit", -1, false, false, false, true)
                setPedAnimation(p, "CARRY", "crry_prtial", 0, true, false, true, true)
                carrierMap[p] = v
                triggerClientEvent(p, "client:setMedicGuide", p, "مصدوم روی دوش شماست؛ به پشت آمبولانس رفته و مجدد E بزنید.")
                return
            end
        end
    end
end)

-- اعزام تبلت
addEvent("server:dispatchToVictim", true)
addEventHandler("server:dispatchToVictim", root, function(target)
    local medic = client
    local amb = getPedOccupiedVehicle(medic)
    if isElement(amb) then
        setElementData(amb, "ambStatus", "responding")
        setVehicleSirensOn(amb, true)
    end
    setElementData(target, "callAccepted", true)
    triggerClientEvent(medic, "client:setMedicGuide", medic, "در مسیر مصدوم هستید؛ با رسیدن به محل کلید E را بزنید.")
end)

-- هوک مرگ پلیر واقعی
addEventHandler("onPlayerWasted", root, function()
    local p = source
    setTimer(function()
        if isElement(p) then
            local x, y, z = getElementPosition(p)
            spawnPlayer(p, x, y, z, 0, getElementModel(p), 0, 0)
            setElementHealth(p, 10)
            setElementData(p, "isKnocked", true)
            setElementData(p, "callAccepted", false)
            setElementFrozen(p, true)
            setPedAnimation(p, "ped", "KO_shot_stom", -1, false, false, false, true)

            triggerClientEvent(p, "client:startKnockTimer", p, 180, false)
            knockTimers[p] = setTimer(autoReviveTimeout, 180000, 1, p)
        end
    end, 200, 1)
end)

function autoReviveTimeout(p)
    if not isElement(p) or not getElementData(p, "isKnocked") then return end
    startWheelchairProcess(p, nil, nil)
end

function cleanUpPatient(p)
    if isTimer(knockTimers[p]) then killTimer(knockTimers[p]) end
    knockTimers[p] = nil
    setElementData(p, "isKnocked", false)
    setElementData(p, "callAccepted", false)
    if not getElementData(p, "isBot") then triggerClientEvent(p, "client:stopKnockTimer", p) end
end

-- دستورات راه‌اندازی و تست
addCommandHandler("setmedic", function(p)
    setElementData(p, "isMedic", true)
    setElementData(p, "medicDuty", true)
    setElementModel(p, 274)
    outputChatBox("[سیستم] شما در شیفت اورژانس قرار گرفتید.", p, 0, 255, 0)
end)

addCommandHandler("duty", function(p)
    local d = not getElementData(p, "medicDuty")
    setElementData(p, "medicDuty", d)
    if d then setElementModel(p, 274) else setElementModel(p, 0) end
end)

addCommandHandler("spawnamb", function(p)
    local x, y, z = getElementPosition(p)
    local v = createVehicle(416, x + 2, y + 2, z)
    setElementData(v, "ambStatus", "idle")
end)

addCommandHandler("spawnbot", function(p)
    local x, y, z = getElementPosition(p)
    local b = createPed(188, x + 1.5, y + 1.5, z)
    setElementData(b, "isBot", true)
    setElementData(b, "botName", "مصدوم تستی")
    setElementData(b, "isKnocked", true)
    setElementFrozen(b, true)
    setPedAnimation(b, "ped", "KO_shot_stom", -1, false, false, false, true)
    outputChatBox("[تست] مصدوم ایجاد شد. کلید E را برای برداشتن بزنید.", p, 0, 255, 0)
end)
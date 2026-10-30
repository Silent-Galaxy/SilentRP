local screenW, screenH = guiGetScreenSize()

local isFlying = false
local targetElement = nil
local baseSpeed = 1.2
local minSpeed = 0.1
local maxSpeed = 15.0

-- محاسبه بردارهای دید دوربین برای حرکت نرم
local function getCameraLookVectors()
    local cx, cy, cz, lx, ly, lz = getCameraMatrix()
    local fx = lx - cx
    local fy = ly - cy
    local fz = lz - cz
    local len = math.sqrt(fx * fx + fy * fy + fz * fz)
    if len == 0 then len = 1 end
    fx, fy, fz = fx / len, fy / len, fz / len

    -- بردار عمود بر افق جهت حرکت به راست و چپ
    local rx = fy
    local ry = -fx
    local rlen = math.sqrt(rx * rx + ry * ry)
    if rlen == 0 then rlen = 1 end
    rx, ry = rx / rlen, ry / rlen

    return cx, cy, cz, fx, fy, fz, rx, ry
end

-- متوقف کردن پرواز و بازگردانی فیزیک طبیعی
local function stopFlying()
    if not isFlying then return end
    isFlying = false

    if isElement(targetElement) then
        setElementCollisionsEnabled(targetElement, true)
        setElementFrozen(targetElement, false)
        setElementVelocity(targetElement, 0, 0, 0)
        setElementAlpha(targetElement, 255)
    end
    targetElement = nil
    removeEventHandler("onClientPreRender", root, updateFlightMovement)
    removeEventHandler("onClientRender", root, renderFlightHUD)
    outputChatBox("#00FF88[پرواز ادمین] #FFFFFFحالت پرواز غیرفعال شد.", 255, 255, 255, true)
end

-- شروع پرواز
local function startFlying()
    local veh = getPedOccupiedVehicle(localPlayer)
    targetElement = veh or localPlayer

    isFlying = true
    setElementCollisionsEnabled(targetElement, false)
    setElementFrozen(targetElement, true)
    setElementVelocity(targetElement, 0, 0, 0)
    
    -- کمی شفاف شدن المنت برای حس شبح بودن
    setElementAlpha(targetElement, 200)

    addEventHandler("onClientPreRender", root, updateFlightMovement)
    addEventHandler("onClientRender", root, renderFlightHUD)
    outputChatBox("#00FF88[پرواز ادمین] #FFFFFFحالت پرواز فعال شد! (F12 برای خروج)", 255, 255, 255, true)
end

-- حلقه فیزیک و جابجایی المنت (PreRender)
function updateFlightMovement(dt)
    if not isFlying or not isElement(targetElement) then return end

    -- ضریب سرعت
    local currentSpeed = baseSpeed
    if getKeyState("lshift") or getKeyState("rshift") then
        currentSpeed = currentSpeed * 4.0 -- شتاب فوق‌العاده
    elseif getKeyState("lalt") or getKeyState("ralt") then
        currentSpeed = currentSpeed * 0.2 -- حرکت بسیار آهسته
    end

    local cx, cy, cz, fx, fy, fz, rx, ry = getCameraLookVectors()
    local dx, dy, dz = 0, 0, 0

    -- کلیدهای جهت جلو/عقب
    if getKeyState("w") then
        dx = dx + fx
        dy = dy + fy
        dz = dz + fz
    end
    if getKeyState("s") then
        dx = dx - fx
        dy = dy - fy
        dz = dz - fz
    end

    -- کلیدهای چپ و راست
    if getKeyState("d") then
        dx = dx + rx
        dy = dy + ry
    end
    if getKeyState("a") then
        dx = dx - rx
        dy = dy - ry
    end

    -- بالا و پایین رفتن مستقیم
    if getKeyState("space") then
        dz = dz + 1
    end
    if getKeyState("lctrl") or getKeyState("c") then
        dz = dz - 1
    end

    -- نرمال‌سازی بردار جهت حرکت همگن
    local mag = math.sqrt(dx * dx + dy * dy + dz * dz)
    if mag > 0 then
        local factor = (currentSpeed * (dt / 16.66)) / mag
        dx = dx * factor
        dy = dy * factor
        dz = dz * factor

        local px, py, pz = getElementPosition(targetElement)
        setElementPosition(targetElement, px + dx, py + dy, pz + dz)

        -- تنظیم جهت المنت به سمت دید دوربین
        local rotZ = -math.deg(math.atan2(fx, fy))
        if getElementType(targetElement) == "player" then
            setElementRotation(targetElement, 0, 0, rotZ, "default", true)
        else
            setElementRotation(targetElement, 0, 0, rotZ)
        end
    end
end

-- هاد و راهنمای روی صفحه
function renderFlightHUD()
    if not isFlying then return end

    local hudText = string.format("⚡ حالت پرواز ادمین فعال است\nسرعت فعلی: %.1fx\n[W/A/S/D] حرکت | [Space/Ctrl] ارتفاع\n[Shift] توربو | [Alt] اسلوموشن\n[اسکرول موس] تنظیم سرعت | [F12] خروج", baseSpeed)

    -- پس‌زمینه نیمه‌شفاف کادر
    dxDrawRectangle(20, screenH - 140, 260, 110, tocolor(15, 20, 28, 200), true)
    dxDrawRectangle(20, screenH - 140, 4, 110, tocolor(0, 229, 255, 255), true)
    
    -- متن راهنما
    dxDrawText(hudText, 32, screenH - 135, 270, screenH - 35, tocolor(240, 245, 255, 255), 1.0, "default-bold", "right", "top", false, false, true, true)
end

-- کم و زیاد کردن سرعت پایه با چرخاندن اسکرول موس
bindKey("mouse_wheel_up", "down", function()
    if isFlying then
        baseSpeed = math.min(maxSpeed, baseSpeed + 0.2)
    end
end)

bindKey("mouse_wheel_down", "down", function()
    if isFlying then
        baseSpeed = math.max(minSpeed, baseSpeed - 0.2)
    end
end)

-- هندلرهای رویداد
addEvent("adminfly:toggleState", true)
addEventHandler("adminfly:toggleState", root, function()
    if isFlying then
        stopFlying()
    else
        startFlying()
    end
end)

-- بایند دکمه F12 و کامند
local function triggerFly()
    triggerServerEvent("adminfly:requestToggle", resourceRoot)
end
bindKey("F12", "down", triggerFly)
addCommandHandler("fly", triggerFly)

-- لغو پرواز در صورت کشته شدن بازیکن
addEventHandler("onClientPlayerWasted", localPlayer, function()
    if isFlying then
        stopFlying()
    end
end)
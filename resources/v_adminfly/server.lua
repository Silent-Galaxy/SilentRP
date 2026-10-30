-- آیا برای تست همه بتوانند پرواز کنند؟ (اگر true باشد نیازی به رنک ادمین نیست)
local FREE_ACCESS_FOR_TEST = false

-- بررسی ادمین بودن
function isPlayerAdmin(player)
    if FREE_ACCESS_FOR_TEST then return true end
    
    -- بررسی سطح ادمینی از دیتابیس یا المنت دیتا
    local adminLevel = getElementData(player, "admin_level")
    if adminLevel and tonumber(adminLevel) >= 0 then
        return true
    end

    -- بررسی ادمین از ACL پیش‌فرض MTA
    local accName = getAccountName(getPlayerAccount(player))
    if isObjectInACLGroup("user." .. accName, aclGetGroup("Admin")) or
       isObjectInACLGroup("user." .. accName, aclGetGroup("SuperAdmin")) or
       isObjectInACLGroup("user." .. accName, aclGetGroup("Console")) then
        return true
    end

    return false
end

-- دریافت درخواست پرواز از کلاینت
addEvent("adminfly:requestToggle", true)
addEventHandler("adminfly:requestToggle", root, function()
    local player = client
    if isPlayerAdmin(player) then
        triggerClientEvent(player, "adminfly:toggleState", player)
    else
        outputChatBox("#FF4444[سیستم] #FFFFFFشما دسترسی ادمین برای استفاده از پرواز (F12) را ندارید!", player, 255, 255, 255, true)
    end
end)
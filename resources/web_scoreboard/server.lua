local MAYOR_SERIAL = "C8779B48243D9EB1BDB4DED901100C43"
local MAYOR_ACCOUNT = "SilentGalaxy"

addEvent("scoreboard:requestSync", true)
addEventHandler("scoreboard:requestSync", root, function()
    local clientPlayer = client
    if not clientPlayer then return end

    local allPlayers = getElementsByType("player")
    local botCount = #getElementsByType("ped") - #allPlayers
    if botCount < 0 then botCount = 0 end

    local mayorOnline = false
    local fPoliceDuty, fMedicDuty, fMechDuty = 0, 0, 0
    local staffCount = 0
    local playersList = {}

    for i = 1, #allPlayers do
        local p = allPlayers[i]
        local serial = getPlayerSerial(p)
        local rawName = getPlayerName(p):gsub("#%x%x%x%x%x%x", "")
        local isMayor = (serial == MAYOR_SERIAL or rawName:lower() == MAYOR_ACCOUNT:lower())
        
        if isMayor then 
            mayorOnline = true 
        end

        local id = getElementData(p, "playerid") or getElementData(p, "id") or i
        local faction = tostring(getElementData(p, "faction") or getElementData(p, "job") or "شهروند")
        local isDuty = (getElementData(p, "onduty") == true or getElementData(p, "duty") == 1 or getElementData(p, "duty") == true or isMayor)
        local isStaff = getElementData(p, "admin") or getElementData(p, "staff") or 0

        local facLower = faction:lower()
        if (facLower:find("police") or facLower:find("lspd") or facLower:find("پلیس")) and isDuty then
            fPoliceDuty = fPoliceDuty + 1
        elseif (facLower:find("medic") or facLower:find("ems") or facLower:find("اورژانس")) and isDuty then
            fMedicDuty = fMedicDuty + 1
        elseif (facLower:find("mech") or facLower:find("مکانیک")) and isDuty then
            fMechDuty = fMechDuty + 1
        end

        if tonumber(isStaff) and tonumber(isStaff) > 0 then
            staffCount = staffCount + 1
        end

        table.insert(playersList, {
            id = id,
            name = rawName,
            role = faction,
            isDuty = isDuty,
            ping = getPlayerPing(p),
            isMayor = isMayor
        })
    end

    -- شهردار در بالاترین ردیف
    table.sort(playersList, function(a, b)
        if a.isMayor and not b.isMayor then return true end
        if b.isMayor and not a.isMayor then return false end
        return tonumber(a.id or 0) < tonumber(b.id or 0)
    end)

    local payload = {
        mayorName = MAYOR_ACCOUNT,
        mayorOnline = mayorOnline,
        total = #allPlayers,
        max = getMaxPlayers(),
        police = fPoliceDuty,
        medic = fMedicDuty,
        mech = fMechDuty,
        staff = staffCount,
        bots = botCount,
        players = playersList
    }

    triggerClientEvent(clientPlayer, "scoreboard:receiveSync", clientPlayer, payload)
end)
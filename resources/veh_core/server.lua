-- Engine
addEvent("veh:toggleEngine", true)
addEventHandler("veh:toggleEngine", root, function(veh)
    if not isElement(veh) or getVehicleOccupant(veh, 0) ~= client then return end
    setVehicleEngineState(veh, not getVehicleEngineState(veh))
end)

-- Lights
addEvent("veh:toggleLights", true)
addEventHandler("veh:toggleLights", root, function(veh)
    if not isElement(veh) or getVehicleOccupant(veh, 0) ~= client then return end
    local state = getVehicleOverrideLights(veh)
    setVehicleOverrideLights(veh, state == 2 and 1 or 2)
end)

-- Handbrake State
addEvent("veh:setHandbrake", true)
addEventHandler("veh:setHandbrake", root, function(veh, state)
    if not isElement(veh) or getVehicleOccupant(veh, 0) ~= client then return end
    setElementData(veh, "handbrake", state, true)
    if not state then
        setElementFrozen(veh, false)
    end
end)

addEvent("veh:freeze", true)
addEventHandler("veh:freeze", root, function(veh, freeze)
    if isElement(veh) and getElementData(veh, "handbrake") then
        setElementFrozen(veh, freeze)
    end
end)

-- Single Door
addEvent("veh:toggleDoor", true)
addEventHandler("veh:toggleDoor", root, function(veh, doorIndex)
    if not isElement(veh) or getVehicleOccupant(veh, 0) ~= client then return end
    local ratio = getVehicleDoorOpenRatio(veh, doorIndex)
    setVehicleDoorOpenRatio(veh, doorIndex, ratio > 0.1 and 0 or 1, 350)
end)

-- Single Unified Toggle for All Doors
addEvent("veh:toggleAllDoors", true)
addEventHandler("veh:toggleAllDoors", root, function(veh)
    if not isElement(veh) or getVehicleOccupant(veh, 0) ~= client then return end
    local anyOpen = false
    for d = 0, 5 do
        if getVehicleDoorOpenRatio(veh, d) > 0.1 then
            anyOpen = true
            break
        end
    end
    local target = anyOpen and 0 or 1
    for d = 0, 5 do
        setVehicleDoorOpenRatio(veh, d, target, 350)
    end
end)

-- Indicators
addEvent("veh:setIndicator", true)
addEventHandler("veh:setIndicator", root, function(veh, indType)
    if not isElement(veh) then return end
    local current = getElementData(veh, "indicator") or "off"
    local newState = (current == indType) and "off" or indType
    setElementData(veh, "indicator", newState, true)
end)

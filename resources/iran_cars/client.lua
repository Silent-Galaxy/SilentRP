-- لیست ماشین‌های موجود در عکس به همراه آیدی اختصاصی هرکدام در بازی
local cars = {
    { id = 445, name = "admiral" },
    { id = 416, name = "ambulan" },
    { id = 496, name = "blistac" },
    { id = 422, name = "bobcat" },
    { id = 575, name = "buccanee" },
    { id = 431, name = "bus" },
    { id = 438, name = "cabbie" },
    { id = 589, name = "club" },
    { id = 437, name = "coach" },
    { id = 599, name = "copcarru" },
    { id = 598, name = "copcarvg" },
    { id = 578, name = "dft30" },
    { id = 419, name = "esperant" },
    { id = 492, name = "greenwoo" },
    { id = 400, name = "landstal" },
    { id = 517, name = "majestic" },
    { id = 522, name = "nrg500" },
    { id = 467, name = "oceanic" },
    { id = 461, name = "pcj600" },
    { id = 600, name = "picador" },
    { id = 436, name = "previon" },
    { id = 547, name = "primo" },
    { id = 405, name = "sentinel" },
    { id = 561, name = "stratum" },
    { id = 506, name = "supergt" },
    { id = 420, name = "taxi" },
    { id = 531, name = "tractor" },
}

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, car in ipairs(cars) do
        -- بارگذاری تکسچر (TXD)
        local txd = engineLoadTXD(car.name .. ".txd")
        if txd then
            engineImportTXD(txd, car.id)
        end

        -- بارگذاری مدل سه‌بعدی (DFF)
        local dff = engineLoadDFF(car.name .. ".dff")
        if dff then
            engineReplaceModel(dff, car.id)
        end
    end
end)
CAR = ac.getCar(0)
SIM = ac.getSim()

IsFuelLimited = false
FuelLimit = nil
IsExtraARainLight = false

CarList = {
    { carID = "rss_gtm_aero_v10_evo2", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = true},
    { carID = "rss_gtm_akuro_v6_evo2", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = true},
    { carID = "rss_gtm_lanzo_v10_evo2", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = true},
    { carID = "rss_gtm_mercer_v8", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = true},
    { carID = "rss_gtm_lux_v8", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = true},
    { carID = "gt4_audi_r8", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = false},
    { carID = "gt4_toyota_supra", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = false},
    { carID = "gt4_camaro", newFuelLimit = false, maxFuelValue = 0, isExtraARainLight = false},
}

for _, data in ipairs(CarList) do
    if data.carID == ac.getCarID(0) then
        if data.newFuelLimit then
            IsFuelLimited = true
            FuelLimit = data.maxFuelValue
        else
            IsFuelLimited = false
        end
        if data.isExtraARainLight then
            IsExtraARainLight = true
        end
    end
end

function script.update(dt)
    if IsFuelLimited then
        if CAR.isInPitlane or not SIM.isSessionStarted then
            if CAR.fuel > FuelLimit then
                physics.setCarFuel(0,FuelLimit)
                --ac.log("Excessive amount of fuel detected. *slurp* I drank it")
            end
        end
    end
    -- quick edit: instead of rain light, this code enables endu lights (extra D option) in gtm cars when player uses headlights
    if IsExtraARainLight then
            if CAR.headlightsActive then
            ac.setExtraSwitch(3,true)
        else
            ac.setExtraSwitch(3,false)
        end
    end
end

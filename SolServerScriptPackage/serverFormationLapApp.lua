-- Maxine's Formation Lap & Rolling Start UI
-- ver 0.9
-- Current features:
-- - reads events sent by a client app responsible for starting the race and prints UI based on that
-- - synced with the server, works separately for predefined car classes (need to be synced with database of the client app) - CarClasses{}

CarClasses = {
    { carID = "rss_gtm_aero_v10_evo2", carClass = "gt3", className = "GT3" },
    { carID = "rss_gtm_akuro_v6_evo2", carClass = "gt3", className = "GT3" },
    { carID = "rss_gtm_lanzo_v10_evo2", carClass = "gt3", className = "GT3" },
    { carID = "rss_gtm_mercer_v8", carClass = "gt3", className = "GT3" },
    { carID = "rss_gtm_lux_v8", carClass = "gt3", className = "GT3" },
    { carID = "gt4_audi_r8", carClass = "gt4", className = "GT4" },
    { carID = "gt4_toyota_supra", carClass = "gt4", className = "GT4"},
    { carID = "gt4_camaro", carClass = "gt4", className = "GT4" },
}

local className = ""

function GetCarClass(carID)
    for _, data in ipairs(CarClasses) do
        if carID == data.carID then
            className = data.className
            return data.carClass
        end
    end
end
 
CAR = ac.getCar(0)
SIM = ac.getSim()

local CarClass = "ignore"
CarID = ac.getCarID(0)
CarClass = GetCarClass(CarID)

-- UI CORDS --

SCREENSIZE = vec2(SIM.windowWidth,SIM.windowHeight)
CENTEROFFSET = 111 -- How many pixels sides of the app go off center
APPTOP = 300 -- Y coordinate of app's top side 
APPBOTTOM = 460 -- Y coordinate of app's bottom side
ICONSIZE = 24 -- Default icon scale in px

FL_OFFSET = 200
FL_APPTOP = 220

--- COLORS ---

GRAY = rgbm(0,0,0,0.7)
LIGHTGRAY = rgbm(0.3,0.3,0.3,0.7)
GRAYTRANS = rgbm(0,0,0,0.2)


----------------------------------------------
------------- MESSAGE RECEIVER ---------------
----------------------------------------------

local startTime = 0
local isFormationLap = false
local isStandBy = false
local isRaceStarted = false
local lightsFadeout = 250
local falseStartChecker = false
local driverInfo = "FORMATION LAP"

local messageReceiver = ac.OnlineEvent({
    message = ac.StructItem.string(50),
    serverTime = ac.StructItem.float(),
    delay = ac.StructItem.float(),
    class = ac.StructItem.string(6)
}, function (sender,data)
    ac.log("received for "..data.class)
    if CarClass == data.class then

        if data.message == "mx_InitFormation" then
            ac.log("mx_InitFormation "..data.class)
            driverInfo = "FORMATION LAP"
            isFormationLap = true
        end

        if data.message == "mx_FormationLights" then
            ac.log("mx_FormationLights "..data.class)
            isStandBy = true
            startTime = -1
        end

        if data.message == "mx_FormationRaceStart" then
            ac.log("mx_FormationRaceStart "..data.class)
            isStandBy = true
            startTime = data.serverTime + (data.delay * 1000)
        end

        if data.message == "mx_kill" then
            ac.log("mx_kill "..data.class)
            isFormationLap = false
            isStandBy = false
            isRaceStarted = false
            lightsFadeout = 500
            startTime = 0
        end
    end
end
,ac.SharedNamespace.ServerScript,false)

function UI_FormationLap()
    ui.drawRectFilled(vec2(SCREENSIZE.x/2-FL_OFFSET,FL_APPTOP),vec2(SCREENSIZE.x/2+FL_OFFSET,FL_APPTOP+50),GRAYTRANS)
    ui.drawRectFilled(vec2(SCREENSIZE.x/2-FL_OFFSET,FL_APPTOP),vec2(SCREENSIZE.x/2-FL_OFFSET+50,FL_APPTOP+50),GRAY)
    ui.drawRectFilled(vec2(SCREENSIZE.x/2+FL_OFFSET-50,FL_APPTOP),vec2(SCREENSIZE.x/2+FL_OFFSET,FL_APPTOP+50),GRAY)
    ui.pushDWriteFont(ui.DWriteFont("Segoi UI"):weight(ui.DWriteFont.Weight.Bold))
    ui.setCursor(vec2(SCREENSIZE.x/2-150,FL_APPTOP+12))
    ui.dwriteTextAligned(driverInfo,26,ui.Alignment.Center,ui.Alignment.Center,vec2(300,24),false,rgbm.colors.white)
    ui.setCursor(vec2(SCREENSIZE.x/2-200,FL_APPTOP+12))
    ui.dwriteTextAligned(className,20,ui.Alignment.Center,ui.Alignment.Center,vec2(50,24),false,rgbm.colors.white)
    ui.drawCircle(vec2(SCREENSIZE.x/2+FL_OFFSET-25,FL_APPTOP+25),20,rgbm.colors.red,32,4)
    ui.setCursor(vec2(SCREENSIZE.x/2+150,FL_APPTOP+12))
    ui.dwriteTextAligned("OT",20,ui.Alignment.Center,ui.Alignment.Center,vec2(50,24),false,rgbm.colors.white)
    
end

function UI_StartingLights()

    local rgbmLightGreen = rgbm.colors.black
    local rgbmLightRed = rgbm.colors.black

    if startTime < SIM.currentServerTime then
        if not falseStartChecker then
            if CAR.speedKmh > 81 then
                ac.log("I've been naughty")
            end
            falseStartChecker = true
        end
        rgbmLightRed = rgbm.colors.black
        rgbmLightGreen = rgbm.colors.lime
        isRaceStarted = true
        isFormationLap = false
    end

    if startTime > SIM.currentServerTime or startTime == -1 then
        rgbmLightGreen = rgbm.colors.black
        rgbmLightRed = rgbm.colors.red
        driverInfo = "STAND BY"
        isRaceStarted = false
        isFormationLap = true
    end

    if isRaceStarted then
        lightsFadeout = lightsFadeout - 1
        if lightsFadeout < 1 then
            isStandBy = false
            driverInfo = "FORMATION LAP"
            isRaceStarted = false
            lightsFadeout = 500
            startTime = 0
        end
    end

    -- draw starting lights
    ui.drawRectFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET-8,APPTOP-4),vec2((SCREENSIZE.x/2)+CENTEROFFSET+8,APPBOTTOM+4),GRAY)
    for i = 0, 4, 1 do
        ui.drawRectFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET+(i*46),APPTOP),vec2((SCREENSIZE.x/2)-CENTEROFFSET+38+(i*46),APPBOTTOM),LIGHTGRAY)
        ui.drawCircleFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET+4+15+(i*46),APPTOP+8+15),15,rgbm.colors.black,32)
        ui.drawCircleFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET+4+15+(i*46),APPTOP+46+15),15,rgbmLightGreen,32)
        ui.drawCircleFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET+4+15+(i*46),APPTOP+84+15),15,rgbmLightRed,32)
        ui.drawCircleFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET+4+15+(i*46),APPTOP+122+15),15,rgbmLightRed,32)
    end
end

function script.update(dt)

    ac.debug("CarClass",CarClass)
    ac.debug("isFormationLap",isFormationLap)
    ac.debug("isStandBy",isStandBy)
    ac.debug("isRaceStarted",isRaceStarted)
    ac.debug("startTime",startTime)
    ac.debug("lightsFadeout",lightsFadeout)

end

function script.drawUI(dt)
    if isFormationLap then
        UI_FormationLap()
    end

    if isStandBy then
        UI_StartingLights()
    end
end

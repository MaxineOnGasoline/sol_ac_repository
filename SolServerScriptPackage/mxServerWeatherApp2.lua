-- Maxine's Server Weather App
-- ver 0.9
-- Changelog:
-- - New, beter-looking design
-- - Can be hidden when clicked on, shows a faint watermark
-- Current features:
-- Displays basic weather information above the virtual mirror, cannnot be disabled or moved

CAR = ac.getCar(0)
SIM = ac.getSim()
SCREENSIZE = vec2(SIM.windowWidth,SIM.windowHeight)
CPHYS = CAR.extendedPhysics
CSPVERSION = tostring(ac.getPatchVersionCode())
local showWeather = true
ui.setAsynchronousImagesLoading(true)

--- APP SIZING ---

CENTEROFFSET = 255 -- How many pixels sides of the app go off center
APPTOP = 50 -- Y coordinate of app's top side 
APPBOTTOM = 150 -- Y coordinate of app's bottom side
ICONSIZE = 24 -- Default icon scale in px
RIGHTOFFSET = 270
RIGHTEDGE = 50

--- COLORS ---

GRAY = rgbm(0,0,0,0.6)
LIGHTGRAY = rgbm(0.8,0.8,0.8,1)

function script.drawUI()
    ui.setAsynchronousImagesLoading(true)
    local AIRTEMP = math.round(SIM.ambientTemperature,1)
    local ROADTEMP = math.round(SIM.roadTemperature,1)
    local GRIP = math.round(SIM.roadGrip*100,1)
    local WETNESS = math.round(SIM.rainWetness*100,1)
    local WATER = math.round(SIM.rainWater*100,1)

    local function wetnessData(data)
        if (data == 0) then
            return "DRY"
        else
            return data.."%"
        end
    end

    local function wetnessIcon()
        if (WETNESS > 15) then
            return ui.Icons.WeatherHail
        elseif (WETNESS > 10) then
            return ui.Icons.WeatherRain
        elseif (WETNESS > 5) then
            return ui.Icons.WeatherRainLight
        elseif (WETNESS > 0) then
            return ui.Icons.WeatherDrizzle
        else
            return ui.weatherIcon(SIM.weatherType)
        end
    end

    local function fontWetnessColor()
        if WETNESS > 0 then
            return rgbm.colors.cyan
        else
            return LIGHTGRAY
        end

    end

    local function CphysReader()
        if CPHYS then
            return "ON"
        else
            return "OFF"
        end
    end

    local function clockFormat(value)
        if value < 10 then
            return "0"..value
        else
            return value
        end
    end
    
    if ui.rectHovered(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP),vec2(SCREENSIZE.x-RIGHTEDGE,APPBOTTOM)) then
        if ui.mouseDoubleClicked(ui.MouseButton.Left) then
            if showWeather then
                showWeather = false
            else
                showWeather = true
            end
        end
    end

    local function DrawWindow()
        if showWeather then

            ui.drawRectFilled(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP),vec2(SCREENSIZE.x-RIGHTEDGE,APPBOTTOM),GRAY,10)

            ui.pushDWriteFont(ui.DWriteFont("Segoi UI"):weight(ui.DWriteFont.Weight.Bold))

            ui.dwriteDrawText(tostring(ROADTEMP.."°C"),20,vec2(SCREENSIZE.x-RIGHTOFFSET+148,APPTOP+15),LIGHTGRAY)
            ui.dwriteDrawText(tostring(AIRTEMP.."°C"),20,vec2(SCREENSIZE.x-RIGHTOFFSET+80,APPTOP+15),LIGHTGRAY)

            ui.popDWriteFont()

            ui.dwriteDrawText(tostring(wetnessData(WETNESS)),16,vec2(SCREENSIZE.x-RIGHTOFFSET+80,APPTOP+45),fontWetnessColor())
            ui.dwriteDrawText(tostring(wetnessData(WATER)),16,vec2(SCREENSIZE.x-RIGHTOFFSET+148,APPTOP+45),fontWetnessColor())
            ui.dwriteDrawText(tostring("grip: "..GRIP.."%"),10,vec2(SCREENSIZE.x-RIGHTOFFSET+80,APPTOP+75),LIGHTGRAY)
            ui.dwriteDrawText(tostring("cphys: "..CphysReader()),10,vec2(SCREENSIZE.x-RIGHTOFFSET+148,APPTOP+75),LIGHTGRAY)
            ui.dwriteDrawText(tostring(clockFormat(SIM.timeHours)..":"..clockFormat(SIM.timeMinutes)),20,vec2(SCREENSIZE.x-RIGHTOFFSET+15,APPTOP+65),LIGHTGRAY)

            ui.drawIcon(wetnessIcon(),vec2(SCREENSIZE.x - RIGHTOFFSET + 25,APPTOP+25),vec2(SCREENSIZE.x - RIGHTOFFSET + 55,APPTOP+55),LIGHTGRAY)
        else
            ui.drawImage('https://i.imgur.com/4PAoRhj.png',vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP),vec2(SCREENSIZE.x-RIGHTEDGE,APPBOTTOM),ui.ImageFit.Fill)
        end
    end
    DrawWindow()
end
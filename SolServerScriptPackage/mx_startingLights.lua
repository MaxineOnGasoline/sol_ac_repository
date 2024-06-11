-- MX Starting Lights 1.0
-- Very simple server app that will render starting lights at the start of a race, both timed and lapped


CAR = ac.getCar(0)
SIM = ac.getSim()

RenderLights = false
HasSessionStarted = false



--if SIM.isSessionStarted then
  --  HasSessionStarted = true
--end

-- UI CORDS --

SCREENSIZE = vec2(SIM.windowWidth,SIM.windowHeight)
CENTEROFFSET = 215 -- How many pixels sides of the app go off center
APPTOP = 260 -- Y coordinate of app's top side 
APPBOTTOM = APPTOP + 90 -- Y coordinate of app's bottom side
MARGIN_LIGHTBOX = 5
MARGIN_LIGHTCIRCLE = 40
LIGHTBOX_SIZE = 80
LIGHTCIRCLE_RADIUS = 32

--- COLORS ---

GRAY = rgbm(0,0,0,0.7)
LIGHTGRAY = rgbm(0.3,0.3,0.3,0.7)
GRAYTRANS = rgbm(0,0,0,0.2)
STARTINGLIGHTS = {}

for i = 0, 4, 1 do
    STARTINGLIGHTS[i] = rgbm.colors.blue
end

--- LOGIC ---

function UI_StartingLights()

    ui.drawRectFilled(vec2((SCREENSIZE.x/2)-CENTEROFFSET,APPTOP),vec2((SCREENSIZE.x/2)+CENTEROFFSET,APPBOTTOM),GRAY)
    
    for i = 0, 4, 1 do

        --fixed position lightbox
        --ui.drawRectFilled(vec2(((SCREENSIZE.x/2)-CENTEROFFSET+MARGIN_LIGHTBOX),APPTOP+MARGIN_LIGHTBOX),vec2(((SCREENSIZE.x/2)-CENTEROFFSET+LIGHTBOX_SIZE+MARGIN_LIGHTBOX),APPBOTTOM-MARGIN_LIGHTBOX),rgbm.colors.red)
        --ui.drawCircleFilled(vec2(((SCREENSIZE.x/2)-CENTEROFFSET+MARGIN_LIGHTBOX+MARGIN_LIGHTCIRCLE),APPTOP+MARGIN_LIGHTBOX+MARGIN_LIGHTCIRCLE),LIGHTCIRCLE_RADIUS,rgbm.colors.yellow,64)

        ui.drawRectFilled(vec2(((SCREENSIZE.x/2)-CENTEROFFSET+MARGIN_LIGHTBOX+(i*85)),APPTOP+MARGIN_LIGHTBOX),vec2(((SCREENSIZE.x/2)-CENTEROFFSET+LIGHTBOX_SIZE+MARGIN_LIGHTBOX+(i*85)),APPBOTTOM-MARGIN_LIGHTBOX),LIGHTGRAY)
        ui.drawCircleFilled(vec2(((SCREENSIZE.x/2)-CENTEROFFSET+MARGIN_LIGHTBOX+MARGIN_LIGHTCIRCLE+(i*85)),APPTOP+MARGIN_LIGHTBOX+MARGIN_LIGHTCIRCLE),LIGHTCIRCLE_RADIUS,STARTINGLIGHTS[i],64)

    end

end

function script.update(dt)
    ac.debug("HasSessionStarted",HasSessionStarted)
    ac.debug("RenderLights",RenderLights)
    ac.debug("SessionStartTimeMS",SessionStartTimeMS)
    ac.debug("SessionType",SessionType)
    ac.debug("sessionTimeLeft",SIM.sessionTimeLeft)
    ac.debug("SIM.isSessionStarted",SIM.isSessionStarted)
    
    SessionType = ac.getSession(SIM.currentSessionIndex).type
    SessionStartTimeMS = ac.getSession(SIM.currentSessionIndex).durationMinutes*60*1000

    for i = 0, 4, 1 do
        ac.debug(i,STARTINGLIGHTS[i])
    end

    if SIM.sessionTimeLeft > SessionStartTimeMS + 6000 and not SIM.isSessionStarted then
        HasSessionStarted = false
    end

    if not HasSessionStarted then

        if SIM.sessionTimeLeft > SessionStartTimeMS + 5000 then
            if RenderLights then
                RenderLights = false
            end
        else
            RenderLights = true
        end

        if RenderLights then
        
            if SIM.sessionTimeLeft < SessionStartTimeMS + 5000 then
                for i = 0, 4, 1 do
                    STARTINGLIGHTS[i] = GRAYTRANS
                end
            end
    
            if SIM.sessionTimeLeft < SessionStartTimeMS + 4000 then
                STARTINGLIGHTS[0] = rgbm.colors.red
            end
    
            if SIM.sessionTimeLeft < SessionStartTimeMS + 3500 then
                STARTINGLIGHTS[1] = rgbm.colors.red
            end
    
            if SIM.sessionTimeLeft < SessionStartTimeMS + 3000 then
                STARTINGLIGHTS[2] = rgbm.colors.red
            end
    
            if SIM.sessionTimeLeft < SessionStartTimeMS + 2500 then
                STARTINGLIGHTS[3] = rgbm.colors.red
            end
    
            if SIM.sessionTimeLeft < SessionStartTimeMS + 2000 then
                STARTINGLIGHTS[4] = rgbm.colors.red
            end
    
            if SIM.sessionTimeLeft < SessionStartTimeMS then
                for i = 0, 4, 1 do
                    STARTINGLIGHTS[i] = rgbm.colors.lime
                    HasSessionStarted = true
                end
            end
        end
    end

    if SIM.sessionTimeLeft < SessionStartTimeMS - 3000 then
        RenderLights = false
    end
end

function script.drawUI(dt)
    
    if ac.getSession(SIM.currentSessionIndex).type == ac.SessionType.Race then
        if RenderLights then
            UI_StartingLights()
        end
    end

end

-- Maxine's Driver Name Changer
-- ver 0.9
-- Current features:
-- Changes player's nickname if their guid is in the database
-- If predefined for a team, allows for name change during pitstops and before start of a session. List is created based on matching racing number in the database.

SIM = ac.getSim()
CAR = ac.getCar(0)
GUID = ac.getUserSteamID()

--- DATA ---

TeamData = {}
RACENUMBER = -1
CoolDown = 0
NICKCHECK = false
DRIVINGLAN = false

--- APP SIZING ---

RowHeight = 40
RIGHTOFFSET = 270
RIGHTEDGE = 50
SCREENSIZE = vec2(SIM.windowWidth,SIM.windowHeight)
APPTOP = 200

--- COLORS ---

GRAY = rgbm(0,0,0,0.6)
LIGHTGRAY = rgbm(0.8,0.8,0.8,1)

----------------------------------------------
--------------- NAME CHANGER -----------------
----------------------------------------------

function script.update(dt)
    if not NICKCHECK then
        ChangeNicknameBasedOnGUID()
        GetAllTeamDrivers()
        NICKCHECK = true
    end
end

function script.drawUI(dt)
    if DRIVINGLAN then
        if CAR.isInPitlane or not SIM.isSessionStarted then
            DrawNameChanger()
        end
    end
end

function ChangeNicknameBasedOnGUID()
    local matchFound = false

    for i, data in ipairs(StoredData) do
        if data.id == GUID then
            ac.log("Match found for GUID: "..GUID)
            if data.isLan then
                DRIVINGLAN = true
                physics.setDriverName(("#"..data.teamNumber.." | "..data.teamName),data.nationality)
            else
                physics.setDriverName(("#"..data.teamNumber.." | "..data.name),data.nationality)
            end
            TeamData[1] = table.clone(StoredData[i],false)
            RACENUMBER = data.teamNumber
            matchFound = true
            break
        end
    end

    if not matchFound then
        ac.log("No match found for ID:", GUID)
    end
end

function GetAllTeamDrivers()
    local j = 1
    ac.log("Getting all drivers from the team")
    for i,data in ipairs(StoredData) do
        if data.teamNumber == RACENUMBER then
            TeamData[j] = table.clone(StoredData[i],false)
            ac.log(TeamData[j].name)
            j = j + 1
        end
    end
end

function DrawNameChanger()
    local DriverCount = #TeamData

    ui.pushDWriteFont(ui.DWriteFont("Segoi UI"):weight(ui.DWriteFont.Weight.SemiBold))

    ui.drawRectFilled(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP-30),vec2(SCREENSIZE.x-RIGHTEDGE,APPTOP),rgbm.colors.black,0)
    ui.setCursor(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP-35))
    ui.dwriteTextAligned(tostring(ac.getDriverName(0)),14,ui.Alignment.Center,ui.Alignment.Center,vec2(220,40),false,rgbm.colors.yellow)

    if CoolDown > 0 then
        ui.drawRectFilled(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP),vec2(SCREENSIZE.x-RIGHTEDGE,APPTOP + (RowHeight*DriverCount) ),rgbm.colors.black)
        ui.setCursor(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP))
        ui.dwriteTextAligned("Name change on cooldown",14,ui.Alignment.Center,ui.Alignment.Center,vec2(220,40),false,rgbm.colors.gray)

        CoolDown = CoolDown - 1
    else
        for i = 0, DriverCount - 1, 1 do
            ui.drawRectFilled(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP + (i * RowHeight)),vec2(SCREENSIZE.x-RIGHTEDGE,APPTOP + RowHeight + (i * RowHeight)),GRAY,0)
            ui.setCursor(vec2(SCREENSIZE.x-RIGHTOFFSET + 10,APPTOP + (i * RowHeight)))
            ui.dwriteTextAligned(TeamData[i+1].name,14,ui.Alignment.Center,ui.Alignment.Center,vec2(200,RowHeight),false)

            if ui.rectHovered(vec2(SCREENSIZE.x-RIGHTOFFSET,APPTOP + (i * RowHeight)),vec2(SCREENSIZE.x-RIGHTEDGE,APPTOP + RowHeight + (i * RowHeight))) then
                if ui.mouseClicked(0) then
                    physics.setDriverName(("#"..TeamData[i+1].teamNumber.." | "..TeamData[i+1].name),TeamData[i+1].nationality)
                    ac.log("Name has been changed")
                    CoolDown = 300
                end
            end
        end
    end
end

StoredData = {
    {id = "76561198063989268", teamNumber = "17", teamName = "Huragan Kielce", name = "Max Prus", nationality = 'POL', isLan = false},
    {id = "76561199045326974", teamNumber = "17", teamName = "Huragan Kielce", name = "Maksu San", nationality = 'JPN', isLan = false},
    {id = "76561198032579097", teamNumber = "17", teamName = "Huragan Kielce", name = "Arek Nakonieczny", nationality = 'POL', isLan = false},
}
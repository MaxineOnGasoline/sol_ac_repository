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
{id='76561198229681208', teamNumber=7, teamName='Euro 7 Alternative Racing', name='Jakub Janiszewski', nationality='POL', isLan=true},
{id='76561198410823389', teamNumber=7, teamName='Euro 7 Alternative Racing', name='Borys Jarnot Bałuszek', nationality='POL', isLan=true},
{id='76561198398039859', teamNumber=997, teamName='Żwirki i Szefury Racing', name='Maciej Śpiewak', nationality='POL', isLan=true},
{id='76561198827660021', teamNumber=997, teamName='Żwirki i Szefury Racing', name='Krystian Michalczuk', nationality='POL', isLan=true},
{id='76561199346444020', teamNumber=997, teamName='Żwirki i Szefury Racing', name='Maksymilian Jaros', nationality='AFG', isLan=true},
{id='76561198879631843', teamNumber=997, teamName='Żwirki i Szefury Racing', name='Szymon Mirczak', nationality='POL', isLan=true},
{id='76561198095975119', teamNumber=775, teamName='775 Racing', name='Jakub Jaroszuk', nationality='POL', isLan=true},
{id='76561198838334059', teamNumber=775, teamName='775 Racing', name='Michał Wądołowski', nationality='POL', isLan=true},
{id='76561198227834088', teamNumber=775, teamName='775 Racing', name='Dawid Krutul', nationality='POL', isLan=true},
{id='76561199013181058', teamNumber=775, teamName='775 Racing', name='Adrian Piekarek', nationality='POL', isLan=true},
{id='76561198242008896', teamNumber=775, teamName='775 Racing', name='Daniel Kensy', nationality='POL', isLan=true},
{id='76561199178062993', teamNumber=51, teamName='Apex One GT4 #1', name='Adrian Kobacki', nationality='POL', isLan=true},
{id='76561198077381614', teamNumber=51, teamName='Apex One GT4 #1', name='Kacper Smirnow', nationality='POL', isLan=true},
{id='76561198142953806', teamNumber=51, teamName='Apex One GT4 #1', name='Daniel Rataj', nationality='POL', isLan=true},
{id='76561198221892956', teamNumber=51, teamName='Apex One GT4 #1', name='Jakub Tarasiuk', nationality='POL', isLan=true},
{id='76561198041557438', teamNumber=101, teamName='Apex One GT3 #3', name='Szymon Piotrowski', nationality='POL', isLan=true},
{id='76561198208193368', teamNumber=101, teamName='Apex One GT3 #3', name='Mikołaj Nowicki', nationality='POL', isLan=true},
{id='76561198334093743', teamNumber=101, teamName='Apex One GT3 #3', name='Igor Wąsowski', nationality='POL', isLan=true},
{id='76561198245596014', teamNumber=101, teamName='Apex One GT3 #3', name='Łukasz Sikorski', nationality='POL', isLan=true},
{id='76561199062444478', teamNumber=117, teamName='AeroLab ESports', name='Michail Dinu', nationality='AUT', isLan=false},
{id='76561198139600721', teamNumber=117, teamName='AeroLab ESports', name='Jascha Schmidt', nationality='DEU', isLan=false},
{id='76561199132176789', teamNumber=117, teamName='AeroLab ESports', name='Luca Yska', nationality='NLD', isLan=false},
{id='76561198151763752', teamNumber=117, teamName='AeroLab ESports', name='Rene Kirscht', nationality='DEU', isLan=false},
{id='76561198277132938', teamNumber=171, teamName='EQP Racing Team ', name='Paweł Maliszewski ', nationality='POL', isLan=true},
{id='76561198962220373', teamNumber=171, teamName='EQP Racing Team ', name='Szymon Mrochem ', nationality='POL', isLan=true},
{id='76561198421073793', teamNumber=171, teamName='EQP Racing Team ', name='Krzysztof Kosiński', nationality='POL', isLan=true},
{id='76561198185998989', teamNumber=171, teamName='EQP Racing Team ', name='Bartosz  Mikoda', nationality='POL', isLan=true},
{id='76561198993861460', teamNumber=50, teamName='WKS RACING', name='Juliusz Winiarek', nationality='POL', isLan=false},
{id='76561198262548902', teamNumber=50, teamName='WKS RACING', name='Michał Kaufmann', nationality='POL', isLan=false},
{id='76561198018323315', teamNumber=50, teamName='WKS RACING', name='Oktawian Sadlak', nationality='POL', isLan=false},
{id='76561198272559221', teamNumber=79, teamName=' Midas Racing Black', name='Mikołaj   Południak', nationality='POL', isLan=false},
{id='76561198441386095', teamNumber=79, teamName=' Midas Racing Black', name='Jan  Gliszczyński', nationality='POL', isLan=false},
{id='76561198103068400', teamNumber=79, teamName=' Midas Racing Black', name='Aleksander  Studziński ', nationality='POL', isLan=false},
{id='76561198083247979', teamNumber=79, teamName=' Midas Racing Black', name='Kacper  Kazimierski', nationality='POL', isLan=false},
{id='76561198974069912', teamNumber=79, teamName=' Midas Racing Black', name='Mateusz  Nawrot', nationality='POL', isLan=false},
{id='76561198001170851', teamNumber=911, teamName='ETP Racing Team', name='Fryderyk Gałecki', nationality='POL', isLan=false},
{id='76561198081142234', teamNumber=911, teamName='ETP Racing Team', name='Jakub Serafin', nationality='POL', isLan=false},
{id='76561198268129763', teamNumber=911, teamName='ETP Racing Team', name='Michał Rudzki', nationality='POL', isLan=false},
{id='76561198168588618', teamNumber=810, teamName='Team Delta Infinite', name='Jakub Radochoński', nationality='POL', isLan=false},
{id='76561198308744714', teamNumber=810, teamName='Team Delta Infinite', name='Michał Juszczak', nationality='AND', isLan=false},
{id='76561198237954450', teamNumber=810, teamName='Team Delta Infinite', name='Mateusz Rogalski', nationality='POL', isLan=false},
{id='76561199100068767', teamNumber=810, teamName='Team Delta Infinite', name='Aleks Składanek', nationality='POL', isLan=false},
{id='76561198869940985', teamNumber=810, teamName='Team Delta Infinite', name='Sebastian Jaskólski', nationality='POL', isLan=false},
{id='76561198410527585', teamNumber=66, teamName='MRD Racing', name='Dawid  Płotka', nationality='POL', isLan=false},
{id='76561199134997846', teamNumber=66, teamName='MRD Racing', name='Daniel  Chmielak ', nationality='POL', isLan=false},
{id='76561198330353696', teamNumber=66, teamName='MRD Racing', name='Oskar  Dziuba', nationality='POL', isLan=false},
{id='76561199029534371', teamNumber=66, teamName='MRD Racing', name='Dorian Wdowicki', nationality='POL', isLan=false},
{id='76561198871195243', teamNumber=66, teamName='MRD Racing', name='Michał Kapel', nationality='POL', isLan=false},
{id='76561198353781236', teamNumber=331, teamName='Undefeated Racing', name='Michał Domagała', nationality='POL', isLan=false},
{id='76561199065888010', teamNumber=331, teamName='Undefeated Racing', name='Jakub Marczak', nationality='POL', isLan=false},
{id='76561198394331877', teamNumber=331, teamName='Undefeated Racing', name='Bartek Stanek', nationality='POL', isLan=false},
{id='76561198068998423', teamNumber=771, teamName='Apex One Academy GT4 #2', name='Przemysław Ludkiewicz', nationality='POL', isLan=true},
{id='76561198109138934', teamNumber=771, teamName='Apex One Academy GT4 #2', name='Eryk Szymendera', nationality='POL', isLan=true},
{id='76561198093217073', teamNumber=771, teamName='Apex One Academy GT4 #2', name='Wiktor Behrendt', nationality='POL', isLan=true},
{id='76561198144472205', teamNumber=771, teamName='Apex One Academy GT4 #2', name='Filip Przygoński', nationality='POL', isLan=true},
{id='76561198211379496', teamNumber=771, teamName='Apex One Academy GT4 #2', name='Kamil Hołub', nationality='POL', isLan=true},
{id='76561198360003609', teamNumber=888, teamName='Apex One GT3 #2', name='Wojtek Niewęgłowski', nationality='POL', isLan=false},
{id='76561198273387549', teamNumber=888, teamName='Apex One GT3 #2', name='Szymon Górka', nationality='POL', isLan=false},
{id='76561198118903734', teamNumber=888, teamName='Apex One GT3 #2', name='Wojtek Surosz', nationality='POL', isLan=false},
{id='76561198416205184', teamNumber=888, teamName='Apex One GT3 #2', name='Robert Radaj', nationality='POL', isLan=false},
{id='76561198194524875', teamNumber=43, teamName='Apex One GT3 #1', name='Adrian Faber', nationality='POL', isLan=false},
{id='76561198107963325', teamNumber=43, teamName='Apex One GT3 #1', name='Marcin Rybaczuk', nationality='POL', isLan=false},
{id='76561198262787782', teamNumber=43, teamName='Apex One GT3 #1', name='Dawid Fryzowicz', nationality='POL', isLan=false},
{id='76561198211245596', teamNumber=43, teamName='Apex One GT3 #1', name='Rafał Szołtysek', nationality='POL', isLan=false},
{id='76561197997431008', teamNumber=666, teamName='WojolRacing.pl', name='Jakub Stanek', nationality='POL', isLan=true},
{id='76561198033217916', teamNumber=666, teamName='WojolRacing.pl', name='Szymon  Wójcik', nationality='POL', isLan=true},
{id='76561197990696929', teamNumber=666, teamName='WojolRacing.pl', name='Krzysztof Wójcik', nationality='POL', isLan=true},
{id='76561198985506206', teamNumber=666, teamName='WojolRacing.pl', name='Kacper  Szafrański', nationality='POL', isLan=true},
{id='76561198107832540', teamNumber=666, teamName='WojolRacing.pl', name='Grzegorz Marszałek', nationality='POL', isLan=true},
{id='76561198897907175', teamNumber=666, teamName='WojolRacing.pl', name='Szymon Praczyk', nationality='POL', isLan=true},
{id='76561198394695558', teamNumber=14, teamName='Speedscape Syndicate', name='Tymon Siekierski', nationality='POL', isLan=true},
{id='76561198828646049', teamNumber=14, teamName='Speedscape Syndicate', name='Cezary Szwaguliński', nationality='POL', isLan=true},
{id='76561198039791439', teamNumber=14, teamName='Speedscape Syndicate', name='Cezary Jankowski', nationality='POL', isLan=true},
{id='76561198800554677', teamNumber=14, teamName='Speedscape Syndicate', name='Mikołaj Wojciechowski', nationality='POL', isLan=true},
{id='76561198940512950', teamNumber=14, teamName='Speedscape Syndicate', name='Wiktor Górecki', nationality='POL', isLan=true},
{id='76561198282984965', teamNumber=179, teamName='Midas Racing ', name='Maciej   Kiljański', nationality='POL', isLan=false},
{id='76561198126612741', teamNumber=179, teamName='Midas Racing ', name='Michał  Glanowski', nationality='POL', isLan=false},
{id='76561198345653070', teamNumber=179, teamName='Midas Racing ', name='Marcin  Grzegrzółka', nationality='POL', isLan=false},
{id='76561198185661571', teamNumber=179, teamName='Midas Racing ', name='Kacper  Śmietana', nationality='POL', isLan=false},
{id='76561198141173148', teamNumber=59, teamName='Szczepan Ubezpieczenia HALO KOMENTATOR TUTAJ JESTESMY', name='Patryk Jaskulski', nationality='POL', isLan=false},
{id='76561198079076562', teamNumber=59, teamName='Szczepan Ubezpieczenia HALO KOMENTATOR TUTAJ JESTESMY', name='Robert Sobota', nationality='POL', isLan=false},
{id='76561198013468403', teamNumber=59, teamName='Szczepan Ubezpieczenia HALO KOMENTATOR TUTAJ JESTESMY', name='Maciej Szczepaniak', nationality='POL', isLan=false},
{id='76561198254676575', teamNumber=97, teamName='Parc Motorsport', name='Mikołaj Muszyński', nationality='POL', isLan=true},
{id='76561198109048329', teamNumber=97, teamName='Parc Motorsport', name='Błażej Szczurek', nationality='POL', isLan=true},
{id='76561198231896000', teamNumber=97, teamName='Parc Motorsport', name='Mark Edmundson', nationality='GBR', isLan=true},
{id='76561198089621220', teamNumber=97, teamName='Parc Motorsport', name='Szymon Janik', nationality='POL', isLan=true},
{id='76561198203927844', teamNumber=97, teamName='Parc Motorsport', name='Tomasz Rogacki', nationality='POL', isLan=true},
{id='76561198854072265', teamNumber=907, teamName='Parc Motorsport White', name='Bartosz Wilk', nationality='POL', isLan=false},
{id='76561198845918965', teamNumber=907, teamName='Parc Motorsport White', name='Antoni Urbaniak', nationality='POL', isLan=false},
{id='76561199125263844', teamNumber=907, teamName='Parc Motorsport White', name='Jakub Kuraczyk', nationality='POL', isLan=false},
{id='76561198839262746', teamNumber=907, teamName='Parc Motorsport White', name='Konrad Chrzan', nationality='POL', isLan=false},
{id='76561199359392529', teamNumber=300, teamName='Apex One Kicia Esports | Alfa', name='Antoni Sokołowski', nationality='POL', isLan=true},
{id='76561198356776764', teamNumber=300, teamName='Apex One Kicia Esports | Alfa', name='Kacper Trzmiel', nationality='POL', isLan=true},
{id='76561199051312374', teamNumber=300, teamName='Apex One Kicia Esports | Alfa', name='Maciej Myrta', nationality='POL', isLan=true},
{id='76561198390317003', teamNumber=300, teamName='Apex One Kicia Esports | Alfa', name='Olivier Jasiak', nationality='POL', isLan=true},
{id='76561198071370945', teamNumber=175, teamName='ThermalGrizzly SimracingDream Team', name='Jakub Rzeszut', nationality='AFG', isLan=true},
{id='76561198166756103', teamNumber=175, teamName='ThermalGrizzly SimracingDream Team', name='Sebastian Bobek', nationality='POL', isLan=true},
{id='76561199442771589', teamNumber=175, teamName='ThermalGrizzly SimracingDream Team', name='Bartosz  Grzywacz', nationality='POL', isLan=true},
{id='76561198328416637', teamNumber=175, teamName='ThermalGrizzly SimracingDream Team', name='Patryk Werbowy', nationality='POL', isLan=true},
{id='76561199044257021', teamNumber=175, teamName='ThermalGrizzly SimracingDream Team', name='Igor  Piasecki', nationality='POL', isLan=true},
{id='76561198040010887', teamNumber=275, teamName='MoveCenter SimracingDream Team', name='Michał  Grzywacz', nationality='POL', isLan=true},
{id='76561199443676081', teamNumber=275, teamName='MoveCenter SimracingDream Team', name='Piotr  Sumara', nationality='POL', isLan=true},
{id='76561198079781361', teamNumber=275, teamName='MoveCenter SimracingDream Team', name='Kamil  Adamczyk', nationality='POL', isLan=true},
{id='76561198084681075', teamNumber=275, teamName='MoveCenter SimracingDream Team', name='Kamil Śmieja', nationality='POL', isLan=true},
{id='76561198032380672', teamNumber=279, teamName='WRS Interstellar by Midas', name='Jan   Sikorski', nationality='POL', isLan=false},
{id='76561198079304872', teamNumber=279, teamName='WRS Interstellar by Midas', name='Adrian   Znosko', nationality='POL', isLan=false},
{id='76561198435773278', teamNumber=279, teamName='WRS Interstellar by Midas', name=' Mikołaj  Szlachciński', nationality='POL', isLan=false},
{id='76561198418106331', teamNumber=279, teamName='WRS Interstellar by Midas', name='Krystian  Zieliński', nationality='POL', isLan=false},
{id='76561198206895407', teamNumber=279, teamName='WRS Interstellar by Midas', name='Kacper  Kasztelan', nationality='POL', isLan=false},
{id='76561198027376954', teamNumber=10, teamName='775 Hymo Setups', name='Dominik Blajer', nationality='POL', isLan=false},
{id='76561198293517275', teamNumber=10, teamName='775 Hymo Setups', name='Piotr Stachulec', nationality='POL', isLan=false},
{id='76561198135221817', teamNumber=10, teamName='775 Hymo Setups', name='Jakub Charkot', nationality='POL', isLan=false},
{id='76561199032761172', teamNumber=10, teamName='775 Hymo Setups', name='Nikodem Sobczyk', nationality='POL', isLan=false},
{id='76561198094191367', teamNumber=10, teamName='775 Hymo Setups', name='Maciej Malinowski', nationality='POL', isLan=false},
{id='76561198038667328', teamNumber=58, teamName='Szczepan Ubezpieczenia GT3', name='Wojciech Bodziony', nationality='POL', isLan=false},
{id='76561198071337643', teamNumber=58, teamName='Szczepan Ubezpieczenia GT3', name='Kamil Paczos', nationality='POL', isLan=false},
{id='76561198325546282', teamNumber=58, teamName='Szczepan Ubezpieczenia GT3', name='Michał Czarnecki', nationality='POL', isLan=false},
{id='76561198994994988', teamNumber=400, teamName='Apex One Kicia Esports | Bravo', name='Adrian Raszke', nationality='POL', isLan=true},
{id='76561198343267497', teamNumber=400, teamName='Apex One Kicia Esports | Bravo', name='Jakub Kozłowski', nationality='POL', isLan=true},
{id='76561198041315474', teamNumber=400, teamName='Apex One Kicia Esports | Bravo', name='David Śliwka', nationality='POL', isLan=true},
{id='76561198032692915', teamNumber=71, teamName='Apex One GT3 #4', name='Patryk Krutyj', nationality='POL', isLan=false},
{id='76561198226748772', teamNumber=71, teamName='Apex One GT3 #4', name='Daniel Libront', nationality='POL', isLan=false},
{id='76561198157333224', teamNumber=71, teamName='Apex One GT3 #4', name='Łukasz Sokół', nationality='POL', isLan=false},
{id='76561198030143608', teamNumber=71, teamName='Apex One GT3 #4', name='Kamil Putoń', nationality='POL', isLan=false},
{id='76561198227476624', teamNumber=71, teamName='Apex One GT3 #4', name='Wojciech Bobrowicz', nationality='POL', isLan=false},
{id='76561198215337277', teamNumber=35, teamName='SFL Endurance Team', name='Kamil Mania', nationality='POL', isLan=false},
{id='76561198190038917', teamNumber=35, teamName='SFL Endurance Team', name='Oskar Tomala', nationality='POL', isLan=false},
{id='76561199207245332', teamNumber=35, teamName='SFL Endurance Team', name='Oliwier Przepióra', nationality='POL', isLan=false},
{id='76561198404272380', teamNumber=35, teamName='SFL Endurance Team', name='Bartosz Czarnecki', nationality='POL', isLan=false},
{id='76561199444283582', teamNumber=35, teamName='SFL Endurance Team', name='Leon Stachera', nationality='POL', isLan=false},
{id='76561199133557694', teamNumber=104, teamName='Apex One GT4 #3', name='Olaf Moryś', nationality='POL', isLan=false},
{id='76561197993587345', teamNumber=104, teamName='Apex One GT4 #3', name='Mateusz Bogusz', nationality='POL', isLan=false},
{id='76561198134992935', teamNumber=104, teamName='Apex One GT4 #3', name='Mateusz Dorocki', nationality='POL', isLan=false},
{id='76561198058138323', teamNumber=104, teamName='Apex One GT4 #3', name='Rafał Dąbal', nationality='POL', isLan=false},
{id='76561198353572174', teamNumber=820, teamName='Team Delta Infinite Red', name='Dariusz Dragon', nationality='POL', isLan=false},
{id='76561199352783922', teamNumber=820, teamName='Team Delta Infinite Red', name='Karol Wielgo', nationality='POL', isLan=false},
{id='76561199206214638', teamNumber=820, teamName='Team Delta Infinite Red', name='Michał Bill', nationality='POL', isLan=false},
{id='76561198057768719', teamNumber=820, teamName='Team Delta Infinite Red', name='Jakub Kucharczyk', nationality='DEU', isLan=false},
{id='76561198836081752', teamNumber=820, teamName='Team Delta Infinite Red', name='Wojciech Podczaski', nationality='POL', isLan=false},
{id='76561198102420230', teamNumber=820, teamName='Team Delta Infinite Red', name='Kacper Kubica', nationality='POL', isLan=false},
{id='76561199082163972', teamNumber=446, teamName='RaceSpot ', name='Bartłomiej Bromblik', nationality='POL', isLan=false},
{id='76561198255222486', teamNumber=446, teamName='RaceSpot ', name='Adrian Zajfert', nationality='POL', isLan=false},
{id='76561198420288691', teamNumber=446, teamName='RaceSpot ', name='Dariusz Hermet', nationality='POL', isLan=false},
{id='76561198095470488', teamNumber=446, teamName='RaceSpot ', name='Piotr Jaromski', nationality='POL', isLan=false},
{id='76561198014297328', teamNumber=777, teamName='RTRD x Gniado Bauelemente GT4', name='Cezary Konieczny', nationality='POL', isLan=false},
{id='76561199103839022', teamNumber=777, teamName='RTRD x Gniado Bauelemente GT4', name='Mateusz Maj', nationality='AFG', isLan=false},
{id='76561198050285458', teamNumber=777, teamName='RTRD x Gniado Bauelemente GT4', name='Wiktor Gogarowski', nationality='POL', isLan=false},
{id='76561197993506093', teamNumber=777, teamName='RTRD x Gniado Bauelemente GT4', name='Bartosz Gniado', nationality='POL', isLan=false},
{id='76561198067357565', teamNumber=777, teamName='RTRD x Gniado Bauelemente GT4', name='Jan Saganowski', nationality='POL', isLan=false},
{id='76561198161440542', teamNumber=133, teamName='RTRD x Gniado Bauelemente GT3', name='Kacper Bogoń', nationality='POL', isLan=false},
{id='76561198189774859', teamNumber=133, teamName='RTRD x Gniado Bauelemente GT3', name='Mateusz Bluszcz', nationality='POL', isLan=false},
{id='76561198352988273', teamNumber=133, teamName='RTRD x Gniado Bauelemente GT3', name='Mateusz Kurpisz', nationality='POL', isLan=false},
{id='76561197990266754', teamNumber=133, teamName='RTRD x Gniado Bauelemente GT3', name='Marcin Zawistowski', nationality='POL', isLan=false},
{id='76561198126418980', teamNumber=133, teamName='RTRD x Gniado Bauelemente GT3', name='Piotr Kwaśniowski', nationality='POL', isLan=false},
{id='76561198059399371', teamNumber=366, teamName='SRD AMP Speed', name='Szymon Uhle', nationality='POL', isLan=true},
{id='76561198307633718', teamNumber=366, teamName='SRD AMP Speed', name='Kacper Skalski', nationality='POL', isLan=true},
{id='76561198217796325', teamNumber=366, teamName='SRD AMP Speed', name='Kamil Górkowy', nationality='POL', isLan=true},
{id='76561198076394331', teamNumber=366, teamName='SRD AMP Speed', name='Andrzej Magiera-Gorzka', nationality='POL', isLan=true},
{id='76561198159522959', teamNumber=366, teamName='SRD AMP Speed', name='Jakub Kozłowski', nationality='POL', isLan=true},
{id='76561198860115848', teamNumber=84, teamName='Kirito Racing Academy', name='George Brooke', nationality='GBR', isLan=false},
{id='76561198844870703', teamNumber=84, teamName='Kirito Racing Academy', name='Alvis Shizuo', nationality='USA', isLan=false},
{id='76561198293948484', teamNumber=84, teamName='Kirito Racing Academy', name='Tim Stahl', nationality='DEU', isLan=false},
{id='76561198425098780', teamNumber=84, teamName='Kirito Racing Academy', name='Jakub Szymborowski', nationality='DEU', isLan=false},
{id='76561198274110121', teamNumber=711, teamName='Arachnid Racing', name='Logan Rae', nationality='AUS', isLan=true},
{id='76561198051406415', teamNumber=711, teamName='Arachnid Racing', name='Rickson Bobby', nationality='USA', isLan=true},
{id='76561199088286610', teamNumber=711, teamName='Arachnid Racing', name='Ryan Pagay', nationality='PHL', isLan=true},
{id='76561199071082357', teamNumber=711, teamName='Arachnid Racing', name='zack llewelly-morris', nationality='GBR', isLan=true},
{id='76561199158590230', teamNumber=711, teamName='Arachnid Racing', name='Armin Lewandowski', nationality='POL', isLan=true},
{id='76561198211616457', teamNumber=711, teamName='Arachnid Racing', name='Jay Kirkham', nationality='GBR', isLan=true},
{id='76561198056645835', teamNumber=420, teamName='JHBACKSTAGE Racing Team', name='Daniel Mrożek', nationality='POL', isLan=false},
{id='76561199059822954', teamNumber=420, teamName='JHBACKSTAGE Racing Team', name='Mateusz Filoda', nationality='POL', isLan=false},
{id='76561198905835901', teamNumber=420, teamName='JHBACKSTAGE Racing Team', name='Michał Źrebiec', nationality='NLD', isLan=false},
{id='76561197990273433', teamNumber=46, teamName='RaceSpot Academy', name='Jarosław Hołda', nationality='POL', isLan=false},
{id='76561199075153293', teamNumber=46, teamName='RaceSpot Academy', name='Andrzej Piekutowski', nationality='POL', isLan=false},
{id='76561198126776074', teamNumber=46, teamName='RaceSpot Academy', name='Oskar Bartosiak', nationality='AFG', isLan=false},
{id='76561198374171954', teamNumber=46, teamName='RaceSpot Academy', name='Przemysław Nastawski', nationality='POL', isLan=false},
{id='76561198185924762', teamNumber=46, teamName='RaceSpot Academy', name='Bartłomiej Długoszewski', nationality='POL', isLan=false},
{id='76561198282822834', teamNumber=46, teamName='RaceSpot Academy', name='Piotr Bielak', nationality='POL', isLan=false},
{id='76561199426536807', teamNumber=22, teamName='Brawn Endurance Racing', name='Jakub Klapa', nationality='POL', isLan=false},
{id='76561198198307673', teamNumber=22, teamName='Brawn Endurance Racing', name='Jakub Tarnowski', nationality='POL', isLan=false},
{id='76561198260452829', teamNumber=22, teamName='Brawn Endurance Racing', name='Filip Kielar', nationality='POL', isLan=false},
{id='76561198106920758', teamNumber=579, teamName='Pika Pika GP Racing', name='Paweł Iwanicki', nationality='POL', isLan=true},
{id='76561199122004803', teamNumber=579, teamName='Pika Pika GP Racing', name='Karol Więch', nationality='POL', isLan=true},
{id='76561199243230558', teamNumber=579, teamName='Pika Pika GP Racing', name='Patryk Machaj', nationality='POL', isLan=true},
{id='76561198859170760', teamNumber=579, teamName='Pika Pika GP Racing', name='Olaf Cygan', nationality='POL', isLan=true},
{id='76561198259769615', teamNumber=20, teamName='OVERCREST Racing Team', name='Jakub Wróbel', nationality='POL', isLan=true},
{id='76561199586566399', teamNumber=20, teamName='OVERCREST Racing Team', name='Kamil Wróbel', nationality='POL', isLan=true},
{id='76561198199842643', teamNumber=20, teamName='OVERCREST Racing Team', name='Kamil Parchański', nationality='POL', isLan=true},
{id='76561198207185268', teamNumber=20, teamName='OVERCREST Racing Team', name='Kacper Wojtan', nationality='POL', isLan=true},
{id='76561199472463584', teamNumber=20, teamName='OVERCREST Racing Team', name='Marek Jagiełło', nationality='POL', isLan=true},
{id='76561198208993784', teamNumber=20, teamName='OVERCREST Racing Team', name='Mikołaj Klimek', nationality='POL', isLan=true},
{id='76561198032579097', teamNumber=17, teamName='AKN Racing Team', name='Arek Nakonieczny', nationality='POL', isLan=false},
{id='76561198077960643', teamNumber=17, teamName='AKN Racing Team', name='Jakub Gregorczyk', nationality='POL', isLan=false},
{id='76561198126448295', teamNumber=17, teamName='AKN Racing Team', name='Dawid Migdał', nationality='POL', isLan=false},
{id='76561198063989268', teamNumber=17, teamName='AKN Racing Team', name='Max Prus', nationality='POL', isLan=false},
}

local QBCore = exports['qb-core']:GetCoreObject()
local Timer, HasAlreadyEnteredMarker, ChoppingInProgress, LastZone, isDead, pedIsTryingToChopVehicle, menuOpen = 0, false, false, nil, false, false, false
local CurrentAction, CurrentActionMsg, CurrentActionData, menuOpen = nil, '', {}, false
local timing = math.ceil(Config.Timer * 60000)

function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function IsDriver()
    return GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId()
end

function MaxSeats(vehicle)
    local vehpas = GetVehicleNumberOfPassengers(vehicle)
    return vehpas
end

-- Display Marker
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local letSleep = true

        for k, v in pairs(Config.Zones) do
            local distance = GetDistanceBetweenCoords(playerCoords, v.Pos.x, v.Pos.y, v.Pos.z, true)
            if Config.MarkerType ~= -1 and distance < Config.DrawDistance then
                DrawMarker(Config.MarkerType, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
                letSleep = false
            end

        end
        if letSleep then
            Citizen.Wait(500)
        end
    end
end)

function CreateBlipCircle(coords, text, radius, color, sprite)

    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
    if Config.EnableBlips == true then
        for k, zone in pairs(Config.Zones) do
            CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
        end
    end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local isInMarker = false
        local currentZone = nil
        local letSleep = true
        for k, v in pairs(Config.Zones) do
            local distance = GetDistanceBetweenCoords(playerCoords, v.Pos.x, v.Pos.y, v.Pos.z, true)
            if distance < v.Size.x then
                isInMarker = true
                currentZone = k
            end

        end
        if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
            HasAlreadyEnteredMarker = true
            LastZone = currentZone
            TriggerEvent('Lenzh_chopshop:hasEnteredMarker', currentZone)
        end

        if not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('Lenzh_chopshop:hasExitedMarker', LastZone)
        end
    end
end)

AddEventHandler('Lenzh_chopshop:hasEnteredMarker', function(zone)
    if zone == 'Chopshop' and IsDriver() then
        CurrentAction = 'Chopshop'
        CurrentActionMsg = Lang:t('press_to_chop')
        CurrentActionData = {}
    elseif zone == 'StanleyShop' then
        CurrentAction = 'StanleyShop'
        CurrentActionMsg = Lang:t('open_shop')
        CurrentActionData = {}
    end
end)

AddEventHandler('Lenzh_chopshop:hasExitedMarker', function(zone)
    if menuOpen then
        exports['qb-menu']:closeMenu()
        exports['qb-core']:HideText()
    end

    CurrentAction = nil
end)

AddEventHandler('Lenzh_chopshop:client:closeMenu', function()
    menuOpen = false
    CurrentAction = 'StanleyShop'
    CurrentActionMsg = Lang:t('open_shop')
    CurrentActionData = {}
    exports['qb-menu']:closeMenu()
end)

RegisterNetEvent('Lenzh_chopshop:client:openMenu')
AddEventHandler('Lenzh_chopshop:client:openMenu', function()
    OpenShopMenu()
end)


-- Key controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentAction ~= nil then
            if IsDriver() then
                if CurrentAction == 'Chopshop' then
                    DrawText3Ds(Config.Zones['Chopshop'].coords.x, Config.Zones['Chopshop'].coords.y, Config.Zones['Chopshop'].coords.z + 0.9, CurrentActionMsg)
                    if IsControlJustReleased(0, 38) then
                        ChopVehicle()
                        CurrentAction = nil
                    end
                end
            elseif CurrentAction == 'StanleyShop' then
                DrawText3Ds(Config.Zones['StanleyShop'].coords.x, Config.Zones['StanleyShop'].coords.y, Config.Zones['StanleyShop'].coords.z + 0.9, CurrentActionMsg)
                if IsControlJustReleased(0, 38) then
                    OpenShopMenu()
                    CurrentAction = nil
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    if Config.NPCEnable == true then
        RequestModel(Config.NPCHash)
        while not HasModelLoaded(Config.NPCHash) do
            Wait(1)
        end

        stanley = CreatePed(1, Config.NPCHash, Config.NPCShop.x, Config.NPCShop.y, Config.NPCShop.z, Config.NPCShop.h, false, true)
        SetBlockingOfNonTemporaryEvents(stanley, true)
        SetPedDiesWhenInjured(stanley, false)
        SetPedCanPlayAmbientAnims(stanley, true)
        SetPedCanRagdollFromPlayerImpact(stanley, false)
        SetEntityInvincible(stanley, true)
        FreezeEntityPosition(stanley, true)
        TaskStartScenarioInPlace(stanley, "WORLD_HUMAN_CLIPBOARD", 0, true);
    end
end)

function ChopVehicle()
    local ped = PlayerPedId()
    if IsPedOnAnyBike(ped) then
        QBCore.Functions.Notify(Lang:t('no_bikes'))
    else
        local seats = MaxSeats(vehicle)
        if seats ~= 0 then
            QBCore.Functions.Notify(Lang:t('Cannot_Chop_Passengers'))
        elseif GetGameTimer() - Timer > Config.CooldownMinutes * 60000 then
            Timer = GetGameTimer()
            QBCore.Functions.TriggerCallback('Lenzh_chopshop:anycops', function(anycops)
                if anycops >= Config.CopsRequired then
                    if Config.CallCops then
                        local randomReport = math.random(1, Config.CallCopsPercent)

                        if randomReport == Config.CallCopsPercent then
                            TriggerEvent('Lenzh_chopshop:StartNotifyPD')
                            pedIsTryingToChopVehicle = true
                        end
                    end
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    ChoppingInProgress = true
                    VehiclePartsRemoval()
                    if not HasAlreadyEnteredMarker then
                        HasAlreadyEnteredMarker = true
                        ChoppingInProgress = false
                        QBCore.Functions.Notify(Lang:t('ZoneLeft'))

                        SetVehicleAlarmTimeLeft(vehicle, 60000)
                    end
                else
                    QBCore.Functions.Notify(Lang:t('not_enough_cops'))
                end
            end)
        else
            local timerNewChop = Config.CooldownMinutes * 60000 - (GetGameTimer() - Timer)
            local TotalTime = math.floor(timerNewChop / 60000)
            if TotalTime >= 0 then
                QBCore.Functions.Notify('Comeback in ' .. TotalTime .. ' minute(s)')
            elseif TotalTime <= 0 then
                QBCore.Functions.Notify(Lang:t('cooldown', { seconds = TotalTime }))
            end
        end
    end
end

function VehiclePartsRemoval()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local rearLeftDoor = GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(-1), false), 'door_dside_r')
    local bonnet = GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(-1), false), 'bonnet')
    local boot = GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(-1), false), 'boot')
    SetVehicleEngineOn(vehicle, false, false, true)
    SetVehicleUndriveable(vehicle, false)
    if ChoppingInProgress == true then
        QBCore.Functions.Notify("Opening Front Left Door", "primary", Config.RemovePart)
        Citizen.Wait(Config.RemovePart)
        SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 0, false, false)
    end
    Citizen.Wait(1000)
    if ChoppingInProgress == true then
        QBCore.Functions.Notify("Removing Front Left Door", "primary", Config.RemovePart)
        Citizen.Wait(Config.RemovePart)
        SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), 0, true)
    end
    Citizen.Wait(1000)
    if ChoppingInProgress == true then
        QBCore.Functions.Notify("Opening Front Right Door", "primary", Config.RemovePart)
        Citizen.Wait(Config.RemovePart)
        SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 1, false, false)
    end
    Citizen.Wait(1000)
    if ChoppingInProgress == true then
        QBCore.Functions.Notify("Removing Front Right Door", "primary", Config.RemovePart)
        Citizen.Wait(Config.RemovePart)
        SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), 1, true)
    end
    Citizen.Wait(1000)
    if rearLeftDoor ~= -1 then
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Opening Rear Left Door", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 2, false, false)
        end
        Citizen.Wait(1000)
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Removing Rear Left Door", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), 2, true)
        end
        Citizen.Wait(1000)
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Opening Rear Right Door", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 3, false, false)
        end
        Citizen.Wait(1000)
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Removing Rear Right Door", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), 3, true)
        end
    end
    Citizen.Wait(1000)
    if bonnet ~= -1 then
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Opening Hood", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 4, false, false)
        end
        Citizen.Wait(1000)
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Removing Hood", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), 4, true)
        end
    end
    Citizen.Wait(1000)
    if boot ~= -1 then
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Opening Trunk", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), 5, false, false)
        end
        Citizen.Wait(1000)
        if ChoppingInProgress == true then
            QBCore.Functions.Notify("Removing Trunk", "primary", Config.RemovePart)
            Citizen.Wait(Config.RemovePart)
            SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), 5, true)
        end
    end
    Citizen.Wait(1000)
    QBCore.Functions.Notify("Let John take care of the car if allowed!")
    Citizen.Wait(Config.RemovePart)
    if ChoppingInProgress == true then
        local vehicle = GetVehiclePedIsUsing(ped)
        if vehicle then
            local vehPlate = GetVehicleNumberPlateText(vehicle)
            QBCore.Functions.TriggerCallback('Lenzh_chopshop:OwnedCar', function(owner)
                if owner then
                    QBCore.Functions.Notify("Your Personal Vehicle is Chopped Successfully...")
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    Citizen.Wait(250)
                    if IsPedInAnyVehicle(ped) then
                        DeleteVehicle(vehicle)
                    end
                else
                    QBCore.Functions.Notify("Vehicle Chopped Successfully...")
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    Citizen.Wait(250)
                    if IsPedInAnyVehicle(ped) then
                        DeleteVehicle(vehicle)
                    end
                end
            end, vehPlate)
        end
        TriggerServerEvent("Lenzh_chopshop:ChopRewards")
    end
end

function OpenShopMenu()
    menuOpen = true
    local menu = {
        {
            header = Lang:t('shop_title'),
            isMenuHeader = true
        }
    }
    QBCore.Functions.TriggerCallback('Lenzh_chopshop:server:getSellableItems', function(sellableItems)
        if sellableItems and #sellableItems > 0 then
            for k, v in pairs(sellableItems) do
                menu[#menu + 1] = {
                    header = v.label,
                    txt = '$' .. v.price,
                    params = {
                        isServer = true,
                        event = 'Lenzh_chopshop:server:sellItem',
                        args = {
                            item = v
                        }
                    }
                }
            end
        else
            QBCore.Functions.Notify(Lang:t('no_items'), 'error')
            return
        end
    end)
    while menu[2] == nil do
        Wait(100)
    end
    menu[#menu + 1] = {
        header = Lang:t('exit_menu'),
        params = {
            event = 'Lenzh_chopshop:client:closeMenu'
        }
    }
    exports['qb-menu']:openMenu(menu)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        Citizen.Wait(3000)
        if pedIsTryingToChopVehicle then
            QBCore.Functions.TriggerCallback('Lenzh_chopshop:server:isWhitelisted', function(isWhitelisted)
                if (isWhitelisted and Config.ShowCopsMisbehave) or not isWhitelisted then
                    DecorSetInt(playerPed, 'Chopping', 2)

                    TriggerServerEvent('Lenzh_chopshop:NotifPos', {
                        x = math.floor(playerCoords.x),
                        y = math.floor(playerCoords.y),
                        z = math.floor(playerCoords.z)
                    })
                end
            end)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        if NetworkIsSessionStarted() then
            DecorRegister('Chopping', 3)
            DecorSetInt(PlayerPedId(), 'Chopping', 1)

            return
        end
    end
end)

RegisterNetEvent('Lenzh_chopshop:StartNotifyPD')
AddEventHandler('Lenzh_chopshop:StartNotifyPD', function()
    TriggerServerEvent('police:server:policeAlert', Lang:t('call'))
    PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
end)

RegisterNetEvent('Lenzh_chopshop:NotifPosProgress')
AddEventHandler('Lenzh_chopshop:NotifPosProgress', function(targetCoords)
    QBCore.Functions.TriggerCallback('Lenzh_chopshop:server:isWhitelisted', function(isWhitelisted)
        if isWhitelisted then
            local alpha = 250
            local ChopBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, 50.0)

            SetBlipHighDetail(ChopBlip, true)
            SetBlipColour(ChopBlip, 17)
            SetBlipAlpha(ChopBlip, alpha)
            SetBlipAsShortRange(ChopBlip, true)

            while alpha ~= 0 do
                Citizen.Wait(5 * 4)
                alpha = alpha - 1
                SetBlipAlpha(ChopBlip, alpha)

                if alpha == 0 then
                    RemoveBlip(ChopBlip)
                    pedIsTryingToChopVehicle = false
                    return
                end
            end
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        if DecorGetInt(PlayerPedId(), 'Chopping') == 2 then
            Citizen.Wait(timing)
            DecorSetInt(PlayerPedId(), 'Chopping', 1)
        end
    end
end)

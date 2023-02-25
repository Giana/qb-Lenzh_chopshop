local QBCore = exports['qb-core']:GetCoreObject()

local Timer, HasAlreadyEnteredMarker, ChoppingInProgress, LastZone, PedIsTryingToChopVehicle, MenuOpen, ProgressBarOpen = 0, false, false, nil, false, false
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local Timing = math.ceil(Config.Timer * 60000)

-- Functions --

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

function CreateBlipCircle(coords, text, radius, color, sprite)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

function OpenShopMenu()
    MenuOpen = true
    local menu = {
        {
            header = Lang:t('shop_title'),
            txt = Lang:t('shop_subtext'),
            isMenuHeader = true
        }
    }
    QBCore.Functions.TriggerCallback('Lenzh_chopshop:server:getSellableItems', function(sellableItems)
        if sellableItems and #sellableItems > 0 then
            for k, v in pairs(sellableItems) do
                if Config.SellAll then
                    menu[#menu + 1] = {
                        header = v.label .. ' (Quantity: ' .. v.amount .. ')',
                        txt = '$' .. v.totalPrice,
                        params = {
                            isServer = true,
                            event = 'Lenzh_chopshop:server:sellItem',
                            args = {
                                item = v
                            }
                        }
                    }
                else
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

function ChopVehicle()
    local ped = PlayerPedId()
    if IsPedOnAnyBike(ped) then
        QBCore.Functions.Notify(Lang:t('no_bikes'), 'error')
    else
        local seats = MaxSeats(vehicle)
        if seats ~= 0 then
            QBCore.Functions.Notify(Lang:t('cannot_chop_passengers'), 'error')
        elseif GetGameTimer() - Timer > Config.CooldownMinutes * 60000 then
            Timer = GetGameTimer()
            QBCore.Functions.TriggerCallback('Lenzh_chopshop:anycops', function(anycops)
                if anycops >= Config.CopsRequired then
                    local randomReport = math.random(1, 100)
                    if randomReport <= Config.CallCopsPercent then
                        TriggerEvent('Lenzh_chopshop:StartNotifyPD')
                        PedIsTryingToChopVehicle = true
                    end
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    ChoppingInProgress = true
                    VehiclePartsRemoval()
                    if not HasAlreadyEnteredMarker then
                        HasAlreadyEnteredMarker = true
                        ChoppingInProgress = false
                        QBCore.Functions.Notify(Lang:t('zoneleft'), 'error')
                        SetVehicleAlarmTimeLeft(vehicle, 60000)
                    end
                else
                    QBCore.Functions.Notify(Lang:t('not_enough_cops'), 'error')
                end
            end)
        else
            local timerNewChop = Config.CooldownMinutes * 60000 - (GetGameTimer() - Timer)
            local TotalTime = math.floor(timerNewChop / 60000)
            if TotalTime > 0 then
                QBCore.Functions.Notify(Lang:t('come_back_in', { minutes = TotalTime }), 'error')
            elseif TotalTime <= 0 then
                QBCore.Functions.Notify(Lang:t('minute'), 'error')
            end
        end
    end
end

function TriggerPartsRemovalProgressBar(message, action, doorIndex)
    local ped = PlayerPedId()
    while ProgressBarOpen do
        Citizen.Wait(250)
    end
    ProgressBarOpen = true
    QBCore.Functions.Progressbar('remove_parts', message, Config.RemovePart * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        -- Done
        if action == 'opening' then
            SetVehicleDoorOpen(GetVehiclePedIsIn(ped, false), doorIndex, false, false)
        elseif action == 'removing' then
            SetVehicleDoorBroken(GetVehiclePedIsIn(ped, false), doorIndex, true)
        else
            QBCore.Functions.Notify(Lang:t('invalid_action'), 'error')
        end
        Citizen.Wait(500)
        ClearPedTasks(ped)
        ClearPedSecondaryTask(ped)
        FreezeEntityPosition(ped, false)
        ProgressBarOpen = false
    end, function()
        -- Cancel
        ClearPedTasks(ped)
        ClearPedSecondaryTask(ped)
        FreezeEntityPosition(ped, false)
        ProgressBarOpen = false
    end)
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
        TriggerPartsRemovalProgressBar(Lang:t('opening_front_left'), 'opening', 0)
    end
    if ChoppingInProgress == true then
        TriggerPartsRemovalProgressBar(Lang:t('removing_front_left'), 'removing', 0)
    end
    if ChoppingInProgress == true then
        TriggerPartsRemovalProgressBar(Lang:t('opening_front_right'), 'opening', 1)
    end
    if ChoppingInProgress == true then
        TriggerPartsRemovalProgressBar(Lang:t('removing_front_right'), 'removing', 1)
    end
    if rearLeftDoor ~= -1 then
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('opening_rear_left'), 'opening', 2)
        end
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('removing_rear_left'), 'removing', 2)
        end
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('opening_rear_right'), 'opening', 3)
        end
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('removing_rear_right'), 'removing', 3)
        end
    end
    if bonnet ~= -1 then
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('opening_hood'), 'opening', 4)
        end
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('removing_hood'), 'removing', 4)
        end
    end
    if boot ~= -1 then
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('opening_trunk'), 'opening', 5)
        end
        if ChoppingInProgress == true then
            TriggerPartsRemovalProgressBar(Lang:t('removing_trunk'), 'removing', 5)
        end
    end
    Citizen.Wait(Config.RemovePart * 1000 + 1000)
    if ChoppingInProgress == true then
        local vehicle = GetVehiclePedIsUsing(ped)
        if vehicle then
            local vehPlate = GetVehicleNumberPlateText(vehicle)
            QBCore.Functions.TriggerCallback('Lenzh_chopshop:OwnedCar', function(owner)
                if owner then
                    QBCore.Functions.Notify(Lang:t('owned_chopped_success'), 'success')
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    Citizen.Wait(250)
                    if IsPedInAnyVehicle(ped) then
                        DeleteVehicle(vehicle)
                    end
                else
                    QBCore.Functions.Notify(Lang:t('chopped_success'), 'success')
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    Citizen.Wait(250)
                    if IsPedInAnyVehicle(ped) then
                        DeleteVehicle(vehicle)
                    end
                end
            end, vehPlate)
        end
        TriggerServerEvent('Lenzh_chopshop:ChopRewards')
    end
end

-- Events --

RegisterNetEvent('Lenzh_chopshop:StartNotifyPD')
AddEventHandler('Lenzh_chopshop:StartNotifyPD', function()
    TriggerServerEvent('police:server:policeAlert', Lang:t('call'))
    PlaySoundFrontend(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', 0)
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
                    PedIsTryingToChopVehicle = false
                    return
                end
            end
        end
    end)
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
    if MenuOpen then
        exports['qb-menu']:closeMenu()
        exports['qb-core']:HideText()
    end
    CurrentAction = nil
end)

AddEventHandler('Lenzh_chopshop:client:closeMenu', function()
    MenuOpen = false
    CurrentAction = 'StanleyShop'
    CurrentActionMsg = Lang:t('open_shop')
    CurrentActionData = {}
    exports['qb-menu']:closeMenu()
end)

RegisterNetEvent('Lenzh_chopshop:client:openMenu')
AddEventHandler('Lenzh_chopshop:client:openMenu', function()
    OpenShopMenu()
end)

-- Threads --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        Citizen.Wait(3000)
        if PedIsTryingToChopVehicle then
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
        Citizen.Wait(2000)
        if DecorGetInt(PlayerPedId(), 'Chopping') == 2 then
            Citizen.Wait(Timing)
            DecorSetInt(PlayerPedId(), 'Chopping', 1)
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

Citizen.CreateThread(function()
    if Config.EnableBlips == true then
        for k, zone in pairs(Config.Zones) do
            CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
        end
    end
end)

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

-- Enter / Exit marker events
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInMarker = false
        local currentZone = nil
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
        TaskStartScenarioInPlace(stanley, 'WORLD_HUMAN_CLIPBOARD', 0, true);
    end
end)
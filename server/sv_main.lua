local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('Lenzh_chopshop:anycops', function(source, cb)
    local policeCount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            policeCount = policeCount + 1
        end
    end
    cb(policeCount)
end)

RegisterServerEvent('Lenzh_chopshop:NotifPos')
AddEventHandler('Lenzh_chopshop:NotifPos', function(targetCoords)
    TriggerClientEvent('Lenzh_chopshop:NotifPosProgress', -1, targetCoords)
end)

RegisterServerEvent("Lenzh_chopshop:ChopRewards")
AddEventHandler("Lenzh_chopshop:ChopRewards", function(rewards)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    for i = 1, 3, 1 do
        local chance = math.random(1, #Config.Items)
        local amount = math.random(1, 3)
        local myItem = Config.Items[chance]

        if xPlayer.Functions.AddItem(myItem, amount) then
            TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items[myItem], 'add', amount)
        else
            TriggerClientEvent('QBCore:Notify', _source, 'You cannot carry anymore!', 'error')
        end
    end
end)

QBCore.Functions.CreateCallback('Lenzh_chopshop:OwnedCar', function(source, cb, plate)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?', { plate, xPlayer.PlayerData.citizenid })
    if result ~= nil and result[1] ~= nil and Config.AnyoneCanChop == true then
        Citizen.Wait(5)
        MySQL.query('DELETE FROM player_vehicles WHERE plate = ?', { plate })
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('Lenzh_chopshop:server:sellItem')
AddEventHandler('Lenzh_chopshop:server:sellItem', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local item = data.item
    if player.Functions.RemoveItem(item.name, 1) then
        if Config.GiveBlack then
            if not player.Functions.AddMoney('black_money', item.price) then
                player.Functions.AddItem(item.name, 1)
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error_selling'), 'error')
                return
            end
        else
            if not player.Functions.AddMoney('cash', item.price) then
                player.Functions.AddItem(item.name, 1)
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error_selling'), 'error')
                return
            end
        end
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'remove', 1)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('not_enough'), 'error')
    end
    TriggerClientEvent('Lenzh_chopshop:client:openMenu', src)
end)

QBCore.Functions.CreateCallback('Lenzh_chopshop:server:getSellableItems', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local items = {}
    for k, v in pairs(Config.Items) do
        local hasItem = player.Functions.GetItemByName(v)
        if hasItem and hasItem.amount > 0 then
            local item = {}
            item.name = v
            item.label = QBCore.Shared.Items[v]['label']
            item.price = Config.ItemsPrices[v]
            table.insert(items, item)
        end
    end
    cb(items)
end)

QBCore.Functions.CreateCallback('Lenzh_chopshop:server:isWhitelisted', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local playerData = player.PlayerData
    if not playerData or not playerData.job then
        cb(false)
    end
    for k, v in ipairs(Config.WhitelistedCops) do
        if v == playerData.job.name then
            cb(true)
        end
    end
    cb(false)
end)
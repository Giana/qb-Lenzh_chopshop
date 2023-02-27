local QBCore = exports['qb-core']:GetCoreObject()

-- Functions --

function rewardItems(source, items)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    for k, v in pairs(items) do
        if Config.SellAll then
            player.Functions.AddItem(v.name, v.totalAmount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.name], 'add', v.totalAmount)
        else
            player.Functions.AddItem(v.name, v.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.name], 'add', v.amount)
        end
    end
end

-- Events --

RegisterServerEvent('Lenzh_chopshop:NotifPos')
AddEventHandler('Lenzh_chopshop:NotifPos', function(targetCoords)
    TriggerClientEvent('Lenzh_chopshop:NotifPosProgress', -1, targetCoords)
end)

RegisterServerEvent('Lenzh_chopshop:ChopRewards')
AddEventHandler('Lenzh_chopshop:ChopRewards', function(rewards)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    for i = 1, 3, 1 do
        local chance = math.random(1, #Config.Items)
        local amount = math.random(1, 3)
        local myItem = Config.Items[chance].name

        if player.Functions.AddItem(myItem, amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[myItem], 'add', amount)
        else
            TriggerClientEvent('QBCore:Notify', src, 'You cannot carry anymore!', 'error')
        end
    end
end)

RegisterServerEvent('Lenzh_chopshop:server:sellItem')
AddEventHandler('Lenzh_chopshop:server:sellItem', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local item = data.item
    if Config.SellAll then
        if player.Functions.RemoveItem(item.name, item.amount) then
            if not player.Functions.AddMoney(Config.MoneyType, item.totalPrice) then
                player.Functions.AddItem(item.name, item.amount)
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error_selling'), 'error')
                return
            end
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'remove', 1)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('not_enough'), 'error')
        end
    else
        if player.Functions.RemoveItem(item.name, 1) then
            if not player.Functions.AddMoney(Config.MoneyType, item.price) then
                player.Functions.AddItem(item.name, 1)
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error_selling'), 'error')
                return
            end
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'remove', 1)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('not_enough'), 'error')
        end
    end
    if item.rewardItems and #item.rewardItems > 0 then
        rewardItems(src, item.rewardItems)
    end
    TriggerClientEvent('Lenzh_chopshop:client:openMenu', src)
end)

-- Callbacks --

QBCore.Functions.CreateCallback('Lenzh_chopshop:anycops', function(source, cb)
    local policeCount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            policeCount = policeCount + 1
        end
    end
    cb(policeCount)
end)

QBCore.Functions.CreateCallback('Lenzh_chopshop:OwnedCar', function(source, cb, plate)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?', { plate, player.PlayerData.citizenid })
    if result ~= nil and result[1] ~= nil and Config.OwnedCarsPermaDeleted == true then
        Citizen.Wait(5)
        MySQL.query('DELETE FROM player_vehicles WHERE plate = ?', { plate })
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('Lenzh_chopshop:server:getSellableItems', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local items = {}
    for k, v in pairs(Config.Items) do
        local hasItem = player.Functions.GetItemByName(v.name)
        if hasItem and hasItem.amount > 0 then
            local item = {}
            local rewardItems = {}
            item.name = v.name
            item.label = QBCore.Shared.Items[v.name]['label']
            item.price = v.price
            item.amount = hasItem.amount
            item.totalPrice = hasItem.amount * v.price
            if Config.EnableItemRewards then
                for k2, v2 in pairs(v.item_sale_rewards) do
                    if v2 > 0 then
                        local rewardItem = {}
                        rewardItem.name = k2
                        rewardItem.amount = v2
                        rewardItem.totalAmount = v2 * item.amount
                        table.insert(rewardItems, rewardItem)
                    end
                end
            end
            item.rewardItems = rewardItems
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
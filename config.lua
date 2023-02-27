Config = {}

Config.DrawDistance = 50.0                                          -- Distance before marker is visible (lower number == better performance)
Config.MarkerType = 27                                              -- Marker type
Config.MarkerColor = { r = 255, g = 0, b = 0 }                      -- Marker color

Config.Timer = 2                                                    -- Minutes player is marked after chopping

Config.CooldownMinutes = 10                                         -- Minimum cooldown between chops

Config.CallCopsPercent = 25                                         -- Percentage chance cops are called for chopping
Config.CopsRequired = 1                                             -- Cops required on duty to chop
Config.ShowCopsMisbehave = true                                     -- Notify when cops steal, too

Config.NPCEnable = true                                             -- true == NPC at shop location, false == no NPC at shop location
Config.NPCHash = 68070371                                           -- NPC ped hash
Config.NPCShop = { x = -55.42, y = 6392.8, z = 30.5, h = 46.0 }     -- Location of NPC for shop

Config.RemovePart = 2                    -- Seconds to remove part

Config.EnableItemRewards = true          -- true == item rewards for selling enabled, false == item rewards for selling disabled
Config.SellAll = true                    -- true == sell all of item when clicked in menu, false == sell 1 of item when clicked in menu
Config.MoneyType = 'cash'                -- Money type to reward for sold parts

-- CAUTION: SETTING BELOW TO TRUE IS DANGEROUS, PLEASE READ NOTE --
Config.OwnedCarsPermaDeleted = false     -- true == owned/personal cars chopped are permanently deleted from player_vehicles table in database, false == owned/personal cars chopped are NOT deleted from player_vehicles table in database

Config.Zones = {
    Chopshop = { coords = vector3(-555.22, -1697.99, 18.75 + 0.99), markerEnabled = true, blipEnabled = true, name = Lang:t('map_blip'), color = 49, sprite = 225, radius = 100.0, Pos = { x = -555.22, y = -1697.99, z = 19.13 - 0.95 }, Size = { x = 5.0, y = 5.0, z = 0.5 }, },
    StanleyShop = { coords = vector3(-55.42, 6392.8, 30.5), markerEnabled = true, blipEnabled = true, name = Lang:t('map_blip_shop'), color = 50, sprite = 120, radius = 25.0, Pos = { x = -55.42, y = 6392.8, z = 30.5 }, Size = { x = 3.0, y = 3.0, z = 1.0 }, },
}

--[[
    For each Config.Items[x]:
    - name: Name of item reward for chopping
    - price: Sale price
    - item_sale_rewards:
        - ['itemName'] (name of item) = itemAmount (amount of item to reward per 1 parent item sold)
    - Example:
        - [10] = {
              name = 'car_radio',
              price = math.random(170, 230),
              item_sale_rewards = {
                  ['plastic'] = math.random(0, 1),
                  ['aluminum'] = 3
               }
           }
            - For every 'car_radio' item sold, $170-$230 will be rewarded, plus 0-1 'plastic' and 3 'aluminum' (if Config.EnableItemRewards == true)
]]
Config.Items = {
    [1] = {
        name = 'battery',
        price = math.random(40, 60),
        item_sale_rewards = {
            ['plastic'] = math.random(0, 1)
        }
    },
    [2] = {
        name = 'muffler',
        price = math.random(160, 200),
        item_sale_rewards = {
            ['metalscrap'] = math.random(0, 1)
        }
    },
    [3] = {
        name = 'hood',
        price = math.random(245, 365),
        item_sale_rewards = {
            ['steel'] = math.random(0, 1)
        }
    },
    [4] = {
        name = 'trunk',
        price = math.random(260, 340),
        item_sale_rewards = {
            ['steel'] = math.random(0, 1)
        }
    },
    [5] = {
        name = 'doors',
        price = math.random(165, 205),
        item_sale_rewards = {
            ['steel'] = math.random(0, 1),
            ['glass'] = math.random(0, 1)
        }
    },
    [6] = {
        name = 'engine',
        price = math.random(610, 750),
        item_sale_rewards = {
            ['plastic'] = math.random(0, 1),
            ['metalscrap'] = math.random(0, 1),
            ['copper'] = math.random(0, 1),
            ['aluminum'] = math.random(0, 1),
            ['iron'] = math.random(0, 1),
            ['steel'] = math.random(0, 1),
            ['rubber'] = math.random(0, 1)
        }
    },
    [7] = {
        name = 'waterpump',
        price = math.random(230, 290),
        item_sale_rewards = {
            ['aluminum'] = math.random(0, 1)
        }
    },
    [8] = {
        name = 'oilpump',
        price = math.random(210, 270),
        item_sale_rewards = {
            ['steel'] = math.random(0, 1)
        }
    },
    [9] = {
        name = 'speakers',
        price = math.random(145, 185),
        item_sale_rewards = {
            ['plastic'] = math.random(0, 1),
            ['metalscrap'] = math.random(0, 1)
        }
    },
    [10] = {
        name = 'car_radio',
        price = math.random(170, 230),
        item_sale_rewards = {
            ['plastic'] = math.random(0, 1),
            ['aluminum'] = math.random(0, 1)
        }
    },
    [11] = {
        name = 'rims',
        price = math.random(620, 780),
        item_sale_rewards = {
            ['aluminum'] = math.random(0, 1)
        }
    },
    [12] = {
        name = 'subwoofer',
        price = math.random(100, 140),
        item_sale_rewards = {
            ['plastic'] = math.random(0, 1),
            ['metalscrap'] = math.random(0, 1)
        }
    },
    [13] = {
        name = 'steeringwheel',
        price = math.random(80, 120),
        item_sale_rewards = {
            ['plastic'] = math.random(0, 1),
            ['steel'] = math.random(0, 1)
        }
    },
}

-- Whitelisted police jobs
Config.WhitelistedCops = {
    'police'
}
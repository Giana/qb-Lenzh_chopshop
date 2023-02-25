Config = {}

Config.DrawDistance = 50.0                                          -- Distance before marker is visible (lower number == better performance)
Config.EnableBlips = true                                           -- true == blips, false == no blips
Config.MarkerType = 27                                              -- Marker type
Config.MarkerColor = { r = 255, g = 0, b = 0 }                      -- Marker color

Config.Timer = 2                                                    -- Minutes player is marked after chopping

Config.CooldownMinutes = 1                                         -- Minimum cooldown between chops

Config.CallCopsPercent = 25                                         -- Percentage chance cops are called for chopping
Config.CopsRequired = 1                                             -- Cops required on duty to chop
Config.ShowCopsMisbehave = true                                     -- Notify when cops steal, too

Config.NPCEnable = true                                             -- true == NPC at shop location, false == no NPC at shop location
Config.NPCHash = 68070371                                           -- NPC ped hash
Config.NPCShop = { x = -55.42, y = 6392.8, z = 30.5, h = 46.0 }     -- Location of NPC for shop

Config.RemovePart = 2           -- Seconds to remove part

Config.SellAll = true                    -- true == sell all of item when clicked in menu, false == sell 1 of item when clicked in menu
Config.MoneyType = 'cash'                -- Money type to reward for sold parts

-- CAUTION: SETTING BELOW TO TRUE IS DANGEROUS, PLEASE READ NOTE --
Config.OwnedCarsPermaDeleted = false     -- true == owned/personal cars chopped are permanently deleted from player_vehicles table in database, false == owned/personal cars chopped are NOT deleted from player_vehicles table in database

Config.Zones = {
    Chopshop = { coords = vector3(-555.22, -1697.99, 18.75 + 0.99), name = Lang:t('map_blip'), color = 49, sprite = 225, radius = 100.0, Pos = { x = -555.22, y = -1697.99, z = 19.13 - 0.95 }, Size = { x = 5.0, y = 5.0, z = 0.5 }, },
    StanleyShop = { coords = vector3(-55.42, 6392.8, 30.5), name = Lang:t('map_blip_shop'), color = 50, sprite = 120, radius = 25.0, Pos = { x = -55.42, y = 6392.8, z = 30.5 }, Size = { x = 3.0, y = 3.0, z = 1.0 }, },
}

-- Item rewards
Config.Items = {
    'battery',
    'muffler',
    'hood',
    'trunk',
    'doors',
    'engine',
    'waterpump',
    'oilpump',
    'speakers',
    'car_radio',
    'rims',
    'subwoofer',
    'steeringwheel'
}

-- Item reward sale prices
Config.ItemsPrices = {
    battery = 50,
    muffler = 180,
    hood = 325,
    trunk = 300,
    doors = 185,
    engine = 680,
    waterpump = 260,
    oilpump = 240,
    speakers = 165,
    car_radio = 200,
    rims = 700,
    subwoofer = 120,
    steeringwheel = 100
}
-- Whitelisted police jobs
Config.WhitelistedCops = {
    'police'
}
local Translations = {
  press_to_chop = "~g~E~w~ - Chop Vehicle",
  map_blip = "Chop Shop",
  map_blip_shop = "Stanley's Car Parts",
  no_vehicle = "Must be in a vehicle to chop.",
  open_shop = "~g~E~w~ - Access Store",
  sold = "you\'ve sold ~b~%sx~s~ ~y~%s~s~ for ~g~$%s~s~",
  not_enough = 'you don\'t have enough of that to sell!',
  shop_prompt = 'press ~INPUT_CONTEXT~ to talk with ~r~Stanley~s~.',
  item = '$%{item}',
  shop_title = 'Stanley\'s Car Parts',
  cooldown = '~s~You have to ~g~wait ~r~%{seconds} secondes ~s~before you can ~g~chop ~s~another vehicle.',
  call = 'Someone is Chopping a vehicle.',
  x911 = '911 Call',
  chop = 'Car Chopping',
  not_enough_cops = 'Not enough cops in service',
  Cannot_Chop_Passengers = '[^1Chopshop^0]: Cannot chop with passengers',
  ZoneLeft = 'You Left The Zone. No Rewards For You',
  ZoneLeftWhileChop = 'You Left The Zone. Go Back In The Zone',
  no = 'no',
  yes = 'yes',
  shop_confirm = 'Sell %{arg1}x %{arg2} for $%{arg3}?',
  sellall = 'Sell All??',
  got_location = 'The police has your location.. RUN!',
  no_bikes = 'Bikes are not allowed',
  no_items = 'You have no sellable items!',
  exit_menu = '✖ Exit',
  error_selling = 'Error selling item'
}

Lang = Locale:new({
  phrases = Translations,
  warnOnMissing = true
})

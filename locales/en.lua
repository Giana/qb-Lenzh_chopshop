local Translations = {
    press_to_chop = '~g~E~w~ - Chop Vehicle',
    map_blip = 'Chop Shop',
    map_blip_shop = 'Stanley\'s Car Parts',
    no_vehicle = 'Must be in a vehicle to chop',
    open_shop = '~g~E~w~ - Access Store',
    not_enough = 'You do not have enough of that to sell!',
    shop_title = 'Stanley\'s Car Parts',
    shop_subtext = 'Sell your car parts here!',
    shop_subtext_rewards = 'Sell your car parts here! We might have some items to trade, too.',
    come_back_in = 'Come back in %{minutes} minute(s)',
    minute = 'Come back in less than a minute',
    call = 'Vehicle chopping in progress',
    not_enough_cops = 'Not enough cops',
    cannot_chop_passengers = 'You cannot chop with passengers!',
    zoneleft = 'You left the zone!',
    no_bikes = 'Bikes are not allowed',
    no_items = 'You have no sellable items!',
    exit_menu = '✖ Exit',
    error_selling = 'Error selling item',
    invalid_action = 'Invalid action',
    opening_front_left = 'Opening front left door...',
    removing_front_left = 'Removing front left door...',
    opening_front_right = 'Opening front right door...',
    removing_front_right = 'Removing front right door...',
    opening_rear_left = 'Opening rear left door...',
    removing_rear_left = 'Removing rear left door...',
    opening_rear_right = 'Opening rear right door...',
    removing_rear_right = 'Removing rear right door...',
    opening_hood = 'Opening hood...',
    removing_hood = 'Removing hood...',
    opening_trunk = 'Opening trunk...',
    removing_trunk = 'Removing trunk...',
    chopped_success = 'Vehicle chopped successfully! Let John take care of the rest of the car.',
    owned_chopped_success = 'Owned vehicle chopped successfully! Let John take care of the rest of the car.',
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
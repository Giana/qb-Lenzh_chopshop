-- compatibility wrapper
fx_version 'cerulean'
game 'gta5'

description 'Lenzh Chop Shop'
author 'Lenzh - Converted to QB by Giana (github.com/Giana)'
version 'v2'

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/sv_main.lua'
}

client_scripts {
	'client/cl_main.lua',
}

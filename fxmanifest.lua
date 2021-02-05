fx_version 'cerulean'

games{'rdm3','gta5'}

author 'Adrian Rodriguez'
descripcion 'This a basic new system where you can get diferent licences. For example: driving licence, motocycle licence etc...'

ui_page 'notifications/notifications.html'

client_script {
    '@es_extended/locale.lua',
    'locales/es.lua',
    'config.lua',
    'client/main-client.lua',
}

server_script {
    '@es_extended/locale.lua',
    'locales/es.lua',
    'config.lua',
    'server/main-server.lua',
}

files {
    'notifications/notifications.html',
    'notifications/style.css',
    'notifications/notifications.js',
    'notifications/DMV_Logo.png'
}

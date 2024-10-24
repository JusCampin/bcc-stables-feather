fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'BCC @Apollyon'

shared_scripts {
    'config/*.lua',
    'language/imports.lua',
    'language/*.lua'
}

client_scripts {
    'client/imports.lua',
    'client/dataview.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/imports.lua',
    'server/main.lua'
}

ui_page {
    'ui/index.html'
}

files {
    "ui/index.html",
    "ui/js/*.*",
    "ui/css/*.*",
    "ui/fonts/*.*",
    "ui/img/*.*"
}

name 'bcc-stables'
version '1.0.0'
github_version_check 'true'
github_version_type 'file'
github_link 'https://github.com/JusCampin/bcc-stables-feather'

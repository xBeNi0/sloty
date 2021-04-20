resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page 'html/ui.html'

client_scripts {
	'config.lua',
	'client/*.lua'
}

server_scripts {
	'server.lua'
}

files {
  'html/ui.html',
  'html/script.js',
  'html/design.css',
  -- Images
  'html/img/*.png',
  -- Audio
  'html/audio/*.wav',
}

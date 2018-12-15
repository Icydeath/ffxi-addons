info.skillchain = {}
info.skillchain.tier1 = S{'Transfixion','Compression','Liquefaction','Scission','Reverberation','Detonation','Induration','Impaction'}
info.skillchain.tier2 = S{'Gravitation','Distortion','Fusion','Fragmentation'}
info.skillchain.tier3 = S{'Dark','Light'}

info.skillchain['Transfixion'] = {}
info.skillchain['Transfixion'].element = 'Light (lv1)'
info.skillchain['Transfixion'].MB = 'Light'
info.skillchain['Transfixion'].lvl = 1

info.skillchain['Compression'] = {}
info.skillchain['Compression'].element = 'Darkness (lv1)'
info.skillchain['Compression'].MB = 'Dark'
info.skillchain['Compression'].lvl = 1

info.skillchain['Liquefaction'] = {}
info.skillchain['Liquefaction'].element = 'Fire'
info.skillchain['Liquefaction'].MB = 'Fire'
info.skillchain['Liquefaction'].lvl = 1

info.skillchain['Scission'] = {}
info.skillchain['Scission'].element = 'Earth'
info.skillchain['Scission'].MB = 'Stone'
info.skillchain['Scission'].lvl = 1

info.skillchain['Reverberation'] = {}
info.skillchain['Reverberation'].element = 'Water'
info.skillchain['Reverberation'].MB = 'Water'
info.skillchain['Reverberation'].lvl = 1

info.skillchain['Detonation'] = {}
info.skillchain['Detonation'].element = 'Wind'
info.skillchain['Detonation'].MB = 'Aero'
info.skillchain['Detonation'].lvl = 1

info.skillchain['Induration'] = {}
info.skillchain['Induration'].element = 'Ice'
info.skillchain['Induration'].MB = 'Blizzard'
info.skillchain['Induration'].lvl = 1

info.skillchain['Impaction'] = {}
info.skillchain['Impaction'].element = 'Lightning'
info.skillchain['Impaction'].MB = 'Thunder'
info.skillchain['Impaction'].lvl = 1


info.skillchain['Distortion'] = {}
info.skillchain['Distortion'].element = 'Water / Ice'
info.skillchain['Distortion'].MB = 'Water / Blizzard'
info.skillchain['Distortion'].lvl = 2

info.skillchain['Fusion'] = {}
info.skillchain['Fusion'].element = 'Fire / Light'
info.skillchain['Fusion'].MB = 'Fire / Light'
info.skillchain['Fusion'].lvl = 2

info.skillchain['Fragmentation'] = {}
info.skillchain['Fragmentation'].element = 'Wind / Thunder'
info.skillchain['Fragmentation'].MB = 'Aero / Thunder'
info.skillchain['Fragmentation'].lvl = 2

info.skillchain['Gravitation'] = {}
info.skillchain['Gravitation'].element = 'Earth / Darkness'
info.skillchain['Gravitation'].MB = 'Stone / Dark'
info.skillchain['Gravitation'].lvl = 2

info.skillchain['Light'] = {}
info.skillchain['Light'].element = 'Light (lv3)'
info.skillchain['Light'].MB = 'Fire / Aero / Thunder / Light'
info.skillchain['Light'].lvl = 2

info.skillchain['Dark'] = {}
info.skillchain['Dark'].element = 'Darkness (lv3)'
info.skillchain['Dark'].MB = 'Stone / Water / Blizzard / Dark'
info.skillchain['Dark'].lvl = 2

--[[
Comment gérer les cas avec plusieurs choix ?
info.skillchain.open = {
  ['Transfixion'] = 'Compression',
  ['Compression'] = 'Transfixion',
  ['Scission'] = 'Detonation',
  ['Reverberation'] = 'Transfixion',
  ['Detonation'] = 'Aero',
  ['Liquefaction'] = 'Fire',
  ['Induration'] = 'Blizzard',
  ['Impaction'] = 'Thunder'
}
info.skillchain.open2 = {
  ['Compression'] = 'Induration',
  ['Reverberation'] = 'Scission',
  ['Scission'] = 'Liquefaction',
}
info.skillchain.close = {
  ['Transfixion'] = 'Transfixion',
  ['Compression'] = 'Compression',
  ['Scission'] = 'Scission',
  ['Reverberation'] = 'Reverberation',
  ['Detonation'] = 'Detonation',
  ['Liquefaction'] = 'Liquefaction',
  ['Induration'] = 'Induration',
  ['Impaction'] = 'Impaction'
}
--]]
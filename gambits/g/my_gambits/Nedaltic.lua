gambits = {}

gambits["RDM"] = {
  {"SELF","STATUS","Paralyzed","JA","Healing Waltz"},
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"AND",{{"SELF","STATUS","Silence"},{"SELF","NOT_STATUS","Amnesia"}},"","JA","Healing Waltz"},
  {"SELF","STATUS","Silence","ITEM","Echo Drops"},
  {"PARTY","HPP <=",75,"MA","Cure IV"},
  {"SELF","HPP <=",75,"JA","Curing Waltz III"},
  {"PARTY","HPP <=",75,"MA","Cure III"},
  {"SELF","NOT_STATUS","Composure","JA","Composure"},
  {"SELF","NOT_STATUS","Refresh","MA","Refresh II"},
  {"SELF","NOT_STATUS","Refresh","MA","Refresh"},
  {"SELF","NOT_STATUS","Protect","MA","Protect V"},
  {"SELF","NOT_STATUS","Haste","MA","Haste II"},
  {"SELF","NOT_STATUS","Multi Strikes","MA","Temper"},
  {"SELF","NOT_STATUS","Enwater","MA","Enwater"},
  {"SELF","NOT_STATUS","Shell","MA","Shell V"},
  {"AND",{{"SELF","TP >=",1000},{"SELF","HPP >",75}},"","WS","Savage Blade"}
}

gambits["BLM"] = {
  {"SELF","CAN_MB","Lightning","MA","Thunder VI"},
  {"SELF","CAN_MB","Lightning","MA","Thunder V"},
  {"SELF","CAN_MB","Fire","MA","Fire VI"},
  {"SELF","CAN_MB","Fire","MA","Fire V"},
  {"SELF","CAN_MB","Wind","MA","Aero VI"},
  {"SELF","CAN_MB","Wind","MA","Aero V"},
  {"SELF","CAN_MB","Ice","MA","Blizzard VI"},
  {"SELF","CAN_MB","Ice","MA","Blizzard V"},
  {"SELF","CAN_MB","Earth","MA","Stone VI"},
  {"SELF","CAN_MB","Earth","MA","Stone V"},
  --[[
  {"ENEMY","READYING","Extremely Bad Breath","MA","Stun"},
  {"ENEMY","READYING","Deathly Glare","MA","Stun"},
  {"ENEMY","READYING","Danse Macabre","MA","Stun"},
  {"ENEMY","READYING","Tainting Breath","MA","Stun"},
  {"ENEMY","READYING","Vampiric Lash","MA","Stun"},
  {"ENEMY","READYING","Static Prison","MA","Stun"},
  {"ENEMY","CASTING","Benthic Typhoon","MA","Stun"},
  {"ENEMY","READYING","Thousand Spears","MA","Stun"},
  {"ENEMY","READYING","Infernal Bulwark","MA","Stun"},
  {"ENEMY","READYING","Mayhem Lantern","MA","Stun"},
  {"ENEMY","READYING","Hell Scissors","MA","Stun"},
  --]]
  {"SELF","NOT_STATUS","Haste","MA","Haste"},
  {"SELF","MA_READY","Fire","MA","Fire"},
  --{"PARTY","NOT_STATUS","Refresh","MA","Refresh"}
  --{"SELF","NOT_ASSISTING","Minisub","ASSIST",""},
  --{"SELF","CAN_SC","Light","MA","Thunder VI"},
  --{"SELF","CAN_SC","Light","MA","Thunder V"},
  --{"SELF","CAN_SC","Light","MA","Aero VI"},
  --{"SELF","CAN_SC","Light","MA","Aero V"}
}

gambits["THF"] = {
  {"SELF","STATUS","Paralyzed","JA","Healing Waltz"},
  {"PARTY","HPP <=",75,"JA","Curing Waltz III"},
  {"AND",{{"SELF","TP >=",1000},{"SELF","HPP >",75}},"","WS","Rudra's Storm"}
}

return gambits
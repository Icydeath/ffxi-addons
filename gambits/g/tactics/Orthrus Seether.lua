tactics = {}

tactics["THF"] = {
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"}
}
tactics["DNC"] = {
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"}
  --{"SELF","NOT_STATUS",385,"JA",239}, --- 5 Steps, No Foot Rise
  --{"SELF","NOT_STATUS","Saber Dance","JA","Saber Dance"} --- Saber Dance
}
tactics["RDM"] = {
  {"SELF","STATUS","Paralyzed","JA","Healing Waltz"},
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"AND",{{"SELF","STATUS","Silence"},{"SELF","NOT_STATUS","Amnesia"}},"","JA","Healing Waltz"},
  {"SELF","STATUS","Silence","ITEM","Echo Drops"},
  {"PARTY","HPP <=",80,"MA","Cure IV"},
  {"SELF","HPP <=",80,"JA","Curing Waltz III"},
  {"SELF","NOT_STATUS","Refresh","MA","Refresh II"},
  {"SELF","NOT_STATUS","Refresh","MA","Refresh"},
  {"SELF","NOT_STATUS","Haste","MA","Haste II"},
  {"SELF","NOT_STATUS","Multi Strikes","MA","Temper"},
  {"SELF","NOT_STATUS","Protect","MA","Protect V"},
  {"SELF","NOT_STATUS","Shell","MA","Shell V"},
  {"SELF","NOT_STATUS","Barparalyze","MA","Barparalyze"},
  {"SELF","NOT_STATUS","Enwater","MA","Enwater"},
  {"AND",{{"SELF","TP >=",1000},{"SELF","HPP >",80}},"","WS","Requiescat"}
}
return tactics
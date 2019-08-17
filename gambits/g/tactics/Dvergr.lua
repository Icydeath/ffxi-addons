tactics = {}

gambits["DRG"] = {
  {"SELF","NOT_STATUS","Defender","JA","Defender"},
  {"SELF","NOT_STATUS","Aggressor","JA","Aggressor"},
  {"SELF","JA_READY","Provoke","JA","Provoke"}
}
tactics["THF"] = {
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"},
  {"SELF","SHADOWS <",1,"MA","Utsusemi: Ni"},
  {"SELF","SHADOWS <",2,"MA","Utsusemi: Ichi"},
  {"SELF","TP >=",1000,"WS","Rudra's Storm"}
}
tactics["DNC"] = {
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"SELF","SHADOWS <",1,"MA","Utsusemi: Ni"},
  {"SELF","SHADOWS <",2,"MA","Utsusemi: Ichi"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"},
  {"SELF","TP >=",1000,"WS","Rudra's Storm"}
}
tactics["RDM"] = {
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"},
  {"SELF","TP >=",1000,"WS","Vorpal Blade"}
}
return tactics
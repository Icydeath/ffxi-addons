tactics = {}

gambits["DRG"] = {
  {"SELF","NOT_STATUS","Defender","JA","Defender"},
  {"SELF","NOT_STATUS","Aggressor","JA","Aggressor"},
  {"SELF","JA_READY","Provoke","JA","Provoke"}
}
tactics["DNC"] = {
  {"ENEMY","CASTING","Firaga IV","JA","Violent Flourish"},
  {"ENEMY","CASTING","Blizzaga IV","JA","Violent Flourish"},
  {"ENEMY","CASTING","Aeroga IV","JA","Violent Flourish"},
  {"ENEMY","CASTING","Stonega IV","JA","Violent Flourish"},
  {"ENEMY","CASTING","Thundaga IV","JA","Violent Flourish"},
  {"ENEMY","CASTING","Waterga IV","JA","Violent Flourish"},
  {"ENEMY","CASTING","Sleepga II","JA","Violent Flourish"},
  {"ENEMY","CASTING","Silencega","JA","Violent Flourish"},
  {"ENEMY","CASTING","Breakga","JA","Violent Flourish"},
  {"ENEMY","CASTING","Dispel","JA","Violent Flourish"},
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"},
  {"SELF","SHADOWS <",1,"MA","Utsusemi: Ni"},
  {"SELF","SHADOWS <",2,"MA","Utsusemi: Ichi"}
}
tactics["NIN"] = {
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"SELF","SHADOWS <",1,"MA","Utsusemi: Ni"},
  {"SELF","SHADOWS <",2,"MA","Utsusemi: Ichi"}
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
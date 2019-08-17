tactics = {}

gambits["DRG"] = {
  {"SELF","NOT_STATUS","Defender","JA","Defender"},
  {"SELF","NOT_STATUS","Aggressor","JA","Aggressor"},
  {"SELF","JA_READY","Provoke","JA","Provoke"}
}
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
  {"SELF","STATUS","Paralyzed","ITEM","Remedy"},
  {"PARTY","HPP <=",70,"JA","Curing Waltz III"}
}
return tactics
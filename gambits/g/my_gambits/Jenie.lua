gambits = {}

gambits["RDM"] = {

}
gambits["WHM"] = {

}

gambits["GEO"] = {
  --{"SELF","NOT_ASSISTING","Jacki","ASSIST","Hanatori"},
  
  --{"SELF","NOT_STATUS","geo refresh","MA","Indi-Refresh"},
  {"SELF","NOT_STATUS","geo magic atk. boost","MA","Indi-Acumen"},
  --{"SELF","NOT_STATUS","geo attack boost","MA","Indi-Fury"},
  --{"SELF","NOT_STATUS","geo magic evasion boost","MA","Indi-Attunement"},
  --{"SELF","NOT_STATUS","geo haste","MA","Indi-Haste"},
  --{"SELF","NOT_STATUS","geo attack boost","MA","Indi-Fury"},
  
  
  {"ENEMY","NOT_TAGGED","","MA","Dia II"},

  --{"SELF","NO_PET","","MA","Geo-Fury"},
  --{"SELF","NO_PET","","MA","Geo-Acumen"},
  {"SELF","NO_PET","","MA","Geo-Malaise"},
  --{"SELF","NO_PET","","MA","Geo-Frailty"},
  --{"SELF","NO_PET","","MA","Geo-Haste"},
  --{"SELF","NO_PET","","MA","Geo-Vex"},

  {"MAGE","STATUS","Sleep","MA","Cure"},
  {"PARTY","STATUS","Sleep","MA","Cure"},
  {"PARTY","HPP <=",55,"MA","Cure IV"},

  --{"SELF","NOT_STATUS","Haste","MA","Haste"},
  {"MAGE","NOT_STATUS","Haste","MA","Haste"},
  --{"SELF","MA_READY","Fire","MA","Fire"},
}

gambits["COR"] = {

}

return gambits
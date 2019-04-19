-- Resource Tables for AF/Relic/Empyrean Armor.
local base_af1_head   = 27663
local base_af1_body   = 27807
local base_af1_hands  = 27943
local base_af1_legs   = 28090
local base_af1_feet   = 28223

local base_af2_head   = 27684
local base_af2_body   = 27828
local base_af2_hands  = 27964
local base_af2_legs   = 28111
local base_af2_feet   = 28244

local base_af3_head   = 23040
local base_af3_body   = 23107
local base_af3_hands  = 23174
local base_af3_legs   = 23241
local base_af3_feet   = 23308

local base_af4_head   = 23375
local base_af4_body   = 23442
local base_af4_hands  = 23509
local base_af4_legs   = 23576
local base_af4_feet   = 23643

local base_re1_head   = 26624
local base_re1_body   = 26800
local base_re1_hands  = 26976
local base_re1_legs   = 27152
local base_re1_feet   = 27328

local base_re2_head   = 26625
local base_re2_body   = 26801
local base_re2_hands  = 26977
local base_re2_legs   = 27153
local base_re2_feet   = 27329

local base_re3_head   = 23063
local base_re3_body   = 23130
local base_re3_hands  = 23197
local base_re3_legs   = 23264 
local base_re3_feet   = 23331

local base_re4_head   = 23398
local base_re4_body   = 23465
local base_re4_hands  = 23532
local base_re4_legs   = 23599
local base_re4_feet   = 23666

local base_em1_head   = 26740
local base_em1_body   = 26898
local base_em1_hands  = 27052
local base_em1_legs   = 27237
local base_em1_feet   = 27411

local base_em2_head   = 26741
local base_em2_body   = 26899
local base_em2_hands  = 27053
local base_em2_legs   = 27238
local base_em2_feet   = 27412

local base_em3_head   = 0
local base_em3_body   = 0
local base_em3_hands  = 0
local base_em3_legs   = 0
local base_em3_feet   = 0

local base_em4_head   = 0
local base_em4_body   = 0
local base_em4_hands  = 0
local base_em4_legs   = 0
local base_em4_feet   = 0

-- Artifact Slips
local afSlip10        = 29326
local afSlip11        = 29327
local afSlip12        = 29335
local afSlip13        = 29336

-- Relic Slips
local afSlip20        = 29328
local afSlip21        = 29329
local afSlip22        = 29337
local afSlip23        = 29338

-- Empyrean Slips
local afSlip30        = 29331
local afSlip31        = 29332
local afSlip32        = 0
local afSlip33        = 0


return {
    --WAR
    --Artifact
    ["WAR AF10"] = {base_af1_head, base_af1_body, base_af1_hands, base_af1_legs, base_af1_feet, 0,0,0,29326},
    ["WAR AF11"] = {base_af2_head, base_af2_body, base_af2_hands, base_af2_legs, base_af2_feet, 0,0,0,29327},
    ["WAR AF12"] = {base_af3_head, base_af3_body, base_af3_hands, base_af3_legs, base_af3_feet, 0,0,0,29335},
    ["WAR AF13"] = {base_af4_head, base_af4_body, base_af4_hands, base_af4_legs, base_af4_feet, 0,0,0,29336},
    --Relic
    ["WAR AF20"] = {base_re1_head, base_re1_body, base_re1_hands, base_re1_legs, base_re1_feet, 0,0,0,29328},
    ["WAR AF21"] = {base_re2_head, base_re2_body, base_re2_hands, base_re2_legs, base_re2_feet, 0,0,0,29329},
    ["WAR AF22"] = {base_re3_head, base_re3_body, base_re3_hands, base_re3_legs, base_re3_feet, 0,0,0,29337},
    ["WAR AF23"] = {base_re4_head, base_re4_body, base_re4_hands, base_re4_legs, base_re4_feet, 0,0,0,29338},
    --Empyrean
    ["WAR AF30"] = {base_em1_head, base_em1_body, base_em1_hands, base_em1_legs, base_em1_feet, 0,0,0,29331},
    ["WAR AF31"] = {base_em2_head, base_em2_body, base_em2_hands, base_em2_legs, base_em2_feet, 0,0,0,29332},
    ["WAR AF32"] = {},
    ["WAR AF33"] = {},
    
    --MNK
    --Artifact
    ["MNK AF10"] = {base_af1_head+1, base_af1_body+1, base_af1_hands+1, base_af1_legs+1, base_af1_feet+1, 0,0,0,29326},
    ["MNK AF11"] = {base_af2_head+1, base_af2_body+1, base_af2_hands+1, base_af2_legs+1, base_af2_feet+1, 0,0,0,29327},
    ["MNK AF12"] = {base_af3_head+1, base_af3_body+1, base_af3_hands+1, base_af3_legs+1, base_af3_feet+1, 0,0,0,29335},
    ["MNK AF13"] = {base_af4_head+1, base_af4_body+1, base_af4_hands+1, base_af4_legs+1, base_af4_feet+1, 0,0,0,29336},
    --Relic
    ["MNK AF20"] = {base_re1_head+2, base_re1_body+2, base_re1_hands+2, base_re1_legs+2, base_re1_feet+2, 0,0,0,29328},
    ["MNK AF21"] = {base_re2_head+2, base_re2_body+2, base_re2_hands+2, base_re2_legs+1, base_re2_feet+2, 0,0,0,29329},
    ["MNK AF22"] = {base_re3_head+2, base_re3_body+2, base_re3_hands+2, base_re3_legs+1, base_re3_feet+2, 0,0,0,29337},
    ["MNK AF23"] = {base_re4_head+2, base_re4_body+2, base_re4_hands+2, base_re4_legs+1, base_re4_feet+2, 0,0,0,29338},
    --Empyrean
    ["MNK AF30"] = {base_em1_head+2, base_em1_body+2, base_em1_hands+2, base_em1_legs+2, base_em1_feet+2, 0,0,0,29331},
    ["MNK AF31"] = {base_em2_head+2, base_em2_body+2, base_em2_hands+2, base_em2_legs+2, base_em2_feet+2, 0,0,0,29332},
    ["MNK AF32"] = {},
    ["MNK AF33"] = {},
    
    --WHM
    --Artifact
    ["WHM AF10"] = {base_af1_head+2, base_af1_body+2, base_af1_hands+2, base_af1_legs+2, base_af1_feet+2, 0,0,0,29326},
    ["WHM AF11"] = {base_af2_head+2, base_af2_body+2, base_af2_hands+2, base_af2_legs+2, base_af2_feet+2, 0,0,0,29327},
    ["WHM AF12"] = {base_af3_head+2, base_af3_body+2, base_af3_hands+2, base_af3_legs+2, base_af3_feet+2, 0,0,0,29335},
    ["WHM AF13"] = {base_af4_head+2, base_af4_body+2, base_af4_hands+2, base_af4_legs+2, base_af4_feet+2, 0,0,0,29336},
    --Relic
    ["WHM AF20"] = {base_re1_head+4, base_re1_body+4, base_re1_hands+4, base_re1_legs+4, base_re1_feet+4, 0,0,0,29328},
    ["WHM AF21"] = {base_re2_head+4, base_re2_body+4, base_re2_hands+4, base_re2_legs+4, base_re2_feet+4, 0,0,0,29329},
    ["WHM AF22"] = {base_re3_head+4, base_re3_body+4, base_re3_hands+4, base_re3_legs+4, base_re3_feet+4, 0,0,0,29337},
    ["WHM AF23"] = {base_re4_head+4, base_re4_body+4, base_re4_hands+4, base_re4_legs+4, base_re4_feet+4, 0,0,0,29338},
    --Empyrean
    ["WHM AF30"] = {base_em1_head+4, base_em1_body+4, base_em1_hands+4, base_em1_legs+4, base_em1_feet+4, 0,0,0,29331},
    ["WHM AF31"] = {base_em2_head+4, base_em2_body+4, base_em2_hands+4, base_em2_legs+4, base_em2_feet+4, 0,0,0,29332},
    ["WHM AF32"] = {},
    ["WHM AF33"] = {},
    
    --BLM
    --Artifact
    ["BLM AF10"] = {base_af1_head+3, base_af1_body+3, base_af1_hands+3, base_af1_legs+3, base_af1_feet+3, 0,0,0,29326},
    ["BLM AF11"] = {base_af2_head+3, base_af2_body+3, base_af2_hands+3, base_af2_legs+3, base_af2_feet+3, 0,0,0,29327},
    ["BLM AF12"] = {base_af3_head+3, base_af3_body+3, base_af3_hands+3, base_af3_legs+3, base_af3_feet+3, 0,0,0,29335},
    ["BLM AF13"] = {base_af4_head+3, base_af4_body+3, base_af4_hands+3, base_af4_legs+3, base_af4_feet+3, 0,0,0,29336},
    --Relic
    ["BLM AF20"] = {base_re1_head+6, base_re1_body+6, base_re1_hands+6, base_re1_legs+6, base_re1_feet+6, 0,0,0,29328},
    ["BLM AF21"] = {base_re2_head+6, base_re2_body+6, base_re2_hands+6, base_re2_legs+6, base_re2_feet+6, 0,0,0,29329},
    ["BLM AF22"] = {base_re3_head+6, base_re3_body+6, base_re3_hands+6, base_re3_legs+6, base_re3_feet+6, 0,0,0,29337},
    ["BLM AF23"] = {base_re4_head+6, base_re4_body+6, base_re4_hands+6, base_re4_legs+6, base_re4_feet+6, 0,0,0,29338},
    --Empyrean
    ["BLM AF30"] = {base_em1_head+6, base_em1_body+6, base_em1_hands+6, base_em1_legs+6, base_em1_feet+6, 0,0,0,29331},
    ["BLM AF31"] = {base_em2_head+6, base_em2_body+6, base_em2_hands+6, base_em2_legs+6, base_em2_feet+6, 0,0,0,29332},
    ["BLM AF32"] = {},
    ["BLM AF33"] = {},
    
    --RDM
    --Artifact
    ["RDM AF10"] = {base_af1_head+4, base_af1_body+4, base_af1_hands+4, base_af1_legs+4, base_af1_feet+4, 0,0,0,29326},
    ["RDM AF11"] = {base_af2_head+4, base_af2_body+4, base_af2_hands+4, base_af2_legs+4, base_af2_feet+4, 0,0,0,29327},
    ["RDM AF12"] = {base_af3_head+4, base_af3_body+4, base_af3_hands+4, base_af3_legs+4, base_af3_feet+4, 0,0,0,29335},
    ["RDM AF13"] = {base_af4_head+4, base_af4_body+4, base_af4_hands+4, base_af4_legs+4, base_af4_feet+4, 0,0,0,29336},
    --Relic
    ["RDM AF20"] = {base_re1_head+8, base_re1_body+8, base_re1_hands+8, base_re1_legs+8, base_re1_feet+8, 0,0,0,29328},
    ["RDM AF21"] = {base_re2_head+8, base_re2_body+8, base_re2_hands+8, base_re2_legs+8, base_re2_feet+8, 0,0,0,29329},
    ["RDM AF22"] = {base_re3_head+8, base_re3_body+8, base_re3_hands+8, base_re3_legs+8, base_re3_feet+8, 0,0,0,29337},
    ["RDM AF23"] = {base_re4_head+8, base_re4_body+8, base_re4_hands+8, base_re4_legs+8, base_re4_feet+8, 0,0,0,29338},
    --Empyrean
    ["RDM AF30"] = {base_em1_head+8, base_em1_body+8, base_em1_hands+8, base_em1_legs+8, base_em1_feet+8, 0,0,0,29331},
    ["RDM AF31"] = {base_em2_head+8, base_em2_body+8, base_em2_hands+8, base_em2_legs+8, base_em2_feet+8, 0,0,0,29332},
    ["RDM AF32"] = {},
    ["RDM AF33"] = {},
    
    --THF
    --Artifact
    ["THF AF10"] = {base_af1_head+5, base_af1_body+5, base_af1_hands+5, base_af1_legs+5, base_af1_feet+5, 0,0,0,29326},
    ["THF AF11"] = {base_af2_head+5, base_af2_body+5, base_af2_hands+5, base_af2_legs+5, base_af2_feet+5, 0,0,0,29327},
    ["THF AF12"] = {base_af3_head+5, base_af3_body+5, base_af3_hands+5, base_af3_legs+5, base_af3_feet+5, 0,0,0,29335},
    ["THF AF13"] = {base_af4_head+5, base_af4_body+5, base_af4_hands+5, base_af4_legs+5, base_af4_feet+5, 0,0,0,29336},
    --Relic
    ["THF AF20"] = {base_re1_head+10, base_re1_body+10, base_re1_hands+10, base_re1_legs+10, base_re1_feet+10, 0,0,0,29328},
    ["THF AF21"] = {base_re2_head+10, base_re2_body+10, base_re2_hands+10, base_re2_legs+10, base_re2_feet+10, 0,0,0,29329},
    ["THF AF22"] = {base_re3_head+10, base_re3_body+10, base_re3_hands+10, base_re3_legs+10, base_re3_feet+10, 0,0,0,29337},
    ["THF AF23"] = {base_re4_head+10, base_re4_body+10, base_re4_hands+10, base_re4_legs+10, base_re4_feet+10, 0,0,0,29338},
    --Empyrean
    ["THF AF30"] = {base_em1_head+10, base_em1_body+10, base_em1_hands+10, base_em1_legs+10, base_em1_feet+10, 0,0,0,29331},
    ["THF AF31"] = {base_em2_head+10, base_em2_body+10, base_em2_hands+10, base_em2_legs+10, base_em2_feet+10, 0,0,0,29332},
    ["THF AF32"] = {},
    ["THF AF33"] = {},
    
    --PLD
    --Artifact
    ["PLD AF10"] = {base_af1_head+6, base_af1_body+6, base_af1_hands+6, base_af1_legs+6, base_af1_feet+6, 0,0,0,29326},
    ["PLD AF11"] = {base_af2_head+6, base_af2_body+6, base_af2_hands+6, base_af2_legs+6, base_af2_feet+6, 0,0,0,29327},
    ["PLD AF12"] = {base_af3_head+6, base_af3_body+6, base_af3_hands+6, base_af3_legs+6, base_af3_feet+6, 0,0,0,29335},
    ["PLD AF13"] = {base_af4_head+6, base_af4_body+6, base_af4_hands+6, base_af4_legs+6, base_af4_feet+6, 0,0,0,29336},
    --Relic
    ["PLD AF20"] = {base_re1_head+12, base_re1_body+12, base_re1_hands+12, base_re1_legs+12, base_re1_feet+12, 0,0,0,29328},
    ["PLD AF21"] = {base_re2_head+12, base_re2_body+12, base_re2_hands+12, base_re2_legs+12, base_re2_feet+12, 0,0,0,29329},
    ["PLD AF22"] = {base_re3_head+12, base_re3_body+12, base_re3_hands+12, base_re3_legs+12, base_re3_feet+12, 0,0,0,29337},
    ["PLD AF23"] = {base_re4_head+12, base_re4_body+12, base_re4_hands+12, base_re4_legs+12, base_re4_feet+12, 0,0,0,29338},
    --Empyrean
    ["PLD AF30"] = {base_em1_head+12, base_em1_body+12, base_em1_hands+12, base_em1_legs+12, base_em1_feet+12, 0,0,0,29331},
    ["PLD AF31"] = {base_em2_head+12, base_em2_body+12, base_em2_hands+12, base_em2_legs+12, base_em2_feet+12, 0,0,0,29332},
    ["PLD AF32"] = {},
    ["PLD AF33"] = {},
    
    --DRK
    --Artifact
    ["DRK AF10"] = {base_af1_head+7, base_af1_body+7, base_af1_hands+7, base_af1_legs+7, base_af1_feet+7, 0,0,0,29326},
    ["DRK AF11"] = {base_af2_head+7, base_af2_body+7, base_af2_hands+7, base_af2_legs+7, base_af2_feet+7, 0,0,0,29327},
    ["DRK AF12"] = {base_af3_head+7, base_af3_body+7, base_af3_hands+7, base_af3_legs+7, base_af3_feet+7, 0,0,0,29335},
    ["DRK AF13"] = {base_af4_head+7, base_af4_body+7, base_af4_hands+7, base_af4_legs+7, base_af4_feet+7, 0,0,0,29336},
    --Relic
    ["DRK AF20"] = {base_re1_head+14, base_re1_body+14, base_re1_hands+14, base_re1_legs+14, base_re1_feet+14, 0,0,0,29328},
    ["DRK AF21"] = {base_re2_head+14, base_re2_body+14, base_re2_hands+14, base_re2_legs+14, base_re2_feet+14, 0,0,0,29329},
    ["DRK AF22"] = {base_re3_head+14, base_re3_body+14, base_re3_hands+14, base_re3_legs+14, base_re3_feet+14, 0,0,0,29337},
    ["DRK AF23"] = {base_re4_head+14, base_re4_body+14, base_re4_hands+14, base_re4_legs+14, base_re4_feet+14, 0,0,0,29338},
    --Empyrean
    ["DRK AF30"] = {base_em1_head+14, base_em1_body+14, base_em1_hands+14, base_em1_legs+14, base_em1_feet+14, 0,0,0,29331},
    ["DRK AF31"] = {base_em2_head+14, base_em2_body+14, base_em2_hands+14, base_em2_legs+14, base_em2_feet+14, 0,0,0,29332},
    ["DRK AF32"] = {},
    ["DRK AF33"] = {},
    
    --BST
    --Artifact
    ["BST AF10"] = {base_af1_head+8, base_af1_body+8, base_af1_hands+8, base_af1_legs+8, base_af1_feet+8, 0,0,0,29326},
    ["BST AF11"] = {base_af2_head+8, base_af2_body+8, base_af2_hands+8, base_af2_legs+8, base_af2_feet+8, 0,0,0,29327},
    ["BST AF12"] = {base_af3_head+8, base_af3_body+8, base_af3_hands+8, base_af3_legs+8, base_af3_feet+8, 0,0,0,29335},
    ["BST AF13"] = {base_af4_head+8, base_af4_body+8, base_af4_hands+8, base_af4_legs+8, base_af4_feet+8, 0,0,0,29336},
    --Relic
    ["BST AF20"] = {base_re1_head+16, base_re1_body+16, base_re1_hands+16, base_re1_legs+16, base_re1_feet+16, 0,0,0,29328},
    ["BST AF21"] = {base_re2_head+16, base_re2_body+16, base_re2_hands+16, base_re2_legs+16, base_re2_feet+16, 0,0,0,29329},
    ["BST AF22"] = {base_re3_head+16, base_re3_body+16, base_re3_hands+16, base_re3_legs+16, base_re3_feet+16, 0,0,0,29337},
    ["BST AF23"] = {base_re4_head+16, base_re4_body+16, base_re4_hands+16, base_re4_legs+16, base_re4_feet+16, 0,0,0,29338},
    --Empyrean
    ["BST AF30"] = {base_em1_head+16, base_em1_body+16, base_em1_hands+16, base_em1_legs+16, base_em1_feet+16, 0,0,0,29331},
    ["BST AF31"] = {base_em2_head+16, base_em2_body+16, base_em2_hands+16, base_em2_legs+16, base_em2_feet+16, 0,0,0,29332},
    ["BST AF32"] = {},
    ["BST AF33"] = {},
    
    --BRD
    --Artifact
    ["BRD AF10"] = {base_af1_head+9, base_af1_body+9, base_af1_hands+9, base_af1_legs+9, base_af1_feet+9, 0,0,0,29326},
    ["BRD AF11"] = {base_af2_head+9, base_af2_body+9, base_af2_hands+9, base_af2_legs+9, base_af2_feet+9, 0,0,0,29327},
    ["BRD AF12"] = {base_af3_head+9, base_af3_body+9, base_af3_hands+9, base_af3_legs+9, base_af3_feet+9, 0,0,0,29335},
    ["BRD AF13"] = {base_af4_head+9, base_af4_body+9, base_af4_hands+9, base_af4_legs+9, base_af4_feet+9, 0,0,0,29336},
    --Relic
    ["BRD AF20"] = {base_re1_head+18, base_re1_body+18, base_re1_hands+18, base_re1_legs+18, base_re1_feet+18, 0,0,0,29328},
    ["BRD AF21"] = {base_re2_head+18, base_re2_body+18, base_re2_hands+18, base_re2_legs+18, base_re2_feet+18, 0,0,0,29329},
    ["BRD AF22"] = {base_re3_head+18, base_re3_body+18, base_re3_hands+18, base_re3_legs+18, base_re3_feet+18, 0,0,0,29337},
    ["BRD AF23"] = {base_re4_head+18, base_re4_body+18, base_re4_hands+18, base_re4_legs+18, base_re4_feet+18, 0,0,0,29338},
    --Empyrean
    ["BRD AF30"] = {base_em1_head+18, base_em1_body+18, base_em1_hands+18, base_em1_legs+18, base_em1_feet+18, 0,0,0,29331},
    ["BRD AF31"] = {base_em2_head+18, base_em2_body+18, base_em2_hands+18, base_em2_legs+18, base_em2_feet+18, 0,0,0,29332},
    ["BRD AF32"] = {},
    ["BRD AF33"] = {},
    
    --RNG 
    --Artifact
    ["RNG AF10"] = {base_af1_head+10, base_af1_body+10, base_af1_hands+10, base_af1_legs+10, base_af1_feet+10, 0,0,0,29326},
    ["RNG AF11"] = {base_af2_head+10, base_af2_body+10, base_af2_hands+10, base_af2_legs+10, base_af2_feet+10, 0,0,0,29327},
    ["RNG AF12"] = {base_af3_head+10, base_af3_body+10, base_af3_hands+10, base_af3_legs+10, base_af3_feet+10, 0,0,0,29335},
    ["RNG AF13"] = {base_af4_head+10, base_af4_body+10, base_af4_hands+10, base_af4_legs+10, base_af4_feet+10, 0,0,0,29336},
    --Relic
    ["RNG AF20"] = {base_re1_head+20, base_re1_body+20, base_re1_hands+20, base_re1_legs+20, base_re1_feet+20, 0,0,0,29328},
    ["RNG AF21"] = {base_re2_head+20, base_re2_body+20, base_re2_hands+20, base_re2_legs+20, base_re2_feet+20, 0,0,0,29329},
    ["RNG AF22"] = {base_re3_head+20, base_re3_body+20, base_re3_hands+20, base_re3_legs+20, base_re3_feet+20, 0,0,0,29337},
    ["RNG AF23"] = {base_re4_head+20, base_re4_body+20, base_re4_hands+20, base_re4_legs+20, base_re4_feet+20, 0,0,0,29338},
    --Empyrean
    ["RNG AF30"] = {base_em1_head+20, base_em1_body+20, base_em1_hands+20, base_em1_legs+20, base_em1_feet+20, 0,0,0,29331},
    ["RNG AF31"] = {base_em2_head+20, base_em2_body+20, base_em2_hands+20, base_em2_legs+20, base_em2_feet+20, 0,0,0,29332},
    ["RNG AF32"] = {},
    ["RNG AF33"] = {},
    
    --SAM
    --Artifact
    ["SAM AF10"] = {base_af1_head+11, base_af1_body+11, base_af1_hands+11, base_af1_legs+11, base_af1_feet+11, 0,0,0,29326},
    ["SAM AF11"] = {base_af2_head+11, base_af2_body+11, base_af2_hands+11, base_af2_legs+11, base_af2_feet+11, 0,0,0,29327},
    ["SAM AF12"] = {base_af3_head+11, base_af3_body+11, base_af3_hands+11, base_af3_legs+11, base_af3_feet+11, 0,0,0,29335},
    ["SAM AF13"] = {base_af4_head+11, base_af4_body+11, base_af4_hands+11, base_af4_legs+11, base_af4_feet+11, 0,0,0,29336},
    --Relic
    ["SAM AF20"] = {base_re1_head+22, base_re1_body+22, base_re1_hands+22, base_re1_legs+22, base_re1_feet+22, 0,0,0,29328},
    ["SAM AF21"] = {base_re2_head+22, base_re2_body+22, base_re2_hands+22, base_re2_legs+22, base_re2_feet+22, 0,0,0,29329},
    ["SAM AF22"] = {base_re3_head+11, base_re3_body+11, base_re3_hands+11, base_re3_legs+11, base_re3_feet+11, 0,0,0,29337},
    ["SAM AF23"] = {base_re4_head+11, base_re4_body+11, base_re4_hands+11, base_re4_legs+11, base_re4_feet+11, 0,0,0,29338},
    --Empyrean
    ["SAM AF30"] = {base_em1_head+22, base_em1_body+22, base_em1_hands+22, base_em1_legs+22, base_em1_feet+22, 0,0,0,29331},
    ["SAM AF31"] = {base_em2_head+22, base_em2_body+22, base_em2_hands+22, base_em2_legs+22, base_em2_feet+22, 0,0,0,29332},
    ["SAM AF32"] = {},
    ["SAM AF33"] = {},
    
    --NIN
    --Artifact
    ["NIN AF10"] = {base_af1_head+12, base_af1_body+12, base_af1_hands+12, base_af1_legs+12, base_af1_feet+12, 0,0,0,29326},
    ["NIN AF11"] = {base_af2_head+12, base_af2_body+12, base_af2_hands+12, base_af2_legs+12, base_af2_feet+12, 0,0,0,29327},
    ["NIN AF12"] = {base_af3_head+12, base_af3_body+12, base_af3_hands+12, base_af3_legs+12, base_af3_feet+12, 0,0,0,29335},
    ["NIN AF13"] = {base_af4_head+12, base_af4_body+12, base_af4_hands+12, base_af4_legs+12, base_af4_feet+12, 0,0,0,29336},
    --Relic
    ["NIN AF20"] = {base_re1_head+24, base_re1_body+24, base_re1_hands+24, base_re1_legs+24, base_re1_feet+24, 0,0,0,29328},
    ["NIN AF21"] = {base_re2_head+24, base_re2_body+24, base_re2_hands+24, base_re2_legs+24, base_re2_feet+24, 0,0,0,29329},
    ["NIN AF22"] = {base_re3_head+24, base_re3_body+24, base_re3_hands+24, base_re3_legs+24, base_re3_feet+24, 0,0,0,29337},
    ["NIN AF23"] = {base_re4_head+24, base_re4_body+24, base_re4_hands+24, base_re4_legs+24, base_re4_feet+24, 0,0,0,29338},
    --Empyrean
    ["NIN AF30"] = {base_em1_head+24, base_em1_body+24, base_em1_hands+24, base_em1_legs+24, base_em1_feet+24, 0,0,0,29331},
    ["NIN AF31"] = {base_em2_head+24, base_em2_body+24, base_em2_hands+24, base_em2_legs+24, base_em2_feet+24, 0,0,0,29332},
    ["NIN AF32"] = {},
    ["NIN AF33"] = {},
    
    --DRG
    --Artifact
    ["DRG AF10"] = {base_af1_head+13, base_af1_body+13, base_af1_hands+13, base_af1_legs+13, base_af1_feet+13, 0,0,0,29326},
    ["DRG AF11"] = {base_af2_head+13, base_af2_body+13, base_af2_hands+13, base_af2_legs+13, base_af2_feet+13, 0,0,0,29327},
    ["DRG AF12"] = {base_af3_head+13, base_af3_body+13, base_af3_hands+13, base_af3_legs+13, base_af3_feet+13, 0,0,0,29335},
    ["DRG AF13"] = {base_af4_head+13, base_af4_body+13, base_af4_hands+13, base_af4_legs+13, base_af4_feet+13, 0,0,0,29336},
    --Relic
    ["DRG AF20"] = {base_re1_head+26, base_re1_body+26, base_re1_hands+26, base_re1_legs+26, base_re1_feet+26, 0,0,0,29328},
    ["DRG AF21"] = {base_re2_head+26, base_re2_body+26, base_re2_hands+26, base_re2_legs+26, base_re2_feet+26, 0,0,0,29329},
    ["DRG AF22"] = {base_re3_head+26, base_re3_body+26, base_re3_hands+26, base_re3_legs+26, base_re3_feet+26, 0,0,0,29337},
    ["DRG AF23"] = {base_re4_head+26, base_re4_body+26, base_re4_hands+26, base_re4_legs+26, base_re4_feet+26, 0,0,0,29338},
    --Empyrean
    ["DRG AF30"] = {base_em1_head+26, base_em1_body+26, base_em1_hands+26, base_em1_legs+26, base_em1_feet+26, 0,0,0,29331},
    ["DRG AF31"] = {base_em2_head+26, base_em2_body+26, base_em2_hands+26, base_em2_legs+26, base_em2_feet+26, 0,0,0,29332},
    ["DRG AF32"] = {},
    ["DRG AF33"] = {},
    
    --SMN
    --Artifact
    ["SMN AF10"] = {base_af1_head+14, base_af1_body+14, base_af1_hands+14, base_af1_legs+14, base_af1_feet+14, 0,0,0,29326},
    ["SMN AF11"] = {base_af2_head+14, base_af2_body+14, base_af2_hands+14, base_af2_legs+14, base_af2_feet+14, 0,0,0,29327},
    ["SMN AF12"] = {base_af3_head+14, base_af3_body+14, base_af3_hands+14, base_af3_legs+14, base_af3_feet+14, 0,0,0,29335},
    ["SMN AF13"] = {base_af4_head+14, base_af4_body+14, base_af4_hands+14, base_af4_legs+14, base_af4_feet+14, 0,0,0,29336},
    --Relic
    ["SMN AF20"] = {base_re1_head+28, base_re1_body+28, base_re1_hands+28, base_re1_legs+28, base_re1_feet+28, 0,0,0,29328},
    ["SMN AF21"] = {base_re2_head+28, base_re2_body+28, base_re2_hands+28, base_re2_legs+28, base_re2_feet+28, 0,0,0,29329},
    ["SMN AF22"] = {base_re3_head+28, base_re3_body+28, base_re3_hands+28, base_re3_legs+28, base_re3_feet+28, 0,0,0,29337},
    ["SMN AF23"] = {base_re4_head+28, base_re4_body+28, base_re4_hands+28, base_re4_legs+28, base_re4_feet+28, 0,0,0,29338},
    --Empyrean
    ["SMN AF30"] = {base_em1_head+28, base_em1_body+28, base_em1_hands+28, base_em1_legs+28, base_em1_feet+28, 0,0,0,29331},
    ["SMN AF31"] = {base_em2_head+28, base_em2_body+28, base_em2_hands+28, base_em2_legs+28, base_em2_feet+28, 0,0,0,29332},
    ["SMN AF32"] = {},
    ["SMN AF33"] = {},
    
    --BLU
    --Artifact
    ["BLU AF10"] = {base_af1_head+15, base_af1_body+15, base_af1_hands+15, base_af1_legs+15, base_af1_feet+15, 0,0,0,29326},
    ["BLU AF11"] = {base_af2_head+15, base_af2_body+15, base_af2_hands+15, base_af2_legs+15, base_af2_feet+15, 0,0,0,29327},
    ["BLU AF12"] = {base_af3_head+15, base_af3_body+15, base_af3_hands+15, base_af3_legs+15, base_af3_feet+15, 0,0,0,29335},
    ["BLU AF13"] = {base_af4_head+15, base_af4_body+15, base_af4_hands+15, base_af4_legs+15, base_af4_feet+15, 0,0,0,29336},
    --Relic
    ["BLU AF20"] = {base_re1_head+30, base_re1_body+30, base_re1_hands+30, base_re1_legs+30, base_re1_feet+30, 0,0,0,29328},
    ["BLU AF21"] = {base_re2_head+30, base_re2_body+30, base_re2_hands+30, base_re2_legs+30, base_re2_feet+30, 0,0,0,29329},
    ["BLU AF22"] = {base_re3_head+30, base_re3_body+30, base_re3_hands+30, base_re3_legs+30, base_re3_feet+30, 0,0,0,29337},
    ["BLU AF23"] = {base_re4_head+30, base_re4_body+30, base_re4_hands+30, base_re4_legs+30, base_re4_feet+30, 0,0,0,29338},
    --Empyrean
    ["BLU AF30"] = {base_em1_head+30, base_em1_body+30, base_em1_hands+30, base_em1_legs+30, base_em1_feet+30, 0,0,0,29331},
    ["BLU AF31"] = {base_em2_head+30, base_em2_body+30, base_em2_hands+30, base_em2_legs+30, base_em2_feet+30, 0,0,0,29332},
    ["BLU AF32"] = {},
    ["BLU AF33"] = {},
    
    --COR
    --Artifact
    ["COR AF10"] = {base_af1_head+16, base_af1_body+16, base_af1_hands+16, base_af1_legs+16, base_af1_feet+16, 0,0,0,29326},
    ["COR AF11"] = {base_af2_head+16, base_af2_body+16, base_af2_hands+16, base_af2_legs+16, base_af2_feet+16, 0,0,0,29327},
    ["COR AF12"] = {base_af3_head+16, base_af3_body+16, base_af3_hands+16, base_af3_legs+16, base_af3_feet+16, 0,0,0,29335},
    ["COR AF13"] = {base_af4_head+16, base_af4_body+16, base_af4_hands+16, base_af4_legs+16, base_af4_feet+16, 0,0,0,29336},
    --Relic
    ["COR AF20"] = {base_re1_head+32, base_re1_body+32, base_re1_hands+32, base_re1_legs+32, base_re1_feet+32, 0,0,0,29328},
    ["COR AF21"] = {base_re2_head+32, base_re2_body+32, base_re2_hands+32, base_re2_legs+32, base_re2_feet+32, 0,0,0,29329},
    ["COR AF22"] = {base_re3_head+16, base_re3_body+16, base_re3_hands+16, base_re3_legs+16, base_re3_feet+16, 0,0,0,29337},
    ["COR AF23"] = {base_re4_head+16, base_re4_body+16, base_re4_hands+16, base_re4_legs+16, base_re4_feet+16, 0,0,0,29338},
    --Empyrean
    ["COR AF30"] = {base_em1_head+32, base_em1_body+32, base_em1_hands+32, base_em1_legs+32, base_em1_feet+32, 0,0,0,29331},
    ["COR AF31"] = {base_em2_head+32, base_em2_body+32, base_em2_hands+32, base_em2_legs+32, base_em2_feet+32, 0,0,0,29332},
    ["COR AF32"] = {},
    ["COR AF33"] = {},
    
    --PUP
    --Artifact
    ["PUP AF10"] = {base_af1_head+17, base_af1_body+17, base_af1_hands+17, base_af1_legs+17, base_af1_feet+17, 0,0,0,29326},
    ["PUP AF11"] = {base_af2_head+17, base_af2_body+17, base_af2_hands+17, base_af2_legs+17, base_af2_feet+17, 0,0,0,29327},
    ["PUP AF12"] = {base_af3_head+17, base_af3_body+17, base_af3_hands+17, base_af3_legs+17, base_af3_feet+17, 0,0,0,29335},
    ["PUP AF13"] = {base_af4_head+17, base_af4_body+17, base_af4_hands+17, base_af4_legs+17, base_af4_feet+17, 0,0,0,29336},
    --Relic
    ["PUP AF20"] = {base_re1_head+34, base_re1_body+34, base_re1_hands+34, base_re1_legs+34, base_re1_feet+34, 0,0,0,29328},
    ["PUP AF21"] = {base_re2_head+34, base_re2_body+34, base_re2_hands+34, base_re2_legs+34, base_re2_feet+34, 0,0,0,29329},
    ["PUP AF22"] = {base_re3_head+34, base_re3_body+34, base_re3_hands+34, base_re3_legs+34, base_re3_feet+34, 0,0,0,29337},
    ["PUP AF23"] = {base_re4_head+34, base_re4_body+34, base_re4_hands+34, base_re4_legs+34, base_re4_feet+34, 0,0,0,29338},
    --Empyrean
    ["PUP AF30"] = {base_em1_head+34, base_em1_body+34, base_em1_hands+34, base_em1_legs+34, base_em1_feet+34, 0,0,0,29331},
    ["PUP AF31"] = {base_em2_head+34, base_em2_body+34, base_em2_hands+34, base_em2_legs+34, base_em2_feet+34, 0,0,0,29332},
    ["PUP AF32"] = {},
    ["PUP AF33"] = {},
    
    --DNC
    --Artifact
    ["DNC AF10"] = {base_af1_head+18, base_af1_body+18, base_af1_hands+18, base_af1_legs+18, base_af1_feet+18, 0,0,0,29326},
    ["DNC AF11"] = {base_af2_head+18, base_af2_body+18, base_af2_hands+18, base_af2_legs+18, base_af2_feet+18, 0,0,0,29327},
    ["DNC AF12"] = {base_af3_head+18, base_af3_body+18, base_af3_hands+18, base_af3_legs+18, base_af3_feet+18, 0,0,0,29335},
    ["DNC AF13"] = {base_af4_head+18, base_af4_body+18, base_af4_hands+18, base_af4_legs+18, base_af4_feet+18, 0,0,0,29336},
    --Relic
    ["DNC AF20"] = {base_re1_head+36, base_re1_body+36, base_re1_hands+36, base_re1_legs+36, base_re1_feet+36, 0,0,0,29328},
    ["DNC AF21"] = {base_re2_head+36, base_re2_body+36, base_re2_hands+36, base_re2_legs+36, base_re2_feet+36, 0,0,0,29329},
    ["DNC AF22"] = {base_re3_head+36, base_re3_body+36, base_re3_hands+36, base_re3_legs+36, base_re3_feet+36, 0,0,0,29337},
    ["DNC AF23"] = {base_re4_head+36, base_re4_body+36, base_re4_hands+36, base_re4_legs+36, base_re4_feet+36, 0,0,0,29338},
    --Empyrean
    ["DNC AF30"] = {base_em1_head+36, base_em1_body+36, base_em1_hands+36, base_em1_legs+36, base_em1_feet+36, 0,0,0,29331},
    ["DNC AF31"] = {base_em2_head+36, base_em2_body+36, base_em2_hands+36, base_em2_legs+36, base_em2_feet+36, 0,0,0,29332},
    ["DNC AF32"] = {},
    ["DNC AF33"] = {},
    
    --SCH
    --Artifact
    ["SCH AF10"] = {base_af1_head+20, base_af1_body+20, base_af1_hands+20, base_af1_legs+20, base_af1_feet+20, 0,0,0,29326},
    ["SCH AF11"] = {base_af2_head+20, base_af2_body+20, base_af2_hands+20, base_af2_legs+20, base_af2_feet+20, 0,0,0,29327},
    ["SCH AF12"] = {base_af3_head+20, base_af3_body+20, base_af3_hands+20, base_af3_legs+20, base_af3_feet+20, 0,0,0,29335},
    ["SCH AF13"] = {base_af4_head+20, base_af4_body+20, base_af4_hands+20, base_af4_legs+20, base_af4_feet+20, 0,0,0,29336},
    --Relic
    ["SCH AF20"] = {base_re1_head+38, base_re1_body+38, base_re1_hands+38, base_re1_legs+38, base_re1_feet+38, 0,0,0,29328},
    ["SCH AF21"] = {base_re2_head+38, base_re2_body+38, base_re2_hands+38, base_re2_legs+38, base_re2_feet+38, 0,0,0,29329},
    ["SCH AF22"] = {base_re3_head+38, base_re3_body+38, base_re3_hands+38, base_re3_legs+38, base_re3_feet+38, 0,0,0,29337},
    ["SCH AF23"] = {base_re4_head+38, base_re4_body+38, base_re4_hands+38, base_re4_legs+38, base_re4_feet+38, 0,0,0,29338},
    --Empyrean
    ["SCH AF30"] = {base_em1_head+38, base_em1_body+38, base_em1_hands+38, base_em1_legs+38, base_em1_feet+38, 0,0,0,29331},
    ["SCH AF31"] = {base_em2_head+38, base_em2_body+38, base_em2_hands+38, base_em2_legs+38, base_em2_feet+38, 0,0,0,29332},
    ["SCH AF32"] = {},
    ["SCH AF33"] = {},
    
    --GEO
    --Artifact
    ["GEO AF10"] = {27786, 27926, 28066, 28206, 28346, 0,0,0,29315},
    ["GEO AF11"] = {27705, 27850, 27985, 28132, 28265, 0,0,0,29327},
    ["GEO AF12"] = {23061, 23128, 23195, 23262, 23329, 0,0,0,29335},
    ["GEO AF13"] = {23396, 23463, 23530, 23597, 23664, 0,0,0,29336},
    --Relic
    ["GEO AF20"] = {26664, 26840, 27016, 27192, 27368, 0,0,0,29328},
    ["GEO AF21"] = {26665, 26841, 27017, 27193, 27369, 0,0,0,29329},
    ["GEO AF22"] = {23083, 23150, 23217, 23284, 23351, 0,0,0,29337},
    ["GEO AF23"] = {23418, 23485, 23552, 23619, 23686, 0,0,0,29338},
    --Empyrean
    ["GEO AF30"] = {26780, 26938, 27092, 27277, 27451, 0,0,0,29331},
    ["GEO AF31"] = {26781, 26939, 27093, 27278, 27452, 0,0,0,29332},
    ["GEO AF32"] = {},
    ["GEO AF33"] = {},
    
    --RUN
    --Artifact
    ["RUN AF10"] = {27787, 27927, 28067, 28207, 28347, 0,0,0,29326},
    ["RUN AF11"] = {27706, 27850, 27986, 28133, 28266, 0,0,0,29327},
    ["RUN AF12"] = {23062, 23129, 23196, 23263, 23330, 0,0,0,29335},
    ["RUN AF13"] = {23397, 23464, 23531, 23598, 23665, 0,0,0,29336},
    --Relic
    ["RUN AF20"] = {26666, 26842, 27018, 27194, 27370, 0,0,0,29328},
    ["RUN AF21"] = {26667, 26843, 27019, 27195, 27371, 0,0,0,29329},
    ["RUN AF22"] = {23084, 23151, 23218, 23285, 23352, 0,0,0,29337},
    ["RUN AF23"] = {23419, 23486, 23553, 23620, 23687, 0,0,0,29338},
    --Empyrean
    ["RUN AF30"] = {26782, 26940, 27094, 27279, 27453, 0,0,0,29331},
    ["RUN AF31"] = {26783, 26941, 27095, 27280, 27454, 0,0,0,29332},
    ["RUN AF32"] = {},
    ["RUN AF33"] = {},
    
    --Misc
    ['Slip 15']  = {afSlip10},
    ['Slip 16']  = {afSlip11},
    ['Slip 17']  = {afSlip20},
    ['Slip 18']  = {afSlip21},
    ['Slip 20']  = {afSlip30},
    ['Slip 21']  = {afSlip31},
    ['Slip 24']  = {afSlip12},
    ['Slip 25']  = {afSlip13},
    ['Slip 26']  = {afSlip22},
    ['Slip 27']  = {afSlip23},   
    
}
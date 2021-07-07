 --Copyright © 2013, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
language = 'english'
skillchain_arr = {'Light:','Darkness:','Gravitation:','Fragmentation:','Distortion:','Fusion:','Compression:','Liquefaction:','Induration:','Reverberation:','Transfixion:','Scission:','Detonation:','Impaction:','Radiance:','Umbra:'}
ratings_arr = {'TW','IEP','EP','DC','EM','T','VT','IT'}
current_job = 'NONE'
default_filt = false
parse_quantity = false
targets_condensed = false
common_nouns = T{}
plural_entities = T{}
item_quantity = {id = 0, count = ''}
rcol = string.char(0x1E,0x01)
non_block_messages = T{1,2,7,14,15,24,25,26,30,31,32,33,44,63,67,69,70,77,102,103,110,122,132,152,157,158,161,162,163,165,167,185,187,188,196,197,223,224,225,226,227,228,229,238,245,252,263,264,265,274,275,276,281,282,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,306,317,318,324,352,353,354,357,358,366,367,373,379,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,409,413,451,452,454,522,535,536,537,539,576,577,587,588,592,603,606,648,650,651,658,732,736,746,747,748,749,750,751,752,753,767,768,769,770,781}
passed_messages = T{4,5,6,16,17,18,20,34,35,36,38,40,47,48,49,53,62,64,72,78,87,88,89,90,94,97,112,116,154,170,171,172,173,174,175,176,177,178,191,192,198,204,206,215,217,218,219,234,246,249,251,307,308,313,315,328,336,350,523,530,531,558,561,563,575,584,601,609,562,610,611,612,613,614,615,616,617,618,619,620,625,626,627,628,629,630,631,632,633,634,635,636,643,660,661,662,679}
agg_messages = T{85,653,655,75,156,189,248,323,355,408,422,425,82,93,116,127,131,134,151,144,146,148,150,166,186,194,230,236,237,242,243,268,271,319,320,364,375,412,414,416,420,424,426,432,433,441,602,645,668,435,437,439}
color_redundant = T{26,33,41,71,72,89,94,109,114,164,173,181,184,186,70,84,104,127,128,129,130,131,132,133,134,135,136,137,138,139,140,64,86,91,106,111,175,178,183,81,101,16,65,87,92,107,112,174,176,182,82,102,67,68,69,170,189,15,208,18,25,32,40,163,185,23,24,27,34,35,42,43,162,165,187,188,30,31,14,205,144,145,146,147,148,149,150,151,152,153,190,13,9,253,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,284,285,286,287,292,293,294,295,300,301,301,303,308,309,310,311,316,317,318,319,324,325,326,327,332,333,334,335,340,341,342,343,344,345,346,347,348,349,350,351,355,357,358,360,361,363,366,369,372,374,375,378,381,384,395,406,409,412,415,416,418,421,424,437,450,453,456,458,459,462,479,490,493,496,499,500,502,505,507,508,10,51,52,55,58,62,66,80,83,85,88,90,93,100,103,105,108,110,113,122,168,169,171,172,177,179,180,12,11,37,291} -- 37 and 291 might be unique colors, but they are not gsubbable.
block_messages = T{12}
block_modes = T{20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,40,41,42,43,56,57,59,60,61,63,104,109,114,162,163,164,165,181,185,186,187,188}
black_colors = T{}--352,354,356,388,390,400,402,430,432,442,444,472,474,484,486}
dmg_drain_msg = T{132,161,187,227,274,281,736,748,749,802,803}
grammar_numb_msg = T{14,31,133,231,369,370,382,385,386,387,388,389,390,391,392,393,394,395,396,397,398,400,401,403,404,405,411,417,535,536,557,570,571,589,607,651,757,769,770,778,792}

replacements_map = {
    actor = {
        hits = T{1,373},
        casts = T{2,7,42,82,83,85,86,93,113,114,227,228,230,236,237,252,268,271,274,275,309,329,330,331,332,333,334,335,341,342,430,431,432,433,454,533,534,570,572,642,647,653,655},
        starts = T{3,327,716},
        gains = T{8,54,105,166,253,371,372,718,735},
        apos = T{14,16,33,69,70,75,248,310,312,352,353,354,355,382,493,535,574,575,576,577,592,606,798,799},
        misses = T{15,63},
        learns = T{23,45,442},
        uses = T{28,77,100,101,102,103,108,109,110,115,116,117,118,119,120,121,122,123,125,126,127,129,131,133,134,135,136,137,138,139,140,141,142,143,144,146,148,150,153,156,157,158,159,185,186,187,188,189,194,197,221,224,225,226,231,238,242,243,245,303,304,305,306,317,318,319,320,321,322,323,324,360,362,364,369,370,375,376,377,378,379,399,400,401,402,405,406,407,408,409,412,413,414,416,417,418,420,422,424,425,426,435,
        437,439,441,451,452,453,519,520,521,522,526,527,528,529,532,539,560,585,591,593,594,595,596,597,598,599,602,607,608,644,645,646,657,658,663,664,667,668,670,671,672,674,730,734,736,737,738,743,746,747,748,750,752,754,755,758,762,763,764,765,766,778,779,780,792,802,803,804,805,1023},
        is = T{29,49,84,106,191},
        does = T{34,91,192},
        readies = T{43,326,675},
        earns = T{50,368,719},
        steals = T{125,133,453,593,594,595,596,597,598,599},
        recovers = T{152,167},
        butmissestarget = T{188,245,324,658},
        eats = T{600,604},
        leads = T{648,650,651},
        has = T{515,661,665,688},
        obtains = T{582,673},
    },
    target = {
        takes = T{2,67,77,110,157,185,196,197,229,252,264,265,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,317,353,379,413,522,648,650,732,747,767,768,800},
        is = T{4,13,64,78,82,86,107,127,128,130,131,134,136,141,148,149,150,151,154,198,203,204,232,236,242,246,270,271,272,277,279,286,287,313,328,350,519,520,521,529,531,586,591,593,594,595,596,597,598,599,645,754,776},
        recovers = T{7,24,25,26,74,102,103,224,238,263,276,306,318,367,373,382,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,651,769,770},
        apos = T{31,38,44,53,73,83,106,112,116,120,121,123,132,159,168,206,221,231,249,285,308,314,321,322,329,330,331,332,333,334,335,341,342,343,344,351,360,361,362,363,364,365,369,374,378,383,399,400,401,402,403,405,407,409,417,418,430,431,435,436,437,438,439,440,459,530,533,534,537,570,571,572,585,606,607,641,642,644,647,676,730,743,756,757,762,792,805,806,1023},
        falls = T{20,113,406,605,646},
        uses = T{79,80},
        resists = T{85,197,284,653,654},
        vanishes = T{93,273},
        receives = T{142,144,145,146,147,237,243,267,268,269,278,320,375,412,414,415,416,420,421,424,432,433,441,532,557,602,668,672,739,755,804},
        seems = T{170,171,172,173,174,175,176,177,178},
        gains = T{186,194,205,230,266,280,319},
        regains = T{357,358,439,440,451,452,539,587,588},
        obtains = T{376,377,565,566,765,766},
        loses = T{426,427,652},
        was = T{97,564},
        has = T{589,684,763},
        compresists = T{655,656},
    },
    number = {
        points = T{1,2,8,10,33,38,44,54,67,77,105,110,157,163,185,196,197,223,229,252,253,264,265,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,310,317,352,353,371,372,373,379,382,385,386,387,388,389,390,391,392,393,394,395,396,397,398,413,522,536,576,577,648,650,651,718,721,722,723,724,725,726,727,728,729,732,735,747,767,768,769,770,800},
        absorbs = T{14,31,535},
        disappears = T{14,31,231,400,401,405,535,570,571,607,757,792,},
        attributes = T{369,403,417},
        status = T{370,404},
        
    },
    the = {
        point = T{33,308,536,800},
    }
}

domain_buffs = S{
    250, -- EF Badge
    257, -- Besieged
    267, -- Allied Tags
    --292, -- Pennant?
    --475, -- Voidwatcher
    511, -- Reive Mark
    603, -- Elvorseal
    } -- EF BadElvorseal, Allied Tags, EF Badge?

--    resists = {85,284}
--    immunobreaks = {653,654}
--    complete_resists = {655,656}
--    no_effects = {75,156,189,248,323,355,408,422,425,283,423,659}
--    receives = {82,116,127,131,134,151,144,146,148,150,166,186,194,230,236,237,242,243,268,271,319,320,364,375,412,414,416,420,424,426,432,433,441,602,645,668,203,205,266,270,272,277,279,280,285,145,147,149,151,267,269,278,286,287,365,415,421,427}
--    vanishes = {93,273}

no_effect_map = T{248,355,189,75,408,156,0,0,0,0,189,0,189,156,156}
receives_map = T{0,0,186,82,375,116,0,0,0,0,186,0,127,116,116}
stat_ignore = T{66,69,70,71,444,445,446}
enfeebling = T{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,155,156,157,158,159,167,168,174,175,177,186,189,192,193,194,223,259,260,261,262,263,264,298,378,379,380,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,404,448,449,450,451,452,473,540,557,558,559,560,561,562,563,564,565,566,567}

reaction_offsets = {
    [1] = 8,
    [3] = 24,
    [4] = 0,
    [6] = 16,
    [11] = 24,
    [13] = 24,
    [14] = 16,
    [15] = 24,
}

female_races = T{2,4,6,7}
male_races = T{1,3,5,8}

color_arr = {}
default_color_table = {mob=69,other=8,
p0=501,p1=204,p2=410,p3=492,p4=259,p5=260,
a10=205,a11=359,a12=167,a13=038,a14=125,a15=185,
a20=429,a21=257,a22=200,a23=481,a24=483,a25=208,
mobdmg=0,mydmg=0,partydmg=0,allydmg=0,otherdmg=0,
spellcol=0,abilcol=0,wscol=0,mobwscol=0,mobspellcol=0,statuscol=191,itemcol=256,enfeebcol=475}

filter = {}
multi_targs = {}
multi_actor = {}
multi_msg = {}
line_aoe       = 'AOE ${numb} '..string.char(129,168)..' ${target}'
line_aoebuff   = '${actor} ${abil} '..string.char(129,168)..' ${target} (${status})'
line_full      = '[${actor}] ${numb} ${abil} '..string.char(129,168)..' ${target}'
line_itemnum   = '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${numb} ${item2})'
line_item      = '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${item2})'
line_steal     = '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${item})'
line_noability = '${numb} '..string.char(129,168)..' ${target}'
line_noactor   = '${abil} ${numb} '..string.char(129,168)..' ${target}'
line_nonumber  = '[${actor}] ${abil} '..string.char(129,168)..' ${target}'
line_notarget  = '[${actor}] ${abil} '..string.char(129,168)..' ${number}'
line_roll      = '${actor} ${abil} '..string.char(129,168)..' ${target} '..string.char(129,170)..' ${number}'

default_settings_table = {line_aoe       = 'AOE ${numb} '..string.char(129,168)..' ${target}',
            line_aoebuff   = '${actor} ${abil} '..string.char(129,168)..' ${target} (${status})',
            line_full      = '[${actor}] ${numb} ${abil} '..string.char(129,168)..' ${target}',
            line_itemnum   = '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${numb} ${item2})',
            line_item      = '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${item2})',
            line_steal     = '[${actor}] ${abil} '..string.char(129,168)..' ${target} (${item})',
            line_noability = '${numb} '..string.char(129,168)..' ${target}',
            line_noactor   = '${abil} ${numb} '..string.char(129,168)..' ${target}',
            line_nonumber  = '[${actor}] ${abil} '..string.char(129,168)..' ${target}',
            line_notarget  = '[${actor}] ${abil} '..string.char(129,168)..' ${number}',
            line_roll = '${actor} ${abil} '..string.char(129,168)..' ${target} '..string.char(129,170)..' ${number}',
    condensedamage=true,condensetargets=true,cancelmulti=true,oxford=true,commamode=false,targetnumber=true,condensetargetname=false,swingnumber=true,sumdamage=true,condensecrits=false,showownernames=false,crafting=true,}

message_map = {}
for n=1,700,1 do
    message_map[n] = T{}
end

message_map[85] = T{284} -- resist
message_map[653] = T{654} -- immunobreak
message_map[655] = T{656} -- complete resist
message_map[93] = T{273} -- vanishes
--    message_map[75] =  -- no effect spell
message_map[156] = T{156,323,422,425} -- no effect ability
message_map[75] = T{283} -- No Effect: Spell, Target
--    message_map[189] = -- no effect ws
--    message_map[408] = -- no effect item
message_map[248] = T{355} -- no ability of any kind
message_map['No effect'] = T{283,423,659} -- generic "no effect" messages for sorting by category
message_map[432] = T{433} -- Receives: Spell, Target
message_map[82] = T{230,236,237,267,268,271} -- Receives: Spell, Target, Status
message_map[230] = T{266} -- Receives: Spell, Target, Status
message_map[319] = T{266} -- Receives: Spell, Target, Status (Generic for avatar buff BPs)
message_map[134] = T{287} -- Receives: Spell, Target, Status
message_map[116] = T{131,134,144,146,148,150,364,414,416,441,602,668,285,145,147,149,151,286,287,365,415,421} -- Receives: Ability, Target
message_map[127]=T{319,320,645} -- Receives: Ability, Target, Status
message_map[420]=T{424} -- Receives: Ability, Target, Status, Number
message_map[375] = T{412}-- Receives: Item, Target, Status
--    message_map[166] =  -- receives additional effect
message_map[186] = T{194,242,243}-- Receives: Weapon skill, Target, Status
message_map.Receives = T{203,205,270,272,277,279,280,266,267,269,278}
message_map[426] = T{427} -- Loses
message_map[320] = T{267}
message_map[414] = T{415} -- Dream Shroud
message_map[7] = T{263}
message_map[148] = T{149}
message_map[441] = T{421}
message_map[131] = T{286}
message_map[150] = T{151}
message_map[420] = T{421}
message_map[424] = T{421}
message_map[437] = T{438}
message_map[126] = T{676}
message_map[268] = T{269}
message_map[271] = T{272}
message_map[252] = T{265}
message_map[360] = T{361}
message_map[362] = T{363}
message_map[318] = T{263} -- Whispering Wind
message_map[323] = T{283} -- No effect Soothing Ruby
message_map[364] = T{365} -- Ecliptic Growl
message_map[146] = T{147} -- Ecliptic Howl
message_map[236] = T{270}
message_map[194] = T{280}
message_map[185] = T{264}
message_map[243] = T{278}
message_map[2] = T{264}
message_map[668] = T{669} -- Valiance
message_map[762] = T{365} -- Mix: Samson's Strength
message_map[242] = T{277}
message_map[238] = T{367} -- Phototrophic Blessing
message_map[188] = T{282} -- Misses
message_map[342] = T{344} -- Dispelga
message_map[369] = T{403} -- Ultimate Terror

spike_effect_valid = {true,false,false,false,false,false,false,false,false,false,false,false,false,false,false}
add_effect_valid = {true,true,true,true,false,false,false,false,false,false,true,false,true,false,false}

-- These are the debuffs that are expressed in their log form by battlemod (The status variable when using english log is code 14 while the other one is code 13 so it should be handled by messages)
--log_form_debuffs = T{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,28,29,30,31,134,135,155,156,157,168,176,177,259,260,261,262,263,264,309,474}
log_form_messages = T{64,73,82,127,128,130,141,203,204,236,242,270,271,272,277,279,350,374,531,645,754}


default_filters = [[
<?xml version="1.0" ?>
<settings>
<!-- Filters are customizable based on the action user. So if you filter other pets, you're going
     to eliminate all messages initiated by everyone's pet but your own.
     True means "filter this"
     False means "don't filter this"
     
     Generally, the outer tag is the actor and the inner tag is the action.
     If the monster is the actor, then the inner tag is the target and the tag beyond that is the action.-->
    <global>
        <me> <!-- You're doing something -->
            <melee>false</melee>  <!-- Prevents your melee ("white") damage from appearing -->
            <ranged>false</ranged> <!-- Prevents your ranged damage from appearing -->
            <damage>false</damage> <!-- Prevents your damage from appearing -->
            <healing>false</healing> <!-- Prevents your healing from appearing -->
            <misses>false</misses> <!-- Prevents your misses from appearing -->
            <items>false</items> <!-- Prevents your "Jim used an item. Jim gains the effect of Reraise." messages from appearing -->
            <uses>false</uses> <!-- Prevents your "Jim uses an item." messages from appearing -->
            <readies>false</readies> <!-- Prevents your "Jim readies ____" messages from appearing -->
            <casting>false</casting> <!-- Prevents your "Jim begins casting ____" messages from appearing -->
            <all>false</all> <!-- Prevents all of your messages from appearing -->
            
            <target>true</target> <!-- true = SHOW all actions where I am the target. -->
        </me>
        <party> <!-- A party member is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <items>false</items>
            <uses>false</uses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </party>
        <alliance> <!-- An alliance member is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <items>false</items>
            <uses>false</uses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </alliance>
        <others> <!-- Some guy nearby is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <items>false</items>
            <uses>false</uses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </others>
        <my_pet> <!-- Your pet is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </my_pet>
        <my_fellow> <!-- Your adventuring fellow is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </my_fellow>
        <other_pets> <!-- Someone else's pet is doing something -->
            <melee>false</melee>
            <ranged>false</ranged>
            <damage>false</damage>
            <healing>false</healing>
            <misses>false</misses>
            <readies>false</readies>
            <casting>false</casting>
            <all>false</all>
        </other_pets>

        <enemies> <!-- Monster that your party has claimed doing something with one of the below targets -->
            <me> <!-- He's targeting you! -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </me>
            <party> <!-- He's targeting a party member -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </party>
            <alliance> <!-- He's targeting an alliance member -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </alliance>
            <others> <!-- He's targeting some guy nearby -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </others>
            <my_pet> <!-- He's targeting your pet -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </my_pet>
            <my_fellow> <!-- He's targeting your adventuring fellow -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </my_fellow>
            <other_pets> <!-- He's targeting someone else's pet -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </other_pets>
            <enemies> <!-- He's targeting himself or another monster your party has claimed -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </enemies>
            <monsters> <!-- He's targeting another monster -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </monsters>
        </enemies>

        <monsters> <!-- NPC not claimed to your party is doing something with one of the below targets -->
            <me> <!-- He's targeting you! -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </me>
            <party> <!-- He's targeting a party member -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </party>
            <alliance> <!-- He's targeting an alliance member -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </alliance>
            <others> <!-- He's targeting some guy nearby -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </others>
            <my_pet> <!-- He's targeting your pet -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </my_pet>
            <my_fellow> <!-- He's targeting your adventuring fellow -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </my_fellow>
            <other_pets> <!-- He's targeting someone else's pet -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </other_pets>
            <enemies> <!-- He's targeting a monster your party has claimed -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </enemies>
            <monsters> <!-- He's targeting himself or another monster -->
                <melee>false</melee>
                <ranged>false</ranged>
                <damage>false</damage>
                <healing>false</healing>
                <misses>false</misses>
                <items>false</items>
                <uses>false</uses>
                <readies>false</readies>
                <casting>false</casting>
                <all>false</all>
            </monsters>
        </monsters>
    </global>
</settings>
]]

default_filter_table = {me={melee=false,ranged=false,damage=false,healing=false,misses=false,items=false,uses=false,readies=false,casting=false,all=false,target=true},
party={melee=false,ranged=false,damage=false,healing=false,misses=false,items=false,uses=false,readies=false,casting=false,all=false,target=false},
alliance={melee=false,ranged=false,damage=false,healing=false,misses=false,items=false,uses=false,readies=false,casting=false,all=false,target=false},
others={melee=false,ranged=false,damage=false,healing=false,misses=false,items=false,uses=false,readies=false,casting=false,all=false,target=false},
my_pet={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false,target=false},
my_fellow={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false,target=false},
other_pets={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false,target=false},
monsters = {
me={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
party={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
alliance={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
others={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
my_pet={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
my_fellow={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
other_pets={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false},
monsters={melee=false,ranged=false,damage=false,healing=false,misses=false,readies=false,casting=false,all=false}} }

default_settings = [[
<?xml version="1.0" ?>
<settings>
<!-- For the output customization lines, ${actor} denotes a value to be replaced. The options are actor, number, abil, and target.
     Options for other modes are either "true" or "false". Other values will not be interpreted.-->
    <global>
        <condensedamage>true</condensedamage>
        <condensetargets>true</condensetargets>
        <cancelmulti>true</cancelmulti>
        <oxford>true</oxford>
        <commamode>false</commamode>
        <targetnumber>true</targetnumber>
        <condensetargetname>false</condensetargetname>
        <swingnumber>true</swingnumber>
        <sumdamage>true</sumdamage>
        <condensecrits>false</condensecrits>
        <tpstatuses>true</tpstatuses>
        <simplify>true</simplify>
        <showownernames>false</showownernames>
        <crafting>true</crafting>
        <line_aoe>AOE ${numb} ]]..string.char(129,168)..[[ ${target}</line_aoe>        
        <line_aoebuff>${actor} ${abil} ]]..string.char(129,168)..[[ ${target} (${status})</line_aoebuff>
        <line_full>[${actor}] ${numb} ${abil} ]]..string.char(129,168)..[[ ${target}</line_full>        
        <line_item>[${actor}] ${abil} ]]..string.char(129,168)..[[ ${target} (${item2})</line_item>
        <line_itemnum>[${actor}] ${abil} ]]..string.char(129,168)..[[ ${target} (${numb} ${item2})</line_itemnum>
        <line_noability>${numb} ]]..string.char(129,168)..[[ ${target}</line_noability>
        <line_noactor>${abil} ${numb} ]]..string.char(129,168)..[[ ${target}</line_noactor>
        <line_nonumber>[${actor}] ${abil} ]]..string.char(129,168)..[[ ${target}</line_nonumber>
        <line_notarget>[${actor}] ${abil} ]]..string.char(129,168)..[[ ${number}</line_notarget>
        <line_roll>${actor} ${abil} ]]..string.char(129,168)..[[ ${target} ]]..string.char(129,170)..[[ ${number}</line_roll>
    </global>
</settings>
]]

default_colors = [[
<? xml version="1.0" ?>
<settings>
<!-- Colors are customizable based on party / alliance position. Use the colortest command to view the available colors.
     If you wish for a color to be unchanged from its normal color, set it to 0. -->
    <global>
        <mob>69</mob>
        <other>8</other>
        
        <p0>501</p0>
        <p1>204</p1>
        <p2>410</p2>
        <p3>492</p3>
        <p4>259</p4>
        <p5>260</p5>
        
        <a10>205</a10>
        <a11>359</a11>
        <a12>167</a12>
        <a13>038</a13>
        <a14>125</a14>
        <a15>185</a15>
        
        <a20>429</a20>
        <a21>257</a21>
        <a22>200</a22>
        <a23>481</a23>
        <a24>483</a24>
        <a25>208</a25>
        
        <mobdmg>0</mobdmg>
        <mydmg>0</mydmg>
        <partydmg>0</partydmg>
        <allydmg>0</allydmg>
        <otherdmg>0</otherdmg>
        
        <spellcol>0</spellcol>
        <mobspellcol>0</mobspellcol>
        <abilcol>0</abilcol>
        <wscol>0</wscol>
        <mobwscol>0</mobwscol>
        <statuscol>0</statuscol>
        <enfeebcol>501</enfeebcol>
        <itemcol>256</itemcol>
    </global>
</settings>
]]

local item_lag_preventer = table.length(res.items)

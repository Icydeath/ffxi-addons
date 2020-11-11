local get = {}

get.songs = {
    paeon = {'Army\'s Paeon VI','Army\'s Paeon V','Army\'s Paeon IV','Army\'s Paeon III','Army\'s Paeon II','Army\'s Paeon'},
    ballad = {'Mage\'s Ballad III','Mage\'s Ballad II','Mage\'s Ballad'},
    minne = {'Knight\'s Minne V','Knight\'s Minne IV','Knight\'s Minne III','Knight\'s Minne II','Knight\'s Minne'},
    march = {'Victory March','Advancing March'},
    minuet = {'Valor Minuet V','Valor Minuet IV','Valor Minuet III','Valor Minuet II','Valor Minuet'}, 
    madrigal = {'Blade Madrigal','Sword Madrigal'},
    prelude = {'Archer\'s Prelude','Hunter\'s Prelude'},
    mambo = {'Dragonfoe Mambo','Sheepfoe Mambo'},
    aubade = {'Fowl Aubade'},
    pastoral = {'Herb Pastoral'},
    fantasia = {'Shining Fantasia'},
    operetta = {'Puppet\'s Operetta','Scop\'s Operetta'},
    capriccio = {'Gold Capriccio'},
    round = {'Warding Round'},
    gavotte = {'Shining Fantasia'},
    hymnus = {'Goddess\'s Hymnus'},
    mazurka = {'Chocobo Mazurka'},
    sirvente = {'Foe Sirvente'},
    dirge = {'Adventurer\'s Dirge'},
    scherzo = {'Sentinel\'s Scherzo'},
    setude = {'Herculean Etude','Sinewy Etude'},
    detude = {'Uncanny Etude','Dextrous Etude'},
    vetude = {'Vital Etude','Vivacious Etude'},
    aetude = {'Swift Etude','Quick Etude'},
    ietude = {'Sage Etude','Learned Etude'},
    metude = {'Logical Etude','Spirited Etude'},
    cetude = {'Bewitching Etude','Enchanting Etude'},
    fcarol = {'Fire Carol','Fire Carol II'},
    icarol = {'Ice Carol','Ice Carol II'},
    wcarol = {'Wind Carol','Wind Carol II'},
    ecarol = {'Earth Carol','Earth Carol II'},
    tcarol = {'Lightning Carol','Lightning Carol II'},
    acarol = {'Water Carol','Water Carol II'},
    lcarol = {'Light Carol','Light Carol II'},
    dcarol = {'Dark Carol','Dark Carol II'},
    }

local song = {
    [368] = 'Foe Requiem',
    [369] = 'Foe Requiem II',
    [370] = 'Foe Requiem III',
    [371] = 'Foe Requiem IV',
    [372] = 'Foe Requiem V',
    [373] = 'Foe Requiem VI',
    [374] = 'Foe Requiem VII',
    [375] = 'Foe Requiem VIII',
    [376] = 'Horde Lullaby',
    [377] = 'Horde Lullaby II',
    [378] = 'Army\'s Paeon',
    [379] = 'Army\'s Paeon II',
    [380] = 'Army\'s Paeon III',
    [381] = 'Army\'s Paeon IV',
    [382] = 'Army\'s Paeon V',
    [383] = 'Army\'s Paeon VI',
    [384] = 'Army\'s Paeon VII',
    [385] = 'Army\'s Paeon VIII',
    [386] = 'Mage\'s Ballad',
    [387] = 'Mage\'s Ballad II',
    [388] = 'Mage\'s Ballad III',
    [389] = 'Knight\'s Minne',
    [390] = 'Knight\'s Minne II',
    [391] = 'Knight\'s Minne III',
    [392] = 'Knight\'s Minne IV',
    [393] = 'Knight\'s Minne V',
    [394] = 'Valor Minuet',
    [395] = 'Valor Minuet II',
    [396] = 'Valor Minuet III',
    [397] = 'Valor Minuet IV',
    [398] = 'Valor Minuet V',
    [399] = 'Sword Madrigal',
    [400] = 'Blade Madrigal',
    [401] = 'Hunter\'s Prelude',
    [402] = 'Archer\'s Prelude',
    [403] = 'Sheepfoe Mambo',
    [404] = 'Dragonfoe Mambo',
    [405] = 'Fowl Aubade',
    [406] = 'Herb Pastoral',
    [407] = 'Chocobo Hum',
    [408] = 'Shining Fantasia',
    [409] = 'Scop\'s Operetta',
    [410] = 'Puppet\'s Operetta',
    [411] = 'Jester\'s Operetta',
    [412] = 'Gold Capriccio',
    [413] = 'Devotee Serenade',
    [414] = 'Warding Round',
    [415] = 'Goblin Gavotte',
    [416] = 'Cactuar Fugue',
    [417] = 'Honor March',
    [418] = 'Protected Aria',
    [419] = 'Advancing March',
    [420] = 'Victory March',
    [421] = 'Battlefield Elegy',
    [422] = 'Carnage Elegy',
    [423] = 'Massacre Elegy',
    [424] = 'Sinewy Etude',
    [425] = 'Dextrous Etude',
    [426] = 'Vivacious Etude',
    [427] = 'Quick Etude',
    [428] = 'Learned Etude',
    [429] = 'Spirited Etude',
    [430] = 'Enchanting Etude',
    [431] = 'Herculean Etude',
    [432] = 'Uncanny Etude',
    [433] = 'Vital Etude',
    [434] = 'Swift Etude',
    [435] = 'Sage Etude',
    [436] = 'Logical Etude',
    [437] = 'Bewitching Etude',
    [438] = 'Fire Carol',
    [439] = 'Ice Carol',
    [440] = 'Wind Carol',
    [441] = 'Earth Carol',
    [442] = 'Lightning Carol',
    [443] = 'Water Carol',
    [444] = 'Light Carol',
    [445] = 'Dark Carol',
    [446] = 'Fire Carol II',
    [447] = 'Ice Carol II',
    [448] = 'Wind Carol II',
    [449] = 'Earth Carol II',
    [450] = 'Lightning Carol II',
    [451] = 'Water Carol II',
    [452] = 'Light Carol II',
    [453] = 'Dark Carol II',
    [454] = 'Fire Threnody',
    [455] = 'Ice Threnody',
    [456] = 'Wind Threnody',
    [457] = 'Earth Threnody',
    [458] = 'Ltng. Threnody',
    [459] = 'Water Threnody',
    [460] = 'Light Threnody',
    [461] = 'Dark Threnody',
    [462] = 'Magic Finale',
    [463] = 'Foe Lullaby',
    [464] = 'Goddess\'s Hymnus',
    [465] = 'Chocobo Mazurka',
    [466] = 'Maiden\'s Virelai',
    [467] = 'Raptor Mazurka',
    [468] = 'Foe Sirvente',
    [469] = 'Adventurer\'s Dirge',
    [470] = 'Sentinel\'s Scherzo',
    [471] = 'Foe Lullaby II',
    [472] = 'Pining Nocturne',
    }

local spell = {
    [57] = {id=57,enl='Haste',dur=180},
    [109] = {id=109,enl='Refresh',dur=150},
}

local trusts = T{
    [1]={id=896,japanese="シャントット",english="Shantotto",name="Shantotto",models=3000},
    [2]={id=897,japanese="ナジ",english="Naji",name="Naji",models=3001},
    [3]={id=898,japanese="クピピ",english="Kupipi",name="Kupipi",models=3002},
    [4]={id=899,japanese="エグセニミル",english="Excenmille",name="Excenmille",models=3003},
    [5]={id=900,japanese="アヤメ",english="Ayame",name="Ayame",models=3004},
    [6]={id=901,japanese="ナナー・ミーゴ",english="Nanaa Mihgo",name="NanaaMihgo",models=3005},
    [7]={id=902,japanese="クリルラ",english="Curilla",name="Curilla",models=3006},
    [8]={id=903,japanese="フォルカー",english="Volker",name="Volker",models=3007},
    [9]={id=904,japanese="アジドマルジド",english="Ajido-Marujido",name="Ajido-Marujido",models=3008},
    [10]={id=905,japanese="トリオン",english="Trion",name="Trion",models=3009},
    [11]={id=906,japanese="ザイド",english="Zeid",name="Zeid",models=3010},
    [12]={id=907,japanese="ライオン",english="Lion",name="Lion",models=3011},
    [13]={id=908,japanese="テンゼン",english="Tenzen",name="Tenzen",models=3012},
    [14]={id=909,japanese="ミリ・アリアポー",english="Mihli Aliapoh",name="MihliAliapoh",models=3013},
    [15]={id=910,japanese="ヴァレンラール",english="Valaineral",name="Valaineral",models=3014},
    [16]={id=911,japanese="ヨアヒム",english="Joachim",name="Joachim",models=3015},
    [17]={id=912,japanese="ナジャ・サラヒム",english="Naja Salaheem",name="NajaSalaheem",models=3016},
    [18]={id=913,japanese="プリッシュ",english="Prishe",name="Prishe",models=3017},
    [19]={id=914,japanese="ウルミア",english="Ulmia",name="Ulmia",models=3018},
    [20]={id=915,japanese="スカリーZ",english="Shikaree Z",name="ShikareeZ",models=3019},
    [21]={id=916,japanese="チェルキキ",english="Cherukiki",name="Cherukiki",models=3020},
    [22]={id=917,japanese="アイアンイーター",english="Iron Eater",name="IronEater",models=3021},
    [23]={id=918,japanese="ゲッショー",english="Gessho",name="Gessho",models=3022},
    [24]={id=919,japanese="ガダラル",english="Gadalar",name="Gadalar",models=3023},
    [25]={id=920,japanese="ライニマード",english="Rainemard",name="Rainemard",models=3024},
    [26]={id=921,japanese="イングリッド",english="Ingrid",name="Ingrid",models=3025},
    [27]={id=922,japanese="レコ・ハボッカ",english="Lehko Habhoka",name="LehkoHabhoka",models=3026},
    [28]={id=923,japanese="ナシュメラ",english="Nashmeira",name="Nashmeira",models=3027},
    [29]={id=924,japanese="ザザーグ",english="Zazarg",name="Zazarg",models=3028},
    [30]={id=925,japanese="アヴゼン",english="Ovjang",name="Ovjang",models=3029},
    [31]={id=926,japanese="メネジン",english="Mnejing",name="Mnejing",models=3030},
    [32]={id=927,japanese="サクラ",english="Sakura",name="Sakura",models=3031},
    [33]={id=928,japanese="ルザフ",english="Luzaf",name="Luzaf",models=3032},
    [34]={id=929,japanese="ナジュリス",english="Najelith",name="Najelith",models=3033},
    [35]={id=930,japanese="アルド",english="Aldo",name="Aldo",models=3034},
    [36]={id=931,japanese="モーグリ",english="Moogle",name="Moogle",models=3035},
    [37]={id=932,japanese="ファブリニクス",english="Fablinix",name="Fablinix",models=3036},
    [38]={id=933,japanese="マート",english="Maat",name="Maat",models=3037},
    [39]={id=934,japanese="D.シャントット",english="D. Shantotto",name="D.Shantotto",models=3038},
    [40]={id=935,japanese="星の神子",english="Star Sibyl",name="StarSibyl",models=3039},
    [41]={id=936,japanese="カラハバルハ",english="Karaha-Baruha",name="Karaha-Baruha",models=3040},
    [42]={id=937,japanese="シド",english="Cid",name="Cid",models=3041},
    [43]={id=938,japanese="ギルガメッシュ",english="Gilgamesh",name="Gilgamesh",models=3042},
    [44]={id=939,japanese="アレヴァト",english="Areuhat",name="Areuhat",models=3043},
    [45]={id=940,japanese="セミ・ラフィーナ",english="Semih Lafihna",name="SemihLafihna",models=3044},
    [46]={id=941,japanese="エリヴィラ",english="Elivira",name="Elivira",models=3045},
    [47]={id=942,japanese="ノユリ",english="Noillurie",name="Noillurie",models=3046},
    [48]={id=943,japanese="ルー・マカラッカ",english="Lhu Mhakaracca",name="LhuMhakaracca",models=3047},
    [49]={id=944,japanese="フェリアスコフィン",english="Ferreous Coffin",name="FerreousCoffin",models=3048},
    [50]={id=945,japanese="リリゼット",english="Lilisette",name="Lilisette",models=3049},
    [51]={id=946,japanese="ミュモル",english="Mumor",name="Mumor",models=3050},
    [52]={id=947,japanese="ウカ・トトゥリン",english="Uka Totlihn",name="UkaTotlihn",models=3051},
    [53]={id=948,japanese="クララ",english="Klara",name="Klara",models=3053},
    [54]={id=949,japanese="ロマー・ミーゴ",english="Romaa Mihgo",name="RomaaMihgo",models=3054},
    [55]={id=950,japanese="クイン・ハスデンナ",english="Kuyin Hathdenna",name="KuyinHathdenna",models=3055},
    [56]={id=951,japanese="ラーアル",english="Rahal",name="Rahal",models=3056},
    [57]={id=952,japanese="コルモル",english="Koru-Moru",name="Koru-Moru",models=3057},
    [58]={id=953,japanese="ピエージェ(UC)",english="Pieuje (UC)",name="Pieuje",models=3058},
    [59]={id=954,japanese="I.シールド(UC)",english="I. Shield (UC)",name="InvincibleShld",models=3060},
    [60]={id=955,japanese="アプルル(UC)",english="Apururu (UC)",name="Apururu",models=3061},
    [61]={id=956,japanese="ジャコ(UC)",english="Jakoh (UC)",name="JakohWahcondalo",models=3062},
    [62]={id=957,japanese="フラヴィリア(UC)",english="Flaviria (UC)",name="Flaviria",models=3059},
    [63]={id=958,japanese="ウェイレア",english="Babban",name="Babban",models=3067},
    [64]={id=959,japanese="アベンツィオ",english="Abenzio",name="Abenzio",models=3068},
    [65]={id=960,japanese="ルガジーン",english="Rughadjeen",name="Rughadjeen",models=3069},
    [66]={id=961,japanese="クッキーチェブキー",english="Kukki-Chebukki",name="Kukki-Chebukki",models=3070},
    [67]={id=962,japanese="マルグレート",english="Margret",name="Margret",models=3071},
    [68]={id=963,japanese="チャチャルン",english="Chacharoon",name="Chacharoon",models=3072},
    [69]={id=964,japanese="レイ・ランガヴォ",english="Lhe Lhangavo",name="LheLhangavo",models=3073},
    [70]={id=965,japanese="アシェラ",english="Arciela",name="Arciela",models=3074},
    [71]={id=966,japanese="マヤコフ",english="Mayakov",name="Mayakov",models=3075},
    [72]={id=967,japanese="クルタダ",english="Qultada",name="Qultada",models=3076},
    [73]={id=968,japanese="アーデルハイト",english="Adelheid",name="Adelheid",models=3077},
    [74]={id=969,japanese="アムチュチュ",english="Amchuchu",name="Amchuchu",models=3078},
    [75]={id=970,japanese="ブリジッド",english="Brygid",name="Brygid",models=3079},
    [76]={id=971,japanese="ミルドリオン",english="Mildaurion",name="Mildaurion",models=3080},
    [77]={id=972,japanese="ハルヴァー",english="Halver",name="Halver",models=3087},
    [78]={id=973,japanese="ロンジェルツ",english="Rongelouts",name="Rongelouts",models=3088},
    [79]={id=974,japanese="レオノアーヌ",english="Leonoyne",name="Leonoyne",models=3089},
    [80]={id=975,japanese="マクシミリアン",english="Maximilian",name="Maximilian",models=3090},
    [81]={id=976,japanese="カイルパイル",english="Kayeel-Payeel",name="Kayeel-Payeel",models=3091},
    [82]={id=977,japanese="ロベルアクベル",english="Robel-Akbel",name="Robel-Akbel",models=3092},
    [83]={id=978,japanese="クポフリート",english="Kupofried",name="Kupofried",models=3093},
    [84]={id=979,japanese="セルテウス",english="Selh\'teus",name="Selh\'teus",models=3094},
    [85]={id=980,japanese="ヨランオラン(UC)",english="Yoran-Oran (UC)",name="Yoran-Oran",models=3095},
    [86]={id=981,japanese="シルヴィ(UC)",english="Sylvie (UC)",name="Sylvie",models=3096},
    [87]={id=982,japanese="アブクーバ",english="Abquhbah",name="Abquhbah",models=3098},
    [88]={id=983,japanese="バラモア",english="Balamor",name="Balamor",models=3099},
    [89]={id=984,japanese="オーグスト",english="August",name="August",models=3100},
    [90]={id=985,japanese="ロスレーシャ",english="Rosulatia",name="Rosulatia",models=3101},
    [91]={id=986,japanese="テオドール",english="Teodor",name="Teodor",models=3103},
    [92]={id=987,japanese="ウルゴア",english="Ullegore",name="Ullegore",models=3105},
    [93]={id=988,japanese="マッキーチェブキー",english="Makki-Chebukki",name="Makki-Chebukki",models=3106},
    [94]={id=989,japanese="キング・オブ・ハーツ",english="King of Hearts",name="KingOfHearts",models=3107},
    [95]={id=990,japanese="モリマー",english="Morimar",name="Morimar",models=3108},
    [96]={id=991,japanese="ダラクァルン",english="Darrcuiln",name="Darrcuiln",models=3109},
    [97]={id=992,japanese="アークHM",english="AAHM",name="ArkHM",models=3113},
    [98]={id=993,japanese="アークEV",english="AAEV",name="ArkEV",models=3114},
    [99]={id=994,japanese="アークMR",english="AAMR",name="ArkMR",models=3115},
    [100]={id=995,japanese="アークTT",english="AATT",name="ArkTT",models=3116},
    [101]={id=996,japanese="アークGK",english="AAGK",name="ArkGK",models=3117},
    [102]={id=997,japanese="イロハ",english="Iroha",name="Iroha",models=3111},
    [103]={id=998,japanese="ユグナス",english="Ygnas",name="Ygnas",models=3118},
    [104]={id=1004,japanese="エグセニミルII",english="Excenmille [S]",name="Excenmille",models=3052},
    [105]={id=1005,japanese="アヤメ(UC)",english="Ayame (UC)",name="Ayame",models=3063},
    [106]={id=1006,japanese="マート(UC)",english="Maat (UC)",name="Maat",models=3064}, --expected models
    [107]={id=1007,japanese="アルド(UC)",english="Aldo (UC)",name="Aldo",models=3065}, --expected models
    [108]={id=1008,japanese="ナジャ(UC)",english="Naja (UC)",name="NajaSalaheem",models=3066},
    [109]={id=1009,japanese="ライオンII",english="Lion II",name="Lion",models=3081},
    [110]={id=1010,japanese="ザイドII",english="Zeid II",name="Zeid",models=3086},
    [111]={id=1011,japanese="プリッシュII",english="Prishe II",name="Prishe",models=3082},
    [112]={id=1012,japanese="ナシュメラII",english="Nashmeira II",name="Nashmeira",models=3083},
    [113]={id=1013,japanese="リリゼットII",english="Lilisette II",name="Lilisette",models=3084},
    [114]={id=1014,japanese="テンゼンII",english="Tenzen II",name="Tenzen",models=3097},
    [115]={id=1015,japanese="ミュモルII",english="Mumor II",name="Mumor",models=3104},
    [116]={id=1016,japanese="イングリッドII",english="Ingrid II",name="Ingrid",models=3102},
    [117]={id=1017,japanese="アシェラII",english="Arciela II",name="Arciela",models=3085},
    [118]={id=1018,japanese="イロハII",english="Iroha II",name="Iroha",models=3112},
    [119]={id=1019,japanese="シャントットII",english="Shantotto II",name="Shantotto",models=3110},
--  [120]={id=1003,japanese="コーネリア",english="Cornelia",name="Cornelia",models=3119}, --goodbye, my love
}

--[[
song = {}
for k,v in ipairs(res.spells) do
    if v.type == 'BardSong' then
        song[k] = v.en
    end
end
]]

local equippable_bags = {
    'Inventory',
    'Wardrobe',
    'Wardrobe2',
    'Wardrobe3',
    'Wardrobe4'
    }

local extra_song_harp = {
    [18571] = 4, -- Daurdabla 99
    [18575] = 3, -- Daurdabla 90
    [18576] = 3, -- Daurdabla 95
    [18839] = 4, -- Daurdabla 99-2
    [21400] = 3, -- Blurred Harp
    [21401] = 3, -- Blurred Harp +1
    [21407] = 3, -- Terpander
    }

local honor_march_horn = {
    [21398] = true -- Marsyas
}

local function find_equippable_item(item_ids)
    for _, bag in ipairs(equippable_bags) do
        local items = windower.ffxi.get_items(bag)
        if items.enabled then
            for i,v in ipairs(items) do
                if item_ids[v.id] then
                    return item_ids[v.id]
                end
            end
        end
    end
end

get.jp_mods = {}

function initialize()
    local jp = windower.ffxi.get_player().job_points.brd
    get.jp_mods.clarion = jp.clarion_call_effect *2
    get.jp_mods.tenuto = jp.tenuto_effect *2
    get.jp_mods.marcato = jp.marcato_effect
    get.jp_mods.mult = jp.jp_spent >= 1200
    get.base_songs = 2
    for _, bag in ipairs(equippable_bags) do
        local items = windower.ffxi.get_items(bag)
        if items.enabled then
            for i,v in ipairs(items) do
                if extra_song_harp[v.id] and get.base_songs < extra_song_harp[v.id] then
                    get.base_songs = extra_song_harp[v.id]
                elseif honor_march_horn[v.id] and #get.songs.march == 2 then
                    table.insert(get.songs.march, 1, 'Honor March')
                end
            end
        end
    end
end
initialize()

function get.is_trust(mobname)
	for i, trust in pairs(trusts) do
		if trust.name == mobname or trust.english == mobname then
			return true
		end
	end
	
	return false
end

function get.buffs()
    local set_buff = {}
    for _, buff_id in ipairs(windower.ffxi.get_player().buffs) do
        local buff_en = res.buffs[buff_id].en:lower()
        if buff_id == 272 then
            set_buff[buff_en] = 10
        else
            set_buff[buff_en] = (set_buff[buff_en] or 0) + 1
        end
    end
    return set_buff
end

function get.spell_by_id(id)
    return spell[id]
end

function get.song_name(id)
    return song[id]
end

function get.spell(name)
    name = string.lower(name)
    for k,v in pairs(spell) do
        if v and v.enl and string.lower(v.enl) == name then
            return v
        end
    end
    return nil
end

function get.song_by_name(name)
    name = string.lower(name)
    for k,v in pairs(song) do
        if k ~= 'n' and string.lower(v) == name then
            return {id=k,enl=v}
        end
    end
    return nil
end

function get.maxsongs(targ,buffs)
    local maxsongs = get.base_songs
    if buffs['clarion call'] then
        maxsongs = maxsongs + 1 
    elseif timers[targ] and maxsongs < table.length(timers[targ]) then
        maxsongs = table.length(timers[targ])
    end
    return maxsongs
end

function get.song_list(songs,targ,maxsongs)
    local list = {}
    local clarion = settings.clarion[targ:lower()]
    for k,v in pairs(songs) do
        list[k] = v
    end
    if clarion and maxsongs > get.base_songs then
        list[clarion] = (list[clarion] or 0) + 1 
    end
    return list
end

function get.eye_sight(play,targ)
    if not targ then return false end
    return math.abs(-math.atan2(targ.y - play.y, targ.x - play.x) - play.facing) < 0.76
end

function get.valid_target(targ,dst)
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.in_party and member.mob.hpp > 0 and 
            member.mob.name:lower() == targ:lower() and math.sqrt(member.mob.distance) < dst and not member.mob.charmed then
            return true
        end
    end
    return false
end

function get.aoe_range()
    for ind,member in pairs(windower.ffxi.get_party()) do
        if type(member) == 'table' and member.mob and member.mob.in_party and member.mob.hpp > 0 and
            not settings.song[member.mob.name:lower()] and not settings.ignore:find(member.mob.name:lower()) and
            math.sqrt(member.mob.distance) >= 10 and not member.mob.charmed then
            return false
        end
    end
    return true
end

function get.nearest_mob(maxrange) -- maxrange is optional
	local id_targ
	local dist_targ = -1
	local marray = windower.ffxi.get_mob_array()
	
	for key,mob in pairs(marray) do
		--local mobtype = get.mob_type(mob) -- mobtype == "MONSTER" 
		local valid = true
		
		-- spawn_type: 16 = monster, 13 = self, 2 = npc, 14 = trust, 1 = player
		if mob.id > 0 and mob.spawn_type == 16 and mob.hpp == 100 and mob.name ~= '' then 

			-- not claimed by a party member.
			if settings.lullaby_partyclaimed and mob.claim_id and mob.claim_id > 0 and not get.is_party_member(mob.claim_id) then
				valid = false
			end
			
			if valid then
				if dist_targ == -1 then
					id_targ = mob["id"]
					dist_targ = math.sqrt(mob["distance"])
				elseif math.sqrt(mob["distance"]) < dist_targ then
					id_targ = mob["id"]
					dist_targ = math.sqrt(mob["distance"])
				end
			end
		end
	end
	--addon_message('nearest mob:'..id_targ)
	return id_targ
end

function get.is_party_member(id)
	local j = windower.ffxi.get_party()
	for i,v in pairs(j) do
		if type(v) == 'table' and v.mob then
			if v.mob.id == id then
				return true
			end
		end
	end
	return false
end

function get.mob_type(mob)
	if windower.ffxi.get_player().id == mob.id then
		return 'SELF'
	elseif mob.is_npc then
		if mob.id%4096>2047 then
			return 'NPC'
		else
			return 'MONSTER'
		end
	else
		return 'PLAYER'
	end
end

get.monster_list = {}
function get.lullaby_duration(spell_id) -- grabbed this code from sleeper.lua, thanks Sammeh
	local self = windower.ffxi.get_player()
	
	local troubadour = false
	local clarioncall = false
	local soulvoice = false
	local marcato = false
	
	for i,v in pairs(self.buffs) do
		if v == 348 then troubadour = true end
		if v == 499 then clarioncall = true end
		if v == 52 then soulvoice = true end
		if v == 231 then marcato = true end
	end
	
	
	lullaby_used = song[spell_id]
    local mult = 1
	
	local gear = windower.ffxi.get_items()
	local mainweapon = res_items[windower.ffxi.get_items(gear.equipment.main_bag, gear.equipment.main).id]
	local subweapon = res_items[windower.ffxi.get_items(gear.equipment.sub_bag, gear.equipment.sub).id]
	local range = res_items[windower.ffxi.get_items(gear.equipment.range_bag, gear.equipment.range).id]
	local ammo = res_items[windower.ffxi.get_items(gear.equipment.ammo_bag, gear.equipment.ammo).id]
	local head = res_items[windower.ffxi.get_items(gear.equipment.head_bag, gear.equipment.head).id]
	local neck = res_items[windower.ffxi.get_items(gear.equipment.neck_bag, gear.equipment.neck).id]
	local ear1 = res_items[windower.ffxi.get_items(gear.equipment.left_ear_bag, gear.equipment.left_ear).id]
	local ear2 = res_items[windower.ffxi.get_items(gear.equipment.right_ear_bag, gear.equipment.right_ear).id]
	local body = res_items[windower.ffxi.get_items(gear.equipment.body_bag, gear.equipment.body).id]
	local hands = res_items[windower.ffxi.get_items(gear.equipment.hands_bag, gear.equipment.hands).id]
	local ring1 = res_items[windower.ffxi.get_items(gear.equipment.left_ring_bag, gear.equipment.right_ring).id]
	local ring2 = res_items[windower.ffxi.get_items(gear.equipment.right_ring_bag, gear.equipment.left_ring).id]
	local back = res_items[windower.ffxi.get_items(gear.equipment.back_bag, gear.equipment.back).id]
	local waist = res_items[windower.ffxi.get_items(gear.equipment.waist_bag, gear.equipment.waist).id]
	local legs = res_items[windower.ffxi.get_items(gear.equipment.legs_bag, gear.equipment.legs).id]
	local feet = res_items[windower.ffxi.get_items(gear.equipment.feet_bag, gear.equipment.feet).id]
	
    if range.id == 18575 then mult = mult + 0.25 end -- Daurdabla LVL 90
	if range.id == 18571 or range.id == 18576 or range.id == 18839 then mult = mult + 0.3 end -- Daurdabla LVL 99 | LVL 95 | AG LVL 99
	if range.id == 18342 or range.id == 18577 or range.id == 18578 then mult = mult + 0.2 end -- Gjallarhorn LVL 75 | LVL 80 | LVL 85
	if range.id == 18579 or range.id == 18580 then mult = mult + 0.3 end -- Gjallarhorn LVL 90 | LVL 95
	if range.id == 18840 or range.id == 18572 then mult = mult + 0.4 end -- Gjallarhorn LVL 99 | AG LVL 99
	if range.id == 21398 then mult = mult + 0.5 end -- Marsyas
	
	-- Give your own math.  Songs + each give 10% per song+.   There are several song+ instruments; Some with Augments (Linos, Nibiru Harp).
	-- You'll need to add your own here.  I will make some assumptions anyone using a Linos has a +1 augment and anyone using a Nibiru Harp is augmented Path C.
	if range.en == "Nibiru Harp" then mult = mult + 0.2 end
	if range.en == "Linos" then mult = mult + 0.3 end 
	if range.en == "Blurred Harp" then mult = mult + 0.3 end
	if range.en == "Blurred Harp +1" then mult = mult + 0.4 end
	if range.en == "Mary's Horn" then mult = mult + 0.1 end
	if range.en == "Cradle Horn" then mult = mult + 0.2 end
	if range.en == "Pan's Horn" then mult = mult + 0.3 end
	
	
	if mainweapon.id == 18980 or mainweapon.id == 19000 then mult = mult + 0.1 end -- Carnwenhan LVL 75
    if mainweapon.id == 19069 then mult = mult + 0.2 end -- Carnwenhan LVL 80
	if mainweapon.id == 19089 then mult = mult + 0.3 end -- Carnwenhan LVL 85
	if mainweapon.id == 19621 or mainweapon.id == 19719 then mult = mult + 0.4 end -- Carnwenhan LVL 90 | LVL 95
	if mainweapon.id == 19828 or mainweapon.id == 19957 or mainweapon.id == 20561 or mainweapon.id == 20562 or mainweapon.id == 20586 then mult = mult + 0.5 end -- Carnwenhan LVL 99 - 119 AG
	
	if subweapon.id == 18980 or subweapon.id == 19000 then mult = mult + 0.1 end -- Carnwenhan LVL 75
    if subweapon.id == 19069 then mult = mult + 0.2 end -- Carnwenhan LVL 80
	if subweapon.id == 19089 then mult = mult + 0.3 end -- Carnwenhan LVL 85
	if subweapon.id == 19621 or subweapon.id == 19719 then mult = mult + 0.4 end -- Carnwenhan LVL 90 | LVL 95
	if subweapon.id == 19828 or subweapon.id == 19957 or subweapon.id == 20561 or subweapon.id == 20562 or subweapon.id == 20586 then mult = mult + 0.5 end -- Carnwenhan LVL 99 - 119 AG
	
    if mainweapon.en == "Legato Dagger" then mult = mult + 0.05 end
	if subweapon.en == "Legato Dagger" then mult = mult + 0.05 end
	if mainweapon.en == "Kali" then mult = mult + 0.05 end
	if subweapon.en == "Kali" then mult = mult + 0.05 end
	if neck.en == "Aoidos' Matinee" then mult = mult + 0.1 end
	if neck.en == "Moonbow Whistle" then mult = mult + 0.2 end 
	if neck.en == "Mnbw. Whistle +1" then mult = mult + 0.2 end 
    if body.en == "Fili Hongreline +1" then mult = mult + 0.12 end
	if body.en == "Aoidos' Hngrln. +2" then mult = mult + 0.1 end
	if body.en == "Aoidos' Hngrln. +1" then mult = mult + 0.05 end
	if legs.en == "Inyanga Shalwar" then mult = mult + 0.12 end
	if legs.en == "Inyanga Shalwar +1" then mult = mult + 0.15 end
	if legs.en == "Inyanga Shalwar +2" then mult = mult + 0.17 end
	if legs.en == "Mdk. Shalwar +1" then mult = mult + 0.1 end
	if feet.en == "Brioso Slippers" then mult = mult + 0.1 end
    if feet.en == "Brioso Slippers +1" then mult = mult + 0.11 end
	if feet.en == "Brioso Slippers +2" then mult = mult + 0.13 end
	if feet.en == "Brioso Slippers +3" then mult = mult + 0.15 end
	if hands.en == 'Brioso Cuffs +1' then mult = mult + 0.1 end
	if hands.en == 'Brioso Cuffs +2' then mult = mult + 0.1 end
	if hands.en == 'Brioso Cuffs +3' then mult = mult + 0.2 end
    
	
	if self.job_points.brd.jp_spent >= 1200 then
		mult = mult + 0.05
	end
		
    if troubadour then
        mult = mult*2
    end
	
	if lullaby_used == "Foe Lullaby II" or lullaby_used == "Horde Lullaby II" then 
		base = 60
	elseif lullaby_used == "Foe Lullaby" or lullaby_used == "Horde Lullaby" then 
		base = 30
	end
	totalDuration = math.floor(mult*base)		
	
	-- Job Points Buff
	totalDuration = totalDuration + self.job_points.brd.lullaby_duration
	if troubadour then 
		totalDuration = totalDuration + self.job_points.brd.lullaby_duration -- adding it a second time if Troubadour up
	end
	
	if clarioncall then
		if troubadour then 
			totalDuration = totalDuration + (self.job_points.brd.clarion_call_effect * 2 * 2) -- Clarion Call gives 2 seconds per Job Point upgrade.  * 2 again for Troubadour
		else
			totalDuration = totalDuration + (self.job_points.brd.clarion_call_effect * 2)  -- Clarion Call gives 2 seconds per Job Point upgrade. 
		end
	end
	
	if marcato and not soulvoice then
		totalDuration = totalDuration + self.job_points.brd.marcato_effect
	end

	--addon_message(totalDuration)

    return totalDuration
end

function get.new_sleep(target, duration)
	local mob = windower.ffxi.get_mob_by_id(target)
	get.monster_list[target] = {start=os.clock(),debuff_duration=duration,x=mob.x,y=mob.y,z=mob.z}
end

function get.count_monster_list()
	local num = 0
		for i,v in pairs(get.monster_list) do
			num = num +1
		end
	return num
end

function get.sleep_target()
	local t = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
	local mob_id,value
	if get.monster_list and get.count_monster_list() > 0 then 
		
		for mob_id,value in pairs(get.monster_list) do
			local mob = windower.ffxi.get_mob_by_id(mob_id)
			
			if mob then 
				if mob.x and value.x then 
					x_delta = mob.x - value.x
				else
					x_delta = 0
				end
				if mob.y and value.y then 
					y_delta = mob.y - value.y
				else
					y_delta = 0
				end
				
				
				if x_delta > 5 or x_delta < -5 or y_delta > 5 or y_delta < -5 then 
					get.monster_list[mob_id].debuff_duration = 0
				end
				
				local start_time = get.monster_list[mob_id].start
				local duration = get.monster_list[mob_id].debuff_duration
				local now = os.clock()	
				--local remaining_time = string.format("%.1f", duration - (now - start_time))
				
				if mob.status == 1 or mob.status == 0 then 
					if duration - (now - start_time) < 0 then -- mob is awake, sleep it
						get.monster_list[mob_id] = nil
						return mob_id 
					end
				end
			else -- couldn't get the mob by its id, remove it from the list
				get.monster_list[mob_id] = nil
			end
		end
	end
	
	return
end



return get

(_crewLoadoutData get "uniforms") append ["OPTRE_Ins_URF_Combat_Uniform"];
(_crewLoadoutData get "vests") append ["OPTRE_Ins_URF_Armor1"];
(_crewLoadoutData get "helmets") append ["OPTRE_Ins_URF_Helmet2"];

(_pilotLoadoutData get "uniforms") append ["OPTRE_Ins_URF_Combat_Uniform"];
(_pilotLoadoutData get "vests") append ["OPTRE_Ins_URF_Armor1"];
(_pilotLoadoutData get "helmets") append ["OPTRE_Ins_URF_Helmet2"];

(_policeLoadoutData get "uniforms") append [
	"OPTRE_CPD_Uniform",
	"OPTRE_CPD_Uniform_Rolled"
];
(_policeLoadoutData get "vests") append [
	"OPTRE_Vest_CPD_Heavy",
	"OPTRE_Vest_CPD_Light"
];
(_policeLoadoutData get "helmets") append [
	"OPTRE_CPD_CH251_Brown",
	"OPTRE_CPD_CH251_DME",
	"OPTRE_CPD_CH251_URF",
	"OPTRE_CPD_CH251_White",
	"OPTRE_CPD_CH251P",
	"OPTRE_CPD_Beret",
	"OPTRE_CPD_Cap"
];

_OPTREmuzzle = ["","OPTRE_M12_Suppressor","OPTRE_M393_Suppressor","OPTRE_M6_silencer","OPTRE_M6C_compensator","OPTRE_M7_silencer","OPTRE_MA37KSuppressor","OPTRE_SRS99D_Suppressor","OPTRE_MA5Suppressor",""];

_riotshieldbipods = ["","OPTRE_Riot_Shield_Icon_Fist","OPTRE_Riot_Shield_Icon_Innie"];

(_policeLoadoutData get "SMGs") append [
	["OPTRE_Bulldog_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],
	["OPTRE_Bulldog_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],
	["OPTRE_Bulldog_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],
	["OPTRE_Bulldog_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],

	["OPTRE_Comet_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],
	["OPTRE_Comet_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],
	["OPTRE_Comet_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],
	["OPTRE_Comet_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],

	["OPTRE_M6B_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6B_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6B_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6B_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],

	["OPTRE_M6C_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6C_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6C_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6C_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],

	["OPTRE_M6G_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6G_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6G_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6G_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],

	["OPTRE_M7_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],
	["OPTRE_M7_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],
	["OPTRE_M7_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],
	["OPTRE_M7_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],

	["OPTRE_SAS10_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], _riotshieldbipods],

	["OPTRE_M45TAC", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45A", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45ATAC", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45E", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],

	["OPTRE_M7", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], ""]
];
(_policeLoadoutData get "sidearms") append [
	["OPTRE_M319", "", "", "", ["M319_Buckshot","M319_Smoke"], [], ""],
	["OPTRE_M319s", "", "", "", ["OPTRE_3Rnd_Smoke_Grenade_shell", "OPTRE_signalSmokeG","OPTRE_1Rnd_Smoke_Grenade_shell"], [], ""],

	["OPTRE_M6B", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6C", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D_Black", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D_Desert", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D_Jungle", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6G", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6B", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],

	["OPTRE_M7_Folded", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], ""],

	["optre_hgun_comet_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], ""],
	["optre_hgun_comet_gold_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], ""],

	["optre_hgun_sas10_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""],
	["optre_hgun_sas10_desert_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""],
	["optre_hgun_sas10_jungle_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""],
	["optre_hgun_sas10_snow_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""]
];
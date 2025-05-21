//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append [
	"GreekHead_A3_02",
    "GreekHead_A3_03",
    "GreekHead_A3_04",
    "GreekHead_A3_05",
    "GreekHead_A3_06",
    "GreekHead_A3_07",
    "GreekHead_A3_08",
    "GreekHead_A3_09",
	"GreekHead_A3_10_l",
	"GreekHead_A3_10_sa",
	"GreekHead_A3_10_a",
    "GreekHead_A3_11",
    "GreekHead_A3_12",
    "GreekHead_A3_13",
    "GreekHead_A3_14",
    "Ioannou",
    "Mavros",
	"RussianHead_1",
	"RussianHead_2",
	"RussianHead_3",
	"RussianHead_4",
	"RussianHead_5"
]; 
_voices append [
"Male01GRE","Male02GRE","Male03GRE","Male04GRE",
"Male05GRE","Male06GRE","Male01ENGFRE","Male02ENGFRE",
"male01rus","male02rus","male03rus"
];

_lightArmedVehicles append ["US85_M1025_M2","US85_M1025_M60","US85_M1043_M2","US85_M1043_M60","US85_M998SFGT","FIA_AZU_DSKM_noinsignia","FIA_AZU_T21_noinsignia","AFMC_M1008_M2_noinsignia","AFMC_M1008_MK19_noinsignia",
"US85_M1025_Mk19","US85_M1025_TOW","US85_M1043_Mk19","US85_M1043_TOW","CSLA_FIA_V3S_AGS17","CSLA_FIA_V3S_GT_noinsignia"];
_lightUnarmedVehicles append ["US85_M1008c","US85_M1008","US85_M1025_ua","US85_M1043_ua","FIA_AZU_para_noinsignia","CSLA_AZU_R2_noinsignia","CSLA_AZU_noinsignia","US85_M998"];
_apc append ["AFMC_LAV25","AFMC_M113A1_noinsignia","AFMC_M113A2ext_noinsignia","AFMC_M113A1_Mk19_noinsignia","CSLA_BVP1_noinsignia","CSLA_MU90_noinsignia","CSLA_OT62_noinsignia",
"CSLA_OT64C_noinsignia","CSLA_OT65A_noinsignia","FIA_BTR40_noinsignia","FIA_BTR40_DSKM_noinsignia","US85_M113A1_TOW","CSLA_OT62D_noinsignia"];
_tanks append ["US85_M1A1","US85_M1IP","CSLA_T72_noinsignia","CSLA_T72M_noinsignia","CSLA_T72M1_noinsignia"];
_helis append ["US85_MH60M134","US85_UH60M240","CSLA_Mi17_noinsignia","CSLA_Mi17mg_noinsignia"];
_trucks append ["CSLA_FIA_V3S_des"];
_staticLowWeapons append ["AFMC_infFALf", "AFMC_M2l","CSLA_UK59L_Stat","CSLA_UK59T_Stat","AFMC_M60_Stat","US85_M60_PVS4_Stat","US85_M60E3_PVS4_Stat","US85_M60E3_Stat","CSLA_DShKM_h_Stat","CSLA_UK59L_Mount"];
_staticAT append ["AFMC_TOW_Stat", "CSLA_rT21","CSLA_9K113_Stat","AFMC_Mk19","CSLA_AGS17_Stat","CSLA_BzK59A_Stat"];

_staticMortars append ["US85_M252_Stat","CSLA_M52_Stat"];

_minesAT append ["US85_M87A1Mine","AFMC_ATMine","CSLA_PtMiBa3Mine"];
_minesAPERS append ["US85_M14Mine","CSLA_RG4oExp","CSLA_F1Exp","US85_M67Exp",
"CSLA_NO2Mine","CSLA_PPMiNaMine","CSLA_PPMiSr2Mine","CSLA_PTMiDMine","CSLA_URG86Exp"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_rifles append [
	["US85_FAL", "", "", "",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], ""],
	["US85_FALf", "", "", "",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], ""],
	["US85_M14", "", "", "",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], ""],
	["US85_M16A1", "", "", "",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
	["US85_M16A2", "", "", "",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
	["CSLA_Sa58P", "", "", "",  ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], ""],
	["CSLA_Sa58V", "", "", "",  ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], "CSLA_Sa58bpd"],
    ["CSLA_Pu57", "", "", "", ["CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43"], [], ""],
    ["CSLA_Pu52", "", "", "", ["CSLA_Pu52_10rnd_7_62vz52","CSLA_Pu52_10rnd_7_62vz52","CSLA_Pu52_10rnd_7_62Sv52","CSLA_Pu52_10rnd_7_62Sv52"], [], ""]
];
_tunedRifles append [
	["US85_FAL", "", "", "US85_scFAL",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_FALbpd"],
    ["US85_FALf", "", "", "US85_scFAL",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_FALbpd"],
	["US85_M16A2CAR", "US85_M16tlm","US85_M16fl","US85_sc4x20_M16",["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
    ["US85_M16A1", "US85_M16tlm", "", "US85_sc4x20_M16",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
	["US85_M16A2", "US85_M16tlm", "", "US85_sc4x20_M16",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
	["CSLA_Sa58P", "","","CSLA_ZD4x8",["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], "CSLA_Sa58bpd"],
    ["CSLA_Pu57", "", "", "CSLA_ZD4x8_Pu52", ["CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43"], [], ""],
    ["CSLA_Pu52", "", "", "CSLA_ZD4x8_Pu52", ["CSLA_Pu52_10rnd_7_62vz52","CSLA_Pu52_10rnd_7_62vz52","CSLA_Pu52_10rnd_7_62Sv52","CSLA_Pu52_10rnd_7_62Sv52"], [], ""]
];
_enforcerRifles append [
	["US85_FAL", "", "", "US85_scFAL",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_FALbpd"],
    ["US85_FALf", "", "", "US85_scFAL",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_FALbpd"],
	["US85_M16A2CAR", "","US85_M16fl","US85_sc4x20_M16",["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
    ["US85_M16A1", "", "", "US85_sc4x20_M16",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
	["US85_M16A2", "", "", "US85_sc4x20_M16",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
	["CSLA_Sa58P", "","","CSLA_ZD4x8",["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], "CSLA_Sa58bpd"],
	["CSLA_Sa58V", "", "", "",  ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], "CSLA_Sa58bpd"]
];
_carbines append [
	["US85_M16A2CAR", "", "", "",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
    ["US85_MPVN", "", "", "", ["US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger"], [], ""],
	["US85_MPVSD", "", "", "", ["US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger"], [], ""],
    ["US85_MPVN1", "", "", "", ["US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger"], [], ""],
    ["US85_MPVN1", "US85_MPVtlm", "", "", ["US85_MPV_30Rnd_9Luger", "US85_MPV_30Rnd_9Luger", "US85_MPV_30Rnd_9Luger", "US85_MPV_30Rnd_9Luger"], [], ""],
    ["CSLA_rSa61", "", "", "", ["CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_10rnd_7_65Pi27"], [], ""],
	["CSLA_Sa24", "", "", "",  ["CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52"], [], ""],
	["CSLA_Sa26", "", "", "",  ["CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52"], [], ""]
];
_gls append [
	["US85_M16A2CARGL", "", "", "US85_sc2000_M16", ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], ["US85_M406","US85_M406","US85_M406"], ""],
	["US85_M16A2GL", "", "", "US85_sc2000_M16", ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], ["US85_M406","US85_M406","US85_M406"], ""],
	["CSLA_VG70", "", "", "", ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], ["CSLA_26_5vz70","CSLA_26_5vz70","CSLA_26_5vz70","CSLA_26_5sigZl1a"], "CSLA_Sa58bnt"]
];
_mgs append [
	["US85_M60","","","",["US85_100Rnd_762x51","US85_100Rnd_762x51","US85_100Rnd_762x51"],[],""],
    ["US85_M60E3LB","","","",["US85_100Rnd_762x51","US85_100Rnd_762x51","US85_100Rnd_762x51"],[],""],
    ["US85_M60E3SB","","","",["US85_100Rnd_762x51","US85_100Rnd_762x51","US85_100Rnd_762x51"],[],""],
    ["US85_M60E3LB","","","US85_ANPVS4_M60",["US85_100Rnd_762x51","US85_100Rnd_762x51","US85_100Rnd_762x51"],[],""],
    ["US85_M60E3SB","","","US85_ANPVS4_M60",["US85_100Rnd_762x51","US85_100Rnd_762x51","US85_100Rnd_762x51"],[],""],
    ["US85_M249","","","US85_sc4x20M249",["US85_200Rnd_556x45","US85_200Rnd_556x45","US85_200Rnd_556x45"],[],""],
    ["CSLA_UK59L","","","CSLA_UK59_ZD4x8",["CSLA_UK59_50rnd_7_62vz59","CSLA_UK59_50rnd_7_62PZ59","CSLA_UK59_50rnd_7_62Tz59","CSLA_UK59_50rnd_7_62TzSv59","CSLA_UK59_50rnd_7_62Sv59"],[],""],
    ["CSLA_LK57_50", "", "", "", ["CSLA_LK57_50rnd_7_62vz43", "CSLA_LK57_50rnd_7_62PZ43","CSLA_LK57_50rnd_7_62Sv43"], [], ""],
    ["CSLA_LK52_25", "", "", "", ["CSLA_LK52_25rnd_7_62vz52", "CSLA_LK52_25rnd_7_62PZ52","CSLA_LK52_25rnd_7_62Sv52"], [], ""]
];
_marksmanRifles append [
	["CSLA_HuntingRifle","","","",["CSLA_10Rnd_762hunt","CSLA_10Rnd_762hunt", "CSLA_10Rnd_762hunt","CSLA_10Rnd_762hunt"], [], "gm_msg90_bipod_blk"],
    ["US85_M14","","","US85_scM21",["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_M14bpd"],
	["US85_M21","","","US85_scM21",["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_M14bpd"],
	["CSLA_OP63","","","CSLA_PSO1_OP63",["CSLA_OP63_10rnd_7_62Odst59","CSLA_OP63_10rnd_7_62PZ59","CSLA_OP63_10rnd_7_62Odst59","CSLA_OP63_10rnd_7_62PZ59"], [], ""],
    ["CSLA_Pu57", "", "", "CSLA_ZD4x8_Pu52", ["CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43","CSLA_Pu57_10rnd_7_62vz43"], [], ""],
    ["CSLA_Pu52", "", "", "CSLA_ZD4x8_Pu52", ["CSLA_Pu52_10rnd_7_62vz52","CSLA_Pu52_10rnd_7_62vz52","CSLA_Pu52_10rnd_7_62Sv52","CSLA_Pu52_10rnd_7_62Sv52"], [], ""],
    ["CSLA_OP54", "", "", "CSLA_PD54", ["CSLA_OP54_5rnd_7_62PZ59","CSLA_OP54_5rnd_7_62TzOdst59","CSLA_OP54_5rnd_7_62Odst59", "CSLA_OP54_5rnd_7_62Odst59"], [], ""]
];

_rpgs append [
	["US85_M136", "", "", "", ["US85_M136_Mag"], [], ""],
    ["US85_M47", "", "", "", ["US85_M47_Mag"], [], ""],
    ["CSLA_RPG7", "", "", "CSLA_PGO7", ["CSLA_PG7M110V", "CSLA_PG7M110V"], [], ""],
	["CSLA_RPG75", "", "", "", ["CSLA_RPG75_Mag", "CSLA_RPG75_Mag"], [], ""],
	["CSLA_RPG7", "", "", "CSLA_PGO7", ["CSLA_PG7M110V", "CSLA_PG7M110V"], [], ""]
];

_rpgsHE append [
	["US85_LAW72", "", "", "", ["US85_LAW72_Mag", "US85_LAW72_Mag"], [], ""],
    ["US85_MAAWS", "", "", "", ["US85_MAAWS_HEDP","US85_MAAWS_HEDP","US85_MAAWS_HEAT"], [], ""],
	["US85_SMAW", "", "", "", ["US85_SMAW_HEAA","US85_SMAW_HEAA","US85_SMAW_HEDP"], [], ""]
];

_AAlaunchers append [
	["CSLA_9K32", "", "", "", ["CSLA_9M32M","CSLA_9M32M"], [], ""],
	["US85_FIM92", "", "", "", ["US85_FIM92_Mag","US85_FIM92_Mag"], [], ""]
];

_pistols append [
	["US85_1911", "", "", "", ["US85_1911_7Rnd_045ACP","US85_1911_7Rnd_045ACP","US85_1911_7Rnd_045ACP"], [], ""],
    ["US85_M9", "", "", "", ["US85_M9_15Rnd_9Luger","US85_M9_15Rnd_9Luger","US85_M9_15Rnd_9Luger"], [], ""],
    ["CSLA_Pi52", "", "", "", ["CSLA_Pi52_8rnd_7_62Pi52","CSLA_Pi52_8rnd_7_62Pi52","CSLA_Pi52_8rnd_7_62Pi52"], [], ""],
    ["CSLA_Pi75lr", "", "", "", ["CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger"], [], ""],
    ["CSLA_Pi75sr", "", "", "", ["CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger"], [], ""],
    ["CSLA_Pi82", "", "", "", ["CSLA_Pi82_12rnd_9Pi82","CSLA_Pi82_12rnd_9Pi82","CSLA_Pi82_12rnd_9Pi82"], [], ""],
    ["CSLA_Sa61", "", "", "", ["CSLA_Sa61_10rnd_7_65Pi27","CSLA_Sa61_10rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27"], [], ""],
    ["US85_Mk23", "US85_Mk23tlm", "US85_Mk23fl", "", ["US85_Mk23_12Rnd_045ACP","US85_Mk23_12Rnd_045ACP"], [], ""],
    ["US85_Mk23", "", "", "", ["US85_Mk23_12Rnd_045ACP","US85_Mk23_12Rnd_045ACP"], [], ""],
    ["US85_Mk23", "", "US85_Mk23fl", "", ["US85_Mk23_12Rnd_045ACP","US85_Mk23_12Rnd_045ACP"], [], ""],
    ["US85_Mk23", "US85_Mk23tlm", "", "", ["US85_Mk23_12Rnd_045ACP","US85_Mk23_12Rnd_045ACP"], [], ""]
];

_ATMines append ["CSLA_PtMiBa3_mag"];
_APMines append ["CSLA_F1m_mag","US85_M67m_mag","CSLA_NO2","CSLA_RG4m_mag","CSLA_URG86m_mag","CSLA_PPMiNa_mag"];
_lightExplosives append ["CSLA_TNT0100g"];
_heavyExplosives append ["IEDLandBig_Remote_Mag"];

_antiInfantryGrenades append ["CSLA_F1","CSLA_RG4o","CSLA_RG4u","CSLA_URG86u","CSLA_URG86o"];
_smokeGrenades append ["CSLA_dymB","US85_dymB"];
_signalsmokeGrenades append ["US85_dymZl","CSLA_dymZl","CSLA_dymC","US85_dymC","US85_dymZ","CSLA_dymZ"];

_maps append ["ItemMap"];
_watches append ["CSLA_Prim_enl"];
_compasses append ["ItemCompass"];
_radios append ["ItemRadio"];
_NVGs append ["CSLA_nokto"];
_binoculars append ["CSLA_bino"];
_Rangefinder append ["CSLA_bino"];

///
_facewear append ["CSLA_glsPlscSpring"];

_headgear append [
	"US85_beanie",
    "CSLA_beretM",
    "CSLA_beretR",
    "AFMC_booniehatLizard",
	"US85_hat",
	"FIA_hat85Gn",
	"FIA_hat85bGn",
	"FIA_hat85Mlok",
	"FIA_hat85bMlok",
	"FIA_capBk",
	"FIA_capGn",
	"FIA_capMlok",
	"CSLA_BudajkaBk",
	"CSLA_BudajkaGy",
	"FIA_Budajka"
];

/////Vests
_vests append [
"CSLA_gr60brr", 
"CSLA_gr60base", 
"CSLA_gr60drv", 
"CSLA_gr60crw", 
"CSLA_gr60svc", 
"CSLA_gr60medic" ,
"CSLA_gr60ofc1",
"CSLA_gr60OP63",
"CSLA_gr60rfl",
"CSLA_gr60RPG7",
"CSLA_gr60RPG7r",
"CSLA_gr60sgt",
"CSLA_gr85ptMdc",
"CSLA_gr85ptOP63",
"CSLA_gr85ptBase",
"CSLA_gr85lrrOP63",
"CSLA_gr85lrrBase",
"CSLA_gr85ptSgt",
"CSLA_gr85Uah61",
"AFMC_grY_FAL",
"US85_grY_M16",
"US85_grY_M24",
"US85_grY_M9",
"AFMC_grY_MG",
"FIA_grY_MG",
"US85_grY_MG",
"FIA_grY_MPV",
"US85_grY_MPV",
"US85_grY_snp"
];

_heavyVests append [
"AFMC_grVest", 
"AFMC_grV_M16", 
"AFMC_grV_M24",
"AFMC_grV_MG",
"AFMC_grV_ofc",
"US85_grVest",
"US85_grV_M16GL",
"US85_grVm_M16GL",
"US85_grV_M16",
"US85_grV_M24",
"US85_grV_M9",
"US85_grV_MG",
"US85_grV_MPV",
"US85_grV_ofc",
"US85_grSF_M16GL",
"US85_grSF_M9",
"US85_grSF_MG",
"US85_grSF_TLBV",
"US85_grSF_M16",
"US85_grSF_M24"
];

_crewVests append [
"CSLA_gr60brr", 
"CSLA_gr60base", 
"CSLA_gr60drv", 
"CSLA_gr60crw", 
"CSLA_gr60svc", 
"CSLA_gr60medic" ,
"CSLA_gr60ofc1",
"CSLA_gr60OP63",
"CSLA_gr60rfl",
"CSLA_gr60RPG7",
"CSLA_gr60RPG7r",
"CSLA_gr60sgt",
"CSLA_gr85ptMdc",
"CSLA_gr85ptOP63",
"CSLA_gr85ptBase",
"CSLA_gr85lrrOP63",
"CSLA_gr85lrrBase",
"CSLA_gr85ptSgt",
"CSLA_gr85Uah61",
"AFMC_grY_FAL",
"US85_grY_M16",
"US85_grY_M24",
"US85_grY_M9",
"AFMC_grY_MG",
"FIA_grY_MG",
"US85_grY_MG",
"FIA_grY_MPV",
"US85_grY_MPV",
"US85_grY_snp"
];

_pilotVests append [
"CSLA_gr60brr", 
"CSLA_gr60base", 
"CSLA_gr60drv", 
"CSLA_gr60crw", 
"CSLA_gr60svc", 
"CSLA_gr60medic" ,
"CSLA_gr60ofc1",
"CSLA_gr60OP63",
"CSLA_gr60rfl",
"CSLA_gr60RPG7",
"CSLA_gr60RPG7r",
"CSLA_gr60sgt",
"CSLA_gr85ptMdc",
"CSLA_gr85ptOP63",
"CSLA_gr85ptBase",
"CSLA_gr85lrrOP63",
"CSLA_gr85lrrBase",
"CSLA_gr85ptSgt",
"CSLA_gr85Uah61",
"AFMC_grY_FAL",
"US85_grY_M16",
"US85_grY_M24",
"US85_grY_M9",
"AFMC_grY_MG",
"FIA_grY_MG",
"US85_grY_MG",
"FIA_grY_MPV",
"US85_grY_MPV",
"US85_grY_snp"
];

/////Uniforms
_uniforms append [
	"FIA_uniwld11",
    "FIA_uniwld",
    "FIA_uniwld1",
    "FIA_uniwld10",
	"FIA_uniwld3",
	"FIA_uniwld4",
	"FIA_uniwld6",
	"FIA_uniwld7",
	"FIA_uniwld9"
];

_pilotUniforms append ["U_Marshal","U_C_WorkerCoveralls","U_Rangemaster"];

/////Helmets
_helmets append [
	"US85_helmetM1g",
    "AFMC_helmetM1c",
    "US85_helmetM1c",
    "AFMC_helmetMk6",
    "AFMC_helmetMk6para",
    "AFMC_helmetMk6r",
    "US85_helmetPASGT",
	"US85_helmetPASGTr",
	"US85_helmetPASGTG",
	"US85_helmetSFL",
	"US85_helmetSFLG",
	"US85_helmetSFLG_on",
	"CSLA_helmet53",
	"CSLA_helmet53j",
	"CSLA_helmet53m",
	"CSLA_helmet53G",
	"CSLA_helmet53G_on"
]; ///look for more helmets

_crewhelmets append ["US85_helmetDH132", "US85_helmetDH132G", "US85_helmetDH132G_on"];

_pilothelmets append ["H_PilotHelmetHeli_O", "H_CrewHelmetHeli_O", "H_PilotHelmetHeli_B", "H_CrewHelmetHeli_B"];

/////
_offuniforms append ["U_I_C_Soldier_Camo_F"];

_backpacks append ["US85_bpSf","FIA_bpPack", "US85_bpAlice"];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_slItems append ["Laserbatteries", "Laserbatteries", "Laserbatteries"];
_eeItems append ["CSLA_toolkit", "CSLA_w3p_detector","US85_anprs8_detector","US85_toolkit_B","CSLA_toolkit_KOMZE","US85_toolkit_S"];

_baseClassCellLeaderArray append ["FIA_cdCmd","FIA_cldsCmd","FIA_mcCmd","CSLA_MCh2a","CSLA_FCh1","CSLA_MCh1a","FIA_mcCmdDES"]; /// squad leader
_baseClassMercenaryArray append ["FIA_cldsPu52","FIA_cldsPu57","FIA_mcVG70","FIA_mcPu52","FIA_mcSa58","FIA_mcVG70DES","FIA_mcPu52DES","FIA_mcPu57DES",
"FIA_mcSa58DES"]; /// can be GL or rifleman
_baseClassEnforcerArray append ["FIA_cdFAL","FIA_mcFAL"]; /// heavy rifleman (?)
_baseClassPartisanArray append ["FIA_cdP27","FIA_cdSa26RPG75","FIA_cldsP27","FIA_cldsRPG75","FIA_mcP27","FIA_mcP27DES","FIA_mcRPG75DES"]; /// light AT
_baseClassMinutemanArray append ["FIA_cldsSa24","FIA_mcSa24","FIA_mcSa24DES"]; /// light rifleman (with carbines?)
_baseClassMedicArray append ["FIA_cdMdc","FIA_cldsMdc","FIA_mcMdc","FIA_mcMdcDES"];
_baseClassSaboteurArray append ["FIA_cldsSvc","FIA_mcSvc","FIA_mcM16","FIA_mcSa58v","FIA_mcSvcDES","FIA_mcSa58vDES"]; /// lightAT with gl rifle ?
_baseClassExplosivesExpertArray append ["FIA_cdSpr","FIA_cldsSpr","FIA_mcLA","FIA_mcSa61","FIA_mcSprDES"];
_baseClassATArray append ["FIA_cdRPG7","FIA_cldsRPG7","FIA_mcRPG7","FIA_mcRPG7DES"];
_baseClassAAArray append ["FIA_clds9K32","FIA_mc9K32","FIA_mc9K32DES"];
_baseClassOppressorArray append ["FIA_cdLK52","FIA_cdLK57","FIA_cdUK59L","FIA_cldsLK52","FIA_cldsLK57","FIA_cldsUK59L","FIA_mcLK52","FIA_mcLK57","FIA_mcUK59L",
"FIA_mcLK52DES","FIA_mcLK57DES","FIA_mcUK59LDES"]; /// thats a machinegun(ner)
_baseClassSharpshooterArray append ["FIA_cdOP54","FIA_cdOP63","FIA_cldsOP54","FIA_cldsOP63","FIA_mcPu57","FIA_mcSnp","FIA_mcOP54","FIA_mcOP54DES","FIA_mcOP63DES"]; ///marksmen/sniper

// ================== Специальные роли ==================

_baseClassCrewArray append ["FIA_cldsCrw","FIA_cldsDrM","FIA_cldsCrwCmd","FIA_cldsCrwDrM","FIA_mrDrM","FIA_mrDrM_Sa26","FIA_crwDES","FIA_mcDrMDES","FIA_CrwCmdDES",
"FIA_crwDrMDES"];
_baseClassPilotArray append ["FIA_cldsCrw","FIA_cldsDrM","FIA_cldsCrwCmd","FIA_cldsCrwDrM","FIA_mrDrM","FIA_mrDrM_Sa26"];
_baseClassCommanderArray append ["FIA_uaEnl8"]; /// vip
_baseClassUnarmedArray append ["CSLA_MCh2u","CSLA_ECh1f","CSLA_MCh1u","FIA_uaDrM"];
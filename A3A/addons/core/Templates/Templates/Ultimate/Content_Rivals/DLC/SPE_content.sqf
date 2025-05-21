if (isClass (configFile >> "cfgVehicles" >> "SPEX_M2_60")) then {
	_staticMortars pushBack "SPEX_M2_60";
};
//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append [
"SPE_Davidson",
"SPE_bykov",
"SPE_boyartsev",
"SPE_Jeppson",
"SPE_Hauptmann",
"SPE_DAgostino",
"SPE_Ivanych",
"SPE_Arnold",
"SPE_Oberst",
"SPE_Krueger",
"SPE_Neumann",
"SPE_Walter",
"SPE_Connors",
"SPE_Kuzmin",
"SPE_Seppmeyer",
"SPE_OBrien",
"SPE_Grishka",
"SPE_Klimakov",
"SPE_Elliot",
"SPE_Vasiliev",
"SPE_Wolf"
]; 
_voices append [
	"SPE_Male02FRE","SPE_Male01FRE","SPE_Male02GER","SPE_Male01GER"
];

_lightArmedVehicles append ["SPE_Milice_R200_MG34_noinsignia","SPE_US_G503_MB_M1919_Armoured_noinsignia","SPE_US_G503_MB_M1919_noinsignia","SPE_US_G503_MB_M2_Armoured_noinsignia","SPE_US_G503_MB_M2_noinsignia","SPE_US_G503_MB_M2_PATROL_noinsignia","SPE_US_G503_MB_M1919_PATROL_noinsignia"];
_lightUnarmedVehicles append ["SPE_Milice_R200_Hood_noinsignia","SPE_Milice_R200_Unarmed_noinsignia","SPE_US_G503_MB_noinsignia","SPE_US_G503_MB_Armoured_noinsignia","SPE_US_G503_MB_Open_noinsignia"];
_apc append ["SPE_FR_M3_Halftrack_Unarmed_Open_noinsignia","SPE_FR_M3_Halftrack_Unarmed_noinsignia","SPE_CCKW_353_noinsignia","SPE_CCKW_353_M2_noinsignia","SPE_CCKW_353_Open_noinsignia"];
_tanks append ["SPE_PzKpfwIV_G_noinsignia","SPE_FR_M10_noinsignia","SPE_FR_M4A0_75_Early_noinsignia","SPE_FR_M4A0_75_mid_noinsignia","SPE_FR_M4A1_76_noinsignia","SPE_FR_M4A1_75_noinsignia","SPE_M18_Hellcat_noinsignia","SPE_M4A1_T34_Calliope_Direct_noinsignia",
"SPE_FR_M4A0_105_noinsignia","SPE_FR_M4A3_75_noinsignia","SPE_FR_M4A3_76_noinsignia","SPE_M4A0_composite_noinsignia","SPE_M4A1_75_erla_noinsignia","SPE_M4A3_T34_Calliope_Direct_noinsignia","SPE_ST_Jagdpanther_G1_noinsignia","SPE_ST_StuG_III_G_SKB_noinsignia","SPE_ST_PzKpfwV_G"];
_trucks append ["SPE_ST_OpelBlitz_Open"];
_staticLowWeapons append ["SPE_ST_MG34_Lafette_Deployed","SPE_ST_MG42_Lafette_Deployed","SPE_GER_SearchLight","SPE_FR_M1919A6_Bipod","SPE_FR_M1919_M2_Trench_Deployed"];
_staticAT append ["SPE_ST_FlaK_36","SPE_ST_Pak40","SPE_ST_leFH18_AT","SPE_FR_57mm_M1","SPE_105mm_M3_Direct"];

_staticMortars append ["SPE_M1_81","SPE_GrW278_1"];

_minesAT append ["SPE_TMI_42_MINE"];
_minesAPERS append ["SPE_SMI_35_MINE"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_rifles append [
	["SPE_STG44","","","",["SPE_30Rnd_792x33","SPE_30Rnd_792x33","SPE_30rnd_792x33_t"],[],""],
    ["SPE_M1918A2_BAR","","","",["SPE_20Rnd_762x63","SPE_20Rnd_762x63_M1","SPE_20Rnd_762x63_M2_AP"],[],""]
];
_tunedRifles append [
	["SPE_K98", "", "", "", ["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t"], [], ""],
    ["SPE_K98_Late", "", "", "", ["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t"], [], ""]
];
_enforcerRifles append [
	["SPE_K98", "", "", "", ["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t"], [], ""],
    ["SPE_K98_Late", "", "", "", ["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t"], [], ""]
];
_carbines append [
	["SPE_M1_Carbine","SPE_ACC_GL_M8","","",["SPE_15Rnd_762x33","SPE_15Rnd_762x33","SPE_15Rnd_762x33_t","SPE_15Rnd_762x33_t"], [], ""],
    ["SPE_M1_Carbine","","","",["SPE_15Rnd_762x33","SPE_15Rnd_762x33","SPE_15Rnd_762x33_t","SPE_15Rnd_762x33_t"], [], ""],
    ["SPE_Fusil_Mle_208_12_Sawedoff","","","",["SPE_2Rnd_12x65_No4_Buck","SPE_2Rnd_12x65_Pellets","SPE_2Rnd_12x65_Slug","SPE_2Rnd_12x65_No4_Buck"], [], ""],
    ["SPE_Fusil_Mle_208_12","","","",["SPE_2Rnd_12x65_No4_Buck","SPE_2Rnd_12x65_Pellets","SPE_2Rnd_12x65_Slug","SPE_2Rnd_12x65_No4_Buck"], [], ""]
];
_gls append [
	["SPE_K98", "SPE_ACC_GW_SB_Empty", "", "", ["SPE_5Rnd_792x57"], ["SPE_1Rnd_G_SPRGR_30","SPE_1Rnd_G_PZGR_30","SPE_1Rnd_G_PZGR_40"], ""],
    ["SPE_K98_Late", "SPE_ACC_GW_SB_Empty", "", "", ["SPE_5Rnd_792x57"], ["SPE_1Rnd_G_SPRGR_30","SPE_1Rnd_G_PZGR_30","SPE_1Rnd_G_PZGR_40"], ""]
];
_mgs append [
	["SPE_MG42","","","",["SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_sS","SPE_50Rnd_792x57"],[],""],
    ["SPE_MG34","","","",["SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_sS","SPE_50Rnd_792x57"],[],""],
    ["SPE_M1919A6","","","",["SPE_100Rnd_762x63","SPE_100Rnd_762x63_M1","SPE_100Rnd_762x63_M2_AP","SPE_50Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1919A4","","","",["SPE_100Rnd_762x63","SPE_100Rnd_762x63_M1","SPE_100Rnd_762x63_M2_AP","SPE_50Rnd_762x63_M2_AP"],[],""],
    ["SPE_FM_24_M29","","","",["SPE_25Rnd_75x54","SPE_25Rnd_75x54","SPE_25Rnd_75x54_35P_AP","SPE_25Rnd_75x54_35P_AP","SPE_25Rnd_75x54","SPE_25Rnd_75x54","SPE_25Rnd_75x54_35P_AP","SPE_25Rnd_75x54_35P_AP"],[],""]
];
_marksmanRifles append [
	["SPE_M1903A3_Springfield","SPE_ACC_M1_Bayo","","",["SPE_5Rnd_762x63","SPE_5Rnd_762x63_M1","SPE_5Rnd_762x63_t","SPE_5Rnd_762x63_M2_AP","SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1903A3_Springfield","SPE_ACC_GL_M1","","",["SPE_5Rnd_762x63","SPE_5Rnd_762x63_M1","SPE_5Rnd_762x63_t","SPE_5Rnd_762x63_M2_AP","SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1903A3_Springfield","SPE_ACC_M1905_Bayo","","",["SPE_5Rnd_762x63","SPE_5Rnd_762x63_M1","SPE_5Rnd_762x63_t","SPE_5Rnd_762x63_M2_AP","SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1903A3_Springfield","","","",["SPE_5Rnd_762x63","SPE_5Rnd_762x63_M1","SPE_5Rnd_762x63_t","SPE_5Rnd_762x63_M2_AP","SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1_Garand","SPE_ACC_M1_Bayo","","",["SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1_Garand","SPE_ACC_M1905_Bayo","","",["SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1_Garand","SPE_ACC_GL_M7","","",["SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_M1_Garand","","","",["SPE_8Rnd_762x63","SPE_8Rnd_762x63_M1","SPE_8Rnd_762x63_t","SPE_8Rnd_762x63_M2_AP"],[],""],
    ["SPE_K98_Late","SPE_ACC_K98_Bayo","","",["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t","SPE_5Rnd_792x57_SMK","SPE_5Rnd_792x57_sS"],[],""],
    ["SPE_K98","SPE_ACC_K98_Bayo","","",["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t","SPE_5Rnd_792x57_SMK","SPE_5Rnd_792x57_sS"],[],""],
    ["SPE_G43","SPE_ACC_K98_Bayo","","",["SPE_10Rnd_792x57","SPE_10Rnd_792x57_T2","SPE_10Rnd_792x57_SMK","SPE_10Rnd_792x57_sS","SPE_10Rnd_792x57_T"],[],""],
	["SPE_M1903A4_Springfield","","","",["SPE_5Rnd_762x63","SPE_5Rnd_762x63_M1","SPE_5Rnd_762x63_t","SPE_5Rnd_762x63_M2_AP"],[],""],
    ["SPE_K98ZF39","","","",["SPE_5Rnd_792x57","SPE_5Rnd_792x57_t","SPE_5Rnd_792x57_SMK","SPE_5Rnd_792x57_sS"],[],""]
];

_rpgs append [
	["SPE_M1A1_Bazooka", "", "", "", ["SPE_1Rnd_60mm_M6","SPE_1Rnd_60mm_M6","SPE_1Rnd_60mm_M6"], [], ""]
];

_rpgsHE append [
	"SPE_PzFaust_60m", "SPE_PzFaust_30m"
];

_AAlaunchers append ["SPE_Faustpatrone"];

_pistols append [
	["SPE_M1911","","","",["SPE_7Rnd_45ACP_1911","SPE_7Rnd_45ACP_1911","SPE_7Rnd_45ACP_1911","SPE_7Rnd_45ACP_1911"], [], ""],
    ["SPE_P08","","","",["SPE_8Rnd_9x19_P08","SPE_8Rnd_9x19_P08","SPE_8Rnd_9x19_P08","SPE_8Rnd_9x19_P08"], [], ""]
];

_ATMines append ["SPE_TMI_42_MINE_mag"];
_APMines append ["SPE_SMI_35_Pressure_MINE_mag"];
_lightExplosives append ["SPE_Ladung_Small_MINE_mag"];
_heavyExplosives append ["SPE_Ladung_Big_MINE_mag"];

_antiInfantryGrenades append ["SPE_Shg24", "SPE_M39","SPE_Shg24x7","SPE_US_Mk_2","SPE_US_AN_M14"];
_smokeGrenades append ["SPE_NB39"];
_signalsmokeGrenades append ["SmokeShellYellow", "SmokeShellRed", "SmokeShellPurple", "SmokeShellOrange", "SmokeShellGreen", "SmokeShellBlue"];

_maps append ["ItemMap"];
_watches append ["SPE_GER_ItemWatch"];
_compasses append ["SPE_GER_ItemCompass_deg", "SPE_GER_ItemCompass"];
_radios append ["TFAR_SCR536"];
_binoculars append ["SPE_Binocular_GER"];
_Rangefinder append ["SPE_Binocular_GER"];

///
_facewear append [
	"G_SPE_GER_Headset",
	"G_SPE_Sunglasses_US_Yellow",
	"G_SPE_Sunglasses_US_Red",
	"G_SPE_Pipe_Sir_Winston",
	"G_SPE_Sunglasses_GER_Red",
	"G_SPE_Sunglasses_GER_Brown",
	"G_SPE_Polar_Goggles",
	"G_SPE_SWDG_Goggles",
	"G_SPE_Dust_Goggles",
	"G_SPE_Ful_Vue",
	"G_SPE_Ful_Vue_Reinforced",
	"G_SPE_Dust_Goggles_2",
	"G_SPE_Dienst_Brille",
	"G_SPE_Cigarette_Strike_Outs",
	"G_SPE_Cigarette_Grundstein",
	"G_SPE_Cigarette_Belomorkanal",
	"G_SPE_Cigar_Moza",
	"G_SPE_Binoculars"
];

_fullmask append [];

_headgear append [
	"H_SPE_CIV_Worker_Cap_1",
    "H_SPE_CIV_Worker_Cap_2",
    "H_SPE_CIV_Worker_Cap_3"
];

/////Vests
_vests append [
"V_SPE_US_Vest_Thompson_M43", 
"V_SPE_US_Vest_Thompson", 
"V_SPE_US_Vest_Carbine_pick", 
"V_SPE_US_Vest_Carbine_m43", 
"V_SPE_US_Vest_M1919", 
"V_SPE_US_Vest_Carbine_eng",
"V_SPE_US_Vest_Carbine_mk2",
"V_SPE_US_Vest_Carbine",
"V_SPE_US_Vest_Asst_MG",
"V_SPE_US_Vest_Thompson_nco_Radio",
"V_SPE_US_Vest_Thompson_nco",
"V_SPE_US_Vest_45_off",
"V_SPE_US_Vest_Carbine_nco_Radio",
"V_SPE_US_Vest_Carbine_nco",
"V_SPE_US_Vest_Medic2",
"V_SPE_US_Vest_Medic",
"V_SPE_US_Vest_Medic3",
"V_SPE_US_Vest_Grenadier",
"V_SPE_US_Vest_Garand_45",
"V_SPE_US_Vest_Garand_mk2",
"V_SPE_US_Vest_Garand_map",
"V_SPE_US_Vest_Garand_M43",
"V_SPE_US_Vest_Garand_eng",
"V_SPE_US_Vest_Garand_gp",
"V_SPE_US_Vest_Garand",
"V_SPE_US_Vest_Bar",
"V_SPE_US_Vest_Bar_assist",
"V_SPE_US_Assault_Vest_rifle_M43",
"V_SPE_US_Assault_Vest_rifle",
"V_SPE_US_Assault_Vest_alt",
"V_SPE_US_Assault_Vest_eng",
"V_SPE_US_Assault_Vest_Light",
"V_SPE_US_Assault_Vest_dday_rifle",
"V_SPE_US_Assault_Vest_dday_rifle_M43",
"V_SPE_US_Assault_Vest_dday_eng",
"V_SPE_US_Assault_Vest_dday_Bag",
"V_SPE_US_Assault_Vest_dday",
"V_SPE_US_Assault_Vest_Bag",
"V_SPE_US_Assault_Vest",
"V_SPE_GER_VestUnterofficer",
"V_SPE_GER_VestSTG",
"V_SPE_GER_VestMP40",
"V_SPE_GER_FWOVest",
"V_SPE_GER_SaniVest",
"V_SPE_GER_VestKar98",
"V_SPE_GER_PioneerVest",
"V_SPE_GER_FieldOfficer",
"V_SPE_GER_VestMG",
"V_SPE_GER_SaniVest2",
"V_SPE_GER_VestG43",
"V_SPE_DAK_PioneerVest",
"V_SPE_DAK_SaniVest2",
"V_SPE_DAK_VestUnterofficer",
"V_SPE_DAK_VestSTG",
"V_SPE_DAK_VestMP40",
"V_SPE_DAK_FWOVest",
"V_SPE_DAK_VestKar98",
"V_SPE_DAK_VestMG",
"V_SPE_DAK_VestG43",
"V_SPE_FFI_Vest_rifle_pouch",
"V_SPE_FFI_Vest_rifle",
"V_SPE_FFI_Vest_Pouch"
];

_crewVests append ["U_SPE_milice_3"];

_pilotVests append ["U_SPE_milice_3"];

/////Uniforms
_uniforms append [
	"U_SPE_US_CC_EM_trop_roll",
    "U_SPE_US_CC_EM_trop",
    "U_SPE_US_CC_HBT_EM_trop_roll",
    "U_SPE_US_CC_HBT_EM_trop",
	"U_SPE_US_Tank_Crew2",
	"U_SPE_US_Tank_Crew",
	"U_SPE_US_HBT44_late_roll",
	"U_SPE_US_HBT44_late",
	"U_SPE_US_HBT44_trop",
	"U_SPE_US_HBT44_FrogSkin_Jungle_trop",
    "U_SPE_US_Tank_Coverall_Trop",
    "U_SPE_US_Tank_Coverall",
    "U_SPE_US_Pilot",
	"U_SPE_US_Pilot_lthr",
	"U_SPE_US_Private_late",
	"U_SPE_FR_Tank_Crew2",
	"U_SPE_FR_HBT_Uniform_Trop",
	"U_SPE_FR_Tank_Crew3",
    "U_SPE_FR_Tank_Crew"
];

_pilotUniforms append ["U_SPE_milice_3"];

/////Helmets
_helmets append [
	"H_SPE_US_Helmet_Scrim_os",
	"H_SPE_US_Helmet_NCO_scrim",
	"H_SPE_US_Helmet_Scrim_ns",
	"H_SPE_US_Helmet_Scrim",
	"H_SPE_US_Helmet_os",
    "H_SPE_US_Helmet_polar_Scrim_os",
    "H_SPE_US_Helmet_polar_Scrim_ns",
    "H_SPE_US_Helmet_polar_Scrim",
	"H_SPE_US_Helmet_polar_os",
	"H_SPE_US_Helmet_polar_net_os",
	"H_SPE_US_Helmet_polar_net_ns",
	"H_SPE_US_Helmet_polar_net",
	"H_SPE_US_Helmet_polar_ns",
    "H_SPE_US_Helmet_polar",
    "H_SPE_US_Helmet_Net_os",
    "H_SPE_US_Helmet_NCO_net",
	"H_SPE_US_Helmet_Net_ns",
	"H_SPE_US_Helmet_CO_Net",
	"H_SPE_US_Helmet_Net",
	"H_SPE_US_Helmet_band_net_os",
	"H_SPE_US_Helmet_band_net_ns",
	"H_SPE_US_Helmet_band_net",
    "H_SPE_US_Helmet_NCO",
    "H_SPE_US_MP_Helmet_White_os",
    "H_SPE_US_MP_Helmet_White_ns",
	"H_SPE_US_MP_Helmet_White",
	"H_SPE_US_Helmet_ns",
	"H_SPE_US_Helmet_CO",
	"H_SPE_US_Helmet_band_os",
	"H_SPE_US_Helmet_band_ns",
    "H_SPE_US_Helmet_band",
    "H_SPE_US_Helmet_29ID_Scrim_os",
    "H_SPE_US_Helmet_29ID_Scrim_ns",
	"H_SPE_US_Helmet_29ID_Scrim",
	"H_SPE_GER_Helmet_os",
	"H_SPE_GER_HelmetCamo2",
	"H_SPE_GER_HelmetCamo",
	"H_SPE_GER_HelmetCamo4",
	"H_SPE_GER_Helmet_ns_wire_painted",
    "H_SPE_GER_Helmet_os_painted",
    "H_SPE_GER_Helmet_ns_painted",
    "H_SPE_GER_Helmet_net_painted",
	"H_SPE_GER_Helmet_Glasses_painted",
	"H_SPE_GER_Helmet_painted",
	"H_SPE_GER_Helmet_ns_wire",
	"H_SPE_GER_Helmet_ns",
	"H_SPE_GER_HelmetUtility_Oak_OS",
    "H_SPE_GER_HelmetUtility_Oak",
    "H_SPE_GER_Helmet_net",
    "H_SPE_GER_HelmetUtility_Grass_OS",
	"H_SPE_GER_HelmetUtility_Grass",
	"H_SPE_GER_Helmet_Glasses",
	"H_SPE_GER_HelmetCamo3_OS",
	"H_SPE_GER_HelmetCamo3",
	"H_SPE_GER_HelmetUtility_OS",
	"H_SPE_GER_HelmetUtility",
    "H_SPE_GER_Helmet",
    "H_SPE_ST_Helmet3",
    "H_SPE_ST_Helmet4",
	"H_SPE_ST_Helmet",
	"H_SPE_ST_Helmet2",
	"H_SPE_FR_Adrian_ns",
	"H_SPE_FR_Adrian"
]; ///look for more helmets

_crewhelmets append ["H_SPE_US_Helmet_Tank_M1_Scrim","H_SPE_US_Helmet_Tank_M1_OS","H_SPE_US_Helmet_Tank_M1_NS"];

_pilothelmets append [
	"U_SPE_US_S31A_glove",
    "U_SPE_US_S31A",
    "U_SPE_US_S31_erla_glove",
    "U_SPE_US_S31_erla",
    "U_SPE_US_Pilot_glove",
    "U_SPE_US_Pilot",
    "U_SPE_US_Pilot_lthr_glove",
    "U_SPE_US_Pilot_lthr"
];

/////
_offuniforms append ["U_SPE_milice_3","U_SPE_milice_3_CD","U_SPE_milice_3_CDA","U_SPE_milice_3_CR","U_SPE_milice_3_CT"];

_backpacks append [
	"B_SPE_US_Radio_packboard",
	"B_SPE_US_packboard_eng",
	"B_SPE_US_packboard_ammo",
	"B_SPE_US_Backpack_Mk2",
	"B_SPE_US_Backpack_pick",
	"B_SPE_US_Backpack_RocketBag_Empty",
	"B_SPE_US_Backpack_M43_GP",
	"B_SPE_US_Backpack_M43_GP",
	"B_SPE_US_Backpack_dday",
	"B_SPE_US_Backpack",
	"B_SPE_US_M36_Bandoleer",
	"B_SPE_US_M36",
	"B_SPE_GER_Tonister41_Frame_Full",
	"B_SPE_GER_Tonister41_Frame",
	"B_SPE_GER_Tonister34_canvas",
	"B_SPE_GER_Tonister41_Frame_Full_ST",
	"B_SPE_GER_Tonister41_Frame_ST",
	"B_SPE_GER_A_frame_ST_Full"
];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_eeItems append ["SPE_ToolKit"];

_baseClassCellLeaderArray append ["SPE_FFI_TeamLeader","SPE_FFI_TeamLeader_Sten"]; /// squad leader
_baseClassMercenaryArray append ["SPE_FFI_Fighter","SPE_FFI_Fighter_No3","SPE_FFI_Grenadier","SPE_FFI_Militia","SPE_FFI_Militia_No3"]; /// can be GL or rifleman
_baseClassEnforcerArray append ["SPE_FFI_Fighter_G43","SPE_FFI_Fighter_Garand"]; /// heavy rifleman (?)
_baseClassPartisanArray append ["SPE_FFI_Tankhunter"]; /// light AT
_baseClassMinutemanArray append ["SPE_FFI_Fighter_Carbine","SPE_FFI_Fighter_M3","SPE_FFI_Fighter_MP40","SPE_FFI_Fighter_Sten","SPE_FFI_Militia_M37_Shotgun","SPE_FFI_Militia_Shotgun"]; /// light rifleman (with carbines?)
_baseClassMedicArray append ["SPE_FFI_Doctor"];
_baseClassSaboteurArray append ["SPE_FFI_Sapper"]; /// lightAT with gl rifle ? or enginier
_baseClassExplosivesExpertArray append ["SPE_FFI_Saboteur_M3A1","SPE_FFI_Saboteur","SPE_FFI_Sapper_Mle208","SPE_FFI_Sapper_Mle208"];
_baseClassATArray append ["SPE_FFI_Tankhunter"];
_baseClassAAArray append ["SPE_FFI_Tankhunter"];
_baseClassOppressorArray append ["SPE_FFI_Autorifleman_303_LMG","SPE_FFI_Autorifleman","SPE_FFI_MGunner"]; /// thats a machinegun(ner)
_baseClassSharpshooterArray append ["SPE_FFI_Sniper"]; ///marksmen/sniper

// ================== Специальные роли ==================

_baseClassCrewArray append ["SPE_FFI_Sapper"];
_baseClassPilotArray append ["SPE_FFI_Sapper"];
_baseClassCommanderArray append ["SPE_FFI_CellLeader"]; /// vip
_baseClassUnarmedArray append ["SPE_FFI_CellLeader"];
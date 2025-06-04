//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append [
"lxWS_African_Head_01",
"lxWS_African_Head_03",
"lxWS_African_Head_04",
"lxWS_African_Head_02",
"lxWS_Said_Head",
"lxWS_African_Head_Old_Bard",
"lxWS_African_Head_05",
"CamoHead_Persian_01_F", 
"CamoHead_Persian_02_F", 
"CamoHead_Persian_03_F",  
"lxWS_African_Head_Old",
"lxWS_Gustavo_Head",
"lxWS_Journalist_Head",
"lxWS_Givens_Head"
];

_lightArmedVehicles append ["O_G_Offroad_01_armor_AT_lxWS", "O_G_Offroad_01_armor_armed_lxWS"];
_lightUnarmedVehicles append ["O_G_Offroad_01_armor_base_lxWS"];
_apc append ["O_SFIA_APC_Wheeled_02_hmg_lxWS","O_SFIA_APC_Wheeled_02_unarmed_lxWS"];
_uav append ["O_UAV_02_lxWS","O_Tura_UAV_02_IED_lxWS"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_rifles append [
	["arifle_Galat_lxWS", "", "", "",  ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""],
	["arifle_Velko_lxWS", "", "", "",  ["35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_tracer_green_lxWS"], [], ""]
];
_tunedRifles append [
	["arifle_AK12_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"],
	["arifle_AK12_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"]
];
_enforcerRifles append [
	["arifle_VelkoR5_lxWS", "", "", "", ["50Rnd_556x45_Velko_reload_tracer_green_lxWS", "50Rnd_556x45_Velko_reload_tracer_green_lxWS", "50Rnd_556x45_Velko_tracer_green_lxWS"], [], ""],
	["arifle_Galat_lxWS", "", "", "", ["75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_Tracer_F"], [], ""],
	["sgun_aa40_lxWS", "", "", "", ["20Rnd_12Gauge_AA40_Pellets_lxWS", "20Rnd_12Gauge_AA40_Slug_lxWS", "20Rnd_12Gauge_AA40_HE_lxWS"], [], ""]
];
_carbines append [
	["arifle_VelkoR5_lxWS", "", "saber_light_lxWS", "optic_r1_high_lxWS",  ["35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_tracer_green_lxWS"], [], ""],
	["arifle_SLR_Para_lxWS", "", "saber_light_lxWS", "optic_r1_high_black_sand_lxWS",  ["20Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS"], [], ""],
	["arifle_SLR_Para_snake_lxWS", "", "saber_light_lxWS", "optic_r1_high_black_sand_lxWS",  ["20Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS"], [], ""]
];
_gls append [
	["arifle_VelkoR5_GL_lxWS", "", "", "", ["35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_tracer_green_lxWS"], _glammo, ""],
	["arifle_SLR_GL_lxWS", "", "", "", ["20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_reload_tracer_green_lxWS"], ["1Rnd_40mm_HE_lxWS", "1Rnd_40mm_HE_lxWS", "1Rnd_58mm_AT_lxWS", "1Rnd_50mm_Smoke_lxWS"], ""]
];
_mgs append [
	["LMG_S77_lxWS", "", "acc_pointer_IR", "optic_NVS", ["100Rnd_762x51_S77_Red_lxWS", "100Rnd_762x51_S77_Red_lxWS", "100Rnd_762x51_S77_Red_Tracer_lxWS"], [], ""]
];
_marksmanRifles append [
	["arifle_SLR_lxWS", "", "", "", ["20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_reload_tracer_green_lxWS"], [], ""]
];

_rpgs append [
	["launch_RPG32_tan_lxWS", "", "", "", ["RPG32_F", "RPG32_F"], [], ""]
];

_rpgsHE append [
	["launch_RPG32_tan_lxWS", "", "", "", ["RPG32_HE_F", "RPG32_HE_F"], [], ""]
];

///
_facewear append ["G_Combat_lxWS"];

_fullmask append [
	"G_Balaclava_blk_lxWS","G_Balaclava_oli_lxWS","G_Balaclava_snd_lxWS"
];

_headgear append [
	"lxWS_H_Headset",
	"H_Beret_Headset_lxWS"	
];

/////Vests
_vests append ["V_lxWS_HarnessO_oli"];

_crewVests append ["V_lxWS_HarnessO_oli"];

_pilotVests append ["V_lxWS_HarnessO_oli"];

/////Uniforms
_uniforms append [
	"U_lxWS_SFIA_soldier_2_O",
    "U_lxWS_SFIA_soldier_1_O",
    "U_lxWS_ION_Casual3",
    "U_lxWS_ION_Casual6",
	"U_lxWS_ION_Casual5",
	"U_SFIA_deserter_lxWS",
	"U_lxWS_SFIA_deserter",
	"U_lxWS_SFIA_pilot_O",
	"U_lxWS_SFIA_Tanker_O"
];

_pilotUniforms append [
	"U_lxWS_SFIA_pilot_O"
];

/////Helmets
_helmets append [
	"lxWS_H_ssh40_black",
	"lxWS_H_ssh40_green",
	"lxWS_H_ssh40_sand",
	"lxWS_H_bmask_base",
	"H_turban_02_mask_black_lxws",
	"lxWS_H_bmask_camo01",
	"H_bmask_snake_lxws",
	"H_turban_02_mask_snake_lxws",
	"lxWS_H_bmask_white", 
	"lxWS_H_bmask_camo02", 
	"lxWS_H_bmask_yellow", 
	"lxWS_H_PASGT_goggles_black_F", 
	"lxWS_H_PASGT_goggles_olive_F", 
	"lxWS_H_HelmetCrew_I"
]; ///look for more helmets

_crewhelmets append [
	"lxWS_H_Tank_tan_F", "lxWS_H_HelmetCrew_I"
];

_backpacks append [
	"B_shield_backpack_lxWS"
];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_baseClassCellLeaderArray append ["O_Tura_watcher_lxWS"]; /// squad leader
_baseClassMercenaryArray append ["O_Tura_defector_lxWS","O_Tura_deserter_lxWS"]; /// can be GL or rifleman
_baseClassEnforcerArray append ["O_Tura_enforcer_lxWS"]; /// heavy rifleman (?)
_baseClassMedicArray append ["O_Tura_medic2_lxWS"];
_baseClassSaboteurArray append ["I_PMC_Story_Gustavo_lxWS"]; /// lightAT with gl rifle ?
_baseClassExplosivesExpertArray append ["O_Tura_thug_lxWS"];
_baseClassATArray append ["O_Tura_hireling_lxWS"];
_baseClassOppressorArray append ["O_Tura_HeavyGunner_lxWS"]; /// thats a machinegun(ner)
_baseClassSharpshooterArray append ["O_Tura_scout_lxWS"]; ///marksmen/sniper

// ================== Специальные роли ==================
_baseClassCommanderArray append ["I_SFIA_Said_lxWS"]; /// vip
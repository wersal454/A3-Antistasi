//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append ["GreekHead_A3_01","GreekHead_A3_02","GreekHead_A3_10_a","GreekHead_A3_10_l",
"GreekHead_A3_10_sa","WhiteHead_01","WhiteHead_02","WhiteHead_18",
"WhiteHead_05","GreekHead_A3_07","WhiteHead_03","WhiteHead_04","GreekHead_A3_03",
"GreekHead_A3_04","WhiteHead_06","WhiteHead_07","GreekHead_A3_05","GreekHead_A3_06",
"WhiteHead_08","AfricanHead_02","AfricanHead_03","WhiteHead_09","GreekHead_A3_08",
"WhiteHead_16","WhiteHead_11", "WhiteHead_22_a", "WhiteHead_22_l",
"WhiteHead_22_sa", "WhiteHead_10", "WhiteHead_19", "WhiteHead_17", "WhiteHead_21", "WhiteHead_12", "WhiteHead_13",
"GreekHead_A3_09","WhiteHead_14","WhiteHead_15","WhiteHead_20","AfricanHead_01",
"GreekHead_A3_13","GreekHead_A3_14","GreekHead_A3_11",
"GreekHead_A3_12","WhiteHead_23",
"Barklem","Mavros","Sturrock","Ioannou",
"PersianHead_A3_01","PersianHead_A3_04_a","PersianHead_A3_04_l","PersianHead_A3_04_sa",
"PersianHead_A3_02","AsianHead_A3_02","AsianHead_A3_03","AsianHead_A3_01",
"PersianHead_A3_03"]; 
_voices append ["Male01GRE","Male02GRE","Male03GRE","Male04GRE","Male05GRE","Male06ENG","Male01GREVR","Male01ENG","Male02ENG","Male03ENG",
"Male04ENG","Male05ENG","Male06ENG","Male07ENG","Male08ENG","Male09ENG","Male10ENG","Male11ENG","Male12ENG","Male01ENGB",
"Male02ENGB","Male03ENGB","Male04ENGB","Male05ENGB","Male01ENGVR","Male01PER","Male02PER","Male03PER","Male01PERVR"];

_lightArmedVehicles append ["O_G_Offroad_01_AT_F", "O_G_Offroad_01_armed_F"];
_lightUnarmedVehicles append ["I_G_Offroad_01_F"];
//_apc append [];
_tanks append ["I_LT_01_cannon_F"];
_helis append ["B_Heli_Light_01_F","I_Heli_light_03_unarmed_F"];
_uav append ["O_UAV_01_F","O_UAV_06_F","O_UAV_06_medical_F","C_IDAP_UAV_06_antimine_F"];
_trucks append ["O_G_Van_01_transport_F","O_G_Van_02_transport_F", "O_G_Van_02_vehicle_F"];
_staticLowWeapons append ["O_G_HMG_02_F"];
_staticAT append ["O_static_AT_F"];
_staticMortars append ["O_Mortar_01_F"];

_minesAT append ["ATMine"];
_minesAPERS append ["APERSMine", "APERSBoundingMine"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_glammo append ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "UGL_FlareWhite_F", "1Rnd_Smoke_Grenade_shell"];

_rifles append [
	["arifle_TRG21_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
_tunedRifles append [
	["arifle_TRG21_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_TRG21_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["srifle_DMR_03_F", "", "acc_flashlight", "optic_MRCO", ["20Rnd_762x51_Mag"], [], "bipod_02_F_blk"]
];
_enforcerRifles append [
	["arifle_TRG21_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
_carbines append [
	["arifle_TRG20_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20C_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
_gls append [
	["arifle_TRG21_GL_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], _glammo, ""],
	["arifle_Mk20_GL_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], _glammo, ""]
];
_mgs append [
	["LMG_Zafir_F", "", "", "", ["150Rnd_762x54_Box", "150Rnd_762x54_Box", "150Rnd_762x54_Box_Tracer"], [], ""]
];
_marksmanRifles append [
	["srifle_EBR_F", "", "", "optic_MRCO", ["20Rnd_762x51_Mag"], [], ""],
	["srifle_DMR_03_F", "", "acc_flashlight", "optic_MRCO", ["20Rnd_762x51_Mag"], [], "bipod_02_F_blk"]
];

_rpgs append [
	["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
	["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
	["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
	["launch_O_Vorona_green_F", "", "", "", ["Vorona_HEAT", "Vorona_HE"], [], ""]
];

_rpgsHE append [
	["launch_RPG32_F", "", "", "", ["RPG32_HE_F", "RPG32_HE_F"], [], ""]
];

_AAlaunchers append [
	["launch_O_Titan_F", "", "acc_pointer_IR", "", ["Titan_AA"], [], ""]
];

_pistols append ["hgun_Rook40_F"];

_ATMines append ["ATMine_Range_Mag"];
_APMines append ["APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag"];
_lightExplosives append ["IEDLandSmall_Remote_Mag"];
_heavyExplosives append ["IEDLandBig_Remote_Mag"];

_antiInfantryGrenades append ["HandGrenade", "MiniGrenade"];
_smokeGrenades append ["SmokeShell"];
_signalsmokeGrenades append ["SmokeShellYellow", "SmokeShellRed", "SmokeShellPurple", "SmokeShellOrange", "SmokeShellGreen", "SmokeShellBlue"];

_maps append ["ItemMap"];
_watches append ["ItemWatch"];
_compasses append ["ItemCompass"];
_radios append ["ItemRadio"];
_gpses append ["ItemGPS"];
_NVGs append ["NVGoggles_INDEP"];
_binoculars append ["Binocular"];
_Rangefinder append ["Rangefinder"];

///
_facewear append [
	"G_Aviator",
	"G_Combat",
	"G_Bandanna_aviator",
	"G_Bandanna_beast",
	"G_Bandanna_sport",
	"G_Bandanna_shades",
	"G_Bandanna_blk"
];

_fullmask append [
	"G_Balaclava_combat", "G_Balaclava_lowprofile", "G_Balaclava_blk"
];

_headgear append [
	"H_Shemag_olive",
    "H_Booniehat_oli",
    "H_Beret_blk",
    "H_Cap_oli",
    "H_Cap_headphones",
	"H_Watchcap_camo"
];

/////Vests
_vests append ["V_Chestrig_oli", "V_TacChestrig_oli_F", 
"V_TacVest_oli", "V_HarnessOGL_brn", 
"V_HarnessO_brn","V_Pocketed_black_F", 
"V_Pocketed_coyote_F", "V_Pocketed_olive_F"
];

_heavyVests append ["V_TacVestIR_blk", "V_Press_F", "V_PlateCarrierIAGL_oli", "V_I_G_resistanceLeader_F", "V_TacVest_blk_POLICE","V_PlateCarrier1_blk","V_PlateCarrier2_blk"];

_crewVests append [];

_pilotVests append [];

/////Uniforms
_uniforms append [
	"U_I_C_Soldier_Para_4_F",
	"U_I_C_Soldier_Para_2_F",
	"U_I_C_Soldier_Para_3_F",
	"U_I_C_Soldier_Para_1_F",
	"U_I_C_Soldier_Camo_F",
	"U_I_C_Soldier_Bandit_3_F",
    "U_I_C_Soldier_Bandit_2_F",
	"U_Tank_green_F"
];

_heavyUniforms append [];

_pilotUniforms append ["U_Marshal","U_C_WorkerCoveralls","U_Rangemaster","U_Tank_green_F"];

/////Helmets
_helmets append ["H_HelmetB","H_PASGT_basic_black_F",
 "H_PASGT_basic_blue_F", 
 "H_PASGT_basic_olive_F", 
 "H_PASGT_neckprot_blue_press_F", 
 "H_PASGT_basic_blue_press_F",
 "H_HeadBandage_clean_F", 
 "H_HeadBandage_stained_F", 
 "H_HeadBandage_bloody_F"
 ]; ///look for more helmets

_crewhelmets append ["H_Tank_black_F","H_Construction_headset_black_F"];

_pilothelmets append ["H_PilotHelmetHeli_O", "H_CrewHelmetHeli_O", "H_PilotHelmetHeli_B", "H_CrewHelmetHeli_B"];

/////
_offuniforms append ["U_I_C_Soldier_Camo_F"];

_backpacks append ["B_AssaultPack_rgr",
"B_AssaultPack_cbr","B_AssaultPack_sgg",
"B_AssaultPack_khk","B_AssaultPack_blk",
"B_TacticalPack_oli","B_Carryall_oli",
"B_Kitbag_sgg","B_FieldPack_oli",
"B_CivilianBackpack_01_Everyday_Black_F",
"B_CivilianBackpack_01_Everyday_Astra_F",
"B_CivilianBackpack_01_Everyday_Vrana_F",
"B_CivilianBackpack_01_Sport_Green_F",
"B_CivilianBackpack_01_Sport_Red_F",
"B_CivilianBackpack_01_Sport_Blue_F",
"B_Messenger_Olive_F","B_Messenger_Black_F","B_LegStrapBag_olive_F","B_LegStrapBag_black_F"
];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_slItems append ["Laserbatteries", "Laserbatteries", "Laserbatteries"];
_eeItems append ["ToolKit", "MineDetector"];

_baseClassCellLeaderArray append ["O_G_Soldier_SL_F","O_G_Soldier_TL_F"]; /// squad leader
_baseClassMercenaryArray append ["O_G_Soldier_A_F","O_G_Soldier_GL_F","I_G_Story_SF_Captain_F"]; /// can be GL or rifleman
_baseClassEnforcerArray append ["I_G_Story_Protagonist_F","I_G_resistanceLeader_F"]; /// heavy rifleman (?)
_baseClassPartisanArray append ["O_G_Soldier_LAT2_F"]; /// light AT
_baseClassMinutemanArray append ["O_G_Soldier_F","O_G_Soldier_lite_F","B_G_Story_Guerilla_01_F"]; /// light rifleman (with carbines?)
_baseClassMedicArray append ["O_G_medic_F"];
_baseClassSaboteurArray append ["O_G_engineer_F"]; /// lightAT with gl rifle ? or enginier
_baseClassExplosivesExpertArray append ["O_G_Soldier_exp_F"];
_baseClassATArray append ["O_G_Soldier_LAT_F"];
_baseClassAAArray append ["O_G_Soldier_LAT_F"];
_baseClassOppressorArray append ["O_G_Soldier_AR_F"]; /// thats a machinegun(ner)
_baseClassSharpshooterArray append ["O_G_Soldier_M_F","O_G_Sharpshooter_F"]; ///marksmen/sniper

// ================== Специальные роли ==================

_baseClassCrewArray append ["B_G_Story_Guerilla_01_F"];
_baseClassPilotArray append ["B_G_Story_Guerilla_01_F"];
_baseClassCommanderArray append ["O_G_officer_F"]; /// vip
_baseClassUnarmedArray append ["O_G_Soldier_unarmed_F","O_G_Survivor_F"];
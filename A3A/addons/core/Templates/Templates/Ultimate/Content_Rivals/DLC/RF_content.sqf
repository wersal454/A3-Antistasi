//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append [
"Pilot1_Head_rf",
"Pilot2_Head_rf"
]; 

_lightArmedVehicles append ["a3a_black_Pickup_mmg_rf", "a3u_black_Pickup_mmg_frame_rf", "a3u_black_Pickup_mmg_alt_rf", "B_G_Pickup_Rocket_rf", "AU_I_G_Pickup_Minigun_R"];
_lightUnarmedVehicles append ["a3u_black_Pickup_rival_rf"];

_staticMortars append ["B_G_CommandoMortar_RF"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_rifles append [
	["arifle_ash12_blk_RF", "", "", "", ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], [], ""]
];
_tunedRifles append [
	["arifle_ash12_LR_blk_RF", "", "", "optic_VRCO_RF", ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], [], ""],
	["srifle_h6_gold_rf", "muzzle_snds_M", "", "optic_VRCO_RF", ["30Rnd_556x45_AP_Stanag_green_RF"], [], ""]
];
_enforcerRifles append [
	["arifle_ash12_LR_blk_RF", "", "optic_VRCO_RF", "", ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], [], ""]
];
_gls append [
	["arifle_ash12_GL_blk_RF", "", "acc_flashlight", "optic_VRCO_khk_RF", ["10Rnd_127x55_Mag_RF", "20Rnd_127x55_Mag_RF"], _glammo, ""]
];
_marksmanRifles append [
	["srifle_DMR_01_black_RF", "", "acc_flashlight", "optic_VRCO_RF", ["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"], [], ""]
];

_rpgs append [
	["launch_PSRL1_black_RF", "", "", "", ["PSRL1_AT_RF","PSRL1_HEAT_RF"], [], ""],
    ["launch_PSRL1_olive_RF", "", "", "", ["PSRL1_AT_RF","PSRL1_HEAT_RF"], [], ""],
    ["launch_PSRL1_PWS_black_RF", "", "", "", ["PSRL1_AT_RF","PSRL1_HEAT_RF"], [], ""],
    ["launch_PSRL1_PWS_olive_RF", "", "", "", ["PSRL1_AT_RF","PSRL1_HEAT_RF"], [], ""],
	["launch_PSRL1_sand_RF", "", "", "", ["PSRL1_AT_RF","PSRL1_HEAT_RF"], [], ""],
	["launch_PSRL1_PWS_sand_RF", "", "", "", ["PSRL1_AT_RF","PSRL1_HEAT_RF"], [], ""]
];

_rpgsHE append [
	["launch_PSRL1_black_RF", "", "", "", ["PSRL1_FRAG_RF","PSRL1_HE_RF"], [], ""],
    ["launch_PSRL1_olive_RF", "", "", "", ["PSRL1_FRAG_RF","PSRL1_HE_RF"], [], ""],
    ["launch_PSRL1_PWS_black_RF", "", "", "", ["PSRL1_FRAG_RF","PSRL1_HE_RF"], [], ""],
    ["launch_PSRL1_PWS_olive_RF", "", "", "", ["PSRL1_FRAG_RF","PSRL1_HE_RF"], [], ""],
	["launch_PSRL1_sand_RF", "", "", "", ["PSRL1_FRAG_RF","PSRL1_HE_RF"], [], ""],
	["launch_PSRL1_PWS_sand_RF", "", "", "", ["PSRL1_FRAG_RF","PSRL1_HE_RF"], [], ""]
];

_pistols append [
	["hgun_Glock19_RF", "hgun_Glock19_auto_RF", "hgun_DEagle_RF", "hgun_Glock19_auto_khk_RF", "hgun_DEagle_classic_RF","hgun_DEagle_camo_RF","hgun_DEagle_gold_RF"]
];

///
_facewear append [
	"G_Bandanna_yellow_RF",
    "G_Glasses_black_RF",
    "G_Glasses_white_RF"
];

_heavyVests append ["V_PlateCarrierLite_black_noFlag_RF","V_TacVest_rig_oli_RF","V_TacVest_rig_khk_RF","V_TacVest_rig_blk_RF", "V_TacVest_gen_holster_RF"];

_crewVests append ["V_TacVest_rig_oli_RF","V_TacVest_rig_khk_RF","V_TacVest_rig_blk_RF", "V_TacVest_gen_holster_RF"];

_pilotVests append ["V_TacVest_rig_oli_RF","V_TacVest_rig_khk_RF","V_TacVest_rig_blk_RF", "V_TacVest_gen_holster_RF"];

/////Uniforms

_pilotUniforms append [
	"U_C_PilotJacket_brown_RF",
    "U_C_PilotJacket_open_brown_RF",
    "U_C_PilotJacket_lbrown_RF",
    "U_C_PilotJacket_open_lbrown_RF",
    "U_C_PilotJacket_black_RF",
    "U_C_PilotJacket_open_black_RF",
    "U_C_HeliPilotCoveralls_Yellow_RF",
    "U_C_HeliPilotCoveralls_Green_RF",
    "U_C_HeliPilotCoveralls_Rescue_RF",
    "U_C_HeliPilotCoveralls_Blue_RF",
    "U_C_HeliPilotCoveralls_Black_RF"
];

/////Helmets
_helmets append [
	"H_HelmetHeavy_White_RF",
	"H_HelmetHeavy_Simple_White_RF",
	"H_HelmetHeavy_VisorUp_White_RF",
	"H_HelmetHeavy_Olive_RF",
	"H_HelmetHeavy_Simple_Olive_RF",
	"H_HelmetHeavy_VisorUp_Olive_RF",
	"H_HelmetHeavy_Sand_RF",
	"H_HelmetHeavy_Simple_Sand_RF",
	"H_HelmetHeavy_VisorUp_Sand_RF",
	"H_HelmetHeavy_Black_RF", 
	"H_HelmetHeavy_Simple_Black_RF", 
	"H_HelmetHeavy_VisorUp_Black_RF",
	"H_HelmetB_plain_sb_wdl_RF",
	"H_HelmetB_plain_sb_tna_RF"
]; ///look for more helmets

_pilothelmets append [
	"H_PilotHelmetHeli_White_RF",
    "H_PilotHelmetHeli_Yellow_RF",
    "H_PilotHelmetHeli_Green_RF",
    "H_PilotHelmetHeli_Red_RF",
	"H_PilotHelmetHeli_MilGreen_RF",
	"H_PilotHelmetHeli_Orange_RF",
	"H_PilotHelmetHeli_Blue_RF",
	"H_PilotHelmetHeli_Black_RF"
];

/////

_backpacks append ["B_DuffleBag_Olive_NoLogo_RF","B_DuffleBag_Black_NoLogo_RF","B_DuffleBag_Sand_RF","B_DuffleBag_Red_RF","B_DuffleBag_Olive_RF","B_DuffleBag_Blue_RF","B_DuffleBag_Black_RF","B_DuffleBag_VRANA_RF"];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_baseClassExplosivesExpertArray append ["O_G_support_CMort_RF"];
_baseClassATArray append ["O_G_Soldier_LAT_RF"];
_baseClassSharpshooterArray append ["O_G_Scout_RF"]; ///marksmen/sniper
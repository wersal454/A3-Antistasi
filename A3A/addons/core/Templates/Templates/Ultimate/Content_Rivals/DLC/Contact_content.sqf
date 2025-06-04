//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append [
	"LivonianHead_9",
"LivonianHead_4",
"LivonianHead_8",
"LivonianHead_10",
"LivonianHead_1",
"LivonianHead_3",
"LivonianHead_6",
"LivonianHead_7",
"LivonianHead_2",
"LivonianHead_5",
"RussianHead_5",
"RussianHead_2",
"RussianHead_3",
"RussianHead_1",
"RussianHead_4",
"WhiteHead_31",
"WhiteHead_30",
"WhiteHead_29",
"WhiteHead_32",
"WhiteHead_28",
"WhiteHead_27",
"WhiteHead_26",
"WhiteHead_25",
"WhiteHead_24"
]; 
_voices append [
"Male01POL",
"Male02POL",
"Male03POL",
"Male01RUS",
"Male02RUS",
"Male03RUS"
];

//////////////////////////
//       Loadouts       //
//////////////////////////
_tunedRifles append [
	["arifle_AK12U_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""]
];
_carbines append [
	["arifle_AK12U_F", "", "", "", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""]
];
_marksmanRifles append [
	["srifle_DMR_06_hunter_F", "", "", "optic_DMS_weathered_F", ["10Rnd_Mk14_762x51_Mag"], [], ""]
];


///
_facewear append ["G_Blindfold_01_black_F","G_Blindfold_01_white_F"];

_fullmask append ["G_RegulatorMask_F"];

_headgear append [
	"H_Booniehat_mgrn",
	"H_Booniehat_taiga", 
	"H_Booniehat_wdl", 
	"H_Booniehat_eaf", 
	"H_MilCap_grn", 
	"H_MilCap_taiga", 
	"H_MilCap_wdl", 
	"H_MilCap_eaf"
];

/////Vests
_vests append ["V_SmershVest_01_F", "V_SmershVest_01_radio_F"];

_heavyVests append ["V_CarrierRigKBT_01_EAF_F", "V_CarrierRigKBT_01_Olive_F","V_CarrierRigKBT_01_light_Olive_F","V_CarrierRigKBT_01_heavy_Olive_F"];

_crewVests append ["V_SmershVest_01_F", "V_SmershVest_01_radio_F"];

_pilotVests append ["V_SmershVest_01_F", "V_SmershVest_01_radio_F"];

/////Uniforms
_uniforms append [
	"U_I_E_Uniform_01_sweater_F",
    "U_I_E_Uniform_01_tanktop_F",
    "U_I_L_Uniform_01_camo_F",
    "U_I_L_Uniform_01_deserter_F",
	"U_C_E_LooterJacket_01_F",
	"U_I_L_Uniform_01_tshirt_olive_F"
];

_heavyUniforms append [
	"U_O_R_Gorka_01_F",
    "U_O_R_Gorka_01_brown_F",
    "U_O_R_Gorka_01_camo_F"
];

/////Helmets
_helmets append ["H_HelmetAggressor_F", "H_HelmetAggressor_cover_F", "H_HelmetAggressor_cover_taiga_F"]; ///look for more helmets

_crewhelmets append ["H_Tank_eaf_F", "H_HelmetCrew_I_E", "H_Booniehat_wdl", "H_Booniehat_eaf"];

_backpacks append ["B_FieldPack_green_F","B_RadioBag_01_digi_F","B_RadioBag_01_black_F","B_Carryall_green_F"];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_baseClassMercenaryArray append ["I_L_Looter_Rifle_F"]; /// can be GL or rifleman
_baseClassMinutemanArray append ["I_L_Criminal_SG_F","I_L_Criminal_SMG_F","I_L_Looter_Pistol_F","I_L_Looter_SG_F","I_L_Looter_SMG_F"]; /// light rifleman (with carbines?)
_baseClassSharpshooterArray append ["I_L_Hunter_F"]; ///marksmen/sniper
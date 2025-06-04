//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append ["AsianHead_A3_06",
"AsianHead_A3_07",
"AsianHead_A3_04",
"AsianHead_A3_05",
"TanoanHead_A3_08",
"TanoanHead_A3_06",
"TanoanHead_A3_01",
"TanoanHead_A3_09",
"TanoanHead_A3_07",
"TanoanHead_A3_05",
"TanoanHead_A3_04",
"TanoanHead_A3_03",
"TanoanHead_A3_02"]; 
_voices append [
"Male01CHI",
"Male02CHI",
"Male03CHI",
"Male01FRE",
"Male02FRE",
"Male03FRE",
"Male01ENGFRE",
"Male02ENGFRE"
];

_helis append ["I_C_Heli_Light_01_civil_F"];

_lightArmedVehicles append ["I_C_Offroad_02_AT_F", "I_C_Offroad_02_LMG_F"];
_lightUnarmedVehicles append ["I_C_Offroad_02_unarmed_F","B_G_Offroad_01_F"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_rifles append [
	["arifle_AKM_F", "", "", "", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""]
];
_tunedRifles append [
	["arifle_AK12_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"],
	["arifle_AK12_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"]
];
_enforcerRifles append [
	["arifle_AKM_F", "", "", "", ["75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_Tracer_F"], [], ""]
];
_carbines append [
	["arifle_AKS_F", "", "", "", ["30Rnd_545x39_Mag_Green_F", "30Rnd_545x39_Mag_Green_F", "30Rnd_545x39_Mag_Tracer_Green_F"], [], ""]
];
_gls append [
	["arifle_AK12_GL_F", "", "", "", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F"], _glammo, ""]
];
_mgs append [
	["LMG_03_F", "", "acc_flashlight", "", ["200Rnd_556x45_Box_Red_F", "200Rnd_556x45_Box_Red_F", "200Rnd_556x45_Box_Tracer_Red_F"], [], ""]
];

_rpgs append [
	["launch_RPG7_F", "", "", "", ["RPG7_F", "RPG7_F", "RPG7_F"], [], ""],
	["launch_RPG7_F", "", "", "", ["RPG7_F", "RPG7_F", "RPG7_F"], [], ""],
	["launch_RPG7_F", "", "", "", ["RPG7_F", "RPG7_F", "RPG7_F"], [], ""]
];

_pistols append ["hgun_Pistol_01_F"];

/////Vests
_vests append ["V_TacChestrig_cbr_F", "V_TacChestrig_grn_F", "V_TacChestrig_oli_F"];

_heavyVests append ["V_TacVest_gen_F","V_PlateCarrier1_rgr_noflag_F","V_PlateCarrier2_rgr_noflag_F"];

_crewVests append ["V_TacChestrig_cbr_F", "V_TacChestrig_grn_F", "V_TacChestrig_oli_F","V_TacVest_gen_F","V_PlateCarrier1_rgr_noflag_F","V_PlateCarrier2_rgr_noflag_F"];

_pilotVests append ["V_TacChestrig_cbr_F", "V_TacChestrig_grn_F", "V_TacChestrig_oli_F","V_TacVest_gen_F","V_PlateCarrier1_rgr_noflag_F","V_PlateCarrier2_rgr_noflag_F"];


/////Helmets
_helmets append ["H_Helmet_Skate"]; ///look for more helmets

_backpacks append ["B_ViperHarness_oli_F","B_ViperLightHarness_oli_F"];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_baseClassCellLeaderArray append ["I_C_Soldier_Bandit_4_F"]; /// squad leader
_baseClassMercenaryArray append ["I_C_Soldier_Bandit_5_F","I_C_Soldier_Bandit_6_F","I_C_Soldier_Para_6_F"]; /// can be GL or rifleman
_baseClassEnforcerArray append ["I_C_Soldier_Para_7_F","I_C_Soldier_Para_2_F","I_C_Soldier_Para_1_F"]; /// heavy rifleman (?)
_baseClassPartisanArray append ["I_C_Soldier_Bandit_2_F","I_C_Soldier_Para_5_F"]; /// light AT
_baseClassMinutemanArray append ["I_C_Soldier_Bandit_7_F"]; /// light rifleman (with carbines?)
_baseClassMedicArray append ["I_C_Soldier_Bandit_1_F","I_C_Soldier_Para_3_F"];
_baseClassExplosivesExpertArray append ["I_C_Soldier_Bandit_8_F","I_C_Soldier_Para_8_F"];
_baseClassOppressorArray append ["I_C_Soldier_Bandit_3_F","I_C_Soldier_Para_4_F"]; /// thats a machinegun(ner)
// ================== Специальные роли ==================
_baseClassCrewArray append ["I_C_Pilot_F","I_C_Helipilot_F"];
_baseClassPilotArray append ["I_C_Pilot_F","I_C_Helipilot_F"];
_baseClassCommanderArray append ["I_C_Soldier_Camo_F"]; /// vip
_baseClassUnarmedArray append ["I_C_Soldier_base_unarmed_F"];
//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
_faces append ["GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04",
"GreekHead_A3_05","GreekHead_A3_06","GreekHead_A3_07","GreekHead_A3_08",
"GreekHead_A3_09","Ioannou","Mavros"]; 
_voices append ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"];

_lightArmedVehicles append ["OPTRE_M12_LRV_ins"];
_lightUnarmedVehicles append ["OPTRE_M12_FAV_ins"];
_apc append ["OPTRE_M12_ins_APC"];
_tanks append ["OPTRE_M808B_INS"];
_helis append ["OPTRE_UNSC_falcon_armed_S_ins"];
_uav append ["O_UAV_01_F"];
_trucks append ["OPTRE_m1015_mule_ins"];
_staticLowWeapons append ["OPTRE_Static_M247H_Tripod"];
_staticAT append ["OPTRE_Static_FG75"];
_staticMortars append ["B_Mortar_01_F"];

_minesAT append ["OPTRE_Placed_Mine"];
_minesAPERS append ["APERSMine"];

//////////////////////////
//       Loadouts       //
//////////////////////////

_glammo append ["1Rnd_HE_Grenade_shell","OPTRE_1Rnd_MasterKey_Pellets","OPTRE_1Rnd_MasterKey_Slugs"];

_rifles append [
["OPTRE_MA5B", "", "", "", ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag"], [], ""],
["OPTRE_BR55HB", "", "", "", ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag"], [], ""]
];
_tunedRifles append [
["OPTRE_MA5B", "", "", "optre_ma5_smartlink", ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag"], [], ""],
["OPTRE_BR55HB", "", "", "optre_br55hb_scope", ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag"], [], ""]
];
_enforcerRifles append [
["OPTRE_MA5B", "", "", "optre_ma5_smartlink", ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag"], [], ""],
["OPTRE_BR55HB", "", "", "optre_br55hb_scope", ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag"], [], ""]
];
_carbines append [
["OPTRE_M392_DMR", "", "optre_dmr_light", "optre_br55hb_scope", ["OPTRE_15Rnd_762x51_Mag", "OPTRE_15Rnd_762x51_Mag", "OPTRE_15Rnd_762x51_Mag"], [], ""],
["OPTRE_Commando", "", "", "optic_Holosight_blk_F", ["Commando_20Rnd_65_Mag", "Commando_20Rnd_65_Mag", "Commando_20Rnd_65_Mag"], [], ""],
["OPTRE_M7", "", "optre_m7_laser", "optre_m7_sight", [], [], ""],
["OPTRE_M45ATAC", "", "optre_m45_flashlight_green", "", [], [], ""]
];
_gls append [
["OPTRE_MA5BGL", "", "", "optre_ma5_smartlink", ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag"], ["3Rnd_HE_Grenade_shell", "3Rnd_HE_Grenade_shell", "OPTRE_1Rnd_SmokeGreen_Grenade_shell"], ""]
];
_mgs append [
["OPTRE_M247H_Etilka", "", "", "", ["OPTRE_200Rnd_127x99_M247H_Etilka_Ball", "OPTRE_200Rnd_127x99_M247H_Etilka_Ball", "OPTRE_200Rnd_127x99_M247H_Etilka_Ball"], [], ""],
["OPTRE_M73", "", "", "", ["OPTRE_200Rnd_95x40_Box", "OPTRE_200Rnd_95x40_Box_Tracer_Yellow","OPTRE_100Rnd_95x40_Box","OPTRE_100Rnd_95x40_Box_Tracer_Yellow"], [], ""]
];
_marksmanRifles append [
["OPTRE_M393_DMR", "", "", "optre_m393_scope", ["OPTRE_15Rnd_762x51_Mag", "OPTRE_15Rnd_762x51_Mag", "OPTRE_15Rnd_762x51_Mag"], [], "bipod_01_f_blk"],
["OPTRE_M6G", "optre_m6_silencer", "optre_m6g_flashlight", "optre_m6g_scope", [], [], ""]
];

_rpgs append [
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HE", "OPTRE_M41_Twin_HEAP","OPTRE_M41_Twin_HEAT"], [], ""]
];

_rpgsHE append [
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HE", "OPTRE_M41_Twin_Smoke_W"], [], ""]
];

_AAlaunchers append [
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HEAT_G_AA", "OPTRE_M41_Twin_HEAT_G_AA"], [], ""]
];

_pistols append [
["OPTRE_M6G", "optre_m6_silencer", "optre_m6g_flashlight", "optre_m6g_scope", [], [], ""]
];

_ATMines append ["UNSCMine_Range_Mag"];
_APMines append ["APERSMine_Range_Mag"];
_lightExplosives append ["M41_IED_Remote_Mag","M41_IED_B_Remote_Mag"];
_heavyExplosives append ["M41_IED_C_Remote_Mag"];

_antiInfantryGrenades append ["OPTRE_M9_Frag","OPTRE_AU44_122mm_Throwable","OPTRE_c7_remote_throwable_sticky_mag","OPTRE_M2_Smoke_Yellow"];
_smokeGrenades append ["OPTRE_M8_Flare_White","OPTRE_M2_Smoke"];
_signalsmokeGrenades append ["OPTRE_M2_Smoke_Blue","OPTRE_M2_Smoke_Green","OPTRE_M2_Smoke_Orange","OPTRE_M2_Smoke_Purple","OPTRE_M2_Smoke_Red",
"OPTRE_M2_Smoke_Yellow","OPTRE_M8_Flare_Blue","OPTRE_M8_Flare_Green","OPTRE_M8_Flare","OPTRE_M8_Flare_Yellow"];

_maps append ["ItemMap"];
_watches append ["ItemWatch"];
_compasses append ["ItemCompass"];
_radios append ["ItemRadio"];
_gpses append ["ItemGPS"];
_NVGs append ["OPTRE_NVG"];
_binoculars append ["OPTRE_Binoculars"];
_Rangefinder append ["OPTRE_Smartfinder"];

///
_facewear append ["G_Balaclava_blk", "OPTRE_HUD_r_Glasses"];

_fullmask append ["G_Balaclava_TI_blk_F"];

_headgear append [
	"OPTRE_Ins_URF_Helmet1",
	"OPTRE_Ins_URF_Helmet2"
];

/////Vests
_vests append [
	"OPTRE_Ins_URF_Armor1",
	"OPTRE_Ins_URF_Desert_Armor1",
	"OPTRE_Ins_URF_Desert_Armor1_Flat",
	"OPTRE_Ins_URF_Armor1_Flat",
	"OPTRE_Ins_URF_Jungle_Armor1",
	"OPTRE_Ins_URF_Jungle_Armor1_Flat",
	"OPTRE_Ins_URF_Snow_Armor1",
	"OPTRE_Ins_URF_Snow_Armor1_Flat",
	"OPTRE_Ins_URF_Tundra_Armor1",
	"OPTRE_Ins_URF_Woodland_Armor1",
	"OPTRE_Ins_URF_Woodland_Armor1_Flat"
];

_heavyVests append [
	"OPTRE_Ins_BJ_Armor",
	"OPTRE_Ins_BJ_Armor_Des",
	"OPTRE_Ins_BJ_Armor_Snw",
	"OPTRE_Ins_BJ_Armor_Wdl"
];

_crewVests append ["OPTRE_Vest_CMA_Light","OPTRE_Ins_URF_Armor1"];

_pilotVests append ["OPTRE_Vest_CMA_Light","OPTRE_Ins_URF_Armor1"];

/////Uniforms
_uniforms append [
	"OPTRE_Ins_ER_jacket_brown_surplus",
	"OPTRE_Ins_ER_uniform_GAgreen",
	"OPTRE_Ins_ER_uniform_GAtan",
	"OPTRE_Ins_ER_uniform_GGgrey",
	"OPTRE_Ins_ER_uniform_GGod",
	"OPTRE_Ins_ER_jacket_od_surplus",
	"OPTRE_Ins_ER_rolled_jean_orca",
	"OPTRE_Ins_ER_rolled_OD_blknblu",
	"OPTRE_Ins_ER_rolled_OD_blknred",
	"OPTRE_Ins_ER_rolled_OD_crimson",
	"OPTRE_Ins_ER_rolled_surplus_black",
	"OPTRE_Ins_ER_rolled_surplus_crimson",
	"OPTRE_Ins_ER_jacket_surgeon1",
	"OPTRE_Ins_ER_jacket_surgeon2",
	"OPTRE_Ins_ER_jacket_surplus_brown",
	"OPTRE_Ins_ER_jacket_surplus_OD",
	"OPTRE_Ins_ER_jacket_surplus_redshirt",
	"OPTRE_Ins_URF_Combat_Uniform",
	"OPTRE_Ins_URF_Combat_Desert_Uniform",
	"OPTRE_Ins_URF_Combat_Desert_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Jungle_Uniform",
	"OPTRE_Ins_URF_Combat_Jungle_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Snow_Uniform",
	"OPTRE_Ins_URF_Combat_Snow_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Tundra_Uniform",
	"OPTRE_Ins_URF_Combat_Woodland_Uniform",
	"OPTRE_Ins_URF_Combat_Woodland_Flat_Uniform"
];

_heavyUniforms append [
	"OPTRE_Ins_BJ_Undersuit",
	"OPTRE_Ins_BJ_Undersuit_Des",
	"OPTRE_Ins_BJ_Undersuit_Snw",
	"OPTRE_Ins_BJ_Undersuit_Wdl"
];

_pilotUniforms append ["OPTRE_Ins_URF_Combat_Uniform"];

/////Helmets
_helmets append [
	"OPTRE_Ins_BJ_Helmet",
	"OPTRE_Ins_BJ_Helmet_Des",
	"OPTRE_Ins_BJ_Helmet_Snw",
	"OPTRE_Ins_BJ_Helmet_Wdl",
	"OPTRE_Ins_URF_Helmet1",
	"OPTRE_Ins_URF_Helmet4",
	"OPTRE_Ins_URF_Helmet4_Brown",
	"OPTRE_Ins_URF_Helmet4_White",
	"OPTRE_Ins_URF_Helmet3",
	"OPTRE_Ins_URF_Helmet3_Brown",
	"OPTRE_Ins_URF_Helmet3_White",
	"OPTRE_Ins_URF_Helmet2",
	"OPTRE_Ins_URF_Helmet2_Brown",
	"OPTRE_Ins_URF_Helmet2_White",
	"OPTRE_Ins_URF_Helmet1_Brown",
	"OPTRE_Ins_URF_Helmet1_White"
];

_crewhelmets append ["OPTRE_UNSC_CH252A_Helmet"];

_pilothelmets append ["OPTRE_FC_VX19_Helmet"];

/////
_offuniforms append [
	"OPTRE_Ins_ER_jacket_od_surplus"
];

_backpacks append ["OPTRE_ILCS_Rucksack_Black","OPTRE_ILCS_Rucksack_Heavy"];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

_slItems append ["Laserbatteries", "Laserbatteries", "Laserbatteries"];
_eeItems append ["ToolKit", "MineDetector"];

_baseClassCellLeaderArray append ["OPTRE_Ins_ER_MAdvisor","OPTRE_Ins_URF_SquadLead","OPTRE_Ins_URF_TeamLead","OPTRE_Ins_URF_D_SquadLead","OPTRE_Ins_URF_D_TeamLead",
"OPTRE_Ins_URF_S_SquadLead","OPTRE_Ins_URF_S_TeamLead"]; /// squad leader
_baseClassMercenaryArray append ["OPTRE_Ins_BIA_Rifleman","OPTRE_Ins_ER_Deserter_GL","OPTRE_Ins_ER_Farmer","OPTRE_Ins_ER_Guerilla_AR","OPTRE_Ins_URF_Grenadier",
"OPTRE_Ins_URF_Grenadier2","OPTRE_Ins_URF_D_Breacher","OPTRE_Ins_URF_D_Breacher2","OPTRE_Ins_URF_D_Grenadier","OPTRE_Ins_URF_D_Grenadier2",
"OPTRE_Ins_URF_S_Breacher","OPTRE_Ins_URF_S_Breacher2","OPTRE_Ins_URF_S_Grenadier","OPTRE_Ins_URF_S_Grenadier2"]; /// can be GL or rifleman
_baseClassEnforcerArray append ["OPTRE_Ins_URF_Assist_Autorifleman","OPTRE_Ins_URF_Breacher","OPTRE_Ins_URF_Breacher2","OPTRE_Ins_URF_Observer",
"OPTRE_Ins_URF_Rifleman_BR","OPTRE_Ins_URF_Rifleman_Light","OPTRE_Ins_URF_Rifleman_AR","OPTRE_Ins_URF_D_Assist_Autorifleman","OPTRE_Ins_URF_D_Observer",
"OPTRE_Ins_URF_D_Rifleman_BR","OPTRE_Ins_URF_D_Rifleman_Light","OPTRE_Ins_URF_D_Rifleman_AR","OPTRE_Ins_URF_S_Assist_Autorifleman","OPTRE_Ins_URF_S_Observer",
"OPTRE_Ins_URF_S_Rifleman_BR","OPTRE_Ins_URF_S_Rifleman_Light","OPTRE_Ins_URF_S_Rifleman_AR"]; /// heavy rifleman (?)
_baseClassPartisanArray append ["OPTRE_Ins_ER_Rebel_AT"]; /// light AT
_baseClassMinutemanArray append ["OPTRE_Ins_BIA_RTO","OPTRE_Ins_ER_Hacker","OPTRE_Ins_URF_Radioman","OPTRE_Ins_URF_D_Radioman","OPTRE_Ins_URF_S_Radioman"]; /// light rifleman (with carbines?)
_baseClassMedicArray append ["OPTRE_Ins_ER_Surgeon","OPTRE_Ins_URF_Medic","OPTRE_Ins_URF_D_Medic","OPTRE_Ins_URF_S_Medic"];
_baseClassSaboteurArray append ["OPTRE_Ins_ER_Mortar_Thrower","OPTRE_Ins_URF_Engineer","OPTRE_Ins_URF_D_Engineer","OPTRE_Ins_URF_S_Engineer"]; /// lightAT with gl rifle ? or enginier
_baseClassExplosivesExpertArray append ["OPTRE_Ins_ER_Terrorist","OPTRE_Ins_URF_Demolitions","OPTRE_Ins_URF_D_Demolitions","OPTRE_Ins_URF_S_Demolitions"];
_baseClassATArray append ["OPTRE_Ins_URF_AT_Specialist","OPTRE_Ins_URF_Rifleman_AT","OPTRE_Ins_URF_D_AT_Specialist","OPTRE_Ins_URF_D_Rifleman_AT","OPTRE_Ins_URF_S_Rifleman_AT"];
_baseClassAAArray append ["OPTRE_Ins_URF_AA_Specialist","OPTRE_Ins_URF_D_AA_Specialist","OPTRE_Ins_URF_S_AA_Specialist"];
_baseClassOppressorArray append ["OPTRE_Ins_BIA_AutoRifleman","OPTRE_Ins_ER_Militia_MG","OPTRE_Ins_URF_Autorifleman","OPTRE_Ins_URF_D_Autorifleman",
"OPTRE_Ins_URF_S_Autorifleman"]; /// thats a machinegun(ner)
_baseClassSharpshooterArray append ["OPTRE_Ins_BIA_Sniper","OPTRE_Ins_ER_Assassin","OPTRE_Ins_ER_Insurgent_BR","OPTRE_Ins_URF_Marksman","OPTRE_Ins_URF_Sniper",
"OPTRE_Ins_URF_Tactical_Sniper","OPTRE_Ins_URF_D_Marksman","OPTRE_Ins_URF_D_Sniper","OPTRE_Ins_URF_D_Tactical_Sniper","OPTRE_Ins_URF_S_Marksman",
"OPTRE_Ins_URF_S_Sniper","OPTRE_Ins_URF_S_Tactical_Sniper"]; ///marksmen/sniper

// ================== Специальные роли ==================

_baseClassCrewArray append ["OPTRE_Ins_URF_Crewman","OPTRE_Ins_URF_D_Crewman","OPTRE_Ins_URF_S_Crewman"];
_baseClassPilotArray append ["OPTRE_Ins_URF_Pilot","OPTRE_Ins_URF_D_Pilot","OPTRE_Ins_URF_S_Pilot"];
_baseClassCommanderArray append ["OPTRE_Ins_ER_Warlord","OPTRE_Ins_URF_Officer","OPTRE_Ins_URF_D_Officer","OPTRE_Ins_URF_S_Officer"]; /// vip
_baseClassUnarmedArray append ["OPTRE_Ins_ER_Unarmed","OPTRE_Ins_URF_Unarmed","OPTRE_Ins_URF_D_Unarmed","OPTRE_Ins_URF_S_Unarmed"];
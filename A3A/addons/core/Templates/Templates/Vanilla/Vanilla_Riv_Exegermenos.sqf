private _hasWs = "ws" in A3A_enabledDLC;
private _hasMarksman = "mark" in A3A_enabledDLC;
private _hasLawsOfWar = "orange" in A3A_enabledDLC;
private _hasTanks = "tank" in A3A_enabledDLC;
private _hasApex = "expansion" in A3A_enabledDLC;
private _hasHelicopters = "heli" in A3A_enabledDLC;
private _hasContact = "enoch" in A3A_enabledDLC;
private _hasJets = "jets" in A3A_enabledDLC;
private _hasArtOfWar = "aow" in A3A_enabledDLC;
private _hasKart = "kart" in A3A_enabledDLC;
private _hasGM = "gm" in A3A_enabledDLC;
private _hasCSLA = "csla" in A3A_enabledDLC;
private _hasRF = "rf" in A3A_enabledDLC;
private _hasSOG = "vn" in A3A_enabledDLC;
private _hasSPE = "spe" in A3A_enabledDLC;

////////////////////////////
//   Rivals Information   //
///////////////////////////

["name", "Exegerménos"] call _fnc_saveToTemplate;
["nameLeader", "Alexander Akhanteros"] call _fnc_saveToTemplate;

//////////////////////////////////////
//       	Identities    			//
//////////////////////////////////////
["faces", [
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
]] call _fnc_saveToTemplate; 
["voices", ["Male01GRE","Male02GRE","Male03GRE","Male04GRE","Male05GRE","Male06GRE","Male01ENGFRE","Male02ENGFRE","male01rus","male02rus","male03rus"]] call _fnc_saveToTemplate;

//////////////////////////
//       Vehicles       //
//////////////////////////
["ammobox", "Box_FIA_Support_F"] call _fnc_saveToTemplate; 	//Don't touch or you die a sad and lonely death!
["surrenderCrate", "Box_Syndicate_Wps_F"] call _fnc_saveToTemplate;

private _lightArmedVehicles = [];
private _lightUnarmedVehicles = [];
private _apc = [];
private _tanks = [];
private _helis = ["B_Heli_Light_01_F","I_Heli_light_03_unarmed_F"];
private _uav = ["O_UAV_01_F"];
private _trucks = ["O_G_Van_01_transport_F"];

if (_hasApex) then {
	_lightArmedVehicles append ["I_C_Offroad_02_AT_F", "I_C_Offroad_02_LMG_F", "O_G_Offroad_01_AT_F", "O_G_Offroad_01_armed_F"];
	_lightUnarmedVehicles append ["I_C_Offroad_02_unarmed_F","B_G_Offroad_01_F"];
} else {
	_lightArmedVehicles append ["O_G_Offroad_01_AT_F", "O_G_Offroad_01_armed_F"];
	_lightUnarmedVehicles pushBack "I_G_Offroad_01_F";
};

if (_hasWs) then {
	_lightArmedVehicles append ["O_G_Offroad_01_armor_AT_lxWS", "O_G_Offroad_01_armor_armed_lxWS"];
	_lightUnarmedVehicles pushBack "O_G_Offroad_01_armor_base_lxWS";
	_apc append ["O_SFIA_APC_Wheeled_02_hmg_lxWS","O_SFIA_APC_Wheeled_02_unarmed_lxWS"];
    _uav append ["O_UAV_02_lxWS","O_Tura_UAV_02_IED_lxWS"];
};

if (_hasLawsOfWar) then {
	_trucks append ["O_G_Van_02_transport_F", "O_G_Van_02_vehicle_F"];
    _uav append ["O_UAV_06_F","O_UAV_06_medical_F","C_IDAP_UAV_06_antimine_F"];
};

if (_hasTanks) then {
	_tanks pushBack "I_LT_01_cannon_F";
};

private _staticLowWeapons = ["O_G_HMG_02_F"];
private _staticAT = ["O_static_AT_F"];
private _staticMortars = ["O_Mortar_01_F"];

if (_hasGM) then {
	_staticLowWeapons append ["gm_dk_army_mg3_aatripod", "gm_gc_army_dshkm_aatripod"];
	_staticAT append ["gm_ge_army_milan_launcher_tripod", "gm_gc_army_fagot_launcher_tripod", "gm_gc_army_spg9_tripod"];
	_lightArmedVehicles append ["gm_pl_army_uaz469_dshkm","gm_ge_army_iltis_mg3","gm_gc_army_uaz469_spg9_noinsignia","gm_ge_army_iltis_milan"];
	_lightUnarmedVehicles append  ["gm_gc_army_brdm2um_noinsignia","gm_ge_army_iltis_cargo","gm_pl_army_uaz469_cargo","gm_dk_army_u1300l_container","gm_dk_army_typ247_cargo","gm_dk_army_typ253_cargo","gm_gc_army_p601_noinsignia","gm_pl_army_ural4320_cargo","gm_ge_army_kat1_451_container"];
	_tanks append ["gm_gc_army_bmp1sp2_noinsignia","gm_gc_army_pt76b_noinsignia","gm_gc_army_t55_noinsignia","gm_gc_army_t55a_noinsignia","gm_gc_army_t55ak_noinsignia","gm_gc_army_t55am2_noinsignia","gm_gc_army_t55am2b_noinsignia","gm_ge_army_Leopard1a1_noinsignia","gm_ge_army_Leopard1a1a2_noinsignia","gm_ge_army_Leopard1a3_noinsignia","gm_ge_army_Leopard1a3a1_noinsignia","gm_ge_army_Leopard1a5_noinsignia"];
	_helis append ["gm_ge_army_bo105p_pah1_noinsignia","gm_ge_army_bo105m_vbh_noinsignia","gm_ge_army_bo105p1m_vbh_noinsignia","gm_ge_army_bo105p1m_vbh_swooper_noinsignia",
	"gm_pl_airforce_mi2t","gm_pl_airforce_mi2urn","gm_pl_airforce_mi2us","gm_gc_airforce_mi2p_noinsignia","gm_gc_airforce_mi2t_noinsignia","gm_gc_airforce_mi2urn_noinsignia","gm_gc_airforce_mi2us_noinsignia","gm_pl_airforce_mi2urp_noinsignia","gm_pl_airforce_mi2urs_noinsignia"];
	_apc append ["gm_dk_army_m113a1dk_apc_noinsignia","gm_dk_army_m113a1dk_command_noinsignia","gm_dk_army_m113a1dk_engineer_noinsignia","gm_dk_army_m113a1dk_medic_noinsignia","gm_dk_army_m113a2dk_noinsignia","gm_ge_army_m113a1g_apc_noinsignia","gm_ge_army_m113a1g_apc_milan_noinsignia","gm_ge_army_m113a1g_command_noinsignia",
	"gm_ge_army_m113a1g_medic_noinsignia","gm_ge_army_luchsa1_noinsignia","gm_ge_army_luchsa2_noinsignia","gm_ge_army_marder1a1plus_noinsignia",
	"gm_ge_army_marder1a1a_noinsignia","gm_ge_army_marder1a2_noinsignia","gm_ge_army_fuchsa0_command_noinsignia",
	"gm_ge_army_fuchsa0_engineer_noinsignia","gm_ge_army_fuchsa0_reconnaissance_noinsignia","gm_gc_army_brdm2_noinsignia","gm_gc_army_btr60pa_noinsignia","gm_gc_army_btr60pa_dshkm_noinsignia","gm_gc_army_btr60pb_noinsignia","gm_gc_army_btr60pu12_noinsignia","gm_pl_army_ot64a_noinsignia"];
	_trucks append ["gm_gc_army_ural375d_cargo_noinsignia","gm_gc_army_ural4320_cargo_noinsignia","gm_dk_army_typ247_cargo","gm_dk_army_u1300l_container","gm_ge_army_kat1_454_cargo","gm_ge_army_u1300l_container","gm_ge_army_kat1_451_cargo","gm_ge_army_u1300l_cargo"];
};

if (_hasRF) then {
	_lightArmedVehicles append ["a3a_black_Pickup_mmg_rf", "a3u_black_Pickup_mmg_frame_rf", "a3u_black_Pickup_mmg_alt_rf"];
	_lightUnarmedVehicles pushBack "a3u_black_Pickup_rival_rf";
};

if (_hasCSLA) then {
	_staticLowWeapons append ["AFMC_infFALf", "AFMC_M2l","CSLA_UK59L_Stat","CSLA_UK59T_Stat"];
	_staticAT append ["AFMC_TOW_Stat", "CSLA_rT21","CSLA_9K113_Stat"];
	_staticMortars append ["US85_M252_Stat","CSLA_M52_Stat"];
	_lightArmedVehicles append ["US85_M1025_M2","US85_M1025_M60","US85_M1043_M2","US85_M1043_M60","US85_M998SFGT","FIA_AZU_DSKM_noinsignia","FIA_AZU_T21_noinsignia"];
	_lightUnarmedVehicles append  ["US85_M1008c","US85_M1008","US85_M1025_ua","US85_M1043_ua","FIA_AZU_para_noinsignia","CSLA_AZU_R2_noinsignia","CSLA_AZU_noinsignia"];
	_tanks append ["US85_M1A1","US85_M1IP","CSLA_T72_noinsignia","CSLA_T72M_noinsignia","CSLA_T72M1_noinsignia"];
	_helis append ["US85_MH60M134","US85_UH60M240","CSLA_Mi17_noinsignia","CSLA_Mi17mg_noinsignia"];
	_apc append ["AFMC_LAV25","AFMC_M113A1","AFMC_M113A2ext","CSLA_BVP1_noinsignia","CSLA_MU90_noinsignia","CSLA_OT62_noinsignia","CSLA_OT64C_noinsignia","CSLA_OT65A_noinsignia","FIA_BTR40_noinsignia","FIA_BTR40_DSKM_noinsignia"];
};

if (_hasSOG) then {
	_staticLowWeapons append ["vn_b_army_static_m2_scoped_high","vn_o_pl_static_mg42_high","vn_o_kr_static_sgm_high_01","vn_o_kr_static_m1910_high_01","vn_i_fank_70_static_rpd_high","vn_i_fank_71_static_m60_high","vn_i_fank_71_static_m2_high","vn_i_fank_71_static_m1919a4_high",
    "vn_i_fank_70_static_dshkm_high_01","vn_i_fank_70_static_dp28_high","vn_i_static_m1919a4_high","vn_i_static_m2_high","vn_i_static_m60_high","vn_i_fank_70_static_dshkm_high_02","vn_i_fank_70_static_sgm_high_01"];
	_staticAT append ["vn_o_pl_static_d44","vn_o_pl_static_at3","vn_i_fank_70_static_type56rr","vn_i_fank_71_static_m40a1rr","vn_i_static_tow","vn_i_static_m101_01"];
	_staticMortars append ["vn_b_aus_army_static_mortar_m2","vn_b_aus_army_static_mortar_m29","vn_o_kr_static_mortar_type53","vn_o_kr_static_mortar_type63"];
	_lightArmedVehicles append ["vn_b_wheeled_m151_mg_03_noinsignia","vn_b_wheeled_m151_mg_02_noinsignia","vn_b_wheeled_m151_mg_04_noinsignia","vn_o_wheeled_btr40_mg_02_noinsignia",
	"vn_o_wheeled_btr40_mg_01_noinsignia","vn_o_wheeled_btr40_mg_04_noinsignia","vn_b_wheeled_lr2a_mg_02_aus_army_noinsignia","vn_b_wheeled_lr2a_mg_01_aus_army_noinsignia","vn_o_car_04_mg_01_kr","vn_o_wheeled_z157_mg_01_nvam"];
	_lightUnarmedVehicles append  ["vn_b_wheeled_lr2a_02_aus_army","vn_b_wheeled_lr2a_01_aus_army","vn_b_wheeled_m151_01_aus_army","vn_b_wheeled_m151_02_aus_army","vn_o_wheeled_btr40_01_noinsignia"];
	_tanks append ["vn_o_armor_type63_01_noinsignia","vn_o_armor_t54b_01_nva65_noinsignia","vn_o_armor_pt76b_01_nva65_noinsignia","vn_o_armor_ot54_01_nva65_noinsignia","vn_o_armor_pt76a_01_pl_noinsignia","vn_b_armor_m41_01_01_noinsignia","vn_b_armor_m48_01_01_noinsignia","vn_b_armor_m67_01_01_noinsignia"];
	_helis append ["vn_b_air_uh1b_01_09","vn_b_air_uh1d_04_09","vn_o_air_mi2_02_02_noinsignia","vn_o_air_mi2_03_05_noinsignia","vn_o_air_mi2_01_02_noinsignia","vn_o_air_mi2_01_01_noinsignia","vn_b_air_uh1f_01_03_noinsignia","vn_b_air_oh6a_01_noinsignia","vn_b_air_uh1b_01_02_noinsignia","vn_b_air_uh1c_07_02_noinsignia",
	"vn_b_air_ch34_04_03_noinsignia","vn_b_air_ch34_04_01_noinsignia","vn_b_air_ch34_04_04_noinsignia","vn_b_air_ch34_04_02_noinsignia","vn_o_air_mi2_03_03_noinsignia","vn_o_air_mi2_03_05_noinsignia","vn_o_air_mi2_04_03_noinsignia",
	"vn_o_air_mi2_04_01_noinsignia","vn_o_air_mi2_04_05_noinsignia","vn_b_air_uh1b_02_05_noinsignia","vn_b_air_oh6a_02_noinsignia","vn_b_air_oh6a_03_noinsignia","vn_b_air_oh6a_07_noinsignia","vn_b_air_uh1d_03_01_noinsignia","vn_b_air_oh6a_06_noinsignia","vn_b_air_oh6a_05_noinsignia","vn_b_air_oh6a_04_noinsignia"
    ,"vn_o_air_mi2_05_03_noinsignia","vn_o_air_mi2_05_01_noinsignia","vn_o_air_mi2_05_05_noinsignia","vn_b_air_uh1c_03_01_noinsignia","vn_b_air_uh1c_01_02_noinsignia","vn_b_air_uh1c_05_01_noinsignia","vn_b_air_uh1c_02_02_noinsignia","vn_b_air_uh1c_04_02_noinsignia",
    "vn_b_air_uh1c_06_01_noinsignia","vn_b_air_ah1g_01_noinsignia","vn_b_air_ach47_04_01_noinsignia","vn_b_air_ach47_03_01_noinsignia","vn_b_air_ach47_05_01_noinsignia","vn_b_air_ach47_01_01_noinsignia","vn_b_air_ach47_02_01_noinsignia"
    ,"vn_i_air_ch47_01_01_noinsignia","vn_i_air_ch34_02_02","vn_i_air_ch34_01_02_noinsignia","vn_i_air_ch34_02_01_noinsignia","vn_b_air_ch34_01_01_noinsignia","vn_b_air_ch34_03_01_noinsignia","vn_b_air_ch47_04_01_noinsignia","vn_b_air_uh1d_02_01_noinsignia"
	];
	_apc append ["vn_i_armor_m132_01_noinsignia","vn_o_armor_btr50pk_01_nva65_noinsignia","vn_b_armor_m113_01_aus_army_noinsignia","vn_b_armor_m113_acav_04_noinsignia","vn_b_armor_m113_acav_02_noinsignia","vn_b_armor_m113_acav_01_noinsignia","vn_b_armor_m113_acav_06_noinsignia",
    "vn_b_armor_m113_acav_03_noinsignia","vn_b_armor_m113_acav_05_noinsignia","vn_b_armor_m113_01_noinsignia"];
	_trucks append ["vn_i_wheeled_m54_01_marines","vn_i_wheeled_m54_02_marines"];
};

if (_hasSPE) then {
	_staticLowWeapons append ["SPE_ST_MG34_Lafette_Deployed","SPE_ST_MG42_Lafette_Deployed","SPE_GER_SearchLight","SPE_FR_M1919A6_Bipod","SPE_FR_M1919_M2_Trench_Deployed"];
	_staticAT append ["SPE_ST_FlaK_36","SPE_ST_Pak40","SPE_ST_leFH18_AT","SPE_FR_57mm_M1"];
	_staticMortars append ["SPE_M1_81","SPE_GrW278_1"];
	//_lightArmedVehicles append [];
	//_lightUnarmedVehicles append  [];
	_tanks append ["SPE_PzKpfwIII_J_noinsignia","SPE_PzKpfwIII_L_noinsignia","SPE_PzKpfwIII_M_noinsignia","SPE_PzKpfwIII_N_noinsignia","SPE_PzKpfwIV_G_noinsignia","SPE_ST_PzKpfwVI_H1","SPE_FR_M10_noinsignia",
	"SPE_FR_M4A0_75_Early_noinsignia","SPE_FR_M4A0_75_mid_noinsignia","SPE_FR_M4A1_76_noinsignia","SPE_FR_M4A1_75_noinsignia","SPE_M18_Hellcat_noinsignia","SPE_M4A1_T34_Calliope_Direct_noinsignia"];
	_apc append ["SPE_FFI_SdKfz250_1_noinsignia","SPE_FR_M3_Halftrack_noinsignia"];
	_trucks append ["SPE_FR_M3_Halftrack_Unarmed_Open_noinsignia","SPE_FR_M3_Halftrack_Unarmed_noinsignia"];
};

["mortarMagazineHE", "8Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["handGrenadeAmmo", ["GrenadeHand"]] call _fnc_saveToTemplate;
["mortarAmmo", ["Sh_82mm_AMOS"]] call _fnc_saveToTemplate;

["minefieldAT", ["ATMine"]] call _fnc_saveToTemplate;
["minefieldAPERS", ["APERSMine", "APERSBoundingMine"]] call _fnc_saveToTemplate;

["staticLowWeapons", _staticLowWeapons] call _fnc_saveToTemplate;
["staticAT", _staticAT] call _fnc_saveToTemplate;
["staticMortars", _staticMortars] call _fnc_saveToTemplate;
["vehiclesRivalsLightArmed", _lightArmedVehicles] call _fnc_saveToTemplate;
["vehiclesRivalsTrucks", _trucks] call _fnc_saveToTemplate;
["vehiclesRivalsCars", _lightUnarmedVehicles] call _fnc_saveToTemplate;
["vehiclesRivalsAPCs", _apc] call _fnc_saveToTemplate;
["vehiclesRivalsTanks", _tanks] call _fnc_saveToTemplate;
["vehiclesRivalsHelis", _helis] call _fnc_saveToTemplate;			
["vehiclesRivalsUavs", _uav] call _fnc_saveToTemplate;			

["animations", [
    ["O_SFIA_APC_Wheeled_02_hmg_lxWS", ["mg_hide_armor_front",0.3,"mg_hide_armor_rear",0.3,"mg_Hide_Rail",0.3,"showBags",0.3,"showCanisters",0.3,"showTools",0.3,"showCamonetHull",0.3,"showSLATHull",0.3]],
    ["O_SFIA_APC_Wheeled_02_unarmed_lxWS", ["showBags",0.3,"showCanisters",0.3,"showTools",0.3,"showCamonetHull",0.3,"showSLATHull",0.3]],
    ["I_LT_01_cannon_F", ["showTools",0.3,"showCamonetHull",0.3,"showBags",0.3,"showSLATHull",0.3]],
	["gm_dk_army_m113a1dk_command_noinsignia", ["antennaMast_01_unhide",0.3,"antennamast_01_elev_trigger",0.3,"generator_01_unhide",0.3,"storageBox_01_unhide",0.3,"IceCleats_01_unhide",0.3,"IceCleats_02_unhide",0.3,"SupportPoles_01_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_dk_army_m113a2dk_noinsignia", ["camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3]],
    ["gm_dk_army_Leopard1a3_noinsignia", ["CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_03_unhide",0.3,"sideskirt_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3]],
    ["gm_dk_army_m113a1dk_medic_noinsignia", ["IceCleats_02_unhide",0.3,"SupportPoles_01_unhide",0.3,"storageBox_01_unhide",0.3,"generator_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_dk_army_m113a1dk_apc_noinsignia",["MachineGunTurret_01_addonarmor_01_unhide",0.3,"MachineGunTurret_01_addonarmor_02_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"ammo_01_unhide",0.3,"ammo_02_unhide",0.3,"ammo_03_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_dk_army_m113a1dk_engineer_noinsignia", ["ladder_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"Tarp_01_unhide",0.3,"ammo_01_unhide",0,"ammo_02_unhide",0.3,"ammo_03_unhide",0.3,"MachineGunTurret_01_addonarmor_01_unhide",0.3,"MachineGunTurret_01_addonarmor_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_dk_army_m109_noinsignia",["CamoNet_01_unhide",0.3,"ammo_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3]],
    ["gm_dk_army_bpz2a0_noinsignia", ["beacon_01_org_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_dk_army_bibera0_noinsignia", ["beacon_01_org_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_m113a1g_apc_noinsignia", ["IceCleats_01_unhide",0.3,"IceCleats_02_unhide",0.3,"SupportPoles_01_unhide",0.3,"storageBox_01_unhide",0.3,"CamoNet_02_unhide",0.3,"generator_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_m113a1g_apc_milan_noinsignia", ["IceCleats_01_unhide",0.3,"IceCleats_02_unhide",0.3,"SupportPoles_01_unhide",0.3,"storageBox_01_unhide",0.3,"CamoNet_02_unhide",0.3,"generator_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_m113a1g_command_noinsignia",["antennaMast_01_unhide",0.3,"antennamast_01_elev_trigger",0.3,"generator_01_unhide",0.3,"storageBox_01_unhide",0.3,"IceCleats_01_unhide",0.3,"IceCleats_02_unhide",0.3,"SupportPoles_01_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_m113a1g_medic_noinsignia",["IceCleats_01_unhide",0.3,"IceCleats_02_unhide",0.3,"SupportPoles_01_unhide",0.3,"storageBox_01_unhide",0.3,"CamoNet_02_unhide",0.3,"generator_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_03_unhide",0.3,"Tarp_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_luchsa1_noinsignia",["CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"beacon_01_org_unhide",0,"beacon_01_blu_unhide",0,"radio_03_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3]],
    ["gm_ge_army_luchsa2_noinsignia",["radio_03_unhide",0.3,"SignsExtraWide_unhide",0.3,"TurretBox_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"beacon_01_org_unhide",0,"beacon_01_blu_unhide",0,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3]],
    ["gm_ge_army_marder1a1plus_noinsignia",["beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"CamoNet_01_unhide",0.3,"supply_01_unhide",0.3,"supply_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3]],
    ["gm_ge_army_marder1a1a_noinsignia", ["beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"CamoNet_01_unhide",0.3,"supply_01_unhide",0.3,"supply_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3]],
    ["gm_ge_army_marder1a2_noinsignia", ["beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"CamoNet_01_unhide",0.3,"supply_01_unhide",0.3,"supply_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3]],
    ["gm_ge_army_fuchsa0_command_noinsignia", ["radio_04_unhide",0.3,"antennamast_01_elev_trigger",0.3,"beacon_01_org_unhide",0.3,"beacon_01_blu_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_rack_unhide",0.3,"StowingBox_01_unhide",0.3,"SignsExtraWide_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_fuchsa0_engineer_noinsignia", ["ringbuoy_01_unhide",0.3,"beacon_01_org_unhide",0,"beacon_01_blu_unhide",0,"CamoNet_01_unhide",0.3,"CamoNet_02_rack_unhide",0.3,"SignsExtraWide_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_fuchsa0_reconnaissance_noinsignia", ["beacon_01_org_unhide",0,"beacon_01_blu_unhide",0,"CamoNet_01_unhide",0.3,"CamoNet_02_rack_unhide",0.3,"StowingBox_01_unhide",0.3,"SignsExtraWide_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_ge_army_ch53gs_noinsignia", ["fueltank_1_1_unhide",0.3]],
    ["gm_ge_army_bo105m_vbh_noinsignia", ["door_1_1_unhide",0.3,"door_1_2_unhide",0.3,"door_2_1_unhide",0.3,"door_2_2_unhide",0.3]],
    ["gm_ge_army_bo105p1m_vbh_noinsignia", ["door_1_1_unhide",0.3,"door_1_2_unhide",0.3,"door_2_1_unhide",0.3,"door_2_2_unhide",0.3]],
    ["gm_ge_army_bo105p1m_vbh_swooper_noinsignia", ["swooperRopes_unhide",0.3,"door_2_1_unhide",0.3,"door_2_2_unhide",0.3,"door_1_1_unhide",0.3,"door_1_2_unhide",0.3]],
    ["gm_ge_army_Leopard1a1_noinsignia", ["CamoNet_01_unhide",0.3,"CamoNet_04_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_03_unhide",0.3,"SpareWheel_01_unhide",0.3,"SpareWheel_02_unhide",0.3,"SpareWheel_03_unhide",0.3,"SpareWheel_04_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3]],
    ["gm_ge_army_Leopard1a1a2_noinsignia", ["CamoNet_01_unhide",0.3,"CamoNet_04_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_05_unhide",0.3,"CamoNet_03_unhide",0.3,"SpareWheel_01_unhide",0.3,"SpareWheel_02_unhide",0.3,"SpareWheel_03_unhide",0.3,"SpareWheel_04_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3]],
    ["gm_ge_army_Leopard1a3a1_noinsignia",["CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_03_unhide",0.3,"beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3]],
    ["gm_ge_army_Leopard1a5_noinsignia", ["CamoNet_01_unhide",0.3,"CamoNet_04_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_05_unhide",0.3,"CamoNet_03_unhide",0.3,"SpareWheel_01_unhide",0.3,"SpareWheel_02_unhide",0.3,"SpareWheel_03_unhide",0.3,"SpareWheel_04_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"beacon_01_org_unhide",0,"sideskirt_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3]],
    ["gm_gc_army_bmp1sp2_noinsignia", ["spareTracks_1_1_unhide",0.3,"spareTracks_1_2_unhide",0.3,"spareTracks_2_1_unhide",0.3,"wheelChock_1_1_unhide",0.3,"wheelChock_1_2_unhide",0.3,"woodenBeam_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"CamoNet_03_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"AmmoBox_04_unhide",0.3,"AmmoBox_05_unhide",0.3,"AmmoBox_06_unhide",0.3,"AmmoBox_07_unhide",0.3,"AmmoBox_08_unhide",0.3,"AmmoBox_09_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3]],
    ["gm_gc_army_brdm2_noinsignia",["ConvoyLights_01_unhide",0.3,"FrontLight_02_Cover_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"SpareWheel_01_unhide",0.3,"SpareWheel_02_unhide",0.3,"CamoNet_01_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3]],
    ["gm_gc_army_brdm2um_noinsignia",["ConvoyLights_01_unhide",0.3,"FrontLight_02_Cover_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanisterHolder_01_unhide",0.3,"FuelCanisterHolder_02_unhide",0.3,"CamoNet_01_unhide",0.3,"SpareWheel_01_unhide",0.3,"SpareWheel_02_unhide",0.3,"generator_01_unhide",0.3,"AmmoBox_03_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3]],
    ["gm_gc_army_btr60pa_noinsignia",["ConvoyLights_01_unhide",0.3,"FrontLight_02_Cover_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"AmmoBox_04_unhide",0.3,"AmmoBox_05_unhide",0.3,"AmmoBox_06_unhide",0.3,"AmmoBox_07_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"FuelCanister_04_unhide",0.3,"FuelCanister_05_unhide",0.3,"FuelCanister_06_unhide",0.3,"Barrel_01_unhide",0.3,"SpareWheel_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3]],
    ["gm_gc_army_btr60pa_dshkm_noinsignia",["ConvoyLights_01_unhide",0.3,"FrontLight_02_Cover_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"AmmoBox_04_unhide",0.3,"AmmoBox_05_unhide",0.3,"AmmoBox_06_unhide",0.3,"AmmoBox_07_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"FuelCanister_04_unhide",0.3,"FuelCanister_05_unhide",0.3,"FuelCanister_06_unhide",0.3,"Barrel_01_unhide",0.3,"SpareWheel_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3]],
    ["gm_gc_army_btr60pb_noinsignia", ["ConvoyLights_01_unhide",0.3,"FrontLight_01_Cover_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"AmmoBox_04_unhide",0.3,"AmmoBox_05_unhide",0.3,"AmmoBox_06_unhide",0.3,"AmmoBox_07_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"FuelCanister_04_unhide",0.3,"FuelCanister_05_unhide",0.3,"Barrel_01_unhide",0.3,"SpareWheel_01_unhide",0.3,"SpareWheel_02_unhide",0.3,"SpareWheel_03_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"FrontLight_02_Cover_unhide",0.3]],
    ["gm_gc_army_btr60pu12_noinsignia",["ConvoyLights_01_unhide",0.3,"antennamast_01_elev_trigger",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"AmmoBox_04_unhide",0.3,"AmmoBox_05_unhide",0.3,"AmmoBox_06_unhide",0.3,"AmmoBox_07_unhide",0.3,"FuelCanister_01_unhide",0.3,"FuelCanister_02_unhide",0.3,"FuelCanister_03_unhide",0.3,"FuelCanister_04_unhide",0.3,"FuelCanister_05_unhide",0.3,"Barrel_01_unhide",0.3,"SpareWheel_03_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"FrontLight_02_Cover_unhide",0.3]],
    ["gm_pl_army_uaz469_cargo", ["ConvoyLights_01_unhide",0.3,"FrontLight_01_Cover_unhide",0.3,"windshield",0.3,"windows_unhide",0.3,"cover_hoops_unhide",0.3,"spare_wheel_unhide",0.3,"antenna_01_unhide",0.3,"antenna_02_unhide",0.3,"FogLights_01_unhide",0.3,"mirrors_01_unhide",0.3,"doors_unhide",0.3]],
    ["gm_pl_army_uaz469_dshkm", ["ConvoyLights_01_unhide",0.3,"FrontLight_01_Cover_unhide",0.3,"windows_unhide",0.3,"mirrors_01_unhide",0.3,"windshield",0.3,"spare_wheel_unhide",0.3,"antenna_01_unhide",0.3,"antenna_02_unhide",0.3,"FogLights_01_unhide",0.3,"doors_unhide",0.3]],
    ["gm_gc_army_uaz469_spg9_noinsignia", ["ConvoyLights_01_unhide",0.3,"FrontLight_01_Cover_unhide",0.3,"windshield",0.3,"windows_unhide",0.3,"mirrors_01_unhide",0.3,"spare_wheel_unhide",0.3,"antenna_01_unhide",0.3,"antenna_02_unhide",0.3,"FogLights_01_unhide",0.3,"doors_unhide",0.3]],
    ["gm_gc_airforce_mi2p_noinsignia", ["cablecutter_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1,"winch_unhide",0.3,"fueltank_left_unhide",0.3,"fueltank_right_unhide",0.3]],
    ["gm_gc_airforce_mi2t_noinsignia", ["cablecutter_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1,"winch_unhide",0.3,"fueltank_left_unhide",0.3,"fueltank_right_unhide",0.3]],
    ["gm_gc_airforce_mi2urn_noinsignia", ["cablecutter_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1,"winch_unhide",0.3,"fueltank_left_unhide",0.3,"fueltank_right_unhide",0.3]],
    ["gm_gc_airforce_mi2us_noinsignia", ["cablecutter_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1,"winch_unhide",0.3,"fueltank_left_unhide",0.3,"fueltank_right_unhide",0.3]],
    ["gm_gc_army_pt76b_noinsignia", ["ConvoyLights_01_unhide",0.3,"CamoNet_01_unhide",0.3,"CamoNet_02_unhide",0.3,"AmmoBox_01_unhide",0.3,"AmmoBox_02_unhide",0.3,"AmmoBox_03_unhide",0.3,"FuelTank_01_unhide",0.3,"FuelTank_02_unhide",0.3,"FuelTank_03_unhide",0.3,"FuelTank_04_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"FrontLight_02_Cover_unhide",0.3]],
    ["gm_gc_army_t55_noinsignia", ["ConvoyLights_01_unhide",0.3,"MainTurret_SearchLight_cover_unhide",0.3,"MainTurret_Optic_cover_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"buoy_01_unhide",0.3,"camoNet_01_unhide",0.3,"camoNet_02_unhide",0.3,"turretBox_01_unhide",0.3,"turretBox_02_unhide",0.3,"fender_01_unhide",0.3,"fender_02_unhide",0.3,"woodenBeam_01_unhide",0.3,"snorkel_01_unhide",0.3,"snorkel_02_unhide",0.3,"rearbar_01_unhide",0.3,"barrelHolder_01_unhide",0.3,"barrel_01_unhide",0.3,"barrel_02_unhide",0.3,"wheelChock_01_unhide",0.3,"storageBox_01_unhide",0.3,"storageBox_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3,"FormationLight_01_unhide",0.3]],
    ["gm_gc_army_t55a_noinsignia", ["ConvoyLights_01_unhide",0.3,"turretBox_01_unhide",0.3,"turretBox_02_unhide",0.3,"MainTurret_SearchLight_cover_unhide",0.3,"MainTurret_Optic_cover_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"buoy_01_unhide",0.3,"camoNet_01_unhide",0.3,"camoNet_02_unhide",0.3,"fender_01_unhide",0.3,"fender_02_unhide",0.3,"woodenBeam_01_unhide",0.3,"snorkel_01_unhide",0.3,"snorkel_02_unhide",0.3,"rearbar_01_unhide",0.3,"barrelHolder_01_unhide",0.3,"barrel_01_unhide",0.3,"barrel_02_unhide",0.3,"wheelChock_01_unhide",0.3,"storageBox_01_unhide",0.3,"storageBox_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3,"FormationLight_01_unhide",0.3]],
    ["gm_gc_army_t55ak_noinsignia",["ConvoyLights_01_unhide",0.3,"antennamast_01_elev_trigger",0.3,"antennaMast_01_unhide",0.3,"turretBox_01_unhide",0.3,"turretBox_02_unhide",0.3,"MainTurret_SearchLight_cover_unhide",0.3,"MainTurret_Optic_cover_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"buoy_01_unhide",0.3,"camoNet_01_unhide",0.3,"camoNet_02_unhide",0.3,"fender_01_unhide",0.3,"fender_02_unhide",0.3,"woodenBeam_01_unhide",0.3,"snorkel_01_unhide",0.3,"snorkel_02_unhide",0.3,"rearbar_01_unhide",0.3,"barrelHolder_01_unhide",0.3,"barrel_01_unhide",0.3,"barrel_02_unhide",0.3,"wheelChock_01_unhide",0.3,"storageBox_01_unhide",0.3,"storageBox_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3,"FormationLight_01_unhide",0.3]],
    ["gm_gc_army_t55am2_noinsignia",["ConvoyLights_01_unhide",0.3,"turretBox_03_unhide",0.3,"turretBox_01_unhide",0.3,"turretBox_02_unhide",0.3,"MainTurret_SearchLight_cover_unhide",0.3,"MainTurret_Optic_cover_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"buoy_01_unhide",0.3,"camoNet_01_unhide",0.3,"snorkel_02_unhide",0.3,"rearbar_01_unhide",0.3,"barrelHolder_01_unhide",0.3,"barrel_01_unhide",0.3,"barrel_02_unhide",0.3,"wheelChock_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3,"FormationLight_01_unhide",0.3]],
    ["gm_gc_army_t55am2b_noinsignia", ["ConvoyLights_01_unhide",0.3,"turretBox_03_unhide",0.3,"turretBox_01_unhide",0.3,"turretBox_02_unhide",0.3,"MainTurret_SearchLight_cover_unhide",0.3,"MainTurret_Optic_cover_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"buoy_01_unhide",0.3,"camoNet_01_unhide",0.3,"snorkel_02_unhide",0.3,"rearbar_01_unhide",0.3,"barrelHolder_01_unhide",0.3,"barrel_01_unhide",0.3,"barrel_02_unhide",0.3,"wheelChock_01_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3,"FormationLight_01_unhide",0.3]],
    ["gm_gc_bgs_mi2p_noinsignia", ["cablecutter_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1,"winch_unhide",0.3,"fueltank_left_unhide",0.3,"fueltank_right_unhide",0.3]],
    ["gm_gc_bgs_mi2us_noinsignia", ["cablecutter_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1,"winch_unhide",0.3,"fueltank_left_unhide",0.3,"fueltank_right_unhide",0.3]],
    ["gm_pl_army_ot64a_noinsignia", ["RoadPrioritySign_01_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3]],
    ["gm_pl_army_t55ak_noinsignia", ["RoadPrioritySign_01_unhide",0.3,"antennamast_01_elev_trigger",0.3,"antennaMast_01_unhide",0.3,"turretBox_01_unhide",0.3,"turretBox_02_unhide",0.3,"MainTurret_SearchLight_cover_unhide",0.3,"MainTurret_Optic_cover_unhide",0.3,"CommanderTurret_SearchLight_cover_unhide",0.3,"buoy_01_unhide",0.3,"camoNet_01_unhide",0.3,"camoNet_02_unhide",0.3,"fender_01_unhide",0.3,"fender_02_unhide",0.3,"woodenBeam_01_unhide",0.3,"snorkel_01_unhide",0.3,"snorkel_02_unhide",0.3,"rearbar_01_unhide",0.3,"barrelHolder_01_unhide",0.3,"barrel_01_unhide",0.3,"barrel_02_unhide",0.3,"wheelChock_01_unhide",0.3,"storageBox_01_unhide",0.3,"storageBox_02_unhide",0.3,"camonet_hull_unhide",0.3,"camofoilage_hull_unhide",0.3,"camonet_MainTurret_trav_unhide",0.3,"camofoilage_MainTurret_trav_unhide",0.3,"camonet_MainTurret_elev_unhide",0.3,"FormationLight_01_unhide",0.3]],
    ["gm_pl_airforce_mi2urs_noinsignia", ["cablecutter_unhide",0.3,"camera_front_unhide",0.3,"camera_rear_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1]],
    ["gm_pl_airforce_mi2urp_noinsignia", ["cablecutter_unhide",0.3,"camera_front_unhide",0.3,"camera_rear_unhide",0.3,"fan_unhide",0.3,"plugs_unhide",0.1,"skids_unhide",0.1]],
	["CSLA_Mi24V_noinsignia", ["addEVU",0.3,"addASO_Tail",0.3,"addASO_Body",0.3]],
    ["CSLA_PLdvK59V3S_noinsignia",["addTools",0.3,"addFuelKanister",0.3]],
    ["CSLA_BVP1_noinsignia", ["addCoverTurret",0.3,"addTools",0.3,"addRope",0.3,"addBar",0.3,"addMudguards",0.3]],
    ["CSLA_BPzV_noinsignia", ["addCoverTurret",0.3,"addTools",0.3,"addRope",0.3,"addBar",0.3,"addMudguards",0.3]],
    ["CSLA_DTP90_noinsignia", ["addTools",0.3,"addRope",0.3,"addBar",0.3,"addMudguards",0.3]],
    ["CSLA_MU90_noinsignia", ["addTools",0.3,"addRope",0.3,"addBar",0.3,"addMudguards",0.3]],
    ["CSLA_OT62_noinsignia", ["addTools",0.3,"addRope",0.3,"addCover",0.3,"addSpareTracks",0.3]],
    ["CSLA_OT64C_noinsignia", ["addTools",0.3,"addRope",0.3,"addTripod",0.3]],
    ["CSLA_OT65A_noinsignia", ["addTools",0.3,"addRope",0.3,"addFuelKanister",0.3]],
    ["CSLA_OZV90_noinsignia", ["addTools",0.3,"addRope",0.3,"addBar",0.3,"addMudguards",0.3]],
    ["CSLA_AZU_noinsignia", ["ADD_canvas",0.3,"ADD_canvas_frame",0.3,"ADD_antenna",0.3,"ADD_sparewheel",0.3,"ADD_fuelcan",0.3,"ADD_frame",0.3,"ADD_light_covers",0.3,"ADD_searchlight",0.3]],
    ["CSLA_AZU_para_noinsignia", ["ADD_antenna",0.3,"ADD_sparewheel",0.3,"ADD_fuelcan",0.3,"ADD_frame",0.3,"ADD_light_covers",0.3,"ADD_searchlight",0.3]],
    ["CSLA_AZU_R2_noinsignia", ["ADD_canvas",0.3,"ADD_canvas_frame",0.3,"ADD_sparewheel",0.3,"ADD_fuelcan",0.3,"ADD_frame",0.3,"ADD_light_covers",0.3,"ADD_searchlight",0.3]],
    ["CSLA_V3SLizard_noinsignia", ["addTools",0.3,"addFuelKanister",0.3]],
    ["CSLA_V3Sa_noinsignia", ["addCanvas",0.3,"addAmmo",1,"addSpareWheel",0.3,"addFuelKanister",0.3]],
    ["CSLA_V3Sf_noinsignia", ["addSpareWheel",0.3,"addFuelKanister",0.3]],
    ["CSLA_V3So_noinsignia", ["addCanvas",0,"addSpareWheel",0.3,"addFuelKanister",0.3]],
    ["CSLA_V3S_noinsignia", ["addCanvas",1,"addSpareWheel",0.3,"addFuelKanister",0.3]],
    ["CSLA_V3Sr_noinsignia", ["addWindowCovers",0.3,"addStowage",0.3,"addTools",0.3,"addSpareWheel",0.3,"addFuelKanister",0.3]],
    ["CSLA_Mi17_noinsignia", ["ADD_winch",0.5]],
    ["CSLA_Mi17mg_noinsignia", ["ADD_winch",0.5]],
    ["CSLA_Mi17pylons_noinsignia", ["ADD_winch",0.5]],
    ["CSLA_T72_noinsignia", ["ADD_antenna",0.3,"ADD_frontMudGuards",0.3,"ADD_trackLinks",0.3,"ADD_fuelDrums",0.3,"ADD_log",0.3,"ADD_R130",0.3,"ADD_nsvMag1",0.3,"ADD_nsvMag2",0.3,"ADD_camoNet",0.3,"ADD_ropeFront",0.3,"ADD_ropeBack",0.3]],
    ["CSLA_T72M_noinsignia", ["ADD_antenna",0.3,"ADD_frontMudGuards",0.3,"ADD_trackLinks",0.3,"ADD_fuelDrums",0.3,"ADD_log",0.3,"ADD_R130",0.3,"ADD_nsvMag1",0.3,"ADD_nsvMag2",0.3,"ADD_camoNet",0.3,"ADD_ropeFront",0.3,"ADD_ropeBack",0.3]],
    ["CSLA_T72M1_noinsignia", ["ADD_antenna",0.3,"ADD_frontMudGuards",0.3,"ADD_trackLinks",0.3,"ADD_fuelDrums",0.3,"ADD_log",0.3,"ADD_R130",0.3,"ADD_nsvMag1",0.3,"ADD_nsvMag2",0.3,"ADD_camoNet",0.3,"ADD_ropeFront",0.3,"ADD_ropeBack",0.3]],
    ["FIA_BTR40_noinsignia", ["ADD_canvas",0.3,"ADD_sparewheel",0.3]],
    ["FIA_BTR40_DSKM_noinsignia",["ADD_sparewheel",0.5]],
    ["US85_M1A1", ["ADD_smallAmmobox",0.3,"ADD_medAmmoBox",0.3,"ADD_topStuff",0.3,"ADD_cardBoardBox",0.3,"ADD_trackLink",0.3,"ADD_spareWheel",0.3,"ADD_frontTowRings",0.3,"ADD_rearTowRings",0.3,"ADD_frontTowBar",0.3,"ADD_rearTowBar",0.3,"ADD_leftTowCable",0.3,"ADD_rightTowCable",0.3,"ADD_alice",0.3,"ADD_fuelCan",0.3,"ADD_camoNet",0.3]],
    ["US85_M1IP", ["ADD_topStuff",0.3,"ADD_cardBoardBox",0.3,"ADD_trackLink",0.3,"ADD_spareWheel",0.3,"ADD_frontTowRings",0.3,"ADD_rearTowRings",0.3,"ADD_frontTowBar",0.3,"ADD_rearTowBar",0.3,"ADD_leftTowCable",0.3,"ADD_rightTowCable",0.3,"ADD_alice",0.3,"ADD_fuelCan",0.3,"ADD_camoNet",0.3]],
    ["AFMC_M113A2ext",["AddBox",0.3,"AddBagsSide",0.3,"AddInt1",0.3,"AddTools",0.3,"AddSpareWheel",0.3,"AddKanister",0.3,"AddTop1",0.3,"AddTop2",0.3,"AddCamonet",0.3,"AddBarbwire",0.3,"AddMetalRope",0.3]],
    ["US85_M163",["AddKanister",0.3,"AddTop1",0.3,"AddTop2",0.3,"AddCamonet",0.3,"AddMetalRope",0.3,"AddTools",0.3,"AddTurret1",0.3]],
    ["US85_LAV25", ["addKanister_body",0.3,"addKanister_turret",0.3,"addBackpacks_turret",0.3,"addAmmo25mm_turret",0.3,"addTools",0.3,"addCamonet",0.3,"addBarbwire",0.3,"addRope",0.3]],
    ["US85_M113_AMB",["AddBagsSide",0.3,"AddInt1",0.3,"AddTools",0.3,"AddKanister",0.3,"AddTop1",0.3,"AddTop2",0.3,"AddCamonet",0.3,"AddBarbwire",0.3,"AddMetalRope",0.3]],
    ["US85_M113_DTP",["AddBagsSide",0.3,"AddInt1",0.3,"AddInt2",0.3,"AddTop2",0.3,"AddSpareWheel",0.3,"AddKanister",0.3,"AddTop1",0.3,"AddCamonet",0.3,"AddBarbwire",0.3,"AddMetalRope",0.3]],
    ["US85_M113", ["AddBox",0.3,"AddBagsSide",0.3,"AddInt1",0.3,"AddTools",0.3,"AddKanister",0.3,"AddTop1",0.3,"AddTop2",0.3,"AddCamonet",0.3,"AddBarbwire",0.3,"AddMetalRope",0.3]],
    ["US85_M1008c", ["addCanvas",0.3,"addCanvasFrame",0.3,"addBenches",0.3,"addRearFrame",0.3,"addFrontFrame",0.3]],
    ["US85_M1008", ["addCanvas",0.3,"addCanvasFrame",0.3,"addBenches",0.3,"addRearFrame",0.3,"addFrontFrame",0.3]],
    ["US85_M1008_S250", ["addFrontFrame",0.5]],
    ["US85_M1025_ua", ["AddBarbwire",0.3,"AddSparewheel",0.3,"AddCamonet",0.3]],
    ["US85_M1025_M2", ["AddBarbwire",0.3,"AddSparewheel",0.3,"AddCamonet",0.3]],
    ["US85_M1025_M60", ["AddBarbwire",0.3,"AddSparewheel",0.3,"AddCamonet",0.3,"AddSandBags",0.3]],
    ["US85_M1043_ua", ["AddBarbwire",0.3,"AddSparewheel",0.3,"AddCamonet",0.3]],
    ["US85_M1043_M2", ["AddBarbwire",0.3,"AddSparewheel",0.3,"AddCamonet",0.3]],
    ["US85_M1043_M60", ["AddBarbwire",0.3,"AddSparewheel",0.3,"AddCamonet",0.3,"AddSandBags",0.3]],
    ["US85_M923a",["ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_reammo",0.3,"ADD_side_benches",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3,"ADD_roof",0.3]],
    ["US85_M923cargo", ["ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_reammo",0,"ADD_repair",0,"ADD_side_benches",0.3,"ADD_explosive",0.3,"ADD_explosive_tailgate",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3,"ADD_roof",0.3]],
    ["US85_M923f",["ADD_spareWheel",0.3,"ADD_fuelcan",0.3,"ADD_roof",0.3]],
    ["US85_M923a1_r", ["ADD_repair",1,"ADD_tarpRoof",0.3,"ADD_roof",0.3,"ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_side_benches",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3]],
    ["US85_M923a1_s280", ["ADD_tarpRoof",0.3,"ADD_roof",0.3,"ADD_s280",0.3,"ADD_s280_ac",0.3,"ADD_s280_panel",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3]],
    ["US85_M923a1o", ["ADD_tarpRoof",0.3,"ADD_roof",0.3,"ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3]],
    ["US85_M923a1om2", ["ADD_ammoBox",0.3,"ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3]],
    ["US85_M923a1c", ["ADD_tarpRoof",0.3,"ADD_roof",0.3,"ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3]],
    ["US85_M923a1cm2", ["ADD_ammoBox",0.3,"ADD_tailgate",0.3,"ADD_canvas",0.3,"ADD_frame",0.3,"ADD_spareWheel",0.3,"ADD_fuelcan",0.3]],
    ["US85_M998SFGT",["AddBarbwire", 0.3,"AddBumper",0.3,"AddBackpacks",0.3,"AddRoofCover",0.3,"AddRearFrame",0.3]],
    ["US85_AH1F",["addAirIntakeCovers",0.3,"addASO_Tail",0.3]],
    ["US85_MH60M134", ["addWinch",0.5]],
    ["US85_MH60FFAR", ["addWinch",0.5]],
    ["US85_UH60", ["addESSS",0.5,"addWinch",0.5]],
    ["US85_UH60M240", ["addWinch",0.5]],
	#include "..\vehicleAnimations\vehicleAnimations_SOG.sqf",
	#include "..\vehicleAnimations\vehicleAnimations_SPE.sqf"
]] call _fnc_saveToTemplate;

["variants", [
    ["I_LT_01_cannon_F", ["Indep_Olive", 1, "Indep_01", 0]]
]] call _fnc_saveToTemplate;

//////////////////////////
//       Loadouts       //
//////////////////////////
private _loadoutData = call _fnc_createLoadoutData;
private _rifles = [
	["arifle_TRG21_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
private _tunedRifles = [
	["arifle_TRG21_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_TRG21_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
private _enforcerRifles = [
	["arifle_TRG21_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
private _carbines = [
	["arifle_TRG20_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""],
	["arifle_Mk20C_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], [], ""]
];
private _gls = [
	["arifle_TRG21_GL_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "UGL_FlareWhite_F", "1Rnd_Smoke_Grenade_shell"], ""],
	["arifle_Mk20_GL_plain_F", "", "", "", ["30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag", "30Rnd_556x45_Stanag_Tracer_Green"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "UGL_FlareWhite_F", "1Rnd_Smoke_Grenade_shell"], ""]
];
private _mgs = [
	["LMG_Zafir_F", "", "", "", ["150Rnd_762x54_Box", "150Rnd_762x54_Box", "150Rnd_762x54_Box_Tracer"], [], ""]
];
private _marksmanRifles = [
	["srifle_EBR_F", "", "", "optic_MRCO", ["20Rnd_762x51_Mag"], [], ""]
];

private _rpgs = [
	["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
	["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
	["launch_RPG32_F", "", "", "", ["RPG32_F", "RPG32_F", "RPG32_HE_F"], [], ""],
	["launch_O_Vorona_green_F", "", "", "", ["Vorona_HEAT", "Vorona_HE"], [], ""]
];

private _pistols = ["hgun_Rook40_F"];

_loadoutData set ["lightHELaunchers", [
["launch_RPG32_F", "", "", "", ["RPG32_HE_F", "RPG32_HE_F"], [], ""]
]];
_loadoutData set ["AALaunchers", [
["launch_O_Titan_F", "", "acc_pointer_IR", "", ["Titan_AA"], [], ""]
]];

_loadoutData set ["ATMines", ["ATMine_Range_Mag"]];
_loadoutData set ["APMines", ["APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag"]];
_loadoutData set ["lightExplosives", ["IEDLandSmall_Remote_Mag"]];
_loadoutData set ["heavyExplosives", ["IEDLandBig_Remote_Mag"]];

_loadoutData set ["antiInfantryGrenades", ["HandGrenade", "MiniGrenade"]];
_loadoutData set ["smokeGrenades", ["SmokeShell"]];
_loadoutData set ["signalsmokeGrenades", ["SmokeShellYellow", "SmokeShellRed", "SmokeShellPurple", "SmokeShellOrange", "SmokeShellGreen", "SmokeShellBlue"]];

if (_hasGM) then {
    (_loadoutData get "antiInfantryGrenades") append [
        "gm_handgrenade_conc_dm51","gm_handgrenade_conc_dm51a1","gm_handgrenade_frag_dm41","gm_handgrenade_frag_dm41a1","gm_handgrenade_frag_dm51","gm_handgrenade_frag_dm51a1","gm_handgrenade_frag_m26",
        "gm_handgrenade_frag_m26a1", "gm_handgrenade_frag_rgd5"
    ];
	(_loadoutData get "smokeGrenades") append [
        "gm_smokeshell_wht_gc",
        "gm_smokeshell_wht_dm25"
    ];
	(_loadoutData get "signalsmokeGrenades") append [
        "gm_smokeshell_blk_gc","gm_smokeshell_blu_gc","gm_smokeshell_grn_gc","gm_smokeshell_org_gc","gm_smokeshell_red_gc","gm_smokeshell_yel_gc","gm_smokeshell_grn_dm21",
        "gm_smokeshell_red_dm23","gm_smokeshell_yel_dm26","gm_smokeshell_org_dm32"
    ];
	(_loadoutData get "lightExplosives") append [
        "gm_explosive_plnp_charge"
    ];
	(_loadoutData get "heavyExplosives") append [
        "gm_explosive_petn_charge"
    ];
	(_loadoutData get "ATMines") append [
        "gm_mine_at_dm21","gm_mine_at_tm46"
    ];
	(_loadoutData get "APMines") append [
        "gm_mine_ap_dm31"
    ];
};

if (_hasCSLA) then {
    (_loadoutData get "antiInfantryGrenades") append [
        "CSLA_F1","CSLA_RG4o","CSLA_RG4u","CSLA_URG86u","CSLA_URG86o"
    ];
	(_loadoutData get "lightExplosives") append [
        "CSLA_TNT0100g"
    ];
	(_loadoutData get "APMines") append [
        "CSLA_F1m_mag","US85_M67m_mag","CSLA_NO2","CSLA_RG4m_mag","CSLA_URG86m_mag","CSLA_PPMiNa_mag"
    ];
	(_loadoutData get "ATMines") append [
        "CSLA_PtMiBa3_mag"
    ];
};

if (_hasRF) then {
	_marksmanRifles pushBack ["srifle_DMR_01_black_RF", "", "acc_flashlight", "optic_VRCO_RF", ["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"], [], ""];
	_rifles pushBack ["arifle_ash12_blk_RF", "", "", "", ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], [], ""];
	_enforcerRifles pushBack ["arifle_ash12_LR_blk_RF", "", "optic_VRCO_RF", "", ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], [], ""];
	_tunedRifles pushBack ["arifle_ash12_LR_blk_RF", "", "", "optic_VRCO_RF", ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], [], ""];
	_gls pushBack ["arifle_ash12_GL_blk_RF", "", "acc_flashlight", "optic_VRCO_khk_RF", ["10Rnd_127x55_Mag_RF", "20Rnd_127x55_Mag_RF"], ["1Rnd_HE_Grenade_shell", "1Rnd_SmokeGreen_Grenade_shell", "UGL_FlareGreen_F"], ""];
	_pistols append ["hgun_Glock19_RF", "hgun_Glock19_auto_RF", "hgun_DEagle_RF", "hgun_Glock19_auto_khk_RF", "hgun_DEagle_classic_RF"];

	if (random 100 <= 45) then {
		_tunedRifles pushBack ["srifle_h6_gold_rf", "muzzle_snds_M", "", "optic_VRCO_RF", ["30Rnd_556x45_AP_Stanag_green_RF"], [], ""];
		_pistols append ["hgun_DEagle_gold_RF"];
	};
};

if (_hasContact) then {
	_carbines pushBack ["arifle_AK12U_F", "", "", "", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""];
	_tunedRifles pushBack ["arifle_AK12U_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""];
	_marksmanRifles = [
		["srifle_DMR_06_hunter_F", "", "", "optic_DMS_weathered_F", ["10Rnd_Mk14_762x51_Mag"], [], ""]
	];
};

if (_hasMarksman) then {
	_tunedRifles pushBack ["srifle_DMR_03_F", "", "acc_flashlight", "optic_MRCO", ["20Rnd_762x51_Mag"], [], "bipod_02_F_blk"]
};

if (_hasApex) then {
	_rifles pushBack ["arifle_AKM_F", "", "", "", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""];
	_tunedRifles append [
		["arifle_AK12_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"],
		["arifle_AK12_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"]
	];
	_carbines pushBack ["arifle_AKS_F", "", "", "", ["30Rnd_545x39_Mag_Green_F", "30Rnd_545x39_Mag_Green_F", "30Rnd_545x39_Mag_Tracer_Green_F"], [], ""];
	_gls pushBack ["arifle_AK12_GL_F", "", "", "", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "UGL_FlareWhite_F", "1Rnd_Smoke_Grenade_shell"], ""];
	_mgs = [
		["LMG_03_F", "", "acc_flashlight", "", ["200Rnd_556x45_Box_Red_F", "200Rnd_556x45_Box_Red_F", "200Rnd_556x45_Box_Tracer_Red_F"], [], ""]
	];
	_rpgs = [
		["launch_RPG7_F", "", "", "", ["RPG7_F", "RPG7_F", "RPG7_F"], [], ""],
		["launch_RPG7_F", "", "", "", ["RPG7_F", "RPG7_F", "RPG7_F"], [], ""],
		["launch_RPG7_F", "", "", "", ["RPG7_F", "RPG7_F", "RPG7_F"], [], ""],
		["launch_O_Vorona_green_F", "", "", "", ["Vorona_HEAT", "Vorona_HE"], [], ""]
	];
	_enforcerRifles pushBack ["arifle_AKM_F", "", "", "", ["75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_Tracer_F"], [], ""];
	_pistols pushBack "hgun_Pistol_01_F";
};

if (_hasWs) then {
	_rifles append [
		["arifle_Galat_lxWS", "", "", "",  ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], ""],
		["arifle_Velko_lxWS", "", "", "",  ["35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_tracer_green_lxWS"], [], ""]
	];
	_tunedRifles append [
		["arifle_AK12_F", "", "acc_flashlight", "optic_MRCO", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"],
		["arifle_AK12_F", "", "acc_flashlight", "optic_ACO_grn", ["30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Green_F", "30Rnd_762x39_Mag_Tracer_Green_F"], [], "bipod_02_F_blk"]
	];
	_carbines append [
		["arifle_VelkoR5_lxWS", "", "saber_light_lxWS", "optic_r1_high_lxWS",  ["35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_tracer_green_lxWS"], [], ""],
		["arifle_SLR_Para_lxWS", "", "saber_light_lxWS", "optic_r1_high_black_sand_lxWS",  ["20Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS"], [], ""],
		["arifle_SLR_Para_snake_lxWS", "", "saber_light_lxWS", "optic_r1_high_black_sand_lxWS",  ["20Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS", "30Rnd_762x51_slr_lxWS"], [], ""]
	];
	_gls append [
		["arifle_VelkoR5_GL_lxWS", "", "", "", ["35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_reload_tracer_green_lxWS", "35Rnd_556x45_Velko_tracer_green_lxWS"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_Pellet_Grenade_shell_lxWS", "UGL_FlareWhite_F", "1Rnd_Smoke_Grenade_shell"], ""],
		["arifle_SLR_GL_lxWS", "", "", "", ["20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_reload_tracer_green_lxWS"], ["1Rnd_40mm_HE_lxWS", "1Rnd_40mm_HE_lxWS", "1Rnd_58mm_AT_lxWS", "1Rnd_50mm_Smoke_lxWS"], ""]
	];
	_mgs pushBack ["LMG_S77_lxWS", "", "acc_pointer_IR", "optic_NVS", ["100Rnd_762x51_S77_Red_lxWS", "100Rnd_762x51_S77_Red_lxWS", "100Rnd_762x51_S77_Red_Tracer_lxWS"], [], ""];
	_marksmanRifles pushBack ["arifle_SLR_lxWS", "", "", "", ["20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_lxWS", "20Rnd_762x51_slr_reload_tracer_green_lxWS"], [], ""];
	_enforcerRifles append [
		["arifle_VelkoR5_lxWS", "", "", "", ["50Rnd_556x45_Velko_reload_tracer_green_lxWS", "50Rnd_556x45_Velko_reload_tracer_green_lxWS", "50Rnd_556x45_Velko_tracer_green_lxWS"], [], ""],
		["arifle_Galat_lxWS", "", "", "", ["75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_F", "75Rnd_762x39_Mag_Tracer_F"], [], ""],
		["sgun_aa40_lxWS", "", "", "", ["20Rnd_12Gauge_AA40_Pellets_lxWS", "20Rnd_12Gauge_AA40_Slug_lxWS", "20Rnd_12Gauge_AA40_HE_lxWS"], [], ""]
	];
	_rpgs append [
		["launch_RPG32_tan_lxWS", "", "", "", ["RPG32_F", "RPG32_F"], [], ""],
		["launch_RPG32_tan_lxWS", "", "", "", ["RPG32_HE_F", "RPG32_HE_F"], [], ""]
	];
};

if (_hasGM) then {
    _rpgs append [
        ["gm_m72a3_oli", "", "", "", ["gm_1Rnd_66mm_heat_m72a3"], [], ""],
        ["gm_rpg18_oli", "", "", "", ["gm_1Rnd_64mm_heat_pg18"], [], ""],
        ["gm_pzf44_2_oli", "", "", "gm_feroz2x17_pzf44_2_blk", ["gm_1Rnd_44x537mm_heat_dm32_pzf44_2", "gm_1Rnd_44x537mm_heat_dm32_pzf44_2"], [], ""]
    ];
    (_loadoutData get "lightHELaunchers") append [
        ["gm_pzf3_blk", "", "", "", ["gm_1Rnd_60mm_heat_dm22_pzf3", "gm_1Rnd_60mm_heat_dm32_pzf3"], [], ""],
        ["gm_pzf84_oli", "", "", "gm_feroz2x17_pzf84_blk", ["gm_1Rnd_84x245mm_heat_t_DM32_carlgustaf","gm_1Rnd_84x245mm_heat_t_DM22_carlgustaf","gm_1Rnd_84x245mm_heat_t_DM12a1_carlgustaf","gm_1Rnd_84x245mm_heat_t_DM12_carlgustaf"], [], ""]
    ];
    (_loadoutData get "AALaunchers") append [
        ["gm_fim43_oli", "", "", "", ["gm_1Rnd_70mm_he_m585_fim43"], [], ""]
    ];
	_gls append [
		["gm_g3a4a1_ris_oli", "", "", "optic_MRCO", ["gm_40Rnd_762x51mm_B_T_DM21_g3_blk","gm_40Rnd_762x51mm_B_T_DM21A1_g3_blk","gm_40Rnd_762x51mm_B_DM111_g3_blk","gm_20Rnd_762x51mm_B_DM41_g3_blk"], ["gm_1rnd_67mm_heat_dm22a1_g3"], ""],
		["gm_akm_pallad_wud", "", "", "gm_zvn64_ak", ["gm_30Rnd_762x39mm_B_57N231_ak47_blk","gm_30Rnd_762x39mm_B_57N231_ak47_blk","gm_30Rnd_762x39mm_B_57N231_ak47_blk"], ["1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell"], ""]
	];
	_rifles append [
		["gm_ak74n_wud", "", "", "",  ["gm_30Rnd_545x39mm_B_7N6_ak74_org", "gm_30Rnd_545x39mm_B_7N6_ak74_org", "gm_30Rnd_545x39mm_B_7N6_ak74_org"], [], ""],
		["gm_akm_wud", "", "", "",  ["gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk"], [], ""],
		["gm_akmn_wud", "", "", "",  ["gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk"], [], ""],
		["gm_akms_wud", "", "", "",  ["gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk"], [], ""],
		["gm_akmsl_wud", "", "", "",  ["gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk"], [], ""],
		["gm_akmsn_wud", "", "", "",  ["gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk", "gm_30Rnd_762x39mm_B_57N231_ak47_blk"], [], ""],
		["gm_hk33a2_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_hk33a3_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_hk33ka2_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_hk33ka3_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_hk33sg1_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],//
		["gm_g3a3a1_ris_blk", "", "", "",  ["gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk"], [], ""],
		["gm_g3a4a1_ris_blk", "", "", "",  ["gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk"], [], ""],
		["gm_g3a4a1_ris_blk", "", "", "",  ["gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk"], [], ""],
		["gm_m16a1_blk", "","","",["gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry"], [], ""],
		["gm_m16a2_blk", "","","",["gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry"], [], ""]
	];
    _carbines append [
        ["gm_mp5n_surefire_blk", "", "gm_surefire_l60_wht_surefire_blk", "gm_rv_stanagClaw_blk", ["gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5_blk"], [], ""],
        ["gm_mp5sd6_blk", "", "gm_surefire_l60_ir_hoseclamp_blk", "gm_rv_stanagClaw_blk", ["gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5_blk"], [], ""],
		["gm_mp5a2_blk", "", "", "gm_rv_stanagClaw_blk", ["gm_30Rnd_9x19mm_B_DM51_mp5_blk","gm_30Rnd_9x19mm_B_DM51_mp5_blk","gm_30Rnd_9x19mm_B_DM11_mp5_blk","gm_30Rnd_9x19mm_AP_DM91_mp5_blk"], [], ""],
        ["gm_mp2a1_blk", "", "", "", ["gm_32Rnd_9x19mm_B_DM51_mp2_blk","gm_32Rnd_9x19mm_B_DM11_mp2_blk","gm_32Rnd_9x19mm_AP_DM91_mp2_blk"], [], ""],
		["gm_g3ka4a1_ris_blk", "", "", "optic_ACO_grn_smg",  ["gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk", "gm_20Rnd_762x51mm_B_T_DM21_g3_blk"], [], ""],
		["gm_hk53a2_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_hk53a3_blk", "", "", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_mpm85_blk", "", "gm_surefire_l60_wht_surefire_blk", "",  ["gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk", "gm_30Rnd_556x45mm_B_DM11_hk33_blk"], [], ""],
		["gm_mpiaks74nk_brn", "", "", "",  ["gm_30Rnd_545x39mm_B_7N6_ak74_org", "gm_30Rnd_545x39mm_B_7N6_ak74_org", "gm_30Rnd_545x39mm_B_7N6_ak74_org"], [], ""],
		["gm_mpikms72k_brn", "", "", "",  ["gm_30Rnd_762x39mm_B_57N231_mpikm_blk", "gm_30Rnd_762x39mm_B_57N231_mpikm_blk", "gm_30Rnd_762x39mm_B_57N231_mpikm_blk"], [], ""]
    ];
    _tunedRifles append [
        ["gm_g11k2_ris_blk","","acc_pointer_IR","optic_Nightstalker",["gm_50Rnd_473x33mm_B_DM11_g11_blk","gm_50Rnd_473x33mm_B_DM11_g11_blk","gm_50Rnd_473x33mm_B_DM11_g11_blk"], [], ""],
        ["gm_sg551_swat_blk","","acc_pointer_IR","optic_Hamr",["gm_30Rnd_556x45mm_B_T_DM21_sg550_brn","gm_30Rnd_556x45mm_B_DM11_sg550_brn","gm_30Rnd_556x45mm_B_DM11_sg550_brn","gm_30Rnd_556x45mm_B_T_DM21_sg550_brn"], [], ""],
		["gm_sg551_ris_blk", "","","optic_Hamr",["gm_30Rnd_556x45mm_B_T_DM21_sg550_brn","gm_30Rnd_556x45mm_B_DM11_sg550_brn","gm_30Rnd_556x45mm_B_DM11_sg550_brn","gm_30Rnd_556x45mm_B_T_DM21_sg550_brn"], [], ""],
        ["gm_sg542_ris_blk", "","","optic_Hamr",["gm_20Rnd_762x51mm_B_T_DM21A2_sg542_blk","gm_20Rnd_762x51mm_AP_DM151_sg542_blk","gm_20Rnd_762x51mm_B_DM41_sg542_blk","gm_20Rnd_762x51mm_B_DM111_sg542_blk"], [], ""],
		["gm_m16a1_blk", "","","gm_colt4x20_ar15_blk",["gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry"], [], ""],
		["gm_m16a2_blk", "","","gm_colt4x20_ar15_blk",["gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry","gm_20Rnd_556x45mm_B_M193_stanag_gry"], [], ""],
		["gm_mpikms72ksd_brn", "","gm_flashlightp2_wht_akkhandguard_blu","gm_pka_dovetail_blk",["gm_30Rnd_762x39mm_BSD_57N231U_mpikm_blk","gm_30Rnd_762x39mm_BSD_57N231U_mpikm_blk","gm_30Rnd_762x39mm_BSD_57N231U_mpikm_blk"], [], ""]
    ];
    _marksmanRifles append [
        ["gm_msg90_blk","","","gm_feroz24_stanagHK_blk",["gm_20Rnd_762x51mm_AP_DM151_g3_blk","gm_20Rnd_762x51mm_B_DM41_g3_blk", "gm_20Rnd_762x51mm_B_DM111_g3_blk","gm_20Rnd_762x51mm_B_T_DM21A2_g3_blk"], [], "gm_msg90_bipod_blk"],
        ["gm_msg90a1_blk","","","gm_feroz24_stanagHK_blk",["gm_20Rnd_762x51mm_AP_DM151_g3_blk","gm_20Rnd_762x51mm_B_DM41_g3_blk", "gm_20Rnd_762x51mm_B_DM111_g3_blk","gm_20Rnd_762x51mm_B_T_DM21A2_g3_blk"], [], "gm_msg90_bipod_blk"],
		["gm_psg1_blk","","","gm_zf6x42_psg1_stanag_blk",["gm_20Rnd_762x51mm_B_T_DM21A2_g3_blk","gm_20Rnd_762x51mm_AP_DM151_g3_blk","gm_20Rnd_762x51mm_B_DM41_g3_blk"], [], "gm_msg90_bipod_blk"],
		["gm_svd_wud","","","gm_pso6x36_1_dovetail_blk",["gm_10Rnd_762x54mmR_AP_7N1_svd_blk","gm_10Rnd_762x54mmR_API_7bz3_svd_blk","gm_10Rnd_762x54mmR_B_T_7t2_svd_blk"], [], "gm_msg90_bipod_blk"]
    ];
    _enforcerRifles append [
        ["gm_c7a1_oli", "", "", "optic_Hamr", ["gm_30Rnd_556x45mm_B_M855_stanag_gry","gm_30Rnd_556x45mm_B_T_M856_stanag_gry","gm_30Rnd_556x45mm_B_M193_stanag_gry","gm_30Rnd_556x45mm_B_T_M196_stanag_gry"], [], ""],
        ["gm_g36a1_blk", "", "", "", ["gm_30Rnd_556x45mm_B_DM11_g36_blk","gm_30Rnd_556x45mm_B_T_DM21_g36_blk","gm_30Rnd_556x45mm_B_DM11_g36_blk","gm_30Rnd_556x45mm_B_T_DM21_g36_blk"], [], ""],
        ["gm_g36e_blk", "", "", "", ["gm_30Rnd_556x45mm_B_DM11_g36_blk","gm_30Rnd_556x45mm_B_T_DM21_g36_blk","gm_30Rnd_556x45mm_B_DM11_g36_blk","gm_30Rnd_556x45mm_B_T_DM21_g36_blk"], [], ""],
        ["gm_g3ka4a1_ris_blk", "", "", "gm_c79a1_blk", ["gm_40Rnd_762x51mm_AP_DM151_g3_blk","gm_40Rnd_762x51mm_B_DM41_g3_blk","gm_40Rnd_762x51mm_B_DM111_g3_blk","gm_40Rnd_762x51mm_B_T_DM21A2_g3_blk"], [], ""],
		["gm_hk512_wud", "", "gm_surefire_l60_wht_hoseclamp_blk", "", ["gm_7rnd_12ga_hk512_pellet","gm_7rnd_12ga_hk512_slug","gm_7rnd_12ga_hk512_pellet","gm_7rnd_12ga_hk512_slug"], [], ""],
        ["gm_hk512_ris_wud", "", "gm_surefire_l60_wht_hoseclamp_blk", "optic_Aco", ["gm_7rnd_12ga_hk512_pellet","gm_7rnd_12ga_hk512_slug","gm_7rnd_12ga_hk512_pellet","gm_7rnd_12ga_hk512_slug"], [], ""]
    ];
    _mgs append [
        ["gm_mg3_blk", "", "", "", ["gm_120Rnd_762x51mm_B_T_DM21_mg3_grn","gm_120Rnd_762x51mm_B_T_DM21A2_mg3_grn"], [], ""],
		["gm_mg8a1_blk", "", "", "gm_colt4x20_stanagClaw_blk", ["gm_100Rnd_762x51mm_B_T_DM21_mg8_oli","gm_100Rnd_762x51mm_B_T_DM21A2_mg8_oli"], [], "gm_g8_bipod_blk"],
        ["gm_mg8a2_blk", "", "", "gm_blits_stanagHK_blk", ["gm_100Rnd_762x51mm_B_T_DM21_mg8_oli","gm_100Rnd_762x51mm_B_T_DM21A2_mg8_oli"], [], "gm_g8_bipod_blk"],
		["gm_hmgpkm_prp", "", "", "", ["gm_100Rnd_762x54mmR_B_T_7t2_pk_grn","gm_100Rnd_762x54mmR_B_T_7t2_pk_grn"], [], ""],
		["gm_lmgrpk74n_blk", "gm_suppressor_pbs4_545mm_blk", "gm_flashlightp2_wht_akhandguard_blu", "gm_pka_dovetail_blk", ["gm_45Rnd_545x39mm_B_7N6_ak74_org","gm_45Rnd_545x39mm_B_7N6_ak74_org","gm_45Rnd_545x39mm_B_7N6_ak74_org"], [], ""],
		["gm_lmgrpk_brn", "gm_suppressor_pbs1_762mm_blk", "gm_flashlightp2_wht_akkhandguard_blu", "gm_pka_dovetail_blk", ["gm_75Rnd_762x39mm_B_57N231_mpikm_blk","gm_75Rnd_762x39mm_B_57N231_mpikm_blk"], [], ""],
		["gm_rpk74n_wud", "gm_suppressor_pbs4_545mm_blk", "", "gm_zfk4x25_blk", ["gm_45Rnd_545x39mm_B_7N6_ak74_org","gm_45Rnd_545x39mm_B_7N6_ak74_org","gm_45Rnd_545x39mm_B_7N6_ak74_org"], [], ""],
		["gm_rpk_wud", "gm_suppressor_pbs1_762mm_blk", "", "gm_zvn64_rpk", ["gm_75Rnd_762x39mm_B_57N231_ak47_blk","gm_75Rnd_762x39mm_B_57N231_ak47_blk"], [], ""],
		["gm_rpkn_wud", "gm_suppressor_pbs1_762mm_blk", "", "gm_zfk4x25_blk", ["gm_75Rnd_762x39mm_B_57N231_ak47_blk","gm_75Rnd_762x39mm_B_57N231_ak47_blk"], [], ""]
    ];
	_pistols append [
        ["gm_m49_blk", "", "", "", ["gm_8Rnd_9x19mm_B_DM51_p210_blk","gm_8Rnd_9x19mm_B_DM11_p210_blk"], [], ""],
        ["gm_p1_blk", "", "", "", ["gm_8Rnd_9x19mm_B_DM11_p1_blk","gm_8Rnd_9x19mm_B_DM51_p1_blk","gm_8Rnd_9x19mm_BSD_DM81_p1_blk"], [], ""],
        ["gm_p1sd_blk", "", "", "", ["gm_8Rnd_9x19mm_B_DM11_p1_blk","gm_8Rnd_9x19mm_B_DM51_p1_blk","gm_8Rnd_9x19mm_BSD_DM81_p1_blk"], [], ""],
        ["gm_p210_blk", "", "", "", ["gm_8Rnd_9x19mm_B_DM11_p210_blk","gm_8Rnd_9x19mm_B_DM51_p210_blk"], [], ""],
        ["gm_pim_blk", "", "", "", ["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"], [], ""],
        ["gm_pimb_blk", "", "", "", ["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"], [], ""],
        ["gm_pm63_handgun_blk", "", "", "", ["gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk"], [], ""]
    ];
};

if (_hasCSLA) then {
    _rpgs append [
        ["US85_M136", "", "", "", ["US85_M136_Mag"], [], ""],
        ["US85_M47", "", "", "", ["US85_M47_Mag"], [], ""],
        ["CSLA_RPG7", "", "", "CSLA_PGO7", ["CSLA_PG7M110V", "CSLA_PG7M110V"], [], ""],
		["CSLA_RPG75", "", "", "", ["CSLA_RPG75_Mag", "CSLA_RPG75_Mag"], [], ""],
		["CSLA_RPG7", "", "", "CSLA_PGO7", ["CSLA_PG7M110V", "CSLA_PG7M110V"], [], ""]
    ];
    (_loadoutData get "lightHELaunchers") append [
        ["US85_LAW72", "", "", "", ["US85_LAW72_Mag", "US85_LAW72_Mag"], [], ""],
        ["US85_MAAWS", "", "", "", ["US85_MAAWS_HEDP","US85_MAAWS_HEDP","US85_MAAWS_HEAT"], [], ""],
		["US85_SMAW", "", "", "", ["US85_SMAW_HEAA","US85_SMAW_HEAA","US85_SMAW_HEDP"], [], ""]
    ];
    (_loadoutData get "AALaunchers") append [
        ["CSLA_9K32", "", "", "", ["CSLA_9M32M","CSLA_9M32M"], [], ""],
		["US85_FIM92", "", "", "", ["US85_FIM92_Mag","US85_FIM92_Mag"], [], ""]
    ];
	_gls append [
		["US85_M16A2CARGL", "", "", "US85_sc2000_M16", ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], ["US85_M406","US85_M406","US85_M406"], ""],
		["US85_M16A2GL", "", "", "US85_sc2000_M16", ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], ["US85_M406","US85_M406","US85_M406"], ""],
		["CSLA_VG70", "", "", "", ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], ["CSLA_26_5vz70","CSLA_26_5vz70","CSLA_26_5vz70","CSLA_26_5sigZl1a"], "CSLA_Sa58bnt"]
	];
	_rifles append [
		["US85_FAL", "", "", "",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], ""],
		["US85_FALf", "", "", "",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], ""],
		["US85_M14", "", "", "",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], ""],
		["US85_M16A1", "", "", "",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
		["US85_M16A2", "", "", "",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
		["CSLA_Sa58P", "", "", "",  ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], ""],
		["CSLA_Sa58V", "", "", "",  ["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], "CSLA_Sa58bpd"]
	];
    _carbines append [
        ["US85_M16A2CAR", "", "", "",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
        ["US85_MPVN", "", "", "", ["US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger"], [], ""],
		["US85_MPVSD", "", "", "", ["US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger","US85_MPV_30Rnd_9Luger"], [], ""],
        ["CSLA_rSa61", "", "", "", ["CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_10rnd_7_65Pi27"], [], ""],
		["CSLA_Sa24", "", "", "",  ["CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52"], [], ""],
		["CSLA_Sa26", "", "", "",  ["CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52", "CSLA_Sa24_32rnd_7_62Pi52"], [], ""]
    ];
    _tunedRifles append [
        ["US85_FAL", "", "", "US85_scFAL",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_FALbpd"],
        ["US85_FALf", "", "", "US85_scFAL",  ["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_FALbpd"],
		["US85_M16A2CAR", "US85_M16tlm","US85_M16fl","US85_sc4x20_M16",["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
        ["US85_M16A1", "US85_M16tlm", "", "US85_sc4x20_M16",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
		["US85_M16A2", "US85_M16tlm", "", "US85_sc4x20_M16",  ["US85_30Rnd_556x45","US85_30Rnd_556x45","US85_20Rnd_556x45","US85_20Rnd_556x45"], [], ""],
		["CSLA_Sa58P", "","","CSLA_ZD4x8",["CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62vz43","CSLA_Sa58_30rnd_7_62Sv43","CSLA_Sa58_30rnd_7_62Sv43"], [], "CSLA_Sa58bpd"]
    ];
    _marksmanRifles append [
        ["CSLA_HuntingRifle","","","",["CSLA_10Rnd_762hunt","CSLA_10Rnd_762hunt", "CSLA_10Rnd_762hunt","CSLA_10Rnd_762hunt"], [], "gm_msg90_bipod_blk"],
        ["US85_M14","","","US85_scM21",["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_M14bpd"],
		["US85_M21","","","US85_scM21",["US85_20Rnd_762x51", "US85_20Rnd_762M61", "US85_20Rnd_762M61"], [], "US85_M14bpd"],
		["CSLA_OP63","","","CSLA_PSO1_OP63",["CSLA_OP63_10rnd_7_62Odst59","CSLA_OP63_10rnd_7_62PZ59","CSLA_OP63_10rnd_7_62Odst59","CSLA_OP63_10rnd_7_62PZ59"], [], ""]
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
    _mgs append [
        ["US85_M249", "", "", "US85_sc4x20M249", ["US85_200Rnd_556x45","US85_200Rnd_556x45"], [], ""],
		["US85_M60", "", "", "", ["US85_100Rnd_762x51","US85_100Rnd_762x51"], [], ""],
        ["CSLA_UK59L", "", "", "CSLA_UK59_ZD4x8", ["CSLA_UK59_50rnd_7_62vz59","CSLA_UK59_50rnd_7_62Sv59","CSLA_UK59_50rnd_7_62PZ59","CSLA_UK59_50rnd_7_62Tz59","CSLA_UK59_50rnd_7_62TzSv59"], [], ""]
    ];
	_pistols append [
        ["US85_1911", "", "", "", ["US85_1911_7Rnd_045ACP","US85_1911_7Rnd_045ACP","US85_1911_7Rnd_045ACP"], [], ""],
        ["US85_M9", "", "", "", ["US85_M9_15Rnd_9Luger","US85_M9_15Rnd_9Luger","US85_M9_15Rnd_9Luger"], [], ""],
        ["CSLA_Pi52", "", "", "", ["CSLA_Pi52_8rnd_7_62Pi52","CSLA_Pi52_8rnd_7_62Pi52","CSLA_Pi52_8rnd_7_62Pi52"], [], ""],
        ["CSLA_Pi75lr", "", "", "", ["CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger"], [], ""],
        ["CSLA_Pi75sr", "", "", "", ["CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger","CSLA_Pi75_15Rnd_9Luger"], [], ""],
        ["CSLA_Pi82", "", "", "", ["CSLA_Pi82_12rnd_9Pi82","CSLA_Pi82_12rnd_9Pi82","CSLA_Pi82_12rnd_9Pi82"], [], ""],
        ["CSLA_Sa61", "", "", "", ["CSLA_Sa61_10rnd_7_65Pi27","CSLA_Sa61_10rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27","CSLA_Sa61_20rnd_7_65Pi27"], [], ""]
    ];
};

if (_hasSOG) then {
    _rpgs append [
		["vn_m72", "", "", "", ["vn_m72_mag"], [], ""],
        ["vn_rpg7", "", "", "", ["vn_rpg7_mag","vn_rpg7_mag","vn_rpg7_mag"], [], ""]
    ];
    (_loadoutData get "lightHELaunchers") append [
        ["vn_rpg2", "", "", "", ["vn_rpg2_fuze_mag","vn_rpg2_fuze_mag","vn_rpg2_mag"], [], ""],
		["vn_m20a1b1_01", "", "", "", ["vn_m20a1b1_wp_mag", "vn_m20a1b1_heat_mag", "vn_m20a1b1_heat_mag"], [], ""]
    ];
    (_loadoutData get "AALaunchers") append [
		["vn_sa7b", "", "", "", ["vn_sa7b_mag"], [], ""],
        ["vn_sa7", "", "", "", ["vn_sa7_mag"], [], ""]
    ];
	_gls append [
		["vn_xm16e1_xm148","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_xm148","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_m203","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_m203_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m79","","","",["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],["vn_40mm_m576_buck_mag"],""],
        ["vn_l1a1_xm148_camo","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_l1a1_xm148","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_l1a1_02_gl","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_22mm_m61_frag_mag","vn_22mm_m61_frag_mag","vn_22mm_n94_heat_mag","vn_22mm_n94_heat_mag"],""],
        ["vn_l1a1_01_gl","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_22mm_m61_frag_mag","vn_22mm_m61_frag_mag","vn_22mm_n94_heat_mag","vn_22mm_n94_heat_mag"],""],
        //
        ["vn_sks_gl","","","",["vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_t_mag"],["vn_22mm_cs_mag","vn_22mm_m19_wp_mag","vn_22mm_m60_frag_mag","vn_22mm_m60_heat_mag"],""],
        ["vn_m4956_gl","","","",["vn_m4956_10_mag","vn_m4956_10_mag","vn_m4956_10_t_mag","vn_m4956_10_t_mag"],["vn_22mm_cs_mag","vn_22mm_he_mag","vn_22mm_m19_wp_mag","vn_22mm_m9_heat_mag"],""],
        ["vn_kbkg_gl","","","",["vn_type56_mag","vn_type56_mag","vn_type56_t_mag","vn_kbkg_t_mag"],["vn_20mm_dgn_wp_mag","vn_20mm_f1n60_frag_mag","vn_20mm_kgn_frag_mag","vn_20mm_pgn60_heat_mag","vn_20mm_pgn60_heat_mag"],""]
	];
	_rifles append [
		["vn_xm16e1","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_m63a","","","",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m16_camo","","","",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m16_camo","","vn_b_m16","vn_o_9x_m16",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m16","","","",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m16","","vn_b_m16","vn_o_9x_m16",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m16_usaf","","","",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m16_usaf","","vn_b_m16","vn_o_9x_m16",["vn_m63a_30_mag","vn_m63a_30_mag","vn_m63a_30_t_mag"],[],""],
        ["vn_m14a1_shorty","","","vn_o_m14_front",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],""],
        ["vn_l2a1_01","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_03_camo","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_03","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_02_camo","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_02","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_03","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_01_camo","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        ["vn_l1a1_01","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],[],""],
        //
        ["vn_type56","","vn_b_type56","",["vn_type56_mag","vn_type56_mag","vn_type56_t_mag","vn_type56_t_mag"],[],""],
        ["vn_type56","","","",["vn_type56_mag","vn_type56_mag","vn_type56_t_mag","vn_type56_t_mag"],[],""],
        ["vn_kbkg","","","",["vn_type56_mag","vn_type56_mag","vn_type56_t_mag","vn_type56_t_mag"],[],""],
        ["vn_ak_01","","","",["vn_type56_mag","vn_type56_mag","vn_type56_t_mag","vn_type56_t_mag"],[],""]
	];
    _carbines append [
		["vn_xm177_stock_camo","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_xm177_short","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_xm177_camo","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_xm177","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_xm177e1_camo","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_xm177e1","","","",["vn_m16_20_mag","vn_m16_40_mag","vn_m16_30_mag"],[],""],
        ["vn_gau5a","","","vn_o_4x_m16",["vn_m16_30_t_mag","vn_m16_30_mag","vn_m16_40_t_mag","vn_m16_20_t_mag"],[],""],
        ["vn_gau5a","","","",["vn_m16_30_t_mag","vn_m16_30_mag","vn_m16_40_t_mag","vn_m16_20_t_mag"],[],""]
    ];
    _tunedRifles append [
		["vn_xm177_xm148_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_xm177_xm148","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_xm177_m203_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_xm177_m203","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_xm148","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_m203","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_m203_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_l1a1_xm148_camo","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_l1a1_xm148","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""]
    ];
    _marksmanRifles append [
		["vn_svd","","","vn_o_4x_svd",["vn_svd_mag","vn_svd_mag","vn_svd_t_mag"],[],"vn_b_camo_svd"],
        ["vn_m14a1","vn_s_m14","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_bipod_m14"],
        ["vn_m14a1","vn_s_m14","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14a1"],
        ["vn_m14a1","","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_bipod_m14"],
        ["vn_m14a1","","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14a1"],
        ["vn_m14_camo","vn_s_m14","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14"],
        ["vn_m14_camo","","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14"],
        ["vn_m14_camo","","vn_b_m14","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14"],
        ["vn_m14","vn_s_m14","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14"],
        ["vn_m14","","","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14"],
        ["vn_m14","","vn_b_m14","vn_o_9x_m14",["vn_m14_t_mag","vn_m14_mag","vn_m14_10_t_mag","vn_m14_10_mag"],[],"vn_b_camo_m14"],
        ["vn_m1carbine_shorty","","","",["vn_carbine_30_mag","vn_carbine_30_mag","vn_carbine_30_t_mag","vn_carbine_15_t_mag"],[],"vn_b_camo_m14"],
        //
        ["vn_sks","","vn_b_sks","vn_o_3x_sks",["vn_sks_mag","vn_sks_mag","vn_sks_t_mag","vn_sks_t_mag"],[],""],
        ["vn_sks","","","vn_o_3x_sks",["vn_sks_mag","vn_sks_mag","vn_sks_t_mag","vn_sks_t_mag"],[],""],
        ["vn_m4956","","vn_b_m4956","vn_o_4x_m4956",["vn_m4956_10_mag","vn_m4956_10_mag","vn_m4956_10_t_mag","vn_m4956_10_t_mag"],[],""],
        ["vn_m4956","","","vn_o_4x_m4956",["vn_m4956_10_mag","vn_m4956_10_mag","vn_m4956_10_t_mag","vn_m4956_10_t_mag"],[],""],
		["vn_m40a1_camo","vn_s_m14","","vn_o_9x_m40a1",["vn_m40a1_mag","vn_m40a1_mag","vn_m40a1_t_mag","vn_m40a1_t_mag"],[],"vn_b_camo_m40a1"],
        ["vn_m40a1_camo","","","vn_o_9x_m40a1",["vn_m40a1_mag","vn_m40a1_mag","vn_m40a1_t_mag","vn_m40a1_t_mag"],[],""],
        ["vn_m40a1","","","vn_o_9x_m40a1",["vn_m40a1_mag","vn_m40a1_mag","vn_m40a1_t_mag","vn_m40a1_t_mag"],[],""],
        //
        ["vn_vz54","","","vn_o_3x_vz54",["vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_t_mag"],[],"vn_b_camo_vz54"],
        ["vn_vz54","","","vn_o_3x_vz54",["vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_t_mag"],[],""],
        ["vn_m9130","","vn_b_m38","vn_o_3x_m9130",["vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_t_mag"],[],"vn_b_camo_m9130"],
        ["vn_m9130","","","vn_o_3x_m9130",["vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_t_mag"],[],"vn_b_camo_m9130"],
        ["vn_m9130","","","vn_o_3x_m9130",["vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_t_mag"],[],""],
        ["vn_k98k","","vn_b_k98k","vn_o_1_5x_k98k",["vn_k98k_mag","vn_k98k_mag","vn_k98k_t_mag","vn_k98k_t_mag"],[],"vn_b_camo_k98k"],
        ["vn_k98k","","","vn_o_1_5x_k98k",["vn_k98k_mag","vn_k98k_mag","vn_k98k_t_mag","vn_k98k_t_mag"],[],"vn_b_camo_k98k"],
        ["vn_k98k","","","vn_o_1_5x_k98k",["vn_k98k_mag","vn_k98k_mag","vn_k98k_t_mag","vn_k98k_t_mag"],[],""]
    ];
    _enforcerRifles append [
		["vn_xm177_xm148_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_xm177_xm148","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_xm177_m203_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_xm177_m203","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_xm148","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_m203","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_m16_m203_camo","","","",["vn_m16_40_t_mag","vn_m16_40_mag","vn_m16_30_t_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_l1a1_xm148_camo","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""],
        ["vn_l1a1_xm148","","","",["vn_l1a1_30_02_t_mag","vn_l1a1_30_02_mag","vn_l1a1_30_t_mag","vn_l1a1_30_mag"],["vn_40mm_m651_cs_mag","vn_40mm_m381_he_mag","vn_40mm_m397_ab_mag","vn_40mm_m406_he_mag","vn_40mm_m433_hedp_mag"],""]
    ];
    _mgs append [
		["vn_mg42","","","",["vn_mg42_50_mag","vn_mg42_50_mag","vn_mg42_50_t_mag","vn_mg42_50_t_mag"],[],""],
        ["vn_m63a_lmg","","","",["vn_m63a_100_mag","vn_m63a_100_t_mag","vn_m63a_100_mag","vn_m63a_100_t_mag"],[],"vn_bipod_m63a"],
        ["vn_m63a_cdo","","","",["vn_m63a_150_mag","vn_m63a_150_t_mag","vn_m63a_150_mag","vn_m63a_150_t_mag"],[],"vn_bipod_m63a"],
        ["vn_m60_shorty_camo","","","",["vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag"],[],"vn_bipod_m63a"],
        ["vn_m60_shorty","","","",["vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag"],[],"vn_bipod_m63a"],
        ["vn_m60","","","",["vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag","vn_m60_100_mag"],[],"vn_bipod_m63a"],
        //
        ["vn_rpd_shorty","","","",["vn_rpd_125_mag","vn_rpd_125_mag","vn_rpd_100_mag","vn_rpd_100_mag"],[],""],
        ["vn_rpd_shorty_01","","","",["vn_rpd_125_mag","vn_rpd_125_mag","vn_rpd_100_mag","vn_rpd_100_mag"],[],""],
        ["vn_rpd","","","",["vn_rpd_125_mag","vn_rpd_125_mag","vn_rpd_100_mag","vn_rpd_100_mag"],[],""],
        ["vn_pk","","","",["vn_pk_100_mag","vn_pk_100_mag","vn_pk_100_mag","vn_pk_100_mag"],[],""],
        ["vn_dp28","","","",["vn_pk_100_mag","vn_pk_100_mag","vn_pk_100_mag","vn_pk_100_mag"],[],""]
    ];
	_pistols append [
		["vn_vz61_p","","","",["vn_vz61_mag","vn_vz61_mag","vn_vz61_t_mag","vn_vz61_t_mag"], [], ""],
        ["vn_type64","","","",["vn_type64_mag","vn_type64_mag","vn_type64_mag","vn_type64_mag"], [], ""],
        ["vn_tt33","","","",["vn_tt33_mag","vn_tt33_mag","vn_tt33_mag","vn_tt33_mag"], [], ""],
        ["vn_ppk","vn_s_ppk","","",["vn_ppk_mag","vn_ppk_mag","vn_ppk_mag","vn_ppk_mag"], [], ""],
        ["vn_ppk","","","",["vn_ppk_mag","vn_ppk_mag","vn_ppk_mag","vn_ppk_mag"], [], ""],
        ["vn_fkb1_pm","","","",["vn_ppk_mag","vn_ppk_mag","vn_ppk_mag","vn_ppk_mag"], [], ""],
        ["vn_pm","vn_s_pm","","",["vn_ppk_mag","vn_ppk_mag","vn_ppk_mag","vn_ppk_mag"], [], ""],
        ["vn_pm","","","",["vn_ppk_mag","vn_ppk_mag","vn_ppk_mag","vn_ppk_mag"], [], ""],
        ["vn_p38","vn_s_ppk","","",["vn_p38_mag","vn_p38_mag","vn_p38_mag","vn_p38_mag"], [], ""],
        ["vn_p38","","","",["vn_p38_mag","vn_p38_mag","vn_p38_mag","vn_p38_mag"], [], ""],
        ["vn_m10","vn_s_mk22","","",["vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag"], [], ""],
        ["vn_m10","","","",["vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag"], [], ""],
        ["vn_mk22","vn_s_mk22","","",["vn_s_mk22","vn_s_mk22","vn_s_mk22","vn_s_mk22"], [], ""],
        ["vn_mk22","","","",["vn_s_mk22","vn_s_mk22","vn_s_mk22","vn_s_mk22"], [], ""],
        ["vn_m712","","","",["vn_m712_mag","vn_m712_mag","vn_m712_mag","vn_m712_mag"], [], ""],
        ["vn_mx991_m1911","vn_s_m1911","","",["vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"], [], ""],
        ["vn_mx991_m1911","","","",["vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"], [], ""],
        ["vn_m1911","vn_s_m1911","","",["vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"], [], ""],
        ["vn_m1911","","","",["vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"], [], ""],
        ["vn_m1895","vn_s_m1895","","",["vn_m1895_mag","vn_m1895_mag","vn_m1895_mag","vn_m1895_mag"], [], ""],
        ["vn_m1895","","","",["vn_m1895_mag","vn_m1895_mag","vn_m1895_mag","vn_m1895_mag"], [], ""],
        ["vn_izh54_p","","","",["vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag"], [], ""],
        ["vn_hp","vn_s_hp","","",["vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"], [], ""],
        ["vn_hp","","","",["vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"], [], ""],
        ["vn_hd","","","",["vn_hd_mag","vn_hd_mag","vn_hd_mag","vn_hd_mag"], [], ""],
        ["vn_p38s","","","",["vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag"], [], ""]
    ];
};

if (_hasSPE) then {
    _rpgs append [
        ["SPE_M1A1_Bazooka", "", "", "", ["SPE_1Rnd_60mm_M6","SPE_1Rnd_60mm_M6","SPE_1Rnd_60mm_M6"], [], ""]
    ];
    _rifles append [
        ["SPE_STG44","","","",["SPE_30Rnd_792x33","SPE_30Rnd_792x33","SPE_30rnd_792x33_t"],[],""],
        ["SPE_M1918A2_BAR","","","",["SPE_20Rnd_762x63","SPE_20Rnd_762x63_M1","SPE_20Rnd_762x63_M2_AP"],[],""]
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
    _mgs append [
        ["SPE_MG42","","","",["SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_sS","SPE_50Rnd_792x57"],[],""],
        ["SPE_MG34","","","",["SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_SMK","SPE_50Rnd_792x57_sS","SPE_50Rnd_792x57"],[],""],
        ["SPE_M1919A6","","","",["SPE_100Rnd_762x63","SPE_100Rnd_762x63_M1","SPE_100Rnd_762x63_M2_AP","SPE_50Rnd_762x63_M2_AP"],[],""],
        ["SPE_M1919A4","","","",["SPE_100Rnd_762x63","SPE_100Rnd_762x63_M1","SPE_100Rnd_762x63_M2_AP","SPE_50Rnd_762x63_M2_AP"],[],""],
        ["SPE_FM_24_M29","","","",["SPE_25Rnd_75x54","SPE_25Rnd_75x54","SPE_25Rnd_75x54_35P_AP","SPE_25Rnd_75x54_35P_AP","SPE_25Rnd_75x54","SPE_25Rnd_75x54","SPE_25Rnd_75x54_35P_AP","SPE_25Rnd_75x54_35P_AP"],[],""]
    ];
	_carbines append [
        ["SPE_M1_Carbine","SPE_ACC_GL_M8","","",["SPE_15Rnd_762x33","SPE_15Rnd_762x33","SPE_15Rnd_762x33_t","SPE_15Rnd_762x33_t"], [], ""],
        ["SPE_M1_Carbine","","","",["SPE_15Rnd_762x33","SPE_15Rnd_762x33","SPE_15Rnd_762x33_t","SPE_15Rnd_762x33_t"], [], ""],
        ["SPE_Fusil_Mle_208_12_Sawedoff","","","",["SPE_2Rnd_12x65_No4_Buck","SPE_2Rnd_12x65_Pellets","SPE_2Rnd_12x65_Slug","SPE_2Rnd_12x65_No4_Buck"], [], ""],
        ["SPE_Fusil_Mle_208_12","","","",["SPE_2Rnd_12x65_No4_Buck","SPE_2Rnd_12x65_Pellets","SPE_2Rnd_12x65_Slug","SPE_2Rnd_12x65_No4_Buck"], [], ""]
    ];
    _pistols append [
        ["SPE_M1911","","","",["SPE_7Rnd_45ACP_1911","SPE_7Rnd_45ACP_1911","SPE_7Rnd_45ACP_1911","SPE_7Rnd_45ACP_1911"], [], ""],
        ["SPE_P08","","","",["SPE_8Rnd_9x19_P08","SPE_8Rnd_9x19_P08","SPE_8Rnd_9x19_P08","SPE_8Rnd_9x19_P08"], [], ""]
    ];
};

_loadoutData set ["rifles", _rifles];
_loadoutData set ["tunedRifles", _tunedRifles];
_loadoutData set ["enforcerRifles", _enforcerRifles];
_loadoutData set ["carbines", _carbines];
_loadoutData set ["grenadeLaunchers", _gls];
_loadoutData set ["machineGuns", _mgs];
_loadoutData set ["marksmanRifles", _marksmanRifles];
_loadoutData set ["lightATLaunchers", _rpgs];
_loadoutData set ["sidearms", _pistols];


_loadoutData set ["facewear", [
	"G_Aviator",
	"G_Combat",
	"G_Bandanna_aviator",
	"G_Bandanna_beast",
	"G_Bandanna_sport",
	"G_Bandanna_shades",
	"G_Bandanna_blk"
]];

if (_hasGM) then {
    (_loadoutData get "facewear") append [
        "gm_ge_facewear_acidgoggles",
        "gm_ge_facewear_dustglasses",
        "gm_gc_army_facewear_dustglasses",
        "gm_ge_facewear_m65",
        "gm_gc_army_facewear_schm41m",
        "gm_ge_facewear_glacierglasses",
        "gm_xx_facewear_scarf_01_trp",
        "gm_xx_facewear_scarf_01_flk",
        "gm_xx_facewear_scarf_01_blk",
        "gm_xx_facewear_scarf_01_blu",
        "gm_xx_facewear_scarf_01_pt1",
        "gm_xx_facewear_scarf_01_pt3",
        "gm_xx_facewear_scarf_01_frog",
        "gm_xx_facewear_scarf_01_grn",
        "gm_xx_facewear_scarf_01_gry",
        "gm_xx_facewear_scarf_01_m84",
        "gm_xx_facewear_scarf_02_blk",
        "gm_xx_facewear_scarf_01_grn",
        "gm_xx_facewear_scarf_01_oli",
        "gm_xx_facewear_scarf_01_wht",
        "gm_xx_facewear_scarf_01_moro",
        "gm_xx_facewear_scarf_01_oli",
        "gm_xx_facewear_scarf_01_red",
        "gm_xx_facewear_scarf_01_pt2",
        "gm_xx_facewear_scarf_01_str",
        "gm_xx_facewear_scarf_01_wht",
        "gm_ge_facewear_sunglasses"
        ];
};

if (_hasRF) then {
    (_loadoutData get "facewear") append [
        "G_Bandanna_yellow_RF",
        "G_Glasses_black_RF",
        "G_Glasses_white_RF"
    ];
}; 

if (_hasSOG) then {
    (_loadoutData get "facewear") append [
        "vn_b_acc_towel_02",
        "vn_b_acc_towel_01",
        "vn_b_spectacles_tinted",
		"vn_g_glasses_01",
		"vn_b_squares_tinted",
		"vn_b_squares",
		"vn_g_spectacles_01",
		"vn_g_spectacles_02",
		"vn_b_spectacles",
		"vn_b_acc_rag_02",
		"vn_b_acc_rag_01",
		"vn_o_scarf_01_01",
		"vn_b_scarf_01_01",
		"vn_o_scarf_01_02",
		"vn_o_scarf_01_03",
		"vn_o_scarf_01_04",
		"vn_b_scarf_01_03",
		"vn_o_poncho_01_01",
		"vn_o_acc_goggles_02",
		"vn_b_acc_goggles_01",
		"vn_o_acc_goggles_01",
		"vn_o_bandana_g",
		"vn_o_bandana_b",
		"vn_b_bandana_a",
		"vn_b_aviator"
    ];
}; 

if (_hasSPE) then {
    (_loadoutData get "facewear") append [
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
}; 

_loadoutData set ["fullmask", [	"G_Balaclava_combat", "G_Balaclava_lowprofile", "G_Balaclava_blk"]];

if (_hasGM) then {
    (_loadoutData get "fullmask") append [
        "gm_ge_facewear_stormhood_blk",
        "gm_ge_facewear_stormhood_dustglasses_blk",
        "gm_ge_facewear_stormhood_brd"
    ];
};

if (_hasSOG) then {
    (_loadoutData get "fullmask") append ["vn_b_acc_m17_02","vn_b_acc_m17_01"];
};

_loadoutData set ["headgear", [
    "H_Shemag_olive",
    "H_Booniehat_oli",
    "H_Beret_blk",
    "H_Cap_oli",
    "H_Cap_headphones",
	"H_Watchcap_camo"
]];

if (_hasGM) then {
	(_loadoutData get "headgear") append [
        "gm_ge_headgear_headset_crew_oli",
        "gm_ge_headgear_beret_crew_blk",
        "gm_xx_headgear_headwrap_crew_01_grn",
        "gm_ge_headgear_hat_beanie_crew_blk"
    ];
};

if (_hasCSLA) then {
	(_loadoutData get "headgear") append [
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
};

if (_hasContact) then {
	(_loadoutData get "headgear") append [
		"H_Booniehat_mgrn",
		"H_Booniehat_taiga", 
		"H_Booniehat_wdl", 
		"H_Booniehat_eaf", 
		"H_MilCap_grn", 
		"H_MilCap_taiga", 
		"H_MilCap_wdl", 
		"H_MilCap_eaf"
	];
};

if (_hasWs) then {
	(_loadoutData get "headgear") append [
		"lxWS_H_Headset",
		"H_Beret_Headset_lxWS"	
	];
};

if (_hasGM) then {
	(_loadoutData get "headgear") append [        
		"gm_ge_headgear_headset_crew_oli",
        "gm_gc_headgear_fjh_model4_oli",
        "gm_ge_headgear_m92_cover_glasses_oli",
        "gm_ge_headgear_m92_cover_oli"
	];
};

if (_hasSOG) then {
	(_loadoutData get "headgear") append [
		"vn_b_headband_02",
        "vn_b_headband_04",
        "vn_c_headband_01",
        "vn_c_headband_02",
		"vn_b_headband_01",
        "vn_b_headband_08",
        "vn_b_headband_05",
        "vn_c_headband_03",
		"vn_c_headband_04",
        "vn_b_headband_03",
        "vn_o_cap_02",
        "vn_o_cap_01",
		"vn_o_cap_03",
        "vn_o_cap_navy_01",
        "vn_o_pl_cap_01_01",
        "vn_o_pl_cap_02_01",
		"vn_o_pl_cap_02_02",
        "vn_o_boonie_vc_02_01",
        "vn_o_boonie_vc_02_02",
        "vn_o_boonie_nva_02_01",
		"vn_o_boonie_nva_02_02",
        "vn_o_boonie_vc_01_01",
        "vn_o_boonie_vc_01_02",
        "vn_b_boonie_01_02",
		"vn_b_boonie_01_05",
        "vn_b_boonie_01_04",
        "vn_b_boonie_01_07",
        "vn_b_boonie_01_09",
		"vn_b_boonie_01_01",
        "vn_b_boonie_01_08",
        "vn_b_boonie_01_06",
        "vn_b_boonie_01_03",
		"vn_b_boonie_05_02",
        "vn_b_boonie_05_05",
        "vn_b_boonie_05_04",
        "vn_b_boonie_05_07",
		"vn_b_boonie_05_09",
        "vn_b_boonie_05_01",
        "vn_b_boonie_05_08",
        "vn_b_boonie_05_06",
		"vn_b_boonie_05_03",
        "vn_b_boonie_04_02",
        "vn_b_boonie_04_05",
        "vn_b_boonie_04_04",
		"vn_b_boonie_04_07",
        "vn_b_boonie_04_09",
        "vn_b_boonie_04_01",
        "vn_b_boonie_04_08",
		"vn_b_boonie_04_06",
        "vn_b_boonie_04_03",
        "vn_b_boonie_03_02",
        "vn_b_boonie_03_05",
		"vn_b_boonie_03_04",
        "vn_b_boonie_03_07",
        "vn_b_boonie_03_09",
        "vn_b_boonie_03_01",
		"vn_b_boonie_03_08",
        "vn_b_boonie_03_06",
        "vn_b_boonie_03_03",
        "vn_b_boonie_02_02",
		"vn_b_boonie_02_05",
        "vn_b_boonie_02_04",
        "vn_b_boonie_09_02",
        "vn_b_boonie_09_05",
		"vn_b_boonie_09_04",
        "vn_b_boonie_09_09",
        "vn_b_boonie_09_01",
        "vn_b_boonie_09_08",
		"vn_b_boonie_09_06",
        "vn_b_boonie_09_07",
        "vn_b_boonie_09_03",
        "vn_b_boonie_02_07",
		"vn_b_boonie_02_09",
        "vn_b_boonie_02_01",
        "vn_b_boonie_02_08",
        "vn_b_boonie_02_06",
		"vn_b_boonie_02_03",
        "vn_b_boonie_06_01",
        "vn_b_boonie_06_02",
        "vn_b_boonie_07_01",
		"vn_b_boonie_07_02",
        "vn_b_boonie_08_01",
        "vn_b_boonie_08_02",
		"vn_b_beret_01_06",
        "vn_b_beret_01_07",
        "vn_b_beret_04_01",
        "vn_b_beret_01_08",
		"vn_b_beret_01_04",
        "vn_b_beret_01_05",
        "vn_b_bandana_02",
        "vn_b_bandana_05",
		"vn_b_bandana_04",
        "vn_b_bandana_07",
        "vn_b_bandana_01",
        "vn_b_bandana_08",
		"vn_b_bandana_06",
        "vn_b_bandana_03"
	];
};

if (_hasSPE) then {
	(_loadoutData get "headgear") append [
		"H_SPE_CIV_Worker_Cap_1",
        "H_SPE_CIV_Worker_Cap_2",
        "H_SPE_CIV_Worker_Cap_3"
	];
};

_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];
_loadoutData set ["radios", ["ItemRadio"]];
_loadoutData set ["gpses", ["ItemGPS"]];
_loadoutData set ["NVGs", ["NVGoggles_INDEP"]];
_loadoutData set ["binoculars", ["Binocular"]];
_loadoutData set ["Rangefinder", ["Rangefinder"]];

/////Vests
private _vests = ["V_Chestrig_oli", "V_TacChestrig_oli_F", "V_TacVest_oli", "V_HarnessOGL_brn", "V_HarnessO_brn"];

if (_hasApex) then {
	_vests append ["V_TacChestrig_cbr_F", "V_TacChestrig_grn_F", "V_TacChestrig_oli_F"];
};

if (_hasWs) then {
	_vests pushback "V_lxWS_HarnessO_oli";
};

if (_hasContact) then {
	_vests append ["V_SmershVest_01_F", "V_SmershVest_01_radio_F"];
};

if (_hasLawsOfWar) then {
	_vests append ["V_Pocketed_black_F", "V_Pocketed_coyote_F", "V_Pocketed_olive_F"];
};

if (_hasGM) then {
	_vests append [
	"gm_ge_vest_90_crew_flk", 
	"gm_ge_vest_90_demolition_flk", 
	"gm_ge_vest_90_leader_flk", 
	"gm_ge_vest_90_machinegunner_flk", 
	"gm_ge_vest_90_medic_flk", 
	"gm_ge_vest_90_officer_flk" ,
	"gm_ge_vest_90_rifleman_flk",
	"gm_gc_vest_combatvest3_str",
	"gm_gc_army_vest_80_at_str",
	"gm_gc_bgs_vest_80_border_str",
	"gm_ge_bgs_vest_80_rifleman",
	"gm_dk_army_vest_54_crew",
	"gm_ge_army_vest_80_demolition",
	"gm_ge_army_vest_80_leader",
	"gm_gc_army_vest_80_leader_str",
	"gm_ge_army_vest_80_leader_smg",
	"gm_ge_army_vest_80_machinegunner",
	"gm_gc_army_vest_80_lmg_str",
	"gm_dk_army_vest_54_machinegunner",
	"gm_ge_army_vest_80_medic",
	"gm_ge_army_vest_80_rifleman",
	"gm_gc_army_vest_80_rifleman_str",
	"gm_dk_army_vest_54_rifleman",
	"gm_ge_vest_sov_80_blk",
	"gm_ge_vest_sov_80_oli",
	"gm_ge_vest_sov_80_wdl",
	"gm_pl_army_vest_80_at_gry",
	"gm_pl_army_vest_80_leader_gry",
	"gm_pl_army_vest_80_mg_gry",
	"gm_pl_army_vest_80_rifleman_gry",
	"gm_pl_army_vest_80_rifleman_smg_gry"
	];
};

if (_hasCSLA) then {
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
};

if (_hasSOG) then {
	_vests append [
	"vn_o_vest_vc_02", 
	"vn_o_vest_vc_03", 
	"vn_o_vest_vc_04", 
	"vn_o_vest_vc_05", 
	"vn_o_vest_vc_01", 
	"vn_b_vest_usmc_07",
	"vn_b_vest_usmc_08",
	"vn_b_vest_usmc_09",
	"vn_b_vest_sog_04",
	"vn_b_vest_sog_01",
	"vn_b_vest_sog_02",
	"vn_b_vest_sog_06",
	"vn_b_vest_sog_05",
	"vn_b_vest_sog_03",
	"vn_b_vest_seal_05",
	"vn_b_vest_seal_03",
	"vn_b_vest_sas_01",
	"vn_b_vest_sas_04",
	"vn_b_vest_sas_03",
	"vn_b_vest_sas_02",
	"vn_o_vest_08",
	"vn_o_vest_02",
	"vn_o_vest_07",
	"vn_o_vest_03",
	"vn_o_vest_06",
	"vn_o_vest_01",
	"vn_b_vest_usarmy_04",
	"vn_b_vest_usarmy_03",
	"vn_b_vest_usarmy_02",
	"vn_b_vest_usarmy_09",
	"vn_b_vest_usarmy_06",
	"vn_b_vest_usarmy_07",
	"vn_b_vest_usarmy_08",
	"vn_b_vest_usarmy_05",
	"vn_b_vest_usarmy_10",
	"vn_b_vest_anzac_03",
	"vn_b_vest_anzac_02",
	"vn_b_vest_anzac_01",
	"vn_b_vest_anzac_07",
	"vn_b_vest_anzac_05",
	"vn_b_vest_anzac_06",
	"vn_b_vest_anzac_04"
	];
};

if (_hasSPE) then {
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
};

private _heavyVests = ["V_TacVestIR_blk", "V_Press_F", "V_PlateCarrierIAGL_oli", "V_I_G_resistanceLeader_F", "V_TacVest_blk_POLICE","V_PlateCarrier1_blk","V_PlateCarrier2_blk"];

if (_hasApex) then {
	_heavyVests append ["V_TacVest_gen_F","V_PlateCarrier1_rgr_noflag_F","V_PlateCarrier2_rgr_noflag_F"];
};

if (_hasWs) then {
	_heavyVests pushBack "V_lxWS_TacVestIR_oli";
};

if (_hasRF) then {
	_heavyVests append ["V_PlateCarrierLite_black_noFlag_RF","V_TacVest_rig_oli_RF","V_TacVest_rig_khk_RF","V_TacVest_rig_blk_RF"];
};

if (_hasContact) then {
	_heavyVests append ["V_CarrierRigKBT_01_EAF_F", "V_CarrierRigKBT_01_Olive_F","V_CarrierRigKBT_01_light_Olive_F","V_CarrierRigKBT_01_heavy_Olive_F"];
};

if (_hasJets) then {
	_heavyVests pushBack "V_DeckCrew_brown_F";
};

if (_hasGM) then {
	_heavyVests append [
	"gm_ge_army_vest_pilot_oli", 
	"gm_ge_vest_armor_90_flk", 
	"gm_ge_vest_armor_90_crew_flk",
	"gm_ge_vest_armor_90_demolition_flk",
	"gm_ge_vest_armor_90_leader_flk",
	"gm_ge_vest_armor_90_machinegunner_flk",
	"gm_ge_vest_armor_90_medic_flk",
	"gm_ge_vest_armor_90_officer_flk",
	"gm_ge_vest_armor_90_rifleman_flk",
	"gm_dk_army_vest_m00_m84",
	"gm_dk_army_vest_m00_wdl",
	"gm_dk_army_vest_m00_m84_machinegunner",
	"gm_dk_army_vest_m00_m84_rifleman",
	"gm_dk_army_vest_m00_wdl_rifleman",
	"gm_ge_vest_sov_armor_80_blk",
	"gm_ge_vest_sov_armor_80_oli",
	"gm_ge_vest_sov_armor_80_wdl",
	"gm_ge_army_vest_type18_dpm",
	"gm_ge_bgs_vest_type18_blk",
	"gm_ge_bgs_vest_type18_grn",
	"gm_ge_bgs_vest_type3_oli",
	"gm_ge_bgs_vest_type3_gry",
	"gm_ge_bgs_vest_type3a1_oli",
	"gm_ge_bgs_vest_type3a1_gry"
	];
};

if (_hasCSLA) then {
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
};

if (_hasSOG) then {
	_heavyVests append [
	"vn_b_vest_usmc_02", 
	"vn_b_vest_usmc_01", 
	"vn_b_vest_usmc_06",
	"vn_b_vest_usmc_03",
	"vn_b_vest_usmc_04",
	"vn_b_vest_usmc_05",
	"vn_b_vest_usarmy_14",
	"vn_b_vest_usarmy_13",
	"vn_b_vest_usarmy_12",
	"vn_b_vest_usarmy_11",
	"vn_b_vest_anzac_08",
	"vn_b_vest_anzac_09",
	"vn_b_vest_aircrew_01"
	];
};

/////Uniforms
_loadoutData set ["uniforms", [
	"U_I_C_Soldier_Para_4_F",
	"U_I_C_Soldier_Para_2_F",
	"U_I_C_Soldier_Para_3_F",
	"U_I_C_Soldier_Para_1_F",
	"U_I_C_Soldier_Camo_F",
	"U_I_C_Soldier_Bandit_3_F",
    "U_I_C_Soldier_Bandit_2_F"
]];

if (_hasWs) then {
	(_loadoutData get "uniforms") append [
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
};

if (_hasContact) then {
	(_loadoutData get "uniforms") append [
        "U_I_E_Uniform_01_sweater_F",
        "U_I_E_Uniform_01_tanktop_F",
        "U_I_L_Uniform_01_camo_F",
        "U_I_L_Uniform_01_deserter_F",
		"U_C_E_LooterJacket_01_F",
		"U_I_L_Uniform_01_tshirt_olive_F"
    ];
};

if (_hasGM) then {
	(_loadoutData get "uniforms") append [
        "gm_ge_uniform_soldier_tshirt_90_oli",
        "gm_ge_uniform_soldier_tshirt_90_flk",
        "gm_xx_uniform_soldier_bdu_80_oli",
        "gm_xx_uniform_soldier_bdu_nogloves_80_oli",
		"gm_xx_uniform_soldier_bdu_rolled_80_oli",
		"gm_pl_army_uniform_soldier_80_moro",
		"gm_pl_army_uniform_soldier_autumn_80_moro",
		"gm_pl_army_uniform_soldier_rolled_80_moro",
		"gm_xx_army_uniform_fighter_04_grn",
		"gm_xx_army_uniform_fighter_02_oli",
		"gm_xx_army_uniform_fighter_02_wdl",
		"gm_xx_army_uniform_fighter_04_wdl"
    ];
};

if (_hasCSLA) then {
	(_loadoutData get "uniforms") append [
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
};

if (_hasSOG) then {
	(_loadoutData get "uniforms") append [
        "vn_o_uniform_vc_mf_04_07",
        "vn_o_uniform_vc_mf_03_07",
        "vn_o_uniform_vc_mf_02_07",
        "vn_o_uniform_vc_mf_01_07",
		"vn_b_uniform_seal_06_02",
		"vn_b_uniform_seal_05_07",
		"vn_b_uniform_seal_02_01",
		"vn_b_uniform_seal_01_01",
		"vn_o_uniform_pl_army_04_14",
		"vn_o_uniform_pl_army_04_13",
        "vn_o_uniform_pl_army_04_12",
        "vn_o_uniform_pl_army_04_11",
        "vn_o_uniform_pl_army_03_14",
		"vn_o_uniform_pl_army_03_13",
		"vn_o_uniform_pl_army_03_12",
		"vn_o_uniform_pl_army_03_11",
		"vn_o_uniform_pl_army_02_14",
		"vn_o_uniform_pl_army_02_13",
		"vn_o_uniform_pl_army_02_12",
        "vn_o_uniform_pl_army_02_11",
        "vn_o_uniform_pl_army_01_14",
        "vn_o_uniform_pl_army_01_13",
		"vn_o_uniform_pl_army_01_12",
		"vn_o_uniform_pl_army_01_11",
		"vn_o_uniform_nva_army_08_04",
		"vn_o_uniform_nva_army_08_03",
		"vn_o_uniform_nva_army_07_04",
		"vn_o_uniform_nva_army_07_03",
        "vn_o_uniform_nva_army_06_04",
        "vn_o_uniform_nva_army_06_03",
        "vn_o_uniform_nva_army_05_04",
		"vn_o_uniform_nva_army_05_03",
		"vn_o_uniform_nva_army_04_04",
		"vn_o_uniform_nva_army_04_03",
		"vn_o_uniform_nva_army_03_04",
		"vn_o_uniform_nva_army_03_03",
		"vn_o_uniform_nva_army_02_04",
		"vn_o_uniform_nva_army_02_03",
		"vn_o_uniform_nva_army_01_04",
		"vn_o_uniform_nva_army_01_03",
		"vn_o_uniform_nva_army_04_02",
		"vn_o_uniform_nva_army_04_01",
		"vn_o_uniform_nva_army_03_02",
		"vn_o_uniform_nva_army_03_01",
		"vn_o_uniform_nva_army_02_02",
		"vn_o_uniform_nva_army_02_01",
		"vn_o_uniform_nva_army_01_02",
		"vn_o_uniform_nva_army_01_01",
		"vn_b_uniform_heli_01_01",
		"vn_b_uniform_sog_02_05",
		"vn_b_uniform_sog_02_02",
		"vn_b_uniform_sog_02_06",
		"vn_b_uniform_sog_02_04",
		"vn_b_uniform_sog_02_01",
		"vn_b_uniform_sog_02_03",
		"vn_b_uniform_sog_01_05",
		"vn_b_uniform_sog_01_02",
		"vn_b_uniform_sog_01_06",
		"vn_b_uniform_sog_01_04",
		"vn_b_uniform_sog_01_01",
		"vn_b_uniform_sog_01_03",
		"vn_b_uniform_sas_03_06",
		"vn_b_uniform_sas_02_06",
		"vn_b_uniform_sas_01_06",
		"vn_b_uniform_macv_06_18",
		"vn_b_uniform_macv_05_18",
		"vn_b_uniform_macv_04_18",
		"vn_b_uniform_macv_03_18",
		"vn_b_uniform_macv_02_18",
		"vn_b_uniform_macv_01_18",
		"vn_b_uniform_macv_06_16",
		"vn_b_uniform_macv_05_16",
		"vn_b_uniform_macv_04_16",
		"vn_b_uniform_macv_03_16",
		"vn_b_uniform_macv_02_16",
		"vn_b_uniform_macv_01_16",
		"vn_b_uniform_nz_06_01",
		"vn_b_uniform_nz_05_01",
		"vn_b_uniform_nz_04_01",
		"vn_b_uniform_nz_03_01",
		"vn_b_uniform_nz_02_01",
		"vn_b_uniform_nz_01_01",
		"vn_b_uniform_macv_06_02",
		"vn_b_uniform_macv_06_05",
		"vn_b_uniform_macv_06_01",
		"vn_b_uniform_macv_06_07",
		"vn_b_uniform_macv_06_08",
		"vn_b_uniform_macv_06_06",
		"vn_b_uniform_macv_06_15",
		"vn_b_uniform_macv_05_02",
		"vn_b_uniform_macv_05_05",
		"vn_b_uniform_macv_05_01",
		"vn_b_uniform_macv_05_07",
		"vn_b_uniform_macv_05_08",
		"vn_b_uniform_macv_05_06",
		"vn_b_uniform_macv_01_26",
		"vn_b_uniform_macv_05_15",
		"vn_b_uniform_macv_04_20",
		"vn_b_uniform_macv_04_02",
		"vn_b_uniform_macv_04_05",
		"vn_b_uniform_macv_04_01",
		"vn_b_uniform_macv_04_07",
		"vn_b_uniform_macv_04_08",
		"vn_b_uniform_macv_04_06",
		"vn_b_uniform_macv_01_25",
		"vn_b_uniform_macv_04_21",
		"vn_b_uniform_macv_04_15",
		"vn_b_uniform_macv_03_02",
		"vn_b_uniform_macv_03_05",
		"vn_b_uniform_macv_03_01",
		"vn_b_uniform_macv_03_07",
		"vn_b_uniform_macv_03_08",
		"vn_b_uniform_macv_03_06",
		"vn_b_uniform_macv_01_24",
		"vn_b_uniform_macv_03_15",
		"vn_b_uniform_macv_02_02",
		"vn_b_uniform_macv_02_05",
		"vn_b_uniform_macv_02_01",
		"vn_b_uniform_macv_02_07",
		"vn_b_uniform_macv_02_08",
		"vn_b_uniform_macv_02_06",
		"vn_b_uniform_macv_01_23",
		"vn_b_uniform_macv_02_15",
		"vn_b_uniform_macv_01_02",
		"vn_b_uniform_macv_01_05",
		"vn_b_uniform_macv_01_04",
		"vn_b_uniform_macv_01_01",
		"vn_b_uniform_macv_01_07",
		"vn_b_uniform_macv_01_08",
		"vn_b_uniform_macv_01_06",
		"vn_b_uniform_macv_01_22",
		"vn_b_uniform_macv_01_15",
		"vn_b_uniform_macv_01_03",
		"vn_b_uniform_aus_09_01",
		"vn_b_uniform_aus_08_01",
		"vn_b_uniform_aus_07_01",
		"vn_b_uniform_aus_06_01",
		"vn_b_uniform_aus_05_01",
		"vn_b_uniform_aus_04_01",
		"vn_b_uniform_aus_03_01",
		"vn_b_uniform_aus_02_01",
		"vn_b_uniform_aus_10_01",
		"vn_b_uniform_aus_01_01",
		"vn_b_uniform_macv_06_17",
		"vn_b_uniform_macv_05_17",
		"vn_b_uniform_macv_04_17",
		"vn_b_uniform_macv_03_17",
		"vn_b_uniform_macv_02_17",
		"vn_b_uniform_macv_01_17"
    ];
};

if (_hasSPE) then {
	(_loadoutData get "uniforms") append [
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
};

_loadoutData set ["heavyUniforms", []]; ///don't know why it's here but could be useful in the future

if (_hasContact) then {
	(_loadoutData get "heavyUniforms") append [
        "U_O_R_Gorka_01_F",
        "U_O_R_Gorka_01_brown_F",
        "U_O_R_Gorka_01_camo_F"
    ];
};

/////Helmets
private _helmets = ["H_HelmetB"]; ///look for more helmets

if (_hasWs) then {
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
	];
};

if (_hasRF) then {
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
	];
};

if (_hasLawsOfWar) then {
	_helmets append ["H_PASGT_basic_black_F", "H_PASGT_basic_blue_F", "H_PASGT_basic_olive_F", "H_PASGT_neckprot_blue_press_F", "H_PASGT_basic_blue_press_F","H_HeadBandage_clean_F", "H_HeadBandage_stained_F", "H_HeadBandage_bloody_F"];
};

if (_hasContact) then {
	_helmets append ["H_HelmetAggressor_F", "H_HelmetAggressor_cover_F", "H_HelmetAggressor_cover_taiga_F"];
};

if (_hasGM) then {
	_helmets append [
        "gm_ge_headgear_psh77_oli",
        "gm_ge_headgear_psh77_up_oli",
        "gm_ge_headgear_psh77_down_oli",
		"gm_ge_bgs_headgear_psh77_cover_smp",
		"gm_ge_bgs_headgear_psh77_cover_up_smp",
		"gm_ge_bgs_headgear_psh77_cover_down_smp",
		"gm_ge_bgs_headgear_psh77_cover_str",
		"gm_ge_bgs_headgear_psh77_cover_up_str",
		"gm_ge_bgs_headgear_psh77_cover_down_str"
    ]; 
};

if (_hasCSLA) then {
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
	];
};

if (_hasSOG) then {
	_helmets append [        
		"vn_o_helmet_nva_08",
        "vn_o_helmet_nva_06",
        "vn_o_helmet_vc_02",
        "vn_o_helmet_vc_05",
		"vn_o_helmet_vc_03",
        "vn_o_helmet_vc_04",
        "vn_o_helmet_vc_01",
        "vn_b_helmet_sog_01",
		"vn_o_helmet_nva_02",
        "vn_o_helmet_nva_07",
        "vn_o_helmet_nva_05",
        "vn_o_helmet_nva_03",
		"vn_o_helmet_nva_04",
        "vn_o_helmet_nva_01",
        "vn_c_conehat_01",
        "vn_c_conehat_02",
		"vn_o_helmet_tsh3_01",
        "vn_o_helmet_tsh3_02",
        "vn_o_helmet_nva_09",
        "vn_o_helmet_shl61_01",
		"vn_o_helmet_shl61_02",
        "vn_o_helmet_nva_10",
        "vn_b_helmet_m1_11_01",
        "vn_b_helmet_m1_10_01",
		"vn_b_helmet_m1_08_01",
        "vn_b_helmet_m1_08_02",
        "vn_b_helmet_m1_17_01",
        "vn_b_helmet_m1_17_02",
		"vn_b_helmet_m1_04_01",
        "vn_b_helmet_m1_04_02",
        "vn_b_helmet_m1_09_01",
        "vn_b_helmet_m1_09_02",
		"vn_b_helmet_m1_07_01",
        "vn_b_helmet_m1_07_02",
        "vn_b_helmet_m1_06_01",
        "vn_b_helmet_m1_06_02",
		"vn_b_helmet_m1_05_01",
        "vn_b_helmet_m1_05_02",
        "vn_b_helmet_m1_03_01",
        "vn_b_helmet_m1_03_02",
		"vn_b_helmet_m1_20_01",
        "vn_b_helmet_m1_20_02",
        "vn_b_helmet_m1_02_01",
        "vn_b_helmet_m1_02_02",
		"vn_b_helmet_m1_19_01",
        "vn_b_helmet_m1_19_02",
        "vn_b_helmet_m1_18_01",
        "vn_b_helmet_m1_18_02",
		"vn_b_helmet_m1_16_01",
        "vn_b_helmet_m1_16_02",
        "vn_b_helmet_m1_15_01",
        "vn_b_helmet_m1_15_02",
		"vn_b_helmet_m1_14_01",
        "vn_b_helmet_m1_14_02",
        "vn_i_helmet_m1_03_02",
        "vn_i_helmet_m1_02_02",
		"vn_b_helmet_m1_01_01",
        "vn_b_helmet_m1_12_02",
        "vn_b_helmet_m1_12_01",
        "vn_i_helmet_m1_01_02",
		"vn_i_helmet_m1_03_01",
        "vn_i_helmet_m1_02_01",
        "vn_i_helmet_m1_01_01",
        "vn_b_helmet_m1_01_02"
	];
};

if (_hasSPE) then {
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
	];
};

private _crewhelmets = ["H_Tank_black_F"];

if (_hasWs) then {
	_crewhelmets append ["lxWS_H_Tank_tan_F", "lxWS_H_HelmetCrew_I"];
};

if (_hasContact) then {
	_crewhelmets append ["H_Tank_eaf_F", "H_HelmetCrew_I_E", "H_Booniehat_wdl", "H_Booniehat_eaf"];
};

if (_hasLawsOfWar) then {
	_crewhelmets pushBack "H_Construction_headset_black_F";
};

if (_hasGM) then {
	_crewhelmets pushBack "gm_ge_headgear_headset_crew_oli";
};

if (_hasCSLA) then {
	_crewhelmets append ["US85_helmetDH132", "US85_helmetDH132G", "US85_helmetDH132G_on"];
};

if (_hasSOG) then {
	_crewhelmets append ["vn_b_beret_04_01", "vn_b_helmet_t56_01_01", "vn_b_helmet_t56_02_01","vn_b_helmet_t56_01_02","vn_b_helmet_t56_02_02","vn_b_helmet_t56_01_03","vn_b_helmet_t56_02_03","vn_o_helmet_tsh3_02","vn_o_helmet_tsh3_01"];
};

if (_hasSPE) then {
	_crewhelmets append ["H_SPE_US_Helmet_Tank_M1_Scrim","H_SPE_US_Helmet_Tank_M1_OS","H_SPE_US_Helmet_Tank_M1_NS"];
};

/////
private _offuniforms = ["U_I_C_Soldier_Camo_F"];
private _backpacks = ["B_AssaultPack_rgr","B_AssaultPack_cbr","B_AssaultPack_sgg","B_AssaultPack_khk","B_AssaultPack_blk","B_TacticalPack_oli","B_Carryall_oli","B_Kitbag_sgg","B_FieldPack_oli"];

if (_hasApex) then {
	_backpacks append ["B_ViperHarness_oli_F","B_ViperLightHarness_oli_F"];
};

if (_hasArtOfWar) then {
	_backpacks append ["B_CivilianBackpack_01_Everyday_Black_F","B_CivilianBackpack_01_Everyday_Astra_F","B_CivilianBackpack_01_Everyday_Vrana_F","B_CivilianBackpack_01_Sport_Green_F","B_CivilianBackpack_01_Sport_Red_F","B_CivilianBackpack_01_Sport_Blue_F"];
};

if (_hasContact) then {
	_backpacks append ["B_FieldPack_green_F","B_RadioBag_01_digi_F","B_RadioBag_01_black_F","B_Carryall_green_F"];
};

if (_hasRF) then {
	_backpacks append ["B_DuffleBag_Olive_NoLogo_RF","B_DuffleBag_Black_NoLogo_RF","B_DuffleBag_Sand_RF","B_DuffleBag_Red_RF","B_DuffleBag_Olive_RF","B_DuffleBag_Blue_RF","B_DuffleBag_Black_RF","B_DuffleBag_VRANA_RF"];
};

if (_hasLawsOfWar) then {
	_backpacks append ["B_Messenger_Olive_F","B_Messenger_Black_F","B_LegStrapBag_olive_F","B_LegStrapBag_black_F"];
};

if (_hasGM) then {
	_backpacks append ["gm_dk_army_backpack_73_oli","gm_ge_army_backpack_90_blk","gm_ge_army_backpack_90_oli","gm_ge_army_backpack_80_oli","gm_ge_backpack_sem35_oli","gm_pl_army_backpack_at_80_gry"];
};

if (_hasCSLA) then {
	_backpacks append ["US85_bpSf","FIA_bpPack", "US85_bpAlice"];
};

if (_hasSOG) then {
	_backpacks append [
		"vn_b_pack_m41_05",
		"vn_b_pack_m41_04",
		"vn_b_pack_m41_03",
		"vn_b_pack_m41_02",
		"vn_b_pack_m41_01",
		"vn_b_pack_trp_02",
		"vn_b_pack_trp_04",
		"vn_b_pack_trp_01",
		"vn_b_pack_trp_03",
		"vn_b_pack_01",
		"vn_b_pack_04",
		"vn_b_pack_03",
		"vn_b_pack_02",
		"vn_b_pack_05",
		"vn_o_pack_t884_01",
		"vn_o_pack_02",
		"vn_o_pack_01",
		"vn_o_pack_05",
		"vn_o_pack_03",
		"vn_o_pack_07",
		"vn_o_pack_06",
		"vn_o_pack_04",
		"vn_b_pack_01_02",
		"vn_b_pack_04_02",
		"vn_b_pack_03_02",
		"vn_b_pack_02_02",
		"vn_b_pack_05_02",
		"vn_b_pack_arvn_04",
		"vn_b_pack_arvn_03",
		"vn_b_pack_arvn_02",
		"vn_b_pack_arvn_01",
		"vn_b_pack_trp_02_02",
		"vn_b_pack_trp_04_02",
		"vn_b_pack_trp_01_02",
		"vn_b_pack_trp_03_02",
		"vn_b_pack_lw_03",
		"vn_b_pack_prc77_01",
		"vn_b_pack_lw_06",
		"vn_b_pack_lw_01",
		"vn_b_pack_lw_02",
		"vn_b_pack_lw_05",
		"vn_b_pack_lw_07",
		"vn_b_pack_m5_01",
		"vn_b_pack_lw_04",
		"vn_b_pack_p44_03",
		"vn_b_pack_p44_02",
		"vn_b_pack_p44_01",
		"vn_b_pack_p08_03",
		"vn_b_pack_p08_02",
		"vn_b_pack_p08_01",
		"vn_b_pack_pfield_02",
		"vn_b_pack_pfield_01"
	];
};

if (_hasSPE) then {
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
};

_loadoutData set ["offuniforms", _offuniforms]; ///check offuniforms later.
_loadoutData set ["vests", _vests];
_loadoutData set ["heavyVests", _heavyVests];
_loadoutData set ["backpacks", _backpacks]; ///check for backpacks later.
_loadoutData set ["helmets", _helmets];
_loadoutData set ["crewHelmets", _crewhelmets];

//Item *set* definitions. These are added in their entirety to unit loadouts. No randomisation is applied.
_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the basic medical loadout for vanilla
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the standard medical loadout for vanilla
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the medic medical loadout for vanilla
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

private _slItems = ["Laserbatteries", "Laserbatteries", "Laserbatteries"];
private _eeItems = ["ToolKit", "MineDetector"];
private _mmItems = [];

if (A3A_hasACE) then {
    _slItems append ["ACE_microDAGR", "ACE_DAGR"];
    _eeItems append ["ACE_Clacker", "ACE_DefusalKit"];
    _mmItems append ["ACE_RangeCard", "ACE_ATragMX", "ACE_Kestrel4500"];
};

_loadoutData set ["items_squadleader_extras", _slItems];
_loadoutData set ["items_rifleman_extras", []];
_loadoutData set ["items_medic_extras", []];
_loadoutData set ["items_grenadier_extras", []];
_loadoutData set ["items_explosivesExpert_extras", _eeItems];
_loadoutData set ["items_engineer_extras", _eeItems];
_loadoutData set ["items_lat_extras", []];
_loadoutData set ["items_at_extras", []];
_loadoutData set ["items_aa_extras", []];
_loadoutData set ["items_machineGunner_extras", []];
_loadoutData set ["items_marksman_extras", _mmItems];
_loadoutData set ["items_sniper_extras", _mmItems];
_loadoutData set ["items_police_extras", []];
_loadoutData set ["items_crew_extras", []];
_loadoutData set ["items_unarmed_extras", []];


//////////////////////////
//    Misc Loadouts     //
//////////////////////////

private _crewLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_crewLoadoutData set ["vests", _vests];
_crewLoadoutData set ["crewHelmets", _crewhelmets];

private _pilotLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_pilotLoadoutData set ["uniforms", ["U_Marshal","U_C_WorkerCoveralls","U_Rangemaster"]];
_pilotLoadoutData set ["vests", _vests];
_pilotLoadoutData set ["helmets", ["H_PilotHelmetHeli_O", "H_CrewHelmetHeli_O", "H_PilotHelmetHeli_B", "H_CrewHelmetHeli_B"]];

if (_hasRF) then {
	(_pilotLoadoutData get "uniforms") append [
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
};

if (_hasRF) then {
	(_pilotLoadoutData get "helmets") append [
        "H_PilotHelmetHeli_White_RF",
        "H_PilotHelmetHeli_Yellow_RF",
        "H_PilotHelmetHeli_Green_RF",
        "H_PilotHelmetHeli_Red_RF",
		"H_PilotHelmetHeli_MilGreen_RF",
		"H_PilotHelmetHeli_Orange_RF",
		"H_PilotHelmetHeli_Blue_RF",
		"H_PilotHelmetHeli_Black_RF"
    ];
};

if (_hasSOG) then {
	(_pilotLoadoutData get "uniforms") append [
        "vn_o_uniform_nva_air_01",
        "vn_b_uniform_k2b_02_03",
        "vn_b_uniform_k2b_01_04",
        "vn_b_uniform_k2b_01_05",
        "vn_b_uniform_k2b_01_02",
        "vn_b_uniform_k2b_02_04",
        "vn_b_uniform_k2b_02_05",
        "vn_b_uniform_k2b_02_02",
        "vn_b_uniform_k2b_01_01",
        "vn_b_uniform_k2b_02_01",
        "vn_b_uniform_k2b_03_01",
		"vn_b_uniform_heli_01_01",
		"vn_b_uniform_k2b_03_02"
    ];
};

if (_hasSOG) then {
	(_pilotLoadoutData get "helmets") append [
        "vn_o_helmet_zsh3_02",
        "vn_o_helmet_zsh3_01",
        "vn_b_helmet_svh4_02_05",
        "vn_b_helmet_svh4_01_05",
		"vn_b_helmet_svh4_02_02",
		"vn_b_helmet_svh4_01_02",
		"vn_b_helmet_svh4_02_04",
		"vn_b_helmet_svh4_01_04",
		"vn_b_helmet_svh4_02_01",
		"vn_b_helmet_svh4_01_01",
		"vn_b_helmet_aph6_02_01",
		"vn_b_helmet_aph6_01_01",
		"vn_b_helmet_aph6_02_04",
		"vn_b_helmet_aph6_01_04",
		"vn_b_helmet_aph6_02_03",
		"vn_b_helmet_aph6_01_03",
		"vn_b_helmet_aph6_02_05",
		"vn_b_helmet_aph6_01_05",
		"vn_b_helmet_aph6_02_02",
		"vn_b_helmet_aph6_01_02"
    ];
};

if (_hasSPE) then {
	(_pilotLoadoutData get "uniforms") append [
        "U_SPE_US_S31A_glove",
        "U_SPE_US_S31A",
        "U_SPE_US_S31_erla_glove",
        "U_SPE_US_S31_erla",
        "U_SPE_US_Pilot_glove",
        "U_SPE_US_Pilot",
        "U_SPE_US_Pilot_lthr_glove",
        "U_SPE_US_Pilot_lthr"
    ];
};

// ##################### DO NOT TOUCH ANYTHING BELOW THIS LINE #####################


/////////////////////////////////
//    Unit Type Definitions    //
/////////////////////////////////
//These define the loadouts for different unit types.
//For example, rifleman, grenadier, squad leader, etc.
//In 95% of situations, you *should not need to edit these*.
//Almost all factions can be set up just by modifying the loadout data above.
//However, these exist in case you really do want to do a lot of custom alterations.

private _cellLeaderTemplate = {
	if (random 100 > 60) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	[selectRandom ["vests", "heavyVests"]] call _fnc_setVest;
	[["offuniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;

	[selectRandom ["grenadeLaunchers", "rifles"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;
	["primary", 5] call _fnc_addAdditionalMuzzleMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_squadLeader_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;
	["signalsmokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["gpses"] call _fnc_addGPS;
	["binoculars"] call _fnc_addBinoculars;
	["NVGs"] call _fnc_addNVGs;
};

private _mercenaryTemplate = {
	["helmets"] call _fnc_setHelmet;
	[selectRandomWeighted [[], 1.5, "facewear", 1, "fullmask", 1]] call _fnc_setFacewear;
	["heavyVests"] call _fnc_setVest;
	[["heavyUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;

	[selectRandom ["grenadeLaunchers", "rifles", "tunedRifles"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_squadLeader_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;
	["signalsmokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["gpses"] call _fnc_addGPS;
	["binoculars"] call _fnc_addBinoculars;
	["NVGs"] call _fnc_addNVGs;
};

private _enforcerTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	[["enforcerRifles", "rifles"] call _fnc_fallback] call _fnc_setPrimary;
	["primary", 4] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_squadLeader_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;
	["signalsmokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["gpses"] call _fnc_addGPS;
	["binoculars"] call _fnc_addBinoculars;
	["NVGs"] call _fnc_addNVGs;
};

private _partisanTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	if (random 1 < 0.15) then {
		["backpacks"] call _fnc_setBackpack;
		["lightHELaunchers"] call _fnc_setLauncher;
		["launcher", 3] call _fnc_addMagazines;
	} else {
		["sidearms"] call _fnc_setHandgun;
		["handgun", 2] call _fnc_addMagazines;
	};

	[selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_rifleman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _minutemanTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	[selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_rifleman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _medicTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

  	["carbines"] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_medic"] call _fnc_addItemSet;
	["items_medic_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _saboteurTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	[selectRandom ["vests", "heavyVests"]] call _fnc_setVest;
	[["heavyUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["grenadeLaunchers"] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;
	["primary", 10] call _fnc_addAdditionalMuzzleMagazines;

	if (random 1 < 0.15) then {
		["lightHELaunchers"] call _fnc_setLauncher;
		["launcher", 2] call _fnc_addMagazines;
	} else {
		["sidearms"] call _fnc_setHandgun;
		["handgun", 2] call _fnc_addMagazines;
	};

	["items_medical_standard"] call _fnc_addItemSet;
	["items_grenadier_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 4] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _explosivesExpertTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["heavyVests"] call _fnc_setVest;
	[["heavyUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	[selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_explosivesExpert_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;

	["lightExplosives", 2] call _fnc_addItem;
	if (random 1 > 0.5) then {["heavyExplosives", 1] call _fnc_addItem;};
	if (random 1 > 0.5) then {["atMines", 1] call _fnc_addItem;};
	if (random 1 > 0.5) then {["apMines", 1] call _fnc_addItem;};

	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _atTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	[selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["lightATLaunchers"] call _fnc_setLauncher;
	//TODO - Add a check if it's disposable.
	["launcher", 3] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_at_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _aaTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	[selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["AALaunchers"] call _fnc_setLauncher;
	//TODO - Add a check if it's disposable.
	["launcher", 3] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_aa_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _oppressorTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["machineGuns"] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_machineGunner_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _sharpshooterTemplate = {
	if (random 100 < 30) then {
		["helmets"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "fullmask", 1]] call _fnc_setFacewear;
	} else {
		["headgear"] call _fnc_setHelmet;
		[selectRandomWeighted [[], 1.5, "facewear", 1]] call _fnc_setFacewear;
	};
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;


	["marksmanRifles"] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_marksman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["Rangefinder"] call _fnc_addBinoculars;
	["NVGs"] call _fnc_addNVGs;
};

private _crewTemplate = {
	["crewHelmets"] call _fnc_setHelmet;
	[selectRandomWeighted [[], 1.5, "fullmask", 1.25, "facewear", 1]] call _fnc_setFacewear;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["carbines"] call _fnc_setPrimary;
	["primary", 3] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_basic"] call _fnc_addItemSet;
	["items_crew_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["gpses"] call _fnc_addGPS;
	["NVGs"] call _fnc_addNVGs;
};

private _unarmedTemplate = {
	["vests"] call _fnc_setVest;
	[selectRandomWeighted [[], 1.5, "facewear", 1, "fullmask", 1]] call _fnc_setFacewear;
	["uniforms"] call _fnc_setUniform;

	["items_medical_basic"] call _fnc_addItemSet;
	["items_unarmed_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _commanderTemplate = {
	[selectRandomWeighted ["helmets", 0.3, "headgear", 0.7]] call _fnc_setHelmet;
	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["vests"] call _fnc_setVest;
	[["offuniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;

	["items_medical_basic"] call _fnc_addItemSet;
	["items_unarmed_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

////////////////////////////////////////////////////////////////////////////////////////
//  You shouldn't touch below this line unless you really really know what you're doing.
//  Things below here can and will break the gamemode if improperly changed.
////////////////////////////////////////////////////////////////////////////////////////

///////////////////////
//  Rivals Units     //
///////////////////////
private _prefix = "militia";
private _unitTypes = [
	["CellLeader", _cellLeaderTemplate, [], [_prefix, true]],
	["Mercenary", _mercenaryTemplate, [], [_prefix, true]],
	["Minuteman", _minutemanTemplate, [], [_prefix, true]],
	["Enforcer", _enforcerTemplate, [], [_prefix, true]],
	["Partisan", _partisanTemplate, [], [_prefix, true]],
	["Saboteur", _saboteurTemplate, [], [_prefix, true]],
	["Medic", _medicTemplate, [["medic", true]], [_prefix, true]],
	["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true]], [_prefix, true]],
	["SpecialistAT", _atTemplate, [], [_prefix, true]],
	["SpecialistAA", _aaTemplate, [], [_prefix, true]],
	["Oppressor", _oppressorTemplate, [], [_prefix, true]],
	["Sharpshooter", _sharpshooterTemplate, [], [_prefix, true]]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

//////////////////////
//    Misc Units    //
//////////////////////
[_prefix, [["Crew", _crewTemplate, [], [_prefix, true]]], _crewLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
[_prefix, [["Pilot", _crewTemplate, [], [_prefix, true]]], _pilotLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
[_prefix, [["Commander", _commanderTemplate, [], [_prefix, true]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
[_prefix, [["Unarmed", _unarmedTemplate, [], [_prefix, true]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

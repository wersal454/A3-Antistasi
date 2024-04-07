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
private _hasRF = "rf" in A3A_enabledDLC;

///////////////////////////
//   Rebel Information   //
///////////////////////////

["name", "FIA"] call _fnc_saveToTemplate;

["flag", "Flag_FIA_F"] call _fnc_saveToTemplate;
["flagTexture", "a3\data_f\flags\flag_fia_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "flag_FIA"] call _fnc_saveToTemplate;

private _vehiclesBasic = ["I_G_Quadbike_01_F"];
private _vehiclesLightUnarmed = ["I_G_Offroad_01_F"];
private _vehiclesLightArmed = ["I_G_Offroad_01_armed_F"];
private _vehiclesAt = ["I_G_Offroad_01_AT_F"];
private _VehTruck = ["I_G_Van_01_transport_F"];
private _vehicleAA = [];

["vehiclesBoat", ["I_C_Boat_Transport_02_F"]] call _fnc_saveToTemplate;

private _vehiclePlane = [];
if (_hasApex) then {
    _vehiclePlane append ["C_Plane_Civil_01_F","C_Plane_Civil_01_racing_F"];
};

private _vehiclesCivCar = ["C_Offroad_01_F", "C_Hatchback_01_F", "C_Hatchback_01_sport_F", "C_SUV_01_F"];
private _CivTruck = ["C_Truck_02_transport_F", "C_Truck_02_covered_F"];
private _vehiclesCivHeli = ["C_Heli_Light_01_civil_F", "a3a_C_Heli_Transport_02_F"];

private _CivBoat = ["C_Boat_Civil_01_F", "C_Rubberboat"];

["staticMGs", ["I_G_HMG_02_high_F", "I_G_HMG_02_F"]] call _fnc_saveToTemplate;
["staticAT", ["I_static_AT_F"]] call _fnc_saveToTemplate;
private _staticAA = ["I_static_AA_F"];
private _staticMortars = ["I_G_Mortar_01_F"];
["staticMortarMagHE", "8Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["staticMortarMagSmoke", "8Rnd_82mm_Mo_Smoke_white"] call _fnc_saveToTemplate;

["minesAT", ["ATMine_Range_Mag", "SLAMDirectionalMine_Wire_Mag"]] call _fnc_saveToTemplate;
["minesAPERS", ["ClaymoreDirectionalMine_Remote_Mag","APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag", "APERSTripMine_Wire_Mag"]] call _fnc_saveToTemplate;

["breachingExplosivesAPC", [["DemoCharge_Remote_Mag", 1]]] call _fnc_saveToTemplate;
["breachingExplosivesTank", [["SatchelCharge_Remote_Mag", 1], ["DemoCharge_Remote_Mag", 2]]] call _fnc_saveToTemplate;

if (_hasRF) then {
    _vehiclesCivCar = ["C_Pickup_rf", "C_Pickup_covered_rf"];
    _vehiclesCivHeli = ["C_Heli_EC_01A_civ_RF", "C_Heli_EC_01_civ_RF"];
    _vehiclesLightArmed = ["a3u_black_Pickup_mmg_alt_rf", "a3u_black_Pickup_mmg_frame_rf"];
    _vehiclesLightUnarmed append ["a3a_black_Pickup_rf"];
};

if (_hasApex) then {
    _vehiclesCivCar pushBack "C_Offroad_02_unarmed_F";
    _vehiclesLightUnarmed pushBack "I_C_Offroad_02_unarmed_F";
    _vehiclesLightArmed pushBack "I_C_Offroad_02_LMG_F";
    _vehiclesAt pushBack "I_C_Offroad_02_AT_F";
    _CivBoat append ["C_Boat_Transport_02_F", "C_Scooter_Transport_01_F"];
};

if (_hasLawsOfWar) then {
    _CivTruck append ["C_Van_02_vehicle_F", "C_Van_02_transport_F"];
    _VehTruck append ["I_G_Van_02_transport_F", "I_G_Van_02_vehicle_F"];
    _vehiclesLightUnarmed pushBack "I_C_Offroad_02_unarmed_F";
    _vehiclesLightArmed pushBack "I_C_Offroad_02_LMG_F";
    _vehiclesAt pushBack "I_C_Offroad_02_AT_F";
};

if (_hasContact) then {
    _vehiclesCivCar append ["C_Offroad_01_covered_F", "C_Offroad_01_comms_F", "C_Tractor_01_F"];
};

if (_hasWs) then {
    _CivTruck append ["C_Truck_02_cargo_lxWS", "C_Truck_02_flatbed_lxWS"];
    _vehiclesCivCar append ["C_Offroad_lxWS","C_Truck_02_racing_lxWS"];
    _vehiclesLightUnarmed pushBack "I_G_Offroad_01_armor_base_lxWS";
    _vehiclesLightArmed pushBack "I_G_Offroad_01_armor_armed_lxWS";
    _vehiclesAt pushBack "I_G_Offroad_01_armor_AT_lxWS";
    _vehicleAA pushBack "I_Tura_Truck_02_aa_lxWS";
    _staticAA = ["I_Tura_ZU23_lxWS"];
};

if (_hasKart) then {
    _vehiclesCivCar pushBack "C_Kart_01_F";
};

["vehiclesBasic", _vehiclesBasic] call _fnc_saveToTemplate;
["vehiclesPlane", _vehiclePlane] call _fnc_saveToTemplate;
["vehiclesCivTruck", _CivTruck] call _fnc_saveToTemplate;
["vehiclesCivHeli", _vehiclesCivHeli] call _fnc_saveToTemplate;
["vehiclesTruck", _VehTruck] call _fnc_saveToTemplate;
["vehiclesCivBoat", _CivBoat] call _fnc_saveToTemplate;
["vehiclesAA", _vehicleAA] call _fnc_saveToTemplate;
["staticAA", _staticAA] call _fnc_saveToTemplate;
["staticMortars", _staticMortars] call _fnc_saveToTemplate;
["vehiclesCivCar", _vehiclesCivCar] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", _vehiclesLightUnarmed] call _fnc_saveToTemplate;
["vehiclesLightArmed", _vehiclesLightArmed] call _fnc_saveToTemplate;
["vehiclesAT", _vehiclesAt] call _fnc_saveToTemplate;

//////////////////////////////////////
//       Antistasi Plus Stuff       //
//////////////////////////////////////

//classname, price, type, availability condition
private _shopWs = if (_hasWs) then {
    [
        ["I_UAV_02_lxWS", 3500, "UAV", {tierWar > 2}], 
        ["I_G_UAV_02_IED_lxWS", 4500, "UAV", {tierWar > 3}]
    ]
} else {
    []
};
private _shopLawsOfWar = if (_hasLawsOfWar) then {
    [
        ["I_UAV_06_F", 2500, "UAV", {tierWar > 2}], 
        ["I_UAV_06_medical_F", 3500, "UAV", {tierWar > 3}],
        ["C_IDAP_UAV_06_antimine_F", 3500, "UAV", {tierWar > 3}]
    ]
} else {
    []
};
private _shopContact = if (_hasContact) then {
    [
        ["C_IDAP_UGV_02_Demining_F", 2500, "UAV", {tierWar > 2}],
        ["I_UGV_02_Science_F", 2000, "UAV", {tierWar > 2}] 
    ]
} else {
    []
};
private _shopJets = if (_hasJets) then {
    [
        ["C_IDAP_UGV_02_Demining_F", 2500, "UAV", {tierWar > 2}],
        ["I_UGV_02_Science_F", 2000, "UAV", {tierWar > 2}]
    ]
} else {
    []
};
private _shopMarksman = if (_hasMarksman) then {
    [
        ["B_Static_Designator_01_F", 1500, "UAV", {tierWar > 2}],
        ["O_Static_Designator_02_F", 1500, "UAV", {tierWar > 2}]
    ]
} else {
    []
};
private _vehiclesBlackMarket = _shopWs + _shopLawsOfWar + _shopContact + _shopJets + _shopMarksman + [
    ["I_UAV_01_F", 2000, "UAV", {true}],
    ["I_HMG_01_A_F", 2500, "UAV", {tierWar > 3}],
    ["I_GMG_01_A_F", 4500, "UAV", {tierWar > 3}],
    ["I_UGV_01_F", 4000, "AA", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}],
    ["I_UGV_01_rcws_F", 7500, "AA", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}],
    ["I_LT_01_AA_F", 7500, "AA", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}],
    ["I_LT_01_scout_F", 7500, "AA", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}],
    ["I_LT_01_cannon_F", 10000, "TANK", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}],
    ["I_LT_01_AT_F", 11000, "TANK", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}],
    ["I_APC_Wheeled_03_cannon_F", 15000, "APC", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count seaports > 0}],
    ["B_Heli_Light_01_F", 7000, "HELI", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}],
    ["I_Heli_light_03_unarmed_F", 10000, "HELI", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}],
    ["B_Heli_Light_01_dynamicLoadout_F", 20000, "HELI", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}],
    ["I_Heli_light_03_dynamicLoadout_F", 25000, "HELI", {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}]
];
["blackMarketStock", _vehiclesBlackMarket] call _fnc_saveToTemplate;

["variants", [
    ["I_Heli_light_03_dynamicLoadout_F", ["Green",1]],
    ["I_APC_Wheeled_03_cannon_F", ["Guerilla_01",0.5, "Guerilla_02",0.5, "Guerilla_03",0.5, "Indep",0, "Indep_03",0, "Indep_02",0]],
    ["I_LT_01_AA_F", ["Indep_Olive",1]],
    ["I_LT_01_scout_F", ["Indep_Olive",1]],
    ["I_LT_01_cannon_F", ["Indep_Olive",1]],
    ["I_LT_01_AT_F", ["Indep_Olive",1]],
    ["I_Heli_Transport_02_F", ["Dahoman", 1]],
    ["O_Heli_Light_02_unarmed_F", ["Blue", 1]]
]] call _fnc_saveToTemplate;

#include "Vanilla_Reb_Vehicle_Attributes.sqf"

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

private _initialRebelEquipment = [
    "hgun_Pistol_heavy_02_F",
    "hgun_PDW2000_F",
    "30Rnd_9x21_Mag", "30Rnd_9x21_Red_Mag",
    "6Rnd_45ACP_Cylinder","MiniGrenade","SmokeShell",
    ["IEDUrbanSmall_Remote_Mag", 10], ["IEDLandSmall_Remote_Mag", 10], ["IEDUrbanBig_Remote_Mag", 3], ["IEDLandBig_Remote_Mag", 3],
    "B_FieldPack_oli","B_FieldPack_blk","B_FieldPack_khk",
    "V_BandollierB_blk","V_BandollierB_cbr","V_BandollierB_rgr","V_BandollierB_khk","V_BandollierB_oli","V_Rangemaster_belt",
    "Binocular",
    "acc_flashlight","acc_flashlight_smg_01","acc_flashlight_pistol"
];

if (_hasRF) then {
    _initialRebelEquipment append ["srifle_h6_tan_rf","10Rnd_556x45_AP_Stanag_red_Tan_RF","10Rnd_556x45_AP_Stanag_Tan_RF","10Rnd_556x45_AP_Stanag_green_Tan_RF"];
    _initialRebelEquipment = _initialRebelEquipment - ["SMG_05_F","SMG_01_F","hgun_PDW2000_F","SMG_02_F","30Rnd_45ACP_Mag_SMG_01","30Rnd_9x21_Mag_SMG_02"];
};

if (_hasLawsOfWar) then {
    _initialRebelEquipment append [
        "V_Pocketed_olive_F", 
        "V_Pocketed_coyote_F", 
        "V_Pocketed_black_F",
        "V_Plain_crystal_F",
        "B_LegStrapBag_black_F", 
        "V_LegStrapBag_coyote_F",
        "V_LegStrapBag_olive_F",
        "V_Safety_blue_F",
        "V_Safety_orange_F",
        "V_Safety_yellow_F"
    ];
};

if (_hasApex) then {
    _initialRebelEquipment append [
        "V_BandollierB_ghex_F",
        "V_TacChestrig_cbr_F",
        "V_TacChestrig_grn_F",
        "V_TacChestrig_oli_F"
    ];
};

private _backpacks = [];
if (_hasLawsOfWar) then {
    _backpacks append [
        "B_Messenger_Black_F", 
        "B_Messenger_Coyote_F", 
        "B_Messenger_Gray_F",
        "B_Messenger_Olive_F"
    ];
} else {
    _backpacks append ["B_FieldPack_blk","B_AssaultPack_blk"];
};

if (_hasArtOfWar) then {
    _backpacks append [
        "B_CivilianBackpack_01_Everyday_Astra_F",
        "B_CivilianBackpack_01_Everyday_Black_F",
        "B_CivilianBackpack_01_Everyday_Vrana_F",
        "B_CivilianBackpack_01_Sport_Blue_F",
        "B_CivilianBackpack_01_Sport_Green_F",
        "B_CivilianBackpack_01_Sport_Red_F"
    ];
};

_initialRebelEquipment append _backpacks;

if (_hasContact) then {
    _initialRebelEquipment append [
        "sgun_HunterShotgun_01_F",
        "sgun_HunterShotgun_01_sawedoff_F",
        "2Rnd_12Gauge_Pellets",
        "2Rnd_12Gauge_Slug"
    ];
};

if (_hasApex) then {
    _initialRebelEquipment append [
        "hgun_Pistol_01_F",
        "10Rnd_9x21_Mag",
        ["launch_RPG7_F", 3], 
        ["RPG7_F", 9]
    ];
} else {
    _initialRebelEquipment append [["launch_RPG32_F", 2], ["RPG32_F", 6]];
};

if (A3A_hasTFAR) then {_initialRebelEquipment append ["tf_microdagr","tf_anprc154"]};
if (A3A_hasTFAR && startWithLongRangeRadio) then {_initialRebelEquipment append ["tf_anprc155","tf_anprc155_coyote"]};
if (A3A_hasTFARBeta) then {_initialRebelEquipment append ["TFAR_microdagr","TFAR_anprc154"]};
if (A3A_hasTFARBeta && startWithLongRangeRadio) then {_initialRebelEquipment append ["TFAR_anprc155","TFAR_anprc155_coyote"]};
_initialRebelEquipment append ["Chemlight_blue","Chemlight_green","Chemlight_red","Chemlight_yellow"];
["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;

private _rebUniforms = [
    "U_IG_Guerilla1_1",
    "U_IG_Guerilla2_1",
    "U_IG_Guerilla2_2",
    "U_IG_Guerilla2_3",
    "U_IG_Guerilla3_1",
    "U_IG_leader",
    "U_IG_Guerrilla_6_1",
    "U_I_G_resistanceLeader_F",
    "U_I_L_Uniform_01_deserter_F",
    "U_C_HunterBody_grn"
];

private _dlcUniforms = [];

if (_hasContact) then {
    _dlcUniforms append [
        "U_I_L_Uniform_01_camo_F",
        "U_I_L_Uniform_01_tshirt_black_F",
        "U_I_L_Uniform_01_tshirt_olive_F",
        "U_I_L_Uniform_01_tshirt_skull_F",
        "U_I_L_Uniform_01_tshirt_sport_F",
        "U_I_L_Uniform_01_deserter_F",
        "U_C_E_LooterJacket_01_F"
    ];
};
if (_hasWs) then {
    _dlcUniforms append [
        "U_lxWS_ION_Casual1",
        "U_lxWS_ION_Casual2",
        "U_lxWS_ION_Casual3",
        "U_lxWS_ION_Casual4",
        "U_lxWS_ION_Casual5",
        "U_lxWS_SFIA_deserter",
        "U_lxWS_Djella_02_Brown",
        "U_lxWS_Djella_02_Grey",
/*         "U_lxWS_Djella_02_Green", */
        "U_lxWS_Djella_02_Sand"
    ];
};
if (_hasApex) then {
    _dlcUniforms append [
        "U_I_C_Soldier_Bandit_1_F",
        "U_I_C_Soldier_Bandit_2_F",
        "U_I_C_Soldier_Bandit_3_F",
        "U_I_C_Soldier_Bandit_4_F",
        "U_I_C_Soldier_Bandit_5_F",
        "U_I_C_Soldier_Camo_F",
        "U_I_C_Soldier_Para_1_F",
        "U_I_C_Soldier_Para_2_F",
        "U_I_C_Soldier_Para_3_F",
        "U_I_C_Soldier_Para_4_F",
        "U_I_C_Soldier_Para_5_F"
    ];
};
if (_hasLawsOfWar) then {
    _dlcUniforms append [
        "U_C_ConstructionCoverall_Black_F",
        "U_C_ConstructionCoverall_Blue_F",
        "U_C_ConstructionCoverall_Red_F",
        "U_C_ConstructionCoverall_Vrana_F",
        "U_BG_Guerilla1_2_F",
        "U_C_Paramedic_01_F"
    ];
};
if (_hasArtOfWar) then {
    _dlcUniforms append [
        "U_C_ArtTShirt_01_v1_F",
        "U_C_ArtTShirt_01_v2_F",
        "U_C_ArtTShirt_01_v3_F",
        "U_C_ArtTShirt_01_v4_F",
        "U_C_ArtTShirt_01_v5_F",
        "U_C_ArtTShirt_01_v6_F"
    ];
};
if (_hasRF) then {
    _dlcUniforms append [
        "U_IG_Guerrilla_RF",
        "U_IG_leader_RF"
    ];
};
["uniforms", _rebUniforms + _dlcUniforms] call _fnc_saveToTemplate;

private _headgear = [
    "H_Booniehat_khk_hs",
    "H_Booniehat_khk",
    "H_Booniehat_tan",
    "H_Booniehat_oli",    
    "H_Bandanna_gry",
    "H_Bandanna_blu",
    "H_Bandanna_cbr",    
    "H_Bandanna_khk_hs",
    "H_Bandanna_khk",
    "H_Bandanna_sgg",
    "H_Bandanna_sand",
    "H_Bandanna_surfer",
    "H_Bandanna_surfer_blk",
    "H_Bandanna_surfer_grn",
    "H_Bandanna_camo",
    "H_Watchcap_blk",
    "H_Watchcap_cbr",
    "H_Watchcap_camo",
    "H_Watchcap_khk",
    "H_Beret_blk",
    "H_Booniehat_khk_hs",
    "H_Booniehat_khk",
    "H_Booniehat_oli",
    "H_Booniehat_tan",
    "H_Cap_oli",
    "H_Cap_surfer",
    "H_Cap_tan",
    "H_Cap_oli_hs",
    "H_Cap_blk",
    "H_Cap_headphones",
    "H_Hat_blue",
    "H_Hat_brown",
    "H_Hat_camo",
    "H_Hat_checker",
    "H_Hat_grey",
    "H_Hat_tan",
    "H_Cap_marshal",
    "H_MilCap_blue",
    "H_MilCap_gry",
    "H_ShemagOpen_tan",
    "H_ShemagOpen_khk",
    "H_ShemagOpen_tan",
    "H_Shemag_olive_hs",
    "H_StrawHat",
    "H_StrawHat_dark"
];

private _dlcheadgear = [];

if (_hasContact) then {
    _dlcheadgear append [
        "H_Booniehat_mgrn",
        "H_Booniehat_taiga",
        "H_Tank_eaf_F",
        "H_MilCap_grn",
        "H_MilCap_taiga",
        "H_Hat_Tinfoil_F"
    ];
};
if (_hasWs) then {
    _dlcheadgear append [
        "lxWS_H_Bandanna_blk_hs",
        "H_Cap_headphones_ion_lxws",
        "lxWS_H_CapB_rvs_blk_ION",
        "lxWS_H_Headset"
    ];
};
if (_hasApex) then {
    _dlcheadgear append [
        "H_Helmet_Skate"
    ];
};
if (_hasLawsOfWar) then {
    _dlcheadgear append [
        "H_EarProtectors_black_F",
        "H_EarProtectors_orange_F",
        "H_EarProtectors_red_F",
        "H_EarProtectors_white_F",
        "H_EarProtectors_yellow_F",
        "U_C_Paramedic_01_F",///
        "H_Construction_basic_black_F",
        "H_Construction_basic_orange_F",
        "H_Construction_basic_red_F",
        "H_Construction_basic_vrana_F",
        "H_Construction_basic_white_F",
        "H_Construction_basic_yellow_F",///
        "H_Construction_earprot_black_F",
        "H_Construction_earprot_orange_F",
        "H_Construction_earprot_red_F",
        "H_Construction_earprot_vrana_F",
        "H_Construction_earprot_white_F",
        "H_Construction_earprot_yellow_F",///
        "H_Construction_headset_black_F",
        "H_Construction_headset_orange_F",
        "H_Construction_headset_red_F",
        "H_Construction_headset_vrana_F",
        "H_Construction_headset_white_F",
        "H_Construction_headset_yellow_F",///
        "H_HeadBandage_clean_F",
        "H_HeadBandage_stained_F",
        "H_HeadBandage_bloody_F",
        "H_HeadSet_black_F",
        "H_HeadSet_orange_F",
        "H_HeadSet_red_F",
        "H_HeadSet_white_F",
        "H_HeadSet_yellow_F",
        "H_Hat_Safari_olive_F",
        "H_Hat_Safari_sand_F",
        "H_WirelessEarpiece_F"
    ];
};

["headgear", _headgear + _dlcheadgear] call _fnc_saveToTemplate;
/////////////////////
///  Identities   ///
/////////////////////

["faces", ["GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04",
"GreekHead_A3_05","GreekHead_A3_06","GreekHead_A3_07","GreekHead_A3_08",
"GreekHead_A3_09","GreekHead_A3_10","GreekHead_A3_11","GreekHead_A3_12","GreekHead_A3_13",
"GreekHead_A3_14","Ioannou","Mavros","Sturrock"]] call _fnc_saveToTemplate;
["voices", ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE","Male01GREVR"]] call _fnc_saveToTemplate;

#include "Vanilla_Reb_Vehicle_Attributes.sqf"

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];


if (_hasWs) then {
    _loadoutData set ["binoculars", ["Binocular","Camera_lxWS"]];
} else {
    _loadoutData set ["binoculars", ["Binocular"]];
};

_loadoutData set ["uniforms", _rebUniforms + _dlcUniforms]; ///check this one

_loadoutData set ["glasses", ["G_Lady_Blue","G_Shades_Black", "G_Shades_Blue", "G_Shades_Green", "G_Shades_Red", "G_Aviator", "G_Spectacles", "G_Spectacles_Tinted", "G_Sport_BlackWhite", "G_Sport_Blackyellow", "G_Sport_Greenblack", "G_Sport_Checkered", "G_Sport_Red", "G_Squares", "G_Squares_Tinted"]];
_loadoutData set ["goggles", ["G_Lowprofile"]];
_loadoutData set ["facemask", ["G_Bandanna_blk", "G_Bandanna_oli", "G_Bandanna_khk", "G_Bandanna_tan", "G_Bandanna_beast", "G_Bandanna_shades", "G_Bandanna_sport", "G_Bandanna_aviator"]];
_loadoutData set ["balaclavas", ["G_Balaclava_blk", "G_Balaclava_BlueStrips", "G_Balaclava_Flecktarn", "G_Balaclava_Halloween_01", "G_Balaclava_lowprofile", "G_Balaclava_oli", "G_Balaclava_Flames1", "G_Balaclava_Scarecrow_01", "G_Balaclava_Skull1", "G_Balaclava_Tropentarn"]];
_loadoutData set ["argoFacemask", ["G_Bandanna_BlueFlame1", "G_Bandanna_BlueFlame2", "G_Bandanna_CandySkull", "G_Bandanna_OrangeFlame1", "G_Bandanna_RedFlame1", "G_Bandanna_Skull1", "G_Bandanna_Syndikat1", "G_Bandanna_Syndikat2","G_Bandanna_Skull2", "G_Bandanna_Vampire_01"]];

if (_hasWs) then {
    _loadoutData set ["facewearWS", ["G_Balaclava_blk_lxWS", "G_Balaclava_oli_lxWS", "G_Balaclava_snd_lxWS", "G_Combat_lxWS", "G_Headset_lxWS"]];
} else {
    _loadoutData set ["facewearWS", []];
};

if (_hasContact) then {
    _loadoutData set ["facewearContact", ["G_Blindfold_01_black_F", "G_Blindfold_01_white_F", "G_RegulatorMask_F"]];
} else {
    _loadoutData set ["facewearContact", []];
};

if (_hasLawsOfWar) then {
    _loadoutData set ["facewearLawsOfWar", ["G_Respirator_blue_F", "G_Respirator_white_F", "G_Respirator_yellow_F", "G_EyeProtectors_F", "G_EyeProtectors_Earpiece_F", "G_WirelessEarpiece_F"]];
} else {
    _loadoutData set ["facewearLawsOfWar", []];
};

_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

////////////////////////
//  Rebel Unit Types  //
///////////////////////.

private _squadLeaderTemplate = {
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75, "facemask", 1, "balaclavas", 1, "argoFacemask", 1 , "facewearWS", 0.75, "facewearContact", 0.3, "facewearLawsOfWar", 0.5]] call _fnc_setFacewear;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75, "facemask", 1, "balaclavas", 1, "argoFacemask", 1 , "facewearWS", 0.75, "facewearContact", 0.3, "facewearLawsOfWar", 0.5]] call _fnc_setFacewear;
    
    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};

private _prefix = "militia";
private _unitTypes = [
    ["Petros", _squadLeaderTemplate],
    ["SquadLeader", _squadLeaderTemplate],
    ["Rifleman", _riflemanTemplate],
    ["staticCrew", _riflemanTemplate],
    ["Medic", _riflemanTemplate, [["medic", true]]],
    ["Engineer", _riflemanTemplate, [["engineer", true]]],
    ["ExplosivesExpert", _riflemanTemplate, [["explosiveSpecialist", true]]],
    ["Grenadier", _riflemanTemplate],
    ["LAT", _riflemanTemplate],
    ["AT", _riflemanTemplate],
    ["AA", _riflemanTemplate],
    ["MachineGunner", _riflemanTemplate],
    ["Marksman", _riflemanTemplate],
    ["Sniper", _riflemanTemplate],
    ["Unarmed", _riflemanTemplate]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

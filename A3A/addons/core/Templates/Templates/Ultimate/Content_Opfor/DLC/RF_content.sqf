

//_basic append [];
_unarmedVehicles append ["O_Pickup_rf","O_Pickup_Comms_rf"];
_armedVehicles append ["O_Pickup_rf","O_Pickup_Comms_rf", "O_Pickup_rcws_rf","AU_O_Pickup_Minigun_RF","O_T_Pickup_rf","O_T_Pickup_Comms_rf", "O_T_Pickup_rcws_rf","AU_O_T_Pickup_Minigun_RF"];
//_Trucks append [];
_cargoTrucks append ["O_Truck_03_cargo_RF","O_T_Truck_03_cargo_RF"];
//_ammoTrucks append [];
//_repairTrucks append [];
//_fuelTrucks append [];
//_medicalTrucks append [];
//_lightAPCs append [];
//_APCs append [];
//_IFVs append [];
//_airborneVehicles append [];
//_tanks append [];
//_lightTanks append [];
//_aa append [];

//_transportBoat append [];
//_gunBoat append [];

//_planesCAS append [];
//_planesAA append [];
//_planesLargeCAS append [];
//_planesLargeAA append [];

//_planesTransport append [];
//_gunship append [];

//_helisLight append [];
//_transportHelicopters append [];
//_helisLightAttack append [];
//_helisAttack append [];

//_airPatrol append [];

//_artillery append [];

//_uavsAttack append [];
_uavsPortable append ["O_UAV_RC40_SENSOR_RF"];

_militiaLightArmed append ["O_G_Pickup_hmg_rf","O_T_G_Pickup_hmg_rf"];
//_militiaTrucks append [];
_militiaCars append ["O_Pickup_rf","O_Pickup_Comms_rf","O_T_Pickup_rf","O_T_Pickup_Comms_rf"];
//_militiaAPCs append []; 

_policeVehs append ["a3a_police_Pickup_rf", "B_GEN_Pickup_covered_rf", "a3a_police_Pickup_comms_rf"];

//_staticMG append [];
//_staticAT append [];
//_staticAA append [];
_staticMortars append ["O_CommandoMortar_RF"];
_howitzers append ["O_TwinMortar_RF","O_T_TwinMortar_RF"];

//_radar append [];
//_SAM append [];

//_mortarMagazineHE append [];
//_mortarMagazineSmoke append [];
//_mortarMagazineFlare append [];

//_minefieldAT append [];
//_minefieldAPERS append [];

//_howitzerMagazineHE append [];

_baseClassSquadLeaderArray append ["O_QRF_Soldier_SL_RF"];
_baseClassRiflemanArray append ["O_support_CMort_RF","O_QRF_Soldier_RF","O_A_scout_RF"];
//_baseClassRadiomanArray append [];
_baseClassMedicArray append ["O_QRF_medic_RF"];
//_baseClassEngineerArray append [];
//_baseClassExplosivesArray append [];
_baseClassGrenadierArray append ["O_QRF_Soldier_GL_RF"];
//_baseClassLATArray append [];
_baseClassATArray append ["O_QRF_Soldier_HAT_RF"];
//_baseClassAAArray append [];
_baseClassMachineGunnerArray append ["O_QRF_Soldier_AR_RF"];
_baseClassMarksmanArray append ["O_QRF_soldier_M_RF"];
_baseClassSniperArray append ["O_QRF_soldier_M_RF"];
_baseClassPatrolSniperArray append ["O_QRF_soldier_M_RF"];
_baseClassPatrolSpotterArray append ["O_QRF_soldier_M_RF"];
// ================== Специальные роли ==================
_baseClassPoliceArray append ["B_GEN_Soldier_RF","B_GEN_Helipilot_RF"];

//_baseClassCrewArray append [];
//_baseClassPilotArray append [];
//_baseClassOfficialArray append [];
_baseClassTraitorArray append ["I_G_support_CMort_RF","I_G_Soldier_LAT_RF","I_G_Scout_RF"];
//_baseClassUnarmedArray append [];

// Оружие
_TlOptics append ["optic_VRCO_RF","optic_VRCO_tan_RF","optic_ACO_grn_desert_RF","optic_ACO_grn_wood_RF","optic_ACO_desert_RF","optic_ACO_wood_RF"];
_RifleOptics append ["optic_VRCO_RF","optic_VRCO_tan_RF","optic_ACO_grn_desert_RF","optic_ACO_grn_wood_RF","optic_ACO_desert_RF","optic_ACO_wood_RF"];
_MGOptics append ["optic_VRCO_RF","optic_VRCO_tan_RF"];
_SMGOptics append ["optic_VRCO_RF","optic_VRCO_tan_RF","optic_ACO_grn_desert_RF","optic_ACO_grn_wood_RF","optic_ACO_desert_RF","optic_ACO_wood_RF"];
_P90Optics append ["optic_VRCO_RF","optic_VRCO_tan_RF","optic_ACO_grn_desert_RF","optic_ACO_grn_wood_RF","optic_ACO_desert_RF","optic_ACO_wood_RF"];
//_MarksmanOptics append [];
//_SniperOptics append [];
//_Bipods append [];

// Оружие
(_loadoutData get "slRifles") append [
	["arifle_ash12_blk_RF","suppressor_127x55_big_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_blk_RF","suppressor_127x55_small_RFF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_blk_RF","",_Accessories,_TlOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
    ["arifle_ash12_urban_RF","suppressor_127x55_big_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_urban_RF","suppressor_127x55_small_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
    ["arifle_ash12_urban_RF","",_Accessories,_TlOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_desert_RF","suppressor_127x55_big_desert_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [], _Bipods],
	["arifle_ash12_desert_RF","suppressor_127x55_small_desert_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [], _Bipods],
    ["arifle_ash12_desert_RF","",_Accessories,_TlOptics,["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [], _Bipods],
	["arifle_ash12_wood_RF","suppressor_127x55_big_wood_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [], _Bipods],
	["arifle_ash12_wood_RF","suppressor_127x55_small_wood_RF",_Accessories,_TlOptics,["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [], _Bipods],
    ["arifle_ash12_wood_RF","",_Accessories,_TlOptics,["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [], _Bipods]
];
(_loadoutData get "rifles") append [
	["arifle_ash12_blk_RF","suppressor_127x55_big_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_blk_RF","suppressor_127x55_small_RFF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_blk_RF","",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
    ["arifle_ash12_urban_RF","suppressor_127x55_big_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_urban_RF","suppressor_127x55_small_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
    ["arifle_ash12_urban_RF","",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [], _Bipods],
	["arifle_ash12_desert_RF","suppressor_127x55_big_desert_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [], _Bipods],
	["arifle_ash12_desert_RF","suppressor_127x55_small_desert_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [], _Bipods],
    ["arifle_ash12_desert_RF","",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [], _Bipods],
	["arifle_ash12_wood_RF","suppressor_127x55_big_wood_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [], _Bipods],
	["arifle_ash12_wood_RF","suppressor_127x55_small_wood_RF",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [], _Bipods],
    ["arifle_ash12_wood_RF","",_Accessories,_RifleOptics,["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [], _Bipods]
];
(_loadoutData get "grenadeLaunchers") append [
	["arifle_ash12_GL_blk_RF", "suppressor_127x55_big_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_blk_RF", "suppressor_127x55_small_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_blk_RF", "", _Accessories,_RifleOptics, ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_desert_RF", "suppressor_127x55_big_desert_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_desert_RF", "suppressor_127x55_small_desert_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_desert_RF", "", _Accessories,_RifleOptics, ["20Rnd_127x55_Mag_desert_RF","20Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_urban_RF", "suppressor_127x55_big_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_urban_RF", "suppressor_127x55_small_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_urban_RF", "", _Accessories,_RifleOptics, ["20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF","20Rnd_127x55_Mag_RF"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_wood_RF", "suppressor_127x55_big_wood_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_wood_RF", "suppressor_127x55_small_wood_RF",_Accessories,_RifleOptics, ["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], ["1Rnd_RC40_shell_RF", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""],
	["arifle_ash12_GL_wood_RF", "", _Accessories,_RifleOptics, ["20Rnd_127x55_Mag_wood_RF","20Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], ["1Rnd_HE_Grenade_shell", "1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell","1Rnd_RC40_HE_shell_RF","1Rnd_RC40_SmokeWhite_shell_RF","1Rnd_RC40_shell_RF"], ""]
];
(_loadoutData get "SMGs") append [
	["SMG_01_black_RF","","",_SMGOptics,["30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01_Tracer_Green"], [], ""],
	["SMG_01_black_RF","muzzle_snds_acp","acc_flashlight_smg_01",_SMGOptics,["30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01_Tracer_Green"], [], ""],
	["SMG_01_black_RF","muzzle_snds_acp","",_SMGOptics,["30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01_Tracer_Green"], [], ""]
];
(_loadoutData get "machineGuns") append [];
(_loadoutData get "marksmanRifles") append [
	["srifle_h6_oli_rf","muzzle_snds_M",_Accessories,_MarksmanOptics,["10Rnd_556x45_AP_Stanag_red_khk_RF","10Rnd_556x45_AP_Stanag_red_khk_RF","20Rnd_556x45_AP_Stanag_red_khk_RF"],[],_Bipods],
	["srifle_h6_oli_rf","",_Accessories,_MarksmanOptics,["10Rnd_556x45_AP_Stanag_red_khk_RF","10Rnd_556x45_AP_Stanag_red_khk_RF","20Rnd_556x45_AP_Stanag_red_khk_RF"],[],_Bipods],
    ["srifle_h6_blk_rf", "muzzle_snds_M", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_blk_rf", "", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_gold_rf", "muzzle_snds_M", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_gold_rf", "", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_tan_rf", "muzzle_snds_M", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_tan_rf", "", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_DMR_01_black_RF","muzzle_snds_B",_Accessories,_SniperOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["srifle_DMR_01_black_RF","",_Accessories,_SniperOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["srifle_DMR_01_tan_RF","muzzle_snds_B",_Accessories,_SniperOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["srifle_DMR_01_tan_RF","",_Accessories,_SniperOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["arifle_ash12_LR_blk_RF","suppressor_127x55_big_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [],  _Bipods],
    ["arifle_ash12_LR_blk_RF","suppressor_127x55_small_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [],  _Bipods],
    ["arifle_ash12_LR_blk_RF","",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [],  _Bipods],
	["arifle_ash12_LR_desert_RF","suppressor_127x55_big_desert_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [],  _Bipods],
    ["arifle_ash12_LR_desert_RF","suppressor_127x55_small_desert_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [],  _Bipods],
    ["arifle_ash12_LR_desert_RF","",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF","10Rnd_127x55_Mag_desert_RF"], [],  _Bipods],
	["arifle_ash12_LR_urban_RF","suppressor_127x55_big_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [],  _Bipods],
    ["arifle_ash12_LR_urban_RF","suppressor_127x55_small_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [],  _Bipods],
    ["arifle_ash12_LR_urban_RF","",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF","10Rnd_127x55_Mag_RF"], [],  _Bipods],
	["arifle_ash12_LR_wood_RF","suppressor_127x55_big_wood_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [],  _Bipods],
    ["arifle_ash12_LR_wood_RF","suppressor_127x55_small_wood_RF",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [],  _Bipods],
    ["arifle_ash12_LR_wood_RF","",_Accessories,_MarksmanOptics,["10Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF","10Rnd_127x55_Mag_wood_RF"], [],  _Bipods]
];
(_loadoutData get "sniperRifles") append [
	["srifle_h6_oli_rf","muzzle_snds_M",_Accessories,_MarksmanOptics,["10Rnd_556x45_AP_Stanag_red_khk_RF","10Rnd_556x45_AP_Stanag_red_khk_RF","20Rnd_556x45_AP_Stanag_red_khk_RF"],[],_Bipods],
	["srifle_h6_oli_rf","",_Accessories,_MarksmanOptics,["10Rnd_556x45_AP_Stanag_red_khk_RF","10Rnd_556x45_AP_Stanag_red_khk_RF","20Rnd_556x45_AP_Stanag_red_khk_RF"],[],_Bipods],
    ["srifle_h6_blk_rf", "muzzle_snds_M", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_blk_rf", "", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_gold_rf", "muzzle_snds_M", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_gold_rf", "", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_tan_rf", "muzzle_snds_M", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_h6_tan_rf", "", _Accessories, _MarksmanOptics,["10Rnd_556x45_AP_Stanag_RF","10Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF","20Rnd_556x45_AP_Stanag_RF"], [], _Bipods],
	["srifle_DMR_01_black_RF","muzzle_snds_B",_Accessories,_MarksmanOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["srifle_DMR_01_black_RF","",_Accessories,_MarksmanOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["srifle_DMR_01_tan_RF","muzzle_snds_B",_Accessories,_MarksmanOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods],
	["srifle_DMR_01_tan_RF","",_Accessories,_MarksmanOptics,["10Rnd_762x54_Mag","10Rnd_762x54_Mag","10Rnd_762x54_Mag"],[],_Bipods]
];

// Пусковые установки
(_loadoutData get "lightATLaunchers") append [
	["launch_PSRL1_black_RF", "", _Accessories, "", ["PSRL1_AT_RF","PSRL1_FRAG_RF","PSRL1_HE_RF","PSRL1_HEAT_RF"], [], ""],
    ["launch_PSRL1_olive_RF", "", _Accessories, "", ["PSRL1_AT_RF","PSRL1_FRAG_RF","PSRL1_HE_RF","PSRL1_HEAT_RF"], [], ""],
	["launch_PSRL1_sand_RF", "", _Accessories, "", ["PSRL1_AT_RF","PSRL1_FRAG_RF","PSRL1_HE_RF","PSRL1_HEAT_RF"], [], ""],
    ["launch_PSRL1_PWS_black_RF", "", _Accessories, "", ["PSRL1_AT_RF","PSRL1_FRAG_RF","PSRL1_HE_RF","PSRL1_HEAT_RF"], [], ""],
    ["launch_PSRL1_PWS_olive_RF", "", _Accessories, "", ["PSRL1_AT_RF","PSRL1_FRAG_RF","PSRL1_HE_RF","PSRL1_HEAT_RF"], [], ""],
	["launch_PSRL1_PWS_sand_RF", "", _Accessories, "", ["PSRL1_AT_RF","PSRL1_FRAG_RF","PSRL1_HE_RF","PSRL1_HEAT_RF"], [], ""]
];
//(_loadoutData get "ATLaunchers") append [];
//(_loadoutData get "missileATLaunchers") append [];
//(_loadoutData get "AALaunchers") append [];
(_loadoutData get "sidearms") append [
	["hgun_Glock19_auto_RF","muzzle_snds_L","acc_flashlight_IR_pistol_RF","optic_MRD_black",["65Rnd_9x19_Red_Mag_RF","33Rnd_9x19_Red_Mag_RF","17Rnd_9x19_red_Mag_RF"],[],""],
    ["hgun_Glock19_auto_khk_RF","muzzle_snds_L","acc_pointer_IR_pistol_RF","optic_MRD_khk_RF",["33Rnd_9x19_Red_Mag_khk_RF","33Rnd_9x19_Red_Mag_khk_RF","33Rnd_9x19_Red_Mag_khk_RF"],[],""],
	["hgun_Glock19_auto_Tan_RF","muzzle_snds_L","acc_pointer_IR_pistol_RF","optic_MRD_khk_RF",["33Rnd_9x19_Red_Mag_khk_RF","33Rnd_9x19_Red_Mag_khk_RF","33Rnd_9x19_Red_Mag_khk_RF"],[],""],
    ["hgun_Glock19_RF","muzzle_snds_L","acc_pointer_IR_pistol_RF","optic_MRD_black",["17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF"],[],""],
	["hgun_Glock19_Tan_RF","muzzle_snds_L","acc_pointer_IR_pistol_RF","optic_MRD_black",["17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF"],[],""],
    ["hgun_Glock19_khk_RF","muzzle_snds_L","acc_flashlight_IR_pistol_RF","optic_MRD_khk_RF",["33Rnd_9x19_Mag_khk_RF","33Rnd_9x19_Mag_khk_RF","33Rnd_9x19_Mag_khk_RF"],[],""],
    ["hgun_DEagle_RF","","","optic_VRCO_pistol_RF",["7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF"],[],""],
    ["hgun_DEagle_classic_RF","","","optic_VRCO_pistol_RF",["7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF"],[],""],
    ["hgun_DEagle_bronze_RF","","","optic_VRCO_pistol_RF",["7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF"],[],""],
    ["hgun_DEagle_camo_RF", "", "", "optic_VRCO_pistol_RF", ["7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF","7Rnd_50AE_Mag_RF"], [], ""]
];

// Базовое снаряжение
(_loadoutData get "NVGs") append ["TiGoggles_RF","TiGoggles_grn_RF","TiGoggles_tan_RF"];

// Предательская экипировка
(_loadoutData get "traitorUniforms") append [
	"U_BG_Guerrilla_RF","U_BG_leader_RF"
];
(_loadoutData get "traitorVests") append [
	"V_TacVest_rig_blk_RF",
	"V_TacVest_rig_khk_RF",
	"V_TacVest_rig_oli_RF"
];

// Специальная экипировка
(_loadoutData get "cloakVests") append [
	"V_TacVest_rig_blk_RF",
	"V_TacVest_rig_khk_RF",
	"V_TacVest_rig_oli_RF"
];

// Основная экипировка
(_loadoutData get "vests") append [
	"V_TacVest_rig_blk_RF",
	"V_TacVest_rig_khk_RF",
	"V_TacVest_rig_oli_RF"
];
(_loadoutData get "Hvests") append [
	"V_TacVest_rig_blk_RF",
	"V_TacVest_rig_khk_RF",
	"V_TacVest_rig_oli_RF"
];
(_loadoutData get "sniVests") append [
	"V_TacVest_rig_blk_RF",
	"V_TacVest_rig_khk_RF",
	"V_TacVest_rig_oli_RF"
];
(_loadoutData get "backpacks") append [
	"O_CommandoMortar_weapon_RF"
];
(_loadoutData get "atBackpacks") append [
	"B_DuffleBag_Black_NoLogo_RF",
	"B_DuffleBag_Sand_NoLogo_RF",
	"B_DuffleBag_Olive_NoLogo_RF"
];
(_loadoutData get "helmets") append [
	"H_HelmetO_ocamo_sb_hex_RF",
	"H_HelmetO_ocamo_sb_urban_RF",
	"H_HelmetAggressor_sb_taiga_RF",
	"H_HelmetB_plain_sb_hex_RF",
	"H_HelmetB_plain_sb_khaki_RF",
	"H_HelmetHeavy_Black_RF",
	"H_HelmetHeavy_Simple_Black_RF",
	"H_HelmetHeavy_VisorUp_Black_RF",
	"H_HelmetHeavy_GHex_RF",
	"H_HelmetHeavy_Simple_GHex_RF",
	"H_HelmetHeavy_VisorUp_GHex_RF",
	"H_HelmetHeavy_Hex_RF",
	"H_HelmetHeavy_Simple_Hex_RF",
	"H_HelmetHeavy_VisorUp_Hex_RF"
];
(_loadoutData get "slHat") append [
	"H_HelmetO_ocamo_sb_hex_RF",
	"H_HelmetO_ocamo_sb_urban_RF",
	"H_HelmetAggressor_sb_taiga_RF",
	"H_HelmetB_plain_sb_hex_RF",
	"H_HelmetB_plain_sb_khaki_RF",
	"H_HelmetHeavy_Black_RF",
	"H_HelmetHeavy_Simple_Black_RF",
	"H_HelmetHeavy_VisorUp_Black_RF",
	"H_HelmetHeavy_GHex_RF",
	"H_HelmetHeavy_Simple_GHex_RF",
	"H_HelmetHeavy_VisorUp_GHex_RF",
	"H_HelmetHeavy_Hex_RF",
	"H_HelmetHeavy_Simple_Hex_RF",
	"H_HelmetHeavy_VisorUp_Hex_RF"
];
(_loadoutData get "sniHats") append [
	"H_HelmetO_ocamo_sb_hex_RF",
	"H_HelmetO_ocamo_sb_urban_RF",
	"H_HelmetAggressor_sb_taiga_RF",
	"H_HelmetB_plain_sb_hex_RF",
	"H_HelmetB_plain_sb_khaki_RF"
];

// Аксессуары
(_loadoutData get "glasses") append ["G_Glasses_black_RF","G_Glasses_white_RF"];

// Дополнительные предметы для специализаций
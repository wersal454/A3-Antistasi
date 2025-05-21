_vehiclesDropPod append ["OPTRE_FC_Scarab_Hull_Base","OPTRE_FC_Scarab_Hull_AT","OPTRE_FC_Hull_AA","OPTRE_FC_Hull_Cmdr","OPTRE_FC_Hull_Cmdr_AA","Land_Pod_Heli_Transport_04_covered_F"];

_basic append ["OPTRE_FC_Ghost_Driverless","OPTRE_FC_Ghost_Armor_Driverless","OPTRE_FC_Ghost_Ultra_Driverless",
"OPTRE_FC_Ghost_Zealot_Driverless","OPTRE_FC_Ghost_FuelRod_Driverless","OPTRE_FC_Ghost_Needler_Driverless"];
_unarmedVehicles append ["OPTRE_FC_Spectre_Transport"];
_armedVehicles append ["OPTRE_FC_Spectre_AI","OPTRE_FC_Spectre_AI_Needler","OPTRE_FC_Spectre_AI_Ultra","OPTRE_FC_Spectre_AT",
"OPTRE_FC_Spectre_AT_Needler","OPTRE_FC_Spectre_AT_Ultra","OPTRE_FC_Ghost","OPTRE_FC_Ghost_Armor","OPTRE_FC_Ghost_Ultra","OPTRE_FC_Ghost_Zealot",
"OPTRE_FC_Ghost_FuelRod","OPTRE_FC_Ghost_Needler"];
_Trucks append ["OPTRE_FC_Spectre_Transport","OPTRE_FC_Spectre_Transport_Needler","OPTRE_FC_Spectre_Transport_Ultra"];
_cargoTrucks append ["OPTRE_FC_Spectre_Empty","OPTRE_FC_Spectre_Empty_Needler","OPTRE_FC_Spectre_Empty_Ultra"];
_repairTrucks append ["OPTRE_FC_Spectre_Recovery","OPTRE_FC_Spectre_Recovery_Needler","OPTRE_FC_Spectre_Recovery_Ultra"];
_airborneVehicles append ["OPTRE_FC_Spectre_AI","OPTRE_FC_Spectre_AI_Needler","OPTRE_FC_Spectre_AI_Ultra","OPTRE_FC_Spectre_AT",
"OPTRE_FC_Spectre_AT_Needler","OPTRE_FC_Spectre_AT_Ultra"];
_tanks append ["OPTRE_FC_Wraith_Tank"];
_lightTanks append ["OPTRE_FC_Wraith"];
_aa append ["OPTRE_FC_SAM_Wraith_Needle","OPTRE_FC_Spectre_AA","OPTRE_FC_Spectre_AA_Needler","OPTRE_FC_Spectre_AA_Ultra","OPTRE_FC_Ghost_AA",
"OPTRE_FC_AA_Wraith","OPTRE_FC_AA_Wraith_NOFLAK","OPTRE_FC_AA_Wraith_Needle"];

_planesCAS append ["OPTRE_FC_Type26B_Banshee","OPTRE_FC_Type26B_Ultra_Banshee","OPTRE_FC_Type26N_Banshee","OPTRE_FC_Type27_Banshee"];
_planesAA append ["OPTRE_FC_Type26B_Banshee","OPTRE_FC_Type26B_Ultra_Banshee","OPTRE_FC_Type26N_Banshee","OPTRE_FC_Type27_Banshee"];

if (["MEU_Covenant"] call A3U_fnc_hasAddon) then {
    _transportHelicopters append ["MEU_Phantom_Light"];
    _helisAttack append ["MEU_Phantom"];
};
_transportHelicopters append ["OPTRE_FC_Spirit"];
_helisAttack append ["OPTRE_FC_Spirit_Concussion"];

_militiaLightArmed append ["OPTRE_FC_Ghost"];
_militiaTrucks append ["OPTRE_FC_Spectre_Transport"];
_militiaCars append ["OPTRE_FC_Spectre_Transport"];
_militiaAPCs append ["OPTRE_FC_Spectre"]; 

_staticAT append ["OPTRE_FC_Locust","OPTRE_FC_T26_AI","OPTRE_FC_T26_AT","OPTRE_FC_T29B_NVar","OPTRE_FC_T56_AAG"];
_staticAA append ["OPTRE_FC_T26_AA"];
_staticMortars append ["Plasma_Mortar"];

_radar append ["OPTRE_FC_Tyrant","OPTRE_FC_Tyrant_StandAlone"];
_SAM append ["OPTRE_FC_T29N_SAM","OPTRE_FC_TyrantAA","OPTRE_FC_T56_AA","OPTRE_FC_T56_AA","OPTRE_FC_TyrantAA_StandAlone"];

_mortarMagazineHE append ["Guided_Plasma_Mag_Test"];
_mortarMagazineSmoke append ["8Rnd_82mm_Mo_Smoke_white"];
_mortarMagazineFlare append ["8Rnd_82mm_Mo_Flare_white"];

_minefieldAT append ["OPTRE_FC_PlasmaMine_Ammo","OPTRE_FC_FuelRod_Mine_Ammo"];
_minefieldAPERS append ["OPTRE_FC_NeedleMine_Dispenser_AntiInfantry_Ammo"];

_baseClassSquadLeaderArray append ["OPTRE_FC_Elite_FieldMarshal","OPTRE_FC_Elite_HonorGuard","OPTRE_FC_Elite_Ultra","OPTRE_FC_Elite_Ultra3","OPTRE_FC_Elite_Ultra2","OPTRE_FC_Elite_Zealot"];
_baseClassRiflemanArray append ["OPTRE_Jackal_F","OPTRE_Jackal_Infantry_F","OPTRE_Jackal_Infantry2_F","OPTRE_Jackal_Major_F","OPTRE_Jackal_Major2_F",
"OPTRE_Jackal_SpecOps_F","OPTRE_Jackal_SpecOps2_F","OPTRE_Jackal_SpecOps3_F","OPTRE_FC_Elite_Major","OPTRE_FC_Elite_Minor",
"OPTRE_FC_Elite_Minor3","OPTRE_FC_Elite_Minor2","OPTRE_FC_Elite_SpecOps4","OPTRE_FC_Elite_Ultra3","OPTRE_FC_Elite_Zealot"];
_baseClassGrenadierArray append ["OPTRE_FC_Elite_FieldMarshal2","OPTRE_FC_Elite_SpecOps3","OPTRE_FC_Elite_Ultra2","OPTRE_FC_Elite_Zealot2"];
_baseClassLATArray append ["OPTRE_FC_Elite_MinorAT"];
_baseClassATArray append ["OPTRE_FC_Elite_MinorAT"];
_baseClassAAArray append ["OPTRE_FC_Elite_MinorAA"];
_baseClassMarksmanArray append ["OPTRE_Jackal_Marksman_F","OPTRE_Jackal_Marksman_Bracer_F","OPTRE_FC_Elite_SpecOps2","OPTRE_FC_Elite_Ultra"];
_baseClassSniperArray append ["OPTRE_Jackal_Sniper_F","OPTRE_Jackal_Sniper_Bracer_F","OPTRE_FC_Elite_SpecOps"];
_baseClassPatrolSniperArray append ["OPTRE_Jackal_Marksman_F","OPTRE_Jackal_Marksman_Bracer_F","OPTRE_FC_Elite_SpecOps2","OPTRE_FC_Elite_Ultra"];
_baseClassPatrolSpotterArray append ["OPTRE_Jackal_Sniper_F","OPTRE_Jackal_Sniper_Bracer_F","OPTRE_FC_Elite_SpecOps"];
// ================== Специальные роли ==================
_baseClassPoliceArray append ["OPTRE_Jackal_F"];

_baseClassCrewArray append ["OPTRE_FC_Elite_Minor"];
_baseClassPilotArray append ["OPTRE_FC_Elite_Minor","OPTRE_Jackal_Infantry_F"];
_baseClassOfficialArray append ["OPTRE_FC_Elite_Officer","OPTRE_FC_Elite_HonorGuard_Ultra"];
_baseClassUnarmedArray append ["OPTRE_Jackal_base_F"];

if (isClass (configFile >> "cfgVehicles" >> "WBK_HaloHunter_1")) then {
_baseClassSquadLeaderArray append ["WBK_EliteMainWeap_5","WBK_EliteMainWeap_7","WBK_EliteMainWeap_8","IMS_Elite_Melee_2"];
_baseClassRiflemanArray append ["WBK_EliteMainWeap_3","WBK_EliteMainWeap_2","WBK_EliteMainWeap_9","IMS_Elite_Melee_1",
"WBK_Grunt_2","WBK_Grunt_1","WBK_Grunt_5","WBK_Grunt_4","WBK_Grunt_Major","WBK_Grunt_Minor","WBK_Grunt_Specops","WBK_Grunt_Ultra"];
_baseClassGrenadierArray append ["WBK_EliteMainWeap_4"];
_baseClassExplosivesArray append ["WBK_Grunt_Sapper"];
_baseClassLATArray append ["WBK_Grunt_Heavy","WBK_Grunt_3","WBK_HaloHunter_1","WBK_HaloHunter_1_IF","WBK_HaloHunter_3","WBK_HaloHunter_3_IF","WBK_HaloHunter_2","WBK_HaloHunter_2_IF","WBK_EliteMainWeap_10"];
_baseClassATArray append ["WBK_HaloHunter_1","WBK_HaloHunter_1_IF","WBK_HaloHunter_3","WBK_HaloHunter_3_IF","WBK_HaloHunter_2","WBK_HaloHunter_2_IF","WBK_EliteMainWeap_10"];
_baseClassMarksmanArray append ["WBK_EliteMainWeap_1"];
_baseClassSniperArray append ["WBK_EliteMainWeap_1"];
_baseClassPatrolSniperArray append ["WBK_EliteMainWeap_1"];
_baseClassPatrolSpotterArray append ["WBK_EliteMainWeap_1"];
// ================== Специальные роли ==================
_baseClassPoliceArray append ["WBK_Grunt_2","WBK_Grunt_1","WBK_Grunt_5","WBK_Grunt_4","WBK_Grunt_Major","WBK_Grunt_Minor","WBK_Grunt_Specops","WBK_Grunt_Ultra"];

_baseClassOfficialArray append ["WBK_EliteMainWeap_5","WBK_EliteMainWeap_6"];
_baseClassUnarmedArray append ["OPTRE_Jackal_base_F"];
	if (isClass (configFile >> "cfgVehicles" >> "MAR_Grunt_Major_Boomstick")) then {
		_baseClassSquadLeaderArray append ["Mar_CustomSpartan_2","MAR_Stalker_1"];
		_baseClassRiflemanArray append ["MAR_Grunt_Major_Boomstick","MAR_Grunt_Major","MAR_Grunt_Major_Needler","MAR_Grunt_Ranger_Disruptor","MAR_Grunt_Ranger_Mangler",
		"MAR_Grunt_Ranger_PP","MAR_Grunt_Ranger_PlasmaRifle","MAR_Grunt_Ranger","MAR_Grunt_Specops","MAR_Grunt_Specops_SMG","MAR_CustomSpartan_1","MAR_Grunt_Ranger_CCN",
		"MAR_Grunt_Ranger_CCPP","Mar_CustomSpartan_2","MAR_Stalker_1"];
		_baseClassLATArray append ["MAR_Skitterer_1","MAR_Skitterer_2"];
		_baseClassATArray append ["MAR_Skitterer_1","MAR_Skitterer_2"];
		_baseClassMarksmanArray append ["Mar_CustomSpartan_3"];
		_baseClassSniperArray append ["Mar_CustomSpartan_3"];
		_baseClassPatrolSniperArray append ["Mar_CustomSpartan_3"];
		_baseClassPatrolSpotterArray append ["Mar_CustomSpartan_3"];
		// ================== Специальные роли ==================
		_baseClassPoliceArray append ["MAR_Grunt_Major_Boomstick","MAR_Grunt_Major","MAR_Grunt_Major_Needler","MAR_Grunt_Ranger_Disruptor","MAR_Grunt_Ranger_Mangler",
		"MAR_Grunt_Ranger_PP","MAR_Grunt_Ranger_PlasmaRifle","MAR_Grunt_Ranger","MAR_Grunt_Specops","MAR_Grunt_Specops_SMG","MAR_CustomSpartan_1","MAR_Grunt_Ranger_CCN",
		"MAR_Grunt_Ranger_CCPP"];
		(_loadoutData get "sidearms") append [
			["MAR_B_Disruptor", "", "", "", ["MAR_Disruptor_Mag", "MAR_Disruptor_Mag", "MAR_Disruptor_Mag"], [], ""],
			["MAR_Brute_Mangler", "", "", "", ["MAR_Mangler_Mag", "MAR_Mangler_Mag", "MAR_Mangler_Mag"], [], ""],
			["MAR_Brute_Spiker", "", "", "", ["MAR_Spiker_Mag", "MAR_Spiker_Mag", "MAR_Spiker_Mag"], [], ""]
		];
	};
};

_voices append ["JackalVO_01","EliteVO_01","EliteVO_02"];
_faces append ["sangheiliHead_DV","sangheiliHead_DVS2","sangheiliHead_DVS1","OPTRE_InvisibleFace","OPTRE_JackalFace_01","OPTRE_JackalFace_02",
"OPTRE_JackalFace_03","sangheiliHead_03","sangheiliHead_03S2","sangheiliHead_03S1","sangheiliHead_LV","sangheiliHead_LVS2","sangheiliHead_LVS1","sangheiliHead_02",
"sangheiliHead_02S2","sangheiliHead_02S1","sangheiliHead_01","sangheiliHead_01S2","sangheiliHead_01S1","sangheiliHead_VP","sangheiliHead_VPS2","sangheiliHead_VPS1"];

// Оружие
(_loadoutData get "slRifles") append [
	["OPTRE_FC_T25_Rifle", "", "", "", ["OPTRE_FC_T25_Rifle_Battery", "OPTRE_FC_T25_Rifle_Battery", "OPTRE_FC_T25_Rifle_Battery"], [], ""],
	["OPTRE_FC_T25J_Rifle", "", "", "", ["OPTRE_FC_T25J_Rifle_Battery", "OPTRE_FC_T25J_Rifle_Battery", "OPTRE_FC_T25J_Rifle_Battery"], [], ""],
	["OPTRE_FC_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],
	["OPTRE_FC_T51_Repeater", "", "", "", ["OPTRE_FC_T51_Repeater_Battery", "OPTRE_FC_T51_Repeater_Battery", "OPTRE_FC_T51_Repeater_Battery"], [], ""],
	["OPTRE_FC_T51J_Repeater", "", "", "", ["OPTRE_FC_T51J_Repeater_Battery", "OPTRE_FC_T51J_Repeater_Battery", "OPTRE_FC_T51J_Repeater_Battery"], [], ""],
	["OPTRE_FC_T60_PulseCarbine", "", "", "", ["OPTRE_FC_T60_Pulse_Carbine_Battery", "OPTRE_FC_T60_Pulse_Carbine_Battery", "OPTRE_FC_T60_Pulse_Carbine_Battery"], [], ""]
];
(_loadoutData get "rifles") append [
	["OPTRE_FC_Jackal_Shield", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "3OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_Jackal_Orange_Shield", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "3OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_Jackal_Red_Shield", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "3OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_Jackal_Shield_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],
	["OPTRE_FC_Jackal_Orange_Shield_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],
	["OPTRE_FC_Jackal_Red_Shield_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],

	["OPTRE_FC_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],

	["OPTRE_FC_T51_Repeater", "", "", "", ["OPTRE_FC_T51_Repeater_Battery", "OPTRE_FC_T51_Repeater_Battery", "OPTRE_FC_T51_Repeater_Battery"], [], ""],
	["OPTRE_FC_T51J_Repeater", "", "", "", ["OPTRE_FC_T51J_Repeater_Battery", "OPTRE_FC_T51J_Repeater_Battery", "OPTRE_FC_T51J_Repeater_Battery"], [], ""]
];
(_loadoutData get "carbines") append [
	["OPTRE_FC_T60_PulseCarbine", "", "", "", ["OPTRE_FC_T60_Pulse_Carbine_Battery", "OPTRE_FC_T60_Pulse_Carbine_Battery", "OPTRE_FC_T60_Pulse_Carbine_Battery"], [], ""]
];
(_loadoutData get "designatedGrenadeLaunchers") append [
	["OPTRE_FC_T50_ConcussionRifle", "", "", "", ["OPTRE_FC_T50_6rnd_mag", "OPTRE_FC_T50_6rnd_mag", "OPTRE_FC_T50_6rnd_mag"], [], ""]
];
(_loadoutData get "marksmanRifles") append [
	["OPTRE_FC_T31_NeedleRifle", "", "", "", ["OPTRE_FC_NeedleRifle_Mag", "OPTRE_FC_NeedleRifle_Mag", "OPTRE_FC_NeedleRifle_Mag"], [], ""],
	["OPTRE_FC_T51_Carbine", "", "", "", ["OPTRE_FC_T51_Ammo_Cartridge", "OPTRE_FC_T51_Ammo_Cartridge", "OPTRE_FC_T51_Ammo_Cartridge"], [], ""],
	["OPTRE_FC_T51B_Carbine", "", "", "", ["OPTRE_FC_Blamite_Mag", "OPTRE_FC_Blamite_Mag", "OPTRE_FC_Blamite_Mag"], [], ""]
];
(_loadoutData get "sniperRifles") append [
	["OPTRE_FC_T50_SRS", "", "", "", ["OPTRE_FC_T50_SRS_Battery", "OPTRE_FC_T50_SRS_Battery", "OPTRE_FC_T50_SRS_Battery"], [], ""]
];

// Пусковые установки
(_loadoutData get "missileATLaunchers") append [
	["OPTRE_FC_T33_FuelRod_Cannon_Guided", "", "", "", ["OPTRE_FC_T33_FuelRod_Pack", "OPTRE_FC_T33_FuelRod_Pack"], [], ""]
];
(_loadoutData get "AALaunchers") append [
	["OPTRE_FC_T33_FuelRod_Cannon_Guided", "", "", "", ["OPTRE_FC_T33_FuelRod_Pack_Guided", "OPTRE_FC_T33_FuelRod_Pack_Guided"], [], ""]
];
(_loadoutData get "sidearms") append [
	["OPTRE_FC_Plasma_Pistol", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_T25_Rifle_Folded", "", "", "", ["OPTRE_FC_T25_Rifle_Battery", "OPTRE_FC_T25_Rifle_Battery", "OPTRE_FC_T25_Rifle_Battery"], [], ""],
	["OPTRE_FC_T25J_Rifle_Folded", "", "", "", ["OPTRE_FC_T25J_Rifle_Battery", "OPTRE_FC_T25J_Rifle_Battery", "OPTRE_FC_T25J_Rifle_Battery"], [], ""]
];

// Взрывчатка
(_loadoutData get "ATMines") append ["OPTRE_FC_FuelRod_Mine","OPTRE_FC_PlasmaMine"];
(_loadoutData get "APMines") append ["OPTRE_FC_NeedleMine_Dispenser_AntiInfantry"];
(_loadoutData get "heavyExplosives") append ["OPTRE_FC_Ultra_Mine"];

// Гранаты
(_loadoutData get "antiInfantryGrenades") append ["OPTRE_FC_PlasmaGrenade"];

// Базовое снаряжение
(_loadoutData get "NVGs") append ["OPTRE_FC_NVG"];

// Офицерская экипировка
(_loadoutData get "officerUniforms") append ["OPTRE_U_Jackal_uniform"];
(_loadoutData get "officerVests") append ["OPTRE_V_Jackal_vest","OPTRE_V_Jackal_gold_vest","OPTRE_V_Jackal_red_vest","OPTRE_V_Jackal_Bracer_vest"];
(_loadoutData get "officerHats") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];

// Основная экипировка
(_loadoutData get "uniforms") append ["OPTRE_U_Jackal_uniform"];
(_loadoutData get "slUniforms") append ["OPTRE_U_Jackal_uniform"];
(_loadoutData get "vests") append ["OPTRE_V_Jackal_vest","OPTRE_V_Jackal_gold_vest","OPTRE_V_Jackal_red_vest","OPTRE_V_Jackal_Bracer_vest"];
(_loadoutData get "Hvests") append ["OPTRE_V_Jackal_Bracer_vest"];
(_loadoutData get "sniVests") append ["OPTRE_V_Jackal_vest","OPTRE_V_Jackal_gold_vest","OPTRE_V_Jackal_red_vest"];
(_loadoutData get "helmets") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];
(_loadoutData get "slHat") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];
(_loadoutData get "sniHats") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];

// Аксессуары
(_loadoutData get "goggles") append ["OPTRE_FC_Glasses_Cigar","OPTRE_FC_Jackal_Bracers"];
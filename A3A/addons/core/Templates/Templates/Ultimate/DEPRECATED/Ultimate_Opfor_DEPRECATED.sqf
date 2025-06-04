private _hasWs = "ws" in A3A_enabledDLC;
private _hasMarksman = "mark" in A3A_enabledDLC;
private _hasLawsOfWar = "orange" in A3A_enabledDLC;
private _hasTanks = "tank" in A3A_enabledDLC;
private _hasContact = "enoch" in A3A_enabledDLC;
private _hasJets = "jets" in A3A_enabledDLC;
private _hasHelicopters = "heli" in A3A_enabledDLC;
private _hasArtOfWar = "aow" in A3A_enabledDLC;
private _hasApex = "expansion" in A3A_enabledDLC;
private _hasGM = "gm" in A3A_enabledDLC;
private _hasCSLA = "csla" in A3A_enabledDLC;
private _hasRF = "rf" in A3A_enabledDLC;
private _hasSOG = "vn" in A3A_enabledDLC;
private _hasSPE = "spe" in A3A_enabledDLC;
private _hasEF = "ef" in A3A_enabledDLC;

//////////////////////////
//   Side Information   //
//////////////////////////
#include "..\..\..\script_component.hpp"

["name", "OPFOR"] call _fnc_saveToTemplate;
["spawnMarkerName", format [localize "STR_supportcorridor", "NATO"]] call _fnc_saveToTemplate;

["flag", "Flag_NATO_F"] call _fnc_saveToTemplate;
["flagTexture", QPATHTOFOLDER(Templates\Templates\Ultimate\flags\Ultimate_OPFOR.paa)] call _fnc_saveToTemplate;
["flagMarkerType", "a3u_flag_OPFOR"] call _fnc_saveToTemplate;

//////////////////////////
//       Vehicles       //
//////////////////////////

private _vehiclesSDV = [];

private _vehiclesDropPod = [];

["ammobox", "I_supplyCrate_F"] call _fnc_saveToTemplate;     //Don't touch or you die a sad and lonely death!
["surrenderCrate", "Box_IND_Wps_F"] call _fnc_saveToTemplate; //Changeing this from default will require you to define logistics attachement offset for the box type
["equipmentBox", "Box_AAF_Equip_F"] call _fnc_saveToTemplate; //Changeing this from default will require you to define logistics attachement offset for the box type

private _basic = [];
private _unarmedVehicles = [];
private _armedVehicles = [];
private _Trucks = [];
private _cargoTrucks = [];
private _ammoTrucks = [];
private _repairTrucks = [];
private _fuelTrucks = [];
private _medicalTrucks = [];
private _lightAPCs = [];
private _APCs = [];
private _IFVs = [];
private _airborneVehicles = [];
private _tanks = [];
private _lightTanks = [];
private _aa = [];

private _transportBoat = [];
private _gunBoat = [];

private _planesCAS = [];
private _planesAA = [];
private _planesLargeCAS = [];
private _planesLargeAA = [];

private _planesTransport = [];
private _gunship = [];

private _helisLight = [];
private _transportHelicopters = [];
private _helisLightAttack =  [];
private _helisAttack = [];

private _airPatrol = [];

private _artillery = [];
["magazines", createHashMapFromArray [
["I_Truck_02_MRL_F", ["12Rnd_230mm_rockets", "12Rnd_230mm_rockets_cluster"]],
["gm_pl_army_2s1",["gm_1Rnd_122x447mm_he_of462","gm_1Rnd_122x447mm_he_3of56"]],
["gm_pl_army_ural375d_mlrs",["gm_40Rnd_mlrs_122mm_he_9m22u","gm_40Rnd_mlrs_122mm_icm_9m218","gm_40Rnd_mlrs_122mm_mine_9m28k"]],
["gmx_aaf_m109_wdl",["gm_1Rnd_155mm_he_dm21","gm_1Rnd_155mm_he_dm111","gm_1Rnd_155mm_icm_dm602"]],
["gmx_aaf_kat1_463_mlrs_wdl",["gm_36Rnd_mlrs_110mm_he_dm21","gm_36Rnd_mlrs_110mm_icm_dm602","gm_36Rnd_mlrs_110mm_mine_dm711"]],
["B_T_MBT_01_arty_F", ["32Rnd_155mm_Mo_shells", "2Rnd_155mm_Mo_Cluster", "6Rnd_155mm_Mo_mine"]],
["I_E_Truck_02_MRL_F", ["12Rnd_230mm_rockets", "12Rnd_230mm_rockets_cluster"]],
["gm_dk_army_m109",["gm_1Rnd_155mm_he_dm21","gm_1Rnd_155mm_he_dm111","gm_1Rnd_155mm_icm_dm602"]],
["gm_ge_army_kat1_463_mlrs",["gm_36Rnd_mlrs_110mm_he_dm21","gm_36Rnd_mlrs_110mm_icm_dm602","gm_36Rnd_mlrs_110mm_mine_dm711"]],
["B_MBT_01_arty_F",["32Rnd_155mm_Mo_shells", "2Rnd_155mm_Mo_Cluster", "6Rnd_155mm_Mo_mine"]],
["B_MBT_01_mlrs_F",["12Rnd_230mm_rockets", "12Rnd_230mm_rockets_cluster"]],
["B_T_MBT_01_mlrs_F",["12Rnd_230mm_rockets", "12Rnd_230mm_rockets_cluster"]],
["APC_Wheeled_01_mortar_base_lxWS",["64Rnd_60mm_Mo_guided_lxWS"]] ////if you want to add new artillery you have to define it here
]] call _fnc_saveToTemplate;

private _uavsAttack = [];
private _uavsPortable = [];

//Config special vehicles - militia vehicles are mostly used in the early game, police cars are being used by troops around cities -- Example:

private _militiaLightArmed = [];
private _militiaTrucks = [];
private _militiaCars = [];
private _militiaAPCs = []; 

private _policeVehs = [];

private _staticMG = [];
private _staticAT = [];
private _staticAA = [];
private _staticMortars = [];
private _howitzers =  [];

private _radar = [];
private _SAM = [];

private _mortarMagazineHE = [];
private _mortarMagazineSmoke = [];
private _mortarMagazineFlare = [];

private _minefieldAT = [];
private _minefieldAPERS = [];

private _howitzerMagazineHE = [];

#include "Ultimate_Vehicle_Attributes.sqf"

["animations", [
    #include "..\vehicleAnimations\vehicleAnimations_Vanilla.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_WS.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_RF.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_GM.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_GMX_AAF.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_CSLA.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_SOG.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_SPE.sqf",
    #include "..\vehicleAnimations\vehicleAnimations_EF.sqf",
    #include "..\MOD_content\CUP\Vehicles_Animations.sqf"
]] call _fnc_saveToTemplate;

["variants", [
    #include "..\vehicleVariants\Vanilla_AAF\CSLA_AAF.sqf",
    #include "..\vehicleVariants\GM_police.sqf",
    #include "..\vehicleVariants\Vanilla_AAF\RF_AAF.sqf",
    #include "..\vehicleVariants\Vanilla_AAF\SPE_AAF.sqf",
    #include "..\vehicleVariants\Vanilla_AAF\Vanilla_AAF.sqf",
    #include "..\vehicleVariants\Vanilla_AAF\WS_AAF.sqf",
    #include "..\MOD_content\CUP\Vanilla_AAF\Vehicles_variants.sqf"
]] call _fnc_saveToTemplate;

// ================== Милиция ==================
private _baseClassMilitiaSquadLeaderArray = [];
private _baseClassMilitiaRiflemanArray = [];
private _baseClassMilitiaRadiomanArray = [];
private _baseClassMilitiaMedicArray = [];
private _baseClassMilitiaEngineerArray = [];
private _baseClassMilitiaExplosivesArray = [];
private _baseClassMilitiaGrenadierArray = [];
private _baseClassMilitiaLATArray = [];
private _baseClassMilitiaATArray = [];
private _baseClassMilitiaAAArray = [];
private _baseClassMilitiaMachineGunnerArray = [];
private _baseClassMilitiaMarksmanArray = [];
private _baseClassMilitiaSniperArray = [];
private _baseClassMilitiaPatrolSniperArray = [];
private _baseClassMilitiaPatrolSpotterArray = [];

// ================== Регулярные войска ==================
private _baseClassMilitarySquadLeaderArray = [];
private _baseClassMilitaryRiflemanArray = [];
private _baseClassMilitaryRadiomanArray = [];
private _baseClassMilitaryMedicArray = [];
private _baseClassMilitaryEngineerArray = [];
private _baseClassMilitaryExplosivesArray = [];
private _baseClassMilitaryGrenadierArray = [];
private _baseClassMilitaryLATArray = [];
private _baseClassMilitaryATArray = [];
private _baseClassMilitaryAAArray = [];
private _baseClassMilitaryMachineGunnerArray = [];
private _baseClassMilitaryMarksmanArray = [];
private _baseClassMilitarySniperArray = [];
private _baseClassMilitaryPatrolSniperArray = [];
private _baseClassMilitaryPatrolSpotterArray = [];

// ================== Элитные войска ==================
private _baseClassEliteSquadLeaderArray = [];
private _baseClassEliteRiflemanArray = [];
private _baseClassEliteRadiomanArray = [];
private _baseClassEliteMedicArray = [];
private _baseClassEliteEngineerArray = [];
private _baseClassEliteExplosivesArray = [];
private _baseClassEliteGrenadierArray = [];
private _baseClassEliteLATArray = [];
private _baseClassEliteATArray = [];
private _baseClassEliteAAArray = [];
private _baseClassEliteMachineGunnerArray = [];
private _baseClassEliteMarksmanArray = [];
private _baseClassEliteSniperArray = [];
private _baseClassElitePatrolSniperArray = [];
private _baseClassElitePatrolSpotterArray = [];

// ================== Спецназ ==================
private _baseClassSFSquadLeaderArray = [];
private _baseClassSFRiflemanArray = [];
private _baseClassSFRadiomanArray = [];
private _baseClassSFMedicArray = [];
private _baseClassSFEngineerArray = [];
private _baseClassSFExplosivesArray = [];
private _baseClassSFGrenadierArray = [];
private _baseClassSFLATArray = [];
private _baseClassSFATArray = [];
private _baseClassSFAAArray = [];
private _baseClassSFMachineGunnerArray = [];
private _baseClassSFMarksmanArray = [];
private _baseClassSFSniperArray = [];
private _baseClassSFPatrolSniperArray = [];
private _baseClassSFPatrolSpotterArray = [];

// ================== Специальные роли ==================
private _baseClassPoliceArray = [];

private _baseClassCrewArray = [];
private _baseClassPilotArray = [];
private _baseClassOfficialArray = [];
private _baseClassTraitorArray = [];
private _baseClassUnarmedArray = [];

/////////////////////
///  Identities   ///
/////////////////////

private _voices = [];
private _faces = [];
private _insignia = ["",""];

//////////////////////////
//       Loadouts       //
//////////////////////////

// Note on loadout array weighting:
// If a given loadoutData variable has a weighted array, make sure all mod/DLC compats also have a weighted array for the same.
// To simplify work on mod/DLC compats, the weighted arrays here are made to sum up to 10. This is so that compats have a consistent base to work off but is not strictly necessary.

private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["slRifles", []];
_loadoutData set ["rifles", []];
_loadoutData set ["carbines", []];
_loadoutData set ["grenadeLaunchers", []];
_loadoutData set ["designatedGrenadeLaunchers", []];
_loadoutData set ["SMGs", []];
_loadoutData set ["machineGuns", []];
_loadoutData set ["marksmanRifles", []];
_loadoutData set ["sniperRifles", []];

_loadoutData set ["lightATLaunchers", []];
_loadoutData set ["ATLaunchers", []];
_loadoutData set ["missileATLaunchers", []];
_loadoutData set ["AALaunchers", []];
_loadoutData set ["sidearms", []];

_loadoutData set ["ATMines", []];
_loadoutData set ["APMines", []];
_loadoutData set ["lightExplosives", []];
_loadoutData set ["heavyExplosives", []];

_loadoutData set ["antiInfantryGrenades", []];
_loadoutData set ["smokeGrenades", []];
_loadoutData set ["signalsmokeGrenades", []];

//Basic equipment. Shouldn't need touching most of the time.
//Mods might override this, or certain mods might want items removed (No GPSs in WW2, for example)
_loadoutData set ["maps", []];
_loadoutData set ["watches", []];
_loadoutData set ["compasses", []];
_loadoutData set ["radios", []];
_loadoutData set ["gpses", []];
_loadoutData set ["NVGs", []];
_loadoutData set ["binoculars", []];
_loadoutData set ["rangefinders", []];

_loadoutData set ["traitorUniforms", []];
_loadoutData set ["traitorVests", []];
_loadoutData set ["traitorHats", []];

_loadoutData set ["officerUniforms", []];
_loadoutData set ["officerVests", []];
_loadoutData set ["officerHats", []];

_loadoutData set ["cloakUniforms", []];
_loadoutData set ["cloakVests", []];

_loadoutData set ["uniforms", []];
_loadoutData set ["slUniforms", []];
_loadoutData set ["vests", []];
_loadoutData set ["Hvests", []];
_loadoutData set ["sniVests", []];
_loadoutData set ["backpacks", []];
_loadoutData set ["longRangeRadios", []];
_loadoutData set ["atBackpacks", []];
_loadoutData set ["helmets", []];
_loadoutData set ["slHat", []];
_loadoutData set ["sniHats", []];

_loadoutData set ["glasses", []];
_loadoutData set ["goggles", []];

//Item *set* definitions. These are added in their entirety to unit loadouts. No randomisation is applied.
_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the basic medical loadout for vanilla
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the standard medical loadout for vanilla
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the medic medical loadout for vanilla
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

//Unit type specific item sets. Add or remove these, depending on the unit types in use.
private _slItems = [];
private _eeItems = [];
private _mmItems = [];

if (A3A_hasACE) then {
    _slItems append ["ACE_microDAGR", "ACE_DAGR"];
    _eeItems append ["ACE_Clacker", "ACE_DefusalKit"];
    _mmItems append ["ACE_RangeCard", "ACE_ATragMX", "ACE_Kestrel4500"];
};

_loadoutData set ["items_squadLeader_extras", _slItems];
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

//TODO - ACE overrides for misc essentials, medical and engineer gear

private _slglammo = [];
private _glammo = [];

private _MXslglammo = [];
private _MXglammo = [];

if (_hasRF) then {
    _slglammo pushBack "1Rnd_RC40_HE_shell_RF";
    _glammo pushBack "1Rnd_RC40_HE_shell_RF";
    _MXslglammo pushBack "1Rnd_RC40_HE_shell_RF";
    _MXglammo pushBack "1Rnd_RC40_HE_shell_RF";
};

if (_hasWs) then {
    _slglammo pushBack "1Rnd_Pellet_Grenade_shell_lxWS";
	_glammo pushBack "1Rnd_Pellet_Grenade_shell_lxWS";
    _MXslglammo pushBack "1Rnd_Pellet_Grenade_shell_lxWS";
	_MXglammo pushBack "1Rnd_Pellet_Grenade_shell_lxWS";
};

_Accessories = [""];
_TlOptics = [""];
_RifleOptics = [""];
_MGOptics = [""];
_SMGOptics = [""];
_P90Optics = [""];
_MarksmanOptics = [""];
_SniperOptics = [""];
_Bipods = [""];
_MSBSOptics = [""];


//////content

#include "Ultimate_content_Opfor.sqf"

///////////////////////////////////////
//    Special Forces Loadout Data    //
///////////////////////////////////////

//private _sfLoadoutData = _loadoutData call _fnc_copyLoadoutData; 


/////////////////////////////////
//    Elite Loadout Data       //
/////////////////////////////////

//private _eliteLoadoutData = _loadoutData call _fnc_copyLoadoutData; 

/////////////////////////////////
//    Military Loadout Data    //
/////////////////////////////////

//private _militaryLoadoutData = _loadoutData call _fnc_copyLoadoutData; 


////////////////////////////////
//    Militia Loadout Data    //
////////////////////////////////

//private _militiaLoadoutData = _loadoutData call _fnc_copyLoadoutData; 

///////////////////////////////
//    Police Loadout Data    //
///////////////////////////////

private _policeLoadoutData = _loadoutData call _fnc_copyLoadoutData; 
_policeLoadoutData set ["uniforms", []];
_policeLoadoutData set ["vests", []];

_policeLoadoutData set ["helmets", []];
_policeLoadoutData set ["SMGs", []];
_policeLoadoutData set ["sidearms", []];
//////////////////////////
//    Misc Loadouts     //
//////////////////////////

private _crewLoadoutData = _loadoutData call _fnc_copyLoadoutData; 
_crewLoadoutData set ["uniforms", []];
_crewLoadoutData set ["vests", []];
_crewLoadoutData set ["helmets", []];

private _pilotLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_pilotLoadoutData set ["uniforms", []];
_pilotLoadoutData set ["vests", []];
_pilotLoadoutData set ["helmets", []];

#include "Ultimate_content_Opfor_Misc.sqf"

private _baseClassMilitiaSquadLeader = ["baseClass", _baseClassMilitiaSquadLeaderArray, true];
private _baseClassMilitiaRifleman = ["baseClass", _baseClassMilitiaRiflemanArray, true];
private _baseClassMilitiaRadioman = ["baseClass", _baseClassMilitiaRadiomanArray, true];
private _baseClassMilitiaMedic = ["baseClass", _baseClassMilitiaMedicArray, true];
private _baseClassMilitiaEngineer = ["baseClass", _baseClassMilitiaEngineerArray, true];
private _baseClassMilitiaExplosives = ["baseClass", _baseClassMilitiaExplosivesArray, true];
private _baseClassMilitiaGrenadier = ["baseClass", _baseClassMilitiaGrenadierArray, true];
private _baseClassMilitiaLAT = ["baseClass", _baseClassMilitiaLATArray, true];
private _baseClassMilitiaAT = ["baseClass", _baseClassMilitiaATArray, true];
private _baseClassMilitiaAA = ["baseClass", _baseClassMilitiaAAArray, true];
private _baseClassMilitiaMachineGunner = ["baseClass", _baseClassMilitiaMachineGunnerArray, true];
private _baseClassMilitiaMarksman = ["baseClass", _baseClassMilitiaMarksmanArray, true];
private _baseClassMilitiaSniper = ["baseClass", _baseClassMilitiaSniperArray, true];
private _baseClassMilitiaPatrolSniper = ["baseClass", _baseClassMilitiaPatrolSniperArray, true];
private _baseClassMilitiaPatrolSpotter = ["baseClass", _baseClassMilitiaPatrolSpotterArray, true];

private _baseClassMilitarySquadLeader = ["baseClass", _baseClassMilitarySquadLeaderArray, true];
private _baseClassMilitaryRifleman = ["baseClass", _baseClassMilitaryRiflemanArray, true];
private _baseClassMilitaryRadioman = ["baseClass", _baseClassMilitaryRadiomanArray, true];
private _baseClassMilitaryMedic = ["baseClass", _baseClassMilitaryMedicArray, true];
private _baseClassMilitaryEngineer = ["baseClass", _baseClassMilitaryEngineerArray, true];
private _baseClassMilitaryExplosives = ["baseClass", _baseClassMilitaryExplosivesArray, true];
private _baseClassMilitaryGrenadier = ["baseClass", _baseClassMilitaryGrenadierArray, true];
private _baseClassMilitaryLAT = ["baseClass", _baseClassMilitaryLATArray, true];
private _baseClassMilitaryAT = ["baseClass", _baseClassMilitaryATArray, true];
private _baseClassMilitaryAA = ["baseClass", _baseClassMilitaryAAArray, true];
private _baseClassMilitaryMachineGunner = ["baseClass", _baseClassMilitaryMachineGunnerArray, true];
private _baseClassMilitaryMarksman = ["baseClass", _baseClassMilitaryMarksmanArray, true];
private _baseClassMilitarySniper = ["baseClass", _baseClassMilitarySniperArray, true];
private _baseClassMilitaryPatrolSniper = ["baseClass", _baseClassMilitaryPatrolSniperArray, true];
private _baseClassMilitaryPatrolSpotter = ["baseClass", _baseClassMilitaryPatrolSpotterArray, true];

private _baseClassEliteSquadLeader = ["baseClass", _baseClassEliteSquadLeaderArray, true];
private _baseClassEliteRifleman = ["baseClass", _baseClassEliteRiflemanArray, true];
private _baseClassEliteRadioman = ["baseClass", _baseClassEliteRadiomanArray, true];
private _baseClassEliteMedic = ["baseClass", _baseClassEliteMedicArray, true];
private _baseClassEliteEngineer = ["baseClass", _baseClassEliteEngineerArray, true];
private _baseClassEliteExplosives = ["baseClass", _baseClassEliteExplosivesArray, true];
private _baseClassEliteGrenadier = ["baseClass", _baseClassEliteGrenadierArray, true];
private _baseClassEliteLAT = ["baseClass", _baseClassEliteLATArray, true];
private _baseClassEliteAT = ["baseClass", _baseClassEliteATArray, true];
private _baseClassEliteAA = ["baseClass", _baseClassEliteAAArray, true];
private _baseClassEliteMachineGunner = ["baseClass", _baseClassEliteMachineGunnerArray, true];
private _baseClassEliteMarksman = ["baseClass", _baseClassEliteMarksmanArray, true];
private _baseClassEliteSniper = ["baseClass", _baseClassEliteSniperArray, true];
private _baseClassElitePatrolSniper = ["baseClass", _baseClassElitePatrolSniperArray, true];
private _baseClassElitePatrolSpotter = ["baseClass", _baseClassElitePatrolSpotterArray, true];

private _baseClassSFSquadLeader = ["baseClass", _baseClassSFSquadLeaderArray, true];
private _baseClassSFRifleman = ["baseClass", _baseClassSFRiflemanArray, true];
private _baseClassSFRadioman = ["baseClass", _baseClassSFRadiomanArray, true];
private _baseClassSFMedic = ["baseClass", _baseClassSFMedicArray, true];
private _baseClassSFEngineer = ["baseClass", _baseClassSFEngineerArray, true];
private _baseClassSFExplosives = ["baseClass", _baseClassSFExplosivesArray, true];
private _baseClassSFGrenadier = ["baseClass", _baseClassSFGrenadierArray, true];
private _baseClassSFLAT = ["baseClass", _baseClassSFLATArray, true];
private _baseClassSFAT = ["baseClass", _baseClassSFATArray, true];
private _baseClassSFAA = ["baseClass", _baseClassSFAAArray, true];
private _baseClassSFMachineGunner = ["baseClass", _baseClassSFMachineGunnerArray, true];
private _baseClassSFMarksman = ["baseClass", _baseClassSFMarksmanArray, true];
private _baseClassSFSniper = ["baseClass", _baseClassSFSniperArray, true];
private _baseClassSFPatrolSniper = ["baseClass", _baseClassSFPatrolSniperArray, true];
private _baseClassSFPatrolSpotter = ["baseClass", _baseClassSFPatrolSpotterArray, true];

private _baseClassPolice = ["baseClass", _baseClassPoliceArray, true];

private _baseClassCrew = ["baseClass", _baseClassCrewArray, true];
private _baseClassPilot = ["baseClass", _baseClassPilotArray, true];
private _baseClassOfficial = ["baseClass", _baseClassOfficialArray, true];
private _baseClassTraitor = ["baseClass", _baseClassTraitorArray, true];
private _baseClassUnarmed = ["baseClass", _baseClassUnarmedArray, true];

["faces", _faces] call _fnc_saveToTemplate;
["voices", _voices] call _fnc_saveToTemplate;
["insignia", _insignia] call _fnc_saveToTemplate;

["vehiclesDropPod", _vehiclesDropPod] call _fnc_saveToTemplate; 
["vehiclesPlanesLargeCAS", _planesLargeCAS] call _fnc_saveToTemplate;
["vehiclesPlanesLargeAA", _planesLargeAA] call _fnc_saveToTemplate;
["vehiclesSDV", _vehiclesSDV] call _fnc_saveToTemplate;
["uavsAttack", _uavsAttack] call _fnc_saveToTemplate;
["howitzerMagazineHE", "magazine_ShipCannon_120mm_HE_shells_x32","magazine_ShipCannon_120mm_HE_cluster_shells_x2"] call _fnc_saveToTemplate;
["mortarMagazineHE", "8Rnd_82mm_Mo_shells"] call _fnc_saveToTemplate;
["mortarMagazineSmoke", "8Rnd_82mm_Mo_Smoke_white"] call _fnc_saveToTemplate;
["mortarMagazineFlare", "8Rnd_82mm_Mo_Flare_white"] call _fnc_saveToTemplate;
/* _howitzerMagazineHE call _fnc_saveToTemplate;
_mortarMagazineHE call _fnc_saveToTemplate;
_mortarMagazineSmoke call _fnc_saveToTemplate;
_mortarMagazineFlare call _fnc_saveToTemplate; */
["minefieldAPERS", _minefieldAT] call _fnc_saveToTemplate;
["minefieldAT", _minefieldAPERS] call _fnc_saveToTemplate;
["staticMortars", _staticMortars] call _fnc_saveToTemplate;
["vehiclesAirPatrol", _airPatrol] call _fnc_saveToTemplate;
["vehiclesPlanesGunship", _gunship] call _fnc_saveToTemplate;
["vehiclesGunBoats", _gunBoat] call _fnc_saveToTemplate;
["vehiclesTransportBoats", _transportBoat] call _fnc_saveToTemplate;
["staticAA", _staticAA] call _fnc_saveToTemplate;
["uavsPortable", _uavsPortable] call _fnc_saveToTemplate;
["staticMGs", _staticMG] call _fnc_saveToTemplate;
["staticAT", _staticAT] call _fnc_saveToTemplate;
["vehiclesMilitiaTrucks", _militiaTrucks] call _fnc_saveToTemplate;
["vehiclesMilitiaLightArmed", _militiaLightArmed] call _fnc_saveToTemplate;
["vehiclesMilitiaCars", _militiaCars] call _fnc_saveToTemplate;
["vehiclesPolice", _policeVehs] call _fnc_saveToTemplate;
["vehiclesBasic", _basic] call _fnc_saveToTemplate;
["vehiclesPlanesTransport", _planesTransport] call _fnc_saveToTemplate;
["vehiclesHelisLight", _helisLight] call _fnc_saveToTemplate;
["vehiclesHelisLightAttack", _helisLightAttack] call _fnc_saveToTemplate;
["vehiclesHelisAttack", _helisAttack] call _fnc_saveToTemplate;
["vehiclesHelisTransport", _transportHelicopters] call _fnc_saveToTemplate;
["staticHowitzers", _howitzers] call _fnc_saveToTemplate;
["vehicleRadar", _radar] call _fnc_saveToTemplate;
["vehicleSam", _SAM] call _fnc_saveToTemplate;
["vehiclesPlanesCAS", _planesCAS] call _fnc_saveToTemplate;
["vehiclesPlanesAA", _planesAA] call _fnc_saveToTemplate;
["vehiclesArtillery", _artillery] call _fnc_saveToTemplate;
["vehiclesLightAPCs", _lightAPCs] call _fnc_saveToTemplate;
["vehiclesAPCs", _APCs] call _fnc_saveToTemplate;
["vehiclesIFVs", _IFVs] call _fnc_saveToTemplate;
["vehiclesMilitiaAPCs", _militiaAPCs] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", _unarmedVehicles] call _fnc_saveToTemplate;
["vehiclesLightArmed", _armedVehicles] call _fnc_saveToTemplate;
["vehiclesLightTanks",  _lightTanks] call _fnc_saveToTemplate;
["vehiclesAirborne", _airborneVehicles] call _fnc_saveToTemplate;
["vehiclesAA", _aa] call _fnc_saveToTemplate;
["vehiclesCargoTrucks", _cargoTrucks] call _fnc_saveToTemplate;
["vehiclesTanks", _tanks] call _fnc_saveToTemplate;
["vehiclesTrucks", _Trucks] call _fnc_saveToTemplate;
["vehiclesAmmoTrucks", _ammoTrucks] call _fnc_saveToTemplate;
["vehiclesRepairTrucks", _repairTrucks] call _fnc_saveToTemplate;
["vehiclesFuelTrucks", _fuelTrucks] call _fnc_saveToTemplate;
["vehiclesMedical", _medicalTrucks] call _fnc_saveToTemplate;

/////////////////////////////////
//    Unit Type Definitions    //
/////////////////////////////////

private _squadLeaderTemplate = {
    [selectRandomWeighted ["helmets", 2, "slHat", 1]] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
    [["slUniforms", "uniforms"] call _fnc_fallback] call _fnc_setUniform;

    [["slRifles", "rifles"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;
    ["primary", 4] call _fnc_addAdditionalMuzzleMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_squadLeader_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 2] call _fnc_addItem;
    ["signalsmokeGrenades", 2] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["gpses"] call _fnc_addGPS;
    ["binoculars"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _riflemanTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;


    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

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

private _radiomanTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["longRangeRadios"] call _fnc_setBackpack;


    [selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

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
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;

    [selectRandomWeighted ["carbines", 0.4, "SMGs", 0.6]] call _fnc_setPrimary;
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

private _grenadierTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "glasses", 0.75, "goggles", 1.25]] call _fnc_setFacewear;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;

    if (random 1 < 0.3) then {
        [["designatedGrenadeLaunchers", "grenadeLaunchers"] call _fnc_fallback] call _fnc_setPrimary;
        ["backpacks"] call _fnc_setBackpack;
    } else {
        ["grenadeLaunchers"] call _fnc_setPrimary;
    };
    
    ["primary", 6] call _fnc_addMagazines;
    ["primary", 10] call _fnc_addAdditionalMuzzleMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

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
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["Hvests", "vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
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

private _engineerTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;

    [selectRandomWeighted ["carbines", 0.4, "SMGs", 0.6]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_engineer_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    if (random 1 > 0.5) then {["lightExplosives", 1] call _fnc_addItem;};

    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _latTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.5, "glasses", 0.75, "goggles", 1]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["atBackpacks", "backpacks"] call _fnc_fallback] call _fnc_setBackpack;

    [selectRandomWeighted ["rifles", 0.2, "carbines", 0.5, "SMGs", 0.3]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    [["lightATLaunchers", "ATLaunchers"] call _fnc_fallback] call _fnc_setLauncher;
    //TODO - Add a check if it's disposable.
    ["launcher", 3] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_lat_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 1] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _atTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["atBackpacks", "backpacks"] call _fnc_fallback] call _fnc_setBackpack;

    [selectRandomWeighted ["rifles", 0.2, "carbines", 0.5, "SMGs", 0.3]] call _fnc_setPrimary;
    ["primary", 5] call _fnc_addMagazines;

    [selectRandom ["ATLaunchers", "missileATLaunchers"]] call _fnc_setLauncher;
    //TODO - Add a check if it's disposable.
    ["launcher", 3] call _fnc_addMagazines;

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
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    [["atBackpacks", "backpacks"] call _fnc_fallback] call _fnc_setBackpack;

    [selectRandomWeighted ["rifles", 0.2, "carbines", 0.5, "SMGs", 0.3]] call _fnc_setPrimary;
    ["primary", 5] call _fnc_addMagazines;

    ["AALaunchers"] call _fnc_setLauncher;
    //TODO - Add a check if it's disposable.
    ["launcher", 3] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_aa_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 1] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _machineGunnerTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;
    ["backpacks"] call _fnc_setBackpack;

    ["machineGuns"] call _fnc_setPrimary;
    ["primary", 4] call _fnc_addMagazines;

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

private _marksmanTemplate = {
    [selectRandomWeighted ["helmets", 2, "sniHats", 1]] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
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
    ["rangefinders"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _sniperTemplate = {
    ["sniHats"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["sniVests","vests"] call _fnc_fallback] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;


    [["sniperRifles", "marksmanRifles"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_sniper_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["rangefinders"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};

private _policeTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;


    ["SMGs"] call _fnc_setPrimary;
    ["primary", 3] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_police_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["smokeGrenades", 1] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _crewTemplate = {
    ["helmets"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    ["vests"] call _fnc_setVest;
    ["uniforms"] call _fnc_setUniform;

    [selectRandom ["carbines", "SMGs"]] call _fnc_setPrimary;
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
    ["uniforms"] call _fnc_setUniform;

    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_unarmed_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _traitorTemplate = {
    ["traitorHats"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.25, "glasses", 0.75]] call _fnc_setFacewear;
    ["traitorVests"] call _fnc_setVest;
    ["traitorUniforms"] call _fnc_setUniform;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_unarmed_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _officerTemplate = {
    ["officerHats"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 1.25, "glasses", 0.75]] call _fnc_setFacewear;
    ["officerVests"] call _fnc_setVest;
    ["officerUniforms"] call _fnc_setUniform;

    [["SMGs", "carbines"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 3] call _fnc_addMagazines;
    
    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_basic"] call _fnc_addItemSet;
    ["items_unarmed_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
};

private _patrolSniperTemplate = {
    ["sniHats"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["cloakVests","vests"] call _fnc_fallback] call _fnc_setVest;
    [["cloakUniforms","uniforms"] call _fnc_fallback] call _fnc_setUniform;

    [["sniperRifles", "marksmanRifles"] call _fnc_fallback] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_sniper_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["NVGs"] call _fnc_addNVGs;
};

private _patrolSpotterTemplate = {
    ["sniHats"] call _fnc_setHelmet;
    [selectRandomWeighted [[], 2, "glasses", 0.75, "goggles", 0.5]] call _fnc_setFacewear;
    [["cloakVests","vests"] call _fnc_fallback] call _fnc_setVest;
    [["cloakUniforms","uniforms"] call _fnc_fallback] call _fnc_setUniform;

    [selectRandom ["rifles", "carbines", "marksmanRifles"]] call _fnc_setPrimary;
    ["primary", 6] call _fnc_addMagazines;

    ["sidearms"] call _fnc_setHandgun;
    ["handgun", 2] call _fnc_addMagazines;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_sniper_extras"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;
    ["antiInfantryGrenades", 1] call _fnc_addItem;
    ["smokeGrenades", 2] call _fnc_addItem;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["radios"] call _fnc_addRadio;
    ["rangefinders"] call _fnc_addBinoculars;
    ["NVGs"] call _fnc_addNVGs;
};


////////////////////////////////////////////////////////////////////////////////////////
//  You shouldn't touch below this line unless you really really know what you're doing.
//  Things below here can and will break the gamemode if improperly changed.
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////
//  Special Forces Units   //
/////////////////////////////
private _prefix = "SF";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [_baseClassSFSquadLeader], [_prefix]],
    ["Rifleman", _riflemanTemplate, [_baseClassSFRifleman], [_prefix]],
    ["Radioman", _radiomanTemplate, [_baseClassSFRadioman], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true], _baseClassSFMedic], [_prefix]],
    ["Engineer", _engineerTemplate, [["engineer", true], _baseClassSFEngineer], [_prefix]],
    ["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true], _baseClassSFExplosives], [_prefix]],
    ["Grenadier", _grenadierTemplate, [_baseClassSFGrenadier], [_prefix]],
    ["LAT", _latTemplate, [_baseClassSFLAT], [_prefix]],
    ["AT", _atTemplate, [_baseClassSFAT], [_prefix]],
    ["AA", _aaTemplate, [_baseClassSFAA], [_prefix]],
    ["MachineGunner", _machineGunnerTemplate, [_baseClassSFMachineGunner], [_prefix]],
    ["Marksman", _marksmanTemplate, [_baseClassSFMarksman], [_prefix]],
    ["Sniper", _sniperTemplate, [_baseClassSFSniper], [_prefix]],
    ["PatrolSniper", _patrolSniperTemplate, [_baseClassSFPatrolSniper], [_prefix]],
    ["PatrolSpotter", _patrolSpotterTemplate, [_baseClassSFPatrolSpotter], [_prefix]]
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

///////////////////////
//  Military Units   //
///////////////////////
private _prefix = "military";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [_baseClassMilitarySquadLeader], [_prefix]],
    ["Rifleman", _riflemanTemplate, [_baseClassMilitaryRifleman], [_prefix]],
    ["Radioman", _radiomanTemplate, [_baseClassMilitaryRadioman], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true], _baseClassMilitaryMedic], [_prefix]],
    ["Engineer", _engineerTemplate, [["engineer", true], _baseClassMilitaryEngineer], [_prefix]],
    ["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true], _baseClassMilitaryExplosives], [_prefix]],
    ["Grenadier", _grenadierTemplate, [_baseClassMilitaryGrenadier], [_prefix]],
    ["LAT", _latTemplate, [_baseClassMilitaryLAT], [_prefix]],
    ["AT", _atTemplate, [_baseClassMilitaryAT], [_prefix]],
    ["AA", _aaTemplate, [_baseClassMilitaryAA], [_prefix]],
    ["MachineGunner", _machineGunnerTemplate, [_baseClassMilitaryMachineGunner], [_prefix]],
    ["Marksman", _marksmanTemplate, [_baseClassMilitaryMarksman], [_prefix]],
    ["Sniper", _sniperTemplate, [_baseClassMilitarySniper], [_prefix]],
    ["PatrolSniper", _patrolSniperTemplate, [_baseClassMilitaryPatrolSniper], [_prefix]],
    ["PatrolSpotter", _patrolSpotterTemplate, [_baseClassMilitaryPatrolSpotter], [_prefix]] 
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

////////////////////////
//    Police Units    //
////////////////////////
private _prefix = "police";
private _unitTypes = [
    ["SquadLeader", _policeTemplate, [_baseClassPolice], [_prefix]],
    ["Standard", _policeTemplate, [_baseClassPolice], [_prefix]]
];

[_prefix, _unitTypes, _policeLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

////////////////////////
//    Militia Units    //
////////////////////////
private _prefix = "militia";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [_baseClassMilitiaSquadLeader], [_prefix]],
    ["Rifleman", _riflemanTemplate, [_baseClassMilitiaRifleman], [_prefix]],
    ["Radioman", _radiomanTemplate, [_baseClassMilitiaRadioman], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true], _baseClassMilitiaMedic], [_prefix]],
    ["Engineer", _engineerTemplate, [["engineer", true], _baseClassMilitiaEngineer], [_prefix]],
    ["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true], _baseClassMilitiaExplosives], [_prefix]],
    ["Grenadier", _grenadierTemplate, [_baseClassMilitiaGrenadier], [_prefix]],
    ["LAT", _latTemplate, [_baseClassMilitiaLAT], [_prefix]],
    ["AT", _atTemplate, [_baseClassMilitiaAT], [_prefix]],
    ["AA", _aaTemplate, [_baseClassMilitiaAA], [_prefix]],
    ["MachineGunner", _machineGunnerTemplate, [_baseClassMilitiaMachineGunner], [_prefix]],
    ["Marksman", _marksmanTemplate, [_baseClassMilitiaMarksman], [_prefix]],
    ["Sniper", _sniperTemplate, [_baseClassMilitiaSniper], [_prefix]],
    ["PatrolSniper", _patrolSniperTemplate, [_baseClassMilitiaPatrolSniper], [_prefix]],
    ["PatrolSpotter", _patrolSpotterTemplate, [_baseClassMilitiaPatrolSpotter], [_prefix]] 
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

///////////////////////
//  Elite Units   //
///////////////////////
private _prefix = "elite";
private _unitTypes = [
    ["SquadLeader", _squadLeaderTemplate, [_baseClassEliteSquadLeader], [_prefix]],
    ["Rifleman", _riflemanTemplate, [_baseClassEliteRifleman], [_prefix]],
    ["Radioman", _radiomanTemplate, [_baseClassEliteRadioman], [_prefix]],
    ["Medic", _medicTemplate, [["medic", true], _baseClassEliteMedic], [_prefix]],
    ["Engineer", _engineerTemplate, [["engineer", true], _baseClassEliteEngineer], [_prefix]],
    ["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true], _baseClassEliteExplosives], [_prefix]],
    ["Grenadier", _grenadierTemplate, [_baseClassEliteGrenadier], [_prefix]],
    ["LAT", _latTemplate, [_baseClassEliteLAT], [_prefix]],
    ["AT", _atTemplate, [_baseClassEliteAT], [_prefix]],
    ["AA", _aaTemplate, [_baseClassEliteAA], [_prefix]],
    ["MachineGunner", _machineGunnerTemplate, [_baseClassEliteMachineGunner], [_prefix]],
    ["Marksman", _marksmanTemplate, [_baseClassEliteMarksman], [_prefix]],
    ["Sniper", _sniperTemplate, [_baseClassEliteSniper], [_prefix]],
    ["PatrolSniper", _patrolSniperTemplate, [_baseClassElitePatrolSniper], [_prefix]],
    ["PatrolSpotter", _patrolSpotterTemplate, [_baseClassElitePatrolSpotter], [_prefix]] 
];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;

//////////////////////
//    Misc Units    //
//////////////////////

//The following lines are determining the loadout of vehicle crew
["other", [["Crew", _crewTemplate, [_baseClassCrew]]], _crewLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
//The following lines are determining the loadout of the pilots
["other", [["Pilot", _crewTemplate, [_baseClassPilot]]], _pilotLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
//The following lines are determining the loadout for the unit used in the "kill the official" mission
["other", [["Official", _SquadLeaderTemplate, [_baseClassOfficial]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
//The following lines are determining the loadout for the AI used in the "kill the traitor" mission
["other", [["Traitor", _traitorTemplate, [_baseClassTraitor]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
//The following lines are determining the loadout for the AI used in the "Invader Punishment" mission
["other", [["Unarmed", _UnarmedTemplate, [_baseClassUnarmed]]], _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
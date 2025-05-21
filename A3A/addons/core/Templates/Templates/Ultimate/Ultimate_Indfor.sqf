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
private _hasEF = "ef" in A3A_enabledDLC;

///////////////////////////
//   Rebel Information   //
///////////////////////////
#include "..\..\..\script_component.hpp"

["name", "INDFOR"] call _fnc_saveToTemplate;

["flag", "Flag_FIA_F"] call _fnc_saveToTemplate;
["flagTexture", QPATHTOFOLDER(Templates\Templates\Ultimate\flags\Ultimate_INDFOR.paa)] call _fnc_saveToTemplate;
["flagMarkerType", "a3u_flag_INDFOR"] call _fnc_saveToTemplate;

private _vehiclesBasic = [];
private _vehiclesLightUnarmed = [];
private _vehiclesLightArmed = [];
private _vehiclesAt = [];
private _VehTruck = [];
private _vehicleAA = [];

private _vehiclesBoat = [];

private _vehiclesMedical = [];

private _vehiclesSupply = [];

private _vehiclePlane = [];

private _vehicleCivPlane = [];

private _vehiclesCivCar = [];
private _CivTruck = [];
private _civHelicopters = [];

private _CivBoat = [];

private _staticMG = [];
private _staticAT = [];
private _staticAA = [];
private _staticMortars = [];

private _MortarMagHE = [];
private _MortarMagSmoke = [];


private _minesAT = [];
private _minesAPERS = [];

private _breachingExplosivesAPC = [];
private _breachingExplosivesTank = [];

//////////////////////////////////////
//       Antistasi Plus Stuff       //
//////////////////////////////////////

#include "Ultimate_Reb_Vehicle_Attributes.sqf"

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

private _initialRebelEquipment = [];

if (A3A_hasTFAR) then {_initialRebelEquipment append ["tf_microdagr","tf_anprc154"]};
if (A3A_hasTFAR && startWithLongRangeRadio) then {_initialRebelEquipment append ["tf_anprc155","tf_anprc155_coyote"]};
if (A3A_hasTFARBeta) then {_initialRebelEquipment append ["TFAR_microdagr","TFAR_anprc154"]};
if (A3A_hasTFARBeta && startWithLongRangeRadio) then {_initialRebelEquipment append ["TFAR_anprc155","TFAR_anprc155_coyote"]};

private _rebUniforms = [];

private _headgear = [];

/////////////////////
///  Identities   ///
/////////////////////

private _faces = [];
private _voices = [];
private _glasses = [];
private _goggles = [];

#include "Content_Indfor\Ultimate_content_Indfor.sqf"

//////////////////////////
//       Loadouts       //
//////////////////////////

private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];
_loadoutData set ["binoculars", ["Binocular"]];
_loadoutData set ["uniforms", _rebUniforms];

_loadoutData set ["glasses", _glasses];
_loadoutData set ["goggles", _goggles];

_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

["staticMortarMagHE", _MortarMagHE] call _fnc_saveToTemplate;
["staticMortarMagSmoke", _MortarMagSmoke] call _fnc_saveToTemplate;
["minesAT", _minesAT] call _fnc_saveToTemplate;
["minesAPERS", _minesAPERS] call _fnc_saveToTemplate;
["breachingExplosivesAPC", _breachingExplosivesAPC] call _fnc_saveToTemplate;
["breachingExplosivesTank", _breachingExplosivesTank] call _fnc_saveToTemplate;

["uniforms", _rebUniforms] call _fnc_saveToTemplate;

["headgear", _headgear] call _fnc_saveToTemplate;

["voices", _voices] call _fnc_saveToTemplate;
["faces", _faces] call _fnc_saveToTemplate;

["vehiclesCivPlane", _vehicleCivPlane] call _fnc_saveToTemplate;
["vehiclesCivSupply", _vehiclesSupply] call _fnc_saveToTemplate;
["vehiclesMedical", _vehiclesMedical] call _fnc_saveToTemplate;
["vehiclesBoat", _vehiclesBoat] call _fnc_saveToTemplate;
["staticMortars", _staticMortars] call _fnc_saveToTemplate;
["staticMGs", _staticMG] call _fnc_saveToTemplate;
["staticAT", _staticAT] call _fnc_saveToTemplate;
["vehiclesCivHeli", _civHelicopters] call _fnc_saveToTemplate;
["vehiclesBasic", _vehiclesBasic] call _fnc_saveToTemplate;
["vehiclesPlane", _vehiclePlane] call _fnc_saveToTemplate;
["vehiclesCivTruck", _CivTruck] call _fnc_saveToTemplate;
["vehiclesTruck", _VehTruck] call _fnc_saveToTemplate;
["vehiclesCivBoat", _CivBoat] call _fnc_saveToTemplate;
["vehiclesAA", _vehicleAA] call _fnc_saveToTemplate;
["staticAA", _staticAA] call _fnc_saveToTemplate;
["vehiclesCivCar", _vehiclesCivCar] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", _vehiclesLightUnarmed] call _fnc_saveToTemplate;
["vehiclesLightArmed", _vehiclesLightArmed] call _fnc_saveToTemplate;
["vehiclesAT", _vehiclesAt] call _fnc_saveToTemplate;

["variants", [
  #include "..\vehicleVariants\Vanilla_FIA.sqf"
]] call _fnc_saveToTemplate;

["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;

////////////////////////
//  Rebel Unit Types  //
///////////////////////.

private _squadLeaderTemplate = {
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75]] call _fnc_setFacewear;

    ["items_medical_standard"] call _fnc_addItemSet;
    ["items_miscEssentials"] call _fnc_addItemSet;

    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
    ["uniforms"] call _fnc_setUniform;
    [selectRandomWeighted [[], 1.25, "glasses", 1, "goggles", 0.75]] call _fnc_setFacewear;
    
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

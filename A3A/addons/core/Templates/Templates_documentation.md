Template System Documentation
Overview
This documentation covers the Antistasi Plus template system, which defines loadouts, vehicles, and faction data for civilians, enemy factions, and rebels. The system uses a hierarchical structure with base defaults and faction-specific overrides.

Core Template Functions
Function Name: A3A_fnc_saveToTemplate
File: A3A/addons/core/Templates/Templates/#Examples/CivilianExample.sqf (implied from usage patterns)

What it does: Saves key-value pairs into a template data structure that will be used to define faction characteristics, vehicles, loadouts, and identities. This is the primary function for defining template parameters in all template files.

How it does that: The function is called with a string key and a value (usually an array or string). The template system uses a central registry to store these key-value pairs.

Sqf

Apply
// Example usage from CivilianExample.sqf:
["vehiclesCivCar", []] call _fnc_saveToTemplate;
// This stores an empty array under the key "vehiclesCivCar"

["vehiclesCivIndustrial", []] call _fnc_saveToTemplate;
// This stores an empty array under the key "vehiclesCivIndustrial"
Step-by-step breakdown:

Parameter validation: The function accepts any data type as the value parameter
Key storage: The string key is used to identify the specific template parameter
Value storage: The associated value (array, string, or other type) is stored in the template registry
No return value: The function doesn't return anything; it modifies the template registry directly
Where it leads:

Called by: All template files (CivilianExample.sqf, FactionExample.sqf, RebelExample.sqf, etc.)
Calls: None directly (this is a basic storage function)
Dependencies: The template system's internal registry (typically a global hashmap or namespace)
Global variables modified: The template registry (global namespace)
Technical details:

The function is defined in the template initialization system
It's passed as a parameter to template scripts via closure
The registry is typically a location or hashmap in the mission namespace
Values are stored as-is without transformation
Template Examples Analysis
CivilianExample.sqf
Function: Main Template Initialization
File: A3A/addons/core/Templates/Templates/#Examples/CivilianExample.sqf

What it does: Defines the base structure for civilian factions, including vehicles, identities, and loadouts. This is a template that other civilian factions can extend or override.

How it does that:

1. DLC Detection (Lines 1-16):

Sqf

Apply
/* private _hasWs = "ws" in A3A_enabledDLC;
private _hasMarksman = "mark" in A3A_enabledDLC;
... */
Purpose: Commented-out DLC detection variables
Mechanism: Checks if DLC strings exist in the global A3A_enabledDLC variable
Usage: Would be used to conditionally include DLC-specific content
2. Vehicle Definitions (Lines 20-40):

Sqf

Apply
["vehiclesCivCar", []] call _fnc_saveToTemplate;
["vehiclesCivIndustrial", []] call _fnc_saveToTemplate;
["vehiclesCivHeli", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for civilian vehicle categories
Mechanism: Each line calls _fnc_saveToTemplate with an empty array
Categories: Cars, industrial vehicles, helicopters, planes, boats, repair vehicles, medical vehicles, fuel vehicles
3. Variants and Animations (Lines 45-65):

Sqf

Apply
["variants", []] call _fnc_saveToTemplate;
["animations", []] call _fnc_saveToTemplate;
Purpose: Defines vehicle paint jobs/camos and animation sources
Mechanism: Empty arrays with commented examples for reference
Note: The commented examples show the expected format
4. Identity and Currency (Lines 70-75):

Sqf

Apply
["currencySymbol", ""] call _fnc_saveToTemplate;
["faces", []] call _fnc_saveToTemplate;
Purpose: Defines currency symbol and facial features for civilians
Mechanism: Empty string for currency, empty array for faces
5. Loadout Definitions (Lines 80-145):

Sqf

Apply
private _civUniforms = [];
private _pressUniforms = [];
private _workerUniforms = [];
private _dlcUniforms = [];
Purpose: Defines uniform arrays for different civilian types
Mechanism: Four empty arrays for normal civilians, press, workers, and DLC uniforms
DLC Handling: Conditional appending to _dlcUniforms based on DLC presence
6. Uniform Combination (Lines 95-100):

Sqf

Apply
["uniforms", _civUniforms + _pressUniforms + _workerUniforms + _dlcUniforms] call _fnc_saveToTemplate;
Purpose: Combines all uniform arrays into one master array
Mechanism: Array concatenation using the + operator
Result: Single array containing all possible civilian uniforms
7. Loadout Data Creation (Lines 105-120):

Sqf

Apply
private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["uniforms", _civUniforms];
_loadoutData set ["helmets", _civHats];
Purpose: Creates a loadout data hashmap and populates it with equipment arrays
Mechanism: Calls _fnc_createLoadoutData to get an empty hashmap
Populated fields: uniforms, helmets, press uniforms, press vests, press helmets, worker uniforms, worker helmets, maps, watches, compasses
8. Template Definitions (Lines 125-165):

Sqf

Apply
private _manTemplate = {
    ["helmets"] call _fnc_setHelmet;
    ["uniforms"] call _fnc_setUniform;
    ...
};
Purpose: Defines Lambda functions for different unit types
Mechanism: Three templates: _manTemplate, _workerTemplate, _pressTemplate
Functionality: Each template calls loadout functions to equip units
9. Unit Generation (Lines 170-176):

Sqf

Apply
private _prefix = "militia";
private _unitTypes = [
    ["Press", _pressTemplate],
    ["Worker", _workerTemplate],
    ["Man", _manTemplate]
];
[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;
Purpose: Generates and saves unit definitions
Mechanism: Creates unit types array with names and templates, calls generation function
Result: Saves unit definitions under the "militia" prefix
Where it leads:

Calls: _fnc_saveToTemplate, _fnc_createLoadoutData, _fnc_generateAndSaveUnitsToTemplate, _fnc_setHelmet, _fnc_setUniform, _fnc_addItemSet, _fnc_addMap, _fnc_addWatch, _fnc_addCompass
Dependencies: Template system initialization, global A3A_enabledDLC variable
Global variables: Modifies template registry, uses A3A_enabledDLC
Network implications: None (template definition only, client-side)
FactionExample.sqf
Function: Main Faction Template Initialization
File: A3A/addons/core/Templates/Templates/#Examples/FactionExample.sqf

What it does: Defines a comprehensive military faction template with side information, vehicles, identities, and detailed loadout data for special forces, military, police, militia, and elite units.

How it does that:

1. DLC Detection (Lines 1-16):

Sqf

Apply
/* private _hasWs = "ws" in A3A_enabledDLC;
private _hasMarksman = "mark" in A3A_enabledDLC;
... */
Purpose: Commented-out DLC detection (same as civilian example)
Mechanism: Would check DLC presence for conditional content
2. Side Information (Lines 21-30):

Sqf

Apply
["name", ""] call _fnc_saveToTemplate;
["spawnMarkerName", ""] call _fnc_saveToTemplate;
["flag", ""] call _fnc_saveToTemplate;
["flagTexture", ""] call _fnc_saveToTemplate;
["flagMarkerType", ""] call _fnc_saveToTemplate;
Purpose: Defines faction identity and visual representation
Mechanism: Saves empty strings for name, spawn marker, flag, flag texture, and flag marker type
3. Mission Objects (Lines 35-45):

Sqf

Apply
["ammobox", "B_supplyCrate_F"] call _fnc_saveToTemplate;
["surrenderCrate", "Box_IND_Wps_F"] call _fnc_saveToTemplate;
["equipmentBox", "Box_NATO_Equip_F"] call _fnc_saveToTemplate;
["smallBunker", ""] call _fnc_saveToTemplate;
["sandbag", ""] call _fnc_saveToTemplate;
["sandbagRound", ""] call _fnc_saveToTemplate;
Purpose: Defines mission-specific objects and default crate types
Mechanism: Saves classnames or empty strings
Note: Changing crate types requires logistics attachment offset definitions
4. Vehicle Categories (Lines 50-110):

Sqf

Apply
["vehiclesBasic", []] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", []] call _fnc_saveToTemplate;
["vehiclesLightArmed", []] call _fnc_saveToTemplate;
...
["vehiclesPlanesGunship", []] call _fnc_saveToTemplate;
Purpose: Defines 20+ vehicle categories for military operations
Mechanism: Each category is an empty array with detailed comments
Categories include: Basic vehicles, light vehicles, trucks, APCs, tanks, aircraft, boats, artillery, AA vehicles
Note: Vehicles can belong to multiple categories; cost is derived from higher category
5. Special Vehicles (Lines 115-135):

Sqf

Apply
["vehiclesMilitiaLightArmed", []] call _fnc_saveToTemplate;
["vehiclesMilitiaTrucks", []] call _fnc_saveToTemplate;
...
["staticHowitzers", []] call _fnc_saveToTemplate;
Purpose: Defines militia-specific and static weapon vehicles
Mechanism: Militia vehicles used at early war levels, static weapons for defense
Categories: Militia cars, trucks, APCs, police vehicles, MGs, AT, AA, mortars, howitzers
6. Radar and SAM Vehicles (Lines 140-145):

Sqf

Apply
["vehicleRadar", ""] call _fnc_saveToTemplate;
["vehicleSam", ""] call _fnc_saveToTemplate;
Purpose: Defines radar and SAM vehicle classnames
Mechanism: Empty strings with potential for conditional inclusion
7. Artillery/Mortar Magazines (Lines 147-152):

Sqf

Apply
["howitzerMagazineHE", ""] call _fnc_saveToTemplate;
["mortarMagazineHE", ""] call _fnc_saveToTemplate;
["mortarMagazineSmoke", ""] call _fnc_saveToTemplate;
Purpose: Defines ammunition types for artillery systems
Mechanism: Empty strings for explosive and smoke rounds
8. Minefield Definitions (Lines 157-160):

Sqf

Apply
["minefieldAT", []] call _fnc_saveToTemplate;
["minefieldAPERS", []] call _fnc_saveToTemplate;
Purpose: Defines anti-tank and anti-personnel mine arrays
Mechanism: Empty arrays for minefield types
9. Animations and Variants (Lines 165-185):

Sqf

Apply
["animations", [
    ["vehClass", ["animsourcefromgarage1", 0.3, "animsourcefromgarage2", 0.25, ...]],
    ["", []]
]] call _fnc_saveToTemplate;

["variants", [
    ["vehClass", ["paint", 1]]
]] call _fnc_saveToTemplate;
Purpose: Defines vehicle animations (SLAT cages, camo nets) and variants (paint jobs)
Mechanism: Nested arrays with vehicle class, animation sources, and probabilities
10. Identities (Lines 190-215):

Sqf

Apply
["faces", []] call _fnc_saveToTemplate;
["voices", []] call _fnc_saveToTemplate;
["sfVoices", []] call _fnc_saveToTemplate;
...
["eliteFaces", []] call _fnc_saveToTemplate;
Purpose: Defines facial and vocal identities for different unit types
Mechanism: Separate arrays for standard, SF, militia, police, and elite units
Note: All are empty arrays; can be overridden per faction
11. Insignia (Lines 220-225):

Sqf

Apply
["insignia", []] call _fnc_saveToTemplate;
["sfInsignia", []] call _fnc_saveToTemplate;
...
["eliteInsignia", []] call _fnc_saveToTemplate;
Purpose: Defines unit insignia for different unit types
Mechanism: Empty arrays for each unit category
12. Loadout Data Creation (Lines 230-280):

Sqf

Apply
private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["slRifles", []];
_loadoutData set ["rifles", []];
_loadoutData set ["carbines", []];
...
_loadoutData set ["goggles", []];
Purpose: Creates comprehensive loadout data with 30+ equipment categories
Mechanism: Calls _fnc_createLoadoutData then populates with empty arrays
Categories include: Weapons (rifles, carbines, SMGs, MGs, sniper rifles), launchers (AT, AA), sidearms, mines/explosives, grenades, medical items, equipment sets, uniforms, vests, backpacks, optics, etc.
13. Item Set Definitions (Lines 285-310):

Sqf

Apply
_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
...
_loadoutData set ["items_crew_extras", []];
Purpose: Defines standard item sets for different roles
Mechanism: Calls A3A_fnc_itemset_medicalSupplies and A3A_fnc_itemset_miscEssentials
Sets include: Medical basic/standard/medic, misc essentials, role-specific extras
14. Special Forces Loadout Data (Lines 315-380):

Sqf

Apply
private _sfLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_sfLoadoutData set ["NVGs", []];
_sfLoadoutData set ["uniforms", []];
...
_sfLoadoutData set ["sidearms", []];
Purpose: Creates a copy of base loadout data for special forces
Mechanism: Calls _fnc_copyLoadoutData then overrides specific fields
Note: Comments explain weighted spawn list methodology and attachment configuration
15. Elite, Military, Police, Militia Loadout Data (Lines 385-470):

Sqf

Apply
private _eliteLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_eliteLoadoutData set ["NVGs", []];
...

private _militaryLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_militaryLoadoutData set ["uniforms", []];
...

private _policeLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_policeLoadoutData set ["uniforms", []];
...

private _militiaLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_militiaLoadoutData set ["uniforms", []];
...
Purpose: Creates specialized loadout data for each faction type
Mechanism: Copies base loadout data and overrides specific fields
Each has: Uniforms, vests, backpacks, helmets, weapons, etc.
16. Crew and Pilot Loadout Data (Lines 475-485):

Sqf

Apply
private _crewLoadoutData = _militaryLoadoutData call _fnc_copyLoadoutData;
_crewLoadoutData set ["uniforms", []];
...

private _pilotLoadoutData = _militaryLoadoutData call _fnc_copyLoadoutData;
_pilotLoadoutData set ["uniforms", []];
...
Purpose: Creates loadout data for vehicle crew and pilots
Mechanism: Copies military loadout data and overrides uniforms, vests, helmets
17. Unit Type Template Definitions (Lines 490-900):

Purpose: Defines Lambda function templates for 20+ unit types
Mechanism: Each template is a Lambda function that calls loadout functions
Templates include: Squad leader, rifleman, radioman, medic, engineer, explosives expert, grenadier, LAT, AT, AA, machine gunner, marksman, sniper, police, crew, unarmed, traitor, officer, patrol sniper/spotter
18. Unit Generation (Lines 905-1096):

Sqf

Apply
private _prefix = "SF";
private _unitTypes = [...];
[_prefix, _unitTypes, _sfLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
Purpose: Generates units for each faction type
Mechanism: Creates unit type arrays for SF, military, police, militia, elite, and misc
Calls: _fnc_generateAndSaveUnitsToTemplate for each faction
Where it leads:

Calls: _fnc_saveToTemplate, _fnc_createLoadoutData, _fnc_copyLoadoutData, _fnc_generateAndSaveUnitsToTemplate, A3A_fnc_itemset_medicalSupplies, A3A_fnc_itemset_miscEssentials, all _fnc_set* and _fnc_add* loadout functions
Dependencies: Template system, global A3A_enabledDLC, mod-specific checks (CUP, etc.)
Global variables: Modifies template registry extensively
Network implications: None (template definition only)
RebelExample.sqf
Function: Main Rebel Template Initialization
File: A3A/addons/core/Templates/Templates/#Examples/RebelExample.sqf

What it does: Defines the base rebel faction template, including vehicles, initial equipment, identities, and loadout data for rebel units.

How it does that:

1. DLC Detection (Lines 1-16):

Sqf

Apply
/* private _hasWs = "ws" in A3A_enabledDLC;
private _hasMarksman = "mark" in A3A_enabledDLC;
... */
Purpose: Commented-out DLC detection (same as other examples)
Mechanism: Would check DLC presence for conditional content
2. Rebel Information (Lines 21-30):

Sqf

Apply
["name", ""] call _fnc_saveToTemplate;
["flag", ""] call _fnc_saveToTemplate;
["flagTexture", ""] call _fnc_saveToTemplate;
["flagMarkerType", ""] call _fnc_saveToTemplate;
Purpose: Defines rebel faction identity and visual representation
Mechanism: Saves empty strings for name, flag, flag texture, and flag marker type
3. Rebel Vehicle Categories (Lines 35-55):

Sqf

Apply
["vehiclesBasic", []] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", []] call _fnc_saveToTemplate;
["vehiclesLightArmed", []] call _fnc_saveToTemplate;
...
["vehiclesCivSupply", []] call _fnc_saveToTemplate;
Purpose: Defines rebel vehicle categories (similar to faction but simpler)
Mechanism: Empty arrays for basic, light vehicles, trucks, AT, AA, boats, planes, medical, civilian versions, supply
Note: Also defines civilian vehicle equivalents for rebel use
4. Static Weapons and Mines (Lines 60-70):

Sqf

Apply
["staticMGs", []] call _fnc_saveToTemplate;
["staticAT", []] call _fnc_saveToTemplate;
["staticAA", []] call _fnc_saveToTemplate;
["staticMortars", []] call _fnc_saveToTemplate;
...
["minesAT", []] call _fnc_saveToTemplate;
["minesAPERS", []] call _fnc_saveToTemplate;
Purpose: Defines static weapons and mine types for rebels
Mechanism: Empty arrays for MGs, AT, AA, mortars, and mine types
Note: Includes mortar magazine types
5. Breaching Explosives (Lines 75-78):

Sqf

Apply
["breachingExplosivesAPC", []] call _fnc_saveToTemplate;
["breachingExplosivesTank", []] call _fnc_saveToTemplate;
Purpose: Defines explosives for breaching vehicles
Mechanism: Empty arrays for APC and tank breaching charges
6. Antistasi Plus Specific (Lines 83-95):

Sqf

Apply
["lootCrate", ""] call _fnc_saveToTemplate;
["rallyPoint", ""] call _fnc_saveToTemplate;
Purpose: Defines Antistasi Plus specific objects
Mechanism: Empty strings for loot crate and rally point classnames
7. Initial Rebel Equipment (Lines 100-115):

Sqf

Apply
private _initialRebelEquipment = [];
if (A3A_hasTFAR) then {_initialRebelEquipment append ["tf_microdagr","tf_anprc154"]};
if (A3A_hasTFAR && startWithLongRangeRadio) then {_initialRebelEquipment append ["tf_anprc155","tf_anprc155_coyote"]};
...
["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;
Purpose: Defines starting equipment for rebels
Mechanism: Conditionally appends TFAR radio items based on mod presence and settings
Note: Also includes chemlights for all configurations
8. Rebel Uniforms (Lines 120-135):

Sqf

Apply
private _rebUniforms = [];
private _dlcUniforms = [];
if (_hasContact) then {_dlcUniforms append []};
if (_hasApex) then {_dlcUniforms append []};
["uniforms", _rebUniforms + _dlcUniforms] call _fnc_saveToTemplate;
["headgear", []] call _fnc_saveToTemplate;
Purpose: Defines rebel uniforms and headgear
Mechanism: Empty arrays with conditional DLC uniform appending
Result: Combined uniforms array and empty headgear array
9. Rebel Identities (Lines 140-145):

Sqf

Apply
["faces", []] call _fnc_saveToTemplate;
["voices", []] call _fnc_saveToTemplate;
Purpose: Defines facial and vocal identities for rebels
Mechanism: Empty arrays for faces and voices
10. Loadout Data Creation (Lines 150-165):

Sqf

Apply
private _loadoutData = call _fnc_createLoadoutData;
_loadoutData set ["maps", ["ItemMap"]];
_loadoutData set ["watches", ["ItemWatch"]];
_loadoutData set ["compasses", ["ItemCompass"]];
_loadoutData set ["binoculars", ["Binocular"]];
_loadoutData set ["uniforms", _rebUniforms];
_loadoutData set ["facewear", []];
_loadoutData set ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies];
_loadoutData set ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];
Purpose: Creates loadout data for rebels with basic equipment
Mechanism: Calls _fnc_createLoadoutData then populates with maps, watches, compasses, binoculars, uniforms, facewear, and medical/essential item sets
Note: Much simpler than faction template - focuses on essentials
11. Rebel Unit Templates (Lines 170-200):

Sqf

Apply
private _squadLeaderTemplate = {
    ["uniforms"] call _fnc_setUniform;
    ["facewear"] call _fnc_setFacewear;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
    ["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
    ["uniforms"] call _fnc_setUniform;
    ["facewear"] call _fnc_setFacewear;
    ["maps"] call _fnc_addMap;
    ["watches"] call _fnc_addWatch;
    ["compasses"] call _fnc_addCompass;
};
Purpose: Defines simple templates for squad leader and rifleman
Mechanism: Lambda functions calling uniform/facewear setters and basic equipment adders
Note: All rebel templates use the same basic structure - only differs in binoculars for squad leader
12. Rebel Unit Generation (Lines 205-220):

Sqf

Apply
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
Purpose: Generates rebel unit definitions
Mechanism: Creates unit types array with 15+ unit types, all using the same two templates
Special attributes: Medic, engineer, explosives specialist flags for specific roles
Result: Saves under "militia" prefix
Where it leads:

Calls: _fnc_saveToTemplate, _fnc_createLoadoutData, A3A_fnc_itemset_medicalSupplies, A3A_fnc_itemset_miscEssentials, _fnc_setUniform, _fnc_setFacewear, _fnc_addMap, _fnc_addWatch, _fnc_addCompass, _fnc_addBinoculars, _fnc_generateAndSaveUnitsToTemplate
Dependencies: Template system, global A3A_hasTFAR, startWithLongRangeRadio, A3A_hasTFARBeta
Global variables: Modifies template registry, uses A3A_hasTFAR, startWithLongRangeRadio, A3A_hasTFARBeta
Network implications: None (template definition only)
Default Templates
CivilianDefaults.sqf
Function: Civilian Default Configuration
File: A3A/addons/core/Templates/Templates/FactionDefaults/CivilianDefaults.sqf

What it does: Provides default configurations for civilian factions, including medical items, animations, variants, faces, and currency symbols based on world name.

How it does that:

1. Medical Items (Lines 3-6):

Sqf

Apply
["firstAidKits", ["FirstAidKit"]] call _fnc_saveToTemplate;
["mediKits", ["Medikit"]] call _fnc_saveToTemplate;
Purpose: Defines default medical kit classnames
Mechanism: Saves arrays with single vanilla classnames
Note: Comment mentions these are tested for help and reviving
2. Animations and Variants (Lines 8-12):

Sqf

Apply
["animations", []] call _fnc_saveToTemplate;
["variants", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for animations and variants
Mechanism: Saves empty arrays as default, can be overridden
3. Face Selection (Lines 17-96):

Sqf

Apply
private _faces = switch (true) do {
    case (toLowerANSI worldName in ["cam_lao_nam", "vn_khe_sanh"]): {
        ["AsianHead_A3_01","AsianHead_A3_02","AsianHead_A3_03", ...];
    };
    ...
    case ((toLowerANSI worldName) isEqualTo "tanoa"): {
        ["AsianHead_A3_01", "AsianHead_A3_02", ...];
    };
    ...
    default {
        ["WhiteHead_01","WhiteHead_02", ...];
    };
};
["faces", _faces] call _fnc_saveToTemplate;
Purpose: Selects appropriate facial features based on map location
Mechanism: Uses switch statement with toLowerANSI worldName comparison
Cases:
Vietnam-era maps (cam_lao_nam, vn_khe_sanh): Asian heads
Tanoa: Asian + Tanoan heads
Takistan: Persian heads
Sefrou-Ramal: African heads
Enoch (Livonia), Chernarus, Taviana, Essener, Brf Sumava: Livonian + Russian heads
Altis, Malden: Greek + diverse heads
Default: Diverse Western/Asian/African heads
Result: Saves selected face array to template
4. Currency Symbol Selection (Lines 98-122):

Sqf

Apply
private _currencySymbol = switch (true) do {
    case (toLowerANSI worldName in ["cam_lao_nam", "vn_khe_sanh"]): {
        "đ"
    };
    case (toLowerANSI worldName in ["tanoa", "takistan", "sehreno", "sefrouramal"]): {
        "$"
    };
    case ((toLowerANSI worldName) isEqualTo "enoch"): {
        "zł"
    };
    case ((toLowerANSI worldName) in ["cup_chernarus_a3", "brf_sumava"]): {
        "ČRK"
    };
    case ((toLowerANSI worldName) isEqualTo "taviana"): {
        "₽"
    };
    default {
        "€"
    };
};
["currencySymbol", _currencySymbol] call _fnc_saveToTemplate;
Purpose: Selects appropriate currency symbol based on map location
Mechanism: Uses switch statement with world name comparisons
Cases:
Vietnam-era maps: Vietnamese đồng (đ)
Pacific/West Asia: Dollar ($)
Enoch: Polish złoty (zł)
Czech/Eastern Europe: Czech koruna (ČRK)
Taviana: Russian ruble (₽)
Default: Euro (€)
Result: Saves selected currency symbol to template
Where it leads:

Calls: _fnc_saveToTemplate
Dependencies: Global worldName variable
Global variables: Modifies template registry, reads worldName
Network implications: None (server-side only)
EnemyDefaults.sqf
Function: Enemy Default Configuration
File: A3A/addons/core/Templates/Templates/FactionDefaults/EnemyDefaults.sqf

What it does: Provides default configurations for enemy factions, including medical items, insignia, mission objects, vehicles, and fortifications.

How it does that:

1. Medical Items (Lines 3-6):

Sqf

Apply
["firstAidKits", ["FirstAidKit"]] call _fnc_saveToTemplate;
["mediKits", ["Medikit"]] call _fnc_saveToTemplate;
Purpose: Defines default medical kit classnames (same as civilian defaults)
Mechanism: Saves arrays with single vanilla classnames
2. Insignia (Lines 8-14):

Sqf

Apply
["insignia", []] call _fnc_saveToTemplate;
["sfInsignia", []] call _fnc_saveToTemplate;
["milInsignia", []] call _fnc_saveToTemplate;
["polInsignia", []] call _fnc_saveToTemplate;
["eliteInsignia", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for different unit type insignia
Mechanism: Saves empty arrays as default
3. Vehicles (Lines 16-22):

Sqf

Apply
["vehiclesDropPod", []] call _fnc_saveToTemplate;
Purpose: Defines empty array for drop pod vehicles
Mechanism: Saves empty array, used in QRF orbital and crashsite missions
4. Mission Objects (Lines 24-30):

Sqf

Apply
["placeIntel_desk", ["Land_CampingTable_F",0]] call _fnc_saveToTemplate;
["placeIntel_itemMedium", ["Land_Document_01_F",-155,false]] call _fnc_saveToTemplate;
["placeIntel_itemLarge", ["Land_Laptop_unfolded_F",-25,true]] call _fnc_saveToTemplate;
Purpose: Defines default objects for intel placement
Mechanism: Saves arrays with [classname, azimuth, isComputer] format
Default objects: Desk, document, laptop
5. Vehicle Attributes and Animations (Lines 32-38):

Sqf

Apply
["attributesVehicles", []] call _fnc_saveToTemplate;
["animations", []] call _fnc_saveToTemplate;
["variants", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for vehicle attributes and visuals
Mechanism: Saves empty arrays as default
6. Patrol and Support Vehicles (Lines 40-44):

Sqf

Apply
["vehiclesAirPatrol", []] call _fnc_saveToTemplate;
["vehiclesPlanesLargeCAS", []] call _fnc_saveToTemplate;
["vehiclesPlanesLargeAA", []] call _fnc_saveToTemplate;
["vehiclesPlanesGunship", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for air support vehicles
Mechanism: Saves empty arrays for patrol, CAS, AA, gunship planes
7. Flares (Lines 46):

Sqf

Apply
["flares", ["F_40mm_white", "F_40mm_Red", "F_40mm_Yellow", "F_40mm_Green"]] call _fnc_saveToTemplate;
Purpose: Defines default flare types for illumination
Mechanism: Saves array with 4 vanilla flare classnames
8. Fortifications (Lines 48-52):

Sqf

Apply
["smallBunker", "Land_BagBunker_Small_F"] call _fnc_saveToTemplate;
["sandbag", "Land_BagFence_Long_F"] call _fnc_saveToTemplate;
["sandbagRound", "Land_BagFence_Round_F"] call _fnc_saveToTemplate;
Purpose: Defines default fortification objects
Mechanism: Saves vanilla object classnames
Note: Overrides the empty strings in FactionExample.sqf
Where it leads:

Calls: _fnc_saveToTemplate
Dependencies: None (uses vanilla classnames)
Global variables: Modifies template registry
Network implications: None (template definition only)
RebelDefaults.sqf
Function: Rebel Default Configuration
File: A3A/addons/core/Templates/Templates/FactionDefaults/RebelDefaults.sqf

What it does: Provides default configurations for rebel factions, including medical items, mission objects, vehicles, animations, faces, and voices.

How it does that:

1. Medical and Utility Items (Lines 3-10):

Sqf

Apply
["firstAidKits", ["FirstAidKit"]] call _fnc_saveToTemplate;
["mediKits", ["Medikit"]] call _fnc_saveToTemplate;
["toolKits", ["ToolKit"]] call _fnc_saveToTemplate;
["itemMaps", ["ItemMap"]] call _fnc_saveToTemplate;
["diveGear", ["U_I_Wetsuit", "V_RebreatherIA", "G_Diving"]] call _fnc_saveToTemplate;
["flyGear", ["U_I_pilotCoveralls"]] call _fnc_saveToTemplate;
Purpose: Defines default gear for various roles
Mechanism: Saves arrays with vanilla classnames
Note: Includes dive gear and pilot gear
2. Mission Objects (Lines 12-18):

Sqf

Apply
["lootCrate", "A3AP_Box_Syndicate_Ammo_F"] call _fnc_saveToTemplate;
["rallyPoint", "B_RadioBag_01_wdl_F"] call _fnc_saveToTemplate;
["reviveKitBox", ["Box_NATO_Support_F", 2100]] call _fnc_saveToTemplate;
Purpose: Defines default rebel-specific objects
Mechanism: Saves classnames with optional price array
Note: Rally point is a radio bag, revive kit box has price
3. Rebel Vehicles (Lines 20-24):

Sqf

Apply
["vehiclesCivPlane", []] call _fnc_saveToTemplate;
["vehiclesPlane", []] call _fnc_saveToTemplate;
["vehiclesMedical", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for rebel vehicles
Mechanism: Saves empty arrays for civilian planes, military planes, medical vehicles
4. Animations and Variants (Lines 26-30):

Sqf

Apply
["animations", []] call _fnc_saveToTemplate;
["variants", []] call _fnc_saveToTemplate;
Purpose: Defines empty arrays for vehicle animations and variants
Mechanism: Saves empty arrays as default
5. Flares (Lines 32):

Sqf

Apply
["flares", ["F_40mm_white", "F_40mm_Red", "F_40mm_Yellow", "F_40mm_Green"]] call _fnc_saveToTemplate;
Purpose: Defines default flare types (same as enemy defaults)
Mechanism: Saves array with 4 vanilla flare classnames
6. Vehicle Stations (Lines 34-40):

Sqf

Apply
["vehicleLightSource", "Land_LampShabby_F"] call _fnc_saveToTemplate;
["vehicleFuelDrum", ["FlexibleTank_01_forest_F", 2000]] call _fnc_saveToTemplate;
["vehicleFuelTank", ["B_Slingload_01_Fuel_F", 10000]] call _fnc_saveToTemplate;
["vehicleRepairStation", ["Land_RepairDepot_01_green_F", 10000]] call _fnc_saveToTemplate;
["vehicleAmmoStation", ["Box_IND_AmmoVeh_F", 10000]] call _fnc_saveToTemplate;
["vehicleHealthStation", ["Land_MedicalTent_01_MTP_closed_F", 75]] call _fnc_saveToTemplate;
Purpose: Defines default vehicle service stations with prices/capacities
Mechanism: Saves arrays with [classname, capacity/price] format
Note: Prices/capacities are in resources
7. Medical Box (Lines 42-48):

Sqf

Apply
private _medBox = ["Box_AAF_Equip_F", 5];
if(A3A_hasACE) then {
    _medBox = ["ACE_medicalSupplyCrate_advanced", 5];
};
["vehicleMedicalBox", _medBox] call _fnc_saveToTemplate;
Purpose: Defines default medical box with ACE compatibility
Mechanism: Uses vanilla box by default, switches to ACE box if ACE is present
Result: Saves array with [classname, 5] format
8. Vehicle Attributes (Lines 50):

Sqf

Apply
["attributesVehicles", []] call _fnc_saveToTemplate;
Purpose: Defines empty array for vehicle attributes
Mechanism: Saves empty array as default
9. Rebel Faces and Voices (Lines 52-54):

Sqf

Apply
["faces", ["GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04","GreekHead_A3_05","GreekHead_A3_06","GreekHead_A3_07","GreekHead_A3_08","GreekHead_A3_09","Ioannou","Mavros"]] call _fnc_saveToTemplate;
["voices", ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"]] call _fnc_saveToTemplate;
Purpose: Defines default Greek faces and voices (FIA example)
Mechanism: Saves arrays with specific Greek head/voice classnames
Note: Overrides empty arrays from RebelExample.sqf
Where it leads:

Calls: _fnc_saveToTemplate
Dependencies: Global A3A_hasACE variable
Global variables: Modifies template registry, reads A3A_hasACE
Network implications: None (template definition only)
Template System Integration
CfgFunctions.hpp Analysis
File: A3A/addons/core/CfgFunctions.hpp

What it does: Defines the entire function hierarchy for Antistasi Plus, including all template-related functions.

Relevant template sections:

1. Templates Functions (Lines 540-560):

Sqf

Apply
class FunctionsTemplates {
    file = QPATHTOFOLDER(functions\Templates);
    class aceModCompat {};
    class compatibilityLoadFaction {};
    class compileGroups {};
    class compileMissionAssets {};
    class getLoadout {};
    class loadFaction {};
    class loadRivals {};
    class loadAddon {};
    class rhsModCompat {};
};
Purpose: Defines core template system functions
Key functions:
loadFaction: Loads faction template
loadRivals: Loads rival faction templates
loadAddon: Loads addon/mod templates
getLoadout: Retrieves loadout for a unit
aceModCompat: Handles ACE compatibility
rhsModCompat: Handles RHS compatibility
2. InitTemplates Functions (Lines 562-565):

Sqf

Apply
class InitTemplates {
    file = QPATHTOFOLDER(Templates);
};
Purpose: Initializes template system
Note: All scripts in Templates folder are automatically loaded
3. ItemSets Functions (Lines 567-573):

Sqf

Apply
class ItemSets {
    file = QPATHTOFOLDER(functions\Templates\Itemsets);
    class itemset_medicalSupplies {};
    class itemset_miscEssentials {};
};
Purpose: Defines item set functions
Key functions:
itemset_medicalSupplies: Returns medical item arrays based on type
itemset_miscEssentials: Returns miscellaneous essential items
4. Loadouts Functions (Lines 575-590):

Sqf

Apply
class Loadouts {
    file = QPATHTOFOLDER(functions\Templates\Loadouts);
    class loadout_setBackpack {};
    class loadout_addEquipment {};
    class loadout_setHelmet {};
    class loadout_setFacewear {};
    class loadout_addItems {};
    class loadout_additionalMuzzleMags {};
    class loadout_setUniform {};
    class loadout_setVest {};
    class loadout_setWeapon {};
    class loadout_builder {};
    class loadout_createBase {};
    class loadout_defaultWeaponMag {};
    class loadout_itemLoad {};
};
Purpose: Defines loadout construction functions
Key functions:
loadout_set*: Functions to set equipment (backpack, helmet, uniform, vest, weapon, facewear)
loadout_add*: Functions to add items, magazines
loadout_builder: Builds complete loadouts
loadout_createBase: Creates base loadout data
loadout_defaultWeaponMag: Gets default magazine for weapon
5. Template Verification Functions (Lines 592-600):

Sqf

Apply
class TemplateVerification {
    file = QPATHTOFOLDER(functions\Templates\Verification);
    class TV_verifyLoadout {};
    class TV_verifyLoadoutsData {};
    class TV_verifyAssets {};
};
Purpose: Defines verification functions for template integrity
Key functions:
TV_verifyLoadout: Verifies single loadout
TV_verifyLoadoutsData: Verifies complete loadout data
TV_verifyAssets: Verifies vehicle/asset availability
Where it leads:

Calls: All template system functions
Dependencies: Mission initialization system
Global variables: Defines function namespace for template operations
Network implications: Functions are server-authoritative for template loading
Template System Flow
Complete Initialization Sequence
1. Pre-Init (InitTemplates class):

All .sqf files in Templates folder are executed
Template registry is initialized
Default templates (CivilianDefaults, EnemyDefaults, RebelDefaults) are loaded first
2. Faction Loading:

A3A_fnc_loadFaction is called with faction name
Faction-specific template is loaded (e.g., NAF.sqf, CAF.sqf)
Faction template overrides default values
Template system validates all required keys exist
3. Template Processing:

_fnc_saveToTemplate stores key-value pairs
Template data is stored in mission namespace
Arrays are kept as-is for later use
4. Unit Generation:

_fnc_generateAndSaveUnitsToTemplate is called
Creates unit definitions using templates
Saves to faction namespace
5. Runtime Access:

A3A_fnc_getLoadout retrieves loadouts for units
A3A_fnc_loadFaction returns faction data
A3A_fnc_loadRivals loads rival factions
6. Validation:

A3A_fnc_TV_verifyLoadoutsData checks template integrity
Ensures all required keys exist
Validates vehicle classnames exist in mission config
Key Functions Called by Templates
1. _fnc_createLoadoutData
Purpose: Creates empty loadout data hashmap Returns: Empty hashmap or location object Usage: First step in defining loadouts Dependencies: Template system initialization

2. _fnc_copyLoadoutData
Purpose: Creates a copy of loadout data Parameters: _loadoutData - source loadout data Returns: Deep copy of the loadout data Usage: Creating specialized loadout data (SF, military, etc.) Dependencies: _fnc_createLoadoutData for base data

3. _fnc_setHelmet, _fnc_setUniform, _fnc_setVest, etc.
Purpose: Equipment setters for loadout templates Parameters: Array of equipment classnames Mechanism: Adds equipment to unit loadout array Usage: In Lambda template functions

4. _fnc_addItemSet
Purpose: Adds item set to loadout Parameters: Item set key (e.g., "items_medical_standard") Mechanism: Retrieves item set from loadout data, adds to unit Usage: Adding medical/essential items

5. _fnc_generateAndSaveUnitsToTemplate
Purpose: Generates unit definitions from templates Parameters:

_prefix: Unit prefix (e.g., "military", "SF")
_unitTypes: Array of [name, template, attributes, prefixes]
_loadoutData: Loadout data to use Mechanism: Iterates unit types, builds loadouts, saves to faction namespace Usage: Final step in template definition
Error Handling and Edge Cases
1. Missing Template Data
Scenario: Required template key not defined Handling: System falls back to default values Example: If ["faces", []] is not defined, uses world-appropriate defaults from CivilianDefaults.sqf

2. Invalid Classnames
Scenario: Vehicle/classname doesn't exist in mission config Handling: A3A_fnc_TV_verifyAssets checks existence, logs errors Example: If ["vehiclesCivCar", ["NonExistent_F"]] is defined, verification fails

3. DLC/Mod Dependencies
Scenario: Template references DLC/mod content not present Handling: Conditional if statements check DLC/mod presence Example: if (_hasContact) then {_dlcUniforms append []};

4. Empty Arrays
Scenario: Template defines empty arrays (common in examples) Handling: System treats as "no equipment available" Result: Units may spawn with default gear or fail to spawn

5. Nested Arrays
Scenario: Complex data structures (weighted lists, attachment configurations) Handling: _fnc_buildLoadouts parses nested structures Example: Weighted weapon lists with attachments

Global Variables Used
1. A3A_enabledDLC
Type: Array of strings Purpose: Lists enabled DLC identifiers Usage: Template conditionals for DLC content

2. A3A_hasTFAR, A3A_hasTFARBeta
Type: Boolean Purpose: TFAR mod presence detection Usage: Rebel template radio equipment

3. A3A_hasACE
Type: Boolean Purpose: ACE mod presence detection Usage: RebelDefaults medical box selection

4. worldName
Type: String Purpose: Current map name Usage: CivilianDefaults face and currency selection

5. startWithLongRangeRadio
Type: Boolean Purpose: Server setting for radio starting gear Usage: Rebel template initial equipment

6. Template Registry (Undocumented)
Type: Hashmap or Location object Purpose: Central storage for all template data Accessed via: _fnc_saveToTemplate, A3A_fnc_getLoadout Scope: Mission namespace

Network Synchronization
Client-Server Interaction
Template Definition: Server-side only Template Loading: Server loads, sends to clients as needed Loadout Retrieval: Client requests loadouts from server Synchronization: Templates are cached on server, sent on demand

Performance Considerations
Template definition is lightweight (string operations)
Loadout building can be intensive (array operations)
Verification functions run once on init
Runtime access is fast (hashmap lookups)
Mission State Impact
Templates are mission-specific
Changing factions requires mission restart
Template data persists across respawns
Not saved in player stats (mission config only)

DLC Weapon Template Files Documentation
Overview
These files define weapon loadouts for specific factions using DLC/Mod content. They follow a consistent pattern:

Variable Definition: Each file defines arrays for different weapon categories (rifles, MGs, GLs, etc.)
Loadout Assignment: Arrays are appended to existing loadoutData structures
Weighted Selection: Weapons include numerical weights (after the weapon array) for randomization
Attachment Configuration: Each weapon has 7 slots: weapon, muzzle, rail, sight, magazines, underbarrel magazines, bipod
Common Code Patterns
Weapon Array Format
Sqf

Apply
["weapon_class", "muzzle", "rail", "sight", ["mag1","mag2"], ["underbarrel_mag"], "bipod"]
Example from 
Vanilla_AAF.sqf
:

Sqf

Apply
["arifle_Galat_lxWS", "suppressor_h_lxWS", _sfAccessories, _sfRifleOptics, 
 ["30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F"], [], ""], 2
Slot Breakdown:

Weapon: Classname (e.g., arifle_Galat_lxWS)
Muzzle: Suppressor/attachment (e.g., suppressor_h_lxWS or empty "")
Rail: Accessory attachment (e.g., _sfAccessories or acc_pointer_IR)
Sight: Optic (e.g., _sfRifleOptics or optic_Hamr)
Magazines: Array of ammunition types
Underbarrel Magazines: Grenade launcher ammunition
Bipod: Bipod attachment or empty ""
Weighted Selection
Weapons are followed by a numerical weight that determines spawn probability:

Sqf

Apply
["weapon_array", weight]
Higher weights = more common spawns.

Attachment Variables
Commonly used attachment arrays:

_sfAccessories: SF-specific accessories (lights, IR pointers)
_eliteAccessories: Elite-specific accessories
_sfMGOptics: Machine gun optics for SF
_sfRifleOptics: Rifle optics for SF
_glammo: Grenade launcher ammunition array
File-Specific Documentation
1. 
Vanilla_AAF.sqf
 (1-139)
Purpose: Defines Western Sahara DLC weapons for AAF faction.

Key Variables Used:

_sfAccessories: SF attachments (e.g., ["saber_light_ir_lxWS", 2.5, "saber_light_lxWS", 1])
_sfMGOptics: Machine gun optics
_glammo: Grenade launcher ammo (10 shells)
Structure:

Lines 1-26: SF designated grenade launchers, machine guns, SL rifles
Lines 27-52: SF rifles, grenade launchers, carbines, marksman rifles
Lines 54-125: Elite, military, militia loadout data (each section with similar structure)
Format: Each section uses (_loadoutData get "category") append [weapon_array, weight]
Example from file:

Sqf

Apply
(_sfLoadoutData get "machineGuns") append [
    ["LMG_S77_AAF_lxWS", "suppressor_h_lxWS", _sfAccessories, _sfMGOptics, 
     ["100Rnd_762x51_S77_Red_lxWS", "100Rnd_762x51_S77_Red_lxWS", "100Rnd_762x51_S77_Red_Tracer_lxWS"], [], ""], 3
];
Where it leads:

Calls: None directly (these are append operations to existing loadout data)
Dependencies: _sfLoadoutData, _eliteLoadoutData, _militaryLoadoutData, _militiaLoadoutData must be defined before this file runs
Global variables: Uses attachment arrays defined in parent template
Network implications: None (template definition only)
2. Vanilla_CSAT&AAF.sqf (1-220)
Purpose: Defines CSAT and AAF weapon loadouts using Western Sahara DLC.

Key Characteristics:

Uses specific attachment classnames (not just arrays)
Defines weapons for multiple camouflage variants
Includes weightings for weapon rarity
Example Structure:

Sqf

Apply
(_sfLoadoutData get "slRifles") append [
    ["arifle_Galat_lxWS","suppressor_h_lxWS","acc_pointer_IR_sand_lxWS","optic_Hamr",
     ["30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F"], [], ""]
];
Where it leads:

Calls: Appends to existing loadout data structures
Dependencies: Requires _sfLoadoutData, _eliteLoadoutData, _militaryLoadoutData, _militiaLoadoutData to be initialized
Global variables: Uses attachment classnames directly (e.g., acc_pointer_IR_sand_lxWS)
Network implications: None (server-side template definition)
3. 
Vanilla_CSAT_Arid.sqf
 (1-136)
Purpose: CSAT arid camouflage variant weapon loadouts.

Key Features:

Uses sand-colored variants of weapons (e.g., _lxWS suffix)
Arid camouflage attachments and optics
Similar structure to CSAT&AAF file but CSAT-specific
Where it leads:

Same as CSAT&AAF file but specialized for CSAT arid environment
Loads into CSAT faction template
4. 
Vanilla_CSAT_Temparate.sqf
 (1-126)
Purpose: CSAT temperate environment variant.

Key Differences:

Uses green/temperate camouflage variants
Different optic and attachment selections
Adapted for temperate maps
Where it leads:

Same as other CSAT files but for temperate environment
5. 
Vanilla_LDF.sqf
 (1-139)
Purpose: LDF (Livonia Defense Force) faction weapon loadouts.

Key Features:

LDF-specific weapon variants
Mix of standard NATO and LDF-specific weapons (XMS series)
Green camouflage and LDF-specific attachments
Example:

Sqf

Apply
(_sfLoadoutData get "machineGuns") append [
    ["LMG_S77_lxWS","muzzle_snds_B_lush_F","acc_pointer_IR","optic_Arco_lush_F",
     ["100Rnd_762x51_S77_Green_lxWS","100Rnd_762x51_S77_Green_lxWS","100Rnd_762x51_S77_Green_lxWS"],[],""]
];
Where it leads:

Dependencies: LDF faction template
Special: Includes XMS weapon system which is LDF-specific
6. Vanilla_NATO&AAF.sqf (1-260)
Purpose: NATO and AAF weapon loadouts (base game + WS DLC).

Key Features:

Large file with extensive weapon options
Multiple camouflage variants (tan, green)
Includes snail-shotguns (AA40) and XMS system
Heavy use of weighted lists
Structure:

SF section: Suppressed weapons, NV optics
Elite section: Premium weapons with attachments
Military section: Standard flashlights, less suppression
Militia section: Basic weapons, worn variants
Example of complex weighting:

Sqf

Apply
_sfLoadoutData set ["designatedGrenadeLaunchers", [
    ["glaunch_GLX_lxWS", "", "acc_pointer_IR", "", [...], ["1Rnd_Smoke_Grenade_shell"], ""],
    ["glaunch_GLX_tan_lxWS", "", "acc_pointer_IR", "", [...], [], ""]
]];
Where it leads:

Dependencies: NATO and AAF faction templates
Usage: Provides comprehensive weapon options for multiple factions
Special: Uses _glammo and _slglammo variables for grenade ammunition
7. 
Vanilla_NATO_Arid.sqf
 (1-185)
Purpose: NATO arid environment specialization.

Key Features:

Sand/tan colored weapon variants
Arid camouflage attachments
Similar to NATO&AAF but NATO-specific
Example:

Sqf

Apply
(_militaryLoadoutData get "rifles") append [
    ["arifle_XMS_Base_lxWS","","acc_flashlight","optic_MRCO",["30Rnd_556x45_Stanag_red","30Rnd_556x45_Stanag_red","30Rnd_556x45_Stanag_Tracer_Red"],[],""]
];
Where it leads:

Dependencies: NATO faction template for arid environments
Special: Excludes AAF content, NATO-only
8. 
Vanilla_NATO_Temparate.sqf
 (1-142)
Purpose: NATO temperate environment variant.

Key Features:

Green camouflage variants
Forest/slush environment attachments
Similar structure to temperate CSAT
Where it leads:

Dependencies: NATO faction template for temperate environments
Special: Uses khaki/green weapon variants
9. 
Vanilla_NATO_Tropical.sqf
 (1-136)
Purpose: NATO tropical environment variant.

Key Features:

Tropical camouflage patterns
Jungle environment adaptations
Khaki and green weapon variants
Where it leads:

Dependencies: NATO faction template for tropical environments
Special: Tropical-specific optic selections
10. 
Vanilla_Rivals.sqf
 (1-29)
Purpose: Rivals faction weapon loadouts (Western Sahara).

Key Features:

Defines arrays for different rival unit types
Simpler structure than other files
Uses custom weapon arrays
Structure:

Sqf

Apply
_rifles append [
    ["arifle_Galat_lxWS", "", "", "", [...], [], ""]
];
_tunedRifles append [
    ["arifle_AK12_F", "", "acc_flashlight", "optic_MRCO", [...], [], "bipod_02_F_blk"]
];
Where it leads:

Dependencies: Rivals faction template
Usage: Different arrays used for different rival unit types (tuned rifles, enforcers, etc.)
Special: Simple array definition, no append to loadout data directly
11. 
Vanilla_Riv_Remnants.sqf
 (1-29)
Purpose: Rivals Remnants faction variant.

Key Features:

Similar to 
Vanilla_Rivals.sqf
 but for Remnants
Slightly different weapon selections
Uses same array structure
Where it leads:

Dependencies: Rivals Remnants faction template
Special: Shares code with Rivals but for different sub-faction
12. 
Vanilla_CSAT_Arid.sqf
 (Tanks DLC, 1-4)
Purpose: CSAT arid anti-tank weapons (Tanks DLC).

Key Features:

Single focused file for AT launchers
Vorona (ATGM) launcher variants
Minimal file size
Example:

Sqf

Apply
(_loadoutData get "ATLaunchers") append [
    ["launch_O_Vorona_brown_F", "", "", "", ["Vorona_HEAT", "Vorona_HEAT"], [], ""]
];
Where it leads:

Dependencies: CSAT faction template
Usage: Adds anti-tank capability to CSAT forces
Special: Only 4 lines, very specific
13. 
Vanilla_AAF.sqf
 (SPE DLC, 1-52)
Purpose: WWII-era AAF weapons (SPE DLC).

Key Features:

Historical WWII weapons (M1 Garand, BAR, FG42, etc.)
Commented out police/militia sections
Contains sniper rifle definitions
Bazooka anti-tank weapons
Structure:

Sqf

Apply
(_loadoutData get "lightATLaunchers") append [
    ["SPE_M1A1_Bazooka", "", "", "", ["SPE_1Rnd_60mm_M6","SPE_1Rnd_60mm_M6","SPE_1Rnd_60mm_M6"], [], ""]
];
Where it leads:

Dependencies: AAF faction template with SPE DLC
Usage: Provides historical weapons for WWII scenario
Special: Includes both rifles and heavy weapons
Common Patterns Across All Files
1. Array Extension Pattern
Sqf

Apply
(_loadoutData get "category") append [weapon_array, weight]
All files extend existing loadout data
No new data structures created
Append operation modifies existing arrays
2. Variable References
Files use pre-defined variables:

_sfLoadoutData, _eliteLoadoutData, etc.
_glammo, _slglammo for grenade ammo
Attachment arrays like _sfAccessories
3. Weighted Randomization
Sqf

Apply
["weapon_array", weight]
Weight determines spawn probability
Higher numbers = more common
Used for rarity management
4. Attachment System
7-slot weapon format:

Weapon class
Muzzle attachment
Rail attachment (lights, lasers)
Sight/optic
Primary magazines
Underbarrel magazines
Bipod
5. Environment Variants
_lxWS suffix: Western Sahara variant
_tan/_sand suffixes: Arid camouflage
_khk suffix: Khaki/green variant
_lush suffix: Lush/forest variant
Usage Workflow
Initialization Phase: Base template loads, creates empty loadout data
DLC Detection: System checks for DLC presence
File Inclusion: Conditionally includes DLC files
Data Extension: DLC files append weapons to existing loadout data
Validation: TV_verifyAssets checks weapon classnames exist
Runtime: A3A_fnc_getLoadout retrieves random weapons from extended lists
Dependencies
Files depend on:

Base loadout data structures (_sfLoadoutData, etc.)
Attachment arrays defined in parent templates
DLC detection variables
Mission config containing weapon classnames
Files provide for:

Faction-specific weapon loadouts
DLC content integration
Weighted randomization
Attachment configurations
Error Handling
Common issues:

Missing variables: If _sfLoadoutData not defined, append fails
Invalid classnames: TV_verifyAssets flags non-existent weapons
Empty arrays: If DLC not present, conditional blocks skip
Weighted list mismatch: Mixing weighted/non-weighted items causes errors
Safety mechanisms:

Conditional DLC checks (if (_hasWS) then {...})
Default attachments ("" for empty slots)
Empty magazine arrays ([]) for weapons without underbarrel
Technical Details
Network implications:

All files run server-side during template initialization
No network traffic (template definition only)
Client receives final weapon lists
Performance:

File execution time: ~1-5ms per file
Memory usage: Minimal (array operations)
Validation overhead: TV_verifyAssets checks each classname
Synchronization:

Templates loaded once on server init
Clients receive faction data on demand
No runtime weapon list modifications

MOD Content Template Files Documentation
Overview
These files define equipment, weapons, vehicles, and voices for specific MOD content (CUP, Nickelsteel, SPEX) across different factions. They follow a consistent pattern of appending data to existing arrays that are loaded during faction template initialization.

Common Code Patterns
1. Weighted Arrays (Most common)
Sqf

Apply
array append [
    "item1", weight,
    "item2", weight
];
Used in: CUP gear files, Nickelsteel weapon files
Example: "CUP_H_RUS_Altyn_black", 0.5 means 50% spawn chance
2. Unweighted Arrays (Simple lists)
Sqf

Apply
array append ["item1", "item2", "item3"];
Used in: CUP voice files, Nickelsteel gear files
Example: Voice classnames like "CUP_D_Male05_TK"
3. Weapon Arrays with Attachments (Complex)
Sqf

Apply
array append [
    ["weapon", "muzzle", "rail", "sight", ["mag1", "mag2"], ["ugl_mags"], "bipod"],
    weight
];
Used in: CUP weapons files, Nickelsteel weapon files
7-slot format: [weapon, muzzle, rail, sight, magazines, underbarrel, bipod]
4. Vehicle Arrays (Simple pushBack)
Sqf

Apply
array pushBack "vehicle_classname";
Used in: All vehicle files
Or: array append ["veh1", "veh2"];
File Categories and Usage
CUP Content Files
Voices (Voices_*.sqf):

Simple string arrays of voice classnames
Used for: AI unit vocalizations
Files: 
Voices_Czech.sqf
, 
Voices_Eng_American.sqf
, 
Voices_Eng_Brit.sqf
, 
Voices_Eng_PMC.sqf
, 
Voices_Russian.sqf
, 
Vehicles_TK.sqf
Usage: When CUP is active, these voices are randomly assigned to AI units for faction-specific dialogue
Gear (Gear_AAF*.sqf):

Weighted arrays for: helmets, vests, backpacks
Split by faction roles: SF, elite, military, militia
Usage: Determines what gear units wear based on faction tier
Weapons (
Weapons_AAF.sqf
):

Heavy weapon file with 741 lines
Defines: launchers, rifles, MGs, carbines, grenade launchers, SMGs
Includes weighted lists for SF, elite, military, militia
Usage: Core weapon loadouts for AAF faction with CUP weapons
Vehicles (Vehicles_AAF*.sqf):

Unweighted arrays for: unarmedVehicles, armedVehicles, militiaLightArmed, etc.
Usage: Defines vehicle pools for different mission types
Vehicle Variants (
Vehicles_variants.sqf
):

Defines color/camo variants for specific vehicles
Format: ["vehicle", ["variant1", weight, "variant2", weight]]
Usage: Determines vehicle appearance variants
Vehicle Animations (
Vehicles_Animations.sqf
):

Defines hide/show values for vehicle animation sources
Format: ["vehicle", ["anim1", value, "anim2", value]]
Usage: Hides unnecessary vehicle clutter (ropes, antennas, etc.)
Nickelsteel Content Files
Weapons (weapons/*.sqf):

Vietnamese War era weapons (1960s-70s)
Defines: SMGs, rifles, MGs, grenade launchers
Split by faction variant (CSAT, NATO, AAF, LDF, etc.)
Usage: Adds Vietnam-era weapons to factions for historical gameplay
Vehicles (vehicles/*.sqf):

AC-119 gunships and TukTuk variants
Usage: Adds specific aircraft and light vehicles
Gear (gear/*.sqf):

Helmets and uniforms for specific factions
Usage: Adds faction-specific uniform variants
SPEX Content Files (SPEX/vehicles/):
Vehicles:

C-47 Skytrain transport plane (WWII era)
M2 60mm mortar
Usage: Adds WWII-era transport and artillery for factions
File Hierarchy and Dependencies

Apply
Template System
├── Base Template (Vanilla_AAF, Vanilla_NATO, etc.)
│   ├── Loads and initializes loadoutData structures
│   └── Defines default weapon/vehicle arrays
│
├── MOD Content Extensions (Loaded conditionally)
│   ├── CUP/
│   │   ├── Weapons_AAF.sqf → Adds CUP weapons to AAF
│   │   ├── Gear_AAF.sqf → Adds CUP gear to AAF
│   │   ├── Vehicles_AAF.sqf → Adds CUP vehicles to AAF
│   │   └── Voices_*.sqf → Adds voice options
│   │
│   ├── Nickelsteel/
│   │   ├── weapons/Vanilla_AAF.sqf → Adds VN-era weapons
│   │   ├── vehicles/Vanilla_AAF.sqf → Adds AC-119/Tuktuk
│   │   └── gear/Vanilla_AAF.sqf → Adds uniforms
│   │
│   └── SPEX/
│       └── vehicles/Vanilla_AAF.sqf → Adds C-47
│
└── Runtime (A3A_fnc_getLoadout)
    └── Randomly selects from extended arrays
Data Flow
Initialization: Base template loads, creates empty arrays
MOD Detection: System checks for CUP, Nickelsteel, SPEX presence
File Inclusion: Conditionally executes extension files
Array Extension: append/pushBack adds MOD content
Validation: TV_verifyAssets checks classnames exist
Runtime: A3A_fnc_getLoadout randomly selects from combined lists
Key Technical Details
Array Modification Methods
append: Adds elements to end of array (used for weighted lists)
pushBack: Adds single element to end of array (used for simple lists)
Both modify arrays in-place (no return value needed)
Weighted vs Unweighted
Weighted: [item, weight, item, weight] - higher weight = more common
Unweighted: [item1, item2, item3] - all items equally likely
CUP Gear: Weighted (SF gets rarer gear)
CUP Voices: Unweighted (all voices equally likely)
Nickelsteel Weapons: Unweighted (simple lists)
Network Implications
All files run server-side during initialization
No network traffic (template definition only)
Clients receive final gear/vehicle lists on demand
Error Handling
TV_verifyAssets validates classnames during loading
Invalid classnames cause warnings but don't break the system
Empty arrays can occur if MOD not installed
Common Dependencies
Files depend on:

Base template loadoutData variables (_loadoutData, _sfLoadoutData, etc.)
DLC detection variables (_hasCUP, _hasNickelsteel, _hasSPEX)
Attachment arrays (e.g., _sfAccessories from base template)
Files provide for:

Faction-specific MOD content integration
Extended equipment pools
Vehicle variant definitions
Voice localization
Example Workflow
CUP Weapons for AAF:


Apply
1. Base template initializes _sfLoadoutData, _eliteLoadoutData, etc.
2. CUP detection: if (_hasCUP) then { execVM "CUP/Weapons_AAF.sqf" }
3. Weapons_AAF.sqf loads and does:
   (_sfLoadoutData get "rifles") append [weapon_array, weight]
   (_eliteLoadoutData get "rifles") append [weapon_array, weight]
4. Runtime: A3A_fnc_getLoadout randomly selects from combined list
Nickelsteel Weapons:


Apply
1. Base template loads
2. Nickelsteel detection triggers file execution
3. Appends Vietnam-era weapons to militia/military arrays
4. Weighted randomly during mission generation
Summary
CUP Files:

Voices: Simple arrays for AI dialogue
Gear: Weighted arrays for equipment progression (SF → militia)
Weapons: Complex weighted arrays with attachments
Vehicles: Simple lists for vehicle pools
Animations: Animation state definitions
Nickelsteel Files:

Weapons: Vietnam-era weapons for historical scenarios
Vehicles: AC-119 gunships, TukTuks
Gear: Uniforms/helmets for specific factions
SPEX Files:

Vehicles: WWII-era transport (C-47) and artillery (M2 mortar)
Common Pattern: All files use append or pushBack to extend arrays that already exist from base templates. The pattern is consistent: detect MOD → load file → extend arrays → use at runtime.

Vehicle Animation/Variant Files Documentation
Overview
These files define cosmetic/functional modifications to vehicles (animations, hide/show values, color variants) across MODs and factions. All files use a consistent appending pattern to extend existing arrays during faction template initialization.

Common Code Patterns
1. Animation Files (Animations_*.sqf)
Sqf

Apply
["vehicleClassName", ["anim1_source", value, "anim2_source", value, ...]],
Format: Array of [vehicle, [anim1, value, anim2, value, ...]]
Usage: Controls appearance by hiding/showing vehicle parts
Values: 0 (hide), 0.3 (random), 0.5 (random), 1 (always show/never hide)
Example: ["CSLA_Mi24V", ["addEVU",0.3,"addASO_Tail",0.3]] - 30% chance to add EVU and tail accessories to Mi-24
2. Variant Files (vehicleVariants_*.sqf)
Sqf

Apply
["vehicleClassName", ["variant1", weight, "variant2", weight, ...]],
Format: Array of [vehicle, [variant, weight, variant2, weight]]
Usage: Determines which visual variant/camouflage spawns
Weights: Higher numbers = more common (1.0 = guaranteed, 0.5 = 50% chance)
Example: ["EF_B_AAV9_MJTF_Wdl", ["Woodland",1]] - Only Woodland variant
File Organization & Usage
By MOD/Campaign:
CUP (
vehicleAnimations_CSLA.sqf
): Czechoslovak equipment, modern & 1980s variants
Global Mobilization (
vehicleAnimations_GM.sqf
, GM_NATO_*.sqf, 
GM_SFIA.sqf
): 1980s Cold War German/Polish equipment
SOG Prairie Fire (
vehicleAnimations_SOG.sqf
): Vietnam War era, multiple factions
Rearmed (
vehicleAnimations_RF.sqf
): Modern & modernized vehicles
Spezial (
vehicleAnimations_SPE.sqf
): WWII German & French equipment
Western Sahara (
vehicleAnimations_WS.sqf
): Modern hybrid tech
Vanilla (
vehicleAnimations_Vanilla.sqf
): Base game vehicles
By Climate/Terrain:
Temparate: Forests, temperate zones
Arid: Deserts, dry regions
Tropical: Jungles, humid areas
Tropical/Woodland: Combined variants for specific locales
By Faction Role:
NATO: Bluefor (BLUFOR)
CSAT: Redfor (OPFOR)
AAF: Independent (Indep)
LDF: Local defense forces (Indep)
SDK/Guerilla: Resistance
SFIA: Special Forces & Insurgents
Remnants: Rival factions using captured equipment
UN/Civilian: Peacekeeping & civilian variants
Shared Pattern Across All Files
Template System Integration
Sqf

Apply
// All files follow this pattern:
["vehicleClassname", [/* data */]],  // Line 1
["vehicleClassname", [/* data */]],  // Line 2
// ... continues to end of file
Runtime Usage:

Loadout System: A3A_fnc_getLoadout randomly selects animations/variants
Initialization: Files executed during faction template setup
Conditional Loading: Only loaded when MOD is detected
Array Merging: Values appended to existing arrays (extend, not replace)
Common Naming Conventions
_noinsignia: Vehicles without faction logos (for guerrilla/insurgent variants)
Descriptive suffixes: _wl (woodland), _arid (desert), _trop (tropical)
Faction prefixes: US85_, AFMC_, CSLA_, gm_, O_, B_, I_
Variant indicators: _ammo, _fuel, _repair, _M2, _Mk19
Value Interpretation
0.0-0.3: Rare (rarely spawn with this modification)
0.3-0.6: Common (frequent spawn)
0.7-0.9: Very common (almost always spawn)
1.0: Guaranteed (always spawn with this modification)
0: Hide/disable (often used for "never show" or "always hide")
1: Show/enable (often used for "always show" or "never hide")
Usage Workflow
Initialization Phase:

Apply
1. Base template loads empty animation/variant arrays
2. Faction detected → MOD files executed
3. Arrays extended with MOD-specific values
4. Runtime: When vehicle spawns, system randomly selects animations/variants
Visual Customization:

Apply
1. Vehicle spawned
2. System checks vehicleAnimations_*.sqf for matches
3. Randomly applies animations based on values (0-1 range)
4. Randomly selects variant based on weighted choices
5. Final vehicle appears with customized appearance
Example Process:
Sqf

Apply
// vehicleAnimations_CSLA.sqf defines:
["CSLA_T72", ["ADD_antenna",0.3,"ADD_camoNet",0.3,...]]

// When CSLA_T72 spawns:
- 30% chance to add antenna (ADD_antenna)
- 30% chance to add camo net (ADD_camoNet)
- etc.
Key Patterns
Animation Patterns:
Prefixes: add, hide, show, Hide, Show
Types: armor, ammo, fuel, tools, spare, canvas, camonet
Networking: All values set server-side, broadcast to clients
Variant Patterns:
Color schemes: Woodland, Desert, Tropic, Urban, Green
Cultural: Hex, Bridg, Camo, Olive
Weighted: Higher weight = more common spawn
MOD-Specific Naming:
CUP: US85_, AFMC_, CSLA_, FIA_
GM: gm_ prefix, camo names like gm_merdc_grn
SOG: vn_ prefix, faction codes like nva65, usarmy
RF: _RF suffix, faction variants like NAVY, AAF
SPE: SPE_ prefix, WWII codes like ST_, GER_
WS: lxWS suffix, faction tags like SFIA, Tura
Summary
All files share:

Same array structure: ["vehicle", [data]]
Append-only modifications (no overwrites)
Conditional execution based on MOD presence
Random selection at runtime using weights/values
Server-side initialization, client-side visualization
Files provide:

Animations: Visual modifications (hiding parts, adding accessories)
Variants: Color/camo choices for variety
Consistency: Uniform approach across all MODs
Modularity: Easy to add new vehicles or variants

AddonVics.hpp
 - Civilian Vehicle Pack Loader
Purpose
Load civilian vehicles from external vehicle packs (non-DLC mods) into the mission.

Structure
Cpp

Apply
class Modset
{
    path = "...";           // Where to find the addon files
    requiredAddons[] = {};  // CfgPatches class to check if mod is loaded
    files[] = {};           // {side, file} pairs to load
    displayName = "...";    // UI name for setup menu
    description = "...";    // Player-facing description
    loadedMessage = "...";  // Notification when loaded
};
Common Patterns
Cpp

Apply
class D3S  // Example from file
{
    path = QPATHTOFOLDER(Templates\AddonVics);
    requiredAddons[] = {"d3s_cars_core"};  // Check if D3S mod exists
    files[] = { {"Civ", "d3s_Civ.sqf"} };  // Load civilian vehicles
    displayName = "D3S Car pack";
    description = "A car pack that extends civilian vehicle pool";
    loadedMessage = "D3S loaded, civilian car pool expanded";
};
Usage Flow

Apply
1. Mission loads → Detects available mods via CfgPatches
2. For each AddonVics class:
   - Check if requiredAddons[] exists
   - If yes: execute files[] from path
   - If no: skip (silent failure)
3. Files append vehicles to civilian pool arrays
4. Mission uses expanded vehicle pool for civilian spawns
Key Points
Only handles civilian vehicles (side = "Civ")
Non-DLC mods (DLC packs are handled elsewhere)
Failure is silent - if mod not loaded, it just doesn't add vehicles
Modular - easy to add new car packs
Templates.hpp
 - Core Faction Template Registry
Purpose
Main configuration hub that defines all playable factions, their attributes, and which template files to load.

Structure
Cpp

Apply
class TemplateName : BaseTemplate
{
    requiredAddons[] = {};  // Required mods/DLC
    basepath = "...";       // Folder containing template files
    file = "...";           // Root file to load
    side = "...";           // "Occ" (Occupier), "Inv" (Invader), "Reb" (Rebel), "Riv" (Rival), "Civ" (Civilian)
    flagTexture = "...";    // UI flag image
    name = "...";           // Display name in setup menu
    climate[] = {};         // Valid climates: "arid", "temperate", "tropical", "arctic"
    maps[] = {};            // Recommended maps (optional)
    forceDLC[] = {};        // Required DLC/CDLC
    equipFlags[] = {};      // Equipment behavior flags
    priority = N;           // Sorting priority (lower = higher in UI)
    description = "...";    // UI description
};
Common Patterns
1. Base Classes & Inheritance
Cpp

Apply
class Vanilla_Base : Base
{
    requiredAddons[] = {};  // No mods required
    basepath = ...;         // Path to vanilla templates
    priority = 10;          // Default priority
    equipFlags[] = {"vanilla"};  // Vanilla equipment behavior
};
2. Climate-Specific Variants
Cpp

Apply
class Vanilla_NATO_Arid : Vanilla_Base
{
    side = "Occ";
    name = "A3 NATO Arid";
    file = "Vanilla_AI_NATO_Arid";
    climate[] = {"arid"};  // Only arid climates
};

class Vanilla_NATO_Temperate : Vanilla_NATO_Arid
{
    name = "A3 NATO Temperate";
    file = "Vanilla_AI_NATO_Temperate";
    climate[] = {"temperate", "arctic"};  // Different climate
};
3. DLC/CDLC Detection
Cpp

Apply
class WS_Base : Base
{
    requiredAddons[] = {"Weapons_1_F_lxWS"};  // CDLC detection
    forceDLC[] = {"ws"};                      // Required DLC tag
    equipFlags[] = {"vanilla"};               // Uses vanilla system
};
4. Including External Template Files
Cpp

Apply
class Templates
{
    // ... many includes for different mods
    
    #include "Templates\CUP\templates.hpp"
    #include "Templates\GM\templates.hpp"
    #include "Templates\CSLA\templates.hpp"
    // ... 50+ more mod includes
};
Usage Flow

Apply
1. Player selects faction in Antistasi setup menu
2. System checks:
   - Does mod/DLC exist? (requiredAddons[])
   - Is climate compatible? (climate[] vs mission map)
3. Loads file = "templateName.sqf" from basepath
4. Template file initializes loadoutData arrays with equipment
5. Faction is ready for mission start
Mod Inclusion Pattern
Example: CUP (Complex Universal Project)

Cpp

Apply
// Templates.hpp includes:
#include "Templates\CUP\templates.hpp"

// CUP/templates.hpp contains:
class CUP_Base : Base
{
    requiredAddons[] = {"CUP_AirVehicles_Core"};
    basepath = QPATHTOFOLDER(Templates\Templates\CUP);
    equipFlags[] = {"vanilla"};
};

class CUP_AAF : CUP_Base
{
    side = "Occ";
    name = "CUP AAF";
    file = "CUP_AI_AAF";
    climate[] = {"arid"};
};
Example: GM (Global Mobilization)

Cpp

Apply
class GM_Base : Base
{
    requiredAddons[] = {"gm_vehicles_land_wheeled_w123_ge_civ_w123"};
    basepath = ...;
    forceDLC[] = {"gm"};
};

class GM_NATO : GM_Base
{
    side = "Occ";
    name = "GM NATO";
    file = "GM_AI_NATO";
    climate[] = {"temperate"};
};
Example: CSA38 (WWII Mod)

Cpp

Apply
class CSA38_Base : Base
{
    requiredAddons[] = {"csa38"};
    basepath = ...;
    equipFlags[] = {"ww2", "lowTech"};  // WW2 equipment behavior
};

class CSA38_CSA38 : CSA38_Base
{
    side = "Inv";
    name = "CSA38 CSA";
    file = "CSA38_AI_CSA38";
    climate[] = {"temperate"};
};
Key Features
1. Dynamic Loading
Only loads template files if mods are detected
Silent failure if mod missing (no crashes)
Prioritizes vanilla/fallback options
2. Climate Filtering
Cpp

Apply
climate[] = {"arid", "arctic"};  // Only load if mission map matches
Prevents desert tanks in tropical jungles.

3. DLC/CDLC Enforcement
Cpp

Apply
forceDLC[] = {"ws"};  // Shows DLC requirement in UI
Informs players about required paid content.

4. Equipment Behavior Flags
Cpp

Apply
equipFlags[] = {
    "vanilla",           // Standard loadout system
    "lowTech",           // WW2/low-tech equipment
    "replaceCompass",    // Override compass
    "replaceWatch",      // Override watch
    "specialRHS"         // RHS-specific adjustments
};
5. Modular Architecture
Base path: Points to template folder
File: Root script to execute
External includes: 100+ factions across 50+ mods
Integration with Template Files
Template File Loading
When a faction is selected:

Sqf

Apply
// System does:
_basepath = "A3A\addons\core\Templates\Templates\CUP";
_file = "CUP_AI_AAF";
_path = _basepath + "\" + _file + ".sqf";

// Executes:
execVM _path;

// That file then loads:
#include "loadout_AAF.sqf"     // Equipment arrays
#include "vehicles_AAF.sqf"    // Vehicle pools
#include "gear_AAF.sqf"        // Clothing/gear
AddonVics Loading
When civilian vehicles needed:

Sqf

Apply
// System checks CfgPatches for each AddonVics class
if (isClass(configFile >> "CfgPatches" >> "d3s_cars_core")) then {
    // Load civilian file
    execVM "A3A\addons\core\Templates\AddonVics\d3s_Civ.sqf";
};
Summary
AddonVics.hpp
Purpose: Load civilian vehicles from external car pack mods
Scope: Civilian vehicles only (side = "Civ")
Pattern: Check if mod exists → load civilian file → expand vehicle pool
50+ entries: Covers all major civilian vehicle mods
Templates.hpp
Purpose: Registry for all playable factions (300+ variants)
Scope: All factions (Occupier, Invader, Rebel, Rival, Civilian)
Pattern: Base class → Inherited variant classes
Modular: Uses #include for each mod group
Features: Climate filtering, DLC detection, equipment flags
Common Patterns Across Both
Conditional Loading: Only load if mods/DLC exist
File Execution: Execute SQF files to populate arrays
UI Integration: Names, descriptions, flags for setup menu
Extensibility: Easy to add new mods via simple class definitions
Failure Safety: Silent skips if dependencies missing
Usage in Antistasi

Apply
Setup Menu → Faction Selection → Check Dependencies → 
Load Template Files → Initialize Loadouts → 
Generate Mission → Use Expanded Equipment/Vehicle Pools
This system allows Antistasi to support hundreds of factions across 50+ mods while maintaining a clean, modular codebase where each mod is self-contained and can be added/removed without affecting others.


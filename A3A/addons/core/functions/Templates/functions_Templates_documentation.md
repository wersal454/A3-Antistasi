Function Name: fn_aceModCompat.sqf
What it does: This function defines and registers all items associated with the ACE3, KAT Medical, and ADV CPR mods. It populates global arrays with classnames of medical supplies, tools, explosives, and other utility items. Based on the active modset, it then modifies the initial rebel equipment loadout to include relevant items. It also cleans up existing loot and attachment arrays to ensure compatibility and prevent duplication.

How it does that:

Defines Global Item Arrays: The function begins by declaring several arrays containing specific classnames. These are hardcoded lists of items belonging to specific mod features.

aceItems: General ACE utility items (earplugs, rangecards, clackers, map tools, flashlights, etc.).
aceMedItems: Standard ACE medical items (bandages, IVs, auto-injectors, surgical kits).
aceMedItemsBlood: Blood IVs specifically (separated from other med items).
advItems: Items from the ADV CPR mod.
katMedItems: A comprehensive list of items from the KAT Medical mod, categorized by functionality (Airway, Breathing, Circulation, Pharmacy, Surgery, Misc).
aceCoolingItems: ACE consumable drinks (canteens, water bottles, sodas).
aceFoodItems: ACE MREs (Meals Ready-to-Eat).
Publishes Variables:

Sqf

Apply
publicVariable "aceItems";
publicVariable "aceMedItems";
// ... (repeats for all arrays)
It uses publicVariable to synchronize these arrays across the network to all clients and the server, ensuring everyone shares the same item definitions.

Modifies Rebel Loadout: It checks the state of global mod detection variables (e.g., A3A_hasACEMedical, A3A_hasKAT, A3A_hasADV).

It always appends aceItems and aceCoolingItems to the rebel initial equipment.
If ACE Medical is active but KAT is not, it appends aceMedItems and aceMedItemsBlood.
If ADV is active, it appends advItems.
If both KAT and ACE Medical are active, it appends aceMedItems and katMedItems (allowing KAT to override basic ACE meds).
If aceFood is true (a global config variable), it appends aceFoodItems.
Updates Loot Arrays:

It checks the A3A_factionEquipFlags array. If "lowTech" is not present, it adds specific ACE attachments to the lootItem array.
It performs cleanup:
Removes "ACE_PreloadedMissileDummy" from lootMagazine.
Removes "ACE_acc_pointer_green" from allLightAttachments.
Removes "MineDetector" from lootItem (presumably because ACE has its own or it's redundant).
Where it leads:

Called by: A3A_fnc_initVarCommon (during server initialization).
Modifies:
aceItems, aceMedItems, etc. (Created/Populated).
FactionGet(reb, "initialRebelEquipment") (Appends items based on mod presence).
lootItem, lootMagazine, allLightAttachments (Removes specific items).
System Impact: This is a critical initialization step. If skipped, rebels will not spawn with ACE/KAT medical supplies, and loot crates will contain incorrect or non-functional items.
Function Name: fn_compatibilityLoadFaction.sqf
What it does: This function acts as a bridge between the new internal faction system (hashmaps) and the legacy system (global variables like A3A_faction_occ). It loads a specific faction definition file, merges it with default values, compiles group definitions, registers unit types globally, and calculates derived vehicle lists (like vehiclesArmor).

How it does that:

Parameter Validation & Logging:

Sqf

Apply
params ["_file", "_side"];
Info_2("Compatibility loading template: '%1' as side %2", _file, _side);
Accepts a file path and a side (west, east, etc.).

Determine Defaults:

Sqf

Apply
private _factionDefaultFile = ["EnemyDefaults","EnemyDefaults","RebelDefaults","CivilianDefaults"] #([west, east, independent, civilian] find _side);
_factionDefaultFile = QPATHTOFOLDER(Templates\Templates\FactionDefaults) + "\" + _factionDefaultFile + ".sqf";
Selects the appropriate default template file (e.g., RebelDefaults.sqf) based on the side.

Load Faction Data:

Sqf

Apply
private _faction = [[_factionDefaultFile,_file]] call A3A_fnc_loadFaction;
Calls fn_loadFaction to parse the SQF files into a hashmap structure.

Register Faction:

Sqf

Apply
private _factionPrefix = ["occ", "inv", "reb", "civ"] #([west, east, independent, civilian] find _side);
missionNamespace setVariable ["A3A_faction_" + _factionPrefix, _faction];
Saves the loaded hashmap to a global variable (e.g., A3A_faction_occ).

Compile Groups:

Sqf

Apply
[_faction, _factionPrefix] call A3A_fnc_compileGroups;
Populates the faction hashmap with group definitions (arrays of unit types for squads, patrols, etc.).

Register Unit Types:

Gets the unit class map (mapping template names to Arma classes).
Iterates over all loadouts defined in the faction.
Calls A3A_fnc_registerUnitType to register each unit class globally (e.g., loadouts_reb_militia_Rifleman).
Calculate Derived Vehicle Lists (if Occ/Inv):

Calculates vehiclesLightArmedTroop: Filters vehiclesLightArmed for vehicles with >= 4 passenger seats.
Calculates vehiclesArmor: Aggregates all armored vehicle types (Tanks, AA, Artillery, APCs, IFVs, etc.) into a single list.
Where it leads:

Called by: Mission initialization or dynamic faction loading.
Calls:
A3A_fnc_loadFaction (Parses the SQF files).
A3A_fnc_compileGroups (Sets up group templates).
A3A_fnc_registerUnitType (Registers units for spawning).
Depends on: The existence of valid faction definition SQF files and A3A_fnc_loadFaction.
Modifies: A3A_faction_occ, A3A_faction_inv, etc. (Global namespace).
System Impact: This is the core entry point for loading a faction. It transforms raw data into usable game logic structures.
Function Name: fn_compileGroups.sqf
What it does: This function populates the faction hashmap with standardized group definitions. It takes the raw loadout names and constructs arrays representing the composition of squads, fireteams, and patrols. It handles different logic for Occupiers/Invaders (tiered units), Rivals, and Rebels.

How it does that:

Setup: Defines a macro unit(SECTION, TYPE) to construct the standard loadout name string: "loadouts_"+_prefix+"_"+ #SECTION +"_"+ TYPE.

Occupiers/Invaders Logic (if (_prefix in ["occ", "inv"])):

Singular Units: Defines static unit references (e.g., unitTierStaticCrew, unitRifle) as arrays of loadout names for Militia, Military, and Elite tiers.
Tiered Groups: Defines arrays for guards and tower guards containing sub-arrays of unit types for different tiers (Militia/Military/Elite).
Small Groups: Defines 2-man and 3-man patrols (Sentry, LAT, Marksman, MG).
Medium Groups (4-man): Defines Fireteams, AA teams, AT teams.
Squads: Uses a for loop to generate 5 randomized squad compositions. It uses selectRandomWeighted to vary the members slightly (e.g., preferring LAT over MG, or Rifleman over Radioman).
SpecOps: Generates random SpecOp groups.
Militia: Generates specific militia groups.
Police: Defines police groups.
Rivals Logic (if (_prefix isEqualTo "riv")):

Sets specific unit names (CellLeader, Minuteman, etc.).
Defines Sentry groups, AA/AT groups, Fireteams, and Squads using weighted randomization similar to Occ/Inv.
Rebel Logic (if (_prefix isEqualTo "reb")):

Defines specific singular units (Petros, Crew, Sniper, LAT, Medic, etc.).
Defines groups (Medium, AT, Squad, SquadEng, SquadSupp, Sniper, Sentry).
Calculates unitsSoldiers: A flat list of all soldier types available to rebels (used for buying units in the barracks).
Defines Emplacement groups (AA, AT, HMG) and Crew groups.
Civilians:

Sets basic civilian unit types (Man, Press, Worker, Special).
Where it leads:

Called by: A3A_fnc_compatibilityLoadFaction or A3A_fnc_loadRivals.
Calls: None directly (pure data structure creation).
Modifies: The _faction hashmap passed in via arguments (specifically keys like unitRifle, groupTierSquads, groupsMilitiaSquads, etc.).
System Impact: Defines the tactical composition of AI forces. The output of this function dictates what groups spawn when a mission or patrol is created.
Function Name: fn_compileMissionAssets.sqf
What it does: This function analyzes all loaded factions (Occ, Inv, Reb, Riv) and the Black Market to compile a single comprehensive list of all assets (vehicles, statics) organized by category. It creates the A3A_faction_all global hashmap.

How it does that:

Initialization:

Sqf

Apply
A3A_faction_all = createHashMap;
Clears or creates the global asset registry.

Helper Functions:

_fnc_extractMarketClasses: Queries the A3U_blackMarketStock array to find items of a specific type (e.g., "APC", "UAV") and returns their classnames.
_fnc_setHashmap: Helper to convert array-based data in the faction (like animations) into hashmap format for faster lookups.
Unit Identification:

Scans loadout names for prefixes "occ_", "inv_" to find Squad Leaders, Medics, and Radiomen.
Appends Rivals and Rebel specific roles.
Stores these lists in A3A_faction_all under keys "SquadLeaders", "Medics", "Radiomen".
Vehicle Identification (SetVar Macro): Uses a macro setVar(VAR, VALUE) which performs arrayIntersect to remove duplicates and stores the result in A3A_faction_all.

Occ/Inv Vehicles: Aggregates lists from factions (e.g., vehiclesAttack, vehiclesAA, vehiclesTanks) and adds Black Market equivalents.
Rivals Vehicles: Aggregates vehiclesRivalsAPCs, vehiclesRivalsTanks, staticMGs, etc.
Rebel Vehicles: Aggregates vehiclesBasic, vehiclesTruck, staticMGs, etc.
Derived Categories:

vehiclesArmor: Aggregates all armored vehicles.
vehiclesRivalsArmor: Aggregates Rivals APCs and Tanks.
vehiclesHelis: Aggregates all helicopters + "HELI" market items.
vehiclesFixedWing: Aggregates all planes + "PLANE" market items.
vehiclesTrucks: Aggregates trucks from all sides.
vehiclesLightArmed: Aggregates armed cars.
vehiclesCargoTrucks: Filters trucks based on A3A_Logistics_fnc_getVehCapacity (only ones that can carry cargo).
Animation/Variants: Converts the animations and variants arrays from the factions into hashmaps for faster lookups.

Where it leads:

Called by: Initialization sequence after all factions are loaded.
Calls: A3A_fnc_getVehCapacity (Logistics function).
Depends on: A3A_faction_occ, A3A_faction_inv, etc., being populated. A3U_blackMarketStock being populated.
Modifies: A3A_faction_all (Global).
System Impact: Provides a centralized, optimized repository for all assets in the mission. Used by spawning scripts, arsenal, and mission generation to quickly determine available assets without searching config files repeatedly.
Function Name: fn_getLoadout.sqf
What it does: This function retrieves a pre-compiled loadout array for a specific unit type. It handles caching to improve performance. It also defines standard medical and misc item sets based on whether ACE is active.

How it does that:

Defines Medical/Misc Defaults:

_basicMedicalSupplies: Checks A3A_hasACE. If true, returns ACE items (tourniquets, bandages, IVs). If false, returns vanilla "FirstAidKit".
_basicMiscItems: Checks A3A_hasACE. If true, returns ACE Earplugs and Cableties.
_medicSupplies: Checks A3A_hasACE. If true, returns advanced ACE medical (surgical kit, more bandages, plasma). If false, returns "Medikit".
Helper Functions (Modifiers):

_fnc_modItem: Takes a boolean (hasMod), a mod item, and a replacement. Returns an array containing the item (or empty/replacement).
_fnc_tfarRadio: Uses the modifier to return a TFAR radio or "ItemRadio".
Retrieval Logic:

It attempts to find the loadout in the missionNamespace cache: missionNamespace getVariable [_loadoutName, []].
If not found (empty): It constructs the file path (format ["%1.sqf", _loadoutName]) and executes preprocessFileLineNumbers.
Caching: The result is stored in the missionNamespace for future use.
Where it leads:

Called by: Unit spawning functions (e.g., A3A_fnc_createUnit, A3A_fnc_spawnGroup).
Calls: preprocessFileLineNumbers (External file I/O).
Depends on: The existence of .sqf files on the disk matching the _loadoutName (e.g., loadouts_reb_militia_Rifleman.sqf).
Modifies: missionNamespace (Caches the loaded array).
System Impact: The primary entry point for retrieving a unit's gear. It decouples the definition of the loadout (the SQF file) from the code that uses it.
Function Name: fn_loadAddon.sqf
What it does: Allows the addition of external "addon packs" (vehicles or gear) to an existing faction without modifying the core faction files. It loads a file and merges its contents into the faction's data structure.

How it does that:

Parameter Validation: Checks if _side is valid ("occ", "inv", "reb", "civ") and if the _path file exists.

Loading Data:

Sqf

Apply
private _addon = createHashMap;
call compile preprocessFileLineNumbers _path;
Executes the addon file. The file is expected to set variables in the _addon hashmap (e.g., _addon set ["vehiclesCars", ["MyMod_Car1", "MyMod_Car2"]]).

Merging:

Sqf

Apply
{
    _faction set [_x, (_faction getOrDefault[_x, []]) + _y];
} forEach _addon;
Iterates over keys in the addon data. It retrieves the existing array from the faction, appends the new array from the addon, and updates the faction.

Where it leads:

Called by: Configuration scripts or user commands to add extra assets.
Calls: preprocessFileLineNumbers.
Depends on: Valid faction data existing in A3A_faction_....
Modifies: The specific A3A_faction_... hashmap.
System Impact: Enables modularity. Users can add third-party vehicle packs (like RHS or CUP) simply by loading an addon script that defines compatibility.
Function Name: fn_loadFaction.sqf
What it does: The core loader for faction definition files. It sets up the environment (local variables and functions) needed by the faction definition files, executes them, and returns the populated data store.

How it does that:

Setup Execution Environment: Creates a private _dataStore = createHashMap. This acts as the container for all data defined in the template file.

Defines Template Functions (Local Scope): These functions are available inside the faction definition SQF files:

saveToTemplate: Adds data to the _dataStore (e.g., ["vehiclesAttack", ["B_MRAP_01_F"]]).
getFromTemplate: Retrieves data.
saveUnitToTemplate: Specifically handles adding unit loadout definitions to a loadouts hashmap within the _dataStore.
generateAndSaveUnitToTemplate: Uses A3A_fnc_loadout_builder to generate multiple variations of a unit and saves them.
saveNames: Loads first/last names from CfgWorlds.
Execution:

Sqf

Apply
{
    call compile preprocessFileLineNumbers _x;
} forEach _filepaths;
It loops through the provided file paths (usually defaults + specific template) and compiles them. The code inside these files calls the local functions defined above to populate _dataStore.

Return: Returns the fully populated _dataStore hashmap.

Where it leads:

Called by: A3A_fnc_compatibilityLoadFaction, A3A_fnc_loadRivals.
Calls: A3A_fnc_loadout_builder (via local helper generateAndSaveUnitToTemplate).
System Impact: This is the sandbox that allows template files to be written in a simplified scripting language (saveToTemplate instead of complex variable assignment).
Function Name: fn_loadRivals.sqf
What it does: Specifically loads the Rivals (Opfor Guerilla) faction. It is similar to compatibilityLoadFaction but tailored for the East side and Rivals-specific unit mapping.

How it does that:

Load Data: Calls A3A_fnc_loadFaction with the Rivals file and the default "EnemyDefaults".

Register Faction: Sets A3A_faction_riv and calls A3A_fnc_compileGroups with the "riv" prefix.

Unit Class Mapping: Creates a specific createHashMapFromArray mapping Rivals loadout names (e.g., "militia_Cellleader") to Arma classnames (e.g., "O_G_Soldier_SL_F").

Register Units: Iterates through the loaded loadouts, looks up the Arma classname in the map, and calls A3A_fnc_registerUnitType to make them available for spawning.

Where it leads:

Called by: Server initialization for Rivals.
Calls: A3A_fnc_loadFaction, A3A_fnc_compileGroups, A3A_fnc_registerUnitType.
System Impact: Sets up the Rivals faction for gameplay.
Function Name: fn_rhsModCompat.sqf
What it does: Filters loot arrays to only include items authored by "Red Hammer Studios". This prevents non-RHS items from appearing in loot if RHS is loaded.

How it does that:

Uses getText (configfile >> "CfgWeapons" >> _x >> "author") == "Red Hammer Studios" to filter lootAttachment, allLightAttachments, and allLaserAttachments.
Where it leads:

Called by: Initialization.
Modifies: lootAttachment, allLightAttachments, allLaserAttachments.
System Impact: Ensures loot matches the modset.
Function Name: fn_TV_verifyAssets.sqf
What it does: Validates the static data in a faction hashmap (vehicles, statics, specific items) to ensure all classnames exist in the game config. It checks for typos and correct casing.

How it does that:

Validation Functions:

_fnc_validClassCaseSensitive: Checks if a class exists in CfgVehicles (or Weapons/Magazines) and verifies the case matches exactly.
_fnc_validateArrayOfClasses: Loops through an array and validates each item.
_fnc_validateSingleClass: Validates a single class.
_fnc_handleUniqueCases: A massive switch statement handling specific keys that don't follow standard naming (e.g., "initialRebelEquipment", "placeIntel_itemMedium").
Processing Loop: Iterates over every key/value pair in the faction hashmap.

Skips loadouts, group..., unit... keys.
Uses pattern matching (e.g., case ("vehicles" in _entry)) to route to the correct validator.
Logs errors to _invalidReasons.
Reporting: If _invalidReasons is not empty, it logs an error message containing all invalid entries.

Where it leads:

Called by: A3A_fnc_compatibilityLoadFaction (if __A3_DEBUG__ is defined).
Calls: isClass (Arma engine command).
System Impact: Prevents runtime errors caused by missing mods or typos in templates.
Function Name: fn_TV_verifyLoadout.sqf
What it does: Validates a single unit loadout array (the 10-element array used by setUnitLoadout). It checks weapons, attachments, magazines, containers, and linked items for existence and compatibility.

How it does that:

Weapon Validation:

Retrieves compatible items for the weapon using compatibleItems.
Validates Muzzle (Type 101): Checks class and ensures it is in the compatible list.
Validates Rail/Pointer (Type 301): Checks class and compatibility.
Validates Optic (Type 201): Checks class and compatibility.
Validates Magazine: Checks class, compatibility (compatibleMagazines), and that bullet count <= max capacity.
Container Validation:

Checks Uniform, Vest, Backpack existence.
Calculates load using getContainerMaxLoad (internal logic in fn_loadout_itemLoad).
Validates contents recursively (items or mags).
Linked Items & Facewear:

Checks GPS, Radio, Map, Watch, Compass, NVGs, Binoculars, Helmet, Facewear classes.
Where it leads:

Called by: fn_TV_verifyLoadoutsData.
Calls: compatibleItems, compatibleMagazines, isClass.
System Impact: Ensures generated loadouts won't break setUnitLoadout or result in units spawning without gear.
Function Name: fn_TV_verifyLoadoutsData.sqf
What it does: Orchestrates the verification of all loadouts within a faction.

How it does that:

Iterates over the loadouts hashmap in the faction data.
For each loadout name, retrieves the array of generated loadouts.
Calls fn_TV_verifyLoadout for each variation.
Checks unit traits (medic, engineer, etc.) for validity.
Aggregates errors and logs them.
Where it leads:

Called by: fn_compatibilityLoadFaction.
Calls: fn_TV_verifyLoadout.
System Impact: Complete quality control for unit definitions.
Function Name: fn_loadout_addEquipment.sqf
What it does: Adds standard equipment (GPS, Radio, Map, Watch, Compass, NVG, Binoculars) to a loadout array.

How it does that:

Takes a loadout array and an equipment list.
Loops through the list.
If the item is an array ["TYPE", "Class"], it uses the specific class. Otherwise, it uses a default.
Updates specific indices in the loadout array:
Index 9 is the linked items array: [Map, GPS, Radio, Compass, Watch, NVG].
Index 8 is the binoculars array.
Where it leads:

Called by: fn_loadout_builder.
System Impact: Fills the "slot 9" and "slot 8" of the unit loadout.
Function Name: fn_loadout_addItems.sqf
What it does: Intelligently adds items (magazines, grenades, medical) to a unit's containers (Uniform, Vest, Backpack) based on available space, prioritizing items.

How it does that:

Batching: Organizes input items into "batches". Batch 1 is most important (e.g., magazines), Batch 2 is less important (e.g., grenades), etc.

Capacity Calculation: Calculates current load and max load for Uniform, Vest, and Backpack using getContainerMaxLoad and A3A_fnc_loadout_itemLoad.

Trimming (Overflow Protection): If the total load of a batch exceeds available space, it loops through the batch and removes items (starting with stacks > 1) until it fits or space is exhausted.

Distribution: Attempts to add items to Uniform -> Vest -> Backpack. It prioritizes filling the Uniform first, then Vest, then Backpack.

Where it leads:

Called by: fn_loadout_builder.
Calls: getContainerMaxLoad, A3A_fnc_loadout_itemLoad.
System Impact: Prevents "Inventory Full" errors and ensures vital items are kept if space is tight.
Function Name: fn_loadout_builder.sqf
What it does: The "compiler" of loadouts. It takes a template (code) and data (hashmap) and produces a finished setUnitLoadout compatible array.

How it does that:

Setup: Creates a base empty loadout _finalLoadout.

Local Helpers: Defines functions available to the template code:

_fnc_parseItemArray: Handles random selection from arrays or weighted arrays.
_fnc_parseWeaponFormat: Takes weapon definitions, resolves magazines, and returns a loadout-ready array.
_fnc_set... functions: Set Uniform, Vest, Backpack, Helmet, Primary, Launcher, Handgun.
_fnc_add... functions: Add magazines, items, equipment.
Execution: call _template; Executes the passed template code. The template calls the helper functions to populate the loadout and internal tracking variables (like _magazineCountForSlots).

Post-Processing:

Equipment: Calls fn_loadout_addEquipment to finalize slot 9/8.
Magazines: Calculates exactly which magazines to add based on the weapon slots and requested counts. Distributes them into batches.
Items: Calls fn_loadout_addItems to place all remaining items into containers.
Where it leads:

Called by: fn_loadFaction (during generation) or fn_loadout_createBase.
Calls: fn_loadout_addEquipment, fn_loadout_addItems.
System Impact: Generates the actual gear data used by the game.
Function Name: fn_loadout_createBase.sqf
What it does: Returns a blank, valid unit loadout array structure.

How it does that: Returns [[],[],[],[_uniform, []],[],[],"","",[],["","","","","",""]].

Where it leads:

Called by: fn_loadout_builder.
Function Name: fn_loadout_defaultWeaponMag.sqf
What it does: Gets the default magazine class and count for a weapon.

How it does that:

Reads configFile >> "CfgWeapons" >> _class >> "Magazines".
Takes the first magazine.
Gets the max count of that magazine.
Returns [_magClass, _count].
Where it leads:

Called by: fn_loadout_builder (if no magazine is specified in template).
Function Name: fn_loadout_itemLoad.sqf
What it does: Calculates the "mass" or "load" of a single item array entry to determine if it fits in a container.

How it does that:

Checks type of input (String, Array of 2, Array of 3, Array of 7).
For items: Gets mass from config.
For mags: Gets mass * count.
For weapons: Sums mass of base weapon + attachments + mags.
Where it leads:

Called by: fn_loadout_addItems, fn_loadout_builder.
Calls: A3A_fnc_itemConfig, A3A_fnc_itemConfigMass.
Function Name: fn_loadout_setBackpack/Uniform/Vest.sqf
What it does: Sets the backpack/uniform/vest slot in the loadout array (Index 5, 3, 4).

How it does that: _loadout set [Index, [_class, _items]].

Function Name: fn_loadout_setFacewear.sqf
What it does: Sets the facewear slot (Index 7).

Function Name: fn_loadout_setHelmet.sqf
What it does: Sets the helmet slot (Index 6).

Function Name: fn_loadout_setWeapon.sqf
What it does: Sets a weapon slot (Index 0, 1, or 2) in the loadout array.

How it does that:

Accepts a class or array of attachments.
Constructs the 7-element weapon array.
If no magazine provided, calls fn_loadout_defaultWeaponMag to fill it.
Function Name: fn_itemset_medicalSupplies.sqf
What it does: Returns an array of medical items based on the requested level ("Minimal", "Standard", "MEDIC") and the active modset.

How it does that: Uses a switch (true) structure:

Checks A3A_hasACEMedical.
If true: Returns ACE specific arrays (bandages, IVs, etc.).
If false: Returns vanilla arrays (FirstAidKit, Medikit).
Where it leads:

Called by: Loadout templates or unit spawning.
Function Name: fn_itemset_miscEssentials.sqf
What it does: Returns essential utility items (Earplugs, MapTools, Cableties) if ACE is active.

How it does that: Checks A3A_hasACE and appends items to a list.

Where it leads:

Called by: Loadout templates.






/////////////////////////////////////second attempt

Function Name: fn_aceModCompat.sqf What it does: This script functions as a configuration loader for Advanced Combat Environment (ACE) and KAT Medical items. Its primary purpose is to populate several global arrays with classnames of items from these popular mods, making them available to the rest of the Antistasi Ultimate system. It then modifies the Rebel faction's initial equipment to include these items based on which mods are detected as active. It also handles modifications to global loot tables (removing vanilla items that are replaced by ACE equivalents) and defines specific items for KAT Medical support.

How it does that:

Define ACE Items:
It initializes a global variable aceItems with an array of standard ACE utility items (e.g., ACE_EarPlugs, ACE_Clacker). Note that Info is a logging macro, not standard SQF.
Sqf

Apply
aceItems = [
    "ACE_EarPlugs",
    "ACE_RangeCard",
    // ... rest of items
];
Define ACE Medical Items:
It defines aceMedItems containing bandages, IVs, and drugs, and aceMedItemsBlood containing blood bags (separated because some setups use Saline/Plasma but not Blood).
Sqf

Apply
aceMedItems = [
    "ACE_fieldDressing",
    // ... rest of items
];
Define Third-Party Mod Items:
It defines advItems (for Advanced CPR) and a large array katMedItems containing items for the KAT Medical mod, categorized by functionality (Airway, Breathing, Circulation, Pharmacy, Surgery, Misc).
Define Consumables:
aceCoolingItems (drinks) and aceFoodItems (MREs) are defined.
Publish Variables:
All arrays are made globally available using publicVariable.
Sqf

Apply
publicVariable "aceItems";
// ...
Modify Rebel Loadouts:
It appends the basic aceItems and aceCoolingItems to the rebel initial equipment.
It checks boolean flags (e.g., A3A_hasACEMedical, A3A_hasKAT) to decide which medical arrays to append.
It checks A3A_factionEquipFlags to see if "lowTech" is active; if not, it adds specific ACE flashlights/pointers to loot lists and removes vanilla equivalents.
Sqf

Apply
FactionGet(reb,"initialRebelEquipment") append aceItems;
if (A3A_hasACEMedical && !A3A_hasKAT) then {
    FactionGet(reb,"initialRebelEquipment") append aceMedItems;
    // ...
};
Where it leads:

Depends on:
A3A_hasACEMedical, A3A_hasKAT, A3A_hasADV: Boolean flags set during mod detection (likely in initVarCommon or initACE).
FactionGet(reb,"initialRebelEquipment"): A function/macro to access the faction configuration.
lootItem, lootMagazine, allLightAttachments: Global arrays used for random loot generation.
Called by:
Likely called during the template initialization phase, potentially directly inside 
fn_loadFaction.sqf
 via a call compile of the template file, or triggered by a specific template setup.
System Integration:
This script bridges the gap between the presence of ACE/KAT and the game logic. Without this, players would not spawn with ACE medical supplies or KAT gear even if the mod is loaded.
It ensures clean loot tables by removing items like "MineDetector" if the ACE equivalent is used.
Function Name: fn_compatibilityLoadFaction.sqf What it does: This function acts as a bridge between the new, modular "Faction Data" system (Hashmaps) and the legacy "Global Variable" system used by older parts of Antistasi. It loads a faction definition file, converts it into the old global variable structure (e.g., vehAttack, unitWave), and registers the loadouts.

How it does that:

Parameter Validation & Setup:
Takes _file (path to template) and _side (west, east, etc.).
Maps the side to a prefix string (["occ", "inv", "reb", "civ"]) and a defaults file path.
Sqf

Apply
params ["_file", "_side"];
private _factionPrefix = ["occ", "inv", "reb", "civ"] #([west, east, independent, civilian] find _side);
Load Data:
Calls A3A_fnc_loadFaction to actually parse the .sqf template file into a Hashmap.
Stores this Hashmap in missionNamespace as A3A_faction_occ (etc.).
Sqf

Apply
private _faction = [[_factionDefaultFile,_file]] call A3A_fnc_loadFaction;
missionNamespace setVariable ["A3A_faction_" + _factionPrefix, _faction];
Compile Groups:
Calls A3A_fnc_compileGroups. This function takes the Hashmap and defines specific unit types (like unitRifle, groupSquad) based on the loadout names inside the Hashmap.
Sqf

Apply
[_faction, _factionPrefix] call A3A_fnc_compileGroups;
Register Units:
It iterates through the loadouts stored in the faction Hashmap.
For every loadout, it calls A3A_fnc_registerUnitType to map the loadout name (e.g., "militia_Rifleman") to a specific unit class defined in _unitClassMap.
This creates the global variables like NATO_MG or SDK_MG.
Sqf

Apply
{
    private _loadoutName = _x;
    private _unitClass = _unitClassMap getOrDefault [_loadoutName, _baseUnitClass];
    [_loadoutsPrefix + _loadoutName, _y + [_unitClass]] call A3A_fnc_registerUnitType;
} forEach _allDefinitions;
Calculate Derived Arrays (Occupants/Invaders):
It performs calculations on vehicle arrays to create new categories.
vehiclesLightArmedTroop: Filters light armed vehicles that have 4+ passenger seats.
vehiclesArmor: Aggregates all armored vehicle categories (Tanks, APCs, IFVs, AA, etc.) into one list for easier selection.
Sqf

Apply
private _lightArmedTroop = (_faction get "vehiclesLightArmed") select {
    ([_x, true] call BIS_fnc_crewCount) - ([_x, false] call BIS_fnc_crewCount) >= 4
};
Where it leads:

Depends on:
A3A_fnc_loadFaction: To parse the raw template file.
A3A_fnc_compileGroups: To set up unit groups.
SCRT_fnc_unit_getUnitMap: (Inferred) A function that maps standard role names to specific classes.
A3A_fnc_registerUnitType: To create the global unit variables.
Called by:
The mission init sequence when loading specific faction templates (e.g., loading the NATO template).
System Integration:
Crucial for Initialization: This is the "entry point" for templates to actually make units spawnable.
It ensures that A3A_faction_occ (the hash map) is populated and synchronized with the old legacy variables (like vehAttack) that older AI scripts still rely on.
Function Name: fn_compileGroups.sqf What it does: This function populates a faction Hashmap with group composition definitions. It takes the raw faction data and generates specific arrays of unit classnames for different tactical roles (Squads, Fireteams, Patrols, Snipers). It supports tiered difficulty (Militia, Military, Elite) for Occupants/Invaders, and specific role definitions for Rebels and Rivals.

How it does that:

Define Helper Macros:
unit(SECTION, TYPE): A macro that constructs a loadout string name (e.g., loadouts_occ_militia_Rifleman).
Sqf

Apply
#define unit(SECTION, TYPE) ("loadouts_"+_prefix+"_"+ #SECTION +"_"+ TYPE)
Occupants/Invaders Logic (if (_prefix in ["occ", "inv"])):
Singular Units: Defines single unit slots (e.g., unitRifle, unitOfficial) by referencing the specific loadout names for Militia, Military, and Elite tiers.
Small Groups: Creates arrays for 2-man patrols (Sentry, LAT, Marksman, MG).
Tiered Groups: Creates 4-man groups (AA, AT, Fireteams).
Squads: Generates 8-man squads. It uses selectRandomWeighted to randomly mix LAT, MG, and Riflemen within the squad to create variation.
Sqf

Apply
private _squads = [];
for "_i" from 1 to 5 do {
    _squads pushBack [
        [
            unit(militia, "SquadLeader"),
            selectRandomWeighted [unit(militia, "LAT"), 2, unit(militia, "MachineGunner"), 1],
            // ... mixing logic
        ],
        // ... other tiers
    ];
};
Rivals Logic (if (_prefix isEqualTo "riv")):
Similar to above, but maps roles specific to Rivals (CellLeader, Minuteman, Partisan) to loadout names.
Generates randomized squads and fireteams using selectRandomWeighted.
Rebel Logic (if (_prefix isEqualTo "reb")):
Defines specific unit slots (Petros, Sniper, LAT, Medic).
Defines static group arrays (Medium, AT, Squad, SquadEng, etc.) referencing the unit slots defined in the previous step.
Note: Rebels do not use the tiered system here; they use static definitions based on the "rebel" loadout prefix.
Where it leads:

Depends on:
loadouts: The Hashmap key containing all loadout definitions (populated by loadFaction).
Called by:
fn_compatibilityLoadFaction and fn_loadRivals.
System Integration:
Spawn Logic: Functions like CREATE_spawnGroup will look at these generated keys (e.g., groupsTierSquads) to decide which units to spawn when an enemy group is created.
Backward Compatibility: It effectively translates the flexible loadout system into rigid arrays that can be easily indexed by selectRandom.
Function Name: fn_compileMissionAssets.sqf What it does: This function creates a global master list of all assets available to all factions. It aggregates vehicle classnames, static weapons, and unit roles (SquadLeaders, Medics) from all loaded factions (Occ, Inv, Reb, Riv) into a single Hashmap A3A_faction_all. This is used for identifying vehicle types for AI logic, logistics, and asset verification.

How it does that:

Setup Aggregation Macros:
Defines macros like OccAndInv(VAR) to simplify getting arrays from both major enemy factions.
Identify Unit Types:
Iterates through prefixes (occ_, inv_) and sections (militia_, SF_) to generate lists of classnames for SquadLeaders, Medics, and Radiomen.
Appends specific rebel/rival classes.
Saves these lists to A3A_faction_all using setVar.
Sqf

Apply
private _squadLeaders = [];
{
    private _prefix = _x;
    {
        _squadLeaders pushBack ('loadouts_'+_prefix+_x+'SquadLeader');
    } forEach ["militia_","military_","elite_","SF_"];
} forEach ["occ_", "inv_"];
setVar("SquadLeaders", _squadLeaders);
Identify Vehicle Types:
It processes vehicle arrays from the faction hashmaps.
Aggregation: It combines vehicles by role. For example, vehiclesAPCs includes standard APCs, Militia APCs, and Rivals APCs.
Black Market Support: It uses a helper function _fnc_extractMarketClasses to scan A3U_blackMarketStock and include black market vehicles in the appropriate categories (e.g., "APC", "TANK").
Derived Lists: It creates logical groupings like vehiclesHelis (Transport + Attack) or vehiclesFixedWing.
Sqf

Apply
setVar("vehiclesAPCs", OccAndInv("vehiclesAPCs") + Riv("vehiclesRivalsAPCs") + ("APC" call _fnc_extractMarketClasses));
Store Variants/Animations:
It converts the "animations" and "variants" arrays (which are usually arrays of pairs) into Hashmaps for faster lookups and stores them in the faction data.
Finalize:
Saves the compiled A3A_faction_all to the mission namespace and broadcasts it.
Where it leads:

Depends on:
A3A_faction_occ, A3A_faction_inv, etc.: The loaded faction data.
A3U_blackMarketStock: Global array of black market items.
A3A_Logistics_fnc_getVehCapacity: Used to filter cargo trucks.
Called by:
Mission initialization, after all factions are loaded.
System Integration:
Global Utility: This is the "source of truth" for the whole mission. When a script needs "all enemy tanks," it queries A3A_faction_all get "vehiclesTanks".
Logistics: Used to identify which trucks can carry cargo.
Function Name: fn_getLoadout.sqf What it does: This is a utility function that retrieves a specific unit loadout. It handles caching the loadout (compiling it only once) and provides default medical/essential items based on active mods (ACE vs Vanilla).

How it does that:

Define Medical/Item Defaults:
It creates variables _basicMedicalSupplies, _basicMiscItems, and _medicSupplies.
It checks A3A_hasACE to decide whether to use ACE item classnames (morphine, bandages) or Vanilla classnames (FirstAidKit, Medikit).
Define Helper Functions (Closures):
_fnc_modItem: Returns an array containing an item if a mod is present, otherwise returns an empty array or a replacement.
_fnc_tfarRadio: Returns the TFAR radio classname or standard ItemRadio.
Load the Loadout:
It attempts to retrieve the loadout from missionNamespace cache.
If not cached, it call compile preprocessFileLineNumbers the specific .sqf file for that loadout name.
It caches the result for future use.
Sqf

Apply
private _loadoutArray = missionNamespace getVariable [_loadoutName, []];
if (_loadoutArray isEqualTo []) then {
    _loadoutArray = call compile preprocessFileLineNumbers format ["%1.sqf", _loadoutName];
    missionNamespace setVariable [_loadoutName, _loadoutArray];
};
Return:
Returns the raw loadout array suitable for setUnitLoadout.
Where it leads:

Depends on:
A3A_hasACE, A3A_hasTFAR: Mod flags.
The .sqf files for specific loadouts (e.g., loadouts_reb_militia_Rifleman.sqf).
Called by:
A3A_fnc_registerUnitType (likely, to process loadouts) or specific unit creation scripts.
System Integration:
This function is the final step before a unit is actually created. It ensures that the unit gets the correct gear for the specific modset the server is running.
Function Name: fn_loadAddon.sqf What it does: This function allows adding extra vehicles or items from a separate file (an "Addon Pack") to an existing faction. This is used to support multiple vehicle mods without rewriting the entire faction template.

How it does that:

Input Validation:
Checks if _side is valid (occ, inv, reb, civ) and if the _path file exists.
Load Data:
Creates an empty _addon Hashmap.
call compile preprocessFileLineNumbers _path: Executes the addon file. This file is expected to populate the _addon hashmap (e.g., _addon set ["vehiclesHelis", ["Heli1", "Heli2"]]).
Merge Data:
Retrieves the current faction data: _faction = missionNamespace getVariable ["A3A_faction_"+_side, ...].
Iterates over keys in the addon.
Appends the addon arrays to the existing faction arrays.
Sqf

Apply
{
    _faction set [_x, (_faction getOrDefault[_x, []]) + _y];
} forEach _addon;
Return:
Returns the modified faction Hashmap.
Where it leads:

Depends on:
The specific addon file path.
Called by:
Template configuration scripts.
System Integration:
Modularity: Keeps base templates clean. If a user wants to add CUP Helis to the NATO template, they load the NATO template, then call this function with the CUP addon path. It merges the CUP helis into the vehiclesHelis array.
Function Name: fn_loadFaction.sqf What it does: This is the core parser for Antistasi templates. It takes one or more file paths, executes them in a controlled environment, and captures all the data definitions into a Hashmap. It defines the "Template System" functions (_fnc_saveToTemplate, etc.) that are used inside the template files.

How it does that:

Create Datastore:
Initializes private _dataStore = createHashMap;. This is where all the template data will live.
Define Context Functions:
_fnc_saveToTemplate: Sets a key/value in _dataStore. Used inside templates like ["vehiclesTanks", ["Tank1"]] call _fnc_saveToTemplate.
_fnc_saveUnitToTemplate: Adds a unit definition to the loadouts hashmap inside _dataStore.
_fnc_generateAndSaveUnitToTemplate: Uses A3A_fnc_loadout_builder to create multiple random loadouts for a unit and saves them.
Execute Files:
Loops through the provided _filepaths.
call compile preprocessFileLineNumbers _x: This executes the template code. Since _fnc_saveToTemplate is defined locally, the template file fills up the local _dataStore.
Return:
Returns the populated _dataStore Hashmap.
Where it leads:

Depends on:
A3A_fnc_loadout_builder: Used by the generation functions.
The template files (e.g., Altis.sqf).
Called by:
fn_compatibilityLoadFaction.
System Integration:
The Engine: This is the interpreter. A template file is just a script that defines data. This function provides the API (_fnc_saveToTemplate) that allows that data to be captured and structured.
Function Name: fn_loadRivals.sqf What it does: This is a specialized version of fn_compatibilityLoadFaction specifically for the Rivals faction. It loads the Rivals template, compiles groups, and registers units for the "Rivals" side (which is distinct from Occ/Inv/Reb).

How it does that:

Load Data:
Sets defaults and calls A3A_fnc_loadFaction.
Sets the prefix to "riv".
Compile Groups:
Calls A3A_fnc_compileGroups to generate _faction group arrays.
Define Unit Class Map:
Hardcodes a mapping of Rivals loadout names (e.g., militia_Cellleader) to specific Arma 3 base classes (e.g., O_G_Soldier_SL_F).
Register Units:
Iterates through the loadouts in the faction data.
For each, finds the corresponding class in the map and calls A3A_fnc_registerUnitType to create the global unit variables (e.g., riv_unitCellLeader).
Where it leads:

Called by:
Initialization logic when Rivals are enabled.
System Integration:
Allows the Rivals to spawn with custom loadouts (from the template) but ensures they are using valid Arma units (via the class map).
Function Name: fn_rhsModCompat.sqf What it does: This script filters the global loot arrays to ensure only RHS (Red Hammer Studios) author items are kept. It acts as a "whitelist" for attachments.

How it does that:

Filter Arrays:
Uses select and configfile >> "CfgWeapons" >> _x >> "author" to check the author of every item in lootAttachment, allLightAttachments, and allLaserAttachments.
Keeps only items where the author equals "Red Hammer Studios".
Sqf

Apply
lootAttachment = lootAttachment select {getText (configfile >> "CfgWeapons" >> _x >> "author") == "Red Hammer Studios"};
Where it leads:

Depends on:
Global arrays lootAttachment, etc., being populated first.
Called by:
Template initialization logic, likely after the main item lists are built.
System Integration:
Prevents "RHS Lite" setups (where only some RHS mods are loaded) from spawning invalid attachments (e.g., CUP attachments) if the template is intended for RHS.
Function Name: fn_TV_verifyAssets.sqf What it does: This is a debug/verification tool. It scans a loaded faction Hashmap to ensure that all classnames referenced (vehicles, weapons, magazines) actually exist in the game config. It prevents errors by catching typos or missing mods early.

How it does that:

Define Validators:
_fnc_validClassCaseSensitive: Checks if a class exists in CfgVehicles, CfgWeapons, etc., and ensures the case matches exactly.
_fnc_validateArrayOfClasses: Loops through an array and validates each entry.
_fnc_validateSingleClass: Validates one entry.
Iterate Faction Data:
Loops through every key/value pair in the _faction Hashmap.
Skips keys like loadouts or keys starting with unit/group.
Route Validation:
Uses switch logic to determine how to validate based on the key name (e.g., if key contains "vehicles", validate as array of classes; if "magazines", validate as hashmap).
Custom Logic:
Handles special keys like initialRebelEquipment (mixed items) or placeIntel_itemMedium (specific format).
Error Reporting:
If validation fails, it adds a message to _invalidReasons and logs an error.
Where it leads:

Called by:
fn_compatibilityLoadFaction (if __A3_DEBUG__ is defined).
System Integration:
Quality Control: Ensures that a template won't crash the server because a vehicle classname was spelled wrong or a mod is missing.
Function Name: fn_TV_verifyLoadout.sqf What it does: Validates a single unit loadout array (the format used by setUnitLoadout). It checks that weapons have compatible attachments, magazines fit in weapons, and all classnames exist.

How it does that:

Define Weapon Validators:
_fnc_validMuzzle, _fnc_validRail, _fnc_validOptic, _fnc_validBipod: These check if the attachment is allowed on the weapon. They retrieve the weapon's compatibleItems and compare it against the proposed attachment.
_fnc_validateWeaponMagazine: Checks if the magazine class exists and if the bullet count exceeds the magazine's capacity.
Validate Containers:
Checks Uniform, Vest, Backpack for valid classnames.
Checks contents of containers for valid items/magazines.
Validate Linked Items:
Checks GPS, Radio, Map, etc., for valid classnames.
Orchestration:
It runs the validators on the passed parameters (Primary weapon, Launcher, Uniform, etc.).
Returns [true, []] if valid, or [false, ["Error message"]].
Where it leads:

Called by:
fn_TV_verifyLoadoutsData.
System Integration:
Ensures that a specific loadout generated by the builder is actually usable in-game (e.g., you didn't put a 5.56 mag into a 7.62 gun).
Function Name: fn_TV_verifyLoadoutsData.sqf What it does: Iterates through all loadouts defined in a faction's loadouts Hashmap and runs fn_TV_verifyLoadout on every single generated loadout. It also verifies unit traits.

How it does that:

Iterate Loadouts:
_forEach loop over _faction get "loadouts".
Verify Loadouts:
Calls A3A_fnc_TV_verifyLoadout for each generated loadout in the array.
Verify Traits:
Checks the _traits array for validity (e.g., medic must be bool).
Handles special "baseClass" trait.
Log Errors:
Collects all errors and prints them at the end.
Where it leads:

Depends on:
A3A_fnc_TV_verifyLoadout.
Called by:
fn_compatibilityLoadFaction (debug mode).
System Integration:
The heavy lifter for loadout verification. It ensures the entire faction roster is valid.
Function Name: fn_loadout_addEquipment.sqf What it does: Adds standard gear (Radio, GPS, Map, Compass, Watch, NVG, Binoculars) to the loadout array.

How it does that:

Loop Equipment:
Iterates over the _equipment array passed to it.
Parse Item:
Checks if the item is a string (default item) or array ["RADIO", "TFAR_Radio"] (specific item).
Switch Slot:
switch (toUpper _type): Handles "GPS", "RADIO", etc.
Update Array: Modifies index 9 of the loadout array (Linked Items).
Index 9: [Map, GPS, Radio, Compass, Watch, NVG].
Binoculars: Handles Index 8 separately.
Where it leads:

Called by:
fn_loadout_builder (at the end of the build process).
System Integration:
Standardizes the "Utility" slot of a unit loadout.
Function Name: fn_loadout_addItems.sqf What it does: Fills a unit's containers (Uniform, Vest, Backpack) with items, respecting weight limits. It uses a "Batching" system to prioritize items (e.g., Medical > Ammo > Misc).

How it does that:

Process Batches:
Converts raw item lists into structured arrays with load calculations (_item select 2 = total load).
Calculate Free Space:
Calculates current load and max load for Uniform, Vest, and Backpack.
Trim Excess:
If the batch load exceeds available space, it enters a loop to remove items (starting from the lowest priority/most count) until it fits.
Distribute Items:
Iterates through the (potentially trimmed) items.
Distributes them to Uniform -> Vest -> Backpack based on available space.
Where it leads:

Depends on:
A3A_fnc_loadout_itemLoad: To calculate weight.
Called by:
fn_loadout_builder.
System Integration:
Load Management: Ensures units carry realistic amounts of gear. Prevents "Max Weight" errors in Arma.
Function Name: fn_loadout_additionalMuzzleMags.sqf What it does: Retrieves magazines for secondary muzzles of a weapon (e.g., GL, Underslung Shotgun).

How it does that:

Config Lookup:
Gets the weapon config >> "muzzles".
Filter Muzzles:
Removes the primary muzzle (index 0) to get secondary muzzles.
Extract Mags:
Loops through secondary muzzles and gets their magazines array.
Where it leads:

Called by:
fn_loadout_builder (when processing weapon magazines).
System Integration:
Ensures units get ammo for their underbarrel weapons.
Function Name: fn_loadout_builder.sqf What it does: This is the "Factory" that creates a loadout. It takes a template code and data, and produces a valid setUnitLoadout array.

How it does that:

Initialize Base:
Calls fn_loadout_createBase to get an empty loadout structure.
Define Builder Functions:
Creates local functions like _fnc_setPrimary, _fnc_setVest.
These functions take a key (e.g., "primaryWeapons"), look it up in _loadoutDataForTemplate, pick a random item, and call the corresponding fn_loadout_set... function.
Magazine Logic: As weapons are added, it stores the compatible magazines in variables (_primaryPrimaryMags) for later use.
Execute Template:
call _template: This executes the actual template code (e.g., _fnc_setPrimary "primaryWeapons").
Process Items & Mags:
It resolves the magazines required (based on _magazineCountForSlots).
It calls fn_loadout_addItems to fill the uniform/vest/backpack.
It calls fn_loadout_addEquipment to fill the utility slots.
Where it leads:

Depends on:
All fn_loadout_set... functions.
fn_loadout_addItems, fn_loadout_addEquipment.
Called by:
fn_loadFaction (during unit generation).
System Integration:
The core logic for creating the specific gear arrays.
Function Name: fn_loadout_createBase.sqf What it does: Returns a generic, empty loadout array structure.

How it does that:

Return Array:
Returns [[],[],[],[_uniform, []],[],[],"","",[],["","","","","",""]].
Indices: 0=Primary, 1=Launcher, 2=Handgun, 3=Uniform, 4=Vest, 5=Backpack, 6=Headgear, 7=Goggles, 8=Binocs, 9=LinkedItems.
Where it leads:

Called by:
fn_loadout_builder.
System Integration:
Standardized data format for Arma loadouts.
Function Name: fn_loadout_defaultWeaponMag.sqf What it does: Gets the default magazine classname and capacity for a specific weapon.

How it does that:

Config Lookup:
Reads configFile >> "CfgWeapons" >> _class >> "Magazines".
Filter:
Removes "CBA_FakeLauncherMagazine" if present.
Return:
Returns [_magazineType, count].
Where it leads:

Called by:
fn_loadout_builder (if no specific magazine is defined in the template).
System Integration:
Fallback mechanism for weapons.
Function Name: fn_loadout_itemLoad.sqf What it does: Calculates the "Mass" of a specific item entry to determine how much space it takes in a container.

How it does that:

Check Format:
Checks array size.
Size 2: Item [class, count].
Size 3: Magazine [class, count, ammo].
Size 7: Weapon [class, ...].
Lookup Mass:
Calls A3A_fnc_itemConfig and A3A_fnc_itemConfigMass to get the config value.
Calculate Total:
Multiplies single item mass by count.
Where it leads:

Depends on:
A3A_fnc_itemConfigMass.
Called by:
fn_loadout_addItems.
System Integration:
Math: Essential for the inventory management system.
Function Name: fn_loadout_setBackpack.sqf What it does: Sets the backpack slot (Index 5) in the loadout array.

How it does that:

Assignment:
_loadout set [5, [_backpack, _items]].
Where it leads:

Called by:
fn_loadout_builder.
System Integration:
Wrapper for array manipulation.
Function Name: fn_loadout_setFacewear.sqf What it does: Sets the facewear/goggles slot (Index 7).

How it does that:

Assignment:
_loadout set [7, _facewear].
Where it leads:

Called by:
fn_loadout_builder.
System Integration:
Wrapper for array manipulation.
Function Name: fn_loadout_setHelmet.sqf What it does: Sets the headgear slot (Index 6).

How it does that:

Assignment:
_loadout set [6, _helmet].
Where it leads:

Called by:
fn_loadout_builder.
System Integration:
Wrapper for array manipulation.
Function Name: fn_loadout_setUniform.sqf What it does: Sets the uniform slot (Index 3).

How it does that:

Assignment:
_loadout set [3, [_uniform, _items]].
Where it leads:

Called by:
fn_loadout_builder.
System Integration:
Wrapper for array manipulation.
Function Name: fn_loadout_setVest.sqf What it does: Sets the vest slot (Index 4).

How it does that:

Assignment:
_loadout set [4, [_vest, _items]].
Where it leads:

Called by:
fn_loadout_builder.
System Integration:
Wrapper for array manipulation.
Function Name: fn_loadout_setWeapon.sqf What it does: Sets a weapon (Primary, Launcher, or Handgun) in the loadout array and automatically populates the chambered magazine if missing.

How it does that:

Parse Input:
Accepts a string (class) or an array (class + attachments).
Converts to full array format [class, muzzle, pointer, optic, priMag, secMag, bipod].
Default Magazine:
If _priMag is empty, calls fn_loadout_defaultWeaponMag to get the default mag and sets it.
Slot Assignment:
Checks _slot string ("PRIMARY", "LAUNCHER", "HANDGUN") and sets Index 0, 1, or 2.
Where it leads:

Depends on:
fn_loadout_defaultWeaponMag.
Called by:
fn_loadout_builder.
System Integration:
Ensures weapons are valid and ready to fire.
Function Name: fn_itemset_medicalSupplies.sqf What it does: Returns an array of medical items based on the requested level ("Minimal", "Standard", "MEDIC") and the active modset (ACE or Vanilla).

How it does that:

Check Level:
Uses a switch statement on _level.
Check Modset:
Inside each case, checks A3A_hasACEMedical.
Return Arrays:
Returns the hardcoded list of ACE classnames or Vanilla classnames.
Where it leads:

Called by:
Scripts that spawn units or fill crates.
System Integration:
Centralizes medical item definitions to avoid duplication.
Function Name: fn_itemset_miscEssentials.sqf What it does: Returns an array of misc items (Earplugs, Maptools, Cableties) if ACE is loaded.

How it does that:

Check Mod:
Checks A3A_hasACE.
Append:
Pushes ACE items to a local array and returns it.
Where it leads:

Called by:
Loadout builders.
System Integration:
Adds basic utility gear to units.
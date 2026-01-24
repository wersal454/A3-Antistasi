fn_ACEpvpReDress.sqf
Function Name: 
fn_ACEpvpReDress.sqf

What it does: This function is responsible for adding basic ACE utility items and medical supplies to a player's equipment. It is specifically designed for PVP (Player vs. Player) scenarios or environments where standard loadout systems might not be fully enabled. It adds essential items like flares, flashlights, cable ties, and map tools to the player's vest or uniform. It also adds earplugs. Crucially, it then adjusts the medical kit contents based on whether the ACE Medical mod is active and whether the player is a designated medic.

How it does that: The function executes sequentially to modify the player's inventory directly.

Basic Utility Items: It uses a forEach loop with a hardcoded array of item classes and quantities.

Sqf

Apply
{
_item = _x select 0;
for "_i" from 1 to (_x select 1) do
    {
    player addItemToVest _item
    };
} forEach [["ACE_HandFlare_White",3],["ACE_Flashlight_XL50",1],["ACE_CableTie",1],["ACE_MapTools",1]];
Explanation: The loop iterates over the array [["ACE_HandFlare_White",3],...]. For each entry, it extracts the class name (_item) and the quantity (_x select 1). It then runs a for loop to add the item to the player's vest N times.
Earplugs: A single item is added to the uniform.

Sqf

Apply
player addItemToUniform "ACE_EarPlugs";
Explanation: Directly adds the earplug item to the uniform.
Medical Logic Check: The function checks if A3A_hasACEMedical is true.

Sqf

Apply
if (A3A_hasACEMedical) then
    {
    ...
    };
Explanation: If the ACE Medical system is detected, it proceeds to modify medical items. It first removes any existing vanilla medical items (FirstAidKit, Medikit) to prevent conflict.
Standard Soldier Medical: If the player is not a medic (!([player] call A3A_fnc_isMedic)), it adds a standard loadout to the uniform.

Sqf

Apply
{
_item = _x select 0;
for "_i" from 1 to (_x select 1) do
    {
    player addItemToUniform _item
    };
} forEach [["ACE_morphine",2],["ACE_epinephrine",2],["ACE_elasticBandage",10],["ACE_PackingBandage",15],["ACE_tourniquet",3],["ACE_splint",2]];
Explanation: Similar to the utility loop, this adds a specific set of basic trauma supplies (morphine, epinephrine, bandages, tourniquets, splints) to the uniform.
Medic Medical: If the player is a medic, it adds an expanded medical loadout to the backpack.

Sqf

Apply
{
_item = _x select 0;
for "_i" from 1 to (_x select 1) do
    {
    player addItemToBackpack _item
    };
} forEach [["ACE_morphine",5],["ACE_epinephrine",5],["ACE_adenosine",5],["ACE_bloodIV",4],["ACE_elasticBandage",20],["ACE_packingBandage",10],["ACE_tourniquet",5],["ACE_salineIV_250",2],["ACE_surgicalKit",1],["ACE_splint", 5]];
Explanation: This adds a heavier load of supplies, including IV bags and a surgical kit, filling the player's backpack.
Where it leads:

Calls: A3A_fnc_isMedic (Called to determine if the player unit has the medic trait).
Modifies: player inventory (adds items to Vest, Uniform, and Backpack).
Global Variables:
A3A_hasACEMedical: Read to determine if ACE Medical is active.
player: The local player object.
Dependencies: Relies on the ACE mod being loaded and the A3A_hasACEMedical variable being set correctly in the mission initialization.
System Fit: Part of the player initialization or loadout selection process. It ensures players in ACE-heavy environments have the necessary tools for survival, bypassing standard loadout scripts.
fn_allMagazines.sqf
Function Name: 
fn_allMagazines.sqf

What it does: Retrieves all unique magazines compatible with a given configuration class (either a vehicle or a weapon). It handles both direct magazine arrays and expanded magazine wells.

How it does that:

Parameter Validation:

Sqf

Apply
params ["_config"];
if (!isClass _config) exitWith { Error_1("Not a config: ", _config); [] };
Explanation: Checks if the input _config is a valid config class. If not, logs an error and returns an empty array.
Initialization:

Sqf

Apply
private _magazines = [];
private _magazineWells = [];
Explanation: Initializes two arrays: one for magazine class names and one for magazine well names.
Vehicle Processing Block:

Sqf

Apply
private _processVehicle = {
    if (isArray (_config/"magazines")) then {_magazines append getArray (_config/"magazines")};
    if (isArray (_config/"magazineWell")) then {_magazineWells append getArray (_config/"magazineWell")};

    {
        if (isArray (_x/"magazines")) then {_magazines append getArray (_x/"magazines")};
        if (isArray (_x/"magazineWell")) then {_magazineWells append getArray (_x/"magazineWell")};
    } forEach (configProperties [_config/"Turrets"]);
};
Explanation: This private function processes the vehicle config. It reads magazines and magazine wells from the root config and iterates through all turrets (using configProperties) to gather their compatible magazines as well.
Weapon Processing Block:

Sqf

Apply
private _processWeapon = {
    if (isArray (_config/"magazines")) then {_magazines append getArray (_config/"magazines")};
    if (isArray (_config/"magazineWell")) then {_magazineWells append getArray (_config/"magazineWell")};

    {
        if (_x isEqualTo "this") then {continue};
        if (isArray (_config/_x/"magazines")) then {_magazines append getArray (_config/_x/"magazines")};
        if (isArray (_config/_x/"magazineWell")) then {_magazineWells append getArray (_config/_x/"magazineWell")};
    } forEach (getArray (_config/"muzzles"));
};
Explanation: This private function processes weapon configs. It reads from the root and then iterates over the weapon's "muzzles" (including underbarrel gls) to find magazine definitions in sub-configs.
Routing Logic:

Sqf

Apply
if ((configFile/"cfgWeapons") in (configHierarchy _config)) then _processWeapon else _processVehicle;
Explanation: Determines if the config belongs to CfgWeapons or CfgVehicles and executes the corresponding processing function.
Expanding Magazine Wells:

Sqf

Apply
{
    {
        if (isArray _x) then { _magazines append getArray _x };
    } forEach configProperties [configFile/"cfgMagazineWells"/_x];
} forEach _magazineWells;
Explanation: Iterates through the collected magazine well names. For each well, it looks up the definition in CfgMagazineWells and appends the defined magazines to the main list.
Deduplication:

Sqf

Apply
_magazines arrayIntersect _magazines;
Explanation: Removes duplicate entries from the final _magazines array.
Where it leads:

Calls:
isArray, isClass, configProperties, getArray, configFile: Standard ArmA scripting commands.
Modifies: None.
Global Variables: None.
Dependencies: Relies on the game's configuration hierarchy (CfgWeapons, CfgVehicles, CfgMagazineWells).
System Fit: Used by arsenal management or item sorting functions to determine what ammunition a weapon or vehicle can accept.
fn_ammunitionTransfer.sqf
Function Name: 
fn_ammunitionTransfer.sqf

What it does: Transfers all unlocked weapons, magazines, items, and backpacks from a source container (_originX) to a destination container (_destinationX), respecting the arsenal unlock status. It optionally deletes the source container. This function is server-authoritative.

How it does that:

Execution Context & Locking:

Sqf

Apply
if (!isServer) exitWith {};
if (isNull _originX) exitWith {};
Explanation: Ensures the function runs only on the server. Checks if the source object exists.
Sqf

Apply
if (isNil { // Run in unschedule scope.
    if (_originX getVariable ["A3A_JNA_ammunitionTransfer_busy",false]) then {
        nil;  // will lead to exit.
    } else {
        _originX setVariable ["A3A_JNA_ammunitionTransfer_busy",true];
        0;  // not nil, will allow script to continue.
    };
}) exitWith {};  // Silent exit, likely due to spamming
Explanation: Implements a locking mechanism using the variable A3A_JNA_ammunitionTransfer_busy. If the source is already being transferred, the function exits silently to prevent race conditions or duplication.
Cargo Extraction:

Sqf

Apply
_ammunition= [];
_items = [];
_ammunition = magazineCargo _originX;
_items = itemCargo _originX;
_weaponsX = [];
_weaponsItemsCargo = weaponsItemsCargo _originX;
_backpcks = [];
Explanation: Uses commands like magazineCargo, itemCargo, and weaponsItemsCargo to extract raw data from the source container. _weaponsItemsCargo is an array of arrays containing the weapon and its attached items.
Backpack & Container Handling:

Sqf

Apply
if (count backpackCargo _originX > 0) then {
    {
        _backpcks pushBack (_x call A3A_fnc_basicBackpack);
    } forEach backpackCargo _originX;
};
Explanation: Iterates through backpacks in the cargo, calling A3A_fnc_basicBackpack to normalize the class name (likely handling specific backpack variants).
Sqf

Apply
_containers = everyContainer _originX;
if (count _containers > 0) then {
    for "_i" from 0 to (count _containers) - 1 do {
        _subObject = magazineCargo ((_containers select _i) select 1);
        // ... extraction logic for sub-containers ...
    };
};
Explanation: Recursively extracts content from nested containers (vests, backpacks) inside the source object and appends them to the main lists.
Weapon Item Decomposition:

Sqf

Apply
if (!isNil "_weaponsItemsCargo") then {
    if (count _weaponsItemsCargo > 0) then {
        {
            _weaponsX pushBack ([(_x select 0)] call BIS_fnc_baseWeapon);
            for "_i" from 1 to (count _x) - 1 do {
                _thingX = _x select _i;
                // ... handle items and magazines attached to weapons ...
            };
        } forEach _weaponsItemsCargo;
    };
};
Explanation: Iterates through the weapon arrays. It extracts the base weapon class and separates attached items/magazines back into the _items and _ammunition lists for individual transfer.
Unlocked Filtering & Transfer (Weapons):

Sqf

Apply
{
    _weaponX = _x;
    if ((!(_weaponX in _weaponsFinal)) && (!(_weaponX in unlockedWeapons))) then {
        _weaponsFinal pushBack _weaponX;
        _weaponsFinalCount pushBack ({_x == _weaponX} count _weaponsX);
    };
} forEach _weaponsX;
Explanation: Filters weapons. It only adds weapons to the final transfer list if they are not already in the final list and not currently unlocked in the arsenal. It also calculates the count.
Sqf

Apply
if (count _weaponsFinal > 0) then {
    for "_i" from 0 to (count _weaponsFinal) - 1 do {
        _destinationX addWeaponCargoGlobal [_weaponsFinal select _i,_weaponsFinalCount select _i];
    };
};
Explanation: Performs the actual global addition of weapons to the destination.
Unlocked Filtering & Transfer (Ammunition, Items, Backpacks):

Explanation: The logic is repeated for magazines (unlockedMagazines), items (unlockedItems), and backpacks (unlockedBackpacks). For each category, it filters out items that are already unlocked (assuming the arsenal acts as a source of infinite supply for those) and transfers the rest.
Cleanup & Notifications:

Sqf

Apply
if (count _this == 3) then {
    deleteVehicle _originX;
} else {
    clearMagazineCargoGlobal _originX; // ... clear cargo ...
};

if (_destinationX == boxX) then {
    // ... update arsenal logic ...
} else {
    [petros,"hint",localize "STR_hints_arsenal_transfer_success", ...] remoteExec ["A3A_fnc_commsMP",driver _destinationX];
};
Explanation: If a third argument is passed, it deletes the source. Otherwise, it empties it. It sends a notification to the driver of the vehicle or updates the main arsenal if the destination is the HQ box.
Unlocking:

Sqf

Apply
_updated = [] call A3A_fnc_arsenalManage;
Explanation: Calls fn_arsenalManage to check if the transferred items meet unlock thresholds.
Where it leads:

Calls:
A3A_fnc_basicBackpack: Normalizes backpack class names.
BIS_fnc_baseWeapon: Extracts the base weapon class from a weapon array.
A3A_fnc_arsenalManage: Updates unlock status.
A3A_fnc_commsMP: Sends notifications to players.
Modifies:
_destinationX (adds cargo).
_originX (clears or deletes cargo).
unlockedWeapons, unlockedMagazines, etc. (indirectly via arsenalManage).
Global Variables:
unlockedWeapons, unlockedMagazines, unlockedItems, unlockedBackpacks: Read for filtering.
boxX: Checked against destination.
Dependencies: Requires the unlocked* arrays to be populated. Runs on server only.
System Fit: Core mechanic for looting and managing supplies. It enforces the "Unlock" system by not transferring items that are already available in the arsenal.
fn_arsenalManage.sqf
Function Name: 
fn_arsenalManage.sqf

What it does: Manages the mission's arsenal unlock system. It checks the cargo in boxX (the HQ arsenal), compares item counts against minWeaps (the unlock threshold), and unlocks items that meet the criteria. It also handles special logic for NVGs and guided launchers.

How it does that:

Initialization & Context Check:

Sqf

Apply
if (!isServer) exitWith {};
private _updated = "";
[boxX] call jn_fnc_arsenal_cargoToArsenal;
if (minWeaps < 0) exitWith {""};
Explanation: Ensures server execution. Initializes a string to track unlocked items. Calls jn_fnc_arsenal_cargoToArsenal (part of the JNA - Joint Non-Additive Arsenal) to scan boxX and populate jna_dataList. Checks if unlock threshold is valid.
Data Extraction & Filtering:

Sqf

Apply
private _weapons = ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON) + ... ) select {_x select 1 != -1};
Explanation: Extracts data for weapons, explosives, magazines, etc., from jna_dataList using predefined IDC constants. Filters to keep only items with a count (_x select 1) greater than -1 (where -1 denotes unlimited/already unlocked items in the JNA system).
Magazine Capacity Logic:

Sqf

Apply
{
    _type = _x select 0;
    _magConfig = configFile >> "CfgMagazines" >> _type;
    _capacity = 1 max getNumber (_magConfig >> "count");

    if (_capacity != 1 || allowGuidedLaunchers isEqualTo 1 || {!(getText (_magConfig >> "ammo") isKindOf "MissileBase")}) then {
        _bullets = _x select 1;
        _count = floor (_bullets/_capacity);
        _magazine pushBack [_type,_count];
    };
} forEach _magazines;
Explanation: Loops through magazines. It calculates the total number of full magazines based on bullet count and mag capacity. It has a special check: if the magazine is for a guided missile and allowGuidedLaunchers is 0, it prevents unlocking. (This prevents infinite missile spam unless enabled).
Unlocking Loop:

Sqf

Apply
private _allExceptNVs = _weapons + _explosives + _backpacks + ...;
private _categoriesToPublish = createHashMap;

{
    call {
        if (_x select 1 < minWeaps) exitWith {}; // Check count vs threshold
        private _item = _x select 0;
        // ... Forbidden item checks (A3U_forbiddenItems) ...

        private _categories = _item call A3A_fnc_equipmentClassToCategories;
        if ("MissileLaunchers" in _categories && {allowGuidedLaunchers == 0}) exitWith {};
        // ... other category checks ...

        [_item, true] call A3A_fnc_unlockEquipment; // UNLOCK
        _categoriesToPublish insert [true, _categories, []];

        // Update description string
        _updated = format ["%1%2<br/>",_updated,_name];

        // Special Ammo Unlocking
        if (unlockedUnlimitedAmmo == 1 && ("Weapons" in _categories)) then {
            // ... unlock primary weapon magazine ...
        };
    };
} forEach _allExceptNVs;
Explanation: Iterates through all eligible items. If the count meets minWeaps, it validates the item (forbidden lists, category restrictions). It calls A3A_fnc_unlockEquipment to unlock the item and adds the category to a hashmap for later publishing. It also handles the "unlimited ammo" setting by unlocking the weapon's default magazine.
NVG Specific Logic:

Sqf

Apply
private _totalNV = 0;
private _sortedNVs = [];
{
    private _amount = (_x select 1);
    private _thermal = getArray (configFile >> "CfgWeapons" >> (_x select 0) >> "thermalMode");
    if (amount > 0 && ((thermal isEqualTo []) or (allowUnlockedTNVG isEqualTo 1))) then {
        _totalNV = _totalNV + _amount;
        _sortedNVs pushBack [_amount, _x select 0];
    };
} forEach _nv;
_sortedNVs sort true;
Explanation: Aggregates NVG counts. It filters out thermal NVGs unless allowUnlockedTNVG is enabled. It sorts NVGs by quantity (ascending).
Sqf

Apply
while {_totalNV >= minWeaps} do {
    private _nvToUnlock = (_sortedNVs deleteAt (count _sortedNVs - 1)) select 1;
    private _categories = [_nvToUnlock, true] call A3A_fnc_unlockEquipment;
    // ... update text ...
    _totalNV =_totalNV - minWeaps;
};
Explanation: Unlocks NVGs from highest count downwards. It deducts minWeaps from the total count for each unlocked NVG type.
Publicizing:

Sqf

Apply
{ publicVariable ("unlocked" + _x) } forEach keys _categoriesToPublish;
Explanation: Publicizes the modified unlocked* arrays to all clients via publicVariable.
Where it leads:

Calls:
jn_fnc_arsenal_cargoToArsenal: External function to scan cargo.
A3A_fnc_equipmentClassToCategories: Determines item type (Rifle, Vest, etc.).
A3A_fnc_unlockEquipment: Performs the actual unlocking.
BIS_fnc_sortBy: Used implicitly or explicitly for sorting.
Modifies:
unlockedWeapons, unlockedMagazines, etc. (via fn_unlockEquipment).
publicVariable transmits these changes.
Global Variables:
minWeaps: Threshold for unlocking.
jna_dataList: Source of truth for cargo counts.
allowGuidedLaunchers, allowUnlockedTNVG, unlockedUnlimitedAmmo: Configuration flags.
Dependencies: Relies on the JNA system and the unlocked variables being initialized.
System Fit: The core economy of the arsenal. It transforms physical items in the box into permanent unlocks for the faction.
fn_categoryOverrides.sqf
Function Name: 
fn_categoryOverrides.sqf

What it does: Initializes a static lookup table (A3A_categoryOverrides) that manually assigns specific item class names to specific categories, overriding the automatic detection logic. This is used for items that are misclassified by the engine or have non-standard configurations (e.g., specific mod weapons).

How it does that:

Data Definition:

Sqf

Apply
private _categoryOverrideTable = [
["rhs_weap_vss", ["SniperRifles","Weapons"]],
["rhs_weap_vss_grip", ["SniperRifles","Weapons"]],
// ... hundreds of entries ...
["SPE_M1_Garand_M7", ["Rifles","Weapons","GrenadeLaunchers"]]
];
Explanation: Defines a massive array of arrays. Each entry maps a class name to a list of categories (e.g., ["Rifles", "Weapons"]).
Namespace Initialization:

Sqf

Apply
A3A_categoryOverrides = false call A3A_fnc_createNamespace;
Explanation: Creates a mission namespace object to store the overrides, ensuring a clean key-value structure.
Population:

Sqf

Apply
{
    A3A_categoryOverrides setVariable [_x select 0, _x select 1];
} forEach _categoryOverrideTable;
Explanation: Iterates through the table, setting the variable on the namespace where the key is the class name and the value is the category array.
Where it leads:

Calls:
A3A_fnc_createNamespace: Creates the storage object.
Modifies:
A3A_categoryOverrides: A global namespace variable.
Global Variables: A3A_categoryOverrides.
Dependencies: None (runs on preInit or initialization).
System Fit: Used by fn_equipmentClassToCategories. Before attempting automatic categorization, the system checks this override table. If the item is found, it uses these categories immediately.
fn_checkRadiosUnlocked.sqf
Function Name: 
fn_checkRadiosUnlocked.sqf

What it does: Checks if the faction has unlocked any radios in the arsenal and updates the global haveRadio variable. It handles ACRE mod detection specially.

How it does that:

ACRE Special Handling:

Sqf

Apply
if (A3A_hasACRE) then {
    haveRadio = true;
} else {
    // Standard check
};
Explanation: If ACRE (a radio mod) is detected, it immediately sets haveRadio to true, as ACRE radios are generally considered always available in this context.
Standard Radio Check (TFAR/Vanilla):

Sqf

Apply
haveRadio = (((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_RADIO) findIf {_x select 1 == -1}) > -1);
Explanation: Accesses the JNA data list for the Radio tab. findIf searches for an entry where the count is -1 (unlimited). If found (> -1), haveRadio is set to true.
Synchronization:

Sqf

Apply
publicVariable "haveRadio";
haveRadio;
Explanation: Broadcasts the updated value to all clients and returns the value locally.
Where it leads:

Calls:
None (directly accesses jna_dataList).
Modifies:
haveRadio (Global).
Global Variables:
A3A_hasACRE: Read for mod detection.
jna_dataList: Read for radio unlock status.
Dependencies: Relies on the JNA system and A3A_hasACRE being set.
System Fit: Used to toggle UI elements or actions that require radio communication. Ensures non-ACRE factions have actually unlocked radios before gaining access to radio-based features.
fn_compatibleMagazinesWithExceptions.sqf
Function Name: 
fn_compatibleMagazinesWithExceptions.sqf

What it does: Returns an array of all magazines compatible with a specific weapon, while excluding a provided list of forbidden magazines (e.g., _forbiddenList).

How it does that:

Parameter Validation:

Sqf

Apply
params [
    ["_weapon","",[""]],
    ["_forbiddenList",[],[[]]],
    ["_showHidden",false,[false]]
];
Explanation: Sets default values. If no weapon is provided, it exits or handles gracefully.
Config Lookup:

Sqf

Apply
private _weaponCfg = configFile >> "CfgWeapons" >> _weapon;
if (isClass _weaponCfg) then { ... };
Explanation: Verifies the weapon config exists.
Muzzle Iteration:

Sqf

Apply
{
    _muzzle = if (_x == "this") then {_weaponCfg} else {_weaponCfg >> _x};
    ...
} foreach getarray (_weaponCfg >> "muzzles");
Explanation: Loops through all muzzles of the weapon (main barrel and underbarrel GLs).
Magazine Extraction:

Sqf

Apply
_magazinesList = getarray (_muzzle >> "magazines");
{
    {
        _magazinesList append (getArray _x);
    }foreach  configproperties [configFile >> "CfgMagazineWells" >> _x,"isArray _x"];
} foreach getArray (_muzzle >> "magazineWell");
Explanation: Appends magazines defined directly in the muzzle config and those referenced via magazineWell arrays.
Filtering & Deduplication:

Sqf

Apply
{
    private _magazine = _x;
    private _magazineCfg = configfile >> "cfgMagazines" >> _magazine;

    if ( ((getnumber (_magazineCfg >> "scope") isEqualTo 2) || _showHidden) && !(_magazine in _forbiddenList) ) then {
        _compatibleMagazines pushBackUnique _magazine;
    };
} foreach _magazinesList;
Explanation: Checks scope (must be 2, unless hidden allowed) and ensures the magazine is not in the _forbiddenList. pushBackUnique prevents duplicates.
Where it leads:

Calls:
configFile, getArray, configProperties: Standard config parsing.
Modifies: None.
Global Variables: None.
Dependencies: Relies on CfgWeapons and CfgMagazines.
System Fit: Used by loot generation or arsenal logic to determine what ammunition a weapon can accept, specifically filtering out items that shouldn't be available (e.g., specific ammo types in restricted modsets).
fn_configSort.sqf
Function Name: 
fn_configSort.sqf

What it does: Scans the entire game configuration (modded and vanilla) to categorize items (weapons, mags, backpacks, glasses) into global arrays (e.g., allRifles, allBackpacks). It applies filters for disabled mods, forbidden assets (e.g., Cold War only), and scope.

How it does that:

Config Collection:

Sqf

Apply
private _allWeaponConfigs = "getNumber (_x >> 'scope') == 2 ... " configClasses (configFile >> "CfgWeapons");
Explanation: Uses config classes to gather all weapons with scope 2 that have a picture and aren't vehicle weapons (type 65536). Similar queries for Magazines, Vehicles (Backpacks), and Glasses.
Base Weapon Filtering (Weapons):

Sqf

Apply
private _fnc_baseWeapon = { ... };
private _allBaseWeapons = _allWeaponConfigs apply { _x call _fnc_baseWeapon };
private _baseWeaponHM = _allBaseWeapons createHashMapFromArray [];
_allWeaponConfigs = keys _baseWeaponHM apply { configFile >> "CfgWeapons" >> _x };
Explanation: A private function _fnc_baseWeapon determines the base class (stripping attachments). It uses a hashmap to ensure only unique base weapons are processed, ignoring variants with different scopes/suppressors.
Cold War Filter (Optional):

Sqf

Apply
if ("coldWar" in A3A_factionEquipFlags) then {
    private _forbiddenAssets = [ ... ]; // Huge list of modern gear
    {
        private _forbiddenItem = _x;
        private _index = _allConfigs findIf {(configName _x) == _forbiddenItem};
        if (_index != -1) then {
            _allConfigs deleteAt _index;
        };
    } forEach _forbiddenAssets;
};
Explanation: If the mission is set to Cold War, it iterates through a hardcoded list of modern class names and removes them from the _allConfigs array.
Sorting Loop:

Sqf

Apply
{
    _nameX = configName _x;
    _itemMod = _x call A3A_fnc_getModOfConfigClass;
    if (_itemMod in A3A_disabledMods) then { continue };
    ...
    _categories = [_nameX, _itemType] call A3A_fnc_equipmentClassToCategories;
    {
        (missionNamespace getVariable ("all" + _x)) pushBack _nameX;
    } forEach _categories;
} forEach _allConfigs;
Explanation: Loops through valid configs. Checks if the mod is disabled. Determines categories using fn_equipmentClassToCategories and pushes the class name into the appropriate global all* array (e.g., allRifles).
Where it leads:

Calls:
A3A_fnc_getModOfConfigClass: Identifies the mod the item comes from.
A3A_fnc_itemType: Determines item type (Weapon/Magazine/etc).
A3A_fnc_equipmentClassToCategories: Categorizes the item.
Modifies:
Global arrays: allRifles, allBackpacks, allMagBullet, etc.
Global Variables:
A3A_disabledMods: List of mods to ignore.
A3A_factionEquipFlags: Flags like "coldWar".
Dependencies: Runs during initialization to populate the item pools.
System Fit: The foundational step for the loot and unlock system. It builds the master lists of all available items in the game, which are then filtered by availability.
fn_dress.sqf
Function Name: 
fn_dress.sqf

What it does: Applies a specific loadout to a unit. It is primarily used for civilian or rebel unit dressing, ensuring they have basic utility items (map, compass, watch) and appropriate headgear/uniforms.

How it does that:

Parameter & Context:

Sqf

Apply
params ["_unit"];
private _loadoutOverride = param [1];
Explanation: Accepts the unit to dress.
Loadout Construction (Civilian/Rebel):

Sqf

Apply
_loadout = switch (side group _unit) do {
    case teamPlayer: {
        if (toLowerANSI worldName isEqualTo "enoch") then {
            // Specific logic for Livonia map (ENoch)
        } else {
            // Standard logic
        };
    };
    default { [] };
};
Explanation: Checks the unit's side. For teamPlayer (rebels), it constructs a loadout array.
Item Selection:

Sqf

Apply
[selectRandom (FactionGet(civ,"uniforms") + FactionGet(reb,"uniforms")), []]
Explanation: Selects a random uniform from either civilian or rebel factions.
Utility Assignment:

Sqf

Apply
[(selectRandom unlockedmaps),"","",(selectRandom unlockedCompasses),(selectRandom unlockedwatches),""]
Explanation: Populates the specific slots (Map, Compass, Watch) by selecting from the unlocked arrays.
Application:

Sqf

Apply
_unit setUnitLoadout _loadout;
_unit selectWeapon (primaryWeapon _unit);
Explanation: Applies the constructed loadout and attempts to select the primary weapon.
Where it leads:

Calls:
FactionGet: Retrieves faction-specific items (uniforms, headgear).
selectRandom: Picks random items from arrays.
Modifies:
_unit (loadout, weapon selection).
Global Variables:
unlockedmaps, unlockedCompasses, unlockedwatches: Used for utility items.
Dependencies: Relies on unlocked arrays and faction definitions.
System Fit: Used for spawning civilian units or rebel recruits to ensure they are equipped with basic navigational tools and appropriate clothing.
fn_empty.sqf
Function Name: 
fn_empty.sqf

What it does: Transfers cargo from a nearby vehicle or crate to the HQ box (boxX). It handles money distribution to players if found in the cargo. It is a user-facing action script.

How it does that:

Target Selection:

Sqf

Apply
if (count _this > 0) then {
    _truckX = _this select 0;
} else {
    // Find nearest vehicle/crate
    private _trucksX = nearestObjects [boxX, ["Helicopter","Plane","LandVehicle","ReammoBox_F"], 20];
    // ... filtering logic ...
};
Explanation: If a target is passed as an argument, use it. Otherwise, search 20 meters around boxX for valid transfer targets (excluding static weapons and UAVs).
Money Distribution:

Sqf

Apply
{
    if(_x in arrayMoney) then {
        // ... calculate index and amount ...
        _moneyEarned = _moneyEarned + (arrayMoneyAmount select _moneyIndex);
    };
} forEach _ammunition;

if(_moneyEarned > 0) then {
    // ... split _moneyEarned among all players ...
    [_incomePerPlayer,_x] call A3A_fnc_addMoneyPlayer;
};
Explanation: Scans the magazine cargo for items listed in arrayMoney (money class names). Calculates the total value and distributes it evenly among all online players using A3A_fnc_addMoneyPlayer.
Transfer Initiation:

Sqf

Apply
if (count _this == 2) then {
    [_truckX,boxX,true] remoteExec ["A3A_fnc_ammunitionTransfer",2];
} else {
    [_truckX,boxX] remoteExec ["A3A_fnc_ammunitionTransfer",2];
};
Explanation: Calls fn_ammunitionTransfer on the server. The true argument indicates the source should be deleted after transfer.
Notifications:

Sqf

Apply
[localize "STR_A3A_ammunition_transfer_header", format [localize "STR_A3A_ammunition_transfer_veh_empty", _vehName]] call A3A_fnc_customHint;
Explanation: Notifies the player of the result (success or empty vehicle).
Where it leads:

Calls:
A3A_fnc_addMoneyPlayer: Distributes money to players.
A3A_fnc_ammunitionTransfer: Performs the actual cargo move.
A3A_fnc_customHint: Displays UI message.
Modifies:
Player money.
Cargo of boxX and target vehicle.
Global Variables:
boxX: The HQ arsenal.
arrayMoney, arrayMoneyAmount: Money definitions.
Dependencies: Requires boxX and player list.
System Fit: Action script attached to vehicles/ammoboxes to allow players to dump loot into the HQ.
fn_equipmentClassToCategories.sqf
Function Name: 
fn_equipmentClassToCategories.sqf

What it does: Categorizes an item class name into specific logical groups (e.g., "Rifles", "Vests", "OpticsLong") used by the unlock and loot systems. It uses a hardcoded override table and automatic config parsing.

How it does that:

Override Check:

Sqf

Apply
private _categories = A3A_categoryOverrides getVariable [_className, []];
if (count _categories > 0) exitWith { _categories };
Explanation: Checks fn_categoryOverrides first. If the item is found there, it returns those categories immediately.
Automatic Classification:

Type Identification: If not in overrides, it calls A3A_fnc_itemType to get the basic type (e.g., ["Item", "AccessorySights"]).
Base Category: A switch statement maps the item subtype to a base category (e.g., "AccessorySights" -> "Optics").
Aggregate Category: It determines the broad category (Weapon, Item, Magazine) based on the primary type.
Specific Logic Blocks (Call Blocks):

Sqf

Apply
call {
    if (_baseCategory isEqualTo "Rifles") exitWith {
        private _config = configfile >> "CfgWeapons" >> _className;
        private _muzzles = getArray (_config >> "muzzles");
        if (count _muzzles >= 2 && {"gl" == getText (_config >> (_muzzles select 1) >> "cursorAim")}) then {
            _categories pushBack "GrenadeLaunchers";
        };
    };
    // ... similar blocks for Vests (Armor check), Headgear (Armor check), Optics (Zoom/Range check) ...
    if (_baseCategory isEqualTo "RocketLaunchers") exitWith {
        _categories pushBack "AT";
        // ... disposable check ...
    };
};
Explanation: Applies advanced logic based on the base category.
Rifles: Checks for underbarrel GLs.
Vests/Headgear: Checks armor values to assign "Armored" subtypes.
Optics: Checks zoom levels and ranging capability to assign "Close", "Mid", or "Long" range categories.
Launchers: Checks if disposable and assigns "AT" or "AA" based on ammo type.
Caching:

Sqf

Apply
A3A_categoryOverrides setVariable [_classname, _categories];
_categories;
Explanation: Saves the result to the overrides namespace (caching) to speed up future calls for the same item.
Where it leads:

Calls:
A3A_fnc_itemType: Gets basic item info.
A3A_categoryOverrides: Checks/sets cache.
Modifies:
A3A_categoryOverrides (caching).
Global Variables: None.
Dependencies: Requires config access.
System Fit: The decision engine for the entire inventory system. It answers "What is this item?" so other systems know how to handle it.
fn_equipmentIsValidForCurrentModset.sqf
Function Name: 
fn_equipmentIsValidForCurrentModset.sqf

What it does: Determines if an item should be available given the current mission settings (e.g., "Low Tech", "Vanilla", "Cold War"). It filters out items that don't fit the theme.

How it does that:

Hardcoded Checks:

Sqf

Apply
if (_configClass in A3U_forbiddenItems && {getNumber (...) isEqualTo 0}) exitWith { false };
Explanation: Checks a master forbidden list (A3U_forbiddenItems) used by mission creators to block specific items entirely.
Special Modset Logic (GM/Cold War):

Sqf

Apply
if ("specialGM" in A3A_factionEquipFlags) exitWith {
    if (_itemMod == "gm") exitWith {true};
    // ... whitelist of allowed items ...
};
Explanation: If the "GM" (Global Mobilization) special flag is active, it only allows GM mod items or a hardcoded whitelist of specific vanilla/other items (e.g., demo charges).
Low Tech Logic:

Sqf

Apply
if ("lowTech" in A3A_factionEquipFlags) exitWith {
    switch (_itemType select 0) do {
        case "Item": {
            // Block optics, lasers, GPS, etc.
        };
        case "Weapon"; case "Equipment"; ... { false };
    };
};
Explanation: If "Low Tech" is active, it blocks almost all modern accessories (Optics, Pointers), GPS, NVGs, and restricts weapon/magazine availability, forcing a primitive loadout.
Vanilla Logic:

Sqf

Apply
if !("vanilla" in A3A_factionEquipFlags) exitWith {
    // Block vanilla attachments and heavily armored vests/helmets
};
Explanation: If the modset is not flagged as "Vanilla" (implying a modset like CUP/RHS is active), it blocks standard Arma 3 gear to prevent anachronisms.
Default Pass:

Sqf

Apply
true;
Explanation: If no specific restrictions apply, the item is valid.
Where it leads:

Calls: None (uses passed parameters and global variables).
Modifies: None.
Global Variables:
A3U_forbiddenItems: Global blacklist.
A3A_factionEquipFlags: Mission settings flags.
A3A_vanillaMods, A3A_extraEquipMods: Mod identification lists.
Dependencies: Relies on correctly set mission flags and lists.
System Fit: Used by fn_configSort and fn_fillLootCrate to filter the global item lists based on the mission's theme/tech level.
fn_equipmentSort.sqf
Function Name: 
fn_equipmentSort.sqf

What it does: Post-processes the global arrays (like allBackpacks, allVests) generated by fn_configSort. It splits them into subcategories (e.g., separating armored vests from civilian vests) and cleans up invalid entries.

How it does that:

Backpack Sorting:

Sqf

Apply
{
    private _itemFaction = getText (configfile >> "CfgVehicles" >> _x >> "faction");
    switch (_itemFaction) do {
        case "Default": {allBackpacksEmpty pushBack _x};
        default {allBackpacksTool pushBack _x};
    };
} forEach allBackpacks;
Explanation: Splits backpacks into allBackpacksEmpty (gear) and allBackpacksTool (assembly packs/static weapon bases).
Sqf

Apply
{
    switch (true) do {
        case ((getText (configfile >> "CfgVehicles" >> _x >> "assembleInfo" >> "assembleTo")) != ""): { ... };
        // ... logic for static vs device ...
    };
} forEach allBackpacksTool;
Explanation: Further sorts tool backpacks into allBackpacksStatic (buildables) and allBackpacksDevice (UAVs, etc).
Vest & Headgear Sorting:

Sqf

Apply
allCivilianVests = allVests - allArmoredVests;
allCosmeticHeadgear = allHeadgear - allArmoredHeadgear;
Explanation: Uses array subtraction to separate armored gear from cosmetic gear.
Special Mod Cleanup:

Sqf

Apply
if ("specialVN" in A3A_factionEquipFlags) then {
    {
        allCosmeticHeadgear deleteAt (allCosmeticHeadgear find _x);
    } forEach [ ... list ... ];
};
Explanation: If specific modsets (like Sog Africa/Vietnam) are active, it removes specific cosmetic items from the pools to maintain immersion.
Radio & NVG Logic:

Sqf

Apply
// TFAR Encryption Code Filtering
allRadios = _allRadioItems select { getText (configFile >> "CfgWeapons" >> _x >> "tf_encryptionCode") in _encryptRebel };
// NVG Scope Check
allNVGs = allNVGs select { getarray (configFile >> "CfgWeapons" >> _x >> "visionMode") isnotequalto ["Normal","Normal"]};
Explanation: Filters TFAR radios by encryption code (so enemies don't share comms). Filters NVGs to remove "fake" NVGs that just have normal vision mode.
Default Item Removal:

Sqf

Apply
private _removableDefaultItems = [ ... ];
{
    _x params ["_itemCategoryArray","_vanillaItem","_templateVariable"];
    private _allowedItems = A3A_fction_reb get _templateVariable;
    if !(_vanillaItem in _allowedItems) then {
        _itemCategoryArray deleteAt (_itemCategoryArray find _vanillaItem);
    };
} forEach _removableDefaultItems;
Explanation: Checks faction templates. If the template doesn't allow the vanilla "FirstAidKit" or "ItemMap", it is removed from the global list so it won't appear in loot or arsenals.
Where it leads:

Calls:
A3A_faction_reb: Reads rebel faction settings.
Modifies:
Global arrays: allBackpacksEmpty, allBackpacksStatic, allCivilianVests, allRadios, etc.
Global Variables:
A3A_factionEquipFlags: Mission settings.
Dependencies: Requires all* arrays to be populated by fn_configSort.
System Fit: Refines the raw item lists into functional pools for loot generation and AI equipment.
fn_fetchRebelGear.sqf
Function Name: 
fn_fetchRebelGear.sqf

What it does: Requests the A3A_rebelGear hashmap from the server (if out of date) and initializes local cache variables for optics, flashlights, lasers, silencers, and bipods.

How it does that:

Version Check:

Sqf

Apply
if (!isNil "A3A_rebelGear" and { A3A_rebelGear get "Version" == A3A_rebelGearVersion}) exitWith {};
Explanation: Checks if the local version matches the global version. If so, it exits immediately.
Data Transfer:

Sqf

Apply
Info("Fetching new version of rebelGear data...");
[clientOwner, "A3A_rebelGear"] remoteExecCall ["publicVariableClient", 2];
waitUntil { sleep 1; !isNil "A3A_rebelGear" and { A3A_rebelGear get "Version" == A3A_rebelGearVersion } };
Explanation: Asks the server (owner ID 2) to send the A3A_rebelGear variable to this client. Waits in a loop until received.
Cache Initialization:

Sqf

Apply
A3A_rebelOpticsCache = createHashMap;
A3A_rebelFlashlightsCache = createHashMap;
// ... etc ...
Explanation: Creates empty hashmaps to store per-weapon compatibility data locally (to avoid recalculating compatible items every time).
Where it leads:

Calls:
remoteExecCall: Network request.
Modifies:
A3A_rebelGear (local).
A3A_rebelOpticsCache (local).
Global Variables:
A3A_rebelGearVersion: The master version number.
Dependencies: Requires the server to have generated A3A_rebelGear (via fn_generateRebelGear).
System Fit: Synchronizes the AI gear configuration from the server to clients, ensuring consistency.
fn_fillLootCrate.sqf
Function Name: 
fn_fillLootCrate.sqf

What it does: Populates a given crate with random loot based on configured limits (types and quantities). It selects items that are not currently unlocked to encourage crate looting.

How it does that:

Setup & Scaling:

Sqf

Apply
params [ "_crate", ... ];
if (!isServer && hasInterface) exitWith { ... remoteExec ... }; // Force server execution
private _quantityScalingFactor = 1 / (1 + _playerCount / 20); // Scale loot based on player count
Explanation: Ensures the script runs on the server. Calculates a scaling factor to reduce loot density in high-population missions.
Loot Selection Logic:

Weapons: Uses selectRandomWeighted on weapon pools (Rifles, MGs, Launchers) based on weights.
Filtering: Calls _fnc_pickRandomFromAProbablyNotInB which tries to pick an item from the all list that is not in the unlocked list. If all items are unlocked, it falls back to a random item.
Magazines: Finds compatible magazines for the selected weapon using A3A_fnc_compatibleMagazinesWithExceptions.
Amount Calculation:

Sqf

Apply
private _fnc_pickAmount = {
    params ["_max"];
    if (_max * _quantityScalingFactor < 1) then { round random 1 } else { round (random [1, floor (_max/2), _max] * _quantityScalingFactor) };
};
Explanation: Uses a Gaussian distribution (random [min, mid, max]) to determine how many of an item to spawn, scaled by the population factor.
Adding Cargo:

Sqf

Apply
_crate addWeaponWithAttachmentsCargoGlobal [[ _loot, "", "", "", [], [], ""], _amount];
_crate addMagazineCargoGlobal [_magazine, _magAmount];
Explanation: Adds the selected items to the crate. Weapons are added stripped of attachments (empty strings/arrays) to save complexity, or with a random default config.
Category Loops:

The function repeats this logic for: Ammo, Explosives, Attachments, Backpacks, Helmets, Vests, and Devices.
It specifically excludes items in A3U_forbiddenItems.
Where it leads:

Calls:
A3A_fnc_compatibleMagazinesWithExceptions: Finds ammo for weapons.
A3A_fnc_itemArrayWeight: Determines preference weight for items.
Modifies:
_crate (adds cargo).
Global Variables:
unlockedWeapons, etc.: Used to filter loot (items not yet unlocked are preferred).
A3U_forbiddenItems: Used to block specific items.
lootWeapon, lootMagazine, etc.: Master loot pools.
Dependencies: Requires loot pools to be initialized (fn_loot) and unlocked arrays populated.
System Fit: Generates rewards for missions (crates, wreckage).
fn_generateRebelGear.sqf
Function Name: 
fn_generateRebelGear.sqf

What it does: Creates the A3A_rebelGear hashmap, which serves as the master reference for AI loadout generation. It calculates weights for items based on stats (accuracy, damage, weight) and determines availability based on unlocks.

How it does that:

Initialization:

Sqf

Apply
private _rebelGear = createHashMapFromArray [ ... ];
Explanation: Creates a hashmap with empty arrays for categories (Rifles, Optics, Vests, etc.).
JNA Data Iteration:

Sqf

Apply
{
    {
        _x params ["_class", "_amount"];
        private _categories = _class call A3A_fnc_equipmentClassToCategories;
        // ... switch on main category ...
    } forEach (jna_datalist select _x);
} forEach [ IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON, ... ];
Explanation: Iterates through the JNA data list (which contains items and their counts in the arsenal). For each item:
It categorizes it.
It checks if magazines are available for weapons (via fn_getAvailableMagazines).
It calculates a "weight" using fn_itemArrayWeight (better stats = higher weight).
Item Weighting & Storage:

Sqf

Apply
[_array, _class, _amount, _arrayWeight] call _fnc_addItem;
Explanation: Adds the item to the appropriate array in the hashmap. The item is added as [ClassName, Weight]. The weight is based on:
Amount: Items with more stock in the arsenal are weighted higher (more likely to be used).
Stats: Weapons with higher accuracy/impact/ROF get higher weights.
Unlock Status: If minWeaps < 0 (disabled unlocks), it uses a weighting function. If unlocks are active, it checks if the item is unlocked.
Optics Mixing:

Sqf

Apply
// ... logic to mix short-range optics into the mid-range pool if mid-range optics are scarce ...
Explanation: Ensures AI has something to put on their guns even if high-end optics aren't unlocked yet.
Normalization & Publishing:

Sqf

Apply
// Normalize weights so they sum to 1 (for selectRandomWeighted)
_rebelGear set [_x, _array apply {if (_x isEqualType 1) then {_x / _totalWeight} else {_x}}];
// Update global
isNil { A3A_rebelGear = _rebelGear; A3A_rebelGearVersion = time; };
publicVariable "A3A_rebelGearVersion";
Explanation: Converts raw weights into probabilities (0.0 to 1.0). Updates the global variable and broadcasts the new version number to trigger client updates.
Where it leads:

Calls:
A3A_fnc_equipmentClassToCategories: Categorizes items.
A3A_fnc_itemArrayWeight: Calculates statistical preference.
A3A_fnc_getAvailableMagazines: Checks ammo availability.
A3A_fnc_generateRebelGear: (Recursively called for underbarrel GLs).
Modifies:
A3A_rebelGear (Global).
A3A_rebelGearVersion (Global).
Global Variables:
jna_dataList: Source of truth for available items.
minWeaps: Determines if weighting is based on unlocks or general stats.
Dependencies: Requires the JNA system to be populated and unlocked* arrays to be accurate.
System Fit: The "brain" for AI loadouts. It determines what gear AI rebels can use based on faction progress and item quality.
fn_getRadio.sqf
Function Name: 
fn_getRadio.sqf

What it does: Returns the class name of the radio assigned to a unit (excluding backpack radios). Supports Vanilla, TFAR, and VN radio systems.

How it does that:

Assigned Item Scan:

Sqf

Apply
private _items = assignedItems _unit;
private _radioPosition = _items findIf { _x == "ItemRadio" || {"tf_" in _x || {"TFAR_" in _x || {"item_radio" in _x}}}};
Explanation: Retrieves the array of assigned items. Uses findIf to search for a string match indicating a radio (Vanilla "ItemRadio", TFAR prefixes, or generic "item_radio").
Return Value:

Sqf

Apply
if (_radioPosition > -1) then {
    _items # _radioPosition;
} else {
    "";
};
Explanation: Returns the class name if found, otherwise an empty string.
Where it leads:

Calls: None.
Modifies: None.
Global Variables: None.
Dependencies: Relies on the unit having assigned items.
System Fit: Helper function used by AI or UI scripts to detect if a unit is carrying a standard radio.
fn_hasARadio.sqf
Function Name: 
fn_hasARadio.sqf

What it does: Checks if a unit has a radio, including backpack radios. Supports Vanilla, TFAR, and VN.

How it does that:

Assigned Items Check:

Sqf

Apply
assignedItems _this findIf { _x == "ItemRadio" || {"tf_" in _x} || {"TFAR" in _x} || {"item_radio" in _x} } > -1
Explanation: Checks assigned items for radio signatures.
Backpack Radio Check:

Sqf

Apply
|| { backpack _this in allBackpacksRadio }
Explanation: Checks if the unit's backpack class is present in the allBackpacksRadio global array.
Where it leads:

Calls: None.
Modifies: None.
Global Variables:
allBackpacksRadio: List of backpack radios.
Dependencies: Requires allBackpacksRadio to be populated (done in fn_equipmentSort).
System Fit: Used to determine if a unit can use radio-based features (e.g., requesting support, TFAR communication).
fn_itemArrayWeight.sqf
Function Name: 
fn_itemArrayWeight.sqf

What it does: Calculates a numerical weight (preference score) for an item based on its combat statistics. Used to rank weapons for AI loadouts.

How it does that:

Stat Extraction:

Sqf

Apply
private _weight = (_config call A3A_fnc_itemConfigMass);
private _accuracy = getNumber (_modecfg >> "dispersion");
private _reloadtime = getNumber (_modecfg >> "reloadTime");
private _rof = if (_reloadTime == 0) then {0} else {1 / _reloadTime};
private _magcap = getNumber (_magcfg >> "count");
private _impact = sqrt (_hit ^ 2 * _muzvel); // Derived damage/velocity metric
Explanation: Pulls raw stats from the config and calculates derived stats like Rate of Fire (RoF) and Impact.
Categorical Formula Application:

Sqf

Apply
switch (_categories select 0) do {
    case "Rifles": { _arrayWeight = round ((_accuracy * 10000) + _rof + _magcap + (_impact / 30) - (_weight / 5)) };
    case "SniperRifles": { ... };
    case "RocketLaunchers": { ... };
    // ... etc ...
};
Explanation: Applies a specific mathematical formula to the stats depending on the weapon type. For example, Rifles value accuracy and RoF, while Launchers value Impact and Range.
Return:

Sqf

Apply
[1, _arrayWeight] select (_arrayWeight > 0);
Explanation: Returns the weight, ensuring it is positive (or defaults to 1).
Where it leads:

Calls:
A3A_fnc_itemConfigMass: Gets item weight.
A3A_fnc_itemConfig: Gets config.
Modifies: None.
Global Variables: None.
Dependencies: Requires valid config classes.
System Fit: Used by fn_generateRebelGear to assign preference scores to items.
fn_itemConfig.sqf
Function Name: 
fn_itemConfig.sqf

What it does: Returns the config entry for a class name, searching through CfgAmmo, CfgMagazines, and CfgWeapons.

How it does that:

Iteration: Loops through the three root config categories.
Check: Uses isClass to see if the class exists in the current root.
Return: Returns the config path if found.
Where it leads:

Calls: Standard config commands.
System Fit: Utility function to abstract config lookup.
fn_itemConfigMass.sqf
Function Name: 
fn_itemConfigMass.sqf

What it does: Returns the mass of an item from its config, checking WeaponSlotsInfo, ItemInfo, and direct mass property.

How it does that:

Checks Hierarchy:
Checks WeaponSlotsInfo >> mass.
If 0, checks ItemInfo >> mass.
If 0, checks mass directly.
Return: Returns the found mass or 0.
Where it leads:

System Fit: Used by weight calculation functions.
fn_itemSort.sqf
Function Name: 
fn_itemSort.sqf

What it does: Post-processes allMagSmokeShell, allMagFlare, and allUnknown to categorize them into specific lists (Smoke, Flares, Chemlights, etc.) based on config properties like nameSound.

How it does that:

Smoke Identification:

Sqf

Apply
{
    if (getText(configfile >> "CfgMagazines" >> _x >> "nameSound") isEqualTo "smokeshell") then {
        allSmokeGrenades pushback _x;
    };
} forEach allMagSmokeShell;
Explanation: Checks the nameSound property to classify smoke shells.
Flare Identification:

Sqf

Apply
private _uglMag = getArray (configfile >> "CfgMagazineWells" >> "UGL_40x36" >> "BI_Magazines");
// ...
if (_x in _uglMag) then { allLaunchedFlares pushBack _x } else { allHandFlares pushBack _x };
Explanation: Checks if the flare magazine is defined in UGL magazine wells to distinguish between handheld and launched flares.
Unknown Cleanup:

Moves IR Grenades, Laser Batteries, and Designator Batteries out of the allUnknown array into their own lists.
Where it leads:

Modifies: allSmokeGrenades, allLaunchedFlares, allHandFlares, allIRGrenades, etc.
System Fit: Refines loot pools so specific item types (like flares) can be spawned correctly.
fn_itemType.sqf
Function Name: 
fn_itemType.sqf

What it does: Returns a category string for an item class name. It is a wrapper around BIS_fnc_itemType with specific handling for CBA Misc Items.

How it does that:

CBA Check:

Sqf

Apply
if (isClass _weaponConfig 
        && _itemInfoType in [TYPE_MUZZLE, TYPE_OPTICS, TYPE_FLASHLIGHT, TYPE_BIPOD] 
        && _item isKindOf ["CBA_MiscItem", (_configCfgWeapons)]
    ) exitWith 
{
    ["Item", "Unknown"];
};
Explanation: Identifies items from the CBA mod that are classified as generic "Misc Items". It forces them into the "Unknown" category to prevent them from being categorized as standard attachments (which might have strict logic).
Default:

Sqf

Apply
_item call BIS_fnc_itemType;
Explanation: Delegates to the standard ArmA engine function for everything else.
Where it leads:

Calls:
BIS_fnc_itemType: Standard engine function.
System Fit: Ensures CBA items don't break the mission's attachment logic.
fn_launcherInfo.sqf
Function Name: 
fn_launcherInfo.sqf

What it does: Analyzes a launcher to determine its capabilities: can it lock onto ground targets, air targets, or both? It also lists unguided, ground-lock, and air-lock magazines.

How it does that:

Magazine Aggregation:

Sqf

Apply
private _rawMagazines = getArray (configFile >> "CfgWeapons" >> _launcherClassName >> "magazines");
// ... handle magazine wells and ACE/CBA disposable launchers ...
Explanation: Gathers all potential magazines. Handles special cases:
ACE Disposables: Looks for ACE_PreloadedMissileDummy.
CBA Disposables: Checks cba_disposable_LoadedLaunchers to find the actual fireable launcher.
Ammo Analysis:

Sqf

Apply
{
    _x params ["_mag", "_ammoType"];
    if (_ammoType isKindOf "MissileCore") then {
        private _ammoConfig = configFile >> "CfgAmmo" >> _ammoType;
        // ... check ACE guidance ...
        private _airLock = getNumber (_ammoConfig >> "airLock");
        // ... switch on _airLock ...
    } else {
        _unguidedMagazines pushBackUnique _mag;
    };
} forEach _magazineAmmo;
Explanation: For each magazine, it checks the ammo type. If it's a missile, it checks the airLock config property:
0: Ground only.
1: Both.
2: Air only.
ACE: If ACE guidance is enabled, it assumes both (if ACE is loaded).
If not a missile, it is added to _unguidedMagazines.
Return:

Sqf

Apply
[_targetGround, _targetAir, _unguidedMagazines, _groundMagazines, _airMagazines];
Explanation: Returns an array containing booleans for capabilities and arrays of magazine class names.
Where it leads:

Calls:
Standard config commands.
Modifies: None.
Global Variables:
A3A_hasACE: Checked for ACE guidance support.
System Fit: Used by AI logic to decide if a launcher is suitable for engaging a specific target type (Air/Ground).
fn_loot.sqf
Function Name: 
fn_loot.sqf

What it does: Populates global loot* arrays (e.g., lootWeapon, lootMagazine) by aggregating from the all* arrays (like allRifles, allBackpacks) and applying basic filters.

How it does that:

Aggregation:

Sqf

Apply
lootBasicItem append allMaps + allToolkits + ...;
lootWeapon append allRifles + allSniperRifles + ...;
Explanation: Simply appends the contents of the sorted global arrays into the loot category arrays.
Filtering:

Sqf

Apply
lootExplosive deleteAt (lootExplosive find "APERSMineDispenser_Mag");
// ... etc ...
Explanation: Removes specific items (like training mines or specific IEDs) from the loot pool that shouldn't be randomly spawned.
Forbidden Item Removal:

Sqf

Apply
call A3U_fnc_removeForbiddenItems;
Explanation: Calls a function to strip items defined in A3U_forbiddenItems from the loot arrays.
Where it leads:

Calls:
A3U_fnc_removeForbiddenItems: Cleans up lists.
Modifies:
lootWeapon, lootMagazine, lootExplosive, etc.
Dependencies: Requires all* arrays to be populated and sorted.
System Fit: Creates the master lists used by fn_fillLootCrate to spawn random items.
fn_randomWeapon.sqf
Function Name: 
fn_randomWeapon.sqf

What it does: Equips a unit with a random weapon from A3A_rebelGear, adding compatible magazines and random attachments (optics, pointers, silencers, bipods).

How it does that:

Weapon Selection:

Sqf

Apply
private _pool = A3A_rebelGear get _weapon;
// ... fallback logic if specific pool is empty ...
_weapon = selectRandomWeighted _pool;
Explanation: Retrieves the weighted list of weapons from the rebel gear hashmap. If a specific type (e.g., "MachineGuns") is requested, it uses that pool. If empty, it falls back to Rifles -> SMGs -> Handguns.
Magazine Addition:

Sqf

Apply
private _magazine = ... selectRandom ((A3A_rebelGear get "Magazines") get _weapon);
_unit addMagazines [_magazine, round (random 0.5 + _totalMagWeight / _magWeight)];
Explanation: Finds a compatible magazine from the cached magazine list. Calculates the number of magazines based on total desired weight and magazine weight.
Attachment Selection (Caching):

Optics: Checks A3A_rebelOpticsCache. If empty, filters compatibleItems against A3A_rebelGear lists (OpticsMid, OpticsLong, etc). Stores result in cache.
Pointers: Checks A3A_rebelFlashlightsCache or A3A_rebelLasersCache based on if the unit has NVGs (Lasers preferred with NVGs, Flashlights without).
Silencers/Bipods: Similar cache check.
Attachment Application:

Sqf

Apply
if (!isNil "_compatPointers" && {_compatPointers isNotEqualTo []}) then { _unit addWeaponItem [_weapon, selectRandom _compatPointers] };
// ... repeat for optics, silencers, bipods ...
Explanation: Picks a random item from the compatible, unlocked list and adds it to the weapon.
Where it leads:

Calls:
A3A_fnc_fetchRebelGear: Ensures gear data is available.
A3A_fnc_equipmentClassToCategories: Determines weapon type.
compatibleItems: Engine command to get attachables.
Modifies:
_unit (adds weapon, mags, attachments).
A3A_rebelOpticsCache, etc. (updates caches).
Global Variables:
A3A_rebelGear: Master gear data.
A3A_rebelGearVersion: Version check.
System Fit: Used by A3A_fnc_equipRebel to equip AI units with sensible, unlocked gear.
fn_transfer.sqf
Function Name: 
fn_transfer.sqf

What it does: Client-side action handler for transferring cargo from a vehicle to the HQ box. It checks distance, ownership (commander only for HQ box), and visualizes the loading process.

How it does that:

Target Identification:

Sqf

Apply
private _truckX = vehicle player;
private _objectsX = nearestObjects [_truckX, ["ReammoBox_F"], 20];
private _boxX = _objectsX select 0;
Explanation: Finds the closest ammobox to the player's vehicle.
Permission Check:

Sqf

Apply
if (_boxX == boxX and {player!=theBoss}) exitWith { ... };
Explanation: Only the commander (theBoss) can transfer items into the main HQ box to prevent cluttering or stealing from the arsenal.
Loading Visualization:

Sqf

Apply
while {_truckX == vehicle player and {speed _truckX == 0 and {_countX > 0}}} do {
    [localize "...", format [localize "...", _countX]] call A3A_fnc_customHint;
    _countX = _countX -1;
    sleep 1;
};
Explanation: Creates a pseudo-progress bar by sleeping 1 second and decrementing a counter, updating the hint each second. It aborts if the player moves the vehicle.
Remote Execution:

Sqf

Apply
[_boxX,_truckX] remoteExec ["A3A_fnc_ammunitionTransfer",2];
Explanation: Once the "loading" is complete (or aborted), it calls the server-side fn_ammunitionTransfer.
Cleanup:

Sqf

Apply
[driver _truckX,"truckX"] remoteExec ["A3A_fnc_flagaction",driver _truckX];
Explanation: Re-adds the action to the vehicle driver so it can be used again.
Where it leads:

Calls:
A3A_fnc_ammunitionTransfer: Server-side logic.
A3A_fnc_flagaction: Manages action menus.
A3A_fnc_customHint: UI updates.
Modifies:
Action menu availability.
Global Variables:
theBoss: Commander check.
boxX: HQ box reference.
Dependencies: Requires a valid vehicle and box.
System Fit: The user interface for moving loot from the battlefield to the HQ.
fn_unlockEquipment.sqf
Function Name: 
fn_unlockEquipment.sqf

What it does: Unlocks a specific item in the arsenal. It adds the item to the JNA system and updates the corresponding unlocked* global array.

How it does that:

Categorization:

Sqf

Apply
private _categories = _className call A3A_fnc_equipmentClassToCategories;
Explanation: Determines what kind of item it is (Rifle, Vest, etc.).
JNA Update:

Sqf

Apply
if (!_dontAddToArsenal) then {
    private _arsenalTab = _className call jn_fnc_arsenal_itemType;
    [_arsenalTab,_className,-1] call jn_fnc_arsenal_addItem;
};
Explanation: Adds the item to the Joint Non-Additive Arsenal (JNA) with a count of -1 (infinite/unlocked).
Global Array Update:

Sqf

Apply
{
    (missionNamespace getVariable ("unlocked" + _x)) pushBackUnique _className;
    if (!_noPublish) then { publicVariable ("unlocked" + _x) };
} forEach _categories;
Explanation: Adds the class name to unlockedWeapons, unlockedRifles, etc., based on the categories found. pushBackUnique prevents duplicates. publicVariable syncs with clients.
Where it leads:

Calls:
A3A_fnc_equipmentClassToCategories: Determines where to unlock the item.
jn_fnc_arsenal_itemType: Determines JNA tab.
jn_fnc_arsenal_addItem: Adds to JNA.
Modifies:
unlocked* arrays.
JNA Data.
Global Variables: All unlocked* arrays.
System Fit: The core function for progressing the faction's arsenal.
fn_vehicleSort.sqf
Function Name: 
fn_vehicleSort.sqf

What it does: Categorizes static weapons found in the allUnknown array (from fn_configSort) into side-specific static weapon lists (Invader, Occupant, Rebel).

How it does that:

Filtering:

Sqf

Apply
{
    if (getText (configfile >> "CfgVehicles" >> _x >> "editorSubcategory") isEqualTo "EdSubcat_Turrets") then
    {
        private _staticSide = getNumber (configfile >> "CfgVehicles" >> _x >> "side");
        // ... switch on side ...
    };
} forEach allUnknown;
Explanation: Checks if a vehicle belongs to the "Turrets" subcategory. If so, it reads the side property (0=East, 1=West, 2=Ind) and pushes the class name to invaderStaticWeapon, occupantStaticWeapon, or rebelStaticWeapon.
Cleanup:

Sqf

Apply
{ allUnknown deleteAt (allUnknown find _x); } forEach invaderStaticWeapon + ...;
Explanation: Removes the sorted static weapons from the generic allUnknown list.
Where it leads:

Modifies:
invaderStaticWeapon, occupantStaticWeapon, rebelStaticWeapon.
allUnknown.
Dependencies: Requires allUnknown to be populated.
System Fit: Preps static weapon lists for AI spawn scripts.
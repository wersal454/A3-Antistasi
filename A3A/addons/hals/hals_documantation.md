
Function Name: HALs_store_fnc_initModule.sqf What it does: Initializes the HALs Store module by setting up server and client components. This function is called during module initialization to prepare the system for operation. How it does that:

Checks if initialization has already occurred to prevent duplicate setup
If on server, calls the server initialization function
If on client with interface, calls the client initialization function Step-by-step breakdown:
Sqf

Apply
if (!isNil "HALs_store_moduleInit") exitWith {};
This checks if the module has already been initialized to prevent duplicate execution.

Sqf

Apply
HALs_store_moduleInit = true;
Sets a global flag to indicate the module has been initialized.

Sqf

Apply
if (isServer) then {call HALs_store_fnc_initServer};
If running on server, calls the server initialization function to set up server-side components.

Sqf

Apply
if (hasInterface) then {call HALs_store_fnc_initClient};
If running on client with interface, calls the client initialization function to set up client-side components. Where it leads: Calls HALs_store_fnc_initServer (server initialization) Calls HALs_store_fnc_initClient (client initialization) This function is the entry point for module initialization and is called by the system during mission start. Requirements: No special requirements beyond standard Arma 3 module initialization flow.

Function Name: HALs_store_fnc_addItemCargo.sqf What it does: Adds items to a container's cargo, handling different item types (magazines, weapons, backpacks, regular items) with appropriate cargo methods. How it does that:

Validates that execution is on server
Checks for valid container and item parameters
Determines item type using getItemType function
Adds items to container using appropriate cargo methods based on item type Step-by-step breakdown:
Sqf

Apply
params [
	["_container", objNull, [objNull]],
	["_classname", "", [""]],
	["_amount", 1, [0]]
];
Parameter validation to ensure container is valid object, classname is string, and amount is number.

Sqf

Apply
if (!isServer) exitWith {};
Exits early if not on server.

Sqf

Apply
if (isNull _container) exitWith {};
Exits early if container is null.

Sqf

Apply
if (_classname isEqualTo "") exitWith {};
Exits early if classname is empty.

Sqf

Apply
if (_amount < 1) exitWith {};
Exits early if amount is less than 1.

Sqf

Apply
switch ([_classname] call HALs_store_fnc_getItemType) do {
	case 1: {_container addMagazineCargoGlobal [_classname, _amount]};
	case 2: {_container addWeaponCargoGlobal [_classname, _amount]};
	case 3: {_container addBackpackCargoGlobal [_classname, _amount]};
	case 4: {_container addItemCargoGlobal [_classname, _amount]};
	default {};
};
Uses switch statement to determine item type and call appropriate cargo method:

Type 1 (magazines): addMagazineCargoGlobal
Type 2 (weapons): addWeaponCargoGlobal
Type 3 (backpacks): addBackpackCargoGlobal
Type 4 (items): addItemCargoGlobal Where it leads: Calls HALs_store_fnc_getItemType to determine item type Depends on: HALs_store_fnc_getItemType This function is used to populate containers with items during purchase operations. Requirements: Must be executed on server Container must be valid object Item classnames must be valid
Function Name: HALs_store_fnc_canAddItem.sqf What it does: Checks if an item can be added to a container, optionally returning the maximum number of items that can be added. How it does that:

Validates parameters including container, classname, and amount
If finding maximum items, iterates through possible amounts to find maximum that can be added
Otherwise, directly calls container's canAdd method Step-by-step breakdown:
Sqf

Apply
params [
	["_container", objNull, [objNull]],
	["_classname", "", [""]],
	["_amount", 1, [1]],
	["_findMax", false, [false]]
];
Parameter validation for container, classname, amount, and findMax flag.

Sqf

Apply
if (_findMax) exitWith {
	if (isNull _container) exitWith {0};
	if (_classname isEqualTo "") exitWith {0};
	if (_amount < 1) exitWith {0};

	private _amtToAdd = 0;
	for [{private _i = 1}, {_container canAdd [_classname, _i] && {_i <= _amount}}, {_i = _i + 1}] do {
		_amtToAdd = _i;
	};

	_amtToAdd
};
When finding maximum items:

Validates inputs
Initializes counter to 0
Uses for loop to test increasing amounts until container can't add more
Returns maximum amount that can be added
Sqf

Apply
if (isNull _container) exitWith {false};
if (_classname isEqualTo "") exitWith {false};
if (_amount < 1) exitWith {false};
Standard input validation for non-maximum case.

Sqf

Apply
_container canAdd [_classname, _amount]
Directly calls container's canAdd method to check if specified amount can be added. Where it leads: Used by purchase and sell functions to validate item addition Depends on: None (uses standard Arma 3 methods) This function validates item addition before purchase/sell operations. Requirements: Container must be valid object

Function Name: HALs_store_fnc_canEquipItem.sqf What it does: Determines if an item can be equipped by a unit, checking compatibility with unit's current equipment. How it does that:

Validates unit and classname parameters
Determines item category and type using BIS_fnc_itemType
Based on item category, checks appropriate compatibility conditions:
Weapon: checks if weapon type matches (primary, secondary, handgun)
Equipment: checks if item type matches (glasses, headgear, vest, uniform, backpack)
Magazine: checks if magazine is compatible with unit's weapons
Item: checks for attachment compatibility or general item availability Step-by-step breakdown:
Sqf

Apply
params [
	["_unit", objNull],
	["_classname", ""]
];
Parameter validation for unit and classname.

Sqf

Apply
_classname = toLower _classname;
Converts classname to lowercase for case-insensitive comparison.

Sqf

Apply
([_classname] call BIS_fnc_itemType) params ["_itemCategory", "_itemType"];
Uses BIS_fnc_itemType to determine item category and type.

Sqf

Apply
private _canAdd = false;
Initializes flag to track if item can be added.

Sqf

Apply
switch (_itemCategory) do {
	case "Weapon": {
		switch ( getNumber (configFile >> "CfgWeapons" >> _classname >> "type") ) do {
			case 1: {_canAdd = (primaryWeapon _unit) isEqualTo ""};
			case 4: {_canAdd = (secondaryWeapon _unit) isEqualTo ""};
			case 2: {_canAdd = (handgunWeapon _unit) isEqualTo ""};
		};
	};
Weapon category logic:

Checks weapon type using config
For type 1 (assault rifle): checks if primary weapon is empty
For type 4 (launcher): checks if secondary weapon is empty
For type 2 (handgun): checks if handgun is empty
Sqf

Apply
	case "Equipment": {
		switch (_itemType) do {
			case "Glasses": {_canAdd = (goggles _unit) isEqualTo ""};
			case "Headgear": {_canAdd = (headgear _unit) isEqualTo ""};
			case "Vest": {_canAdd = (vest _unit) isEqualTo ""};
			case "Uniform": {_canAdd = (uniform _unit) isEqualTo ""};
			case "Backpack": {_canAdd = (backpack _unit) isEqualTo ""};
		};
	};
Equipment category logic:

Checks if item type is already equipped on unit
For glasses, headgear, vest, uniform, backpack - checks if empty
Sqf

Apply
	case "Magazine": {
		{
			if (count (_x select 0) > 0) then {
				if ((_x select 1) isEqualTo []) then {
					_compatibleWeaponItems = ((_x select 0) call HALs_store_fnc_getCompatibleItems) apply {toLower _x};

					_canAdd = _classname in _compatibleWeaponItems;
				};
			};

			if (_canAdd) exitWith {};
		} forEach [
			[primaryWeapon _unit, primaryWeaponMagazine _unit],
			[secondaryWeapon _unit, secondaryWeaponMagazine _unit],
			[handgunWeapon _unit, handgunMagazine _unit]
		];
	};
Magazine category logic:

Iterates through all weapon types (primary, secondary, handgun)
For each weapon, gets compatible items using getCompatibleItems
Checks if magazine classname is in compatible items list
Sqf

Apply
	case "Item": {
		switch (_itemType) do {
			case "AccessoryMuzzle",
			case "AccessoryPointer",
			case "AccessorySights",
			case "AccessoryBipod": {
				_attachmentSlotIndex = switch (_itemType) do {
					case "AccessoryMuzzle": {0};
					case "AccessoryPointer": {1};
					case "AccessorySights": {2};
					case "AccessoryBipod": {3};
				};

				{
					if (count (_x select 0) > 0) then {
						if (((_x select 1) select _attachmentSlotIndex) isEqualTo "") then {
							_compatibleWeaponItems = ((_x select 0) call HALs_store_fnc_getCompatibleItems) apply {toLower _x};

							_canAdd = _classname in _compatibleWeaponItems;
						};
					};

					if (_canAdd) exitWith {};
				} forEach [
					[primaryWeapon _unit, primaryWeaponItems _unit],
					[secondaryWeapon _unit, secondaryWeaponItems _unit],
					[handgunWeapon _unit, handgunItems _unit]
				];
			};

			case "NVGoggles": {_canAdd = (hmd _unit) isEqualTo ""};
			case "Glasses",
			case "LaserDesignator",
			case "Binocular": {_canAdd = (binocular _unit) isEqualTo ""};
			default {
				_canAdd = !(_classname in (assignedItems _unit apply {toLower _x}))
			};
		};
	};
Item category logic:

For accessories (muzzle, pointer, sights, bipod): checks attachment slots
For NVGoggles: checks if head-mounted display is empty
For glasses, laser designator, binoculars: checks if item is empty
For other items: checks if item is already assigned to unit Where it leads: Called by purchase and equip functions to validate item compatibility Depends on: HALs_store_fnc_getCompatibleItems This function validates whether items can be equipped before purchase. Requirements: Unit must be valid object
Function Name: HALs_store_fnc_equipItem.sqf What it does: Equips an item on a unit, handling different item types and checking compatibility. How it does that:

Validates unit and classname parameters
Determines item type using BIS_fnc_itemType
For magazines, checks weapon compatibility and adds to appropriate weapon
For other items, routes to appropriate equip methods based on item type Step-by-step breakdown:
Sqf

Apply
#include "..\..\..\..\script_component.hpp"
Includes the script component header.

Sqf

Apply
params [
	["_unit", objNull, [objNull]],
	["_classname", "", [""]]
];
Parameter validation for unit and classname.

Sqf

Apply
Error("Equip function call.");
Logs that the function was called.

Sqf

Apply
if (isNull _unit) exitWith {
	Error("Unit is null.");
	false
	};
Exits early if unit is null.

Sqf

Apply
if (_classname isEqualTo '') exitWith {
	Error("Classname is empty.");
	false
};
Exits early if classname is empty.

Sqf

Apply
private _added = false;
Initializes flag to track if item was added.

Sqf

Apply
_classname = toLower _classname;
([_classname] call BIS_fnc_itemType) params ["_itemCategory", "_itemType"];
Determines item category and type.

Sqf

Apply
if (_itemCategory isEqualTo "Magazine") then {
	{
		if !(_x isEqualTo "") then {
			switch (_forEachIndex) do {
				case 0: {
					if ((primaryWeaponMagazine _unit) isEqualTo []) then {
						_compatibleWeaponItems = (_x call HALs_store_fnc_getCompatibleItems) apply {toLower _x};
						if (_classname in _compatibleWeaponItems) then {
							_unit addPrimaryWeaponItem _classname;
							_added = true;
						};
					};
				};
				case 1: {
					if ((secondaryWeaponMagazine _unit) isEqualTo []) then {
						_compatibleWeaponItems = (_x call HALs_store_fnc_getCompatibleItems) apply {toLower _x};
						if (_classname in _compatibleWeaponItems) then {
							_unit addSecondaryWeaponItem _classname;
							_added = true;
						};
					};
				};
				case 2: {
					if ((handgunMagazine _unit) isEqualTo []) then {
						_compatibleWeaponItems = (_x call HALs_store_fnc_getCompatibleItems) apply {toLower _x};
						if (_classname in _compatibleWeaponItems) then {
							_unit addHandgunItem _classname;
							_added = true;
						};
					};
				};
			};
		};
		if (_added) exitWith {};
	}  forEach [primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit];
}
Magazine handling logic:

Iterates through weapon types (primary, secondary, handgun)
For each weapon, checks if magazine is empty
Gets compatible items for weapon
If classname is in compatible items, adds magazine to weapon
Sqf

Apply
else {
	_added = call {
		if (_itemType in ["AssaultRifle", "Rifle", "SubmachineGun", "MachineGun", "RocketLauncher", "MissileLauncher", "Shotgun", "SniperRifle", "Handgun", "LaserDesignator", "Throw", "Binocular"]) exitWith {
			_unit addWeaponGlobal _classname;
			true
		};
		if (_itemType in ["GPS", "Map", "Radio", "UAVTerminal", "Watch", "Compass", "NVGoggles", "Glasses"]) exitWith {
			_unit linkItem _classname;
			true;
		};
		if (_itemType isEqualTo "Headgear") exitWith {
			_unit addHeadgear _classname;
			true
		};
		if (_itemType isEqualTo "Backpack") exitWith {
			_unit addBackpackGlobal _classname;
			true
		};
		if (_itemType isEqualTo "Uniform") exitWith {
			_unit forceAddUniform _classname;
			true
		};
		if (_itemType isEqualTo "Vest") exitWith {
			_unit addVest _classname;
			true
		};
		if (_itemType in ["AccessorySights", "AccessoryPointer", "AccessoryMuzzle", "AccessoryBipod"]) exitWith {
			{
				if !(_x isEqualTo "") then {
					_compatibleWeaponItems = (_x call HALs_store_fnc_getCompatibleItems) apply {toLower _x};
					if (_classname in _compatibleWeaponItems) exitWith {
						switch (_forEachIndex) do {
							case 0: {_unit addPrimaryWeaponItem _classname; _added = true;};
							case 1: {_unit addSecondaryWeaponItem _classname; _added = true;};
							case 2: {_unit addHandgunItem _classname; _added = true;};
						};
					};
				};
				if (_added) exitWith {};
			} forEach [primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit];
			true
		};
		false
	};
};
Non-magazine handling logic:

Uses switch statements to route to appropriate item handling methods
Weapons: addWeaponGlobal
Equipment items: linkItem or addHeadgear/addBackpack/forceAddUniform/addVest
Accessories: checks compatibility and adds to appropriate weapon slot
Returns true if item was successfully added, false otherwise Where it leads: Called by purchase function when item is to be equipped Depends on: HALs_store_fnc_getCompatibleItems This function actually performs the item equipping operation. Requirements: Unit must be valid object
Function Name: HALs_store_fnc_hashGet.sqf What it does: Retrieves a value from a hash table using a key, implementing a hash-based lookup system. How it does that:

Uses a hash function to compute hash index from key
Looks up the hash in the container array
Finds the value in the key-value pairs at that hash index Step-by-step breakdown:
Sqf

Apply
#define GET_HASH _a = toArray _k; _d = (count _a); _h = (_a select 0)*(_a select _d-1)+(_d+(_a select ((_d-2)) max 0))
Defines a hash function that computes hash based on character values of key.

Sqf

Apply
params ["_c", "_k"];
GET_HASH;
Parameters for container and key, then computes hash.

Sqf

Apply
(((_c select _h) select 1) select (((_c select _h) select 0) find _k))
Retrieves the value from the hash table:

Gets the hash entry at index _h
Gets the values array from that entry
Gets the keys array from that entry
Finds the key's index in the keys array
Uses that index to get the corresponding value Where it leads: Used by other hash functions for lookup operations Depends on: None (standalone hash implementation) This function implements a hash table lookup mechanism. Requirements: Container must be properly initialized hash table
Function Name: HALs_store_fnc_hashGetOrDefault.sqf What it does: Retrieves a value from a hash table or returns a default value if key is not found. How it does that:

Validates key is not empty
Attempts to get value using hashGet function
If value is nil, returns default value; otherwise returns found value Step-by-step breakdown:
Sqf

Apply
params ["_c", "_k", "_default"];
Parameter validation for container, key, and default value.

Sqf

Apply
if (_k isEqualTo "") exitWith {_default};
Exits early if key is empty.

Sqf

Apply
private _val = [_c, _k] call HALs_store_fnc_hashGet;
Calls hashGet to retrieve value.

Sqf

Apply
if (isNil "_val") then {_default} else {_val}
Returns default if value is nil, otherwise returns found value. Where it leads: Used by other functions to safely retrieve hash values Depends on: HALs_store_fnc_hashGet This function provides safe hash value retrieval with default fallback. Requirements: Container must be properly initialized hash table

Function Name: HALs_store_fnc_hashSet.sqf What it does: Sets a key-value pair in a hash table, creating the hash entry if needed. How it does that:

Computes hash index from key
Creates hash entry if it doesn't exist
Adds or updates key-value pair in the entry Step-by-step breakdown:
Sqf

Apply
#define GET_HASH _a = toArray _k; _d = (count _a); _h = (_a select 0)*(_a select _d-1)+(_d+(_a select ((_d-2)) max 0))
Defines hash function.

Sqf

Apply
params ["_container", "_key", "_val"];
private ["_hash", "_chain", "_keys", "_val", "_index"];
Parameter validation and variable declarations.

Sqf

Apply
_k = _key;
GET_HASH;
_hash = _h;
Computes hash value.

Sqf

Apply
if (count _container < _hash) then {
	_container set [_hash, [[],[]]];
};
Creates hash entry if needed.

Sqf

Apply
_pairs = _container select _hash;
Retrieves existing hash entry.

Sqf

Apply
if (isNil "_pairs") then {
	_pairs = [[], []];
	_container set [_hash, _pairs];
};
Initializes hash entry if not already done.

Sqf

Apply
_keys = _pairs select 0;
_vals = _pairs select 1;
_index = _keys find _key;
Retrieves keys and values arrays, finds existing key index.

Sqf

Apply
if (_index == -1) then {
	_keys pushBack _key;
	_vals pushBack _val;
} else {
	_vals set[_index, _val];
};
Adds new key-value pair or updates existing one. Where it leads: Used by other functions to store hash values Depends on: None (standalone hash implementation) This function implements hash table insertion/update mechanism. Requirements: Container must be properly initialized hash table

Function Name: HALs_store_fnc_getCargoMass.sqf What it does: Calculates the total mass of items in a container, including recursive calculation for nested containers. How it does that:

Gets all cargo types from container (magazines, weapons, items, backpacks)
Calculates mass for each item type using config files
Recursively processes nested containers Step-by-step breakdown:
Sqf

Apply
params [
	["_container", objNull, [objNull]]
];
Parameter validation for container.

Sqf

Apply
private _totalMass = 0;
Initializes total mass counter.

Sqf

Apply
{
	_x params ["_items", "_configCode"];
	_items params ["_item", "_count"];

	{
		_totalMass = _totalMass + (getNumber ((call _configCode) >> "mass") * (_count select _forEachIndex));
	} forEach _item;

	true
} count [
	[getMagazineCargo _container,	{configFile >> "CfgMagazines" >> _x}],
	[getBackpackCargo _container, 	{configFile >> "CfgVehicles" >> _x}],
	[getItemCargo _container, 	{configFile >> "CfgWeapons" >> _x >> "ItemInfo"}],
	[getItemCargo _container, 	{configFile >> "CfgGlasses" >> _x}],
	[getWeaponCargo _container, 	{configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo"}]
];
Processes different cargo types:

Magazine cargo: uses CfgMagazines config
Backpack cargo: uses CfgVehicles config
Item cargo: uses CfgWeapons ItemInfo config
Glasses cargo: uses CfgGlasses config
Weapon cargo: uses CfgWeapons WeaponSlotsInfo config
Sqf

Apply
_containers = (everyContainer _container);
if (count _containers > 0) then {
	{
		_totalMass = _totalMass + (_x call HALs_store_fnc_getCargoMass);
	} forEach (_containers apply {_x select 1})
};
Recursively processes nested containers to include their mass. Where it leads: Used by cargo management functions to calculate load Depends on: None (uses standard Arma 3 cargo methods) This function calculates the total mass of a container including nested containers. Requirements: Container must be valid object

Function Name: HALs_store_fnc_getCompatibleItems.sqf What it does: Returns all items and magazines compatible with a weapon, including weapon-specific attachments. How it does that:

Gets compatible items using BIS_fnc_compatibleItems
Adds weapon's magazines to the list
Adds magazines from weapon's muzzles to the list Step-by-step breakdown:
Sqf

Apply
params [
	["_classname", ""]
];
Parameter validation for classname.

Sqf

Apply
private _attachments = _classname call BIS_fnc_compatibleItems;
Gets base compatible items for weapon.

Sqf

Apply
private _config = configFile >> "CfgWeapons" >> _classname;
_attachments append getArray (_config >> "magazines");
Appends weapon's magazines to list.

Sqf

Apply
{
	if !(_x isEqualTo "this") then {
		_attachments append getArray (_config >> _x >> "magazines");
	};
} forEach getArray (_config >> "muzzles");
Appends magazines from weapon's muzzles to list. Where it leads: Used by canEquipItem and other functions to check compatibility Depends on: BIS_fnc_compatibleItems This function provides comprehensive compatibility information for weapons. Requirements: Valid weapon classname

Function Name: HALs_store_fnc_getItemMass.sqf What it does: Returns the mass of an item by looking up its mass in config files. How it does that:

Tries to get mass from multiple config types (magazines, vehicles, weapons, glasses)
Sums up mass from all applicable configs Step-by-step breakdown:
Sqf

Apply
private _totalMass = 0;
Initializes mass counter.

Sqf

Apply
{
	_totalMass = _totalMass + getNumber ((call _x) >> "mass");
	true
} count [
	{configFile >> "CfgMagazines" >> _this},
	{configFile >> "CfgVehicles" >> _this},
	{configFile >> "CfgWeapons" >> _this >> "ItemInfo"},
	{configFile >> "CfgWeapons" >> _this >> "WeaponSlotsInfo"},
	{configFile >> "CfgGlasses" >> _this}
];
Tries to get mass from all config types:

CfgMagazines
CfgVehicles
CfgWeapons ItemInfo
CfgWeapons WeaponSlotsInfo
CfgGlasses Where it leads: Used by cargo mass calculations and item management Depends on: None (uses standard Arma 3 config methods) This function calculates the mass of an item from various config sources. Requirements: Valid item classname
Function Name: HALs_store_fnc_getItemStats.sqf What it does: Gets statistical information about an item compared to global values for weapon, equipment, and optics. How it does that:

Initializes global statistics if not already done
Determines item type and category
Uses bis_fnc_configExtremes to compare item stats against global ranges
Normalizes stats to 0.01-1 range for display Step-by-step breakdown:
Sqf

Apply
params [
	["_config", configNull, [configNull]]
];
Parameter validation for config.

Sqf

Apply
if (isNil "HALs_store_stats_weapons") exitWith {
	// Taken from BIS_fnc_arsenal, modified by HallyG
	HALs_store_stats_weapons = [
		("getNumber (_x >> 'scope') isEqualTo 2 && getNumber (_x >> 'type') < 5") configClasses (configfile >> "cfgWeapons"),
		["reloadtime","dispersion","maxzeroing","hit","initSpeed"],
		[true,true,false,true,false]
	] call bis_fnc_configExtremes;

	private _statsEquipment = [
		("getNumber (_x >> 'scope') isEqualTo 2 && getNumber (_x >> 'itemInfo' >> 'type') in [605,701,801]") configClasses (configFile >> "cfgWeapons"),
		["passthrough","armor","maximumLoad"],
		[false,false,false]
	] call bis_fnc_configExtremes;

	private _statsBackpacks = [
		("getNumber (_x >> 'scope') isEqualTo 2 && getNumber (_x >> 'isBackpack') isEqualTo 1") configClasses (configFile >> "cfgVehicles"),
		["passthrough","armor","maximumLoad"],
		[false,false,false]
	] call bis_fnc_configExtremes;

	private _statsEquipmentMin = _statsEquipment select 0;
	private _statsEquipmentMax = _statsEquipment select 1;
	private _statsBackpacksMin = _statsBackpacks select 0;
	private _statsBackpacksMax = _statsBackpacks select 1;
	for "_i" from 2 to 3 do { //--- Ignore backpack armor and passThrough, has no effect
		_statsEquipmentMin set [_i,(_statsEquipmentMin select _i) min (_statsBackpacksMin select _i)];
		_statsEquipmentMax set [_i,(_statsEquipmentMax select _i) max (_statsBackpacksMax select _i)];
	};

	HALs_store_stats_equipment = [_statsEquipmentMin, _statsEquipmentMax];

	private _statsOpticsMin = ("isClass (_x >> 'ItemInfo' >> 'OpticsModes')" configClasses (configFile >> "CfgWeapons")) apply {
		selectMax (("true" configClasses (_x >> "ItemInfo" >> "OpticsModes")) apply {getNumber (_x >> "distanceZoomMax")})
	};
	private _statsOpticsMax = ("isClass (_x >> 'ItemInfo' >> 'OpticsModes')" configClasses (configFile >> "CfgWeapons")) apply {
		selectMax (("true" configClasses (_x >> "ItemInfo" >> "OpticsModes")) apply {getNumber (_x >> "distanceZoomMax")})
	};

	HALs_store_stats_optics = [selectMin _statsOpticsMin, selectMax _statsOpticsMax];
};
Initializes global statistics for weapons, equipment, and optics if not already done:

Weapon stats: reloadtime, dispersion, maxzeroing, hit, initSpeed
Equipment stats: passthrough, armor, maximumLoad
Optics stats: distanceZoomMax
Sqf

Apply
call {
	if (getNumber (_config >> "type") in [1, 2, 4] && {getNumber (_config >> "isbackpack") != 1}) exitWith {
		HALs_store_stats_weapons params ["_statsMin", "_statsMax"];

		private _stats = ([[_config], ["reloadtime","dispersion","maxzeroing","hit","initSpeed"], [true,true,false,true,false], _statsMin] call bis_fnc_configExtremes) select 1;
		private _barMax = 1;
		private _barMin = 0.01;

		private _statReloadSpeed = linearConversion [_statsMin select 0,_statsMax select 0,_stats select 0, _barMax,_barMin];
		private _statDispersion = linearConversion [_statsMin select 1,_statsMax select 1,_stats select 1, _barMax,_barMin];
		private _statMaxRange = linearConversion [_statsMin select 2,_statsMax select 2,_stats select 2, _barMin,_barMax];
		private _statHit = linearConversion [_statsMin select 3,_statsMax select 3,_stats select 3, _barMin,_barMax];
		private _statInitSpeed = linearConversion [_statsMin select 4,_statsMax select 4,_stats select 4, _barMin, _barMax];

		if (getNumber (_config >> "type") isEqualTo 4) then {
			[
				[_statMaxRange, localize "str_a3_rscdisplayarsenal_stat_range"],
				[_statHit, localize "str_a3_rscdisplayarsenal_stat_impact"],
				[],
				[],
				[]
			]
		} else {
			_statHit = sqrt (_statHit^2 * _statInitSpeed);

			[
				[_statReloadSpeed, localize "str_a3_rscdisplayarsenal_stat_rof"],
				[_statDispersion, localize "str_a3_rscdisplayarsenal_stat_dispersion"],
				[_statMaxRange, localize "str_a3_rscdisplayarsenal_stat_range"],
				[_statHit, localize "str_a3_rscdisplayarsenal_stat_impact"],
				[]
			]
		};
	};
Weapon category processing:

Gets weapon stats using bis_fnc_configExtremes
Converts stats to 0.01-1 range using linearConversion
For launchers (type 4): returns range and impact stats
For other weapons: returns multiple stats including normalized hit
Sqf

Apply
	if (getNumber (_config >> "itemInfo" >> "type") in [605,701,801] || (getNumber (_config >> "type") isEqualTo 1 && getNumber (_config >> "isbackpack") isEqualTo 1)) exitWith {
		HALs_store_stats_equipment params ["_statsMin", "_statsMax"];

		private _stats = ([[_config], ["passthrough", "armor", "maximumLoad"], [false,false,false], _statsMin] call bis_fnc_configExtremes) select 1;
		private _barMax = 1;
		private _barMin = 0.01;

		private _statArmorShot = linearConversion [_statsMin select 0, _statsMax select 0, _stats select 0, _barMin, _barMax];
		private _statArmorExpl = linearConversion [_statsMin select 1, _statsMax select 1, _stats select 1, _barMin, _barMax];
		private _statMaximumLoad = linearConversion [_statsMin select 2, _statsMax select 2, _stats select 2, _barMin, _barMax];

		//--- Force no backpack armor
		if (getNumber (_config >> "isbackpack") isEqualTo 1) then {
			_statArmorShot = _barMin;
			_statArmorExpl = _barMin;
		};

		[
			[_statArmorShot, localize "str_a3_rscdisplayarsenal_stat_passthrough"],
			[_statArmorExpl, localize "str_a3_rscdisplayarsenal_stat_armor"],
			[_statMaximumLoad, localize "str_a3_rscdisplayarsenal_stat_load"],
			[],
			[]
		]
	};
Equipment category processing:

Gets equipment stats using bis_fnc_configExtremes
Converts stats to 0.01-1 range using linearConversion
For backpacks: sets armor to minimum
Returns armor and load stats
Sqf

Apply
	if (isClass (_config >> 'ItemInfo' >> 'OpticsModes')) exitWith {
		private _zoom = selectMax (("true" configClasses (_config >> "ItemInfo" >> "OpticsModes")) apply {getNumber (_x >> "distanceZoomMax")});
		private _statZoom = linearConversion [HALs_store_stats_optics select 0, HALs_store_stats_optics select 1, _zoom, 0.01, 1, true];

		[
			[_statZoom, "Zoom"],
			[],
			[],
			[],
			[]
		]
	};
Optics category processing:

Gets maximum zoom from optics modes
Converts zoom to 0.01-1 range using linearConversion
Returns zoom stat
Sqf

Apply
	[[],[],[],[],[]]
};
Default return for unknown item types. Where it leads: Used by UI to display item statistics Depends on: bis_fnc_configExtremes, HALs_store_stats_weapons, HALs_store_stats_equipment, HALs_store_stats_optics This function provides normalized statistical data for item comparison. Requirements: Valid config path

Function Name: HALs_store_fnc_getItemType.sqf What it does: Returns an item's enumerated type based on its category and type. How it does that:

Uses BIS_fnc_itemType to determine category and type
Maps categories to numerical types for internal use:
Weapon: type 2
Mine: type 1
Magazine: type 1
Item: type 4
Equipment: type 3 for backpacks, type 4 for others Step-by-step breakdown:
Sqf

Apply
params [
	['_classname', "", [""]]
];
Parameter validation for classname.

Sqf

Apply
private _type = [_classname] call BIS_fnc_itemType;
Determines item category and type using BIS_fnc_itemType.

Sqf

Apply
switch (_type select 0) do {
	case "Weapon": {2};
	case "Mine": {1};
	case "Magazine": {1};
	case "Item": {4};
	case "Equipment": {[4, 3] select ((_type#1) isEqualTo "Backpack")};
	default {4};
};
Maps category to numerical type:

Weapon: 2
Mine: 1
Magazine: 1
Item: 4
Equipment: 4 for non-backpacks, 3 for backpacks Where it leads: Used by cargo and item management functions to categorize items Depends on: BIS_fnc_itemType This function provides a simple numeric classification for item types. Requirements: Valid item classname
Function Name: HALs_store_fnc_getParentClassname.sqf What it does: Returns the parent classname of a weapon, useful for identifying base







Continue your response exactly where you left off:


Chat

Qwen3-coder:30b
Ctrl⏎ Active file
⏎ Enter
Function Name: HALs_store_fnc_getParentClassname.sqf What it does: Returns the classname of a weapon's parent class, which is useful for identifying base weapon types when dealing with weapon variants. How it does that:

Uses inheritsFrom to get the parent class of the weapon
Checks if the parent class has scope 2 (public)
If so, returns the parent's config name
Otherwise, returns the original classname Step-by-step breakdown:
Sqf

Apply
#define CFG configFile >> "CfgWeapons"
Defines a shorthand for the CfgWeapons config path.

Sqf

Apply
private _parent = inheritsFrom (CFG >> _this);
Gets the parent class of the weapon using inheritsFrom.

Sqf

Apply
if (getNumber (_parent >> 'scope') isEqualTo 2) exitWith {
	configName _parent;
};
If the parent has scope 2 (public), returns the parent's config name.

Sqf

Apply
_this 
Returns the original classname if parent is not public. Where it leads: Used by sell functions to check if items can be sold when they have parent classes Depends on: None (uses standard Arma 3 config methods) This function helps identify base weapon types for compatibility checks. Requirements: Valid weapon classname

Function Name: HALs_store_fnc_addContainerCargo.sqf What it does: Adds items to a container's cargo, handling nested containers recursively. How it does that:

Validates container parameter
Processes different item types (magazines, items, weapons, containers)
For weapons, uses addWeaponWithAttachmentsCargoGlobal
For containers, recursively processes nested containers Step-by-step breakdown:
Sqf

Apply
params [
    ["_container", objNull, [objNull]],
    ["_data", [[], [], [], []], [[]]]
];
Parameter validation for container and data array.

Sqf

Apply
if (isNull _container) exitWith {false};
Exits early if container is null.

Sqf

Apply
_data params ["_magazines", "_items", "_weapons", "_containers"];
Unpacks data array into individual item categories.

Sqf

Apply
{
    _container addMagazineAmmoCargo [_x select 0, 1, _x select 1];
} forEach _magazines;
Adds magazines to container using addMagazineAmmoCargo.

Sqf

Apply
{
	_container addItemCargoGlobal [_x select 0, _x select 1];
} forEach _items;
Adds regular items to container using addItemCargoGlobal.

Sqf

Apply
_weapons = _weapons select {count _x > 0};
if (count _weapons > 0) then {
    {
        _container addWeaponWithAttachmentsCargoGlobal [_x, 1];
    } forEach _weapons;
};
Adds weapons with attachments using addWeaponWithAttachmentsCargoGlobal.

Sqf

Apply
{
    _x params ["_subClassname", "_subData"];

    if (_subClassname isKindOf "bag_base") then {
		_container addBackpackCargoGlobal [_subClassname, 1];
	} else {
		_container addItemCargoGlobal [_subClassname, 1];
	};

    private _evContainer = everyContainer _container;
    private _cnt = count _evContainer - 1;
    private _subContainer = _evContainer select _cnt select 1;

    [_subContainer] call HALs_store_fnc_clearContainerCargo;
    [_subContainer, _subData] call HALs_store_fnc_addContainerCargo;
} forEach _containers;
Handles nested containers recursively:

Determines if container is a backpack
Adds appropriate cargo type
Gets the last nested container
Clears and recursively adds cargo to nested container Where it leads: Used by container management functions to populate containers Depends on: HALs_store_fnc_clearContainerCargo This function fully populates containers with items including nested containers. Requirements: Valid container object
Function Name: HALs_store_fnc_clearContainerCargo.sqf What it does: Removes all items from a container's cargo, clearing all item types. How it does that:

Validates container parameter
Clears all cargo types from container:
Magazine cargo
Item cargo
Weapon cargo
Backpack cargo Step-by-step breakdown:
Sqf

Apply
params [
    ["_container", objNull, [objNull]]
];
Parameter validation for container.

Sqf

Apply
if (isNull _container) exitWith {};
Exits early if container is null.

Sqf

Apply
clearItemCargoGlobal _container;
clearMagazineCargoGlobal _container;
clearWeaponCargoGlobal _container;
clearBackpackCargoGlobal _container;
Clears all cargo types from container using standard Arma 3 methods. Where it leads: Used by container management functions to reset containers Depends on: None (uses standard Arma 3 methods) This function completely empties a container of all items. Requirements: Valid container object

Function Name: HALs_store_fnc_getContainerCargo.sqf What it does: Returns all items in a container's inventory, including nested containers. How it does that:

Validates container parameter
Gets all cargo types from container
Gets nested container items recursively
Returns structured data with all items Step-by-step breakdown:
Sqf

Apply
params [
    ["_container", objNull, [objNull]]
];
Parameter validation for container.

Sqf

Apply
if (isNull _container) exitWith {
    [[], [], [], []]
};
Returns empty array if container is null.

Sqf

Apply
private _magazines = magazinesAmmoCargo _container;
private _weapons = weaponsItemsCargo _container;
private _itemsCargo = getItemCargo _container;
private _containerClassNames = (everyContainer _container) apply {_x select 0};
private _items = [];
Gets all cargo types from container:

Magazine ammo cargo
Weapon items cargo
Item cargo
Nested container classnames
Initializes items array
Sqf

Apply
if (count _itemsCargo > 0) then {
    {
        if !(_x in _containerClassNames) then {
            _items pushBack [_x, (_itemsCargo select 1) select _forEachIndex];
        };
    } forEach (_itemsCargo select 0);
};
Processes item cargo, filtering out container classnames.

Sqf

Apply
private _containerItems = [];
private _everyContainer = everyContainer _container;
{
    _x params ["_classname", "_obj"];

    _containerItems pushBack [_classname, _obj call HALs_store_fnc_getContainerCargo];
} forEach _everyContainer;
Recursively processes nested containers.

Sqf

Apply
[_magazines, _items, _weapons, _containerItems]
Returns structured data with all items. Where it leads: Used by container management functions to retrieve container contents Depends on: HALs_store_fnc_getContainerCargo (recursive call) This function retrieves complete container inventory including nested items. Requirements: Valid container object

Function Name: HALs_store_fnc_getContainerItems.sqf What it does: Returns all items (as a list) in a container, including nested containers. How it does that:

Validates container parameter
Gets items from different cargo types:
Backpack cargo
Magazine cargo
Weapon cargo
Item cargo
Processes nested containers recursively Step-by-step breakdown:
Sqf

Apply
params [
    ["_container", objNull, []]
];
Parameter validation for container.

Sqf

Apply
private _containerItems = [];
if (isNull _unit) exitWith {_containerItems};
Initializes items array and exits if container is null.

Sqf

Apply
private _backpack = backpackCargo _container;
if (count _backpack > 0) then {_containerItems append _backpack};
Gets backpack items and adds to list.

Sqf

Apply
private _magazines = magazineCargo _container;
if (count _magazines > 0) then {_containerItems append _magazines};
Gets magazine items and adds to list.

Sqf

Apply
private _weapons = weaponsItemsCargo _container;
if (count _weapons > 0) then {
    {
        {
            if (_x isEqualType []) then {
                _containerItems pushBack (_x select 0)
            } else {
                _containerItems pushBack _x
            };
        } forEach (_x select {count _x > 0});
    } forEach _weapons;
};
Gets weapon items and adds to list.

Sqf

Apply
private _items = getItemCargo _container;
if (count _items > 0) then {
    {
        private _amt  = (_items select 1) select _forEachIndex;

        for [{private _i = 0}, {_i < _amt}, {_i = _i + 1}] do {
            _containerItems pushBack _x;
        };
    } forEach (_items select 0);
};
Gets regular items and adds multiple instances based on quantity. Where it leads: Used by item management functions to get complete container contents Depends on: None (uses standard Arma 3 methods) This function provides a complete list of all items in a container. Requirements: Valid container object

Function Name: HALs_store_fnc_getPlayerCargo.sqf What it does: Returns the items equipped by a unit and those stored in its uniform, vest, and backpack. How it does that:

Validates unit parameter
Gets items from:
Unit's uniform container
Unit's vest container
Unit's backpack container
Gets items from unit's equipment (weapons, gear) Step-by-step breakdown:
Sqf

Apply
params [
    ["_unit", objNull, []]
];
Parameter validation for unit.

Sqf

Apply
private _list = [];
if (isNull _unit) exitWith {_list};
Initializes list and exits if unit is null.

Sqf

Apply
_list append ([_unit] call HALs_store_fnc_getPlayerItems);
_list append ([uniformContainer _unit] call HALs_store_fnc_getContainerItems);
_list append ([vestContainer _unit] call HALs_store_fnc_getContainerItems);
_list append ([backpackContainer _unit] call HALs_store_fnc_getContainerItems);
Appends all items:

Unit's equipped items
Uniform container items
Vest container items
Backpack container items Where it leads: Used by inventory management functions to get complete player inventory Depends on: HALs_store_fnc_getPlayerItems, HALs_store_fnc_getContainerItems This function provides complete player inventory including all containers. Requirements: Valid unit object
Function Name: HALs_store_fnc_getPlayerItems.sqf What it does: Returns all items equipped by a unit, including weapons, gear, and assigned items. How it does that:

Validates unit parameter
Gets all equipment and assigned items from unit:
Uniform, vest, backpack
Primary, secondary, handgun weapons
Weapon magazines and items
Goggles, headgear
Assigned items Step-by-step breakdown:
Sqf

Apply
params [
    ["_unit", objNull, []]
];
Parameter validation for unit.

Sqf

Apply
private _items = [];
if (isNull _unit) exitWith {_items};
Initializes items array and exits if unit is null.

Sqf

Apply
private _slots = [];
_slots pushBack [uniform _unit, vest _unit, backpack _unit];
_slots pushBack [primaryWeapon _unit];
_slots pushBack primaryWeaponMagazine _unit;
_slots pushBack primaryWeaponItems _unit;
_slots pushBack [secondaryWeapon _unit];
_slots pushBack secondaryWeaponMagazine _unit;
_slots pushBack secondaryWeaponItems _unit;
_slots pushBack [handgunWeapon _unit];
_slots pushBack handgunMagazine _unit;
_slots pushBack handgunItems _unit;
_slots pushBack [goggles _unit, headgear _unit];
_slots pushBack assignedItems _unit;
Organizes unit equipment into slots:

Uniform, vest, backpack
Primary weapon and its items
Secondary weapon and its items
Handgun and its items
Goggles, headgear
Assigned items
Sqf

Apply
{
	{_items pushBack _x} forEach (_x select {count _x > 0});
} forEach _slots;
Flattens slot arrays into single items list. Where it leads: Used by inventory management functions to get unit's equipped items Depends on: None (uses standard Arma 3 unit methods) This function provides a complete list of all items equipped by a unit. Requirements: Valid unit object

Function Name: HALs_store_fnc_removeContainerItem.sqf What it does: Removes an item from a container's cargo, handling different item types. How it does that:

Validates container and classname parameters
Retrieves existing container cargo data
Searches for and removes item from appropriate cargo type
Rebuilds container with updated cargo Step-by-step breakdown:
Sqf

Apply
params [
    ["_container", objNull, [objNull]],
    ["_classname", "", [""]]
];
Parameter validation for container and classname.

Sqf

Apply
if (isNull _container) exitWith {false};
if (_classname isEqualTo "") exitWith {false};
Exits early if container is null or classname is empty.

Sqf

Apply
private _found = false;
private _data = (_container call HALs_store_fnc_getContainerCargo);
_data params ["_magazines", "_items", "_weapons", "_containers"];
Retrieves current container cargo and unpacks data.

Sqf

Apply
try {
    {
        if ((_x select 0) isEqualTo _classname) then {
            _magazines deleteAt _forEachIndex;
            throw true;
        };
    } forEach _magazines;
Searches for and removes magazine item.

Sqf

Apply
private _curIndex = 0;
    {
        _curIndex = _forEachIndex;
        _weapon = _x;
        {
            private _wepClassname = if (_x isEqualType []) then {_x select 0} else {_x};

            if (_classname isEqualTo _wepClassname) then {
                if (_forEachIndex isEqualTo 0) then {
                    _weapon set [_forEachIndex, ""];

                    private _mags = _weapon select [4, 2];
                    {
                        _magazines pushBack _x
                    } forEach (_mags select {count _x > 0});

                    private _itemArr = _weapon;
                    {
                        if (!(_forEachIndex in [0, 4, 5]) && {count _x > 0}) then {
                            _items pushBack [_x, 1];
                        };
                    } forEach _itemArr;

                    _weapons set [_curIndex, []];
                } else {
                    _weapon set [_forEachIndex, ["", []] select (_forEachIndex in [4, 5])];
                };

                throw true;
            };
        } forEach _weapon;
    } forEach _weapons;
Searches for and removes weapon item, handling weapon-specific logic.

Sqf

Apply
{
        if ((_x select 0) isEqualTo _classname) then {
            private _amt = _x select 1;

            if (_amt isEqualTo 1) then {
                _items deleteAt _forEachIndex;
            } else {
                (_items select _forEachIndex) set [1, _amt - 1];
            };

            throw true;
        };
    } forEach _items;
Searches for and removes regular item.

Sqf

Apply
} catch {
    [_container] call HALs_store_fnc_clearContainerCargo;
    [_container, _data] call HALs_store_fnc_addContainerCargo;

    _found = _exception;
};
Rebuilds container with updated cargo if item was found. Where it leads: Used by sell functions to remove items from containers Depends on: HALs_store_fnc_getContainerCargo, HALs_store_fnc_clearContainerCargo, HALs_store_fnc_addContainerCargo This function removes specific items from containers. Requirements: Valid container object

Function Name: HALs_store_fnc_removePlayerItem.sqf What it does: Removes an equipped item from a unit, handling different item types. How it does that:

Validates unit and classname parameters
Removes items from unit's equipment based on item type:
Uniform, vest, backpack
Goggles, headgear
Weapons (primary, secondary, handgun)
Assigned items
Weapon attachments Step-by-step breakdown:
Sqf

Apply
params [
    ["_unit", objNull, []],
    ["_classname", "", [""]]
];
Parameter validation for unit and classname.

Sqf

Apply
if (isNull _unit) exitWith {false};
if (_classname isEqualTo "") exitWith {false};
Exits early if unit is null or classname is empty.

Sqf

Apply
private _classnameLower = toLowerANSI _classname;
Converts classname to lowercase for case-insensitive comparison.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI uniform _unit) exitWith {
    removeUniform _unit; true
};
Removes uniform if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI vest _unit) exitWith {
    removeVest _unit; true
};
Removes vest if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI backpack _unit) exitWith {
    removeBackpackGlobal _unit; true
};
Removes backpack if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI goggles _unit) exitWith {
    removeGoggles _unit; true
};
Removes goggles if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI headgear _unit) exitWith {
    removeHeadgear _unit; true
};
Removes headgear if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI binocular _unit) exitWith {
    _unit removeWeaponGlobal _classname; true;
};
Removes binocular if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI primaryWeapon _unit) exitWith {
    _unit removeWeaponGlobal _classname; true
};
Removes primary weapon if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI secondaryWeapon _unit) exitWith {
    _unit removeWeaponGlobal _classname; true
};
Removes secondary weapon if matches.

Sqf

Apply
if (_classnameLower isEqualTo toLowerANSI handgunWeapon _unit) exitWith {
    _unit removeWeaponGlobal _classname; true
};
Removes handgun if matches.

Sqf

Apply
// Check item arrays
if (_classnameLower in ((assignedItems _unit) apply {tolower _x})) exitWith {
    _unit unlinkItem _classname; true;
};
Removes assigned item if matches.

Sqf

Apply
// Primary weapon
if (_classnameLower in ((primaryWeaponItems _unit) apply {tolower _x})) exitWith {
    _unit removePrimaryWeaponItem _classname; true;
};
Removes primary weapon attachment if matches.

Sqf

Apply
if (_classnameLower in ((primaryWeaponMagazine _unit) apply {tolower _x})) exitWith {
    _unit removePrimaryWeaponItem _classname; true;
};
Removes primary weapon magazine if matches.

Sqf

Apply
// Handgun Weapon
if (_classnameLower in ((handgunItems _unit) apply {tolower _x})) exitWith {
    _unit removeHandgunItem _classname; true;
};
Removes handgun attachment if matches.

Sqf

Apply
if (_classnameLower in ((handgunMagazine _unit) apply {tolower _x})) exitWith {
    _unit removeHandgunItem _classname; true;
};
Removes handgun magazine if matches.

Sqf

Apply
// Secondary Weapon
if (_classnameLower in ((secondaryWeaponItems _unit) apply {tolower _x})) exitWith {
    _unit removeSecondaryWeaponItem _classname; true;
};
Removes secondary weapon attachment if matches.

Sqf

Apply
if (_classnameLower in ((secondaryWeaponMagazine _unit) apply {tolower _x})) exitWith {
    _unit removeSecondaryWeaponItem _classname; true;
};
Removes secondary weapon magazine if matches.

Sqf

Apply
false
Returns false if no item was removed. Where it leads: Used by sell functions to remove items from units Depends on: None (uses standard Arma 3 unit methods) This function removes specific items from unit's equipment. Requirements: Valid unit object

Function Name: HALs_store_fnc_addActionTrader.sqf What it does: Adds an open store action to a trader object for players to interact with. How it does that:

Validates trader parameter
Checks if trader is already initialized
Adds hold action to trader for opening store
If target is not false, adds action to specific targets Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_target", false, [0, objNull, "", sideUnknown, grpNull, [], false]]
];
Parameter validation for trader and target.

Sqf

Apply
if (isNull _trader) exitWith {};
if (isNil {_trader getVariable "HALs_store_trader_type"}) exitWith {};
Exits early if trader is null or not initialized.

Sqf

Apply
if (_target isEqualType false) then {
	if (hasInterface) then {
		[
			_trader,
			format [localize "STR_HALS_STORE_OPEN_ACTION", _trader getVariable ["HALs_store_name", localize "STR_HALS_STORE_ACTION"]],
			"\a3\Ui_F_Oldman\Data\IGUI\Cfg\HoldActions\holdAction_market_ca.paa",
			"\a3\Ui_F_Oldman\Data\IGUI\Cfg\HoldActions\holdAction_market_ca.paa",
			"alive _target && _this distance _target < 3 && isNull objectParent _this",
			"_this distance _target < 3",
			{},
			{},
			{
				params ["_trader", "_caller", "_actionId", "_arguments"];

				[_trader] call HALs_store_fnc_openStore;
			}, {}, [], 0.5, nil, false, false
		] call BIS_fnc_holdActionAdd;
	};
};
Adds hold action for local players:

Sets action text using localized string
Uses store icon
Checks distance and alive status
Calls openStore function when activated
Sqf

Apply
else {
	if (isServer) then {
		[_trader] remoteExecCall ["HALs_store_fnc_addActionTrader", _target, _trader];
	};
};
For remote targets, calls remote execution on server. Where it leads: Called by addTrader to set up trader interaction Depends on: HALs_store_fnc_openStore This function enables players to interact with traders. Requirements: Valid trader object

Function Name: HALs_store_fnc_addTrader.sqf What it does: Initializes a trader object with its type and stock information. How it does that:

Validates trader parameters
Checks if trader is already initialized
Validates trader type
Processes categories and items for trader
Sets up trader variables and actions Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_traderType", [], [[]]],
	["_target", 0, [0, objNull, "", sideUnknown, grpNull, []]]
];
Parameter validation for trader, type, and target.

Sqf

Apply
if (!isServer) exitWith {false};
Exits early if not on server.

Sqf

Apply
try {
	if (!isNil {_trader getVariable "HALs_store_trader_type"}) then {throw ["Trader already initialised", __LINE__]};
	if (isNull _trader) then {throw ["Trader cannot be null", __LINE__]};
	if (!alive _trader) then {throw ["Trader cannot be dead", __LINE__]};
	if (isPlayer _trader) then {throw ["Trader cannot be a player", __LINE__]};
	if (_traderType isEqualTo []) then {throw ["No Trader type", __LINE__]};
Multiple validation checks for trader.

Sqf

Apply
{
		if (!isClass (configFile >> "cfgHALsAddons" >> "cfgHALsStore" >> "stores" >> _x)) then {
			throw ["Invalid Trader type", __LINE__];
			Error_2("Broken Entry: %1. Full Entry: %2", _x, _traderType);
		};
	} forEach _traderType;
Validates trader types exist in config.

Sqf

Apply
private _categories = [];
Initializes categories array.

Sqf

Apply
{
		private _categoryAdd = [
			getArray (configFile >> "cfgHALsAddons" >> "cfgHALsStore" >> "stores" >> _x >> "categories"),
			{getText (configFile >> "cfgHALsAddons" >> "cfgHALsStore" >> "categories" >> _x >> "displayname")},
			true
		] call HALs_fnc_sortArray;
		// _categories pushBack _categoryAdd;
		_categories = _categories + _categoryAdd;
	} forEach _traderType;
Collects categories from all trader types.

Sqf

Apply
Verbose_1("_categories:\n%1", _categories);
Logs categories for debugging.

Sqf

Apply
private _classes = [];
private _stocks = [];
Initializes arrays for item classes and stock information.

Sqf

Apply
{
		private _category = _x;
		_configCategory = configFile >> "cfgHALsAddons" >> "cfgHALsStore" >> "categories" >> _category;
		_items = "true" configClasses (_configCategory) apply {configName _x};

		_duplicateClass = {_classes find _x > -1} count _items > 0;
		_duplicateItem = !(count (_items arrayIntersect _items) isEqualTo count _items);
		// if (_duplicateClass || _duplicateItem) then {
			// throw [format ["Duplicate items [category: %1, type: %2]", toUpper _x, toUpper (_traderType select 0)], __LINE__];
		// };

		{
			_classes pushBack _x;
			_stocks pushBack toLower _x;
			_stocks pushBack (getNumber (_configCategory >> _x >> "stock") max 0);
		} forEach _items;
	} forEach _categories;
Processes items for all categories:

Gets items from category
Checks for duplicates
Adds items and stock to arrays
Sqf

Apply
_trader setVariable ["HALs_store_trader_type", _traderType, true];
_trader setVariable ["HALs_store_trader_stocks", _stocks, true];
Sets trader variables for type and stock.

Sqf

Apply
if !(typeOf _trader isKindOf ["CAManBase", configFile >> "cfgVehicles"]) then {
	clearMagazineCargoGlobal _trader;
	clearWeaponCargoGlobal _trader;
	clearItemCargoGlobal _trader;
	clearBackpackCargoGlobal _trader;
};
Clears cargo for non-human traders.

Sqf

Apply
_trader setVariable ["HALs_store_name", getText (configFile >> "cfgHALsAddons" >> "cfgHALsStore" >> "stores" >> (_traderType select 0) >> "displayName"), true];
Sets trader display name.

Sqf

Apply
[_trader, _target] call HALs_store_fnc_addActionTrader;
Adds action to trader.

Sqf

Apply
true
Returns success. Where it leads: Called to initialize trader objects Depends on: HALs_store_fnc_addActionTrader, HALs_fnc_sortArray This function sets up traders for interaction. Requirements: Valid trader object, server execution

Function Name: HALs_store_fnc_initServer.sqf What it does: Initializes server-side components for HALs Store module. How it does that:

Validates server execution
Sets up module settings from config
Creates helper functions for nearby vehicle detection Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_types", ["LandVehicle", "Air", "Ship", "ReammoBox_F"], [[]]],
	["_radius", HALs_store_containerRadius, [0]]
];
Parameter validation for trader, types, and radius.

Sqf

Apply
if (!isServer) exitWith {};
if (!isNil "HALs_store_debug") exitWith {};
Exits early if not on server or already initialized.

Sqf

Apply
[
	["CfgHALsStore"],
	"HALs_store_",
	[
		["containerRadius", 30, {_this max 0}, true],
		["containerTypes", ["LandVehicle", "Air", "Ship", "ReammoBox_F"], {_this}, true],
		["sellFactor", 1, {_this max 0 min 1}, true],
		["debug", 0, {_this isEqualTo 1}]
	]
] call HALs_fnc_getModuleSettings;
Sets up module settings from config:

containerRadius: radius for nearby containers
containerTypes: types of containers to search
sellFactor: factor for sell prices
debug: debug mode flag
Sqf

Apply
missionNamespace setVariable ["HALs_store_getNearbyVehicles", compileFinal '
	params [
		["_trader", objNull, [objNull]],
		["_types", ["LandVehicle", "Air", "Ship", "ReammoBox_F"], [[]]],
		["_radius", HALs_store_containerRadius, [0]]
	];

	private _vehicles = nearestObjects [_trader, _types, _radius, true];
	_vehicles select {local _x && {abs speed _x < 1 && {alive _x && isNil {_x getVariable "HALs_store_trader_type"}}}};
', true];
Creates function to find nearby vehicles for selling:

Gets vehicles within radius
Filters for local, stationary, alive vehicles without trader variables Where it leads: Called during server initialization Depends on: HALs_fnc_getModuleSettings This function sets up server configuration and helper functions. Requirements: Server execution
Function Name: HALs_store_fnc_purchase.sqf What it does: Handles purchase transactions on the server, updating funds and stock. How it does that:

Validates parameters and execution context
Gets current trader and stock
Calculates maximum items that can be added
Validates funds and item compatibility
Adds items to container and updates stock/funds Step-by-step breakdown:
Sqf

Apply
params [
	["_unit", objNull, [objNull]],
	["_classname", "", [""]],
	["_price", 0, [0]],
	["_amt", 0, [0]],
	["_container", objNull, [objNull]],
	["_equip", false, [true]]
];
Parameter validation for all parameters.

Sqf

Apply
if (!isServer) exitWith {};
if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};
if (_amt < 1) exitWith {};
if (_price < 0) exitWith {};
Multiple validation checks.

Sqf

Apply
try {
	// Fetch current trader
	private _trader = _unit getVariable ["HALs_store_trader_current", objNull];
	if (isNull _trader) then {throw [""]};
Gets current trader from unit variable.

Sqf

Apply
// Fetch stock
	private _stock = [_trader, _classname] call HALs_store_fnc_getTraderStock;
	if (_stock < 1) then {throw [localize "STR_HALS_STORE_ITEM_UNAVALIABLE"]};
Gets trader stock and checks availability.

Sqf

Apply
// Calculate how many items the container can actually hold
	private _amtMax = [_container, _classname, _amt, true] call HALs_store_fnc_canAddItem;
	if (_amtMax > _stock) then {throw [localize "STR_HALS_STORE_ITEM_OUTOFSTOCK"]};
Calculates maximum items that can be added and checks stock.

Sqf

Apply
// Calculate predicted cost
	private _price = _price max 0;
	private _money = [_unit] call HALs_money_fnc_getFunds;
	private _sale = 0 max (1 - (_trader getVariable ["HALs_store_trader_sale", 0])) min 1;
	private _total = _price * _sale * _amt;
	if (_total > _money) then {throw [localize "STR_HALS_STORE_ITEM_TOOEXPENSIVE"]};
Calculates cost with sale discount and checks funds.

Sqf

Apply
// Variable to track how many items were added
	private _amtAdded = 0;
Initializes added items counter.

Sqf

Apply
// Equip item as required
	if (_equip && {[_unit, _classname] call HALs_store_fnc_canEquipItem}) then {
		private _equipped = [_unit, _classname] call HALs_store_fnc_equipItem;

		// Item was equipped
		if (_equipped) then {
			_amtAdded = _amtAdded + 1;

			// Additional items were requested
			if ((_amt - 1) > 0) then {
				// Can't add the additional items
				if (_amtMax isEqualTo 0) then {
					private _msg = format ["%1 %2", localize "STR_HALS_STORE_ITEM_NOCARGOSPACE", "for additional items!"];

					[_msg, "FD_CP_NOT_CLEAR_F"] remoteExecCall ["HALs_store_fnc_systemChat", _unit];
				} else {
					private _amtToAdd = _amtMax min (_amt - 1);
					_amtAdded = _amtAdded + _amtToAdd;

					[_container, _classname, _amtToAdd] call HALs_store_fnc_addItemCargo;
				};
			};
		} else {
			throw [localize "STR_HALS_STORE_ITEM_NOEQUIP"]
		};
	} else {
		if (_amtMax isEqualTo 0) then {
			throw [localize "STR_HALS_STORE_ITEM_NOCARGOSPACE"]
		} else {
			_amtAdded = _amtAdded + _amtMax;
			[_container, _classname, _amtMax] call HALs_store_fnc_addItemCargo;
		};
	};
Handles item equipping and adding:

If equipping and possible, equips item
Adds additional items if possible
Otherwise, adds items to container directly
Sqf

Apply
// Calculate actual cost
	_total = _price * _sale * _amtAdded;

	// Update unit's funds and trader's stock
	[_trader, _classname, -_amtAdded] call HALs_store_fnc_updateStock;
	[_unit, -_total] call HALs_money_fnc_addFunds;
Updates stock and funds.

Sqf

Apply
// Create message to display to _unit
	private _message = format [
		"x%1 %2(s) %3 for %4 %5.", _amtAdded,
		[(_classname call HALs_fnc_getConfigClass) >> "displayName", ""] call HALs_fnc_getConfigValue,
		localize "STR_HALS_STORE_ITEM_PURCHASED",
		_total, 
		A3A_faction_civ get "currencySymbol"
	];
	
	// Log purchase
	if (HALs_store_debug) then {
		private _log = format ["%2(%1) %3 from (%4).", name _unit, getPlayerUID _unit, _message, _trader];
		[_log] call HALs_fnc_log;
	};

	throw [_message, "FD_CP_CLEAR_F"];
} catch {
	_exception params [
		["_message", ""],
		["_sound", "FD_CP_NOT_CLEAR_F", [""]]
	];

	if (count _message > 0) then {
		[_message, _sound] remoteExecCall ["HALs_store_fnc_systemChat", _unit];
	};
};
Creates success message and logs purchase, handles errors. Where it leads: Called when players purchase items Depends on: HALs_store_fnc_getTraderStock, HALs_store_fnc_canAddItem, HALs_store_fnc_canEquipItem, HALs_store_fnc_equipItem, HALs_store_fnc_updateStock, HALs_money_fnc_getFunds, HALs_money_fnc_addFunds, HALs_store_fnc_systemChat This function processes all purchase transactions. Requirements: Server execution, valid unit, container, and item

Function Name: HALs_store_fnc_sell.sqf What it does: Handles sell transactions on the server, updating funds and stock. How it does that:

Validates parameters and execution context
Gets current trader and stock
Checks if trader will buy item
Validates item is not forbidden
Removes items from container and updates stock/funds Step-by-step breakdown:
Sqf

Apply
params [
	["_unit", objNull, [objNull]],
	["_classname", "", [""]],
	["_price", 0, [0]],
	["_amt", 0, [0]],
	["_container", objNull, [objNull]]
];
Parameter validation for all parameters.

Sqf

Apply
if (!isServer) exitWith {};
if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};
if (_amt < 1) exitWith {};
if (_classname isEqualTo "") exitWith {};
if (isNull _container) exitWith {};
if (_price < 0) exitWith {};
Multiple validation checks.

Sqf

Apply
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"
Includes UI definitions.

Sqf

Apply
try {
	// Fetch current trader
	private _trader = _unit getVariable ["HALs_store_trader_current", objNull];
	if (isNull _trader) then {throw [""]};
Gets current trader from unit variable.

Sqf

Apply
private _forbiddenItem_is_unlimited = 0;
Initializes forbidden item flag.

Sqf

Apply
if (_classname in A3U_forbiddenItems) then {
		private _is_forbiddenItem = isClass (configFile >> "A3U" >> "forbiddenItems" >> _classname);

		Debug_1("%1 is a forbidden item.", _classname);

		if (_is_forbiddenItem) then {
			_is_forbiddenItemUnlimited = (getNumber (configFile >> "A3U" >> "forbiddenItems" >> _classname >> "unlimited"));
		};
	};
Checks if item is forbidden.

Sqf

Apply
    // Check if the trader will buy this item
	private _stock = [_trader, _classname] call HALs_store_fnc_getTraderStock;
	if (_stock isEqualTo -1) then { // && {_is_forbiddenItem isEqualTo false}
		// Try parent
		_parent = _classname call HALs_store_fnc_getParentClassname;
		_stock = [_trader, _parent] call HALs_store_fnc_getTraderStock;
		if (_stock isEqualTo -1) then {
			throw ["The trader will not buy this item."]
		};
	};
Checks if trader will buy item, tries parent if needed.

Sqf

Apply
["buttonInvToJNA"] call jn_fnc_arsenal;
Calls JNA arsenal function.

Sqf

Apply
private _unlockedItems = ((jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_PRIMARYWEAPON) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HANDGUN) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_SECONDARYWEAPON) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL) +
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOTHROW) +
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BACKPACK) +
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GOGGLES) +
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_MAP) +
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_GPS) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_RADIO) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_COMPASS) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_WATCH) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMACC) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMMUZZLE) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMBIPOD) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_BINOCULARS) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_CARGOMISC) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_UNIFORM) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_ITEMOPTIC) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_NVGS) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_HEADGEAR) + 
		(jna_dataList select IDC_RSCDISPLAYARSENAL_TAB_VEST)
	) select {(_x select 1) == -1 || {(_x select 1) >= minWeaps && {_is_forbiddenItemUnlimited isEqualTo 0}}}) apply {_x select 0};
Creates list of unlocked items.

Sqf

Apply
Debug_2("%1 unlock state: %2", _classname, (_classname in _unlockedItems));
Logs unlock state.

Sqf

Apply
if (_classname in _unlockedItems) then {
		throw ["The trader is not interested in this item, no deal."]
	};
Throws error if item is unlocked.

Sqf

Apply
_unlockedItems = nil;
Clears unlocked items variable.

Sqf

Apply
    // Check that player has the item
    // Remove items from unit
	private _amount = 0;
	private _continue = true;

	for [{private _i = 0}, { _i < floor _amt && _continue}, {_i = _i + 1}] do {
		private _removed = [_container, _classname] call HALs_store_fnc_removeContainerItem;
		if (_removed) then {_amount = _amount + 1} else {_continue = false};
	};
Removes items from container.

Sqf

Apply
if (_amount < 1) then {throw ["Unable to sell item."]};
Throws error if no items removed.

Sqf

Apply
// Update unit's funds and trader's stock
	private _sellFactor = HALs_store_sellFactor min 1 max 0;
	private _total = (_price max 0) * _amount * _sellFactor;
	[_trader, _classname, _amount] call HALs_store_fnc_updateStock;
	[_unit, _total] call HALs_money_fnc_addFunds;
Updates stock and funds.

Sqf

Apply
private _message = format [
		"x%1 %2(s) sold for %3 %4.", 
		_amount, 
		[(_classname call HALs_fnc_getConfigClass) >> "displayName", ""] call HALs_fnc_getConfigValue, 
		_total, 
		A3A_faction_civ get "currencySymbol"
	];

	// Log sell
	if (HALs_store_debug) then {
		private _log = format ["%2(%1) %3 to (%4).", name _unit, getPlayerUID _unit, _message, _trader];
		[_log] call HALs_fnc_log;
	};

	throw [_message, "FD_CP_CLEAR_F"];
} catch {
	_exception params [
		["_message", ""],
		["_sound", "FD_CP_NOT_CLEAR_F", [""]]
	];

	if (count _message > 0) then {
		[_message, _sound] remoteExecCall ["HALs_store_fnc_systemChat", _unit];
	};
};
Creates success message and logs sale, handles errors. Where it leads: Called when players sell items Depends on: HALs_store_fnc_getTraderStock, HALs_store_fnc_removeContainerItem, HALs_store_fnc_updateStock, HALs_money_fnc_addFunds, HALs_store_fnc_systemChat This function processes all sell transactions. Requirements: Server execution, valid unit, container, and item

Function Name: HALs_store_fnc_getTraderStock.sqf What it does: Gets a trader's stock for a specific item. How it does that:

Validates trader and classname parameters
Retrieves trader's stock array
Finds item in stock array
Returns item's stock value Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_classname", "", [""]]
];
Parameter validation for trader and classname.

Sqf

Apply
private _stocks = _trader getVariable ["HALs_store_trader_stocks", []];
private _idx = _stocks find (toLower _classname);
Retrieves stock array and finds item index.

Sqf

Apply
if (_idx isEqualTo -1) exitWith {-1};
(_stocks select (_idx + 1)) max 0
Returns stock value or -1 if not found. Where it leads: Used by purchase and sell functions to check stock levels Depends on: None (uses standard Arma 3 variable methods) This function retrieves specific item stock from trader. Requirements: Valid trader object

Function Name: HALs_store_fnc_setTraderStock.sqf What it does: Sets a trader's stock for a specific item. How it does that:

Validates parameters and execution context
Retrieves trader's stock array
Finds item in stock array
Updates item's stock value Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_classname", "", [""]],
	["_amount", 0, [0]]
];
Parameter validation for trader, classname, and amount.

Sqf

Apply
if (!isServer) exitWith {false};
if (_classname isEqualTo "") exitWith {false};
if (_amount isEqualTo 0) exitWith {false};
Validation checks.

Sqf

Apply
private _stocks = _trader getVariable ["HALs_store_trader_stocks", []];
private _idx = _stocks find (toLower _classname);
Retrieves stock array and finds item index.

Sqf

Apply
if (_idx isEqualTo -1) exitWith {false};
private _stock = _stocks select (_idx + 1);
_stocks set [(_idx + 1), 0 max (_stock + _amount)];
_trader setVariable ["HALs_store_trader_stocks", _stocks, true];
Updates stock value and sets variable.

Sqf

Apply
true
Returns success. Where it leads: Used by updateStock to modify trader stock Depends on: None (uses standard Arma 3 variable methods) This function updates trader stock values. Requirements: Server execution, valid trader object

Function Name: HALs_store_fnc_updateStock.sqf What it does: Updates a store's stock for a desired item and notifies players. How it does that:

Validates parameters
Calls setTraderStock to update stock
Notifies players using remote execution Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_classname", "", [""]],
	["_amount", 0, [0]]
];
Parameter validation for trader, classname, and amount.

Sqf

Apply
private _stockAdded = [_trader, _classname, _amount] call HALs_store_fnc_setTraderStock;
if (_stockAdded) then {
	// Fetch all players using the store
	private _players = allPlayers select {(_x getVariable ["HALs_store_trader_current", objNull]) isEqualTo _trader} apply {owner _x};

	[] remoteExecCall ["HALs_store_fnc_update", _players, false];
};
Updates stock and notifies players if change occurred. Where it leads: Called by purchase and sell functions to update stock Depends on: HALs_store_fnc_setTraderStock, HALs_store_fnc_update This function updates stock and notifies clients. Requirements: Server execution, valid trader object

Function Name: HALs_store_fnc_initClient.sqf What it does: Initializes client-side components for HALs Store module. How it does that:

Validates interface availability
Calls get item stats function Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]]
];
Parameter validation for trader.

Sqf

Apply
if (!hasInterface) exitWith {};
if (isNull _trader) exitWith {};
if (isNil {_trader getVariable "HALs_store_trader_type"}) exitWith {};
Validation checks.

Sqf

Apply
[] call HALs_store_fnc_getItemStats;
Calls get item stats function. Where it leads: Called during client initialization Depends on: HALs_store_fnc_getItemStats This function initializes client-side functionality. Requirements: Client interface

Function Name: HALs_store_fnc_openStore.sqf What it does: Opens the store dialog for a player interacting with a trader. How it does that:

Validates parameters
Sets current trader for player
Creates store dialog Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]]
];
Parameter validation for trader.

Sqf

Apply
if (!hasInterface) exitWith {};
if (isNull _trader) exitWith {};
if (isNil {_trader getVariable "HALs_store_trader_type"}) exitWith {};
Validation checks.

Sqf

Apply
player setVariable ["HALs_store_trader_current", _trader, true];
Sets current trader for player.

Sqf

Apply
createDialog "RscDisplayStore";
Creates store dialog. Where it leads: Called when players interact with traders Depends on: None (uses standard Arma 3 dialog methods) This function opens the store interface. Requirements: Client interface, valid trader object

Function Name: HALs_store_fnc_systemChat.sqf What it does: Displays a system chat message on client. How it does that:

Validates parameters
Plays sound if specified
Formats and displays message Step-by-step breakdown:
Sqf

Apply
params [
	["_message", "", [[], ""]],
	["_sound", "", [""]]
];
Parameter validation for message and sound.

Sqf

Apply
if (count _sound > 0 && {isClass (configfile >> "CfgSounds" >> _sound)}) then {
	playSound _sound;
};
Plays sound if valid.

Sqf

Apply
if (_message isEqualType []) then {
	_message = format _message;
};
Formats message if array.

Sqf

Apply
systemChat _message;
Displays system chat message. Where it leads: Used by purchase/sell functions to display messages Depends on: None (uses standard Arma 3 methods) This function displays messages to players. Requirements: Client interface

Function Name: HALs_store_fnc_eachFrame.sqf What it does: Periodically checks if player's money or items have changed for UI updates. How it does that:

Validates interface and initialization
Sets up update tracking variables
Adds mission event handler for frame updates
Checks for changes in money or inventory
Updates UI when changes occur Step-by-step breakdown:
Sqf

Apply
if (!hasInterface) exitWith {};
if (!isNil {missionNamespace getVariable "#HALs_store_money"}) exitWith {};
Validation checks.

Sqf

Apply
missionNamespace setVariable ["HALs_store_updated", false];
missionNamespace setVariable ["#HALs_store_money", [player] call HALs_money_fnc_getFunds];
missionNamespace setVariable ["#HALs_store_containers", [uniform player, vest player, backpack player]];
missionNamespace setVariable ["#HALs_store_nextUpdateTick", diag_tickTime];
Initializes tracking variables.

Sqf

Apply
addMissionEventHandler ["EachFrame", {
	if (isNull (uiNamespace getVariable ["HALs_store_display", displayNull])) exitWith {
		{missionNamespace setVariable [_x, nil]} forEach ["#HALs_store_nextUpdateTick", "HALs_store_updated", "#HALs_store_containers", "#HALs_store_money"];
		
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};
Sets up frame event handler for UI updates.

Sqf

Apply
if (HALs_store_updated) then {
	["update"] call  HALs_store_fnc_main;
	
	missionNamespace setVariable ["#HALs_store_money", [player] call HALs_money_fnc_getFunds];
	missionNamespace setVariable ["#HALs_store_containers", [uniform player, vest player, backpack player]];
	HALs_store_updated = false;
};
Updates UI when changes detected.

Sqf

Apply
if (diag_tickTime > missionNamespace getVariable ["#HALs_store_nextUpdateTick", diag_tickTime]) then {
	_containers = [uniform player, vest player, backpack player];
	_oldContainers = missionNamespace getVariable ["#HALs_store_containers", []];
	
	_money = [player] call HALs_money_fnc_getFunds;
	_oldMoney = missionNamespace getVariable ["#HALs_store_money", [player] call HALs_money_fnc_getFunds];

	if (_money != _oldMoney) then {
		missionNamespace setVariable ["#HALs_store_money", _money];
		HALs_store_updated = true;
	};

	if !(_containers isEqualTo _oldContainers) then {
		missionNamespace setVariable ["#HALs_store_containers", _containers];
		HALs_store_updated = true;
	};

	missionNamespace setVariable ["#HALs_store_nextUpdateTick", diag_tickTime + 0.25];
};
Checks for changes every 0.25 seconds and updates tracking. Where it leads: Called by main UI function to maintain updates Depends on: HALs_money_fnc_getFunds This function maintains UI synchronization. Requirements: Client interface

Function Name: HALs_store_fnc_main.sqf What it does: Handles the functionality of RscDisplayStore dialog. How it does that:

Processes different modes (onLoad, onUnload, onInit, update)
Sets up UI controls and event handlers
Manages item listing and display
Handles user interactions Step-by-step breakdown:
Sqf

Apply
params [
	["_mode", "onload", [""]],
	["_this", [], [[]]]
];
Parameter validation for mode and parameters.

Sqf

Apply
private _trader = player getVariable ["HALs_store_trader_current", objNull];
Gets current trader.

Sqf

Apply
switch (_mode) do {
	case ("onLoad"): {
		// ... initialization code
	};
Handles dialog load event.

Sqf

Apply
case ("onUnload"): {
	// ... cleanup code
};
Handles dialog unload event.

Sqf

Apply
case ("onInit"): {
	// ... initialization code
};
Handles dialog initialization event.

Sqf

Apply
case ("update"): {
	// ... update code
};
Handles dialog update event.

Sqf

Apply
case ("listbox"): {
	// ... listbox handling code
};
Handles listbox interactions.

Sqf

Apply
case ("combobox"): {
	// ... combobox handling code
};
Handles combobox interactions.

Sqf

Apply
case ("edit"): {
	// ... edit handling code
};
Handles edit box interactions.

Sqf

Apply
case ("button"): {
	// ... button handling code
};
Handles button interactions.

Sqf

Apply
case ("text"): {
	// ... text handling code
};
Handles text display updates.

Sqf

Apply
case "progressLoad": {
	// ... progress load handling code
};
Handles progress bar updates.

Sqf

Apply
case "progressStats": {
	// ... progress stats handling code
};
Handles progress stats updates. };


Apply
Switch statement for different dialog modes.
Where it leads:
Main UI controller function for store dialog
Depends on: Multiple other functions for different UI elements
This function is the main controller for the store interface.
Requirements:
Client interface, valid trader

Function Name: HALs_store_fnc_update.sqf
What it does:
Flags the store dialog to update for UI refresh.
How it does that:
1. Validates interface availability
2. Sets update flag
Step-by-step breakdown:
```sqf
params [
	["_trader", objNull, [objNull]]
];
Parameter validation for trader.

Sqf

Apply
if (hasInterface) then {
	HALs_store_updated = true;
};
Sets update flag. Where it leads: Called by server functions to trigger UI updates Depends on: None This function triggers UI refreshes. Requirements: Client interface

Function Name: HALs_money_fnc_addFunds.sqf What it does: Adds funds to a unit's money variable and displays notification. How it does that:

Validates execution context
Updates unit's money variable
Displays notification to player Step-by-step breakdown:
Sqf

Apply
params [
	["_unit", objNull, [objNull]],
	["_funds", 0, [0]]
];
Parameter validation for unit and funds.

Sqf

Apply
if (!local _unit) exitWith {
	[_unit, _funds] remoteExec ["HALs_money_fnc_addFunds", _unit, false]
};
Remote execution for non-local units.

Sqf

Apply
private _money = ((_unit getVariable ["moneyX", 0]) + _funds) max 0;
_money = round _money;
Calculates new money amount.

Sqf

Apply
_unit setVariable ["moneyX", _money, true];
_sign = if(_funds > 0) then {"+"} else {""};
Sets money variable and determines sign.

Sqf

Apply
_textX = format ["<br/><br/><br/><br/><br/><br/><t color='#00FF00'>%1 %2 %3</t>", _sign, _funds, A3A_faction_civ get "currencySymbol"];
[petros,"income",_textX] remoteExec ["A3A_fnc_commsMP",_unit];
Creates notification text and sends to player. Where it leads: Called by money functions to add funds Depends on: None This function manages unit money. Requirements: Valid unit object

Function Name: HALs_money_fnc_getFunds.sqf What it does: Returns a unit's current money amount. How it does that:

Gets money variable from unit
Returns value or 0 if not set Step-by-step breakdown:
Sqf

Apply
params [
	["_unit", objNull, [objNull]]
];
Parameter validation for unit.

Sqf

Apply
(_unit getVariable ["moneyX", 0])
Returns money variable or 0. Where it leads: Called by purchase functions to check funds Depends on: None This function retrieves unit money. Requirements: Valid unit object

Function Name: HALs_money_fnc_initServer.sqf What it does: Initializes server-side money module settings. How it does that:

Validates server execution
Sets up module settings from config Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]],
	["_types", ["LandVehicle", "Air", "Ship", "ReammoBox_F"], [[]]],
	["_radius", HALs_store_containerRadius, [0]]
];
Parameter validation.

Sqf

Apply
if (!isServer) exitWith {};
if (!isNil "HALs_money_debug") exitWith {};
Validation checks.

Sqf

Apply
[
	["CfgHALsMoney"],
	"HALs_money_",
	[
		["startingFunds", 0, {_this max 0}, true],
		["oldManItemsPrice", [50, 150, 300, 600], {_this apply {_x max 0}}, true],
		["debug", 0, {_this isEqualTo 1}]
	]
] call HALs_fnc_getModuleSettings;
Sets up money module settings:

startingFunds: initial money amount
oldManItemsPrice: prices for money items
debug: debug mode flag Where it leads: Called during server initialization Depends on: HALs_fnc_getModuleSettings This function sets up money module configuration. Requirements: Server execution
Function Name: HALs_money_fnc_initClient.sqf What it does: Initializes client-side money functionality, including money pickup and display. How it does that:

Validates interface availability
Adds event handlers for money pickup
Adds money display to inventory Step-by-step breakdown:
Sqf

Apply
params [
	["_trader", objNull, [objNull]]
];
Parameter validation for trader.

Sqf

Apply
if (!hasInterface) exitWith {};
Validation check.

Sqf

Apply
// Add money when player picks up money
player addEventHandler ["Take", {
	params ["_unit", "_container", "_item"];
	
	private _money = 0;
	switch (_item) do {
		case "Money_bunch": {_money = HALs_money_oldManItemsPrice select 0};
		case "Money_roll": {_money = HALs_money_oldManItemsPrice select 1};
		case "Money_stack": {_money = HALs_money_oldManItemsPrice select 2};
		case "Money": {_money = HALs_money_oldManItemsPrice select 3};
	};

	if (_money > 0) then {
		player removeItem _item;
		[player, _money] call HALs_money_fnc_addFunds;
	};
}];
Adds event handler for money pickup:

Detects money items
Calculates value
Removes item and adds funds
Sqf

Apply
// Display money in the player's inventory
player addEventHandler ["InventoryOpened", {
	_h = [] spawn {
		disableSerialization;
		waitUntil {!isNull findDisplay 602};
		
		if (isNull (uiNamespace getVariable ["HALs_InventoryMoneyInfo", controlNull])) then {
			uiNamespace setVariable ["HALs_InventoryMoneyInfo", (findDisplay 602) ctrlCreate ["RscStructuredText", 12365]];
		};
		
		_ctrl = uiNamespace getVariable ["HALs_InventoryMoneyInfo", controlNull];
		if (!isNull _ctrl) then {
			ctrlPosition (findDisplay 602 displayCtrl 2) params ["_x", "_y", "", "_h"];
			_w = ctrlPosition (findDisplay 602 displayCtrl 111) param [2, 0];
			_ctrl ctrlSetPosition [_x - _w, _y, _w, _h];
			_ctrl ctrlCommit 0;
			_ctrl ctrlShow true;
			
			while {ctrlShown _ctrl} do {
				private _currencySymbol = if (!isNil "A3A_faction_civ") then {
					A3A_faction_civ get "currencySymbol"
				} else {
					""
				};
				_ctrl ctrlSetStructuredText parseText format [
					"<t align='right' shadow='1' font='RobotoCondensed' color='#aaffaa'>%1 %2</t>",
					([player] call HALs_money_fnc_getFunds) toFixed 2,
					_currencySymbol
				];
				
				sleep 0.5;
			};
		};
	};
}];
Adds money display to inventory:

Creates money display control
Updates money value every 0.5 seconds
Positions display correctly Where it leads: Called during client initialization Depends on: HALs_money_fnc_addFunds, HALs_money_fnc_getFunds This function manages money pickup and display. Requirements: Client interface
Function Name: HALs_fnc_log.sqf What it does: Logs a message to the .rpt file with optional script name and line number. How it does that:

Validates parameters
Formats log message with script name and line number
Writes to diag_log Step-by-step breakdown:
Sqf

Apply
params [
	["_msg", "", [""]],
	["_line", -1, [0]]
];
Parameter validation for message and line number.

Sqf

Apply
private _scriptName = if (isNil "_fnc_scriptName") then {""} else {_fnc_scriptName};
private _log = profileName + "/" + _scriptName;
_log = if (_line > -1) then {format ["%1(%2)", _scriptName, _line]} else {_scriptName};
Formats log identifier with script name and line number.

Sqf

Apply
if (count _log > 0) then {
	diag_log format ["[%1]: %2", _log, _msg];
} else {
	diag_log format ["%1", _msg];
}
Writes to diag_log with proper formatting. Where it leads: Used by other functions for logging Depends on: None This function provides logging capability. Requirements: None

Function Name: HALs_fnc_numberToString.sqf What it does: Converts a number to a string, avoiding scientific notation. How it does that:

Gets digits of number
Formats digits with commas for thousands
Returns formatted string Step-by-step breakdown:
Sqf

Apply
params [
	["_number", 0, [0]]
];
Parameter validation for number.

Sqf

Apply
private _digits = [_number] call BIS_fnc_numberDigits;
private _digitsCount = count _digits - 1;
private _modBase = _digitsCount % 3;
Gets digits and calculates formatting base.

Sqf

Apply
{
	_digits set [
		_forEachIndex,
		format [
			["%1", "%1,"] select ((_forEachIndex - _modBase) % 3 isEqualTo 0 && {_forEachIndex != _digitsCount}),
			_x
		]
	];
} forEach _digits;
Formats digits with commas.

Sqf

Apply
_digits joinString ""
Joins formatted digits into string. Where it leads: Used by other functions for number formatting Depends on: BIS_fnc_numberDigits This function formats numbers with commas. Requirements: Valid number

Function Name: HALs_fnc_getConfigClass.sqf What it does: Returns the config path of an item based on its type. How it does that:

Checks item type using config classes
Returns appropriate config path for weapon, magazine, glasses, or vehicle Step-by-step breakdown:
Sqf

Apply
params [
	["_configName", "", [""]]
];
Parameter validation for config name.

Sqf

Apply
call {
	if (isClass (configFile >> "CfgWeapons" >> _configName)) exitWith {configFile >> "CfgWeapons" >> _this};
	if (isClass (configFile >> "CfgMagazines" >> _configName)) exitWith {configFile >> "CfgMagazines" >> _this};
	if (isClass (configFile >> "CfgGlasses" >> _configName)) exitWith {configFile >> "CfgGlasses" >> _this};
	if (isClass (configFile >> "CfgVehicles" >> _configName)) exitWith {configFile >> "CfgVehicles" >> _this};
	configNull
};
Checks config classes and returns appropriate path. Where it leads: Used by other functions to get config paths Depends on: None (uses standard Arma 3 config methods) This function provides config path lookup. Requirements: Valid item classname

Function Name: HALs_fnc_getConfigValue.sqf What it does: Returns the config entry from a config path. How it does that:

Checks config type (text, number, array)
Returns appropriate value based on type Step-by-step breakdown:
Sqf

Apply
params [
	["_class", configNull, [configNull]],
	["_return", nil]
];
Parameter validation for class and return value.

Sqf

Apply
call {
	if (isText _class) exitWith {getText _class};
	if (isNumber _class) exitWith {getNumber _class};
	if (isArray _class) exitWith  {getArray _class};
	_return
};
Checks config type and returns appropriate value. Where it leads: Used by other functions to get config values Depends on: None (uses standard Arma 3 config methods) This function retrieves config values. Requirements: Valid config path

Function Name: HALs_fnc_getModuleSettings.sqf What it does: Returns and sets module settings from config. How it does that:

Builds config path from component name
Gets settings from config
Sets variables in mission namespace Step-by-step breakdown:
Sqf

Apply
params [
	["_component", [""], [[]]],
	["_prefix", "HALs_", [""]],
	["_settings", [], [[]]]
];
Parameter validation for component, prefix, and settings.

Sqf

Apply
private _configPath = configFile >> "cfgHALsAddons";
{_configPath = _configPath >> _x} forEach _component;
Builds config path.

Sqf

Apply
{
	_x params [
		["_setting", "", [""]],
		"_default",
		["_code", {_this}, [{}]],
		["_broadcast", false, [false]]
	];

	if (count _setting > 0) then {
		private _value = [_configPath >> _setting, _default] call HALs_fnc_getConfigValue;
		missionNamespace setVariable [
			format ["%1%2", _prefix, _setting],
			_value call _code,
			_broadcast
		];
	};
} forEach _settings;
Processes settings:

Gets config value
Applies code transformation
Sets variable in mission namespace Where it leads: Used by module initialization functions Depends on: HALs_fnc_getConfigValue This function manages module configuration. Requirements: Valid component path
Function Name: HALs_fnc_sortArray.sqf What it does: Sorts an array by applying a code to each element and returning sorted results. How it does that:

Applies code to each element to get sort keys
Sorts elements based on keys
Returns sorted array Step-by-step breakdown:
Sqf

Apply
params [
	["_arr", [], [[]]],
	["_code", {_x}, [{}]],
	["_order", true, [true]]
];
Parameter validation for array, code, and order.

Sqf

Apply
if !(_code isEqualTo {}) exitWith {
	private _arr = _arr apply {
		[call _code, _x]
	};

	_arr sort _order;
	_arr apply {_x select 1}
};
If code provided:

Applies code to each element
Sorts by key
Returns values
Sqf

Apply
_arr = +_arr;
_arr sort _order;
_arr
If no code, sorts array directly. Where it leads: Used by other functions to sort arrays Depends on: None This function provides flexible array sorting. Requirements: Valid array
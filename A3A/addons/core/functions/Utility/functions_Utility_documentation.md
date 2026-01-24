A3A_fnc_basicBackpack
File: A3A/addons/core/functions/Utility/fn_basicBackpack.sqf

What it does: Returns the basic/empty variant of a backpack, or the original backpack if no empty variant exists. This is essential for logistics and gear management systems where modded backpacks may not have defined empty variants, preventing errors when attempting to switch between backpack states.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_backpack"];
Extracts a single string parameter _backpack which should be a backpack class name.

Basic Backpack Resolution:

Sqf

Apply
private _basicBackpack = (_backpack call BIS_fnc_basicBackpack);
Calls the native Arma function BIS_fnc_basicBackpack to retrieve the empty variant of the given backpack class name. This function is part of Arma's standard library and handles vanilla backpacks correctly.

Empty Variant Check:

Sqf

Apply
if (_basicBackpack isEqualTo "") exitWith {
     _backpack;
};	
Checks if the returned basic backpack is an empty string (which happens when the modded backpack has no defined empty variant). If true, exits early and returns the original _backpack unchanged.

Return Basic Backpack:

Sqf

Apply
_basicBackpack;
Returns the resolved basic backpack if one was found.

Where it leads:

Called Functions:
BIS_fnc_basicBackpack: Native Arma function that returns the empty variant of a backpack class
Called By: Likely used by:
A3A_fnc_fetchRebelGear (when retrieving gear from storage)
A3A_fnc_empty (clearing backpack contents)
A3A_fnc_itemSort (sorting inventory items)
Mission systems that need to preserve backpack models while emptying contents
Global Variables Modified: None
Network Implications: None - local-only operation
System Fit: Part of the gear management system, ensuring compatibility with modded content where backpack definitions may be incomplete
A3A_fnc_classNameToModel
File: A3A/addons/core/functions/Utility/fn_classNameToModel.sqf

What it does: Retrieves the 3D model path from an Arma config class name. Specifically designed to assist inexperienced users in manually adding entries to the logistics system by providing a simple way to get the model file path needed for object placement.

How it does that:

Include and Line Number Fix:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Includes the project's script component configuration and applies line number fixes for better debugging output.

Parameter Extraction with Validation:

Sqf

Apply
params [["_className", "", [""]]];
Extracts the class name parameter with default empty string and enforces string type validation.

Config Class Validation:

Sqf

Apply
if !(isClass (configFile/"CfgVehicles"/_className)) exitWith { Error("Invalid classname: " + _classname); "N/A" };
Checks if the class exists in CfgVehicles config
If invalid, calls Error() (likely logging function) and exits with "N/A" string
Uses configFile base path for standard config lookup
Model Path Retrieval:

Sqf

Apply
getText (configFile >> "CfgVehicles" >> _className >> "model");
Accesses the config hierarchy: configFile → CfgVehicles → [className] → model
Returns the string path to the .p3d model file (e.g., "a3\armor_f_beta\apc_track_01\apc_track_01.p3d")
Where it leads:

Called Functions:
Error(): Likely logging function (exact implementation not shown)
Called By:
A3A_fnc_initBuildableObjects: When initializing buildable objects for construction
A3A_fnc_placeBuilderObjects: When placing terrain objects in the builder system
User manual configuration tools for adding custom logistics entries
Global Variables Modified: None
Network Implications: None - local config lookup
System Fit: Supports the builder/constructor system and logistics, allowing users to easily add new object types to the construction menu by providing their model paths
A3A_fnc_countAttachedObjects
File: A3A/addons/core/functions/Utility/fn_countAttachedObjects.sqf

What it does: Counts the number of attached objects on a given object with standardized exception handling for common problematic attached object types (null objects and particle sources).

How it does that:

Parameter Extraction:

Sqf

Apply
params [["_object", objNull, [objNull]]];
Extracts an object parameter with default objNull and enforces object type validation.

Attached Objects Retrieval:

Sqf

Apply
count ([_object] call A3A_fnc_attachedObjects);
Calls A3A_fnc_attachedObjects to get the list of attached objects
Uses count to return the number of objects
The helper function handles filtering of null objects and particle sources
Where it leads:

Called Functions:
A3A_fnc_attachedObjects: Core function that retrieves and filters attached objects (likely excludes null objects, particle sources, and other special entities)
Called By:
Object cleanup systems
Performance monitoring (tracking attached object accumulation)
Attachment validation before object deletion
Any system needing to verify clean object state
Global Variables Modified: None
Network Implications: None - local object inspection
System Fit: Part of the object management system, ensuring clean state tracking for objects in the mission environment
A3A_fnc_createDataObject
File: A3A/addons/core/functions/Utility/fn_createDataObject.sqf

What it does: Creates a data object (simple logic object) used purely for storing variables. This is an Antistasi-specific implementation inspired by Community Base Addons (CBA) namespaces, providing a lightweight object for persistent data storage.

How it does that:

Simple Object Creation:
Sqf

Apply
createSimpleObject ["Logic", [0,0,0]]
Creates a simple object of class "Logic" (invisible helper object)
Positioned at world origin (0,0,0)
Returns the created object which can be used with setVariable/getVariable
No parameters required - minimalist implementation
Where it leads:

Called Functions: None
Called By:
A3A_fnc_initPreJIP: For pre-init data storage
Mission initialization systems needing data persistence
State management systems for client/server data
Any system requiring a lightweight data container
Global Variables Modified: None (data stored on the object itself)
Network Implications: None for creation, but variables can be synced via remoteExec
System Fit: Provides the foundation for data persistence systems, replacing or augmenting CBA namespaces with Antistasi's own implementation
A3A_fnc_createNamespace
File: A3A/addons/core/functions/Utility/fn_createNamespace.sqf

What it does: Creates a namespace for data storage. Global namespaces can be accessed from all machines, while local namespaces are machine-specific. Unlike data objects, these are persistent unless explicitly deleted.

How it does that:

Parameter Extraction:

Sqf

Apply
params [["_globalNamespace", false]];
Extracts boolean parameter for namespace type (global vs local).

Local Namespace Creation:

Sqf

Apply
if (!_globalNamespace) exitWith
{
     createLocation ["Invisible", [-10, -10, 0], 0, 0];
};
Creates a local "Invisible" location type at offset coordinates
Returns immediately for local namespaces
Local namespaces cannot be accessed from other machines without remote execution
Global Namespace Creation:

Sqf

Apply
createSimpleObject ["a3\weapons_f\empty.p3d", [-10, -10, 0], false]
Creates a global simple object using an empty weapon model
Positioned at offset coordinates to avoid visual clutter
false parameter means it's not positioned on terrain
Returns the global object that can be accessed from any machine
Where it leads:

Called Functions: None
Called By:
A3A_fnc_initPreJIP: For creating persistent data containers
A3A_fnc_setIdentityLocal: For storing JIP identity data
Mission state management systems
Systems needing machine-independent data access
Global Variables Modified: None (data stored in namespace)
Network Implications:
Global namespaces: Variables can be read remotely (access from all machines)
Local namespaces: Require remoteExec for cross-machine access
System Fit: Provides robust data storage with machine accessibility control, critical for multiplayer persistence systems
A3A_fnc_createRandomIdentity
File: A3A/addons/core/functions/Utility/fn_createRandomIdentity.sqf

What it does: Creates a random identity for a unit including face, voice, and name. Returns a hash map that can be passed to A3A_fnc_createUnit for standardized unit creation with proper identity distribution based on faction and unit type.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_faction", "_unitType"];
Extracts faction hash map and unit type string.

Unit Type Prefix Detection:

Sqf

Apply
private _typePrefix = switch (true) do {
     case ("militia_" in _unitType): { "mil" };
     case ("police" in _unitType): { "pol" };
     case ("SF" in _unitType): { "sf" };
     default { "" };
};
Determines unit category from type string
Uses string containment checks for flexible matching
Prefix determines which faction lists to use
Face Selection:

Sqf

Apply
private _faceKey = _typePrefix + (if (_typePrefix == "") then { "faces" } else { "Faces" });
private _faces = _faction getOrDefault [_faceKey, _faction getOrDefault ["faces", []]];
private _identity = createHashMap;
_identity set ["face", selectRandom _faces];
Constructs config key based on prefix
Uses getOrDefault with fallback to generic "faces" list
Creates new hash map for identity storage
Selects random face from available list
Voice Selection:

Sqf

Apply
private _voiceKey = _typePrefix + (if (_typePrefix == "") then { "voices" } else { "Voices" });
private _voices = _faction getOrDefault [_voiceKey, _faction getOrDefault ["voices", []]];
_identity set ["speaker", selectRandom _voices];
Similar to face selection but for voices
Uses "voices" as fallback key
Stores in identity hash map
Name Selection:

Sqf

Apply
_identity set ["firstName", selectRandom (_faction getOrDefault ["firstNames", []])];
_identity set ["lastName", selectRandom (_faction getOrDefault ["lastNames", []])];
Selects random first and last names from faction lists
Uses getOrDefault with empty array fallback
Stores both in identity hash map
Return Identity:

Sqf

Apply
_identity;
Returns the populated hash map with keys: "face", "speaker", "firstName", "lastName"

Where it leads:

Called Functions: None
Called By:
A3A_fnc_createUnit: When creating faction-specific units
A3A_fnc_setIdentity: When generating fallback identities
A3A_fnc_reDressFaction: When applying faction loadouts
Any system creating AI or rebel units with proper identities
Global Variables Modified: None
Network Implications: None - local identity generation
System Fit: Core to unit creation system, ensuring proper faction representation and diversity in AI units
A3A_fnc_deleteNamespace
File: A3A/addons/core/functions/Utility/fn_deleteNamespace.sqf

What it does: Safely deletes a namespace object, handling both location-based and object-based namespaces appropriately.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_namespace"];
Extracts the namespace parameter (type varies).

Location Namespace Check:

Sqf

Apply
if (_namespace isEqualType locationNull) exitWith {
     deleteLocation _namespace;
};
Checks if parameter is a location (local namespace)
Uses deleteLocation for proper cleanup
Exits immediately after deletion
Object Namespace Deletion:

Sqf

Apply
deleteVehicle _namespace;
For global namespaces (simple objects)
Uses standard object deletion
Where it leads:

Called Functions: None
Called By:
Cleanup systems at mission end
Dynamic data management (creating/deleting temporary namespaces)
Memory management for player disconnect
Any system using A3A_fnc_createNamespace
Global Variables Modified: None
Network Implications:
Global namespaces: deleteVehicle executes on all machines
Local namespaces: Only executes locally
System Fit: Memory management component, ensuring proper cleanup of namespace resources
A3A_fnc_getAdmin
File: A3A/addons/core/functions/Utility/fn_getAdmin.sqf

What it does: Returns the unit object of the online admin or objNull if none found. Detects admin in single-player, multiplayer, and headless client environments.

How it does that:

Single Player Detection:

Sqf

Apply
if (isServer && hasInterface) then { A3A_admin = player; };
In SP: Server has interface, so player is admin
Sets global A3A_admin to player unit
Global Variable Initialization:

Sqf

Apply
if (isNil "A3A_admin") then {A3A_admin = objNull};
Ensures A3A_admin exists
Initializes to objNull if not set
Admin Owner Check:

Sqf

Apply
if (admin owner A3A_admin isEqualTo 0 && !hasInterface) then {
Checks if current admin object has admin privileges
!hasInterface ensures only HC or server checks this
Find Online Admin:

Sqf

Apply
private _allPlayers = (allUnits + allDeadMen);
private _adminIndex = _allPlayers findIf {!(admin owner _x isEqualTo 0)};
A3A_admin = if (_adminIndex isEqualTo -1) then { objNull } else { _allPlayers # _adminIndex };
Combines living and dead units (handles respawning admins)
Uses findIf to locate first unit with admin privileges
Updates global A3A_admin with found unit or objNull
Return Admin:

Sqf

Apply
A3A_admin;
Returns the global admin unit reference

Where it leads:

Called Functions: None
Called By:
Admin logging/identification systems
Punishment system (admin forgiveness)
Permission checks for commands
Any admin-specific functionality
Global Variables Modified:
A3A_admin: Global admin unit reference (updated periodically)
Network Implications:
admin owner is network-aware
Executes on server/HC only (!hasInterface guard)
Returns unit object reference
System Fit: Permission and administration system, critical for multiplayer admin tools
A3A_fnc_getItemListFromDLC
File: A3A/addons/core/functions/Utility/fn_getItemListFromDLC.sqf

What it does: Returns an array of items from a specific DLC/mod, categorizing each item based on its config type. Used for mod content detection and logistics system initialization.

How it does that:

Parameter Extraction:

Sqf

Apply
params["_mod"];
Extracts DLC/mod identifier string.

Configuration Iteration:

Sqf

Apply
private _items = [];
{
     private _cfg = _x;
     private _itemList = ( 
             ("true" configClasses ( configFile >>  _cfg )) select {
                     private _name = configName _x;
                     private _modOfItem = [configFile >> _cfg >> _name] call A3A_fnc_getModOfConfigClass;
                     _modOfItem == _mod
             }
     ) apply { 
             private _CfgName = configName _x;
             [_CfgName, _CfgName call A3A_fnc_equipmentClassToCategories]
     }; 
     _items append _itemList;
} forEach ["CfgWeapons", "CfgGlasses", "CfgMagazines"];
Iterates through weapon, glasses, and magazine configs
configClasses gets all config entries under each config type
Selects items where A3A_fnc_getModOfConfigClass returns the requested mod
For each matching item, creates pair: [itemClassName, [category1, category2, ...]]
Appends to cumulative _items array
Return Items:

Sqf

Apply
_items
Returns array of [className, [categories]] pairs

Where it leads:

Called Functions:
A3A_fnc_getModOfConfigClass: Determines which mod a config class belongs to
A3A_fnc_equipmentClassToCategories: Categorizes equipment (weapon, optic, etc.)
Called By:
A3A_fnc_initUtilityItems: When initializing item systems
Mod detection systems for logistics
DLC content management tools
Global Variables Modified: None
Network Implications: None - config analysis only
System Fit: Mod compatibility and logistics initialization, ensuring all DLC items are properly categorized
A3A_fnc_getRoadDirection
File: A3A/addons/core/functions/Utility/fn_getRoadDirection.sqf

What it does: Returns a direction between 0-360 for a road object, using its connection to determine orientation. If road has no connections or is null, returns random direction.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_road"];
Extracts road object parameter.

Null Road Check:

Sqf

Apply
if (isNull _road) exitWith { random 360 };
Returns random direction for null road
Provides graceful fallback
Connected Roads Check:

Sqf

Apply
private _roadConnectedTo = [];
_roadConnectedTo = roadsConnectedTo _road;

if (_roadConnectedTo isEqualTo []) exitWith {random 360};
Gets array of connected roads
Returns random direction if no connections
Uses roadsConnectedTo native function
Direction Calculation:

Sqf

Apply
private _connectedRoad = _roadConnectedTo select 0;
private _direction = [_road, _connectedRoad] call BIS_fnc_DirTo;

_direction;
Selects first connected road
Uses BIS_fnc_DirTo to calculate angle between roads
Returns the calculated direction
Where it leads:

Called Functions:
BIS_fnc_DirTo: Calculates direction from one object to another
Called By:
A3A_fnc_roadConnPoint: Road connection point calculation
Pathfinding systems
Convoy movement algorithms
Road placement validation
Global Variables Modified: None
Network Implications: None - local road network analysis
System Fit: Pathfinding and navigation system, providing orientation data for road-based movement
A3A_fnc_isEngineer
File: A3A/addons/core/functions/Utility/fn_isEngineer.sqf

What it does: Checks if a unit has engineering capability, considering both ACE medical engineer status and vanilla Arma engineer trait.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_unit"];
Extracts unit object parameter.

ACE Engineer Check:

Sqf

Apply
if (!isNil {_unit getVariable "ace_isEngineer"}) exitWith {
     // Yes, the spec for this var is garbage
     !(_unit getVariable "ace_isEngineer" in [0, false])
};
Checks if ACE has set the ace_isEngineer variable
Handles ACE's garbage spec: values can be 0, 1, true, false
Returns true for any truthy value except 0 and false
Exits immediately if ACE variable exists
Vanilla Engineer Trait:

Sqf

Apply
_unit getUnitTrait "engineer";
Falls back to vanilla Arma unit trait system
Returns true/false based on engineer trait
Only reached if ACE variable is not set
Where it leads:

Called Functions: None
Called By:
A3A_fnc_initBuilderMonitors: For construction capability checks
A3A_fnc_startBreachVehicle: For breaching capability
Repair/revive systems
Equipment loadout validation
Global Variables Modified: None
Network Implications: None - local unit property check
System Fit: Unit capability system, ensuring compatibility between ACE and vanilla engineer definitions
A3A_fnc_localLog
File: A3A/addons/core/functions/Utility/fn_localLog.sqf

What it does: Logs arguments as text to the local RPT file. Simple wrapper around diag_log for logging multiple items.

How it does that:

Iterative Logging:
Sqf

Apply
{diag_log text _x} forEach _this;
Uses forEach to iterate through all passed arguments
Converts each to text with text operator
Logs each with diag_log
No parameters defined - accepts any number of arguments
Where it leads:

Called Functions: None
Called By:
A3A_fnc_log: When logging to local client
Debug systems
Error reporting
Any logging output
Global Variables Modified: None
Network Implications: None - local RPT writing only
System Fit: Logging infrastructure, providing local debug output
A3A_fnc_log
File: A3A/addons/core/functions/Utility/fn_log.sqf

What it does: Logs formatted messages with levels (Error=1, Info=2, Debug=3, Verbose=4), optionally to server, with timestamp and file information.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_level", "_message", ["_file", "No File Specified"]];
private _toServer = param [3, !(hasInterface && _level > 1)];
private _filename = "fn_log";
Extracts log level, message, and optional file name
Determines target: defaults to server for HC and errors
Sets internal filename (likely overridden in actual usage)
Level Threshold Check:

Sqf

Apply
if (_level > LogLevel) exitwith {};
Checks global LogLevel variable (e.g., 2=Info, 3=Debug)
Exits if message level exceeds threshold
Performance optimization for filtered logging
Log Line Construction:

Sqf

Apply
private _logLine = if (1 <= _level && _level <= 4) then {
     (systemTimeUTC call A3A_fnc_systemTime_format_S) + " | Antistasi | " + ["Error","Info","Debug","Verbose"]#(_level-1) + " | File=" + _file + " | " + _message;
} else {
     (systemTimeUTC call A3A_fnc_systemTime_format_S) + " | Antistasi | Error | File=fn_log | Invalid Log Level | Dump=" + str _this;
};
Formats timestamp with A3A_fnc_systemTime_format_S
Builds log string with "Level | File | Message" pattern
Handles invalid levels by dumping entire parameter array
Uses array indexing for level names
Remote vs Local Logging:

Sqf

Apply
if (isNil "blockServerLogging" && _toServer && !isServer) then {
     // Tag remote log lines with player. HCs return hc, hc_1, hc_2 etc
     _logLine = _logLine + " | Client: "+str player+" ["+str clientOwner+"]";
     _logLine remoteExec ["A3A_fnc_localLog", 2];
} else {
     diag_log text _logLine;
};
If logging to server and not server itself:
Appends client info (player name and owner ID)
Remote executes A3A_fnc_localLog on machine 2 (server/HC)
Otherwise logs locally with diag_log
Where it leads:

Called Functions:
A3A_fnc_systemTime_format_S: Formats system time as string
A3A_fnc_localLog: Receives remote log calls
Called By:
All systems requiring structured logging
Error handlers
Debug output
Performance monitoring
Global Variables Modified:
blockServerLogging: Can suppress remote logging
LogLevel: Global filtering threshold
Network Implications:
Can remote execute logging to server/HC
Adds client context to remote logs
Machine 2 is server/HC
System Fit: Central logging infrastructure for debugging and error tracking
A3A_fnc_setIdentity
File: A3A/addons/core/functions/Utility/fn_setIdentity.sqf

What it does: Sets face, voice, pitch, and name of a unit globally with JIP-safe execution. Handles fallback identity generation when required parameters are missing.

How it does that:

Include and Parameter Extraction:

Sqf

Apply
#include "..\..\script_component.hpp"

params ["_unit", "_identity"];
Includes project config and extracts unit and identity hash map parameters.

Null Unit Check:

Sqf

Apply
if (isNull _unit) exitWith {};
Early exit for invalid units.

Name Extraction with Defaults:

Sqf

Apply
private _firstName = _identity getOrDefault ["firstName", ""];
private _lastName = _identity getOrDefault ["lastName", ""];
Gets name components from identity hash map with empty string defaults.

Fallback Identity Generation:

Sqf

Apply
if ((isNil "_firstName" || {_firstName isEqualTo ""}) || (isNil "_lastName" || {_lastName isEqualTo ""})) then {
     private _nameConfig = configfile >> "CfgWorlds" >> "GenericNames" >> "GreekMen";
     private _firstNames = configProperties [_nameConfig >> "FirstNames"] apply { getText(_x) };
     private _lastNames = configProperties [_nameConfig >> "LastNames"] apply { getText(_x) };

     private _type = _unit getVariable ["unitType", ""]; // Why do some units *not* have this set? I will never know!
     private _identity = [Faction(side _unit), _type] call A3A_fnc_createRandomIdentity;

     // Choose appropriate faction identity if possible, fallback to default names if unavailable
     _firstName = ([_identity getOrDefault ["firstName", ""], selectRandom _firstNames] select {_x != ""}) # 0;
     _lastName = ([_identity getOrDefault ["lastName", ""], selectRandom _lastNames] select {_x != ""}) # 0;
};
Checks if names are missing/empty
Loads Greek male names as default from config
Gets unit's unitType variable (with fallback)
Calls A3A_fnc_createRandomIdentity for faction-appropriate identity
Selects first non-empty name from generated identity or default lists
Handles case where faction identity might also be empty
Update Identity Map:

Sqf

Apply
_identity set ["firstName", _firstName];
_identity set ["lastName", _lastName];
Ensures identity hash map contains name data
Overwrites any previous values
JIP-Safe Remote Execution:

Sqf

Apply
private _JIPID = "identity_" + netId _unit;
[_JIPID, _unit, _identity] remoteExec ["A3A_fnc_setIdentityLocal", 0, _JIPID];
Creates unique JIP ID from unit's network ID
Remote executes on all machines (0)
JIP ID ensures only one instance per unit
Cleanup on Deletion:

Sqf

Apply
_unit addEventHandler ["Deleted", {
     remoteExec ["", "identity_" + netId _unit];
}];
Adds event handler to clean up JIP entry when unit is deleted
Sends empty remote exec to clear JIP queue
Where it leads:

Called Functions:
A3A_fnc_createRandomIdentity: Generates fallback identity
A3A_fnc_setIdentityLocal: Receives JIP execution
Called By:
A3A_fnc_createUnit: When creating new units
A3A_fnc_RivalsCreateUnit: For rival faction units
Any system creating units with identity
Global Variables Modified: None (JIP ID stored in event handler)
Network Implications:
Remote executes to all machines (0)
JIP-safe via unique ID
Cleanup on unit deletion
System Fit: Unit creation system, ensuring consistent identity across network and JIP
A3A_fnc_setIdentityLocal
File: A3A/addons/core/functions/Utility/fn_setIdentityLocal.sqf

What it does: Sets identity on a local machine, handling JIP cleanup and ACE integration for name display.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_JIPID", "_unit", "_identity"];
Extracts JIP ID, unit, and identity hash map.

Null Unit Check with JIP Cleanup:

Sqf

Apply
if (isNull _unit) exitWith { remoteExec ["", _JIPID] };
If unit no longer exists, clears JIP entry
Prevents execution on stale units
Face Application:

Sqf

Apply
private _face = _identity get "face";
if !(isNil "_face") then { _unit setFace _face };
Gets face from identity
Only sets if defined
Uses native setFace
Speaker/Voice Application:

Sqf

Apply
private _speaker = _identity get "speaker";
if !(isNil "_speaker") then { _unit setSpeaker _speaker };
Gets speaker from identity
Only sets if defined
Uses native setSpeaker
Pitch Application:

Sqf

Apply
private _pitch = _identity get "pitch";
if !(isNil "_pitch") then { _unit setPitch _pitch };
Gets pitch from identity
Only sets if defined
Uses native setPitch
Name Application:

Sqf

Apply
private _firstName = _identity get "firstName";
private _lastName = _identity get "lastName";

if (_firstName != "" || _lastName != "") then {
     private _fullName = [_firstName, _lastName] select { _x != "" } joinString " ";
     _unit setName [_fullName, _firstName, _lastName];
     if (isServer and {!isNil "ace_common_fnc_setName"}) then {
         // Updates the name displayed in ACE Medical, dogtags, name tags and other ACE features
         // Runs global setVariable so only needs executing once
         _unit call ace_common_fnc_setName;
     };
};
Gets first and last names
Only processes if at least one is non-empty
Builds full name by joining non-empty parts
Uses native setName with full name and components
On server (once), calls ACE's setName if available for full ACE integration
Where it leads:

Called Functions:
ace_common_fnc_setName: ACE name display update (if ACE loaded)
Called By:
A3A_fnc_setIdentity: Receives JIP execution
JIP system for identity synchronization
Global Variables Modified: None
Network Implications:
Executes locally only
Called via JIP system
ACE integration runs on server once
System Fit: Identity application on local machines, ensuring visual and ACE consistency
A3A_fnc_setPos
File: A3A/addons/core/functions/Utility/fn_setPos.sqf

What it does: Moves an object to a new position with coordinate system flexibility (ASL, ASLW, ATL, AGL, AGLS, WORLD), enforcing XY consistency and handling height offsets.

How it does that:

Parameter Extraction:

Sqf

Apply
params [
     ["_object",objNull,[objNull]],
     ["_positionIn",[0,0,0],[ [] ], [3,4]],
     ["_coordinateSystem","AGL",[""]]
];
Extracts object, position (3 or 4 elements), and coordinate system
Position can include coordinate system as 4th element
Alternate Parameter Handling:

Sqf

Apply
private _position = +_positionIn;
if (count _position isEqualTo 4) then {
     _position deleteAt 3;
};
Copies position array to avoid modification
If 4 elements, removes the last (coordinate system)
Coordinate System Switch:

Sqf

Apply
switch (_coordinateSystem) do {
     case "ASL": { _object setPosASL _this#1 };
     case "ASLW": { _object setPosASLW _this#1 };
     case "ATL": { _object setPosATL _this#1 };
     case "AGL": { _object setPos _this#1 };
     case "AGLS": {
         _object setPosWorld [_position#0,_position#1,10000];
         _position set [2,_position#2 + 10000 - (getPosVisual _object)#2];
         _object setPosWorld _position;
     };
     case "WORLD": { _object setPosWorld _position };
     default {};
};
Handles different coordinate systems
AGLS (Above Ground Level Special) has special handling:
Temporarily sets to high altitude
Calculates ground offset
Applies final position
Default case does nothing (coordinate drift prevention in next step)
XY Position Correction:

Sqf

Apply
_position set [2, getPosWorld _object #2];  // Corrects XY drift due to model not being centred with bounding box.
_object setPosWorld _position;
_object
Updates Z-coordinate to object's current world Z
Re-sets using setPosWorld to prevent model drift
Returns object reference
Where it leads:

Called Functions: None (uses native Arma position functions)
Called By:
A3A_fnc_spawnVehicle: For precise vehicle placement
A3A_fnc_placeBuilderObjects: For object construction
A3A_fnc_teleportVehicleToBase: For base teleportation
Any movement system
Global Variables Modified: None
Network Implications: None - position change is network-synced automatically
System Fit: Movement and placement system, ensuring precise object positioning
A3A_fnc_vehicleTextureSync
File: A3A/addons/core/functions/Utility/fn_vehicleTextureSync.sqf

What it does: Makes local vehicle texture settings global, working around Arma's texture synchronization misfeature/bug where locally set textures aren't synchronized.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_veh"];
Extracts vehicle object parameter.

Null/Nil Check:

Sqf

Apply
if (isNil "_veh" or {isNull _veh}) exitWith {};
Early exit for invalid vehicles
Prevents errors
Texture List Validation:

Sqf

Apply
if (count getArray (configfile >> "CfgVehicles" >> typeof _veh >> "textureList") > 2) then
Checks if vehicle has multiple texture options
textureList is weighted array; >2 entries indicates multiple options
Only syncs for vehicles with texture variations
Texture Synchronization:

Sqf

Apply
{ _veh setObjectTextureGlobal [_forEachindex, _x] } forEach getObjectTextures _veh;
{ _veh setObjectMaterialGlobal [_forEachindex, _x] } forEach getObjectMaterials _veh;
Iterates through current textures with index
Sets each globally using setObjectTextureGlobal
Does same for materials with setObjectMaterialGlobal
Ensures all clients see same appearance
Where it leads:

Called Functions: None
Called By:
A3A_fnc_spawnVehicle: After vehicle creation
A3A_fnc_initVEH: During vehicle initialization
Any system creating vehicles with custom textures
Global Variables Modified: None
Network Implications:
Uses setObjectTextureGlobal which synchronizes to all machines
Critical for multiplayer vehicle appearance consistency
System Fit: Vehicle management system, ensuring visual consistency across network
A3A_fnc_vehicleWillCollideAtPosition
File: A3A/addons/core/functions/Utility/fn_vehicleWillCollideAtPosition.sqf

What it does: Checks if a vehicle will collide with anything if moved to a target position, using bounding box corner detection and line intersection testing.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_vehicle", "_targetPos"];
Extracts vehicle and target position (AGL format).

Bounding Box Calculation:

Sqf

Apply
private _vehiclePosAGL = getPos _vehicle;
private _boundingBox = boundingBoxReal _vehicle; 
private _corners = [ 
     //Bottom - rear - left 
     [_boundingBox select 0 select 0, _boundingBox select 0 select 1, _boundingBox select 0 select 2], 
     //Bottom - front - left 
     [_boundingBox select 0 select 0, _boundingBox select 1 select 1, _boundingBox select 0 select 2], 
     //Bottom - rear - right 
     [_boundingBox select 1 select 0, _boundingBox select 0 select 1, _boundingBox select 0 select 2], 
     //Bottom - front - right 
     [_boundingBox select 1 select 0, _boundingBox select 1 select 1, _boundingBox select 0 select 2], 
     //Top - rear - left 
     [_boundingBox select 0 select 0, _boundingBox select 0 select 1, _boundingBox select 1 select 2], 
     //Top - front - left 
     [_boundingBox select 0 select 0, _boundingBox select 1 select 1, _boundingBox select 1 select 2], 
     //Top - rear - right 
     [_boundingBox select 1 select 0, _boundingBox select 0 select 1, _boundingBox select 1 select 2], 
     //Top - front - right 
     [_boundingBox select 1 select 0, _boundingBox select 1 select 1, _boundingBox select 1 select 2] 
]; 
Gets current vehicle position
Retrieves bounding box as min/max coordinates
Defines all 8 corners of the bounding box in model space
Collision Line Definition:

Sqf

Apply
private _lines = [ 
     //Bottom - rear - left to Bottom - rear - right 
     [_corners select 0, _corners select 2], 
     //Bottom - front - left to Bottom - front - right 
     [_corners select 1, _corners select 3], 
     //Bottom - rear - left to Bottom - front - left 
     [_corners select 0, _corners select 1], 
     //Bottom - rear - right to Bottom - front - right 
     [_corners select 2, _corners select 3], 
     //Top - rear - left to Bottom - rear - right 
     [_corners select 4, _corners select 6], 
     //Top - front - left to Bottom - front - right 
     [_corners select 5, _corners select 7], 
     //Top - rear - left to Bottom - front - left 
     [_corners select 4, _corners select 5], 
     //Top - rear - right to Bottom - front - right 
     [_corners select 6, _corners select 7],
     //Diagonal - Bottom - rear - left to Top - front - right
     [_corners select 0, _corners select 7]
]; 
Defines 9 line segments between corners
Covers edges and diagonals for comprehensive detection
Height Offset Calculation:

Sqf

Apply
private _heightOffset = (_boundingBox select 1 select 2) - (_boundingBox select 0 select 2) / 2; 
Calculates center offset for height adjustment
Ensures collision lines are at proper vertical position
Collision Detection Loop:

Sqf

Apply
{ 
     private _startPosModelSpace = _x select 0;
     private _endPosModelSpace = _x select 1;
     private _startPosVehicleCurrentLocation = _vehicle modelToWorld (_startPosModelSpace);
     private _endPosVehicleCurrentLocation = _vehicle modelToWorld (_endPosModelSpace);

     private _positionDifference = [
             (_targetPos select 0) - (_vehiclePosAGL select 0),
             (_targetPos select 1) - (_vehiclePosAGL select 1),
             (_targetPos select 2) - (_vehiclePosAGL select 2)
     ];

     private _startPos = [
             (_startPosVehicleCurrentLocation select 0) + (_positionDifference select 0),
             (_startPosVehicleCurrentLocation select 1) + (_positionDifference select 1),
             0.1 + (_startPosModelSpace select 2) + _heightOffset
     ];

     private _endPos = [
             (_endPosVehicleCurrentLocation select 0) + (_positionDifference select 0),
             (_endPosVehicleCurrentLocation select 1) + (_positionDifference select 1),
             0.1 + (_startPosModelSpace select 2) + _heightOffset
     ];

     private _result = lineIntersectsSurfaces [AGLtoASL _startPos, AGLtoASL _endPos, objNull, objNull, false, 1, "FIRE", "FIRE"]; 
     if (count _result > 0) exitWith { 
             _collision = true;
     }; 
} forEach _lines; 
For each line segment:
Converts model-space corners to current world position
Calculates movement offset (target - current)
Creates start/end positions at target location
Adds 0.1m offset for ground clearance
Uses lineIntersectsSurfaces to detect collisions
Exits early if any intersection found
Return Result:

Sqf

Apply
_collision; 
Returns true if collision detected, false otherwise

Where it leads:

Called Functions: None (uses native Arma physics functions)
Called By:
A3A_fnc_spawnVehicle: For safe vehicle placement
A3A_fnc_placeBuilderObjects: For object placement validation
Movement systems for collision avoidance
Global Variables Modified: None
Network Implications: None - local physics check
System Fit: Placement and movement validation, preventing object clipping and clipping
A3A_fnc_uintToHex
Files: 
fn_uint12ToHex.sqf
, 
fn_uint16ToHex.sqf
, 
fn_uint20ToHex.sqf
, 
fn_uint24ToHex.sqf

What it does: Converts unsigned integers to hexadecimal strings of specified lengths (12, 16, 20, 24 bits). Uses pre-computed lookup tables for performance.

How they do that:

Base Lookup Tables:

Sqf

Apply
// fn_uintToHexGenTables.sqf
A3A_base16LookupTable = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"];

A3A_base16e2LookupTable = [];
{
     private _prefix = _x;
     A3A_base16e2LookupTable append (A3A_base16LookupTable apply {_prefix + _x});
} forEach A3A_base16LookupTable;
Base table: single hex digits
Extended table: 2-digit hex combinations (00-ff)
12-bit Conversion (fn_uint12ToHex.sqf):

Sqf

Apply
A3A_base16e2LookupTable # floor (_this / 16) +
A3A_base16LookupTable # (_this mod 16);
Divides by 16 for high nibble (first digit)
Modulo 16 for low nibble (second digit)
Concatenates from tables
16-bit Conversion (fn_uint16ToHex.sqf):

Sqf

Apply
A3A_base16e2LookupTable # floor (_this / 256) +
A3A_base16e2LookupTable # (_this mod 256);
Divides by 256 for high byte
Modulo 256 for low byte
Each byte looked up in 2-digit table
20-bit Conversion (fn_uint20ToHex.sqf):

Sqf

Apply
A3A_base16e2LookupTable # floor (_this / 4096) +
A3A_base16e2LookupTable # floor (_this / 16 mod 256) +
A3A_base16LookupTable # (_this mod 16);
Divides by 4096 for high nibble (20-16=4 bits)
Divides by 16 then mod 256 for middle byte
Mod 16 for low nibble
24-bit Conversion (fn_uint24ToHex.sqf):

Sqf

Apply
A3A_base16e2LookupTable # floor (_this / 65536) +
A3A_base16e2LookupTable # floor (_this / 256 mod 256) +
A3A_base16e2LookupTable # (_this mod 256);
Divides by 65536 for high byte
Divides by 256 then mod 256 for middle byte
Mod 256 for low byte
All lookups in 2-digit table
Where it leads:

Called Functions: None (uses pre-generated lookup tables)
Called By:
A3A_fnc_shortID_format: For formatted ShortID strings
Debug logging with hexadecimal representation
Any system needing efficient hex conversion
Global Variables Modified:
A3A_base16LookupTable: Single digit lookup
A3A_base16e2LookupTable: Two digit lookup
Network Implications: None - local computation
System Fit: Utility functions for efficient data representation, primarily used for ShortID formatting
A3A_fnc_shortID_create
File: A3A/addons/core/functions/Utility/ShortID/fn_shortID_create.sqf

What it does: Creates a ShortID that is unique to every computer on a server during the server's uptime. Returns [mostSignificant, leastSignificant] tuple for efficient storage.

How it does that:

ID Creation:

Sqf

Apply
private _newID = [A3A_shortID_clientID + A3A_shortID_counter2, A3A_shortID_counter1];
Combines client ID with counter2 for most significant
Uses counter1 as least significant
Creates tuple for efficient storage
Counter Management:

Sqf

Apply
A3A_shortID_counter1 = A3A_shortID_counter1 + 1;
if (A3A_shortID_counter1 >= A3A_shortID_counter1Modulo) then {
     A3A_shortID_counter1 = 0;
     A3A_shortID_counter2 = (A3A_shortID_counter2 + 1) mod A3A_shortID_counter2Modulo;
};
Increments counter1
If counter1 overflows, resets to 0 and increments counter2
Counter2 overflows with modulo operation
Return ID:

Sqf

Apply
_newID;
Returns [mostSignificant, leastSignificant]

Where it leads:

Called Functions: None
Called By:
Systems needing unique, sortable IDs
Logging systems for traceability
Data tracking (events, entities)
JIP request tracking
Global Variables Modified:
A3A_shortID_counter1: Current counter value
A3A_shortID_counter2: Overflow counter
A3A_shortID_clientID: Client/server identifier
Network Implications:
IDs are unique per client (prevents collisions)
Counter values are machine-local
IDs are not globally unique across restarts
System Fit: Unique identification system for distributed tracking
A3A_fnc_shortID_format
File: A3A/addons/core/functions/Utility/ShortID/fn_shortID_format.sqf

What it does: Converts a ShortID tuple into a formatted hexadecimal string for display/logging.

How it does that:

Parameter Extraction:

Sqf

Apply
params ["_mostSignificant","_leastSignificant"];
Extracts the two components of the ShortID.

Hex Conversion:

Sqf

Apply
(_mostSignificant call A3A_fnc_uint24ToHex) + "-" + (_leastSignificant call A3A_fnc_uint24ToHex);
Converts most significant 24 bits to hex
Converts least significant 24 bits to hex
Joins with hyphen separator
Results in format like "ffffff-ffffff"
Where it leads:

Called Functions:
A3A_fnc_uint24ToHex: Converts 24-bit integer to hex
Called By:
Logging systems for ID display
Debug output for traceability
User-visible identifiers
Global Variables Modified: None
Network Implications: None - local string formatting
System Fit: Provides human-readable format for ShortIDs
A3A_fnc_shortID_init
File: A3A/addons/core/functions/Utility/ShortID/fn_shortID_init.sqf

What it does: Initializes the ShortID system by calculating client ID based on machine type (server, HC, or client) and initializing random counter values.

How it does that:

Counter Modulo Definition:

Sqf

Apply
A3A_shortID_counter1Modulo = 2^24;
Sets counter1 overflow to 2^24 (24-bit space)
Machine Type Detection:

Sqf

Apply
if (isServer || !hasInterface) then {
     if (isServer) then {
             A3A_shortID_clientID = 1 * 2^23;                    // 1 isServerLike bit
             A3A_shortID_clientID = A3A_shortID_clientID + 2^22; // 1 isServer bit
             A3A_shortID_counter2Modulo = 2^22;                  // 22 Counter bits
     } else {  // Headless client.
             A3A_shortID_clientID = 1 * 2^23;                                            // 1 isServerLike bit
             A3A_shortID_clientID = A3A_shortID_clientID + 0 * 2^22;                     // 1 isServer bit
             A3A_shortID_clientID = A3A_shortID_clientID + (clientOwner mod 2^6) * 2^16; // 6 ID bits
             A3A_shortID_counter2Modulo = 2^16;                                          // 16 Counter bits
     };
} else {
     A3A_shortID_clientID = 0 * 2^23;                                            // 1 isServerLike bit
     A3A_shortID_clientID = A3A_shortID_clientID + (clientOwner mod 2^15) * 2^8; // 15 ID bits
     A3A_shortID_counter2Modulo = 2^8;                                           // 8 Counter bits
};
Server: Uses bit 23 (1), bit 22 (1), leaving 22 bits for counter2
Headless Client: Uses bit 23 (1), bit 22 (0), adds clientOwner mod 64 in bits 16-21, leaving 16 bits for counter2
Regular Client: Uses bit 23 (0), adds clientOwner mod 32768 in bits 8-22, leaving 8 bits for counter2
Counter Initialization:

Sqf

Apply
A3A_shortID_counter1 = floor random A3A_shortID_counter1Modulo;
A3A_shortID_counter2 = floor random A3A_shortID_counter2Modulo;
Randomizes both counters to prevent collisions
Counter1: 24-bit range
Counter2: machine-type-dependent range
Where it leads:

Called Functions: None
Called By:
A3A_fnc_initPreJIP: During pre-initialization
Mission start systems
Before any ShortID generation
Global Variables Modified:
A3A_shortID_counter1Modulo: Overflow threshold
A3A_shortID_clientID: Machine identifier
A3A_shortID_counter2Modulo: Counter2 overflow
A3A_shortID_counter1: Initial counter
A3A_shortID_counter2: Initial overflow counter
Network Implications:
Client IDs are machine-specific
Counters are random per machine
Prevents ID collisions during session
System Fit: Foundation for unique ID generation system
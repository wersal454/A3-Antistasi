A3A Logistics Addon Documentation
Function: fn_addLoadAction.sqf
What it does:
The 
fn_addLoadAction.sqf
 function adds logistics load/unload actions to objects, enabling players to interact with cargo items for loading into vehicles. It validates the cargo object and prepares to add appropriate actions based on the object's capabilities.

How it does that:
The function performs several validation steps before adding load actions:

It accepts a cargo object, action type ("load" or "unload"), and a flag for breaking undercover
It validates that the object exists and is alive
It checks if the object has a valid cargo node type
It generates a unique JIP key for remote execution
It remotely executes the A3A_Logistics_fnc_addAction function on all clients
Code Breakdown:
Sqf

Apply
#include "..\script_component.hpp"
FIX_LINE_NUMBERS()
params [["_object", objNull, [objNull]], ["_action", "load"],["_breakUC",false]];
Purpose: Includes necessary header files and sets up function parameters with default values.

params statement defines three parameters with default values:
_object: The cargo object to process (default: objNull)
_action: Action type ("load" or "unload") (default: "load")
_breakUC: Boolean flag for breaking undercover (default: false)
Sqf

Apply
if (isNull _object) exitWith {
    Error("No object passed, aborting");
    nil
};
Purpose: Validates that a valid object was passed.

Checks if _object is null
If null, logs an error and returns nil
This prevents further processing of invalid objects
Sqf

Apply
if (!alive _object) exitWith {
    Error("Destroyed object passed, aborting");
    nil
};
Purpose: Ensures the object is still alive.

Checks if _object is alive using alive function
If destroyed, logs an error and returns nil
Prevents operations on destroyed objects
Sqf

Apply
if (([_object] call A3A_Logistics_fnc_getCargoNodeType) isEqualTo -1) exitWith {nil};
Purpose: Validates that the object has a valid cargo node type.

Calls A3A_Logistics_fnc_getCargoNodeType with the object
If the returned value equals -1 (invalid), exits with nil
This ensures only valid cargo objects get load actions added
Sqf

Apply
private _jipKey = "A3A_Logistics_" + _action + ((str _object splitString ":") joinString "");
Purpose: Creates a unique JIP (Just In Place) key for remote execution.

Combines a prefix with the action type and object string representation
Uses splitString ":" and joinString "" to create a unique identifier
This key ensures proper synchronization across networked clients
Sqf

Apply
[_object, _action, _jipKey,_breakUC] remoteExec ["A3A_Logistics_fnc_addAction", 0, _jipKey];
Purpose: Executes the actual action addition on all clients.

Calls remoteExec to execute A3A_Logistics_fnc_addAction on all clients (0)
Passes the object, action, JIP key, and break undercover flag
The remote execution ensures actions are added consistently across network
Where it leads:
Calls: A3A_Logistics_fnc_getCargoNodeType - Determines cargo node type
Calls: A3A_Logistics_fnc_addAction - Actually adds the load/unload action
Depends on: A3A_Logistics_fnc_getCargoNodeType for validation
Depends on: A3A_Logistics_fnc_addAction for final execution
Requirements:
The object must be a valid, alive object
The object must have a valid cargo node type (not -1)
The A3A_Logistics_fnc_addAction function must exist and be accessible
The A3A_Logistics_fnc_getCargoNodeType function must exist and be accessible
Function: fn_getCargo.sqf
What it does:
The 
fn_getCargo.sqf
 function retrieves the cargo array from a vehicle's Cargo variable, processes it to filter out non-vehicle items, and returns the resulting cargo array.

How it does that:
The function:

Takes a vehicle as input parameter
Retrieves the vehicle's Cargo variable, defaulting to an empty array
If cargo exists, it flattens the array and filters for items that are of the same type as the vehicle
Returns the filtered cargo array
Code Breakdown:
Sqf

Apply
private _vehicle = _this;
Purpose: Assigns the input parameter (vehicle) to a local variable.

_this refers to the vehicle object passed to the function
Stores it in _vehicle for clarity and consistency
Sqf

Apply
private _cargo = _vehicle getVariable ["Cargo", []];
Purpose: Retrieves the vehicle's Cargo variable or initializes to empty array.

Uses getVariable to fetch the "Cargo" variable from the vehicle
If the variable doesn't exist, defaults to an empty array []
Sqf

Apply
if !(_cargo isEqualTo []) then {
	_cargo = (flatten _cargo) select {_x isEqualType _vehicle};	
};
Purpose: Processes the cargo array if it's not empty.

Checks if _cargo is not an empty array
If not empty, it:
Flattens the nested cargo array using flatten
Selects items that are of the same type as _vehicle using select with isEqualType
Updates _cargo with the filtered results
Sqf

Apply
_cargo
Purpose: Returns the processed cargo array.

Returns the final cargo array, either the original empty array or the filtered results
Where it leads:
Does not call other functions directly
Depends on: The vehicle having a "Cargo" variable
Used by: Other logistics functions that need to access vehicle cargo
Requirements:
The input must be a valid vehicle object
The vehicle must have a "Cargo" variable (can be empty)
The function is designed to work in a scheduled environment
Function: fn_getVehCapacity.sqf
What it does:
The 
fn_getVehCapacity.sqf
 function returns the cargo loading capacity of a vehicle by counting the number of nodes defined in the vehicle's configuration.

How it does that:
The function:

Takes a vehicle or vehicle class name as input
Retrieves the node configuration for the vehicle
Counts the number of properties in the "Nodes" configuration section
Returns this count as the vehicle's cargo capacity
Code Breakdown:
Sqf

Apply
params [["_vehicle", objNull, [objNull, ""]]];
Purpose: Sets up function parameters with default values.

Accepts either a vehicle object or a vehicle class name
Default value is objNull for object input
Accepts both objNull and string types as valid inputs
Sqf

Apply
private _config = [_vehicle] call A3A_Logistics_fnc_getNodeConfig;
Purpose: Gets the node configuration for the vehicle.

Calls A3A_Logistics_fnc_getNodeConfig with the vehicle input
This function returns the configuration class for the vehicle's nodes
Sqf

Apply
if (isNull _config) exitWith { 0 };
Purpose: Handles invalid configurations gracefully.

Checks if the returned configuration is null
If null (no configuration found), exits with 0 capacity
This prevents errors when vehicle class isn't supported
Sqf

Apply
count (configProperties [(_config/"Nodes"), "true", true]);
Purpose: Counts the number of nodes available for cargo loading.

Accesses the "Nodes" sub-class of the configuration using (_config/"Nodes")
Uses configProperties to get all properties of the Nodes class
The parameters "true", true specify that properties should be counted recursively
count returns the total number of node properties
Where it leads:
Calls: A3A_Logistics_fnc_getNodeConfig - Gets the node configuration for the vehicle
Depends on: A3A_Logistics_fnc_getNodeConfig for node configuration access
Requirements:
The vehicle must have a valid configuration with nodes defined
The A3A_Logistics_fnc_getNodeConfig function must be available
The vehicle class must be supported in the logistics configuration system
Function: fn_isLoadable.sqf
What it does:
The 
fn_isLoadable.sqf
 function checks whether a given object class can be loaded as logistics cargo by validating its presence in the cargo configuration system.

How it does that:
The function:

Takes a class name or object as input
Calls A3A_Logistics_fnc_getCargoConfig with the class
Checks if the returned configuration is not null
Returns true if the configuration exists, false otherwise
Code Breakdown:
Sqf

Apply
params [["_class","", ["", objNull]]];
Purpose: Sets up function parameters with default values.

Accepts either a class name (string) or object
Default value is an empty string
Accepts both string and object types as valid inputs
Sqf

Apply
!isNull ([_class] call A3A_Logistics_fnc_getCargoConfig);
Purpose: Determines if the class is loadable by checking cargo configuration.

Calls A3A_Logistics_fnc_getCargoConfig with the class input
!isNull checks if the returned configuration exists
Returns true if configuration exists (loadable), false if not
Where it leads:
Calls: A3A_Logistics_fnc_getCargoConfig - Gets the cargo configuration for a class
Depends on: A3A_Logistics_fnc_getCargoConfig for cargo configuration access
Requirements:
The input must be a valid class name or object
The A3A_Logistics_fnc_getCargoConfig function must be available
The class must be defined in the logistics cargo configuration system
File: CfgFunctions.hpp
What it does:
The 
CfgFunctions.hpp
 file defines the structure and organization of all functions in the A3A Logistics addon, categorizing them into public, private, and development functions with their respective file locations.

How it does that:
The file organizes functions into logical categories:

Public functions: Functions intended for external use by other scripts
Private functions: Internal functions not meant for direct external use
Development functions: Tools for developers working on the addon
Code Breakdown:
Sqf

Apply
class CfgFunctions {
    class ADDON {
Purpose: Creates the main configuration class for the A3A Logistics addon.

Defines the root configuration class structure for the addon
Provides namespace organization for all functions
Sqf

Apply
        class Dev {
            file = QPATHTOFOLDER(Dev);
            class convertCargoToNew {};
            class convertNodesToNew {};
            class generateCargoOffset {};
            class generateHardPoints {};
        };
Purpose: Defines the development category of functions.

Sets the file path for development functions using QPATHTOFOLDER(Dev)
Lists specific development functions:
convertCargoToNew - Converts cargo to new format
convertNodesToNew - Converts nodes to new format
generateCargoOffset - Generates cargo offset data
generateHardPoints - Generates hard points data
Sqf

Apply
        class Public {
            file = QPATHTOFOLDER(Public);
            class addLoadAction {};
            class getVehCapacity {};
            class getCargo {};
            class isLoadable {};
        };
Purpose: Defines the public category of functions.

Sets the file path for public functions using QPATHTOFOLDER(Public)
Lists specific public functions:
addLoadAction - Adds load/unload actions to objects
getVehCapacity - Gets vehicle cargo capacity
getCargo - Retrieves vehicle cargo
isLoadable - Checks if object is loadable
Sqf

Apply
        class Private {
            file = QPATHTOFOLDER(Private);
            class addAction {};
            class removeAction {};
            class addOrRemoveObjectMass {};
            class addWeaponAction {};
            class canLoad {};
            class getCargoConfig {};
            class getCargoNodeType {};
            class getCargoOffsetAndDir {};
            class getNodeConfig {};
            class getVehicleNodes {};
            class initMountedWeapon {};
            class load {};
            class packObject {};
            class refreshVehicleLoad {};
            class removeWeaponAction {};
            class toggleAceActions {};
            class toggleLock {};
            class tryLoad {};
            class unload {};
            class unpackObject {};
        };
Purpose: Defines the private category of functions.

Sets the file path for private functions using QPATHTOFOLDER(Private)
Lists internal functions used by the logistics system:
addAction - Adds actions to objects
removeAction - Removes actions from objects
addOrRemoveObjectMass - Adjusts object mass
addWeaponAction - Adds weapon-related actions
canLoad - Checks if loading is possible
getCargoConfig - Gets cargo configuration
getCargoNodeType - Gets cargo node type
getCargoOffsetAndDir - Gets cargo offset and direction
getNodeConfig - Gets node configuration
getVehicleNodes - Gets vehicle nodes
initMountedWeapon - Initializes mounted weapons
load - Loads objects into vehicles
packObject - Packs objects
refreshVehicleLoad - Refreshes vehicle load state
removeWeaponAction - Removes weapon actions
toggleAceActions - Toggles ACE actions
toggleLock - Toggles vehicle locks
tryLoad - Attempts to load objects
unload - Unloads objects from vehicles
unpackObject - Unpacks objects
Where it leads:
Used by: The game's function loading system to register all A3A Logistics functions
Depends on: The file paths specified for each function category
Integration: This configuration file is referenced by the main game configuration system
Requirements:
All referenced file paths must exist in the addon structure
All listed functions must exist in their respective files
The QPATHTOFOLDER macro must be properly defined in the build system
File: CfgLogistics.hpp
What it does:
The 
CfgLogistics.hpp
 file defines the complete logistics configuration system, including vehicle node definitions, cargo configurations, and packable items. It organizes these into categorized sections for different factions and content packs.

How it does that:
The file defines three main configuration classes:

Nodes: Defines vehicle node structures for cargo loading
Cargo: Defines cargo item configurations with properties
Packable: Defines items that can be packed/unpacked
Code Breakdown:
Sqf

Apply
class DOUBLES(ADDON,Nodes)
{
    class TRIPLES(ADDON,Nodes,Base)
    {
        class Nodes {};
        canLoadWeapon = 1; //if the vehicle can load weapons
    };
Purpose: Creates the main Nodes configuration class with base settings.

Uses DOUBLES macro to create the main class name (e.g., A3A_Logistics_Nodes)
Defines a base class TRIPLES(ADDON,Nodes,Base) with:
Empty class Nodes {} for node structure definition
canLoadWeapon = 1 flag indicating weapons can be loaded
Sqf

Apply
    #include "Nodes\3CBBAF.hpp"
    #include "Nodes\3CBFactions.hpp"
    #include "Nodes\CUP.hpp"
    #include "Nodes\CSLA.hpp"
    #include "Nodes\D3S.hpp"
    #include "Nodes\GM.hpp"
    #include "Nodes\RDS.hpp"
    #include "Nodes\RF.hpp"
    #include "Nodes\EF.hpp"
    #include "Nodes\RHS.hpp"
    #include "Nodes\RNT.hpp"
    #include "Nodes\Scion.hpp"
    #include "Nodes\SPE.hpp"
    #include "Nodes\SPEX.hpp"
    #include "Nodes\IFA.hpp"
    #include "Nodes\CSA.hpp"
    #include "Nodes\UNS.hpp"
    #include "Nodes\Vanilla.hpp"
    #include "Nodes\OPTRE.hpp"
    #include "Nodes\RACS.hpp"
    #include "Nodes\VN.hpp"
    #include "Nodes\Nickelsteel.hpp"
    #include "Nodes\WS.hpp"
    #include "Nodes\Aegis.hpp"
    #include "Nodes\CW.hpp"
    #include "Nodes\FFAA.hpp"
    #include "Nodes\PED.hpp"
    #include "Nodes\EMP.hpp"
	#include "Nodes\BRAF.hpp"
	#include "Nodes\AMF.hpp"
	#include "Nodes\TFC.hpp"
	#include "Nodes\TMT.hpp"
	#include "Nodes\NFtS.hpp"
	#include "Nodes\EAW.hpp"
	#include "Nodes\FOW.hpp"
	#include "Nodes\CWR.hpp"
    #include "Nodes\HAFM.hpp"
Purpose: Includes node configurations for various factions and content packs.

Includes multiple header files that define specific vehicle node configurations
Covers various factions and content packs including:
3CB factions
CUP (Community Upgrade Project)
RHS (RHS Weapons)
Vanilla (base game)
Various other faction packs
Sqf

Apply
class DOUBLES(ADDON,Cargo) {
    class TRIPLES(ADDON,Cargo,Base) {
        class Cargo {};
    };
Purpose: Creates the main Cargo configuration class with base settings.

Uses DOUBLES macro to create the main class name (e.g., A3A_Logistics_Cargo)
Defines a base class TRIPLES(ADDON,Cargo,Base) with:
Empty class Cargo {} for cargo structure definition
Sqf

Apply
    #include "Cargo\3CBBAF.hpp"
    #include "Cargo\3CBFactions.hpp"
    #include "Cargo\CUP.hpp"
    #include "Cargo\CSLA.hpp"
    #include "Cargo\D3S.hpp"
    #include "Cargo\GM.hpp"

A3A Logistics Addon Documentation
Function: fn_convertCargoToNew.sqf
What it does:
The 
fn_convertCargoToNew.sqf
 function generates new cargo class definitions from the old attachmentOffset list format. It transforms legacy cargo configuration data into the new structured format used by the logistics system.

How it does that:
The function:

Takes the legacy A3A_Logistics_attachmentOffset array as input
Processes each entry in the array to extract model, offset, rotation, size, and recoil data
Looks up weapon blacklists for weapons associated with each model
Generates formatted text output containing new cargo class definitions
Returns the complete text output with all generated classes
Code Breakdown:
Sqf

Apply
//generate cargo class from old attachmentOffset list
private _entries = [];
Purpose: Initializes an empty array to store generated class definitions.

Creates _entries as an empty array to collect formatted class text
This will hold all the generated cargo class definitions
Sqf

Apply
{
    private _model = (_x#0);
    private _offset = str (_x#1);
    private _rotation = str (_x#2);
    private _weaponsIndex = A3A_Logistics_weapons findIf {(_x#0) isEqualTo _model};
    private _blackListText = if (_weaponsIndex isEqualTo -1) then {""} else { //cleaner to proccess this here than inline
        private _str = str (A3A_Logistics_weapons#_weaponsIndex#1);
        _str select [1, count _str -2]; //remove brackets
    };
Purpose: Processes each entry from the legacy attachmentOffset array.

_model: Extracts the model name from the first element of current entry
_offset: Converts the offset array to string format
_rotation: Converts the rotation array to string format
_weaponsIndex: Searches for weapons associated with this model in A3A_Logistics_weapons
_blackListText: If a weapon entry is found, extracts and formats the blacklist data by removing brackets
Sqf

Apply
    _entries pushBack text (format [
        "class %1 : TRIPLES(ADDON,Cargo,Base)%7{%7%2%3%4%5%6%7};%7",
        ((_x#0) splitString "\.") joinString "_",
        "    offset[] = {" + (_offset select [1, count _offset - 2]) + "};" + endl,
        "    rotation[] = {" + (_rotation select [1, count _rotation - 2]) + "};" + endl,
        "    size = "+ str (_x#3) + ";",
        ["", endl + "    recoil = " + str (_x#4) + ";"] select (count _x > 4),
        ["", endl + "    isWeapon = 1;" + endl + "    blackList[] = {" + _blackListText + "};"] select (-1 != _weaponsIndex),
        endl
    ]);
Purpose: Formats and adds a new cargo class definition to the entries array.

Uses format to create a complete class definition string
Class name is generated by splitting the model name by "." and joining with "_"
Adds offset configuration from the offset string (removing first and last characters)
Adds rotation configuration from the rotation string (removing first and last characters)
Adds size configuration from the fourth element of the entry
Conditionally adds recoil configuration if the entry has more than 4 elements
Conditionally adds weapon-specific configurations (isWeapon = 1 and blackList) if weapons were found
Uses endl for line breaks for proper formatting
Sqf

Apply
} forEach A3A_Logistics_attachmentOffset;
Purpose: Iterates through all entries in the legacy attachmentOffset array.

Processes each element in A3A_Logistics_attachmentOffset array
Applies the formatting logic to each entry
Sqf

Apply
text (_entries joinString endl);
Purpose: Returns the complete formatted text output.

Joins all generated class definitions with line breaks
Converts the final string to text format for output
Where it leads:
Used by: Development tools for converting legacy cargo configurations
Depends on: A3A_Logistics_attachmentOffset - legacy cargo data array
Depends on: A3A_Logistics_weapons - weapon data for blacklisting
Integration: This is a development utility, not part of the main gameplay system
Requirements:
The A3A_Logistics_attachmentOffset array must exist and contain valid data
The A3A_Logistics_weapons array must exist and contain valid weapon data
The function is designed for development use only, not for runtime gameplay
The function outputs formatted text that can be copied into new configuration files

A3A Logistics Addon Documentation
Function: fn_convertNodesToNew.sqf
What it does:
The 
fn_convertNodesToNew.sqf
 function generates new node class definitions from the old hardpoints list format. It transforms legacy vehicle hardpoint data into the new structured node format used by the logistics system.

How it does that:
The function:

Takes the legacy A3A_Logistics_vehicleHardpoints array as input
Processes each vehicle entry to extract hardpoint data
Generates individual node class definitions for each hardpoint
Creates a complete class definition with node structure and vehicle-specific settings
Returns the complete text output with all generated node classes
Code Breakdown:
Sqf

Apply
//generate node classes from old hardpoints list
private _entries = [];
Purpose: Initializes an empty array to store generated class definitions.

Creates _entries as an empty array to collect formatted class text
This will hold all the generated node class definitions
Sqf

Apply
{
    private _nodes = [];
    {
        private _offsetArray = str (_x#1);
        private _seatArray = str (_x#2);

        _nodes pushBack text (format [
            "        class %1%4        {%4            offset[] = {%2};%4            seats[] = {%3};%4        };",
            "Node"+ str (_forEachIndex + 1),
            _offsetArray select [1, count _offsetArray - 2],
            _seatArray select [1, count _seatArray - 2],
            endl
        ]);
    } forEach (_x#1);
Purpose: Processes individual hardpoints for each vehicle entry.

Creates an inner loop to process each hardpoint in the current vehicle's hardpoint array
_offsetArray: Converts the offset data to string format
_seatArray: Converts the seat data to string format
Generates formatted node class definitions with:
Class name: "Node" + sequential number
Offset configuration from offset array (removing first and last characters)
Seats configuration from seat array (removing first and last characters)
Sqf

Apply
    private _nodesString = "    class Nodes" + endl + "    {" + endl + (_nodes joinString endl) + endl + "    };";
Purpose: Creates the complete Nodes class structure for the current vehicle.

Builds the Nodes class definition containing all individual node classes
Properly formatted with indentation and line breaks
Joins all generated node classes together
Sqf

Apply
    _entries pushBack text (format [
        "class %1 : TRIPLES(ADDON,Nodes,Base) %4{%4%2%3%4};%4",
        ((_x#0) splitString "\.") joinString "_",
        ["","    canLoadWeapon = 0;"+endl] select ((_x#0) in A3A_Logistics_coveredVehicles),
        _nodesString,
        endl
    ])
Purpose: Formats and adds a complete vehicle node class definition to the entries array.

Class name is generated by splitting the vehicle model name by "." and joining with "_"
Inherits from TRIPLES(ADDON,Nodes,Base) base class
Conditionally adds canLoadWeapon = 0; if the vehicle is in A3A_Logistics_coveredVehicles
Includes the complete _nodesString containing all node definitions
Uses proper formatting with line breaks
Sqf

Apply
} forEach A3A_Logistics_vehicleHardpoints;
Purpose: Iterates through all vehicle entries in the legacy hardpoints array.

Processes each vehicle entry in A3A_Logistics_vehicleHardpoints
Applies the formatting logic to each vehicle's hardpoint data
Sqf

Apply
text (_entries joinString endl);
Purpose: Returns the complete formatted text output.

Joins all generated class definitions with line breaks
Converts the final string to text format for output
Where it leads:
Used by: Development tools for converting legacy node configurations
Depends on: A3A_Logistics_vehicleHardpoints - legacy vehicle hardpoint data array
Depends on: A3A_Logistics_coveredVehicles - list of vehicles that can load weapons
Integration: This is a development utility, not part of the main gameplay system
Requirements:
The A3A_Logistics_vehicleHardpoints array must exist and contain valid vehicle hardpoint data
The A3A_Logistics_coveredVehicles array must exist and contain valid vehicle model names
The function is designed for development use only, not for runtime gameplay
The function outputs formatted text that can be copied into new configuration files

A3A Logistics Addon Documentation
Function: fn_generateCargoOffset.sqf
What it does:
The 
fn_generateCargoOffset.sqf
 function generates cargo offset configurations for vehicles by calculating optimal attachment points and generating the necessary configuration data. It's a development utility that helps create proper cargo placement configurations for vehicles.

How it does that:
The function:

Takes vehicle and cargo objects as input along with configuration parameters
Validates input parameters and checks if the vehicle has sufficient nodes for the cargo
Calculates the optimal hardpoint position between the first and last node
Generates visual rendering data for debugging purposes
Creates a properly formatted class definition for the cargo configuration
Sets up visual rendering in the game for debugging the cargo placement
Returns a formatted text output containing the class definition
Code Breakdown:
Sqf

Apply
#include "..\script_component.hpp"
#define BOUNDRYFORWARD [0,0.4,0]
#define BOUNDRYBACKWARDS [0,-0.4,0]
#define COLORRED [0.9,0.1,0.2,1]
#define COLORGREEN [0.1,0.9,0.2,1]
#define COLORWHITE [0.9,0.9,0.9,1]
Purpose: Includes necessary components and defines constants for the function.

Includes the script component header for proper addon integration
Defines boundary vectors for rendering purposes
Defines color constants for visual debugging elements
Sqf

Apply
params [
    ["_vehicle",objNull, [objNull]]
  , ["_cargo",objNull, [objNull]]
  , ["_params", [], [[]]]
  , ["_modelBased", true, [true]]
];
Purpose: Sets up function parameters with defaults.

_vehicle: The vehicle object to configure cargo for (default: null object)
_cargo: The cargo object to be configured (default: null object)
_params: Configuration parameters array (default: empty array)
_modelBased: Whether to use model-based class naming (default: true)
Sqf

Apply
if (isNull _vehicle || isNull _cargo) exitWith {"invalid params: null object(s)"};
Purpose: Validates input parameters.

Checks if either vehicle or cargo is null and exits with error if so
Sqf

Apply
//get vehicle nodes
private _nodes = ([_vehicle] call FUNC(getVehicleNodes)) apply {_x#1};
if (_nodes isEqualTo []) exitWith {"Vehicle lacks nodes, define them or use a different vehicle"};
Purpose: Retrieves vehicle node data.

Gets vehicle node configuration from the vehicle
Exits with error if no nodes are found
Sqf

Apply
private _nodeConfig = [_vehicle] call FUNC(getNodeConfig);
Purpose: Gets node configuration for the vehicle.

Retrieves specific node configuration for the vehicle
Sqf

Apply
_params params [
    ["_offset", [0,0,0], [[]], 3]
  , ["_rotation", [0,1,0], [[]], 3]
  , ["_size", 1, [0]]
  , ["_isWeapon", 0, [0]]
  , ["_recoil", 0, [0]]
];
if (_isWeapon isEqualType 0) then {_isWeapon = _isWeapon isEqualTo 1};
Purpose: Processes configuration parameters.

Sets up default values for offset, rotation, size, isWeapon, and recoil
Converts isWeapon from numeric to boolean format
Sqf

Apply
if (count _nodes < _size) exitWith {"vehicle lacks the capacity for a cargo of this size. Capacity: " + str count _nodes};
if (_isWeapon && 0 == getNumber (_nodeConfig/"canLoadWeapon")) exitWith {"vehicle lacks the ability to load weapons"};
Purpose: Validates capacity and weapon loading capabilities.

Checks if vehicle has enough nodes for the requested cargo size
Checks if vehicle can load weapons when isWeapon is set
Sqf

Apply
//calc general use data
private _firstNode = _nodes#0;
private _lastNode = _nodes#(_size-1);
GVAR(hardpoint) = _lastNode vectorAdd ((_firstNode vectorDiff _lastNode) vectorMultiply 0.5);
Purpose: Calculates the optimal hardpoint position.

Gets first and last nodes for the cargo
Calculates midpoint between first and last nodes for attachment point
Sqf

Apply
//calc render data
//cargo plane
private _tl = _firstNode vectorAdd BOUNDRYFORWARD vectorAdd [-0.6,0,0];
private _tr = _firstNode vectorAdd BOUNDRYFORWARD vectorAdd [0.6,0,0];
private _bl = _lastNode vectorAdd BOUNDRYBACKWARDS vectorAdd [-0.6,0,0];
private _br = _lastNode vectorAdd BOUNDRYBACKWARDS vectorAdd [0.6,0,0];
Purpose: Calculates rendering boundaries for visual debugging.

Sets up points for drawing a rectangle around the cargo area
Sqf

Apply
GVAR(renderLinePairs_vehicle) = [
    [_tl,_tr]
    ,[_tr,_br]
    ,[_br,_bl]
    ,[_bl,_tl]
];
Purpose: Sets up vehicle rendering lines.

Creates line pairs for drawing the vehicle boundary
Sqf

Apply
//cargo bb
private _bb_cargo = 0 boundingBoxReal _cargo;
private _bbMin = _bb_cargo#0;
private _bbMax = _bb_cargo#1;
_bbMin params ["_bbMinX","_bbMinY","_bbMinZ"];
_bbMax params ["_bbMaxX","_bbMaxY","_bbMaxZ"];
Purpose: Gets cargo bounding box information.

Calculates the bounding box of the cargo object
Extracts min and max coordinates for rendering
Sqf

Apply
GVAR(renderLinePairs_cargo) = [
    //square x min
    [[_bbMinX, _bbMinY, _bbMinZ], [_bbMinX, _bbMinY, _bbMaxZ]]
    ,[[_bbMinX, _bbMinY, _bbMaxZ], [_bbMinX, _bbMaxY, _bbMaxZ]]
    ,[[_bbMinX, _bbMaxY, _bbMaxZ], [_bbMinX, _bbMaxY, _bbMinZ]]
    ,[[_bbMinX, _bbMaxY, _bbMinZ], [_bbMinX, _bbMinY, _bbMinZ]]

    //square x max
    ,[[_bbMaxX, _bbMinY, _bbMinZ], [_bbMaxX, _bbMinY, _bbMaxZ]]
    ,[[_bbMaxX, _bbMinY, _bbMaxZ], [_bbMaxX, _bbMaxY, _bbMaxZ]]
    ,[[_bbMaxX, _bbMaxY, _bbMaxZ], [_bbMaxX, _bbMaxY, _bbMinZ]]
    ,[[_bbMaxX, _bbMaxY, _bbMinZ], [_bbMaxX, _bbMinY, _bbMinZ]]

    //square conectors
    ,[[_bbMinX, _bbMinY, _bbMinZ], [_bbMaxX, _bbMinY, _bbMinZ]]
    ,[[_bbMinX, _bbMaxY, _bbMinZ], [_bbMaxX, _bbMaxY, _bbMinZ]]
    ,[[_bbMinX, _bbMinY, _bbMaxZ], [_bbMaxX, _bbMinY, _bbMaxZ]]
    ,[[_bbMinX, _bbMaxY, _bbMaxZ], [_bbMaxX, _bbMaxY, _bbMaxZ]]

    //diagonal
    ,[_bbMin, _bbMax]
];
Purpose: Sets up cargo bounding box rendering lines.

Creates line pairs for drawing the cargo bounding box
Sqf

Apply
GVAR(cargoAttachmentPoint) = [0,0,_bbMinZ];
Purpose: Sets the cargo attachment point.

Defines where the cargo should be attached to the vehicle
Sqf

Apply
//attach cargo at position with rotation specified
private _attachmentPoint = GVAR(hardpoint) vectorAdd _offset;
_cargo attachTo [_vehicle, _attachmentPoint];
if (clientOwner isEqualTo (owner _cargo)) then {
    _cargo setVectorDirAndUp [_rotation,[0,0,1]];
} else {
    [_cargo, [_rotation,[0,0,1]]] remoteExecCall ["setVectorDirAndUp", owner _cargo];
};
Purpose: Attaches cargo to vehicle with specified offset and rotation.

Calculates final attachment point
Attaches cargo to vehicle
Sets rotation if owner is client
Sqf

Apply
GVAR(renderTime) = time + 60;
GVAR(vehicle) = _vehicle;
GVAR(cargo) = _cargo;
Purpose: Sets up rendering variables.

Sets render duration to 60 seconds from current time
Stores vehicle and cargo references for rendering
Sqf

Apply
private _className = if (_modelBased) then { ( (getText ((configOf _cargo)/"model")) splitString "\.") joinString "_" } else {typeOf _cargo};
Purpose: Determines class name for the generated configuration.

Uses model-based naming if _modelBased is true
Uses typeOf if _modelBased is false
Sqf

Apply
private _return = text format [
    "class %1 : TRIPLES(ADDON,Cargo,Base)%7{%7%2%3%4%5%6%7};%7",
    _className,
    "    offset[] = {" + (str _offset select [1, count str _offset - 2]) + "};" + endl,
    "    rotation[] = {" + (str _rotation select [1, count str _rotation - 2]) + "};" + endl,
    "    size = "+ str _size + ";",
    endl + "    recoil = " + str _recoil + ";",
    ["", endl + "    isWeapon = 1;"] select _isWeapon,
    endl
];
Purpose: Creates the formatted class definition text.

Generates complete class definition with all parameters
Formats offset, rotation, size, recoil, and weapon flags
Sqf

Apply
if !(isNil QGVAR(render)) exitWith {_return};
GVAR(render) = addMissionEventHandler ["Draw3D", {
    //draw cargo plane
    {
        drawLine3D  [GVAR(vehicle) modelToWorldVisual (_x#0), GVAR(vehicle) modelToWorldVisual (_x#1), COLORRED];
    } forEach GVAR(renderLinePairs_vehicle);

    //draw cargo bb
    {
        drawLine3D  [GVAR(cargo) modelToWorldVisual (_x#0), GVAR(cargo) modelToWorldVisual (_x#1), COLORWHITE];
    } forEach GVAR(renderLinePairs_cargo);

    //draw hardpoint and cargo base
    drawIcon3D ["\a3\ui_f\data\map\markers\military\dot_ca.paa", COLORGREEN, GVAR(vehicle) modelToWorldVisual GVAR(hardpoint), 0.6, 0.6, 0, "", true, 0.03, "TahomaB", "center"];
    drawIcon3D ["\a3\ui_f\data\map\markers\military\dot_ca.paa", COLORGREEN, GVAR(cargo) modelToWorldVisual GVAR(cargoAttachmentPoint), 0.6, 0.6, 0, "", true, 0.03, "TahomaB", "center"];

    //cleanup
    if (GVAR(renderTime) < time || isNull GVAR(vehicle)) then {
        removeMissionEventHandler ["Draw3D", GVAR(render)];
        GVAR(render) = nil;
        GVAR(vehicle) = nil;
        GVAR(cargo) = nil;
        GVAR(renderLinePairs_vehicle) = nil;
        GVAR(renderLinePairs_cargo) = nil;
        GVAR(hardpoint) = nil;
        GVAR(cargoAttachmentPoint) = nil;
        GVAR(renderTime) = nil;
    };

}];
Purpose: Sets up 3D rendering for debugging.

Adds a Draw3D event handler for visual debugging
Draws vehicle boundaries, cargo bounding box, and attachment points
Cleans up event handler when time expires or vehicle is destroyed
Sqf

Apply
_return
Purpose: Returns the generated class definition.

Returns the formatted text output containing the class definition
Where it leads:
Used by: Development tools for creating cargo configurations
Depends on:
FUNC(getVehicleNodes) - function to get vehicle node data
FUNC(getNodeConfig) - function to get node configuration
TRIPLES(ADDON,Cargo,Base) - base class for cargo configurations
Integration: This is a development utility, not part of the main gameplay system
Requirements:
The A3A_Logistics_attachmentOffset array must exist and contain valid data
The A3A_Logistics_weapons array must exist and contain valid weapon data
The function is designed for development use only, not for runtime gameplay
The function outputs formatted text that can be copied into new configuration files

A3A Logistics Addon Documentation
Function: fn_generateHardPoints.sqf
What it does:
The 
fn_generateHardPoints.sqf
 function generates node arrays for vehicle cargo planes based on visual start and end positions. It creates a series of evenly spaced nodes along a cargo plane and provides visual guides for positioning. The function outputs a formatted class definition that can be used for vehicle attachment points.

Arguments:
<Object> Vehicle your generating the nodes for
<Array> Model relative position of cargo plane start position
<Int> The length of the cargo plane
<Bool> Return prepared for model based definition instead of class based
Return Value:
<Array> vehicle hardpoint point [model, node array]

Scope: Clients
Environment: unscheduled
Public: Yes
Description:
This function generates a rough node array for vehicle cargo planes based on visual start and end positions. It creates evenly spaced nodes along the cargo plane and provides visual guides on screen to help position the cargo plane correctly. The visuals last for 60 seconds and include:

Green dot: Start position of cargo plane (only visible if you can see the position)
Red dot: End position of cargo plane (only visible if you can see the position)
White line: Cargo plane boundaries
White dots: Node return positions
Where it leads:
Used by: Development tools for creating vehicle node configurations
Depends on:
TRIPLES(ADDON,Nodes,Base) - base class for node configurations
modelOfClass(typeOf _vehicle) - function to get model class of vehicle
A3A_Logistics_fnc_getVehicleNodes - function to get vehicle node data
Integration: This is a development utility, not part of the main gameplay system
Requirements:
The vehicle must be valid and exist in the game world
The plane start position must be a valid 3D vector
The plane span must be a positive number
The function is designed for development use only, not for runtime gameplay
The function outputs formatted text that can be copied into new configuration files
Code Walkthrough:
Sqf

Apply
params [["_vehicle", objNull, [objNull]], ["_planeStart", [], [[]], 3], ["_planeSpan", 0, [0]], ["_defineWithModel", true, [true]]];
Purpose: Sets up function parameters with default values and validation types.

Sqf

Apply
//validate input
if (isNull _vehicle) exitWith {"Null vehicle"};
if (_planeStart isEqualTo []) exitWith {"Invalid start off plane"};
if (_planeSpan < 0) exitWith {"Plane length cannot be negative"};
Purpose: Validates input parameters and exits with error messages if invalid.

Sqf

Apply
//calculate nodes
private _planeEnd = +_planeStart;
_planeEnd set [1, (_planeEnd#1) - _planeSpan];
private _diameter = 0.8;
private _radius = _diameter/2;// get some distance from walls
private _plane = _planeStart vectorDiff _planeEnd;
Purpose: Calculates the end position of the cargo plane and sets up parameters for node generation.

Sqf

Apply
private _nodeArray = [];
private _node = _planeStart vectorDiff [0,_radius,0];//first point
while {(_radius*1.5) < (_plane#1)} do {
    _plane = _plane vectorDiff [0,_diameter,0];
    _nodeArray pushBack _node;
    _node = _node vectorDiff [0,_diameter,0];
};
Purpose: Generates evenly spaced nodes along the cargo plane, starting from the calculated start position.

Sqf

Apply
//construct output string
private _nodes = [];
{
    private _offsetArray = str _x;

    _nodes pushBack text (format [
        "        class %1%3        {%3            offset[] = {%2};%3        };",
        "Node"+ str (_forEachIndex + 1),
        _offsetArray select [1, count _offsetArray - 2],
        endl
    ]);
} forEach _nodeArray;
private _nodesString = "    class Nodes" + endl + "    {" + endl + (_nodes joinString endl) + endl + "    };";
Purpose: Formats the node array into a proper class definition string with offset values.

Sqf

Apply
private _return = format ["class %1 : TRIPLES(ADDON,Nodes,Base)%3{%3    %2%3};%3",
    if (_defineWithModel) then { modelOfClass(typeOf _vehicle) } else { typeOf _vehicle },
    _nodesString,
    endl
];
Purpose: Creates the final formatted class definition with either model-based or type-based naming.

Sqf

Apply
//Rendering visuals
A3A_Logistics_nodeArray = _nodeArray;
A3A_Logistics_vehicle = _vehicle;
A3A_Logistics_pStart = _planeStart;
A3A_Logistics_pEnd = _planeEnd;
A3A_Logistics_RenderTime = time + 60;
Purpose: Sets up global variables for rendering visual guides.

Sqf

Apply
if !(isNil "A3A_Logistics_RenderCP") exitWith {_return};
A3A_Logistics_RenderCP = addMissionEventHandler ["Draw3D", {
    //get the render position of the start and end cargo plane positions
    private _startPos = A3A_Logistics_vehicle modelToWorldVisual A3A_Logistics_pStart;
    private _startPosASL = A3A_Logistics_vehicle modelToWorldVisualWorld A3A_Logistics_pStart;
    private _endPos = A3A_Logistics_vehicle modelToWorldVisual A3A_Logistics_pEnd;
    private _endPosASL = A3A_Logistics_vehicle modelToWorldVisualWorld A3A_Logistics_pEnd;

    //plane boundries corner positions
    private _startGuide1 = A3A_Logistics_vehicle modelToWorldVisual (A3A_Logistics_pStart vectorAdd [-0.6,0,0]);
    private _startGuide2 = A3A_Logistics_vehicle modelToWorldVisual (A3A_Logistics_pStart vectorAdd [0.6,0,0]);
    private _endGuide1 = A3A_Logistics_vehicle modelToWorldVisual (A3A_Logistics_pEnd vectorAdd [-0.6,0,0]);
    private _endGuide2 = A3A_Logistics_vehicle modelToWorldVisual (A3A_Logistics_pEnd vectorAdd [0.6,0,0]);

    //Plane Start and end
    if (count (lineIntersectsSurfaces [eyePos player, _startPosASL, player]) isEqualTo 0) then {
        drawIcon3D ["\a3\ui_f\data\map\markers\military\dot_ca.paa", [0.1,0.9,0.2,1], _startPos, 0.6, 0.6, 0, "", true, 0.03, "TahomaB", "center"];
    };
    if (count (lineIntersectsSurfaces [eyePos player, _endPosASL, player]) isEqualTo 0) then {
        drawIcon3D ["\a3\ui_f\data\map\markers\military\dot_ca.paa", [0.9,0.1,0.2,1], _endPos, 0.6, 0.6, 0, "", true, 0.03, "TahomaB", "center"];
    };

    //plane boundries
    drawLine3D [_startGuide1, _startGuide2, [0.9,0.9,0.9,1]];
    drawLine3D [_endGuide1, _endGuide2, [0.9,0.9,0.9,1]];
    drawLine3D [_startGuide1, _endGuide1, [0.9,0.9,0.9,1]];
    drawLine3D [_startGuide2, _endGuide2, [0.9,0.9,0.9,1]];

    //nodes
    {
        drawIcon3D ["\a3\ui_f\data\map\markers\military\dot_ca.paa", [0.9,0.9,0.9,1], A3A_Logistics_vehicle modelToWorldVisual _x, 0.6, 0.6, 0, "", true, 0.03, "TahomaB", "center"];
    } forEach A3A_Logistics_nodeArray;

    //remove if render time is out
    if (A3A_Logistics_RenderTime < time || isNull A3A_Logistics_vehicle) then {
        removeMissionEventHandler ["Draw3D", A3A_Logistics_RenderCP];
        A3A_Logistics_RenderCP = nil;
        A3A_Logistics_vehicle = nil;
        A3A_Logistics_pStart = nil;
        A3A_Logistics_pEnd = nil;
        A3A_Logistics_RenderTime = nil;
    };
}];
Purpose: Sets up 3D rendering for visual guides including start/end positions, plane boundaries, and node positions.

Sqf

Apply
_return;
Purpose: Returns the generated node array class definition.

A3A Logistics Addon Documentation
Function: fn_addAction.sqf
What it does:
The 
fn_addAction.sqf
 function adds load or unload actions to objects in the game. It dynamically creates interactive actions that allow players to load cargo onto vehicles or unload cargo from vehicles. The function handles both loading and unloading actions, with appropriate validation and visual feedback.

How it does that:
The function first validates input parameters and checks if the action already exists. It then creates appropriate action text based on the object type and action type (load/unload). For loading actions, it creates a hold action that triggers the A3A_Logistics_fnc_tryLoad function. For unloading actions, it creates a hold action that triggers the A3A_Logistics_fnc_unload function. The function also sets up user action text for visual feedback and handles JIP (Just-In-Play) key management.

Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
Purpose: Includes the script component header file which likely contains macros and definitions for the logistics addon.

Sqf

Apply
params [["_object", objNull, [objNull]], "_action", ["_jipKey", "", [""]], ["_breakUC",false]];
if (isNull _object) exitWith {
    remoteExec ["", _jipKey]; //clear custom JIP
};
Purpose: Sets up function parameters with default values and validates that the object is not null. If the object is null, it clears the JIP key and exits.

Sqf

Apply
private _actionNames = (actionIDs _object) apply {(_object actionParams _x)#0};
private _vehicleName = nil;

if ((typeOf _object) isEqualTo FactionGet(reb, "lootCrate")) then {
    _vehicleName = localize "STR_antistasi_actions_loot_crate";
} else {
    _vehicleName = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
};
Purpose: Gets existing action names on the object to prevent duplicates, and determines the display name for the vehicle. For loot crates, it uses a specific localized string; otherwise, it gets the display name from the configuration.

Sqf

Apply
private _loadText = format [(format["<img image='\a3\data_f_destroyer\data\ui\igui\cfg\holdactions\holdaction_loadvehicle_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", (localize "STR_antistasi_actions_load_cargo")]), _vehicleName];
Purpose: Creates the localized text for the load action, including an icon and vehicle name.

Sqf

Apply
switch (_action) do {
    case "load":{
        if (_loadText in _actionNames) exitWith {};
Purpose: Handles the load action case, first checking if the action already exists to prevent duplicates.

Sqf

Apply
private _loadActionID = _object addAction
[
    _loadText,
    {
        params ["_target","_caller","_actionID","_breakUC"];
        [_target] remoteExecCall ["A3A_Logistics_fnc_tryLoad",2];
        if (_breakUC) then {_caller setCaptive false};
    },
    _breakUC,
    -5,
    true,
    true,
    "",
    "(
        ((attachedTo _target) isEqualTo objNull)
        and ((vehicle _this) isEqualTo _this)
        and (alive _target)
    )",
    5
];
Purpose: Creates the load action with specific conditions and executes A3A_Logistics_fnc_tryLoad when triggered.

Sqf

Apply
_object setUserActionText [
    _loadActionID,
    _loadText,
    "<t size='2'><img image='\A3\ui_f\data\IGUI\Cfg\Actions\arrow_up_gs.paa'/></t>"
];
_object setVariable ["loadActionID", _loadActionID, false];
Purpose: Sets user-friendly text for the action and stores the action ID in a variable.

Sqf

Apply
case "unload": {
    private _text = format["<img image='\a3\data_f_destroyer\data\ui\igui\cfg\holdactions\holdaction_unloadvehicle_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", (localize "STR_antistasi_actions_unload_cargo")];
    if (_text in _actionNames) exitWith {};
Purpose: Handles the unload action case, creating the unload text and checking for duplicates.

Sqf

Apply
private _unloadActionID = _object addAction
[
    _text,
    {
        params ["_target"];
        [_target] remoteExec ["A3A_Logistics_fnc_unload",2];
    },
    nil,
    -5,
    true,
    true,
    "",
    "(
        !((_target getVariable ['Cargo', []]) isEqualTo [])
        and !(_target getVariable ['LoadingCargo', false])
        and ((vehicle _this) isEqualTo _this)
    )",
    5
];
Purpose: Creates the unload action with specific conditions and executes A3A_Logistics_fnc_unload when triggered.

Sqf

Apply
_object setUserActionText [
    _unloadActionID,
    _text,
    "<t size='2'><img image='\A3\ui_f\data\IGUI\Cfg\Actions\arrow_down_gs.paa'/></t>"
];
_object setVariable ["unloadActionID", _unloadActionID, false];
Purpose: Sets user-friendly text for the unload action and stores the action ID in a variable.

Where it leads:
Called by: Various logistics system functions that need to add actions to objects
Calls:
A3A_Logistics_fnc_tryLoad (for load actions)
A3A_Logistics_fnc_unload (for unload actions)
Depends on:
A3A_Logistics_fnc_tryLoad - for handling load operations
A3A_Logistics_fnc_unload - for handling unload operations
Global variables modified:
loadActionID - stores the ID of the load action for the object
unloadActionID - stores the ID of the unload action for the object
Network implications: Uses remoteExecCall to execute functions on the server
Requirements:
Input object must be valid (not null)
Action parameter must be either "load" or "unload"
JIP key handling for synchronization
Proper validation of object state before adding actions
Network synchronization through remote execution
Function: fn_addOrRemoveObjectMass.sqf
What it does:
The 
fn_addOrRemoveObjectMass.sqf
 function modifies the mass properties of objects in the game world, specifically handling the addition or removal of cargo mass to/from vehicles. It provides visual feedback to players about mass changes and updates the vehicle's physical properties accordingly.

How it does that:
The function first validates that both the cargo object and vehicle are valid and alive. It then retrieves configuration data for both the vehicle and cargo, and determines if the cargo is a weapon. It calculates the mass changes and displays a detailed hint to the player showing the vehicle's mass properties before and after the change.

Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
Purpose: Includes the script component header file which likely contains macros and definitions for the logistics addon.

Sqf

Apply
params [ ["_vehicle", objNull, [objNull] ], ["_object", objNull, [objNull] ] ];
if !(alive _vehicle) exitWith {-1}; //vehicle destroyed
if !(alive _object) exitWith {-2}; //cargo destroyed
Purpose: Sets up function parameters and validates that both vehicle and object are alive.

Sqf

Apply
private _vehConfig = [_vehicle] call A3A_Logistics_fnc_getNodeConfig;
if (isNull _vehConfig) exitWith {-7};
Purpose: Gets the vehicle's node configuration and exits with error code -7 if null.

Sqf

Apply
private _cargoConfig = [_object] call A3A_Logistics_fnc_getCargoConfig;
if (isNull _cargoConfig) exitWith {-3};
private _objNodeType = [_object] call A3A_Logistics_fnc_getCargoNodeType;
if (_objNodeType isEqualTo -1) exitWith {-3}; //invalid cargo
Purpose: Gets cargo configuration and validates node type, exiting with error code -3 if invalid.

Sqf

Apply
private _weapon = 1 == getNumber (_cargoConfig/"isWeapon");
private _allowed = if (!_weapon) then {true} else {
    if (0 == getNumber (_vehConfig/"canLoadWeapon")) exitWith {false};

    private _vehModel = getText (configFile/"CfgVehicles"/typeOf _vehicle/"model");
    private _blackList = getArray (_cargoConfig/"blackList");
    !(
        _vehModel in _blackList
        || typeOf _vehicle in _blackList
    )
};
if !(_allowed) exitWith {-5}; //weapon not allowed on vehicle
Purpose: Determines if the cargo is a weapon and whether it's allowed on the vehicle, exiting with error code -5 if not allowed.

Sqf

Apply
private _nodes = _vehicle getVariable [QGVAR(Nodes),nil];
if (isNil "_nodes") then {
    _nodes = [_vehicle] call A3A_Logistics_fnc_getVehicleNodes;
    _vehicle setVariable [QGVAR(Nodes), _nodes];
};
Purpose: Gets vehicle nodes or initializes them if not already set.

Sqf

Apply
private _defaultMass = getNumber (_vehConfig/"defaultMass");
private _cargoMass = getNumber (_cargoConfig/"mass");
private _newMass = _defaultMass + _cargoMass;
Purpose: Retrieves mass values from configurations and calculates the new mass.

Sqf

Apply
private _text = format [
    "
    <img image='%1' size='2' align='left'/>
    <t color='#a02e69' size='1.2' shadow='1' shadowColor='#000000' align='center'>%2</t><br/>
    <t color='#00aafd' size='1.2' shadow='1' shadowColor='#000000' align='left'>%6: </t>
    <t color='#00ff59' size='1.2' shadow='1' shadowColor='#000000' align='left'>%3</t><br/>
    <t color='#00aafd' size='1.2' shadow='1' shadowColor='#000000' align='left'>%7: </t>
    <t color='#00ff59' size='1.2' shadow='1' shadowColor='#000000' align='left'>%4</t><br/>
    <t color='#00aafd' size='1.2' shadow='1' shadowColor='#000000' align='left'>%8: </t>
    <t color='#00ff59' size='1.2' shadow='1' shadowColor='#000000' align='left'>%5</t><br/>
    ",
    getText(configFile >> "cfgVehicles" >> typeOf _vehicle >> "picture"),
    getText(configFile >> "cfgVehicles" >> typeOf _vehicle >> "displayName"),
    _defaultMass,
    _cargoMass,
    _newMass,
    localize "STR_A3A_Logistics_addOrRemoveObjectMass_additive_1",
    localize "STR_A3A_Logistics_addOrRemoveObjectMass_additive_2",
    localize "STR_A3A_Logistics_addOrRemoveObjectMass_additive_3"
];
Purpose: Creates formatted text with vehicle picture and mass information for display.

Sqf

Apply
_text = _text + _msg;
Purpose: Appends additional message to the formatted text.

Sqf

Apply
[localize "STR_A3A_Logistics_header", parseText _text] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner];
[localize "STR_A3A_Logistics_header", parseText _text] remoteExec ["A3A_fnc_customHint", crew _vehicle];
Purpose: Displays the formatted mass information to the player and vehicle crew using custom hint system.

Where it leads:
Called by: Functions that need to update vehicle mass when cargo is added or removed
Calls:
A3A_Logistics_fnc_getNodeConfig - for vehicle configuration
A3A_Logistics_fnc_getCargoConfig - for cargo configuration
A3A_Logistics_fnc_getCargoNodeType - for cargo node type
A3A_Logistics_fnc_getVehicleNodes - for vehicle node information
Depends on:
Configuration files for vehicles and cargo
Mass calculation logic
Custom hint system for player feedback
Global variables modified: None directly, but affects vehicle mass properties
Network implications: Uses remoteExec to display hints to players
Requirements:
Both vehicle and object must be alive
Valid configurations for both vehicle and cargo
Proper mass calculation and display formatting
Network synchronization for player feedback
Error handling for invalid configurations or mass values
Function: fn_addWeaponAction.sqf
What it does:
The 
fn_addWeaponAction.sqf
 function adds interactive actions to vehicles for players to get into mounted static weapons. It also sets up event handlers for weapon destruction and player movement when exiting the weapon.

How it does that:
The function first validates that both cargo (weapon) and vehicle are valid. It creates a "get in" action that allows players to move into the gunner position of the static weapon. It sets up event handlers to remove the action when the weapon is destroyed and to move players to appropriate positions when exiting the weapon. It also breaks undercover status for players getting into the weapon.

Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
Purpose: Includes the script component header file which likely contains macros and definitions for the logistics addon.

Sqf

Apply
params [["_cargo", objNull, [objNull]], ["_vehicle", objNull, [objNull]], ["_jipKey", "", [""]]];
if (isNull _cargo || isNull _vehicle) exitWith {
    remoteExec ["", _jipKey]; //clear custom JIP
};
Purpose: Sets up function parameters and validates that both cargo and vehicle are not null.

Sqf

Apply
private _name = getText (configFile >> "CfgVehicles" >> typeOf _cargo >> "displayName");
private _text = format [(localize "STR_antistasi_actions_get_in_gunner"), _name];
Purpose: Gets the weapon's display name and creates localized text for the action.

Sqf

Apply
private _actionID = _vehicle addAction [
    _text,
    {
        params ["_vehicle", "_caller", "_id", "_static"];
        if !(attachedTo _static isEqualTo _vehicle) exitWith {[_vehicle, _id] remoteExecCall ["removeAction", 0]};// incase of code break in unloading static
        if (!alive gunner _static) then {
            _caller moveInGunner _static;
        } else {[localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_addWeaponAction_staticoccupied"] call A3A_fnc_customHint};
    },
    _cargo,
    5.5,
    true,
    true,
    "",
    "(
        ((attachedTo _this) isEqualTo objNull)
        and (_this isEqualTo (vehicle _this))
        and ((gunner _target) isEqualTo objNull)
    )",
    5
];
Purpose: Creates the "get in" action with conditions and executes the action logic when triggered.

Sqf

Apply
_vehicle setUserActionText [
    _actionID,
    _text,
    "<t size='2'><img image='\A3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/></t>"
];
_cargo setVariable ["getInAction", _actionID];
Purpose: Sets user-friendly text for the action and stores the action ID in the cargo variable.

Sqf

Apply
private _KilledEH = _cargo addEventHandler ["Killed", {
    params ["_cargo"];
    private _vehicle = attachedTo _cargo;
    [_vehicle, _cargo] remoteExecCall ["A3A_Logistics_fnc_removeWeaponAction",0]
}];
_cargo setVariable ["KilledEH", _KilledEH];
_cargo enableWeaponDisassembly false;
Purpose: Sets up event handler for when the weapon is destroyed, removes the action, and disables weapon disassembly.

Sqf

Apply
private _GetOutEH = _cargo addEventHandler ["GetOut", {
    params ["_cargo", "", "_unit"];
    private _vehicle = attachedTo _cargo;
    if (isNull _vehicle) exitWith { _cargo removeEventHandler ["GetOut", _thisEventHandler] };

    private _bb = 3 boundingBoxReal _vehicle;
    private _mPos = [(_bb#0#0) - 0.3, (_vehicle worldToModel getPos _cargo)#1, _bb#0#2];
    private _newPos = _vehicle modelToWorld _mPos;
    _unit setPos _newPos;
}];
_cargo setVariable ["GetOutEH", _GetOutEH];
Purpose: Sets up event handler for when player gets out of the weapon, positions them appropriately.

Sqf

Apply
private _undercoverBreak = _vehicle addEventHandler ["GetIn", {
    _this spawn {sleep 0.1; (_this#2) setCaptive false};
}];
_vehicle setVariable ["undercoverBreak", _undercoverBreak];
Purpose: Sets up event handler to break undercover status for players getting into the vehicle.

Sqf

Apply
[_cargo] call A3A_Logistics_fnc_initMountedWeapon;
Purpose: Initializes the mounted weapon with additional features.

Where it leads:
Called by: Functions that need to set up static weapon actions
Calls:
A3A_Logistics_fnc_removeWeaponAction - for removing actions when weapon is destroyed
A3A_Logistics_fnc_initMountedWeapon - for initializing weapon features
Depends on:
Static weapon configuration
Vehicle attachment system
Player movement and positioning
Global variables modified:
getInAction - stores the ID of the get-in action
KilledEH
Network implications: Uses remoteExecCall to execute functions on the server for action removal and initialization

Function: fn_canLoad.sqf
What it does:
The 
fn_canLoad.sqf
 function verifies whether cargo can be loaded onto a vehicle. It performs comprehensive validation checks to ensure the loading operation is safe and appropriate, returning either an error code or a successful result with necessary loading parameters.

How it does that:
The function performs a series of validation checks:

Checks if both vehicle and cargo are alive and valid
Validates vehicle configuration for cargo loading capability
Determines if the cargo is loadable and not a static weapon with a gunner
Validates weapon compatibility with the vehicle
Checks if units are conscious or otherwise unable to be loaded
Identifies available nodes on the vehicle for cargo placement
Ensures no crew members are blocking the loading seats
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params [ ["_vehicle", objNull, [objNull] ], ["_object", objNull, [objNull] ] ];
if !(alive _vehicle) exitWith {-1}; //vehicle destroyed
if !(alive _object) exitWith {-2}; //cargo destroyed
Purpose: Sets up function parameters and validates that both vehicle and object are alive.

Sqf

Apply
//check if vehicle can load cargo
private _vehConfig = [_vehicle] call A3A_Logistics_fnc_getNodeConfig;
if (isNull _vehConfig) exitWith {-7};
Purpose: Gets the vehicle's node configuration and exits with error code -7 if null.

Sqf

Apply
//get cargo node size
private _cargoConfig = [_object] call A3A_Logistics_fnc_getCargoConfig;
if (isNull _cargoConfig) exitWith {-3};
private _objNodeType = [_object] call A3A_Logistics_fnc_getCargoNodeType;
if (_objNodeType isEqualTo -1) exitWith {-3}; //invalid cargo
Purpose: Gets cargo configuration and validates node type, exiting with error code -3 if invalid.

Sqf

Apply
if !(
    ((gunner _object) isEqualTo _object)
    or ((gunner _object) isEqualTo objNull)
) exitWith {-4}; //gunner in static
Purpose: Checks if the cargo is a static weapon with a gunner, which prevents loading.

Sqf

Apply
//is weapon? and weapon allowed
private _weapon = 1 == getNumber (_cargoConfig/"isWeapon");
private _allowed = if (!_weapon) then {true} else {
    if (0 == getNumber (_vehConfig/"canLoadWeapon")) exitWith {false};

    private _vehModel = getText (configFile/"CfgVehicles"/typeOf _vehicle/"model");
    private _blackList = getArray (_cargoConfig/"blackList");
    !(
        _vehModel in _blackList
        || typeOf _vehicle in _blackList
    )
};
if !(_allowed) exitWith {-5}; //weapon not allowed on vehicle
Purpose: Determines if the cargo is a weapon and whether it's allowed on the vehicle, exiting with error code -5 if not allowed.

Sqf

Apply
if ((_object isKindOf "CAManBase") and (
    ( [_object] call A3A_fnc_canFight )
    or !( isNull (_object getVariable ["helped",objNull]) )
    or !( isNull attachedTo _object )
)) exitWith {-6}; //conscious man
Purpose: Checks if the cargo is a conscious unit that cannot be loaded, exiting with error code -6.

Sqf

Apply
//get vehicle nodes
private _nodes = _vehicle getVariable [QGVAR(Nodes),nil];

//if nodes not initilized
if (isNil "_nodes") then {
    _nodes = [_vehicle] call A3A_Logistics_fnc_getVehicleNodes;
    _vehicle setVariable [QGVAR(Nodes), _nodes];
};
Purpose: Gets vehicle nodes or initializes them if not already set.

Sqf

Apply
//Vehicle not able to carry cargo
if (_nodes isEqualTo []) exitWith {-7};

//enough free nodes to load cargo
private "_node";
{
    private _currentNodes = [];
    for "_i" from 0 to _objNodeType - 1 do {
        private _currentNode = _forEachIndex + _i;
        if (isNil {_nodes#_currentNode}) exitWith {};//zero divisor block
        if (((_nodes#_currentNode)#0) isEqualTo 1) then {_currentNodes pushBack _nodes#_currentNode};
    };
    if ((count _currentNodes) isEqualTo _objNodeType) exitWith {_node = _currentNodes};
} forEach _nodes;
if (isNil "_node") exitWith {-8};
Purpose: Finds available nodes on the vehicle for cargo placement, exiting with error code -8 if insufficient space.

Sqf

Apply
//block loading if crew in node seats
private _fullCrew = fullCrew _vehicle;
private _seats = [];
if ((_node#0) isEqualType []) then {
    {_seats append (_x#2)} forEach _node;
} else {
    _seats append (_node#2);
};
if !(_fullCrew findIf {_x#2 in _seats} isEqualTo -1) exitWith {-9};
Purpose: Checks if crew members are blocking the loading seats, exiting with error code -9 if they are.

Sqf

Apply
[_object, _vehicle, _node, _weapon]
Purpose: Returns the successful result with cargo, vehicle, node, and weapon information.

Where it leads:
Called by: Functions that need to validate cargo loading operations
Calls:
A3A_Logistics_fnc_getNodeConfig - for vehicle configuration
A3A_Logistics_fnc_getCargoConfig - for cargo configuration
A3A_Logistics_fnc_getCargoNodeType - for cargo node type
A3A_Logistics_fnc_getVehicleNodes - for vehicle node information
A3A_fnc_canFight - for checking if a unit can fight
Depends on:
Configuration files for vehicles and cargo
Node system for vehicle loading
Crew management system
Global variables modified:
Nodes - stores vehicle node information
Network implications: No direct network calls, but may be called from remote-executed functions
Requirements:
Both vehicle and object must be alive
Valid configurations for both vehicle and cargo
Proper node system setup for vehicles
Crew management system for seat blocking checks
Error handling for various loading scenarios
Error codes:
-1: Vehicle not alive or null
-2: Cargo not alive or null
-3: Cargo not loadable
-4: Gunner in static weapon (cargo)
-5: Weapon not allowed on vehicle
-6: Unit no longer loadable (conscious)
-7: Vehicle unable to load any cargo
-8: Not enough space to load cargo onto vehicle
-9: Units in cargo seats blocking loading

Function: fn_getCargoConfig.sqf
What it does:
The 
fn_getCargoConfig.sqf
 function retrieves the cargo configuration for a given vehicle class or object. It searches through multiple configuration levels to find the appropriate cargo definition, prioritizing mission-specific configurations over default ones.

How it does that:
The function first validates the input parameter and converts object parameters to class names. It then searches through several configuration levels in order of priority:

Mission configuration by class name
Vehicle-specific configuration
Default configuration class
Mission configuration by model name
Default configuration by model name If no configuration is found, it returns configNull.
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params [["_class","",["",objNull]]];
if (_class isEqualType objNull) then {_class = typeOf _class};
Purpose: Includes the script component header and sets up function parameters with validation. If input is an object, it extracts the class name.

Sqf

Apply
#define cgVehicle (configFile/"CfgVehicles"/_class)
#define VehicleNodes (configFile/"CfgVehicles"/_class/QGVAR(Cargo))
#define CfgNodes (configFile/"A3A"/QGVAR(Cargo))
#define MissionNodes (missionConfigFile/"A3A"/QGVAR(Cargo))
Purpose: Defines macros for easier configuration access paths.

Sqf

Apply
if !(isClass cgVehicle) exitWith { configNull };
Purpose: Validates that the vehicle class exists in the configuration, returning configNull if not.

Sqf

Apply
if (isClass (MissionNodes/_class)) exitWith { (MissionNodes/_class) };
if (isClass VehicleNodes) exitWith { VehicleNodes };
if (isClass (CfgNodes/_class)) exitWith { (CfgNodes/_class) };
Purpose: Searches for configuration in order of priority: mission config by class, vehicle config, default config by class.

Sqf

Apply
private _model = modelOfClass(_class);
if (isClass (MissionNodes/_model)) exitWith { (MissionNodes/_model) };
if (isClass (CfgNodes/_model)) exitWith { (CfgNodes/_model) };
configNull;
Purpose: Searches for configuration by model name and returns configNull if none found.

Where it leads:
Called by: Functions that need cargo configuration data
Calls:
modelOfClass - for getting model class from vehicle class
Depends on:
Configuration files for vehicles and cargo
Mission configuration system
Global variables modified: None
Network implications: No direct network calls
Requirements:
Input must be a valid vehicle class or object
Configuration files must be properly structured
Model class function must be available
Configuration hierarchy must be maintained
Function: fn_getCargoNodeType.sqf
What it does:
The 
fn_getCargoNodeType.sqf
 function determines the node size/type of a cargo object. It retrieves the cargo configuration and extracts the size property, which indicates how many nodes the cargo occupies.

How it does that:
The function first validates that the input object is valid. It then retrieves the cargo configuration for the object and extracts the "size" property from the configuration. If no valid configuration is found, it returns -1.

Code Walkthrough:
Sqf

Apply
params [["_object", objNull, [objNull, ""]]];
Purpose: Sets up function parameters with validation for the cargo object.

Sqf

Apply
private _config = [_object] call A3A_Logistics_fnc_getCargoConfig;
if (isNull _config) exitWith {-1};
Purpose: Gets the cargo configuration and exits with -1 if null.

Sqf

Apply
getNumber (_config/"size");
Purpose: Retrieves and returns the "size" property from the cargo configuration.

Where it leads:
Called by: Functions that need to know how much space cargo occupies
Calls:
A3A_Logistics_fnc_getCargoConfig - for retrieving cargo configuration
Depends on:
Cargo configuration system
Node system for size calculations
Global variables modified: None
Network implications: No direct network calls
Requirements:
Input must be a valid cargo object
Cargo configuration must be available
Size property must be defined in configuration
Function: fn_getCargoOffsetAndDir.sqf
What it does:
The 
fn_getCargoOffsetAndDir.sqf
 function retrieves the offset and rotation values for attaching cargo to a vehicle. It provides the necessary positioning data for proper cargo placement.

How it does that:
The function retrieves the cargo configuration and extracts the "offset" and "rotation" properties. It handles special cases for human units (CAManBase) by returning default values. It returns both values in an array format.

Code Walkthrough:
Sqf

Apply
params [["_object", objNull, [objNull, ""]]];
Purpose: Sets up function parameters with validation for the cargo object.

Sqf

Apply
private _config = [_object] call A3A_Logistics_fnc_getCargoConfig;
if (isNull _config) exitWith { [[0,0,0], [0,0,0]] };
Purpose: Gets the cargo configuration and exits with default values if null.

Sqf

Apply
if (_object isKindOf "CAManBase") exitWith { [[0,0,0], [0,0,0]] };//exception for the mdical system
Purpose: Special handling for human units, returning default values for medical system exceptions.

Sqf

Apply
[getArray (_config/"offset"), getArray (_config/"rotation")];
Purpose: Returns the offset and rotation arrays from the cargo configuration.

Where it leads:
Called by: Functions that need positioning data for cargo attachment
Calls:
A3A_Logistics_fnc_getCargoConfig - for retrieving cargo configuration
Depends on:
Cargo configuration system
Offset and rotation properties in configuration
Global variables modified: None
Network implications: No direct network calls
Requirements:
Input must be a valid cargo object
Cargo configuration must contain offset and rotation properties
Configuration system must be properly structured
Function: fn_getNodeConfig.sqf
What it does:
The 
fn_getNodeConfig.sqf
 function retrieves the node configuration for a given vehicle class or object. It searches through multiple configuration levels to find the appropriate node definition, prioritizing mission-specific configurations over default ones.

How it does that:
The function first validates the input parameter and converts object parameters to class names. It then searches through several configuration levels in order of priority:

Mission configuration by class name
Vehicle-specific configuration
Default configuration class
Mission configuration by model name
Default configuration by model name If no configuration is found, it returns configNull.
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params [["_class","",["",objNull]]];
if (_class isEqualType objNull) then {_class = typeOf _class};
Purpose: Includes the script component header and sets up function parameters with validation. If input is an object, it extracts the class name.

Sqf

Apply
#define cfgVehicle (configFile/"CfgVehicles"/_class)
#define VehicleNodes (configFile/"CfgVehicles"/_class/QGVAR(Nodes))
#define CfgNodes (configFile/"A3A"/QGVAR(Nodes))
#define MissionNodes (missionConfigFile/"A3A"/QGVAR(Nodes))
Purpose: Defines macros for easier configuration access paths.

Sqf

Apply
if !(isClass cfgVehicle) exitWith { configNull };
Purpose: Validates that the vehicle class exists in the configuration, returning configNull if not.

Sqf

Apply
if (isClass (MissionNodes/_class)) exitWith { (MissionNodes/_class) };
if (isClass VehicleNodes) exitWith { VehicleNodes };
if (isClass (CfgNodes/_class)) exitWith { (CfgNodes/_class) };
Purpose: Searches for configuration in order of priority: mission config by class, vehicle config, default config by class.

Sqf

Apply
private _model = modelOfClass(_class);
if (isClass (MissionNodes/_model)) exitWith { (MissionNodes/_model) };
if (isClass (CfgNodes/_model)) exitWith { (CfgNodes/_model) };
configNull;
Purpose: Searches for configuration by model name and returns configNull if none found.

Where it leads:
Called by: Functions that need vehicle node configuration data
Calls:
modelOfClass - for getting model class from vehicle class
Depends on:
Configuration files for vehicles and nodes
Mission configuration system
Global variables modified: None
Network implications: No direct network calls
Requirements:
Input must be a valid vehicle class or object
Configuration files must be properly structured
Model class function must be available
Configuration hierarchy must be maintained
Function: fn_getVehicleNodes.sqf
What it does:
The 
fn_getVehicleNodes.sqf
 function retrieves the node array for a given vehicle. It gets the vehicle's node configuration and processes it to return an array of node data that can be used for cargo loading operations.

How it does that:
The function first validates the input vehicle and retrieves its node configuration. It then gets all properties from the "Nodes" configuration section and processes them to create a standardized node array format with offset and seat information.

Code Walkthrough:
Sqf

Apply
params [["_vehicle", objNull, [objNull, ""]]];
private _config = [_vehicle] call A3A_Logistics_fnc_getNodeConfig;
if (isNull _config) exitWith { [] };
Purpose: Sets up function parameters and gets the vehicle's node configuration, returning empty array if null.

Sqf

Apply
private _nodes = configProperties [(_config/"Nodes"), "true", true];
_nodes apply { [1, getArray (_x/"offset"), getArray (_x/"seats")] };
Purpose: Gets all node properties and transforms them into a standardized array format with [1, offset, seats].

Where it leads:
Called by: Functions that need vehicle node data for loading operations
Calls:
A3A_Logistics_fnc_getNodeConfig - for retrieving node configuration
Depends on:
Node configuration system
Configuration properties access
Global variables modified: None
Network implications: No direct network calls
Requirements:
Input must be a valid vehicle object
Vehicle must have a valid node configuration
Configuration system must be properly structured
Function: fn_initMountedWeapon.sqf
What it does:
The 
fn_initMountedWeapon.sqf
 function adds functional features to mounted weapons, including recoil effects and proper cleanup when the weapon is no longer attached. It enhances the realism of static weapons by simulating weapon recoil.

How it does that:
The function first retrieves the weapon's cargo configuration to get recoil values. It then sets up an event handler for the "Fired" event that applies recoil force to the vehicle when the weapon fires. The function also sets up cleanup to remove the event handler when the weapon is detached.

Code Walkthrough:
Sqf

Apply
params ["_weapon"];
Purpose: Sets up function parameter for the mounted weapon object.

Sqf

Apply
//weapon recoil
private _cargoConfig = [_weapon] call A3A_Logistics_fnc_getCargoConfig;
private _fireForce = if (isNull _cargoConfig) then { 0 } else { getNumber (_cargoConfig/"recoil") };
_weapon setVariable ["fireForce", _fireForce, true];
Purpose: Gets the weapon's recoil configuration and stores it in a variable.

Sqf

Apply
//credits to audiocustoms on youtube (Cup dev) for the concept and CalebSerafin for optimisation.
private _idRecoil = _weapon addEventHandler ["Fired", compile ('
    params ["_weapon"];
    private _vehicle = attachedTo _weapon;
    private _weaponDir = _weapon weaponDirection currentWeapon _weapon;
    private _appliedForce = (_weaponDir vectorMultiply -' + (str _fireForce) +');
    _vehicle addForce [_appliedForce, ' + (str (_weapon getVariable ["AttachmentOffset", [0,0,0]])) + '];
')];
Purpose: Sets up the fired event handler that applies recoil force to the vehicle when the weapon fires.

Sqf

Apply
[_weapon, _idRecoil] spawn {
    params ["_weapon", "_idRecoil"];
    waitUntil {sleep 1; (attachedTo _weapon) isEqualTo objNull};
    _weapon removeEventHandler ["Fired", _idRecoil];
};
Purpose: Sets up a cleanup process that removes the event handler when the weapon is no longer attached.

Sqf

Apply
nil
Purpose: Returns nil as the function's result.

Where it leads:
Called by: Functions that set up mounted weapons
Calls:
A3A_Logistics_fnc_getCargoConfig - for retrieving weapon configuration
Depends on:
Weapon configuration system
Event handling system
Vehicle attachment system
Global variables modified:
fireForce - stores the recoil force value for the weapon
Network implications: Uses spawn and waitUntil for asynchronous cleanup
Requirements:
Input must be a valid mounted weapon object
Weapon must have proper configuration with recoil values
Vehicle attachment system must be functional
Event handling system must be available

Function: fn_load.sqf
What it does:
The 
fn_load.sqf
 function handles the loading of cargo objects into vehicles. It manages the entire loading process including node allocation, positioning, attachment, and updating vehicle state information.

How it does that:
The function performs several key operations:

Validates that the vehicle isn't already loading cargo
Sets up JIP (Just-In-Play) keys for synchronization
Updates the vehicle's node list to mark used nodes as occupied
Calculates proper positioning and attachment points
Handles seat locking for crew members
Manages the physical attachment of cargo to the vehicle
Implements smooth loading animation
Updates vehicle cargo lists and performs cleanup
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params ["_cargo", "_vehicle", "_node", "_weapon", ["_instant", false, [true]]];
Purpose: Includes script component and sets up function parameters with default values.

Sqf

Apply
if (_vehicle getVariable ["LoadingCargo", false]) exitWith {
    [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_load_alreadyloading"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner]; 
    nil
};
_vehicle setVariable ["LoadingCargo",true,true];
Purpose: Checks if vehicle is already loading cargo and exits with error if so. Sets loading state to true.

Sqf

Apply
//object string for jip
private _objStringCargo = str _cargo splitString ":" joinString "";
private _objStringVehicle = str _vehicle splitString ":" joinString "";
Purpose: Creates unique JIP keys by converting object strings to avoid duplicates.

Sqf

Apply
//update list of nodes on vehicle
_updateList = {
    params ["_vehicle", "_node"];
    private _list = _vehicle getVariable [QGVAR(Nodes),[]];
    private _index = _list find _node;
    _node set [0,0];
    _list set [_index, _node];
    _vehicle setVariable [QGVAR(Nodes), _list, true];
};
Purpose: Defines a local function to update the vehicle's node list, marking nodes as occupied.

Sqf

Apply
//find node point and seats
private _nodeOffset = [0,0,0];
private _seats = [];

if ((_node#0) isEqualType []) then {
    //offset
    private _lastNode = (count _node) -1;
    private _offsetOne = (_node#0#1);
    private _offsetTwo = (_node#_lastNode#1);
    private _diff = _offsetOne vectorDiff _offsetTwo;
    _nodeOffset = _offsetTwo vectorAdd [0,(_diff#1)/2,0];

    //seats
    {
        _seats append (_x#2);
    } forEach _node;

    //update cargo list
    for "_i" from 0 to _lastNode do {
        [_vehicle, _node#_i] call _updateList;
    };
} else { //single node
    //offset
    _nodeOffset = (_node#1);
    //seats
    _seats append (_node#2);
    //update list
    [_vehicle , _node] call _updateList;
};
Purpose: Processes node data to calculate offset and seat information, updating the node list accordingly.

Sqf

Apply
private _isLootcrate = (typeOf _cargo) isEqualTo (A3A_faction_reb get "lootCrate");
if (_isLootcrate) then {
    _cargo allowDamage false;
};
Purpose: Handles special case for loot crates by disabling damage during loading.

Sqf

Apply
//attach data
private _offsetAndDir = [_cargo] call A3A_Logistics_fnc_getCargoOffsetAndDir;
private _location = _offsetAndDir#0;
private _location = _location vectorAdd _nodeOffset;

private _bbVehicle = boundingBoxReal _vehicle select 0 select 1;
private _bbCargo = boundingBoxReal _cargo select 0 select 1;
private _yStart = _bbVehicle + _bbCargo - 0.1;
private _yEnd = _location#1;
_cargo setVariable ["AttachmentOffset", _location];
Purpose: Calculates attachment location and sets up positioning data for cargo.

Sqf

Apply
//block seats
[_cargo, true] remoteExec ["A3A_Logistics_fnc_toggleLock", 0, "A3A_Logistics_toggleLock" + _objStringCargo];
[_vehicle, true, _seats] remoteExecCall ["A3A_Logistics_fnc_toggleLock", 0, "A3A_Logistics_toggleLock" + _objStringVehicle];
_cargo engineOn false;
Purpose: Locks seats and disables engine for the cargo object.

Sqf

Apply
//break undercover
if (_weapon && !_instant) then {
    {_x setCaptive false;}forEach crew _vehicle;
    player setCaptive false;
};
Purpose: Breaks undercover status for crew if loading a weapon.

Sqf

Apply
//initial attachement, hide uglyness
_vectorUp = if (_cargo isKindOf "CAManBase") then {[0,0,0]} else {[0,0,1]};
_location set [1, _yStart];
_cargo hideObjectGlobal true;
_cargo attachto [_vehicle,_location];
[_cargo, [(_offsetAndDir#1),[0,0,1]]] remoteExecCall ["setVectorDirAndUp", owner _cargo]; //need to be done where cargo is local, command broadcast updated vector dir and up
_cargo hideObjectGlobal false;
Purpose: Performs initial attachment with hiding to avoid visual glitches.

Sqf

Apply
_vehicle animateDoor ["Door_rear", 1];
//slideing attachment
if (_instant) then {
    _location set [1, _yEnd+0.1];
    _cargo attachto [_vehicle,_location];
} else {
    private _prevTime = time;
    while {(_location#1) < _yEnd} do {
        uiSleep 0.01;
        _location = _location vectorAdd [0,time-_prevTime,0];
        _cargo attachto [_vehicle,_location];
        _prevTime = time;
    };
};
Purpose: Implements smooth loading animation or instant loading based on parameter.

Sqf

Apply
//update loaded list (for unload ease)
private _previousLoaded = _vehicle getVariable ["Cargo", []];
private _loadedCargo = [[_cargo,_node]] + _previousLoaded;
_vehicle setVariable ["Cargo", _loadedCargo, true];
Purpose: Updates the vehicle's cargo list with the newly loaded cargo.

Sqf

Apply
//misc
[_cargo] call A3A_Logistics_fnc_toggleAceActions;
[_vehicle, _cargo, nil, _instant] call A3A_Logistics_fnc_addOrRemoveObjectMass;
Purpose: Toggles ACE actions and updates vehicle mass.

Sqf

Apply
if (_isLootcrate) then {
    _nil = [_cargo] spawn {
        params["_cargo"];
        if (!isNil "_cargo" && {alive _cargo}) then {
            private _timeOut = time + 10;
            waitUntil {_timeOut < time};
            _cargo allowDamage true;
        };
        terminate _thisScript;
    };
};
Purpose: Re-enables damage for loot crates after a timeout.

Sqf

Apply
if (_weapon) then {
        private _jipKey = "A3A_Logistics_weaponAction_" + _objStringCargo;
    [_cargo, _vehicle, _jipKey] remoteExec ["A3A_Logistics_fnc_addWeaponAction", 0, _jipKey];
};
_vehicle animateDoor ["Door_rear", 0];
_vehicle setVariable ["LoadingCargo",nil,true];
Purpose: Adds weapon actions if needed and cleans up loading state.

Sqf

Apply
private _jipKey = "A3A_Logistics_unload_" + _objStringVehicle;
[_vehicle, "unload", _jipKey] remoteExec ["A3A_Logistics_fnc_addAction", 0 ,_jipKey];
nil
Purpose: Adds unload action to vehicle and returns nil.

Where it leads:
Called by: Functions that initiate cargo loading operations
Calls:
A3A_Logistics_fnc_getCargoOffsetAndDir - for positioning data
A3A_Logistics_fnc_toggleLock - for seat locking
A3A_Logistics_fnc_addOrRemoveObjectMass - for mass updates
A3A_Logistics_fnc_toggleAceActions - for ACE action toggling
A3A_Logistics_fnc_addWeaponAction - for weapon actions
A3A_Logistics_fnc_getVehicleNodes - for node refresh
Depends on:
Node system for vehicle loading
Cargo configuration system
ACE actions system
Vehicle attachment system
Global variables modified:
LoadingCargo - vehicle loading state
Cargo - vehicle cargo list
Nodes - vehicle node list
Network implications: Uses remoteExec and remoteExecCall for synchronization
Requirements:
Valid cargo and vehicle objects
Proper node configuration
Cargo configuration with offset and rotation data
ACE actions system for optional toggling
Vehicle attachment system for positioning
Function: fn_packObject.sqf
What it does:
The 
fn_packObject.sqf
 function handles the packing of objects into different objects for transportation. It creates a package container and transfers the original object's properties to the new container.

How it does that:
The function:

Validates that the object is not attached to anything
Determines the appropriate package class for the object
Creates a new package vehicle at the object's position
Transfers the original object type to the package
Disables damage on the package
Deletes the original object
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params  [
    ["_object", objNull, [objNull]]
];
Purpose: Includes script component and sets up function parameter with validation.

Sqf

Apply
if(!(isNull attachedTo _object)) exitWith {};
Purpose: Exits if the object is already attached to something.

Sqf

Apply
//search the object will be the package
private _packageClassName = getText (configFile >> "A3A" >> "A3A_Logistics_Packable" >> typeOf _object >> "packObject"); 
if (_packageClassName isEqualTo "") then {_packageClassName = "CargoNet_01_box_F"};
Purpose: Gets the package class name from configuration or defaults to CargoNet_01_box_F.

Sqf

Apply
//create package
private _package = objNull;
isNil {
    _package = createVehicle [_packageClassName, getPosATL _object, [], 0, "CAN_COLLIDE"];
    _package setVariable ["A3A_packedObject", typeOf _object, true]; 
    _package allowDamage false;
    deleteVehicle _object;
};
Purpose: Creates the package vehicle, sets its properties, and deletes the original object.

Sqf

Apply
[_package] call A3A_fnc_initObject;
Purpose: Initializes the package object with standard initialization.

Where it leads:
Called by: Functions that need to pack objects for transportation
Calls:
A3A_fnc_initObject - for package initialization
Depends on:
Configuration system for packable objects
Vehicle creation system
Object initialization system
Global variables modified:
A3A_packedObject - stores original object type in package
Network implications: Uses createVehicle and deleteVehicle which are network-aware
Requirements:
Valid object to be packed
Configuration for packable objects
Proper vehicle creation and deletion system
Object initialization system
Function: fn_refreshVehicleLoad.sqf
What it does:
The 
fn_refreshVehicleLoad.sqf
 function cleans up the cargo and node lists on vehicles that have become corrupted with null objects. It resets the lists when they are truly empty to prevent loading issues.

How it does that:
The function:

Retrieves the vehicle's cargo list
Checks if all remaining cargo items are null objects
If so, resets the cargo list and refreshes the node list
This prevents the "objNull bug" where corrupted lists cause loading problems
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params ["_vehicle"];
Purpose: Includes script component and sets up function parameter.

Sqf

Apply
private _cargo = _vehicle getVariable ["Cargo",[]];
if (_cargo findIf {!((_x#0) isEqualTo objNull)} isEqualTo -1) then { //if all remaining cargo on list is objNull, reset list
    private _nodes = [_vehicle] call A3A_Logistics_fnc_getVehicleNodes;
    _vehicle setVariable [QGVAR(Nodes),_nodes];
    _vehicle setVariable ["Cargo", []];
};
Purpose: Checks if cargo list contains only null objects and resets both cargo and node lists if so.

Where it leads:
Called by: Functions that need to clean up corrupted vehicle load data
Calls:
A3A_Logistics_fnc_getVehicleNodes - for refreshing node list
Depends on:
Vehicle cargo and node system
Node configuration system
Global variables modified:
Cargo - vehicle cargo list
Nodes - vehicle node list
Network implications: Direct variable modification on vehicle
Requirements:
Valid vehicle object
Proper cargo and node system
Vehicle variable access permissions
Function: fn_removeAction.sqf
What it does:
The 
fn_removeAction.sqf
 function removes load or unload actions from vehicles. It handles the cleanup of action IDs stored on vehicle objects.

How it does that:
The function:

Takes vehicle and action type as parameters
Removes the appropriate action (load or unload) from the vehicle
Clears the stored action ID from the vehicle's variables
Code Walkthrough:
Sqf

Apply
params ["_vehicle", "_action"];
Purpose: Sets up function parameters for vehicle and action type.

Sqf

Apply
switch (_action) do {
    case "load":{
        private _loadActionID = _vehicle getVariable ["loadActionID", nil];
        if(!isnil "_loadActionID")then{
            _vehicle removeAction _loadActionID;
            _vehicle setVariable ["loadActionID", nil];
        };
    };
    case "unload": {
        private _unloadActionID = _vehicle getVariable ["unloadActionID", nil];
        if(!isnil "_unloadActionID")then{
            _vehicle removeAction _unloadActionID;
            _vehicle setVariable ["unloadActionID", nil];
        };
    };
};
Purpose: Removes the appropriate action based on action type and clears the stored ID.

Where it leads:
Called by: Functions that need to remove actions from vehicles
Calls:
removeAction - for removing actions from vehicles
Depends on:
Vehicle action system
Action ID storage system
Global variables modified:
loadActionID - vehicle load action ID
unloadActionID - vehicle unload action ID
Network implications: Direct action removal on vehicle
Requirements:
Valid vehicle object
Action IDs stored on vehicle variables
Proper action removal system
Function: fn_removeWeaponAction.sqf
What it does:
The 
fn_removeWeaponAction.sqf
 function removes mounted weapon actions and related event handlers from vehicles. It cleans up all weapon-related functionality when a weapon is removed from a vehicle.

How it does that:
The function:

Removes the "get in" action for the weapon
Removes event handlers for weapon destruction and player exit
Removes the undercover breaking event handler if no weapons remain
Clears all stored action IDs and event handlers
Code Walkthrough:
Sqf

Apply
params [["_vehicle", objnull, [objNull]], ["_cargo", objnull, [objNull]], ["_jipKey", "", [""]]];
Purpose: Sets up function parameters with validation for vehicle, cargo, and JIP key.

Sqf

Apply
//Remove action
private _id = _cargo getVariable ["getInAction", -1];
_cargo setVariable ["getInAction", nil];
remoteExecCall ["", _jipKey]; //clear JIP addAction
_vehicle removeAction _id;
Purpose: Removes the get-in action and clears JIP key.

Sqf

Apply
//remove weapon killed EH
private _killedEH = _cargo getVariable ["KilledEH", -1];
_cargo removeEventHandler ["Killed", _killedEH];
_cargo setVariable ["KilledEH", nil];
Purpose: Removes the weapon destroyed event handler.

Sqf

Apply
//remove GetOut EH
private _GetOutEH = _cargo getVariable ["GetOutEH", -1];
_cargo removeEventHandler ["GetOut", _GetOutEH];
_cargo setVariable ["GetOutEH", nil];
Purpose: Removes the player exit event handler.

Sqf

Apply
//remove Undercover break if last weapon
private _attachedObjects = attachedObjects _vehicle;
private _weaponCount = _attachedObjects findIf {
    !isNull ( [_x] call A3A_Logistics_fnc_getCargoConfig )
};
if (_weaponCount isEqualTo -1) then {
    private _undercoverBreak = _vehicle getVariable ["undercoverBreak", -1];
    _vehicle removeEventHandler ["GetIn", _undercoverBreak];
    _vehicle setVariable ["undercoverBreak", nil];
};
Purpose: Removes undercover breaking event handler if no weapons remain on vehicle.

Where it leads:
Called by: Functions that need to remove mounted weapons from vehicles
Calls:
A3A_Logistics_fnc_getCargoConfig - for weapon configuration check
removeAction - for removing actions
removeEventHandler - for removing event handlers
Depends on:
Vehicle attachment system
Action and event handler system
Weapon configuration system
Global variables modified:
getInAction - weapon get-in action ID
KilledEH - weapon destroyed event handler ID
GetOutEH - player exit event handler ID
undercoverBreak - undercover breaking event handler ID
Network implications: Uses remoteExecCall for JIP cleanup and direct event handler removal
Requirements:
Valid vehicle and weapon objects
Proper action and event handler storage
Vehicle attachment system for weapon detection
Event handler management system

Function: fn_toggleAceActions.sqf
What it does:
The 
fn_toggleAceActions.sqf
 function toggles ACE actions (drag, carry, and load) on or off for cargo objects. It saves the original state of ACE actions before disabling them and can restore them when needed.

How it does that:
The function:

Checks if the object is valid
Retrieves stored ACE action state from the object
If no state is stored, saves the current ACE action states and disables them
If state is stored, restores the original ACE action states
Code Walkthrough:
Sqf

Apply
params ["_object"];
if (isNil "_object") exitWith {};
Purpose: Sets up function parameter and exits if object is nil.

Sqf

Apply
private _actions = _object getVariable ["LogisticsAceToggle", nil];
private _removeAction = false;
if (isNil "_actions") then {_removeAction = true};
Purpose: Gets stored ACE actions or sets flag to save current state.

Sqf

Apply
if (_removeAction) then {
    //check if actions are on the object
    private _canDrag = _object getVariable ["ace_dragging_canDrag",false];
    private _canCarry = _object getVariable ["ace_dragging_canCarry",false];
    private _canLoad = getNumber (configFile >> "CfgVehicles" >> typeOf _object >> "ace_cargo_canLoad") isEqualTo 1;

    //save old actions
    _object setVariable ["LogisticsAceToggle", [_canDrag, _canCarry, _canLoad], true];

    //disable ACE dragging
    _object setVariable ["ace_dragging_canDrag",false, true];
    _object setVariable ["ace_dragging_canCarry",false, true];
    _object setvariable ["ace_cargo_canLoad",false, true];
} else {
    _actions params ["_canDrag","_canCarry","_canLoad"];

    //set actions to the state it was before load
    _object setVariable ["ace_dragging_canDrag",_canDrag, true];
    _object setVariable ["ace_dragging_canCarry",_canCarry, true];
    _object setvariable ["ace_cargo_canLoad",_canLoad, true];

    _object setVariable ["LogisticsAceToggle", nil, true];
};
Purpose: Either saves current ACE states and disables them, or restores original states.

Where it leads:
Called by: Functions that need to temporarily disable ACE actions during loading
Calls:
getVariable - for retrieving ACE action states
setVariable - for setting ACE action states
Depends on:
ACE actions system
Object variable storage system
Global variables modified:
LogisticsAceToggle - stores original ACE action states
ace_dragging_canDrag - drag action state
ace_dragging_canCarry - carry action state
ace_cargo_canLoad - load action state
Network implications: Direct variable modification on object
Requirements:
Valid object parameter
ACE actions system for action state management
Object variable access permissions
Function: fn_toggleLock.sqf
What it does:
The 
fn_toggleLock.sqf
 function manages locking and unlocking of vehicle seats. It handles both specific seat locking/unlocking and full vehicle locking for cargo operations.

How it does that:
The function:

Locks cargo on the vehicle
For specific seat locking, updates the list of occupied seats and locks/unlocks specified seats
For full vehicle locking, moves out crew and locks all seats
Handles cleanup of tow ropes if needed
Code Walkthrough:
Sqf

Apply
params ["_vehicle", "_lock", "_seats"];
//toggle lock of the propper seats
_vehicle lockCargo false;
Purpose: Sets up function parameters and unlocks cargo initially.

Sqf

Apply
if !(isNil "_seats") then {//for vehicle loading cargo
    private _crew = crew _vehicle;
    private _crewCargoIndex = _crew apply {_vehicle getCargoIndex _x};

    private _seatsToLock = _vehicle getVariable ["Logistics_occupiedSeats", []];
    if (_lock) then {
        _seatsToLock append _seats
    } else {
        _seatsToLock = _seatsToLock - _seats;
    };
    _vehicle setVariable ["Logistics_occupiedSeats", _seatsToLock, true];
    {
        if (_x in _crewCargoIndex) then {
            moveOut (_crew # (_crewCargoIndex find _x)); //incase someone got into the seat before it is locked in the loading process
        };
        _vehicle lockCargo [_x, true];
    } forEach _seatsToLock;
} else {//for cargo, lock it fully and kick out any crew
    /* if (_vehicle isKindOf "StaticWeapon") exitWith {}; // dont lock statics, cant get out otherwise
    _vehicle lock _lock;
    if (_lock) then { */
        //move out crew
        {moveOut _x}forEach crew _vehicle;

        if (!isNil "SA_Put_Away_Tow_Ropes") then {
            //detach tow ropes attached to cargo
            {
                _veh = ropeAttachedTo _x;
                if (!isNull _veh) then {[_veh,player] call SA_Put_Away_Tow_Ropes};
            } forEach attachedObjects _vehicle;
            //detach tow ropes from cargo
            [_vehicle,player] call SA_Put_Away_Tow_Ropes;
        };
    /* }; */
};
Purpose: Handles specific seat locking/unlocking or full vehicle locking with crew movement.

Where it leads:
Called by: Functions that need to lock/unlock vehicle seats during loading/unloading
Calls:
crew - for getting vehicle crew
moveOut - for removing crew from vehicle
lockCargo - for locking vehicle cargo
getVariable - for retrieving seat information
setVariable - for setting seat information
Depends on:
Vehicle crew management system
Cargo locking system
Tow rope system (if present)
Global variables modified:
Logistics_occupiedSeats - stores list of occupied seats
Network implications: Uses lockCargo and moveOut which are network-aware
Requirements:
Valid vehicle object
Proper crew management system
Cargo locking system
Tow rope system (optional)
Function: fn_tryLoad.sqf
What it does:
The 
fn_tryLoad.sqf
 function attempts to load cargo into the nearest vehicle. It finds nearby vehicles, validates the load operation, and provides appropriate feedback to the player.

How it does that:
The function:

Validates that it's running on the server
Finds nearby vehicles to load into
Validates the load operation using A3A_Logistics_fnc_canLoad
Provides feedback to the player based on error codes
If successful, spawns the load operation
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith {};
params ["_cargo"];
Purpose: Includes script component, validates server execution, and sets up parameter.

Sqf

Apply
private _vehicles = (nearestObjects [_cargo,["Car","Ship","Tank","Helicopter"], 10]) - [_cargo];
private _vehicle = _vehicles#0;
if (isNil "_vehicle") exitWith {
    [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_tryLoad_novehclose"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner]
};
Purpose: Finds nearby vehicles and exits with error if none found.

Sqf

Apply
private _return = [_vehicle, _cargo] call A3A_Logistics_fnc_canLoad;
if (_return isEqualType 0) exitWith {
    //error handling with feedback
    private _cargoName = getText (configFile >> "CfgVehicles" >> typeOf _cargo >> "displayName");
    private _vehicleName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
    if (_cargo isKindOf "CAManBase") then {_cargoName = name _cargo};

    switch _return do {
        case -1: { [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_tryLoad_nodestroyedveh"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -2: { [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_tryLoad_nodestroyedcargo"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -3: { [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_tryLoad_itemcantbeloaded", _cargoName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -4: { [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_tryLoad_nomountedstatic"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -5: { [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_tryLoad_incompat", _cargoName, _vehicleName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -6: { [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_tryLoad_alreadyhelped",_cargoName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -7: { [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_unableToLoad", _vehicleName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -8: { [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_tryLoad_not_enough_space", _vehicleName, _cargoName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        case -9: { [localize "STR_A3A_Logistics_header", format [localize "STR_A3A_Logistics_tryLoad_blocking_plane_cargo", _vehicleName]] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner] };
        default { Error_1("Unknown error code: %1", _return) };
    };
};
Purpose: Validates the load operation and provides detailed feedback for different error cases.

Sqf

Apply
_return spawn A3A_Logistics_fnc_load;
nil
Purpose: Spawns the load operation if successful and returns nil.

Where it leads:
Called by: Player actions or other systems that initiate loading
Calls:
A3A_Logistics_fnc_canLoad - for validation
A3A_Logistics_fnc_load - for actual loading
A3A_fnc_customHint - for player feedback
Depends on:
Vehicle and cargo detection system
Load validation system
Player feedback system
Global variables modified: None directly
Network implications: Uses remoteExec for feedback and spawn for loading
Requirements:
Valid cargo object
Server execution environment
Nearby vehicle detection system
Load validation system
Player feedback system
Function: fn_unload.sqf
What it does:
The 
fn_unload.sqf
 function unloads cargo from vehicles. It handles the physical detachment of cargo, updates vehicle state information, and manages cleanup operations.

How it does that:
The function:

Validates the unload operation and checks if vehicle is already loading
Sets up JIP keys for synchronization
Updates the vehicle's node list to mark nodes as free
Calculates proper positioning and attachment points for unloading
Handles the physical detachment of cargo from the vehicle
Updates vehicle cargo lists and performs cleanup
Manages seat unlocking and ACE action restoration
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_vehicle", ["_instant", false, [true]]];
private _fileName = "fn_logistics_unload";
Purpose: Includes script component, sets up parameters, and defines filename for error tracking.

Sqf

Apply
private _loaded = _vehicle getVariable ["Cargo", []];
private _lastLoaded = false;
if ((count _loaded) isEqualTo 1) then {_lastLoaded = true};
(_loaded#0) params ["_cargo", "_node"];
Purpose: Retrieves loaded cargo information and checks if this is the last item.

Sqf

Apply
if !(
    ((gunner _cargo) isEqualTo _cargo)
    or ((gunner _cargo) isEqualTo objNull)
) exitWith {
    [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_unload_nostatic"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner]
};
Purpose: Validates that cargo is not a static weapon with a gunner.

Sqf

Apply
if (_vehicle getVariable ["LoadingCargo", false]) exitWith {
    [localize "STR_A3A_Logistics_header", localize "STR_A3A_Logistics_unload_already"] remoteExec ["A3A_fnc_customHint", remoteExecutedOwner]
};
_vehicle setVariable ["LoadingCargo",true,true];
Purpose: Checks if vehicle is already loading and exits with error if so.

Sqf

Apply
//object string for jip
private _objStringCargo = str _cargo splitString ":" joinString "";
private _objStringVehicle = str _vehicle splitString ":" joinString "";
Purpose: Creates unique JIP keys for synchronization.

Sqf

Apply
//update list of nodes on vehicle
_updateList = {
    params ["_vehicle", "_node"];
    private _list = _vehicle getVariable [QGVAR(Nodes),[]];
    private _index = _list find _node;
    if (_index < 0) exitWith { Error_3("Bad _updateList call | Vehicle: %1 | Vehicle Nodes: %2 | Node: %3", _vehicle, _list, _node) };
    _node set [0,1];
    _list set [_index, _node];
    _vehicle setVariable [QGVAR(Nodes), _list];
};
Purpose: Defines local function to update vehicle node list, marking nodes as free.

Sqf

Apply
//find node point and seats
private _nodeOffset = [0,0,0];
private _seats = [];

if ((_node#0) isEqualType []) then {
    //type 2 cargo
    //offset
    private _lastNode = (count _node) -1;
    private _offsetOne = (_node#0#1);
    private _offsetTwo = (_node#_lastNode#1);
    private _diff = _offsetOne vectorDiff _offsetTwo;
    _nodeOffset = _offsetTwo vectorAdd [0,(_diff#1)/2,0];

    //seats
    {
        _seats append (_x#2);
    } forEach _node;

    //update cargo list
    for "_i" from 0 to _lastNode do {
        [_vehicle, _node#_i] call _updateList;
    };
} else {
    //type 1 cargo
    //offset
    _nodeOffset = (_node#1);
    //seats
    _seats append (_node#2);
    //update list
    [_vehicle , _node] call _updateList;
};
Purpose: Processes node data to calculate offset and seat information, updating node list.

Sqf

Apply
private _isLootcrate = (typeOf _cargo) isEqualTo (A3A_faction_reb get "lootCrate");
if (_isLootcrate) then {
    _cargo allowDamage false;
};
_vehicle animateDoor ["Door_rear", 1];
//detach cargo
private _keepUnloading = false;
if !(_cargo isEqualTo objNull) then {//cargo not deleted
    //check if its a weapon
    private _cargoConfig = [_cargo] call A3A_Logistics_fnc_getCargoConfig;
    private _weapon = 1 == getnumber (_cargoConfig/"isWeapon");

    if (_weapon) then {
        [_vehicle, _cargo, "A3A_Logistics_weaponAction_" + _objStringCargo] remoteExecCall ["A3A_Logistics_fnc_removeWeaponAction",0];
        player setCaptive false; //break undercover for unloading weapon
    };
    _cargo setVariable ["AttachmentOffset", nil, true];

    private _location = ([_cargo] call A3A_Logistics_fnc_getCargoOffsetAndDir)#0;
    private _location = _location vectorAdd _nodeOffset;
    private _bbv = boundingBoxReal _vehicle select 0 select 1;
    private _bbc = boundingBoxReal _cargo select 0 select 1;
    private _yEnd = _bbv + _bbc - 0.1;

    if (_instant) then {
        _location set [1, _yEnd-0.1];
        _cargo attachto [_vehicle,_location];
    } else {
        private _prevTime = time;
        while {(_location#1) > _yEnd} do {
            uiSleep 0.01;
            if (isNull _cargo || isNull _vehicle) exitWith {};//vehicle or cargo deleted
            _location = _location vectorAdd [0,_prevTime-time,0];
            _cargo attachto [_vehicle,_location];
            _prevTime = time;
        };
    };
    if (isNull _cargo || isNull _vehicle) exitWith {};//vehicle or cargo deleted
    detach _cargo;

    [_cargo] call A3A_Logistics_fnc_toggleAceActions;
    [_vehicle, _cargo, true, _instant] call A3A_Logistics_fnc_addOrRemoveObjectMass;
    _cargo lockDriver false;
} else {_keepUnloading = true};
Purpose: Handles the physical detachment and animation of cargo from vehicle.

Sqf

Apply
//unlock seats
[_cargo, false] remoteExec ["A3A_Logistics_fnc_toggleLock", 0, "A3A_Logistics_toggleLock" + _objStringCargo];
[_vehicle, false, _seats] remoteExec ["A3A_Logistics_fnc_toggleLock", 0, "A3A_Logistics_toggleLock" + _objStringVehicle];

if (_isLootcrate) then {
    _nil = [_cargo] spawn {
        params["_cargo"];
        if (!isNil "_cargo" && {alive _cargo}) then {
            private _timeOut = time + 10;
            waitUntil {_timeOut < time};
            _cargo allowDamage true;
        };
        terminate _thisScript;
    };
};

//update list
_loaded deleteAt 0;
_vehicle setVariable ["Cargo", _loaded, true];
[_vehicle] call A3A_Logistics_fnc_refreshVehicleLoad; //refresh list in case theres more on the list but no actuall cargo loaded

_vehicle setVariable ["LoadingCargo",nil,true];
_vehicle animateDoor ["Door_rear", 0];
if (_keepUnloading and !_lastLoaded) then {[_vehicle] spawn A3A_Logistics_fnc_unload};//if you tried to unload a null obj unload next on list
nil
Purpose: Updates vehicle state, performs cleanup, and handles cascading unloading.

Where it leads:
Called by: Functions that initiate cargo unloading operations
Calls:
A3A_Logistics_fnc_getCargoConfig - for weapon detection
A3A_Logistics_fnc_removeWeaponAction - for weapon cleanup
A3A_Logistics_fnc_getCargoOffsetAndDir - for positioning data
A3A_Logistics_fnc_toggleLock - for seat unlocking
A3A_Logistics_fnc_toggleAceActions - for ACE action restoration
A3A_Logistics_fnc_addOrRemoveObjectMass - for mass updates
A3A_Logistics_fnc_refreshVehicleLoad - for list cleanup
A3A_Logistics_fnc_unload - for cascading unloading
Depends on:
Node system for vehicle loading
Cargo configuration system
ACE actions system
Vehicle attachment system
Global variables modified:
LoadingCargo - vehicle loading state
Cargo - vehicle cargo list
Nodes - vehicle node list
AttachmentOffset - cargo attachment position
Network implications: Uses remoteExec and remoteExecCall for synchronization
Requirements:
Valid vehicle and cargo objects
Proper node configuration
Cargo configuration with offset and rotation data
ACE actions system for optional toggling
Vehicle attachment system for positioning
Function: fn_unpackObject.sqf
What it does:
The 
fn_unpackObject.sqf
 function handles unpacking objects that were previously packed for transportation. It converts the package back to the original object type and places it properly in the world.

How it does that:
The function:

Validates that the object is not attached to anything
Retrieves the original object type from the package
Uses a placement system to convert the package back to the original object
Initializes the unpacked object with standard initialization
Code Walkthrough:
Sqf

Apply
#include "..\script_component.hpp"
params  [
    ["_object", objNull, [objNull]]
];
Purpose: Includes script component and sets up function parameter with validation.

Sqf

Apply
// don't unpack if attached.
if !(isNull attachedTo _object) exitWith {};
Purpose: Exits if the object is already attached to something.

Sqf

Apply
//get data 
private _itemClassName = _object getVariable "A3A_packedObject";
if (isNil "_itemClassName") exitwith { Error_1("No packed object for item type %1", typeof _object) };
Purpose: Gets the original object class name from package or exits with error.

Sqf

Apply
private _fnc_placed = {
    params ["_item", "_oldItem"];
    if (isNull _item) exitWith { _oldItem hideObject false };          // placement cancelled
 
    deleteVehicle _oldItem;
    _item call A3A_fnc_initObject;
};
Purpose: Defines a local function for handling the placement process.

Sqf

Apply
_object hideObject true;
[_itemClassName, _fnc_placed, {[false]}, [_object]] call HR_GRG_fnc_confirmPlacement;
Purpose: Hides the package and calls the placement system to convert it back to the original object.

Where it leads:
Called by: Functions that need to unpack objects from packages
Calls:
HR_GRG_fnc_confirmPlacement - for the actual placement system
deleteVehicle - for removing the package
A3A_fnc_initObject - for initializing the unpacked object
Depends on:
Package object system
Placement system (HR_GRG_fnc_confirmPlacement)
Object initialization system
Global variables modified:
A3A_packedObject - stores original object type in package
Network implications: Uses deleteVehicle and hideObject which are network-aware
Requirements:
Valid package object to be unpacked
Placement system for conversion
Object initialization system
Proper package object structure with A3A_packedObject variable
Function Name: fn_attachedObjects.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_attachedObjects.sqf

What it does: This function returns a filtered list of attached objects from a given object, removing null objects and "source" objects (objects with type names starting with "#", such as particle sources). It's a utility function used to get a clean list of actual, valid attached objects that can be interacted with, ignoring engine-generated virtual objects.

Context & Usage: This is called when checking if a player is already carrying something, when determining what objects should be displayed in inventory screens, or when processing attached objects for game mechanics. It prevents game logic from attempting to interact with temporary or invisible engine objects.

How it does that:

Step 1: Parameter Validation and Initialization

Sqf

Apply
params [["_object", objNull, [objNull]]];
Uses SQF's params command with default value objNull
Validates the first parameter is an Object type (exactly one array element [[objNull]])
If no parameter is provided or it's not an Object, defaults to objNull
The variable _object now holds the target object to check attachments on
Step 2: Get All Attached Objects

Sqf

Apply
attachedObjects _object select { ... }
Calls SQF's built-in attachedObjects command on _object
Returns an array of all objects currently attached to _object
Applies a selection filter using the select command with a code block
Step 3: Filter Logic - Null Check

Sqf

Apply
!isNull _x
For each element _x in the attached objects array:
Checks if the object is not null using isNull
This filters out any objects that were destroyed or removed but still appear in the array
Step 4: Filter Logic - Source Object Check

Sqf

Apply
&& {"#" in typeOf _x}
Uses logical AND (&&) to chain conditions
Checks if "#" appears anywhere in the string result of typeOf _x
typeOf returns the class name of an object
Objects like particle sources (#particleSource) and other engine-generated objects use names starting with #
This filters out these non-interactive "source" objects
Step 5: Return Filtered Array

Sqf

Apply
// Returns the filtered array
The select command returns a new array containing only elements that passed the filter
Returns an array of valid, attached objects
Complete Function:

Sqf

Apply
params [["_object", objNull, [objNull]]];
attachedObjects _object select {
    !isNull _x
    && {"#" in typeOf _x} //example "#particleSource"
};
Error Handling & Edge Cases:

If _object is objNull, attachedObjects returns an empty array
If _object doesn't exist or isn't local, may return empty or unexpected results
If any attached object has typeOf returning an empty string, it will pass the filter (shouldn't happen in practice)
Where it leads:

Calls: attachedObjects (SQF engine function), isNull (SQF engine function), typeOf (SQF engine function)
Dependents:
fn_carryItem.sqf
 - Uses to check if player is already carrying something
fn_initMovableObject.sqf
 - Uses in action conditions
fn_initObjectRemote.sqf
 - Uses in action conditions
System Fit: Part of the utility items system, providing object filtering for all carrying/attachment mechanics
Global Variables: None modified
Network Implications: Purely local function, no network calls. When used in remote commands, the remote context needs valid local object references.
Function Name: fn_buyItem.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_buyItem.sqf

What it does: Attempts to purchase a buyable utility item, handles payment logic (commander vs regular player), provides user feedback, manages cooldowns, and places the item either manually or automatically based on item flags. It validates all inputs and ensures sufficient funds before initiating placement.

Context & Usage: Called when a player wants to purchase an item from the shop. It coordinates with the resource management system (commander resources vs player money), enforces purchase cooldowns, and triggers the placement UI or automatic placement. It's the main entry point for the item economy.

How it does that:

Step 1: Function Definition and Helper Functions

Sqf

Apply
private _fnc_placed = {
    params ["_item", "_unit", "_price", "_flags"];
    if (isNull _item) exitWith {};          // placement cancelled
    
    if ((_unit == theBoss && server getVariable ["resourcesFIA", 0] < _price) || (_unit != theBoss && _unit getVariable ["moneyX", 0] < _price)) exitWith {
        [localize "STR_A3A_Utility_Items_Purchase_Title", localize "STR_A3A_Utility_Items_Insufficient_Funds"] call A3A_fnc_customHint;
        deleteVehicle _item;
    };
    
    if (_price > 0) then {
        if (_unit == theBoss) exitWith { [0, -_price] remoteExec ["A3A_fnc_resourcesFIA", 2] };
        [-_price] call A3A_fnc_resourcesPlayer;     // uh, we're just assuming _unit == player here
    };
    
    _unit setVariable ["A3A_spawnItem_cooldown", time + 15];
    
    _item call A3A_fnc_initObject;
};
Defines a private helper function _fnc_placed for handling post-placement logic
Takes parameters: item object, purchasing unit, price, and item flags
First checks if placement was cancelled (item is null)
Then checks funds again (race condition protection):
If commander, checks server's FIA resources variable
If regular player, checks the player's personal money variable
If insufficient funds, shows hint and deletes the already-placed item
If funds exist and price > 0:
For commander: remotely executes A3A_fnc_resourcesFIA on server (ID 2) with negative price
For player: calls A3A_fnc_resourcesPlayer locally with negative price
Sets a 15-second cooldown on the purchasing unit
Initializes the placed object using A3A_fnc_initObject
Step 2: Parameter Validation

Sqf

Apply
params ["_unit", "_itemClass"];
Expects two parameters: unit object and item class name string
Step 3: Null Check

Sqf

Apply
if (isNull _unit) exitwith { Error("Unit is null") };
Checks if unit is null
If true, logs error and exits function
Step 4: Class Existence Check

Sqf

Apply
if (!isClass (configFile/"CfgVehicles"/_itemClass)) exitwith { Error_1("Class %1 does not exist", _itemClass) };
Checks if the item class exists in vehicle configuration
Uses SQF's configFile global and config path system
Logs error with class name if it doesn't exist
Step 5: Buyable Item Validation

Sqf

Apply
if !(_itemClass in A3A_utilityItemsHM) exitWith { Error_1("Class %1 is not a buyable item", _itemClass) };
Checks if class exists in the utility items hashmap A3A_utilityItemsHM
This hashmap contains all buyable items and their properties
Exits with error if not found
Step 6: Extract Item Properties

Sqf

Apply
(A3A_utilityItemHM get _itemClass) params ["", "_price", "", "", "_flags"];
Retrieves item data from A3A_utilityItemHM hashmap
Uses parameter destructuring params to extract:
Position 0: (unused)
Position 1: _price (cost)
Position 2: (unused)
Position 3: (unused)
Position 4: _flags (array of item flags)
Assumes hashmap structure has exactly 5 elements per item
Step 7: Cooldown Check

Sqf

Apply
private _lastItemPurchase = _unit getVariable ["A3A_spawnItem_cooldown", 0];
if (_lastItemPurchase > time) exitwith {
    [localize "STR_A3A_Utility_Items_Purchase_Title", format [localize "STR_A3A_Utility_Items_Last_Time_Purchase", ceil (_lastItemPurchase - time)]] call A3A_fnc_customHint;
};
Gets cooldown variable from unit (default 0)
Compares with current mission time
If cooldown still active, shows hint with remaining time
Uses ceil to round up seconds for display
Step 8: Commander-Only Flag Check

Sqf

Apply
if (("cmmdr" in _flags) && player isNotEqualTo theBoss) exitwith {
    [localize "STR_antistasi_dialogs_buy_item_custom_hint_header", localize "STR_antistasi_dialogs_buy_item_custom_hint_commander_only"] call A3A_fnc_customHint;
};
Checks if "cmmdr" flag exists in item flags
AND checks if the local player isn't the commander (theBoss)
If both true, shows commander-only hint and exits
Step 9: Initial Fund Check

Sqf

Apply
if ((_unit == theBoss && server getVariable ["resourcesFIA", 0] < _price) || (_unit != theBoss && _unit getVariable ["moneyX", 0] < _price)) exitWith {
    [localize "STR_A3A_Utility_Items_Purchase_Title", localize "STR_A3A_Utility_Items_Insufficient_Funds"] call A3A_fnc_customHint;
};
Performs first fund check before any object creation:
For commander: checks server's FIA resources
For player: checks player's money variable
Shows insufficient funds hint if check fails
Step 10: Simple Placement (No Manual Placement Flag)

Sqf

Apply
if !("place" in _flags) exitWith
{
    private _position = (getPosATL _unit vectorAdd [3,0,0]) findEmptyPosition [1,50,_itemClass];
    if (_position isEqualTo []) then {_position = getPosATL _unit};
    private _item = _itemClass createVehicle _position;
    _item allowDamage false;            // what, permanent? TODO: make this an item flag?
    
    [_item, _unit, _price, _flags] call _fnc_placed;
};
Checks if "place" flag is NOT in flags array
If true, performs automatic placement:
Calculates position: unit's ATL position + 3 meters forward
Finds empty position within 50m radius for vehicle class
If no empty position found, defaults to unit's exact position
Creates vehicle of item class at position
Prevents damage on the item (permanent currently)
Calls helper function with all parameters
Exits after successful automatic placement
Step 11: Manual Placement (With "place" Flag)

Sqf

Apply
[_itemClass, _fnc_placed, {false}, [_unit, _price, _flags]] call HR_GRG_fnc_confirmPlacement;
Calls HR_GRG_fnc_confirmPlacement from HR Garage system
Parameters:
Item class name
Callback function (the helper defined earlier)
Code that returns false (no preview? Not sure)
Arguments array passed to callback
This triggers the placement UI where player positions the item
Complete Function Flow:

Sqf

Apply
// Function definition
params ["_unit", "_itemClass"];
if (isNull _unit) exitwith { Error("Unit is null") };
if (!isClass (configFile/"CfgVehicles"/_itemClass)) exitwith { Error_1("Class %1 does not exist", _itemClass) };
if !(_itemClass in A3A_utilityItemsHM) exitWith { Error_1("Class %1 is not a buyable item", _itemClass) };

// Helper function
private _fnc_placed = { ... };

// Extract item data
(A3A_utilityItemHM get _itemClass) params ["", "_price", "", "", "_flags"];

// Cooldown check
private _lastItemPurchase = _unit getVariable ["A3A_spawnItem_cooldown", 0];
if (_lastItemPurchase > time) exitwith { ... };

// Commander check
if (("cmmdr" in _flags) && player isNotEqualTo theBoss) exitwith { ... };

// Fund check
if ((_unit == theBoss && server getVariable ["resourcesFIA", 0] < _price) || (_unit != theBoss && _unit getVariable ["moneyX", 0] < _price)) exitWith { ... };

// Placement logic
if !("place" in _flags) exitWith { ... };
// Else manual placement
[_itemClass, _fnc_placed, {false}, [_unit, _price, _flags]] call HR_GRG_fnc_confirmPlacement;
Error Handling & Edge Cases:

All validation happens before any side effects
Object creation only after passing all checks
Placement cancellation handled in callback (deletes item)
Race condition protected by second fund check in callback
Assumes unit is player when subtracting money (comment indicates TODO)
Where it leads:

Calls:
A3A_fnc_customHint - Shows UI feedback
A3A_fnc_resourcesFIA - Deducts commander funds (remote)
A3A_fnc_resourcesPlayer - Deducts player money
A3A_fnc_initObject - Initializes placed item
HR_GRG_fnc_confirmPlacement - Triggers placement UI
Error/Error_1 - Logging functions
Dependents:
Called by shop UI actions or keybinds
Potential direct calls from admin tools or debug functions
System Fit: Core of the economy system, bridging user action with resource management and object initialization
Global Variables Modified:
theBoss - Checked for equality
A3A_spawnItem_cooldown - Set on unit (15 second cooldown)
Server variables: resourcesFIA (modified remotely)
Network Implications:
remoteExec to server for commander funds (ID 2 = all clients)
Placement callback may be networked depending on placement system
Object creation and initialization is local to caller
Function Name: fn_carryItem.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_carryItem.sqf

What it does: Handles picking up and dropping objects. When picking up, it attaches the object to the player, disables its simulation to prevent physics issues, adds an event handler to handle vehicle entry, and sets up monitoring. When dropping, it detaches the object, positions it safely on the ground, restores its mass and simulation, and cleans up event handlers.

Context & Usage: Called when a player interacts with a movable object (via action) or when they want to drop an item they're carrying. It's the core mechanic for moving objects around the map manually. The function handles both pickup and drop operations based on the boolean parameter.

How it does that:

Step 1: Parameter Parsing

Sqf

Apply
params [["_item", objNull, [objNull]], "_pickUp", ["_player", player]];
Parses three parameters:
_item: Object to carry (defaults to objNull, must be Object type)
_pickUp: Boolean (no default) - determines if pickup or drop
_player: Object (defaults to player) - who is carrying/holding
If picking up with null item, will search for attached object
Step 2: Pickup Logic

Sqf

Apply
if (_pickUp) then { ... }
Enters pickup branch when _pickUp is true
Step 3: Pickup - Check Already Carrying

Sqf

Apply
if (([_player] call A3A_fnc_countAttachedObjects) > 0) exitWith {[localize "STR_A3A_Utility_Title", localize "STR_A3A_Utility_Items_Feedback_Normal"] call A3A_fnc_customHint};
Calls A3A_fnc_countAttachedObjects to check if player already has attached objects
If count > 0, shows "already carrying" hint and exits pickup
This prevents carrying multiple objects simultaneously
Step 4: Pickup - Setup Event Handler for Vehicle Entry

Sqf

Apply
private _eventIDcarry = _player addEventHandler ["GetInMan", {
    params ["_unit", "_role", "_vehicle", "_turret"];
    private _objectCarrying = _unit getVariable ['A3A_objectCarrying', nil];
    if (isNil "_objectCarrying") exitwith {_unit removeEventHandler ["GetInMan", _thisEventHandler]};
    
    detach _objectCarrying;
    _unit setVelocity [0,0,0];
    _objectCarrying setVelocity [0,0,0];
    _objectCarrying setVehiclePosition [position _unit, [], 10,"NONE"];
    
    [_objectCarrying, true] remoteExec ["enableSimulationGlobal", 0];
    
    _unit setVariable ["A3A_carryingObject", nil];
    _unit setVariable ['A3A_objectCarrying', nil];
    _unit allowSprint true;
}];
Adds "GetInMan" event handler to the player
Handler parameters: unit, role (driver/gunner/cargo), vehicle, turret position
Retrieves the object being carried from unit variable
If variable is nil (object already handled), removes event handler and exits
Detaches the object from player
Stops all unit/vehicle velocities (prevents physics weirdness)
Moves object 10m away from unit (safe distance)
Enables simulation globally on the object (old method, may not work well)
Clears carrying variables on unit
Restores sprint ability
Step 5: Pickup - Prepare Object Physics

Sqf

Apply
if (isNil {_item getVariable "A3A_originalMass"}) then { _item setVariable ["A3A_originalMass", getMass _item] };
[_item, 1e-12] remoteExecCall ["setMass", 0]; 
Sets original mass as object variable if not already set (stores for later restoration)
Sets object mass to 1e-12 (effectively zero) globally to prevent physics interactions
Uses remoteExecCall with 0 for all clients to ensure mass is set everywhere
Step 6: Pickup - Store Carrying State

Sqf

Apply
_player setVariable ['A3A_eventIDcarry', _eventIDcarry];
_player setVariable ['A3A_objectCarrying', _item];
Stores event handler ID on player for later removal
Stores reference to carried item on player
Step 7: Pickup - Disable Object Simulation

Sqf

Apply
[_item, false] remoteExec ["enableSimulationGlobal", 2];
Disables simulation on object globally using ID 2 (server only)
This prevents object from falling or interacting with physics
Uses remoteExec for server-side execution
Step 8: Pickup - Calculate Attachment Position

Sqf

Apply
private _bbReal = boundingBoxReal _item;
private _diff = (_bbReal select 1) vectorDiff (_bbReal select 0);
private _positionAttached = [0, (_diff vectorDotProduct [0,.65,0]) + 1.0, (_diff vectorDotProduct [0,0,0.5]) + 0.5];
Gets real bounding box of object (min and max corners)
Calculates difference vector (size)
Uses dot product with specific vectors to position the object:
Y (forward) offset: 0.65 * size_y + 1.0
Z (up) offset: 0.5 * size_z + 0.5
X (left/right) offset: 0
This positions object in front of player's chest
Step 9: Pickup - Attach Object to Player

Sqf

Apply
_item attachTo [_player, _positionAttached, "Chest"];
_player setVariable ["A3A_carryingObject", true];
Attaches item to player at calculated offset, with "Chest" memory point
Sets carrying flag variable to true
Step 10: Pickup - Start Monitoring Coroutine

Sqf

Apply
[_player ,_item] spawn {
    params ["_player", "_item"];
    waitUntil {_player allowSprint false; !alive _item or !(_player getVariable ["A3A_carryingObject", false]) or !(vehicle _player isEqualTo _player) or _player getVariable ["incapacitated",false] or !alive _player or !(isPlayer attachedTo _item) };
    [_item, false, _player] call A3A_fnc_carryItem;
};
Spawns a monitoring script
Immediately disables player sprint capability
waitUntil loop checks for termination conditions:
Item destroyed
Player no longer carrying (variable false)
Player enters any vehicle
Player incapacitated
Player dies
Player no longer attached to item (shouldn't happen)
When any condition met, calls this function again with drop parameters
Step 11: Drop Logic - Item Null Handling

Sqf

Apply
} else { // DROP LOGIC
    if (isNull _item) then {
        private _attached = [_player] call A3A_fnc_attachedObjects;
        if (_attached isEqualTo []) exitWith {};
        _item = _attached # 0;
    };
If dropping but no item specified:
Get all attached objects from player
If none, exit drop
Take first attached object as item to drop
Step 12: Drop - Detachment and Velocity Control

Sqf

Apply
    if !(isNull _item) then {
        _player setVelocity [0,0,0];
        detach _item;
        
        [_item, [0,0,0]] remoteExec ["setVelocity", _item];
        [_item, surfaceNormal position _item] remoteExec ["setVectorUp", _item];
Stops player velocity
Detaches item
Sets item velocity to zero on its own locality (remoteExec)
Sets item's "up" vector to surface normal (keeps it level on ground)
Both remoteExec calls target the object's owner (which may change after detach)
Step 13: Drop - Position on Ground

Sqf

Apply
        private _pos = getPosASL _item;
        private _intersects = lineIntersectsSurfaces [_pos, _pos vectorAdd [0,0,-100], _item];
        if (count _intersects > 0) then {
            _item setPosASL (_intersects select 0 select 0);
        };
Gets item's current ASL position
Casts line down 100m to find ground
Uses lineIntersectsSurfaces to get surface intersections
If surface found, sets item to that intersection position
This ensures object sits exactly on ground, not floating
Step 14: Drop - Restore Simulation and Clean Up

Sqf

Apply
        [_item, true] remoteExec ["enableSimulationGlobal", 2];
        _eventIDcarry = _player getVariable 'A3A_eventIDcarry';
        _player removeEventHandler ["GetInMan", _eventIDcarry];
Re-enables simulation globally on object
Retrieves event handler ID from player
Removes the GetInMan event handler
Step 15: Drop - Restore Mass

Sqf

Apply
        _item spawn {
            sleep 1;
            if (isNull _this) exitWith {};
            [_this, _this getVariable "A3A_originalMass"] remoteExecCall ["setMass", _this];
        };
Spawns delayed restoration of mass
Waits 1 second to ensure detachment completes
Checks object still exists
Restores original mass using remoteExecCall to object owner
Step 16: Drop - Clean Up Player Variables

Sqf

Apply
    };
    _player setVariable ["A3A_carryingObject", nil];
    _player allowSprint true;
};
Clears carrying variable
Restores sprint ability
Complete Function Flow:

Sqf

Apply
// Parameter parsing
params [["_item", objNull, [objNull]], "_pickUp", ["_player", player]];

if (_pickUp) then {
    // Pickup flow
    if (([_player] call A3A_fnc_countAttachedObjects) > 0) exitWith { ... };
    
    private _eventIDcarry = _player addEventHandler ["GetInMan", { ... }];
    
    if (isNil {_item getVariable "A3A_originalMass"}) then { ... };
    [_item, 1e-12] remoteExecCall ["setMass", 0];
    
    _player setVariable ['A3A_eventIDcarry', _eventIDcarry];
    _player setVariable ['A3A_objectCarrying', _item];
    
    [_item, false] remoteExec ["enableSimulationGlobal", 2];
    private _bbReal = boundingBoxReal _item;
    private _diff = (_bbReal select 1) vectorDiff (_bbReal select 0);
    private _positionAttached = [0, (_diff vectorDotProduct [0,.65,0]) + 1.0, (_diff vectorDotProduct [0,0,0.5]) + 0.5];
    _item attachTo [_player, _positionAttached, "Chest"];
    _player setVariable ["A3A_carryingObject", true];
    [_player ,_item] spawn { ... };
} else {
    // Drop flow
    if (isNull _item) then {
        private _attached = [_player] call A3A_fnc_attachedObjects;
        if (_attached isEqualTo []) exitWith {};
        _item = _attached # 0;
    };
    
    if !(isNull _item) then {
        _player setVelocity [0,0,0];
        detach _item;
        [_item, [0,0,0]] remoteExec ["setVelocity", _item];
        [_item, surfaceNormal position _item] remoteExec ["setVectorUp", _item];
        
        private _pos = getPosASL _item;
        private _intersects = lineIntersectsSurfaces [_pos, _pos vectorAdd [0,0,-100], _item];
        if (count _intersects > 0) then {
            _item setPosASL (_intersects select 0 select 0);
        };
        
        [_item, true] remoteExec ["enableSimulationGlobal", 2];
        _eventIDcarry = _player getVariable 'A3A_eventIDcarry';
        _player removeEventHandler ["GetInMan", _eventIDcarry];
        
        _item spawn {
            sleep 1;
            if (isNull _this) exitWith {};
            [_this, _this getVariable "A3A_originalMass"] remoteExecCall ["setMass", _this];
        };
    };
    
    _player setVariable ["A3A_carryingObject", nil];
    _player allowSprint true;
};
Error Handling & Edge Cases:

Handles null item by searching for attached objects
Mass restoration after delay protects against race conditions
Event handler cleanup when no longer needed
Velocity zeroing prevents physics bugs
Surface normal adjustment prevents item from tipping
Where it leads:

Calls:
A3A_fnc_countAttachedObjects - Check current attachments
A3A_fnc_customHint - User feedback
A3A_fnc_attachedObjects - Find item to drop
lineIntersectsSurfaces - Ground detection
SQF commands: addEventHandler, detach, attachTo, remoteExec, spawn, setVelocity, etc.
Dependents:
fn_initMovableObject.sqf
 - Adds carry action
fn_initObjectRemote.sqf
 - Adds carry action
fn_dropObject.sqf
 - Provides drop action
Potential other interaction systems
System Fit: Core physical interaction system for utility items, enabling manual object manipulation
Global Variables Modified:
_player variables: A3A_eventIDcarry, A3A_objectCarrying, A3A_carryingObject
_item variables: A3A_originalMass
Player's sprint ability (modified directly)
Network Implications:
Multiple remoteExec calls for mass, velocity, vectorUp, and simulation
Event handlers are local to player
Object state changes are replicated via engine (position, attachment)
Mass restoration is delayed and remote to object owner
Function Name: fn_dropObject.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_dropObject.sqf

What it does: Adds an action to the player to drop their currently carried object. The action is conditionally shown only when the player is carrying an object. This is a simple wrapper function that delegates to the main fn_carryItem function with drop parameters.

Context & Usage: Called on player initialization or when carrying logic starts. It provides a quick way for players to drop objects without finding the specific object or using a context menu. The action appears on the player's action menu.

How it does that:

Step 1: Add Drop Action to Player

Sqf

Apply
player addAction [
    localize "STR_A3A_dropObject",
    {
        [nil, false] call A3A_fnc_carryItem;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "(
        (_this getVariable ['A3A_carryingObject', false])
    )"
];
Adds action to player object
Title: Localized string "STR_A3A_dropObject"
Code: Calls A3A_fnc_carryItem with parameters [nil, false]
nil: No specific item (will auto-find attached object)
false: PickUp parameter = false (drop operation)
Arguments: nil (passed as third argument to code, but not used)
Priority: 1.5 (mid-range priority)
ShowWindow: true (visible in action menu)
HideOnUse: true (hide menu after use)
Shortcut: "" (no keyboard shortcut)
Condition: Code block that returns boolean:
Checks if local player has variable A3A_carryingObject set to true
This ensures action only shows when player is carrying something
Radius: 8 (action visible within 8m of player, but since it's added to player, this is probably ignored or acts as proximity)
Step 2: Return Nil

Sqf

Apply
nil;
Returns nil (action addition is side-effect only)
Standard for action setup functions
Complete Function Flow:

Sqf

Apply
player addAction [
    localize "STR_A3A_dropObject",      // Action title
    { [nil, false] call A3A_fnc_carryItem; },  // Action code
    nil,                                // Arguments
    1.5,                                // Priority
    true,                               // ShowWindow
    true,                               // HideOnUse
    "",                                 // Shortcut
    "(_this getVariable ['A3A_carryingObject', false])",  // Condition
    8                                   // Radius
];

nil;
Error Handling & Edge Cases:

If player variable doesn't exist, condition fails safely (action hidden)
If fn_carryItem fails, it handles its own errors
No direct error handling in this function
Where it leads:

Calls:
localize - For translated text
A3A_fnc_carryItem - Main drop functionality
player addAction - Engine action addition
Dependents:
Called by player initialization scripts
May be called by other systems that need drop functionality
System Fit: Provides UI access point for the drop functionality
Global Variables Modified:
Action menu on player (engine-managed)
Network Implications:
Action is local to player only
A3A_fnc_carryItem may have network implications
Function Name: fn_initMovableObject.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_initMovableObject.sqf

What it does: Adds carry and rotate actions to an object that is marked as movable. This function is used for objects that can be moved after placement, providing direct interaction without needing to go through the shop system.

Context & Usage: Called on objects that need to be interactable after placement (like crates, furniture, or other utility objects that weren't placed via the shop system). It's a simplified initialization for movable objects without the full shop integration.

How it does that:

Step 1: Parameter Parsing

Sqf

Apply
params [["_object", objNull, [objNull]]];
Validates and parses the object parameter
Defaults to objNull if not provided
Step 2: Add Carry Action

Sqf

Apply
_object addAction [
    localize "STR_A3A_carryObject",
    {
        [_this#3, true] call A3A_fnc_carryItem;
    },
    _object,
    1.5,
    true,
    true,
    "",
    "(
        (([_this] call A3A_fnc_countAttachedObjects) isEqualTo 0)
        and (attachedTo _target isEqualTo objNull)
    )",
    8
];
Adds carry action to the object
Title: Localized "STR_A3A_carryObject"
Code: Calls A3A_fnc_carryItem with:
_this#3: The object (third argument to action code)
true: PickUp = true (carry operation)
Arguments: The object itself (for reference)
Priority: 1.5
ShowWindow: true
HideOnUse: true
Shortcut: ""
Condition: Complex boolean:
(([_this] call A3A_fnc_countAttachedObjects) isEqualTo 0): Player has no attached objects
and (attachedTo _target isEqualTo objNull): Object isn't already attached to something
Combined: Can only carry if player is free AND object is free
Radius: 8
Step 3: Add Rotate Action

Sqf

Apply
_object addAction [
    localize "STR_A3A_rotateObject",
    {
        [_this#3] call A3A_fnc_rotateItem;
    },
    _object,
    1.5,
    true,
    true,
    "",
    "(
        !(_originalTarget getVariable ['A3A_rotatingObject',false]) 
        and (attachedTo _originalTarget isEqualTo objNull)
    )",
    8
];
Adds rotate action to the object
Title: Localized "STR_A3A_rotateObject"
Code: Calls A3A_fnc_rotateItem with:
_this#3: The object (same as above)
Arguments: The object
Priority: 1.5
ShowWindow: true
HideOnUse: true
Shortcut: ""
Condition: Complex boolean:
!(_originalTarget getVariable ['A3A_rotatingObject',false]): Object isn't currently being rotated by anyone
and (attachedTo _originalTarget isEqualTo objNull): Object isn't attached to something
Combined: Can only rotate if object is free and not already rotating
Radius: 8
Step 4: Return Nil

Sqf

Apply
nil;
Returns nil (side-effect only)
Complete Function Flow:

Sqf

Apply
params [["_object", objNull, [objNull]]];

// Carry action
_object addAction [
    localize "STR_A3A_carryObject",
    { [_this#3, true] call A3A_fnc_carryItem; },
    _object,
    1.5,
    true,
    true,
    "",
    "(
        (([_this] call A3A_fnc_countAttachedObjects) isEqualTo 0)
        and (attachedTo _target isEqualTo objNull)
    )",
    8
];

// Rotate action
_object addAction [
    localize "STR_A3A_rotateObject",
    { [_this#3] call A3A_fnc_rotateItem; },
    _object,
    1.5,
    true,
    true,
    "",
    "(
        !(_originalTarget getVariable ['A3A_rotatingObject',false]) 
        and (attachedTo _originalTarget isEqualTo objNull)
    )",
    8
];

nil;
Error Handling & Edge Cases:

If object is null, actions won't be added (engine handles null objects)
Actions will fail gracefully if called functions are missing
Conditions prevent invalid states (carrying while already carrying, rotating while already rotating)
Where it leads:

Calls:
localize - Text translation
A3A_fnc_carryItem - Main carry functionality
A3A_fnc_rotateItem - Rotate functionality
A3A_fnc_countAttachedObjects - Check player attachments
player addAction - Engine action addition
Dependents:
Called on objects that need movable interaction but aren't shop items
May be used for map-placed objects or custom objects
System Fit: Provides core interaction for movable objects outside the shop system
Global Variables Modified:
Action menu on object (engine-managed)
Object's A3A_rotatingObject variable (checked but not modified)
Network Implications:
Actions are local to object/clients
Called functions may have network implications
Function Name: fn_initObject.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_initObject.sqf

What it does: Initializes a buyable utility item after it's been placed. It sets up vehicle properties, clears or populates inventory based on flags, configures loot functionality, and sets up logistics integration. It's the master initialization function for shop-purchased items.

Context & Usage: Called after an item is successfully purchased and placed (from 
fn_buyItem.sqf
). It transforms a generic vehicle into a fully functional utility item with proper properties and interactions.

How it does that:

Step 1: Set Vehicle Systems

Sqf

Apply
_object setVehicleRadar ([0, 1] select (getNumber(configOf _veh >> "radarType") in [2, 4]));
_object setVehicleReceiveRemoteTargets true;
_object setVehicleReportRemoteTargets true;
Note: Variable _veh is undefined in this snippet (should be _object)
Sets vehicle radar capability based on config:
If radarType is 2 or 4, enable radar (1), else disable (0)
Ensures object can receive and report remote targets (for editor/Zeus compatibility)
These settings are for compatibility with mission systems
Step 2: Parameter Parsing and Validation

Sqf

Apply
params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith { Error("Non-existent object passed") };
if !(typeof _object in A3A_utilityItemHM) exitWith { Error_1("initObject used on object type %1", typeof _object) };
if (!isNil {_object getVariable "A3A_canGarage"}) exitWith { Error_1("Object type %1 already initialized", typeof _object) };
Parses object parameter
Three validation checks:
Object exists (not null)
Object type is in utility items hashmap
Object hasn't been initialized already (checks A3A_canGarage variable)
Step 3: Extract Item Properties

Sqf

Apply
(A3A_utilityItemHM get typeof _object) params ["", "_price", "", "", "_flags"];
Retrieves item data from hashmap
Destructures to get price and flags (other fields unused)
Step 4: Clear Inventory (Conditional)

Sqf

Apply
if !("noclear" in _flags) then {
    clearMagazineCargoGlobal _object;
    clearWeaponCargoGlobal _object;
    clearItemCargoGlobal _object;
    clearBackpackCargoGlobal _object;
};
Checks if "noclear" flag is NOT present
If true, clears all cargo types globally (affects all clients)
This ensures items start empty unless marked otherwise
Step 5: Add Revive Kit (Conditional)

Sqf

Apply
if ("revivekit" in _flags) then {
    _object addItemCargoGlobal ["A3AP_SelfReviveKit", 3];
};
If "revivekit" flag present, adds 3 self-revive kits to the item
Uses global addition so all clients see the items
Step 6: Configure Loot Crate (Conditional)

Sqf

Apply
if ("loot" in _flags) then {
    [_object] remoteExec ["SCRT_fnc_loot_addActionLoot", [teamPlayer, civilian], _object];
    
    if (minWeaps == -1) then {
        [_object, (maxLoad _object) * 2] remoteExecCall ["setMaxLoad", 2];      // setMaxLoad is server-execution
    };
};
If "loot" flag present:
Remotely executes loot action addition to teamPlayer and civilian sides
If global variable minWeaps is -1 (no unlocks), doubles the max load capacity
Uses server execution (ID 2) for setMaxLoad
Step 7: Set Garage and Price Variables

Sqf

Apply
_object setVariable ["A3A_canGarage", true, true];
_object setVariable ["A3A_itemPrice", _price, true];
Marks object as garage-able
Stores item price as object variable
Both are global (true) for JIP compatibility
Step 8: Add Logistics Integration

Sqf

Apply
if ([typeOf _object] call A3A_Logistics_fnc_isLoadable) then {[_object] call A3A_Logistics_fnc_addLoadAction};
Checks if object type is loadable via logistics system
If true, adds load action to the object
Step 9: Remote Execution for Client Actions

Sqf

Apply
private _jipKey = "A3A_initObject_" + ((str _object splitString ":") joinString "");
[_object, _jipKey] remoteExec ["A3A_fnc_initObjectRemote", 0, _jipKey];
Creates unique JIP key from object string representation
Removes colons (safe for JIP keys)
Remotely executes fn_initObjectRemote on all clients (ID 0)
JIP ensures late joiners get the actions too
Complete Function Flow:

Sqf

Apply
// First lines (vehicle settings)
_object setVehicleRadar ([0, 1] select (getNumber(configOf _object >> "radarType") in [2, 4]));
_object setVehicleReceiveRemoteTargets true;
_object setVehicleReportRemoteTargets true;

// Main function
params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith { Error("Non-existent object passed") };
if !(typeof _object in A3A_utilityItemHM) exitWith { Error_1("initObject used on object type %1", typeof _object) };
if (!isNil {_object getVariable "A3A_canGarage"}) exitWith { Error_1("Object type %1 already initialized", typeof _object) };

(A3A_utilityItemHM get typeof _object) params ["", "_price", "", "", "_flags"];

if !("noclear" in _flags) then {
    clearMagazineCargoGlobal _object;
    clearWeaponCargoGlobal _object;
    clearItemCargoGlobal _object;
    clearBackpackCargoGlobal _object;
};

if ("revivekit" in _flags) then {
    _object addItemCargoGlobal ["A3AP_SelfReviveKit", 3];
};

if ("loot" in _flags) then {
    [_object] remoteExec ["SCRT_fnc_loot_addActionLoot", [teamPlayer, civilian], _object];
    
    if (minWeaps == -1) then {
        [_object, (maxLoad _object) * 2] remoteExecCall ["setMaxLoad", 2];
    };
};

_object setVariable ["A3A_canGarage", true, true];
_object setVariable ["A3A_itemPrice", _price, true];

if ([typeOf _object] call A3A_Logistics_fnc_isLoadable) then {[_object] call A3A_Logistics_fnc_addLoadAction};

private _jipKey = "A3A_initObject_" + ((str _object splitString ":") joinString "");
[_object, _jipKey] remoteExec ["A3A_fnc_initObjectRemote", 0, _jipKey];
Error Handling & Edge Cases:

Validates object existence and type before any modifications
Prevents double initialization
Conditional flags allow flexible item configuration
JIP key ensures clients joining late get proper initialization
Where it leads:

Calls:
A3A_Logistics_fnc_isLoadable - Check logistics compatibility
A3A_Logistics_fnc_addLoadAction - Add logistics action
A3A_fnc_initObjectRemote - Remote initialization
remoteExec / remoteExecCall - Network calls
Error / Error_1 - Logging
Dependents:
Called by 
fn_buyItem.sqf
 after successful purchase
Could be called by other systems creating utility items
System Fit: Initializes shop-purchased items with proper game systems integration
Global Variables Modified:
Object variables: A3A_canGarage, A3A_itemPrice
minWeaps (checked, not modified)
Server/Client variables via remoteExec
Network Implications:
Multiple remoteExec calls for loot actions, setMaxLoad, and initObjectRemote
All cargo operations are global
JIP key ensures late joiners get initialized
Function Name: fn_initObjectRemote.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_initObjectRemote.sqf

What it does: Adds client-side actions to utility items based on their flags. This runs on each client for each item, providing local interaction actions like carry, rotate, pack/unpack, and building placement. It's the client-side counterpart to fn_initObject.

Context & Usage: Called remotely from 
fn_initObject.sqf
 for each placed item. It ensures all players see the proper interaction actions on items, regardless of when they joined. This is crucial for JIP compatibility.

How it does that:

Step 1: Parameter Parsing

Sqf

Apply
params [["_object", objNull, [objNull]],["_jipKey", "", [""]]];
Parses object and JIP key
Validates object exists and key is a string
Step 2: Null Object Check and JIP Cleanup

Sqf

Apply
if (isNull _object) exitwith {remoteExec ["", _jipKey]};
If object no longer exists (destroyed/despawned), removes JIP entry
Empty remoteExec clears the JIP function for that key
Step 3: Client Initialization Wait

Sqf

Apply
if (isNil "initClientDone") then {
    waitUntil {sleep 1; !isNil "initClientDone"};
};
Waits for client initialization to complete
Ensures A3A_utilityItemHM and other systems are ready
Polls every second until initClientDone is set
Step 4: Get Item Flags

Sqf

Apply
private _flags = (A3A_utilityItemHM get typeof _object) # 4;
Retrieves item data from global hashmap
Extracts flags (5th element, index 4)
Step 5: Movable Object Action (Conditional)

Sqf

Apply
if ("move" in _flags) then {
    _object addAction [
        "Carry object",
        { [_this#3, true] call A3A_fnc_carryItem },
        _object, 1.5, true, true, "",
        "([_this] call A3A_fnc_countAttachedObjects == 0)
            and (isNull attachedTo _originalTarget)", 8
    ];
};
If "move" flag present, adds carry action
Condition checks:
Player has no attached objects
Target object isn't attached to anything
Step 6: Rotate Object Action (Conditional)

Sqf

Apply
if ("rotate" in _flags) then {
    _object addAction [
        "Rotate object",
        { [_this#3] call A3A_fnc_rotateItem },
        _object, 1.5, true, true, "",
        "!(_originalTarget getVariable ['A3A_rotatingObject',false])
            and (isNull attachedTo _originalTarget)", 8
    ];
};
If "rotate" flag present, adds rotate action
Condition checks object not being rotated and not attached
Step 7: Pack Object Action (Conditional)

Sqf

Apply
if ("pack" in _flags) then {
    _object addAction [
        "Pack object",
        { _this#0 call A3A_Logistics_fnc_packObject },
        nil, 1.5, true, true, "",
        "(isNull attachedTo _originalTarget)", 10
    ];
};
If "pack" flag present, adds pack action
Condition: object not attached to anything
Calls logistics pack function
Step 8: Unpack Object Action (Conditional)

Sqf

Apply
if ("unpack" in _flags) then {
    _object addAction [
        "Unpack object",
        { _this#0 call A3A_Logistics_fnc_unpackObject },
        nil, 1.5, true, true, "",
        "(isNull attachedTo _originalTarget)", 10
    ];
};
If "unpack" flag present, adds unpack action
Condition: object not attached
Calls logistics unpack function
Step 9: Building Placer Action (Conditional)

Sqf

Apply
if ("build" in _flags) then {
    _object addAction [
        "Building placer",
        { [_this#0, 75, _this#0] spawn A3A_fnc_buildingPlacerStart },
        nil, 1.5, true, true, "",
        "(isNull attachedTo _originalTarget)", 4
    ];
};
If "build" flag present, adds building placement action
Uses spawn to start building placer with 75m range
Condition: object not attached
Step 10: Tent-Specific Action

Sqf

Apply
if (typeOf _object == "Land_MedicalTent_01_MTP_closed_F") then {
    _object addAction [
        "Open Doors",
        { _this#0 animateSource ["Door_Hide", 1, true] },
        nil, 1.5, true, true, "",
        "true", 10
    ];
};
Special case for medical tent
Adds door animation action
Condition always true
Animates door source with value 1 (open)
Complete Function Flow:

Sqf

Apply
params [["_object", objNull, [objNull]],["_jipKey", "", [""]]];

if (isNull _object) exitwith {remoteExec ["", _jipKey]};

if (isNil "initClientDone") then {
    waitUntil {sleep 1; !isNil "initClientDone"};
};

private _flags = (A3A_utilityItemHM get typeof _object) # 4;

// Conditional actions based on flags
if ("move" in _flags) then { ... };

if ("rotate" in _flags) then { ... };

if ("pack" in _flags) then { ... };

if ("unpack" in _flags) then { ... };

if ("build" in _flags) then { ... };

// Tent special case
if (typeOf _object == "Land_MedicalTent_01_MTP_closed_F") then { ... };
Error Handling & Edge Cases:

Handles null objects by cleaning up JIP
Waits for client initialization to avoid race conditions
Multiple conditional actions allow flexible item configuration
Special case for tent adds specific functionality
Where it leads:

Calls:
A3A_fnc_carryItem - Carry functionality
A3A_fnc_rotateItem - Rotate functionality
A3A_Logistics_fnc_packObject / unpackObject - Logistics functions
A3A_fnc_buildingPlacerStart - Building system
remoteExec - JIP cleanup
Dependents:
Called by 
fn_initObject.sqf
 for each item
Called by JIP system for late joiners
System Fit: Provides client-side interaction for utility items
Global Variables Modified:
Object's action menu (engine-managed)
JIP system (via remoteExec cleanup)
Network Implications:
Runs locally on each client
JIP key ensures proper cleanup if object is destroyed
Action conditions are evaluated locally
Function Name: fn_remainingAmmo.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_remainingAmmo.sqf

What it does: Calculates the remaining ammunition cargo as a percentage (0.0 to 1.0) for a vehicle. Supports both vanilla Arma and ACE mod functionality, returning 0 if the vehicle has no ammo cargo.

Context & Usage: Used by logistics and UI systems to display ammunition status for vehicles. Particularly important for ACE where ammo handling is different from vanilla. Used in vehicle status displays, resupply calculations, and logistics planning.

How it does that:

Step 1: Parameter Parsing

Sqf

Apply
params [["_vehicle", objNull, [objNull]]];
Validates and parses vehicle parameter
Defaults to objNull
Step 2: Get Vehicle Configuration

Sqf

Apply
private _vehCfg = configFile/"CfgVehicles"/typeOf _vehicle;
Gets config path for the vehicle's class
Used to read vehicle properties
Step 3: ACE Compatibility Check

Sqf

Apply
if(A3A_hasACE) then {
    private _vehicleMaxAmmo = getNumber (_vehCfg >> "ace_rearm_defaultSupply");
    if(_vehicleMaxAmmo == 0) exitwith {0};
    private _currentAmmoCargo = [_vehicle] call ace_rearm_fnc_getSupplyCount;
    (_currentAmmoCargo / _vehicleMaxAmmo);
} else {
    getAmmoCargo _vehicle;
};
Checks global variable A3A_hasACE to determine if ACE is loaded
ACE Path:

Get ace_rearm_defaultSupply from config (total ammo capacity)
If capacity is 0, return 0 (no ammo capacity)
Call ACE function ace_rearm_fnc_getSupplyCount to get current ammo
Return ratio of current/total
Vanilla Path:

Use SQF's built-in getAmmoCargo command
Returns the current ammo cargo value directly
For vanilla, this is already a percentage (0.0 to 1.0)
Complete Function Flow:

Sqf

Apply
params [["_vehicle", objNull, [objNull]]];
private _vehCfg = configFile/"CfgVehicles"/typeOf _vehicle;

if(A3A_hasACE) then {
    private _vehicleMaxAmmo = getNumber (_vehCfg >> "ace_rearm_defaultSupply");
    if(_vehicleMaxAmmo == 0) exitwith {0};
    private _currentAmmoCargo = [_vehicle] call ace_rearm_fnc_getSupplyCount;
    (_currentAmmoCargo / _vehicleMaxAmmo);
} else {
    getAmmoCargo _vehicle;
};
Error Handling & Edge Cases:

Handles null vehicle (returns 0 from vanilla path)
Handles zero max ammo in ACE (returns 0)
Returns float between 0 and 1
If vehicle config missing, defaults to 0 in vanilla path
Where it leads:

Calls:
ace_rearm_fnc_getSupplyCount - ACE ammo function (if ACE loaded)
getAmmoCargo - Vanilla SQF function (if no ACE)
Dependents:
UI displays for vehicle ammo
Logistics resupply calculations
Vehicle status scripts
System Fit: Provides standardized ammo status for vehicles across different modsets
Global Variables Modified:
A3A_hasACE (read only)
Network Implications:
All operations are local
ACE functions run locally if ACE is local
No network calls
Function Name: fn_remainingFuel.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_remainingFuel.sqf

What it does: Calculates the remaining fuel cargo as a percentage (0.0 to 1.0) for a vehicle. Supports both vanilla Arma and ACE mod functionality, returning 0 if the vehicle has no fuel cargo.

Context & Usage: Used by logistics and UI systems to display fuel status for vehicles. Particularly important for ACE where fuel handling is different from vanilla. Used in vehicle status displays, resupply calculations, and fuel logistics planning.

How it does that:

Step 1: Parameter Parsing

Sqf

Apply
params [["_vehicle", objNull, [objNull]]];
Validates and parses vehicle parameter
Defaults to objNull
Step 2: Get Vehicle Configuration

Sqf

Apply
private _vehCfg = configFile/"CfgVehicles"/typeOf _vehicle;
Gets config path for the vehicle's class
Used to read vehicle properties
Step 3: ACE Compatibility Check

Sqf

Apply
if(A3A_hasACE) then {
    private _vehicleMaxFuel = getNumber (_vehCfg >> "ace_refuel_fuelCargo");
    if(_vehicleMaxFuel == 0) exitwith {0};
    private _currentFuelCargo = [_vehicle] call ace_refuel_fnc_getFuel;
    (_currentFuelCargo / _vehicleMaxFuel);
} else {
    getFuelCargo _vehicle;
};
Checks global variable A3A_hasACE to determine if ACE is loaded
ACE Path:

Get ace_refuel_fuelCargo from config (total fuel capacity)
If capacity is 0, return 0 (no fuel capacity)
Call ACE function ace_refuel_fnc_getFuel to get current fuel
Return ratio of current/total
Vanilla Path:

Use SQF's built-in getFuelCargo command
Returns the current fuel cargo value directly
For vanilla, this is already a percentage (0.0 to 1.0)
Complete Function Flow:

Sqf

Apply
params [["_vehicle", objNull, [objNull]]];
private _vehCfg = configFile/"CfgVehicles"/typeOf _vehicle;

if(A3A_hasACE) then {
    private _vehicleMaxFuel = getNumber (_vehCfg >> "ace_refuel_fuelCargo");
    if(_vehicleMaxFuel == 0) exitwith {0};
    private _currentFuelCargo = [_vehicle] call ace_refuel_fnc_getFuel;
    (_currentFuelCargo / _vehicleMaxFuel);
} else {
    getFuelCargo _vehicle;
};
Error Handling & Edge Cases:

Handles null vehicle (returns 0 from vanilla path)
Handles zero max fuel in ACE (returns 0)
Returns float between 0 and 1
If vehicle config missing, defaults to 0 in vanilla path
Where it leads:

Calls:
ace_refuel_fnc_getFuel - ACE fuel function (if ACE loaded)
getFuelCargo - Vanilla SQF function (if no ACE)
Dependents:
UI displays for vehicle fuel
Logistics resupply calculations
Vehicle status scripts
System Fit: Provides standardized fuel status for vehicles across different modsets
Global Variables Modified:
A3A_hasACE (read only)
Network Implications:
All operations are local
ACE functions run locally if ACE is local
No network calls
Function Name: fn_rotateItem.sqf
File Path: A3A/addons/core/functions/UtilityItems/fn_rotateItem.sqf

What it does: Provides real-time rotation control for objects using keyboard inputs (E to rotate one way, Q the other way, Space/Enter to finish). The rotation is immediate and continuous, with visual feedback and distance checks. It's a minigame-style interface for precise object positioning.

Context & Usage: Called when a player selects the "Rotate Object" action on a movable item. The function manages an input loop and visual feedback until rotation is complete. It's used for fine-tuning object placement after carrying or initial placement.

How it does that:

Step 1: Define Constants

Sqf

Apply
#include "\a3\ui_f\hpp\definedikcodes.inc"
params[["_object", objNull, [objNull]]];

#define E_PRESSED 0
#define Q_PRESSED 1
#define WAIT_TIME 2
#define OBJ_DIR 3
#define OBJ 4
#define INFO_TEXT 5
#define END_ROTATING 6
#define KEYDOWN_EH 7
#define EACHFRAME_EH 8
#define HINT_DISPLAY 9
Includes DIK key code definitions (for key detection)
Defines constants for array indices in the database
This makes the code more readable
Step 2: Check for Active Rotation

Sqf

Apply
if(!isNil "A3A_objectRotate_EHDB") exitwith {};
Checks if rotation database already exists
Prevents multiple simultaneous rotations
Exits if rotation is already in progress
Step 3: Initialize Rotation Database

Sqf

Apply
A3A_objectRotate_EHDB = [false, false, time, getDir _object, _object, "", {
    findDisplay 46 displayRemoveEventHandler ["KeyDown", A3A_objectRotate_EHDB # KEYDOWN_EH ];
    removeMissionEventHandler ["EachFrame", A3A_objectRotate_EHDB # EACHFRAME_EH ];
    terminate (A3A_objectRotate_EHDB # HINT_DISPLAY );
    (A3A_objectRotate_EHDB # OBJ) setVariable ["A3A_rotatingObject", false, true];
    A3A_objectRotate_EHDB = nil;
}, -1, -1, controlNull];
Creates global database array:
0: E_PRESSED (false)
1: Q_PRESSED (false)
2: WAIT_TIME (current time)
3: OBJ_DIR (current object direction)
4: OBJ (the object being rotated)
5: INFO_TEXT (feedback text)
6: END_ROTATING (cleanup code)
7: KEYDOWN_EH (event handler ID, -1 initially)
8: EACHFRAME_EH (event handler ID, -1 initially)
9: HINT_DISPLAY (spawn handle, controlNull initially)
The cleanup code is defined inline
Step 4: Mark Object as Rotating

Sqf

Apply
_object setVariable ["A3A_rotatingObject", true, true];
Sets global variable on object indicating it's being rotated
Prevents others from rotating it simultaneously
Step 5: Add KeyDown Event Handler

Sqf

Apply
private _keyDownEH = findDisplay 46 displayAddEventHandler ["KeyDown", {
    params["","_key"];
    private _return = false;
    
    if (_key isEqualTo DIK_E && (A3A_objectRotate_EHDB # WAIT_TIME) < time) then {
        _return = true;
        A3A_objectRotate_EHDB set [E_PRESSED, true];
        A3A_objectRotate_EHDB set [ WAIT_TIME , (A3A_objectRotate_EHDB # WAIT_TIME ) + 0.01];
    };
    
    if (_key isEqualTo DIK_Q && (A3A_objectRotate_EHDB # WAIT_TIME) < time) then {
        _return = true;
        A3A_objectRotate_EHDB set [Q_PRESSED, true];
        A3A_objectRotate_EHDB set [WAIT_TIME , (A3A_objectRotate_EHDB # WAIT_TIME ) + 0.01];
    };
    
    if (_key in [DIK_SPACE,DIK_RETURN]) then{
        _return = true;
        call (A3A_objectRotate_EHDB # END_ROTATING);
    };
    _return;
}];
A3A_objectRotate_EHDB set [KEYDOWN_EH , _keyDownEH];
Adds key handler to main display (DIK_E, DIK_Q, Space, Enter)
E key: Sets E_PRESSED true, increments wait time by 0.01s (cooldown)
Q key: Sets Q_PRESSED true, increments wait time by 0.01s
Space/Enter: Calls the end rotating cleanup code
Stores handler ID in database
Returns true for handled keys, false for others
Step 6: Add EachFrame Event Handler

Sqf

Apply
private _eachFrameEH  = addMissionEventHandler ["EachFrame", {
    private _directionChanged = false;
    
    // rotation
    if (A3A_objectRotate_EHDB # Q_PRESSED) then {
        A3A_objectRotate_EHDB set [Q_PRESSED, false];
        A3A_objectRotate_EHDB set [OBJ_DIR, (A3A_objectRotate_EHDB # OBJ_DIR) -1];
        _directionChanged = true;
    };
    
    if (A3A_objectRotate_EHDB # E_PRESSED) then {
        A3A_objectRotate_EHDB set [E_PRESSED, false];
        A3A_objectRotate_EHDB set [OBJ_DIR, (A3A_objectRotate_EHDB # OBJ_DIR) +1];
        _directionChanged = true;
    };
    
    //set dir
    if (_directionChanged) then {
        (A3A_objectRotate_EHDB # OBJ) setDir (A3A_objectRotate_EHDB # OBJ_DIR);
        (A3A_objectRotate_EHDB # OBJ) setVectorUp surfaceNormal getPos (A3A_objectRotate_EHDB # OBJ);
    };
    
    if ((player distance (A3A_objectRotate_EHDB # OBJ)) > 5) then {
        A3A_objectRotate_EHDB set [INFO_TEXT, localize "STR_A3A_Utility_Items_Feedback_Far"];
    }else {
        A3A_objectRotate_EHDB set [INFO_TEXT, localize "STR_A3A_Utility_Items_Feedback_Normal"];
    };
    
    private _control_Hint = [A3A_objectRotate_EHDB # INFO_TEXT , 0, 0.9, 0.2, 0, 0, 17001] spawn BIS_fnc_dynamicText;
    A3A_objectRotate_EHDB set [HINT_DISPLAY, _control_Hint];
    
    if (!([player] call A3A_fnc_canFight)||((player distance (A3A_objectRotate_EHDB # OBJ)) > 6)) then{
        call (A3A_objectRotate_EHDB # END_ROTATING);
    };
    
}];
A3A_objectRotate_EHDB set [EACHFRAME_EH , _eachFrameEH];
Q key handling: Decrements direction by 1 degree, clears flag, sets change flag
E key handling: Increments direction by 1 degree, clears flag, sets change flag
Direction change: If any change occurred:
Sets object direction
Adjusts vectorUp to surface normal (keeps object level)
Distance check: Shows different feedback text based on distance
5m: "Move closer" warning

≤5m: "Normal" feedback
Dynamic text: Spawns BIS_fnc_dynamicText with position (0, 0.9) - upper middle
Termination conditions: Calls cleanup if:
Player can't fight (dead/unconscious)
Distance > 6m (too far)
Stores handler ID in database
Complete Function Flow:

Sqf

Apply
// Constants and parameters
#include "\a3\ui_f\hpp\definedikcodes.inc"
params[["_object", objNull, [objNull]]];
#define E_PRESSED 0
// ... other defines

// Check if already rotating
if(!isNil "A3A_objectRotate_EHDB") exitwith {};

// Initialize database
A3A_objectRotate_EHDB = [false, false, time, getDir _object, _object, "", {
    // Cleanup code
    findDisplay 46 displayRemoveEventHandler ["KeyDown", A3A_objectRotate_EHDB # KEYDOWN_EH ];
    removeMissionEventHandler ["EachFrame", A3A_objectRotate_EHDB # EACHFRAME_EH ];
    terminate (A3A_objectRotate_EHDB # HINT_DISPLAY );
    (A3A_objectRotate_EHDB # OBJ) setVariable ["A3A_rotatingObject", false, true];
    A3A_objectRotate_EHDB = nil;
}, -1, -1, controlNull];

// Mark object
_object setVariable ["A3A_rotatingObject", true, true];

// Add KeyDown handler
private _keyDownEH = findDisplay 46 displayAddEventHandler ["KeyDown", {
    params["","_key"];
    private _return = false;
    // Key handling logic
    if (_key isEqualTo DIK_E && (A3A_objectRotate_EHDB # WAIT_TIME) < time) then { ... };
    if (_key isEqualTo DIK_Q && (A3A_objectRotate_EHDB # WAIT_TIME) < time) then { ... };
    if (_key in [DIK_SPACE,DIK_RETURN]) then { ... };
    _return;
}];
A3A_objectRotate_EHDB set [KEYDOWN_EH , _keyDownEH];

// Add EachFrame handler
private _eachFrameEH = addMissionEventHandler ["EachFrame", {
    private _directionChanged = false;
    // Q/E key processing
    if (A3A_objectRotate_EHDB # Q_PRESSED) then { ... };
    if (A3A_objectRotate_EHDB # E_PRESSED) then { ... };
    // Direction update
    if (_directionChanged) then { ... };
    // Distance feedback
    if ((player distance (A3A_objectRotate_EHDB # OBJ)) > 5) then { ... } else { ... };
    // Dynamic text display
    private _control_Hint = [A3A_objectRotate_EHDB # INFO_TEXT , 0, 0.9, 0.2, 0, 0, 17001] spawn BIS_fnc_dynamicText;
    A3A_objectRotate_EHDB set [HINT_DISPLAY, _control_Hint];
    // Termination check
    if (!([player] call A3A_fnc_canFight)||((player distance (A3A_objectRotate_EHDB # OBJ)) > 6)) then { ... };
}];
A3A_objectRotate_EHDB set [EACHFRAME_EH , _eachFrameEH];
Error Handling & Edge Cases:

Prevents double rotation with initial check
Cleanup ensures handlers are removed even on abnormal termination
Distance checks prevent rotating from afar
Object variable prevents concurrent rotations
Dynamic text spawns new text each frame (may cause accumulation)
Where it leads:

Calls:
A3A_fnc_canFight - Check player combat ability
BIS_fnc_dynamicText - Display feedback
SQF commands: addEventHandler, setDir, setVectorUp, etc.
Dependents:
Called by 
fn_initMovableObject.sqf
 (rotate action)
Called by 
fn_initObjectRemote.sqf
 (rotate action)
System Fit: Provides precise control for object positioning
Global Variables Modified:
A3A_objectRotate_EHDB - Global database (created, modified, deleted)
Object's A3A_rotatingObject variable - Set to true then false
Network Implications:
All operations are local
Object state changes are replicated by engine
No network calls
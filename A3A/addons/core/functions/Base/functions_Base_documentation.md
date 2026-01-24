Function Name: fn_addActionBreachVehicle.sqf
What it does: This function adds an "action" to a vehicle object, allowing players to initiate a breaching interaction. It is used to create a contextual menu option on enemy vehicles, enabling a specific gameplay mechanic (breaching).

How it does that:

Parameter Extraction: It extracts the _vehicle object from the passed arguments.
Remote Execution: It uses remoteExec to execute the addAction command on all clients (0) but only for the specific vehicle (_vehicle). This ensures the action appears for all players near the vehicle without requiring global object syncing.
Action Configuration: It constructs the action parameters:
Text: Localized string "Breach Vehicle".
Code: Executes A3A_fnc_startBreachVehicle when selected.
Arguments: nil (not used in the target function).
Priority: 4.
Other Flags: false (hide on use), true (require cursor).
Condition: " (isPlayer _this) && (_this == vehicle _this)" (Player must be on foot) and " " " (Specific cursor object condition, though usually implied by the logic).
Script ID: The code executes in the scope of the passed vehicle context.
Code Snippet:

Sqf

Apply
params ["_vehicle"];

[_vehicle, [localize "STR_antistasi_actions_breach_vehicle", A3A_fnc_startBreachVehicle,nil,4,false,true,"","(isPlayer _this) && (_this == vehicle _this)",5]] remoteExec ["addAction", 0, _vehicle];
Where it leads:

Called by: Usually called during vehicle initialization or spawning (e.g., fn_addRebelVehicleActions).
Calls: A3A_fnc_startBreachVehicle (upon user activation).
Dependencies: Relies on the remoteExec system (JIP compatible) and the client having the localized string available.
Global State: None.
Network: Multicast to all clients (0) with the vehicle as the target, ensuring JIP players get the action.

Function Name: fn_addAggression.sqf
What it does: This function adds a specified amount of aggression to a given side (Occupants or Invaders) and sets how long it should remain active. It manages the aggression decay system and recalculates aggression levels. It's called when mission events need to influence enemy behavior, such as capturing territories or completing objectives.

How it does that:

Sqf

Apply
// 1. Parameter validation and initialization
params
[
    ["_side", sideUnknown, [sideUnknown]],
    ["_aggroChange", 0, [0]],
    ["_aggroTime", 0, [0]],
    ["_doNotAdjust", false, [false]]
];
Parameter validation: Uses SQF's params command with default values and type checking. Each parameter has a default value: side defaults to sideUnknown, aggression change to 0, time to 0, and adjustment flag to false.
Type safety: The third parameter for each entry is the type array [sideUnknown], [0], [0], [false] which provides compile-time type checking.
Sqf

Apply
// 2. Define helper function to convert minutes to decay rate
_fn_convertMinutesToDecayRate =
{
    params ["_points", "_minutes"];
    if(_minutes == 0) then
    {
        Error("Minute parameter is 0, assuming 1");
        _minutes = 1;
    };
    (-1) * (_points / _minutes);
};
Helper function definition: Defines a local lambda to calculate the decay rate.
Edge case handling: Checks if _minutes is 0 to prevent division by zero. If so, logs an error and defaults to 1 minute.
Calculation: Decay rate is calculated as negative of points divided by minutes (negative because it's a reduction over time).
Sqf

Apply
// 3. Exit early if no change requested
if(_aggroChange == 0) exitWith {};
Early exit: If the aggression change is 0, exit immediately to avoid unnecessary processing.
Sqf

Apply
// 4. Synchronize access to prevent race conditions
waitUntil {!prestigeIsChanging};
prestigeIsChanging = true;
Thread synchronization: Uses waitUntil with a busy-wait loop to ensure exclusive access to the aggression system.
Locking mechanism: Sets a global boolean prestigeIsChanging to true to prevent concurrent modification of aggression stacks.
Sqf

Apply
// 5. Apply player count scaling if needed
if (!_doNotAdjust) then { _aggroChange = _aggroChange / A3A_balancePlayerScale };
Balance adjustment: If adjustment flag is false, divides aggression change by the player balance scale (A3A_balancePlayerScale). This ensures more players cause proportionally more aggression.
Sqf

Apply
// 6. Calculate decay rate for the aggression addition
private _decayRate = [_aggroChange, _aggroTime] call _fn_convertMinutesToDecayRate;
Decay calculation: Calls the helper function to compute how quickly this aggression addition should decay.
Sqf

Apply
// 7. Add aggression to appropriate side stacks
if(_side == Occupants) then
{
    aggressionStackOccupants pushBack [_aggroChange, _decayRate];
};

if(gameMode != 3 && (_side == Invaders)) then
{
    aggressionStackInvaders pushBack [_aggroChange, _decayRate];
};
Side-specific handling: Checks the side parameter and adds to the corresponding aggression stack.
Game mode check: For Invaders, checks if game mode is not 3 (likely campaign mode) before adding.
Stack structure: Each entry is an array [currentValue, decayRate] where currentValue is the remaining aggression points.
Sqf

Apply
// 8. Recalculate aggression levels
[] call A3A_fnc_calculateAggression;
Recalculation trigger: Calls the dedicated function to update aggression values and levels based on the new stack.
Sqf

Apply
// 9. Release synchronization lock
prestigeIsChanging = false;
Unlocking: Releases the global lock to allow other functions to modify aggression.
Where it leads:

Called functions:
A3A_fnc_calculateAggression - Recalculates aggression values and levels based on the stacks
Error (macro) - Logs error messages when minute parameter is 0
Called by: Various mission systems including:
fn_markerChange.sqf
 when territories are captured
fn_aggressionUpdateLoop.sqf
 during periodic updates
Mission reward systems
Modifies global variables:
prestigeIsChanging - Lock mechanism
aggressionStackOccupants - Occupant aggression stack
aggressionStackInvaders - Invader aggression stack
Synchronization implications: Uses busy-wait locking. The lock is held briefly (only for stack modification and recalculation). Networked servers need to ensure all clients see consistent aggression values, which is handled by calculateAggression making public variable updates.
System fit: Part of the dynamic difficulty adjustment system. Aggression affects enemy AI behavior, spawn rates, and attack frequency. The decay system ensures temporary spikes in aggression naturally reduce over time.
Function Name: fn_addEnemyResources.sqf
What it does: Adds or removes resources from enemy faction resource pools (attack and defense). It manages three resource types: attack, defense, and legacy (which splits equally between attack and defense).

How it does that:

Sqf

Apply
// 1. Server-side validation
if (!isServer) exitWith { Error("Server-only function miscalled") };
Execution context check: Ensures the function only runs on the server, exiting with an error if called elsewhere.
Sqf

Apply
// 2. Parameter extraction
params ["_count", "_side", "_type"];
Parameter binding: Extracts the three required parameters.
Sqf

Apply
// 3. Validate side parameter
if (_side != Occupants && _side != Invaders) exitWith { Error_1("Called with invalid side: %1", _side) };
Side validation: Only Occupants and Invaders are valid enemy factions. Exits with formatted error message if invalid.
Sqf

Apply
// 4. Validate count parameter
if (isNil "_count" or {!finite _count}) exitWith { Error("Called with invalid count") };
Value validation: Checks if count is nil or not finite (NaN or infinity), preventing invalid resource calculations.
Sqf

Apply
// 5. Debug logging
Debug_3("Adding %1 resources of type %2 to side %3", _count, _type, _side);
Debug output: Logs the operation details when debug mode is active.
Sqf

Apply
// 6. Handle defense resources
if (_type isEqualTo "defence") exitWith {
    if (_side == Invaders) then {
        A3A_resourcesDefenceInv = A3A_resourcesDefenceInv + _count;
    } else {
        A3A_resourcesDefenceOcc = A3A_resourcesDefenceOcc + _count;
    };
};
Defense type handling: Directly modifies the appropriate defense resource variable.
Variable selection: Uses ternary logic to select between Invader and Occupant defense resources.
Sqf

Apply
// 7. Handle attack resources
if (_type isEqualTo "attack") exitWith {
    if (_side == Invaders) then {
        A3A_resourcesAttackInv = A3A_resourcesAttackInv + _count;
    } else {
        A3A_resourcesAttackOcc = A3A_resourcesAttackOcc + _count;
    };
};
Attack type handling: Similar structure to defense, but modifies attack resources.
Sqf

Apply
// 8. Handle legacy resources (split)
if (_type isEqualTo "legacy") exitWith {
    [_count/2, _side, "defence"] call A3A_fnc_addEnemyResources;
    [_count/2, _side, "attack"] call A3A_fnc_addEnemyResources;
};
Legacy type handling: Recursively calls itself to split the count between defense and attack.
Division: Splits count in half for each resource type.
Sqf

Apply
// 9. Unknown type error
Error_1("Called with unknown type: %1", _type);
Final validation: If type doesn't match any valid string, logs an error.
Where it leads:

Called functions:
A3A_fnc_addEnemyResources - Self-call for legacy type (recursive)
Error_1 (macro) - Error logging
Called by: Multiple systems:
fn_aggressionUpdateLoop.sqf
 for periodic resource generation
fn_markerChange.sqf
 for resource rewards
fn_chooseAttack.sqf
 when spending resources
Modifies global variables:
A3A_resourcesDefenceInv - Invader defense resources
A3A_resourcesDefenceOcc - Occupant defense resources
A3A_resourcesAttackInv - Invader attack resources
A3A_resourcesAttackOcc - Occupant attack resources
Synchronization implications: Server-side only. Variables are global and should be synchronized manually if needed. Typically used in server-side logic only.
System fit: Core of enemy resource management. Attack resources drive enemy assaults, defense resources affect garrison strength. The legacy system provides backward compatibility for mission rewards that give "resources" without specifying type.
Function Name: fn_addHC.sqf
What it does: Registers a Headless Client connection by adding its ID to the hcArray and sets the global flag indicating HC support is available.

How it does that:

Sqf

Apply
// 1. Extract Headless Client ID from parameters
_clientID = _this select 0;
Parameter extraction: Gets the first element from the parameter array (the client ID).
Sqf

Apply
// 2. Add to HC array (with duplicate prevention)
hcArray pushBackUnique _clientID;
Array modification: Uses pushBackUnique to add the ID only if not already present.
Data structure: hcArray stores all connected HC IDs.
Sqf

Apply
// 3. Log connection
Info_1("Headless Client Connected: %1.",hcArray);
Information logging: Logs the connection event with the current array contents.
Sqf

Apply
// 4. Set global HC availability flag
if (isNil "hasHeadlessClients") then {
    hasHeadlessClients = true;
    publicVariable "hasHeadlessClients";
};
First HC detection: Checks if hasHeadlessClients is nil (first HC connection).
Flag setting: Sets flag to true and makes it public so all clients know HCs are available.
Where it leads:

Called functions:
Info_1 (macro) - Logging function
Called by: Event handler on HC connection (likely onPlayerConnected or similar)
Modifies global variables:
hcArray - Array of connected HC client IDs
hasHeadlessClients - Boolean flag indicating HC presence
Synchronization implications:
pushBackUnique modifies array on server only
publicVariable broadcasts hasHeadlessClients to all clients
HC ID is a number, safe for network transmission
System fit: Part of distributed AI processing system. When HCs are connected, AI tasks can be offloaded from the main server to reduce performance load. The scheduler uses hcArray to determine where to spawn AI groups.
Function Name: fn_addRecentDamage.sqf
What it does: Records damage events for enemy factions. For air vehicles, it adds threat to the vehicle; for ground units, it stores position and value data for future enemy reinforcement calculations.

How it does that:

Sqf

Apply
// 1. Server-side validation
if (!isServer) exitWith { Error("Server-only function miscalled") };
Execution context: Ensures server-only execution for data consistency.
Sqf

Apply
// 2. Parameter extraction
params ["_side", "_pos", "_value", "_killer"];
Binding parameters: Extracts side, position, damage value, and vehicle object.
Sqf

Apply
// 3. Air vehicle special handling
if (_killer isKindOf "Air") exitWith {
    Debug_2("Adding %1 threat to vehicle %2", _value, typeof _killer);
    private _extraThreat = _killer getVariable ["A3A_airKills", 0];
    _killer setVariable ["A3A_airKills", _extraThreat + _value];
};
Type check: Uses isKindOf to detect air vehicles.
Threat accumulation: Retrieves existing threat value (default 0) and adds current damage value.
Variable storage: Stores cumulative threat on the vehicle object itself.
Sqf

Apply
// 4. Validate side for ground units
if (_side != Occupants && _side != Invaders) exitWith { Error_1("Called with invalid side: %1", _side) };
Side validation: Ensures only valid enemy sides are processed.
Sqf

Apply
// 5. Prepare damage data for storage
private _killPosValue = [_pos#0, _pos#1, 1000*20 + round _value];
Data encoding: Creates a 3-element array:
_pos#0 - X coordinate
_pos#1 - Y coordinate
1000*20 + round _value - Encoded value (20,000 + rounded damage)
Encoding logic: Base value (20,000) + actual damage. This likely stores time and damage in one integer.
Sqf

Apply
// 6. Store in appropriate damage array
([A3A_recentDamageOcc, A3A_recentDamageInv] select (_side == Invaders)) pushBack _killPosValue;
Array selection: Uses ternary to select between Occupant and Invader damage arrays.
Storage: Appends the encoded data to the selected array.
Where it leads:

Called functions:
Error_1 (macro) - Error logging
Debug_2 (macro) - Debug logging
Called by:
fn_airspaceControl.sqf
 when aircraft are detected
fn_calculateSupportCallReveal.sqf for threat assessment
Mission events where damage is dealt
Modifies global variables:
A3A_recentDamageOcc - Occupant damage events array
A3A_recentDamageInv - Invader damage events array
A3A_airKills - Vehicle-specific threat value
Synchronization implications:
Server-side only operation
Vehicle variables are local to the vehicle object
Arrays are server-side only, not synchronized to clients
System fit: Part of enemy reinforcement intelligence system. The recent damage data is used to:
Calculate appropriate response strength
Determine where to send reinforcements
Assess threat levels for support calls
The air vehicle threat affects subsequent air defense responses
Function Name: fn_aggressionUpdateLoop.sqf
What it does: Main server loop that updates aggression values, resource generation, and triggers enemy attacks every minute. It manages the entire enemy economy and balance system.

How it does that:

Sqf

Apply
// 1. Infinite loop structure
while {true} do
{
Loop setup: Creates an infinite loop that runs once per minute.
Execution context: Designed to be spawned on the server.
Sqf

Apply
// 2. Update active player count
A3A_activePlayerCount = count ((allPlayers - entities "HeadlessClient_F") select { !(_x getVariable ["isAFK", false]) });
publicVariable "A3A_activePlayerCount";
Player filtering: Counts all non-HC players who aren't marked as AFK.
Global synchronization: Broadcasts the count to all clients for display and balancing.
Sqf

Apply
// 3. Pause when no players online
if (A3A_activePlayerCount == 0) then { sleep 60; continue };
Idle detection: Skips processing if no active players, sleeping for 60 seconds and continuing to next iteration.
Sqf

Apply
// 4. Wait for exclusive access to aggression system
waitUntil {!prestigeIsChanging};
prestigeIsChanging = true;
Synchronization lock: Ensures no other thread is modifying aggression data simultaneously.
Sqf

Apply
// 5. Update Occupant aggression stack
aggressionStackOccupants = aggressionStackOccupants apply {[(_x select 0) + (_x select 1), (_x select 1)]};
Decay calculation: For each entry in the stack, adds the decay rate to the current value (making it less negative/more positive or more negative).
Array transformation: Uses apply to transform each stack entry.
Sqf

Apply
// 6. Filter out expired Occupant entries
aggressionStackOccupants = aggressionStackOccupants select {(_x select 0) * (_x select 1) < 0};
Cleanup logic: Selects entries where current value and decay rate have opposite signs (meaning the value crossed zero).
Mathematical condition: When multiplied, if result is negative, values are opposite signs and have passed through zero.
Sqf

Apply
// 7. Repeat for Invaders
aggressionStackInvaders = aggressionStackInvaders apply {[(_x select 0) + (_x select 1), (_x select 1)]};
aggressionStackInvaders = aggressionStackInvaders select {(_x select 0) * (_x select 1) < 0};
Mirror operations: Same calculation and filtering for Invader aggression stack.
Sqf

Apply
// 8. Release aggression lock
prestigeIsChanging = false;
[] call A3A_fnc_calculateAggression;
Unlock and recalculate: Releases lock and immediately recalculates global aggression values.
Sqf

Apply
// 9. Update recent damage arrays (time decay)
{ _x set [2, _x#2 - 1000] } forEach A3A_recentDamageOcc;
{ _x set [2, _x#2 - 1000] } forEach A3A_recentDamageInv;
Time-based decay: Reduces the third element (encoded time) by 1000 units per minute for all damage entries.
In-place modification: Uses set to modify array elements directly.
Sqf

Apply
// 10. Clean up expired damage entries
A3A_recentDamageOcc = A3A_recentDamageOcc select { _x#2 > 0 };
A3A_recentDamageInv = A3A_recentDamageInv select { _x#2 > 0 };
Filtering: Keeps only entries with positive time values (not expired).
Sqf

Apply
// 11. Calculate player balance scaling
private _lastScale = A3A_balancePlayerScale;
A3A_balancePlayerScale = (A3A_activePlayerCount ^ 0.8 + 1 + tierWar / 4) / 6;
A3A_balancePlayerScale = A3A_balancePlayerScale * (A3A_enemyBalanceMul / 10);
A3A_balanceVehicleCost = 100 + tierWar * 10;
A3A_balanceResourceRate = A3A_balancePlayerScale * ([A3A_balanceVehicleCost, 140] select (gameMode == 1));
publicVariable "A3A_balancePlayerScale";
Complex calculation: Multi-part formula for balance:
A3A_activePlayerCount ^ 0.8 - Non-linear scaling with player count
+ 1 - Minimum of 1
+ tierWar / 4 - War tier adjustment
/ 6 - Normalization factor
* (A3A_enemyBalanceMul / 10) - Difficulty multiplier from settings
Related calculations: Vehicle cost and resource rate based on the scale.
Network sync: Broadcasts balance scale to clients for AI skill adjustment.
Sqf

Apply
// 12. Scale defense resources with balance change
A3A_resourcesDefenceOcc = A3A_resourcesDefenceOcc * A3A_balancePlayerScale / _lastScale;
A3A_resourcesDefenceInv = A3A_resourcesDefenceInv * A3A_balancePlayerScale / _lastScale;
Proportional scaling: Adjusts existing defense resources based on new vs old balance scale.
Sqf

Apply
// 13. Update difficulty coefficient
difficultyCoef = floor (A3A_activePlayerCount / 5);
publicVariable "difficultyCoef";
Simplified difficulty: Integer division by 5 to get tiered difficulty level.
Broadcast: Makes it available to mission systems.
Sqf

Apply
// 14. Calculate Occupant resource rates
private _aggroMul = [1.0 + aggressionOccupants/200, 0.5 + aggressionOccupants/200] select (gameMode != 1);
private _resRateDef = _aggroMul * A3A_balanceResourceRate / 10;
private _resRateAtk = _aggroMul * A3A_balanceResourceRate * (A3A_enemyAttackMul / 10) / 12;
Aggression multiplier: Scales rates based on aggression level.
Resource calculation: Defense rate gets full resource rate divided by 10; attack rate is further reduced by 12 and multiplied by attack multiplier.
Sqf

Apply
// 15. Airport availability check for Occupants
private _noAirport = -1 == airportsX findIf { sidesX getVariable _x == Occupants };
if (_noAirport) then { _resRateDef = _resRateDef * 0.6; _resRateAtk = _resRateAtk * 0.6 };
Airport check: Uses findIf to check if any airport is occupied by Occupants.
Penalty application: Reduces rates by 40% if no airfield available.
Sqf

Apply
// 16. Defense/attack resource balancing for Occupants
private _maxDef = _resRateDef*100;
private _shift = linearConversion [0, _maxDef, A3A_resourcesDefenceOcc, -0.5, 0.5, true];
_resRateDef = _resRateDef - _resRateAtk * _shift;
_resRateAtk = _resRateAtk + _resRateAtk * _shift;
Resource shifting: Moves resources between defense and attack based on current defense level.
Linear conversion: Scales shift from -0.5 to 0.5 based on defense resources compared to maximum.
Balancing: Low defense resources get more defense rate; high defense resources get more attack rate.
Sqf

Apply
// 17. Add resources to Occupants
Debug_4("Adding %1 def resources to %2 and %3 atk resources to %4", _resRateDef, A3A_resourcesDefenceOcc, _resRateAtk, A3A_resourcesAttackOcc);
A3A_resourcesDefenceOcc = (A3A_resourcesDefenceOcc + _resRateDef) min _maxDef;
A3A_resourcesAttackOcc = A3A_resourcesAttackOcc + _resRateAtk;
Resource addition: Adds calculated rates to current resources, capping defense at _maxDef.
Sqf

Apply
// 18. Trigger Occupant attack if possible
if (A3A_resourcesAttackOcc > 0 && !bigAttackInProgress) then
{
    private _success = [Occupants] call A3A_fnc_chooseAttack;
    if (!_success) then {
        A3A_resourcesAttackOcc = A3A_resourcesAttackOcc - _resRateAtk*10;
    };
};
Attack condition: Checks if attack resources exist and no big attack is ongoing.
Attack selection: Calls chooseAttack to select and initiate an attack.
Failure penalty: If attack fails (returns false), removes 10x the resource rate as penalty.
Sqf

Apply
// 19. Repeat for Invaders (if game mode allows)
if (gameMode != 3) then
{
    // ... Similar calculations and logic for Invaders ...
};
Game mode check: Invaders don't exist in campaign mode (gameMode == 3).
Mirror logic: Same calculations as Occupants but with different multipliers and variables.
Sqf

Apply
// 20. Sleep for one minute
sleep 60;
Loop timing: Pauses until next minute cycle.
Where it leads:

Called functions:
A3A_fnc_calculateAggression - Recalculates aggression levels
A3A_fnc_chooseAttack - Initiates enemy attacks
A3A_fnc_maxDefenceSpend (implied) - Called within chooseAttack
linearConversion - Resource balancing calculation
Called by: Server initialization system (spawned as persistent script)
Modifies global variables:
A3A_activePlayerCount - Player count for balancing
A3A_balancePlayerScale - Dynamic difficulty scale
A3A_balanceVehicleCost - Vehicle cost baseline
A3A_balanceResourceRate - Base resource generation rate
difficultyCoef - Simplified difficulty indicator
aggressionStackOccupants - Occupant aggression stack (decay)
aggressionStackInvaders - Invader aggression stack (decay)
A3A_recentDamageOcc - Damage event cleanup
A3A_recentDamageInv - Damage event cleanup
A3A_resourcesDefenceOcc/Inv - Defense resources
A3A_resourcesAttackOcc/Inv - Attack resources
bigAttackInProgress - Attack state flag
Synchronization implications:
Server-authoritative calculations
Public variables broadcast to clients for UI updates
Attack triggers are server-side only
Resource modifications are server-side only
System fit: Core economy loop. The entire enemy AI behavior depends on these calculations. The loop balances:
Player count vs enemy strength
Aggression vs resource generation
Defense vs attack focus
Airport availability penalties
War progression scaling

Function Name: fn_airspaceControl.sqf
What it does:
This function handles airspace control for any player aircraft. It monitors aircraft position relative to enemy territory (airports, milbases, outposts) and breaks undercover status when aircraft enter restricted airspace. It also triggers support calls when non-undercover aircraft are detected by enemy positions. The function runs continuously in a loop for the lifetime of the aircraft until it's destroyed or crewed by players.

How it does that:
1. Initial Setup and Parameter Validation
Sqf

Apply
params ["_vehicle"];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

//If vehicle already has an airspace control script, exit here
if(_vehicle getVariable ["airspaceControl", false]) exitWith {};
_vehicle setVariable ["airspaceControl", true, true];
The function accepts a vehicle object as a parameter. It checks if the vehicle already has an airspace control script running (via the airspaceControl variable). If so, it exits to prevent duplicate scripts. Otherwise, it sets the airspaceControl flag to true globally.

2. Aircraft Type Classification
Sqf

Apply
private _airType = -1;
if(_vehicle isKindOf "Helicopter") then
{
    if((typeOf _vehicle) in (FactionGet(reb,"vehiclesCivHeli"))) then
    {
        _airType = CIV_HELI;
    }
    else
    {
        _airType = MIL_HELI;
    };
}
else
{
    _airType = JET;
};
The function classifies the aircraft into one of three types:

CIV_HELI (0): Civilian helicopters (from rebel faction's vehiclesCivHeli array)
MIL_HELI (1): Military helicopters
JET (2): Fixed-wing aircraft (any aircraft not a helicopter)
This classification determines detection ranges and thresholds.

3. Detection Range Configuration
Sqf

Apply
//Select height and range for outposts
private _outpostDetectionRange = [300, 500, 750] select _airType;
private _outpostDetectionHeight = [150, 250, 500] select _airType;

//Select height and range for milbases
private _milbaseDetectionRange = [450, 600, 1000] select _airType;
private _milbaseDetectionHeight = [350, 350, 1500] select _airType;

//Select height and range for airports
private _airportDetectionRange = [500, 750, 1500] select _airType;
private _airportDetectionHeight = [500, 500, 2500] select _airType;

//Warning thresholds (static for all aircraft types)
private _outpostWarningRange = 500;
private _outpostWarningHeight = 250;

private _milbaseWarningRange = 600;
private _milbaseWarningHeight = 350;

private _airportWarningRange = 750;
private _airportWarningHeight = 750;
Detection ranges are set based on aircraft type:

CIV_HELIs have the shortest detection ranges (300m ground, 150m height)
MIL_HELIs have medium ranges (500m ground, 250m height)
JETs have the longest ranges (750m ground, 500m height)
Warning ranges are static and provide a buffer before detection.

4. Variable Initialization
Sqf

Apply
private _inWarningRangeOutpost = [];
private _inWarningRangeMilbase = [];
private _inWarningRangeAirport = [];
private _inDetectionRangeOutpost = []; 
private _inDetectionRangeAirport = [];
private _inDetectionRangeMilbase = [];
private _vehicleIsUndercover = false;
private _supportCallAt = -1;
private _vehPos = [];
These arrays track which specific markers the aircraft is currently in (warning or detection ranges). This prevents spamming repeated warnings for the same marker.

5. Support Call Function Definition
Sqf

Apply
private _fn_sendSupport =
{
    params ["_vehicle", "_marker", "_threat"];
    private _markerSide = sidesX getVariable [_marker, sideUnknown];

    ServerDebug_2("Vehicle %1 violated airspace of marker %2", typeof _vehicle, _marker);

    // Add threat to vehicle on server side. Hopefully faster than the requestSupport call
    [_markerSide, false, _threat, _vehicle] remoteExecCall ["A3A_fnc_addRecentDamage", 2];

    // Let support system decide whether it's worth reacting to
    private _revealValue = [getMarkerPos _marker, _markerSide] call A3A_fnc_calculateSupportCallReveal;
    [_markerSide, _vehicle, markerPos _marker, 4, _revealValue] remoteExec ["A3A_fnc_requestSupport", 2];

    _supportCallAt = time + 30;
};
This closure function triggers when aircraft violate airspace:

Gets the marker's side
Logs the violation
Adds threat to the vehicle via addRecentDamage (executed on server 2)
Calculates reveal value based on marker position and side
Requests support via requestSupport (executed on server 2)
Sets a 30-second cooldown before another support can be called
6. No-Fly Zone Check Function
Sqf

Apply
private _fn_checkNoFlyZone =
{
    params ["_vehicle", "_vehPos", "_markerPos", "_detectionRange", "_detectionHeight"];

    private _heightDiff = (_vehPos select 2) - (_markerPos select 2);
    if(_heightDiff < _detectionHeight && {_markerPos distance2D _vehPos < _detectionRange}) exitWith
    {
        //Too close to marker, break undercover
        _vehicle setVariable ["NoFlyZoneDetected", _x, true];
        _vehicleIsUndercover = false;
        true;
    };
    false;
};
This closure checks if aircraft is within detection thresholds:

Calculates height difference between aircraft and marker
Checks if height is below detection threshold AND distance is within detection range
If both conditions met, marks vehicle with "NoFlyZoneDetected" variable and breaks undercover status
Returns true if detected, false otherwise
7. Marker Retrieval Function
Sqf

Apply
private _fn_getMarkersInRange =
{
    params ["_markers", "_vehPos", "_range", "_height"];

    private _inRange = _markers select
    {
        private _markerPos = AGLToASL (getMarkerPos _x);
        private _heightDiff = (_vehPos select 2) - (_markerPos select 2);
        _heightDiff < _height &&
        {_markerPos distance2D _vehPos < _range}
    };

    _inRange;
};
This closure filters markers based on position and thresholds:

Converts marker positions to ASL (Above Sea Level)
Calculates height difference from aircraft
Selects markers where height < threshold AND distance < range
Returns array of matching markers
8. Main Monitoring Loop
Sqf

Apply
while {!(isNull _vehicle) && {alive _vehicle && {count (crew _vehicle) != 0}}} do
{
    // Loop continues while vehicle exists, is alive, and has crew
The loop runs continuously until:

Vehicle is null (destroyed or deleted)
Vehicle is dead
No crew members remain
9. Support Call Cooldown Check
Sqf

Apply
    // If we already made a call, wait until the timeout
    if (time < _supportCallAt) then { continue };
If a support call was made within the last 30 seconds, skip to next iteration to prevent spam.

10. Vehicle Position and Undercover Status
Sqf

Apply
    //Check undercover status
    _vehicleIsUndercover = captive ((crew _vehicle) select 0);
    _vehPos = getPosASL _vehicle;
Gets undercover status from first crew member (using captive command)
Gets vehicle position in ASL (Above Sea Level) coordinates
11. Enemy Marker Identification
Sqf

Apply
    //Get all enemy airports and outposts to not search that much options
    private _enemyAirports = airportsX select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
    private _enemyOutposts = (outposts + seaports) select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
    private _enemyMilbases = milbases select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
Filters marker arrays to only include enemy-controlled positions, reducing processing overhead.

12. Undercover Aircraft Logic
Sqf

Apply
    if(_vehicleIsUndercover && {_vehicle getVariable ["NoFlyZoneDetected", ""] == ""}) then
    {
        //Warnings will be issued before undercover is broken
Only processes warning logic if aircraft is still undercover and hasn't triggered a no-fly zone detection yet.

13. Warning Range Detection
Sqf

Apply
        private _airportsInWarningRange = [_enemyAirports, _vehPos, _airportWarningRange, _airportWarningHeight] call _fn_getMarkersInRange;

        //NewAirport will contain all airports of which the warning zone has just been entered
        private _newAirports = _airportsInWarningRange - _inWarningRangeAirport;
        _inWarningRangeAirport = _airportsInWarningRange;
Gets airports within warning range (750m, 750m height)
Calculates new airports by subtracting previously tracked airports
Updates the tracking array
Same logic applied to outposts and milbases with their respective warning thresholds.

14. Warning Message Delivery
Sqf

Apply
        {
            //Assuming you only get a single one each second, need to split it otherwise
            private _warningText = format [localize "STR_A3A_base_airspace_control_warning", [_x] call A3A_fnc_localizar];
            [localize "STR_info_bar_undercover_break_title", _warningText] remoteExec ["A3A_fnc_customHint", (crew _vehicle)];
        } forEach (_newAirports + _newOutposts + _newMilbases);
For each newly entered warning zone, sends a localized warning hint to all crew members.

15. Detection Range Check for Warning Areas
Sqf

Apply
        //Check if the aircraft got to close to any airport in which warning zone it already is
        {
            if([_vehicle, _vehPos, AGLToASL (getMarkerPos _x), _airportDetectionRange, _airportDetectionHeight] call _fn_checkNoFlyZone) exitWith
            {
                _vehicleIsUndercover = false;
            };
        } forEach _inWarningRangeAirport;
For airports already in warning zone, checks if aircraft has moved into detection range. If so, breaks undercover status.

Same logic for outposts and milbases (with exit to prevent multiple calls).

16. Non-Undercover Aircraft Logic (Hostile Aircraft)
Sqf

Apply
    else
    {
        //Vehicles will be attacked instantly once detected

        //Check for nearby airports
        private _airportsInRange = [_enemyAirports, _vehPos, _airportDetectionRange, _airportDetectionHeight] call _fn_getMarkersInRange;
        private _milbasesInRange = [_enemyMilbases, _vehPos, _milbaseDetectionRange, _milbaseDetectionHeight] call _fn_getMarkersInRange;
For non-undercover aircraft, immediately checks for detection without warnings.

17. New Detection and Support Triggering
Sqf

Apply
        //newAirports will contain all airports which just detected the aircraft
        private _newAirports = _airportsInRange - _inDetectionRangeAirport;
        _inDetectionRangeAirport = _airportsInRange;

        private _newMilbases = _milbasesInRange - _inDetectionRangeMilbase;
        _inDetectionRangeMilbase = _milbasesInRange;

        switch (true) do {
            case (count _newAirports > 0): {
                //Vehicle detected by another airport (or multiple, lucky in that case)
                [_vehicle, _airportsInRange select 0, 30] call _fn_sendSupport;
                continue;
            };
Calculates newly detected markers
Uses switch statement to prioritize airports over milbases over outposts
Calls _fn_sendSupport with threat level 30 for airports
Uses continue to skip to next loop iteration
18. Milbase Detection
Sqf

Apply
            case (count _newMilbases > 0): {
                //Vehicle detected by another milbase (or multiple, lucky in that case)
                [_vehicle, _milbasesInRange select 0, 30] call _fn_sendSupport;
                continue;
            };
Similar to airport detection but with threat level 30.

19. Outpost Detection (Lower Priority)
Sqf

Apply
            default {
                //No airport near, to save performance we only check outpost if they would be able to send support
                if(time > _supportCallAt) then
                {
                    //Check for nearby outposts
                    private _outpostsInRange = [_enemyOutposts, _vehPos, _outpostDetectionRange, _outpostDetectionHeight] call _fn_getMarkersInRange;

                    private _newOutposts = _outpostsInRange - _inDetectionRangeOutpost;
                    _inDetectionRangeOutpost = _outpostsInRange;

                    if(count _newOutposts > 0) then
                    {
                        //Vehicle detected by another outpost, call support if possible
                        [_vehicle, _outpostsInRange select 0, 10] call _fn_sendSupport;
                        continue;
                    };
                };
            };
Outposts are only checked if:

No airports or milbases were newly detected
Support call cooldown has expired
Threat level is lower (10 vs 30)
20. Loop Control
Sqf

Apply
    sleep 1;
};
Loop sleeps for 1 second between iterations to prevent excessive CPU usage.

21. Cleanup
Sqf

Apply
_vehicle setVariable ["airspaceControl", nil, true];
When loop exits (vehicle destroyed or uncrewed), removes the airspace control flag.

Where it leads:
Functions Called:
A3A_fnc_localizar (line 136): Localizes marker names for warning messages
A3A_fnc_calculateSupportCallReveal (line 43): Determines how much enemy knows about vehicle position
A3A_fnc_addRecentDamage (line 40): Adds threat to vehicle for support calculations
A3A_fnc_requestSupport (line 44): Triggers enemy support response
Global Variables Modified:
airspaceControl (vehicle variable): Set to true when script starts, nil when ends
NoFlyZoneDetected (vehicle variable): Set when undercover aircraft violates no-fly zone
Synchronization/Network Implications:
Uses remoteExecCall for addRecentDamage on server 2 (persistent server execution)
Uses remoteExec for requestSupport on server 2 (server-side support system)
Uses remoteExec for warning hints to crew members (local to vehicle crew)
System Integration:
Part of the Undercover System: Breaks undercover when aircraft enter restricted airspace
Part of Support System: Triggers enemy support responses
Part of Air Combat System: Monitors air unit positioning
Runs in Scheduled Environment (while loop with sleep)
Edge Cases Handled:
Duplicate script execution prevented by airspaceControl flag
Support call spam prevented by 30-second cooldown
Null vehicle checks prevent script errors
Dead/empty crew checks prevent unnecessary processing
ASL position coordinates ensure accurate height calculations
Separate tracking arrays prevent repeated warnings for same markers

Function Name: fn_arePositionsConnected.sqf
What it does:
Determines if two positions (or markers) are connected by roads. It converts positions to navigation nodes and checks connectivity using A* pathfinding or similar algorithm. This is used for convoy routes, reinforcement paths, and logistics calculations.

How it does that:
1. Parameter Validation
Sqf

Apply
params
[
    ["_pos1", [0,0,0], ["", []]],
    ["_pos2", [0,0,0], ["", []]]
];
Accepts either marker names (strings) or position arrays (arrays of 3 numbers). Default values are [0,0,0] if not provided.

2. Node Conversion
Sqf

Apply
private _node1 = if (_pos1 isEqualType "") then {[_pos1] call A3A_fnc_getMarkerNavPoint} else {[_pos1] call A3A_fnc_getNearestNavPoint};
private _node2 = if (_pos2 isEqualType "") then {[_pos2] call A3A_fnc_getMarkerNavPoint} else {[_pos2] call A3A_fnc_getNearestNavPoint};
If _pos1 is a string (marker), gets the associated navigation point using A3A_fnc_getMarkerNavPoint
If _pos1 is an array (position), finds the nearest navigation point using A3A_fnc_getNearestNavPoint
Same logic for _pos2
3. Connectivity Check
Sqf

Apply
private _result = [_node1, _node2] call A3A_fnc_areNodesConnected;
_result;
Calls the core connectivity check between the two navigation nodes and returns the boolean result.

Where it leads:
Functions Called:
A3A_fnc_getMarkerNavPoint: Converts a marker name to its navigation node
A3A_fnc_getNearestNavPoint: Finds the closest navigation node to a position
A3A_fnc_areNodesConnected: Core pathfinding algorithm to check if two nodes are connected by roads
Global Variables Modified:
None - this is a pure query function with no side effects.

System Integration:
Part of Pathfinding System: Used for convoy and reinforcement routing
Part of Logistics System: Validates road connections for supply routes
Part of Mission System: Checks accessibility for mission locations
Deterministic: Same inputs always produce same output
Edge Cases:
Input type validation (string vs array)
Default position [0,0,0] if parameters missing
Navigation nodes may not exist for remote positions (handled by getNearestNavPoint)
Function Name: fn_blackout.sqf
What it does:
Creates or removes blackout effect at a marker by damaging/lights on or off within a specified radius. Used for mission effects, representing power outages or darkness effects.

How it does that:
1. Parameter Extraction
Sqf

Apply
params ["_markerX", "_onoff", ["_overrideRadius", nil]];
_markerX: Marker to affect
_onoff: Boolean - true for lights on, false for lights off (blackout)
_overrideRadius: Optional radius override
2. Position and Damage Calculation
Sqf

Apply
private _positionX = getMarkerPos _markerX;
private _damage = 0;
if (not _onoff) then {_damage = 0.95;};

private _radiusX = nil;
private _size = nil;

if (!isNil "_overrideRadius") then { 
    _radiusX =_overrideRadius;
    _size = _overrideRadius;
} else { 
    _radiusX = markerSize _markerX;
    _size = _radiusX select 0;
};
Gets marker position
Sets damage to 0.95 (nearly destroyed) for blackout, 0 for lights on
Uses override radius if provided, otherwise uses marker size (x-dimension)
3. Light Object Processing
Sqf

Apply
for "_i" from 0 to ((count A3A_lampTypes) -1) do {
    private _lamps = _positionX nearObjects [A3A_lampTypes select _i,_size];
    {
        sleep 0.3; 
        _x setDamage _damage
    } forEach _lamps;
};
Iterates through all lamp types in A3A_lampTypes array
Finds all lamps of that type within radius
Sets damage on each lamp (0.95 for blackout, 0 for repair)
Sleeps 0.3 seconds between each lamp to prevent performance spikes
Where it leads:
Functions Called:
None directly, but uses global array A3A_lampTypes.

Global Variables Modified:
Lamp objects: Their damage state is modified
Network Implications:
Damage changes are local to machine executing function
To broadcast to all clients, would need remoteExec wrapper
System Integration:
Part of Visual Effects System: Creates darkness/blackout visual
Part of Mission System: Used in missions requiring power loss
Used in Rebuild Systems: Can restore lights after rebuilding
Edge Cases:
A3A_lampTypes must be populated with lamp classnames
Large areas may cause performance issues (mitigated by sleep)
Lamp objects may not exist in some locations
Function Name: fn_buildHQ.sqf
What it does:
Initializes Petros (HQ commander) and HQ objects after game start or HQ relocation. Sets up Petros's group, behavior, animations, and ensures he's properly owned by the server.

How it does that:
1. Petros Group Management
Sqf

Apply
if (petros != (leader group petros)) then
{
    private _groupPetros = createGroup teamPlayer;
    [petros] join _groupPetros;
    _groupPetros selectLeader petros;
};
Checks if Petros is the leader of his group
If not, creates a new group for rebels and moves Petros into it
Sets Petros as the group leader
2. Petros Behavior Setup
Sqf

Apply
petros switchAction "PlayerStand";
petros disableAI "MOVE";
petros disableAI "AUTOTARGET";
petros setBehaviour "SAFE";
Forces Petros into standing animation
Disables movement and target acquisition
Sets behavior to SAFE (non-combat)
3. Server Ownership
Sqf

Apply
[group petros, 2] remoteExec ["setGroupOwner", 2];
Transfers group ownership to server (machine ID 2) to prevent desync issues when players disconnect.

4. HQ Object Relocation
Sqf

Apply
[getPos petros, false] remoteExec ["A3A_fnc_relocateHQObjects", 2];
Relocates HQ objects (boxX, mapX, flagX, vehicleBox) to Petros's position on the server.

5. Event Trigger
Sqf

Apply
sleep 5;
["HQPlaced", [getPos petros]] call EFUNC(Events,triggerEvent);
Waits 5 seconds then triggers "HQPlaced" event system with Petros's position.

Where it leads:
Functions Called:
A3A_fnc_relocateHQObjects: Moves HQ physical objects to new position
EFUNC(Events,triggerEvent): Triggers event system
Global Variables Modified:
Petros: Position, behavior, AI capabilities
Group ownership
HQ objects: Position
Network Implications:
Uses remoteExec to transfer group ownership to server
Uses remoteExec to relocate HQ objects on server
Event system broadcasts to all clients
System Integration:
Part of HQ Management System: Sets up HQ after relocation
Part of Petros System: Initializes commander entity
Called during Mission Start and HQ Move operations
Edge Cases:
Petros must exist as an object
Server must be available for ownership transfer
Event system must be initialized
Function Name: fn_calculateAggression.sqf
What it does:
Calculates current aggression values and levels for both Occupants and Invaders based on aggression stacks. Updates global aggression variables and triggers notifications when levels change.

How it does that:
1. Parameter Extraction
Sqf

Apply
params [["_silent", false]];
_silent parameter controls whether notifications are shown (used during mission load).

2. Calculate New Values from Stacks
Sqf

Apply
private _newOccupantsValue = 0;
{
    _newOccupantsValue = _newOccupantsValue + (_x select 0);
} forEach aggressionStackOccupants;

private _newInvadersValue = 0;
{
    _newInvadersValue = _newInvadersValue + (_x select 0);
} forEach aggressionStackInvaders;
Sums all values from the aggression stacks (arrays of [value, duration] pairs).

3. Value Clamping
Sqf

Apply
_newOccupantsValue = round ((_newOccupantsValue min 100) max 0);
_newInvadersValue = round ((_newInvadersValue min 100) max 0);
Ensures values stay within 0-100 range and are rounded to integers.

4. Update Global Variables
Sqf

Apply
aggressionOccupants = _newOccupantsValue;
aggressionInvaders = _newInvadersValue;
publicVariable "aggressionOccupants";
publicVariable "aggressionInvaders";
Updates and broadcasts aggression values to all clients.

5. Calculate Level Bounds
Sqf

Apply
private _levelBoundsOccupants = [((aggressionLevelOccupants - 1) * 20) - 2.5, aggressionLevelOccupants * 20 + 2.5];
private _levelBoundsInvaders = [((aggressionLevelInvaders - 1) * 20) - 2.5, aggressionLevelInvaders * 20 + 2.5];
Calculates threshold ranges for current levels (each level is 20 points wide with 2.5-point buffer).

6. Level Change Detection
Sqf

Apply
if(_newOccupantsValue < (_levelBoundsOccupants select 0)) then
{
    aggressionLevelOccupants = ((ceil (_newOccupantsValue / 20)) min 5) max 1;
    publicVariable "aggressionLevelOccupants";
    _notificationText = format [localize "STR_comms_calc_aggr_reduced_occ", FactionGet(occ,"name"), [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString];
    _levelsChanged = true;
}
else
{
    if(_newOccupantsValue > (_levelBoundsOccupants select 1)) then
    {
        aggressionLevelOccupants = ((ceil (_newOccupantsValue / 20)) min 5) max 1;
        publicVariable "aggressionLevelOccupants";
        _notificationText = format [localize "STR_comms_calc_aggr_increased_occ", FactionGet(occ,"name"), [aggressionLevelOccupants] call A3A_fnc_getAggroLevelString];
        _levelsChanged = true;
    };
};
Checks if new value is below lower bound (level decreased)
Checks if new value is above upper bound (level increased)
Calculates new level: ceil(value/20), clamped to 1-5
Creates notification text and flags that level changed
Same logic for Invaders.

7. Notification and HUD Update
Sqf

Apply
if(_levelsChanged) then
{
    //Updating HUDs of players
    [] remoteExec ["A3A_fnc_statistics", [teamPlayer, civilian]];
    if(!_silent) then
    {
        //If not load progress, show message for everyone
        _notificationText = format [localize "STR_comms_calc_aggr_changed", _notificationText];
        [petros, "income", _notificationText] remoteExec ["A3A_fnc_commsMP", [teamPlayer, civilian]];
    };
};
Updates statistics HUD for all players
Sends notification to all teamPlayer and civilian clients if not silent
Where it leads:
Functions Called:
A3A_fnc_getAggroLevelString: Converts aggression level number to localized string
A3A_fnc_statistics: Updates HUD display
A3A_fnc_commsMP: Sends notification messages
Global Variables Modified:
aggressionOccupants: Updated value
aggressionInvaders: Updated value
aggressionLevelOccupants: Updated level
aggressionLevelInvaders: Updated level
All broadcast to all clients
Network Implications:
Uses publicVariable to broadcast aggression values
Uses remoteExec to update HUD on all clients
Uses remoteExec to send notifications
System Integration:
Part of Aggression System: Tracks enemy force aggression
Part of War Level System: Aggression affects war tier
Part of Difficulty System: Higher aggression = tougher enemies
Called regularly by aggressionUpdateLoop
Edge Cases:
Values clamped to 0-100 range
Levels clamped to 1-5 range
Silent mode for loading saves
Level bounds include buffer zones
Function Name: fn_canMoveHQ.sqf
What it does:
Checks if the commander can move the HQ. Validates that the player is the commander, arsenal is empty, and Petros isn't being carried.

How it does that:
1. Parameter and Initial Checks
Sqf

Apply
private _result = [false];
if (player != theBoss) then
{
    [localize "STR_antistasi_journal_entry_header_commander_5", localize "STR_generic_commander_only"] call A3A_fnc_customHint;
    _result pushBack (localize "STR_A3A_Base_canMoveHq_only_comm");
};
Initializes result array with false (first element indicates success)
Checks if player is theBoss (commander)
If not, sends hint and adds error message to result
2. Arsenal Check
Sqf

Apply
if ((count weaponCargo boxX >0) or (count magazineCargo boxX >0) or (count itemCargo boxX >0) or (count backpackCargo boxX >0)) then
{
    if(count _result == 1) then
    {
        [localize "STR_antistasi_journal_entry_header_commander_5", localize "STR_A3A_Base_canMoveHq_arsenal_empty"] call A3A_fnc_customHint;
    };
    _result pushBack (localize "STR_A3A_Base_canMoveHq_arsenal_empty_2");
};
Checks if arsenal box (boxX) has any items. If so, adds error to result.

3. Petros Carrying Check
Sqf

Apply
if !(isNull attachedTo petros) then
{
    if(count _result == 1) then
    {
        [localize "STR_antistasi_journal_entry_header_commander_5", localize "STR_A3A_Base_canMoveHq_arsenal_petros_picked"] call A3A_fnc_customHint;
    };
    _result pushBack (localize "STR_A3A_Base_canMoveHq_arsenal_petros_picked_2");
};
Checks if Petros has something attached to him (being carried). If so, adds error.

4. Return Result
Sqf

Apply
if(count _result != 1) exitWith {
    _result;
};

[true, ""];
If errors found (array size > 1), return error array. Otherwise, return success array.

Where it leads:
Functions Called:
A3A_fnc_customHint: Displays error messages
Global Variables Modified:
None - this is a validation function with no side effects.

System Integration:
Part of HQ Management System: Validates HQ movement conditions
Called before A3A_fnc_moveHQ
Edge Cases:
Result array uses first element as success flag
Multiple errors accumulate in array
Silent validation possible by checking first element
Function Name: fn_checkLossCondition.sqf
What it does:
Checks if any loss conditions are met and ends the mission if so. Supports multiple loss conditions: population death, HR loss, financial loss, or hardcore mode.

How it does that:
1. Data Gathering
Sqf

Apply
private _factionMoney = server getVariable ["resourcesFIA",0];
private _hr = server getVariable ["hr",0];
private _victoryZones = airportsX + milbases + outposts + resourcesX + factories + seaports;
private _victoryZonesLogistical = airportsX + milbases + seaports;
private _popTotal = 0;
private _popKilled = 0;
private _missingMoney = ((2000000 - _factionMoney) call BIS_fnc_numberText) splitString " " joinString ",";
private _popReb = 0;
private _popGov = 0;
private _popMajority = 0;
Gets faction resources, calculates total population, tracks killed population.

2. Population Calculation Loop
Sqf

Apply
{
    private _city = _x;
    private _cityData = server getVariable _city;
    _cityData params ["_numCiv", "_numVeh", "_supportGov", "_supportReb"];

    _popTotal = _popTotal + _numCiv;
    if (_city in destroyedSites) then { _popKilled = _popKilled + _numCiv; continue };

    _popReb = _popReb + (_numCiv * (_supportReb / 100));
    _popGov = _popGov + (_numCiv * (_supportGov / 100));
} forEach citiesX;
Iterates through all cities, accumulating:

Total civilian population
Killed population from destroyed cities
Rebel support population (pop * support%)
Government support population
3. Loss Condition Switch
Sqf

Apply
switch (lossCondition) do
{
    //3rd of the pop dead
    case 0:
    {
        if (_popKilled > (_popTotal / 3)) then
        {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["destroyedSites",false,true] remoteExec ["BIS_fnc_endMission"];
        };
    };

    //no HR left ()
    case 1:
    {
        private _tierWarHRloss = missionNamespace getVariable ["A3U_setting_tierWarHRLoss",3];
        if (_hr <= 0 && {(tierWar >= _tierWarHRloss)}) then 
        {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["HRLoss",false,true] remoteExec ["BIS_fnc_endMission"];
        };
    };

    //faction has no money left
    case 2:
    {
        if (_factionMoney <= 0) then
        {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["financialLoss",false,true] remoteExec ["BIS_fnc_endMission"];
        };
    };

    //hardcore (all loss conditions in one)
    case 3:
    {
        if ((_factionMoney <= 0) || {_hr <= 0} || {_popKilled > (_popTotal / 3)}) then
        {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["hardcoreLoss",false,true] remoteExec ["BIS_fnc_endMission"];
        };
    };

    default {Error_1("Loss condition was not recognized. Condition given: %1", lossCondition)};
};
Four loss conditions:

Case 0: >1/3 population killed
Case 1: HR <= 0 and war tier >= threshold
Case 2: Faction money <= 0
Case 3: Any of the above (hardcore)
If condition met:

Sets "ended" flag in save variable
Ends mission with specific ending
Where it leads:
Functions Called:
A3A_fnc_writebackSaveVar: Marks mission as ended in save data
BIS_fnc_endMission: Ends the mission for all players
Global Variables Modified:
Server "ended" flag (in save variable)
Network Implications:
Uses remoteExec to trigger mission end on all clients
isNil wrapper prevents race conditions
System Integration:
Part of Mission End System: Checks for defeat conditions
Part of Difficulty System: Hardcore mode has stricter conditions
Called by resourceCheck loop
Edge Cases:
Settings: A3U_setting_tierWarHRLoss controls when HR loss applies
Save data marked as "ended" to prevent continuation
Different endings for different loss types
Function Name: fn_checkWinCondition.sqf
What it does:
Checks if any victory conditions are met and ends the mission if so. Supports multiple victory conditions: normal, total, economic, logistical, and political victory.

How it does that:
1. Data Gathering
Sqf

Apply
private _factionMoney = server getVariable ["resourcesFIA",0];
private _hr = server getVariable ["hr",0];
private _victoryZones = airportsX + milbases + outposts + resourcesX + factories + seaports;
private _victoryZonesLogistical = airportsX + milbases + seaports;
private _popTotal = 0;
private _popKilled = 0;
private _popReb = 0;
private _popGov = 0;
private _popMajority = 0;
private _resourcesCount = count (resourcesX);
private _economicCalculation = (_resourcesCount * 100000);
private _missingMoney = ((_economicCalculation - _factionMoney) call BIS_fnc_numberText) splitString " " joinString ",";
Similar to loss conditions but adds economic calculation (resources * 100,000).

2. Population Calculation (Same as Loss)
Iterates through cities calculating totals, killed, and support populations.

3. Count Controlled Zones
Sqf

Apply
private _resourcesTotal = count (resourcesX);
private _resourcesOwned = ({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (resourcesX));

private _factoriesTotal = count (factories);
private _factoriesOwned = ({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (factories));

// ... similar for outposts, seaports, milbases, airports
Counts total and rebel-controlled zones for each type.

4. Victory Condition Switch
Sqf

Apply
switch (victoryCondition) do
{
    //Normal Victory
    case 0:
    {
        if ((_popReb > _popGov) && {({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (airportsX + milbases)) isEqualTo count (airportsX + milbases)}) then {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["End1",true,true,true,true] remoteExec ["BIS_fnc_endMission"];
        } else {
            isNil { [format [localize "STR_A3AU_victory_condition_check" + localize "STR_A3AU_victory_type_normal"],format [localize "STR_A3AU_victory_condition_not_met" + localize "STR_A3AU_victory_condition_normal_victory_info", (round _popReb),(round _popGov),_milbasesOwned,_milbasesTotal,_airportsOwned,_airportsTotal], true] call A3A_fnc_customHint };
        };
    };

    //Total Victory
    case 1:
    {
        if ((_popReb > _popGov) && {({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (_victoryZones)) isEqualTo count (_victoryZones)}) then {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["totalVictory",true,true,true,true] remoteExec ["BIS_fnc_endMission"];
        } else {
            isNil { [format [localize "STR_A3AU_victory_condition_check" + localize "STR_A3AU_victory_type_total"],format [localize "STR_A3AU_victory_condition_not_met" + localize "STR_A3AU_victory_condition_total_victory_info", (round _popReb),(round _popGov),_resourcesOwned,_resourcesTotal,_factoriesOwned,_factoriesTotal,_outpostsOwned,_outpostsTotal,_seaportsOwned,_seaportsTotal,_milbasesOwned,_milbasesTotal,_airportsOwned,_airportsTotal], true] call A3A_fnc_customHint };
        };
    };

    //Economic Victory
    case 2:
    {
        if (_factionMoney >= _economicCalculation) then {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["economicVictory",true,true,true,true] remoteExec ["BIS_fnc_endMission"];
        } else {
            isNil { [format [localize "STR_A3AU_victory_condition_check" + localize "STR_A3AU_victory_type_economic"],format [localize "STR_A3AU_victory_condition_not_met" + localize "STR_A3AU_victory_condition_missing_money", _missingMoney, A3A_faction_civ get "currencySymbol"], true] call A3A_fnc_customHint };
        };
    };

    //Logistical Victory
    case 3:
    {
        if (({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (_victoryZonesLogistical) ) isEqualTo count (_victoryZonesLogistical)) then {
            isNil { ["ended", true] call A3A_fnc_writebackSaveVar };
            ["logisticalVictory",true,true,true,true] remoteExec ["BIS_fnc_endMission"];
        } else {
            isNil { [format [localize "STR_A3AU_victory_condition_check" + localize "STR_A3AU_victory_type_logistical"],format [localize "STR_A3AU_victory_condition_not_met" + localize "STR_A3AU_victory_condition_logistical_victory_info",_seaportsOwned,_seaportsTotal,_milbasesOwned,_milbasesTotal,_airportsOwned,_airportsTotal], true] call A3A_fnc_customHint };
        };
    };

    //Political Victory (Over 75% population Support)
    case 4:
    { 
        if (_popReb >= _popMajority) then {
            isNil {["ended", true] call A3A_fnc_writebackSaveVar};
            ["politicalVictory",true,true,true,true] remoteExec ["BIS_fnc_endMission"];
        } else {
            isNil { [format [localize "STR_A3AU_victory_condition_check" + localize "STR_A3AU_victory_type_political"],format [localize "STR_A3AU_victory_condition_not_met" + localize "STR_A3AU_victory_condition_missing_support",_popTotal,(round _popGov),(round _popReb)], true] call A3A_fnc_customHint };
        };
    };

    default {Error_1("Victory condition was not recognized. Condition given: %1", victoryCondition)};
};
Five victory conditions:

Normal (0): Rebel population > Gov population AND control all airports and milbases
Total (1): Rebel population > Gov population AND control all victory zones
Economic (2): Faction money >= (resources * 100,000)
Logistical (3): Control all airports, milbases, and seaports
Political (4): Rebel support >= 75% of total population
Where it leads:
Functions Called:
A3A_fnc_writebackSaveVar: Marks mission as ended
A3A_fnc_customHint: Shows progress/status messages
BIS_fnc_endMission: Ends mission for all players
Global Variables Modified:
Server "ended" flag
Network Implications:
Uses remoteExec to end mission on all clients
Shows hints to all players
System Integration:
Part of Victory System: Checks for win conditions
Part of Difficulty System: Different conditions for different victory types
Called by resourceCheck loop
Edge Cases:
Different victory conditions have different requirements
Political victory requires 75% population support
Economic victory scales with number of resource zones
Function Name: fn_chooseAttack.sqf
What it does:
Selects and launches an appropriate enemy attack against the player faction. Chooses target based on weighted selection considering distance, threat, and war tier.

How it does that:
1. Parameter Extraction and Target Finding
Sqf

Apply
params ["_side"];

Info_1("Starting attack choice script for side %1", _side);

// Make a weighted list of rebel attack targets
private _targetsAndWeights = [teamPlayer, _side] call A3A_fnc_findAttackTargets;
_targetsAndWeights params ["_targets", "_weights"];
Gets side (Occupants or Invaders) launching attack
Calls findAttackTargets to get potential targets with weights
Extracts targets array and weights array
2. HQ Proximity Weighting
Sqf

Apply
// Give targets within mission distance higher weight
// Returns total multiplier due to this adjustment
private _rebWeightMul = call {
    if (_targets isEqualTo []) exitWith {1};
    private _totalW = 0; private _distW = 0;
    private _hqPos = markerPos "Synd_HQ";
    {
        _totalW = _totalW + _x; 
        private _dist = markerPos (_targets#_forEachIndex#0) distance2d _hqPos;
        private _weightMul = linearConversion [3000, 8000, _dist, A3A_attackHQProximityMul, 1, true];
        _distW = _distW + _x * _weightMul;
        _weights set [_forEachIndex, _x * _weightMul];
    } forEach _weights;
    _distW / _totalW;
};
For each target:

Calculates distance from target to HQ
Uses linearConversion to create weight multiplier (closer = higher multiplier)
Updates weights array with multiplier
Returns total weight multiplier for normalization
3. Adding Enemy Targets (Multi-Faction Mode)
Sqf

Apply
if (gameMode == 1) then 
{
    private _enemySide = [Occupants, Invaders] select (_side == Occupants); 
    private _targetsAndWeightsEnemy = [_enemySide, _side] call A3A_fnc_findAttackTargets;
    if (_targetsAndWeightsEnemy#0 isEqualTo []) exitWith {};

    // Reduce chance of attacking rebels a bit at lower war tiers & aggro
    private _aggro = [aggressionOccupants, aggressionInvaders] select (_side == Invaders);
    private _weightFactor = (0.4 + tierWar/30 + _aggro/200) / _rebWeightMul;
    _weights = _weights apply { _x * _weightFactor };

    _targets append (_targetsAndWeightsEnemy#0);
    _weights append (_targetsAndWeightsEnemy#1);
};
In gameMode 1 (multi-faction):

Finds other enemy side (if Occupants, other is Invaders)
Gets their potential targets
Calculates weight factor: base 0.4 + tier/30 + aggro/200, divided by rebel weight multiplier
Applies factor to all weights
Appends enemy targets and weights to original arrays
4. Early Exit Checks
Sqf

Apply
if (_targets isEqualTo []) exitWith {
    Info_1("Aborting attack by %1 because no targets available", _side);
    false;
};

if ((areInvadersDefeated && _side == Invaders) || {(areOccupantsDefeated && _side == Occupants)}) exitWith {
    Info_1("Aborting attack by %1 because faction was defeated before.", _side);
    false;
};
Exits if:

No targets available
Faction was already defeated
5. Target Selection
Sqf

Apply
// Cull anything worse than 10:1 value ratio, otherwise we'll launch some really stupid attacks occasionally
private _arePunishmentsAllowed = ((enablePunishments isEqualTo 1) && (tierWar >= A3U_setting_tierWarPunishments));

Info("Logging available targets: Original, Culled");
InfoArray("Original Targets:", _targets);

private _minWeight = selectMax _weights / 10;
private _culledTargets = [];
{
    private _weight = _weights select _forEachIndex;
    if (_weight > _minWeight) then { _culledTargets append [_x, _weight] };
} forEach _targets;

InfoArray("Culled Targets:", _culledTargets);

// Now we just pick a target
private _target = selectRandomWeighted _culledTargets;
_target params ["_targetMrk", "_originMrk", "_targetValue", "_localThreat", "_flyoverThreat", "_countLandAttackBases"];
Calculates minimum weight (max weight / 10) to cull low-value targets
Builds new array with only targets above threshold
Selects random target weighted by remaining weights
Extracts target parameters
6. Target Validation
Sqf

Apply
if (sidesX getVariable _targetMrk == _side) exitWith {
    Info_1("Aborting attack because target (%1) already captured", _targetMrk);
    false;
};
if (sidesX getVariable _originMrk != _side) exitWith {
    // do we check spawner status too?
    Info_1("Aborting attack because origin (%1) changed sides", _originMrk);
    false;
};
Exits if:

Target already belongs to attacking side
Origin marker changed sides
7. Attack Type Selection
Sqf

Apply
private _resourcesAttackSide = [A3A_resourcesAttackOcc, A3A_resourcesAttackInv] select (_side isEqualTo Invaders);
private _resourcesDefenceSide = [A3A_resourcesDefenceOcc, A3A_resourcesDefenceInv] select (_side isEqualTo Invaders);

if (_targetMrk in citiesX) exitWith {
    Info_2("%1 was in citiesX. Side: %2.", _targetMrk, _side);
    if (_side isEqualTo Invaders && {_arePunishmentsAllowed}) then {
        // Punishment, unsimulated
        Info_2("Starting punishment mission from %1 to %2", _originMrk, _targetMrk);
        [-400, _side, "attack"] call A3A_fnc_addEnemyResources;
        bigAttackInProgress = true; publicVariable "bigAttackInProgress";
        [_targetMrk, _originMrk] spawn A3A_fnc_invaderPunish;
    } else {
        // Supply convoy, unsimulated
        Info_2("Sending supply convoy from %1 to %2", _originMrk, _targetMrk);
        [-200, _side, "attack"] call A3A_fnc_addEnemyResources;
        [[_targetMrk, _originMrk, "Supplies", "attack"],"A3A_fnc_convoy"] call A3A_fnc_scheduler;
    };
    Info_3("Resources for: %1. | Attack: %2 | Defence: %3 |", _side, _resourcesAttackSide, _resourcesDefenceSide);
    true;
};
For city targets:

If Invaders and punishments enabled: Spawn punishment mission (cost 400)
Otherwise: Spawn supply convoy (cost 200)
Sets bigAttackInProgress flag
Calls appropriate spawn function
8. HQ Attack
Sqf

Apply
if (_targetMrk == "Synd_HQ") exitWith {
    Info_2("Starting HQ attack from %1", _originMrk);
    [-400, _side, "attack"] call A3A_fnc_addEnemyResources;
    bigAttackInProgress = true; publicVariable "bigAttackInProgress";
    [_side, _originMrk] spawn A3A_fnc_attackHQ;
    true;
};
For HQ attack:

Cost 400 resources
Spawn HQ attack mission
9. Major Attack (Real or Simulated)
Sqf

Apply
if((spawner getVariable _targetMrk) != 2 || (sidesX getVariable _targetMrk) == teamPlayer) then
{
    // Sending real attack, execute the fight
    private _waves = round (1 + random 1 + _localThreat / 1000);         // TODO: magic number

    //no one actually likes multi-hour defense slog
    if(_waves > 3) then {
        _waves = 3;
    };

    Info_3("Starting waved attack with %1 waves from %2 to %3", _waves, _originMrk, _targetMrk);
    [-400, _side, "attack"] call A3A_fnc_addEnemyResources;
    bigAttackInProgress = true; publicVariable "bigAttackInProgress";
    [_targetMrk, _originMrk, _waves] spawn A3A_fnc_wavedAttack;
    true;
}
else
{
    // Get the available defence resources
    private _defSide = [Occupants, Invaders] select (_side == Occupants);
    private _defResources = [_defSide, _side, _targetMrk, 1] call A3A_fnc_maxDefenceSpend;

    // subtract that from defender and equal quantity for attacker
    [-_defResources, _defSide, "defence"] call A3A_fnc_addEnemyResources;

    // land units are a bit cheaper, attack is generally more expensive than defence
    private _atkResources = _defResources + _localThreat + _flyoverThreat;
    _atkResources = 400 + _atkResources * (0.75 + 2^(-_countLandAttackBases));
    [-_atkResources, _side, "attack"] call A3A_fnc_addEnemyResources;

    // Flip marker and add garrison once flipped
    [_side, _targetMrk] spawn A3A_fnc_markerChange;
    Info_4("Simulated capture of %1 by %2, atk resources %3, def resources %4", _targetMrk, _side, _atkResources, _defResources);

    sleep 10;
    if (sidesX getVariable _targetMrk != _side) exitWith {
        Error_2("%1 still not switched to side %2 after 10 seconds", _targetMrk, _side);
        false;
    };

    // Get the garrison for free because we already paid for them in the simulated attack
    private _maxTroops = 12 max round ((0.5 + random 0.5) * ([_targetMrk] call A3A_fnc_garrisonSize));
    private _soldiers = [];
    private _faction = Faction(_side);
    private _groups = (_faction get "groupsTierMedium") apply {[_x] call SCRT_fnc_unit_getTiered};
    private _squads = (_faction get "groupsTierSquads") apply {[_x] call SCRT_fnc_unit_getTiered};

    while {count _soldiers < _maxTroops} do {
        _soldiers append selectRandom (_groups + _squads);
    };
    _soldiers resize _maxTroops;
    [_soldiers, _side, _targetMrk, 0] spawn A3A_fnc_garrisonUpdate;
    true;
};
Two attack types:

Real Attack (if target is spawned or rebel-controlled):

Calculate waves (1-3 based on local threat)
Cost 400 resources
Spawn waved attack
Simulated Attack (if target despawned and enemy-controlled):

Calculate defender resources using maxDefenceSpend
Defender loses resources
Attacker spends: 400 + (defResources + threats) * (0.75 + 2^(-landBases))
Flip marker
Wait 10 seconds
If successful, spawn garrison with random troops (12-24 units)
Where it leads:
Functions Called:
A3A_fnc_findAttackTargets: Gets weighted target list
A3A_fnc_addEnemyResources: Deducts resources for attack
A3A_fnc_invaderPunish: Spawns punishment mission
A3A_fnc_convoy: Spawns supply convoy
A3A_fnc_attackHQ: Spawns HQ attack
A3A_fnc_wavedAttack: Spawns real attack with multiple waves
A3A_fnc_maxDefenceSpend: Calculates defender resource allocation
A3A_fnc_markerChange: Changes marker ownership
A3A_fnc_garrisonSize: Gets garrison size for marker
A3A_fnc_garrisonUpdate: Updates garrison with new troops
Global Variables Modified:
bigAttackInProgress: Set to true when attack starts
Marker ownership changes via sidesX
Network Implications:
publicVariable "bigAttackInProgress" broadcasts to all clients
Spawn functions execute on server/HC
System Integration:
Part of Enemy AI System: Manages enemy attacks
Part of War Level System: Attack difficulty scales with war tier
Part of Resource System: Attacks cost resources
Part of Multi-Faction System: Can coordinate between factions
Edge Cases:
10:1 weight culling prevents stupid attacks
Wave limit of 3 to prevent long defense slogs
Punishment missions only for Invaders with specific setting enabled
Simulated attacks require target to be despawned
I'll continue documenting the remaining functions. Due to the extensive length, I'll provide the next batch:

Function Name: fn_citiesToCivPatrol.sqf
What it does:
Returns an array of city markers within 3000 meters of a given marker, excluding the marker itself. Used to find nearby cities for civilian patrols or missions.

How it does that:
1. Parameter Extraction
Sqf

Apply
params ["_markerX"];
Accepts a marker name as input.

2. Position Calculation
Sqf

Apply
private _posMarker = getMarkerPos _markerX;
private _arrayCities = (citiesX select {getMarkerPos _x distance _posMarker < 3000}) - [_markerX];
Gets position of input marker
Filters citiesX array to only include cities within 3000 meters
Removes the input marker from the result (if it's a city)
3. Return Result
Sqf

Apply
_arrayCities
Returns the filtered array.

Where it leads:
Functions Called:
None directly.

Global Variables Modified:
None.

System Integration:
Part of Civilian Patrol System: Finds nearby cities for patrols
Part of Mission System: Locates mission locations
Used by A3A_fnc_patrolDestinations
Edge Cases:
Input marker might not be in citiesX array
Distance check uses direct position comparison
Function Name: fn_citySupportChange.sqf
What it does:
Modifies civilian support for a city (government or rebel). Handles scaling by population, radio propaganda limits, and prevents concurrent modifications.

How it does that:
1. Concurrency Control
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith {Error("Server-only function miscalled")};

waitUntil {!cityIsSupportChanging};
cityIsSupportChanging = true;
Ensures function runs only on server
Waits for lock release, then sets lock to prevent concurrent execution
2. Parameter Validation
Sqf

Apply
params [["_changeGov", ""], ["_changeReb", ""], ["_pos","",["",[]]], ["_scaled", true], ["_isRadio", false]];

if !(_changeGov isEqualType 0) exitWith {Error("Function was called incorrectly. First param must be a number.")};
if !(_changeReb isEqualType 0) exitWith {Error("Function was called incorrectly. Second param must be a number.")};
if (_pos isEqualTo "" || {_pos isEqualTo []}) exitWith {
    Error("Function was called incorrectly. Third param must be a city varname (STR) or coordinates (ARR).")
};
Validates that:

First two parameters are numbers
Third parameter is either a string (city name) or array (coordinates)
3. City Identification
Sqf

Apply
private _city = if (_pos isEqualType "") then {_pos} else {[citiesX, _pos] call BIS_fnc_nearestPosition};
private _cityData = server getVariable _city;
if (isNil "_cityData" || {!(_cityData isEqualType [])}) exitWith
{
    cityIsSupportChanging = false;
    Error_1("No data found for city %1", _city);
};
_cityData params ["_numCiv", "_numVeh", "_supportGov", "_supportReb"];
If position is string, use as city name
If position is array, find nearest city
Gets city data from server variable
Extracts population and support values
4. Radio Propaganda Limits
Sqf

Apply
if (_isRadio) then {
    if (_changeGov > 0) then { _changeGov = (30 - _supportGov) max 0 min _changeGov };
    if (_changeGov < 0) then { _changeGov = (50 - _supportGov) min 0 max _changeGov };

    if (_changeReb > 0) then { _changeReb = (30 - _supportReb) max 0 min _changeReb };
    if (_changeReb < 0) then { _changeReb = (50 - _supportReb) min 0 max _changeReb };
}
For radio propaganda:

Can't increase support above 30%
Can't decrease support below 50%
Limits applied based on current support level
5. Population Scaling
Sqf

Apply
else {
    // Most non-radio changes are scaled inversely by city population, so less effect on large towns
    if (_scaled) then {
        private _popScale = 200 / (_numCiv max 50);
        _changeGov = _changeGov * _popScale;
        _changeReb = _changeReb * _popScale;
    };
};
For non-radio changes:

Scales by population (200 / population)
Minimum population of 50 to prevent divide by zero
Larger cities have smaller support changes
6. Apply Changes and Clamp
Sqf

Apply
_supportGov = 0 max (_supportGov + _changeGov);
_supportReb = 0 max (_supportReb + _changeReb);

private _supportTotal = _supportGov + _supportReb;
if (_supportTotal > 100) then {
    _supportGov = _supportGov * (100 / _supportTotal);
    _supportReb = _supportReb * (100 / _supportTotal);
};
Adds changes to current support
Clamps to minimum 0
If total exceeds 100%, scales both down proportionally
7. Save and Cleanup
Sqf

Apply
_cityData = [_numCiv, _numVeh, _supportGov, _supportReb];

server setVariable [_city, _cityData, true];
cityIsSupportChanging = false;
true
Updates city data array
Saves to server variable with public broadcast
Releases lock
Returns true for success
Where it leads:
Functions Called:
BIS_fnc_nearestPosition: Finds closest city when position array given
Global Variables Modified:
cityIsSupportChanging: Lock variable
City data on server: Updated support values
Network Implications:
Uses publicVariable on city data (via setVariable with true parameter)
Lock variable not broadcast (local to server)
System Integration:
Part of Civilian Support System: Manages population loyalty
Used by Mission Rewards: Changes support from missions
Used by Radio Propaganda: Limited support changes
Edge Cases:
Radio propaganda has hard limits (30% max increase, 50% min decrease)
Population scaling prevents huge changes in large cities
Total support clamped to 100%
Concurrency lock prevents race conditions
Function Name: fn_commsMP.sqf
What it does:
Displays various types of messages/hints to players. Handles different message types: sideChat, hint, countdown, income, tier, support, announce, unlock.

How it does that:
1. Initial Checks
Sqf

Apply
if (!hasInterface) exitWith {};
if (isNil "teamPlayer") exitWith {};
if (!(side player in [teamPlayer,civilian])) exitWith {};
Only runs on:

Clients with interface (players)
After teamPlayer is defined
For players on teamPlayer or civilian side
2. Parameter Extraction
Sqf

Apply
params [["_unit", objNull], ["_typeX", ""], ["_textX", ""], ["_titleX", ""]];
_unit: Unit for sideChat (optional)
_typeX: Message type
_textX: Message text
_titleX: Title for hints
3. Type Switch
Sqf

Apply
switch (_typeX) do {
    case "sideChat": {
        _unit sideChat format ["%1", _textX];
    };
    case "hint": {
        [_titleX, format ["%1",_textX]] call A3A_fnc_customHint;
    };
    // ... more cases
};
4. Specific Type Handlers
hintS (Silent hint):

Sqf

Apply
case "hintS": {
    [_titleX, format ["%1",_textX], true] call A3A_fnc_customHint;
};
intelError:

Sqf

Apply
case "intelError": {
    [_titleX, format [localize "STR_A3A_Base_commsMp_download_error",_textX]] call A3A_fnc_customHint;
};
globalChat:

Sqf

Apply
case "globalChat": {
    _unit globalChat format ["%1", _textX];
};
countdown:

Sqf

Apply
case "countdown": {
    _textX = format [localize "STR_A3A_Base_commsMp_countdown_desc",_textX];
    [localize "STR_A3A_Base_commsMp_countdown_header", format ["%1",_textX]] call A3A_fnc_customHint;
};
income (Resource notification):

Sqf

Apply
case "income": {
    waitUntil {sleep 0.2; !incomeRep};
    private _layer = ["A3A_infoRight"] call BIS_fnc_rscLayer;
    incomeRep = true;
    playSound "A3AP_UiSuccess";
    [_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, _layer] spawn bis_fnc_dynamicText;
    incomeRep = false;
    [] spawn A3A_fnc_statistics;
};
Waits for incomeRep flag to be false
Sets flag to prevent concurrent displays
Shows dynamic text on screen
Resets flag and updates statistics
taxRep (Tax notification):

Sqf

Apply
case "taxRep": {
    private _layer = ["A3A_infoRight"] call BIS_fnc_rscLayer;
    incomeRep = true;
    playSound "A3AP_UiSuccess";
    [_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, _layer] spawn bis_fnc_dynamicText;
    sleep 10;
    incomeRep = false;
    [] spawn A3A_fnc_statistics;
};
Similar to income but with 10-second delay before resetting.

tier (War level change):

Sqf

Apply
case "tier": {
    waitUntil {sleep 0.2; !incomeRep};
    private _layer = ["A3A_infoRight"] call BIS_fnc_rscLayer;
    incomeRep = true;
    playSound "A3AP_UiSuccess";
    _textX = format ["War Level Changed<br/><br/>Current Level: %1",tierWar];
    [_textX, [safeZoneX + (0.8 * safeZoneW), (0.2 * safeZoneW)], 0.5, 5, 0, 0, _layer] spawn bis_fnc_dynamicText;
    incomeRep = false;
    [] spawn A3A_fnc_statistics;
};
support (Support point notification):

Sqf

Apply
case "support": {
    private _layer = ["A3A_infoDown"] call BIS_fnc_rscLayer;
    [_textX, [safeZoneX + (0.65 * safeZoneW), (0.2 * safeZoneW)], 0.65, 8, 0, 0, _layer] spawn BIS_fnc_dynamicText;
    playSound "A3AP_UiSuccess";
    [] spawn A3A_fnc_statistics;
};
announce (General announcement):

Sqf

Apply
case "announce": {
    private _layer = ["A3A_infoDown"] call BIS_fnc_rscLayer;
    [_textX, [safeZoneX + (0.65 * safeZoneW), (0.2 * safeZoneW)], 0.45, 8, 0, 0, _layer] spawn BIS_fnc_dynamicText;
    playSound "A3AP_UiSuccess";
};
unlock (Unlock notification):

Sqf

Apply
case "unlock": {
    private _layer = ["A3A_infoUnlock"] call BIS_fnc_rscLayer;
    switch (tierWar) do {
        case (3): {
            _textX = localize "STR_A3A_Base_commsMp_unlock_tier_general";
            if (player == theBoss) then {
                _textX = _textX + localize "STR_A3A_Base_commsMp_unlock_tier3_theBoss";
            };
        };
        // ... cases 4 and 5
    };

    if (!isSupportAnnounced) then {
        private _outposts = {sidesX getVariable [_x,sideUnknown] == teamPlayer} count outposts;
        if(_outposts > 4 && {player == theBoss}) then {
            _textX = _textX + localize "STR_A3A_Base_commsMp_unlock_support_points";
            isSupportAnnounced = true;
            publicVariable "isSupportAnnounced";
        };
    };

    if(tierWar > 3 && {!isPowPaycheckAnnounced}) then {
        _textX = _textX + format [localize "STR_A3A_Base_commsMp_idap", A3A_faction_reb get "name", A3A_faction_occ get "name"];
        isPowPaycheckAnnounced = true; 
        publicVariable "isPowPaycheckAnnounced";
    };

    [_textX, [safeZoneX + (0.55 * safeZoneW), (0.2 * safeZoneW)], 0.45, 8, 0, 0, _layer] spawn BIS_fnc_dynamicText;
};
Handles tier-specific unlock messages, support points announcement (when 4+ outposts owned), and POW paycheck announcement.

Where it leads:
Functions Called:
A3A_fnc_customHint: Displays formatted hints
BIS_fnc_dynamicText: Shows on-screen text
A3A_fnc_statistics: Updates HUD
Global Variables Modified:
incomeRep: Lock flag for resource notifications
isSupportAnnounced: Flag for support unlock message
isPowPaycheckAnnounced: Flag for POW paycheck message
Both flags broadcast to all clients
Network Implications:
Uses publicVariable for announcement flags
Dynamic text is local to client (no network)
Sound is local to client
System Integration:
Part of Communication System: Player notifications
Part of UI System: Displays various HUD elements
Used by Mission System: Reports mission results
Used by War System: Reports tier changes
Edge Cases:
Prevents concurrent income displays via incomeRep flag
Tier-specific unlock messages for commander vs players
Support points announcement only for commander and only once
Function Name: fn_createBreachChargeText.sqf
What it does:
Generates HTML-formatted text listing breach charges available. Used to display what explosives can breach a vehicle.

How it does that:
1. Parameter Extraction
Sqf

Apply
private _array = _this;
private _text = "";
Gets the array parameter (passed as _this).

2. Loop Through Charges
Sqf

Apply
for "_count" from 0 to ((count _array) - 1) do
{
    private _charge = _array select _count;
    private _name = getText (configFile >> "CfgMagazines" >> (_charge select 0) >> "displayName");
    private _amount = _charge select 1;
    _text = format ["%1%2%3x %4", _text, LINE_BREAK, _amount, _name];
    if(_count != ((count _array) - 1)) then
    {
        _text = format ["%1 OR", _text];
    };
};
For each charge:

Gets magazine classname and amount from array
Looks up display name from config
Appends formatted text: [amount]x [name]
Adds " OR" between charges (but not after last)
3. Return Result
Sqf

Apply
_text;
Returns HTML-formatted string with <br> breaks.

Where it leads:
Functions Called:
None directly - uses config lookups.

Global Variables Modified:
None.

System Integration:
Part of Breach System: Displays available explosives
Used by A3A_fnc_startBreachVehicle
Edge Cases:
Empty array results in empty string
Uses LINE_BREAK constant for HTML formatting
Config lookup must succeed for each magazine
Function Name: fn_createPetros.sqf
What it does:
Creates or relocates Petros (HQ commander). Handles group creation, identity setup, and cleanup of old Petros.

How it does that:
1. Group Management
Sqf

Apply
params ["_location"];

private _groupPetros = if (isNull petros or {side group petros != teamPlayer}) then {createGroup teamPlayer} else {group petros};

// Don't re-use group if petros was killed by enemy while being moved
if (!isNil "_location" && count units _groupPetros > 1) then { _groupPetros = createGroup teamPlayer };
Gets or creates group for Petros
Creates new group if Petros is null or wrong side
Creates new group if moving and group has other units (to avoid taking them with)
2. Location Determination
Sqf

Apply
if (isNil "_location") then {
    if (count units _groupPetros > 1) then {
        _location = getPosATL petros
    } else {
        _location = getMarkerPos respawnTeamPlayer
    };
};
If no location provided:
If Petros's group has other units, use current Petros position
Otherwise, use HQ respawn marker
3. Identity Setup
Sqf

Apply
private _petrosIdentity = createHashMapFromArray [["face", "GreekHead_A3_01"], ["speaker", "Male01GRE"], ["pitch", 1.1], ["firstName", "Petros"], ["lastName", ":)"]];
Creates identity hash map for Petros.

4. Create New Petros
Sqf

Apply
private _oldPetros = petros;
petros = [_groupPetros, FactionGet(reb,"unitPetros"), _location, [], 10, "NONE", _petrosIdentity] call A3A_fnc_createUnit;
publicVariable "petros";
deleteVehicle _oldPetros;
Saves reference to old Petros
Creates new Petros unit with identity
Makes global variable public
Deletes old Petros unit
5. Initialize Petros
Sqf

Apply
call A3A_fnc_initPetros;
Calls initialization function to set up Petros's behavior, actions, etc.

Where it leads:
Functions Called:
A3A_fnc_createUnit: Creates the Petros unit
A3A_fnc_initPetros: Initializes Petros's behavior and actions
Global Variables Modified:
petros: Global variable for Petros unit
Group ownership
Network Implications:
Uses publicVariable to broadcast new Petros
Unit creation is server-side
System Integration:
Part of Petros System: Manages HQ commander
Used during HQ Relocation and Game Start
Edge Cases:
Old Petros cleanup prevents memory leaks
Group creation avoids taking other units
Location defaults to HQ marker
Function Name: fn_deleteControls.sqf
What it does:
Deletes control points (checkpoints) when their associated marker is captured. Waits for marker to be despawned before changing control ownership.

How it does that:
1. Parameter Extraction
Sqf

Apply
params ["_markerX", "_control"];
_markerX: Marker that controls the control point
_control: Control point marker to delete
2. Position and Nearest Marker Check
Sqf

Apply
private _pos = getMarkerPos _control;
private _nearX = [(markersX - controlsX),_pos] call BIS_fnc_nearestPosition;

if (_nearX isEqualTo _markerX) then {
Gets control point position
Finds nearest marker (excluding other control points)
Checks if that marker matches the input marker
3. Wait for Despawn
Sqf

Apply
    waitUntil {sleep 1;(spawner getVariable _control == 2)};
    _sideX = sidesX getVariable [_markerX,sideUnknown];
    sidesX setVariable [_control,_sideX,true];
};
Waits for control point to be despawned (spawner state 2)
Gets side of owning marker
Sets control point to same side
Makes ownership public
Where it leads:
Functions Called:
BIS_fnc_nearestPosition: Finds nearest marker
Global Variables Modified:
sidesX: Control point ownership
Network Implications:
Uses publicVariable on sidesX (via setVariable with true)
System Integration:
Part of Control Point System: Manages checkpoint ownership
Called when marker is captured
Edge Cases:
Only processes if control point belongs to captured marker
Waits for despawn to avoid conflicts with active spawns
Uses spawner state 2 (DESPAWN)
Function Name: fn_destroyCity.sqf
What it does:
Destroys random buildings in a city and triggers blackout effect. Used for mission visual effects or city destruction.

How it does that:
1. Parameter and Position
Sqf

Apply
params ["_markerX"];

private _positionX = getMarkerPos _markerX;
private _size = [_markerX] call A3A_fnc_sizeMarker;
private _buildings = _positionX nearObjects ["house",_size];
Gets marker position
Calculates marker size
Finds all houses within radius
2. Building Damage Loop
Sqf

Apply
{
    private _hitpoints = getAllHitPointsDamage _x;
    if (_hitpoints isEqualTo []) then { continue };
    if (random 100 < 30) then { continue };
    private _building = _x;
    {
        _building setHit [_x, 1];
    } forEach (_hitpoints # 1 select { _x find "dam" == 0 });
} forEach _buildings;
For each building:

Gets hit points
Skips if no hit points
30% chance to skip (not all buildings destroyed)
Sets all "dam" hit points to 1 (destroyed)
3. Blackout
Sqf

Apply
[_markerX,false] spawn A3A_fnc_blackout;
Triggers blackout for the city.

Where it leads:
Functions Called:
A3A_fnc_sizeMarker: Gets marker size
A3A_fnc_blackout: Turns off lights
Global Variables Modified:
Building damage states
System Integration:
Part of City Destruction System: Visual destruction
Used in Missions requiring city damage
Edge Cases:
Random selection (30% skip rate) prevents complete destruction
Only damages buildings with "dam" hit points
Blackout triggers regardless of building count
Function Name: fn_distance.sqf
What it does:
Main distance-based spawn manager. Handles spawning, despawning, and simulation of AI units based on player distance. Manages different marker types (cities, airports, outposts, etc.) with different rules.

How it does that:
1. Constants Definition
Sqf

Apply
#define COUNT_CYCLES 5
#define ENABLED 0
#define DISABLED 1
#define DESPAWN 2
Defines spawn states: ENABLED (active/simulated), DISABLED (simulated), DESPAWN (not loaded).

2. Process Occupant Marker Closure
Sqf

Apply
private _processOccupantMarker = {
    switch (spawner getVariable _marker)
    do
    {
        case ENABLED:
        {
            // Check if players or Invaders are nearby
            if (_teamplayer inAreaArray [_position, distanceSPWN, distanceSPWN] isNotEqualTo []
                || { _invaders inAreaArray [_position, distanceSPWN2, distanceSPWN2] isNotEqualTo []
                || { _marker in forcedSpawn } }) exitWith {};

            // DISABLE this marker
            spawner setVariable [_marker, DISABLED, true];

            // disable simulation for all marker units
            {
                if (_x getVariable ["markerX", ""] == _marker
                    && { vehicle _x == _x })
                then { _x enableSimulationGlobal false; };
            } forEach allUnits;
        };

        case DISABLED:
        {
            // Check if players or Invaders are nearby or forced spawn
            if (_teamplayer inAreaArray [_position, distanceSPWN, distanceSPWN] isNotEqualTo []
                || { _invaders inAreaArray [_position, distanceSPWN2, distanceSPWN2] isNotEqualTo []
                || { _marker in forcedSpawn } })
            then
            {
                // ENABLE this marker
                spawner setVariable [_marker, ENABLED, true];

                // enable simulation for all marker units
                {
                    if (_x getVariable ["markerX", ""] == _marker
                        && { vehicle _x == _x })
                    then { _x enableSimulationGlobal true; };
                } forEach allunits;
            }
            else
            {
                // Check if players or Invaders are in distanceSPWN1
                if (_teamplayer inAreaArray [_position, distanceSPWN1, distanceSPWN1] isNotEqualTo []
                    || { _invaders inAreaArray [_position, distanceSPWN, distanceSPWN] isNotEqualTo [] })
                exitWith {};

                // DESPAWN this marker
                spawner setVariable [_marker, DESPAWN, true];
            };
        };

        case DESPAWN:
        {
            // Check if players or Invaders are in distanceSPWN or forced spawn
            if (_teamplayer inAreaArray [_position, distanceSPWN, distanceSPWN] isEqualTo []
                && { _invaders inAreaArray [_position, distanceSPWN2, distanceSPWN2] isEqualTo []
                && { !(_marker in forcedSpawn) } }) exitWith {};

            // ENABLE this marker
            spawner setVariable [_marker, ENABLED, true];

            // Spawn appropriate units
            switch (true)
            do
            {
                case (_marker in citiesX):
                {
                    [[_marker], "A3A_fnc_createAICities"] call A3A_fnc_scheduler;
                };

                case (_marker in controlsX):
                {
                    [[_marker], "A3A_fnc_createAIcontrols"] call A3A_fnc_scheduler;
                };

                // Prevent other routines taking spawn places 
                [_marker, 1] call A3A_fnc_addTimeForIdle;

                case (_marker in airportsX):
                {
                    [[_marker], "A3A_fnc_createAIAirplane"] call A3A_fnc_scheduler;
                };

                case (_marker in resourcesX);
                case (_marker in factories):
                {
                    [[_marker], "A3A_fnc_createAIresources"] call A3A_fnc_scheduler;
                };

                case (_marker in outposts);
                case (_marker in seaports):
                {
                    [[_marker], "A3A_fnc_createAIOutposts"] call A3A_fnc_scheduler;
                };

                case(_marker in milbases): 
                {
                    [[_marker],"A3A_fnc_createAIMilbase"] call A3A_fnc_scheduler;
                };

                case (_marker in milAdministrationsX):
                {
                    [[_marker], "A3A_fnc_createAIMilAdmin"] call A3A_fnc_scheduler;
                };
            };
        };
    };
};
State Transitions:

ENABLED → DISABLED: When no players/Invaders in outer range (distanceSPWN) and not forced spawn. Disables simulation for units.

DISABLED → ENABLED: When players/Invaders enter inner range (distanceSPWN) or forced spawn. Re-enables simulation.

DISABLED → DESPAWN: When no players/Invaders in inner range (distanceSPWN1) and not forced spawn. Marks for despawning.

DESPAWN → ENABLED: When players/Invaders enter outer range (distanceSPWN) or forced spawn. Spawns appropriate AI.

3. Process FIA Marker Closure
Sqf

Apply
private _processFIAMarker = {
    // Similar logic but with different conditions
    // FIA markers are owned by rebels, so different spawn rules
    // Includes watchposts, roadblocks, AA posts, etc.
};
Similar state machine but for FIA-owned markers with different unit types.

4. Process Invader Marker Closure
Sqf

Apply
private _processInvaderMarker = {
    // Similar logic for invader-controlled markers
};
Similar state machine for invader markers.

5. Process City Civilian Marker Closure
Sqf

Apply
private _processCityCivMarker = {
    // No garrison to disable, so use a despawn time threshold instead
    private _spawnKey = _marker + "_civ";
    private _timeKey = _spawnKey + "_time";

    switch (spawner getVariable _spawnKey)
    do
    {
        case ENABLED:
        {
            // if player is inside distanceSPWN, reset the timer
            if (_players inAreaArray [_position, distanceSPWN, distanceSPWN] isNotEqualTo []) exitWith 
            {
                spawner setVariable [_timeKey, time + 30, false];
            };
            if (spawner getVariable _timeKey > time) exitWith {};

            // DESPAWN marker
            spawner setVariable [_spawnKey, DESPAWN, true];
        };

        case DESPAWN:
        {
            // if no player is inside distanceSPWN, leave despawned
            if (_players inAreaArray [_position, distanceSPWN, distanceSPWN] isEqualTo []) exitWith {};

            // ENABLED this marker
            spawner setVariable [_spawnKey, ENABLED, true];
            spawner setVariable [_timeKey, time + 30, false];

            if !(_marker in destroyedSites) then
            {
                [[_marker], "A3A_fnc_createAmbientCiv"] call A3A_fnc_scheduler;
                [[_marker], "A3A_fnc_createAmbientCivTraffic"] call A3A_fnc_scheduler;
                [[_marker], "SCRT_fnc_rivals_trySpawnWanderingGroup"] call A3A_fnc_scheduler;
            };
        };
    };
};
Civilian markers use timer-based despawning:

ENABLED: Player in range → reset 30-second timer
DESPAWN: Player out of range or timer expired → despawn civilians
DESPAWN → ENABLED: Player enters range → spawn civilians
6. Main Loop Setup
Sqf

Apply
if !(isServer) exitwith {};

waitUntil { sleep 0.1; if !(isnil "theBoss") exitWith { true }; false };

// Prepare spawner values for civ part of city spawning
{ spawner setVariable [_x + "_civ", 2] } forEach citiesX;

private _time = 1 / count ((markersX + milAdministrationsX));
private _counter = 0;
private _teamplayer = [];
private _occupants = [];
private _invaders = [];
private _players = [];
private _playerVehicles = [];
Ensures server only
Waits for theBoss to exist
Initializes civilian spawner state
Sets update time (cycles through all markers evenly)
Initializes unit arrays
7. Main Loop
Sqf

Apply
while { true }
do
    _counter = _counter + 1;

    if (_counter > COUNT_CYCLES)
    then
    {
        _counter = 0;

        // Update unit lists every 5 cycles
        _occupants = units Occupants select { _x getVariable ["spawner", false] and _x == effectiveCommander vehicle _x };
        _invaders = units Invaders select { _x getVariable ["spawner", false] and _x == effectiveCommander vehicle _x };

        // TeamPlayer includes AI rebels (excludes fast-moving aircraft)
        _teamplayer = units teamPlayer select {
            private _veh = vehicle _x;
            _x getVariable ["spawner", false] and _x == effectiveCommander _veh
            and (_veh == _x or {!(_veh isKindOf "Plane" and (!isTouchingGround _veh or speed _veh > 80))})
        };
        // Add rebel-controlled UAVs
        _teamplayer append (allUnitsUAV select { side group _x == teamPlayer });

        // Players array is used to spawn civilians and rebel garrisons
        _players = [];
        _playerVehicles = [];
        {
            private _rp = _x getVariable ["owner", _x];         // real player unit in remote-control case
            private _veh = vehicle _rp;
            if (_veh in _playerVehicles) then { continue };
            if (_veh in _playerVehicles) then { continue };
            if (_veh isNotEqualTo _rp) then { _playerVehicles pushBackUnique _veh};
            if (_veh == _rp or {!(_veh isKindOf "Air" and speed _veh > 50)}) then { _players pushBack _rp };
        } forEach (allPlayers - entities "HeadlessClient_F");
    };

    {
        sleep _time;

        _marker = _x;
        _position = getmarkerPos (_marker);

        switch (sidesX getVariable [_marker, sideUnknown])
        do
        {
            case Occupants: _processOccupantMarker;
            case Invaders: _processInvaderMarker;
            case teamPlayer: _processFIAMarker;
        };

        if (_marker in citiesX) then { call _processCityCivMarker };

    } forEach (markersX + milAdministrationsX);
};
Cycles through all markers with sleep interval
Every 5 cycles, updates unit lists
Processes each marker based on owner side
For cities, also processes civilian spawning
Continues indefinitely
Where it leads:
Functions Called:
A3A_fnc_addTimeForIdle: Prevents other spawns from taking priority
A3A_fnc_createAICities: Spawns city AI
A3A_fnc_createAIcontrols: Spawns control point AI
A3A_fnc_createAIAirplane: Spawns airport AI
A3A_fnc_createAIresources: Spawns resource AI
A3A_fnc_createAIOutposts: Spawns outpost AI
A3A_fnc_createAIMilbase: Spawns milbase AI
A3A_fnc_createAIMilAdmin: Spawns military admin AI
A3A_fnc_createAmbientCiv: Spawns civilian ambient AI
A3A_fnc_createAmbientCivTraffic: Spawns civilian vehicles
SCRT_fnc_rivals_trySpawnWanderingGroup: Spawns rival groups
A3A_fnc_scheduler: Offloads spawning to scheduler/HC
Global Variables Modified:
spawner: State of each marker (ENABLED, DISABLED, DESPAWN)
Various unit variables: markerX, spawner
A3A_lastGarbageCleanTime (via addTimeForIdle)
Network Implications:
Uses publicVariable on spawner states
Uses remoteExec via scheduler for spawning
Unit simulation enabled/disabled globally
System Integration:
Core Spawn System: Manages all AI spawning/despawning
Part of Performance System: Optimizes by disabling distant units
Part of Multiplayer Optimization: Reduces server load
Called by server init after game start
Edge Cases:
Fast-moving aircraft excluded from teamPlayer list (performance)
Remote-controlled units use their owner for distance checks
Civilian markers use timer-based despawning (no garrison to disable)
Military administration markers processed separately
Forced spawn overrides all distance checks
Performance Considerations:
Sleep interval calculated to cycle through markers evenly
Unit lists updated every 5 cycles (not every iteration)
Simulation disabled for distant units to save CPU
Different ranges for different unit types (distanceSPWN, distanceSPWN1, distanceSPWN2)
Aircraft have stricter despawn rules (speed > 80, not touching ground)

fn_distanceUnits.sqf
Function Name: A3A_fnc_distanceUnits

What it does: This function searches for units capable of spawning (marked with "spawner" variable set to true) that belong to a specified side within a given radius around a center point. It serves two modes: returning an array of found units (mode 0) or a boolean indicating if at least one matching unit exists (mode 1). This is used to check for enemy presence near HQ or to gather spawn-capable units for various mission logic.

How it does that:

Sqf

Apply
params ["_distanceX","_modeX","_center","_targetSide"];
The function begins by extracting four parameters: search radius (_distanceX), return mode (_modeX), center position/object (_center), and target side (_targetSide). The mode determines whether to return units (0) or a boolean (1).

Sqf

Apply
if (_center isEqualType objNull) then { _center = getPosATL _center };
This checks if _center is an object (vehicle/unit). If so, it converts it to a position array using getPosATL (returns [x,y,z] relative to ground level). This ensures consistent input handling whether called with a unit or a position.

Sqf

Apply
private _allSideClose = units _targetSide inAreaArray [_center, _distanceX, _distanceX];
Key technical details:

units _targetSide returns all units belonging to that side (teamPlayer, Occupants, Invaders)
inAreaArray is a highly optimized command that filters units within an elliptical area
The ellipse is defined as [_center, radiusX, radiusY] where both radii are equal (circular)
This returns an array of units (not nil)
Sqf

Apply
if (_modeX == 0) exitWith { _allSideClose select {_x getVariable ["spawner",false]} };
Mode 0 logic:

select filters the array using a condition
{_x getVariable ["spawner",false]} checks if the unit has a variable "spawner" set to true
getVariable with default false safely handles units without the variable
The result is an array of spawn-capable units only
Sqf

Apply
_allSideClose findIf { _x getVariable ["spawner",false] } != -1;
Mode 1 logic:

findIf iterates through the array and returns the index of the first element where the condition is true
If no element matches, it returns -1
The comparison != -1 evaluates to true if at least one unit matches, false otherwise
The function then returns this boolean directly (no explicit return needed in SQF)
Where it leads:

Calls: getPosATL (system function), inAreaArray (system function), units (system function), getVariable (system function)
Called by: A3A_fnc_mrkWIN (flag capture validation), A3A_fnc_markerChange (enemy detection during capture), A3A_fnc_moveOutCrew (crew removal check)
Global variables modified: None
Network implications: None - purely local calculation
System fit: Part of the spawn/control system that tracks which units are spawn-capable (units that can be respawned from marker spawns)
Edge cases handled:

Object vs position input transparently handled
Mode parameter strictly checked (0 or 1)
Empty results correctly handled (empty array or false)
Missing "spawner" variable defaults to false
Dead/unconscious units are still included (filtering happens elsewhere)
fn_fiaFIAradio.sqf
Function Name: A3A_fnc_FIAradio

What it does: Calculates the probability of revealing rebel HQ location to enemies based on radio tower influence, number of active towers near HQ, and tier. It can either reveal the location (and show notifications) or hide it, depending on the random roll and current state. Used as a periodic system to manage intel about rebel HQ.

How it does that:

Sqf

Apply
private _chance = tierWar*3;
Initializes a base chance value. tierWar is the global war tier (1-10). Multiplying by 3 gives a base chance of 3-30%, scaling with game progression.

Sqf

Apply
{
    private _pos = getPos _x;
    private _markerX = [outposts,_pos] call BIS_fnc_nearestPosition;
    if ((sidesX getVariable [_markerX,sideUnknown] == teamPlayer) and {alive _x}) then {_chance = _chance + 4};
} forEach antennas;
Loop logic:

Iterates through all radio towers (antennas array)
For each tower, finds the nearest outpost marker
Checks if that outpost belongs to teamPlayer (rebel-owned)
If tower is rebel-owned AND alive, adds +4% to chance
This rewards rebel-controlled territory for securing towers
Sqf

Apply
private _return = false;
Initializes return value for when function is called with parameters (used by other systems).

Sqf

Apply
if (random 100 < _chance) then {
    if (count _this == 0) then
    {
        if (not revealX) then {
            ["TaskSucceeded", ["", (localize "STR_notifiers_comms_intercept")]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
            revealX = true; publicVariable "revealX";
            [] remoteExec ["A3A_fnc_revealToPlayer",teamPlayer];
        };
    }
    else
    {
        _return = true;
    };
} else {
    if (count _this == 0) then {
        if (revealX) then {
            ["TaskFailed", ["", (localize "STR_notifiers_comms_lost")]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
            revealX = false; 
            publicVariable "revealX";
        };
    };
};
_return
Main logic flow:

Probability check: random 100 < _chance determines if HQ should be revealed (true if random < chance)
Two execution paths based on call type:
No parameters (count _this == 0): Direct system call - updates global state
If revealX is false, shows success notification, sets revealX = true, makes it public, and triggers HQ reveal to players
If reveal fails and HQ was previously revealed, show failure notification, hide HQ, make public
With parameters: Returns boolean for external logic (used by other functions to check if HQ is revealed)
Notification system: Uses remoteExec with BIS_fnc_showNotification to show task updates to teamPlayer side
Global state management: revealX tracks if HQ location is known to enemies (public variable for all clients)
Where it leads:

Calls: getPos _x (system), BIS_fnc_nearestPosition (system), remoteExec (system), A3A_fnc_revealToPlayer (reveals units to players)
Called by: Periodic system calls, A3A_fnc_revealToPlayer (indirectly through revealX)
Global variables modified: revealX (boolean), tierWar (read), antennas (read), outposts (read), sidesX (read via getVariable)
Network implications: Uses publicVariable to sync revealX across all clients; uses remoteExec to trigger notifications on teamPlayer clients
System fit: Part of the intelligence/reconnaissance system where enemy AI can discover rebel HQ location through radio tower control and monitoring
Edge cases handled:

Empty antennas array (loop doesn't execute)
Dead towers (skipped by alive _x check)
Non-rebel outposts (skipped by side check)
Multiple calls (function is stateless except for global variables)
When revealX is already correct (idempotent)
fn_findAttackTargets.sqf
Function Name: A3A_fnc_findAttackTargets

What it does: Generates weighted attack targets for AI forces (Occupants/Invaders) by calculating value, threat, flyover risk, and available ground support. It filters potential targets by distance from air bases and calculates attack viability based on war tier, garrison strength, and player proximity.

How it does that:

Sqf

Apply
params ["_targetSide", "_side"];
Extracts target side (who to attack) and attacking side (who is attacking). Typically used for AI vs rebels or AI vs AI conflicts.

Sqf

Apply
private _possibleStartBases = airportsX select {sidesX getVariable [_x, sideUnknown] == _side && [_x] call A3A_fnc_airportCanAttack};
_possibleStartBases pushBack (["NATO_carrier", "CSAT_carrier"] select (_side == Invaders));
Attack base selection:

Filters airportsX array to find airports owned by attacking side
Additional check airportCanAttack ensures base has spawn capacity
Pushes carrier marker (NATO/CSAT based on attacking side) as an air base option
Results: array of string markers representing possible attack origins
Sqf

Apply
private _airportPositions = _possibleStartBases apply { markerPos _x };
Converts marker names to position arrays for distance calculations later. Uses apply for efficient transformation.

Sqf

Apply
private _possibleTargets = airportsX + outposts + seaports + factories + resourcesX + milbases;
if (_targetSide == teamPlayer) then {_possibleTargets = _possibleTargets + citiesX};
_possibleTargets = _possibleTargets select {sidesX getVariable [_x,sideUnknown] == _targetSide};
Target compilation:

Builds base target list from all marker types
Adds citiesX only when targeting rebels (teamPlayer)
Filters to include only targets belonging to _targetSide
Creates comprehensive list of all enemy-controlled locations
Sqf

Apply
private _hqInfo = [A3A_curHQInfoOcc, A3A_curHQInfoInv] select (_side == Invaders);
if (_targetSide == teamPlayer and _hqInfo >= 1) then { _possibleTargets pushBack "Synd_HQ" };
HQ targeting logic:

Retrieves HQ intelligence level for the attacking side (0-100% known)
If targeting rebels AND intelligence >= 1, adds "Synd_HQ" as attackable target
This allows AI to target rebel HQ if they've discovered its location
Sqf

Apply
if (count _possibleTargets == 0 || count _possibleStartBases == 0) exitWith {
    Info("Attack found no suitable targets or no suitable start bases, aborting!"); [[], []];
};
Early exit validation:

If no valid targets OR no valid start bases, log and return empty arrays
Prevents wasted processing on impossible attack scenarios
Phase 2: Data Preparation

Sqf

Apply
private _markersXYT = [];
private _maxThreatDist = distanceForAirAttack + 1000;
{
    private _markerSide = sidesX getVariable [_x, sideUnknown];
    if (_markerSide == _side) then { continue };
    if (gameMode != 1 && _markerSide != _targetSide) then { continue };
    if (_airportPositions inAreaArray [markerPos _x, _maxThreatDist, _maxThreatDist] isEqualTo []) then { continue };
    // ... threat calculation ...
} forEach markersX;
Threat marker processing:

Iterates through all markers in map
Skips markers owned by attacking side
In non-rebellion modes (gameMode != 1), skips non-target side markers
Checks if any airport is within distanceForAirAttack + 1000 of marker
Continues to calculate threat for remaining markers
Sqf

Apply
private _threat = 10 * count (garrison getVariable [_x, []]);
if (_markerSide == teamPlayer) then {
    _threat = _threat + 50 * count (staticsToSave inAreaArray _x);
} else {
    _threat = _threat + call {
        if (_x in controlsX or _x in seaports) exitWith { 50 };
        if (_x in outposts) exitWith { 150 };
        if (_x in milbases) exitWith { 350 };
        if (_x in airportsX) exitWith { 600 };
        0;
    };
};
Threat calculation:

Base threat: 10 points per garrisoned unit
Rebel-owned markers: +50 per static weapon in marker area
AI-owned markers: Type-based bonus:
Control points/seaports: +50
Outposts: +150
Military bases: +350
Airports: +600
continue if threat == 0 (no reason to attack empty markers)
Sqf

Apply
_markersXYT pushBack [markerPos _x # 0, markerPos _x # 1, _threat];
Stores as [x, y, threat] for efficient spatial filtering later.

Phase 3: Target Value Calculation

Sqf

Apply
private _value = if (_x in citiesX) then {
    private _baseValue = sqrt ((server getVariable _x) # 0);
    if (_side == Occupants) exitWith { _baseValue * (1.5 - tierWar / 10) };
    _baseValue * (tierWar / 5);
} else {
    private _value = call {
        if (_x in outposts) exitWith { [20, 25] select (count (_radioTowers inAreaArray _x) > 0) };
        if (_x == "Synd_HQ") exitWith { 60 };
        if (_x in seaports) exitWith { 20 };
        if (_x in milbases) exitWith { 40 };
        if (_x in airportsX) exitWith { [60, 90] select (count _possibleStartBases == 1) };
        if (_x in factories) exitWith { 15 };
        10;
    };
    _baseValue + ([_x, true] call A3A_fnc_garrisonSize) / 2;
};
Base value calculation:

Cities: Square root of population, scaled by war tier (Occupants care more at low tier, Invaders at high tier)
Outposts: 20 or 25 if radio tower nearby
Synd_HQ: Fixed 60
Seaports: 20
Military bases: 40
Airports: 60 (or 90 if only one start base left - critical fallback)
Factories: 15
Resources: 10
Add garrison size bonus (divided by 2) for large/defensible targets
Phase 4: Local Threat Calculation

Sqf

Apply
private _targpos = markerPos _x;
private _localMarkers = _markersXYT inAreaArray [_targpos, 1500, 1500];
private _nonLocalMarkers = _markersXYT - _localMarkers;
private _localThreat = 0;
{
    private _dist = _x distance2d _targpos;
    private _threat = (_x#2) * linearConversion [500, 1500, _dist, 1, 0, true];
    _localThreat = _localThreat + _threat;
    if (_dist > 500) then { _nonLocalMarkers pushBack [_x#0, _x#1, (_x#2) - _threat] };
} forEach _localMarkers;
Local vs global threat:

Finds markers within 1500m of target
Calculates weighted threat: full strength at 500m, zero at 1500m
Threat removed from nonLocalMarkers if distance > 500m (partial reduction)
Tracks total local threat for defense difficulty assessment
Sqf

Apply
if (_targetSide == teamPlayer) then {
    _localThreat = _localThreat + 150;
} else {
    _localThreat = _localThreat + 30 * count (_rebelPlayers inAreaArray [_targpos, 500, 500]);
};
_localThreat = _localThreat + 10 * count (_rebelAISpawners inAreaArray [_targpos, 500, 500]);
Active defense modifiers:

Rebel targets: +150 for assumed active defense
AI vs AI: +30 per player within 500m
All targets: +10 per rebel AI spawner within 500m
Phase 5: Supply Convoy Shortcut

Sqf

Apply
if (_x in citiesX and _side == Occupants) then {
    private _landBase = [_x] call A3A_fnc_findBasesForConvoy;
    if (_landBase == "") then { continue };
    _finalTargets pushBack [_target, _landBase, _value, _localThreat, 0, 1];
    _finalWeights pushBack (_value / _localThreat^0.8) ^ 2;
    continue;
};
Convoy bypass:

If attacking rebel city as Occupants, find ground base for convoy
Skip if no valid base found
Push target with special _countLand = 1 flag
Weight formula: (value / threat^0.8)^2 (exponential scaling)
continue skips air base iteration
Phase 6: Air Attack Calculation

Sqf

Apply
private _countLand = call {
    private _targNavIndex = _target call A3A_fnc_getMarkerNavPoint;
    private _suppMarkers = [_targNavIndex, _lowAir] call A3A_fnc_findLandSupportMarkers apply { _x#0 };
    count (_suppMarkers arrayIntersect _landBases);
};
Ground support count:

Gets target's nav point index
Finds land support markers (returns array with marker info)
Extracts marker names, intersects with land base array
Counts usable ground attack bases
Sqf

Apply
private _weights = [];
private _totalWeight = 0;
private _maxWeight = 0;
{
    private _basePos = markerPos _x;
    private _dist = _basePos distance2d _targPos;
    if (_dist > distanceForAirAttack) then { continue };
    
    private _midpoint = (_basePos vectorAdd _targPos) vectorMultiply 0.5;
    private _targDir = _basePos getDir _targPos;
    private _flyoverMarkers = _nonLocalMarkers inAreaArray [_midpoint, 1200, _dist/2, _targDir, true];
    private _sideVec = [cos _targDir, -sin _targDir, 0];
    private _flyoverThreat = 0;
    {
        private _dist = abs ((_x vectorDiff _basePos) vectorDotProduct _sideVec);
        private _threat = (_x#2) * linearConversion [200, 1200, _dist, 1, 0, true];
        _flyoverThreat = _flyoverThreat + _threat;
        if (_flyoverThreat > 300) exitWith {};
    } forEach _flyoverMarkers;
    
    if (_flyoverThreat > 300) then { continue };
    
    _finalTargets pushBack [_target, _x, _value, _localThreat, _flyoverThreat, _countLand];
    
    private _difficulty = if (_lowAir) then {
        private _distFactor = linearConversion [0, distanceForAirAttack, _dist, 0.5, 1.5, true];
        (_localThreat + 2*_flyoverThreat) * (_distFactor + 3^(-_countLand));
    } else {
        private _distFactor = linearConversion [0, distanceForAirAttack, _dist, 0.65, 1, true];
        (_localThreat + 2*_flyoverThreat) * (_distFactor + 2^(-_countLand));
    };
    private _weight = (_value / _difficulty^0.8) ^ 2;
    
    _maxWeight = _weight max _maxWeight;
    _totalWeight = _totalWeight + _weight;
    _weights pushBack _weight;
} forEach _possibleStartBases;

{ _finalWeights pushBack (_x * _maxWeight / _totalWeight) } forEach _weights;
Per-base attack viability:

Skip if distance exceeds distanceForAirAttack
Calculate midpoint for flyover threat
Project enemy markers onto attack vector (line from base to target)
Sum threat from markers within 200-1200m of vector
Skip if flyover threat > 300 (too dangerous)
Calculate difficulty with distance factor and ground support bonus (3^(-count) vs 2^(-count))
Weight formula scales exponentially with value/difficulty
Normalize weights so total doesn't exceed max (prevents stacking benefits)
Final weights multiplied by 10 for readability
Final Output:

Sqf

Apply
[_finalTargets, _finalWeights];
Returns two synchronized arrays:

_finalTargets: Each element [targetMarker, sourceBase, value, localThreat, flyoverThreat, countLand]
_finalWeights: Normalized weights for random selection
Where it leads:

Calls: A3A_fnc_airportCanAttack, A3A_fnc_getMarkerNavPoint, A3A_fnc_findLandSupportMarkers, A3A_fnc_garrisonSize, BIS_fnc_nearestPosition, linearConversion
Called by: A3A_fnc_chooseAttack (main attack decision), A3A_fnc_wavedAttack (spawning)
Global variables modified: None (reads many)
Network implications: None - server-side calculation only
System fit: Core AI attack planning system; feeds into attack selection and spawning
Edge cases:

No targets/start bases (early exit with empty arrays)
Single start base (airport value bonus)
No flyover threats (normal difficulty)
Extreme distances (filtered by distanceForAirAttack)
Empty garrison arrays (handled by garrisonSize)
fn_findBasesForConvoy.sqf
Function Name: A3A_fnc_findBasesForConvoy

What it does: Finds a suitable base (airport, outpost, or military base) to send a supply convoy from to a destination marker. Validates based on side ownership, distance (1000-3000m), spawn availability, garrison size, connectivity, and recent attacks.

How it does that:

Sqf

Apply
params ["_mrkDest", ["_possibleBases", airportsX + outposts + milbases]];
Parameters:

_mrkDest: Target marker for convoy
_possibleBases: Optional array of base markers (defaults to all base types)
This allows filtering by specific base types if needed
Sqf

Apply
private _posDest = getMarkerPos _mrkDest;
private _side = sidesX getVariable [_mrkDest,sideUnknown];
if (_mrkDest in citiesX and _side == teamPlayer) then {_side = Occupants};
Destination side logic:

Get destination position
Get owner side of destination
Special case: If destination is a rebel-owned city, treat target side as Occupants (convoy from Occupants to rebel city)
This is because cities are always captured by rebels initially
Sqf

Apply
private _bases = _possiblebases select {
    (sidesX getVariable [_x,sideUnknown] == _side)
    and (_posDest distance getMarkerPos _x > 1000)
    and (_posDest distance getMarkerPos _x < 3000)
    and {
        (spawner getVariable _x == 2)
        and (dateToNumber date > server getVariable _x)
        and (count (garrison getVariable [_x,[]]) >= 16)
        and ([_x,_mrkDest] call A3A_fnc_arePositionsConnected)
        and !(_x in forcedSpawn) and !(_x in blackListDest)
        and ({_x == _mrkDest} count (killZones getVariable [_x,[]]) < 3)
    };
};
Base selection criteria (all must be true):

Ownership: Base belongs to convoy side
Distance range: 1000m < distance < 3000m from destination
Spawn status: spawner getVariable _x == 2 (base is despawned/ready)
Garrison not busy: dateToNumber date > server getVariable _x (base idle timer passed)
Garrison size: At least 16 garrisoned units (sufficient force)
Road connectivity: [_x,_mrkDest] call A3A_fnc_arePositionsConnected (direct route exists)
Not blacklisted: Base not in forcedSpawn or blackListDest
Recent attacks: Count of kill zone entries for this destination < 3 (prevents immediate re-attack)
Sqf

Apply
if (count _bases == 0) exitWith {""};
selectRandom _bases;
Result:

If no valid bases, return empty string
Otherwise, return random base from valid candidates
Where it leads:

Calls: getMarkerPos, sidesX getVariable, dateToNumber, garrison getVariable, A3A_fnc_arePositionsConnected, spawner getVariable, server getVariable, killZones getVariable
Called by: A3A_fnc_findAttackTargets (convoy shortcut), A3A_fnc_wavedAttack (convoy spawns)
Global variables modified: None (reads many)
Network implications: None - local calculation
System fit: Convoy route planning system; part of logistics and reinforcement network
Edge cases handled:

Empty possibleBases array (returns empty string)
No bases within distance range (filtered out)
Unconnected bases (direct road check fails)
Recently attacked destinations (kill zone limit)
Garris­on size too small (must be >= 16)

Function Documentation
A3A/addons/core/functions/Base/fn_findNearestGoodRoad.sqf
Function Name: fn_findNearestGoodRoad.sqf

What it does: Finds the nearest suitable road within an expanding search radius. The function identifies roads that are not located on prohibited terrain types (forests, rocks, tall grass) and are connected to the road network.

How it does that: The function takes a position array _pos as input. It defines bad surface types and initializes a search radius at 10 meters. It enters a while loop that continues until a valid road is found. Inside the loop, it gathers all roads within the current radius using nearRoads. It iterates through these roads, checking the surface type at each road's position and verifying if the road has connections (roadsConnectedTo). If a valid road is found, it exits the loop. The radius is increased by 10 meters each iteration if no valid road is found.

Sqf

Apply
params ["_pos"];

private _badSurfaces = ["#GdtForest", "#GdtRock", "#GdtGrassTall"];
private _radiusX = 10;
private _road = objNull;

while {isNull _road} do
{
    private _nearRoads = _pos nearRoads _radiusX;
    {
        private _surfType = surfaceType (position _x);
        if (!(_surfType in _badSurfaces) && { count roadsConnectedTo _x != 0 }) exitWith {_road = _x};
    } forEach _nearRoads;
    _radiusX = _radiusX + 10;
};
_road;
Where it leads:

Calls: None internally.
Called by: This is a utility function used by other systems (likely spawn or pathfinding functions).
Dependencies: Uses engine commands: params, nearRoads, surfaceType, position, roadsConnectedTo, isNull.
Global Variables: None modified.
Synchronization: Pure local calculation; no network implications.

Function Name: fn_flagaction.sqf What it does: This function adds specific actions to game objects (flags, units, vehicles, etc.) based on the provided type parameter. It's a core system that enables interactive functionality for various in-game entities, including taking flags, recruiting units, buying vehicles, managing the HQ, healing/reviving actions, prisoner interactions, intel gathering, and more. It only executes on client machines with an interface (hasInterface) since it's purely an action system.

How it does that: The function receives parameters _flag and _typeX, then uses a switch statement to handle 25 different action types. For each type, it adds specific action commands using SQF's addAction method, often with localized text, images, and conditions for when the action should appear.

1. Parameter Validation and Initialization:

Sqf

Apply
if (!hasInterface) exitWith {};
params ["_flag","_typeX"];
private _actionX = -1;
First checks if the script runs on a client (hasInterface). If not, it exits immediately since actions are only needed on clients.
The function expects two parameters: an object reference (_flag) and a string (_typeX) indicating which action to add.
2. Action Type: "take" (Flag Capturing):

Sqf

Apply
case "take":
{
    removeAllActions _flag;
    _actionX = _flag addAction [
        format["<img image='\A3\ui_f\data\igui\cfg\actions\takeflag_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", (localize "STR_antistasi_actions_take_flag")], 
        A3A_fnc_mrkWIN, nil, 6, true, true, "", 
        "(isPlayer _this) and (_this == _this getVariable ['owner',objNull])", 4
    ];
    _flag setUserActionText [_actionX,(localize "STR_antistasi_actions_take_flag"),"<t size='2'><img image='\A3\ui_f\data\igui\cfg\actions\takeflag_ca.paa'/></t>"];
};
Removes all existing actions from the flag object.
Adds a new action with localized text, an image, and a condition that ensures only the owner player can see and execute it. The action executes A3A_fnc_mrkWIN when triggered. The params for the action are passed as [flag, caller, actionID, arguments] (arguments are nil here).
Sets the action text for the wheel menu with a larger icon.
3. Action Type: "unit" (Unit Recruitment):

Sqf

Apply
case "unit":
{
    if (playerRecruitAI isEqualTo 1) then 
    {
        _flag addAction [
            format ["<img image='\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", localize "STR_antistasi_actions_recruit_units"],
            {
                if ([getPosATL player] call A3A_fnc_enemyNearCheck) then {
                    [localize "STR_antistasi_actions_unit_recruitment", localize "STR_antistasi_actions_unit_recruitment_distance_check_failure"] call A3A_fnc_customHint;
                } else { 
                    [] spawn A3A_fnc_unit_recruit; 
                };
            }, nil, 0, false, true, "", "(isPlayer _this) and (_this == _this getVariable ['owner',objNull])", 4
        ];
    };
};
Checks if unit recruitment is enabled via playerRecruitAI.
Adds an action that, when triggered, first checks for nearby enemies using A3A_fnc_enemyNearCheck.
If no enemies are near, it spawns the unit recruitment dialog (A3A_fnc_unit_recruit). If enemies are near, it shows a warning via A3A_fnc_customHint.
4. Action Type: "vehicle" (Buy Vehicle):

Sqf

Apply
case "vehicle":
{
    _flag addAction [
        format ["<img image='a3\ui_f\data\igui\cfg\simpletasks\types\truck_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", localize "STR_antistasi_actions_buy_vehicle"], 
        {
            if ([getPosATL player] call A3A_fnc_enemyNearCheck) then {
                [localize "STR_antistasi_actions_buy_vehicle", localize "STR_antistasi_actions_buy_vehicle_distance_check_failure"] call A3A_fnc_customHint
            } else {
                createDialog "A3A_BuyVehicleDialog";
            };
        }, nil, 0, false, true, "", "(isPlayer _this) and (_this == _this getVariable ['owner',objNull])", 4
    ];
};
Adds an action for buying vehicles.
Similar to unit recruitment, it checks for enemies first. If safe, it opens the "A3A_BuyVehicleDialog" to purchase vehicles. Shows a warning if enemies are present.
5. Action Type: "petros" (Petros/HQ Specific Actions):

Sqf

Apply
case "petros":
{
    petros addAction [
        format ["<img image='\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", localize "STR_antistasi_actions_request_mission"], {
            #ifdef UseDoomGUI
                ERROR("Disabled due to UseDoomGUI Switch.")
            #else
                createDialog "missionMenu";
            #endif
        },
        nil, 0, false, true, "", "([_this] call A3A_fnc_isMember or _this == theBoss) and (petros == leader group petros)", 4
    ];
    petros addAction [localize "STR_antistasi_actions_move_this_asset", A3A_fnc_moveHQObject, nil, 0, false, true, "", "(_this == theBoss) and (petros == leader group petros)"];
    petros addAction [format ["<img image='a3\ui_f\data\igui\cfg\actions\takeflag_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", localize "STR_antistasi_actions_build_hq"], A3A_fnc_buildHQ, nil, 0, false, true, "", "(_this == theBoss) and (petros != leader group petros)", 4];
};
Adds three actions to the Petros unit (HQ).
Request Mission: Opens mission selection menu (checks if player is member or theBoss).
Move Asset: Allows moving assets, only for theBoss.
Build HQ: Allows building the HQ, only for theBoss when Petros is not the leader.
6. Action Type: "truckX" (Transfer Ammo to Truck):

Sqf

Apply
case "truckX":
{
    actionX = _flag addAction [
        format [
            "<img image='\A3\ui_f\data\igui\cfg\actions\unloadVehicle_ca.paa' size='1.6' shadow=2 /> <t>%1</t>", 
            localize "STR_antistasi_transfer_ammobox_to_truck"
        ], A3A_fnc_transfer, nil, 6, true, true, "", "(isPlayer _this) and (_this == _this getVariable ['owner',objNull])"
    ];
};
Adds an action to transfer ammo boxes to/from a truck, calling A3A_fnc_transfer.
7. Action Types: "heal", "heal1", "heal2" (Healing/Reviving):

These add actions for reviving players/units. They check if the target isn't the player, add a revive action, and optionally add hold actions for self-revive kits (if enabled) and carrying actions.
heal1 and heal2 are variations with different icons/conditions (e.g., heal1 includes carry action, heal2 is simpler).
They use A3A_fnc_actionRevive and A3A_fnc_carry for the main functions.
For self-revive kits, they use BIS_fnc_holdActionAdd with a condition that checks for the kit in the player's backpack and distance to target.
8. Action Types: "remove" (Cleanup):

Sqf

Apply
case "remove":
{
    if (player == _flag) then
    {
        if (isNil "actionX") then
        {
            removeAllActions _flag;
            if (player == player getVariable ["owner",player]) then {[] call SA_Add_Player_Tow_Actions};
            call A3A_fnc_dropObject;
        }
        else
        {
            _flag removeAction actionX;
        };
    }
    else
    {
        removeAllActions _flag;
    };
};
Cleans up actions from a unit or object. If it's the player, it might add tow actions or drop carried objects. Otherwise, it removes all actions.
9. Action Types: "refugee", "deserter", "prisonerX", "prisonerFlee" (Prisoner Interactions):

These add actions to interact with captives (refugees, deserters, POWs). They call specific liberate functions like A3A_fnc_liberaterefugee, A3A_fnc_liberateDeserter, etc. Conditions check if the target is alive and the player is the owner.
10. Action Type: "captureX" (Capture/Release Recruit Actions):

Adds multiple actions for captured units: release, recruit to faction, recruit to player squad (if enabled), interrogate, and reveal. Uses A3A_fnc_captureX, A3A_fnc_interrogate, SCRT_fnc_common_reveal.
11. Action Type: "captureRivals" (Rivals Specific):

Similar to captureX but for rival units, with imprison and interrogate actions.
12. Action Type: "seaport":

Currently empty (no actions assigned).
13. Action Type: "garage":

Initializes the garage functionality using HR_GRG_fnc_initGarage.
14. Action Type: "SDKFlag":

Adds recruit and buy vehicle actions to rebel-controlled flags (like unit and vehicle cases), plus initializes the garage.
15. Action Types: "Intel_Small", "Intel_Medium", "Intel_Large", "Intel_Encrypted", "Intel_Rivals_Laptop":

These add actions to search or hack intel objects. They call functions like A3A_fnc_searchIntelOnLeader, A3A_fnc_searchIntelOnDocument, A3A_fnc_searchIntelOnLaptop, A3A_fnc_searchEncryptedIntel, SCRT_fnc_rivals_searchDataOnLaptop. Conditions often check if the target is not in combat or if the laptop hasn't been searched.
16. Action Type: "Move_Outpost_Static":

Adds an action to move static weapons from outposts using SCRT_fnc_common_moveOutpostStatic.
17. Action Types: "static", "vehiclestatic":

These add actions to lock/unlock statics for AI and move them. They use A3A_fnc_unlockStatic, A3A_fnc_lockStatic, and A3A_fnc_moveHQObject. Conditions check ownership, attachment status, and crew count.
18. Action Type: "rivals_quest":

Similar to Intel_Rivals_Laptop but for rival quests.
19. Return Value:

Sqf

Apply
_actionX
Returns the action ID of the last added action (or -1 if none were added).
Where it leads:

Called Functions:
A3A_fnc_mrkWIN: Handles flag capture and marker change.
A3A_fnc_unit_recruit: Opens unit recruitment dialog.
A3A_fnc_enemyNearCheck: Checks for nearby enemies.
A3A_fnc_customHint: Shows UI hints.
A3A_fnc_moveHQObject: Moves HQ-related objects.
A3A_fnc_buildHQ: Initiates HQ building.
A3A_fnc_transfer: Handles ammo transfer.
A3A_fnc_actionRevive: Executes the revive action.
A3A_fnc_carry: Picks up a carried unit.
A3A_fnc_liberate...: Various liberate functions for prisoners.
A3A_fnc_captureX: Handles capture/recruit/release.
A3A_fnc_interrogate: Interrogates a target.
SCRT_fnc_common_reveal: Reveals intel/locations.
HR_GRG_fnc_initGarage: Initializes the garage system.
SCRT_fnc_rivals_imprison, SCRT_fnc_rivals_searchDataOnLaptop: Rivals-specific actions.
BIS_fnc_holdActionAdd, BIS_fnc_holdActionRemove: For hold-actions (self-revive).
Depends on: System variables like playerRecruitAI, recruitToPlayerSquad, reviveKitsEnabled, teamPlayer, theBoss, petros, staticsToSave, A3A_faction_reb, A3A_faction_occ, A3A_faction_inv. Global variables like actionX are modified (used as a global reference for cleanup).
System Fit: This is the primary interface for player interaction with base flags, captured units, and interactive objects. It's part of the action system that bridges player intent with game logic functions. It relies heavily on the mission's global state (owner variables, global arrays).
Global Variables Modified: actionX is sometimes set (as a global variable) to be used later in remove. The _actionX local variable is returned.
Network Implications: Actions are added locally on each client. Conditions like (isPlayer _this) and (_this == _this getVariable ['owner',objNull]) are evaluated client-side. Function calls like A3A_fnc_markerChange are often executed remotely on the server (via remoteExec). Hold actions like BIS_fnc_holdActionAdd are local to the client performing the action.
Function Name: fn_fogCheck.sqf What it does: Calculates the effective visibility distance between two points in fog, using the game's fog parameters (value, decay, base). It determines how much fog impacts line of sight, returning a value between 0 and 1 where 1 indicates clear visibility and 0 indicates complete occlusion by fog.

How it does that: It takes a starting point (_thing0) and a boolean flag (_typeX) indicating if the second point is elevated. It calculates the distance and height difference, then applies the fog density formula to determine the effective fog line-of-sight factor.

1. Parameter Processing and Coordinate Conversion:

Sqf

Apply
params ["_thing0", "_typeX"];
private _error = false;
private _pos0 = [];
if (_thing0 isEqualType []) then
{
    if ((_thing0 select 2) < 3) then
    {
        _pos0 = ATLToASL _thing0;
    }
    else
    {
        _pos0 = _thing0;
    };
}
else
{
    if (_thing0 isEqualType "") then
    {
        _pos0 = ATLToASL (getMarkerPos _thing0);
    }
    else
    {
        if (_thing0 isEqualType objNull) then {_pos0 = getPosASL _thing0} else {_error = true};
    };
};
if (_error) exitWith {
    Error_1("Unknown height:%1.",_thing0);
};
Determines the type of _thing0 (array, string (marker), or object) and converts it to ASL coordinates for consistency.
Handles edge cases (e.g., low ATL Z values are converted, high ones are assumed ASL).
Exits with an error if the input type is invalid.
2. Fog Parameter Calculation:

Sqf

Apply
private _pos1 = [(_pos0 select 0) + 300,_pos0 select 1,_pos0 select 2];
if (_typeX) then {_pos1 = [(_pos0 select 0) + 300,_pos0 select 1,(_pos0 select 2)+300]};
private _MaxViewDistance = 10000;
private _ViewDistanceDecayRate = 120;
private _z0 = _pos0 param [2, 0, [0]];
private _z1 = _pos1 param [2, 0, [0]];
private _l = _pos0 distance _pos1;
fogParams params ["_fogValue", "_fogDecay", "_fogBase"];
_fogValue = _fogValue min 1.0;
_fogValue = _fogValue max 0.0;
_fogDecay = _fogDecay min 1.0;
_fogDecay = _fogDecay max -1.0;
_fogBase = _fogBase min 5000;
_fogBase = _fogBase max -5000;
private _dz = _z1 - _z0;
private _fogCoeff = 1.0;
Defines _pos1 as a point 300m ahead (horizontally). If _typeX is true, it also raises _pos1 by 300m (calculating for elevated targets).
Extracts fog parameters from the game engine (fogParams).
Clamps fog parameters to sensible ranges (prevent runaway values).
Calculates the vertical difference (_dz) and initializes the fog coefficient to 1.0 (clear).
3. Fog Coefficient Calculation (Physics-based):

Sqf

Apply
if (_dz !=0 && _fogDecay != 0) then
{
    private _cl = -_fogDecay * _dz;
    private _d = -_fogDecay * (_z0 - _fogBase);
    // lim [(exp(x)-1) / x] = 1 as x->0
    if (abs(_cl) > 1e-4) then
    {
        _fogCoeff = exp(_d) * ( exp (_cl) - 1.0) / _cl;
    }
    else
    {
        _fogCoeff = exp(_d);
    };
};
If there is vertical movement and fog decay is non-zero, it calculates the fog coefficient using an integration of exponential fog density based on height.
Handles the special case where _cl is near zero (using the limit [(exp(x)-1) / x] = 1 to avoid division by zero).
The coefficient represents the average fog density between the two points.
4. Final Visibility Calculation:

Sqf

Apply
private _fogAverage = _fogValue * _fogCoeff;
private _fogViewDistance = 0.9 * _MaxViewDistance * exp (- _fogAverage * ln(_ViewDistanceDecayRate));
if (_fogViewDistance == 0) exitWith {0};
0 max (1.0 - _l/_fogViewDistance)
Calculates the average fog density between points (_fogAverage).
Calculates the effective view distance through fog (_fogViewDistance).
If effective view distance is zero, returns 0 (completely obscured).
Otherwise, returns a linear interpolation: 1 if distance _l is less than effective view distance, dropping to 0 as distance increases. Returns 0 if negative (clamped).
Where it leads:

Called Functions: ATLToASL, getMarkerPos, getPosASL, fogParams (engine), Error_1 (logging).
Depends on: Game engine fog parameters. No global variables are modified.
System Fit: Used for dynamic visibility checks, likely for AI targeting or support calls. It's a utility function providing environmental awareness.
Network Implications: None. Runs entirely locally based on current game state.
Function Name: fn_garbageCleaner.sqf What it does: Cleans up the server environment by deleting dead bodies, weapon holders, and specific vehicle wrecks. It also manages the building limit for the construction system by capping the saved buildings array. It's designed to be run periodically or manually to prevent performance degradation from clutter.

How it does that: 1. Scheduling and Initialization:

Sqf

Apply
if (!canSuspend) exitWith { [] spawn A3A_fnc_garbageCleaner };
Ensures the script runs in a scheduled environment (can sleep). If not, it re-spawns itself to force scheduling.
2. Notification and Setup:

Sqf

Apply
private _timeSinceLastGC = [[serverTime-A3A_lastGarbageCleanTime] call A3A_fnc_secondsToTimeSpan,0,0,false,2] call A3A_fnc_timeSpan_format;
[localize "STR_antistasi_dialogs_open_clean_garbage_title", format [localize "STR_antistasi_dialogs_open_clean_garbage_exit", _timeSinceLastGC]] remoteExec ["A3A_fnc_customHint", 0];
Info("Cleaning garbage...");
Calculates the time since the last garbage cleanup and sends a notification to all players.
Logs the start of the process.
3. Rebel Spawner Definition:

Sqf

Apply
private _rebelSpawners = units teamPlayer select { _x getVariable ["spawner",false] };
_rebelSpawners pushBack petros;
Identifies rebel players (units marked as spawners) and Petros. These are used as reference points for distance checks later (to avoid deleting items near players).
4. Distance Check Function:

Sqf

Apply
private _fnc_distCheck = {
    params["_object", "_dist"];
    if (_rebelSpawners inAreaArray [getPosATL _object, _dist, _dist] isEqualTo []) then { deleteVehicle _object };
};
Defines a local function to delete an object only if no rebel spawners are within the specified distance.
5. Building Limit Capping:

Sqf

Apply
if (count (A3A_buildingsToSave) >= A3A_builderLimit) then { A3A_buildingsToSave = A3A_buildingsToSave select [0, A3A_builderLimit - 1] };
publicVariable "A3A_buildingsToSave";
Checks if the number of saved buildings exceeds the limit. If so, it truncates the array (removing the oldest buildings) and syncs the variable to all clients.
6. Dead Body Cleanup:

Sqf

Apply
Debug("Moving dead solders out of vehicles...")
{
    if !(isNull objectParent _x) then { moveOut _x };
} forEach allDeadMen;
Debug("Finished moving soldiers out of vehicles; executing garbage clean.")
sleep 0.5;
{ deleteVehicle _x } forEach allDead;
Moves all dead bodies out of vehicles (to prevent them getting stuck inside).
Waits 0.5 seconds.
Deletes all dead bodies (allDead).
7. Object Cleanup (Weapon Holders, Leaflets, etc.):

Sqf

Apply
{ deleteVehicle _x } forEach (allMissionObjects "WeaponHolder");
{ deleteVehicle _x } forEach (allMissionObjects "WeaponHolderSimulated");
{ [_x, 500] call _fnc_distCheck } forEach (allMissionObjects FactionGet(occ,"surrenderCrate"));
// ... more distance checks ...
{ deleteVehicle _x } forEach (allMissionObjects "Leaflet_05_F");
{ deleteVehicle _x } forEach (allMissionObjects "Ejection_Seat_Base_F");
{ deleteVehicle _x } forEach (allMissionObjects "Land_Pallet_F");
Deletes weapon holders (ground loot).
Deletes surrender crates (NATO, CSAT, Rivals) if they are 500m away from rebel spawners.
Deletes leaflets, ejection seats, and pallets globally.
8. Rebel Vehicle Cleanup:

Sqf

Apply
private _lootCrateType = FactionGet(reb, "lootCrate");
{
    if !(_x isKindOf "StaticWeapon" or {(typeOf _x) isEqualTo _lootCrateType or {unitIsUAV _x or {locked _x > 1}}}) then { [_x, 500] call _fnc_distCheck };
} forEach (vehicles select {_x getVariable ["ownerSide", sideUnknown] == teamPlayer});
Iterates over rebel-owned vehicles. It skips static weapons, loot crates, UAVs, and locked vehicles (likely mission-critical).
Deletes other rebel vehicles if they are 500m away from rebel spawners.
9. Mod-Specific Cleanup (ACE, RHS, etc.):

Sqf

Apply
if (A3A_hasACE) then {
    { deleteVehicle _x } forEach (allMissionObjects "ACE_bodyBagObject");
    // ... more ACE objects ...
    [_x, 200] call _fnc_distCheck } forEach (allMissionObjects "ACE_Grave");
};
if (isClass (configFile/"CfgPatches"/"rhsgref_main")) then {
    { deleteVehicle _x } forEach (allMissionObjects "rhs_a10_acesII_seat");
    // ... more RHS objects ...
};
If ACE is loaded, deletes specific ACE objects (body bags, spray tags, cookoff turrets, graves) with distance checks for graves.
If RHS is loaded, deletes various RHS ejection seats and helicopter parts.
10. Final Notification:

Sqf

Apply
[localize "STR_antistasi_dialogs_open_clean_garbage_title", format [localize "STR_antistasi_dialogs_open_clean_garbage_success", _timeSinceLastGC]] remoteExec ["A3A_fnc_customHint", 0];
missionNamespace setVariable ["A3A_lastGarbageCleanTime",serverTime,true];
Info("Garbage clean completed");
Notifies players of completion and updates the global last garbage clean timestamp.
Where it leads:

Called Functions: A3A_fnc_secondsToTimeSpan, A3A_fnc_timeSpan_format, A3A_fnc_customHint, Error (implied via logs), _fnc_distCheck (local).
Depends on: A3A_lastGarbageCleanTime, teamPlayer, petros, A3A_buildingsToSave, A3A_builderLimit, Faction definitions (FactionGet), Mod presence booleans (A3A_hasACE, etc.). It uses remoteExec to send hints to clients.
System Fit: This is a critical maintenance script. It runs on the server (dedicated or host) to manage object count and prevent crashes due to too many entities. It interacts with the builder system (buildings) and vehicle ownership system.
Global Variables Modified: A3A_lastGarbageCleanTime (server-time updated), A3A_buildingsToSave (truncated and publicVariable).
Network Implications: Hints are broadcast to all clients. publicVariable syncs building data. Execution is server-side only.
Function Name: fn_garbageCleanerTracker.sqf What it does: An automated background tracker that monitors time since the last garbage cleanup and triggers A3A_fnc_garbageCleaner automatically if a threshold is exceeded. It also notifies players periodically about the time elapsed since the last manual cleanup.

How it does that: 1. Server-Side and Threshold Check:

Sqf

Apply
if(!isServer) exitWith {};
#define GC_THRESHOLD_DISABLE 9999999
if(A3A_GCThreshold isEqualTo GC_THRESHOLD_DISABLE) exitWith {};
Exits immediately if not running on the server.
Checks if the garbage cleaning threshold is disabled. If set to the disable constant, it exits.
2. Infinite Loop with Timers:

Sqf

Apply
while {true} do {
    // ... notification logic ...
    // ... threshold check logic ...
    sleep (A3A_GCThreshold / 4);
};
Enters an infinite loop (runs for the lifetime of the server session).
Sleeps for a quarter of the garbage threshold duration between iterations.
3. Periodic Notification Logic:

Sqf

Apply
if ((serverTime - A3A_lastGarbageCleanTimeNote) > (A3A_GCThreshold / 4)) then {
    private _timeSinceLastGC = [[serverTime - A3A_lastGarbageCleanTime] call A3A_fnc_secondsToTimeSpan,0,0,false,2] call A3A_fnc_timeSpan_format;
    [localize "STR_A3A_GCTracker_tracker_title", format [localize "STR_A3A_GCTracker_tracker_notification", _timeSinceLastGC]] remoteExec ["A3A_fnc_customHint", 0];
    missionNamespace setVariable ["A3A_lastGarbageCleanTimeNote", serverTime, true];
    // ... logging ...
};
Checks if enough time has passed since the last notification (A3A_lastGarbageCleanTimeNote).
If so, it calculates the time since the last actual cleanup (A3A_lastGarbageCleanTime), formats it, and broadcasts a hint to all players.
Updates the notification timestamp.
4. Automatic Cleanup Trigger:

Sqf

Apply
if ((serverTime - A3A_lastGarbageCleanTime) > A3A_GCThreshold) then {
    [] call A3A_fnc_garbageCleaner;
    [localize "STR_A3A_GCTracker_tracker_title", localize "STR_A3A_GCTracker_tracker_ran_gc"] remoteExec ["A3A_fnc_customHint", 0];
    // ... logging ...
};
Checks if the time since the last cleanup exceeds the defined threshold (A3A_GCThreshold).
If true, it calls A3A_fnc_garbageCleaner directly (blocking execution until it finishes).
Sends a notification that the automatic cleanup was performed.
Where it leads:

Called Functions: A3A_fnc_secondsToTimeSpan, A3A_fnc_timeSpan_format, A3A_fnc_customHint, A3A_fnc_garbageCleaner.
Depends on: isServer, A3A_GCThreshold, A3A_lastGarbageCleanTime, A3A_lastGarbageCleanTimeNote.
System Fit: This is a watchdog script. It ensures the environment doesn't degrade over long sessions without player intervention. It complements fn_garbageCleaner by automating it.
Global Variables Modified: A3A_lastGarbageCleanTimeNote (updated periodically).
Network Implications: Broadcasts notification hints to all clients. The call to A3A_fnc_garbageCleaner is local to the server.
Function Name: fn_garrisonInfo.sqf What it does: Generates a formatted text string displaying the composition and count of a garrison at a specific site. It categorizes units by type (SL, rifleman, MG, AT, etc.) and lists static weapons present in the area.

How it does that: 1. Input and Data Retrieval:

Sqf

Apply
params["_siteX"];
private _garrison = garrison getVariable [_siteX,[]];
private _size = [_siteX] call A3A_fnc_sizeMarker;
private _positionX = getMarkerPos _siteX;
private _estatic = if (_siteX in roadblocksFIA) then {localize "STR_garrison_info_technicals"} else {localize "STR_garrison_info_statics"};
private _limit = [_siteX] call A3A_fnc_getGarrisonLimit;
Retrieves the garrison array for _siteX from the garrison namespace.
Gets marker size and position.
Determines if statics should be labeled as "Technicals" or "Statics" based on marker type.
Retrieves the garrison limit (if any).
2. Unit Categorization:

Sqf

Apply
private _units = [ [],[],[],[],[],[],[],[],[],[],[] ];
{
    _units # (switch _x do {
        case (FactionGet(reb,"unitSL")): {0};
        case (FactionGet(reb,"unitCrew")): {1};
        case (FactionGet(reb,"unitRifle")): {2};
        case (FactionGet(reb,"unitMG")): {3};
        case (FactionGet(reb,"unitMedic")): {4};
        case (FactionGet(reb,"unitGL")): {5};
        case (FactionGet(reb,"unitSniper")): {6};
        case (FactionGet(reb,"unitLAT")): {7};
        case (FactionGet(reb,"unitAT")): {8};
        case (FactionGet(reb,"unitAA")): {9};
        default {10};
    }) pushBack _x;
} forEach _garrison;
Initializes an array of 11 empty arrays (10 for specific unit types, 1 for "other").
Loops through the garrison unit classnames.
Uses a switch statement to map classnames to indices (0-9). Unrecognized classes go to index 10.
Pushes the unit class name into the appropriate sub-array. This effectively groups/counters unit types.
3. Static Weapon Counting:

Sqf

Apply
{_x distance _positionX < _size} count staticsToSave
Counts static weapons in staticsToSave that are within the marker's size radius.
4. Formatting the Output String:

Sqf

Apply
_textX = format [
    "<br/><br/>Garrison units: %1%15<br/><br/>Squad Leaders: %2<br/>%14: %3<br/>Riflemen: %4<br/>Autoriflemen: %5<br/>Medics: %6<br/>Grenadiers: %7<br/>Marksmen: %8<br/>AT Men: %9<br/>AT Specialists: %10<br />AA Specialists: %11<br />Other: %12<br/>Static Weap: %13"
    , count _garrison  // %1
    , count (_units#0) // %2
    , count (_units#1) // %3
    // ... and so on for all 13 parameters
    , if (_limit != -1) then {format ["/%1", _limit]} else {""} // %15 (limit string)
];
Uses format to build an HTML-like structured text string.
Fills in the placeholders with counts of units in each category and the static weapon count.
Includes logic to append the limit if it exists (e.g., "10/15").
Where it leads:

Called Functions: A3A_fnc_sizeMarker, A3A_fnc_getGarrisonLimit.
Depends on: garrison namespace variable, roadblocksFIA, staticsToSave, Faction definitions.
System Fit: Used for UI displays (likely info bars or hints) to show garrison strength. It reads data populated by the garrison system.
Global Variables Modified: None.
Network Implications: None. This is a pure calculation function. The result is usually displayed locally.
Function Name: fn_getAggroLevelString.sqf What it does: Returns a localized string representing the aggression level (1-5) of a side.

How it does that: 1. Input Validation and Mapping:

Sqf

Apply
params ["_level"];
if(_level == 1) exitWith {localize "STR_info_bar_aggr_1"};
if(_level == 2) exitWith {localize "STR_info_bar_aggr_2"};
if(_level == 3) exitWith {localize "STR_info_bar_aggr_3"};
if(_level == 4) exitWith {localize "STR_info_bar_aggr_4"};
if(_level == 5) exitWith {localize "STR_info_bar_aggr_5"};
Error_1("Bad level recieved, cannot generate string, was %1", _level);
"None"
Takes an integer _level.
Uses a series of if checks to map the level to a localized string key (e.g., "Low", "Medium", "High").
If the level is invalid (not 1-5), it logs an error and returns a fallback string "None".
Where it leads:

Called Functions: None (other than logging).
Depends on: Localization strings.
System Fit: A utility function for UI formatting, specifically for the info bar where aggression is displayed.
Global Variables Modified: None.
Network Implications: None.
Function Name: fn_getRecentDamage.sqf What it does: Calculates the total damage (in resource units) taken by a specific side (Occupants or Invaders) within a defined circular area.

How it does that: 1. Input and Event Selection:

Sqf

Apply
params ["_side", "_center", "_radius"];
private _recentDamage = 0;
private _damageEvents = [A3A_recentDamageOcc, A3A_recentDamageInv] select (_side == Invaders);
Takes the side, center position, and radius.
Selects the appropriate damage event array (A3A_recentDamageOcc or A3A_recentDamageInv) based on the side parameter.
2. Filtering and Summation:

Sqf

Apply
_damageEvents = _damageEvents inAreaArray [_center, _radius, _radius];
{ _recentDamage = _recentDamage + (_x#2) % 1000 } forEach _damageEvents;
_recentDamage;
Filters the damage events to only include those within the specified area (using inAreaArray).
Iterates through the filtered events. The damage value is stored in the third element (#2) of the event array. The % 1000 operation extracts the damage value (likely stored in a specific format).
Sums the damage and returns the total.
Where it leads:

Called Functions: None.
Depends on: A3A_recentDamageOcc, A3A_recentDamageInv (global arrays tracking damage events).
System Fit: Used in strategic calculations, likely for balancing reinforcements or determining if a side has taken significant losses recently, influencing attack/defense logic.
Global Variables Modified: None (read-only).
Network Implications: None. Relies on server-side data.
Function Name: fn_getSideRadioTowerInfluence.sqf What it does: Determines which side (or unknown) controls a marker based on the proximity of radio towers. It compares the distance to the nearest alive tower vs. the nearest destroyed tower.

How it does that: 1. Input and Initial Check:

Sqf

Apply
_markerX = _this select 0;
if (count antennas == 0) exitWith {sideUnknown};
_positionX = getMarkerPos _markerX;
Takes the marker name.
If there are no antennas (alive) defined in the mission, it immediately returns sideUnknown as no influence can be exerted.
2. Finding Nearest Towers:

Sqf

Apply
_aliveRadioTower = [antennas, _positionX] call BIS_fnc_nearestPosition;
_destroyedRadioTower = [antennasDead, _positionX] call BIS_fnc_nearestPosition;
Uses BIS_fnc_nearestPosition to find the closest alive antenna and the closest destroyed antenna to the marker position.
3. Influence Logic:

Sqf

Apply
if (_aliveRadioTower distance _positionX > _destroyedRadioTower distance _positionX) exitWith {sideUnknown};
Compares distances. If the destroyed tower is closer than the alive tower, the marker is considered under "No Influence" (returns sideUnknown).
4. Determining Side:

Sqf

Apply
_outpost = [markersX, _aliveRadioTower] call BIS_fnc_NearestPosition;
private _sideX = sidesX getVariable [_outpost, sideUnknown];
_sideX;
Finds the marker closest to the alive tower (presumably the base/town the tower belongs to).
Retrieves the owner side of that marker from the sidesX namespace.
Returns that side (e.g., Occupants, Invaders, teamPlayer).
Where it leads:

Called Functions: BIS_fnc_nearestPosition (Engine).
Depends on: antennas, antennasDead (global arrays), markersX (global array), sidesX (namespace).
System Fit: Part of the radio tower system. Radio towers provide control (intervention) over nearby markers. This function calculates that influence for gameplay logic (e.g., can players fast travel, does the HQ need to move).
Global Variables Modified: None.
Network Implications: None.
Function Name: fn_getVehiclesAirSupport.sqf What it does: Generates a weighted array of air support vehicles and support types based on the war level and side. Used by the support system to determine what units can request/plan for.

How it does that: 1. Input and Faction Selection:

Sqf

Apply
params ["_side", "_level"];
_level = (_level max 1 min 10) - 1;
private _faction = [A3A_faction_occ, A3A_faction_inv] select (_side == Invaders);
Takes side and war level (1-10).
Clamps level to 1-10 and adjusts to 0-9 index.
Selects the correct faction data (Occupant or Invader).
2. Weighting Helper Function:

Sqf

Apply
private _fnc_addArrayToWeights = {
    params ["_vehArray", "_baseWeight"];
    { _vehWeights append [_x, _baseWeight / count _vehArray] } forEach _vehArray;
};
Defines a local function to distribute a base weight equally among all vehicles in a list.
3. Calculating Specific Weights:

Sqf

Apply
private _lightAHWeight =   [70, 65, 60, 55, 50, 45, 40, 35, 30, 25] select _level;
private _AHWeight =        [ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50] select _level;
private _casWeight =       [ 2,  4,  6,  8, 10, 12, 14, 16, 18, 20] select _level;
private _casDiveWeight =   [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10] select _level;
Defines base weights for different types of air support (Light Attack Helis, Heavy Attack Helis, CAS, Dive CAS) using arrays indexed by the war level.
4. Compensating for Missing Vehicle Types:

Sqf

Apply
if (_faction get "vehiclesHelisLightAttack" isEqualTo []) then { _AHWeight = _AHWeight + _lightAHWeight };
if (_faction get "vehiclesHelisAttack" isEqualTo []) then { _casWeight = _casWeight + _AHWeight };
if (_faction get "vehiclesPlanesCAS" isEqualTo []) then { _AHWeight = _AHWeight + _casWeight };
If a faction lacks specific vehicle types (e.g., no heavy attack helis), it redistributes their weight to other types to ensure the system always returns a valid pool.
5. Building the Weighted Array:

Sqf

Apply
if (_faction get "vehiclesPlanesCAS" isNotEqualTo []) then {
    _vehWeights append ["CAS", _casWeight];
    _vehWeights append ["CASDIVE", _casDiveWeight];
};
[_faction get "vehiclesHelisAttack", _AHWeight] call _fnc_addArrayToWeights;
[_faction get "vehiclesHelisLightAttack", _lightAHWeight] call _fnc_addArrayToWeights;
_vehWeights;
Appends support types ("CAS", "CASDIVE") and their weights.
Calls the helper function to add specific vehicle classnames and their distributed weights.
Returns the flat array [type1, weight1, type2, weight2, ...].
Where it leads:

Called Functions: None (internal logic).
Depends on: Faction data (A3A_faction_occ, A3A_faction_inv), War Level.
System Fit: Used by the support request system (e.g., A3A_fnc_requestSupport) to generate a pool of possible air support units, which is then passed to a selection function (likely BIS_fnc_selectRandomWeighted).
Global Variables Modified: None.
Network Implications: None.
Function Name: fn_getVehicleSellPrice.sqf What it does: Calculates the sell price of a vehicle, which is typically 50% of its purchase price.

How it does that: 1. Input and Price Retrieval:

Sqf

Apply
params ["_veh"];
private _typeX = if (_veh isEqualType objNull) then {typeOf _veh} else {_veh};
private _price = ([_typeX] call A3A_fnc_vehiclePrice) / 2;
_price;
Takes a vehicle object or classname.
Determines the type.
Calls A3A_fnc_vehiclePrice to get the base purchase cost.
Divides by 2 for the sell price.
Returns the price.
Where it leads:

Called Functions: A3A_fnc_vehiclePrice (Retrieves cost from A3A_vehicleResourceCosts or similar).
Depends on: Vehicle cost database (A3A_vehicleResourceCosts).
System Fit: Used by the sell vehicle system (A3A_fnc_sellVehicle) and garage/transport dialogs to display prices.
Global Variables Modified: None.
Network Implications: None.
Function Name: fn_getVehiclesGroundSupport.sqf What it does: Generates a weighted array of ground combat vehicles (tanks, IFVs, APCs, AA, etc.) for a side based on war level.

How it does that: 1. Input and Faction Selection:

Sqf

Apply
params ["_side", "_level", ["_tanksOnly", false]];
_level = (_level max 1 min 10) - 1;
private _faction = [A3A_faction_occ, A3A_faction_inv] select (_side == Invaders);
Similar to air support, takes side, level, and an optional tanksOnly flag.
2. Weight Arrays:

Defines weights for various ground vehicle types (MilCar, Car, AA, MilApc, Tank, LightTank, etc.) using arrays indexed by war level.
3. AA Vehicle Filtering:

Sqf

Apply
private _vehAA = (_faction get "vehiclesAA") select { A3A_vehicleResourceCosts get _x >= 100 };
if (_vehAA isEqualTo []) then { _tankWeight = _tankWeight + _aaWeight };
Filters AA vehicles to exclude "cheap" ones (likely static or weak) if the faction has no proper heavy AA, redistributing the weight to tanks.
4. Tank-Only Mode:

Sqf

Apply
if (_tanksOnly) exitWith { _vehWeights };
If the tanksOnly flag is true, it stops early and only returns the weights for tanks and light tanks (ignoring cars, APCs).
5. Militia and Faction Specific Logic:

Sqf

Apply
if (_side == Occupants) then {
    // Add militia vehicles
};
// Add standard vehicles
// Add AA
Conditionally adds militia vehicles only for the Occupants (Invaders don't use militia).
Calls the _fnc_addArrayToWeights helper (defined in the file) to populate _vehWeights.
Returns the weighted array.
Where it leads:

Called Functions: None (internal logic, assumes _fnc_addArrayToWeights is defined in scope or imported).
Depends on: Faction data, War level.
System Fit: Used by the AI reinforcement and attack system to spawn ground combat units.
Global Variables Modified: None.
Network Implications: None.
Function Name: fn_getVehiclesGroundTransport.sqf What it does: Generates a weighted array of ground transport vehicles (trucks, APCs, cars) for a side based on war level.

How it does that: 1. Input and Faction Selection:

Sqf

Apply
params ["_side", "_level"];
_level = (_level max 1 min 10) - 1;
private _faction = [A3A_faction_occ, A3A_faction_inv] select (_side == Invaders);
Standard input handling.
2. Weight Arrays:

Defines weights for transport types: Police, Militia Cars, Militia Trucks, Cars, Armed Cars, Trucks, Light APCs, APCs, IFVs, Tanks, Light Tanks.
3. Attribute Modifiers:

Sqf

Apply
if (_faction getOrDefault ["attributeMoreTrucks", false]) then {
    // Adjust weights for truck-heavy factions
};
Checks for a faction attribute (attributeMoreTrucks) to adjust weights if the faction relies heavily on trucks.
4. Missing Vehicle Compensation:

Checks if Light APCs, IFVs, or APCs are missing and redistributes weights (e.g., if no APCs, add weight to Trucks or Light APCs).
5. Militia Logic:

Adds Police, Militia Cars, Militia Trucks, and Militia APCs only for the Occupants.
6. Building the Array:

Uses the _fnc_addArrayToWeights helper to add vehicle classnames and weights to _vehWeights.
Returns the flat weighted array.
Where it leads:

Called Functions: None (internal logic).
Depends on: Faction data, War level.
System Fit: Used by the AI reinforcement and attack system to spawn transport units and troop carriers.
Global Variables Modified: None.
Network Implications: None.

Function Name: fn_initPetros.sqf What it does: This function initializes Petros, the leader of the rebel forces and a critical unit in Antistasi. It sets his skill, identity, equipment, and manages his behavior and death handling. It's called when the game starts to ensure Petros is properly configured and to prevent immediate death, allowing the commander to interact with him.

How it does that: Parameter validation: None. The function uses the global object petros. Variable initialization:

Sets petros skill to maximum (1)
Sets respawning variable to false
Makes Petros invulnerable via allowDamage false Identity check and setup:
Checks if Petros' face matches the expected "GreekHead_A3_01"
If not, sets identity via A3A_fnc_setIdentity with a hash map containing face, speaker, pitch, name, and last name
Sqf

Apply
if (face petros != "GreekHead_A3_01") then {
    [petros, createHashMapFromArray [["face", "GreekHead_A3_01"], ["speaker", "Male01GRE"], ["pitch", 1.1], ["firstName", "Petros"], ["lastName", ":)"]]] call A3A_fnc_setIdentity;
};
Equipment setup:

Removes headgear and goggles
Selects a random armored vest from rebel gear, falling back to civilian vests if none available
Adds the vest to Petros
Gives Petros a random rifle via A3A_fnc_randomWeapon
Gives Petros a random handgun with 10 magazines via A3A_fnc_randomWeapon
Selects the primary weapon as active
Sqf

Apply
removeHeadgear petros;
removeGoggles petros;
private _vest = selectRandomWeighted (A3A_rebelGear get "ArmoredVests");
if (_vest == "") then { _vest = selectRandomWeighted (A3A_rebelGear get "CivilianVests") };
petros addVest _vest;
[petros, "Rifles"] call A3A_fnc_randomWeapon;
[petros, "Handguns", 10] call A3A_fnc_randomWeapon;
petros selectWeapon (primaryWeapon petros);
Group leader setup:

If Petros is group leader, sets group ID to "Petros" with color 4
Disables AI movement and auto-targeting
Sets behavior to SAFE
Sqf

Apply
if (petros == leader group petros) then {
	group petros setGroupIdGlobal ["Petros","GroupColor4"];
	petros disableAI "MOVE";
	petros disableAI "AUTOTARGET";
	petros setBehaviour "SAFE";
};
Flag action installation: Executes A3A_fnc_flagaction remotely to add flag interaction actions

Sqf

Apply
[petros,"petros"] remoteExec ["A3A_fnc_flagaction", 0, petros];
Friendly fire punishment handler: Adds FF punishment event handler

Sqf

Apply
[petros,true] call A3A_fnc_punishment_FF_addEH;
HandleDamage event handler: Complex damage handling that:

Prevents damage if inflicted by self or null
Manages incapacitation state
Tracks cumulative damage
Triggers unconscious state if damaged beyond threshold
Removes handler if cumulative damage exceeds 1
Sqf

Apply
petros addEventHandler
[
    "HandleDamage",
    {
    // ... complex damage logic ...
    }
];
MPKilled event handler: Handles Petros' death:

Clears actions from Petros
Checks if killed by AI enemy (Invaders/Occupants)
If so, reduces HR and resources, starts death monitor
Otherwise, respawns Petros via A3A_fnc_createPetros
Sqf

Apply
petros addMPEventHandler ["mpkilled",
{
    removeAllActions petros;
    if (!isServer) exitWith {};

    _killer = _this select 1;
    if ((side _killer == Invaders) or (side _killer == Occupants) and !(isPlayer _killer) and !(isNull _killer)) then
    {
        // ... resource reduction and monitor spawn
    }
    else
    {
        [] call A3A_fnc_createPetros;
    };
}];
Re-enable damage: After 120 seconds, re-enables damage to Petros

Sqf

Apply
[] spawn {sleep 120; petros allowDamage true;};
Add ambient sounds/animations: Calls A3A_fnc_unitAmbient for ambient behavior

Sqf

Apply
[petros] call A3A_fnc_unitAmbient;
Where it leads: Called functions:

A3A_fnc_setIdentity: Sets Petros' identity
A3A_fnc_randomWeapon: Gives random weapons to Petros
A3A_fnc_flagaction: Adds flag interaction actions
A3A_fnc_punishment_FF_addEH: Adds friendly fire punishment handler
A3A_fnc_unconscious: Triggers unconscious state (via spawn in HandleDamage)
A3A_fnc_petrosDeathMonitor: Spawns death monitor when killed by AI
A3A_fnc_createPetros: Respawns Petros if killed by player or non-enemy
A3A_fnc_unitAmbient: Adds ambient behavior
Dependents:

Mission initialization sequence
Petros death handling system
Commander interaction system
System fit:

Part of base initialization
Ensures Petros is ready for commander interactions
Handles damage/death scenarios
Provides game mechanics continuity
Global variables modified:

petros (object modifications)
petros skill, damage state, AI settings
Network implications:

Remote execution for flag actions (0 = all machines)
MP event handler runs on server
Damage handling is local to Petros but state variables are networked
Edge cases:

Petros identity mismatch triggers re-identity
Missing armored vests falls back to civilian vests
Killers determined by side and isPlayer check
Damage re-enabled after delay regardless of state
Error handling:

!isServer check in mpkilled prevents execution on clients
Null checks for injurer in HandleDamage
Owner check for death monitor selection
Code flow: Initialize → Identity check → Equipment → AI settings → Event handlers → Ambient behavior → Damage re-enable timer

File dependencies: None in particular, uses global objects and functions.

Function Name: fn_isFrontline.sqf What it does: Determines if a given marker is a frontline position by checking if it's within distanceSPWN of any enemy-controlled marker of specific types (airports, outposts, seaports, milbases). Returns true if it's a frontline.

How it does that: Parameter validation: Takes one parameter _markerX (string - marker name) Variable initialization:

Initializes _isFrontier to false
Gets side of the marker via sidesX variable
Sqf

Apply
params ["_markerX"];
private ["_positionX","_mrkENY"];
private _isFrontier = false;
private _sideX = sidesX getVariable [_markerX,sideUnknown];
Enemy markers selection:

Creates array of enemy-controlled markers from specific types
Filters to only include markers with different side than _markerX
Sqf

Apply
private _mrkENY = (airportsX + outposts + seaports + milbases) select {sidesX getVariable [_x,sideUnknown] != _sideX};
Distance check:

If there are enemy markers, gets position of current marker
Uses findIf to check if any enemy marker is within distanceSPWN
Sets _isFrontier to true if found
Sqf

Apply
if (count _mrkENY > 0) then {
	private _positionX = getMarkerPos _markerX;
	_isFrontier = _mrkENY findIf {_positionX distance (getMarkerPos _x) < distanceSPWN} != -1;
};
Return: Returns the _isFrontier boolean

Sqf

Apply
_isFrontier
Where it leads: Called functions: None directly Dependents:

Mission system for frontline detection
AI behavior calculations
Reinforcement system
Attack planning
System fit:

Part of map state analysis
Used for combat zone detection
Helps determine if units can reinforce
Used by AI for positioning
Global variables read:

sidesX: Marker side storage
airportsX, outposts, seaports, milbases: Marker arrays
distanceSPWN: Global distance constant
Global variables modified: None

Network implications: None (read-only, local calculation)

Edge cases:

If marker not in sidesX, defaults to sideUnknown (always enemy)
Empty enemy array results in false
Marker position retrieval is safe
Error handling:

No specific error handling, relies on valid marker names
sideUnknown fallback ensures undefined markers are considered enemy
Code flow: Input → Get marker side → Filter enemy markers → Check distances → Return boolean

File dependencies: Uses global arrays and constants.

Function Name: fn_isFrontlineNoFia.sqf What it does: Determines if a given marker is a frontline for enemy forces (non-FIA) by checking distance to enemy-controlled military infrastructure. Returns true if within distanceSPWN*2 of enemy marker.

How it does that: Parameter validation: Takes one parameter _markerX (string - marker name) Variable initialization:

Initializes _isFrontier to false
Gets side of marker and determines opposite side (Invaders if Occupants, else Occupants)
Sqf

Apply
params ["_markerX"];
private ["_positionX","_mrkENY"];
private _isFrontier = false;
private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _sideOpposite = objNull;
if (_sideX == Occupants) then {
	_sideOpposite = Invaders;
} else {
	_sideOpposite = Occupants;
};
Enemy markers selection:

Creates array of enemy-controlled markers from military infrastructure types
Filters to markers with side equal to _sideOpposite
Sqf

Apply
private _mrkENY = (airportsX + milbases + outposts + seaports + factories + resourcesX) select {sidesX getVariable [_x,sideUnknown] == _sideOpposite};
Distance check:

If enemy markers exist, gets marker position
Checks if any enemy marker is within distanceSPWN*2
Sets _isFrontier accordingly
Sqf

Apply
if (count _mrkENY > 0) then {
	private _positionX = getMarkerPos _markerX;
	_isFrontier = _mrkENY findIf {_positionX distance (getMarkerPos _x) < distanceSPWN*2} != -1;
};
Return: Returns the _isFrontier boolean

Sqf

Apply
_isFrontier
Where it leads: Called functions: None directly Dependents:

Enemy territory analysis
Defense planning
Reinforcement distance calculations
System fit:

Variant of frontline detection
Used for enemy perspective analysis
Helps determine safe areas for enemy forces
Global variables read:

sidesX: Marker side storage
airportsX, milbases, outposts, seaports, factories, resourcesX: Marker arrays
distanceSPWN: Global distance constant (doubled)
Global variables modified: None

Network implications: None (local calculation)

Edge cases:

Uninitialized marker side defaults to sideUnknown
Empty enemy array results in false
Doubled distance provides larger detection radius
Error handling:

Uses sideUnknown fallback for undefined markers
No exceptions, pure boolean logic
Code flow: Input → Determine enemy side → Filter enemy markers → Check distances → Return boolean

File dependencies: Uses global arrays and constants.

Function Name: fn_joinMultipleGroups.sqf What it does: Joins several groups into a single new group with a specified name. Used for consolidating scattered units or merging reinforcements.

How it does that: Parameter validation: Takes two parameters - array of groups to join and optional group name

Sqf

Apply
private _groups = param [0];
private _groupName = param [1, groupId (_groups select 0)];
Edge case handling: If group array is empty, returns null group

Sqf

Apply
if (_groups IsEqualTo []) exitWith {
	grpNull;
};
New group creation: Creates group of same side as first group in array

Sqf

Apply
private _joinedGroup = createGroup [side (_groups select 0), true];
Unit joining: Iterates through each group and joins all units to new group

Sqf

Apply
{
	units _x join _joinedGroup;
} forEach _groups;
Group naming: Sets group ID to specified or default name

Sqf

Apply
_joinedGroup setGroupId [_groupName];
Return: Returns the new consolidated group

Sqf

Apply
_joinedGroup;
Where it leads: Called functions: None directly (uses engine commands) Dependents:

Reinforcement consolidation
AI group management
Mission objective merging
System fit:

Utility for group management
Used in reinforcement systems
Helps organize scattered forces
Global variables read: None

Global variables modified: None

Network implications:

Group creation is server-authoritative
Side determination is consistent across network
Edge cases:

Empty input array handled
Side determined from first group
Default name from first group ID
Error handling:

Null group return for empty array
Relies on valid group array
Code flow: Validate input → Create group → Join units → Set name → Return group

File dependencies: None.

Function Name: fn_localizar.sqf What it does: Returns a localized text string describing a marker's type and its nearest city. Used for UI display and mission descriptions.

How it does that: Parameter validation: Takes one parameter _siteX (string - marker name)

Sqf

Apply
params ["_siteX"];
Position and text initialization: Gets marker position and initializes empty text

Sqf

Apply
private _pos = getMarkerPos _siteX;
private _textX = "";
City name handling: If marker is a city itself, uses its name directly

Sqf

Apply
if (_siteX in citiesX) then {
	_textX = format ["%1",_siteX];
}
Nearest city determination: For non-city markers, finds nearest city

Sqf

Apply
private _city = [citiesX, _pos] call BIS_fnc_nearestPosition;
Switch statement for marker type: Uses switch with true condition to match various marker types

Airport: "Airbase near [city]"
Military base: "Military base near [city]"
Resource: "Resource near [city]"
Factory: "Factory near [city]"
Outpost: "Outpost near [city]"
Seaport: "Seaport/Riverport near [city]" (world-specific)
Control point: "Roadblock"/"Outskirts"
Military administration: "Military administration"
Carrier markers: "Support corridor"
Sqf

Apply
switch (true) do {
	case (_siteX in airportsX): {
		_textX = format [localize "STR_localizar_airbase",_city];
	};
	// ... other cases
	case (_siteX in seaports): {
		if (toLowerANSI worldName in ["enoch", "vn_khe_sanh", "esseker", "sefrouramal"]) then {
			_textX = format [localize "STR_localizar_riverport",_city];
		} else {
			_textX = format [localize "STR_localizar_seaport",_city];
		};
	};
	// ... more cases
};
Return: Returns the formatted text string

Sqf

Apply
_textX
Where it leads: Called functions:

BIS_fnc_nearestPosition: Finds nearest city
Localization system for string translation
Dependents:

UI displays
Mission descriptions
Marker update functions
Notification systems
System fit:

Localization utility
UI text generation
Player feedback system
Global variables read:

citiesX, airportsX, milbases, resourcesX, factories, outposts, seaports, controlsX, milAdministrationsX: Marker arrays
worldName: For world-specific text
Global variables modified: None

Network implications: None (local calculation)

Edge cases:

World-specific text for seaports (riverport vs seaport)
Control point detection (on road vs not)
Carrier markers have specific text
Uses worldName for geographical adaptation
Error handling:

Assumes valid marker exists
Uses toLowerANSI for case-insensitive comparison
Code flow: Input → Check if city → Find nearest city → Match marker type → Format text → Return string

File dependencies: Uses global arrays and BIS functions.

Function Name: fn_lockStatic.sqf What it does: Prevents AI garrison units from using a static weapon by setting a "lockedForAI" variable and optionally adding to flip array. Ejects any AI currently occupying the weapon.

How it does that: Parameter validation: Takes one parameter _target (object - static weapon)

Sqf

Apply
params ["_target"];
Lock setting: Sets lockedForAI variable to true on the static weapon, networked

Sqf

Apply
_target setVariable ["lockedForAI", true, true];
Array management: Updates staticsToFlip array based on AI vehicle enabling setting

If AI can use vehicles, adds to flip array
Otherwise, removes from flip array
Public variable update
Sqf

Apply
if (A3U_enableVehiclesForAI) then { staticsToFlip pushBackUnique _target } else { staticsToFlip = staticsToFlip - [_target] };
publicVariable "staticsToFlip";
AI ejection: Iterates through crew of static weapon

Skips players
Remotely executes unassignVehicle and moveOut on AI
Sqf

Apply
{
    if (isPlayer _x) then { continue };
    [_x] remoteExec ["unassignVehicle", _x];
    moveOut _x;
} forEach (crew _target);
Where it leads: Called functions: None directly (uses engine commands) Dependents:

Manual static weapon locking
Player control over garrison behavior
Defense setup customization
System fit:

Part of static weapon management
Player control over AI behavior
Tactical defense setup
Global variables read:

A3U_enableVehiclesForAI: Configuration setting
staticsToFlip: Array of statics to manage
Global variables modified:

staticsToFlip: Array updated
staticsToFlip public variable updated
Network implications:

lockedForAI variable is networked (true as third parameter)
Remote execution for AI ejection
Public variable update for staticsToFlip
Edge cases:

Empty crew array (no ejection needed)
Player crew members are skipped
Unique addition to array prevents duplicates
Error handling:

No explicit error handling, assumes valid object
Player check prevents unwanted ejection
Code flow: Lock static → Update flip array → Eject AI crew → Update network

File dependencies: None.

Function Name: fn_logPerformance.sqf What it does: Logs performance metrics about the game state, including unit counts, group counts, side distributions, and game statistics. Used for debugging and monitoring.

How it does that: Parameter validation: Takes optional message parameter with default empty string

Sqf

Apply
params [["_message", ""]];
Counter initialization: Initializes counters for different categories

Sqf

Apply
private _countGroups = 0;
private _countRebels = 0;
private _countInvaders = 0;
private _countOccupants = 0;
private _countCiv = 0;
Group counting: Iterates through all groups and counts by side

Sqf

Apply
{
	_countGroups = _countGroups + 1;
	switch(side _x) do {
		case teamPlayer: { _countRebels = _countRebels + 1; };
		case Occupants: { _countOccupants = _countOccupants + 1; };
		case Invaders: { _countInvaders = _countInvaders + 1; };
		case civilian: { _countCiv = _countCiv + 1; };
	};
} forEach allGroups;
Performance log formatting: Creates detailed formatted string with multiple metrics

Sqf

Apply
private _performanceLog = format [
	"%10 ServerFPS=%1 Players=%11 DeadUnits=%2 AllUnits=%3 UnitsAwareOfEnemies=%14 AllVehicles=%4 WreckedVehicles=%12 Entities=%13 GroupsRebels=%5 GroupsInvaders=%6 GroupsOccupants=%7 GroupsCiv=%8 GroupsTotal=%9 GroupsCombatBehaviour=%15 FactionCash=%16 HR=%17 OccAggro=%18 InvAggro=%19 Warlevel=%20 RivalsActivityLevel=%21"
	,diag_fps
	,(count alldead)
	,count allunits
	,count vehicles
	,_countRebels
	,_countInvaders
	,_countOccupants
	,_countCiv
	,_countGroups
	,_message
	,count (allPlayers)
	,{!alive _x} count vehicles
	,count entities ""
	,{!isPlayer _x && !isNull (_x findNearestEnemy _x)} count allUnits
	,{behaviour leader _x == "COMBAT"} count allGroups
	,(server getVariable "resourcesFIA") toFixed 0
	,(server getVariable "hr") toFixed 0
    ,aggressionOccupants
    ,aggressionInvaders
    ,tierWar
	,inactivityLevelRivals
];
Log output: Sends formatted string to log system

Sqf

Apply
Info(_performanceLog);
Where it leads: Called functions:

Info: Logging function
Dependents:

Debug monitoring
Performance analysis
Server administration
System fit:

Part of logging system
Performance monitoring utility
Debugging tool
Global variables read:

teamPlayer, Occupants, Invaders: Side constants
server: Server namespace for resources
aggressionOccupants, aggressionInvaders: Aggression levels
tierWar: War level
inactivityLevelRivals: Rivals activity
Global variables modified: None

Network implications: None (local calculation and logging)

Edge cases:

Handles empty groups array
Uses toFixed for numeric precision
Includes combat behavior check
Error handling:

Safe array iteration
Assumes valid global variables exist
Code flow: Initialize counters → Count groups by side → Format log string → Output log

File dependencies: Uses global variables and engine commands.

Function Name: fn_manageFlagAccess.sqf What it does: Manages flag access to garage, buying vehicles, or recruiting units. Provides cooldown based on flag flip time and shows appropriate messages for blocked access.

How it does that: Parameter validation: Takes two parameters - flag object and access type (garage, buy, unit)

Sqf

Apply
params ["_flag","_access"];
Time calculation: Gets last flip time, calculates elapsed time, computes remaining cooldown

Sqf

Apply
private _flipTime = _flag getVariable ["A3A_flagFlipTime",-99999];
private _timeSinceFlip = serverTime - _flipTime;
private _flagAccessBlockTime = A3A_flagGarageBlock * 60;
private _remainingTime = _flagAccessBlockTime - _timeSinceFlip;
Cooldown check: If time remaining is positive, block access and show message

Sqf

Apply
if (_remainingTime > 0) exitWith {
    private _prettyTime = [_remainingTime,1,1,false,2,false,true] call A3A_fnc_timeSpan_format;
    private _menus = createHashMapFromArray [
        ["garage", localize "STR_A3A_fn_base_flagaction_garage"],
        ["buy", localize "STR_A3A_fn_base_flagaction_buyveh"],
        ["unit", localize "STR_A3A_fn_base_flagaction_recruit"]
    ];
    [localize "STR_A3A_fn_base_manageFlagAccess_title", format [localize "STR_A3A_fn_base_manageFlagAccess_main",_menus get _access, _prettyTime]] call A3A_fnc_customHint;
};
Access granting: If no cooldown, opens appropriate dialog or spawns recruitment function

Sqf

Apply
switch (_access) do {
    case ("garage"): {createDialog 'HR_GRG_VehicleSelect'};
    case ("buy"): {createDialog "A3A_BuyVehicleDialog"};
    case ("unit"): {if (A3A_GUIDevPreview) then {createDialog "A3A_RecruitDialog";} else {[] spawn A3A_fnc_unit_recruit;}};
};
Where it leads: Called functions:

A3A_fnc_timeSpan_format: Formats time for display
A3A_fnc_customHint: Shows cooldown message
A3A_fnc_unit_recruit: Spawns recruitment function
Dependents:

Flag interaction system
Player accessibility management
System fit:

Part of flag interaction system
Manages cooldowns
Controls access to base functions
Global variables read:

A3A_flagGarageBlock: Cooldown duration in minutes
serverTime: Current server time
Global variables modified: None

Network implications:

Uses serverTime which is synchronized
Flag variable is assumed to be networked
Edge cases:

Negative flip time defaults to very large elapsed time
Hash map for menu localization
Condition for preview mode
Error handling:

Assumes flag has A3A_flagFlipTime variable
Safe hash map creation
Code flow: Calculate times → Check cooldown → Show message or open dialog

File dependencies: Uses flag variable and global constants.

Function Name: fn_markerChange.sqf What it does: Changes marker ownership between sides, updates garrisons, triggers counterattacks, manages static weapons, and handles notification and reward systems. Core function for territory control.

How it does that: Parameter validation: Takes two parameters - winning side and marker name

Sqf

Apply
params ["_winner", "_markerX"];
Server check: Exits if not running on server

Sqf

Apply
if (!isServer) exitWith {};
Early exit checks: Multiple checks to prevent unnecessary processing

Don't allow teamPlayer to take airports/milbases below war level 3
Don't change if already owned by winner
Exit if marker already in process
Sqf

Apply
if ((_winner == teamPlayer) and (_markerX in airportsX) and (tierWar < 3)) exitWith {};
if ((_winner == teamPlayer) and (_markerX in milbases) and (tierWar < 3)) exitWith {};
if ((_winner == teamPlayer) and (sidesX getVariable [_markerX,sideUnknown] == teamPlayer)) exitWith {};
if ((side _winner == Occupants) and (sidesX getVariable [_markerX,sideUnknown] == Occupants)) exitWith {};
if ((side _winner == Invaders) and (sidesX getVariable [_markerX,sideUnknown] == Invaders)) exitWith {};
if (_markerX in markersChanging) exitWith {};
markersChanging pushBackUnique _markerX;
Variable initialization: Gets marker position, loser side, side array, and other variables

Sqf

Apply
private _positionX = getMarkerPos _markerX;
private _loser = sidesX getVariable [_markerX,sideUnknown];
private _sides = [teamPlayer,Occupants,Invaders];
private _other = "";
private _textX = "";
private _prestigeOccupants = [0, 0];
private _prestigeInvaders = [0, 0];
private _flagX = objNull;
private _size = [_markerX] call A3A_fnc_sizeMarker;
Flag detection: Finds flag object near marker if not in cities and not despawned

Sqf

Apply
if ((!(_markerX in citiesX)) and (spawner getVariable _markerX != 2)) then {
	private _flagsX = nearestObjects [_positionX, ["FlagCarrierCore"], _size];
	_flagX = _flagsX select 0;
};
if (isNil "_flagX") then {_flagX = objNull};
Loser text determination: Gets faction name for loser side

Sqf

Apply
switch (_loser) do {
	case teamPlayer: {
		_textX = format ["%1 ",FactionGet(reb,"name")];
		[] call A3A_fnc_tierCheck;
	};
	case Occupants: {
		_textX = format ["%1 ",FactionGet(occ,"name")];
	};
	case Invaders: {
		_textX = format ["%1 ",FactionGet(inv,"name")];
	};
	default {
		Error_2("Not supported side of %1 marker - %2", _markerX, str _loser);
	};
};
Garrison update: Clears and resets garrison data for the marker

Sqf

Apply
garrison setVariable [_markerX,[],true];
sidesX setVariable [_markerX,_winner,true];
// New garrison system reset
garrison setVariable [format ["%1_garrison", _markerX], [], true];
garrison setVariable [format ["%1_other", _markerX], [], true];
garrison setVariable [format ["%1_requested", _markerX], [], true];
TeamPlayer capture handling: If rebels capture the marker

Get old garrison units and surrender them
Calculate max defense spend resources
Spawn counterattack if resources sufficient
Add support strikes to arrays
Sqf

Apply
if (_winner == teamPlayer) then
{
	// Old garrison surrender
	private _oldGarrison = units _loser select { _x getVariable ["markerX", ""] == _markerX };
	{ [_x] remoteExec ["A3A_fnc_surrenderAction", _x] } forEach _oldGarrison;

	// Resource calculation
	private _resources = [_loser, teamPlayer, _markerX, 0.6] call A3A_fnc_maxDefenceSpend;
	private _minAttack = (1 + random 0.5) * A3A_balanceResourceRate;

	if (_resources >= _minAttack) then {
		private _vehCount = round (random 0.5 + _resources / A3A_balanceVehicleCost);
		private _reveal = [markerPos _markerX] call A3A_fnc_calculateSupportCallReveal;
		_reveal = [_loser, markerPos _markerX, _reveal] call A3A_fnc_useRadioKey;

		[[_markerX, _loser, _vehCount, _reveal], "A3A_fnc_singleAttack"] call A3A_fnc_scheduler;

		// Support arrays
		A3A_supportStrikes pushBack [_loser, "TROOPS", markerPos _markerX, time + 2700, 2700, _resources];
		A3A_supportSpends pushBack [_loser, markerPos _markerX, markerPos _markerX, _resources, time];
	};
}
Enemy capture handling: If enemy captures marker

Determines marker type
Gets preference from garrison system
Creates random garrison and request lines
Sqf

Apply
else
{
	private _type = "Other";
	switch (true) do
	{
	    case (_markerX in airportsX): {_type = "Airport"};
		case (_markerX in outposts): {_type = "Outpost"};
		case (_markerX in milbases): {_type = "MilitaryBase"};
		case (_markerX in citiesX): {_type = "City"};
	};
	private _preference = garrison getVariable (format ["%1_preference", _type]);
	private _indexToReinf = floor (random count _preference);
	private _garrison = [];
	private _request = [];
	{
		private _line = [_x, _winner] call A3A_fnc_createGarrisonLine;
		if (_forEachIndex == _indexToReinf) then {
			_garrison pushBack ["", [], []];
			_request pushBack _line;
		} else {
			_garrison pushBack _line;
			_request pushBack ["", [], []];
		};
	} forEach _preference;
	garrison setVariable [format ["%1_garrison", _markerX], _garrison, true];
	garrison setVariable [format ["%1_requested", _markerX], _request, true];
};
Reinforcement state update: Updates reinforcement state for both old and new sides

Sqf

Apply
[_markerX, [_loser, _winner]] call A3A_fnc_updateReinfState;
Killzone cleanup: Removes killzone entries near friendly airfield

Sqf

Apply
if !(_markerX in airportsX) then
{
	private _friendlyAirports = airportsX select { _winner == sidesX getVariable [_x, sideUnknown] };
	if (count _friendlyAirports > 0) then
	{
		private _nearAirport = [_friendlyAirports, _markerX] call BIS_fnc_nearestPosition;
		private _kzlist = killZones getVariable [_nearAirport, []];
		_kzlist = _kzlist - [_markerX];
		killZones setVariable [_nearAirport, _kzlist, true];
	};
};
Marker update: Updates visual marker

Sqf

Apply
_nul = [_markerX] call A3A_fnc_mrkUpdate;
Side array manipulation: Removes winner and loser, gets "other" side

Sqf

Apply
_sides = _sides - [_winner,_loser];
_other = _sides select 0;
Type-specific handling: Massive switch statement for different marker types

Airport: Updates prestige, adds city support, sends notifications
Outpost: Updates prestige, sends notifications
Seaport: Riverport vs seaport text, sends notifications
Factory/Resource: Prestige updates, notifications
Military base: Complex handling including city support and counterintelligence
Static weapon handling: Converts nearby statics to teamPlayer on capture

Sqf

Apply
if (_winner == teamPlayer) then {
	private _staticWeapons = nearestObjects [_positionX, ["LandVehicle", "Ship"], _size * 1.5, true];
	{
		[_x, teamPlayer, true] call A3A_fnc_vehKilledOrCaptured;
		if !(_x in staticsToSave) then {
			staticsToSave pushBack _x;
		};
	} forEach _staticWeapons;
	publicVariable "staticsToSave";
}
Flag handling: Updates flag ownership and actions

Sqf

Apply
if (!isNull _flagX) then
{
	if (_winner == teamPlayer) then
	{
		[_flagX,"SDKFlag"] remoteExec ["A3A_fnc_flagaction",0,_flagX];
		[_flagX,FactionGet(reb,"flagTexture")] remoteExec ["setFlagTexture",_flagX];
	}
	else
	{
		[_flagX,"remove"] remoteExec ["A3A_fnc_flagaction",0,_flagX];
		if (_winner == Occupants) then {
			[_flagX,FactionGet(occ,"flagTexture")] remoteExec ["setFlagTexture",_flagX];
		} else {
			[_flagX,FactionGet(inv,"flagTexture")] remoteExec ["setFlagTexture",_flagX];
		};
	};
};
Defeat condition checks: If enemy captures after being defeated

Sqf

Apply
if (areInvadersDefeated && {_winner == Invaders}) then {
	areInvadersDefeated = false;
	publicVariable "areInvadersDefeated";
	"CSAT_carrier" setMarkerAlpha 1;
};
Final cleanup: Remove from changing array, trigger event, check defeat conditions

Sqf

Apply
markersChanging = markersChanging - [_markerX];
["markerChange", [_markerX, _winner]] call EFUNC(Events,triggerEvent);

if (_winner == teamPlayer) then {
	[_loser] remoteExecCall ["SCRT_fnc_common_defeatFactionIfPossible", 2];
};
Where it leads: Called functions:

A3A_fnc_sizeMarker: Gets marker size
A3A_fnc_surrenderAction: Makes garrison units surrender
A3A_fnc_maxDefenceSpend: Calculates available defense resources
A3A_fnc_calculateSupportCallReveal: Determines support call visibility
A3A_fnc_useRadioKey: Uses radio key for support calls
A3A_fnc_scheduler: Schedules counterattack
A3A_fnc_createGarrisonLine: Creates garrison line
A3A_fnc_updateReinfState: Updates reinforcement state
A3A_fnc_mrkUpdate: Updates marker visuals
A3A_fnc_vehKilledOrCaptured: Handles static weapon conversion
A3A_fnc_flagaction: Updates flag interactions
Event system for "markerChange"
Defeat condition checking function
Dependents:

Territory capture missions
AI attack/defense systems
Mission progression
Player reward systems
System fit:

Core territory control function
Balances game economy and combat
Manages map state transitions
Global variables read:

markersChanging: Prevents duplicate processing
tierWar, distanceSPWN, A3A_balanceResourceRate, etc.: Balance constants
garrison, sidesX, killZones, spawner: Game state namespaces
A3A_supportStrikes, A3A_supportSpends: Support arrays
staticsToSave: Saved static weapons
areInvadersDefeated, areOccupantsDefeated: Defeat states
Global variables modified:

markersChanging: Array updated
garrison: Multiple garrison variables updated
sidesX: Marker side updated
killZones: Killzone cleanup
staticsToSave: Added converted statics
A3A_supportStrikes, A3A_supportSpends: Support arrays updated
Defeat variables if applicable
Flag variables
Network implications:

Remote execution for surrender actions, flag actions, setFlagTexture
Event system trigger
Public variable updates for global states
Networked variable updates for garrison and side
Error handling:

Exit if not server
Multiple early exit conditions
Type validation for loser side
Null check for flag
Killzone array safety
Code flow: Validate input → Check conditions → Update state → Process capture → Handle aftermath → Clean up

File dependencies: Extensive use of global game systems.

Function Name: fn_moveHQ.sqf What it does: Initiates HQ relocation process if possible. Manages moving Petros to commander, handles garrison refunds, and updates marker states.

How it does that: Parameter validation: None, called without parameters Pre-move check: Calls A3A_fnc_canMoveHQ to verify if move is possible

Sqf

Apply
private _possible = [] call A3A_fnc_canMoveHQ;
if !(_possible#0) exitWith {};
Petros management: Moves Petros to commander's group, deletes old group

Sqf

Apply
private _groupPetros = group petros;
[petros] join theBoss;
deleteGroup _groupPetros;
Petros behavior: Updates Petros behavior for movement

Sqf

Apply
petros setBehaviour "AWARE";
petros enableAI "MOVE";
petros enableAI "AUTOTARGET";
Marker updates: Hides respawn marker for both teamPlayer and civilian sides

Sqf

Apply
[respawnTeamPlayer, 0, teamPlayer] call A3A_fnc_setMarkerAlphaForSide;
[respawnTeamPlayer, 0, civilian] call A3A_fnc_setMarkerAlphaForSide;
Garrison handling: Processes HQ garrison

Checks for enemy units near HQ
Refunds dead units and deleted vehicles
Clears garrison variable
Notifies player of refund
Sqf

Apply
private _garrison = garrison getVariable ["Synd_HQ", []];
private _posHQ = getMarkerPos "Synd_HQ";

if (count _garrison > 0) then
{
    private _costs = 0;
    private _hr = 0;
    if (allUnits findIf {(alive _x) && (!captive _x) && ((side (group _x) == Occupants) || (side (group _x) == Invaders)) && {_x distance2D _posHQ < 500}} != -1) then
    {
        [localize "STR_antistasi_journal_entry_header_commander_5", localize "STR_A3A_Base_moveHq_garrison_1"] call A3A_fnc_customHint;
    }
    else
    {
        private _size = ["Synd_HQ"] call A3A_fnc_sizeMarker;
        {
            if ((side (group _x) == teamPlayer) && (!(_x getVariable ["spawner",false])) && (_x distance2D _posHQ < _size) && (_x != petros)) then
            {
                if (!alive _x) then
                {
                    private _unitType = _x getVariable "unitType";
                    if (_unitType in FactionGet(reb,"unitsSoldiers")) then
                    {
                        if (_unitType == FactionGet(reb,"unitCrew")) then
                        {
                            _costs = _costs - ([(FactionGet(reb,"staticMortars")) # 0] call A3A_fnc_vehiclePrice)
                        };
                        _hr = _hr - 1;
                        _costs = _costs - (server getVariable (_unitType));
                    };
                };
                if (typeOf (vehicle _x) in FactionGet(reb,"staticMortars")) then
                {
                    deleteVehicle vehicle _x
                };
                deleteVehicle _x;
            };
        } forEach allUnits;
    };
    {
        if (_x == FactionGet(reb,"unitCrew")) then
        {
            _costs = _costs + ([(FactionGet(reb,"staticMortars")) # 0] call A3A_fnc_vehiclePrice)
        };
        _hr = _hr + 1;
        _costs = _costs + (server getVariable _x);
    } forEach _garrison;
    [_hr,_costs] remoteExec ["A3A_fnc_resourcesFIA",2];
    garrison setVariable ["Synd_HQ",[],true];
    [localize "STR_antistasi_journal_entry_header_commander_5", format [localize "STR_A3A_Base_moveHq_garrison_2",_costs,_hr, A3A_faction_civ get "currencySymbol"]] call A3A_fnc_customHint;
};
Where it leads: Called functions:

A3A_fnc_canMoveHQ: Validates if move is possible
A3A_fnc_sizeMarker: Gets HQ marker size
A3A_fnc_vehiclePrice: Gets vehicle price for crew refund
A3A_fnc_resourcesFIA: Updates resources
A3A_fnc_customHint: Shows notifications
Dependents:

Commander relocation
HQ management
Resource management
System fit:

HQ management system
Resource calculation
Commander assignment
Global variables read:

petros: Petros object
theBoss: Commander object
respawnTeamPlayer: HQ marker
garrison: HQ garrison data
FactionGet(reb, ...): Rebel faction data
Global variables modified:

garrison: Cleared for HQ
petros: Joined new group
Resource variables (via remote execution)
Network implications:

Remote execution for resource update
Group changes (local to machine executing)
No public variables modified directly
Edge cases:

Early exit if cannot move
Enemy detection near HQ
Crew vs soldier refund calculation
Static mortar special handling
Error handling:

Early validation check
Distance check for enemy units
Unit type validation
Code flow: Check validity → Move Petros → Update markers → Process garrison refund → Clean up

File dependencies: Uses HQ marker, garrison data, and faction data.

Function Name: fn_moveOutCrew.sqf What it does: Ejects all crew (including UAV AI) from a vehicle. Restricts usage to vehicle owner or commander.

How it does that: Parameter validation: Takes two parameters - player attempting to move crew and vehicle object

Sqf

Apply
params [
    ["_player",objNull,[objNull]],
    ["_veh",objNull,[objNull]]
];
Null checks: Validates both parameters are valid objects

Sqf

Apply
if (isNull _player) exitWith { Error("_player is null.") };
if (isNull _vehicle) exitWith {
    [localize "STR_A3A_Base_moveOutCrew_header", localize "STR_A3A_reinf_airstrike_not_looking_at_veh"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};
Owner check: Verifies player owns vehicle or is commander

Sqf

Apply
_owner = _vehicle getVariable ["ownerX",""];
if (_owner isNotEqualTo "" && {getPlayerUID _player isNotEqualTo _owner}) exitWith {
    [localize "STR_A3A_Base_moveOutCrew_header", localize "STR_A3A_Base_sellVehicle_err2"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};
Side check: Prevents moving crew from enemy vehicles

Sqf

Apply
if ((side _vehicle == west) || (side _vehicle == east)) exitWith {
    [localize "STR_A3A_Base_moveOutCrew_header", localize "STR_A3A_Base_moveOutCrew_err0"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};
UAV handling: Special case for UAVs - delete crew instead of moving

Sqf

Apply
if (unitIsUAV _vehicle) then {
    {
        deleteVehicle _x;  
    } forEach _crewgroup;
};
Crew ejection: Unassign, eject, moveOut, leaveVehicle for all crew

Sqf

Apply
{
    [_x] remoteExec ["unassignVehicle", _x];
    unassignVehicle _x;
    _x action ["Eject", _vehicle];
} forEach _crewgroup;

{
	moveOut _x 
} forEach _crewgroup;

{
    _x leaveVehicle _vehicle;
} forEach _crewgroup;
Success message: Notify player of success

Sqf

Apply
[localize "STR_A3A_Base_moveOutCrew_header", localize "STR_A3A_Base_moveOutCrew_success"] remoteExecCall ["A3A_fnc_customHint",_player];
Where it leads: Called functions:

SCRT_fnc_misc_deniedHint: Shows denial message
A3A_fnc_customHint: Shows success message
Dependents:

Vehicle management
Crew control
Owner enforcement
System fit:

Vehicle control system
Owner restriction system
Global variables read: None

Global variables modified: None

Network implications:

Remote execution for hints
UnassignVehicle remote execution
Edge cases:

UAV special handling (delete crew)
Null vehicle/player
Owner validation
Enemy vehicle restriction
Error handling:

Null checks
Owner validation
Side validation
Code flow: Validate input → Check ownership → Eject crew → Notify player

File dependencies: None.

Function Name: fn_mrkUpdate.sqf What it does: Updates visual representation of a marker based on its current side, type, and garrison status. Changes marker type, color, and text.

How it does that: Parameter validation: Takes one parameter - marker name

Sqf

Apply
params ["_marker"];
Variable initialization: Gets duplicate marker name, marker side, and faction

Sqf

Apply
private _mrkD = format ["Dum%1",_marker];
private _mrkSide = sidesX getVariable _marker;
private _faction = Faction(_mrkSide);
Type handling: Handles airport markers specially (different flag type)

Sqf

Apply
if (_marker in airportsX) then {
    _mrkD setMarkerTypeLocal (_faction get "flagMarkerType");
    _mrkD setMarkerColorLocal "Default";
}
Color/type determination: For non-airport markers

Destroyed cities get black color
TeamPlayer markers get specific types and color
Enemy markers get appropriate types and colors
Sqf

Apply
else {
    if (_marker in destroyedSites and _marker in citiesX) exitWith { _mrkD setMarkerColorLocal "ColorBlack" };
    if (_mrkSide == teamPlayer) exitWith {
        if (_marker in milbases) then {
            _mrkD setMarkerTypeLocal "n_hq";
        };
        if (_marker in seaports) then {
            _mrkD setMarkerTypeLocal "n_naval";
        };
        _mrkD setMarkerColorLocal colorTeamPlayer;
    };

    if (_marker in milbases) then {
        private _markerType = if (_mrkSide == Invaders) then {"o_hq"} else {"b_hq"};
        _mrkD setMarkerTypeLocal _markerType;
    };
    if (_marker in seaports) then {
        private _markerType = if (_mrkSide == Invaders) then {"o_naval"} else {"b_naval"};
        _mrkD setMarkerTypeLocal _markerType;
    };

    _mrkD setMarkerColorLocal ([colorOccupants, colorInvaders] select (_mrkSide == Invaders));
};
Text generation: Calls localization function to get descriptive text

Sqf

Apply
private _mrkText = call {
    if (_marker in airportsX) exitWith { format [localize "STR_airbase", _faction get "name"] };
    if (_marker in outposts) exitWith { format [localize "STR_outpost", _faction get "name"] };
    if (_marker in resourcesX) exitWith { localize "STR_resources" };
    if (_marker in factories) exitWith { localize "STR_factory" };
    if (_marker in milbases) exitWith { format [localize "STR_milbase", _faction get "name"] };
    if (_marker in seaports) exitWith {
        if (toLowerANSI worldName in ["enoch", "vn_khe_sanh", "esseker"]) then {
            localize "STR_port_river"
        } else {
            localize "STR_port_sea"
        }
    };
    ""; // city
};
Garrison display: For teamPlayer markers, adds garrison count and limit

Sqf

Apply
if (_mrkSide == teamPlayer) then {
    private _numTroops = count (garrison getVariable [_marker, []]);
    private _limit = [_marker] call A3A_fnc_getGarrisonLimit;
    if (_numTroops > 0) then {
        _mrkText = format ["%1: %2%3",
            _mrkText,
            _numTroops,
            if (_limit != -1) then {format ["/%1", _limit]} else {""}
        ];
    };
};
Text application: Sets marker text

Sqf

Apply
_mrkD setMarkerText _mrkText;
Where it leads: Called functions:

Faction: Gets faction data
A3A_fnc_getGarrisonLimit: Gets garrison capacity
Localization functions for strings
Dependents:

Territory update system
UI updates
Mission markers
System fit:

Visual marker system
Territory feedback system
Player information system
Global variables read:

sidesX: Marker side storage
destroyedSites: Destroyed markers
airportsX, milbases, outposts, resourcesX, factories, seaports: Marker arrays
colorOccupants, colorInvaders, colorTeamPlayer: Color constants
garrison: Garrison data
Global variables modified: None (marker updates only)

Network implications:

Local marker updates only (setMarkerTypeLocal, setMarkerColorLocal)
No network synchronization
Edge cases:

Airport markers get special treatment
Destroyed cities get black color
TeamPlayer markers show garrison count
Riverport vs seaport world detection
Error handling:

Assumes valid marker
Safe faction lookup
Garrison data safety
Code flow: Get marker info → Set type/color → Generate text → Add garrison info → Update marker

File dependencies: Uses global marker arrays and faction data.

Function Name: fn_mrkWIN.sqf What it does: Handles flag capture sequence for a marker. Manages capture UI, enemy proximity checks, and triggers marker change when conditions are met.

How it does that: Parameter validation: Takes flag object, caller, action ID, and arguments

Sqf

Apply
params ["_flagX","_caller","_actionID","_argument"];
Client check: Ensures called locally by player

Sqf

Apply
if (_caller isNotEqualTo player) exitWith {
    ServerError("Flag action mrkWIN must be locally called");
};
Marker identification: Finds nearest marker of appropriate types

Sqf

Apply
private _markerX = [airportsX + resourcesX + factories + outposts + seaports + milbases, getPosATL _flagX] call BIS_fnc_nearestPosition;
Hidden markers: Reveal marker if setting enabled

Sqf

Apply
if (hideEnemyMarkers) then {
    "Dum"+_markerX setMarkerAlpha 1;
};
Grid square calculation: Formats position for logging

Sqf

Apply
private _markerPos = getMarkerPos _markerX;
private _outpostGridSquare = ((_markerPos#0 toFixed 0) call A3A_fnc_pad_3Digits) + ((_markerPos#1 toFixed 0) call A3A_fnc_pad_3Digits);
Early exit checks:

Already owned by teamPlayer
Player cannot fight
Player undercover
War level restrictions for airports/milbases
Sqf

Apply
if (sidesX getVariable [_markerX,sideUnknown] == teamPlayer) exitWith {};
if !(player call A3A_fnc_canFight) exitWith { ServerError("Action somehow used by dead or unconscious player?") };
if (captive player) exitWith { ... };
if ((_markerX in airportsX) and {tierWar < 3}) exitWith { ... };
if ((_markerX in milbases) and {tierWar < 3}) exitWith { ... };
Flag lock check: Prevents rapid captures

Sqf

Apply
private _flagCaptureETA = _flagX getVariable ["A3A_flagCaptureETA", -1];
if(_flagCaptureETA > serverTime) exitWith {
    private _timeSpan = [_flagCaptureETA - serverTime] call A3A_fnc_secondsToTimeSpan;
    private _secondsLeftString = [_timeSpan,0,0,false,1] call A3A_fnc_timeSpan_format;
    [localize "STR_A3A_Base_mrkWin_header", format [localize "STR_A3A_Base_mrkWin_flagpole_used", _secondsLeftString]] call SCRT_fnc_misc_deniedHint;
};
Lock flag: Set 10 second lock

Sqf

Apply
_flagX setVariable ["A3A_flagCaptureETA", serverTime + 10, true];
Proximity assessment: Calculate friendly vs enemy value in capture radius

Sqf

Apply
private _capRadius = ((markerSize _markerX select 0) + (markerSize _markerX select 1)) / 2;
_capRadius = 50 max _capRadius;

private _rebelValue = 0;
private _enemyValue = 0;
{
    if !(_x call A3A_fnc_canFight) then { continue };
    private _value = linearConversion [_capRadius/2, _capRadius, _markerPos distance2d _x, 1, 0, true];
    if (side _x == teamPlayer) then {
        _rebelValue = _rebelValue + _value;
        continue;
    };
    if (side _x == Occupants or side _x == Invaders) then {
        _enemyValue = _enemyValue + _value;
        player reveal _x;
    };
} forEach (allUnits inAreaArray [_markerPos, _capRadius, _capRadius]);
Enemy proximity check: Exit if too many enemies

Sqf

Apply
if (_enemyValue > 2*_rebelValue) exitWith {
    ServerInfo_4("Outpost at %1 (%2): Flag capture cancelled due to enemy value (%3) greater than 2*rebel value (%4)", _outpostGridSquare, _markerX, _enemyValue, _rebelValue);
    [localize "STR_A3A_Base_mrkWin_header", localize "STR_A3A_Base_mrkWin_nearenemy"] call SCRT_fnc_misc_deniedHint;
};
Capture sequence setup: Set flag, play animation, create cancel action

Sqf

Apply
A3A_isPlayerCapturingFlag = true;
player playMove "MountSide";

private _cancellationToken = [false];
private _cancelActionID = player addAction [localize "STR_A3A_Base_mrkWin_abort",
{
    params ["_target","_caller","_actionID","_cancellationToken"];
    _cancellationToken set [0, true];
    A3A_isPlayerCapturingFlag = nil;
    player switchMove "";
    player removeAction _actionID;
    [localize "STR_A3A_Base_mrkWin_header", localize "STR_A3A_Base_mrkWin_abort_2"] call A3A_fnc_customHint;
}, _cancellationToken];
Capturing: Sleep 8 seconds for animation, check cancellation

Sqf

Apply
sleep 8;

if (_cancellationToken #0) exitWith {
    ServerInfo_3("Outpost at %1 (%2): Flag capture aborted by %3", _outpostGridSquare, _markerX, str player);
};
A3A_isPlayerCapturingFlag = nil;
player removeAction _cancelActionID;
player playMove "";
Rewards: Grant score and money to nearby teamPlayer units

Sqf

Apply
{
    if (isPlayer _x) then
    {
        [round (2 * tierWar),_x] remoteExec ["A3A_fnc_addScorePlayer",_x];
        [round (100 * tierWar),_x] remoteExec ["A3A_fnc_addMoneyPlayer",_x];
        if (captive _x) then
        {
            [_x,false] remoteExec ["setCaptive",_x];
        };
    };
} forEach ([_capRadius,0,_markerPos,teamPlayer] call A3A_fnc_distanceUnits);
Trigger marker change: Remote execute marker change to server

Sqf

Apply
[teamPlayer,_markerX] remoteExec ["A3A_fnc_markerChange",2];
Where it leads: Called functions:

BIS_fnc_nearestPosition: Finds nearest marker
A3A_fnc_pad_3Digits: Pads number for grid square
A3A_fnc_canFight: Checks if player can fight
A3A_fnc_secondsToTimeSpan: Converts seconds to readable format
A3A_fnc_timeSpan_format: Formats time span
SCRT_fnc_misc_deniedHint: Shows denial message
A3A_fnc_customHint: Shows status messages
A3A_fnc_addScorePlayer: Awards score
A3A_fnc_addMoneyPlayer: Awards money
A3A_fnc_markerChange: Triggers territory change
Dependents:

Flag capture missions
Territory control
Player rewards
System fit:

Flag capture system
Territory mechanics
Player interaction
Global variables read:

hideEnemyMarkers: Display setting
tierWar: War level
sidesX: Marker side storage
Global variables modified:

A3A_isPlayerCapturingFlag: Capture state
flagX: Capture ETA variable
Network implications:

Remote execution for marker change
Remote execution for rewards
Flag variable is networked
Edge cases:

Already owned marker
Dead/unconscious player
Undercover player
War level restrictions
Enemy proximity
Flag lock timing
Cancellation during capture
Error handling:

Client-side validation
Early exits for invalid states
Enemy proximity calculation
Code flow: Validate input → Check conditions → Assess proximity → Capture animation → Award rewards → Trigger change

File dependencies: Uses global constants and marker arrays.

Function Name: fn_numericRank.sqf What it does: Converts rank string to numeric ID and next rank string. Used for progression calculations.

How it does that: Parameter validation: Takes one parameter - unit object

Sqf

Apply
params ["_unit"];
Rank retrieval: Gets unit's rank from variable or default

Sqf

Apply
private _rankX = _unit getVariable ["rankX","PRIVATE"];
Switch statement: Maps rank string to numeric ID and next rank

Sqf

Apply
switch (_rankX) do {
	case "PRIVATE": {_idRank= 1; _newRank = "CORPORAL"};
	case "CORPORAL": {_idRank = 2; _newRank = "SERGEANT"};
	case "SERGEANT": {_idRank = 3; _newRank = "LIEUTENANT"};
	case "LIEUTENANT": {_idRank = 4; _newRank = "CAPTAIN"};
	case "CAPTAIN": {_idRank = 5; _newRank = "MAJOR"};
	case "MAJOR": {_idRank = 6; _newRank = "COLONEL"};
	case "COLONEL": {_idRank = 7; _newRank = "COLONEL"};
};
Return: Returns array with numeric ID and next rank string

Sqf

Apply
[_idRank,_newRank];
Where it leads: Called functions: None directly Dependents:

Rank progression system
Score calculations
Reward systems
System fit:

Part of rank/progression system
Used for calculations
Global variables read: None

Global variables modified: None

Network implications: None (local calculation)

Edge cases:

COLONEL ranks to itself
Default rank is PRIVATE
Error handling:

Assumes valid rank string
Defaults to PRIVATE if not found
Code flow: Get rank → Switch to numeric/next rank → Return array

File dependencies: None.

Function Name: fn_onHeadlessClientDisconnect.sqf What it does: Handles headless client disconnection. Checks if units were owned by the HC and provides error messages if so.

How it does that: Parameter validation: Takes client ID from disconnect parameters

Sqf

Apply
private _owner = param [4];
Check if in HC array: Verifies if the client was a headless client

Sqf

Apply
if (_owner in hcArray) then
{
	Info_2("Headless client ID %1 disconnected from HC array %2", _owner, hcArray);
Unit count check: Counts units owned by the disconnected client

Sqf

Apply
	if ({owner _x == _owner} count allUnits > 0) then
	{
		A3A_HCErrorHandle = [] spawn {
			while {true} do
			{
				[petros,"hint",localize "STR_hints_hc_restart", localize "STR_hints_hc_header"] remoteExec ["A3A_fnc_commsMP"];
				sleep 30;
			};
		};
	}
	else
	{
		hcArray = hcArray - [_owner];
	};
};
Where it leads: Called functions:

A3A_fnc_commsMP: Sends message to players
Dependents:

Headless client management
Multi-machine setup
System fit:

HC error handling
Server stability system
Global variables read:

hcArray: Headless client ID array
petros: Message sender
Global variables modified:

hcArray: Removes disconnected client
A3A_HCErrorHandle: Error handling script
Network implications:

Remote message to all players
Only affects server and players
Edge cases:

Units remain after disconnect → Spams messages
No units → Clean removal from array
Error handling:

Periodic message loop
Client ID validation
Code flow: Check if HC → Count owned units → Error or clean up

File dependencies: Uses global HC array and petros object.

Function Name: fn_onPlayerDisconnect.sqf What it does: Handles player disconnection: manages boss transfer, PvP tracking, saves player data, and cleans up player unit.

How it does that: Parameter validation: Takes unit, client ID, and player UID

Sqf

Apply
params ["_unit", "_id", "_uid"];
Logging: Logs disconnect information

Sqf

Apply
Info_3("Player disconnected with id %1 and unit %2 on side %3", _uid, _unit, side _unit);
Early exit: If unit is sideLogic or has no UID (likely HC)

Sqf

Apply
if (side _unit == sideLogic || {_uid == ""}) exitWith {
    Error("Exiting onPlayerDisconnect due to no UID or sideLogic unit. Possible Headless Client disconnect?");
};
Remote control detection: Finds real unit if player was remote controlling

Sqf

Apply
private _realUnit = _unit getVariable ["owner", _unit];
Boss transfer: If disconnected player was commander

Remove eligible status
Move Petros to HQ if in same group
Assign new boss
Sqf

Apply
if (_realUnit == theBoss) then
{
	if (group petros == group _realUnit) then { [] spawn A3A_fnc_buildHQ };

	// Remove our real unit from boss
	_realUnit setVariable ["eligible", false, true];
	[] call A3A_fnc_assignBossIfNone;
};
PvP tracking: If side is teamPlayer or unknown, track PvP eligibility

Sqf

Apply
if (side group _unit == teamPlayer || side group _unit == sideUnknown) then
{
	if (membershipEnabled and pvpEnabled) then
	{
		if (_uid in membersX) then {playerHasBeenPvP pushBack [_uid,time]};
	};
};
Save player data: Call save function

Sqf

Apply
[_uid, _realUnit, false] call A3A_fnc_savePlayer;
Unit cleanup: Delete or damage unit based on state

Sqf

Apply
if (alive _realUnit && {!(_realUnit getVariable ["incapacitated", false])} ) then { deleteVehicle _realUnit }
else { _realUnit setDamage 1 };
Where it leads: Called functions:

A3A_fnc_buildHQ: Rebuilds HQ if needed
A3A_fnc_assignBossIfNone: Assigns new commander
A3A_fnc_savePlayer: Saves player data
Dependents:

Player session management
Commander succession
Data persistence
System fit:

Player lifecycle system
Commander management
Data persistence
Global variables read:

theBoss: Current commander
membersX: Members list
membershipEnabled, pvpEnabled: Settings
playerHasBeenPvP: PvP tracking array
Global variables modified:

playerHasBeenPvP: Adds entry
theBoss: Indirectly via boss assignment
Network implications:

Boss assignment is remote/networked
Save function handles network saves
Edge cases:

Remote control detection
Server-side execution only
Boss role vacancy
PvP tracking eligibility
Error handling:

Early exit for HC disconnect
Real unit detection
Code flow: Validate input → Handle boss transfer → Track PvP → Save data → Clean unit

File dependencies: Uses global boss variable, membership settings.

A3A_fnc_patrolDestinations.sqf
Function Name: patrolDestinations
What it does:
Determines valid patrol destination markers based on proximity to player-controlled fast travel points (controllable areas). It filters an input array of markers to only include those near enough to teamPlayer factions for potential land-based attack or patrol missions, typically used for AI reinforcement or patrol spawning logic.

How it does that:

Sqf

Apply
params ["_markersX", "_positionX"];
Parameter Validation: Accepts two arguments:
_markersX: Array of marker names (typically control points or objectives)
_positionX: 2D/3D position array that serves as reference point for distance calculations
Sqf

Apply
private _array = (_markersX - controlsX) select {getMarkerPos _x distance2D _positionX < distanceForLandAttack};
Step 1: Removes all control markers (stored in controlsX global variable) from _markersX to get only non-control objective markers
Step 2: Filters the result using select to keep only markers where the distance from the marker's position to _positionX is less than distanceForLandAttack (a global distance threshold)
Technical Note: Uses distance2D for 2D plane distance (ignoring Z-axis), which is appropriate for map-based marker distance calculations
Sqf

Apply
private _destinationsX = [];
Step 3: Initializes an empty array to store valid destination markers
Sqf

Apply
//Spawn patrols if we've nearby fast travel points if we're in singleplayer, otherwise use nearby players.
private _isValidDestination = { playableUnits findIf {(side (group _x) == teamPlayer) and (_x distance2d _this < 2000)} != -1 };
Step 4: Defines a lambda function _isValidDestination that checks:
Within all playable units, is there at least one unit belonging to teamPlayer (typically players/characters)
That unit is within 2000 meters of the position being tested (_this context)
Returns true if such a unit exists, false otherwise
Technical Note: This function is called with the marker position as _this context, testing for nearby player presence within 2km radius
Sqf

Apply
{
	private _destinationX = _x;
	private _pos = getMarkerPos _destinationX;
	if (_pos call _isValidDestination) then {_destinationsX pushBack _destinationX};
} forEach _array;
Step 5: Iterates through each marker in _array
For each marker, gets its world position via getMarkerPos
Calls _isValidDestination with that position to check for nearby teamPlayer units
If valid (position has nearby teamPlayer units), adds the marker name to _destinationsX
Edge Case: If no teamPlayer units are within 2000m, the marker is excluded
Sqf

Apply
_destinationsX
Step 6: Returns the array of valid destination marker names
Where it leads:

Calls: No internal function calls, but uses:
playableUnits (wrapper function via fn_playableUnits.sqf)
teamPlayer (global side variable, typically west or independent)
distanceForLandAttack (global distance threshold)
controlsX (global array of control point markers)
Depended by: Likely used by patrol spawning systems, reinforcement logic, or mission generation code that needs to select valid targets for AI patrols
Global Variables Modified: None
Network Implications: None (client-side computation for mission planning)
Synchronization: None - purely local computation for decision making
Fits into System: Part of tactical decision-making for AI; determines where patrols can be spawned or directed based on player presence, ensuring patrols don't spawn in isolated areas
A3A_fnc_petrosDeathMonitor.sqf
Function Name: petrosDeathMonitor
What it does:
A server-side monitor that handles the distribution of post-death placement "UI" to clients when the commander (Petros) dies. It determines which player should receive the petros placement interface based on availability and status of the player designated as the commander (theBoss).

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Step 1: Includes the script component header and fixes line numbers for debugging purposes
Sqf

Apply
Info("Petros death monitor started");
Step 2: Logs a debug/info message indicating the monitor has started
Sqf

Apply
A3A_playerPlacingPetros = "";           // this is a playerID
Step 3: Initializes a global variable tracking which player ID is currently responsible for placing Petros. Set to empty string initially.
Sqf

Apply
while {!alive petros} do {
Step 4: Enters an infinite loop that runs while the petros unit object is not alive. The loop exits once Petros is placed again (becomes alive).
Sqf

Apply
	private _userInfo = getUserInfo A3A_playerPlacingPetros;
	if (_userInfo isEqualTo [] or {_userInfo # 6 != 10}) then {
Step 5: Checks the user info for the player currently assigned to place Petros:
getUserInfo retrieves player info array for the given player ID
Checks if array is empty (player disconnected) or if player's client state (# 6) is not 10 (not fully connected/synced)
Technical Note: Index 6 of getUserInfo returns client state: 10 = fully connected
Sqf

Apply
		// Don't bother trying to open the interface until we have an alive & conscious commander
		if (!alive theBoss or {theBoss getVariable ["incapacitated", false]}) exitWith {};
Step 6: If the previous player is invalid, checks if theBoss (the commander unit) exists and is alive/incapacitated:
theBoss is a global variable referencing the commander unit
If theBoss is dead or incapacitated, exits the loop iteration (skip this iteration)
Sqf

Apply
		// In case commander is remote controlling...
		private _index = allPlayers findIf { _x getVariable ["owner", _x] == theBoss };
Step 7: If theBoss is alive, finds the player controlling theBoss:
Searches allPlayers array for a player whose owner variable equals theBoss
If theBoss is controlled by a player, this finds the controlling player; otherwise, it finds theBoss itself (when not remote-controlled)
Technical Note: The owner variable tracks which player owns/controls a unit; if not set, the unit owns itself
Sqf

Apply
		if (_index == -1) exitWith { Error("Uh, boss has no owner?") };
Step 8: Error handling: If no owner found for theBoss, logs an error and exits the loop iteration
Sqf

Apply
		private _bossPlayer = allPlayers select _index;
		Info_1("Selected player %1 to place petros", name _bossPlayer);
Step 9: Retrieves the player object and logs debug info showing which player was selected
Sqf

Apply
		A3A_playerPlacingPetros = getPlayerID _bossPlayer;
		publicVariable "A3A_playerPlacingPetros";
Step 10: Assigns the selected player's ID to the global variable and makes it public across the network so all clients can see who is responsible for placement
Sqf

Apply
		[] remoteExec ["A3A_fnc_placementSelection", _bossPlayer];
Step 11: Remotely executes the A3A_fnc_placementSelection function on the selected player's machine only, triggering the placement interface
Sqf

Apply
	};
Step 12: Closes the inner conditional block
Sqf

Apply
    sleep 5;
};
Step 13: Sleeps for 5 seconds before checking again, creating a polling loop to handle player disconnections or state changes
Sqf

Apply
Info("Petros successfully placed");
Step 14: Logs success when the loop exits (Petros becomes alive)
Where it leads:

Calls:
getUserInfo (BIS function) - retrieves player info array
alive (condition) - checks unit status
theBoss getVariable ["incapacitated", false] - checks commander status
allPlayers findIf - searches for controlling player
getPlayerID (BIS function) - gets player ID string
remoteExec with A3A_fnc_placementSelection - triggers the placement interface on the selected player's machine
Depended by: Called when Petros dies (typically from mission failure or combat loss)
Global Variables Modified:
A3A_playerPlacingPetros - tracks which player should handle Petros placement
Network Implications: Uses publicVariable to synchronize the responsible player ID across all clients
Synchronization: The function runs on the server and synchronizes the placement responsibility to all clients
Fits into System: Part of the HQ relocation system triggered when the commander dies; ensures the correct player receives the UI for placing Petros in a new location
A3A_fnc_placementselection.sqf
Function Name: placementSelection
What it does:
Provides a client-side interface for selecting a new location to place Petros after death. It opens the map, marks enemy zones, validates player clicks against criteria (no water, no enemy zones, within bounds, no nearby enemies), and handles the actual placement process.

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
scriptName "fn_placementSelection.sqf";
Step 1: Includes headers and sets script name for debugging
Sqf

Apply
private _disabledPlayerDamage = false;
Step 2: Initializes a flag (though unused in the provided snippet)
Sqf

Apply
player allowDamage false;
Step 3: Temporarily disables damage to the player to prevent interruption during map interaction
Sqf

Apply
format [localize "STR_hints_new_game_petros_dead_header",name petros] hintC format [localize "STR_hints_new_game_petros_dead_text",name petros];
Step 4: Displays a hintC dialog with localized messages explaining Petros' death and the need to place him. Uses name petros to personalize the message
Sqf

Apply
hintC_arr_EH = findDisplay 72 displayAddEventHandler ["unload",{
	_nul = _this spawn {
		_this select 0 displayRemoveEventHandler ["unload", hintC_arr_EH];
		hintSilent "";
	};
}];
Step 5: Adds an event handler to the hint dialog's unload event to clean up the event handler and clear the hint message when the dialog closes
Sqf

Apply
private _markersX = markersX select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
_markersX = _markersX - (controlsX select {!isOnRoad (getMarkerPos _x)});
Step 6: Gets enemy-controlled markers:
markersX contains all objective markers
Filters to markers where sidesX variable indicates the side is NOT teamPlayer (i.e., enemy-controlled)
Removes control points (controlsX) that are NOT on roads (enemy non-road outposts)
Sqf

Apply
openMap [true,true];
Step 7: Opens the map (full-screen map view) and makes it controllable
Sqf

Apply
private _mrkDangerZone = [];
{
	_mrk = createMarkerLocal [format ["%1dumdum", count _mrkDangerZone], getMarkerPos _x];
	_mrk setMarkerShapeLocal "ELLIPSE";
	_mrk setMarkerSizeLocal [500,500];
	_mrk setMarkerTypeLocal "hd_warning";
	_mrk setMarkerColorLocal "ColorRed";
	_mrk setMarkerBrushLocal "DiagGrid";
	_mrkDangerZone pushBack _mrk;
} forEach _markersX;
Step 8: Creates local danger zones on the map:
For each enemy-controlled marker, creates a local red ellipse with 500m radius
Uses warning icon and diagonal grid pattern for visual clarity
Stores all created marker names in _mrkDangerZone for later cleanup
Sqf

Apply
private _positionClicked = [];
private _positionIsInvalid = true;
Step 9: Initializes variables to track clicked position and validity state
Sqf

Apply
while {_positionIsInvalid} do {
	positionClickedDuringHQPlacement = [];
	onMapSingleClick "positionClickedDuringHQPlacement = _pos;";
	waitUntil {sleep 1; (count positionClickedDuringHQPlacement > 0) or (not visiblemap)};
	onMapSingleClick "";
Step 10: Main selection loop:
Clears previous click data
Sets up single-click handler to store clicked position in positionClickedDuringHQPlacement
Waits for either a click (array filled) or map closed by player
Clears the click handler afterward
Sqf

Apply
	//If they quit the map, keep HQ where it is.
	if (not visiblemap) exitWith {};
Step 11: If player closed map without clicking, exits the loop (HQ stays in place)
Sqf

Apply
	//Assume the position chosen is valid.
	_positionIsInvalid = false;
	_positionClicked = positionClickedDuringHQPlacement;
Step 12: Marks position as initially valid and stores the clicked position
Sqf

Apply
	_markerX = [_markersX,_positionClicked] call BIS_fnc_nearestPosition;
Step 13: Finds the nearest enemy marker to the clicked position
Sqf

Apply
	if (getMarkerPos _markerX distance _positionClicked < 500) then {
		[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_too_close_enemy_zones"] call SCRT_fnc_misc_deniedHint;
		_positionIsInvalid = true;
	};
Step 14: Validates against being too close to enemy zones:
If distance to nearest enemy marker < 500m, shows denied hint and marks position invalid
Sqf

Apply
	if (!_positionIsInvalid && {surfaceIsWater _positionClicked}) then {
		[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_not_water"] call SCRT_fnc_misc_deniedHint;
		_positionIsInvalid = true;
	};
Step 15: Validates against water:
If position is on water, shows denied hint and marks position invalid
Sqf

Apply
	if (!_positionIsInvalid && (_positionClicked findIf { (_x < 0) || (_x > worldSize)} != -1)) then {
		[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_oob"] call SCRT_fnc_misc_deniedHint;
		_positionIsInvalid = true;
	};
Step 16: Validates against out-of-bounds:
Checks if any coordinate (X or Y) is negative or exceeds worldSize
If OOB, shows denied hint and marks position invalid
Sqf

Apply
	if (!_positionIsInvalid) then {
		//Invalid if enemies nearby
		_positionIsInvalid = (allUnits findIf {(side _x == Occupants || side _x == Invaders) && {_x distance _positionClicked < 500}}) > -1;
		if (_positionIsInvalid) then {[localize "STR_A3A_Base_placementselection_header", localize "STR_A3A_Base_placementselection_enemies"] call SCRT_fnc_misc_deniedHint;};
	};
Step 17: Validates against nearby live enemies:
Searches allUnits for any unit belonging to Occupants or Invaders (enemy factions) within 500m
If found, marks position invalid and shows denied hint
Technical Note: Uses findIf for efficiency - returns index if found, -1 if not
Sqf

Apply
	sleep 0.1;
Step 18: Small delay to prevent tight loop
Sqf

Apply
player allowDamage true;
Step 19: Re-enables player damage after selection completes
Sqf

Apply
{deleteMarkerLocal _x} forEach _mrkDangerZone;
Step 20: Deletes all local danger zone markers to clean up the map view
Sqf

Apply
//If we're still in the map, we chose a place.
if (visiblemap) then {
	_controlsX = controlsX select {!(isOnRoad (getMarkerPos _x))};
	{
		if (getMarkerPos _x distance _positionClicked < distanceSPWN) then {
			sidesX setVariable [_x,teamPlayer,true];
		};
	} forEach _controlsX;
Step 21: If map is still open (player chose a valid location):
Gets non-road control points
For each control point within distanceSPWN of the new HQ, changes its ownership to teamPlayer (captured)
sidesX variable is set to teamPlayer globally (true = network sync)
Sqf

Apply
	[_positionClicked] remoteExec ["A3A_fnc_createPetros", 2];
	[_positionClicked, false] remoteExec ["A3A_fnc_relocateHQObjects", 2];
	openmap [false,false];
Step 22: Triggers server-side actions:
remoteExec to server (machine 2) to create Petros at the clicked position
remoteExec to server to relocate HQ objects to the new position
Closes the map
Sqf

Apply
	// Make sure petros is actually placed before we signal that we're done placing
	sleep 5;
};
Step 23: Waits 5 seconds to ensure Petros placement completes on server before proceeding
Sqf

Apply
A3A_playerPlacingPetros = "";
publicVariableServer "A3A_playerPlacingPetros";
Step 24: Clears the global placement responsibility variable and syncs to server (sends to server only, not all clients)
Where it leads:

Calls:
localize - for translated text strings
SCRT_fnc_misc_deniedHint - shows denial message to player
BIS_fnc_nearestPosition - finds nearest marker to position
surfaceIsWater - checks if position is on water
findIf with side checks - searches for nearby enemies
remoteExec to A3A_fnc_createPetros (server) - creates Petros unit
remoteExec to A3A_fnc_relocateHQObjects (server) - moves HQ objects
Depended by: Called by A3A_fnc_petrosDeathMonitor when Petros dies and a player is assigned placement
Global Variables Modified:
positionClickedDuringHQPlacement - stores clicked map position
A3A_playerPlacingPetros - cleared after placement
sidesX - updates control point ownership (via remoteExec to server)
Network Implications: Uses remoteExec to server for creating Petros and relocating objects; publicVariableServer to sync variable to server only
Synchronization: Map click data is local to the executing client; placement actions are server-authoritative
Fits into System: Client-side interface for HQ relocation after commander death; validates input and triggers server-side actions to complete the relocation process
A3A_fnc_playableUnits.sqf
Function Name: playableUnits
What it does:
A simple wrapper around the engine's playableUnits array to ensure consistent behavior across singleplayer and multiplayer environments.

How it does that:

Sqf

Apply
playableUnits;
Step 1: Simply returns the engine's playableUnits array
Technical Note: The function exists as a wrapper for organizational purposes, potentially for future modifications or to provide a consistent entry point for code that needs playable units
Where it leads:

Calls: No internal calls
Depended by: A3A_fnc_patrolDestinations and any other function needing to check player unit presence
Global Variables Modified: None
Network Implications: None (local computation)
Synchronization: None
Fits into System: Provides a standard interface for accessing playable units, maintaining consistency across the codebase
A3A_fnc_rebuildAssets.sqf
Function Name: rebuildAssets
What it does:
Handles the process of rebuilding various destroyed assets (cities, economic sites, radio towers, or general buildings) at a specific location. It determines the type of asset to rebuild based on the site identifier and triggers appropriate rebuilding logic with appropriate notifications.

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Step 1: Includes headers and fixes line numbers
Sqf

Apply
params ["_site", "_position"];
Step 2: Accepts parameters:
_site: Marker name of the site to rebuild
_position: World position array for the rebuild location
Sqf

Apply
private _leave = false;
private _antennaDead = objNull;
private _economyDead = ""; // Rebuild Factories and Resources Variables Definition
Step 3: Initializes tracking variables:
_leave: Exit flag (unused in provided code)
_antennaDead: Reference to dead antenna object
_economyDead: Empty string or marker name for economic site
Sqf

Apply
if (_site in outposts) then {
	_antennasDead = antennasDead select {_x inArea _site};
	if (count _antennasDead > 0) then {
		_antennaDead = _antennasDead select 0;
	};
};
Step 4: Checks if site is an outpost with a destroyed antenna:
If site is in outposts array, filters antennasDead for antennas within the site's area
If any found, stores the first antenna in _antennaDead
Sqf

Apply
// Check if the site is a destroyed economy site
if ((_site in factories || _site in resourcesX) && _site in destroyedSites) then {
	_economyDead = _site;
	Debug_1("Rebuilding Economic Site %1", _economyDead);
};
Step 5: Checks if site is a destroyed factory or resource site:
Verifies site is in factories/resources arrays AND in destroyedSites array
If so, stores site name in _economyDead for special handling
Sqf

Apply
private _name = [_site] call A3A_fnc_localizar;
Step 6: Gets localized name for the site for notification purposes
Sqf

Apply
private _rebuildSuccess = {
	params ["_message", ["_name", _name]];
	[		localize "STR_notifiers_success_type",
		localize "STR_notifiers_rebuild_assets_header",
		parseText format [localize _message, _name],
		30
	] spawn SCRT_fnc_ui_showMessage;

	[0,-5000] remoteExec ["A3A_fnc_resourcesFIA",2];
};
Step 7: Defines success callback:
Shows success notification with message and site name
Deducts 5000 FIA resources (remoteExec to server)
Sqf

Apply
private _rebuildFail = {
	params ["_message", ["_name", _name]];
	[		localize "STR_notifiers_fail_type",
		localize "STR_notifiers_rebuild_assets_header",
		parsetext format [localize _message, _name],
		30
	] spawn SCRT_fnc_ui_showMessage;
};
Step 8: Defines failure callback for notifications
Sqf

Apply
switch (true) do {
Step 9: Begins switch on conditions to determine rebuild type
Sqf

Apply
	case (_site in citiesX): {
		[0, 10, _position] remoteExec ["A3A_fnc_citySupportChange",2];
    	[Occupants, 10, 30] remoteExec ["A3A_fnc_addAggression",2];
    	[Invaders, 10, 30] remoteExec ["A3A_fnc_addAggression",2];

		private _destroyedSite = destroyedSites find _site;
		if (_destroyedSite == -1) exitWith {
			["STR_notifiers_rebuild_assets_nothing_to_rebuild", _name] call _rebuildFail;
		};
		destroyedSites deleteAt(_destroyedSite);
		publicVariable "destroyedSites";

		["STR_notifiers_rebuild_assets_success"] call _rebuildSuccess;
	};
Step 10: Case 1: Rebuilding a city:
Updates city support and aggression for both enemy factions
Removes city from destroyedSites array
Calls success callback with default success message
Technical Note: Uses remoteExec to server for faction updates; publicVariable to sync destroyedSites globally
Sqf

Apply
	// Rebuild Economic Assets and building repair start
	case (_economyDead != ""): {
		Debug_1("Calling A3A_fnc_rebuildEconomicAssets for %1", _economyDead);
		[_economyDead] remoteExec ["A3A_fnc_rebuildEconomicAssets", 2]; // Call the actual function that rebuilds the economic site

		["STR_notifiers_rebuild_assets_success"] call _rebuildSuccess;
	};
	// Rebuild Economic Assets and building repair end
Step 11: Case 2: Rebuilding economic site:
Calls server-side A3A_fnc_rebuildEconomicAssets for the specific site
Calls success callback
Sqf

Apply
	case (!isNull _antennaDead): {
		private _militaryBuildings = nearestObjects [_position, A3A_buildingWhitelist, 500,  true];

		{
			[_x] remoteExec ["A3A_fnc_repairRuinedBuilding", 2];
		} forEach _militaryBuildings;

		[_antennaDead] remoteExec ["A3A_fnc_rebuildRadioTower", 2];

		["STR_notifiers_rebuild_assets_radiotower_success"] call _rebuildSuccess;
	};
Step 12: Case 3: Rebuilding antenna (radio tower):
Finds military buildings within 500m of position
Repairs each ruined building via remoteExec to server
Rebuilds the radio tower via remoteExec to server
Calls success callback with specific radio tower message
Sqf

Apply
	default {
		[clientOwner, "destroyedBuildings"] remoteExecCall ["publicVariableClient", 2];

		private _militaryBuildings = (nearestObjects [_position, A3A_buildingWhitelist, 500,  true]) select {_x in destroyedBuildings};
		if (_militaryBuildings isEqualTo []) exitWith {
			["STR_notifiers_rebuild_assets_nothing_to_rebuild", _name] call _rebuildFail;
		};
		
		{
			[_x] remoteExec ["A3A_fnc_repairRuinedBuilding", 2];
		} forEach _militaryBuildings;
		["STR_notifiers_rebuild_assets_success", _name] call _rebuildSuccess;
		[clientOwner, "destroyedBuildings"] remoteExecCall ["publicVariableClient", 2];
	};
Step 13: Default case: General building rebuild:
Requests destroyedBuildings array from server (via publicVariableClient)
Finds military buildings in the destroyedBuildings list within 500m
If none found, calls failure callback
Repairs each building via remoteExec
Calls success callback
Requests updated destroyedBuildings array again
Where it leads:

Calls:
A3A_fnc_localizar - gets localized site name
SCRT_fnc_ui_showMessage - shows notification UI
remoteExec to A3A_fnc_citySupportChange - updates city support
remoteExec to A3A_fnc_addAggression - updates faction aggression
remoteExec to A3A_fnc_rebuildEconomicAssets - rebuilds economic sites
remoteExec to A3A_fnc_repairRuinedBuilding - repairs buildings
remoteExec to A3A_fnc_rebuildRadioTower - rebuilds radio tower
remoteExec to A3A_fnc_resourcesFIA - updates resources
publicVariable / publicVariableClient - synchronizes data
Depended by: Called when players rebuild destroyed assets via the reconstruction system
Global Variables Modified:
destroyedSites - removed rebuilt site (synchronized)
destroyedBuildings - accessed via server synchronization
Network Implications: Extensive use of remoteExec to server for all rebuild operations; uses publicVariable and publicVariableClient for synchronization
Synchronization: Server-authoritative rebuild operations; multiple synchronization points for global arrays
Fits into System: Part of the reconstruction/repair gameplay loop; handles different asset types with appropriate logic and notifications
A3A_fnc_rebuildEconomicAssets.sqf
Function Name: rebuildEconomicAssets
What it does:
Server-side function that repairs a destroyed economic site (factory or resource). It removes the site from the destroyed sites list, repairs all associated buildings, and notifies players of success.

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith { Error("Server-only function miscalled") };
Step 1: Includes headers and verifies function runs only on server
Sqf

Apply
params ["_economicSite"];
Step 2: Accepts one parameter: _economicSite - marker name of the economic site to rebuild
Sqf

Apply
Debug_1("Entered A3A_fnc_rebuildEconomicAssets for %1", _economicSite);
Step 3: Logs debug information
Sqf

Apply
if !(_economicSite in destroyedSites) exitWith { Error("Attempted to rebuild invalid economic site") };
Step 4: Validation: Checks if site is in destroyedSites array; if not, logs error and exits
Sqf

Apply
Info_1("Rebuilding %1", _economicSite);
Step 5: Logs rebuild attempt
Sqf

Apply
// Remove from destroyed sites
destroyedSites = destroyedSites - [_economicSite];
publicVariable "destroyedSites";
Step 6: Removes site from destroyed sites array and synchronizes globally
Sqf

Apply
// Repair factory or resource buildings at the site
private _repairTypes = ["Building", "House"]; // So depots and such in resources and factories can be rebuilt, could be too loose
private _economicSitePosition = getMarkerPos _economicSite;
private _economicBuildings = nearestObjects [_economicSitePosition, _repairTypes, 250];
{
    [_x] call A3A_fnc_repairRuinedBuilding;
} forEach _economicBuildings;
Step 7: Finds and repairs buildings:
Defines repair types (Building and House) for broad coverage
Gets marker position
Finds all buildings/ruins within 250m of the economic site
Calls A3A_fnc_repairRuinedBuilding for each building to repair it
Sqf

Apply
// Notify players about successful rebuild
private _nameX = [_economicSite] call A3A_fnc_localizar;
["TaskSucceeded", ["", format [localize "STR_notifiers_rebuild_assets_success", _nameX]]] remoteExec ["BIS_fnc_showNotification",[teamPlayer, civilian]];
Step 8: Notifies players:
Gets localized site name
Shows task success notification to teamPlayer side and civilians via remoteExec
Sqf

Apply
Info_1("%1 has been Rebuilt.", _economicSite);
Step 9: Logs success
Where it leads:

Calls:
A3A_fnc_localizar - gets localized name
A3A_fnc_repairRuinedBuilding - repairs each building
remoteExec to BIS_fnc_showNotification - notifies players
getMarkerPos - gets position
nearestObjects - finds buildings
Depended by: Called by A3A_fnc_rebuildAssets when rebuilding economic sites
Global Variables Modified:
destroyedSites - removed economic site (synchronized globally)
Network Implications: Uses publicVariable to synchronize destroyedSites; uses remoteExec to notify players
Synchronization: Server-authoritative; synchronizes destroyedSites globally
Fits into System: Server-side component of economic site reconstruction; handles the actual repair logic for factories and resources
A3A_fnc_rebuildRadioTower.sqf
Function Name: rebuildRadioTower
What it does:
Server-side function that repairs a destroyed radio tower. It removes the antenna from dead list, repairs the building, adds it back to active antennas, creates a marker, and sets up event handlers for future destruction.

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith { Error("Server-only function miscalled") };
Step 1: Includes headers and verifies server execution
Sqf

Apply
params ["_antenna"];
Step 2: Accepts _antenna - object reference to the radio tower to rebuild
Sqf

Apply
if !(_antenna in antennasDead) exitWith { Error("Attempted to rebuild invalid radio tower") };
Info_1("Repairing Antenna %1", str _antenna);
Step 3: Validates antenna is in antennasDead array and logs info
Sqf

Apply
antennasDead = antennasDead - [_antenna]; publicVariable "antennasDead";
[_antenna] call A3A_fnc_repairRuinedBuilding;
antennas pushBack _antenna; publicVariable "antennas";
Step 4: Removes from dead antennas, repairs building, adds to active antennas, synchronizes both arrays globally
Sqf

Apply
{if ([antennas,_x] call BIS_fnc_nearestPosition == _antenna) then {[_x,true] spawn A3A_fnc_blackout}} forEach citiesX;
Step 5: For each city, if the nearest antenna to the city is this antenna, trigger blackout resolution (power restoration)
Technical Note: Uses BIS_fnc_nearestPosition to find closest antenna from antennas array
Sqf

Apply
private _mrkFinal = createMarker [format ["Ant%1", mapGridPosition _antenna], getPos _antenna];
_mrkFinal setMarkerShape "ICON";
_mrkFinal setMarkerType "loc_Transmitter";
_mrkFinal setMarkerColor "ColorBlack";
_mrkFinal setMarkerText (localize "STR_radiotower");
mrkAntennas pushBack _mrkFinal;
publicVariable "mrkAntennas";
Step 6: Creates new marker for the antenna:
Creates marker with name "AntX" where X is grid position
Sets shape, type, color, and text
Adds to mrkAntennas array and synchronizes globally
Sqf

Apply
_antenna addEventHandler ["Killed", {
	params ["_antenna"];
	_antenna removeAllEventHandlers "Killed";
	{if ([antennas,_x] call BIS_fnc_nearestPosition == _antenna) then {[_x,false] spawn A3A_fnc_blackout}} forEach citiesX;
	_mrk = [mrkAntennas, _antenna] call BIS_fnc_nearestPosition;
	mrkAntennas deleteAt(mrkAntennas find _mrk);
	antennas deleteAt(antennas find _antenna);
	deleteMarker _mrk;
	antennasDead pushBack _antenna;
	publicVariable "antennas"; 
	publicVariable "antennasDead"; 
	publicVariable "mrkAntennas";
	["TaskSucceeded",["", localize "STR_notifiers_radiotower_destroyed"]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
	["TaskFailed",["", localize "STR_notifiers_radiotower_destroyed"]] remoteExec ["BIS_fnc_showNotification",Occupants];
}];
Step 7: Adds Killed event handler to antenna for future destruction:
Removes all existing Killed handlers to avoid duplicates
Triggers blackouts for cities served by this antenna
Finds and removes marker from arrays
Moves antenna to dead list
Notifies teamPlayer (success for them) and Occupants (failure for them)
Technical Note: Uses publicVariable three times to synchronize all affected arrays
Where it leads:

Calls:
A3A_fnc_repairRuinedBuilding - repairs the antenna building
A3A_fnc_blackout - handles city power blackouts
BIS_fnc_nearestPosition - finds nearest antenna/markers
remoteExec to BIS_fnc_showNotification - notifies players
mapGridPosition - for marker naming
Depended by: Called by A3A_fnc_rebuildAssets when rebuilding a radio tower
Global Variables Modified:
antennasDead - removed antenna (synchronized)
antennas - added antenna (synchronized)
mrkAntennas - added marker (synchronized)
Network Implications: Extensive synchronization via publicVariable for three global arrays; event handler triggers network notifications on destruction
Synchronization: Server-authoritative with global synchronization of antenna arrays
Fits into System: Part of the radio tower system; handles rebuild and sets up future destruction tracking and city blackout logic
A3A_fnc_relocateHQObjects.sqf
Function Name: relocateHQObjects
What it does:
Server-side function that moves HQ objects (HQ marker, respawn, box, map, flag, vehicle box) to a new position. It also updates HQ intelligence tracking and aligns objects with terrain.

How it does that:

Sqf

Apply
params ["_newPosition", "_isNewGame"];
Step 1: Accepts parameters:
_newPosition: New HQ position array
_isNewGame: Boolean flag indicating if this is a new game (used to skip intelligence tracking)
Sqf

Apply
// Update cur/old HQ knowledge. Shouldn't be interrupted
isNil {
	if (_isNewGame) exitWith {};
	private _oldPos = markerPos "Synd_HQ";
	_oldPos set [2, A3A_curHQInfoOcc];
	A3A_oldHQInfoOcc pushBack +_oldPos;
	A3A_curHQInfoOcc = 0;
	{
		private _dist = _x distance2d _newPosition;
		A3A_curHQInfoOcc = A3A_curHQInfoOcc max linearConversion [0, 1000, _dist, _x#2, 0, true];
	} forEach A3A_oldHQInfoOcc;

	_oldPos set [2, A3A_curHQInfoInv];
	A3A_oldHQInfoInv pushBack +_oldPos;
	A3A_curHQInfoInv = 0;
	{
		private _dist = _x distance2d _newPosition;
		A3A_curHQInfoInv = A3A_curHQInfoInv max linearConversion [0, 1000, _dist, _x#2, 0, true];
	} forEach A3A_oldHQInfoInv;
};
Step 2: Updates enemy intelligence tracking (wrapped in isNil for atomicity):
If not new game, gets old HQ position and current intelligence values
Pushes old position with intelligence to history arrays
Recalculates current intelligence for both factions based on distance to new position
Uses linearConversion to adjust intelligence based on distance
Sqf

Apply
respawnTeamPlayer setMarkerPos _newPosition;
posHQ = _newPosition; publicVariable "posHQ";
"Synd_HQ" setMarkerPos _newPosition;
chopForest = false; publicVariable "chopForest";
Step 3: Updates core HQ data:
Moves respawn marker to new position
Updates posHQ and synchronizes it
Moves "Synd_HQ" marker
Disables forest chopping flag and synchronizes it
Sqf

Apply
[respawnTeamPlayer, 1, teamPlayer] call A3A_fnc_setMarkerAlphaForSide;
[respawnTeamPlayer, 1, civilian] call A3A_fnc_setMarkerAlphaForSide;
Step 4: Sets marker visibility for teamPlayer and civilians
Sqf

Apply
// Move headless client logic objects near HQ so that firedNear EH etc. work more reliably
private _hcpos = _newPosition vectorAdd [-100, -100, 0];
{ _x setPosATL _hcpos } forEach (entities "HeadlessClient_F");
Step 5: Moves all headless client objects near new HQ for reliable event handlers
Sqf

Apply
private _alignNormals = {
	private _thing = _this;
	_thing setVectorUp surfaceNormal getPos _thing;
};
Step 6: Defines helper function to align objects with ground surface
Sqf

Apply
private _firePos = [_newPosition, 3, getDir petros] call BIS_Fnc_relPos;
_rnd = getdir petros;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
boxX setPos _pos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
mapX setDir ([_firePos, _pos] call BIS_fnc_dirTo);
mapX setPos _pos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
_emptyPos = _pos findEmptyPosition [0,50,(typeOf flagX)];
_pos = if (count _emptyPos > 0) then {_emptyPos} else {_pos};
flagX setPos _pos;
_rnd = _rnd + 45;
_pos = [_firePos, 3, _rnd] call BIS_Fnc_relPos;
vehicleBox setPos _pos;
Step 7: Positions objects around Petros (at firePos which is 3m from new HQ in Petros' direction):
boxX: 45° offset from firePos
mapX: 90° offset, direction set towards firePos
flagX: 180° offset, with empty position check for flag pole
vehicleBox: 225° offset
Uses BIS_Fnc_relPos for relative positioning
Sqf

Apply
//Align with ground. Deliberately ignoring flagX, because a flag pole at 45 degrees looks /weird/
{_x call _alignNormals} forEach [boxX, mapX, vehicleBox];
Step 8: Aligns boxes with ground surface (excluding flag for visual consistency)
Sqf

Apply
boxX hideObjectGlobal false;
vehicleBox hideObjectGlobal false;
mapX hideObjectGlobal false;
flagX hideObjectGlobal false;
Step 9: Shows all HQ objects globally
Where it leads:

Calls:
markerPos - gets positions
linearConversion - for intelligence calculation
vectorAdd - for headless client position
BIS_Fnc_relPos - for relative positioning
BIS_fnc_dirTo - for direction calculation
findEmptyPosition - for flag placement
surfaceNormal - for ground alignment
A3A_fnc_setMarkerAlphaForSide - sets marker visibility
Depended by: Called by A3A_fnc_placementSelection after HQ relocation
Global Variables Modified:
posHQ - new HQ position (synchronized)
chopForest - forest flag (synchronized)
A3A_curHQInfoOcc, A3A_curHQInfoInv - current intelligence
A3A_oldHQInfoOcc, A3A_oldHQInfoInv - intelligence history
Network Implications: Uses publicVariable to synchronize HQ position and flags; moves headless clients (network-relevant)
Synchronization: All changes are synchronized globally; intelligence arrays updated atomically with isNil
Fits into System: Core HQ relocation system; handles all object repositioning, intelligence updates, and synchronization for HQ moves
A3A_fnc_repairRuinedBuilding.sqf
Function Name: repairRuinedBuilding
What it does:
Server-side function that repairs a ruined building or a building that has ruins. It locates the matching building/ruin pair, repairs the building, deletes the ruins, and cleans up tracking variables.

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if (!isServer) exitWith { Error("Server-only function miscalled") };
Step 1: Includes headers and verifies server execution
Sqf

Apply
params ["_target"];
Step 2: Accepts _target - either a ruin object or the building object itself
Sqf

Apply
private _buildingToRepair = objNull;
private _ruins = objNull;
Step 3: Initializes tracking variables
Sqf

Apply
if (_target isKindOf "Ruins") then {
Step 4: Checks if target is a ruin:
Sqf

Apply
	//If it's been killed during play, it's  stored in here.
	_buildingToRepair = _target getVariable ["building", objNull];
	//Check if it's been made into a ruin by BIS_fnc_createRuin, rather than killed during play.
	if (isNull _buildingToRepair) then {
		_buildingToRepair = _target getVariable ["BIS_fnc_createRuin_object", objNull];
	};
	_ruins = _target;
Step 5: For ruins:
Gets original building from building variable (for building killed in game)
If not found, checks BIS_fnc_createRuin_object (for script-created ruins)
Sets ruins to target
Sqf

Apply
} else {
	_buildingToRepair = _target;
	//If it's been killed during play, it's  stored in here.
	_ruins = _target getVariable ["ruins", objNull];
	//Check if it's been made into a ruin by BIS_fnc_createRuin
	if (isNull _ruins) then {
		_ruins = _target getVariable ["BIS_fnc_createRuin_ruin", objNull];
	};
};
Step 6: For buildings:
Target is the building to repair
Gets ruins from ruins variable (for building killed in game)
If not found, checks BIS_fnc_createRuin_ruin (for script-created ruins)
Sqf

Apply
//Haven't located the matching building - abort!
if (isNull _buildingToRepair || isNull _ruins) exitWith {false;};
Step 7: Validation: If building or ruins not found, exits with false
Sqf

Apply
_buildingToRepair setDamage 0;
Step 8: Repairs building to full health
Sqf

Apply
deleteVehicle _ruins;
Step 9: Deletes the ruin object
Sqf

Apply
private _oldPos = getPos _buildingToRepair;
_buildingToRepair setPos [_oldPos select 0, _oldPos select 1, 0];
Step 10: Reset building position to ground level (Z=0) to prevent floating
Sqf

Apply
//Make sure we unhide, in case it was hidden by BIS_fnc_createRuin
[_buildingToRepair, false] remoteExec ["hideObject", 0, _buildingToRepair];
Step 11: Unhides building remotely (0 = all machines) if it was hidden
Sqf

Apply
destroyedBuildings = destroyedBuildings - [_buildingToRepair];
Step 12: Removes building from destroyed buildings tracking array
Note: This doesn't synchronize - expected to be handled by calling function if needed
Sqf

Apply
true;
Step 13: Returns success
Where it leads:

Calls:
isKindOf - checks object type
getVariable - retrieves building/ruin references
setDamage - repairs building
deleteVehicle - removes ruins
getPos/setPos - repositions building
remoteExec to hideObject - unhides building
Depended by: Called by:
A3A_fnc_rebuildAssets for general building repair
A3A_fnc_rebuildEconomicAssets for economic building repair
A3A_fnc_rebuildRadioTower for tower repair
Global Variables Modified:
destroyedBuildings - removed building from array (not synchronized automatically)
Network Implications: Uses remoteExec to hideObject on all machines (0) to ensure building visibility
Synchronization: No automatic synchronization of destroyedBuildings; expects calling function to handle synchronization
Fits into System: Core repair mechanic for all ruined buildings; handles the actual repair logic for both player-killed and script-created ruins
A3A_fnc_resourcecheckSkipTime.sqf
Function Name: resourcecheckSkipTime
What it does:
Skips time forward by a specified number of hours, showing a black screen transition. Used for sleeping/waiting at base.

How it does that:

Sqf

Apply
params [["_hours", 6]];
Step 1: Accepts optional parameter for hours to skip (defaults to 6)
Sqf

Apply
cutText [format [localize "STR_params_rest", _hours],"BLACK",5];
Step 2: Shows black screen with localized message "Resting for X hours" for 5 seconds
Sqf

Apply
sleep 10;
Step 3: Waits 10 seconds (5 seconds of black screen + 5 second pause)
Sqf

Apply
skiptime _hours;
Step 4: Advances game time by _hours hours
Sqf

Apply
forceWeatherChange;
Step 5: Forces weather to update to match new time
Sqf

Apply
cutText [localize "STR_params_time_to_go","BLACK IN",10];
Step 6: Shows "Time to go" message with fade-in from black over 10 seconds
Where it leads:

Calls:
localize - for text strings
cutText - for visual transitions
skiptime - for time advancement
forceWeatherChange - for weather updates
Depended by: Called from menu/dialog for waiting/sleeping at base
Global Variables Modified: None
Network Implications: None (client-side time skip)
Synchronization: None
Fits into System: Provides time passing mechanism for players at base; part of rest/wait functionality
A3A_fnc_resourcesFIA.sqf
Function Name: resourcesFIA
What it does:
Adjusts FIA resources (manpower and money) atomically. Handles HR (manpower) limits, validates inputs, and sends notifications to the commander.

How it does that:

Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Step 1: Includes headers and fixes line numbers
Sqf

Apply
params ["_hr", "_resourcesFIA"];
Step 2: Accepts parameters:
_hr: Manpower change (positive for add, negative for subtract)
_resourcesFIA: Money change (positive for add, negative for subtract)
Sqf

Apply
waitUntil {!resourcesIsChanging};
Step 3: Waits for resourcesIsChanging flag to be false (prevents concurrent modification)
Sqf

Apply
private _warningText = nil;
resourcesIsChanging = true;
Step 4: Sets flag to true and initializes warning text variable
Sqf

Apply
if (isNil "_resourcesFIA") then {Error("_resourceFIA is nil");};
if ((isNil "_hr") or (isNil "_resourcesFIA")) exitWith {resourcesIsChanging = false};
if ((floor _resourcesFIA == 0) and (floor _hr == 0)) exitWith {resourcesIsChanging = false};
Step 5: Validation:
Checks if _resourcesFIA is nil (logs error)
Checks if either parameter is nil (exits with flag reset)
Checks if both changes are zero (exits with flag reset)
Sqf

Apply
private _hrT = server getVariable "hr";
private _resourcesFIAT = server getVariable "resourcesFIA";
private _hrLimit = nil;
Step 6: Retrieves current values from server variables
Sqf

Apply
_hrT = _hrT + _hr;
_resourcesFIAT = round (_resourcesFIAT + _resourcesFIA);
Step 7: Applies changes to local copies
Sqf

Apply
if (_hrT < 0) then {_hrT = 0};
if (_resourcesFIAT < 0) then {_resourcesFIAT = 0};
Step 8: Prevents negative values (minimum 0)
Sqf

Apply
if (limitHR != 0) then {
	_hrLimit = (((tierWar * 100) * (limitHR / 100)) + 100);
	if (_hrT > _hrLimit) then {_hrT = _hrLimit};
};
Step 9: Enforces HR limit if configured:
Calculates limit based on war tier and limitHR percentage
Caps HR at calculated limit
Sqf

Apply
server setVariable ["hr",_hrT,true];
server setVariable ["resourcesFIA",_resourcesFIAT,true];
Step 10: Updates server variables with true flag for network synchronization
Sqf

Apply
resourcesIsChanging = false;
Step 11: Releases the lock
Sqf

Apply
private _textX = "";
private _hrSim = "";
private _resourcesFIASim = "";
if (_hr > 0) then {_hrSim = "+"};
if (_resourcesFIA > 0) then {_resourcesFIASim = "+"};
Step 12: Prepares notification text with signs for positive changes
Sqf

Apply
switch (true) do {
	case ((_hr != 0) && {_resourcesFIA != 0}): {
		_textX = format [localize "STR_comms_res_FIA_1",_hr,_resourcesFIA,_hrSim,_resourcesFIASim,FactionGet(reb,"name"), A3A_faction_civ get "currencySymbol"];
	};
	case (_hr != 0): {
		_textX = format [localize "STR_comms_res_FIA_2",_hr,_hrSim,FactionGet(reb,"name")];
	};
	case (_resourcesFIA != 5): {
		_textX = format [localize "STR_comms_res_FIA_3",_hr,_resourcesFIA,_hrSim,_resourcesFIASim,FactionGet(reb,"name"), A3A_faction_civ get "currencySymbol"];
	};
};
Step 13: Formats notification text based on what changed:
Case 1: Both HR and resources changed
Case 2: Only HR changed
Case 3: Only resources changed (note: checks against 5, likely a bug or specific case)
Sqf

Apply
if (_textX isEqualTo "") exitWith {};
 
[petros,"income",_textX] remoteExec ["A3A_fnc_commsMP",theBoss];
Step 14: Sends notification to commander via remoteExec if text is not empty
Where it leads:

Calls:
server getVariable - retrieves current values
server setVariable - updates values with sync
localize - for text strings
FactionGet / A3A_faction_civ get - for faction name and currency symbol
remoteExec to A3A_fnc_commsMP - sends notification
Depended by: Called whenever resources need adjustment (missions, taxes, purchases, etc.)
Global Variables Modified:
resourcesIsChanging - lock flag (local)
Server variables hr and resourcesFIA (synchronized globally)
Network Implications: Uses server setVariable with synchronization flag to update resources globally
Synchronization: Server-authoritative resource management with global synchronization
Fits into System: Core resource management system; handles atomic updates of HR and money with validation and notifications
A3A_fnc_returnMuzzle.sqf
Function Name: returnMuzzle
What it does:
Returns the appropriate muzzle for a smoke grenade based on its magazine class name. Used when assigning smoke grenade magazines to units.

How it does that:

Sqf

Apply
private ["_unit","_muzzles","_muzzle","_magazines"];
Step 1: Declares private variables (though not initialized here)
Sqf

Apply
_unit = _this select 0;
Step 2: Takes first parameter as unit object
Sqf

Apply
_muzzles = [];
_muzzle = "";
_magazines = magazines _unit select {_x in allSmokeGrenades};
Step 3: Initializes variables and gets only smoke grenade magazines from the unit's inventory
allSmokeGrenades is a global array of smoke magazine class names
Sqf

Apply
{
switch (_x) do
	{
	case "SmokeShell": {_muzzles pushBack "SmokeShellMuzzle"};
	case "SmokeShellRed": {_muzzles pushBack "SmokeShellRedMuzzle"};
	// ... more cases for different smoke types ...
	};
} forEach _magazines;
Step 4: For each smoke magazine, adds corresponding muzzle to array:
Base vanilla smokes map to standard muzzles
RHS mod smokes map to mod-specific muzzles (Rhsusf_Throw_Smoke_white, etc.)
Sqf

Apply
if (count _muzzles > 0) then {_muzzle = selectRandom _muzzles};
_muzzle
Step 5: If any muzzles found, selects one randomly; returns the muzzle or empty string
Where it leads:

Calls: No internal function calls
Depended by: Likely used by loadout scripts or equipment management when assigning smoke grenades to units
Global Variables Modified: None
Network Implications: None
Synchronization: None
Fits into System: Part of loadout/equipment system; ensures correct muzzle assignment for smoke grenade magazines across mods
A3A_fnc_revealToPlayer.sqf
Function Name: revealToPlayer
What it does:
Either reveals enemy leaders to the player in a continuous loop (when no arguments), or reveals a specific group's leader to the player (when one argument is provided).

How it does that:

Sqf

Apply
if (isDedicated) exitWith {};
Step 1: Exits if running on dedicated server (client-only function)
Sqf

Apply
private ["_LeaderX"];
if (count _this == 0) then
	{
Step 2: Checks if any arguments provided:
If no arguments, runs continuous loop mode
Sqf

Apply
	while {revealX} do
		{
		if (player == leader group player) then
			{
			if ([player] call A3A_fnc_hasRadio) then
				{
				{
				_LeaderX = leader _x;
				if (((side _LeaderX == Invaders) or (side _LeaderX == Occupants)) and (vehicle _LeaderX != _LeaderX) and (player knowsAbout _LeaderX < 1.5)) then
					{
					player reveal [_LeaderX,4];
					sleep 1;
					};
				} forEach allGroups;
				};
			};
		sleep 10;
		};
	}
Step 3: Continuous loop mode:
Runs while global revealX flag is true
Only if player is leader of their group
Only if player has radio (via A3A_fnc_hasRadio)
For each group, gets leader, checks if enemy faction, in vehicle (not on foot), and player's knowledge < 1.5
If conditions met, reveals leader with 4 knowledge level
Sleeps 1 second between reveals, 10 seconds between cycles
Sqf

Apply
else
	{
Step 4: Else branch for single-reveal mode
Sqf

Apply
	private ["_groupX"];
	if (player == leader group player) then
		{
		_groupX = _this select 0;
		_LeaderX = leader _groupX;
		player reveal [_LeaderX,4];
		};
	};
Step 5: Single reveal mode:
Only if player is group leader
Takes group as argument
Reveals that group's leader to the player
Where it leads:

Calls:
A3A_fnc_hasRadio - checks if player has radio
player reveal - reveals units to player
sleep - creates delays
Depended by: Called by game systems needing to reveal enemy positions; continuous loop started by initialization or conditions
Global Variables Modified:
revealX - global flag controlling continuous loop
Network Implications: None (client-side visibility updates)
Synchronization: None
Fits into System: Part of reconnaissance/spotting system; provides controlled revealing of enemy leaders to enhance gameplay without overwhelming the player
A3A_fnc_scheduler.sqf
Function Name: scheduler
What it does:
Distributes server-side function execution across available headless clients (HCs) or the server itself, balancing load based on unit counts.

How it does that:

Sqf

Apply
if (!isServer) exitWith {};
Step 1: Ensures function runs only on server
Sqf

Apply
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
Step 2: Includes headers and fixes line numbers
Sqf

Apply
params ["_params", "_function"];
Info_2("Scheduled function: %1, Function params: %2", _function, _params);
Step 3: Accepts parameters:
_params: Parameters to pass to the target function
_function: Function name to execute
Logs debug information
Sqf

Apply
if (count hcArray == 0) exitWith {_params remoteExec [_function,2]};
Step 4: If no headless clients, executes directly on server (machine 2)
Sqf

Apply
private _targetID = 2;
private _min = ({local _x} count allUnits) * 2;			// use server too when it's quiet
Step 5: Initializes:
_targetID defaults to server (2)
_min is current local unit count × 2 (server gets lower priority when busy)
Sqf

Apply
{
	private _hcID = _x;
	private _num = {owner _x == _hcID} count allUnits;
	if (_num < _min) then {
		_targetID = _hcID;
		_min = _num;
	};
} forEach hcArray;
Step 6: Loops through each HC in hcArray:
Counts units owned by that HC
If this HC has fewer units than current minimum, selects it as target
Continues to find the least busy HC
Sqf

Apply
Info_2("Executing on machine ID %1, minimum units %2", _targetID, _min);
_params remoteExec [_function, _targetID];
Step 7: Logs selection and executes function on chosen target (HC or server)
Where it leads:

Calls:
remoteExec - executes function on target machine
owner - gets machine owner of unit
local - checks if unit is local
Depended by: Called by systems that need to distribute load: mission generation, patrol spawning, reinforcement calculations
Global Variables Modified: None
Network Implications: Uses remoteExec to distribute computation across multiple machines
Synchronization: Synchronizes work distribution across available machines
Fits into System: Load balancing system; ensures server performance by distributing computationally intensive tasks across available headless clients

Function Name: 
fn_sellVehicle.sqf
File Path: A3A/addons/core/functions/Base/fn_sellVehicle.sqf

What it does:
This function handles the logic for selling a vehicle in the Antistasi mod. It performs validation checks to ensure the vehicle is eligible for sale, calculates the sell price based on the vehicle's type and condition, transfers the funds to the faction, cleans up the vehicle entity, and removes it from persistent storage (if applicable). It is designed to be called remotely via remoteExecCall on the server.

Context:

It is typically triggered by a player action menu entry (e.g., "Sell Vehicle").
It must be executed on the Server or a Headless Client (HC), as indicated by the execution target 2.
It is protected against concurrent execution (spamming) using a lock variable.
How it does that:
The implementation is divided into four logical phases: Parameter Validation, Location/State Checks, Price Calculation, and Transaction/Deletion.

Phase 1: Parameter Validation and Initialization
The function starts by validating the inputs and setting up the execution environment.

Sqf

Apply
params [
    ["_player",objNull,[objNull]],
    ["_veh",objNull,[objNull]]
];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

#define OccAndInv(VAR) (FactionGet(occ, VAR) + FactionGet(inv, VAR))
Explanation:
params: Unpacks arguments. _player is the object initiating the sale; _veh is the cursorObject (target).
#include: Includes standard A3A scripting components.
#define: Creates a shorthand macro OccAndInv to combine Occupants and Invaders faction arrays, reducing code duplication in price checks.
Phase 2: Initial Checks (Location and Ownership)
Before processing the sale, several environmental and ownership checks are performed.

Sqf

Apply
_blacklistedAssets = [ ... ]; // Array of classnames like "ACE_I_SpottingScope", "O_Static_Designator_02_F", etc.

if (isNull _player) exitWith { Error("_player is null.") };
if (isNull _veh) exitWith {
    [localize "STR_A3A_Base_sellVehicle_header", localize "STR_A3A_reinf_airstrike_not_looking_at_veh"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};

private _nearAirfields = airportsX select {
    (sidesX getVariable [_x, sideUnknown] == teamPlayer) && 
    (getMarkerPos _x distance2D _veh <= 50)
};
private _isHQ = _veh distance (getMarkerPos "Synd_HQ") <= 50;

if (!_isHQ && _nearAirfields isEqualTo []) exitWith {
    [localize "STR_A3A_Base_sellVehicle_header", localize "STR_A3A_Base_sellVehicle_err0.1"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};

if ({isPlayer _x} count crew _veh > 0) exitWith {
    [localize "STR_A3A_Base_sellVehicle_header", localize "STR_A3A_Base_sellVehicle_err1"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};

private _owner = _veh getVariable ["ownerX",""];
if !(_owner isEqualTo "" || {getPlayerUID _player isEqualTo _owner}) exitWith {
    [localize "STR_A3A_Base_sellVehicle_header", localize "STR_A3A_Base_sellVehicle_err2"] remoteExecCall ["SCRT_fnc_misc_deniedHint",_player];
};
Explanation:
Blacklist: Defines an array of classnames (e.g., static spotter scopes) that have a sell value of 0 to prevent exploits.
Null Checks: Validates that both arguments are valid objects. If _veh is null, it returns a localized hint to the player.
Location Check: Verifies the vehicle is near the HQ (Synd_HQ marker) OR within 50m of a friendly airport (airportsX). If not, the sale is aborted.
Crew Check: Ensures no players are currently in the vehicle crew to prevent selling occupied vehicles or vehicles that players are using.
Ownership Check: Retrieves the ownerX variable from the vehicle. It allows the sale if the vehicle is unowned ("") OR if the requesting player's UID matches the owner. It blocks the sale if owned by someone else.
Phase 3: Concurrency Lock and Price Calculation
The function checks for a concurrent sale process and calculates the sell price based on vehicle classification.

Sqf

Apply
if (_veh getVariable ["A3A_sellVehicle_inProgress",false]) exitWith { ... };
_veh setVariable ["A3A_sellVehicle_inProgress",true,false];

private _typeX = typeOf _veh;
private _costs = call {
    if (_typeX in _blacklistedAssets) exitWith {0};
    if (_veh isKindOf "StaticWeapon") exitWith {100};
    if (_typeX in (FactionGet(all,"vehiclesReb") + ...)) exitWith { ([_typeX] call A3A_fnc_vehiclePrice) / 2 };
    
    // ... (Long chain of if/exitIf checks for different vehicle classes) ...
    if (_typeX in (FactionGet(all,"vehiclesPlanesGunship"))) exitWith {10000};
    0; // Default fallback
};
Explanation:
Concurrency Lock: Uses the variable A3A_sellVehicle_inProgress to prevent multiple processes from trying to sell the same vehicle simultaneously.
Price Calculation (call block):
Logic Flow: A sequential call block evaluates the vehicle type against specific categories.
Priority: It checks specific classes first (e.g., StaticWeapon = 100), then faction lists (rebels, civilians), then generic types (trucks, tanks, planes).
Damage Penalty: Later in the script, the base cost is multiplied by (1 - damage _veh), meaning damaged vehicles sell for less.
Fallback: Returns 0 if no category matches.
Phase 4: Transaction and Cleanup
If the cost is valid (>0), the funds are added, and the vehicle is cleaned up.

Sqf

Apply
if (_costs == 0) exitWith {
    _veh setVariable ["A3A_sellVehicle_inProgress",false,false];
    // ... error hint ...
};

_costs = round (_costs * (1-damage _veh));

[0,_costs] remoteExec ["A3A_fnc_resourcesFIA",2];

if (_veh in staticsToSave) then {staticsToSave = staticsToSave - [_veh]; publicVariable "staticsToSave"};

[_veh,true] call A3A_fnc_empty;

if (_veh isKindOf "StaticWeapon") then {deleteVehicle _veh};

[localize "STR_A3A_Base_sellVehicle_header", localize "STR_A3A_Base_sellVehicle_success"] remoteExecCall ["A3A_fnc_customHint",_player];
Explanation:
Damage Adjustment: Calculates the final price based on current vehicle health.
Resource Update: Calls A3A_fnc_resourcesFIA remotely on the server (argument 2) to add the money to the global faction funds.
Persistence Removal: If the vehicle exists in the global array staticsToSave (used for saving static weapons to the database), it is removed and the variable is broadcast via publicVariable.
Emptying Cargo: Calls A3A_fnc_empty to remove any items or units inside the vehicle.
Deletion: Deletes the vehicle object specifically if it is a StaticWeapon. Note: Other vehicles are typically not deleted immediately here, but A3A_fnc_empty handles crew deletion. Correction: Looking at the code, deleteVehicle is only for statics. For other vehicles, they might remain as world objects or be handled by garbage collection, but the main intent is to process the sale, not necessarily despawn the physical entity (unless it's a static gun, which is treated as an item).
Success Hint: Sends a localized success message back to the player.
Where it leads:
Called Functions:

A3A_fnc_vehiclePrice: (Called via call) Retrieves the base purchase price of the vehicle from the template definitions.
SCRT_fnc_misc_deniedHint: (Called via remoteExecCall) Displays a red notification to the player explaining why the sale failed (e.g., "Wrong zone").
A3A_fnc_resourcesFIA: (Called via remoteExec) Updates the global money pool of the faction (Server side).
A3A_fnc_empty: Cleans the vehicle contents (cargo, dead bodies, alive crew).
A3A_fnc_customHint: (Called via remoteExecCall) Displays a green notification confirming the sale success.
Dependent Functions:

This function relies on A3A_fnc_vehiclePrice being defined to calculate values for custom rebel vehicles.
It depends on A3A_fnc_resourcesFIA to actually credit the money.
Global Variables Modified:

staticsToSave: Directly modifies this global array by removing the vehicle object. It then triggers publicVariable "staticsToSave" to sync this change to all clients.
ownerX: (Indirectly) The sale invalidates the ownership by deleting the entity.
A3A_sellVehicle_inProgress: Sets and unsets a locking variable on the specific vehicle object.
Network Implications:

Server/HC Authority: All logic executes on the server (or HC) as defined by the execution target 2 in the calling action.
Remote Execution: Uses remoteExecCall to send UI feedback (hints) back to the individual client.
Public Variable: publicVariable "staticsToSave" is a heavy network operation used to update the persistent save state for static weapons across all connected clients.
Edge Cases:

Null Arguments: Handled immediately.
Invalid Location: Handled by checking HQ distance and airport proximity.
Occupied Vehicle: Handled by checking crew count.
Soldier Ownership: Handled by checking ownerX variable against player UID.
Concurrent Execution: Handled by the boolean lock.
Zero Value: Handled by checking if _costs == 0 before proceeding.
Damage: Handled by applying (1 - damage) multiplier.
Function Name: 
fn_setMarkerAlphaForSide.sqf
File Path: A3A/addons/core/functions/Base/fn_setMarkerAlphaForSide.sqf

What it does:
This function sets the transparency (alpha) of a specific map marker for a specific side only. It ensures that the setting persists for players joining late (JIP - Join In Progress) by storing the request in the network JIP queue.

Context:

Used for side-specific visual markers (e.g., showing a marker to the rebellion but hiding it from occupant/invader forces).
Executed on the Server or HC to control global visibility settings.
How it does that:
The function creates a unique JIP ID and executes the setMarkerAlphaLocal command locally for the specified side.

Sqf

Apply
params ["_marker", "_alpha", "_side"];

private _jipId = _marker + (str _side);

[_marker, _alpha] remoteExec ["setMarkerAlphaLocal", _side, _jipId];
Step-by-step breakdown:

Parameter Unpacking:

params ["_marker", "_alpha", "_side"]: Takes the marker name (string), desired alpha value (0 to 1), and the side (e.g., west, resistance).
JIP ID Generation:

private _jipId = _marker + (str _side): Creates a unique identifier string for the remote execution. This is crucial for the JIP queue. If a player connects later, the engine checks this ID; if it exists in the queue, the command is executed for the new player. Using the marker name and side ensures that updates to the same marker/side combination overwrite previous entries.
Remote Execution:

remoteExec ["setMarkerAlphaLocal", _side, _jipId]: This is the core command.
"setMarkerAlphaLocal": The command to execute on the target machine. It modifies the alpha of a marker only on that local machine (not globally).
_side: The target. The command only runs on machines belonging to this side.
_jipId: Registers the execution with the JIP system. This ensures that any player who joins after this command is called will still receive it and have their marker alpha updated.
Where it leads:
Called Functions:

setMarkerAlphaLocal: This is a built-in Arma 3 engine command, not a script function. It sets the alpha of a marker locally.
Dependent Functions:

This function is a utility wrapper. It is likely called by other logic that manages fog of war, objective visibility, or base management (e.g., A3A_fnc_mrkUpdate or A3A_fnc_markerChange).
Global Variables Modified:

None directly. It relies on the global marker system.
Network Implications:

Local Execution: The actual alpha change happens client-side (locally), ensuring performance is not impacted by sending marker updates across the network continuously.
JIP Queue: The _jipId is critical. It adds the command to the "Join in Progress" queue on the server.
If side is sideUnknown or civilian, it might target everyone or no one depending on how the engine handles it, but typically this is used for teamPlayer (rebels), occupants, or invaders.
Edge Cases:

Invalid Marker: If _marker does not exist locally on the client, setMarkerAlphaLocal will have no effect or throw a warning in RPT logs, but the script will not crash.
Non-Standard Sides: If _side is not a recognized side object (e.g., sideUnknown), the command will likely not execute on any client.

Function Name: 
fn_setPlaneLoadout.sqf
What it does: This function equips a specific aircraft object (_plane) with a predefined loadout based on the requested mission type (_type). It serves as a centralized loadout management system for the A3A framework, ensuring that planes spawn with the correct weapons, pylons, and specific internal variables required for AI behavior (like dive parameters for CAS).

It handles three primary mission profiles:

"CAS": Close Air Support (Loitering/Hunting).
"CASDIVE": Dive Bombing (Precise strikes with specific parameters).
"AA": Air-to-Air (Interception/Patrol).
It supports a massive list of vanilla and modded aircraft via two methods:

Config-Driven: Checks an internal A3U config for loadout definitions.
Hardcoded Fallback: If the plane isn't in the config, it falls back to a massive switch-case statement handling specific classnames.
How it does that:

1. Parameter Validation and Initialization
The function begins by defining the parameters and initializing variables to store loadout components.

Sqf

Apply
params ["_plane", "_type"];

private _validInput = false;
private _loadout = [];

private _mainGun = "";
private _rocketLauncher = [];
private _missileLauncher = [];
private _bombRacks = [];
private _diveParams = [];
Logic: Accepts _plane (Object) and _type (String). Initializes empty containers for weapon types and dive parameters. These variables will be populated and attached to the plane object later.
2. Config-Based Loadout Check
The function first checks if the plane's class name exists in a custom configuration hierarchy (configfile >> "A3U" >> "planeLoadouts"). This allows for modularity and easy additions without editing the script.

Sqf

Apply
private _cfgPath = (configfile >> "A3U" >> "planeLoadouts");
private _cfgAA = (_cfgPath >> "AA");
private _cfgCASDIVE = (_cfgPath >> "CASDIVE");
private _cfgCAS = (_cfgPath >> "CAS");
private _cfgAAClasses = _cfgAA call BIS_fnc_getCfgSubClasses;
private _cfgCASDIVEClasses = _cfgCASDIVE call BIS_fnc_getCfgSubClasses;
private _cfgCASClasses = _cfgCAS call BIS_fnc_getCfgSubClasses;

private _cfg = _cfgAAClasses + _cfgCASDIVEClasses + _cfgCASClasses;

if ((typeOf _plane) in _cfg) exitWith { ... };
Logic: It retrieves all class names defined in the A3U config for AA, CASDIVE, and CAS. It combines them into _cfg.
Validation: If the current plane's type is found in this list, it proceeds to extract data from the config and exitWith.
Inside the Config Block: Once a match is found, it determines which specific loadout type was requested:

Sqf

Apply
switch (_type) do
{	
    case "CASDIVE": {
        _loadout = getArray (_cfgCASDIVE >> (typeOf _plane) >> "loadout");
        _mainGun = [(_cfgCASDIVE >> (typeOf _plane)), "mainGun", ""] call BIS_fnc_returnConfigEntry;
        // ... (repeats for rocketLauncher, missileLauncher, bombRacks, diveParams)
    };
    // ... (Similar blocks for CAS and AA)
};
Logic: It reads the loadout array (pylon magazines), mainGun classname, and other specific variables from the config.
Data Extraction: BIS_fnc_returnConfigEntry is used to safely read values, providing a default empty value if the entry is missing.
Setting Plane Variables: After extracting data, it applies it to the plane object:

Sqf

Apply
if !(_mainGun isEqualTo "") then {
    _plane setVariable ["mainGun", _mainGun];
};
// ... (Repeats for other weapon types)

if !(_diveParams isEqualTo []) then {
    _plane setVariable ["diveParams", _diveParams];
} else {
    // Apply default dive params if none defined
    _plane setVariable ["diveParams", [1000, 600, 180, 55, 15, [0, 0]]];
};
Technical Detail: Uses setVariable to store data locally on the entity. This is critical because later scripts (like SUP_CASDiveRoutine) read these variables to decide which weapons to fire.
Fallback: If diveParams is missing from the config, it applies a generic default (Start Alt: 1000m, End Alt: 600m, etc.).
Applying the Loadout: It then iterates through the _loadout array to apply pylon loadouts.

Sqf

Apply
if !(_loadout isEqualTo []) then {
    {
        _plane setPylonLoadout [_forEachIndex + 1, _x, true];
        _plane setVariable ["loadout", _loadout];
    } forEach _loadout;
} else {
    // Fallback to existing plane loadout if config array is empty
    _loadout = getPylonMagazines _plane;
    {
        _plane setPylonLoadout [_forEachIndex + 1, _x, true];
        _plane setVariable ["loadout", _loadout];
    } forEach _loadout;
};
Logic: setPylonLoadout applies the magazine to the specific pylon index. _forEachIndex + 1 accounts for the 1-based indexing required by the command.
Edge Case: If the config defines an empty array, it grabs the plane's current magazines (default loadout) and applies them, ensuring the variable loadout is still set.
3. Hardcoded Fallback (The "Big Switch")
If the plane is not found in the config, the function proceeds to the hardcoded switch (typeOf _plane) do block. This is the legacy/mod support section.

A. Handling "CASDIVE" Type: If _type is "CASDIVE", _validInput is set to true. It uses a switch on the plane's class name to set specific arrays and variables.

Sqf

Apply
if (_type == "CASDIVE") then
{
    _validInput = true;
    switch (typeOf _plane) do
    {
        // Vanilla NATO A-10
        case "B_Plane_CAS_01_dynamicLoadout_F": {
            _loadout = ["","","","","PylonMissile_1Rnd_Bomb_04_F","..."];
            _plane setVariable ["mainGun", "Gatling_30mm_Plane_CAS_01_F"];
            _plane setVariable ["bombRacks", ["Bomb_04_Plane_CAS_01_F", "BombCluster_03_F"]];
            _plane setVariable ["diveParams", [1000, 600, 180, 55, 15, [0, 0]]];
        };
        // ... (Hundreds of other cases for RHS, CUP, Unsung, etc.)
        default {
            Error_1("Plane type %1 currently not supported for CASDIVE...", typeOf _plane);
        };
    };
};
Logic: Explicitly defines the pylon layout for specific class names.
Data Structure: _loadout is an array of strings corresponding to pylon magazines.
Dive Parameters: _diveParams is defined as [StartAlt, EndAlt, DiveSpeed, DiveAngle, TurnRate, BombOffset].
Example: [1000, 600, 180, 55, 15, [0, 0]] means the plane starts the dive at 1000m, ends at 600m, travels at 180m/s, starts the dive at 55 degrees, turns at 15 deg/s, and has a 0m bomb offset.
Error Handling: The default case logs an error if an unregistered plane attempts to use this function.
B. Handling "CAS" Type: Similar to CASDIVE, but specifically for standard loitering CAS.

Sqf

Apply
if (_type == "CAS") then {
    _validInput = true;
    switch (typeOf _plane) do {
        case "B_Plane_CAS_01_dynamicLoadout_F": {
            _loadout = ["PylonRack_7Rnd_Rocket_04_AP_F", "..."];
            _plane setVariable ["mainGun", "Gatling_30mm_Plane_CAS_01_F"];
            _plane setVariable ["rocketLauncher", ["missiles_DAR", "..."]];
            _plane setVariable ["missileLauncher", ["missiles_SCALPEL", "..."]];
        };
        // ...
    };
};
Logic: This path populates rocketLauncher and missileLauncher arrays, which are used by AI pilots to select weapons for strafing or guided missile attacks.
C. Handling "AA" Type:

Sqf

Apply
if (_type == "AA") then {
    switch (typeOf _plane) do {
        case "B_Plane_CAS_01_dynamicLoadout_F": {
            _loadout = ["PylonRack_1Rnd_Missile_AA_04_F", "", "PylonRack_1Rnd_AAA_missiles", "..."];
            _plane setVariable ["mainGun", "Gatling_30mm_Plane_CAS_01_F"];
        };
        // ...
    };
};
Logic: Configures the plane with Air-to-Air missiles (AIM-9, AIM-120, R-73, etc.).
4. Final Application (Hardcoded)
After the if (_type == "X") blocks, the function applies the generated _loadout.

Sqf

Apply
if !(_loadout isEqualTo []) then
{
    Debug("Selected new loadout for plane, now equiping plane with it");
    {
        _plane setPylonLoadout [_forEachIndex + 1, _x, true];
        _plane setVariable ["loadout", _loadout];
    } forEach _loadout;
} else {
    _loadout = getPylonMagazines _plane;
    Debug_1("Selected default loadout for %1...", typeOf _plane);
    {
        _plane setPylonLoadout [_forEachIndex + 1, _x, true];
        _plane setVariable ["loadout", _loadout];
    } forEach _loadout;
};
Logic: This is the execution phase. It physically modifies the vehicle in the game world.
Safety: The else block acts as a catch-all. If _loadout is still empty (meaning the plane wasn't in config, and the hardcoded switch failed to match), it defaults to the plane's existing pylons to prevent an unarmed plane from spawning.
5. Debugging
Finally, it logs the result.

Sqf

Apply
Debug_2("Given plane class %1 a loadout of %2", typeOf _plane, _loadout);
Where it leads:
Functions Called (Internal & External):

BIS_fnc_getCfgSubClasses: Called to scan the A3U config hierarchy. It returns an array of all class names defined in a config node.
BIS_fnc_returnConfigEntry: Called repeatedly to read specific config values (like mainGun or diveParams) with fallback defaults.
setPylonLoadout: (Engine Command) The core command that physically applies the magazine to the pylon slot on the model.
setVariable: (Engine Command) Used to store metadata (mainGun, bombRacks, diveParams) on the plane object for other systems to read.
Debug / Debug_1 / Debug_2: Custom logging macros (defined in script_component.hpp) used to output information to the RPT log if debugging is enabled.
Functions Dependent on this one:

A3A_fnc_SUP_CAS / A3A_fnc_SUP_CASDive: These support functions spawn the plane and then immediately call setPlaneLoadout to equip it before sending it to the target area.
A3A_fnc_createAIAirplane: Used during mission generation (e.g., enemy air patrols) to ensure patrol planes have appropriate weapons.
A3A_fnc_addFIAveh: If a player buys an aircraft from the garage/hq, this might be called to ensure it has a standard loadout.
Global Variable Modifications:

Local Variables on _plane:
"mainGun": String classname of the main cannon.
"rocketLauncher": Array of rocket types available.
"missileLauncher": Array of missile types available.
"bombRacks": Array of bomb types available.
"diveParams": Array [alt_start, alt_end, speed, angle, turnRate, offset].
"loadout": Array of the currently applied pylon magazines.
These variables are essential for the AI logic. For example, A3A_fnc_SUP_CASDiveRoutine specifically looks for "bombRacks" and "diveParams" to perform the attack run.

Function Name: fn_sizeMarker.sqf
What it does: This function calculates the "size" of a map marker by returning the larger of its width and height dimensions (in meters). It's used in various places where the game needs to approximate a marker's scale for area-based calculations, such as determining patrol zones, spawn radii, or trigger ranges. The function is called whenever a specific marker's bounding size is needed for a logic check or placement calculation.

How it does that: The implementation follows a straightforward mathematical comparison process.

1. Parameter Validation & Initialization:

Sqf

Apply
params ["_markerX"];
private _size = 0;
private _area = markerSize _markerX;
Step: The function accepts a single parameter, _markerX, which is expected to be the name (string) of a map marker.
Logic: It initializes _size to 0 and uses the markerSize command to retrieve the marker's dimensions. markerSize returns an array [width, height].
Technical Detail: markerSize is a built-in Arma command. No explicit validation is performed here; if _markerX is invalid, markerSize will likely return [0,0] or a similar default.
2. Size Comparison Logic:

Sqf

Apply
_size = _area select 0;
if (_size < _area select 1) then {_size = _area select 1};
Step: The function takes the first element (width) of the _area array and assigns it to _size.
Logic: It then compares _size with the second element (height). If the width is smaller than the height, _size is overwritten with the height.
Result: At the end, _size holds the maximum value between the marker's width and height. This represents the marker's "radius" if it were circular, or its longest axis if rectangular.
3. Return Value:

Sqf

Apply
_size
Step: The final calculated value is returned implicitly (the last expression in a function is the return value).
Output: A single number representing the larger dimension of the marker.
Where it leads:

Functions this calls:
markerSize (Built-in command): Retrieves the width and height of the specified marker.
Functions depending on this:
A3A_fnc_updateRebelStatics: Calls fn_sizeMarker (or uses similar logic) to determine the search radius for static weapons within a marker.
A3A_fnc_zoneCheck: Uses markerSize internally (which is what fn_sizeMarker calculates) to determine the capture radius for zone ownership changes.
A3A_fnc_garrisonUpdate: Likely uses marker size to determine how many units are needed for a garrison based on the area.
Larger System Context: This is a utility function used in the base system for spatial calculations. It abstracts the logic of getting a single scalar value for a marker's scale, simplifying calculations for other systems that need to treat markers as circular areas regardless of their actual shape.
Global Variables: None modified.
Synchronization/Network: None. Purely local calculation.
Function Name: fn_splitVehicleCrewIntoOwnGroups.sqf
What it does: This function takes a vehicle and separates its crew into individual, single-person groups. It's used when a vehicle is captured or abandoned, and the game wants to make the crew members independent units (e.g., for AI behavior, garrison logic, or player interaction) rather than remaining attached to a vehicle group.

How it does that: The function iterates through the crew and creates a new group for each member.

1. Parameter Validation & Initial Setup:

Sqf

Apply
params ["_vehicle"];
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

Debug_2("Splitting the crew of %1, type of %2", _vehicle, typeOf _vehicle);
Step: Accepts the _vehicle object.
Logic: Includes debug macros and logs the action. This is standard for A3A debugging.
Edge Case Handling: No explicit null check, but later logic handles empty crew.
2. Crew Extraction:

Sqf

Apply
private _crew = fullCrew _vehicle select {_x select 1 != "cargo"};
if (_crew isEqualTo []) exitWith {
    [ [], "" ];
};
Step: Uses fullCrew to get all crew members. The select statement filters out passengers (role "cargo").
Logic: The function only processes actual crew (driver, gunner, commander, turret positions).
Exit Condition: If no crew is found (only cargo), it returns an empty array and an empty string immediately.
3. Group Creation and Assignment Loop:

Sqf

Apply
private _crewGroups = [];
private _groupName = groupId group (_crew select 0 select 0);

{
    private _unit = _x select 0;
    private _group = createGroup [side _unit, true];

    [_unit] join _group;
    _group setGroupId [_groupName + "#" + str _forEachIndex];

    _crewGroups pushBack _group;
} forEach _crew;
Step 1: Initializes an empty array _crewGroups to store the new groups.
Step 2: Extracts the original group name from the first crew member's current group.
Logic (Loop):
For each crew member entry, extract the unit object (_x select 0).
Create a new, local group for that unit's side. The true parameter creates the group locally.
Join the unit to this new group.
Rename the new group by appending an index to the original group name (e.g., "Alpha 1-1" becomes "Alpha 1-1#0").
Push the new group object into the _crewGroups array.
Technical Detail: createGroup [side, true] is crucial for local group creation to avoid network latency.
4. Return Value:

Sqf

Apply
[_crewGroups, _groupName];
Step: Returns an array containing the list of new groups and the original group's base name.
Output: [_group1, _group2, ...], "GroupName".
Where it leads:

Functions this calls:
fullCrew (Built-in): Gets crew information.
group, groupId (Built-in): Retrieves original group info.
createGroup (Built-in): Creates new groups.
join (Built-in): Assigns units to new groups.
Functions depending on this:
A3A_fnc_vehKilledOrCaptured: Likely called when a vehicle is captured to disband the crew.
A3A_fnc_createVehicleCrew: Might be used in reverse logic for spawning.
Larger System Context: Part of the vehicle and unit management system. It handles the transition of units from a vehicle context to an independent ground unit context, which is essential for AI logic (e.g., crew fleeing after vehicle destruction).
Global Variables: None modified directly. Creates new local groups.
Synchronization/Network: The groups are created locally (true parameter). The units are moved locally. This is efficient for immediate AI response. The resulting groups are not synced globally unless explicitly handled by a later function.
Function Name: fn_startBreachVehicle.sqf
What it does: Initiates a breaching action on a locked vehicle. It performs extensive checks (player status, required explosives, vehicle state), plays an animation, consumes explosives, applies damage to specific hitpoints, and potentially destroys the vehicle or forces the crew to surrender. This is a complex action for players to disable enemy vehicles.

How it does that: The function acts as a state machine with validation, an animation state, and a post-animation effect application.

1. Parameter & Initial Validation:

Sqf

Apply
params["_vehicle", "_caller", "_actionID"];

if(!isPlayer _caller) exitWith { ... };
if !(_caller call A3A_fnc_isEngineer) exitWith { ... };
if(!alive _vehicle) exitWith { _vehicle removeAction _actionID; };
Step: Takes the vehicle, the player performing the action, and the action ID.
Logic:
Checks if the caller is a player. If not, denies access.
Checks if the caller is an engineer (using A3A_fnc_isEngineer). If not, denies access.
Checks if the vehicle is alive. If not, removes the action and exits.
Error Handling: Shows denial hints for invalid users.
2. Crew State Validation:

Sqf

Apply
private _vehCrew = crew _vehicle;
private _aliveCrew = _vehCrew select {alive _x};
if(count _aliveCrew == 0) exitWith { ... };
if(side (_aliveCrew select 0) == teamPlayer) exitWith { ... };
Step: Retrieves the crew and filters for living members.
Logic:
If no living crew, the vehicle is already effectively disabled. Shows hint and unlocks vehicle/removes action.
If the crew is on the player's side (rebels), prevents the breach.
Edge Cases: Handles empty crew and friendly crew.
3. Explosive Detection & Selection:

Sqf

Apply
private _magazines = magazines _caller;
private _magazineArray = [];
// ... sorting logic ...
private _needed = FactionGet(reb, (if(_isTank) then {"breachingExplosivesTank"} else {"breachingExplosivesAPC"}));
private _explo = [_needed, _magazineArray] call _fn_selectExplosive;
Step: Scans the caller's magazines, counts them, and matches against faction-defined required explosives.
Logic:
Sorts magazines into an array [[magClassname, count], ...].
Retrieves required explosive types from the faction config (different for tanks vs APCs).
Uses a nested helper function _fn_selectExplosive to check if the player has sufficient quantities of the required magazines.
Technical Detail: FactionGet is a global function retrieving configuration data. The helper function validates counts strictly.
4. Animation & State Initiation:

Sqf

Apply
private _time = 15 + (random 5);
// ... tank specific adjustments ...
_caller setVariable ["timeToBreach", time + _time];
_caller playMoveNow selectRandom medicAnims;
_caller setVariable ["breachVeh", _vehicle];
_caller setVariable ["animsDone", false];
_caller setVariable ["cancelBreach", false];
private _action = _caller addAction [ ... cancel ... ];
_vehicle removeAction _actionID;
Step: Calculates breach time based on vehicle type. Sets several public variables on the caller to track state.
Logic:
Assigns a timer limit.
Starts the healing animation (simulating placing charges).
Adds a "Cancel Breach" action to the player.
Removes the original breach action from the vehicle.
Network: Variables are set locally (default). addAction is local.
5. Animation Monitoring Loop (Event Handler):

Sqf

Apply
_caller addEventHandler ["AnimDone", {
    private _caller = _this select 0;
    private _vehicle = _caller getVariable "breachVeh";
    if ( /* checks for valid state */ ) then {
        _caller playMoveNow selectRandom medicAnims; // Repeat animation
    } else {
        _caller removeEventHandler ["AnimDone", _thisEventHandler];
        _caller setVariable ["animsDone", true];
    };
}];
Step: Attaches an AnimDone event handler to the caller.
Logic:
Checks if the vehicle is alive, caller is near, caller can fight, time hasn't expired, and cancel hasn't been pressed.
If valid, it loops the animation.
If invalid, it cleans up the handler and sets animsDone to true.
State Management: This creates a continuous loop that breaks only when the action is finished or cancelled.
6. Wait for Completion & Post-Validation:

Sqf

Apply
waitUntil {sleep 0.5; (_caller getVariable ["animsDone", false])};

// ... cleanup ...

if ( /* vehicle destroyed/moved/invalid */ ) exitWith { ... };
Step: The main thread sleeps until the animation loop signals completion.
Logic: After waking up, it performs a final check. If the vehicle is gone, the caller moved too far, etc., it cancels the breach and restores the action on the vehicle.
7. Effects Application (Explosive Removal & Damage):

Sqf

Apply
for "_count" from 1 to _explosiveCount do { _caller removeMagazineGlobal _explosive; };
sleep 10;

// ... Hitpoint Damage Logic ...
private _result = _currentDamage + _damageDealt;
if(_result > 1) then {_result = 1};
_vehicle setHit [_hullHitPoint, _result];
Step: Removes the required number of magazines. Waits 10 seconds (explosive timer). Applies damage to Hull, Fuel, Engine, and Body hitpoints.
Logic:
Calculates new damage, capping it at 1 (total destruction).
Uses setHit to apply specific damage to named hitpoints.
If total damage > 0.9, it creates a scripted explosive and destroys the vehicle.
Technical Detail: Uses configFile to look up hitpoint names dynamically based on vehicle type.
8. Crew Handling & Cleanup:

Sqf

Apply
_vehicle lock 0;
{
    if(random 10 > 7) then { _x setDamage 1; };
    if(alive _x) then {
        moveOut _x;
        [_x] remoteExec ["A3A_fnc_surrenderAction", _x];
    };
} forEach _crew;

[_vehicle, teamPlayer, true] call A3A_fnc_vehKilledOrCaptured;
Step: Unlocks vehicle. Iterates through original crew.
Logic:
Randomly kills some crew members (30% chance).
Moves living crew out and executes A3A_fnc_surrenderAction locally on them.
Calls A3A_fnc_vehKilledOrCaptured to register the vehicle as captured by rebels.
Where it leads:

Functions this calls:
A3A_fnc_isEngineer (Custom): Checks unit qualification.
SCRT_fnc_misc_deniedHint (Custom): Shows error messages.
A3A_fnc_customHint (Custom): Shows success/progress messages.
FactionGet (Custom): Retrieves config data.
A3A_fnc_surrenderAction (Custom): Makes AI surrender.
A3A_fnc_vehKilledOrCaptured (Custom): Registers vehicle capture.
addEventHandler (Built-in): Manages animation loop.
removeMagazineGlobal (Built-in): Consumes items.
setHit (Built-in): Applies damage.
createVehicle (Built-in): Spawns explosion.
Functions depending on this:
A3A_fnc_addActionBreachVehicle: Adds the action that calls this function.
Larger System Context: Part of the interactive mission mechanics, specifically vehicle capture/destroy. It integrates player skills, inventory, AI response, and network commands.
Global Variables: Modifies local variables on the caller (breachVeh, animsDone, cancelBreach).
Synchronization/Network: removeMagazineGlobal syncs inventory removal. remoteExec is used to trigger surrender logic on specific crew members locally.
Function Name: fn_startTestingTimer.sqf
What it does: Manages a periodic timer (every 5 minutes) to track "testing time" for the mission creator (Wurzel). It counts active players (based on movement) and adds weighted time to a counter. This is likely for balancing gameplay durations or resource generation based on active playtime.

How it does that: Runs a persistent server-side loop with sleep intervals and player position checks.

1. Initialization & Suspended Execution:

Sqf

Apply
#define TESTING_INTERVAL 300

if !(canSuspend) exitWith {
    [] spawn A3A_fnc_startTestingTimer;
};

Debug("Starting testing timer now");
testingTimerIsActive = true;
private _testedTime = 0;
Step: Defines the interval (300 seconds). Ensures the function is suspended (sleeps); if not, it spawns itself.
Logic: Sets a global flag testingTimerIsActive and initializes the accumulator _testedTime.
Technical Detail: canSuspend checks if the execution context allows sleeping.
2. Player Activity Snapshot:

Sqf

Apply
private _peopleOnline = [];
{
    _peopleOnline pushBack [_x, getPos _x];
} forEach (allPlayers - (entities "HeadlessClient_F"));
Step: Creates an initial snapshot of all human players and their positions.
Logic: Filters out Headless Clients to only count active human players.
3. Main Loop:

Sqf

Apply
while {true} do {
    // Sleep if no players
    if (count (allPlayers - (entities "HeadlessClient_F")) == 0) then {
        waitUntil {sleep 10; (count (allPlayers - (entities "HeadlessClient_F")) > 0)};
    };

    sleep TESTING_INTERVAL; // 5 minutes
    // ... logic ...
};
Step: Enters an infinite loop.
Logic: First, checks if any players are online. If not, it sleeps in 10-second increments until players return. Then, it sleeps for the main TESTING_INTERVAL.
4. Activity Calculation:

Sqf

Apply
private _newOnline = [];
private _index = 0;
{
    private _player = _x;
    _index = _peopleOnline findIf {(_x select 0) isEqualTo _player};
    if(_index != -1) then {
        if((_peopleOnline select _index select 1) distance (getPos _player) > 5) then {
            _playersActive = _playersActive + 1;
        };
    };
    _newOnline pushBack [_player, getPos _player];
} forEach (allPlayers - (entities "HeadlessClient_F"));

_peopleOnline = _newOnline;
Step: Iterates through current players, comparing their current position to the stored position from the last cycle.
Logic: If a player moved more than 5 meters, they are counted as "active".
Technical Detail: Uses findIf for efficient array lookup. Updates the snapshot with new positions.
5. Time Accumulation & Logging:

Sqf

Apply
_playersActive = _playersActive min 10;
_testedTime = _testedTime + (_playersActive * TESTING_INTERVAL);

Debug_3(...);
Step: Caps active players at 10. Adds ActivePlayerCount * 300 seconds to _testedTime.
Logic: The "testing time" is weighted by active player count. Logs the total hours, cycle hours, and player count.
Variables: Modifies _testedTime (local), _playersActive (local).
6. Reset & Loop Continuation:

Sqf

Apply
_playersActive = 0;
Step: Resets the counter for the next iteration.
Logic: The loop repeats indefinitely (or until mission end).
Where it leads:

Functions this calls:
spawn (Built-in): Resumes execution if needed.
getPos (Built-in): Gets player locations.
entities (Built-in): Filters player list.
distance (Built-in): Calculates movement.
Functions depending on this:
None identified in the provided snippets, but likely used by mission scripting or admin tools to track server uptime/load.
Larger System Context: Administrative/Development tool. It provides metrics on how long the mission has been actively played, which can influence resource gain rates or event triggers in custom mission logic.
Global Variables: Sets testingTimerIsActive = true.
Synchronization/Network: Runs entirely on the server (Server scope). No network traffic other than reading player states.
Function Name: fn_statistics.sqf
What it does: Updates the on-screen information bar (H8erHUD) with live player and mission data. It displays money, rank, commander, HR (Human Resources), aggression levels, rally point status, and economy currency.

How it does that: Gathers data from global variables and remote server variables, formats a structured text string, and updates a UI control.

1. UI & Environment Check:

Sqf

Apply
if (!hasInterface) exitWith {};
disableSerialization;
if (isNull (uiNameSpace getVariable "H8erHUD")) exitWith {};
private _display = uiNameSpace getVariable "H8erHUD";
Step: Ensures the script runs only on clients with an interface. Checks if the HUD exists in the UI namespace.
Logic: Exits immediately if the UI isn't available.
2. Data Collection (Local & Global):

Sqf

Apply
private _player = player getVariable ["owner",player];
private _rank = localize (rank _player);
private _ucovertxt = ... select ((captive _player) and !(_player getVariable ["incapacitated",false]));
private _rallytxt = ... select (!isNil "isRallyPointPlaced" && {isRallyPointPlaced});
private _rivalsActivityTxt = ... select (areRivalsEnabled && ...);
Step: Retrieves player-specific data.
Logic:
owner: Handles remote control (Zeus/AI).
rank: Localizes the rank string.
ucovertxt: Checks captive and incapacitated variables for undercover status.
rallytxt: Checks global isRallyPointPlaced.
rivalsActivityTxt: Checks global flags for rival activity status.
Technical Detail: Uses localize for string table lookups. Uses ternary selection logic for dynamic text.
3. Aggression String Logic:

Sqf

Apply
switch (gameMode) do {
    case 3: { ... }; // Specific logic for game mode 3
    default { ... }; // Standard logic for occupant/invader aggression
};
Step: Builds the aggression display string based on the current game mode and defeated status.
Logic: Uses a switch statement to handle different display requirements (single faction vs dual faction). Calls A3A_fnc_getAggroLevelString to get textual descriptions of aggression levels.
4. HR Limit Calculation:

Sqf

Apply
if (limitHR != 0) then {
    _hrLimit = (((tierWar * 100) * (limitHR / 100)) + 100);
    _hrMax = format[" / %1",_hrLimit];
};
Step: Checks if a hard HR limit is active.
Logic: Calculates the max HR based on war tier and the configured limit percentage. Formats a string like " / 100".
5. Commander Name Logic:

Sqf

Apply
if (isNil "theBoss" || {theBoss isEqualTo objNull}) exitWith { ... format string with "None" ... };

if (_player != theBoss) then { ... } else { ... };
Step: Determines how to display the commander.
Logic:
If no commander exists, defaults to "None".
If the current player is the commander, it uses a different string format (STR_info_bar_final_string_2) emphasizing rebel resources.
If the player is not the commander, it uses STR_info_bar_final_string_1 showing the commander's name.
6. UI Update:

Sqf

Apply
_setText ctrlSetStructuredText (parseText format ["%1", _textX]);
_setText ctrlCommit 0;
Step: Parses the formatted text string into structured text and applies it to the control.
Logic: ctrlCommit 0 forces an immediate visual update.
Where it leads:

Functions this calls:
A3A_fnc_getAggroLevelString (Custom): Converts numeric aggression to text.
SCRT_fnc_rivals_getActivityLevelString (Custom): Converts rivals inactivity level to text.
localize (Built-in): String table lookup.
parseText (Built-in): Converts tags to text.
ctrlSetStructuredText (Built-in): UI update.
Functions depending on this:
A3A_fnc_customHint / Mission Events: Often triggered alongside or as part of the HUD update cycle.
Larger System Context: Core UI component. It acts as a centralized dashboard for critical mission state information, improving player awareness.
Global Variables: Reads theBoss, isRallyPointPlaced, tierWar, limitHR, gameMode, aggressionLevelOccupants, aggressionLevelInvaders, areRivalsEnabled, etc.
Synchronization/Network: Relies on global variables (synchronized by the server) and local player state. No direct network calls.
Function Name: fn_stripGearFromLoadout.sqf
What it does: Strips a unit's loadout down to essentials, keeping only the uniform (with content) and specific unlocked utility items (map, GPS, compass, watch, radio). It returns a new loadout array.

How it does that: Clones the original loadout, nullifies weapon and inventory arrays, then selectively restores valid items.

1. Input & Deconstruction:

Sqf

Apply
private _originalLoadout = _this;

private _uniform = _originalLoadout select 3;
private _uniform = if (count _uniform > 0) then {[_uniform select 0,[]]} else {[]};
Step: The entire loadout array is passed as _this.
Logic:
Extracts the uniform (index 3).
If a uniform exists, it keeps the uniform class name but clears its inventory (removes items inside the uniform).
Result is an empty uniform: [uniformClass, []].
2. New Loadout Construction:

Sqf

Apply
private _newLoadout = [
    [], [], [],  // Weapons & Mags
    _uniform,    // Uniform
    [], [],      // Vest & Backpack
    "", "",      // Helmet & Facewear
    [],          // Binoculars
    ["", "", "", "", "", ""] // Special Items (Map, GPS, etc.)
];
Step: Creates a standardized empty loadout array with the stripped uniform.
Logic: All slots are empty or null except the uniform.
3. Utility Item Restoration:

Sqf

Apply
private _oldSpecialItems = _originalLoadout select 9;
private _newSpecialItems = _newLoadout select 9;

{
    if ((_oldSpecialItems select _x) in unlockedItems) then {
        _newSpecialItems set [_x, (_oldSpecialItems select _x)];
    };
} forEach [0,1,2,3,4];
Step: Compares special items (index 9 of the loadout) against the global unlockedItems array.
Logic: If an item (Map, GPS, Compass, Watch, Radio) is in the unlocked list, it is preserved in the new loadout.
Global Variable: Depends on unlockedItems.
4. Radio Compatibility:

Sqf

Apply
if (A3A_hasTFAR || {A3A_hasACRE || {A3A_hasTFARBeta}}) then {
    _newSpecialItems set [2, _oldSpecialItems select 2];
};
Step: Checks for radio mod presence.
Logic: If TFAR, ACRE, or TFAR Beta is active, it forces the preservation of the radio item (index 2), regardless of the unlockedItems check. This is a compatibility override.
5. Return Value:

Sqf

Apply
_newLoadout;
Step: Returns the constructed array.
Where it leads:

Functions this calls:
None (pure array manipulation).
Functions depending on this:
A3A_fnc_reDress: Likely used when respawning or reviving to reset loadouts to basics.
A3A_fnc_addFIAveh: Might be used to strip gear before assigning unit to vehicle.
A3A_fnc_garrisonUpdate: Could be used to standardize garrison unit gear.
Larger System Context: Inventory management utility. Used to enforce loadout restrictions, such as when assigning units to vehicles (where heavy gear is unnecessary) or for standardizing rebel gear.
Global Variables: Reads unlockedItems, A3A_hasTFAR, A3A_hasACRE, A3A_hasTFARBeta.
Synchronization/Network: None. Local array processing.
Function Name: fn_teleportVehicleToBase.sqf
What it does: Teleports a vehicle to a safe position near HQ. It performs collision checks, disables damage during transport, updates velocity and vector, and re-enables damage after a delay.

How it does that: Calculates a safe position, disables physics, moves the object, and re-enables physics.

1. Validation & Size Calculation:

Sqf

Apply
params ["_vehicle"];
if (isNil "_vehicle" or isNull _vehicle) exitWith {};
private _boundingSphereDiameter = ((boundingBox _vehicle) select 2) + 1;
Step: Checks if the vehicle exists. Calculates the size of the vehicle.
Logic: boundingBox returns [[minX, minY, minZ], [maxX, maxY, maxZ]]. Index 2 is the Z-difference (height). The function uses the vehicle's height to ensure the found position is clear.
2. Safe Position Search:

Sqf

Apply
private _newPosition = for "_i" from 1 to 20 do {
 private _possiblePosition = [(getMarkerPos respawnTeamPlayer), 20, 60, _boundingSphereDiameter, 0, 0.3] call BIS_fnc_findSafePos;
 private _checkedPosition = if (count _possiblePosition > 0) then { _possiblePosition findEmptyPosition [0,0, typeOf _vehicle]; } else {[]};
 if (count _checkedPosition > 0) exitWith {_checkedPosition};
};
Step: Loops up to 20 times to find a valid position.
Logic:
Uses BIS_fnc_findSafePos to find a spot within 20-60 meters of HQ (respawnTeamPlayer), requiring flat ground (gradient 0.3).
Validates the spot with findEmptyPosition to ensure no objects are blocking.
Exits the loop immediately on success.
3. Failure Handling:

Sqf

Apply
if (count _newPosition == 0) exitWith {
    Info("Couldn't find a safe position to teleport vehicle to base.");
    false;
};
Step: If the loop finishes without success, logs an error and returns false.
4. Teleport Execution (Physics Suspension):

Sqf

Apply
_vehicle setVelocity [0, 0, 0];
_vehicle engineOn false;
_vehicle allowDamage false;
_vehicle enableSimulation false;

_vehicle setPos _newPosition;
_vehicle setVectorUp (surfaceNormal _newPosition);
Step: Prepares the vehicle for movement.
Logic:
setVelocity [0,0,0]: Stops all movement.
engineOn false: Turns off engine.
allowDamage false: Prevents damage during teleport (e.g., from hitting a tree).
enableSimulation false: Freezes the object in space (prevents physics interference).
setPos: Moves the vehicle to the calculated coordinates.
setVectorUp: Aligns the vehicle with the terrain slope.
5. Post-Teleport Recovery:

Sqf

Apply
[_vehicle] spawn {
    private _vehicle = param [0];
    sleep 1;
    _vehicle allowDamage true;
    _vehicle enableSimulation true;
};
Step: Spawns a separate thread to re-enable physics after a delay.
Logic: Waits 1 second (allowing the position to settle), then restores damage and simulation. This prevents the vehicle from falling through the ground or exploding immediately.
6. Return Value:

Sqf

Apply
true;
Step: Returns success.
Where it leads:

Functions this calls:
BIS_fnc_findSafePos (Built-in): Finds a suitable spot.
findEmptyPosition (Built-in): Checks for obstacles.
spawn (Built-in): Asynchronous recovery.
setPos, setVectorUp, setVelocity (Built-in): Teleport logic.
Functions depending on this:
Garage/Logistics System: Likely called when a player wants to move a vehicle from the map back to HQ.
Larger System Context: Vehicle logistics and management. It provides a "recall" feature for vehicles.
Global Variables: Reads respawnTeamPlayer (HQ marker).
Synchronization/Network: setPos is global. The vehicle will teleport for all players. The recovery (damage/simulation) is local to where the script runs (usually the player who requested it).
Function Name: fn_timingCA.sqf
What it does: This function is marked as obsolete. It was intended to add a random amount of time to the "Attack Counter," but currently, it modifies enemy resources (defence and attack) based on the input time. It's a legacy function that still triggers side effects.

How it does that: It calculates a resource modifier and calls the enemy resources function.

1. Parameter Validation:

Sqf

Apply
params ["_timeToAdd", "_side"];
Step: Accepts the amount of time and the target side.
Logic: No explicit validation; relies on calling function to provide valid inputs.
2. Resource Calculation & Application:

Sqf

Apply
//if (_timeToAdd < 0) exitWith {};
[-_timeToAdd/10, _side, "defence"] call A3A_fnc_addEnemyResources;
[-_timeToAdd/10, _side, "attack"] call A3A_fnc_addEnemyResources;
Step: Calculates a value derived from the input time.
Logic:
It divides the time by 10 and inverts the sign (negative time reduces resources?).
It calls A3A_fnc_addEnemyResources twice: once for "defence" and once for "attack".
Note: The comment suggests this is a fudge effect. It likely impacts how quickly the AI can launch attacks or build defenses.
Where it leads:

Functions this calls:
A3A_fnc_addEnemyResources (Custom): Modifies side-specific resource pools.
Functions depending on this:
Mission reward scripts (as noted in the comments).
Any logic that previously used this for timing but now uses it for resource management.
Larger System Context: Economy and AI pacing system. It allows other mission systems to influence the AI's capabilities indirectly.
Global Variables: Modifies global resource variables for the specified side (via addEnemyResources).
Synchronization/Network: Calls a function likely running on the server, which may broadcast changes or update server-side variables.
Function Name: fn_unlockStatic.sqf
What it does: Unlocks a static weapon for AI garrison use and updates the global list of statics. It allows AI to man the weapon.

How it does that: Modifies variables on the object and updates a global array.

1. Input & Variable Update:

Sqf

Apply
params ["_target"];
_target setVariable ["lockedForAI", nil, true];
Step: Takes the static weapon object.
Logic: Removes the lockedForAI variable from the object. The true parameter makes this a public variable, syncing it across the network so all clients know the weapon is unlocked.
2. Static List Management:

Sqf

Apply
if (A3U_enableVehiclesForAI) then { staticsToFlip = staticsToFlip - [_target] } else { staticsToFlip pushBackUnique _target };
publicVariable "staticsToFlip";
Step: Updates the global array staticsToFlip.
Logic:
A3U_enableVehiclesForAI is a setting. If true, it removes the static from the list (meant for vehicles).
If false (default), it adds the static to the list (pushBackUnique prevents duplicates).
publicVariable syncs the array to all clients.
Technical Detail: staticsToFlip is likely used by a script that periodically checks this list and flips the direction of static weapons for AI optimization.
3. Remote Execution:

Sqf

Apply
[_target] remoteExec ["A3A_fnc_updateRebelStatics", 2];
Step: Sends a command to the server (machine ID 2) to update the rebel statics logic.
Logic: This tells the server to re-evaluate garrison assignments for this specific static.
Where it leads:

Functions this calls:
remoteExec (Built-in): Network call.
A3A_fnc_updateRebelStatics (Custom): Updates garrison logic.
Functions depending on this:
A3A_fnc_addActionUnlockStatic: Adds the action that calls this function.
Larger System Context: Garrison and AI management. It bridges the gap between player action (unlocking a weapon) and AI behavior (using that weapon).
Global Variables: Modifies staticsToFlip and the lockedForAI variable on the object.
Synchronization/Network: Uses setVariable with true and publicVariable to ensure the unlock status is global.
Function Name: fn_unlockVehicle.sqf
What it does: Toggles the locked/unlocked state of a vehicle for the current player. It verifies ownership and vehicle validity, then updates the A3A_locked variable.

How it does that: Checks cursor object validity, ownership, and toggles a boolean variable.

1. Object Validation:

Sqf

Apply
private _veh = cursorObject;
if (isNull _veh) exitWith { ... };
if (!alive _veh) exitWith { ... };
if (_veh isKindOf "Man") exitWith { ... };
if (not(_veh isKindOf "AllVehicles")) exitWith { ... };
Step: Checks the object under the cursor.
Logic: Validates that the object exists, is alive, is a vehicle (not a person), and is actually a vehicle type. Shows denial hints on failure.
2. Ownership Verification:

Sqf

Apply
_ownerX = _veh getVariable "ownerX";
if (isNil "_ownerX") exitWith { ... };
if (_ownerX != getPlayerUID player) exitWith { ... };
Step: Retrieves the ownerX variable from the vehicle.
Logic: Checks if the vehicle is owned and if the current player's UID matches the owner.
Security: Uses getPlayerUID for persistent identification.
3. State Toggling:

Sqf

Apply
if (isNil { _veh getVariable "A3A_locked"} ) then {
    _veh setVariable ["A3A_locked",true,true];
    [ ... "Lock Success" ... ];
} else {
    _veh setVariable ["A3A_locked",nil,true];
    [ ... "Unlock Success" ... ];
};
Step: Checks the current state of A3A_locked.
Logic:
If the variable is nil (unlocked), sets it to true (locked).
If the variable exists (locked), sets it to nil (unlocked).
setVariable uses true to sync the state globally.
Shows appropriate hints.
4. Feedback:

Sqf

Apply
playSound "A3AP_UiSuccess";
Step: Plays a success sound.
Where it leads:

Functions this calls:
cursorObject (Built-in): Get target.
getPlayerUID (Built-in): Identify player.
setVariable (Built-in): Update state.
playSound (Built-in): Audio feedback.
Functions depending on this:
A3A_fnc_addActionUnlockVehicle: Adds the action that calls this.
Larger System Context: Vehicle ownership management. It allows players to secure their vehicles from theft or accidental use by other players/AI.
Global Variables: Modifies A3A_locked on the vehicle object (global).
Synchronization/Network: The setVariable call is global, ensuring the lock state is visible to all players.
Function Name: fn_updateRebelStatics.sqf
What it does: Manages garrison static weapons. It finds empty static weapons in a marker area, identifies available rebel riflemen, and assigns them to the static weapons as gunners/commanders/turrets.

How it does that: Performs spatial queries, filtering, and unit assignment in a multi-step process.

1. Target Identification:

Sqf

Apply
params ["_target"];
if !(_target isEqualType "") then {
    // ... find nearest rebel marker logic ...
};
if (_marker isEqualTo "") exitWith {};
Step: Accepts a position or marker name.
Logic: If not a marker string, it scans markersX to find the nearest rebel-controlled marker containing the target position. If no marker is found, it exits.
2. Static Weapon Discovery:

Sqf

Apply
private _statics = staticsToSave inAreaArray _marker;
_statics = _statics select {!(_x isKindOf "Air")};
private _freeStatics = _statics select {
    isNil { _x getVariable "lockedForAI" }
    and isNull (gunner _x)
};
Step: Scans the marker area for saved statics, filters out aircraft (bunkers), then filters for weapons that are not AI-locked and have no gunner.
Logic: Determines which weapons need crew.
3. Crew Discovery:

Sqf

Apply
private _possibleCrew = allUnits inAreaArray _marker;
_possibleCrew = _possibleCrew select {
    _x getVariable ["markerX", ""] isEqualTo _marker
    and _x getVariable ["UnitType", ""] isEqualTo FactionGet(reb,"unitRifle")
    and isNull objectParent _x
    and [_x] call A3A_fnc_canFight
};
Step: Finds all units in the marker.
Logic: Filters for rebel riflemen (not passengers, specific unit type), currently unmounted, and capable of fighting.
4. Group Management:

Sqf

Apply
private _staticGroup = grpNull;
// ... check existing group logic ...
if (isNull _staticGroup) then { _staticGroup = createGroup [teamPlayer, true] };
Step: Checks if a local static garrison group already exists for this marker.
Logic: If found, uses it; otherwise, creates a new local group.
5. Assignment Loop:

Sqf

Apply
{
    private _veh = _x;
    // ... position logic (Gunner, Commander, Turret) ...
    // ... assignment loop ...
    {
        private _unit = _possibleCrew deleteAt 0;
        // ... assignAsGunner / moveInGunner / assignAsTurret ...
    } forEach _positions;

    // ... joinSilent / setGroupOwner ...
} forEach _freeStatics;
Step: Iterates through free statics.
Logic:
Identifies empty positions (Gunner, Commander, specific Turrets).
Populates them with units from the _possibleCrew list.
Joins units to the _staticGroup and sets group ownership to the server (2) for persistence.
Includes a sanity check (spawn) to re-assign units if they fail to move in immediately.
6. Post-Assignment Config:

Sqf

Apply
_veh setVehicleRadar ([0, 1] select (getNumber(configOf _veh >> "radarType") in [2, 4]));
_staticGroup setBehaviour "AWARE";
_staticGroup setCombatMode "WHITE";
Step: Configures the group and vehicle.
Logic: Enables radar if the vehicle supports it. Sets AI behavior to hold position and fire freely.
Where it leads:

Functions this calls:
inAreaArray (Built-in): Spatial query.
createGroup (Built-in): Group creation.
assignAsGunner/moveInGunner (Built-in): Unit assignment.
setGroupOwner (Built-in): Network ownership.
A3A_fnc_canFight (Custom): Status check.
FactionGet (Custom): Config lookup.
Functions depending on this:
A3A_fnc_unlockStatic: Calls this remotely after unlocking.
A3A_fnc_garrisonUpdate: Likely triggers this to populate statics after a garrison change.
Larger System Context: Garrison system. It automates the manning of static defenses, a core part of base defense.
Global Variables: Modifies _possibleCrew array (deletes used units).
Synchronization/Network: Creates local groups (true parameter). Sets group owner to server (2) for persistence. Uses remoteExec if called externally.
Function Name: fn_vehicleBoxRestore.sqf
What it does: Restores rebel units and vehicles near HQ. It heals units, restores stamina, clears "reported" status, and refuels/rearms/repairs vehicles if HQ has the corresponding garage sources.

How it does that: Queries objects near HQ and applies effects based on conditions.

1. Usage Cooldown:

Sqf

Apply
if ((serverTime - (boxX getVariable ["lastUsed", -30])) < 30) exitWith { ... };
boxX setVariable ["lastUsed", serverTime, true];
Step: Checks the lastUsed variable on boxX (the HQ vehicle box).
Logic: Prevents spam by enforcing a 30-second cooldown. Updates the timestamp globally.
2. Unit Restoration:

Sqf

Apply
private _posHQ = getMarkerPos respawnTeamPlayer;
private _rebelPlayers = allUnits select {side _x in [teamPlayer, civilian] && {_x distance _posHQ < 50}};

{
    // ... ACE Fatigue/Healing logic ...
    // ... Vanilla Fatigue logic ...
    _x setDamage 0;
    _x setVariable ["incapacitated",false,true];
    _x setVariable ["compromised", 0, true];
    // ... etc ...
} forEach _rebelPlayers;
Step: Finds units within 50m of HQ.
Logic:
Resets stamina (ACE or Vanilla).
Full heals (ACE or Vanilla).
Resets damage, incapacitation, and compromise variables.
Resets undercover flags.
3. Vehicle Restoration:

Sqf

Apply
private _hqVehicles = (vehicles inAreaArray [_posHQ, 150, 150]) select { ... };

{
    if (isNil {_x getVariable "A3A_reported"}) then { continue };
    _x setVariable ["A3A_reported", nil, true];
} forEach _hqVehicles;

if (HR_GRG_hasAmmoSource) then { ... [_x,1] remoteExec ["setVehicleAmmo",_x]; ... };
if (HR_GRG_hasRepairSource) then { ... _x setDamage 0; ... };
if (HR_GRG_hasFuelSource) then { ... remoteExecCall ["HR_GRG_fnc_refuelVehicleFromSources", 2]; ... };
Step: Finds vehicles near HQ. Checks for garage sources (HR_GRG_has...).
Logic:
Clears the "Reported" flag (police/GPS tracking).
If Ammo Source exists, remotes a rearm command to the vehicle.
If Repair Source exists, sets damage to 0.
If Fuel Source exists, calls a specific refuel function on server (machine 2).
4. UI Feedback:

Sqf

Apply
private _additiveTexts = [localize "STR_A3A_base_vehicleBoxRestore_noreported"];
// ... pushBack based on sources ...
private _finalString = format [_finalStringVariant, _finalAdditiveString];
[localize "STR_A3A_base_vehicleBoxRestore_restoration_title", _finalString] call A3A_fnc_customHint;
Step: Builds a dynamic hint string describing what was restored.
Logic: Collects localized strings for "No Report", "Repaired", "Rearmed", "Refueled" and joins them.
Where it leads:

Functions this calls:
A3A_fnc_customHint (Custom): UI notification.
HR_GRG_fnc_refuelVehicleFromSources (Custom): Specific refuel logic.
remoteExec/remoteExecCall (Built-in): Network effects.
setDamage (Built-in): Vehicle repair.
Functions depending on this:
A3A_fnc_addActionVehicleBoxRestore: Adds the action that calls this.
Larger System Context: HQ Logistics. It acts as a supply depot, rewarding players for returning to base and encouraging them to keep their equipment in good condition.
Global Variables: Reads boxX, respawnTeamPlayer, HR_GRG_hasAmmoSource, etc.
Synchronization/Network: Uses remoteExec to apply ammo/refuel effects to vehicles (which may be local to different players). Updates global variables on objects (A3A_reported).
Function Name: fn_zoneCheck.sqf
What it does: Checks if a marker's ownership should change based on the ratio of friendly to enemy units present. It calculates weighted unit counts based on distance to the marker center and flips the side if enemies heavily outnumber defenders.

How it does that: Performs a spatial unit count, calculates a "weight" for each unit, and compares totals.

1. Concurrency Control:

Sqf

Apply
waitUntil {!zoneCheckInProgress};
zoneCheckInProgress = true;
Step: Uses a global flag zoneCheckInProgress to prevent overlapping executions.
Logic: This is a critical section lock.
2. Side Validation:

Sqf

Apply
if(_side != sidesX getVariable [_marker, sideUnknown]) exitWith { zoneCheckInProgress = false };
Step: Checks if the unit that died (_side) matches the current owner of the marker.
Logic: Only proceeds if the death happened in a zone owned by the unit's side. If an enemy died, we don't care (for this specific check).
3. Enemy Identification:

Sqf

Apply
switch (_side) do {
    case (teamPlayer): { _enemy1 = Invaders; _enemy2 = Occupants; };
    // ... other cases ...
};
Step: Determines who the enemies are based on the defender's side.
4. Weighted Unit Counting:

Sqf

Apply
private _capRadius = ((markerSize _marker select 0) + (markerSize _marker select 1)) / 2;
_capRadius = _capRadius max 50;

private _units = allUnits inAreaArray [_markerPos, _capRadius, _capRadius];
{
    if !(_x call A3A_fnc_canFight) then { continue };
    if (vehicle _x isKindOf "Air") then { continue };
    private _value = linearConversion [_capRadius/2, _capRadius, _markerPos distance2d _x, 1, 0, true];
    switch (side _x) do {
        case (_side): {_defenderUnitCount = _defenderUnitCount + _value};
        case (_enemy1): {_enemy1UnitCount = _enemy1UnitCount + _value};
        case (_enemy2): {_enemy2UnitCount = _enemy2UnitCount + _value};
    };
} forEach _units;
Step: Defines a capture radius. Iterates through units in that radius.
Logic:
Filtering: Skips dead/incapacitated units (canFight) and air units.
Weighting: Uses linearConversion to assign a value between 1 and 0 based on distance. Units at the center (0m) get 1.0, units at the edge (_capRadius) get 0.0. This makes control more sensitive to units near the center.
Counting: Adds the weighted value to the respective side's total.
5. Decision Logic:

Sqf

Apply
if (_enemy1UnitCount > 3 * _defenderUnitCount || {_enemy2UnitCount > 3 * _defenderUnitCount}) then {
    private _winner = if (_enemy1UnitCount > _enemy2UnitCount) then {_enemy1} else {_enemy2};
    if (_winner isEqualTo teamPlayer) exitWith { ... };
    [_winner,_marker] remoteExec ["A3A_fnc_markerChange",2];
};
zoneCheckInProgress = false;
Step: Compares enemy weight to defender weight (3:1 ratio required).
Logic:
If the ratio is met, determine the dominant enemy side.
Exception: Prevents auto-capture by rebels (requires manual action).
Action: Calls A3A_fnc_markerChange on the server to flip the marker.
Cleanup: Releases the lock (zoneCheckInProgress = false).
Where it leads:

Functions this calls:
A3A_fnc_canFight (Custom): Check unit status.
linearConversion (Built-in): Weight calculation.
inAreaArray (Built-in): Spatial query.
remoteExec (Built-in): Network call to flip marker.
A3A_fnc_markerChange (Custom): Applies the ownership change.
Functions depending on this:
Unit Kill Event Handlers: Triggered when a unit dies to check if the death impacts zone control.
Larger System Context: Dynamic Frontline & Territory System. It automates the shifting of control lines based on combat presence, creating a fluid battlefield.
Global Variables: Modifies zoneCheckInProgress.
Synchronization/Network: remoteExec to machine 2 (server) ensures the marker change is authoritative and synced.
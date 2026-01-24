Function Name: fn_cleanConvoyMarker.sqf
What it does: This function cleans up global server variables that store convoy marker names by filtering out markers that no longer exist. It is intended to be run periodically (e.g., via a scheduled loop) to prevent the arrays from growing indefinitely with invalid references.

Context: Called to maintain the integrity of the convoyMarker_Occupants and convoyMarker_Invaders server variables. It ensures that convoy tracking systems only retain references to currently active markers.
How it does that:

Initialization (Occupants): The function starts by retrieving the array of occupant convoy markers from the server namespace. If the variable doesn't exist, it defaults to [""] (an array containing an empty string).

Sqf

Apply
private _convoysOccupants = server getVariable ["convoyMarker_Occupants", [""]];
Filtering (Occupants): It filters the _convoysOccupants array. The filter checks if the marker color is not an empty string. In Arma 3, a non-existent or deleted marker returns an empty string for getMarkerColor. This removes orphaned markers.

Sqf

Apply
_convoysOccupants = _convoysOccupants select {(getMarkerColor _x) != ""};
Saving (Occupants): The cleaned array is written back to the server variable. The true flag ensures this variable change is synchronized across the network to all clients (publicVariable).

Sqf

Apply
server setVariable ["convoyMarker_Occupants", _convoysOccupants, true];
Initialization (Invaders): The same process is repeated for the Invader side.

Sqf

Apply
private _convoysInvaders = server getVariable ["convoyMarker_Invaders", [""]];
Filtering (Invaders): The filtering logic is identical to the Occupant step.

Sqf

Apply
_convoysInvaders = _convoysInvaders select {(getMarkerColor _x) != ""};
Saving (Invaders): The cleaned array is saved back to the server namespace and synced.

Sqf

Apply
server setVariable ["convoyMarker_Invaders", _convoysInvaders, true];
Where it leads:

Called Functions: None directly within this snippet.
Dependent Functions:
fn_convoyDebug.sqf
: Relies on these variables to show/hide markers.
fn_convoyMovement.sqf
: Relies on these variables to track active convoys.
fn_createConvoy.sqf
: Adds markers to these variables.
Global Variables: Modifies server namespace variables convoyMarker_Occupants and convoyMarker_Invaders.
Synchronization: The true flag in setVariable triggers a public broadcast, updating all clients with the cleaned list.
Function Name: fn_convoyDebug.sqf
What it does: This function provides a debug visualization for convoy routes. It forces convoy markers to become visible (alpha 1) on the map for the local player, allowing admins to track convoy positions in real-time. It includes an action to deactivate the debug mode.

Context: Used for debugging convoy AI pathing or identifying issues with convoy spawning/despawning. It is strictly restricted to server admins or single-player environments.
How it does that:

Execution Context Check: It first checks if the code is running in a suspended environment (like a scheduled script). If not (e.g., called via a button press), it restarts itself in a spawn thread to allow the sleep commands to function.

Sqf

Apply
if(!canSuspend) exitWith { [] spawn A3A_fnc_convoyDebug; };
Environment Check: Exits immediately if running on a dedicated server (dedicated servers have no player object to attach actions to).

Sqf

Apply
if(isDedicated) exitWith {};
Permission Check: Ensures the caller is either the server or an admin (checked via BIS_fnc_admin).

Sqf

Apply
if(!isServer && {!(call BIS_fnc_admin > 0)}) exitWith {["Convoy Debug", "Only server admins can execute the convoy debug!"] call A3A_fnc_customHint; };
State Activation & Action Creation: Sets a variable on the player object to true and creates an "Deactivate convoy debug" action. This action sets the variable to false and removes the action itself.

Sqf

Apply
player setVariable ["convoyDebug", true];
_stop = player addAction ["Deactivate convoy debug", {(_this select 0) setVariable ["convoyDebug", false]; (_this select 0) removeAction (_this select 2);}, nil, 0, false, false, "", "_originalTarget == _this"];
Visualization Loop: A while loop runs as long as player getVariable ["convoyDebug", false] is true.

It retrieves all active convoy markers from the server variables (Occupants and Invaders).
It iterates through the _allConvoyMarker array.
It forces the local alpha to 1 (setMarkerAlphaLocal), making them visible even if they are meant to be hidden (alpha 0).
Sqf

Apply
while {player getVariable ["convoyDebug", false]} do
{
    _allConvoyMarker = server getVariable ["convoyMarker_Occupants", []];
    _allConvoyMarker = _allConvoyMarker + (server getVariable ["convoyMarker_Invaders", []]);
    if(count _allConvoyMarker != 0) then
    {
        { _x setMarkerAlphaLocal 1; } forEach _allConvoyMarker;
    };
    sleep 10;
};
Cleanup: Once the loop ends (user deactivated debug), the action is removed, and all previously collected markers have their alpha reset to 0 to hide them again.

Sqf

Apply
player removeAction _stop;
{ _x setMarkerAlphaLocal 0; } forEach _allConvoyMarker;
Where it leads:

Called Functions:
A3A_fnc_customHint: Displays error messages if permissions fail.
Dependent Functions:
fn_createConvoy.sqf
: Creates the markers that this function visualizes.
fn_cleanConvoyMarker.sqf
: Cleans up the variables this function reads.
Global Variables: Reads server variables convoyMarker_Occupants and convoyMarker_Invaders. Modifies player variable convoyDebug.
Synchronization: Uses setMarkerAlphaLocal (local effect only) so only the admin sees the debug markers.
Function Name: fn_convoyMovement.sqf
What it does: Simulates the movement of a convoy along a defined route without actually spawning physical units, until a trigger condition is met (player proximity or roadblock encounter), at which point it spawns the physical convoy.

Context: This is the "stealth" phase of a convoy. It saves server performance by only simulating position updates in code until combat is imminent.
How it does that:

Parameter Validation: Accepts parameters for ID, route, speed, units, side, type, and debug object. It verifies that the max speed is greater than 0.

Sqf

Apply
if(!(_maxSpeed > 0)) exitWith { deleteMarker _convoyMarker; };
Route Validation: Checks if the route contains at least one valid coordinate point.

Sqf

Apply
if(count _route == 0 || {count (_route select 0) != 2}) exitWith { Debug("Path is broken"); };
Setup: Calculates the movement vector and initializes state variables (_isSimulated, _isDestroyed, _roadBlockCountdown).

Sqf

Apply
private _movementVector = (_lastPoint vectorFromTo _nextPoint) vectorMultiply _maxSpeed;
private _movementLength = _lastPoint vectorDistance _nextPoint;
Simulation Loop: Loops through the route points.

Movement: Every second (sleep 1), it updates _currentPos by adding _movementVector.
Roadblock Check: Checks roadblocksFIA array for nearby roadblocks (within 250m). If a roadblock is found and is active (spawner variable == 2), it calculates a fight outcome.
Sqf

Apply
_isSimulated = [_units, _currentRoadBlock] call A3A_fnc_roadblockFight;
Player Proximity: Checks if player units are within distanceSPWN * 0.9. If true, simulation stops and physical spawning begins.
Sqf

Apply
_isSimulated = false;
[_convoyID, ...] call A3A_fnc_spawnConvoy;
Termination/Arrival:

If _isDestroyed (from roadblock fight), it deletes the marker.
If simulation finishes without interruption, it calls onConvoyArrival (triggering mission success or reinforcements) and deletes the marker after a delay.
Where it leads:

Called Functions:
A3A_fnc_roadblockFight: Handles combat logic against roadblocks.
A3A_fnc_spawnConvoy: Spawns physical units when simulation ends.
A3A_fnc_trimPath: Cleans up remaining route data.
A3A_fnc_onConvoyArrival: Handles mission completion logic.
Dependent Functions:
fn_createConvoy.sqf
: Starts this simulation.
Global Variables: Reads/Writes roadblocksFIA, spawner (via getVariable), modifies the convoy%1 marker position.
Function Name: fn_createConvoy.sqf
What it does: Creates a convoy marker and generates a path for the convoy. It determines the type of convoy (Air, Land, Mixed) and sets up the simulation by calling fn_convoyMovement.

Context: Called when the mission system decides to launch a convoy (e.g., reinforcements, supply drop, attack).
How it does that:

Input Validation: Checks that all required parameters (ID, units, origin, destination) are present.

Sqf

Apply
if (isNil "_convoyID") exitWith {Error("CreateConvoy: No convoy ID given")};
Vehicle Analysis: Iterates through the _units array to determine if the convoy contains Air or Land vehicles and calculates the slowest vehicle's max speed (the convoy's speed limit).

Sqf

Apply
{
    _vehicle = _x select 0;
    if (!_hasLand && {_vehicle isKindOf "Land"}) then {_hasLand = true;};
} forEach _units;
Pathfinding:

Air Only: Generates a direct vector path, including altitude changes (origin + 200m, dest + 200m).
Mixed/Land: Calls A3A_fnc_findPath to calculate a road-based route.
Sqf

Apply
if(_hasAir && {!_hasLand}) then { _route = [[_origin, true], ...]; }
else { _route = [_origin, _destination] call A3A_fnc_findPath; };
Marker Creation: Creates a marker at the origin. The marker icon depends on the convoy type (Air, Mixed, Land) and the side (Occupants, Invaders).

Sqf

Apply
_convoyMarker = createMarker [format ["convoy%1", _convoyID], _origin];
_convoyMarker setMarkerType format ["%1%2", _markerPrefix, _markerType];
State Management: Adds the new marker to the relevant server variable (convoyMarker_Occupants or convoyMarker_Invaders) so it can be tracked by fn_cleanConvoyMarker and fn_convoyDebug.

Execution: Spawns fn_convoyMovement to begin the simulation.

Where it leads:

Called Functions:
A3A_fnc_findPath: Calculates road routes.
A3A_fnc_convoyMovement: Starts the simulation.
Dependent Functions:
fn_despawnConvoy.sqf
: Calls this to respawn a convoy.
Mission scripts (e.g., convoy mission in Missions folder).
Global Variables: Writes to server variables convoyMarker_Occupants or convoyMarker_Invaders.
Function Name: fn_despawnConvoy.sqf
What it does: Safely removes a physical convoy from the world (deleting vehicles and crew) and immediately restarts it as a simulated convoy (via fn_createConvoy) to allow it to move off-map or to the next objective without consuming server resources.

Context: Called when a convoy moves out of player spawn distance during the fn_spawnConvoy monitoring loop.
How it does that:

FSM Abort: Iterates through all convoy vehicles and sets their FSM variable _abort to true, stopping their AI movement immediately.

Sqf

Apply
private _fsm = (_x select 0) getVariable "fsm";
if !(isNil "_fsm" || {completedFSM _fsm}) then { _fsm setFSMVariable["_abort", true] };
Data Preservation: Loops through the _unitObjects array (which contains [vehicle, crew, cargo]). It extracts the vehicle type, crew types, and cargo types into a new _convoyData array. It deletes the physical units (groups) and vehicles.

Sqf

Apply
private _cargoData = [];
{
    if(alive _x) then {
        _cargoData pushBack (_x getVariable "unitType");
        deleteVehicle _x;
    };
} forEach (_data select 2);
Respawn: Spawns fn_createConvoy using the extracted _convoyData. This recreates the convoy definition at the current position _convoyPos and restarts the simulation (convoyMovement).

Where it leads:

Called Functions:
A3A_fnc_createConvoy: Restarts the simulation.
Dependent Functions:
fn_spawnConvoy.sqf
: Calls this when convoy goes out of range.
Global Variables: Modifies FSM variables on vehicle objects.
Function Name: fn_findAirportForAirstrike.sqf
What it does: Finds the most suitable airport (or carrier) belonging to a specific side to launch an airstrike against a destination.

Context: Used by support or mission scripts to spawn aircraft.
How it does that:

Input Resolution: Determines the destination position and side. If the destination is a marker, it looks up the side controlling that marker.

Sqf

Apply
if(_destination isEqualType "") then { _side = sidesX getVariable [_destination, sideUnknown]; };
Filtering by State: Filters the airportsX global array for airports that:

Belong to the specified side.
Are active in the spawner (spawner var == 2).
Are not on cooldown (dateToNumber date > server getVariable _x).
Are not force-spawned.
Sqf

Apply
_possibleAirports = _possibleAirports select { (spawner getVariable _x == 2) && ... };
Distance Filtering: Calculates distance to destination. Only keeps airports within distanceForAirAttack.

Sqf

Apply
if ((_destinationPos distance2D _posbase < distanceForAirAttack)) then { ... };
Selection: If suitable airports exist, uses BIS_fnc_nearestPosition to select the closest one.

Where it leads:

Called Functions:
BIS_fnc_nearestPosition: Utility to find closest position.
Dependent Functions:
Support system functions (e.g., SUP_airstrikeRoutine).
Global Variables: Reads airportsX, sidesX, spawner, server.
Function Name: fn_followVehicle.sqf
What it does: Directs a helicopter to follow a lead vehicle, adjusting altitude, and lands it once the target is reached.

Context: Used for logistics or insertion missions involving helicopters.
How it does that:

Speed & Initial Move: Sets speed limit and issues the first move command to a position 30m above the lead vehicle.

Sqf

Apply
_helicopter limitSpeed _speed;
_helicopter move ((getPos _leadVehicle) vectorAdd [0,0,30]);
Tracking Loop: While the helicopter is alive and the target is more than 20m away (2D distance), it updates the move command every 0.5 seconds to the current position of the lead vehicle (using getPosWorld for accuracy).

Sqf

Apply
while {alive _helicopter && {_leadVehicle distance2D _target > 20}} do { ... };
Landing Sequence: Once the target is reached, it waits for the helicopter to become "ready" (unitReady) and then issues the land command with the "LAND" mode (full touchdown).

Sqf

Apply
if(alive _helicopter) then { _helicopter land "LAND"; };
Where it leads:

Called Functions: None directly.
Dependent Functions: Likely called from mission scripts like LOG_Airdrop or SUP_QRFVehAirdrop.
Global Variables: None modified.
Function Name: fn_onConvoyArrival.sqf
What it does: Handles the logic when a simulated convoy reaches its destination. It clears the convoy ID from the server and executes side-specific logic based on the convoy type (Reinforce, Patrol, Convoy, etc.).

Context: Called at the end of fn_convoyMovement.
How it does that:

Cleanup: Removes the convoy ID from the server namespace.

Sqf

Apply
server setVariable [format ["Con%1", _convoyID], nil, true];
Type Switch: Uses a switch statement on _convoyType:

Patrol: Reschedules a return trip (calls createConvoy with "return" type).
Convoy: Updates mission states (BIS tasks).
Reinforce: Looks for the nearest marker in markersX at the destination and calls addGarrison to add the units to the garrison.
Sqf

Apply
case ("reinforce"): {
    _index = markersX findIf {(getMarkerPos _x) distanceSqr _endPos < 100};
    if(_index != -1) then {
        _marker = markersX select _index;
        [_marker, _units] call A3A_fnc_addGarrison;
    };
};
Where it leads:

Called Functions:
A3A_fnc_createConvoy (for Patrol return).
A3A_fnc_addGarrison (for Reinforce).
BIS_fnc_taskSetState (for Convoy).
Dependent Functions:
fn_convoyMovement.sqf
: Calls this upon arrival.
Global Variables: Modifies server variable, markersX, and garrison variables.
Function Name: fn_roadblockFight.sqf
What it does: Simulates a fight between a convoy and a roadblock. It calculates a win/loss probability based on unit counts and types (e.g., Tanks have higher weight).

Context: Called during fn_convoyMovement when a convoy enters a roadblock trigger zone.
How it does that:

Defender Calculation: Retrieves the garrison of the roadblock marker. Counts units, giving a +3 bonus for crew units (heavily armed).

Sqf

Apply
private _garrison = garrison getVariable [_roadblockMarker, []];
_roadblockCount = 0;
{
    if(_x == FactionGet(reb,"unitCrew")) then { _roadblockCount = _roadblockCount + 3; };
    _roadblockCount = _roadblockCount + 1;
} forEach _garrison;
Attacker Calculation: Iterates through the convoy _units. Adds base count (+1) and bonuses based on vehicle class (APC +5, Tank +10, Helicopter +7, Plane +10).

Sqf

Apply
switch (true) do {
    case (_vehicle isKindOf "Tank"): {_attackerCount = _attackerCount + 10};
};
Ratio Logic: Calculates _ratio = _roadblockCount / _attackerCount.

If Ratio < 0.9: Attacker wins.
If Ratio > 1.1: Defender wins.
If 0.9 <= Ratio <= 1.1: 50/50 Random chance.
Outcome: If the attacker wins, it deletes the roadblock from roadblocksFIA, markersX, and sidesX, and notifies players.

Sqf

Apply
if(_result) then {
    roadblocksFIA = roadblocksFIA - [_roadblockMarker]; publicVariable "roadblocksFIA";
    markersX deleteAt (markersX find _roadblockMarker);
};
Where it leads:

Called Functions:
A3A_fnc_citySupportChange: Updates city support (negative impact).
BIS_fnc_showNotification: Alerts players.
Dependent Functions:
fn_convoyMovement.sqf
.
Global Variables: Modifies roadblocksFIA, markersX, sidesX.
Function Name: fn_spawnConvoy.sqf
What it does: Physically spawns the convoy units (vehicles and infantry) into the world and initializes FSMs (Finite State Machines) to control their driving/flying behavior. It monitors them until they despawn or arrive.

Context: Called by fn_convoyMovement when a convoy becomes visible/engaged.
How it does that:

Position Alignment: Ensures ground vehicles are on a road (using nearRoads) to prevent starting in open fields.

Sqf

Apply
private _road = roadAt _pos;
if(isNull _road) then { ... find nearest road ... };
Line Spawning: Loops through the _units array and calls A3A_fnc_spawnConvoyLine for each entry.

Sqf

Apply
private _lineData = [_units select _i, _convoySide, _pos, _dir] call A3A_fnc_spawnConvoyLine;
FSM Initialization: Depending on vehicle type, it executes a specific FSM:

Air: ConvoyTravelAir.fsm (circle logic, altitude).
Land: ConvoyTravel.fsm (driving, path following). The FSM is attached to the vehicle via setVariable ["fsm", _fsm].
Monitoring Loop: Runs a continuous loop:

Checks FSM result variable (fsmresult). If != 0, the vehicle is done (arrived or destroyed). It removes it from the tracking arrays.
Checks distance to teamPlayer. If all vehicles are out of range, it calls fn_despawnConvoy.
Updates the visual marker position based on the lead vehicle.
Sqf

Apply
if ([distanceSPWN*1.2, 1, getPos _veh, teamPlayer] call A3A_fnc_distanceUnits) then { _despawn = false };
Killzone Tracking: If a vehicle fails (FSM result < 0), it adds the target to the killZones variable to prevent repetitive failures.

Sqf

Apply
private _kzlist = killZones getVariable [_markers#0, []];
_kzlist pushBack _markers#1;
killZones setVariable [_markers#0, _kzlist, true];
Where it leads:

Called Functions:
A3A_fnc_spawnConvoyLine: Spawns individual units.
A3A_fnc_despawnConvoy: Reverts to simulation if out of range.
Dependent Functions:
fn_convoyMovement.sqf
.
Global Variables: Reads/Writes killZones.
Function Name: fn_spawnConvoyLine.sqf
What it does: Spawns a single line of a convoy (1 vehicle + crew + cargo) and places units inside.

Context: Called by fn_spawnConvoy to handle individual units.
How it does that:

Vehicle Spawn: Creates the vehicle. If it is Air, it uses "FLY" placement mode (creates at altitude with velocity). If Land, "CAN_COLLIDE".

Sqf

Apply
if(!(_vehicleType isKindOf "Air")) then {
    _vehicleObj = createVehicle [_vehicleType, _pos, [], 0 , "CAN_COLLIDE"];
} else {
    _vehicleObj = createVehicle [_vehicleType, _pos, [], 0 , "FLY"];
};
Crew Spawn: Creates units in the _vehicleGroup. It checks turret paths (allTurrets) to ensure units are assigned correctly to driver, gunner, or specific turrets.

Sqf

Apply
if (isNull driver _vehicleObj) then {
    _unit assignAsDriver _vehicleObj;
} else {
    private _turretData = [_vehicleObj, _turrets select _nextTurretIndex];
    _unit assignAsTurret _turretData;
};
Cargo Spawn: Creates a separate group (_cargoGroup) for cargo units and assigns them to cargo seats.

Return: Returns an array containing [[_vehicleObj, _crewObjs, _cargoObjs], _vehicleGroup, _cargoGroup, _slowConvoy].

Where it leads:

Called Functions:
A3A_fnc_createVehicleCrew (implied via createUnit logic, though manual assignment is used here).
A3A_fnc_AIVEHinit: Initializes vehicle properties.
Dependent Functions:
fn_spawnConvoy.sqf
.
Global Variables: None modified directly.

Function Name: A3A/addons/core/FSMs/ConvoyTravel.fsm
High-level description of the function's purpose: This FSM (Finite State Machine) controls the autonomous movement of a convoy vehicle (ground transport) along a predefined route. It manages waypoint navigation, handles vehicle or driver destruction, detects when the vehicle gets stuck, and executes appropriate cleanup logic upon arrival at the destination or upon failure/abort.

When/Why it's called: It is instantiated by A3A_fnc_vehicleConvoyTravel (found in 
CfgFunctions.hpp
) when a scripted convoy mission is spawned. It runs autonomously on the server or headless client until it reaches a final state.

How it does that:

State: Start
Purpose: Initialization and input validation. Checks for critical errors (missing vehicle, missing route, missing driver) and sets up crew groups.

Step-by-step implementation:

Parameter Extraction:

Extracts input parameters: _vehicle, _route, _markers, _convoyType.
Code: params ["_vehicle", "_route", "_markers", "_convoyType"];
Input Validation:

Checks if the vehicle is null. If true, logs an error and sets _abort = true.
Checks if the route array is empty. If true, logs an error and sets _abort = true.
Checks if the driver is null or dead. If true, logs an error and sets _abort = true.
Code:
Sqf

Apply
if (isNull _vehicle) exitWith { _abort = true; [1, "Null vehicle input", "ConvoyTravel"] call A3A_fnc_log };
if (count _route == 0) exitWith { _abort = true; [1, "No route specified", "ConvoyTravel"] call A3A_fnc_log };
if (isNull driver _vehicle) exitWith { _abort = true; [1, "No driver in vehicle", "ConvoyTravel"] call A3A_fnc_log };
if (!alive driver _vehicle) exitWith { _abort = true; [1, "Dead driver in vehicle", "ConvoyTravel"] call A3A_fnc_log };
Crew Management:

Splits the vehicle crew into their own groups using A3A_fnc_splitVehicleCrewIntoOwnGroups. This ensures that the crew (commander/gunner) can act independently of the driver if necessary.
Sets the crew group behavior to "CARELESS" and combat mode to "BLUE" (non-engaging) to prevent them from stopping to shoot at enemies during travel.
Identifies the cargo group (if any) to manage disembarking later.
Code:
Sqf

Apply
private _splitCrew = [_vehicle] call A3A_fnc_splitVehicleCrewIntoOwnGroups;
(group driver _vehicle) setBehaviour "CARELESS";
(group driver _vehicle) setCombatMode "BLUE";
private _cargoUnits = assignedCargo _vehicle;
private _cargoGroup = if (count _cargoUnits > 0) then {group (_cargoUnits # 0)} else {grpNull};
Variable Initialization:

Sets the destination to the last marker in the _route array.
Sets accuracy (waypoint completion radius) to 50 meters.
Initializes _currentNode index to 0.
Code:
Sqf

Apply
private _destination = _route select (count _route - 1);
private _accuracy = 50;
private _currentNode = 0;
Where it leads:

Triggers Hard_Abort Link: If _abort is true.
Calls: A3A_fnc_log (logging).
Leads to: State End_and_Abort.
Triggers True Link: If validation passes.
Leads to: State Head_to__Next_Po.
State: Head_to__Next_Po (Head to Next Pos)
Purpose: Calculates the next waypoint and orders the vehicle to move there. It also contains a timeout mechanism to detect if the vehicle is stuck.

Step-by-step implementation:

State Update:

Sets internal state variable to "FOLLOW".
Code: _state = "FOLLOW";
Waypoint Calculation:

Retrieves the next position from the _route array using _currentNode.
Code: private _nextPos = _route # _currentNode;
Order Movement:

Iterates through the split crew groups (_splitCrew # 0).
Adds a waypoint at _nextPos (converted from AGL to ASL) and sets it as the current waypoint.
Code:
Sqf

Apply
{
    private _nextWaypoint = _x addWaypoint [AGLToASL _nextPos, -1];
    _x setCurrentWaypoint _nextWaypoint;
} forEach (_splitCrew # 0);
Stuck Timer:

Sets a timeout limit based on the current time plus the distance to the next position. If the vehicle takes longer than this distance (in seconds, roughly) to reach the point, it is considered stuck.
Code: private _timeout = time + (_vehicle distance2d _nextPos);
Where it leads:

Triggers Abort Link: If _abort variable is set to true externally.
Leads to: State End_and_Abort.
Triggers Veh_or_Crew_Dead Link: If !canMove _vehicle or !alive driver _vehicle.
Action: Logs "Vehicle or driver died during travel, abandoning".
Leads to: State End_and_Rejoin.
Triggers HasArrived Link: If _vehicle distance _destination < 100.
Action: Logs "Convoy vehicle arrived at destination".
Leads to: State End_and_Unload.
Triggers At_Next_Pos Link: If _vehicle distance _nextPos < _accuracy (50m).
Action: Increments _currentNode.
Leads to: State Head_to__Next_Po (Loop).
Triggers Veh_stuck Link: If time > _timeout.
Action: Logs "Vehicle stuck during travel, abandoning".
Leads to: State End_and_Rejoin.
State: End_and_Rejoin
Purpose: Failure state. Unifies the split crew groups, unassigns vehicle roles, and despawns the convoy units while sending them back to base.

Step-by-step implementation:

State Update:

Sets internal state variable to "END".
Code: _state = "END";
Result Variable:

Sets the FSM result on the vehicle to -1 (indicates failure/abandonment).
Code: _vehicle setVariable["fsmresult", -1];
Group Unification:

Merges the split crew groups back into one using A3A_fnc_joinMultipleGroups.
Unassigns all crew members from the vehicle.
If there was a cargo group, joins it to the crew group and deletes the old cargo group.
Code:
Sqf

Apply
private _crewGroup = _splitCrew call A3A_fnc_joinMultipleGroups;
{ unassignVehicle _x } forEach (crew _vehicle);
if !(isNull _cargoGroup) then {
    (units _cargoGroup) joinSilent _crewGroup;
    deleteGroup _cargoGroup;
};
Despawning:

Adds a waypoint for the crew to return to the origin marker (_markers # 0).
Spawns A3A_fnc_groupDespawner and A3A_fnc_vehDespawner to handle cleanup.
Code:
Sqf

Apply
private _wp3 = _crewGroup addWaypoint [getMarkerPos (_markers # 0), 100];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointBehaviour "AWARE";
_crewGroup setCurrentWaypoint _wp3;
[_crewGroup] spawn A3A_fnc_groupDespawner;
[_vehicle] spawn A3A_fnc_vehDespawner;
Where it leads:

This is a Final State. The FSM terminates here.
State: End_and_Unload
Purpose: Success state. Orders the vehicle to the destination marker and unloads cargo. Handles specific logic for "reinforce" convoy types (adding units to garrison immediately).

Step-by-step implementation:

State & Result:

Sets _state to "END" and fsmresult to 1 (Success).
Code: _state = "END"; _vehicle setVariable["fsmresult", 1];
Group Unification:

Merges split crew groups using A3A_fnc_joinMultipleGroups.
Code: private _crewGroup = _splitCrew call A3A_fnc_joinMultipleGroups;
Unloading Waypoint:

Adds a "TR UNLOAD" waypoint at the destination with a 50m radius.
Sets a waypoint statement to unassign cargo when the waypoint is reached (local execution check).
Code:
Sqf

Apply
private _wp0 = _crewGroup addWaypoint [_destination, 50];
_wp0 setWaypointCompletionRadius 50;
_wp0 setWaypointType "TR UNLOAD";
_wp0 setWaypointStatements ["true", "if !(local this) exitWith {}; { unassignVehicle _x; } forEach (assignedCargo (vehicle this));"];
Cargo Movement:

If cargo exists, adds a "MOVE" waypoint for the cargo group to the destination.
Sets a waypoint statement to trigger A3A_fnc_attackDrillAI upon arrival.
Code:
Sqf

Apply
if !(isNull _cargoGroup) then {
    private _wp2 = _cargoGroup addWaypoint [_destination, 10];
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI;"];
    _cargoGroup setCurrentWaypoint _wp2;
};
Reinforcement Logic (Garrison):

Checks if _convoyType is "reinforce" and if the side matches the destination marker side.
Gathers unit types from crew and cargo groups.
Calls A3A_fnc_addGarrison to immediately bolster the outpost defense.
Code:
Sqf

Apply
if (_convoyType isEqualTo "reinforce" && (_side == sidesX getVariable _markers#1)) then {
    private _garrison = [typeOf _vehicle, [], []];
    { (_garrison # 1) pushBack (_x getVariable "unitType") } foreach units _crewGroup;
    { (_garrison # 2) pushBack (_x getVariable "unitType") } foreach units _cargoGroup;
    [_markers # 1, [_garrison]] call A3A_fnc_addGarrison;
    // ... despawn synchronization logic ...
};
Despawning:

If not a reinforce convoy (or side mismatch), standard despawners are called (A3A_fnc_groupDespawner, A3A_fnc_vehDespawner).
If it is a reinforce convoy, a spawn script waits for the spawner variable on the marker to be 2 (idle) before deleting units, ensuring they are fully integrated.
Where it leads:

This is a Final State.
State: End_and_Abort
Purpose: Clean abort state. Sets the result variable to -2 (Abort) and terminates.

Step-by-step implementation:

State & Result:
Sets _state to "END".
Sets fsmresult to -2.
Code:
Sqf

Apply
_state = "END";
if !(isNull _vehicle) then { _vehicle setVariable["fsmresult", -2] };
Where it leads:

This is a Final State.
Function Name: A3A/addons/core/FSMs/ConvoyTravelAir.fsm
High-level description of the function's purpose: This FSM controls the movement of an air vehicle (helicopter) in a convoy. It handles hovering/flying to a target, following a dynamic position (leader), landing at a destination, unloading cargo, and returning to base.

When/Why it's called: Called when an air transport convoy is spawned (e.g., reinforcements via helicopter).

How it does that:

State: Start
Purpose: Initializes the air vehicle, extracts offset positions (for formation flying), and validates inputs.

Step-by-step implementation:

Parameter Extraction:

Extracts _vehicle, _offset (vector offset from leader), _markers, _convoyType.
Code: params ["_vehicle", "_offset", "_markers", "_convoyType"];
Validation:

Checks for null vehicle or null driver.
Code:
Sqf

Apply
if (isNull _vehicle) exitWith { _abort = true; [1, "Null vehicle input", "ConvoyTravelAir"] call A3A_fnc_log };
if (isNull (driver _vehicle)) exitWith { _abort = true; [1, "No driver in vehicle", "ConvoyTravelAir"] call A3A_fnc_log };
Group Setup:

Identifies cargo group and crew group based on assigned cargo.
Stores destination and origin positions from markers.
Code:
Sqf

Apply
private _cargo = assignedCargo _vehicle;
private _cargoGroup = if (_cargo isEqualTo []) then { grpNull } else { group (_cargo # 0) };
private _crewGroup = group driver _vehicle;
private _destPos = getMarkerPos (_markers # 1);
private _originPos = getMarkerPos (_markers # 0);
Where it leads:

Triggers Hard_Abort: If _abort is true. Leads to End_and_Abort.
Triggers Nothing_to_follo: If _vehicle getVariable "followpos" is nil. Leads to Head_to__Target.
Triggers True: Default. Leads to Follow_position.
State: Head_to__Target
Purpose: Flies the helicopter directly to the destination marker.

Step-by-step implementation:

State Update:

Sets state to "FLYTO".
Code: _state = "FLYTO";
Waypoint Setup:

Adds a "MOVE" waypoint at the destination with 50m altitude (vector add [0,0,50]).
Code:
Sqf

Apply
private _wp0 = _crewGroup addWaypoint [_destPos vectorAdd [0,0,50], 100];
_wp0 setWaypointType "MOVE";
_crewGroup setCurrentWaypoint _wp0;
Where it leads:

Triggers Abort: Leads to End_and_Abort.
Triggers Veh_Incapacitate: If !canMove or !alive driver. Leads to End_and_Cleanup.
Triggers HasArrived: If distance < 500m. Leads to Land_and_Unload.
State: Follow_position
Purpose: Manages dynamic movement where the helicopter follows a moving object (leader) using a defined offset.

Step-by-step implementation:

Position Calculation:

Retrieves the current followpos from vehicle variables.
Applies the _offset vector to calculate the specific position for this helicopter.
Uses move command (which creates a localized "soft" waypoint).
Code:
Sqf

Apply
private _followPos = _vehicle getVariable "followpos";
_vehicle move (_followPos vectorAdd _offset);
Timeout:

Sets a 2-second timeout to update the position again (preventing command spam).
Code: private _timeout = time + 2;
Where it leads:

Triggers Timed_position_u: If time >= _timeout. Loops back to Follow_position (refreshes move command).
Triggers Abort: Leads to End_and_Abort.
Triggers Veh_Incapacitate: Leads to End_and_Cleanup.
Triggers HasArrived: If distance < 500m. Leads to Land_and_Unload.
Triggers Nothing_to_follo: If followpos becomes nil. Leads to Head_to__Target.
State: Land_and_Unload
Purpose: Finds a safe landing position near the destination, creates a helipad, and lands to unload troops.

Step-by-step implementation:

Landing Zone Search:

Uses BIS_fnc_findSafePos to find a landing spot near _destPos.
Sets Z-level to 0.
Code:
Sqf

Apply
private _landPos = [_destPos, 0, 300, 10, 0, 0.20, 0,[],[[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
_landPos set [2, 0];
Helipad Creation:

Spawns an invisible helipad object at the landing spot to ensure valid landing terrain.
Code: private _landPad = createVehicle ["Land_HelipadEmpty_F", _landpos, [], 0, "NONE"];
Landing Waypoint:

Adds "TR UNLOAD" waypoint at _landpos.
Sets waypoint statement to execute land 'GET OUT' locally.
Sets behavior to "CARELESS".
Code:
Sqf

Apply
private _wp1 = _crewGroup addWaypoint [_landpos, 0];
_wp1 setWaypointType "TR UNLOAD";
_wp1 setWaypointStatements ["true", "if !(local this) exitWith {}; (vehicle this) land 'GET OUT';"];
_wp1 setWaypointBehaviour "CARELESS";
Cargo Unloading:

Unassigns cargo units from the vehicle.
Sends cargo group to the exact destination marker (center of outpost).
Code:
Sqf

Apply
if !(isNull _cargoGroup) then {
    { unassignVehicle _x } forEach units _cargoGroup;
    private _wp2 = _cargoGroup addWaypoint [_destPos, 10];
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI;"];
    _cargoGroup setCurrentWaypoint _wp2;
};
Where it leads:

Triggers Abort: Leads to End_and_Abort.
Triggers Veh_Incapacitate: Leads to End_and_Cleanup.
Triggers HasUnloaded: Checks if cargo units are no longer inside a vehicle ({ vehicle _x != _x } count units _cargoGroup == 0). Leads to Return__to_Base.
State: Return__to_Base
Purpose: Sends the helicopter back to the origin marker. Handles garrison reinforcement logic if applicable.

Step-by-step implementation:

Result & Cleanup:

Sets fsmresult to 1 (Success).
Deletes the temporary _landPad.
Code:
Sqf

Apply
_vehicle setVariable["fsmresult", 1];
if !(isNil "_landPad") then { deleteVehicle _landPad };
Return Waypoint:

Enables deleteGroupWhenEmpty on the crew group.
Adds a waypoint to the origin position (plus 50m altitude).
Sets waypoint statement to delete the vehicle and crew units upon arrival (if not already despawned).
Code:
Sqf

Apply
_crewGroup deleteGroupWhenEmpty true;
private _wp3 = _crewGroup addWaypoint [_originPos vectorAdd [0,0,50], 100];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointStatements ["true", "if !(local this) exitWith {}; [3, ""heli return completed"", ""ConvoyTravelAir""] call A3A_fnc_log; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
Garrison Logic:

If this was a "reinforce" convoy, adds cargo unit types to the garrison of the destination marker immediately.
Sets up a despawn loop that waits for the marker to be idle (spawner getVariable _marker == 2) before deleting cargo units.
Code:
Sqf

Apply
if (_convoyType isEqualTo "reinforce" && (side _cargoGroup == sidesX getVariable _markers#1)) then {
    private _unitTypes = [];
    { _unitTypes pushBack (_x getVariable "unitType") } foreach units _cargoGroup;
    [_markers # 1, [["", [], _unitTypes]]] call A3A_fnc_addGarrison;
    // Spawn despawn synchronization
};
Where it leads:

This is a Final State.
State: End_and_Cleanup
Purpose: Failure state for air vehicles (e.g., shot down). Cleans up groups, despawns units, and sends survivors back to origin.

Step-by-step implementation:

Result & Pad:

Sets fsmresult to -1.
Deletes _landPad if it exists.
Code: _vehicle setVariable["fsmresult", -1]; if !(isNil "_landPad") then { deleteVehicle _landPad };
Group Unification:

Unassigns vehicle, joins cargo to crew group, deletes cargo group.
Code:
Sqf

Apply
{ unassignVehicle _x } forEach (crew _vehicle);
if !(isNull _cargoGroup) then {
    (units _cargoGroup) joinSilent _crewGroup;
    deleteGroup _cargoGroup;
};
Despawn & Return:

Calls despawners.
Adds a waypoint for the crew to return to _originPos.
Code:
Sqf

Apply
[_crewGroup] spawn A3A_fnc_groupDespawner;
[_vehicle] spawn A3A_fnc_vehDespawner;
private _wp3 = _crewGroup addWaypoint [_originPos, 100];
_wp3 setWaypointType "MOVE";
Where it leads:

This is a Final State.
State: End_and_Abort
Purpose: Immediate termination without movement. Cleans up the helipad if it was created.

Step-by-step implementation:

Result & Cleanup:
Sets fsmresult to -2.
Deletes _landPad if present.
Code:
Sqf

Apply
_state = "END";
_vehicle setVariable["fsmresult", -2];
if !(isNil "_landPad") then { deleteVehicle _landPad };
Where it leads:

This is a Final State.
Function Name: A3A/addons/core/FSMs/DriveAlongPath.fsm
High-level description of the function's purpose: A simplified version of ConvoyTravel. It drives a vehicle along a path but lacks the complex logging, multi-group unloading logic, or garrison management of the main convoy FSM. It is used for simpler transport tasks.

When/Why it's called: Likely used for simpler scripted vehicle movements where full convoy logic isn't required.

How it does that:

State: Start
Purpose: Validates inputs and initializes the vehicle and crew.

Step-by-step implementation:

Parameter Extraction:

Extracts _vehicle and _route.
Code: params ["_vehicle", "_route"];
Validation:

Checks if vehicle is null or route is empty. If so, exits silently (no abort variable).
Code: if (isNull _vehicle || count _route == 0) exitWith {};
Initialization:

Sets destination, accuracy (50m), and splits vehicle crew.
Sets driver behavior to careless.
Code:
Sqf

Apply
private _destination = _route select (count _route - 1);
private _accuracy = 50;
private _splitCrew = [_vehicle] call A3A_fnc_splitVehicleCrewIntoOwnGroups;
if (_splitCrew select 0 isEqualTo []) exitWith { _hardAbort = true; };
(group driver _vehicle) setBehaviour "CARELESS";
(group driver _vehicle) setCombatMode "BLUE";
private _currentNode = 0;
Where it leads:

Triggers Hard_Abort_: If _splitCrew was empty. Leads to Abort.
Triggers True: Leads to Head_to__Next_Po.
State: Head_to__Next_Po
Purpose: Orders the vehicle to move to the next node in the route.

Step-by-step implementation:

Movement Order:
Retrieves _nextPos.
Iterates through split crew groups and adds a waypoint at the position.
Code:
Sqf

Apply
private _nextPos = _route # _currentNode;
{
    private _nextWaypoint = _x addWaypoint [AGLToASL _nextPos, -1];
    _x setCurrentWaypoint _nextWaypoint;
} forEach (_splitCrew # 0);
Where it leads:

Triggers Abort: Checks if _abort variable exists (note: syntax is !(isNil "_abort")). Leads to End_and_Rejoin.
Triggers Veh_or_Crew_Dead: If vehicle/crew is dead. Leads to End_and_Rejoin.
Triggers HasArrived: If vehicle distance to final destination < _accuracy. Leads to End_and_Rejoin.
Triggers At_Next_Pos: If vehicle distance to next waypoint < _accuracy. Increments _currentNode and loops back to Head_to__Next_Po.
Triggers Fucked_Waypoint: Checks if currentWaypoint + 1 > count waypoints. This detects if the vehicle has run out of waypoints (logic error) and loops back to retry.
State: End_and_Rejoin
Purpose: Rejoins split crew groups and terminates.

Step-by-step implementation:

Join Groups:
Calls A3A_fnc_joinMultipleGroups to merge the crew back together.
Code: _splitCrew call A3A_fnc_joinMultipleGroups;
Where it leads:

Final State.
State: Abort
Purpose: Terminates without rejoining.

Step-by-step implementation:

State Update:
Sets state to "END".
Code: _state = "END";
Where it leads:

Final State.
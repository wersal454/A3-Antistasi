params ["_veh", "_groupX", "_positionX",/*  "_posOrigin", */ "_Pod"];

///TODO
///Make as many landing positions as there landing Pods
///If landing Pod doesn't fit any cargo, spawn at least 2 or 3 pods, split cargo group and spawn them near pod after landing.
///If landing Pod have less cargo then group size, fill pod, then spawn enother fill that pod, etc.
///If landing Pod has 1 seat , spawn as many pods as there are units in the group.
///If there multiple pods, launch each Pod at random delay (from 0.5 to 2 seconds)
///Launch Pod(s) straitgt to earth, no angle , no curve , don't want to deal with physx
///Don't care if landing pos. is near units(halo wars 2 trailer style(or WH40k)), big bad if landing pos is a building(or maybe not, just destroy building upon landing?(what if builing undestracteble))
///After landing, reg. behaviour for the troops.
///Maybe add a check if units in the groop somehow managed to land far apart, split the group(to avoid stupid behaviour like running towards one enother), after some time check if they are near each other, if so rejoin group.

private _reinf = if (count _this > 5) then {_this select 5} else {false};

private _xRef = 2;
private _yRef = 1;
private _landpos = [];
private _dist = if (_reinf) then {30} else {100 + random 100};

while {true} do
	{
 	_landpos = _positionX getPos [_dist,random 360];
 	if (!surfaceIsWater _landpos) exitWith {};
	};
_landpos set [2,0];
{_x setBehaviour "CARELESS";} forEach units _Pod;
private _wp = _Pod addWaypoint [_landpos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "FULL";
_wp setWaypointCompletionRadius 3;



waitUntil {sleep 1; (not alive _veh) or (_veh distance _landpos < 550) or !(canMove _veh)};

_veh flyInHeight 15;

_veh animateDoor ['door_R', 1];
_veh animateDoor ["Door_rear_source", 1, true];
waitUntil {sleep 1; (not alive _veh) or ((speed _veh < 1) and (speed _veh > -1)) or !(canMove _veh)};

if (alive _veh) then
{
	[_veh] call A3A_fnc_smokeCoverAuto;
};

waitUntil {sleep 1; (not alive _veh) or ((count assignedCargo _veh == 0) and (([_veh] call A3A_fnc_countAttachedObjects) == 0))};


sleep 5;
_veh flyInHeight 150;
_veh animateDoor ['door_R', 0];
_veh animateDoor ["Door_rear_source", 0, true];
if !(_reinf) then
	{
	private _wp2 = _groupX addWaypoint [(position (leader _groupX)), 0];
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];
	_wp2 = _groupX addWaypoint [_positionX, 1];
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
	_wp2 = _groupX addWaypoint [_positionX, 2];
	_wp2 setWaypointType "SAD";
	}
else
	{
	private _wp2 = _groupX addWaypoint [_positionX, 0];
	_wp2 setWaypointType "MOVE";
	};
private _wp3 = _Pod addWaypoint [_posOrigin, 1];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "NORMAL";
_wp3 setWaypointBehaviour "CARELESS";
_wp3 setWaypointStatements ["true", "if !(local this) exitWith {}; deleteVehicle (vehicle this); {deleteVehicle _x} forEach thisList"];
{_x setBehaviour "CARELESS";} forEach units _Pod;

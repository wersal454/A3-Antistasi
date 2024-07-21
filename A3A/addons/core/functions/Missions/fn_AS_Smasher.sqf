#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_markerX"];

//Mission: Assassinate a smasher (zombie modset)
if (!isServer and hasInterface) exitWith {};

private _difficultX = random 10 < tierWar;
private _positionX = getMarkerPos _markerX;

private _sideX = sidesX getVariable [_markerX,sideUnknown];
private _faction = Faction(_sideX);

private _civNonHuman = Faction(civilian) getOrDefault ["attributeCivNonHuman", false];

if !(_civNonHuman) exitWith {
	["AS"] remoteExec ["A3A_fnc_missionRequest",2];
    Info("Current civ faction is not non-human. Rerolling");
};

private _limit = if (_difficultX) then {
	30 call SCRT_fnc_misc_getTimeLimit
} else {
	60 call SCRT_fnc_misc_getTimeLimit
}; _limit params ["_dateLimitNum", "_displayTime"];

private _radiusX = [_markerX] call A3A_fnc_sizeMarker;
private _nameDest = [_markerX] call A3A_fnc_localizar;

private _posTask = _positionX getPos [random 100, random 360];
private _taskId = "AS" + str A3A_taskCount;
[
	[teamPlayer,civilian],
	_taskID,
	[
		format [localize "STR_A3A_Missions_AS_Smasher_task_desc", FactionGet(occ,"name"), _nameDest, _displayTime],
		localize "STR_A3A_Missions_AS_Smasher_task_header",
		_markerX
	],
	_positionX,
	false,
	0,
	true,
	"Kill",
	true
] call BIS_fnc_taskCreate;
[_taskId, "AS", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

// Wait until players are close enough to the city, the idea being that they will see the SF groups fighting the smasher (+ helps perf)
waitUntil {
	sleep 5;
	((call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_positionX, 300, 300] isNotEqualTo []) || {dateToNumber date > _dateLimitNum}
};

private _smasher = ObjNull;
private _groupSmasher = createGroup Invaders;

private _groupSFHash = A3A_faction_occ;
private _groupSFSide = Occupants;

if (_difficultX) then {
	_smasher = [_groupSmasher, "WBK_Goliaph_3", _posTask, [], 0, "NONE"] call A3A_fnc_createUnit; // goliath (OPF)
} else {
	_smasher = [_groupSmasher, "WBK_SpecialZombie_Smasher_3", _posTask, [], 0, "NONE"] call A3A_fnc_createUnit; // smasher (OPF)
};

private _groupsSF = [];
for "_i" from 0 to 3 do
{
	private _sfPos = _posTask getPos [random 10, random 360];
	
	private _typeGroup = selectRandom (_groupSFHash get "groupSpecOpsRandom");
	private _groupSF = [_sfPos, _groupSFSide, _typeGroup, false, true] call A3A_fnc_spawnGroup;

	// Set up SF group behaviour
	{
		[_x, ""] call A3A_fnc_NATOinit;
		_x allowFleeing 0;
		_x setUnitPos "UP";
	} forEach units _groupSF;
	[_groupSF, "Patrol_Area", 25, 50, 100, false, [], false] call A3A_fnc_patrolLoop;

	_groupsSF pushBack _groupSF;

	uiSleep 1;
};

private _attackHeliVehicle = ObjNull;

if (_difficultX) then {
	private _heliType = selectRandom (_faction getOrDefault ["vehiclesHelisAttack", []]);

	private _heliPos = _posTask getPos [random [1000, 2000, 3000], random 360]; // replace this with an airbase or outpost, etc

	if (_heliType isEqualTo []) then {
		_heliType = _faction getOrDefault ["vehiclesHelisLightAttack", []]
	};

	private _heliGroup = createGroup _groupSFSide;

	private _attackHeli = [_heliPos, 0, _heliType, _groupSFSide] call A3A_fnc_spawnVehicle;
	_attackHeliVehicle = (_attackHeli#0); // defined in outer scope first

	{
		[_x] join _heliGroup;
	} forEach crew _attackHeliVehicle;

	[_attackHeliVehicle, _heliGroup, _positionX] spawn A3A_fnc_attackHeli;

	// _attackHeliVehicleWaypoint = _heliGroup addWaypoint [_smasher, 1];
	// _attackHeliVehicleWaypoint setWaypointType "DESTROY";
	// _attackHeliVehicleWaypoint setWaypointBehaviour "COMBAT";
};

// Wait until the smasher is dead or mission is expired
waitUntil {
	sleep 10;
	!(alive _smasher) || {dateToNumber date > _dateLimitNum}
};

if (dateToNumber date > _dateLimitNum) then {
	[_taskId, "AS", "FAILED", true] call A3A_fnc_taskSetState;
} else {
	[_taskId, "AS", "SUCCEEDED", true] call A3A_fnc_taskSetState;

	if (_difficultX) then {
		[0, 3000] remoteExec ["A3A_fnc_resourcesFIA",2];
		[0, 30, _positionX] remoteExec ["A3A_fnc_citySupportChange",2];

		{ 
			[80, _x] call A3A_fnc_addScorePlayer;
			[2000, _x] call A3A_fnc_addMoneyPlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
	} else {
		[0, 1000] remoteExec ["A3A_fnc_resourcesFIA",2];
		[0, 10, _positionX] remoteExec ["A3A_fnc_citySupportChange",2];

		{ 
			[40, _x] call A3A_fnc_addScorePlayer;
			[1000, _x] call A3A_fnc_addMoneyPlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
	};

};

[_taskId, "AS", 1200, true] spawn A3A_fnc_taskDelete;

{
	[_x] spawn A3A_fnc_groupDespawner;
} forEach _groupsSF;

[_groupSmasher] spawn A3A_fnc_groupDespawner;

[_heliGroup] spawn A3A_fnc_groupDespawner;

[_attackHeliVehicle] spawn A3A_fnc_vehDespawner;
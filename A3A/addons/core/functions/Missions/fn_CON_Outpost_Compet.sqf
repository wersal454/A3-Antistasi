params ["_markerX"];

//Mission: Conquer the outpost, before other faction will do it.
if (!isServer and hasInterface) exitWith{};

private _difficultX = if (random 10 < tierWar) then {true} else {false};
private _positionX = getMarkerPos _markerX;

private _limit = if (_difficultX) then {
	45 call SCRT_fnc_misc_getTimeLimit
} else {
	90 call SCRT_fnc_misc_getTimeLimit
};
_limit params ["_dateLimitNum", "_displayTime"];

private _markerSide = sidesX getVariable [_markerX, sideUnknown];

private _nameDest = [_markerX] call A3A_fnc_localizar;
private _textX = "";
private _taskName = "";

private _specOpsArray = if (_difficult) then {selectRandom (_faction get "groupSpecOpsRandom")} else {selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)};

params ["_mrkDest", "_side", "_vehCount", "_reveal"];


if ((_side == Occupants && areOccupantsDefeated) || {(_side == Invaders && areInvadersDefeated)}) exitWith {
    ServerInfo_1("%1 faction was defeated earlier, aborting single attack.", str _side);
};

private _targPos = markerPos _mrkDest;

ServerInfo_1("Starting attack with parameters %1", _this);

private _airbase = [_side, markerPos _mrkDest] call A3A_fnc_availableBasesAir;

//params ["_side", "_airbase", "_target", "_resPool", "_vehCount", "_delay", "_modifiers", "_attackType", "_reveal"];
private _data = [_side, _airbase, _mrkDest, "defence", _vehCount, 0, [], "CounterAttack", _reveal] call A3A_fnc_createAttackForceMixed;
_data params ["", "_vehicles", "_crewGroups", "_cargoGroups"];

// Prepare despawn conditions
private _endTime = time + 2700;
private _victory = false;
private _soldiers = [];
{ _soldiers append units _x } forEach _cargoGroups;

while {true} do
{
    private _markerSide = sidesX getVariable _mrkDest;
    if(_markerSide == _side) exitWith {
        ServerInfo_1("Small attack to %1 captured the marker, starting despawn routines", _mrkDest);
        _victory = true;
    };

    private _curSoldiers = { !fleeing _x and _x call A3A_fnc_canFight } count _soldiers;
    if (_curSoldiers < count _soldiers * 0.25) exitWith {
        ServerInfo_1("Small attack to %1 has been defeated, starting despawn routines", _mrkDest);
    };
    if(_endTime < time) exitWith {
        ServerInfo_1("Small attack to %1 timed out, starting despawn routines", _mrkDest);
    };

    // Attempt to flip marker
    [_mrkDest, _markerSide] remoteExec ["A3A_fnc_zoneCheck", 2];
    sleep 30;
};

{ [_x] spawn A3A_fnc_VEHDespawner } forEach _vehicles;
{ [_x] spawn A3A_fnc_enemyReturnToBase } forEach _crewGroups;
{
    [_x, [nil, _mrkDest] select _victory] spawn A3A_fnc_enemyReturnToBase;
    sleep 10;
} forEach _cargoGroups;


switch (true) do {
	case (_markerX in resourcesX): {
		_textX = format [localize "STR_CON_Outpost_resources_desc", _nameDest, _displayTime];
		_taskName = localize "STR_CON_Outpost_resources_task";
	};
	case (_markerX in controlsX): {
		_textX = format [localize "STR_CON_Outpost_controls_desc", _nameDest, _displayTime];
		_taskName = localize "STR_CON_Outpost_controls_task";
	};
	default {
		_textX = format [localize "STR_CON_Outpost_outposts_desc", _nameDest, _displayTime];
		_taskName = localize "STR_CON_Outpost_outposts_task";
	};
};

private _taskId = "CON" + str A3A_taskCount;
[[teamPlayer,civilian],_taskId,[_textX,_taskName,_markerX],_positionX,false,0,true,"Target",true] call BIS_fnc_taskCreate;
[_taskId, "CON", "CREATED"] remoteExecCall ["A3A_fnc_taskUpdate", 2];

waitUntil {sleep 1; dateToNumber date > _dateLimitNum or {sidesX getVariable [_markerX,sideUnknown] == teamPlayer}};

// add a check if all players are dead, in the area of a marker
// Or add a check if possible to determite whenver other faction managed to capture marker
if (dateToNumber date > _dateLimitNum) then {
	[_taskId, "CON", "FAILED"] call A3A_fnc_taskSetState;
	if (_difficultX) then {
		[25,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[-1200, _markerSide] remoteExec ["A3A_fnc_timingCA",2];
		[-20,theBoss] call A3A_fnc_addScorePlayer;
	} else {
		[5,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[-600, _markerSide] remoteExec ["A3A_fnc_timingCA",2];
		[-10,theBoss] call A3A_fnc_addScorePlayer;
	};
} else {
	sleep 10;
	[_taskId, "CON", "SUCCEEDED"] call A3A_fnc_taskSetState;
	if (_difficultX) then {
		[0,800] remoteExec ["A3A_fnc_resourcesFIA",2];
		[-25,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[1800, _markerSide] remoteExec ["A3A_fnc_timingCA",2];
		{ 
			[450, _x] call A3A_fnc_addMoneyPlayer;
			[20, _x] call A3A_fnc_addScorePlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
		[20, theBoss] call A3A_fnc_addScorePlayer;
        [200,theBoss, true] call A3A_fnc_addMoneyPlayer;
	} else {
		[0,600] remoteExec ["A3A_fnc_resourcesFIA",2];
		[-20,0,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
		[1200, _markerSide] remoteExec ["A3A_fnc_timingCA",2];
		{ 
			[250, _x] call A3A_fnc_addMoneyPlayer;
			[10, _x] call A3A_fnc_addScorePlayer;
		} forEach (call SCRT_fnc_misc_getRebelPlayers);
		[10, theBoss] call A3A_fnc_addScorePlayer;
        [100, theBoss, true] call A3A_fnc_addMoneyPlayer;
	};
};

[_taskId, "CON", 1200] spawn A3A_fnc_taskDelete;

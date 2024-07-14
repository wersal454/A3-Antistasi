params ["_pod", "_groupX", "_positionX", "_posOrigin"/* , "_crew" */];

///TODO
///Make as many landing positions as there landing Pods
///If landing Pod doesn't fit any cargo, spawn at least 2 or 3 pods, split cargo group and spawn them near pod after landing.
///If landing Pod have less cargo then group size, fill pod, then spawn enother fill that pod, etc.
///If landing Pod has 1 seat , spawn as many pods as there are units in the group.
///If there multiple pods, launch each Pod at random delay (from 0.5 to 2 seconds)
///Launch Pod(s) straitgt to earth, no angle , no curve , don't want to deal with physx
///Don't care if landing pos. is near units(halo wars 2 trailer style(or WH40k)), big bad if landing pos is building(or maybe not, just destroy building upon landing?(what if builing undestracteble))
///After landing, reg. behaviour for the troops.
///Maybe add a check if units in the groop somehow managed to land far apart, split the group(to avoid stupid behaviour like running towards one enother), after some time check if they are near each other, if so rejoin group.

_dist = 1 + random 100;
_landpos = _positionX getPos [_dist,random 360];
{
	_x allowDamage false;

} forEach units _groupX;

private _podseats = 0;

_podseats = [typeOf _pod, true] call BIS_fnc_crewCount;

private _groupcount = count (units _groupX);

if (_podseats >= _groupcount) then {
	{
		_x assignAsCargo _pod;
		_x moveInCargo _pod;
	} forEach units _groupX;
};

private _wp2 = _groupX addWaypoint [(position (leader _groupX)), 0];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true", "if !(local this) exitWith {}; (group this) spawn A3A_fnc_attackDrillAI"];
_wp2 = _groupX addWaypoint [_positionX, 1];
_wp2 setWaypointType "MOVE";
_wp2 setWaypointStatements ["true","if !(local this) exitWith {}; {if (side _x != side this) then {this reveal [_x,4]}} forEach allUnits"];
_wp2 = _groupX addWaypoint [_positionX, 2];
_wp2 setWaypointType "SAD";

{_x setBehaviour "AWARE";} forEach units _Pod;

_pod allowDamage false;

_pod lock 2;
_pod setVehicleLock "LOCKED";
_pod setPos [(_landpos select 0),(_landpos select 1), 3000];
_pod setVelocity [0,0,-150];
[_pod] call SCRT_fnc_effect_orbitalDropEffect;
/* _pod setVelocity [0,0,-1]; */
_bomb ="Sh_155mm_AMOS" createVehicle [(getPos _pod select 0),(getPos _pod  select 1),0]; //bomb doesn't go off, sad
sleep 0.2;
_pod setPos [(getPos _pod select 0),(getPos _pod  select 1),1];

sleep 1;

{
	_x allowDamage true;

} forEach units _groupX;

_pod allowDamage true;

_pod animateDoor ['door_R', 1];
_pod animateDoor ["Door_rear_source", 1, true];
[_pod] call A3A_fnc_smokeCoverAuto;

diag_log _groupcount;
diag_log _groupcount;
diag_log _groupcount;
if (_podseats >= _groupcount) then {
private _second = false;
{
  if (_second) then {
    _x action ["Eject", _pod];
    unassignVehicle _x;
    _second = false;
  } else {
    _second = true;
    _x leaveVehicle _pod;
  };
  private _second = true;
} forEach units _groupX;
};
sleep 2;
private _SafeMovePos = [];
if (_podseats < _groupcount) then {
	{
		diag_log 123456;
		diag_log 123456;
		diag_log 123456;
		_SafeMovePos = [getPos _pod, 1, 3, 3, 1, 20, 0] call BIS_fnc_findSafePos;
		_x setPos _SafeMovePos;
		sleep 0.02;
	} forEach units _groupX;
};

/* private _dist = objNull;
private _landingpositions = [];

private _case = objNull; ///not sure about this

private _groupcount = count units _groupX;
private _podseats = [_pod, true] call BIS_fnc_crewCount;
private _pods = [];

if (_podseats == 0) then {
	_case = 1;
	_podsneaded = _groupcount/3; ///splitting group roughly to 2-3 groups, and giving each group their pod
	{
		_x = createVehicle [_pod, _posOrigin, [], 0, "NONE"];
		_pods append _x;
	}forEach _podsneaded;
} else {
	if (_podseats > 1 && _podseats <= _groupcount) then {
		_case = 2;
		_podsneaded = _podseats/_groupcount; ///creating pods to fill all members of each group. Split group later.
		{
			_x = createVehicle [_pod, _posOrigin, [], 0, "NONE"];
			_pods append _x;
		}forEach _podsneaded;
	} else {
		_case = 2;
		{
			_x = createVehicle [_pod, _posOrigin, [], 0, "NONE"];
			_pods append _x;
		}forEach _groupX; ///creating pods for every unit in the group, because pod has only 1 seat or because pod has the same(or more) seats as group size. 
	};
};

{
	_dist = 1 + random 100;
 	_landpos = _positionX getPos [_dist,random 360];
 	if (!surfaceIsWater _landpos) then {
		_landingpositions append _landpos; ///creating an array of good landing possitons;
	} else {
		_landpos = _positionX getPos [_dist,random 360]; ///dunno... let them land into the water?
		_landingpositions append _landpos;
	};
}forEach _pods;

///here we should split groups and put them inside pods(if possible)
private _groups = [];
{
	_unitgroupX = select random units _groupX;
	_newgroup = [];
	_newgroup  append _unitgroupX;
	_groups  append _newgroup;
}forEach _pods;

private _i = 0;
{
	if (_podseats != 0 && _podseats > 1) then {
		{
			units (_groups select _i) moveInAny _x;
		};
	} else {
		if (_podseats == 1) then {
			units (_groups select _i) moveInAny _x; //dunno if its even needed

		}else {}; //don't do shit since pod doesn't have cargo , spawn near it later.
	};
	_i = _i + 1;
}forEach _pods;

////should probabaly use dummes to launch, just like in crashsite mission
private _i = 0;
{
	_j = _landingpositions select _i;
	_x setPos [(_j select 0),(_j select 1), 3000]; ///3000 or whatever to give sometime for message to pop up to let rebels prepare(if there is any message about orbital drop)
	_x setVelocity [0,0,-200]; ///should probably be more then 200
	[_x] call SCRT_fnc_effect_crashingEffects;
    //_bomb ="ammo_Missile_Cruise_01" createVehicle [(_j  select 0),(_j  select 1),0]; //bomb should be "smaller"
	_i = _i + 1;
	//sleep random from 0.5 to 2; //probably too bad, can lead to undesireble behaviour
}forEach _pods; */

/* {
	_bomb = "ammo_Missile_Cruise_01" createVehicle [(getPos _x  select 0),(getPos _x  select 1),0]; //bomb should be "smaller"
}forEach _pods; */



///somehow rejoin all units back to original group(maybe under certian condition)


/* {_x setBehaviour "CARELESS";} forEach units _Pod;
private _wp = _Pod addWaypoint [_landpos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointSpeed "FULL";
_wp setWaypointCompletionRadius 3; */

/* waitUntil {sleep 1; (not alive _veh) or ((count assignedCargo _veh == 0) and (([_veh] call A3A_fnc_countAttachedObjects) == 0))};

*/

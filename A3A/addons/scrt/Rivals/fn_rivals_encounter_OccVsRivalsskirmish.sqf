#include "..\defines.inc"
FIX_LINE_NUMBERS()

Info("Skirmish occupants vs rivals event Init.");

private _difficult = random 10 < tierWar; ///maybe add a war level check, if high(7+) -> big battle(5 vs 5 squads)
private _difficult2 = random 10 < tierWar;

private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);

if (isNil "_player") exitWith {
    Error("No players found, aborting.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};

private _originPosition = position _player;
Info_2("%1 will be used as center of the event at %2 position.", name _player, str _originPosition);

private _potentialOutposts = (outposts + resourcesX + factories + citiesX) select { sidesX getVariable [_x, sideUnknown] == Occupants && {(getMarkerPos _x) distance2D _player < distanceSPWN*2}};
if (_potentialOutposts isEqualTo []) exitWith {
    Info("No outposts in proximity, aborting Skirmish fronline Event.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};
private _FrontlineOutpost = selectRandom _potentialOutposts;

private _side = Occupants; //?
private _side2 = Rivals;
private _faction = Faction(_side);
private _faction2 = Faction(_side2);
private _FrontlineOutpostPosition = getMarkerPos _FrontlineOutpost;

private _specOpsArray = if (_difficult) then {selectRandom (_faction get "groupSpecOpsRandom")} else {selectRandom ([_faction, "groupsTierSquads"] call SCRT_fnc_unit_flattenTier)}; ///maybe move this into fuction and roll every time?
private _specOpsArray2 = if (_difficult2) then {selectRandom (A3A_faction_riv get "groupsSquad")} else {selectRandom ((A3A_faction_riv get "groupsFireteam") + (A3A_faction_riv get "groupsSentry") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT"))};

//(selectRandom ((A3A_faction_riv get "groupsSentry") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT"))); //not very good
//selectRandom ((A3A_faction_riv get "groupsFireteam") + (A3A_faction_riv get "groupsAA") + (A3A_faction_riv get "groupsAT")); //mid
//(A3A_faction_riv get "groupsSquad") //good?

_skirmishposition = [_originPosition, distanceSPWN, distanceSPWN, 1, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;///pos player , distance distance spwn
///add a check for HQ
_skirmishposition2 = [_skirmishposition, 500, 700, 1, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;

private _fnc_spawngroups = {
	params ["_amount","_amount2", "_vehiclesAmount" , "_vehiclesAmount2" , "_difficult" , "_difficult2"];
	for "_i" from 1 to _amount do {
		_skirmishpositionActuall = [_skirmishposition, 300, 500, 1, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		_InfGroup = [_skirmishpositionActuall, _side, _specOpsArray] call A3A_fnc_spawnGroup;
		{[_x] call A3A_fnc_NATOinit} forEach units _InfGroup;
		_InfGroup setBehaviourStrong "AWARE";
		private _wp = _InfGroup addWaypoint [_skirmishposition, 50];
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointType "SAD";
		_InfGroups pushBack _InfGroup;

		private _vehicles = if (_difficult) then {selectRandom ((_faction get "vehiclesAirborne") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesTanks") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs"))
					} else {selectRandom
					((_faction get "vehiclesLightUnarmed") + (_faction get "vehiclesLightArmed") + (_faction get "vehiclesAirborne") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesMilitiaAPCs") + 
					(_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaCars"))
		};///add a check for a crew or vehicle type, if met order getout because weak vehicle or unarmed.
		diag_log _vehicles;
		//_skirmishpositionActuall = [_skirmishposition, 70, 200, 10, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		_vehicledata = [_skirmishpositionActuall, 0, _vehicles, _side] call A3A_fnc_spawnVehicle;
		_vehicle = _vehicledata select 0;
		_vehiclegroup = _vehicledata select 2;
		[_vehicle, Occupants] call A3A_fnc_AIVEHinit;
		_vehiclegroup setBehaviourStrong "AWARE";
		/* private _wp = _vehiclegroup addWaypoint [_skirmishposition, 50];
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointType "SAD"; */
		//{_x assignAsCargo _vehicle} forEach units _InfGroup;
		//units _vehiclegroup join _InfGroup;
		if (_difficult) then {
			_UAVtype = selectRandom (_faction get "uavsPortable");
			_uav = createVehicle [_UAVtype, _skirmishpositionActuall, [], 0, "FLY"];
			[_side, _uav] call A3A_fnc_createVehicleCrew;
			_vehiclesArray pushBack _uav;
			_groupUAV = group (crew _uav select 1);
			{[_x] joinSilent _InfGroup} forEach units _groupUAV;
		};
		[_InfGroup, "Patrol_Attack", 0, 300, 1000, true, _skirmishposition, true] call A3A_fnc_patrolLoop;
		[_vehiclegroup, "Patrol_Area", 0, 300, 1000, true, _skirmishposition, false] call A3A_fnc_patrolLoop;
		_vehiclesArray pushBack _vehicle;
	};
	for "_i" from 1 to _amount2 do {
		_skirmishpositionActuall2 = [_skirmishposition2, 150, 200, 1, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		_Rivalsgroup = [_skirmishpositionActuall2, Rivals, _specOpsArray2] call A3A_fnc_spawnGroup;
		{[_x] call A3A_fnc_NATOinit} forEach units _Rivalsgroup;
		_Rivalsgroup setBehaviourStrong "AWARE";
		private _wp = _Rivalsgroup  addWaypoint [_skirmishposition, 50];
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointType "SAD";
		_Rivalsgroups pushBack _Rivalsgroup;

		private _vehicles2 = if (_difficult2) then {selectRandom ((A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks"))} else {selectRandom ((A3A_faction_riv get "vehiclesRivalsCars") + 
		(A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsTrucks"))};
		diag_log _vehicles2;
		//_skirmishpositionActuall2 = [_skirmishposition2, 125, 450, 10, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		_vehicledata2 = [_skirmishpositionActuall2, 0,_vehicles2, _side2] call A3A_fnc_spawnVehicle;
		_vehicle2 = _vehicledata2 select 0;
		_vehiclegroup2 = _vehicledata2 select 2;
		[_vehicle2, Invaders] call A3A_fnc_AIVEHinit;
		_vehiclegroup2 setBehaviourStrong "AWARE";
		/* private _wp2 = _vehiclegroup2 addWaypoint [_skirmishposition, 50];
		_wp2 setWaypointSpeed "NORMAL";
		_wp2 setWaypointType "SAD"; */
		//{_x assignAsCargo _vehicle2} forEach units _Rivalsgroup;
		//units _vehiclegroup2 join _Rivalsgroup;
		/* if (_difficult2) then {
			_UAV2type = selectRandom (A3A_faction_riv get "vehiclesRivalsUavs");
			_uav2 = createVehicle [_UAV2type, _skirmishpositionActuall2, [], 0, "FLY"];
			[_side2, _uav2] call A3A_fnc_createVehicleCrew;
			_vehiclesArray2 pushBack _uav2;
			_groupUAV2 = group (crew _uav2 select 1);
			{[_x] joinSilent _Rivalsgroup} forEach units _groupUAV2;
		}; */
		[_Rivalsgroup, "Patrol_Attack", 0, 300, 1000, true, _skirmishposition, true] call A3A_fnc_patrolLoop;
		[_vehiclegroup2, "Patrol_Area", 0, 300, 1000, true, _skirmishposition, true] call A3A_fnc_patrolLoop;
		_vehiclesArray2 pushBack _vehicle2;
	};
	/* for "_i" from 1 to _vehiclesAmount do {
		private _vehicles = if (_difficult) then {selectRandom ((_faction get "vehiclesAirborne") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesTanks") + (_faction get "vehiclesAPCs") + (_faction get "vehiclesIFVs"))
					} else {selectRandom
					((_faction get "vehiclesLightUnarmed") + (_faction get "vehiclesLightArmed") + (_faction get "vehiclesAirborne") + (_faction get "vehiclesLightTanks") + (_faction get "vehiclesMilitiaAPCs") + 
					(_faction get "vehiclesMilitiaLightArmed") + (_faction get "vehiclesMilitiaCars"))
		};///add a check for a crew or vehicle type, if met order getout because weak vehicle or unarmed.
		diag_log _vehicles;
		_skirmishpositionActuall = [_skirmishposition, 30, 200, 10, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		_vehicledata = [_skirmishpositionActuall, 0, _vehicles, _side] call A3A_fnc_spawnVehicle;
		_vehicle = _vehicledata select 0;
		_vehiclegroup = _vehicledata select 2;
		[_vehicle, Occupants] call A3A_fnc_AIVEHinit;
		_vehiclegroup setBehaviourStrong "AWARE";
		private _wp = _vehiclegroup addWaypoint [_skirmishposition, 0];
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointType "SAD";
		_vehiclesArray pushBack _vehicle;
	};
	for "_i" from 1 to _vehiclesAmount2 do {
		private _vehicles2 = if (_difficult2) then {selectRandom ((A3A_faction_riv get "vehiclesRivalsAPCs") + (A3A_faction_riv get "vehiclesRivalsTanks"))} else {selectRandom ((A3A_faction_riv get "vehiclesRivalsCars") + (A3A_faction_riv get "vehiclesRivalsLightArmed") + (A3A_faction_riv get "vehiclesRivalsTrucks"))};
		diag_log _vehicles2;
		_skirmishpositionActuall2 = [_skirmishposition2, 125, 350, 10, 0, 10, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
		_vehicledata2 = [_skirmishpositionActuall2, 0,_vehicles2, _side2] call A3A_fnc_spawnVehicle;
		_vehicle2 = _vehicledata2 select 0;
		_vehiclegroup2 = _vehicledata2 select 2;
		[_vehicle2, Invaders] call A3A_fnc_AIVEHinit;
		_vehiclegroup2 setBehaviourStrong "AWARE";
		private _wp = _vehiclegroup2 addWaypoint [_skirmishposition, 0];
		_wp setWaypointSpeed "NORMAL";
		_wp setWaypointType "SAD";
		{[_x] assignAsCargo _vehicle2} forEach units _Rivalsgroup;
		units _vehiclegroup2 join _Rivalsgroup;
		_vehiclesArray2 pushBack _vehicle2;
	}; */
};
private _amount = round random 3;
if (_amount == 0) then {
	_amount = 1;
};
private _amount2 = _amount * 2;
if (_amount2 > 5) then {
	_amount2 = 5;
};
private _vehiclesAmount = round random 3;
private _vehiclesAmount2 = round random 3;
if (_vehiclesAmount2 == 0) then {
	_vehiclesAmount2 = 1;
};
private _InfGroups = [];
private _Rivalsgroups = [];
private _vehiclesArray = [];
private _vehiclesArray2 = [];

[_amount, _amount2, _vehiclesAmount , _vehiclesAmount2 ,_difficult ,_difficult2] call _fnc_spawngroups;
///dissable AI and wait until players are nearby? or just wait until players are nearby and then spawn units

private _timeOut = time + 3600;
waitUntil {time > _timeOut && (call SCRT_fnc_misc_getRebelPlayers) inAreaArray [_skirmishposition, distanceSPWN1, distanceSPWN1] isEqualTo []};
///If someone survived -> move to base from the check above?
///some sort of check needed to delete groups and vehicles smart way
{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _InfGroups;
{[_x] spawn A3A_fnc_groupDespawner} forEach _Rivalsgroups;

isEventInProgress = false;
publicVariableServer "isEventInProgress";

Info("Frontline skirmish clean up event complete.");
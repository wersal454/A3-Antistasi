#include "..\defines.inc"
FIX_LINE_NUMBERS()

Info("Civilian Aircraft random event init.");

private _vehicles = [];
private _groups = [];

private _player = selectRandom (call SCRT_fnc_misc_getRebelPlayers);

if (isNil "_player") exitWith {
    Error("No players found, aborting.");
    isEventInProgress = false;
    publicVariableServer "isEventInProgress";
};

private _originPosition = position _player;

Info_2("%1 will be used as center of the event at %2 position.", name _player, str _originPosition);

private _finPosition = [_originPosition, 2500, (random 360)] call BIS_fnc_relPos;

private _spawnPosition = [_originPosition, 1400, 1600, 0, 0, 1] call BIS_fnc_findSafePos;
private _civPlaneData = [[(_spawnPosition select 0), (_spawnPosition select 1), 100 + random 200], 0, selectRandom (A3A_faction_civ get "vehiclesCivPlanes"), civilian] call A3A_fnc_spawnVehicle;
private _PlaneVeh = _civPlaneData select 0;
[_PlaneVeh, civilian] call A3A_fnc_AIVEHinit;
private _PlaneCrew = _civPlaneData select 1;

if (random 100 < 30) then {
    private _civ = [(_civPlaneData select 2), A3A_faction_civ get "unitPress", [0,0,0], [],0, "NONE"] call A3A_fnc_createUnit;
    _civ assignAsCargo _PlaneVeh;
    _civ moveInCargo _PlaneVeh;
};

{[_x] spawn A3A_fnc_civilianInitEH} forEach _PlaneCrew;
private _PlaneGroup = _civPlaneData select 2;

_groups pushBack _PlaneGroup;
_vehicles pushBack _PlaneVeh;

_PlaneVeh flyInHeight (550 + (random 75));

private _relativePositions = [];

{
    private _relativePosition = [_originPosition, 300, _x] call BIS_fnc_relPos;
    _relativePositions pushBack _relativePosition;
} forEach [0, 180];

{
    private _wp = _PlaneGroup addWaypoint [_x, _forEachIndex];
    _wp setWaypointSpeed "NORMAL";
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
} forEach _relativePositions;

private _wp3 = _PlaneGroup addWaypoint [_finPosition, 3];
_wp3 setWaypointType "MOVE";
_wp3 setWaypointSpeed "NORMAL";

private _timeOut = time + 600;
waitUntil { sleep 5; (currentWaypoint _PlaneGroup == 3) || (time > _timeOut) || !(canMove _PlaneVeh) || !alive (driver _PlaneVeh)};

{[_x] spawn A3A_fnc_vehDespawner} forEach _vehicles;
{[_x] spawn A3A_fnc_groupDespawner} forEach _groups;

isEventInProgress = false;
publicVariableServer "isEventInProgress";


Info("Plane Event clean up complete.");

params ["_supportName", "_side", "_resPool", "_maxSpend", "_target", "_targPos", "_reveal", "_delay"];

/*  Sets up the gunship support

    Execution: HC or Server

    Scope: Internal

    Params:
        <STRING> The (unique) name of the support, mostly for logging
        <SIDE> The side from which the support should be sent (occupants or invaders)
        <STRING> Resource pool used for this support. Should be "attack" or "defence"
        <SCALAR> Maximum resources to spend. Not used here.
        <OBJECT|BOOL> Initial CAS target. "false" creates with no initial target
        <POSITION> Estimated position of target, or center of target zone
        <SCALAR> Reveal value 0-1, higher values mean more information provided about support
        <SCALAR> Setup delay time in seconds, if negative will calculate based on war tier

    Returns:
        The name of the target marker, empty string if not created
*/
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

private _airport = [_side, _targPos] call A3A_fnc_availableBasesAir;
if (isNil "_airport") exitWith { Debug_1("No airport found for %1 support", _supportName); -1; };

private _aggro = if(_side == Occupants) then {aggressionOccupants} else {aggressionInvaders};
if (_delay < 0) then { _delay = (0.5 + random 1) * (450 - 15*tierWar - 1*_aggro) };

private _faction = Faction(_side);
private _vehType = selectRandom (_faction get "vehiclesPlanesGunship");
if (isNil "_vehType") exitWith { Debug_1("No gunship for faction.", _supportName); -1; };

private _targArray = [];
if (_target isEqualType objNull and {!isNull _target}) then {
    A3A_supportStrikes pushBack [_side, "AREA", _target, time + 1200, 1200, 200];
    _targArray = [_target, _targPos];
};

// name, side, suppType, center, radius, [target, targpos]
private _suppData = [_supportName, _side, "GUNSHIP", _targPos, 3000, _targArray];       // should radius be larger?
A3A_activeSupports pushBack _suppData;

if(_side == Occupants) then {
    [_suppData, _resPool, _airport, _delay, _reveal] spawn A3A_fnc_SUP_gunshipRoutineNATO;
} else {
    [_suppData, _resPool, _airport, _delay, _reveal] spawn A3A_fnc_SUP_gunshipRoutineCSAT;
};

[_reveal, _side, "GUNSHIP", _targPos, _delay] spawn A3A_fnc_showInterceptedSetupCall;

// Vehicle cost + extra support cost for balance
(A3A_vehicleResourceCosts get _vehType) + 100;

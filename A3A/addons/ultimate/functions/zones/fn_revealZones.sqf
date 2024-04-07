/*
    Author:
    Silence

    Description:
    Reveals multiple zones.

    Params:
	_markers    <ARRAY> <DEFAULT: []>

    Usage:
    [["outpost_1", "outpost_2"]] call A3U_fnc_revealZones;

    Return:
    true or false respectively  <BOOL>
*/

params [
    ["_markers", []]
];

if (_markers isEqualTo []) exitWith {
    ["Function was called with incorrect parameters. Double check them!", _fnc_scriptName] call A3U_fnc_log
};

{
    private _marker = _x;
    if (_marker isEqualTo "") exitWith {false};
    [_marker] call A3U_fnc_revealZone;
} forEach _markers;

true
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_side", "_position"];

///if(tierWar < 7) exitWith {-1}; don't forget to uncommnet it

private _lastSupport = server getVariable ["lastSupport", ["", 0]];
if((_lastSupport select 0) == "MISSILE" && {(_lastSupport select 1) > time}) exitWith {-1};

if !(allowUnfairSupports) exitWith {-1};
private _loadedTemplate = if (_side isEqualTo Occupants) then {A3A_Occ_template} else {A3A_Inv_template};
if (toLower _loadedTemplate isEqualTo "VN") exitWith {-1}; //dont allow with VN
if ("lowTech" in A3A_factionEquipFlags) exitWith {-1}; //leave it like this untill, we add CM launcher vehicle type, and if WW2 modsets have V-2 rockets or something

private _spawnMarkers = (milbases + airportsX) select {sidesX getVariable [_x, sideUnknown] != teamPlayer && sidesX getVariable [_x, sideUnknown] == _side};
private _spawnMarker = selectRandom _spawnMarkers;
_spawnPos = getMarkerPos _spawnMarkers;

//Cruise missile range is 16 km (it can have 32km, but I limit it here)
if(_spawnPos distance2D _position > 16000) exitWith {-1};

private _timerIndex = -1;
private _playerAdjustment = (floor ((count allPlayers)/10)) + 1;
private _supportTimer = if(_side == Occupants) then {occupantsCruiseMissileTimer} else {invadersCruiseMissileTimer};

if(count _supportTimer < _playerAdjustment) then
{
    _timerIndex = count _supportTimer;
    for "_i" from ((count _supportTimer) + 1) to _playerAdjustment do
    {
        _supportTimer pushBack -1;
    };
}
else
{
    _timerIndex = _supportTimer findIf {_x < time};
    if(_playerAdjustment <= _timerIndex) then
    {
        _timerIndex = -1;
    };
};

_timerIndex;

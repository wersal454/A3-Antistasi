params ["_logic", "_unit", "_activated"];

//Only worry about the curators machine
if (!local _logic) exitWith {};

//If we failed we can just leave
if (isNull _unit) exitWith{};

[vehicle _unit] spawn CRAM37_fnc_handleCRAM;
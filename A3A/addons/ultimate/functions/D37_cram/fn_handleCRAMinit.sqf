params ["_logic", "_unit", "_activated"];

//Only worry about the curators machine
if (!local _logic) exitWith {};

//Get our selected unit or fail gracefully
private _unit = [_logic, [
	[{_this isKindOf "AAA_System_01_base_F"}, "INVALID UNIT"]
]] call A3U_fnc_handleCuratorPlacement;

//If we failed we can just leave
if (isNull _unit) exitWith{};

[vehicle _unit] spawn A3U_fnc_handleCRAM;
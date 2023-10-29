#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_typeX"];

private _cost = A3U_blackMarketStock select { _x select 0 == _typeX } select 0 select 1;

_cost = if (isNil "_cost") then {
	Error_1("Invalid vehicle price at %1.", _typeX);

	0
} else {
	private _multiplier = if (count seaports > 0) then {
		{sidesX getVariable [_x,sideUnknown] == teamPlayer} count seaports;
	} else {
		{sidesX getVariable [_x,sideUnknown] == teamPlayer} count resourcesX;
	};

	round (_cost - (_cost * (0.1 * _multiplier)))
};


_cost

#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_hr", "_resourcesFIA"];

waitUntil {!resourcesIsChanging};
resourcesIsChanging = true;
if (isNil "_resourcesFIA") then {Error("_resourceFIA is nil");};
if ((isNil "_hr") or (isNil "_resourcesFIA")) exitWith {resourcesIsChanging = false};
if ((floor _resourcesFIA == 0) and (floor _hr == 0)) exitWith {resourcesIsChanging = false};
private _hrT = server getVariable "hr";
private _resourcesFIAT = server getVariable "resourcesFIA";

_hrT = _hrT + _hr;
_resourcesFIAT = round (_resourcesFIAT + _resourcesFIA);

if (_hrT < 0) then {_hrT = 0};
if (_resourcesFIAT < 0) then {_resourcesFIAT = 0};

switch (tierWar) do
{
	case 1:{if (_hrT > 200) then {_hrT = 200};};
	case 2:{if (_hrT > 300) then {_hrT = 300};};
	case 3:{if (_hrT > 400) then {_hrT = 400};};
	case 4:{if (_hrT > 550) then {_hrT = 550};};
	case 5:{if (_hrT > 700) then {_hrT = 700};};
	case 6:{if (_hrT > 850) then {_hrT = 850};};
	case 7:{if (_hrT > 1000) then {_hrT = 1000};};
	case 8:{if (_hrT > 1200) then {_hrT = 1200};};
	case 9:{if (_hrT > 1400) then {_hrT = 1400};};
	case 10:{if (_hrT > 1600) then {_hrT = 1600};};
	default {diag_log format["[Lose HR on Death] War tier was not recognized. Condition given: %1", tierWar]};
};

server setVariable ["hr",_hrT,true];
server setVariable ["resourcesFIA",_resourcesFIAT,true];
resourcesIsChanging = false;

private _textX = "";
private _hrSim = "";
private _resourcesFIASim = "";
if (_hr > 0) then {_hrSim = "+"};
if (_resourcesFIA > 0) then {_resourcesFIASim = "+"};

switch (true) do {
	case ((_hr != 0) && {_resourcesFIA != 0}): {
		_textX = format [localize "STR_comms_res_FIA_1",_hr,_resourcesFIA,_hrSim,_resourcesFIASim,FactionGet(reb,"name"), A3A_faction_civ get "currencySymbol"];
	};
	case (_hr != 0): {
		_textX = format [localize "STR_comms_res_FIA_2",_hr,_hrSim,FactionGet(reb,"name")];
	};
	case (_resourcesFIA != 5): {
		_textX = format [localize "STR_comms_res_FIA_3",_hr,_resourcesFIA,_hrSim,_resourcesFIASim,FactionGet(reb,"name"), A3A_faction_civ get "currencySymbol"];
	};
};

if (_textX isEqualTo "") exitWith {};
 
[petros,"income",_textX] remoteExec ["A3A_fnc_commsMP",theBoss];

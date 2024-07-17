_unit = param[0];

if(!isServer) exitWith {};
if(is3DEN) exitWith {};
if !(allowCRAMIRONDOME) exitWith {};

private _isInitialized = (_unit getVariable ["cramInit", false]);
if(_isInitialized) exitWith {};
_unit setVariable ["cramInit", true, true];

//Toggle incoming alarm
_unit setVariable ["alarmEnabled", true, true];
_unit addAction ["Toggle alarm", {
	params ["_target", "_caller", "_actionId", "_arguments"];
	_state = !(_target getVariable ["alarmEnabled", true]);
	_target setVariable ["alarmEnabled", _state, true];

	_out = "";
	if(_state) then {
		_out = "ON";
	} else {
		_out = "OFF";
	};

	_id = owner _caller;
	["Alarm state: " + _out] remoteExec ["hint", _id];

}, nil, 9, false, false, "", "!(_this in _target)", 10];

//Change logic
_unit setVariable ["_tgtLogic", 1, true];
_unit addAction ["Change targeting mode", {
	params ["_target", "_caller", "_actionId", "_arguments"];
	_tgtLogic = _target getVariable ["_tgtLogic", 0];

	_tgtLogic = _tgtLogic + 1;
	if(_tgtLogic > 3) then {
		_tgtLogic = 0;
	};

	_out = "";
	switch (_tgtLogic) do {
		case 0: {
			_out = "Random selection";
		};
		case 1: {
			_out = "Distance/Speed bias";
		};
		case 2: {
			_out = "Threat bias";
		};
		default {_out = "No targeting"};
	};

	_id = owner _caller;
	["Logic changed to: " + _out] remoteExec ["hint", _id];

	_target setVariable	["_tgtLogic", _tgtLogic, true];
}, nil, 10, false, false, "", "!(_this in _target)", 10];

{
	_x setSkill 1;
}foreach crew _unit;

/* private _friendlyentities = [];
private _side = side _unit;
addMissionEventHandler ["ArtilleryShellFired", {
	params ["_vehicle", "_weapon", "_ammo", "_gunner", "_instigator", "_artilleryTarget", "_targetPosition", "_shell"];
	if (side _gunner == _side) then {
		_friendlyentities = pushBack _shell;
	};
}]; */ ///untill 2.18 is released

//Performance optimizations
_emptyLoops = 0;
_delay = 0.1;
_unit setVehicleRadar 1;
_wep = currentweapon _unit;

//Main loop
while {alive _unit} do {
	//[2675fa44080# 80: tracer_red.p3d,"air","unknown",["activeradar","datalink"]]
	_list = getSensorTargets _unit;
	_list = _list select {
		typeOf (_x # 0) == "CRAM_Fake_PlaneTGT";
	};
	/* _list = _list select {
		_x !in _friendlyentities;
	}; */ ///untill 2.18 is released
	_entities = [];
	{
		_entities pushback (_x # 0);
	}foreach _list;
	_entities = _entities select {(getPosATL _x # 2) > 10};
	_list = _entities;

	if(count _list > 0) then {
		_delay = 0.05;
		_emptyLoops = 0;
		if(_unit getVariable ["alarmEnabled",false]) then {
			if (!(_unit getVariable ["alarmplaying",false])) then {
				_unit setVariable ["alarmplaying",true,true];
				_unit say3D ["CRAMALARM",1000,1,false,0];
				_unit spawn {
					sleep 10;
					_this setVariable ["alarmplaying",false,true];
				};
			};
		};

		_tgtLogic = _unit getVariable ["_tgtLogic", 1];
		_target = [_list, _unit, _tgtLogic] call A3U_fnc_pickTargetCRAM;
		if(!isNull _target) then {
			_time = time;
			_unit doTarget _target;
			_shell = attachedTo _target;
			
			waitUntil{_unit aimedAtTarget [_target, _wep] > 0.65 or (time - _time) > 1.25};
			for "_i" from 1 to 100 do {
				if(!alive _shell) exitWith {};
				if((_i % 20) == 0) then {
					_unit doTarget _target;
				};
				
				[_unit, _wep, [0]] call BIS_fnc_fire;
				sleep 0.01;
			};
		} else {
			_unit doTarget objNull;
		};
	} else {
		//Lowers the amount of checks per second when nothing is found
		_delay = 0.1;
		_emptyLoops = (_emptyLoops + 1);
		if(_emptyLoops == 50) then {
			_delay = 0.5;
			_unit doTarget objNull;
		};
	};
	sleep _delay;
};

removeallActions _unit;
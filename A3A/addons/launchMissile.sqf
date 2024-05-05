//////////////////////////////////////////////////////////////////
// Function file for Armed Assault
// Created by: Venori
// Tweaks by: kylania, AnimalMother92
// Rebuild by: [W] Lusor
// Testing, Sound [W] Pyro
//////////////////////////////////////////////////////////////////

params ["_player","_uav","_playerArray",  "_missileType", "_missileSpeed"];

_primaryTarget = lasertarget _player; //target for the missile

_laserOn = true;
if (isNull _primarytarget) exitWith {

	"notarget"  remoteExec ["playSound" , _playerArray];
	//_uav sideChat "Negative, that's an invalid target, over.";
};


_missileStart = getPosASL _uav ;//(_arguments select 1); //position where the missile spawns
_missileStart = [_missileStart select 0, (_missileStart select 1) - 10 , (_missileStart select 2) - 30 ];

_primaryTargetPos = getPos _primaryTarget;
_defaultTargetPos = _primaryTargetPos;  //default position where unguided missiles hits


 //getVariables
_miMissionActive = missionNamespace getVariable ["miMissionActive",false];
_miHellFireAvailable = missionNamespace getVariable ["miHellFireAvailable",4];
_miGBUAvailable = missionNamespace getVariable ["miGBUAvailable",2];

_round = "";
_reloadTime = 30;


if (_miMissionActive) exitWith {
	"systemoffline"  remoteExec ["playSound" , _playerArray];
	//_uav sideChat "AGMs are offline.";
};

if (_miHellFireAvailable == 0 && _missileType == "ACE_Hellfire_AGM114N") exitWith { };//_uav sideChat "Hellfires depleted.";
if (_miGBUAvailable == 0 && _missileType == "Bo_GBU12_LGB") exitWith {};//_uav sideChat "GBUs depleted."; };


_miMissionActive = missionNamespace setVariable ["miMissionActive",true,true];

switch (_missileType) do {
	case "ACE_Hellfire_AGM114N": {
		_round = "Hellfire";
		_miHellFireAvailable = _miHellFireAvailable - 1;
		missionNamespace setVariable ["miHellFireAvailable",_miHellFireAvailable, true];
	};
	case "Bo_GBU12_LGB": {
		_round = "GBU";
		_miGBUAvailable = _miGBUAvailable - 1;
		missionNamespace setVariable ["miGBUAvailable",_miGBUAvailable, true];
	};
};

//_uav sideChat "Roger, we have a lock, engaging target.";
"lock"  remoteExec ["playSound" , _playerArray];
//_uav sideChat format["Target locked, %1 inbound.", _round];


sleep 5;

_perSecondChecks = 3; //direction checks per second (reciprocal)
_getPrimaryTarget = {if (typeName _primaryTarget == typename {}) then {call _primaryTarget} else {_primaryTarget}}; //code can be used for laser dots
_target = call _getPrimaryTarget;

_missile = _missileType createVehicle _missileStart;
_missile setPos _missileStart;

//secondary target used for random trajectory when laser designator is turned off prematurely
_secondaryTarget = "HeliHEmpty" createVehicle _defaultTargetPos;
_secondaryTarget setPos _defaultTargetPos;

_guidedRandomly = FALSE;
_laserOff = false;

//procedure for guiding the missile
_homeMissile = {

	//here we switch to secondary target at random position if the laser dot no longer exists
	//if the designator is turned on again, the missile will return to its original target (providing it hadn't flown too far)
	private _dir = direction _missile;
	private _vel = velocity _missile;
	private _velocityX = 	(_vel select 0) + (sin _dir * _missileSpeed);
	private _velocityY = 	(_vel select 1) + (cos _dir * _missileSpeed);
	private _velocityZ =  (_vel select 2);
	private _target = _secondaryTarget;

	if (_laserOff) then {
			"deadeye"  remoteExec ["playSound" , _playerArray];
			_laserOn = false;
			_laserOff = false;
	};

	
	if (!(_guidedRandomly) && _missile distance _target > _missileSpeed * 1.5) then {

		_guidedRandomly = TRUE;
		_target = _secondaryTarget;
		_dispersion = (_missile distance _defaultTargetPos) / 20;
		_dispersionMin = _dispersion / 10;
		_target setPos [(_defaultTargetPos select 0) + _dispersionMin - (_dispersion / 2) + random _dispersion, (_defaultTargetPos select 1) + _dispersionMin - (_dispersion / 2) + random _dispersion, 0];
	};
	if (!(isNull (call _getPrimaryTarget))) then {
		_target = call _getPrimaryTarget;
		_defaultTargetPos = position _target;
		_guidedRandomly = FALSE;
		_laserOn = true;
		 }
	else {
		if(_laserOn) then {
			_laserOff = true;
		};
	};

	//altering the direction, pitch and trajectory of the missile
	if (_missile distance _target > 0.1) then {
		_travelTime = (_target distance _missile) / _missileSpeed;

		_relDirHor = [_missile, _target] call BIS_fnc_DirTo;
		_missile setDir _relDirHor;

		_relDirVer = asin ((((getPosASL _missile) select 2) - ((getPosASL _target) select 2)) / (_target distance _missile));
		_relDirVer = (_relDirVer * -1);
		[_missile, _relDirVer, 0] call BIS_fnc_setPitchBank;

		_velocityX = (((getPosASL _target) select 0) - ((getPosASL _missile) select 0)) / _travelTime;
		_velocityY = (((getPosASL _target) select 1) - ((getPosASL _missile) select 1)) / _travelTime;
		_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _missile) select 2)) / _travelTime;
	};

	[_velocityX, _velocityY, _velocityZ]
};

call _homeMissile;

//fuel burning should illuminate the landscape
_fireLight = "#lightpoint" createVehicle position _missile;
_fireLight setLightBrightness 0.5;
_fireLight setLightAmbient [1.0, 1.0, 1.0];
_fireLight setLightColor [1.0, 1.0, 1.0];
_fireLight lightAttachObject [_missile, [0, -0.5, 0]];

//missile flying
while {alive _missile} do {
	_velocityForCheck = call _homeMissile;

	if ({(typeName (_velocityForCheck select 1)) == (typeName 0)} count _velocityForCheck == 3) then {
		_missile setVelocity _velocityForCheck
	};
	sleep (1 / _perSecondChecks)
};

deleteVehicle _fireLight;
deleteVehicle _secondaryTarget;

if (_miHellFireAvailable == 0 && _round == "Hellfire") then {	"agmwinchester"  remoteExec ["playSound" , _playerArray];};//_uav sideChat "Hellfires depleted.";
if (_miGBUAvailable == 0 && _round == "GBU") then {	"gbuwinchester"  remoteExec ["playSound" , _playerArray];};//_uav sideChat "GBUs depleted.";

sleep _reloadtime;



missionNamespace setVariable ["miMissionActive",false, true];
if(_miHellFireAvailable > 0 || _miGBUAvailable > 0) then {
	"uavready"  remoteExec ["playSound" , _playerArray];
	//_uav sideChat "AGM missile is online, I repeat, AGM missile is online.";
} else {
	"noammo"  remoteExec ["playSound" , _playerArray];
	_grpuav = group _uav;
	if(count waypoints _grpuav>0)then{
	{deleteWaypoint((waypoints _grpuav)select 0);}forEach waypoints _grpuav;};
	sleep 2;
	_exitwp = _grpuav addWaypoint [[0,0,5000], 0];
	_exitwp setWaypointStatements ["true", "deleteVehicle vehicle (leader(group this));"];
	_grpuav setCurrentWaypoint [_grpuav, 2];
	//_uav sideChat "UAV is offline.";
};

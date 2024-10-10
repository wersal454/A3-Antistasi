if(!isServer) exitWith {};

//Prevents multiple overlaps
private _ammoInit = missionNamespace getVariable ["CRAMammoInit", false];
if(_ammoInit) exitWith {};
missionNamespace setVariable ["CRAMammoInit", true, true];

addMissionEventHandler ["ProjectileCreated", {
	params ["_projectile"];
    [_projectile] spawn CRAM37_fnc_initshells;
}];
#include "..\..\..\script_component.hpp"
FIX_LINE_NUMBERS()
if(!isServer) exitWith {};

//Prevents multiple overlaps
private _ammoInit = missionNamespace getVariable ["CRAMammoInit", false];
if(_ammoInit) exitWith {};
missionNamespace setVariable ["CRAMammoInit", true, true];

addMissionEventHandler ["ProjectileCreated", {
	params ["_projectile"];
    _projectile spawn {
        _projectile = _this;
        if((_projectile isKindOf "ShellBase") or (_projectile isKindOf "SubmunitionBase")) then {
            //Create the target
            sleep 2;
            _fake = "CRAM_Fake_PlaneTGT" createVehicle [0,0,0];
            _fake attachTo [_projectile, [0,3,0]];	

            while {alive _projectile} do {
                _entities = (_projectile nearObjects ["BulletBase", 5]);
                _entities append (_projectile nearObjects ["MissileBase", 30]);
                if(count _entities > 0) then {
                    _mine = createMine ["APERSMine", getPosATL _projectile, [], 0];
                    _mine setDamage 1;
                    deletevehicle _projectile;
                };
                sleep 0.04;
            };

            deletevehicle _fake;
        };
    };
}];
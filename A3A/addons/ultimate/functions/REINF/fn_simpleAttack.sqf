params [
    ["_side", Invaders],
    ["_origin", "CSAT_carrier"],
    ["_target", ""],
    ["_pool", "attack"],
    ["_vehCount", 5],
    ["_delay", 5],
    ["_modifiers", ["specops"]]
];

private _data = [
    _side, 
    _origin, 
    _target, 
    _pool, 
    _vehCount, 
    _delay, 
    _modifiers
] call A3A_fnc_createAttackForceMixed;

_data;
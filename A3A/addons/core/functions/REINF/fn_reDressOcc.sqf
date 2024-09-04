params ["_unit"];

_unit forceAddUniform (selectRandom (A3A_faction_occ get "uniforms"));
_unit addItemToUniform "FirstAidKit";
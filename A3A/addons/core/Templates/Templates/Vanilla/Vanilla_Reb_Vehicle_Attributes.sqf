["attributesVehicles", [
    ["I_C_Offroad_02_LMG_F", ["rebCost", 500]],
    ["I_G_Offroad_01_armor_base_lxWS", ["rebCost", 500]],
    ["I_G_Offroad_01_armor_armed_lxWS", ["rebCost", 1100]],
    ["I_G_Offroad_01_armor_AT_lxWS", ["rebCost", 1500]],

    ["a3a_C_Heli_Transport_02_F", ["rebCost", 8000]]
]] call _fnc_saveToTemplate;

if (isClass (configFile >> "CfgPatches" >> "RF_Vehicles")) then {
    (["attributesVehicles"] call _fnc_getFromTemplate) append [
        ["C_Heli_EC_01A_civ_RF", ["rebCost", 8000]],
        ["C_Heli_EC_01_civ_RF", ["rebCost", 8000]],
        ["C_Heli_EC_04_rescue_RF", ["rebCost", 8000]],
        ["C_Pickup_rf", ["rebCost", 250]],
        ["C_Pickup_covered_rf", ["rebCost", 250]]
    ];
};
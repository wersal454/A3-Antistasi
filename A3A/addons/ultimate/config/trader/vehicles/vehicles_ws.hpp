class vehicles_ws : vehicles_base
{
    ITEM(I_A_Truck_02_aa_lxWS, 6200, "AA", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(APC_Wheeled_01_command_base_lxWS, 12720, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(APC_Wheeled_01_atgm_base_lxWS, 32970, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(O_APC_Tracked_02_30mm_lxWS, 32150, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(O_APC_Wheeled_02_hmg_lxWS, 5860, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(I_G_Offroad_01_armor_AT_lxWS, 6650, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(I_G_Offroad_01_armor_armed_lxWS, 4950, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(APC_Wheeled_01_mortar_base_lxWS, 26400, "ARTILLERY", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(B_ION_Heli_Light_02_dynamicLoadout_lxWS, 30200, "HELI", "(call A3U_fnc_sidesX count airportsX >= 1 || call A3U_fnc_sidesX count milbases >= 1) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(B_ION_Heli_Light_02_unarmed_lxWS, 11000, "HELI", "(call A3U_fnc_sidesX count airportsX >= 1 || call A3U_fnc_sidesX count milbases >= 1) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(I_Tura_ZU23_lxWS, 5000, "STATICAA", "tierWar >= 3 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(O_APC_Wheeled_02_unarmed_lxWS, 1740, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(I_G_Offroad_01_armor_base_lxWS, 1280, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(I_Truck_02_cargo_lxWS, 1700, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(I_Truck_02_flatbed_lxWS, 1700, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(C_Offroad_lxWS, 1280, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
};

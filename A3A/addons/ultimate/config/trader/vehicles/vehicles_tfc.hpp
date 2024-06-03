class vehicles_tfc : vehicles_base
{
    ITEM(TFC_Wheeled_Bison_Amb, 6400, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TFC_Wheeled_Bison_CP, 2560, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(tfc_wheeled_lav6_isc, 23720, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(tfc_wheeled_lav6_lrss, 28240, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(tfc_vs_luvw_armed_f, 2800, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(tfc_mrzr4_d_tow, 14100, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(tfc_tapv_gmg, 18100, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TFC_BGM_71_Tripod, 9000, "STATICAT", "tierWar >= 3 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(tfc_ws_c16_gmg, 6000, "STATICMG", "tierWar >= 3 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(TFC_MBT_Leopard2A4M_F, 44900, "TANK", "call A3U_fnc_sidesX count milbases >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(tfc_vs_luvw_f, 960, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
};

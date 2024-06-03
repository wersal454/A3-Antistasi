class vehicles_braf : vehicles_base
{
    ITEM(braf_guarani_eb_remax, 10740, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(BRAF_AM11_Armed, 2200, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(BRAF_LMV_EB_RCWS, 9800, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(BRAF_EE9_Cascavel_EB, 28500, "TANK", "call A3U_fnc_sidesX count milbases >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(BRAF_AM11_Unarmed, 850, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
    ITEM(BRAF_LMV_EB, 1080, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
};

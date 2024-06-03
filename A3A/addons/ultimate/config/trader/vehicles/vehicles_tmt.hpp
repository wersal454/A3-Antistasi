class vehicles_tmt : vehicles_base
{
    ITEM(TMT_Landrover_w_AA, 41000, "AA", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_ACV300_W_Amb, 6320, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_ACV300_W_M2, 5940, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_KirpiII_MRAP_W, 13300, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_Cobra_RCWS_W, 9550, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_Ejder_RCWS_GEN, 12550, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_Arma_GMG_HMG, 18850, "ARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_T155_W, 55800, "ARTILLERY", "call A3U_fnc_sidesX count resourcesX >= 3 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_LEO2A4_w, 37100, "TANK", "call A3U_fnc_sidesX count milbases >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(TMT_Leopard2_NG_W, 46900, "TANK", "call A3U_fnc_sidesX count milbases >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(TMT_BayraktarTB2, 23000, "UAV", "call A3U_fnc_sidesX count airportsX >= 1 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(TMT_Kirpi_MRAP_GEN, 2040, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
};

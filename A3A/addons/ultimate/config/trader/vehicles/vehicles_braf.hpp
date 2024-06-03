class vehicles_braf : vehicles_base
{
    ITEM(braf_guarani_eb_remax, 10740, "APC", "([""seaports_1""] call A3U_fnc_hasRequirements || [""resources_3""] call A3U_fnc_hasRequirements) && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(BRAF_AM11_Armed, 2200, "ARMEDCAR", "[""resources_3""] call A3U_fnc_hasRequirements && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(BRAF_LMV_EB_RCWS, 9800, "ARMEDCAR", "[""resources_3""] call A3U_fnc_hasRequirements && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(BRAF_EE9_Cascavel_EB, 28500, "TANK", "[""milbases_1""] call A3U_fnc_hasRequirements && [""factories_5""] call A3U_fnc_hasRequirements");
    ITEM(BRAF_AM11_Unarmed, 850, "UNARMEDCAR", "[""resources_1""] call A3U_fnc_hasRequirements && [""factories_1""] call A3U_fnc_hasRequirements");
    ITEM(BRAF_LMV_EB, 1080, "UNARMEDCAR", "[""resources_1""] call A3U_fnc_hasRequirements && [""factories_1""] call A3U_fnc_hasRequirements");
};

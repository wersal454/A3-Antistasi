class vehicles_aegis : vehicles_base
{
    ITEM(O_R_APC_Wheeled_04_cannon_F, 31310, "APC", "([""seaports_1""] call A3U_fnc_hasRequirements || [""resources_3""] call A3U_fnc_hasRequirements) && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(C_Boat_Civil_02_F, 1700, "BOAT", "[""seaports_1""] call A3U_fnc_hasRequirements");
    ITEM(Aegis_I_EAF_Heli_Attack_04_F, 8, "HELI", "([""airports_1""] call A3U_fnc_hasRequirements || [""milbases_1""] call A3U_fnc_hasRequirements) && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(Aegis_I_Heli_Transport_02_Heavy_F, 12000, "HELI", "([""airports_1""] call A3U_fnc_hasRequirements || [""milbases_1""] call A3U_fnc_hasRequirements) && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(Aegis_C_Heli_Transport_02_VIP_F, 10800, "HELI", "([""airports_1""] call A3U_fnc_hasRequirements || [""milbases_1""] call A3U_fnc_hasRequirements) && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(B_Plane_Fighter_05_F, 92550, "PLANE", "[""airports_1""] call A3U_fnc_hasRequirements && [""factories_5""] call A3U_fnc_hasRequirements");
    ITEM(B_Plane_Fighter_05_Stealth_F, 78900, "PLANE", "[""airports_1""] call A3U_fnc_hasRequirements && [""factories_5""] call A3U_fnc_hasRequirements");
    ITEM(I_Plane_Transport_01_infantry_F, 45000, "PLANE", "[""airports_1""] call A3U_fnc_hasRequirements && [""factories_5""] call A3U_fnc_hasRequirements");
    ITEM(I_Plane_Transport_01_vehicle_F, 28500, "PLANE", "[""airports_1""] call A3U_fnc_hasRequirements && [""factories_5""] call A3U_fnc_hasRequirements");
    ITEM(I_UGV_01_medical_F, 14600, "UAV", "[""airports_1""] call A3U_fnc_hasRequirements && [""factories_3""] call A3U_fnc_hasRequirements");
    ITEM(B_W_APC_Wheeled_01_medical_F, 6960, "UNARMEDCAR", "[""resources_1""] call A3U_fnc_hasRequirements && [""factories_1""] call A3U_fnc_hasRequirements");
};

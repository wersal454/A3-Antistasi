class vehicles_aegis : vehicles_base
{
    ITEM(O_R_APC_Wheeled_04_cannon_F, 31310, "APC", "(call A3U_fnc_sidesX count seaports >= 1 || call A3U_fnc_sidesX count resourcesX >= 3) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(C_Boat_Civil_02_F, 1700, "BOAT", "call A3U_fnc_sidesX count seaports >= 1");
    ITEM(Aegis_I_EAF_Heli_Attack_04_F, 8, "HELI", "(call A3U_fnc_sidesX count airportsX >= 1 || call A3U_fnc_sidesX count milbases >= 1) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(Aegis_I_Heli_Transport_02_Heavy_F, 12000, "HELI", "(call A3U_fnc_sidesX count airportsX >= 1 || call A3U_fnc_sidesX count milbases >= 1) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(Aegis_C_Heli_Transport_02_VIP_F, 10800, "HELI", "(call A3U_fnc_sidesX count airportsX >= 1 || call A3U_fnc_sidesX count milbases >= 1) && call A3U_fnc_sidesX count factories >= 3");
    ITEM(B_Plane_Fighter_05_F, 92550, "PLANE", "call A3U_fnc_sidesX count airportsX >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(B_Plane_Fighter_05_Stealth_F, 78900, "PLANE", "call A3U_fnc_sidesX count airportsX >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(I_Plane_Transport_01_infantry_F, 45000, "PLANE", "call A3U_fnc_sidesX count airportsX >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(I_Plane_Transport_01_vehicle_F, 28500, "PLANE", "call A3U_fnc_sidesX count airportsX >= 1 && call A3U_fnc_sidesX count factories >= 5");
    ITEM(I_UGV_01_medical_F, 14600, "UAV", "call A3U_fnc_sidesX count airportsX >= 1 && call A3U_fnc_sidesX count factories >= 3");
    ITEM(B_W_APC_Wheeled_01_medical_F, 6960, "UNARMEDCAR", "call A3U_fnc_sidesX count resourcesX >= 1 && call A3U_fnc_sidesX count factories >= 1");
};

#include "..\script_component.hpp"

class CfgPatches 
{
    class ultimate_d37
    {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {ADDON};
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
    };
};

#include "CfgSounds.hpp" 
#include "CfgVehicles.hpp"

class cfgWeapons
{
    class ItemRadio;

    class LauncherCore;
	class MissileLauncher: LauncherCore {};
	class weapon_rim116Launcher: MissileLauncher {
		magazines[] += {"magazine_Missile_dome_x21"};
	};
};

class cfgAmmo 
{
	class MissileCore;
	class MissileBase: MissileCore {};
	class ammo_Missile_ShortRangeAABase: MissileBase {};
	class ammo_Missile_rim116: ammo_Missile_ShortRangeAABase {};

	class ammo_Missile_dome: ammo_Missile_rim116 {
		thrust = 40;
		thrustTime = 34;
		timeToLive = 34;
	};
};

class cfgMagazines 
{
	class CA_Magazine;
	class VehicleMagazine: CA_Magazine {};
	class magazine_Missile_rim116_x21: VehicleMagazine {};

	class magazine_Missile_dome_x21: magazine_Missile_rim116_x21 {
		ammo = "ammo_Missile_dome";
	};
};

#include "CfgSounds.hpp" 
#include "CfgVehicles.hpp"
#include "\x\A3A\addons\ultimate\script_component.hpp"
class CfgPatches 
{
    class ADDON 
    {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {"TFAR_SCR536"};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"A3A_Events"};
        author = AUTHOR;
        authors[] = { AUTHORS };
        authorUrl = "";
        VERSION_CONFIG;
    };
    class D37_cram
    {
        units[] = {"CRAM_Fake_PlaneTGT"};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"A3_Static_F_Jets_AAA_System_01"};
    };
    class D37_dome
    {
        units[] = {"B_SAM_System_01_F_DOME"};
		weapons[] = {"B_SAM_System_01_F_DOME"};
		requiredVersion = 0.1;
		requiredAddons[] = {"A3_Static_F_Jets_SAM_System_01","A3_Static_F_Jets_SAM_System_02"};
    };
};

class cfgWeapons
{
    class ItemRadio;
    //#include "patches\cfgWeapons.hpp"

    class LauncherCore;
	  class MissileLauncher: LauncherCore {};
	  class weapon_rim116Launcher: MissileLauncher {
		magazines[] += {"magazine_Missile_dome_x21"};
	  };
};

//["SAM_System_01_base_F","StaticMGWeapon","StaticWeapon","LandVehicle","Land","AllVehicles","All"]

//["ammo_Missile_ShortRangeAABase","MissileBase","MissileCore","Default"]
class cfgAmmo {
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

//["VehicleMagazine","CA_Magazine","Default"]
class cfgMagazines {
	class CA_Magazine;
	class VehicleMagazine: CA_Magazine {};
	class magazine_Missile_rim116_x21: VehicleMagazine {};

	class magazine_Missile_dome_x21: magazine_Missile_rim116_x21 {
		ammo = "ammo_Missile_dome";
	};	
};

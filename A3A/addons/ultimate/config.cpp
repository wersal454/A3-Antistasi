#include "script_component.hpp"

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

#include "CfgFunctions.hpp"

class cfgWeapons
{
    class ItemRadio;
    #include "patches\cfgWeapons.hpp"

    class LauncherCore;
	class MissileLauncher: LauncherCore {};
	class weapon_rim116Launcher: MissileLauncher {
		magazines[] += {"magazine_Missile_dome_x21"};
	};
};

class cfgVehicles
{
    class Item_Base_F;
    class Thing;
    #include "patches\cfgVehicles.hpp"

    //B_AAA_System_01_F
	//["AAA_System_01_base_F","StaticMGWeapon","StaticWeapon","LandVehicle","Land","AllVehicles","All"]

	//["Plane_Fighter_01_Base_F","Plane_Base_F","Plane","Air","AllVehicles","All"]
	

    class AllVehicles;
	class Land: AllVehicles {};
	class LandVehicle: Land {};
	class StaticWeapon: LandVehicle {};
	class StaticMGWeapon: StaticWeapon {};
    class AAA_System_01_base_F: StaticMGWeapon{
		class EventHandlers;

		class Turrets {
			class MainTurret;
		};
	};

    class B_AAA_System_01_F:AAA_System_01_base_F {
		class EventHandlers: EventHandlers {
			class CRAM37 {
				init = "[_this select 0, 2800, 2] spawn A3U_fnc_handleCRAM;";
			};
		};

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				magazines[] = {"magazine_Cannon_Phalanx_x1550","magazine_Cannon_Phalanx_x1550","magazine_Cannon_Phalanx_x1550"};
			};
		};
	};
	class SAM_System_01_base_F: StaticMGWeapon{
		class EventHandlers;
		class Turrets {
			class MainTurret;
		};
	};

	class B_SAM_System_01_F: SAM_System_01_base_F {
		class EventHandlers: EventHandlers {
			class DOME37 {
				init = "[_this select 0, 4400, 1] spawn A3U_fnc_handleDome;";
			};
		};
	};

    class B_SAM_System_01_F_DOME: B_SAM_System_01_F {
        displayName = "Iron Dome";
        class EventHandlers: EventHandlers {
			class DOME37 {
				init = "[_this select 0, 4400, 1, [420/3.6, 0, 4, false, 14, 1]] spawn A3U_fnc_handleDome;";
			};
		};

        class Turrets: Turrets {
            class MainTurret: MainTurret {
                initElev = 89;
                maxelev = 90;
                minelev = 89;

				magazines[] = {"magazine_Missile_dome_x21"};
            };
        };
    };

	class SAM_System_03_base_F:StaticMGWeapon {
		class EventHandlers;
	};
	class B_SAM_System_03_F: SAM_System_03_base_F {
		class EventHandlers: EventHandlers {
			class DOME37 {
				init = "[_this select 0, 7500, 1, [1100/3.6, 0, 4, true, 30, 3]] spawn A3U_fnc_handleDome;";
			};
		};
	};

	class SAM_System_04_base_F:StaticMGWeapon {
		class EventHandlers;
	};
	class O_SAM_System_04_F: SAM_System_04_base_F {
		class EventHandlers: EventHandlers {
			class DOME37 {
				init = "[_this select 0, 7500, 1, [1100/3.6, 0, 4, true, 30, 3]] spawn A3U_fnc_handleDome;";
			};
		};
	};

	class SAM_System_02_base_F: StaticMGWeapon {
		class EventHandlers;
	};
	class B_SAM_System_02_F: SAM_System_02_base_F {
		class EventHandlers: EventHandlers {
			class DOME37 {
				init = "[_this select 0, 4500, 1, [800/3.6, 0, 3, true, 15, 4]] spawn A3U_fnc_handleDome;";
			};
		};
	};

    class Air: AllVehicles {};
	class Plane: Air {};
	class Plane_Base_F: Plane {};
	class Plane_Fighter_01_Base_F: Plane_Base_F {};
	class B_Plane_Fighter_01_F: Plane_Fighter_01_Base_F {
		class EventHandlers {};
	};

	class CRAM_Fake_PlaneTGT: B_Plane_Fighter_01_F {
		//model = "\A3\Structures_F\Mil\Helipads\HelipadEmpty_F.p3d";
		class EventHandlers: EventHandlers {
			init = "(_this select 0) hideObjectGlobal true;";
		};
		scope = 1;
	};
};

class RscBackPicture;
class RscEditLCD;
class HiddenButton;
class HiddenRotator;
class HiddenFlip;

/* #Mosecu
$[
	1.063,
	["ree",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,0,0],
	[-1200,"background: RscBackPicture",[1,"x\A3A\addons\ultimate\patches\data\radio_co.paa",["0.123594 * safezoneW + safezoneX","0.00499991 * safezoneH + safezoneY","0.252656 * safezoneW","0.781 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[-1201,"image: RscBackPicture",[1,"x\A3A\addons\ultimate\patches\data\radio_paper_background_ca.paa",["0.304062 * safezoneW + safezoneX","0.225 * safezoneH + safezoneY","0.175313 * safezoneW","0.154 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","-1"],[]],
	[1002,"enter: HiddenButton",[1,"",["0.438125 * safezoneW + safezoneX","0.346 * safezoneH + safezoneY","0.020625 * safezoneW","0.022 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Set frequency","-1"],["idc = 100300;","onButtonClick = |[((ctrlParent (_this select 0))) displayCtrl 100500] call TFAR_handhelds_fnc_onButtonClick_Enter;|;","action = ||;"]],
	[1003,"clear: HiddenButton",[1,"",["0.324687 * safezoneW + safezoneX","0.335 * safezoneH + safezoneY","0.0309375 * safezoneW","0.022 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Clear frequency","-1"],["idc = 100400;","action = |ctrlSetText [100500,^^]; ctrlSetFocus ((findDisplay 100400) displayCtrl 100500);|;"]],
	[1004,"edit: RscEditLCD",[1,"",["0.365937 * safezoneW + safezoneX","0.236 * safezoneH + safezoneY","0.0928125 * safezoneW","0.044 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Current frequency","-1"],["idc = 100500;","canModify = 1;","onKeyUp = |if (_this select 1 in [28,156]) then { [((ctrlParent (_this select 0))) displayCtrl 100500] call TFAR_handhelds_fnc_onButtonClick_Enter; };|;"]],
	[1005,"channel_edit: RscEditLCD",[1,"",["0.407187 * safezoneW + safezoneX","0.28 * safezoneH + safezoneY","0.061875 * safezoneW","0.044 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Current channel","-1"],["idc = 100600;","canModify = 0;"]],
	[1006,"channel_up: HiddenButton",[1,"",["0.396875 * safezoneW + safezoneX","0.335 * safezoneH + safezoneY","0.020625 * safezoneW","0.022 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Next channel","-1"],["idc = 100700;","action = |[1, false] call TFAR_fnc_setChannelViaDialog;|;"]],
	[1007,"channel_down: HiddenButton",[1,"",["0.371094 * safezoneW + safezoneX","0.346 * safezoneH + safezoneY","0.020625 * safezoneW","0.022 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Previous channel","-1"],["idc = 100800;","action = |[0, false] call TFAR_fnc_setChannelViaDialog;|;"]]
]
*/

class scr536_radio_dialog
{
	idd=100000;
	movingEnable=1;
	controlsBackground[]={};
	objects[]={};
	onUnload="['OnRadioOpen', [player, TF_sw_dialog_radio, false, 'scr536_radio_dialog', false]] call TFAR_fnc_fireEventHandlers;";
	// onLoad="if (sunOrMoon < 0.2) then { ((_this select 0) displayCtrl 67676) ctrlSetText '\z\tfar\addons\handhelds\fadak\ui\fadak_n.paa';};";
	controls[]=
	{
		"background",
        "image",
        "enter",
        "clear",
        "edit",
        // "channel_edit",
        "channel_up",
        "channel_down"
	};
    class background: RscBackPicture
    {
        idc = 100100;
        text = "x\A3A\addons\ultimate\patches\data\radio_ca.paa";
        moving = 1;
        x = 0.0978125 * safezoneW + safezoneX;
        y = -0.00599999 * safezoneH + safezoneY;
        w = 0.252656 * safezoneW;
        h = 0.891 * safezoneH;
    };
    class image: RscBackPicture
    {
        idc = 100200;
        text = "x\A3A\addons\ultimate\patches\data\radio_paper_background_ca.paa";
        moving = 1;
        x = 0.304062 * safezoneW + safezoneX;
        y = 0.225 * safezoneH + safezoneY;
        w = 0.175313 * safezoneW;
        h = 0.154 * safezoneH;
    };
    class edit: RscEditLCD
    {
        idc = 100500;
        canModify = 1;
        onKeyUp = "if (_this select 1 in [28,156]) then { [((ctrlParent (_this select 0))) displayCtrl 100500] call TFAR_handhelds_fnc_onButtonClick_Enter; };";

        x = 0.365937 * safezoneW + safezoneX;
        y = 0.247 * safezoneH + safezoneY;
        w = 0.0979687 * safezoneW;
        h = 0.033 * safezoneH;
        tooltip = "Current frequency";
    };
    // class channel_edit: RscEditLCD
    // {
    //     idc = 100600;
    //     canModify = 0;

    //     x = 0.407187 * safezoneW + safezoneX;
    //     y = 0.291 * safezoneH + safezoneY;
    //     w = 0.061875 * safezoneW;
    //     h = 0.033 * safezoneH;
    //     tooltip = "Current channel";
    // };
    class enter: HiddenButton
    {
        idc = 100300;
        onButtonClick = "[((ctrlParent (_this select 0))) displayCtrl 100500] call TFAR_handhelds_fnc_onButtonClick_Enter;";
        action = "";

        x = 0.438125 * safezoneW + safezoneX;
        y = 0.335 * safezoneH + safezoneY;
        w = 0.020625 * safezoneW;
        h = 0.022 * safezoneH;
        tooltip = "Set frequency";
    };
    class clear: HiddenButton
    {
        idc = 100400;
        action = "ctrlSetText [100500,'']; ctrlSetFocus ((findDisplay 100400) displayCtrl 100500);";

        x = 0.324687 * safezoneW + safezoneX;
        y = 0.335 * safezoneH + safezoneY;
        w = 0.0309375 * safezoneW;
        h = 0.022 * safezoneH;
        tooltip = "Clear frequency";
    };
    class channel_up: HiddenButton
    {
        idc = 100700;
        action = "[1, false] call TFAR_fnc_setChannelViaDialog;";

        x = 0.396875 * safezoneW + safezoneX;
        y = 0.335 * safezoneH + safezoneY;
        w = 0.020625 * safezoneW;
        h = 0.022 * safezoneH;
        tooltip = "Next channel";
    };
    class channel_down: HiddenButton
    {
        idc = 100800;
        action = "[0, false] call TFAR_fnc_setChannelViaDialog;";

        x = 0.371094 * safezoneW + safezoneX;
        y = 0.335 * safezoneH + safezoneY;
        w = 0.020625 * safezoneW;
        h = 0.022 * safezoneH;
        tooltip = "Previous channel";
    };
};

// to-do: move the radio stuff into a seperate folder inside patches, let arma load it as its own addon

class A3U
{
    #include "config\plane\cfgPlaneLoadouts.hpp"
    #include "config\cfgForbiddenItems.hpp"
    #include "config\trader\cfgTraderMods.hpp"
};

class Extended_PreInit_EventHandlers 
{
    class A3U_init
	{
        init = "call A3U_fnc_init";
    };
};
class CfgSounds
{
	class CRAMALARM
	{
		name = "CRAM_Alarm";
		sound[] = {"D37_cram\Sound\CRAM_ALARM.ogg", 1.0, 1.0};
		titles[] = {0, ""};
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

//weapons[] = {"weapon_rim116Launcher"};
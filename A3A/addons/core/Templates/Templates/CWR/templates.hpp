    // ***************************** CUP *****************************

    class CWR_Base
    {
        requiredAddons[] = {"CUP_Creatures_People_Civil_Russia", "CUP_BaseConfigs", "CUP_AirVehicles_Core", "cwr3_weapons"};        // units, weapons, vehicles
        //requiredAddons[] = {"CUP_AirVehicles_Core"};        // vehicles requires units & weapons
        basepath = QPATHTOFOLDER(Templates\Templates\CWR);
        logo = QPATHTOFOLDER(Templates\Templates\CWR\CWR_logo.paa);
        priority = 65;
    };

    class CWR_USArmy_Temperate : CWR_Base
    {
        side = "Occ";
        flagTexture = "a3\data_f\flags\flag_us_co.paa";
        name = "CWR US Army";
        file = "CWR_AI_US_Army_Temperate";
		climate[] = {"temperate","tropical","arctic"};
    };
	
    class CWR_USArmy_Arid : CWR_USArmy_Temperate
    {
        name = "CWR US Army";
        file = "CWR_AI_US_Army_Arid";
		climate[] = {"arid"};
    };

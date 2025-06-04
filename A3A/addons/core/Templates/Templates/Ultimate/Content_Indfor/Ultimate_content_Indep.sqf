if (_hasMarksman || _hasArtOfWar || _hasTanks || _hasJets || _hasHelicopters || _hasLawsOfWar || _hasApex || _hasContact || _hasWs || _hasRF) then {
	#include "Vanilla_content.sqf";

    if (_hasApex) then {
        #include "DLC\Apex_content.sqf";
    };
    if (_hasContact) then {
        #include "DLC\Contact_content.sqf";
    };

    if (_hasWs) then {
        #include "DLC\WS_content.sqf";
    };
    if (_hasRF) then {
        #include "DLC\RF_content.sqf";
    };
};

if (_hasCSLA) then {
    #include "DLC\CSLA_content.sqf";
};

if (_hasSOG) then {
    #include "DLC\SOG_content.sqf";
    if (isClass (configFile >> "cfgVehicles" >> "vnx_b_air_ac119_02_01")) then {
	    #include "..\MOD_content\Nickelsteel\gear\Vanilla_FIA.sqf"
    };
};

if (_hasSPE) then {
    #include "DLC\SPE_content.sqf";
};

if (_hasGM) then {
    #include "DLC\GM_content.sqf";
};

if (isClass (configFile >> "cfgVehicles" >> "OPTRE_M494")) then {
	#include "OPTRE_content.sqf";
};

/* if (isClass (configFile >> "cfgVehicles" >> "SPEX_M2_60")) then {
	#include "..\MOD_content\SPEX\vehicles\Vanilla_AAF.sqf"
};

//If CUP
if (isClass (configFile >> "cfgVehicles" >> "CUP_ZSU23_Base")) then {
    #include "..\MOD_content\CUP\Vanilla_AAF\Vehicles_AAF.sqf"
}; */
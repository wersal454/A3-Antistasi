if (_hasMarksman || _hasArtOfWar || _hasTanks || _hasJets || _hasHelicopters || _hasLawsOfWar || _hasApex || _hasContact || _hasWs || _hasRF || _hasEF) then {
	#include "Vanilla_content.sqf";

    if (_hasApex) then {
        #include "Apex_content.sqf";
    };
    if (_hasContact) then {
        #include "Contact_content.sqf";
    };

    if (_hasWs) then {
        #include "WS_content.sqf";
    };
    if (_hasRF) then {
        #include "RF_content.sqf";
    };
    if (_hasEF) then {
        #include "EF_content.sqf";
    };
};

if (_hasCSLA) then {
    #include "CSLA_content.sqf";
};

if (_hasSOG) then {
    #include "SOG_content.sqf";
};

if (_hasSPE) then {
    #include "SPE_content.sqf";
};

if (_hasGM) then {
    #include "GM_content.sqf";
};

if (isClass (configFile >> "cfgVehicles" >> "OPTRE_M494")) then {
	#include "OPTRE_content.sqf";
    if (isClass (configFile >> "cfgVehicles" >> "OPTRE_FC_Spectre_AA")) then {
        #include "OPTRE_FC_content.sqf";
    };
};

/* if (isClass (configFile >> "cfgVehicles" >> "SPEX_M2_60")) then {
	#include "..\MOD_content\SPEX\vehicles\Vanilla_AAF.sqf"
};

//If CUP
if (isClass (configFile >> "cfgVehicles" >> "CUP_ZSU23_Base")) then {
    #include "..\MOD_content\CUP\Vanilla_AAF\Vehicles_AAF.sqf"
}; */
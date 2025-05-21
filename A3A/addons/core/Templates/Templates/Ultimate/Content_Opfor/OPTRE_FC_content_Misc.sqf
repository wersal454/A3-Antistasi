(_crewLoadoutData get "uniforms") append ["OPTRE_U_Jackal_uniform"];
(_crewLoadoutData get "vests") append ["OPTRE_V_Jackal_vest","OPTRE_V_Jackal_gold_vest","OPTRE_V_Jackal_red_vest"];
(_crewLoadoutData get "helmets") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];

(_pilotLoadoutData get "uniforms") append ["OPTRE_U_Jackal_uniform"];
(_pilotLoadoutData get "vests") append ["OPTRE_V_Jackal_vest","OPTRE_V_Jackal_gold_vest","OPTRE_V_Jackal_red_vest"];
(_pilotLoadoutData get "helmets") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];

(_policeLoadoutData get "uniforms") append ["OPTRE_U_Jackal_uniform"];
(_policeLoadoutData get "vests") append ["OPTRE_V_Jackal_vest","OPTRE_V_Jackal_gold_vest","OPTRE_V_Jackal_red_vest"];
(_policeLoadoutData get "helmets") append ["OPTRE_FC_Jackal_SO_Headgear","OPTRE_FC_Jackal_T_Headgear"];

(_policeLoadoutData get "SMGs") append [
	["OPTRE_FC_Jackal_Shield", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "3OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_Jackal_Orange_Shield", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "3OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_Jackal_Red_Shield", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "3OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_Jackal_Shield_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],
	["OPTRE_FC_Jackal_Orange_Shield_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""],
	["OPTRE_FC_Jackal_Red_Shield_Needler", "", "", "", ["OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag", "OPTRE_FC_Needler_Mag"], [], ""]
];
(_policeLoadoutData get "sidearms") append [
	["OPTRE_FC_Plasma_Pistol", "", "", "", ["OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery", "OPTRE_FC_Plasma_Pistol_Battery"], [], ""],
	["OPTRE_FC_T25_Rifle_Folded", "", "", "", ["OPTRE_FC_T25_Rifle_Battery", "OPTRE_FC_T25_Rifle_Battery", "OPTRE_FC_T25_Rifle_Battery"], [], ""],
	["OPTRE_FC_T25J_Rifle_Folded", "", "", "", ["OPTRE_FC_T25J_Rifle_Battery", "OPTRE_FC_T25J_Rifle_Battery", "OPTRE_FC_T25J_Rifle_Battery"], [], ""]
];


if (isClass (configFile >> "cfgVehicles" >> "MAR_Grunt_Major_Boomstick")) then {
	(_policeLoadoutData get "sidearms") append [
		["MAR_B_Disruptor", "", "", "", ["MAR_Disruptor_Mag", "MAR_Disruptor_Mag", "MAR_Disruptor_Mag"], [], ""],
		["MAR_Brute_Mangler", "", "", "", ["MAR_Mangler_Mag", "MAR_Mangler_Mag", "MAR_Mangler_Mag"], [], ""],
		["MAR_Brute_Spiker", "", "", "", ["MAR_Spiker_Mag", "MAR_Spiker_Mag", "MAR_Spiker_Mag"], [], ""]
	];
};
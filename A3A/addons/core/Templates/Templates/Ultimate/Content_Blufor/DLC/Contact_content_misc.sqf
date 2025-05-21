(_crewLoadoutData get "uniforms") append ["U_I_E_Uniform_01_tanktop_F","U_B_CombatUniform_tshirt_mcam_wdL_f"];
(_crewLoadoutData get "vests") append ["V_CarrierRigKBT_01_Olive_F","V_CarrierRigKBT_01_EAF_F"];
(_crewLoadoutData get "helmets") append ["H_Tank_eaf_F","H_HelmetCrew_I_E"];

(_pilotLoadoutData get "uniforms") append ["U_I_E_Uniform_01_coveralls_F"];
(_pilotLoadoutData get "vests") append ["V_CarrierRigKBT_01_Olive_F","V_CarrierRigKBT_01_EAF_F"];
(_pilotLoadoutData get "helmets") append ["H_CrewHelmetHeli_I_E","H_PilotHelmetHeli_I_E","H_PilotHelmetFighter_I_E"];

//(_policeLoadoutData get "uniforms") append [];
//(_policeLoadoutData get "vests") append [];
//(_policeLoadoutData get "helmets") append [];

(_policeLoadoutData get "SMGs") append [
	["sgun_HunterShotgun_01_F", "", "", "", ["2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug", "2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug"], [], ""],
	["sgun_HunterShotgun_01_sawedoff_F", "", "", "", ["2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug", "2Rnd_12Gauge_Pellets", "2Rnd_12Gauge_Slug"], [], ""]
];
//(_policeLoadoutData get "sidearms") append [];
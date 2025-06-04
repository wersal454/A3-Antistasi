(_crewLoadoutData get "uniforms") append ["U_B_CombatUniform_mcam", "U_B_CombatUniform_mcam_tshirt","U_I_CombatUniform", "U_I_CombatUniform_shortsleeve", "U_Tank_green_F"];
(_crewLoadoutData get "vests") append ["V_Chestrig_rgr","V_BandollierB_oli"];
(_crewLoadoutData get "helmets") append ["H_HelmetCrew_B","H_HelmetCrew_I"];

(_pilotLoadoutData get "uniforms") append ["U_I_HeliPilotCoveralls","U_B_HeliPilotCoveralls","U_I_pilotCoveralls", "U_B_PilotCoveralls"];
(_pilotLoadoutData get "vests") append ["V_TacVest_blk","V_TacVest_oli","V_TacVestIR_blk"];
(_pilotLoadoutData get "helmets") append ["H_CrewHelmetHeli_I", "H_CrewHelmetHeli_B","H_PilotHelmetHeli_I", "H_PilotHelmetHeli_B","H_PilotHelmetFighter_I","H_PilotHelmetFighter_B"];

(_policeLoadoutData get "uniforms") append ["U_Marshal"];
(_policeLoadoutData get "vests") append ["V_TacVestIR_blk","V_BandollierB_blk","V_TacVest_blk","V_TacVest_blk_POLICE"];

(_policeLoadoutData get "helmets") append ["H_Beret_blk","H_Cap_police","H_MilCap_blue","H_PASGT_basic_black_F","H_PASGT_basic_blue_F","H_HeadSet_black_F"];
(_policeLoadoutData get "SMGs") append [
	["SMG_01_F", "", "acc_flashlight_smg_01", "optic_Aco_smg", ["30Rnd_45ACP_Mag_SMG_01", "30Rnd_45ACP_Mag_SMG_01", "30Rnd_45ACP_Mag_SMG_01_Tracer_Red"], [], ""],
["SMG_03_camo", "", "", "", ["50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03"], [], ""],
["SMG_03C_camo", "", "", "", ["50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03"], [], ""],
["SMG_03_TR_camo", "", "acc_flashlight", "optic_Aco_smg", ["50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03"], [], ""],
["SMG_03C_TR_camo", "", "acc_flashlight", "optic_Aco_smg", ["50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03"], [], ""],
["SMG_03C_TR_camo", "", "acc_flashlight", "optic_Aco_smg", ["50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03","50Rnd_570x28_SMG_03"], [], ""],
["SMG_02_F", "", "acc_flashlight", "optic_Aco_smg", ["30Rnd_9x21_Mag_SMG_02", "30Rnd_9x21_Mag_SMG_02", "30Rnd_9x21_Mag_SMG_02_Tracer_Red"], [], ""]
];
(_policeLoadoutData get "sidearms") append [
	["hgun_Rook40_F", "", "", "", ["16Rnd_9x21_Mag", "16Rnd_9x21_Mag"], [], ""]
];
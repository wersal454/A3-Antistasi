(_crewLoadoutData get "uniforms") append ["U_O_SpecopsUniform_ocamo","U_O_CombatUniform_ocamo"];
(_crewLoadoutData get "vests") append ["V_TacVest_khk","V_TacVest_brn","V_TacVest_blk","V_TacVestIR_blk","V_HarnessO_brn"];
(_crewLoadoutData get "helmets") append ["H_HelmetCrew_O","H_Tank_black_F"];

(_pilotLoadoutData get "uniforms") append ["U_O_PilotCoveralls"];
(_pilotLoadoutData get "vests") append ["V_TacVest_khk","V_TacVest_brn","V_TacVest_blk","V_TacVestIR_blk"];
(_pilotLoadoutData get "helmets") append ["H_CrewHelmetHeli_O","H_PilotHelmetHeli_O","H_PilotHelmetFighter_O"];

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
(_crewLoadoutData get "vests") append ["V_TacVest_rig_blk_RF","V_TacVest_rig_khk_RF","V_TacVest_rig_oli_RF"];

(_pilotLoadoutData get "uniforms") append ["U_C_HeliPilotCoveralls_Black_RF","U_C_HeliPilotCoveralls_Green_RF","U_B_HeliPilotCoveralls_MTP_RF"];
(_pilotLoadoutData get "vests") append ["V_TacVest_rig_blk_RF","V_TacVest_rig_khk_RF","V_TacVest_rig_oli_RF"];
(_pilotLoadoutData get "helmets") append ["H_PilotHelmetHeli_Black_RF","H_PilotHelmetHeli_Blue_RF","H_PilotHelmetHeli_MilGreen_RF","H_PilotHelmetHeli_White_RF"];

(_policeLoadoutData get "vests") append ["V_TacVest_gen_holster_RF"];

(_policeLoadoutData get "SMGs") append [
	["SMG_01_black_RF","","","optic_VRCO_RF",["30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01_Tracer_Green"], [], ""],
	["SMG_01_black_RF","muzzle_snds_acp","acc_flashlight_smg_01","optic_VRCO_RF",["30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01_Tracer_Green"], [], ""],
	["SMG_01_black_RF","muzzle_snds_acp","","optic_VRCO_RF",["30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01_Tracer_Green"], [], ""]
];
(_policeLoadoutData get "sidearms") append [
	["hgun_Glock19_auto_RF","muzzle_snds_L","acc_flashlight_IR_pistol_RF","optic_MRD_black",["65Rnd_9x19_Red_Mag_RF","33Rnd_9x19_Red_Mag_RF","17Rnd_9x19_red_Mag_RF"],[],""],
    ["hgun_Glock19_RF","muzzle_snds_L","acc_pointer_IR_pistol_RF","optic_MRD_black",["17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF"],[],""],
	["hgun_Glock19_auto_RF","","acc_flashlight_IR_pistol_RF","optic_MRD_black",["65Rnd_9x19_Red_Mag_RF","33Rnd_9x19_Red_Mag_RF","17Rnd_9x19_red_Mag_RF"],[],""],
    ["hgun_Glock19_RF","","acc_pointer_IR_pistol_RF","optic_MRD_black",["17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF","17Rnd_9x19_Mag_RF"],[],""]
];
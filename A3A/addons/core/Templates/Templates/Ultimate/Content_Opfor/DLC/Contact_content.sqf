_baseClassSquadLeaderArray append ["O_R_Soldier_TL_F","O_R_Patrol_Soldier_TL_F","O_R_recon_TL_F"];
_baseClassRiflemanArray append ["O_R_JTAC_F","O_R_Patrol_Soldier_A_F","O_R_Patrol_Soldier_M_F","O_R_recon_JTAC_F"];
//_baseClassRadiomanArray append [];
_baseClassMedicArray append ["O_R_medic_F","O_R_Patrol_Soldier_Medic","O_R_recon_medic_F"];
_baseClassEngineerArray append ["O_R_Patrol_Soldier_Engineer_F"];
_baseClassExplosivesArray append ["O_R_soldier_exp_F","O_R_recon_exp_F"];
_baseClassGrenadierArray append ["O_R_Soldier_GL_F","O_R_Patrol_Soldier_GL_F","O_R_recon_GL_F"];
_baseClassLATArray append ["O_R_Soldier_LAT_F","O_R_Patrol_Soldier_LAT_F","O_R_recon_LAT_F"];
//_baseClassATArray append [];
//_baseClassAAArray append [];
_baseClassMachineGunnerArray append ["O_R_Soldier_AR_F","O_R_Patrol_Soldier_AR2_F","O_R_Patrol_Soldier_AR_F","O_R_recon_AR_F"];
_baseClassMarksmanArray append ["O_R_soldier_M_F","O_R_Patrol_Soldier_M2_F","O_R_recon_M_F"];
_baseClassSniperArray append ["O_R_soldier_M_F","O_R_Patrol_Soldier_M2_F","O_R_recon_M_F"];
//_baseClassPatrolSniperArray append [];
//_baseClassPatrolSpotterArray append [];
// ================== Специальные роли ==================

_voices append ["Male01RUS","Male02RUS","Male03RUS"];
_faces append ["RussianHead_4","RussianHead_1","RussianHead_3","RussianHead_2","RussianHead_5"];

_insignia append ["Spetsnaz223rdDetachment"];

_Accessories append [""];
_TlOptics append ["optic_Arco_AK_arid_F","optic_Arco_AK_blk_F","optic_Arco_AK_lush_F","optic_Holosight_arid_F","optic_Holosight_lush_F"];
_RifleOptics append ["optic_Arco_AK_arid_F","optic_Arco_AK_blk_F","optic_Arco_AK_lush_F","optic_Holosight_arid_F","optic_Holosight_lush_F"];
_MGOptics append ["optic_Arco_AK_arid_F","optic_Arco_AK_blk_F","optic_Arco_AK_lush_F","optic_Holosight_arid_F","optic_Holosight_lush_F","optic_DMS_weathered_Kir_F","optic_DMS_weathered_F"];
_SMGOptics append ["optic_Holosight_arid_F","optic_Holosight_lush_F"];
_P90Optics append ["optic_Holosight_arid_F","optic_Holosight_lush_F"];
_MarksmanOptics append ["optic_DMS_weathered_Kir_F","optic_DMS_weathered_F"];
_SniperOptics append ["optic_DMS_weathered_Kir_F","optic_DMS_weathered_F"];
_Bipods append ["","bipod_02_F_arid","bipod_02_F_lush"];

// Оружие
(_loadoutData get "slRifles") append [
	["arifle_AK12_arid_F","muzzle_snds_B_arid_F",_Accessories,_TlOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_arid_F","",_Accessories,_TlOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_lush_F","muzzle_snds_B_lush_F",_Accessories,_TlOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_lush_F","",_Accessories,_TlOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_GL_arid_F","muzzle_snds_B_arid_F",_Accessories,_TlOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_slglammo,""],
	["arifle_AK12_GL_arid_F","",_Accessories,_TlOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_slglammo,""],
	["arifle_AK12_GL_lush_F","muzzle_snds_B_lush_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_slglammo,""],
	["arifle_AK12_GL_lush_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_slglammo,""]
];
(_loadoutData get "rifles") append [
	["arifle_AK12_arid_F","muzzle_snds_B_arid_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_arid_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_lush_F","muzzle_snds_B_lush_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12_lush_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods]
];
(_loadoutData get "carbines") append [
	["arifle_AK12U_F","muzzle_snds_B",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
    ["arifle_AK12U_arid_F","muzzle_snds_B_arid_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12U_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
    ["arifle_AK12U_arid_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12U_lush_F","muzzle_snds_B_lush_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods],
	["arifle_AK12U_lush_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],_Bipods]
];
(_loadoutData get "grenadeLaunchers") append [
	["arifle_AK12_GL_arid_F","muzzle_snds_B_arid_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_glammo,""],
	["arifle_AK12_GL_arid_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_glammo,""],
	["arifle_AK12_GL_lush_F","muzzle_snds_B_lush_F",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_glammo,""],
	["arifle_AK12_GL_lush_F","",_Accessories,_RifleOptics,["30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_F","30rnd_762x39_AK12_Arid_Mag_Tracer_F"],_glammo,""]
];
(_loadoutData get "machineGuns") append [
	["arifle_RPK12_F","muzzle_snds_B",_Accessories,_MGOptics,["75rnd_762x39_AK12_Mag_F","75rnd_762x39_AK12_Mag_F","75rnd_762x39_AK12_Mag_Tracer_F"],[],""],
    ["arifle_RPK12_arid_F","muzzle_snds_B_arid_F",_Accessories,_MGOptics,["75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],""],
	["arifle_RPK12_F","",_Accessories,_MGOptics,["75rnd_762x39_AK12_Mag_F","75rnd_762x39_AK12_Mag_F","75rnd_762x39_AK12_Mag_Tracer_F"],[],""],
    ["arifle_RPK12_arid_F","",_Accessories,_MGOptics,["75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],""],
	["arifle_RPK12_lush_F","muzzle_snds_B_lush_F",_Accessories,_MGOptics,["75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],""],
	["arifle_RPK12_lush_F","",_Accessories,_MGOptics,["75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_F","75rnd_762x39_AK12_Arid_Mag_Tracer_F"],[],""]
];

// Пусковые установки
(_loadoutData get "lightATLaunchers") append [
	["launch_RPG32_green_F","","","",["RPG32_F","RPG32_F","RPG32_HE_F"],[],""]
];

// Базовое снаряжение
(_loadoutData get "watches") append ["ChemicalDetector_01_watch_F"];
(_loadoutData get "NVGs") append ["O_NVGoggles_grn_F"];

// Предательская экипировка
(_loadoutData get "traitorUniforms") append ["U_C_E_LooterJacket_01_F","U_I_L_Uniform_01_tshirt_black_F","U_I_L_Uniform_01_tshirt_olive_F","U_I_L_Uniform_01_tshirt_skull_F","U_I_L_Uniform_01_tshirt_sport_F"];
(_loadoutData get "traitorHats") append ["H_Booniehat_mgrn","H_Booniehat_taiga","H_Hat_Tinfoil_F"];

// Офицерская экипировка
(_loadoutData get "officerVests") append [
	"V_SmershVest_01_F",
	"V_SmershVest_01_radio_F"
];
(_loadoutData get "officerHats") append [
	"H_MilCap_grn",
	"H_MilCap_taiga"
];

// Специальная экипировка
(_loadoutData get "cloakUniforms") append [];
(_loadoutData get "cloakVests") append [
	"V_SmershVest_01_F",
	"V_SmershVest_01_radio_F"
];

// Основная экипировка
(_loadoutData get "uniforms") append [
	"U_C_CBRN_Suit_01_Blue_F",
	"U_O_R_Gorka_01_F",
	"U_O_R_Gorka_01_brown_F",
	"U_O_R_Gorka_01_camo_F"
];
(_loadoutData get "slUniforms") append [];
(_loadoutData get "vests") append [
	"V_SmershVest_01_F",
	"V_SmershVest_01_radio_F"
];
(_loadoutData get "Hvests") append [];
(_loadoutData get "sniVests") append [
	"V_SmershVest_01_F",
	"V_SmershVest_01_radio_F"
];
(_loadoutData get "backpacks") append [
	"B_CombinationUnitRespirator_01_F",
	"B_FieldPack_green_F"
];
(_loadoutData get "longRangeRadios") append [
	"B_RadioBag_01_black_F",
	"B_RadioBag_01_ghex_F",
	"B_RadioBag_01_hex_F",
	"B_RadioBag_01_oucamo_F",
	'B_SCBA_01_F'
];
(_loadoutData get "atBackpacks") append [
	"B_Carryall_green_F",
	"B_Carryall_taiga_F",
	"B_FieldPack_taiga_F"
];
(_loadoutData get "helmets") append [
	"H_HelmetAggressor_F",
	"H_HelmetAggressor_cover_F",
	"H_HelmetAggressor_cover_taiga_F"
];
(_loadoutData get "slHat") append [
	"H_MilCap_grn",
	"H_MilCap_taiga"
];
(_loadoutData get "sniHats") append [
	"H_Booniehat_mgrn",
	"H_Booniehat_taiga"
];

// Аксессуары
(_loadoutData get "glasses") append ["G_Blindfold_01_black_F","G_Blindfold_01_white_F"];
(_loadoutData get "goggles") append ["G_AirPurifyingRespirator_02_black_F","G_AirPurifyingRespirator_02_olive_F","G_AirPurifyingRespirator_02_sand_F"];

// Дополнительные предметы для специализаций
_slItems append ["O_R_IR_Grenade"];
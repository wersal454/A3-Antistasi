_vehiclesBasic append ["gm_ge_army_k125"];
_vehiclesLightUnarmed append ["gm_ge_army_iltis_cargo","gm_pl_army_uaz469_cargo"];
_vehiclesLightArmed append ["gm_pl_army_uaz469_dshkm","gm_ge_army_iltis_mg3"];
_vehiclesAt append ["gm_gc_army_uaz469_spg9_noinsignia","gm_ge_army_iltis_milan"];
_VehTruck append ["gm_pl_army_ural4320_cargo","gm_ge_army_kat1_451_container","gm_dk_army_u1300l_container","gm_ge_army_kat1_451_cargo"];

_vehiclesMedical append ["gm_ge_ff_u1300l_medic","gm_gc_bgs_ural375d_medic_noinsignia","gm_ge_army_m113a1g_medic_noinsignia"];

_vehiclesSupply append ["gm_ge_army_u1300l_firefighter"];

_vehiclePlane append ["gm_gc_civ_l410s_passenger", "gm_gc_civ_l410s_salon" , "gm_ge_airforce_do28d2_noinsignia"];


_vehiclesCivCar append ["gm_ge_civ_typ1200","gm_gc_civ_p601","gm_ge_civ_typ253","gm_ge_civ_w123","gm_xx_civ_bicycle_01","gm_ge_dbp_bicycle_01_ylw"];
_CivTruck append ["gm_gc_civ_ural375d_cargo", "gm_ge_civ_u1300l", "gm_ge_civ_typ247", "gm_ge_civ_typ251"];
_civHelicopters append ["gm_gc_civ_mi2p", "gm_ge_adak_bo105m_vbh"];


_staticMG append ["gm_dk_army_mg3_aatripod", "gm_gc_army_dshkm_aatripod", "gm_gc_bgs_searchlight_01"];
_staticAT append ["gm_ge_army_milan_launcher_tripod", "gm_gc_army_fagot_launcher_tripod", "gm_gc_army_spg9_tripod"];
_staticMortars append ["B_Mortar_01_F"];

_MortarMagHE append ["8Rnd_82mm_Mo_shells"];
_MortarMagSmoke append ["8Rnd_82mm_Mo_Smoke_white"];

_minesAT append ["gm_mine_at_dm21"];
_minesAPERS append ["gm_mine_ap_dm31"];

_breachingExplosivesAPC append [["DemoCharge_Remote_Mag", 1]];
_breachingExplosivesTank append [["gm_explosive_petn_charge", 1], ["DemoCharge_Remote_Mag", 2]];

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

_initialRebelEquipment append [
    "gm_pm_blk",
    "gm_8Rnd_9x18mm_B_pst_pm_blk",
    "gm_photocamera_01_blk",
    "gm_df7x40_blk",
    "gm_ge_army_conat2",
    "gm_gc_compass_f73",
    "gm_watch_kosei_80",
    "gm_handgrenade_conc_dm51","gm_handgrenade_conc_dm51a1","gm_handgrenade_frag_dm41","gm_handgrenade_frag_dm41a1","gm_handgrenade_frag_dm51","gm_handgrenade_frag_dm51a1","gm_handgrenade_frag_m26",
    "gm_handgrenade_frag_m26a1", "gm_handgrenade_frag_rgd5",
    "gm_smokeshell_blk_gc","gm_smokeshell_blu_gc","gm_smokeshell_grn_gc","gm_smokeshell_org_gc","gm_smokeshell_red_gc","gm_smokeshell_wht_gc","gm_smokeshell_yel_gc","gm_smokeshell_grn_dm21",
    "gm_smokeshell_red_dm23","gm_smokeshell_wht_dm25","gm_smokeshell_yel_dm26","gm_smokeshell_org_dm32",
    ["gm_explosive_petn_charge", 10], ["gm_explosive_plnp_charge", 10],
    "gm_boltcutter",
    ["gm_rpg7_wud", 3], 
    ["gm_1Rnd_40mm_heat_pg7v_rpg7", 9],
    ["gm_1Rnd_40mm_heat_pg7vl_rpg7", 9],
	"gm_ge_army_backpack_medic_80_oli",
    "gm_ge_backpack_satchel_80_blk",
    "gm_ge_backpack_satchel_80_san"
];

_rebUniforms append [
	"gm_gc_civ_uniform_man_04_80_gry",
    "gm_gc_civ_uniform_man_04_80_blu",
    "gm_ge_dbp_uniform_suit_80_blu",
    "gm_gc_civ_uniform_man_03_80_gry",
    "gm_gc_civ_uniform_man_03_80_grn",
    "gm_gc_civ_uniform_man_03_80_blu",
    "gm_pl_airforce_uniform_pilot_80_gry",
    "gm_gc_airforce_uniform_pilot_80_blu",
    "gm_gc_civ_uniform_pilot_80_blk",
    "gm_xx_army_uniform_fighter_04_wdl",
    "gm_xx_army_uniform_fighter_01_oli",
    "gm_xx_army_uniform_fighter_01_alp",
    "gm_xx_army_uniform_fighter_01_m84",
    "gm_xx_army_uniform_fighter_02_wdl",
    "gm_xx_army_uniform_fighter_02_oli",
    "gm_xx_army_uniform_fighter_03_blk",
    "gm_xx_army_uniform_fighter_03_brn",
    "gm_xx_army_uniform_fighter_04_grn",
    "gm_ge_uniform_pilot_commando_rolled_oli",
    "gm_ge_uniform_pilot_commando_rolled_gry",
    "gm_ge_uniform_pilot_commando_rolled_blk",
    "gm_ge_uniform_pilot_commando_oli",
    "gm_ge_uniform_pilot_commando_gry",
    "gm_ge_uniform_pilot_commando_blk",
    "gm_ge_ff_uniform_man_80_orn",
    "gm_ge_army_uniform_soldier_parka_80_win",
    "gm_dk_army_uniform_soldier_84_win",
    "gm_ge_civ_uniform_blouse_80_gry",
    "gm_gc_civ_uniform_man_02_80_brn",
    "gm_gc_civ_uniform_man_01_80_blu",
    "gm_gc_civ_uniform_man_01_80_blk"
];

_headgear append [
	"gm_ge_headgear_beret_blk",
    "gm_ge_headgear_beret_un",
    "gm_ge_headgear_beret_mrb",
    "gm_ge_headgear_hat_boonie_trp",
    "gm_ge_headgear_hat_boonie_flk",
    "gm_dk_headgear_hat_boonie_m84",
    "gm_ge_headgear_hat_boonie_oli",
    "gm_ge_headgear_hat_boonie_wdl",
    "gm_ge_headgear_crewhat_80_blk",
    "gm_gc_army_headgear_crewhat_80_blk",
    "gm_ge_headgear_headset_crew_oli",
    "gm_ge_headgear_beret_crew_blk",
    "gm_gc_headgear_fjh_model4_oli",
    "gm_gc_headgear_fjh_model4_wht",
    "gm_xx_headgear_headwrap_01_trp",
    "gm_xx_headgear_headwrap_01_flk",
    "gm_xx_headgear_headwrap_01_blk",
    "gm_xx_headgear_headwrap_01_blu",
    "gm_xx_headgear_headwrap_01_smp",
    "gm_xx_headgear_headwrap_crew_01_trp",
    "gm_xx_headgear_headwrap_crew_01_flk",
    "gm_xx_headgear_headwrap_crew_01_blk",
    "gm_xx_headgear_headwrap_crew_01_smp",
    "gm_xx_headgear_headwrap_crew_01_grn",
    "gm_xx_headgear_headwrap_crew_01_m84",
    "gm_xx_headgear_headwrap_crew_01_oli",
    "gm_xx_headgear_headwrap_01_frog",
    "gm_xx_headgear_headwrap_01_grn",
    "gm_xx_headgear_headwrap_01_m84",
    "gm_xx_headgear_headwrap_01_moro",
    "gm_xx_headgear_headwrap_01_oli",
    "gm_xx_headgear_headwrap_01_str",
    "gm_xx_headgear_headwrap_01_wht",
    "gm_xx_headgear_headwrap_01_dino",
    "gm_ge_headgear_winterhat_80_oli",
    "gm_ge_headgear_hat_beanie_blk",
    "gm_ge_headgear_hat_beanie_crew_blk"
];

/////////////////////
///  Identities   ///
/////////////////////

_faces append [
"gm_WhiteHead_01_camo_01",
"gm_WhiteHead_01_camo_02",
"gm_WhiteHead_02_camo_01",
"gm_WhiteHead_02_camo_02",
"gm_WhiteHead_18_camo_01",
"gm_WhiteHead_18_camo_02",
"gm_WhiteHead_05_camo_01",
"gm_WhiteHead_05_camo_02",
"gm_WhiteHead_03_camo_01",
"gm_WhiteHead_03_camo_02",
"gm_WhiteHead_04_camo_01",
"gm_WhiteHead_04_camo_02",
"gm_WhiteHead_06_camo_01",
"gm_WhiteHead_06_camo_02",
"gm_WhiteHead_07_camo_01",
"gm_WhiteHead_07_camo_02",
"gm_WhiteHead_08_camo_01",
"gm_WhiteHead_08_camo_02",
"gm_WhiteHead_09_camo_01",
"gm_WhiteHead_09_camo_02",
"gm_WhiteHead_16_camo_01",
"gm_WhiteHead_16_camo_02",
"gm_WhiteHead_11_camo_01",
"gm_WhiteHead_11_camo_02",
"gm_WhiteHead_10_camo_01",
"gm_WhiteHead_10_camo_02",
"gm_WhiteHead_19_camo_01",
"gm_WhiteHead_19_camo_02",
"gm_WhiteHead_17_camo_01",
"gm_WhiteHead_17_camo_02",
"gm_WhiteHead_21_camo_01",
"gm_WhiteHead_21_camo_02",
"gm_WhiteHead_12_camo_01",
"gm_WhiteHead_12_camo_02",
"gm_WhiteHead_13_camo_01",
"gm_WhiteHead_13_camo_02",
"gm_WhiteHead_14_camo_01",
"gm_WhiteHead_14_camo_02",
"gm_WhiteHead_15_camo_01",
"gm_WhiteHead_15_camo_02",
"gm_WhiteHead_20_camo_01",
"gm_WhiteHead_20_camo_02"
];
_voices append [
"gm_voice_male_deu_01",
"gm_voice_male_deu_02",
"gm_voice_male_deu_03",
"gm_voice_male_deu_04",
"gm_voice_male_deu_05",
"gm_voice_male_deu_06",
"gm_voice_male_deu_07",
"gm_voice_male_deu_08",
"gm_voice_male_deu_09"
];

_glasses append ["gm_ge_facewear_dustglasses","gm_gc_army_facewear_dustglasses","gm_ge_facewear_glacierglasses","gm_ge_facewear_stormhood_dustglasses_blk","gm_ge_facewear_sunglasses"];

_goggles append ["gm_ge_facewear_acidgoggles",
    "gm_ge_facewear_m65",
    "gm_gc_army_facewear_schm41m",
    "gm_xx_facewear_scarf_01_trp",
    "gm_xx_facewear_scarf_01_flk",
    "gm_xx_facewear_scarf_01_blk",
    "gm_xx_facewear_scarf_01_blu",
    "gm_xx_facewear_scarf_01_pt1",
    "gm_xx_facewear_scarf_01_pt3",
    "gm_xx_facewear_scarf_01_frog",
    "gm_xx_facewear_scarf_01_grn",
    "gm_xx_facewear_scarf_01_gry",
    "gm_xx_facewear_scarf_01_m84",
    "gm_xx_facewear_scarf_02_blk",
    "gm_xx_facewear_scarf_01_grn",
    "gm_xx_facewear_scarf_01_oli",
    "gm_xx_facewear_scarf_01_wht",
    "gm_xx_facewear_scarf_01_moro",
    "gm_xx_facewear_scarf_01_oli",
    "gm_xx_facewear_scarf_01_red",
    "gm_xx_facewear_scarf_01_pt2",
    "gm_xx_facewear_scarf_01_str",
    "gm_xx_facewear_scarf_01_wht",
    "gm_ge_facewear_stormhood_blk",
    "gm_ge_facewear_stormhood_brd"];
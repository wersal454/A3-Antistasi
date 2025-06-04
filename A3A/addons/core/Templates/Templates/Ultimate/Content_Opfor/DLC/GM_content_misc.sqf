(_crewLoadoutData get "uniforms") append [
	"gm_gc_army_uniform_soldier_80_blk",
	"gm_gc_army_uniform_soldier_80_str",
	"gm_gc_army_uniform_soldier_80_win",
	"gm_gc_army_uniform_soldier_gloves_80_str"
];
(_crewLoadoutData get "vests") append [];
(_crewLoadoutData get "helmets") append [
	"gm_gc_army_headgear_crewhat_80_blk",
	"gm_gc_headgear_fjh_model4_oli",
	"gm_gc_headgear_fjh_model4_wht",
	"gm_pl_army_headgear_wz63_oli",
	"gm_pl_army_headgear_wz63_net_oli"
];

(_pilotLoadoutData get "uniforms") append [
	"gm_gc_airforce_uniform_pilot_80_blu",
	"gm_pl_airforce_uniform_pilot_80_gry"
];
(_pilotLoadoutData get "vests") append [
	"gm_gc_army_vest_80_belt_str",
	"gm_gc_army_vest_80_rifleman_str",
	"gm_pl_army_vest_80_crew_gry"
];
(_pilotLoadoutData get "helmets") append [
	"gm_gc_headgear_zsh3_wht",
	"gm_gc_headgear_zsh3_blu",
	"gm_gc_headgear_zsh3_orn"
];

(_policeLoadoutData get "uniforms") append [
	"gm_gc_pol_uniform_dress_80_blu"
];
(_policeLoadoutData get "vests") append [
	"gm_ge_pol_vest_80_wht",
	"gm_gc_vest_combatvest3_pol"
];
(_policeLoadoutData get "helmets") append [
	"gm_gc_pol_headgear_cap_80_blu"
];

_UZIoptics = ["","gm_ls45_ir_uziclaw_blk","gm_ls45_red_uziclaw_blk"];

(_policeLoadoutData get "SMGs") append [
	["gm_mp2a1_blk","gm_suppressor_m10_9mm_blk","",_UZIoptics,["gm_32Rnd_9x19mm_AP_DM91_mp2_blk","gm_32Rnd_9x19mm_B_DM11_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk"],[],""],
	["gm_mp2a1_blk","","",_UZIoptics,["gm_32Rnd_9x19mm_AP_DM91_mp2_blk","gm_32Rnd_9x19mm_B_DM11_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk"],[],""],
	["gm_pm63_blk","gm_suppressor_safloryt_blk","","",["gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk","gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk"],[],""],
	["gm_pm63_blk","","","",["gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk","gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk"],[],""]
];
(_policeLoadoutData get "sidearms") append [
	["gm_lp1_blk","","","",["gm_1Rnd_265mm_flare_single_grn_gc","gm_1Rnd_265mm_flare_multi_red_gc","gm_1Rnd_265mm_flare_single_red_gc","gm_1Rnd_265mm_flare_single_wht_gc","gm_1Rnd_265mm_flare_single_yel_DM10","gm_1Rnd_265mm_flare_single_grn_DM11","gm_1Rnd_265mm_flare_single_red_DM13","gm_1Rnd_265mm_flare_single_wht_DM15","gm_1Rnd_265mm_flare_para_yel_DM16","gm_1Rnd_265mm_flare_multi_yel_DM20","gm_1Rnd_265mm_flare_multi_grn_DM21","gm_1Rnd_265mm_flare_multi_red_DM23","gm_1Rnd_265mm_flare_multi_wht_DM25","gm_1Rnd_265mm_flare_multi_nbc_DM47","gm_1Rnd_265mm_smoke_single_blk_gc","gm_1Rnd_265mm_smoke_single_blu_gc","gm_1Rnd_265mm_smoke_single_yel_gc","gm_1Rnd_265mm_smoke_single_yel_DM19","gm_1Rnd_265mm_smoke_single_org_DM22","gm_1Rnd_265mm_smoke_single_vlt_DM24"],[],""],
	["gm_p1_blk","","","",["gm_8Rnd_9x19mm_B_DM11_p1_blk","gm_8Rnd_9x19mm_B_DM51_p1_blk","gm_8Rnd_9x19mm_BSD_DM81_p1_blk"],[],""],
	["gm_p1sd_blk","","","",["gm_8Rnd_9x19mm_B_DM11_p1_blk","gm_8Rnd_9x19mm_B_DM51_p1_blk","gm_8Rnd_9x19mm_BSD_DM81_p1_blk"],[],""],
	["gm_p210_blk","","","",["gm_8Rnd_9x19mm_B_DM11_p210_blk","gm_8Rnd_9x19mm_B_DM51_p210_blk"],[],""],
	["gm_lp1_blk","","","",["gm_1Rnd_265mm_flare_single_grn_gc","gm_1Rnd_265mm_flare_multi_red_gc","gm_1Rnd_265mm_flare_single_red_gc","gm_1Rnd_265mm_flare_single_wht_gc","gm_1Rnd_265mm_flare_single_yel_DM10","gm_1Rnd_265mm_flare_single_grn_DM11","gm_1Rnd_265mm_flare_single_red_DM13","gm_1Rnd_265mm_flare_single_wht_DM15","gm_1Rnd_265mm_flare_para_yel_DM16","gm_1Rnd_265mm_flare_multi_yel_DM20","gm_1Rnd_265mm_flare_multi_grn_DM21","gm_1Rnd_265mm_flare_multi_red_DM23","gm_1Rnd_265mm_flare_multi_wht_DM25","gm_1Rnd_265mm_flare_multi_nbc_DM47","gm_1Rnd_265mm_smoke_single_blk_gc","gm_1Rnd_265mm_smoke_single_blu_gc","gm_1Rnd_265mm_smoke_single_yel_gc","gm_1Rnd_265mm_smoke_single_yel_DM19","gm_1Rnd_265mm_smoke_single_org_DM22","gm_1Rnd_265mm_smoke_single_vlt_DM24"],[],""],
	["gm_pim_blk","","","",["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"],[],""],
	["gm_pimb_blk","","","",["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"],[],""],
	["gm_pimb_blk","gm_suppressor_kacnavy_9mm_blk","","",["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"],[],""],
	["gm_pimb_blk","gm_suppressor_kacnavysd_9mm_blk","","",["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"],[],""],
	["gm_pimb_blk","gm_suppressor_tgpp_9mm_blk","","",["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"],[],""],
	["gm_pm_blk","","","",["gm_8Rnd_9x18mm_B_pst_pm_blk","gm_8Rnd_9x18mm_B_pst_pm_blk"],[],""],
	["gm_pm63_handgun_blk","gm_suppressor_safloryt_blk","","",["gm_25Rnd_9x18mm_B_pst_pm63_blk","gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk"],[],""],
	["gm_pn3_gry","","","",[],[],""],
	["gm_wz78_blk","","","",["gm_1Rnd_265mm_flare_single_grn_gc","gm_1Rnd_265mm_flare_multi_red_gc","gm_1Rnd_265mm_flare_single_red_gc","gm_1Rnd_265mm_flare_single_wht_gc","gm_1Rnd_265mm_flare_single_yel_DM10","gm_1Rnd_265mm_flare_single_grn_DM11","gm_1Rnd_265mm_flare_single_red_DM13","gm_1Rnd_265mm_flare_single_wht_DM15","gm_1Rnd_265mm_flare_para_yel_DM16","gm_1Rnd_265mm_flare_multi_yel_DM20","gm_1Rnd_265mm_flare_multi_grn_DM21","gm_1Rnd_265mm_flare_multi_red_DM23","gm_1Rnd_265mm_flare_multi_wht_DM25","gm_1Rnd_265mm_flare_multi_nbc_DM47","gm_1Rnd_265mm_smoke_single_blk_gc","gm_1Rnd_265mm_smoke_single_blu_gc","gm_1Rnd_265mm_smoke_single_yel_gc","gm_1Rnd_265mm_smoke_single_yel_DM19","gm_1Rnd_265mm_smoke_single_org_DM22","gm_1Rnd_265mm_smoke_single_vlt_DM24"],[],""]
];
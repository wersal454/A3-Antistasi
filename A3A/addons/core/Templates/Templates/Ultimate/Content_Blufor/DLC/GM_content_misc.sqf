(_crewLoadoutData get "uniforms") append [
	"gm_ge_army_uniform_crew_90_trp",
	"gm_ge_army_uniform_crew_90_flk",
	"gm_ge_army_uniform_crew_80_oli"
];
(_crewLoadoutData get "vests") append [
	"gm_ge_vest_90_crew_flk",
	"gm_ge_vest_armor_90_crew_flk",
	"gm_ge_army_vest_80_crew",
	"gm_dk_army_vest_54_crew"
];
(_crewLoadoutData get "helmets") append [
	"gm_ge_headgear_crewhat_80_blk",
	"gm_ge_headgear_headset_crew_oli",
	"gm_ge_headgear_beret_crew_red_antiair",
	"gm_ge_headgear_beret_crew_blk_antitank",
	"gm_ge_headgear_beret_crew_blk_armor",
	"gm_ge_headgear_beret_crew_blk_armorrecon",
	"gm_ge_headgear_beret_crew_red_artillery",
	"gm_ge_headgear_beret_crew_blk",
	"gm_ge_bgs_headgear_beret_crew_grn",
	"gm_ge_headgear_beret_crew_red_engineer",
	"gm_ge_bgs_headgear_beret_crew_grn_sf",
	"gm_ge_headgear_beret_crew_grn_infantry",
	"gm_ge_headgear_beret_crew_bdx_lrrp",
	"gm_ge_headgear_beret_crew_red_maintenance",
	"gm_ge_headgear_beret_crew_grn_mechinf",
	"gm_ge_headgear_beret_crew_red_militarypolice",
	"gm_ge_headgear_beret_crew_red_nbc",
	"gm_ge_headgear_beret_crew_red_opcom",
	"gm_ge_headgear_beret_crew_bdx_paratrooper",
	"gm_ge_headgear_beret_crew_blk_recon",
	"gm_ge_headgear_beret_crew_red_signals",
	"gm_ge_headgear_beret_crew_red_supply",
	"gm_ge_headgear_hat_beanie_crew_blk"
];

(_pilotLoadoutData get "uniforms") append [
	"gm_ge_uniform_pilot_commando_blk",
	"gm_ge_uniform_pilot_commando_gry",
	"gm_ge_uniform_pilot_commando_oli",
	"gm_ge_uniform_pilot_commando_rolled_blk",
	"gm_ge_uniform_pilot_commando_rolled_gry",
	"gm_ge_uniform_pilot_commando_rolled_oli",
	"gm_ge_army_uniform_pilot_oli",
	"gm_ge_army_uniform_pilot_rolled_oli",
	"gm_ge_army_uniform_pilot_sar",
	"gm_ge_army_uniform_pilot_rolled_sar"
];
(_pilotLoadoutData get "vests") append [
	"gm_ge_army_vest_pilot_oli",
	"gm_ge_army_vest_pilot_pads_oli"
];
(_pilotLoadoutData get "helmets") append [
	"gm_ge_headgear_sph4_oli"
];

(_policeLoadoutData get "uniforms") append [
	"gm_gc_pol_uniform_dress_80_blu",
	"gm_ge_pol_uniform_blouse_80_blk",
	"gm_ge_pol_uniform_suit_80_grn"
];
(_policeLoadoutData get "vests") append [
	"gm_ge_army_vest_80_brassard_mp",
	"gm_ge_army_vest_80_mp_wht"
];
(_policeLoadoutData get "helmets") append [
	"gm_ge_pol_headgear_cap_80_grn",
	"gm_ge_pol_headgear_cap_80_wht",
	"gm_ge_headgear_beret_red_militarypolice",
	"gm_ge_headgear_beret_crew_red_militarypolice"
];

_UZIoptics = ["","gm_ls45_ir_uziclaw_blk","gm_ls45_red_uziclaw_blk"];

(_policeLoadoutData get "SMGs") append [
	["gm_mp2a1_blk","gm_suppressor_m10_9mm_blk","",_UZIoptics,["gm_32Rnd_9x19mm_AP_DM91_mp2_blk","gm_32Rnd_9x19mm_B_DM11_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk"],[],""],
	["gm_mp2a1_blk","","",_UZIoptics,["gm_32Rnd_9x19mm_AP_DM91_mp2_blk","gm_32Rnd_9x19mm_B_DM11_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk","gm_32Rnd_9x19mm_B_DM51_mp2_blk"],[],""],
	["gm_pm63_blk","gm_suppressor_safloryt_blk","","",["gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk","gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk"],[],""],
	["gm_pm63_blk","","","",["gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk","gm_15Rnd_9x18mm_B_pst_pm63_blk","gm_25Rnd_9x18mm_B_pst_pm63_blk"],[],""],

	["gm_mp5a2_blk",_MPmuzzle,"gm_maglite_2d_hkslim_blk",_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_B_DM51_mp5a3_blk","gm_60Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5a2_blk",_MPmuzzle,"",_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_B_DM51_mp5a3_blk","gm_60Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5a3_blk",_MPmuzzle,"gm_maglite_2d_hkslim_blk",_GMWESTERNOptics,["gm_30Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_30Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5a3_blk",_MPmuzzle,"",_GMWESTERNOptics,["gm_30Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_30Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],

	["gm_mp5a3_surefire_blk",_MPmuzzle,_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	
	["gm_mp5a4_blk",_MPmuzzle,"gm_maglite_2d_hkslim_blk",_GMWESTERNOptics,["gm_30Rnd_9x19mm_AP_DM91_mp5_blk","gm_30Rnd_9x19mm_B_DM11_mp5_blk","gm_30Rnd_9x19mm_B_DM51_mp5_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5_blk"],[],""],
	["gm_mp5a4_blk",_MPmuzzle,"",_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_B_DM51_mp5a3_blk","gm_60Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5a5_blk",_MPmuzzle,"gm_maglite_2d_hkslim_blk",_GMWESTERNOptics,["gm_30Rnd_9x19mm_AP_DM91_mp5_blk","gm_30Rnd_9x19mm_B_DM11_mp5_blk","gm_30Rnd_9x19mm_B_DM51_mp5_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5_blk"],[],""],
	["gm_mp5a5_blk",_MPmuzzle,"",_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_B_DM51_mp5a3_blk","gm_60Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	
	["gm_mp5n_blk",_MPmuzzle,"",_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_60Rnd_9x19mm_B_DM51_mp5a3_blk","gm_60Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	
	["gm_mp5n_surefire_blk",_MPmuzzle,_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	
	["gm_mp5nsd1_blk","",_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5nsd2_blk","",_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	
	["gm_mp5sd2_blk","",_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5sd3_blk","",_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	
	["gm_mp5sd5_blk","",_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""],
	["gm_mp5sd6_blk","",_MPMattachemnts,_GMWESTERNOptics,["gm_60Rnd_9x19mm_AP_DM91_mp5a3_blk","gm_60Rnd_9x19mm_B_DM11_mp5a3_blk","gm_30Rnd_9x19mm_B_DM51_mp5a3_blk","gm_30Rnd_9x19mm_BSD_DM81_mp5a3_blk"],[],""]
];
(_policeLoadoutData get "sidearms") append [
	["gm_lp1_blk","","","",["gm_1Rnd_265mm_flare_single_grn_gc","gm_1Rnd_265mm_flare_multi_red_gc","gm_1Rnd_265mm_flare_single_red_gc","gm_1Rnd_265mm_flare_single_wht_gc","gm_1Rnd_265mm_flare_single_yel_DM10","gm_1Rnd_265mm_flare_single_grn_DM11","gm_1Rnd_265mm_flare_single_red_DM13","gm_1Rnd_265mm_flare_single_wht_DM15","gm_1Rnd_265mm_flare_para_yel_DM16","gm_1Rnd_265mm_flare_multi_yel_DM20","gm_1Rnd_265mm_flare_multi_grn_DM21","gm_1Rnd_265mm_flare_multi_red_DM23","gm_1Rnd_265mm_flare_multi_wht_DM25","gm_1Rnd_265mm_flare_multi_nbc_DM47","gm_1Rnd_265mm_smoke_single_blk_gc","gm_1Rnd_265mm_smoke_single_blu_gc","gm_1Rnd_265mm_smoke_single_yel_gc","gm_1Rnd_265mm_smoke_single_yel_DM19","gm_1Rnd_265mm_smoke_single_org_DM22","gm_1Rnd_265mm_smoke_single_vlt_DM24"],[],""],
	["gm_m49_blk","","","",["gm_8Rnd_9x19mm_B_DM11_p210_blk","gm_8Rnd_9x19mm_B_DM51_p210_blk"],[],""],
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
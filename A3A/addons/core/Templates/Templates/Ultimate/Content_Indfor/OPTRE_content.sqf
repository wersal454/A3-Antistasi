_vehiclesBasic append ["OPTRE_M274_ATV_Ins","OPTRE_M274_ATV"];
_vehiclesLightUnarmed append ["OPTRE_M12_FAV_ins","OPTRE_DME_M12_FAV"];
_vehiclesLightArmed append ["OPTRE_M12_LRV_ins","OPTRE_M12_LRV_DME"];
_vehiclesAt append ["OPTRE_M12A1_LRV_ins","OPTRE_M12_TD_CMA", "OPTRE_M12A1_LRV_CMA"];
_VehTruck append ["OPTRE_m1015_mule_ins","OPTRE_m1015_mule_cma","OPTRE_m1087_stallion_unsc"];

_vehiclesBoat append ["optre_catfish_ins_mg_f","optre_catfish_cma_unarmed_f"];

_vehiclesMedical append ["OPTRE_m1015_mule_medical_ins","OPTRE_M12_ins_MED"];

_vehiclePlane append ["OPTRE_Pelican_unarmed_ins","OPTRE_YSS_1000_A"];

_vehiclesCivCar append ["OPTRE_M12_CIV", "OPTRE_Genet","OPTRE_M12_CIV", "OPTRE_Genet"];
_CivTruck append ["C_Van_01_transport_F", "C_Van_02_transport_F", "C_Van_02_vehicle_F","C_Van_01_transport_F", "C_Van_02_transport_F", "C_Van_02_vehicle_F"];
_civHelicopters append ["OPTRE_ins_falcon_unarmed","OPTRE_UNSC_falcon_PD"];

_CivBoat append ["optre_catfish_ins_unarmed_f","optre_catfish_cma_unarmed_f"];

_staticMG append ["OPTRE_Static_M247H_Tripod"];
_staticAT append ["OPTRE_Static_Gauss"];
_staticAA append ["OPTRE_Static_AA"];
_staticMortars append ["I_G_Mortar_01_F","OPTRE_AU_44_DME_Mortar"];

_MortarMagHE append ["8Rnd_82mm_Mo_shells","OPTRE_10Rnd_122mm_SABOT_81mm_Mo_shells"];
_MortarMagSmoke append ["8Rnd_82mm_Mo_Smoke_white","OPTRE_10Rnd_122mm_Mo_Smoke_white"];

_minesAT append ["ATMine_Range_Mag"];
_minesAPERS append ["APERSMine_Range_Mag"];

_breachingExplosivesAPC append [["DemoCharge_Remote_Mag", 1]];
_breachingExplosivesTank append [["SatchelCharge_Remote_Mag", 1], ["DemoCharge_Remote_Mag", 2]];

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

_initialRebelEquipment append [
"OPTRE_M45", "OPTRE_6Rnd_8Gauge_Pellets",
"OPTRE_M6G",
"OPTRE_M6C",
"OPTRE_8Rnd_127x40_AP_Mag","OPTRE_8Rnd_127x40_Mag","MiniGrenade","SmokeShell",
["IEDUrbanSmall_Remote_Mag", 10], ["IEDLandSmall_Remote_Mag", 10], ["IEDUrbanBig_Remote_Mag", 3], ["IEDLandBig_Remote_Mag", 3],
"B_FieldPack_blk","B_AssaultPack_blk","B_Kitbag_rgr",
"V_SmershVest_01_F","V_BandollierB_rgr","V_Chestrig_oli",
"OPTRE_M45ATAC", "OPTRE_M392_DMR", "OPTRE_15Rnd_762x51_Mag","OPTRE_M6D_Black","OPTRE_M9_Frag",
"OPTRE_UNSC_Rucksack","OPTRE_UNSC_Rucksack_Heavy",
"OPTRE_UNSC_M52A_Armor_Rifleman_URB","OPTRE_UNSC_M52A_Armor1_URB","OPTRE_UNSC_M52A_Armor_Breacher_URB",
"OPTRE_M7", "OPTRE_M393_DMR", "OPTRE_48Rnd_5x23mm_Mag",
"OPTRE_ILCS_Rucksack_Black","OPTRE_ILCS_Rucksack_Heavy","OPTRE_ILCS_Rucksack_Medical",
"OPTRE_UNSC_M52D_Armor","OPTRE_UNSC_M52D_Armor_Demolitions","OPTRE_UNSC_M52D_Armor_Rifleman",
"OPTRE_MA5B", "OPTRE_60Rnd_762x51_Mag",
["OPTRE_M41_SSR", 5], ["OPTRE_M41_Twin_HEAT", 10],"OPTRE_UNSC_Rucksack_Medic",
"OPTRE_UNSC_M52A_Armor_TL_URB",
"Binocular"
];

_rebUniforms append [
	"OPTRE_Ins_URF_Combat_Uniform",
    "OPTRE_Ins_ER_jacket_od_surplus",
    "OPTRE_Ins_ER_jacket_surgeon1",
    "OPTRE_Ins_ER_jacket_surgeon2",
    "OPTRE_Ins_ER_jacket_surplus_OD",
    "OPTRE_Ins_ER_jacket_surplus_brown",
    "OPTRE_Ins_ER_jacket_surplus_redshirt",
    "OPTRE_Ins_ER_rolled_surplus_crimson",
    "OPTRE_Ins_ER_rolled_surplus_black",
	"OPTRE_DME_Uniform",
    "OPTRE_DME_Temperate_Uniform",
	"OPTRE_UNSC_ODST_Uniform",
    "OPTRE_UNSC_Army_Uniform_BLK",
    "OPTRE_UNSC_Army_Uniform_URB",
    "OPTRE_UNSC_Army_Uniform_R_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DES",
    "OPTRE_UNSC_Army_Uniform_DESWDL",
    "OPTRE_UNSC_Army_Uniform_R_DES_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_R_DESWDL_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_S_DES_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_S_DESWDL_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_T_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_SNO_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_R_SNO",
    "OPTRE_UNSC_Army_Uniform_S_SNO_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_SNO_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_T_SNO_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_T_SNO",
	"OPTRE_UNSC_Army_Uniform_WDL",
    "OPTRE_UNSC_Army_Uniform_R_WDL",
    "OPTRE_UNSC_Army_Uniform_S_Gloves_WDL",
    "OPTRE_UNSC_Army_Uniform_R_TRO_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_R_TRO",
    "OPTRE_UNSC_Army_Uniform_S_TRO_SlimLeg",
    "OPTRE_UNSC_Army_Uniform_OLITRO"
];

_headgear append [
	"H_Booniehat_khk_hs",
    "H_Booniehat_tan",
    "H_Cap_tan",
    "H_Cap_oli_hs",
    "H_Cap_blk",
    "H_Cap_headphones",
    "H_ShemagOpen_tan",
    "H_Shemag_olive_hs",
    "OPTRE_Cap_FinalDawn",
    "OPTRE_h_PatrolCap_Green",
    "OPTRE_UNSC_Watchcap",
	"OPTRE_CPD_CH251_DME",
    "OPTRE_UNSC_CH252_Helmet2_URB",
    "OPTRE_UNSC_CH252_Helmet_OLI",
    "OPTRE_FC_VX19_Helmet_Urban",
    "OPTRE_FC_VX19_Helmet",
	"OPTRE_UNSC_CH252D_Helmet",
    "OPTRE_UNSC_CH252D_Helmet_Stripes",
    "OPTRE_UNSC_CH252A_Black_Helmet",
	"OPTRE_UNSC_CH252_Helmet_DES",
    "OPTRE_UNSC_CH252_Helmet_DES_MED",
    "OPTRE_UNSC_CH252_Helmet3_DES",
    "OPTRE_UNSC_CH252_Helmet2_Vacuum_DES",
	"OPTRE_UNSC_CH252_Helmet_SNO",
    "OPTRE_UNSC_CH252_Helmet_SNO_MED",
    "OPTRE_UNSC_CH252_Helmet2_SNO",
    "OPTRE_UNSC_CH252_Helmet2_Vacuum_SNO",
	"OPTRE_UNSC_CH252_Helmet_WDL",
    "OPTRE_UNSC_CH252_Helmet3_WDL",
    "OPTRE_UNSC_CH252_Helmet2_Vacuum_WDL",
    "OPTRE_UNSC_CH252_Helmet_TRO",
    "OPTRE_UNSC_CH252_Helmet_TRO_MED",
    "OPTRE_UNSC_CH252_Helmet2_Vacuum_TRO"
];

/////////////////////
///  Identities   ///
/////////////////////

_faces append ["GreekHead_A3_02","GreekHead_A3_03","GreekHead_A3_04",
"GreekHead_A3_05","GreekHead_A3_06","GreekHead_A3_07","GreekHead_A3_08",
"GreekHead_A3_09","Ioannou","Mavros"];
_voices append ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"];

_glasses append ["G_Shades_Black", "G_Shades_Blue", "G_Shades_Green", "G_Shades_Red", "G_Aviator", "G_Spectacles", "G_Spectacles_Tinted", "G_Sport_BlackWhite", "G_Sport_Blackyellow", "G_Sport_Greenblack", "G_Sport_Checkered", "G_Sport_Red", "G_Squares", "G_Squares_Tinted"];

_goggles append ["G_Lowprofile"];
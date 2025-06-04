_vehiclesBasic append ["I_G_Quadbike_01_F"];
_vehiclesLightUnarmed append ["I_G_Offroad_01_F"];
_vehiclesLightArmed append ["I_G_Offroad_01_armed_F"];
_vehiclesAt append ["I_G_Offroad_01_AT_F"];
_VehTruck append ["I_G_Van_01_transport_F","I_G_Van_02_transport_F", "I_G_Van_02_vehicle_F"];
//_vehicleAA append [];

_vehiclesBoat append ["I_C_Boat_Transport_02_F" , "I_SDV_01_F" , "I_Boat_Armed_01_minigun_F" , "O_Boat_Armed_01_hmg_F"];

_vehiclesMedical append ["C_Van_02_medevac_F"];

_vehiclesSupply append ["C_Van_01_box_F"];

_vehiclePlane append ["C_Plane_Civil_01_F","C_Plane_Civil_01_racing_F"];

_vehicleCivPlane append ["C_Plane_Civil_01_F","C_Plane_Civil_01_racing_F"];

_vehiclesCivCar append ["C_Kart_01_F","C_Offroad_01_F", "C_Hatchback_01_F", "C_Hatchback_01_sport_F", "C_SUV_01_F"];
_CivTruck append ["C_Truck_02_transport_F", "C_Truck_02_covered_F","C_Van_02_vehicle_F", "C_Van_02_transport_F"];
_civHelicopters append ["C_Heli_Light_01_civil_F", "a3a_C_Heli_Transport_02_F", "a3a_C_Heli_Light_02_blue_F"];

_CivBoat append ["C_Boat_Civil_01_F", "C_Rubberboat"];

_staticMG append ["I_G_HMG_02_high_F", "I_G_HMG_02_F"];
_staticAT append ["I_static_AT_F"];
_staticAA append ["I_static_AA_F"];
_staticMortars append ["I_G_Mortar_01_F"];

_MortarMagHE append ["8Rnd_82mm_Mo_shells"];
_MortarMagSmoke append ["8Rnd_82mm_Mo_Smoke_white"];

_minesAT append ["ATMine_Range_Mag", "SLAMDirectionalMine_Wire_Mag"];
_minesAPERS append ["ClaymoreDirectionalMine_Remote_Mag","APERSMine_Range_Mag", "APERSBoundingMine_Range_Mag", "APERSTripMine_Wire_Mag"];

_breachingExplosivesAPC append [["DemoCharge_Remote_Mag", 1]];
_breachingExplosivesTank append [["SatchelCharge_Remote_Mag", 1], ["DemoCharge_Remote_Mag", 2]];

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

_initialRebelEquipment append [
    "hgun_Pistol_heavy_02_F",
    "hgun_PDW2000_F",
    "30Rnd_9x21_Mag", "30Rnd_9x21_Red_Mag",
    "6Rnd_45ACP_Cylinder","MiniGrenade","SmokeShell",
    ["IEDUrbanSmall_Remote_Mag", 10], ["IEDLandSmall_Remote_Mag", 10], ["IEDUrbanBig_Remote_Mag", 3], ["IEDLandBig_Remote_Mag", 3],
    "B_FieldPack_oli","B_FieldPack_blk","B_FieldPack_khk",
    "V_BandollierB_blk","V_BandollierB_cbr","V_BandollierB_rgr","V_BandollierB_khk","V_BandollierB_oli","V_Rangemaster_belt",
    "Binocular",
    "acc_flashlight","acc_flashlight_smg_01","acc_flashlight_pistol",
    "B_FieldPack_blk","B_AssaultPack_blk",
    ["launch_RPG32_F", 2], ["RPG32_F", 6],
	"Chemlight_blue",
	"Chemlight_green",
	"Chemlight_red",
	"Chemlight_yellow",
	"B_CivilianBackpack_01_Everyday_Astra_F",
    "B_CivilianBackpack_01_Everyday_Black_F",
    "B_CivilianBackpack_01_Everyday_Vrana_F",
    "B_CivilianBackpack_01_Sport_Blue_F",
    "B_CivilianBackpack_01_Sport_Green_F",
    "B_CivilianBackpack_01_Sport_Red_F",
	"V_Pocketed_olive_F", 
    "V_Pocketed_coyote_F", 
    "V_Pocketed_black_F",
    "V_Plain_crystal_F",
    "B_LegStrapBag_black_F", 
    "V_LegStrapBag_coyote_F",
    "V_LegStrapBag_olive_F",
    "V_Safety_blue_F",
    "V_Safety_orange_F",
    "V_Safety_yellow_F",
	"B_Messenger_Black_F", 
    "B_Messenger_Coyote_F", 
    "B_Messenger_Gray_F",
    "B_Messenger_Olive_F"
];

_rebUniforms append [
    "U_IG_Guerilla1_1",
    "U_IG_Guerilla2_1",
    "U_IG_Guerilla2_2",
    "U_IG_Guerilla2_3",
    "U_IG_Guerilla3_1",
    "U_IG_leader",
    "U_IG_Guerrilla_6_1",
    "U_I_G_resistanceLeader_F",
    "U_I_L_Uniform_01_deserter_F",
    "U_C_HunterBody_grn",
	"U_C_ArtTShirt_01_v1_F",
    "U_C_ArtTShirt_01_v2_F",
    "U_C_ArtTShirt_01_v3_F",
    "U_C_ArtTShirt_01_v4_F",
    "U_C_ArtTShirt_01_v5_F",
    "U_C_ArtTShirt_01_v6_F",
	"U_C_ConstructionCoverall_Black_F",
    "U_C_ConstructionCoverall_Blue_F",
    "U_C_ConstructionCoverall_Red_F",
    "U_C_ConstructionCoverall_Vrana_F",
    "U_BG_Guerilla1_2_F",
    "U_C_Paramedic_01_F"
];

_headgear append [
    "H_Booniehat_khk_hs",
    "H_Booniehat_khk",
    "H_Booniehat_tan",
    "H_Booniehat_oli",    
    "H_Bandanna_gry",
    "H_Bandanna_blu",
    "H_Bandanna_cbr",    
    "H_Bandanna_khk_hs",
    "H_Bandanna_khk",
    "H_Bandanna_sgg",
    "H_Bandanna_sand",
    "H_Bandanna_surfer",
    "H_Bandanna_surfer_blk",
    "H_Bandanna_surfer_grn",
    "H_Bandanna_camo",
    "H_Watchcap_blk",
    "H_Watchcap_cbr",
    "H_Watchcap_camo",
    "H_Watchcap_khk",
    "H_Beret_blk",
    "H_Booniehat_khk_hs",
    "H_Booniehat_khk",
    "H_Booniehat_oli",
    "H_Booniehat_tan",
    "H_Cap_oli",
    "H_Cap_surfer",
    "H_Cap_tan",
    "H_Cap_oli_hs",
    "H_Cap_blk",
    "H_Cap_headphones",
    "H_Hat_blue",
    "H_Hat_brown",
    "H_Hat_camo",
    "H_Hat_checker",
    "H_Hat_grey",
    "H_Hat_tan",
    "H_Cap_marshal",
    "H_MilCap_blue",
    "H_MilCap_gry",
    "H_ShemagOpen_tan",
    "H_ShemagOpen_khk",
    "H_ShemagOpen_tan",
    "H_Shemag_olive_hs",
    "H_StrawHat",
    "H_StrawHat_dark",
	"H_EarProtectors_black_F",
    "H_EarProtectors_orange_F",
    "H_EarProtectors_red_F",
    "H_EarProtectors_white_F",
    "H_EarProtectors_yellow_F",
    "U_C_Paramedic_01_F",///
    "H_Construction_basic_black_F",
    "H_Construction_basic_orange_F",
    "H_Construction_basic_red_F",
    "H_Construction_basic_vrana_F",
    "H_Construction_basic_white_F",
    "H_Construction_basic_yellow_F",///
    "H_Construction_earprot_black_F",
    "H_Construction_earprot_orange_F",
    "H_Construction_earprot_red_F",
    "H_Construction_earprot_vrana_F",
    "H_Construction_earprot_white_F",
    "H_Construction_earprot_yellow_F",///
    "H_Construction_headset_black_F",
    "H_Construction_headset_orange_F",
    "H_Construction_headset_red_F",
    "H_Construction_headset_vrana_F",
    "H_Construction_headset_white_F",
    "H_Construction_headset_yellow_F",///
    "H_HeadBandage_clean_F",
    "H_HeadBandage_stained_F",
    "H_HeadBandage_bloody_F",
    "H_HeadSet_black_F",
    "H_HeadSet_orange_F",
    "H_HeadSet_red_F",
    "H_HeadSet_white_F",
    "H_HeadSet_yellow_F",
    "H_Hat_Safari_olive_F",
    "H_Hat_Safari_sand_F",
    "H_WirelessEarpiece_F"
];

/////////////////////
///  Identities   ///
/////////////////////

_faces append ["GreekHead_A3_01","GreekHead_A3_02","GreekHead_A3_10_a","GreekHead_A3_10_l",
"GreekHead_A3_10_sa","WhiteHead_01","WhiteHead_02","WhiteHead_18",
"WhiteHead_05","GreekHead_A3_07","WhiteHead_03","WhiteHead_04","GreekHead_A3_03",
"GreekHead_A3_04","WhiteHead_06","WhiteHead_07","GreekHead_A3_05","GreekHead_A3_06",
"WhiteHead_08","AfricanHead_02","AfricanHead_03","WhiteHead_09","GreekHead_A3_08",
"WhiteHead_16","WhiteHead_11", "WhiteHead_22_a", "WhiteHead_22_l",
"WhiteHead_22_sa", "WhiteHead_10", "WhiteHead_19", "WhiteHead_17", "WhiteHead_21", "WhiteHead_12", "WhiteHead_13",
"GreekHead_A3_09","WhiteHead_14","WhiteHead_15","WhiteHead_20","AfricanHead_01",
"GreekHead_A3_13","GreekHead_A3_14","GreekHead_A3_11",
"GreekHead_A3_12","WhiteHead_23",
"Barklem","Mavros","Sturrock","Ioannou",
"PersianHead_A3_01","PersianHead_A3_04_a","PersianHead_A3_04_l","PersianHead_A3_04_sa",
"PersianHead_A3_02","AsianHead_A3_02","AsianHead_A3_03","AsianHead_A3_01",
"PersianHead_A3_03"];
_voices append ["Male01GRE","Male02GRE","Male03GRE","Male04GRE","Male05GRE","Male06ENG","Male01GREVR","Male01ENG","Male02ENG","Male03ENG",
"Male04ENG","Male05ENG","Male06ENG","Male07ENG","Male08ENG","Male09ENG","Male10ENG","Male11ENG","Male12ENG","Male01ENGB",
"Male02ENGB","Male03ENGB","Male04ENGB","Male05ENGB","Male01ENGVR","Male01PER","Male02PER","Male03PER","Male01PERVR"];

_glasses append ["G_Lady_Blue","G_Shades_Black", "G_Shades_Blue", "G_Shades_Green", "G_Shades_Red", "G_Aviator", "G_Spectacles", "G_Spectacles_Tinted", "G_Sport_BlackWhite", "G_Sport_Blackyellow", "G_Sport_Greenblack", "G_Sport_Checkered", "G_Sport_Red", "G_Squares", "G_Squares_Tinted",
"G_Bandanna_blk", "G_Bandanna_oli", "G_Bandanna_khk", "G_Bandanna_tan", "G_Bandanna_beast", "G_Bandanna_shades", "G_Bandanna_sport", "G_Bandanna_aviator","G_Bandanna_BlueFlame1", "G_Bandanna_BlueFlame2", "G_Bandanna_CandySkull", "G_Bandanna_OrangeFlame1", "G_Bandanna_RedFlame1", "G_Bandanna_Skull1",
"G_Bandanna_Syndikat1", "G_Bandanna_Syndikat2","G_Bandanna_Skull2", "G_Bandanna_Vampire_01"];

_goggles append ["G_Lowprofile","G_Balaclava_blk", "G_Balaclava_BlueStrips", "G_Balaclava_Flecktarn", "G_Balaclava_Halloween_01", "G_Balaclava_lowprofile", "G_Balaclava_oli", "G_Balaclava_Flames1", "G_Balaclava_Scarecrow_01", "G_Balaclava_Skull1", "G_Balaclava_Tropentarn","G_Respirator_blue_F", "G_Respirator_white_F", "G_Respirator_yellow_F", "G_EyeProtectors_F", "G_EyeProtectors_Earpiece_F", "G_WirelessEarpiece_F"];
_vehiclesBasic append [];
_vehiclesLightUnarmed append ["SPE_US_G503_MB_noinsignia","SPE_US_G503_MB_Open_noinsignia"];
_vehiclesLightArmed append ["SPE_Milice_R200_MG34_noinsignia","SPE_US_G503_MB_M1919_Armoured_noinsignia","SPE_US_G503_MB_M1919_noinsignia","SPE_US_G503_MB_M2_Armoured_noinsignia","SPE_US_G503_MB_M2_noinsignia","SPE_US_G503_MB_M2_PATROL_noinsignia","SPE_US_G503_MB_M1919_PATROL_noinsignia"];
_vehiclesAt append [];
_VehTruck append ["SPE_FR_M3_Halftrack_Unarmed_Open_noinsignia","SPE_FR_M3_Halftrack_Unarmed_noinsignia","SPE_FR_M3_Halftrack_noinsignia","SPE_CCKW_353_noinsignia","SPE_CCKW_353_Open_noinsignia","SPE_CCKW_353_M2_noinsignia"];
_vehicleAA append ["SPE_FR_M16_Halftrack_noinsignia","SPE_OpelBlitz_Flak38_noinsignia"];

_vehiclesBoat append [];

_vehiclesMedical append ["SPE_FFI_OpelBlitz_Ambulance_noinsignia","SPE_FR_M3_Halftrack_Ambulance"];

_vehiclesSupply append [];

_vehiclePlane append [];

_vehicleCivPlane append [];

_vehiclesCivCar append ["SPE_Milice_R200_Unarmed_noinsignia", "SPE_Milice_R200_Hood_noinsignia"];
_CivTruck append ["SPE_FFI_OpelBlitz_noinsignia","SPE_FFI_OpelBlitz_Open_noinsignia"];
_civHelicopters append [];

_CivBoat append ["B_Boat_Transport_01_F"];

_staticMG append ["SPE_ST_MG34_Lafette_Deployed","SPE_ST_MG42_Lafette_Deployed","SPE_GER_SearchLight","SPE_FR_M1919A6_Bipod","SPE_FR_M1919_M2_Trench_Deployed"];
_staticAT append ["SPE_ST_FlaK_36","SPE_ST_Pak40","SPE_ST_leFH18_AT","SPE_FR_57mm_M1"];
_staticAA append ["SPE_ST_FlaK_36_AA","SPE_ST_FlaK_38"];
_staticMortars append ["SPE_MLE_27_31"];

_MortarMagHE append ["SPE_8Rnd_81mm_FA_Mle_1932_HE"];
_MortarMagSmoke append ["SPE_8Rnd_81mm_FA_Mle_1932_Smoke"];

_minesAT append ["SPE_US_M1A1_ATMINE_mag"];
_minesAPERS append ["SPE_US_M3_Pressure_MINE_mag"];

_breachingExplosivesAPC append [["SPE_Ladung_Small_MINE_mag", 1], ["SPE_Ladung_Big_MINE_mag", 1], ["SPE_US_TNT_half_pound_mag", 2], ["SPE_US_TNT_4pound_mag", 1]];
_breachingExplosivesTank append [["SPE_Ladung_Small_MINE_mag", 3], ["SPE_Ladung_Big_MINE_mag", 1], ["SPE_US_TNT_4pound_mag", 1], ["SPE_US_TNT_half_pound_mag", 8]];

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////

_initialRebelEquipment append [
    "SPE_M1903A3_Springfield",
    "SPE_ACC_M1905_Bayo",
    "SPE_ACC_GL_M1",
    "SPE_ACC_M1_Bayo",
    "SPE_5Rnd_762x63",
    "SPE_K98_Late",
    "SPE_ACC_GW_SB_Empty",
    "SPE_ACC_K98_Bayo",
    "SPE_5Rnd_792x57",
    "SPE_K98",
    "SPE_Fusil_Mle_208_12_Sawedoff",
    "SPE_Fusil_Mle_208_12",
    "SPE_2Rnd_12x65_Slug",
    "SPE_2Rnd_12x65_Pellets",
    "SPE_2Rnd_12x65_No4_Buck",
    "SPE_Rauchsichtzeichen_Orange",
    "SPE_NBK39b",
    "SPE_US_M18_Yellow",
    "SPE_US_M18_Violet",
    "SPE_US_M18_Red",
    "SPE_US_M18_Green",
    "SPE_US_M15",
    "SPE_Handrauchzeichen_Yellow",
    "SPE_Handrauchzeichen_Violet",
    "SPE_Handrauchzeichen_Red",
    "SPE_US_M18",
    "SPE_US_AN_M14",
    "SPE_US_Mk_2_Yellow",
    "SPE_US_Mk_2",
    "SPE_US_Mk_3",
    "SPE_M39",
    "SPE_Shg24",
    ["SPE_Shg24x7",20],
    ["SPE_TMI_42_MINE_mag",3],
    ["SPE_STMI_MINE_mag",5],
    ["SPE_SMI_35_1_MINE_mag",3],
    ["SPE_SMI_35_MINE_mag",5],
    ["SPE_SMI_35_Pressure_MINE_mag",5],
    ["SPE_Shg24x7_Improvised_Mine_mag",5],
    ["SPE_shumine_42_MINE_mag",5],
    ["SPE_US_M3_MINE_mag",5],
    ["SPE_US_M3_Pressure_MINE_mag",5],
    ["SPE_US_Bangalore_mag",5],
    ["SPE_US_M1A1_ATMINE_mag",5],
    "SPE_US_ItemCompass",
    "SPE_GER_ItemCompass",
    "SPE_GER_ItemCompass_deg",
    "SPE_US_ItemWatch",
    "SPE_GER_ItemWatch",
	["SPE_PzFaust_30m", 50],
    ["SPE_Ladung_Small_MINE_mag", 10], ["SPE_US_TNT_half_pound_mag", 10], ["SPE_US_TNT_4pound_mag", 3], ["SPE_Ladung_Big_MINE_mag", 3],
    "SPE_Shg24_Frag", "SPE_NB39", "SPE_US_Mk_1",
    "V_SPE_US_Vest_M1919", "V_SPE_DAK_VestKar98",
    "B_SPE_FFI_M36_Saboteur", "B_SPE_GER_MedicBackpack_Empty",
    "SPE_Binocular_US",
	"SPE_Binocular_GER"
];

_rebUniforms append [
"U_SPE_US_Tank_Crew2",
"U_SPE_US_Tank_Crew_camo",
"U_SPE_US_Tank_Crew",
"U_SPE_US_HBT44_late_roll",
"U_SPE_US_HBT44_late",
"U_SPE_US_HBT44_trop",
"U_SPE_US_HBT44_FrogSkin_Jungle_trop",
"U_SPE_US_Pilot_lthr",
"U_SPE_FR_Tank_Crew2",
"U_SPE_FR_HBT_Uniform_Trop",
"U_SPE_FR_Tank_Crew3",
"U_SPE_FR_Tank_Crew",
"U_SPE_FFI_Casual_1_trop",
"U_SPE_FFI_Casual_2",
"U_SPE_FFI_Casual_2_trop",
"U_SPE_FFI_Casual_4_trop",
"U_SPE_FFI_Casual_5",
"U_SPE_FFI_Casual_5_trop",
"U_SPE_FFI_Casual_7_trop",
"U_SPE_FFI_Jacket_bruin",
"U_SPE_FFI_Jacket_bruin_swetr",
"U_SPE_FFI_Jacket_grijs",
"U_SPE_FFI_Jacket_grijs_swetr",
"U_SPE_FFI_Jacket_zwart_Alt",
"U_SPE_FFI_Worker_2_trop",
"U_SPE_FFI_Worker_3_trop",
"U_SPE_FFI_Worker_4"
];

_headgear append [
	"H_SPE_CIV_Worker_Cap_1",
    "H_SPE_CIV_Worker_Cap_2",
    "H_SPE_CIV_Worker_Cap_3",
    "H_SPE_CIV_Fedora_Cap_3",
    "H_SPE_CIV_Fedora_Cap_4",
    "H_SPE_CIV_Fedora_Cap_2",
    "H_SPE_CIV_Fedora_Cap_1",
    "H_SPE_CIV_Fedora_Cap_6",
    "H_SPE_CIV_Fedora_Cap_5"
];

/////////////////////
///  Identities   ///
/////////////////////

_faces append [
"SPE_Davidson",
"SPE_bykov",
"SPE_boyartsev",
"SPE_Jeppson",
"SPE_Hauptmann",
"SPE_DAgostino",
"SPE_Ivanych",
"SPE_Arnold",
"SPE_Oberst",
"SPE_Krueger",
"SPE_Neumann",
"SPE_Walter",
"SPE_Connors",
"SPE_Kuzmin",
"SPE_Seppmeyer",
"SPE_OBrien",
"SPE_Grishka",
"SPE_Klimakov",
"SPE_Elliot",
"SPE_Vasiliev",
"SPE_Wolf"
];
_voices append ["SPE_Male02FRE","SPE_Male01FRE","SPE_Male02GER","SPE_Male01GER"];

_glasses append ["G_SPE_Sunglasses_GER_Red","G_SPE_Sunglasses_GER_Brown","G_SPE_Sunglasses_US_Yellow","G_SPE_Sunglasses_US_Red"];

_goggles append ["G_SPE_GER_Headset","G_SPE_Pipe_Sir_Winston","G_SPE_Polar_Goggles","G_SPE_SWDG_Goggles","G_SPE_Dust_Goggles","G_SPE_Ful_Vue","G_SPE_Ful_Vue_Reinforced","G_SPE_Dust_Goggles_2","G_SPE_Dienst_Brille","G_SPE_Cigarette_Strike_Outs","G_SPE_Cigarette_Grundstein","G_SPE_Cigarette_Belomorkanal","G_SPE_Cigar_Moza","G_SPE_Binoculars"];

if (isClass (configFile >> "CfgPatches" >> "WW2_SPEX_Assets_m_Vehicles_Planes_m")) then {
	_vehiclePlane pushBack "SPEX_C47_Skytrain";

	_vehicleCivPlane pushBack "SPEX_C47_CIV_Skytrain";

	_staticMortars pushBack "SPEX_M2_60";
};
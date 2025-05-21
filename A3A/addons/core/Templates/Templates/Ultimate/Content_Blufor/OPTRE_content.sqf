_vehiclesDropPod append ["OPTRE_HEV","OPTRE_Cryopod"];

_basic append ["OPTRE_m1087_stallion_device_unsc","OPTRE_M274_ATV","OPTRE_cart","OPTRE_EscapePod","OPTRE_Static_Base_Turret"];
_unarmedVehicles append ["OPTRE_M12_FAV_APC","OPTRE_M12_FAV","OPTRE_M813_TT","OPTRE_M12_FAV_APC_CMA","OPTRE_M12_FAV_CMA","OPTRE_M813_TT_CMA"];
_armedVehicles append ["OPTRE_M12_LRV","OPTRE_M12A1_LRV","OPTRE_M12G1_LRV","OPTRE_M12_LRV_CMA","OPTRE_M12_TD_CMA","OPTRE_M12A1_LRV_CMA","OPTRE_M12G1_LRV_CMA"];
_Trucks append ["OPTRE_m1087_stallion_unsc","OPTRE_m1087_stallion_cover_unsc","OPTRE_m1015_mule_cover_cma","OPTRE_m1015_mule_cma","OPTRE_M313_UNSC"];
_cargoTrucks append ["OPTRE_m1087_stallion_unsc","OPTRE_m1087_stallion_cover_unsc"];
_ammoTrucks append ["OPTRE_m1087_stallion_unsc_resupply","OPTRE_m1015_mule_ammo_cma"];
_repairTrucks append ["OPTRE_m1087_stallion_unsc_repair","OPTRE_M914_RV","OPTRE_M808R_Engineer_UNSC","OPTRE_m1015_mule_repair_cma","OPTRE_M914_RV_CMA","OPTRE_M808R_Engineer_CMA"];
_fuelTrucks append ["OPTRE_m1087_stallion_unsc_refuel","OPTRE_m1015_mule_fuel_cma"];
_medicalTrucks append ["OPTRE_m1087_stallion_unsc_medical","OPTRE_M12_FAV_APC_MED","OPTRE_m1015_mule_medical_cma","OPTRE_M12_FAV_APC_MED_CMA"];
_lightAPCs append ["OPTRE_M411_APC_UNSC","OPTRE_M493_APC","OPTRE_M493_AIE","OPTRE_M493_AIE_RCWS","OPTRE_M493_M37","OPTRE_M493_AIE_CMA"];
_APCs append ["OPTRE_M412_IFV_UNSC","OPTRE_M413_MGS_UNSC"];
_IFVs append ["OPTRE_M493_M37_RCWS","OPTRE_M494","OPTRE_M494_CMA"];
_airborneVehicles append ["OPTRE_M411_APC_UNSC","OPTRE_M493_APC","OPTRE_M493_AIE","OPTRE_M493_AIE_RCWS","OPTRE_M493_M37"];
_tanks append ["OPTRE_M808BM_UNSC","OPTRE_M808L","OPTRE_M808S","OPTRE_M850_UNSC","OPTRE_M808BM_UNSC_Driverless","OPTRE_M808S_Driverless","OPTRE_M850_UNSC_Driverless","OPTRE_M808BM_CMA","OPTRE_M808BM_CMA_Driverless"];
_lightTanks append ["OPTRE_M808B_UNSC","OPTRE_M808B_UNSC_Driverless","OPTRE_M808B_CMA","OPTRE_M808B_CMA_Driverless"];
_aa append ["OPTRE_M808B2","OPTRE_M808B2A1","OPTRE_M12R_AA","OPTRE_M808B2_Driverless","OPTRE_M808B2A1_Driverless","OPTRE_M12R_AA_CMA"];

_transportBoat append ["optre_catfish_unarmed_f"];
_gunBoat append ["optre_catfish_aa_f","optre_catfish_atgm_f","optre_catfish_gauss_f","optre_catfish_mg_f","optre_catfish_cma_mg_f","optre_catfish_cma_unarmed_f"];

_planesCAS append ["OPTRE_YSS_1000_A","OPTRE_YSS_1000_A_VTOL","OPTRE_YSS_1000_A_Single","OPTRE_YSS_1000_A_VTOL_Single"];
_planesAA append ["OPTRE_YSS_1000_A","OPTRE_YSS_1000_A_VTOL","OPTRE_YSS_1000_A_Single","OPTRE_YSS_1000_A_VTOL_Single"];

if (isClass (configFile >> "cfgVehicles" >> "OPAEX_Pelican_VTOL")) then {
	_planesTransport append ["OPAEX_Pelican_VTOL","OPAEX_Pelican_VTOL_Armed"];
	_gunship append ["OPAEX_Pelican_VTOL","OPAEX_Pelican_VTOL_Armed"];
} else {
	_planesTransport append ["OPTRE_Pelican_armed","OPTRE_Pelican_armed_single_seater","OPTRE_Pelican_armed_70mm","OPTRE_Pelican_armed_70mm_single_seater","OPTRE_Pelican_armed_SOCOM"];
};
//_planesTransport append [];
_gunship append ["OPTRE_Pelican_armed","OPTRE_Pelican_armed_single_seater","OPTRE_Pelican_armed_70mm","OPTRE_Pelican_armed_70mm_single_seater","OPTRE_Pelican_armed_SOCOM"];

_helisLight append ["OPTRE_UNSC_falcon_medical","OPTRE_UNSC_falcon_PD","OPTRE_CMA_falcon_unarmed","OPTRE_DME_falcon_unarmed"];
_transportHelicopters append ["OPTRE_Pelican_unarmed","OPTRE_Pelican_unarmed_SOCOM","OPTRE_Pelican_armed","OPTRE_Pelican_armed_single_seater","OPTRE_Pelican_armed_70mm","OPTRE_Pelican_armed_70mm_single_seater","OPTRE_Pelican_armed_SOCOM","OPTRE_Pelican_unarmed_PD","OPTRE_DME_SOCOM_Pelican","OPTRE_Pelican_unarmed_CMA","OPTRE_Pelican_armed_CMA"];
_helisLightAttack append ["OPTRE_UNSC_hornet_CAP","OPTRE_UNSC_hornet_CAS","OPTRE_UNSC_MH_144_Falcon","OPTRE_UNSC_falcon_armed","OPTRE_UNSC_MH_144S_Falcon","OPTRE_UNSC_UH_144S_Falcon_DAP","OPTRE_DME_hornet","OPTRE_DME_falcon_armed","OPTRE_CMA_falcon_armed_S","OPTRE_CMA_hornet","OPTRE_CMA_MH_144_Falcon","OPTRE_CMA_falcon","OPTRE_CMA_MHS_144_Falcon","OPTRE_CMA_UH_144_Falcon_DAP","OPTRE_CMA_falcon_S","OPTRE_CMA_UH_144S_Falcon_DAP"];
_helisAttack append ["OPTRE_AV22C_Sparrowhawk","OPTRE_AV22A_Sparrowhawk","OPTRE_AV22_Sparrowhawk","OPTRE_AV22B_Sparrowhawk"];

_airPatrol append ["OPTRE_UNSC_hornet_CAP","OPTRE_UNSC_hornet_CAS","OPTRE_UNSC_MH_144_Falcon","OPTRE_UNSC_falcon_armed","OPTRE_UNSC_MH_144S_Falcon","OPTRE_UNSC_UH_144S_Falcon_DAP","OPTRE_DME_hornet","OPTRE_DME_falcon_armed","OPTRE_CMA_falcon_armed_S","OPTRE_CMA_hornet","OPTRE_CMA_MH_144_Falcon","OPTRE_CMA_falcon","OPTRE_CMA_MHS_144_Falcon","OPTRE_CMA_UH_144_Falcon_DAP","OPTRE_CMA_falcon_S","OPTRE_CMA_UH_144S_Falcon_DAP"];

_artillery append ["OPTRE_M875_SPH","OPTRE_m1015_mule_mlr_cma","OPTRE_M875_SPH_CMA"];

_uavsAttack append ["OPTRE_Wombat_S","OPTRE_Wombat","OPTRE_Wombat_B","OPTRE_Wombat_CMA","OPTRE_Wombat_B_CMA","OPTRE_Wombat_S_CMA"];
_uavsPortable append ["B_UAV_01_F"];

_militiaLightArmed append ["OPTRE_M12_LRV","OPTRE_M12_LRV_DME"];
_militiaTrucks append ["OPTRE_m1087_stallion_unsc","OPTRE_m1087_stallion_cover_unsc"];
_militiaCars append ["OPTRE_M12_FAV","OPTRE_DME_M12_FAV"];
_militiaAPCs append ["OPTRE_M411_APC_UNSC"]; 

_policeVehs append ["OPTRE_Genet_Police","OPTRE_M12_FAV_APC_PD","OPTRE_M12_LRV_PD","OPTRE_M12_FAV_PD","OPTRE_M813_TT_Police","OPTRE_M914_RV_PD"];

_staticMG append ["OPTRE_AIE_486H_Static_HMG","OPTRE_AIE_486H_Static_HMG_Spartan","OPTRE_AIE_486H_Static_HMG_Standalone","OPTRE_AIE_486H_Static_HMG_Standalone_Spartan","OPTRE_Static_M247H_Tripod","OPTRE_Static_M247H_Shielded_Tripod","OPTRE_Static_M247H_Spartan_Tripod","OPTRE_Static_M247H_Shielded_Spartan_Tripod","OPTRE_Static_M247T_Tripod","OPTRE_Static_M247T_Spartan_Tripod","OPTRE_Static_M247T_Tripod_CMA"];
_staticAT append ["OPTRE_Static_ATGM","OPTRE_Static_Gauss","OPTRE_Scythe","OPTRE_Static_ATGM_CMA","OPTRE_Static_FG75_CMA","OPTRE_Static_Gauss_CMA","OPTRE_Scythe_CMA"];
_staticAA append ["OPTRE_LAU65D_pod","OPTRE_Static_M41","OPTRE_Static_AA","OPTRE_Static_M41_CMA","OPTRE_Static_AA_CMA"];
_staticMortars append ["OPTRE_AU_44_Mortar","OPTRE_AU_44_Mortar_Spartan","OPTRE_AU_44_Mortar_Standalone","OPTRE_AU_44_Mortar_Standalone_Spartan","OPTRE_AU_44_DME_Mortar"];

_radar append ["OPTRE_Scythe_AA"];
_SAM append ["OPTRE_Scythe","OPTRE_Scythe_AA","OPTRE_Corvette_M910_Turret","OPTRE_Lance","OPTRE_Lance_CMA"];

_mortarMagazineHE append ["OPTRE_10Rnd_122mm_SABOT_81mm_Mo_shells"];
_mortarMagazineSmoke append ["OPTRE_10Rnd_122mm_Mo_Smoke_white"];
_mortarMagazineFlare append ["OPTRE_10Rnd_122mm_Mo_Flare_white"];

_minefieldAT append ["OPTRE_Placed_Mine"];
_minefieldAPERS append ["APERSMine"];

_baseClassSquadLeaderArray append ["OPTRE_UNSC_Army_Soldier_SquadLead_DES","OPTRE_UNSC_Army_Soldier_TeamLead_DES","OPTRE_UNSC_Marine_Soldier_SquadLead",
"OPTRE_UNSC_Marine_Soldier_TeamLead","OPTRE_UNSC_ODST_Soldier_TeamLeader","OPTRE_UNSC_Army_Soldier_SquadLead_OLI",
"OPTRE_UNSC_Army_Soldier_TeamLead_OLI","OPTRE_UNSC_Army_Soldier_SquadLead_SNO","OPTRE_UNSC_Army_Soldier_TeamLead_SNO","OPTRE_Spartan2_Soldier_TeamLeader",
"OPTRE_Spartan3_Soldier_TeamLeader","OPTRE_UNSC_Army_Soldier_SquadLead_TRO","OPTRE_UNSC_Army_Soldier_TeamLead_TRO","OPTRE_UNSC_Army_Soldier_SquadLead_URB",
"OPTRE_UNSC_Army_Soldier_TeamLead_URB","OPTRE_UNSC_Army_Soldier_SquadLead_WDL","OPTRE_UNSC_Army_Soldier_TeamLead_WDL","OPTRE_CMA_Army_Soldier_SquadLead",
"OPTRE_CMA_Army_Soldier_TeamLead","OPTRE_Ins_DME_TeamLeader"];
_baseClassRiflemanArray append ["OPTRE_UNSC_Army_Soldier_Assist_Autorifleman_DES","OPTRE_UNSC_Army_Soldier_Breacher_DES","OPTRE_UNSC_Army_Soldier_Breacher2_DES",
"OPTRE_UNSC_Army_Soldier_ForwardObserver_DES","OPTRE_UNSC_Army_Soldier_Paratrooper_AR_DES","OPTRE_UNSC_Army_Soldier_Rifleman_BR_DES",
"OPTRE_UNSC_Army_Soldier_Rifleman_Light_DES","OPTRE_UNSC_Army_Soldier_Rifleman_AR_DES","OPTRE_UNSC_Marine_Soldier_Assist_Autorifleman",
"OPTRE_UNSC_Marine_Soldier_Breacher","OPTRE_UNSC_Marine_Soldier_Breacher2","OPTRE_UNSC_Marine_Soldier_Corpsman",
"OPTRE_UNSC_Marine_Soldier_ForwardObserver","OPTRE_UNSC_Marine_Soldier_Paratrooper_AR","OPTRE_UNSC_Marine_Soldier_Rifleman_BR",
"OPTRE_UNSC_Marine_Soldier_Rifleman_Light","OPTRE_UNSC_Marine_Soldier_Rifleman_AR","OPTRE_UNSC_Navy_Soldier_SCPO","OPTRE_UNSC_ODST_Soldier_Breacher",
"OPTRE_UNSC_ODST_Soldier_Breacher2","OPTRE_UNSC_ODST_Soldier_Bullfrog","OPTRE_UNSC_ODST_Soldier_Rifleman_BR","OPTRE_UNSC_ODST_Soldier_Rifleman_AR",
"OPTRE_UNSC_ODST_Soldier_Scout","OPTRE_UNSC_ODST_Soldier_M6D","OPTRE_UNSC_Army_Soldier_Assist_Autorifleman_OLI","OPTRE_UNSC_Army_Soldier_Breacher_OLI",
"OPTRE_UNSC_Army_Soldier_Breacher2_OLI","OPTRE_UNSC_Army_Soldier_ForwardObserver_OLI","OPTRE_UNSC_Army_Soldier_Paratrooper_AR_OLI","OPTRE_UNSC_Army_Soldier_Rifleman_BR_OLI",
"OPTRE_UNSC_Army_Soldier_Rifleman_Light_OLI","OPTRE_UNSC_Army_Soldier_Rifleman_AR_OLI","OPTRE_ONI_Researcher_Armed2","OPTRE_ONI_Researcher_Armed",
"OPTRE_UNSC_ONI_Soldier_Operative","OPTRE_UNSC_ONI_Soldier_Operative2","OPTRE_UNSC_Army_Soldier_Assist_Autorifleman_SNO","OPTRE_UNSC_Army_Soldier_Breacher_SNO",
"OPTRE_UNSC_Army_Soldier_Breacher2_SNO","OPTRE_UNSC_Army_Soldier_ForwardObserver_SNO","OPTRE_UNSC_Army_Soldier_Paratrooper_AR_SNO",
"OPTRE_UNSC_Army_Soldier_Rifleman_BR_SNO","OPTRE_UNSC_Army_Soldier_Rifleman_Light_SNO","OPTRE_UNSC_Army_Soldier_Rifleman_AR_SNO",
"OPTRE_Spartan2_Soldier_Corpsman","OPTRE_Spartan2_Soldier_Rifleman_BR","OPTRE_Spartan2_Soldier_Rifleman_AR","OPTRE_Spartan2_Soldier_Scout",
"OPTRE_Spartan3_Soldier_Corpsman","OPTRE_Spartan3_Soldier_Rifleman_BR","OPTRE_Spartan3_Soldier_Rifleman_AR","OPTRE_Spartan3_Soldier_Scout",
"OPTRE_UNSC_ODST_Soldier_Deltagamer","OPTRE_UNSC_ODST_Soldier_Jedi","OPTRE_UNSC_ODST_Soldier_Lumnuon","OPTRE_UNSC_ODST_Soldier_McDaniel",
"OPTRE_UNSC_ODST_Soldier_Nightovizard","OPTRE_UNSC_ODST_Soldier_Scorch","OPTRE_UNSC_ODST_Soldier_Scouter407",
"OPTRE_UNSC_Army_Soldier_Assist_Autorifleman_TRO","OPTRE_UNSC_Army_Soldier_Breacher_TRO","OPTRE_UNSC_Army_Soldier_Breacher2_TRO",
"OPTRE_UNSC_Army_Soldier_ForwardObserver_TRO","OPTRE_UNSC_Army_Soldier_Paratrooper_AR_TRO","OPTRE_UNSC_Army_Soldier_Rifleman_BR_TRO",
"OPTRE_UNSC_Army_Soldier_Rifleman_Light_TRO","OPTRE_UNSC_Army_Soldier_Rifleman_AR_TRO","OPTRE_UNSC_Army_Soldier_Assist_Autorifleman_URB",
"OPTRE_UNSC_Army_Soldier_Breacher_URB","OPTRE_UNSC_Army_Soldier_Breacher2_URB","OPTRE_UNSC_Army_Soldier_ForwardObserver_URB",
"OPTRE_UNSC_Army_Soldier_Paratrooper_AR_URB","OPTRE_UNSC_Army_Soldier_Rifleman_BR_URB","OPTRE_UNSC_Army_Soldier_Rifleman_Light_URB","OPTRE_UNSC_Army_Soldier_Rifleman_AR_URB",
"OPTRE_UNSC_Army_Soldier_Assist_Autorifleman_WDL","OPTRE_UNSC_Army_Soldier_Breacher_WDL","OPTRE_UNSC_Army_Soldier_Breacher2_WDL",
"OPTRE_UNSC_Army_Soldier_ForwardObserver_WDL","OPTRE_UNSC_Army_Soldier_Paratrooper_AR_WDL","OPTRE_UNSC_Army_Soldier_Rifleman_BR_WDL","OPTRE_UNSC_Army_Soldier_Rifleman_Light_WDL",
"OPTRE_UNSC_Army_Soldier_Rifleman_AR_WDL","OPTRE_CMA_Army_Soldier_Assist_Autorifleman","OPTRE_CMA_Army_Soldier_Breacher","OPTRE_CMA_Army_Soldier_Breacher2",
"OPTRE_CMA_Army_Soldier_ForwardObserver","OPTRE_CMA_Army_Soldier_Rifleman_BR","OPTRE_CMA_Army_Soldier_Rifleman_HMG38","OPTRE_CMA_Army_Soldier_Rifleman_Light",
"OPTRE_CMA_Army_Soldier_Rifleman_AR","OPTRE_CMA_Army_Soldier_Rifleman_VK78","OPTRE_CPD_Riot_Officer","OPTRE_CPD_SWAT","OPTRE_CPD_SWAT_Bulldog",
"OPTRE_CPD_SWAT_M392","OPTRE_CPD_SWAT_M45","OPTRE_CPD_SWAT_M7","OPTRE_CPD_SWAT_MA37K","OPTRE_CPD_SWAT_RIOTCQQS48","OPTRE_CPD_SWAT_RIOTM7",
"OPTRE_CPD_SWAT_VK78","OPTRE_Ins_DME_Breacher","OPTRE_Ins_DME_Rifleman","OPTRE_Ins_DME_Rifleman_VK78"];
_baseClassRadiomanArray append ["OPTRE_UNSC_Army_Soldier_Radioman_DES","OPTRE_UNSC_Marine_Soldier_Radioman","OPTRE_UNSC_Army_Soldier_Radioman_OLI",
"OPTRE_UNSC_Army_Soldier_Radioman_SNO","OPTRE_UNSC_Army_Soldier_Radioman_TRO","OPTRE_UNSC_Army_Soldier_Radioman_URB","OPTRE_UNSC_Army_Soldier_Radioman_WDL",
"OPTRE_CMA_Army_Soldier_Radioman","OPTRE_CPD_Radio_Operator"];
_baseClassMedicArray append ["OPTRE_UNSC_Army_Soldier_Medic_DES","OPTRE_UNSC_ODST_Soldier_Paramedic","OPTRE_UNSC_Army_Soldier_Medic_OLI",
"OPTRE_UNSC_Army_Soldier_Medic_SNO","OPTRE_UNSC_Army_Soldier_Medic_TRO","OPTRE_UNSC_Army_Soldier_Medic_URB","OPTRE_UNSC_Army_Soldier_Medic_WDL",
"OPTRE_CMA_Army_Soldier_Medic","OPTRE_CPD_Medic"];
_baseClassEngineerArray append ["OPTRE_UNSC_Army_Soldier_Engineer_DES","OPTRE_UNSC_Marine_Soldier_Engineer","OPTRE_UNSC_Army_Soldier_Engineer_OLI",
"OPTRE_UNSC_Army_Soldier_Engineer_SNO","OPTRE_Spartan2_Soldier_Engineer","OPTRE_Spartan3_Soldier_Engineer","OPTRE_UNSC_Army_Soldier_Engineer_TRO",
"OPTRE_UNSC_Army_Soldier_Engineer_URB","OPTRE_UNSC_Army_Soldier_Engineer_WDL","OPTRE_CMA_Army_Soldier_Engineer"];
_baseClassExplosivesArray append ["OPTRE_UNSC_Army_Soldier_Demolitions_DES","OPTRE_UNSC_Marine_Soldier_Demolitions",
"OPTRE_UNSC_ODST_Soldier_DemolitionsExpert","OPTRE_UNSC_Army_Soldier_Demolitions_OLI","OPTRE_UNSC_Army_Soldier_Demolitions_SNO",
"OPTRE_UNSC_Army_Soldier_Demolitions_TRO","OPTRE_UNSC_Army_Soldier_Demolitions_URB","OPTRE_UNSC_Army_Soldier_Demolitions_WDL",
"OPTRE_CMA_Army_Soldier_Demolitions","OPTRE_CPD_Demolitions_Expert"];
_baseClassGrenadierArray append ["OPTRE_UNSC_Army_Soldier_Grenadier_DES","OPTRE_UNSC_Army_Soldier_Grenadier_DES2","OPTRE_UNSC_Marine_Soldier_Grenadier",
"OPTRE_UNSC_Marine_Soldier_Grenadier2","OPTRE_UNSC_Army_Soldier_Grenadier_OLI","OPTRE_UNSC_Army_Soldier_Grenadier_OLI2","OPTRE_UNSC_Army_Soldier_Grenadier_SNO",
"OPTRE_UNSC_Army_Soldier_Grenadier_SNO2","OPTRE_UNSC_Army_Soldier_Grenadier_TRO","OPTRE_UNSC_Army_Soldier_Grenadier_TRO2","OPTRE_UNSC_Army_Soldier_Grenadier_URB",
"OPTRE_UNSC_Army_Soldier_Grenadier_URB2","OPTRE_UNSC_Army_Soldier_Grenadier_WDL","OPTRE_UNSC_Army_Soldier_Grenadier_WDL2",
"OPTRE_CMA_Army_Soldier_Grenadier","OPTRE_CMA_Army_Soldier_Grenadier2","OPTRE_Ins_DME_Rifleman_Grenadier","OPTRE_Ins_DME_Rifleman_Grenadier2"];
_baseClassLATArray append ["OPTRE_UNSC_Army_Soldier_AT_Specialist_DES","OPTRE_UNSC_Army_Soldier_Rifleman_AT_DES",
"OPTRE_UNSC_Marine_Soldier_AT_Specialist","OPTRE_UNSC_Marine_Soldier_Rifleman_AT","OPTRE_UNSC_ODST_Soldier_Rifleman_AT","OPTRE_UNSC_Army_Soldier_AT_Specialist_OLI",
"OPTRE_UNSC_Army_Soldier_Rifleman_AT_OLI","OPTRE_UNSC_Army_Soldier_AT_Specialist_SNO","OPTRE_UNSC_Army_Soldier_Rifleman_AT_SNO","OPTRE_Spartan2_Soldier_Rifleman_AT",
"OPTRE_Spartan3_Soldier_Rifleman_AT","OPTRE_UNSC_Army_Soldier_AT_Specialist_TRO","OPTRE_UNSC_Army_Soldier_Rifleman_AT_TRO","OPTRE_UNSC_Army_Soldier_AT_Specialist_URB",
"OPTRE_UNSC_Army_Soldier_Rifleman_AT_URB","OPTRE_UNSC_Army_Soldier_AT_Specialist_WDL","OPTRE_UNSC_Army_Soldier_Rifleman_AT_WDL","OPTRE_CMA_Army_Soldier_AT_Specialist",
"OPTRE_CMA_Army_Soldier_Rifleman_AT","OPTRE_Ins_DME_Rifleman_AT","OPTRE_UNSC_ODST_Soldier_Scout_AT"];
_baseClassATArray append ["OPTRE_UNSC_Army_Soldier_AT_Specialist_DES","OPTRE_UNSC_Army_Soldier_Rifleman_AT_DES",
"OPTRE_UNSC_Marine_Soldier_AT_Specialist","OPTRE_UNSC_Marine_Soldier_Rifleman_AT","OPTRE_UNSC_ODST_Soldier_Rifleman_AT","OPTRE_UNSC_Army_Soldier_AT_Specialist_OLI",
"OPTRE_UNSC_Army_Soldier_Rifleman_AT_OLI","OPTRE_UNSC_Army_Soldier_AT_Specialist_SNO","OPTRE_UNSC_Army_Soldier_Rifleman_AT_SNO","OPTRE_Spartan2_Soldier_Rifleman_AT",
"OPTRE_Spartan3_Soldier_Rifleman_AT","OPTRE_UNSC_Army_Soldier_AT_Specialist_TRO","OPTRE_UNSC_Army_Soldier_Rifleman_AT_TRO","OPTRE_UNSC_Army_Soldier_AT_Specialist_URB",
"OPTRE_UNSC_Army_Soldier_Rifleman_AT_URB","OPTRE_UNSC_Army_Soldier_AT_Specialist_WDL","OPTRE_UNSC_Army_Soldier_Rifleman_AT_WDL","OPTRE_CMA_Army_Soldier_AT_Specialist",
"OPTRE_CMA_Army_Soldier_Rifleman_AT","OPTRE_Ins_DME_Rifleman_AT","OPTRE_UNSC_ODST_Soldier_Scout_AT"];
_baseClassAAArray append ["OPTRE_UNSC_Army_Soldier_AA_Specialist_DES","OPTRE_UNSC_Marine_Soldier_AA_Specialist","OPTRE_UNSC_Army_Soldier_AA_Specialist_OLI",
"OPTRE_UNSC_Army_Soldier_AA_Specialist_SNO","OPTRE_UNSC_Army_Soldier_AA_Specialist_TRO","OPTRE_UNSC_Army_Soldier_AA_Specialist_URB","OPTRE_UNSC_Army_Soldier_AA_Specialist_WDL",
"OPTRE_CMA_Army_Soldier_AA_Specialist"];
_baseClassMachineGunnerArray append ["OPTRE_UNSC_Army_Soldier_Autorifleman_DES","OPTRE_UNSC_Marine_Soldier_Autorifleman","OPTRE_UNSC_ODST_Soldier_Automatic_Rifleman",
"OPTRE_UNSC_Army_Soldier_Autorifleman_OLI","OPTRE_UNSC_Army_Soldier_Autorifleman_SNO","OPTRE_Spartan2_Soldier_Automatic_Rifleman","OPTRE_Spartan3_Soldier_Automatic_Rifleman",
"OPTRE_UNSC_Army_Soldier_Autorifleman_TRO","OPTRE_UNSC_Army_Soldier_Autorifleman_URB","OPTRE_UNSC_Army_Soldier_Autorifleman_WDL",
"OPTRE_CMA_Army_Soldier_Autorifleman","OPTRE_CPD_Juggernaut","OPTRE_Ins_DME_Autorifleman"];
_baseClassMarksmanArray append ["OPTRE_UNSC_Army_Soldier_Marksman_DES","OPTRE_UNSC_Marine_Soldier_Marksman","OPTRE_UNSC_ODST_Soldier_Marksman",
"OPTRE_UNSC_Army_Soldier_Marksman_OLI","OPTRE_UNSC_Army_Soldier_Marksman_SNO","OPTRE_Spartan2_Soldier_Marksman","OPTRE_Spartan3_Soldier_Marksman",
"OPTRE_UNSC_Army_Soldier_Marksman_TRO","OPTRE_UNSC_Army_Soldier_Marksman_URB","OPTRE_UNSC_Army_Soldier_Marksman_WDL",
"OPTRE_CMA_Army_Soldier_Marksman","OPTRE_Ins_DME_Marksman"];
_baseClassSniperArray append ["OPTRE_UNSC_Marine_Soldier_Sniper","OPTRE_UNSC_ODST_Soldier_Scout_Sniper","OPTRE_UNSC_Army_Soldier_Sniper_SNO",
"OPTRE_Spartan2_Soldier_Scout_Sniper","OPTRE_Spartan3_Soldier_Scout_Sniper","OPTRE_UNSC_Army_Soldier_Sniper_URB",
"OPTRE_CMA_Army_Soldier_Sniper","OPTRE_CPD_SWAT_SRS99","OPTRE_CPD_SWAT_Tactical_Sniper","OPTRE_Ins_DME_Tactical_Sniper"];
_baseClassPatrolSniperArray append ["OPTRE_UNSC_Army_Soldier_Sniper_DES","OPTRE_UNSC_Army_Soldier_Sniper_OLI","OPTRE_UNSC_Army_Soldier_Sniper_TRO","OPTRE_UNSC_Army_Soldier_Sniper_WDL"];
_baseClassPatrolSpotterArray append ["OPTRE_UNSC_Army_Soldier_Sniper_DES","OPTRE_UNSC_Army_Soldier_Sniper_OLI","OPTRE_UNSC_Army_Soldier_Sniper_TRO","OPTRE_UNSC_Army_Soldier_Sniper_WDL"];
// ================== Специальные роли ==================
_baseClassPoliceArray append ["OPTRE_CPD_Demolitions_Expert","OPTRE_CPD_Juggernaut","OPTRE_CPD_Medic","OPTRE_CPD_Officer_M392","OPTRE_CPD_Officer_M45","OPTRE_CPD_Officer_M6D_Carbine","OPTRE_CPD_Officer_M7","OPTRE_CPD_Officer_MA37K","OPTRE_CPD_Radio_Operator","OPTRE_CPD_Riot_Officer","OPTRE_CPD_SWAT","OPTRE_CPD_SWAT_Bulldog","OPTRE_CPD_SWAT_M392","OPTRE_CPD_SWAT_M45","OPTRE_CPD_SWAT_M7","OPTRE_CPD_SWAT_MA37K","OPTRE_CPD_SWAT_RIOTCQQS48","OPTRE_CPD_SWAT_RIOTM7","OPTRE_CPD_SWAT_SRS99","OPTRE_CPD_SWAT_Tactical_Sniper","OPTRE_CPD_SWAT_VK78"];

_baseClassCrewArray append ["OPTRE_UNSC_Army_Soldier_Crewman_DES","OPTRE_UNSC_Army_Soldier_Crewman_DES_Heavy","OPTRE_UNSC_Marine_Soldier_Crewman",
"OPTRE_UNSC_Marine_Soldier_Crewman_Heavy","OPTRE_UNSC_Navy_Soldier_Blue","OPTRE_UNSC_Navy_Soldier_Gray","OPTRE_UNSC_Navy_Soldier_Orange","OPTRE_UNSC_Navy_Soldier_Yellow","OPTRE_UNSC_Navy_Soldier_White",
"OPTRE_UNSC_Navy_Soldier_Red","OPTRE_UNSC_Navy_Soldier_Red_HVY","OPTRE_UNSC_Navy_Soldier_Red_LT","OPTRE_UNSC_Navy_Soldier_Red_SG",
"OPTRE_UNSC_Navy_Soldier_Red_SMG","OPTRE_UNSC_Army_Soldier_Crewman_OLI","OPTRE_UNSC_Army_Soldier_Crewman_OLI_Heavy","OPTRE_UNSC_Army_Soldier_Crewman_SNO",
"OPTRE_UNSC_Army_Soldier_Crewman_SNO_Heavy","OPTRE_UNSC_Army_Soldier_Crewman_TRO","OPTRE_UNSC_Army_Soldier_Crewman_TRO_Heavy","OPTRE_UNSC_Army_Soldier_Crewman_URB",
"OPTRE_UNSC_Army_Soldier_Crewman_URB_Heavy","OPTRE_UNSC_Army_Soldier_Crewman_WDL","OPTRE_UNSC_Army_Soldier_Crewman_WDL_Heavy","OPTRE_CMA_Army_Soldier_Crewman"];
_baseClassPilotArray append ["OPTRE_UNSC_Airforce_Soldier_Airman","OPTRE_UNSC_Marine_Pilot","OPTRE_UNSC_Navy_Soldier_Olive",
"OPTRE_CMA_Army_Soldier_Airman","OPTRE_CPD_Pilot"];
_baseClassOfficialArray append ["OPTRE_UNSC_Army_Soldier_Officer_DES","OPTRE_UNSC_Marine_Soldier_Officer","OPTRE_UNSC_Navy_Officer_Dress_Armed",
"OPTRE_UNSC_Navy_Officer_Dress","OPTRE_UNSC_Army_Soldier_Officer_OLI","OPTRE_UNSC_ONI_Soldier_Naval","OPTRE_UNSC_ONI_Soldier_Naval_Unarmed",
"OPTRE_UNSC_Army_Soldier_Officer_SNO","OPTRE_UNSC_Army_Soldier_Officer_TRO","OPTRE_UNSC_Army_Soldier_Officer_URB","OPTRE_UNSC_Army_Soldier_Officer_WDL",
"OPTRE_CMA_Army_Soldier_Officer","OPTRE_CPD_Officer","OPTRE_CPD_Officer_M392","OPTRE_CPD_Officer_M45","OPTRE_CPD_Officer_M6D_Carbine","OPTRE_CPD_Officer_M7","OPTRE_CPD_Officer_MA37K"];
_baseClassTraitorArray append ["OPTRE_Ins_DME_Contractor","OPTRE_Ins_ER_Warlord","OPTRE_Ins_BIA_AutoRifleman","OPTRE_Ins_BIA_RTO","OPTRE_Ins_BIA_Rifleman","OPTRE_Ins_BIA_Sniper","OPTRE_Ins_ER_Assassin","OPTRE_Ins_ER_Deserter_GL","OPTRE_Ins_ER_Farmer","OPTRE_Ins_ER_Guerilla_AR","OPTRE_Ins_ER_Hacker","OPTRE_Ins_ER_Insurgent_BR","OPTRE_Ins_ER_Militia_MG","OPTRE_Ins_ER_Mortar_Thrower","OPTRE_Ins_ER_Rebel_AT","OPTRE_Ins_ER_Surgeon","OPTRE_Ins_ER_Terrorist","OPTRE_Ins_ER_Unarmed"];
_baseClassUnarmedArray append ["OPTRE_UNSC_Army_Soldier_Unarmed_DES","OPTRE_UNSC_Marine_Soldier_Unarmed","OPTRE_UNSC_Navy_Soldier_Olive_Unarmed","OPTRE_UNSC_Navy_Soldier_Blue_Unarmed",
"OPTRE_UNSC_Navy_Soldier_Gray_Unarmed","OPTRE_UNSC_Navy_Soldier_Orange_Unarmed","OPTRE_UNSC_Navy_Soldier_Yellow_unarmed",
"OPTRE_UNSC_Navy_Soldier_White_Unarmed","OPTRE_UNSC_Navy_Soldier_Red_Unarmed","OPTRE_UNSC_Army_Soldier_Unarmed_OLI","OPTRE_ONI_Researcher","OPTRE_ONI_Researcher_Light",
"OPTRE_UNSC_Army_Soldier_Unarmed_SNO","OPTRE_Spartan2_Soldier","OPTRE_Spartan3_Soldier","OPTRE_UNSC_Army_Soldier_Unarmed_TRO","OPTRE_UNSC_Army_Soldier_Unarmed_URB",
"OPTRE_UNSC_Army_Soldier_Unarmed_WDL","OPTRE_CMA_Army_Soldier_Unarmed"];

_voices append ["Male01GRE","Male02GRE","Male03GRE","Male04GRE","Male05GRE","Male06ENG","Male01GREVR","Male01ENG","Male02ENG","Male03ENG","Male04ENG","Male05ENG","Male06ENG","Male07ENG","Male08ENG","Male09ENG","Male10ENG","Male11ENG","Male12ENG","Male01ENGB","Male02ENGB","Male03ENGB","Male04ENGB","Male05ENGB"];
_faces append ["Spartan_WhiteHead_01","Spartan_WhiteHead_02","Spartan_WhiteHead_05","Spartan_WhiteHead_03","Spartan_WhiteHead_04"];

_insignia append [
	"OPTRE_Insignia_emblems_blackwidow",
	"OPTRE_Insignia_emblems_bull",
	"OPTRE_Insignia_emblems_cartridges",
	"OPTRE_Insignia_emblems_cone",
	"OPTRE_Insignia_emblems_crosshairs",
	"DME",
	"OPTRE_Insignia_emblems_fox",
	"OPTRE_Insignia_emblems_hazmat",
	"OPTRE_Insignia_emblems_hornet",
	"OPTRE_Insignia_emblems_jollyroger",
	"OPTRE_Insignia_emblems_keepitclean",
	"OPTRE_Insignia_emblems_king",
	"OPTRE_Insignia_emblems_lightning",
	"OPTRE_Insignia_medic",
	"OPTRE_Insignia_odst_13th",
	"OPTRE_Insignia_odst_19th",
	"OPTRE_Insignia_odst_7th",
	"OPTRE_Insignia_oni",
	"OPTRE_Insignia_osp",
	"OPTRE_Insignia_emblems_radioactive",
	"OPTRE_Insignia_emblems_rooster",
	"OPTRE_Insignia_emblems_skull",
	"OPTRE_Insignia_emblems_stallion",
	"OPTRE_Insignia_emblems_unicorn",
	"OPTRE_Insignia_unsc_1st",
	"OPTRE_Insignia_emblems_valkyrie",
	"OPTRE_Insignia_emblems_wolf",
	"OPTRE_Insignia_emblems_yinyang"
];

_slglammo append ["OPTRE_3Rnd_Smoke_Grenade_shell","OPTRE_signalSmokeG","OPTRE_1Rnd_Smoke_Grenade_shell","OPTRE_1Rnd_MasterKey_Pellets","OPTRE_1Rnd_MasterKey_Slugs","1Rnd_HE_Grenade_shell"];
_glammo append ["1Rnd_HE_Grenade_shell","OPTRE_1Rnd_MasterKey_Pellets","OPTRE_1Rnd_MasterKey_Slugs"];

_MXslglammo append ["OPTRE_3Rnd_Smoke_Grenade_shell","OPTRE_signalSmokeG","OPTRE_1Rnd_Smoke_Grenade_shell","OPTRE_3Rnd_MasterKey_Pellets","OPTRE_3Rnd_MasterKey_Slugs"];
_MXglammo append ["OPTRE_3Rnd_MasterKey_Pellets","OPTRE_3Rnd_MasterKey_Slugs"];

_Accessories append ["OPTRE_M12_Laser","OPTRE_M45_Flashlight","OPTRE_M6C_Flashlight","OPTRE_M6C_Vis_Red_Laser","OPTRE_M6C_Laser","OPTRE_M6G_Flashlight","OPTRE_M6G_Laser","OPTRE_M6G_Vis_Red_Laser","OPTRE_M7_Flashlight","OPTRE_M7_Laser","OPTRE_BMR_Laser"];
_TlOptics append ["OPTRE_BR45_Scope","OPTRE_BR55HB_Scope","OPTRE_BR55HB_Scope_Grey","Optre_Evo_Sight_Riser","Optre_Evo_Sight_Riser_Covie","Optre_Evo_Sight_Riser_Spartan","Optre_Evo_Sight_Riser_Yellow","OPTRE_M392_Scope","OPTRE_M393_Scope","OPTRE_HMG38_CarryHandle","OPTRE_M12_Optic","OPTRE_M12_Optic_Green","OPTRE_M12_Optic_Red","OPTRE_M393_ACOG","OPTRE_BMR_Scope","OPTRE_M6C_Scope","OPTRE_M6D_Scope","OPTRE_M6D_Scope_Black","OPTRE_M6D_Scope_Desert","OPTRE_M6D_Scope_Jungle","OPTRE_M6G_Scope","OPTRE_M7_Sight","OPTRE_M73_SmartLink","OPTRE_MA5_SmartLink","OPTRE_MA5C_SmartLink","Optre_Recon_Sight","Optre_Recon_Sight_Desert","Optre_Recon_Sight_Green","Optre_Recon_Sight_Red","Optre_Recon_Sight_Snow","Optre_Recon_Sight_UNSC","OPTRE_M393_EOTECH","OPTRE_SRM_Sight"];
_RifleOptics append ["OPTRE_BR45_Scope","OPTRE_BR55HB_Scope","OPTRE_BR55HB_Scope_Grey","Optre_Evo_Sight_Riser","Optre_Evo_Sight_Riser_Covie","Optre_Evo_Sight_Riser_Spartan","Optre_Evo_Sight_Riser_Yellow","OPTRE_M392_Scope","OPTRE_M393_Scope","OPTRE_HMG38_CarryHandle","OPTRE_M12_Optic","OPTRE_M12_Optic_Green","OPTRE_M12_Optic_Red","OPTRE_M393_ACOG","OPTRE_BMR_Scope","OPTRE_M6C_Scope","OPTRE_M6D_Scope","OPTRE_M6D_Scope_Black","OPTRE_M6D_Scope_Desert","OPTRE_M6D_Scope_Jungle","OPTRE_M6G_Scope","OPTRE_M7_Sight","OPTRE_M73_SmartLink","OPTRE_MA5_SmartLink","OPTRE_MA5C_SmartLink","Optre_Recon_Sight","Optre_Recon_Sight_Desert","Optre_Recon_Sight_Green","Optre_Recon_Sight_Red","Optre_Recon_Sight_Snow","Optre_Recon_Sight_UNSC","OPTRE_M393_EOTECH","OPTRE_SRM_Sight"];
_MGOptics append ["OPTRE_BR45_Scope","OPTRE_BR55HB_Scope","OPTRE_BR55HB_Scope_Grey","Optre_Evo_Sight_Riser","Optre_Evo_Sight_Riser_Covie","Optre_Evo_Sight_Riser_Spartan","Optre_Evo_Sight_Riser_Yellow","OPTRE_M392_Scope","OPTRE_M393_Scope","OPTRE_HMG38_CarryHandle","OPTRE_M12_Optic","OPTRE_M12_Optic_Green","OPTRE_M12_Optic_Red","OPTRE_M393_ACOG","OPTRE_BMR_Scope","OPTRE_M6C_Scope","OPTRE_M6D_Scope","OPTRE_M6D_Scope_Black","OPTRE_M6D_Scope_Desert","OPTRE_M6D_Scope_Jungle","OPTRE_M6G_Scope","OPTRE_M7_Sight","OPTRE_M73_SmartLink","OPTRE_MA5_SmartLink","OPTRE_MA5C_SmartLink","Optre_Recon_Sight","Optre_Recon_Sight_Desert","Optre_Recon_Sight_Green","Optre_Recon_Sight_Red","Optre_Recon_Sight_Snow","Optre_Recon_Sight_UNSC","OPTRE_M393_EOTECH","OPTRE_SRM_Sight"];
_SMGOptics append ["Optre_Evo_Sight_Riser","Optre_Evo_Sight_Riser_Covie","Optre_Evo_Sight_Riser_Spartan","Optre_Evo_Sight_Riser_Yellow","Optre_Evo_Sight","Optre_Evo_Sight_Innie","Optre_Evo_Sight_Covie","Optre_Evo_Sight_Spartan","Optre_Evo_Sight_Yellow","OPTRE_M12_Optic","OPTRE_M12_Optic_Green","OPTRE_M12_Optic_Red","OPTRE_M7_Sight","OPTRE_MA5_BUIS"];
_P90Optics append ["Optre_Evo_Sight_Riser","Optre_Evo_Sight_Riser_Covie","Optre_Evo_Sight_Riser_Spartan","Optre_Evo_Sight_Riser_Yellow","Optre_Evo_Sight","Optre_Evo_Sight_Innie","Optre_Evo_Sight_Covie","Optre_Evo_Sight_Spartan","Optre_Evo_Sight_Yellow","OPTRE_M12_Optic","OPTRE_M12_Optic_Green","OPTRE_M12_Optic_Red","OPTRE_M7_Sight","OPTRE_MA5_BUIS"];
_MarksmanOptics append ["OPTRE_BR45_Scope","OPTRE_BR55HB_Scope","OPTRE_BR55HB_Scope_Grey","OPTRE_M393_Scope","OPTRE_BMR_Scope","OPTRE_M73_SmartLink","OPTRE_SRS99C_Scope","OPTRE_SRS99_Scope","OPTRE_SRM_Sight"];
_SniperOptics append ["OPTRE_SRS99C_Scope","OPTRE_SRS99_Scope"];
//_Bipods append [];

_OPTREmuzzle = ["","OPTRE_M12_Suppressor","OPTRE_M393_Suppressor","OPTRE_M6_silencer","OPTRE_M6C_compensator","OPTRE_M7_silencer","OPTRE_MA37KSuppressor","OPTRE_SRS99D_Suppressor","OPTRE_MA5Suppressor",""];

_M6Daccesories = ["","OPTRE_M6D_Carbine_Flashlight","OPTRE_M6D_Carbine_IR","OPTRE_M6D_Carbine_Vis_Red"];
_M6Dmuzzle = ["","OPTRE_M6D_Carbine_Brake","OPTRE_M6D_Carbine_Suppressor"];

_riotshieldbipods = ["","OPTRE_Riot_Shield_Icon_A2S","OPTRE_Riot_Shield_Icon_CMA","OPTRE_Riot_Shield_Icon_Jolly","OPTRE_Riot_Shield_Icon_MEU","OPTRE_Riot_Shield_Icon_ODST","OPTRE_Riot_Shield_Icon_ODSTBlue","OPTRE_Riot_Shield_Icon_Police","OPTRE_Riot_Shield_Icon_UNSC","OPTRE_Riot_Shield_Icon_Virgil"];
// Оружие
(_loadoutData get "slRifles") append [
	["OPTRE_BR37", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_10RND_338_AP", "OPTRE_10RND_338_SP", "OPTRE_10RND_338_VLD"], [], ""],
	///
	["OPTRE_BR45_Black", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], "OPTRE_BR45Grip"],
	["OPTRE_BR45_Black", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR45", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], "OPTRE_BR45Grip"],
	["OPTRE_BR45", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	///
	["OPTRE_BR55", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR55_Grey", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR55HB", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR55HB_Grey", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	//
	["OPTRE_CQS48_Bulldog_Automatic", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48_Bulldog_Automatic_Desert", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48_Bulldog_Automatic_Green", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48_Bulldog_Automatic_Snow", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic_Desert", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic_Green", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic_Snow", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	///
	["OPTRE_HMG38_Rifle", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_100Rnd_30x06_Mag", "OPTRE_100Rnd_30x06_Mag_Tracer", "OPTRE_40Rnd_30x06_Mag","OPTRE_40Rnd_30x06_Mag_Tracer"], [], _Bipods],
	///
	["OPTRE_M295_BMR", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _TlOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M295_BMR_Desert", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _TlOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M295_BMR_Snow", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _TlOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M295_BMR_Woodland", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _TlOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	////
	["OPTRE_M58S", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _TlOptics, ["OPTRE_42Rnd_95x40_Mag", "OPTRE_42Rnd_95x40_Mag_Tracer", "OPTRE_42Rnd_95x40_Mag_Tracer_Yellow"], [], ""],
	["OPTRE_M58S", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_42Rnd_95x40_Mag", "OPTRE_42Rnd_95x40_Mag_Tracer", "OPTRE_42Rnd_95x40_Mag_Tracer_Yellow"], [], ""],
	///
	["OPTRE_MA32", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA37", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	["OPTRE_MA37", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA5A", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA37B", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	["OPTRE_MA37B", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA32B", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA5B", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_60Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA5C", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_Commando", _OPTREmuzzle, _Accessories, _TlOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Black", _OPTREmuzzle, _Accessories, _TlOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Police", _OPTREmuzzle, _Accessories, _TlOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Red", _OPTREmuzzle, _Accessories, _TlOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Snow", _OPTREmuzzle, _Accessories, _TlOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Tan", _OPTREmuzzle, _Accessories, _TlOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	/// GL
	["OPTRE_BR45GL", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], _slglammo, ""],
	["OPTRE_BR45GL_black", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], _slglammo, ""],
	["OPTRE_HMG38", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_100Rnd_30x06_Mag", "OPTRE_100Rnd_30x06_Mag_Tracer", "OPTRE_40Rnd_30x06_Mag","OPTRE_40Rnd_30x06_Mag_Tracer"], _slglammo, _Bipods],

	["OPTRE_MA32GL", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],
	["OPTRE_MA37GL", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],
	["OPTRE_MA37GL", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],

	["OPTRE_MA5AGL", _OPTREmuzzle, _Accessories,_TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],

	["OPTRE_MA37BGL", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],
	["OPTRE_MA37BGL", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],

	["OPTRE_MA32BGL", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""],

	["OPTRE_MA5BGL", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_60Rnd_762x51_Mag_Tracer"], _slglammo, ""],

	["OPTRE_MA5CGL", _OPTREmuzzle, _Accessories, _TlOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _slglammo, ""]
];
(_loadoutData get "rifles") append [
	["OPTRE_Bulldog_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],
	["OPTRE_Bulldog_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],
	["OPTRE_Bulldog_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],
	["OPTRE_Bulldog_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], _riotshieldbipods],

	["OPTRE_Comet_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],
	["OPTRE_Comet_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],
	["OPTRE_Comet_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],
	["OPTRE_Comet_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], _riotshieldbipods],

	["OPTRE_M6B_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6B_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6B_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6B_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],

	["OPTRE_M6C_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6C_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6C_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6C_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],

	["OPTRE_M6G_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6G_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6G_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],
	["OPTRE_M6G_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], _riotshieldbipods],

	["OPTRE_M7_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],
	["OPTRE_M7_Riot_Shield_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],
	["OPTRE_M7_Riot_Shield_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],
	["OPTRE_M7_Riot_Shield_Urban", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], _riotshieldbipods],

	["OPTRE_SAS10_Riot_Shield", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], _riotshieldbipods],

	["OPTRE_BR37", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_10RND_338_AP", "OPTRE_10RND_338_SP", "OPTRE_10RND_338_VLD"], [], ""],
	///
	["OPTRE_BR45_Black", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], "OPTRE_BR45Grip"],
	["OPTRE_BR45_Black", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR45", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], "OPTRE_BR45Grip"],
	["OPTRE_BR45", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	///
	["OPTRE_BR55", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR55_Grey", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR55HB", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	["OPTRE_BR55HB_Grey", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], [], ""],
	//
	["OPTRE_CQS48_Bulldog_Automatic", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48_Bulldog_Automatic_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48_Bulldog_Automatic_Green", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48_Bulldog_Automatic_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic_Desert", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic_Green", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	["OPTRE_CQS48S_Chihuahua_Automatic_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_12Gauge_HE", "OPTRE_12Rnd_12Gauge_HE_Tracer", "OPTRE_12Rnd_12Gauge_Pellets","OPTRE_12Rnd_12Gauge_Pellets_Tracer","OPTRE_12Rnd_12Gauge_Smoke","OPTRE_12Rnd_12Gauge_Smoke_Tracer"], [], ""],
	///
	["OPTRE_HMG38_Rifle", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_100Rnd_30x06_Mag", "OPTRE_100Rnd_30x06_Mag_Tracer", "OPTRE_40Rnd_30x06_Mag","OPTRE_40Rnd_30x06_Mag_Tracer"], [], _Bipods],
	///
	["OPTRE_M295_BMR", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _RifleOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M295_BMR_Desert", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _RifleOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M295_BMR_Snow", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _RifleOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M295_BMR_Woodland", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _RifleOptics, ["OPTRE_25Rnd_762x51_AP_Mag", "OPTRE_25Rnd_762x51_AP_Mag_Tracer", "OPTRE_25Rnd_762x51_Mag","OPTRE_25Rnd_762x51_Mag_Tracer_Yellow","OPTRE_25Rnd_762x51_Mag_Tracer"], [], _Bipods],
	////
	["OPTRE_M58S", _OPTREmuzzle, "OPTRE_BMR_Flashlight", _RifleOptics, ["OPTRE_42Rnd_95x40_Mag", "OPTRE_42Rnd_95x40_Mag_Tracer", "OPTRE_42Rnd_95x40_Mag_Tracer_Yellow"], [], ""],
	["OPTRE_M58S", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_42Rnd_95x40_Mag", "OPTRE_42Rnd_95x40_Mag_Tracer", "OPTRE_42Rnd_95x40_Mag_Tracer_Yellow"], [], ""],
	///
	["OPTRE_MA32", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA37", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	["OPTRE_MA37", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA5A", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA37B", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	["OPTRE_MA37B", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA32B", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA5B", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_60Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_MA5C", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],
	///
	["OPTRE_Commando", _OPTREmuzzle, _Accessories, _RifleOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Black", _OPTREmuzzle, _Accessories, _RifleOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Police", _OPTREmuzzle, _Accessories, _RifleOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Red", _OPTREmuzzle, _Accessories, _RifleOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Snow", _OPTREmuzzle, _Accessories, _RifleOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods],
	["OPTRE_Commando_Tan", _OPTREmuzzle, _Accessories, _RifleOptics, ["Commando_20Rnd_65_TracerR_Mag","Commando_20Rnd_65_TracerY_Mag","Commando_20Rnd_65_ReloadR_Mag","Commando_20Rnd_65_ReloadY_Mag","Commando_20Rnd_65_Mag","Command_20Rnd_65_TracerR_Mag"], [], _Bipods]
];
(_loadoutData get "carbines") append [
	["OPTRE_M12_SOC", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_64Rnd_57x31_Mag", "OPTRE_64Rnd_57x31_Mag_Tracer_Yellow", "OPTRE_64Rnd_57x31_Mag_Tracer"], [], _Bipods],
	["OPTRE_M45TAC", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_HEDP","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_HEDP","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_HEDP","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_HEDP","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45A", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_HEDP","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_HEDP","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45ATAC", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_HEDP","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_HEDP","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],
	["OPTRE_M45E", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_HEDP","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_HEDP","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],

	["OPTRE_M6D_Carbine_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6D_Carbine_Black_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6D_Carbine_Desert_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6D_Carbine_Jungle_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6DS_Carbine_Foregrip_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6DS_Carbine_Foregrip_Black_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6DS_Carbine_Foregrip_Desert_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],
	["OPTRE_M6DS_Carbine_Foregrip_Jungle_F", _M6Dmuzzle, _M6Daccesories, _RifleOptics, ["OPTRE_40Rnd_127x40_Drum_Tracer", "OPTRE_26Rnd_127x40_Mag_Tracer", "OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_16Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Mag_Tracer","OPTRE_12Rnd_127x40_Mag","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_8Rnd_127x40_Tracer_HE"], [], _Bipods],

	["OPTRE_M90A", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_12Rnd_8Gauge_Pellets","OPTRE_12Rnd_8Gauge_HEDP","OPTRE_12Rnd_8Gauge_Slugs","OPTRE_6Rnd_8Gauge_HEDP","OPTRE_6Rnd_8Gauge_Pellets","OPTRE_6Rnd_8Gauge_Slugs"], [], ""],

	["OPTRE_MA37K", _OPTREmuzzle, _RifleOptics, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], [], ""],

	["OPTRE_MA5K", _OPTREmuzzle, _RifleOptics, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_UW", "OPTRE_32Rnd_762x51_Mag_UW"], [], ""]
];
(_loadoutData get "grenadeLaunchers") append [
	/// GL
	["OPTRE_BR45GL", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], _glammo, ""],
	["OPTRE_BR45GL_black", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_36Rnd_95x40_Mag", "OPTRE_36Rnd_95x40_Mag_Tracer_Yellow", "OPTRE_36Rnd_95x40_Mag_Tracer"], _glammo, ""],
	["OPTRE_HMG38", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_100Rnd_30x06_Mag", "OPTRE_100Rnd_30x06_Mag_Tracer", "OPTRE_40Rnd_30x06_Mag","OPTRE_40Rnd_30x06_Mag_Tracer"], _glammo, _Bipods],

	["OPTRE_MA32GL", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],
	["OPTRE_MA37GL", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],
	["OPTRE_MA37GL", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],

	["OPTRE_MA5AGL", _OPTREmuzzle, _Accessories,_RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],

	["OPTRE_MA37BGL", _OPTREmuzzle, _Accessories, "", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],
	["OPTRE_MA37BGL", _OPTREmuzzle, _Accessories, "OPTRE_MA37_Smartlink_Scope", ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],

	["OPTRE_MA32BGL", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""],

	["OPTRE_MA5BGL", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_60Rnd_762x51_Mag", "OPTRE_60Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_60Rnd_762x51_Mag_Tracer"], _glammo, ""],

	["OPTRE_MA5CGL", _OPTREmuzzle, _Accessories, _RifleOptics, ["OPTRE_32Rnd_762x51_Mag", "OPTRE_32Rnd_762x51_Mag_Tracer_Yellow", "OPTRE_32Rnd_762x51_Mag_Tracer"], _glammo, ""]
];
(_loadoutData get "designatedGrenadeLaunchers") append [
	["OPTRE_M319", "", _Accessories, "", ["M319_HE_Grenade_Shell", "M319_HEDPC_Grenade_Shell","M319_HEAT_Grenade_Shell", "M319_HEDP_Grenade_Shell","M319_Buckshot","M319_Smoke"], [], ""],
	["OPTRE_M319N", "", _Accessories, "", ["M319_HE_Grenade_Shell", "M319_HEDPC_Grenade_Shell","M319_HEAT_Grenade_Shell", "M319_HEDP_Grenade_Shell","M319_Buckshot","M319_Smoke"], [], ""]
];
(_loadoutData get "SMGs") append [
	["OPTRE_M7", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], ""]
];
(_loadoutData get "machineGuns") append [
	["OPTRE_M247", _OPTREmuzzle, _Accessories, _MGOptics, ["OPTRE_400Rnd_762x51_Box_Tracer", "OPTRE_100Rnd_762x51_Box", "OPTRE_100Rnd_762x51_Box_Tracer_Yellow","OPTRE_100Rnd_762x51_Box_Tracer"], [], _Bipods],
	["OPTRE_M247H_Etilka", _OPTREmuzzle, _Accessories, _MGOptics, ["OPTRE_200Rnd_127x99_M247H_Etilka_Ball", "OPTRE_200Rnd_127x99_M247H_Etilka"], [], _Bipods],
	["OPTRE_M247H_Shield_Etilka", _OPTREmuzzle, _Accessories, _MGOptics, ["OPTRE_200Rnd_127x99_M247H_Etilka_Ball", "OPTRE_200Rnd_127x99_M247H_Etilka"], [], _Bipods],
	["OPTRE_M73", _OPTREmuzzle, _Accessories, _MGOptics, ["OPTRE_200Rnd_95x40_Box", "OPTRE_200Rnd_95x40_Box_Tracer_Yellow", "OPTRE_200Rnd_95x40_Box_Tracer","OPTRE_100Rnd_95x40_Box","OPTRE_100Rnd_95x40_Box_Tracer_Yellow","OPTRE_100Rnd_95x40_Box_Tracer"], [], _Bipods]
];
(_loadoutData get "marksmanRifles") append [
	["OPTRE_M392_DMR", _OPTREmuzzle, "OPTRE_DMR_Light", _MarksmanOptics, ["OPTRE_15Rnd_762x51_AP_Mag", "OPTRE_15Rnd_762x51_AP_Mag_Tracer", "OPTRE_15Rnd_762x51_Mag","OPTRE_15Rnd_762x51_Mag_Tracer_Yellow","OPTRE_15Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M392_DMR", _OPTREmuzzle, _Accessories, _MarksmanOptics, ["OPTRE_15Rnd_762x51_AP_Mag", "OPTRE_15Rnd_762x51_AP_Mag_Tracer", "OPTRE_15Rnd_762x51_Mag","OPTRE_15Rnd_762x51_Mag_Tracer_Yellow","OPTRE_15Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M393_DMR", _OPTREmuzzle, "OPTRE_DMR_Light", _MarksmanOptics, ["OPTRE_15Rnd_762x51_AP_Mag", "OPTRE_15Rnd_762x51_AP_Mag_Tracer", "OPTRE_15Rnd_762x51_Mag","OPTRE_15Rnd_762x51_Mag_Tracer_Yellow","OPTRE_15Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M393_DMR", _OPTREmuzzle, _Accessories, _MarksmanOptics, ["OPTRE_15Rnd_762x51_AP_Mag", "OPTRE_15Rnd_762x51_AP_Mag_Tracer", "OPTRE_15Rnd_762x51_Mag","OPTRE_15Rnd_762x51_Mag_Tracer_Yellow","OPTRE_15Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M393S_DMR", _OPTREmuzzle, "OPTRE_DMR_Light", _MarksmanOptics, ["OPTRE_15Rnd_762x51_AP_Mag", "OPTRE_15Rnd_762x51_AP_Mag_Tracer", "OPTRE_15Rnd_762x51_Mag","OPTRE_15Rnd_762x51_Mag_Tracer_Yellow","OPTRE_15Rnd_762x51_Mag_Tracer"], [], _Bipods],
	["OPTRE_M393S_DMR", _OPTREmuzzle, _Accessories, _MarksmanOptics, ["OPTRE_15Rnd_762x51_AP_Mag", "OPTRE_15Rnd_762x51_AP_Mag_Tracer", "OPTRE_15Rnd_762x51_Mag","OPTRE_15Rnd_762x51_Mag_Tracer_Yellow","OPTRE_15Rnd_762x51_Mag_Tracer"], [], _Bipods]
];
(_loadoutData get "sniperRifles") append [
	["OPTRE_M393S_DMR", "", "", "", ["OPTRE_7Rnd_20mm_APFSDS_Mag", "OPTRE_7Rnd_20mm_HEDP_Mag", "OPTRE_7Rnd_20mm_APFSDS_Mag"], [], ""],

	["OPTRE_SRM77_S1", _OPTREmuzzle, _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],
	["OPTRE_SRM77_S1_Green", _OPTREmuzzle, _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],
	["OPTRE_SRM77_S1_Blue", _OPTREmuzzle, _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],
	["OPTRE_SRM77_S1_Red", _OPTREmuzzle, _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],

	["OPTRE_SRM77_S2", "", _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],
	["OPTRE_SRM77_S2_Green", "", _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],
	["OPTRE_SRM77_S2_Blue", "", _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],
	["OPTRE_SRM77_S2_Red", "", _Accessories, _SniperOptics, ["OPTRE_10Rnd_127x99_noTracer", "OPTRE_10Rnd_127x99", "OPTRE_10Rnd_127x99_Subsonic_noTracer","OPTRE_10Rnd_127x99_Subsonic","OPTRE_5Rnd_127x99_noTracer","OPTRE_5Rnd_127x99","OPTRE_5Rnd_127x99_Subsonic_noTracer","OPTRE_5Rnd_127x99_Subsonic"], [], _Bipods],

	["OPTRE_SRS99C", _OPTREmuzzle, _Accessories, _SniperOptics, ["OPTRE_4Rnd_145x114_APFSDS_Mag", "OPTRE_4Rnd_145x114_APFSDS_Mag_D", "OPTRE_4Rnd_145x114_HEDP_Mag","OPTRE_4Rnd_145x114_HEDP_Mag_D","OPTRE_4Rnd_145x114_HVAP_Mag","OPTRE_4Rnd_145x114_HVAP_Mag_D"], [], ""],
	["OPTRE_SRS99D", _OPTREmuzzle, _Accessories, _SniperOptics, ["OPTRE_4Rnd_145x114_APFSDS_Mag", "OPTRE_4Rnd_145x114_APFSDS_Mag_D", "OPTRE_4Rnd_145x114_HEDP_Mag","OPTRE_4Rnd_145x114_HEDP_Mag_D","OPTRE_4Rnd_145x114_HVAP_Mag","OPTRE_4Rnd_145x114_HVAP_Mag_D"], [], ""]
];

// Пусковые установки
(_loadoutData get "lightATLaunchers") append [
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HE", "OPTRE_M41_Twin_Smoke_W"], [], ""]
];
(_loadoutData get "ATLaunchers") append [
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HE", "OPTRE_M41_Twin_HEAP","OPTRE_M41_Twin_HEAT"], [], ""]
];
(_loadoutData get "missileATLaunchers") append [
	["OPTRE_M6GGNR", "", "", "", ["OPTRE_SpLaser_Battery_Launcher", "OPTRE_SpLaser_Battery_Launcher","OPTRE_SpLaser_Battery_Launcher"], [], ""],
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HEAT_G", "OPTRE_M41_Twin_HEAT_SACLOS","OPTRE_M41_Twin_HEAT_SALH"], [], ""]
];
(_loadoutData get "AALaunchers") append [
	["OPTRE_M41_SSR", "", "", "", ["OPTRE_M41_Twin_HEAT_G_AA", "OPTRE_M41_Twin_HEAT_G_AA"], [], ""]
];
(_loadoutData get "sidearms") append [
	["OPTRE_M319", "", "", "", ["M319_HE_Grenade_Shell", "M319_HEDPC_Grenade_Shell","M319_HEAT_Grenade_Shell", "M319_HEDP_Grenade_Shell","M319_Buckshot","M319_Smoke"], [], ""],
	["OPTRE_M319s", "", "", "", ["OPTRE_3Rnd_Smoke_Grenade_shell", "OPTRE_signalSmokeG","OPTRE_1Rnd_Smoke_Grenade_shell"], [], ""],

	["OPTRE_M6B", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6C", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D_Black", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D_Desert", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6D_Jungle", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6G", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],
	["OPTRE_M6B", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_12Rnd_127x40_Black_Mag", "OPTRE_12Rnd_127x40_Mag_Black_Tracer","OPTRE_12Rnd_127x40_Black_Mag_HE","OPTRE_12Rnd_127x40_Mag_Black_Tracer_HE","OPTRE_16Rnd_127x40_Black_Mag","OPTRE_16Rnd_127x40_Mag_Black_Tracer","OPTRE_16Rnd_127x40_Mag_Tracer","OPTRE_40Rnd_127x40_Drum_Tracer"], [], ""],

	["OPTRE_M7_Folded", _OPTREmuzzle, _Accessories, _SMGOptics, ["OPTRE_60Rnd_5x23mm_Mag", "OPTRE_60Rnd_5x23mm_Mag_tracer_yellow", "OPTRE_60Rnd_5x23mm_Mag_tracer","OPTRE_48Rnd_5x23mm_FMJ_Mag","OPTRE_48Rnd_5x23mm_JHP_Mag","OPTRE_48Rnd_5x23mm_Mag","OPTRE_48Rnd_5x23mm_Mag_tracer_yellow","OPTRE_48Rnd_5x23mm_Mag_tracer"], [], ""],

	["optre_hgun_comet_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], ""],
	["optre_hgun_comet_gold_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["4Rnd_454Casull", "4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull","4Rnd_454Casull"], [], ""],

	["optre_hgun_sas10_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""],
	["optre_hgun_sas10_desert_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""],
	["optre_hgun_sas10_jungle_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""],
	["optre_hgun_sas10_snow_F", _OPTREmuzzle, _Accessories, _RifleOptics, ["16Rnd_10mm_AP", "16Rnd_10mm_Ball", "32Rnd_10mm_Ball","8Rnd_10mm_EXP"], [], ""]
];

// Взрывчатка
(_loadoutData get "ATMines") append ["UNSCMine_Range_Mag"];
(_loadoutData get "APMines") append ["APERSMine_Range_Mag"];
(_loadoutData get "lightExplosives") append ["C7_Remote_Mag","C12_Remote_Mag"];
(_loadoutData get "heavyExplosives") append ["M168_Remote_Mag"];

// Гранаты
(_loadoutData get "antiInfantryGrenades") append ["OPTRE_M9_Frag","OPTRE_c7_remote_throwable_sticky_mag","OPTRE_M2_Smoke_Yellow"];
(_loadoutData get "smokeGrenades") append ["OPTRE_M8_Flare_White","OPTRE_M2_Smoke"];
(_loadoutData get "signalsmokeGrenades") append ["OPTRE_M2_Smoke_Blue","OPTRE_M2_Smoke_Green","OPTRE_M2_Smoke_Orange","OPTRE_M2_Smoke_Purple","OPTRE_M2_Smoke_Red",
"OPTRE_M2_Smoke_Yellow","OPTRE_M8_Flare_Blue","OPTRE_M8_Flare_Green","OPTRE_M8_Flare","OPTRE_M8_Flare_Yellow"];

// Базовое снаряжение
(_loadoutData get "maps") append ["ItemMap"];
(_loadoutData get "watches") append ["ItemWatch"];
(_loadoutData get "compasses") append ["ItemCompass"];
(_loadoutData get "radios") append ["ItemRadio"];
(_loadoutData get "gpses") append ["ItemGPS"];
(_loadoutData get "NVGs") append [
	"OPTRE_NVGT_C",
	"OPTRE_NVG",
	"OPTRE_NVG_CNM_MVI_HURS",
	"OPTRE_NVG_CNM_UAB_HURS",
	"OPTRE_NVG_CNM",
	"OPTRE_NVG_UL",
	"OPTRE_NVG_HUL",
	"OPTRE_NVG_HUL3",
	"OPTRE_NVG_HUL3_Gray",
	"OPTRE_NVG_HURS",
	"OPTRE_NVG_HUL_MVI_HURS",
	"OPTRE_NVG_HUL_UAB_HURS",
	"OPTRE_NVG_HURS_CNM",
	"OPTRE_NVG_HURS_HUL",
	"OPTRE_NVG_MVI",
	"OPTRE_NVG_MVI_CNM",
	"OPTRE_NVG_MVI_HUL",
	"OPTRE_NVG_MVI_HURS",
	"OPTRE_NVG_MVI_UL",
	"OPTRE_NVG_MVI_UL_CNM",
	"OPTRE_NVG_MVI_UL_HUL",
	"OPTRE_NVG_UA_CNM",
	"OPTRE_NVG_UA_HUL",
	"OPTRE_NVG_UA_HURS",
	"OPTRE_NVG_UA_HURS_CNM",
	"OPTRE_NVG_UA_HURS_HUL",
	"OPTRE_NVG_UA_UL",
	"OPTRE_NVG_UA_UL_CNM",
	"OPTRE_NVG_UAB_CNM",
	"OPTRE_NVG_UAB_HUL",
	"OPTRE_NVG_UAB_HURS",
	"OPTRE_NVG_UAB_UL",
	"OPTRE_NVG_UAB_UL_CNM",
	"OPTRE_NVG_UAB_UL_HUL",
	"OPTRE_NVG_UL_CNM",
	"OPTRE_NVG_UL_HUL",
	"OPTRE_NVG_UA",
	"OPTRE_NVG_UAB",
	"OPTRE_NVG_Visor"
];
(_loadoutData get "binoculars") append ["OPTRE_Binoculars"];
(_loadoutData get "rangefinders") append ["OPTRE_Smartfinder","OPTRE_Smartfinder_Vector"];

// Предательская экипировка
(_loadoutData get "traitorUniforms") append [
	"OPTRE_Ins_BJ_Undersuit",
	"OPTRE_Ins_BJ_Undersuit_Des",
	"OPTRE_Ins_BJ_Undersuit_Snw",
	"OPTRE_Ins_BJ_Undersuit_Wdl",
	"OPTRE_Ins_ER_jacket_brown_surplus",
	"OPTRE_Ins_ER_uniform_GAgreen",
	"OPTRE_Ins_ER_uniform_GAtan",
	"OPTRE_Ins_ER_uniform_GGgrey",
	"OPTRE_Ins_ER_uniform_GGod",
	"OPTRE_Ins_ER_jacket_od_surplus",
	"OPTRE_Ins_ER_rolled_jean_orca",
	"OPTRE_Ins_ER_rolled_OD_blknblu",
	"OPTRE_Ins_ER_rolled_OD_blknred",
	"OPTRE_Ins_ER_rolled_OD_crimson",
	"OPTRE_Ins_ER_rolled_surplus_black",
	"OPTRE_Ins_ER_rolled_surplus_crimson",
	"OPTRE_Ins_ER_jacket_surgeon1",
	"OPTRE_Ins_ER_jacket_surgeon2",
	"OPTRE_Ins_ER_jacket_surplus_brown",
	"OPTRE_Ins_ER_jacket_surplus_OD",
	"OPTRE_Ins_ER_jacket_surplus_redshirt",
	"OPTRE_Ins_URF_Combat_Uniform",
	"OPTRE_Ins_URF_Combat_Desert_Uniform",
	"OPTRE_Ins_URF_Combat_Desert_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Jungle_Uniform",
	"OPTRE_Ins_URF_Combat_Jungle_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Snow_Uniform",
	"OPTRE_Ins_URF_Combat_Snow_Flat_Uniform",
	"OPTRE_Ins_URF_Combat_Tundra_Uniform",
	"OPTRE_Ins_URF_Combat_Woodland_Uniform",
	"OPTRE_Ins_URF_Combat_Woodland_Flat_Uniform"
];
(_loadoutData get "traitorVests") append [
	"OPTRE_Ins_BJ_Armor",
	"OPTRE_Ins_BJ_Armor_Des",
	"OPTRE_Ins_BJ_Armor_Snw",
	"OPTRE_Ins_BJ_Armor_Wdl",
	"OPTRE_Ins_URF_Armor1",
	"OPTRE_Ins_URF_Desert_Armor1",
	"OPTRE_Ins_URF_Desert_Armor1_Flat",
	"OPTRE_Ins_URF_Armor1_Flat",
	"OPTRE_Ins_URF_Jungle_Armor1",
	"OPTRE_Ins_URF_Jungle_Armor1_Flat",
	"OPTRE_Ins_URF_Snow_Armor1",
	"OPTRE_Ins_URF_Snow_Armor1_Flat",
	"OPTRE_Ins_URF_Tundra_Armor1",
	"OPTRE_Ins_URF_Woodland_Armor1",
	"OPTRE_Ins_URF_Woodland_Armor1_Flat"
];
(_loadoutData get "traitorHats") append [
	"OPTRE_Ins_BJ_Helmet",
	"OPTRE_Ins_BJ_Helmet_Des",
	"OPTRE_Ins_BJ_Helmet_Snw",
	"OPTRE_Ins_BJ_Helmet_Wdl",
	"OPTRE_Ins_URF_Helmet1",
	"OPTRE_Ins_URF_Helmet4",
	"OPTRE_Ins_URF_Helmet4_Brown",
	"OPTRE_Ins_URF_Helmet4_White",
	"OPTRE_Ins_URF_Helmet3",
	"OPTRE_Ins_URF_Helmet3_Brown",
	"OPTRE_Ins_URF_Helmet3_White",
	"OPTRE_Ins_URF_Helmet2",
	"OPTRE_Ins_URF_Helmet2_Brown",
	"OPTRE_Ins_URF_Helmet2_White",
	"OPTRE_Ins_URF_Helmet1_Brown",
	"OPTRE_Ins_URF_Helmet1_White"
];

// Офицерская экипировка
(_loadoutData get "officerUniforms") append [
	"OPTRE_UNSC_Dress_Uniform_gray",
	"OPTRE_UNSC_Dress_Uniform_green",
	"OPTRE_UNSC_Dress_Uniform_Green_Colonel",
	"OPTRE_UNSC_Dress_Uniform_Green_General",
	"OPTRE_UNSC_Dress_Uniform_Green_Major",
	"OPTRE_UNSC_Dress_Uniform_medical",
	"OPTRE_UNSC_Dress_Uniform_odst",
	"OPTRE_UNSC_Dress_Uniform_ODST_Major",
	"OPTRE_UNSC_Dress_Uniform_ONI_Captain",
	"OPTRE_UNSC_Dress_Uniform_ONI_Colonel",
	"OPTRE_UNSC_Dress_Uniform_ONI_Major",
	"OPTRE_UNSC_Dress_Uniform_NBlue",
	"OPTRE_UNSC_Dress_Uniform_NBlue_Colonel",
	"OPTRE_UNSC_Dress_Uniform_NBlue_General",
	"OPTRE_UNSC_Dress_Uniform_NBlue_Major",
	"OPTRE_UNSC_Dress_Uniform_white",
	"OPTRE_UNSC_Dress_Uniform_White_Captain",
	"OPTRE_UNSC_Dress_Uniform_White_Fleet",
	"OPTRE_UNSC_Dress_Uniform_White_Rear"
];
(_loadoutData get "officerVests") append [
	"V_Rangemaster_belt"
];
(_loadoutData get "officerHats") append [
	"OPTRE_UNSC_Dress_Hat",
	"OPTRE_UNSC_Dress_Hat_Army",
	"OPTRE_UNSC_Dress_Hat_Navy",
	"OPTRE_UNSC_Dress_Hat_ODST",
	"OPTRE_UNSC_Dress_Hat_ONI"
];

// Специальная экипировка
(_loadoutData get "cloakUniforms") append [
	"OPTRE_CMA_Uniform",
	"OPTRE_CMA_Uniform_Rolled",
	"OPTRE_CPD_Uniform",
	"OPTRE_CPD_Uniform_Rolled",
	"OPTRE_UNSC_Army_Uniform_R_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_R_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_R_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_BLKURB",
	"OPTRE_UNSC_Army_Uniform_R_BLK",
	"OPTRE_UNSC_Army_Uniform_R_DESWDL",
	"OPTRE_UNSC_Army_Uniform_R_DES",
	"OPTRE_UNSC_Army_Uniform_R_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform_R",
	"OPTRE_UNSC_Marine_Uniform_R",
	"OPTRE_UNSC_Army_Uniform_R_OLITRO",
	"OPTRE_UNSC_Army_Uniform_R_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_R_OLI",
	"OPTRE_UNSC_Army_Uniform_R_SNO",
	"OPTRE_UNSC_Army_Uniform_R_TRO",
	"OPTRE_UNSC_Army_Uniform_R_URB",
	"OPTRE_UNSC_Army_Uniform_R_WDLDES",
	"OPTRE_UNSC_Army_Uniform_R_WDL",
	"OPTRE_UNSC_Army_Uniform_S_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_S_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_S_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_BLKURB",
	"OPTRE_UNSC_Army_Uniform_S_BLK",
	"OPTRE_UNSC_Army_Uniform_S_DESWDL",
	"OPTRE_UNSC_Army_Uniform_S_DES",
	"OPTRE_UNSC_Army_Uniform_S_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform_S",
	"OPTRE_UNSC_Marine_Uniform_S",
	"OPTRE_UNSC_Army_Uniform_S_OLITRO",
	"OPTRE_UNSC_Army_Uniform_S_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_S_OLI",
	"OPTRE_UNSC_Army_Uniform_S_TRO",
	"OPTRE_UNSC_Army_Uniform_S_URB",
	"OPTRE_UNSC_Army_Uniform_S_WDLDES",
	"OPTRE_UNSC_Army_Uniform_S_WDL",
	"OPTRE_UNSC_Army_Uniform_S_Gloves_WDL",
	"OPTRE_UNSC_Army_Uniform_S_Gloves_Slim_WDL",
	"OPTRE_UNSC_Army_Uniform_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_DES_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T3_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_DES_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T2_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_DES",
	"OPTRE_UNSC_Marine_Uniform_T3",
	"OPTRE_UNSC_Army_Uniform_T_OLI",
	"OPTRE_UNSC_Army_Uniform_T2_TRO",
	"OPTRE_UNSC_Army_Uniform_T_URB",
	"OPTRE_UNSC_Army_Uniform_T3_WDL",
	"OPTRE_UNSC_Army_Uniform_T_BLK",
	"OPTRE_UNSC_Army_Uniform_T2_BLK",
	"OPTRE_UNSC_Army_Uniform_T2_DES",
	"OPTRE_UNSC_Army_Uniform_T_TRO",
	"OPTRE_UNSC_Army_Uniform_T_WDL",
	"OPTRE_UNSC_Army_Uniform_T3_BLK",
	"OPTRE_UNSC_Army_Uniform_T_DES",
	"OPTRE_UNSC_Marine_Uniform_T2",
	"OPTRE_UNSC_Marine_Uniform_T",
	"OPTRE_UNSC_Army_Uniform_T2_WDL",
	"OPTRE_UNSC_Army_Uniform_T_SNO",
	"OPTRE_UNSC_Army_Uniform_BLKURB",
	"OPTRE_UNSC_Army_Uniform_BLK",
	"OPTRE_UNSC_Army_Uniform_DESWDL",
	"OPTRE_UNSC_Army_Uniform_DES",
	"OPTRE_UNSC_Army_Uniform_AFMAR"
];
(_loadoutData get "cloakVests") append [
	"OPTRE_UNSC_M52A_Armor_Sniper_DES",
	"OPTRE_UNSC_M52A_Armor_Sniper_MAR",
	"OPTRE_UNSC_M52A_Armor_Sniper_OLI",
	"OPTRE_UNSC_M52A_Armor_Sniper_SNO",
	"OPTRE_UNSC_M52A_Armor_Sniper_TRO",
	"OPTRE_UNSC_M52A_Armor_Sniper_URB",
	"OPTRE_UNSC_M52A_Armor_Sniper_WDL"
];

// Основная экипировка
(_loadoutData get "uniforms") append [
	"OPTRE_ONI_Researcher_Uniform",
	"OPTRE_ONI_Researcher_Uniform_Light",
	"OPTRE_CMA_Uniform",
	"OPTRE_CMA_Uniform_Rolled",
	"OPTRE_CPD_Uniform",
	"OPTRE_CPD_Uniform_Rolled",
	"OPTRE_UNSC_Army_Uniform_R_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_R_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_R_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_BLKURB",
	"OPTRE_UNSC_Army_Uniform_R_BLK",
	"OPTRE_UNSC_Army_Uniform_R_DESWDL",
	"OPTRE_UNSC_Army_Uniform_R_DES",
	"OPTRE_UNSC_Army_Uniform_R_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform_R",
	"OPTRE_UNSC_Marine_Uniform_R",
	"OPTRE_UNSC_Army_Uniform_R_OLITRO",
	"OPTRE_UNSC_Army_Uniform_R_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_R_OLI",
	"OPTRE_UNSC_Army_Uniform_R_SNO",
	"OPTRE_UNSC_Army_Uniform_R_TRO",
	"OPTRE_UNSC_Army_Uniform_R_URB",
	"OPTRE_UNSC_Army_Uniform_R_WDLDES",
	"OPTRE_UNSC_Army_Uniform_R_WDL",
	"OPTRE_UNSC_Army_Uniform_S_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_S_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_S_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_BLKURB",
	"OPTRE_UNSC_Army_Uniform_S_BLK",
	"OPTRE_UNSC_Army_Uniform_S_DESWDL",
	"OPTRE_UNSC_Army_Uniform_S_DES",
	"OPTRE_UNSC_Army_Uniform_S_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform_S",
	"OPTRE_UNSC_Marine_Uniform_S",
	"OPTRE_UNSC_Army_Uniform_S_OLITRO",
	"OPTRE_UNSC_Army_Uniform_S_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_S_OLI",
	"OPTRE_UNSC_Army_Uniform_S_TRO",
	"OPTRE_UNSC_Army_Uniform_S_URB",
	"OPTRE_UNSC_Army_Uniform_S_WDLDES",
	"OPTRE_UNSC_Army_Uniform_S_WDL",
	"OPTRE_UNSC_Army_Uniform_S_Gloves_WDL",
	"OPTRE_UNSC_Army_Uniform_S_Gloves_Slim_WDL",
	"OPTRE_UNSC_Army_Uniform_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_DES_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T3_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_DES_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T2_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_DES",
	"OPTRE_UNSC_Marine_Uniform_T3",
	"OPTRE_UNSC_Army_Uniform_T_OLI",
	"OPTRE_UNSC_Army_Uniform_T2_TRO",
	"OPTRE_UNSC_Army_Uniform_T_URB",
	"OPTRE_UNSC_Army_Uniform_T3_WDL",
	"OPTRE_UNSC_Army_Uniform_T_BLK",
	"OPTRE_UNSC_Army_Uniform_T2_BLK",
	"OPTRE_UNSC_Army_Uniform_T2_DES",
	"OPTRE_UNSC_Army_Uniform_T_TRO",
	"OPTRE_UNSC_Army_Uniform_T_WDL",
	"OPTRE_UNSC_Army_Uniform_T3_BLK",
	"OPTRE_UNSC_Army_Uniform_T_DES",
	"OPTRE_UNSC_Marine_Uniform_T2",
	"OPTRE_UNSC_Marine_Uniform_T",
	"OPTRE_UNSC_Army_Uniform_T2_WDL",
	"OPTRE_UNSC_Army_Uniform_T_SNO",
	"OPTRE_UNSC_Army_Uniform_BLKURB",
	"OPTRE_UNSC_Army_Uniform_BLK",
	"OPTRE_UNSC_Army_Uniform_DESWDL",
	"OPTRE_UNSC_Army_Uniform_DES",
	"OPTRE_UNSC_Army_Uniform_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform",
	"OPTRE_UNSC_Marine_Uniform",
	"OPTRE_UNSC_ODST_Uniform",
	"OPTRE_UNSC_Army_Uniform_OLITRO",
	"OPTRE_UNSC_Army_Uniform_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_OLI",
	"OPTRE_UNSC_Army_Uniform_TRO",
	"OPTRE_UNSC_Army_Uniform_URB",
	"OPTRE_UNSC_Army_Uniform_WDLDES",
	"OPTRE_UNSC_Army_Uniform_WDL",
	"OPTRE_UNSC_MJOLNIR_Undersuit_Human",
	"OPTRE_UNSC_PT_ODST_Uniform",
	"OPTRE_UNSC_PT_Uniform",
	"OPTRE_UNSC_Army_Uniform_S_SNO",
	"OPTRE_UNSC_Army_Uniform_SNO",
	"OPTRE_UNSC_Army_Uniform_T2_OLI"
];
(_loadoutData get "slUniforms") append [
	"OPTRE_ONI_Researcher_Uniform",
	"OPTRE_ONI_Researcher_Uniform_Light",
	"OPTRE_CMA_Uniform",
	"OPTRE_CMA_Uniform_Rolled",
	"OPTRE_CPD_Uniform",
	"OPTRE_CPD_Uniform_Rolled",
	"OPTRE_UNSC_Army_Uniform_R_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_R_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_R_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_R_BLKURB",
	"OPTRE_UNSC_Army_Uniform_R_BLK",
	"OPTRE_UNSC_Army_Uniform_R_DESWDL",
	"OPTRE_UNSC_Army_Uniform_R_DES",
	"OPTRE_UNSC_Army_Uniform_R_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform_R",
	"OPTRE_UNSC_Marine_Uniform_R",
	"OPTRE_UNSC_Army_Uniform_R_OLITRO",
	"OPTRE_UNSC_Army_Uniform_R_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_R_OLI",
	"OPTRE_UNSC_Army_Uniform_R_SNO",
	"OPTRE_UNSC_Army_Uniform_R_TRO",
	"OPTRE_UNSC_Army_Uniform_R_URB",
	"OPTRE_UNSC_Army_Uniform_R_WDLDES",
	"OPTRE_UNSC_Army_Uniform_R_WDL",
	"OPTRE_UNSC_Army_Uniform_S_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_S_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_S_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_S_BLKURB",
	"OPTRE_UNSC_Army_Uniform_S_BLK",
	"OPTRE_UNSC_Army_Uniform_S_DESWDL",
	"OPTRE_UNSC_Army_Uniform_S_DES",
	"OPTRE_UNSC_Army_Uniform_S_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform_S",
	"OPTRE_UNSC_Marine_Uniform_S",
	"OPTRE_UNSC_Army_Uniform_S_OLITRO",
	"OPTRE_UNSC_Army_Uniform_S_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_S_OLI",
	"OPTRE_UNSC_Army_Uniform_S_TRO",
	"OPTRE_UNSC_Army_Uniform_S_URB",
	"OPTRE_UNSC_Army_Uniform_S_WDLDES",
	"OPTRE_UNSC_Army_Uniform_S_WDL",
	"OPTRE_UNSC_Army_Uniform_S_Gloves_WDL",
	"OPTRE_UNSC_Army_Uniform_S_Gloves_Slim_WDL",
	"OPTRE_UNSC_Army_Uniform_BLKURB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DESWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_AFMAR_SlimLeg",
	"OPTRE_UNSC_Airforce_Uniform_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLITRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLIWDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_WDLDES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_DES_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T3_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_URB_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_OLI_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_DES_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_TRO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_BLK_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_DES_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T2_SlimLeg",
	"OPTRE_UNSC_Marine_Uniform_T_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T2_WDL_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T_SNO_SlimLeg",
	"OPTRE_UNSC_Army_Uniform_T3_DES",
	"OPTRE_UNSC_Marine_Uniform_T3",
	"OPTRE_UNSC_Army_Uniform_T_OLI",
	"OPTRE_UNSC_Army_Uniform_T2_TRO",
	"OPTRE_UNSC_Army_Uniform_T_URB",
	"OPTRE_UNSC_Army_Uniform_T3_WDL",
	"OPTRE_UNSC_Army_Uniform_T_BLK",
	"OPTRE_UNSC_Army_Uniform_T2_BLK",
	"OPTRE_UNSC_Army_Uniform_T2_DES",
	"OPTRE_UNSC_Army_Uniform_T_TRO",
	"OPTRE_UNSC_Army_Uniform_T_WDL",
	"OPTRE_UNSC_Army_Uniform_T3_BLK",
	"OPTRE_UNSC_Army_Uniform_T_DES",
	"OPTRE_UNSC_Marine_Uniform_T2",
	"OPTRE_UNSC_Marine_Uniform_T",
	"OPTRE_UNSC_Army_Uniform_T2_WDL",
	"OPTRE_UNSC_Army_Uniform_T_SNO",
	"OPTRE_UNSC_Army_Uniform_BLKURB",
	"OPTRE_UNSC_Army_Uniform_BLK",
	"OPTRE_UNSC_Army_Uniform_DESWDL",
	"OPTRE_UNSC_Army_Uniform_DES",
	"OPTRE_UNSC_Army_Uniform_AFMAR",
	"OPTRE_UNSC_Airforce_Uniform",
	"OPTRE_UNSC_Marine_Uniform",
	"OPTRE_UNSC_ODST_Uniform",
	"OPTRE_UNSC_Army_Uniform_OLITRO",
	"OPTRE_UNSC_Army_Uniform_OLIWDL",
	"OPTRE_UNSC_Army_Uniform_OLI",
	"OPTRE_UNSC_Army_Uniform_TRO",
	"OPTRE_UNSC_Army_Uniform_URB",
	"OPTRE_UNSC_Army_Uniform_WDLDES",
	"OPTRE_UNSC_Army_Uniform_WDL",
	"OPTRE_UNSC_MJOLNIR_Undersuit_Human",
	"OPTRE_UNSC_PT_ODST_Uniform",
	"OPTRE_UNSC_PT_Uniform",
	"OPTRE_UNSC_Army_Uniform_S_SNO",
	"OPTRE_UNSC_Army_Uniform_SNO",
	"OPTRE_UNSC_Army_Uniform_T2_OLI"
];
(_loadoutData get "vests") append [
	"OPTRE_Vest_CMA_Light",
	"OPTRE_UNSC_M52A_Armor_MG_DES",
	"OPTRE_UNSC_M52A_Armor_MG_MAR",
	"OPTRE_UNSC_M52A_Armor_MG_OLI",
	"OPTRE_UNSC_M52A_Armor_MG_SNO",
	"OPTRE_UNSC_M52A_Armor_MG_TRO",
	"OPTRE_UNSC_M52A_Armor_MG_URB",
	"OPTRE_UNSC_M52A_Armor_MG_WDL",
	"OPTRE_UNSC_M52A_Armor_Breacher_DES",
	"OPTRE_UNSC_M52A_Armor_Breacher_MAR",
	"OPTRE_UNSC_M52A_Armor_Breacher_OLI",
	"OPTRE_UNSC_M52A_Armor_Breacher_SNO",
	"OPTRE_UNSC_M52A_Armor_Breacher_TRO",
	"OPTRE_UNSC_M52A_Armor_Breacher_URB",
	"OPTRE_UNSC_M52A_Armor_Breacher_WDL",
	"OPTRE_UNSC_M52A_Armor_Corpsman_MAR",
	"OPTRE_UNSC_M52A_Armor_Grenadier_DES",
	"OPTRE_UNSC_M52A_Armor_Grenadier_MAR",
	"OPTRE_UNSC_M52A_Armor_Grenadier_OLI",
	"OPTRE_UNSC_M52A_Armor_Grenadier_SNO",
	"OPTRE_UNSC_M52A_Armor_Grenadier_TRO",
	"OPTRE_UNSC_M52A_Armor_Grenadier_URB",
	"OPTRE_UNSC_M52A_Armor_Grenadier_WDL",
	"OPTRE_UNSC_M52A_Armor3_DES",
	"OPTRE_UNSC_M52A_Armor3_MAR",
	"OPTRE_UNSC_M52A_Armor3_OLI",
	"OPTRE_UNSC_M52A_Armor3_SNO",
	"OPTRE_UNSC_M52A_Armor3_TRO",
	"OPTRE_UNSC_M52A_Armor3_URB",
	"OPTRE_UNSC_M52A_Armor3_WDL",
	"OPTRE_UNSC_M52A_Armor_Marksman_DES",
	"OPTRE_UNSC_M52A_Armor_Marksman_MAR",
	"OPTRE_UNSC_M52A_Armor_Marksman_OLI",
	"OPTRE_UNSC_M52A_Armor_Marksman_SNO",
	"OPTRE_UNSC_M52A_Armor_Marksman_TRO",
	"OPTRE_UNSC_M52A_Armor_Marksman_URB",
	"OPTRE_UNSC_M52A_Armor_Marksman_WDL",
	"OPTRE_UNSC_M52A_Armor2_DES",
	"OPTRE_UNSC_M52A_Armor2_MAR",
	"OPTRE_UNSC_M52A_Armor2_OLI",
	"OPTRE_UNSC_M52A_Armor2_SNO",
	"OPTRE_UNSC_M52A_Armor2_TRO",
	"OPTRE_UNSC_M52A_Armor2_URB",
	"OPTRE_UNSC_M52A_Armor2_WDL",
	"OPTRE_UNSC_M52A_Armor_Rifleman_DES",
	"OPTRE_UNSC_M52A_Armor_Rifleman_MAR",
	"OPTRE_UNSC_M52A_Armor_Rifleman_OLI",
	"OPTRE_UNSC_M52A_Armor_Rifleman_SNO",
	"OPTRE_UNSC_M52A_Armor_Rifleman_TRO",
	"OPTRE_UNSC_M52A_Armor_Rifleman_URB",
	"OPTRE_UNSC_M52A_Armor_Rifleman_WDL",
	"OPTRE_UNSC_M52A_Armor_SoftD",
	"OPTRE_UNSC_M52A_Armor_SoftDK",
	"OPTRE_UNSC_M52A_Armor_Soft",
	"OPTRE_UNSC_M52A_Armor4_DES",
	"OPTRE_UNSC_M52A_Armor4_MAR",
	"OPTRE_UNSC_M52A_Armor4_OLI",
	"OPTRE_UNSC_M52A_Armor4_SNO",
	"OPTRE_UNSC_M52A_Armor4_TRO",
	"OPTRE_UNSC_M52A_Armor4_URB",
	"OPTRE_UNSC_M52A_Armor4_WDL",
	"OPTRE_UNSC_M52D_Armor_Light"
];
(_loadoutData get "Hvests") append [
	"OPTRE_Vest_CMA_Heavy",
	"OPTRE_UNSC_M52A_Armor1_DES",
	"OPTRE_UNSC_M52A_Armor1_MAR",
	"OPTRE_UNSC_M52A_Armor1_OLI",
	"OPTRE_UNSC_M52A_Armor1_SNO",
	"OPTRE_UNSC_M52A_Armor1_TRO",
	"OPTRE_UNSC_M52A_Armor1_URB",
	"OPTRE_UNSC_M52A_Armor1_WDL",
	"OPTRE_UNSC_M52A_Armor_Medic_DES",
	"OPTRE_UNSC_M52A_Armor_Medic_OLI",
	"OPTRE_UNSC_M52A_Armor_Medic_SNO",
	"OPTRE_UNSC_M52A_Armor_Medic_TRO",
	"OPTRE_UNSC_M52A_Armor_Medic_URB",
	"OPTRE_UNSC_M52A_Armor_Medic_WDL",
	"OPTRE_UNSC_M52A_Armor_TL_DES",
	"OPTRE_UNSC_M52A_Armor_TL_MAR",
	"OPTRE_UNSC_M52A_Armor_TL_OLI",
	"OPTRE_UNSC_M52A_Armor_TL_SNO",
	"OPTRE_UNSC_M52A_Armor_TL_TRO",
	"OPTRE_UNSC_M52A_Armor_TL_URB",
	"OPTRE_UNSC_M52A_Armor_TL_WDL",
	"OPTRE_UNSC_M52D_Armor",
	"OPTRE_UNSC_M52D_Armor_Convader",
	"OPTRE_UNSC_M52D_Armor_Deltagamer",
	"OPTRE_UNSC_M52D_Armor_Demolitions",
	"OPTRE_UNSC_M52D_Armor_Dog",
	"OPTRE_UNSC_M52D_Armor_Evolved",
	"OPTRE_UNSC_M52D_Armor_Evolved_Green",
	"OPTRE_UNSC_M52D_Armor_Evolved_White",
	"OPTRE_UNSC_M52D_Armor_Forky",
	"OPTRE_UNSC_M52D_Armor_Jedi",
	"OPTRE_UNSC_M52D_Armor_Leigh",
	"OPTRE_UNSC_M52D_Armor_Lum",
	"OPTRE_UNSC_M52D_Armor_Medic",
	"OPTRE_UNSC_M52D_Armor_Namenai",
	"OPTRE_UNSC_M52D_Armor_Nighto",
	"OPTRE_UNSC_M52D_Armor_Rifleman",
	"OPTRE_UNSC_M52D_Armor_Scorch",
	"OPTRE_UNSC_M52D_Armor_Scout",
	"OPTRE_UNSC_M52D_Armor_Scouter407",
	"OPTRE_UNSC_M52D_Armor_Storey",
	"OPTRE_UNSC_M52D_Armor_Stripes",
	"OPTRE_UNSC_M52D_Armor_Thomas",
	"OPTRE_UNSC_M52D_Armor_Venom",
	"OPTRE_UNSC_M52D_Armor_Wilk",
	"OPTRE_MJOLNIR_MkVBArmor_Human"
];
(_loadoutData get "sniVests") append [
	"OPTRE_UNSC_M52A_Armor_Sniper_DES",
	"OPTRE_UNSC_M52A_Armor_Sniper_MAR",
	"OPTRE_UNSC_M52A_Armor_Sniper_OLI",
	"OPTRE_UNSC_M52A_Armor_Sniper_SNO",
	"OPTRE_UNSC_M52A_Armor_Sniper_TRO",
	"OPTRE_UNSC_M52A_Armor_Sniper_URB",
	"OPTRE_UNSC_M52A_Armor_Sniper_WDL",
	"OPTRE_UNSC_M52A_Armor_Marksman_DES",
	"OPTRE_UNSC_M52A_Armor_Marksman_MAR",
	"OPTRE_UNSC_M52A_Armor_Marksman_OLI",
	"OPTRE_UNSC_M52A_Armor_Marksman_SNO",
	"OPTRE_UNSC_M52A_Armor_Marksman_TRO",
	"OPTRE_UNSC_M52A_Armor_Marksman_URB",
	"OPTRE_UNSC_M52A_Armor_Marksman_WDL",
	"OPTRE_UNSC_M52D_Armor_Marksman",
	"OPTRE_UNSC_M52D_Armor_Sniper",
	"OPTRE_UNSC_M52D_Armor_Scout"
];
(_loadoutData get "backpacks") append [
	"OPTRE_Armored_Matrix",
	"OPTRE_ONI_Researcher_Suitcase",
	"OPTRE_Fury_Backpack_Nuke",
	"OPTRE_ILCS_Rucksack_Medical",
	"OPTRE_ILCS_Rucksack_Black",
	"OPTRE_S12_SOLA_Jetpack",
	"OPTRE_S12_SOLA_Jetpack_Heavy",
	"OPTRE_S12_SOLA_Jetpack_Medical",
	"OPTRE_UNSC_Backpack",
	"OPTRE_UNSC_Rucksack",
	"OPTRE_UNSC_Rucksack_Medic"
];
(_loadoutData get "longRangeRadios") append [
	"OPTRE_ANPRC_515",
	"OPTRE_ANPRC_521_Black",
	"OPTRE_ANPRC_521_Green",
	"OPTRE_ANPRC_521_Snow",
	"OPTRE_ANPRC_521_Tan",
	"OPTRE_ANPRC_521_URF"
];
(_loadoutData get "atBackpacks") append [
	"OPTRE_ILCS_Rucksack_Heavy",
	"OPTRE_UNSC_Rucksack_Heavy"
];
(_loadoutData get "helmets") append [
	"OPTRE_ONI_Researcher_Headgear",
	"OPTRE_ONI_Researcher_Headgear_p",
	"OPTRE_Cap_FinalDawn",
	"OPTRE_UNSC_Cap_ODST",
	"OPTRE_CPD_CH251_Brown",
	"OPTRE_CPD_CH251_DME",
	"OPTRE_CPD_CH251_URF",
	"OPTRE_CPD_CH251_White",
	"OPTRE_CPD_CH251P",
	"OPTRE_UNSC_CH252_Helmet2_DES_MED",
	"OPTRE_UNSC_CH252_Helmet2_DES",
	"OPTRE_UNSC_CH252_Helmet2_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet2_MAR",
	"OPTRE_UNSC_CH252_Helmet2_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet2_OLI",
	"OPTRE_UNSC_CH252_Helmet2_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet2_SNO",
	"OPTRE_UNSC_CH252_Helmet2_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet2_TRO",
	"OPTRE_UNSC_CH252_Helmet2_URB_MED",
	"OPTRE_UNSC_CH252_Helmet2_URB",
	"OPTRE_UNSC_CH252_Helmet2_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet2_WDL",
	"OPTRE_UNSC_CH252_Helmet3_DES",
	"OPTRE_UNSC_CH252_Helmet3_OLI",
	"OPTRE_UNSC_CH252_Helmet3_TRO",
	"OPTRE_UNSC_CH252_Helmet3_WDL",
	"OPTRE_UNSC_CH252_Helmet_DES_MED",
	"OPTRE_UNSC_CH252_Helmet_DES",
	"OPTRE_UNSC_CH252_Helmet_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet_MAR",
	"OPTRE_UNSC_CH252_Helmet_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet_OLI",
	"OPTRE_UNSC_CH252_Helmet_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet_SNO",
	"OPTRE_UNSC_CH252_Helmet_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet_TRO",
	"OPTRE_UNSC_CH252_Helmet_URB_MED",
	"OPTRE_UNSC_CH252_Helmet_URB",
	"OPTRE_UNSC_CH252_Helmet_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet_WDL",
	"OPTRE_UNSC_CH252A_Black_Helmet",
	"OPTRE_UNSC_CH252A_Brown_Helmet",
	"OPTRE_UNSC_CH252A_Helmet",
	"OPTRE_UNSC_CH252A_Marine_Helmet",
	"OPTRE_UNSC_CH252A_Tan_Helmet",
	"OPTRE_UNSC_CH252A_Tropic_Helmet",
	"OPTRE_UNSC_CH252A_White_Helmet",
	"OPTRE_UNSC_CH252D_Helmet",
	"OPTRE_UNSC_CH252D_Helmet_Deltagamer",
	"OPTRE_UNSC_CH252D_Helmet_Dog",
	"OPTRE_UNSC_CH252D_Helmet_Evolved_Green",
	"OPTRE_UNSC_CH252D_Helmet_Evolved_White",
	"OPTRE_UNSC_CH252D_Helmet_Evolved",
	"OPTRE_UNSC_CH252D_Helmet_Convader",
	"OPTRE_UNSC_CH252D_Helmet_Forky",
	"OPTRE_UNSC_CH252D_Helmet_Jedi",
	"OPTRE_UNSC_CH252D_Helmet_Leigh",
	"OPTRE_UNSC_CH252D_Helmet_Lum",
	"OPTRE_UNSC_CH252D_Helmet_Namenai",
	"OPTRE_UNSC_CH252D_Helmet_Nighto",
	"OPTRE_UNSC_CH252D_Helmet_Scorch",
	"OPTRE_UNSC_CH252D_Helmet_Scouter407",
	"OPTRE_UNSC_CH252D_Helmet_Storey",
	"OPTRE_UNSC_CH252D_Helmet_Stripes",
	"OPTRE_UNSC_CH252D_Helmet_Thomas",
	"OPTRE_UNSC_CH252D_Helmet_Venom",
	"OPTRE_UNSC_CH252D_Helmet_Wilk",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Black",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Brown",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Marine",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Snow",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Tan",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Tropic",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Black",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Brown",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Marine",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Snow",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Tan",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Tropic",
	"OPTRE_CH255_Security_Advanced_Type_3_Helmet",
	"OPTRE_CH255_Security_Advanced_Type_4_Helmet",
	"OPTRE_CH255_Security_Basic_Type_1_Helmet",
	"OPTRE_CH255_Security_Basic_Type_1_Light_Helmet",
	"OPTRE_CH255_Security_Basic_Type_2_Helmet",
	"OPTRE_CH255_Security_Basic_Type_3_Helmet",
	"OPTRE_CH255_Security_Basic_Type_3_Helmet_Black",
	"OPTRE_CH255_Security_Basic_Type_3_Helmet_Spartan_Black",
	"OPTRE_CH255_Security_Type_1_Helmet",
	"OPTRE_CH255_Security_Type_2_Helmet",
	"OPTRE_CH255_Security_Type_3_Helmet",
	"OPTRE_CH255_Security_Type_4_Helmet",
	"OPTRE_CMA_Helmet",
	"OPTRE_CMA_Helmet_chops",
	"OPTRE_CMA_Helmet_ear",
	"OPTRE_CMA_Helmet_headset",
	"OPTRE_CPD_Cap",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_DES_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_DES",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_MAR",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_OLI",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_SNO",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_TRO",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_URB_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_URB",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_WDL",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_DES_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_DES",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_MAR",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_OLI",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_SNO",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_TRO",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_URB_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_URB",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_WDL",
	"OPTRE_UNSC_CQB_Helmet",
	"OPTRE_UNSC_CQC_Helmet",
	"OPTRE_UNSC_EOD_Helmet",
	"OPTRE_UNSC_JFO_Helmet",
	"OPTRE_UNSC_Commando_Helmet",
	"OPTRE_UNSC_Commando_Helmet_Black",
	"OPTRE_UNSC_Commando_Helmet_Blue",
	"OPTRE_UNSC_Commando_Helmet_Red",
	"OPTRE_UNSC_Security_Helmet",
	"OPTRE_UNSC_Operator_Helmet",
	"OPTRE_UNSC_HRPilot_Helmet",
	"OPTRE_UNSC_HRPilot_Helmet_Haunted",
	"OPTRE_MJOLNIR_MkVBHelmet_Human",
	"OPTRE_UNSC_Scout_Helmet",
	"OPTRE_UNSC_Scout_Black_Helmet",
	"OPTRE_UNSC_Scout_Blue_Helmet",
	"OPTRE_UNSC_Scout_Red_Helmet",
	"OPTRE_h_PatrolCap_Brown",
	"OPTRE_h_PatrolCap_Green",
	"OPTRE_UNSC_PatrolCap_Army",
	"OPTRE_UNSC_PatrolCap_Marines",
	"OPTRE_PatrolCap_Navy",
	"OPTRE_UNSC_Recon_Helmet",
	"OPTRE_UNSC_Watchcap"
];
(_loadoutData get "slHat") append [
	"OPTRE_ONI_Researcher_Headgear",
	"OPTRE_ONI_Researcher_Headgear_p",
	"OPTRE_Cap_FinalDawn",
	"OPTRE_UNSC_Cap_ODST",
	"OPTRE_CPD_CH251_Brown",
	"OPTRE_CPD_CH251_DME",
	"OPTRE_CPD_CH251_URF",
	"OPTRE_CPD_CH251_White",
	"OPTRE_CPD_CH251P",
	"OPTRE_UNSC_CH252_Helmet2_DES_MED",
	"OPTRE_UNSC_CH252_Helmet2_DES",
	"OPTRE_UNSC_CH252_Helmet2_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet2_MAR",
	"OPTRE_UNSC_CH252_Helmet2_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet2_OLI",
	"OPTRE_UNSC_CH252_Helmet2_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet2_SNO",
	"OPTRE_UNSC_CH252_Helmet2_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet2_TRO",
	"OPTRE_UNSC_CH252_Helmet2_URB_MED",
	"OPTRE_UNSC_CH252_Helmet2_URB",
	"OPTRE_UNSC_CH252_Helmet2_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet2_WDL",
	"OPTRE_UNSC_CH252_Helmet3_DES",
	"OPTRE_UNSC_CH252_Helmet3_OLI",
	"OPTRE_UNSC_CH252_Helmet3_TRO",
	"OPTRE_UNSC_CH252_Helmet3_WDL",
	"OPTRE_UNSC_CH252_Helmet_DES_MED",
	"OPTRE_UNSC_CH252_Helmet_DES",
	"OPTRE_UNSC_CH252_Helmet_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet_MAR",
	"OPTRE_UNSC_CH252_Helmet_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet_OLI",
	"OPTRE_UNSC_CH252_Helmet_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet_SNO",
	"OPTRE_UNSC_CH252_Helmet_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet_TRO",
	"OPTRE_UNSC_CH252_Helmet_URB_MED",
	"OPTRE_UNSC_CH252_Helmet_URB",
	"OPTRE_UNSC_CH252_Helmet_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet_WDL",
	"OPTRE_UNSC_CH252A_Black_Helmet",
	"OPTRE_UNSC_CH252A_Brown_Helmet",
	"OPTRE_UNSC_CH252A_Helmet",
	"OPTRE_UNSC_CH252A_Marine_Helmet",
	"OPTRE_UNSC_CH252A_Tan_Helmet",
	"OPTRE_UNSC_CH252A_Tropic_Helmet",
	"OPTRE_UNSC_CH252A_White_Helmet",
	"OPTRE_UNSC_CH252D_Helmet",
	"OPTRE_UNSC_CH252D_Helmet_Deltagamer",
	"OPTRE_UNSC_CH252D_Helmet_Dog",
	"OPTRE_UNSC_CH252D_Helmet_Evolved_Green",
	"OPTRE_UNSC_CH252D_Helmet_Evolved_White",
	"OPTRE_UNSC_CH252D_Helmet_Evolved",
	"OPTRE_UNSC_CH252D_Helmet_Convader",
	"OPTRE_UNSC_CH252D_Helmet_Forky",
	"OPTRE_UNSC_CH252D_Helmet_Jedi",
	"OPTRE_UNSC_CH252D_Helmet_Leigh",
	"OPTRE_UNSC_CH252D_Helmet_Lum",
	"OPTRE_UNSC_CH252D_Helmet_Namenai",
	"OPTRE_UNSC_CH252D_Helmet_Nighto",
	"OPTRE_UNSC_CH252D_Helmet_Scorch",
	"OPTRE_UNSC_CH252D_Helmet_Scouter407",
	"OPTRE_UNSC_CH252D_Helmet_Storey",
	"OPTRE_UNSC_CH252D_Helmet_Stripes",
	"OPTRE_UNSC_CH252D_Helmet_Thomas",
	"OPTRE_UNSC_CH252D_Helmet_Venom",
	"OPTRE_UNSC_CH252D_Helmet_Wilk",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Black",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Brown",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Marine",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Snow",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Tan",
	"OPTRE_CH255_Security_Advanced_Type_1_Helmet_Tropic",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Black",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Brown",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Marine",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Snow",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Tan",
	"OPTRE_CH255_Security_Advanced_Type_2_Helmet_Tropic",
	"OPTRE_CH255_Security_Advanced_Type_3_Helmet",
	"OPTRE_CH255_Security_Advanced_Type_4_Helmet",
	"OPTRE_CH255_Security_Basic_Type_1_Helmet",
	"OPTRE_CH255_Security_Basic_Type_1_Light_Helmet",
	"OPTRE_CH255_Security_Basic_Type_2_Helmet",
	"OPTRE_CH255_Security_Basic_Type_3_Helmet",
	"OPTRE_CH255_Security_Basic_Type_3_Helmet_Black",
	"OPTRE_CH255_Security_Basic_Type_3_Helmet_Spartan_Black",
	"OPTRE_CH255_Security_Type_1_Helmet",
	"OPTRE_CH255_Security_Type_2_Helmet",
	"OPTRE_CH255_Security_Type_3_Helmet",
	"OPTRE_CH255_Security_Type_4_Helmet",
	"OPTRE_CMA_Helmet",
	"OPTRE_CMA_Helmet_chops",
	"OPTRE_CMA_Helmet_ear",
	"OPTRE_CMA_Helmet_headset",
	"OPTRE_CPD_Cap",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_DES_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_DES",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_MAR",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_OLI",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_SNO",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_TRO",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_URB_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_URB",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet2_Vacuum_WDL",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_DES_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_DES",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_MAR_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_MAR",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_OLI_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_OLI",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_SNO_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_SNO",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_TRO_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_TRO",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_URB_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_URB",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_WDL_MED",
	"OPTRE_UNSC_CH252_Helmet_Vacuum_WDL",
	"OPTRE_UNSC_CQB_Helmet",
	"OPTRE_UNSC_CQC_Helmet",
	"OPTRE_UNSC_EOD_Helmet",
	"OPTRE_UNSC_JFO_Helmet",
	"OPTRE_UNSC_Commando_Helmet",
	"OPTRE_UNSC_Commando_Helmet_Black",
	"OPTRE_UNSC_Commando_Helmet_Blue",
	"OPTRE_UNSC_Commando_Helmet_Red",
	"OPTRE_UNSC_Security_Helmet",
	"OPTRE_UNSC_Operator_Helmet",
	"OPTRE_UNSC_HRPilot_Helmet",
	"OPTRE_UNSC_HRPilot_Helmet_Haunted",
	"OPTRE_MJOLNIR_MkVBHelmet_Human",
	"OPTRE_UNSC_Scout_Helmet",
	"OPTRE_UNSC_Scout_Black_Helmet",
	"OPTRE_UNSC_Scout_Blue_Helmet",
	"OPTRE_UNSC_Scout_Red_Helmet",
	"OPTRE_h_PatrolCap_Brown",
	"OPTRE_h_PatrolCap_Green",
	"OPTRE_UNSC_PatrolCap_Army",
	"OPTRE_UNSC_PatrolCap_Marines",
	"OPTRE_PatrolCap_Navy",
	"OPTRE_UNSC_Recon_Helmet",
	"OPTRE_UNSC_Watchcap",
	"OPTRE_CMA_Beret",
	"OPTRE_CPD_Beret"
];
(_loadoutData get "sniHats") append [
	"OPTRE_h_Booniehat_Grey",
	"OPTRE_UNSC_CH252_Helmet3_DES",
	"OPTRE_UNSC_CH252_Helmet3_OLI",
	"OPTRE_UNSC_CH252_Helmet3_TRO",
	"OPTRE_UNSC_CH252_Helmet3_WDL"
];

// Аксессуары
(_loadoutData get "glasses") append ["OPTRE_EyePiece","OPTRE_HUD_blk_Glasses","OPTRE_HUD_b_Glasses","OPTRE_HUD_g_Glasses","OPTRE_HUD_In_Glasses","OPTRE_HUD_Glasses","OPTRE_HUD_p_Glasses","OPTRE_HUD_r_Glasses","OPTRE_HUD_w_Glasses","OPTRE_FW_None","OPTRE_CBRN","OPTRE_Glasses_Visor","OPTRE_Glasses_Visor_Blue"];
(_loadoutData get "goggles") append ["OPTRE_Glasses_Cigar","OPTRE_Glasses_Cigarette"];

// Дополнительные предметы для специализаций
_slItems append ["Laserbatteries", "Laserbatteries", "Laserbatteries"];
_eeItems append ["ToolKit", "MineDetector"];
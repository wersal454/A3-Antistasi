
_tanks append ["OPTRE_M808L"];

_baseClassSquadLeaderArray append ["OPTRE_FC_Marines_Soldier_SquadLead","OPTRE_FC_Marines_Soldier_TeamLead","OPTRE_FC_Spartan_TeamLeader"];
_baseClassRiflemanArray append ["OPTRE_FC_Marines_Soldier_Assist_Autorifleman","OPTRE_FC_Marines_Soldier_Breacher","OPTRE_Marines_Soldier_ForwardObserver",
"OPTRE_FC_Marines_Soldier_Rifleman_BR","OPTRE_FC_Marines_Soldier_Rifleman_Light","OPTRE_FC_Marines_Soldier_Rifleman_AR","OPTRE_FC_Spartan_Corpsman","OPTRE_FC_Spartan_Rifleman_BR",
"OPTRE_FC_Spartan_Rifleman_AR","OPTRE_FC_Spartan_Scout"];
_baseClassRadiomanArray append ["OPTRE_FC_Marines_Soldier_Radioman"];
_baseClassMedicArray append ["OPTRE_FC_Marines_Soldier_Medic"];
_baseClassEngineerArray append ["OPTRE_FC_Marines_Soldier_Engineer","OPTRE_FC_Spartan_Engineer"];
_baseClassExplosivesArray append ["OPTRE_FC_Marines_Soldier_Demolitions"];
_baseClassGrenadierArray append ["OPTRE_FC_Marines_Soldier_Grenadier"];
_baseClassLATArray append ["OPTRE_FC_Marines_Soldier_AT_Specialist","OPTRE_FC_Marines_Soldier_Rifleman_AT","OPTRE_FC_Spartan_Rifleman_AT"];
_baseClassATArray append ["OPTRE_FC_Marines_Soldier_AT_Specialist","OPTRE_FC_Marines_Soldier_Rifleman_AT","OPTRE_FC_Spartan_Rifleman_AT"];
_baseClassAAArray append ["OPTRE_FC_Marines_Soldier_AA_Specialist"];
_baseClassMachineGunnerArray append ["OPTRE_FC_Marines_Soldier_Autorifleman","OPTRE_FC_Spartan_Automatic_Rifleman"];
_baseClassMarksmanArray append ["OPTRE_FC_Marines_Soldier_Marksman","OPTRE_FC_Spartan_Marksman"];
_baseClassSniperArray append ["OPTRE_FC_Marines_Soldier_Sniper"];
_baseClassPatrolSniperArray append ["OPTRE_FC_Marines_Soldier_Sniper","OPTRE_FC_Spartan_Scout_Sniper"];
_baseClassPatrolSpotterArray append ["OPTRE_FC_Marines_Soldier_Sniper"];
// ================== Специальные роли ==================

_baseClassCrewArray append ["OPTRE_FC_Marines_Soldier_Crewman","OPTRE_FC_Marines_Soldier_Crewman_Heavy"];
_baseClassPilotArray append ["OPTRE_FC_Marines_Soldier_Airman","OPTRE_FC_Marines_Soldier_Pilot"];
_baseClassUnarmedArray append ["OPTRE_FC_Marines_Soldier_Unarmed","OPTRE_FC_Spartan_MkVI","OPTRE_FC_Spartan"];

if (isClass (configFile >> "cfgVehicles" >> "WBK_HaloHunter_1")) then {
_baseClassSquadLeaderArray append ["WBK_CustomSpartan_3"];
_baseClassRiflemanArray append ["WBK_CustomSpartan_1","WBK_CustomSpartan_7","WBK_CustomSpartan_8"];
_baseClassLATArray append ["WBK_CustomSpartan_6"];
_baseClassATArray append ["WBK_CustomSpartan_6"];
_baseClassMachineGunnerArray append ["WBK_CustomSpartan_5"];
_baseClassMarksmanArray append ["WBK_CustomSpartan_2"];
_baseClassSniperArray append ["WBK_CustomSpartan_4"];
_baseClassPatrolSniperArray append ["WBK_CustomSpartan_4"];
_baseClassPatrolSpotterArray append ["WBK_CustomSpartan_2"];
};

_faces append ["OPTRE_InvisibleFace"];

// Оружие
(_loadoutData get "slRifles") append [
	["OPTRE_FC_Railgun", "", "", "", ["OPTRE_FC_Railgun_Slug", "OPTRE_FC_Railgun_Slug", "OPTRE_FC_Railgun_Slug"], [], ""]
];
(_loadoutData get "designatedGrenadeLaunchers") append [
	["OPTRE_FC_Railgun", "", "", "", ["OPTRE_FC_Railgun_Slug", "OPTRE_FC_Railgun_Slug", "OPTRE_FC_Railgun_Slug"], [], ""]
];

(_loadoutData get "cloakVests") append [
	"OPTRE_FC_M52B_Armor_Sniper_DES",
	"OPTRE_FC_M52B_Armor_Sniper_SNO",
	"OPTRE_FC_M52B_Armor_Sniper_URB",
	"OPTRE_FC_M52B_Armor_Sniper_BRN",
	"OPTRE_FC_M52B_Armor_Sniper"
];

// Основная экипировка
(_loadoutData get "uniforms") append [
	"OPTRE_FC_Marines_Uniform",
	"OPTRE_FC_Marines_Uniform_L",
	"OPTRE_FC_Marines_Uniform_BLK_L",
	"OPTRE_FC_Marines_Uniform_BRN_L",
	"OPTRE_FC_Marines_Uniform_DES_L",
	"OPTRE_FC_Marines_Uniform_GRN_L",
	"OPTRE_FC_Marines_Uniform_SNO_L",
	"OPTRE_FC_Marines_Uniform_TRO_L",
	"OPTRE_FC_Marines_Uniform_WDL_L",
	"OPTRE_FC_Marines_Uniform_BLK",
	"OPTRE_FC_Marines_Uniform_BRN",
	"OPTRE_FC_Marines_Uniform_DES",
	"OPTRE_FC_Marines_Uniform_GRN",
	"OPTRE_FC_Marines_Uniform_SNO",
	"OPTRE_FC_Marines_Uniform_TRO",
	"OPTRE_FC_Marines_Uniform_WDL",
	"OPTRE_FC_Spartan_Uniform",
	"OPTRE_UNSC_MJOLNIR_MKVI_Undersuit_Human"
];
(_loadoutData get "slUniforms") append [
	"OPTRE_FC_Marines_Uniform",
	"OPTRE_FC_Marines_Uniform_L",
	"OPTRE_FC_Marines_Uniform_BLK_L",
	"OPTRE_FC_Marines_Uniform_BRN_L",
	"OPTRE_FC_Marines_Uniform_DES_L",
	"OPTRE_FC_Marines_Uniform_GRN_L",
	"OPTRE_FC_Marines_Uniform_SNO_L",
	"OPTRE_FC_Marines_Uniform_TRO_L",
	"OPTRE_FC_Marines_Uniform_WDL_L",
	"OPTRE_FC_Marines_Uniform_BLK",
	"OPTRE_FC_Marines_Uniform_BRN",
	"OPTRE_FC_Marines_Uniform_DES",
	"OPTRE_FC_Marines_Uniform_GRN",
	"OPTRE_FC_Marines_Uniform_SNO",
	"OPTRE_FC_Marines_Uniform_TRO",
	"OPTRE_FC_Marines_Uniform_WDL",
	"OPTRE_FC_Spartan_Uniform",
	"OPTRE_UNSC_MJOLNIR_MKVI_Undersuit_Human"
];
(_loadoutData get "vests") append [
	"OPTRE_FC_M52B_Armor_Vest",
	"OPTRE_FC_M52B_Armor_Vest_DES",
	"OPTRE_FC_M52B_Armor_Breacher_DES",
	"OPTRE_FC_M52B_Armor_Grenadier_DES",
	"OPTRE_FC_M52B_Armor_Light_DES",
	"OPTRE_FC_M52B_Armor_Rifleman_DES",
	"OPTRE_FC_M52B_Armor_Vest_SNO",
	"OPTRE_FC_M52B_Armor_Breacher_SNO",
	"OPTRE_FC_M52B_Armor_Grenadier_SNO",
	"OPTRE_FC_M52B_Armor_Light_SNO",
	"OPTRE_FC_M52B_Armor_Rifleman_SNO",
	"OPTRE_FC_M52B_Armor_Vest_URB",
	"OPTRE_FC_M52B_Armor_Breacher_URB",
	"OPTRE_FC_M52B_Armor_Grenadier_URB",
	"OPTRE_FC_M52B_Armor_Light_URB",
	"OPTRE_FC_M52B_Armor_Rifleman_URB",
	"OPTRE_FC_M52B_Armor_Vest_BRN",
	"OPTRE_FC_M52B_Armor_Breacher_BRN",
	"OPTRE_FC_M52B_Armor_Grenadier_BRN",
	"OPTRE_FC_M52B_Armor_Light_BRN",
	"OPTRE_FC_M52B_Armor_Rifleman_BRN",
	"OPTRE_FC_M52B_Armor_Breacher",
	"OPTRE_FC_M52B_Armor_Grenadier",
	"OPTRE_FC_M52B_Armor_Light",
	"OPTRE_FC_M52B_Armor_Rifleman"
];
(_loadoutData get "Hvests") append [
	"OPTRE_FC_M52B_Armor_TeamLeader_DES",
	"OPTRE_FC_M52B_Armor_TeamLeader_SNO",
	"OPTRE_FC_M52B_Armor_TeamLeader_URB",
	"OPTRE_FC_M52B_Armor_TeamLeader_BRN",
	"OPTRE_FC_M52B_Armor_TeamLeader",
	"OPTRE_FC_MJOLNIR_Mark_VI_Armor_Human",
	"OPTRE_FC_MJOLNIR_MKV_Armor_Human"
];
(_loadoutData get "sniVests") append [
	"OPTRE_FC_M52B_Armor_Marksman_DES",
	"OPTRE_FC_M52B_Armor_Marksman_SNO",
	"OPTRE_FC_M52B_Armor_Marksman_URB",
	"OPTRE_FC_M52B_Armor_Marksman_BRN",
	"OPTRE_FC_M52B_Armor_Marksman"
];
(_loadoutData get "helmets") append [
	"OPTRE_FC_CH255_Helmet",
	"OPTRE_FC_CH255_Helmet_DES",
	"OPTRE_FC_CH255_Helmet_DES_Medic",
	"OPTRE_FC_CH255_Helmet_Medic",
	"OPTRE_FC_CH255_Helmet_SNO",
	"OPTRE_FC_CH255_Helmet_SNO_Medic",
	"OPTRE_FC_CH255_Helmet_URB",
	"OPTRE_FC_CH255_Helmet_URB_Medic",
	"OPTRE_FC_CH255_Helmet_BRN",
	"OPTRE_FC_CH255_Helmet_BRN_Medic",
	"OPTRE_FC_CH255_Helmet_Visor",
	"OPTRE_FC_CH255_Helmet_DES_Visor",
	"OPTRE_FC_CH255_Helmet_DES_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_SNO_Visor",
	"OPTRE_FC_CH255_Helmet_SNO_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_URB_Visor",
	"OPTRE_FC_CH255_Helmet_URB_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_BRN_Visor",
	"OPTRE_FC_CH255_Helmet_BRN_Visor_Medic",
	"OPTRE_FC_MJOLNIR_MKV_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_EOD_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_EVA_Helmet_Human",
	"OPTRE_FC_MJOLNIR_MKVI_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_Rogue_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_Scout_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_Security_Helmet_Human"
];
(_loadoutData get "slHat") append [
	"OPTRE_FC_CH255_Helmet",
	"OPTRE_FC_CH255_Helmet_DES",
	"OPTRE_FC_CH255_Helmet_DES_Medic",
	"OPTRE_FC_CH255_Helmet_Medic",
	"OPTRE_FC_CH255_Helmet_SNO",
	"OPTRE_FC_CH255_Helmet_SNO_Medic",
	"OPTRE_FC_CH255_Helmet_URB",
	"OPTRE_FC_CH255_Helmet_URB_Medic",
	"OPTRE_FC_CH255_Helmet_BRN",
	"OPTRE_FC_CH255_Helmet_BRN_Medic",
	"OPTRE_FC_CH255_Helmet_Visor",
	"OPTRE_FC_CH255_Helmet_DES_Visor",
	"OPTRE_FC_CH255_Helmet_DES_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_SNO_Visor",
	"OPTRE_FC_CH255_Helmet_SNO_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_URB_Visor",
	"OPTRE_FC_CH255_Helmet_URB_Visor_Medic",
	"OPTRE_FC_CH255_Helmet_BRN_Visor",
	"OPTRE_FC_CH255_Helmet_BRN_Visor_Medic",
	"OPTRE_FC_MJOLNIR_MKV_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_EOD_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_EVA_Helmet_Human",
	"OPTRE_FC_MJOLNIR_MKVI_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_Rogue_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_Scout_Helmet_Human",
	"OPTRE_FC_MJOLNIR_Mark_VI_Security_Helmet_Human"
];

// Аксессуары
(_loadoutData get "goggles") append ["OPTRE_FC_Glasses_Cigar"];

// Дополнительные предметы для специализаций
_slItems append ["OPTRE_FC_BubbleShield"];
_eeItems append ["OPTRE_FC_BubbleShield"];
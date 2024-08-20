//Remmember to update the list @ A3A\addons\scrt\UI\fn_ui_setAvailableBuildingTypes.sqf
//Era Modifiers (Depends on map not modset)
#define BUILDABLES_MODERN_GREEN {"Land_GuardTower_01_F", 300}, {"Land_HBarrier_01_line_3_green_F", 100}, {"Land_HBarrier_01_line_5_green_F", 150}, {"Land_HBarrier_01_line_1_green_F", 50}, {"Land_HBarrier_01_big_4_green_F", 300}, {"Land_HBarrier_01_wall_corridor_green_F", 250}, {"Land_HBarrier_01_wall_corner_green_F", 250}, {"Land_HBarrier_01_wall_6_green_F", 450}, {"Land_HBarrier_01_wall_4_green_F", 400}, {"Land_HBarrier_01_big_tower_green_F", 500}, 
#define BUILDABLES_MODERN_SAND {"Land_GuardTower_01_F", 300}, {"Land_HBarrier_3_F", 100}, {"Land_HBarrier_5_F", 150}, {"Land_HBarrier_1_F", 50}, {"Land_HBarrier_Big_F", 300}, {"Land_HBarrierWall_corridor_F", 250}, {"Land_HBarrierWall_corner_F", 250}, {"Land_HBarrierWall6_F", 450}, {"Land_HBarrierWall4_F", 400}, {"Land_HBarrierTower_F", 500}, 
#define BUILDABLES_HISTORIC {"Land_Tyres_F", 20}, {"Land_Barricade_01_10m_F", 50}, {"Land_Barricade_01_4m_F", 30}, {"Land_DeerStand_01_F", 100},
#define BUILDABLES_SCIFI {"A3AU_Cargo_Post", 450}, {"A3AU_Cargo_Tower", 1000}, {"A3AU_Cargo_HQ", 500}, {"A3AU_Cargo_House", 350}, 

//Map Climate Modifiers (What type of terrain is the biggest area of the map)
#define BUILDABLES_ARID {"Land_BagFence_Corner_F", 10}, {"Land_BagFence_End_F", 10}, {"Land_BagFence_Long_F", 30}, {"Land_BagFence_Round_F", 30}, {"Land_BagFence_Short_F", 20},
#define BUILDABLES_TEMPERATE {"Land_BagFence_01_corner_green_F", 10}, {"Land_BagFence_01_end_green_F", 10}, {"Land_BagFence_01_long_green_F", 30}, {"Land_BagFence_01_round_green_F", 30}, {"Land_BagFence_01_short_green_F", 20},
#define BUILDABLES_ARCTIC {"Land_BagFence_Corner_F", 10}, {"Land_BagFence_End_F", 10}, {"Land_BagFence_Long_F", 30}, {"Land_BagFence_Round_F", 30}, {"Land_BagFence_Short_F", 20},
#define BUILDABLES_TROPIC {"Land_BagFence_01_corner_green_F", 10}, {"Land_BagFence_01_end_green_F", 10}, {"Land_BagFence_01_long_green_F", 30}, {"Land_BagFence_01_round_green_F", 30}, {"Land_BagFence_01_short_green_F", 20},

//Modlist Modifiers (Only for maps that have dependency mods with usable items in them)
#define BUILDABLES_CUP {"TK_GUE_WarfareBBarrier5x_EP1", 600}, {"TK_GUE_WarfareBBarrier10xTall_EP1", 700}, {"TK_WarfareBBarrier10x_EP1", 650}, {"Land_Misc_deerstand", 60}, {"Land_Hlaska", 120}, 
#define BUILDABLES_JBAD {"jbad_Wall_L_2m5", 100}, {"jbad_Wall_L_2m5_corner", 75}, {"jbad_Wall_L_2m5_gate", 75}, {"jbad_wall_l_5m", 150}, {"jbad_wall_L_5m_hole_big", 125}, 

//cDLC Modifiers (For cDLC dependent maps)
#define BUILDABLES_SPEARHEAD 
#define BUILDABLES_PRAIRIE 
#define BUILDABLES_MOBILAZATION 
#define BUILDABLES_WESTREN 

//Ending Build List. (Universal Items)
#define BUILDABLES_UNIVERSAL {"Land_GuardTower_02_F", 150}, {"Land_PortableLight_double_F", 50}, {"Land_LampShabby_F", 75}, {"Land_LampHarbour_F", 100}, {"Land_BarGate_F", 100}, {"Land_SandbagBarricade_01_half_F", 40}, {"Land_SandbagBarricade_01_hole_F", 40}, {"Land_SandbagBarricade_01_F", 40}, {"A3AU_RebHelipad_Square_F", 100}, {"A3AU_RebHelipad_Circle_F", 100}, {"Land_BagBunker_Large_F", 250}, {"Land_BagBunker_Small_F", 150}, {"Land_Bunker_02_light_double_F", 500}, {"Land_GuardBox_01_brown_F", 100}, {"Land_CzechHedgehog_01_new_F", 15}, {"Land_Razorwire_F", 15}

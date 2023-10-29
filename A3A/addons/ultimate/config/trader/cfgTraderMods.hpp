#define ITEM(CLASSNAME, PRICE, TYPE, CONDITION)\
class CLASSNAME {\
    price = PRICE;\
    type = TYPE;\
    condition = CONDITION;\
};

class traderAddons
{
    class addons_base
    {
        addons[] = {};
    };
    class addons_empire : addons_base
    {
        addons[] = {"JMSLLTE_empire_mod"};
    };
    class addons_unsung : addons_base
    {
        addons[] = {"uns_weap_w"};
    };
    class addons_sogpf : addons_base
    {
        addons[] = {"vn_weapons"};
    };
    class addons_3CBF : addons_base
    {
        addons[] = {"UK3CB_Factions_Vehicles_SUV"};
    };
    class addons_IFA : addons_base
    {
        addons[] = {"IFA3_Core"};
    };
    class addons_SPE : addons_base
    {
        addons[] = {"ww2_spe_assets_c_characters_germans_c"};
    };
    class addons_FFAA : addons_base
    {
        addons[] = {"ffaa_data"};
    };
    class addons_Pedagne : addons_base
    {
        addons[] = {"ASZ_Weapons_A3"};
    };
    class addons_SFP : addons_base
    {
        addons[] = {"sfp_soldiers"};
    };
    class addons_PLA : addons_base
    {
        addons[] = {"mas_chi_army"};
    };
    class addons_BWA3 : addons_base
    {
        addons[] = {"bwa3_common"};
    };
    class addons_CW : addons_base
    {
        addons[] = {"3AS_Characters", "442_equipment", "SWLB_clones", "JLTS_core", "CWDependencies"};
    };
    class addons_CUP : addons_base
    {
        addons[] = {"CUP_Creatures_People_Civil_Russia", "CUP_BaseConfigs", "CUP_AirVehicles_Core"};
    };
    class addons_3CBBAF : addons_base
    {
        addons[] = {"UK3CB_BAF_Weapons", "UK3CB_BAF_Vehicles", "UK3CB_BAF_Units_Common", "UK3CB_BAF_Equipment"};
    };
    class addons_RHS : addons_base
    {
        addons[] = {"rhsgref_main", "rhssaf_c_vehicles", "rhs_c_tanks", "RHS_US_A2Port_Armor"};
    };
    class addons_OPTRE : addons_base
    {
        addons[] = {"OPTRE_Core", "OPTRE_FC_Core"};
    };
    class addons_GM : addons_base
    {
        addons[] = {"gm_core"};
    };
    class addons_niarms : addons_base
    {
        addons[] = {"hlcweapons_core"};
    };
    class addons_fwa : addons_base
    {
        addons[] = {"sp_fwa_fal"};
    };
    class addons_tow : addons_base
    {
        addons[] = {"Tier1_Weapons"};
    };
    class addons_sma : addons_base
    {
        addons[] = {"SMA_Weapons"};
    };
    class addons_csa38 : addons_base
    {
        addons[] = {"csa38ii_data"};
    };
    class addons_scion : addons_base
    {
        addons[] = {"sc_weapons"};
    };
    class addons_wrs : addons_base
    {
        addons[] = {"WBK_SciFiWeaponary"};
    };
    class addons_braf : addons_base
    {
        addons[] = {"BRAF_Air"};
    };
    class traderPrefixes
    {
        class base : addons_base
        {
            prefix = "";
        };
        class empire : addons_empire
        {
            prefix = "emp";
        };
        class unsung : addons_unsung
        {
            prefix = "unsstore";
        };
        class sogpf : addons_sogpf
        {
            prefix = "vn";
        };
        class 3CBF : addons_3CBF
        {
            prefix = "3cbf";
        };
        class IFA : addons_IFA
        {
            prefix = "ww2mod";
        };
        class SPE : addons_SPE
        {
            prefix = "ww2cdlc";
        };
        class FFAA : addons_FFAA
        {
            prefix = "ffaastock";
        };
        class Pedagne : addons_Pedagne
        {
            prefix = "italystock";
        };
        class SFP : addons_SFP
        {
            prefix = "sfpstock";
        };
        class PLA : addons_PLA
        {
            prefix = "plastock";
        };
        class BWA3 : addons_BWA3
        {
            prefix = "bwastock";
        };
        class CW : addons_CW
        {
            prefix = "cw";
        };
        class CUP : addons_CUP
        {
            prefix = "cup";
        };
        class 3CBBAF : addons_3CBBAF
        {
            prefix = "3cbbafstock";
        };
        class RHS : addons_RHS
        {
            prefix = "rhs";
        };
        class OPTRE : addons_OPTRE
        {
            prefix = "optre";
        };
        class GM : addons_GM
        {
            prefix = "globmob";
        };
        class niarms : addons_niarms
        {
            prefix = "niarms";
        };
        class fwa : addons_fwa
        {
            prefix = "fwa";
        };
        class tow : addons_tow
        {
            prefix = "tow";
        };
        class sma : addons_sma
        {
            prefix = "sma";
        };
        class csa38 : addons_csa38
        {
            prefix = "csa38";
        };
        class scion : addons_scion
        {
            prefix = "scion";
        };
        class wrs : addons_wrs
        {
            prefix = "wrs";
        };
        class braf : addons_braf
        {
            prefix = "brafstock";
        };
    };
    class blackMarketStock
    {
        #include "vehicles\rhs.hpp"
        #include "vehicles\cup.hpp"
    };
};
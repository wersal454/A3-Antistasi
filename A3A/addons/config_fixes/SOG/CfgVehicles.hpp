//SOG - CfgVehicles.hpp

class CfgVehicles
{
	class vn_b_armor_m113_01_aus_army;
	class vn_b_armor_m125_01_aus_army;
	class vn_b_armor_m577_01_aus_army;
	class vn_b_wheeled_lr2a_mg_02_aus_army;
	class vn_b_wheeled_lr2a_mg_03_aus_army;
	class vn_b_wheeled_lr2a_mg_01_aus_army;
	class vn_b_wheeled_lr2a_03_aus_army;
	class vn_b_wheeled_lr2a_02_aus_army;
	class vn_b_wheeled_lr2a_01_aus_army;
	class vn_o_wheeled_btr40_mg_02;
	class vn_o_wheeled_btr40_mg_01;
	class vn_o_wheeled_btr40_mg_04;
	class vn_o_wheeled_btr40_mg_06;
	class vn_o_wheeled_btr40_mg_05;
	class vn_o_wheeled_btr40_mg_03;
	class vn_o_wheeled_btr40_02;
	class vn_o_wheeled_btr40_01;
	class vn_b_wheeled_m151_mg_04;
	class vn_i_wheeled_m151_mg_01;
	class vn_b_wheeled_m151_mg_02;
	class vn_i_wheeled_m151_mg_06;
	class vn_b_wheeled_m151_mg_03;
	class vn_b_wheeled_m151_mg_05;
	class vn_b_wheeled_m151_01;
	class vn_b_armor_m113_acav_04;
	class vn_b_armor_m113_acav_02;
	class vn_b_armor_m113_acav_01;
	class vn_b_armor_m113_acav_06;
	class vn_b_armor_m113_acav_03;
	class vn_b_armor_m113_acav_05;
	class vn_b_armor_m113_01;
	class vn_i_armor_m125_01;
	class vn_i_armor_m132_01;
	class vn_b_armor_m41_01_01;
	class vn_b_armor_m48_01_01;

	class vn_i_armor_m577_01;
	class vn_b_armor_m67_01_01;
	class vn_o_armor_ot54_01_nva65;
	class vn_o_armor_pt76a_01_pl;
	class vn_o_armor_pt76b_01_nva65;
	class vn_o_armor_t54b_01_nva65;
	class vn_o_armor_type63_01;

	class vn_b_air_ach47_04_01;
	class vn_b_air_ach47_03_01;
	class vn_b_air_ach47_05_01;
	class vn_b_air_ach47_01_01;
	class vn_b_air_ach47_02_01;
	class vn_b_air_ah1g_01;

	class vn_i_air_ch34_02_01;
	class vn_i_air_ch34_01_02;
	class vn_i_air_ch34_02_02;

	class vn_b_air_ch47_04_01;
	class vn_b_air_ch47_03_01;
	class vn_i_air_ch47_01_01;
	class vn_b_air_ch47_02_01;

	class vn_b_air_uh1b_01_09;
	class vn_b_air_uh1b_01_05;
	class vn_b_air_uh1b_01_04;
	class vn_b_air_uh1b_01_03;
	class vn_b_air_uh1b_01_02;
	class vn_b_air_uh1b_01_01;
	class vn_b_air_uh1b_02_05;

	class vn_b_air_uh1c_07_02;
	class vn_b_air_uh1c_07_01;
	class vn_b_air_uh1c_06_01;
	class vn_b_air_uh1c_04_02;
	class vn_b_air_uh1c_04_01;
	class vn_b_air_uh1c_02_02;
	class vn_b_air_uh1c_02_01;
	class vn_b_air_uh1c_05_01;
	class vn_b_air_uh1c_01_02;
	class vn_b_air_uh1c_01_01;
	class vn_b_air_uh1d_04_09;
	class vn_b_air_uh1d_03_06;
	class vn_i_air_uh1d_01_01;
	class vn_b_air_uh1d_01_01;
	class vn_b_air_uh1d_02_01;
	class vn_b_air_uh1e_01_04;
	class vn_b_air_uh1e_02_04;
	class vn_b_air_uh1e_03_04;
	class vn_b_air_uh1f_01_03;
	class vn_b_air_uh1c_03_01;

	class vn_b_air_ch34_04_03;
	class vn_b_air_ch34_04_02;
	class vn_b_air_ch34_04_04;
	class vn_b_air_ch34_04_01;
	class vn_b_air_ch34_03_01;
	class vn_b_air_ch34_01_01;

	///uh 34 and uh1 helis are broken(don't want to apply camos, would require writing camos manually in templates)(or I missed something)
	
	class vn_b_armor_m113_01_aus_army_noinsignia : vn_b_armor_m113_01_aus_army
    {
        textureList[] = {"m113_01",1,"m113_43",1};
    };
	class vn_b_armor_m125_01_aus_army_noinsignia : vn_b_armor_m125_01_aus_army
    {
        textureList[] = {"m125_01",1,"m125_43",1};
    };
	class vn_b_armor_m577_01_aus_army_noinsignia : vn_b_armor_m577_01_aus_army
    {
        textureList[] = {"m577_01",1};
    };
	class vn_b_wheeled_lr2a_mg_01_aus_army_noinsignia : vn_b_wheeled_lr2a_mg_01_aus_army
	{
        textureList[] = {"lr2a_aus_01_01",1,"lr2a_nz_01_01",1,"lr2a_nz_02_01",1,"lr2a_aus_02_01",1,"lr2a_aus_03_01",1,"lr2a_nz_03_01",1};
    };
	class vn_b_wheeled_lr2a_mg_02_aus_army_noinsignia : vn_b_wheeled_lr2a_mg_02_aus_army
	{
        textureList[] = {"lr2a_aus_01_01",1,"lr2a_nz_01_01",1,"lr2a_nz_02_01",1,"lr2a_aus_02_01",1,"lr2a_aus_03_01",1,"lr2a_nz_03_01",1};
    };
	class vn_b_wheeled_lr2a_mg_03_aus_army_noinsignia : vn_b_wheeled_lr2a_mg_03_aus_army
	{
        textureList[] = {"lr2a_aus_01_01",1,"lr2a_nz_01_01",1,"lr2a_nz_02_01",1,"lr2a_aus_02_01",1,"lr2a_aus_03_01",1,"lr2a_nz_03_01",1};
    };

	class vn_b_wheeled_lr2a_03_aus_army_noinsignia : vn_b_wheeled_lr2a_03_aus_army
	{
        textureList[] = {"lr2a_nz_01_22",1,"lr2a_aus_01_02",1,"lr2a_aus_02_02",1,"lr2a_nz_02_22",1,"lr2a_nz_03_22",1,"lr2a_aus_03_02",1};
    };
	class vn_b_wheeled_lr2a_02_aus_army_noinsignia : vn_b_wheeled_lr2a_02_aus_army
	{
        textureList[] = {"lr2a_aus_01_01",1,"lr2a_nz_01_01",1,"lr2a_nz_02_01",1,"lr2a_aus_02_01",1,"lr2a_aus_03_01",1,"lr2a_nz_03_01",1};
    };
	class vn_b_wheeled_lr2a_01_aus_army_noinsignia : vn_b_wheeled_lr2a_01_aus_army
	{
        textureList[] = {"lr2a_aus_01_01",1,"lr2a_nz_01_01",1,"lr2a_nz_02_01",1,"lr2a_aus_02_01",1,"lr2a_aus_03_01",1,"lr2a_nz_03_01",1};
    };

	class vn_o_wheeled_btr40_mg_02_noinsignia : vn_o_wheeled_btr40_mg_02
	{
        textureList[] = {"btr_01",1,"btr_07",1,"btr_08",1,"btr_07",0};
    };
	class vn_o_wheeled_btr40_mg_01_noinsignia : vn_o_wheeled_btr40_mg_01
	{
        textureList[] = {"btr_01",1,"btr_07",1,"btr_08",1,"btr_07",0};
    };
	class vn_o_wheeled_btr40_mg_04_noinsignia : vn_o_wheeled_btr40_mg_04
	{
        textureList[] = {"btr_01",1,"btr_09",1,"btr_10",1};
    };
	class vn_o_wheeled_btr40_mg_05_noinsignia : vn_o_wheeled_btr40_mg_05
	{
        textureList[] = {"btr_01",1,"btr_09",1,"btr_10",1};
    };
	class vn_o_wheeled_btr40_mg_06_noinsignia : vn_o_wheeled_btr40_mg_06
	{
        textureList[] = {"btr_01",1,"btr_09",1,"btr_10",1};
    };
	class vn_o_wheeled_btr40_mg_03_noinsignia : vn_o_wheeled_btr40_mg_03
	{
        textureList[] = {"btr_01",1,"btr_07",1,"btr_08",1,"btr_07",0};
    };
	class vn_o_wheeled_btr40_02_noinsignia : vn_o_wheeled_btr40_02
	{
        textureList[] = {"btr_01",1,"btr_07",1,"btr_08",1,"btr_07",0};
    };
	class vn_o_wheeled_btr40_01_noinsignia : vn_o_wheeled_btr40_01
	{
        textureList[] = {"btr_01",1,"btr_07",1,"btr_08",1,"btr_07",0};
    };
	
	class vn_b_wheeled_m151_mg_04_noinsignia : vn_b_wheeled_m151_mg_04
	{
        textureList[] = {"m151_13",1};
    };
	class vn_i_wheeled_m151_mg_01_noinsignia : vn_i_wheeled_m151_mg_01
	{
        textureList[] = {"m151_01",1};
    };
	class vn_b_wheeled_m151_mg_02_noinsignia : vn_b_wheeled_m151_mg_02
	{
        textureList[] = {"m151_01",1};
    };
	class vn_i_wheeled_m151_mg_06_noinsignia : vn_i_wheeled_m151_mg_06
	{
        textureList[] = {"m151_01",1};
    };
	class vn_b_wheeled_m151_mg_03_noinsignia : vn_b_wheeled_m151_mg_03
	{
        textureList[] = {"m151_01",1};
    };
	class vn_b_wheeled_m151_mg_05_noinsignia : vn_b_wheeled_m151_mg_05
	{
        textureList[] = {"m151_01",1};
    };
	class vn_b_wheeled_m151_01_noinsignia : vn_b_wheeled_m151_01
	{
        textureList[] = {"m151_01",1};
    };

	class vn_b_armor_m113_acav_04_noinsignia : vn_b_armor_m113_acav_04
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_b_armor_m113_acav_02_noinsignia : vn_b_armor_m113_acav_02
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_b_armor_m113_acav_01_noinsignia : vn_b_armor_m113_acav_01
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_b_armor_m113_acav_06_noinsignia : vn_b_armor_m113_acav_06
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_b_armor_m113_acav_03_noinsignia : vn_b_armor_m113_acav_03
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_b_armor_m113_acav_05_noinsignia : vn_b_armor_m113_acav_05
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_b_armor_m113_01_noinsignia : vn_b_armor_m113_01
	{
        textureList[] = {"m113_43",1,"m113_01",1};
    };
	class vn_i_armor_m125_01_noinsignia : vn_i_armor_m125_01
	{
        textureList[] = {"m125_43",1,"m125_01",1};
    };
	class vn_i_armor_m132_01_noinsignia : vn_i_armor_m132_01
	{
        textureList[] = {"m132_43",1,"m132_01",1};
    };

	class vn_b_armor_m41_01_01_noinsignia : vn_b_armor_m41_01_01
	{
        textureList[] = {"m41_04",1};
    };
	class vn_b_armor_m48_01_01_noinsignia : vn_b_armor_m48_01_01
	{
        textureList[] = {"m48_01",1};
    };
	class vn_i_armor_m577_01_noinsignia : vn_i_armor_m577_01
	{
        textureList[] = {"m577_01",1};
    };
	class vn_b_armor_m67_01_01_noinsignia : vn_b_armor_m67_01_01
	{
        textureList[] = {"m67_14",1};
    };
	class vn_o_armor_ot54_01_nva65_noinsignia : vn_o_armor_ot54_01_nva65
	{
        textureList[] = {"t54b_19",1,"t54b_13",1,"t54b_07",1,"ot54_01",1};
    };
	class vn_o_armor_pt76a_01_pl_noinsignia : vn_o_armor_pt76a_01_pl
	{
        textureList[] = {"pt76a_01",1};
    };
	class vn_o_armor_pt76b_01_nva65_noinsignia : vn_o_armor_pt76b_01_nva65
	{
        textureList[] = {"pt76b_01",1};
    };
	class vn_o_armor_t54b_01_nva65_noinsignia : vn_o_armor_t54b_01_nva65
	{
        textureList[] = {"t54b_19",1,"t54b_13",1,"t54b_07",1,"t54b_01",1};
    };
	class vn_o_armor_type63_01_noinsignia : vn_o_armor_type63_01
	{
        textureList[] = {"type63_01",1};
    };

	class vn_b_air_ach47_04_01_noinsignia : vn_b_air_ach47_04_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ach47_03_01_noinsignia : vn_b_air_ach47_03_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ach47_05_01_noinsignia : vn_b_air_ach47_05_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ach47_01_01_noinsignia : vn_b_air_ach47_01_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ach47_02_01_noinsignia : vn_b_air_ach47_02_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ah1g_01_noinsignia : vn_b_air_ah1g_01
	{
        textureList[] = {"ah1g_18",1,"ah1g_19",1,"ah1g_16",1,"ah1g_17",1,"ah1g_20",1,"ah1g_06",1,"ah1g_07",0};
    };

	class vn_i_air_ch34_02_01_noinsignia : vn_i_air_ch34_02_01
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_i_air_ch34_01_02_noinsignia : vn_i_air_ch34_01_02
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_i_air_ch34_02_02_noinsignia : vn_i_air_ch34_02_02
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };

	class vn_b_air_ch47_04_01_noinsignia : vn_b_air_ch47_04_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ch47_03_01_noinsignia : vn_b_air_ch47_03_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_i_air_ch47_01_01_noinsignia : vn_i_air_ch47_01_01
	{
        textureList[] = {"ch47_01",1};
    };
	class vn_b_air_ch47_02_01_noinsignia : vn_b_air_ch47_02_01
	{
        textureList[] = {"ch47_01",1};
    };

	class vn_b_air_uh1b_01_09_noinsignia : vn_b_air_uh1b_01_09
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1b_01_05_noinsignia : vn_b_air_uh1b_01_05
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1b_01_04_noinsignia : vn_b_air_uh1b_01_04
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1b_01_03_noinsignia : vn_b_air_uh1b_01_03
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1b_01_02_noinsignia : vn_b_air_uh1b_01_02
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1b_01_01_noinsignia : vn_b_air_uh1b_01_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1b_02_05_noinsignia : vn_b_air_uh1b_02_05
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_07_02_noinsignia : vn_b_air_uh1c_07_02
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_07_01_noinsignia : vn_b_air_uh1c_07_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_06_01_noinsignia : vn_b_air_uh1c_06_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_04_02_noinsignia : vn_b_air_uh1c_04_02
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_04_01_noinsignia : vn_b_air_uh1c_04_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_02_02_noinsignia : vn_b_air_uh1c_02_02
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_02_01_noinsignia : vn_b_air_uh1c_02_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_05_01_noinsignia : vn_b_air_uh1c_05_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_01_02_noinsignia : vn_b_air_uh1c_01_02
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_01_01_noinsignia : vn_b_air_uh1c_01_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1d_04_09_noinsignia : vn_b_air_uh1d_04_09
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0,"uh1d_01",0};
    };
	class vn_b_air_uh1d_03_06_noinsignia : vn_b_air_uh1d_03_06
	{
        textureList[] = {"uh1d_30",1,"uh1d_32",0,"uh1d_01",0};
    };
	class vn_i_air_uh1d_01_01_noinsignia : vn_i_air_uh1d_01_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0,"uh1d_01",0};
    };
	class vn_b_air_uh1d_01_01_noinsignia : vn_b_air_uh1d_01_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0,"uh1d_01",0};
    };
	class vn_b_air_uh1d_02_01_noinsignia : vn_b_air_uh1d_02_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0,"uh1d_01",0};
    };
	class vn_b_air_uh1f_01_03_noinsignia : vn_b_air_uh1f_01_03
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };
	class vn_b_air_uh1c_03_01_noinsignia : vn_b_air_uh1c_03_01
	{
        textureList[] = {"uh1c_05",1,"uh1c_04",1,"uh1c_17",1,"uh1c_18",1,"uh1c_01",0,"uh1c_21",0};
    };

	class vn_b_air_ch34_04_03_noinsignia : vn_b_air_ch34_04_03
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_b_air_ch34_04_02_noinsignia : vn_b_air_ch34_04_02
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_b_air_ch34_04_04_noinsignia : vn_b_air_ch34_04_04
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_b_air_ch34_04_01_noinsignia : vn_b_air_ch34_04_01
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_b_air_ch34_03_01_noinsignia : vn_b_air_ch34_03_01
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };
	class vn_b_air_ch34_01_01_noinsignia : vn_b_air_ch34_01_01
	{
        textureList[] = {"ch34_04",1,"ch34_03",1,"ch34_06",0};
    };

};
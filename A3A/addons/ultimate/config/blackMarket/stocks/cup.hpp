class cup_market_stock : black_market_stock_base {
	addons[] = { "CUP_Creatures_People_Civil_Russia", "CUP_BaseConfigs", "CUP_AirVehicles_Core" };

    ITEM(CUP_B_BMP2_CDF, 9000, "APC", "tierWar > 3 && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}");
};
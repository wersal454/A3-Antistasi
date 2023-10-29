class cup_market_stock : addons_CUP {
    ITEM(CUP_B_BMP2_CDF, 9000, "APC", "tierWar > 3 && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}");
};
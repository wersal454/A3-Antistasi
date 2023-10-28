class rhs_market_stock : black_market_stock_base {
    addons[] = { "rhsgref_main" };

    ITEM(RHS_TOW_TriPod_WD, 3000, "STATICAT", "tierWar > 3");
    ITEM(rhsgref_BRDM2UM_msv, 3000, "CAR", "true");
    ITEM(rhs_t72ba_tv, 20000, "TANK", "tierWar > 7 && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count (milbases + airportsX) > 0}");
};
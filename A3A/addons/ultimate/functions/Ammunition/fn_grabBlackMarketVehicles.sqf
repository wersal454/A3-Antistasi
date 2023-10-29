/*
    Author:
    Westalgie

    Description:
    Handles grabbing black market vehicles from config. Puts result into the A3U_blackMarketStock global space.

    Params:
	N/A

    Usage:
    [] call A3U_grabBlackMarketVehicles;
*/
private _blackMarketStock = [];
private _baseCfg = configFile >> "A3U" >> "traderAddons" >> "blackMarketStock";
private _cfg = _baseCfg call BIS_fnc_getCfgSubClasses; 
{
	private _addons = getArray (_baseCfg >> _x >> "addons");
	if (count _addons > 0 && { (isClass (configFile >> "CfgPatches" >> _x)) } count _addons != count _addons) then {
		[format ["Skipped %1 from adding to black market list. Addons requirements not met.", _x]] call A3U_fnc_log;
		continue;
	};
	
	private _vehicleCfg = _baseCfg >> _x;
	private _vehicles = _vehicleCfg call BIS_fnc_getCfgSubClasses;
	{
		private _price = getNumber (_vehicleCfg >> _x >> "price");
		private _type = getText (_vehicleCfg >> _x >> "type");
		private _condition = compile getText (_vehicleCfg >> _x >> "condition");
		_blackMarketStock pushBack [_x, _price, _type, _condition];

		[format ["Adding %1 with price = %2, type = %3, condition = %4", _x, _price, _type, _condition]] call A3U_fnc_log;
	} forEach _vehicles;

} forEach _cfg;

A3U_blackMarketStock = _blackMarketStock;
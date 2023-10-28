#define ITEM(CLASSNAME, PRICE, TYPE, CONDITION)\
	class CLASSNAME {\
		price = PRICE;\
		type = TYPE;\
		condition = CONDITION;\
	};

class blackMarketStock {
	class black_market_stock_base {
		addons[] = {};
	};

	#include "stocks\rhs.hpp"
	#include "stocks\cup.hpp"
};
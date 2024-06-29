class forbiddenItems
{
    class forbidden_unlimited_base
    {
        addons[] = {};
        unlimited = 1;
        appearInCrates = 0;
    };
    class forbidden_limited_base : forbidden_unlimited_base
    {
        unlimited = 0;
    };

    class LMG_Mk200_F : forbidden_unlimited_base {}; // here for testing purposes

    #include "cfgForbiddenItemsAndroid.hpp"
    #include "cfgForbiddenItemsCW.hpp"
    #include "cfgForbiddenItemsFWA.hpp"
	#include "cfgForbiddenItemsGM.hpp"
	#include "cfgForbiddenItemsNIA.hpp"
    #include "cfgForbiddenItemsOPTRE.hpp"
    #include "cfgForbiddenItemsPracs.hpp"
    #include "cfgForbiddenItemsSMA.hpp"
    #include "cfgForbiddenItemsTOW.hpp"
    #include "cfgForbiddenItemsUns.hpp"
};
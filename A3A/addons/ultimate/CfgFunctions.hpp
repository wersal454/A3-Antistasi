class CfgFunctions
{
    class A3U
    {
        class Ammunition
        {
            file = QPATHTOFOLDER(functions\Ammunition);
            class grabForbiddenItems {};
            class removeForbiddenItems {};
            class removeUnlockedItems {};
        };
        class cba
        {
            file = QPATHTOFOLDER(functions\cba);
            class settings {};
        };
        class init
        {
            file = QPATHTOFOLDER(functions\init);
            class checkMods {};
            class init {};
            class initZones {};
            class popup {};
        };
        class patches
        {
            file = QPATHTOFOLDER(functions\patches);
            class IMS_stealthKill {};
        };
        class STALKER
        {
            file = QPATHTOFOLDER(functions\STALKER);
            class cleanupAnomalyField {};
            class createAnomalyField {};
            class emission {};
            class fillMapAnomalies {};
        };
        class D37Dome
        {
            file = QPATHTOFOLDER(functions\D37-Dome);
            class guidanceLaws {};
            class handleDome {};
            class handleTargets {};
            class initShells {};
            class pickTarget {};
            class postInitEH {};
            class watchQuality {};
        };
        class D37cram
        {
            file = QPATHTOFOLDER(functions\D37_cram);
            class handleCRAM {};
            class handleCuratorPlacement {};
            class initShells {};
            class pickTargetCRAM {};
            class postInit {};
        };
        class Utility
        {
            file = QPATHTOFOLDER(functions\Utility);
            class exportCrate {};
            class exportPylons {};
            class exportTowns {};
            class hasAddon {};
            class log {};
            class logisticsGrabSeats {};
            class weightTest {};
        };
        class zones
        {
            file = QPATHTOFOLDER(functions\zones);
            class revealRandomZones {};
            class revealZone {};
            class revealZones {};
            class revealZonesDistance {};
        };
    };
};

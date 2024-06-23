/*
Maintainer: DoomMetal
    Handles the initialization and updating of the Black Market dialog.
    This function should only be called from BlackMarket onLoad and control activation EHs.

Arguments:
    <STRING> Mode, only possible value for this dialog is "onLoad"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

Scope: Clients, Local Arguments, Local Effect
Environment: Scheduled for onLoad mode / Unscheduled for everything else unless specified
Public: No
Dependencies:
    None

Example:
    ["onLoad"] spawn A3A_fnc_blackMarketDialog; // initialization
*/

#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params[
    ["_mode","onLoad"], 
    ["_params",[]],
    ["_fnc_populateMenu", {[]}],
    ["_callbackHandlerKey", "BUYFIA"]
];

private _display = findDisplay A3A_IDD_BLACKMARKETVEHICLEDIALOG;
private _paramsTable = _display displayCtrl A3A_IDC_SETUP_BMTABLE;

switch (_mode) do
{
    case ("switchTab"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;

        // private _vehicleType = (_paramsTable getVariable ["vehicleType", ""]);

        // diag_log _vehicleType;

        // private _categoryIndex = _vehicleType lbValue lbCurSel _vehicleType;

        // diag_log _categoryIndex;

        private _display = findDisplay A3A_IDD_BLACKMARKETVEHICLEDIALOG;
        private _selectedTab = _params select 0;

        Debug_1("MainDialog switching tab to %1.", _selectedTab);

        private _selectedTabIDC = -1;
        switch (_selectedTab) do 
        {
            case ("all"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETMAIN;
            };
            case ("artillery"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETARTY;
            };
            case ("apc"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETAPC;
            };
            case ("AA"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETAA;
            };
            case ("uav"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETUAV;
            };
            case ("tank"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETTANK;
            };
            case ("statics"):
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETSTATICS;
            };
            case ("heli"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETHELI;
            };
            case ("plane"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETPLANE;
            };
            case ("armedcar"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETARMEDCAR;
            };
            case ("unarmedcar"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETUNARMEDCAR;
            };
            case ("boat"): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETBOAT;
            };
        };

        if (_selectedTabIDC == -1) exitWith {
            Error("Attempted to access tab without permission : %1", _selectedTab);
        };

        private _allTabs = [
            A3A_IDC_BLACKMARKETMAIN,
            A3A_IDC_BLACKMARKETARTY,
            A3A_IDC_BLACKMARKETAPC,
            A3A_IDC_BLACKMARKETAA,
            A3A_IDC_BLACKMARKETUAV,
            A3A_IDC_BLACKMARKETTANK,
            A3A_IDC_BLACKMARKETSTATICS,
            A3A_IDC_BLACKMARKETHELI,
            A3A_IDC_BLACKMARKETPLANE,
            A3A_IDC_BLACKMARKETARMEDCAR,
            A3A_IDC_BLACKMARKETUNARMEDCAR,
            A3A_IDC_BLACKMARKETBOAT,
            A3A_IDC_BLACKMARKETPREVIEW
        ];

        // Hide all tabs
        Debug("Hiding all tabs");
        {
            private _ctrl = _display displayCtrl _x;
            _ctrl ctrlShow false;
        } forEach _allTabs;


        // Show selected tab
        Debug("Showing selected tab");
        private _selectedTabCtrl = _display displayCtrl _selectedTabIDC;
        _selectedTabCtrl ctrlShow true;
    };

    case ("onLoad"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;
        ["vehicles", [A3A_IDC_BLACKMARKETMAIN, A3A_IDC_BLACKMARKETVEHICLESGROUP, "all"]] call A3A_fnc_blackMarketTabs; ///show all?
        ["vehicles", [A3A_IDC_BLACKMARKETARTY, A3A_IDC_BLACKMARKETVEHICLESGROUPATRY, "artillery"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETAPC, A3A_IDC_BLACKMARKETVEHICLESGROUPAPC, "apc"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETAA, A3A_IDC_BLACKMARKETVEHICLESGROUPAA, "AA"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETUAV, A3A_IDC_BLACKMARKETVEHICLESGROUPUAV, "uav"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETTANK, A3A_IDC_BLACKMARKETVEHICLESGROUPTANK, "tank"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETSTATICS, A3A_IDC_BLACKMARKETVEHICLESGROUPSTATICS, "statics"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETHELI, A3A_IDC_BLACKMARKETVEHICLESGROUPHELI, "heli"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETPLANE, A3A_IDC_BLACKMARKETVEHICLESGROUPPLANE, "plane"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETARMEDCAR, A3A_IDC_BLACKMARKETVEHICLESGROUPARMEDCAR, "armedcar"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETUNARMEDCAR, A3A_IDC_BLACKMARKETVEHICLESGROUPUNARMED, "unarmedcar"]] call A3A_fnc_blackMarketTabs;
        ["vehicles", [A3A_IDC_BLACKMARKETBOAT, A3A_IDC_BLACKMARKETVEHICLESGROUPBOAT, "boat"]] call A3A_fnc_blackMarketTabs;

        // private _vehicleTypes = ["All", "Artillery", "APC", "AA", "UAV", "Tank", "Statics", "Helicopters", "Planes", "Armed Car", "Unarmed Car", "Boat"];
        // private _vals = ["all", "artillery", "apc", "aa", "uav", "tank", "statics", "heli", "plane", "armedcar", "unarmedcar", "boat"];

        // private _valsCtrl = _display ctrlCreate ["A3A_ComboBox_Small", -1 + A3A_IDC_SETUP_BMROWS, _paramsTable];
        // _valsCtrl ctrlSetPosition [GRID_W*35, GRID_H*-17.8, GRID_W*30, GRID_H*5];
        // _valsCtrl ctrlCommit 0;
        // {
        //     private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
        //     _valsCtrl lbSetValue [_index, (_vals find _x)];
        // } forEach _vals;
        // private _default = "all";
        // _valsCtrl lbSetCurSel (_vals find _default);

        // _paramsTable setVariable ["vehicleType", _valsCtrl];

        // show the vehicle tab so that user don't freak out
        private _display = findDisplay A3A_IDD_BLACKMARKETVEHICLEDIALOG;
        private _selectedTabCtrl = _display displayCtrl A3A_IDC_BLACKMARKETMAIN;
        _selectedTabCtrl ctrlShow true;
    };

    case ("onUnload"): 
    {
        ['off'] call SCRT_fnc_ui_toggleMenuBlur;
    };

    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("BlackMarketDialog mode does not exist: %1", _mode);
    };
};

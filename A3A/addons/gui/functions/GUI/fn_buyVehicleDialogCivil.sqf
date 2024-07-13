/*
Maintainer: DoomMetal
    Handles the initialization and updating of the Buy Vehicle dialog.
    This function should only be called from BuyVehicle onLoad and control activation EHs.
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
    ["onLoad"] spawn A3A_fnc_buyVehicleDialog; // initialization
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

switch (_mode) do
{
    case ("switchTab"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;

        private _vehicleType = (uiNamespace getVariable ["cv_vehicleTypeBox", ""]);
        private _categoryIndex = _vehicleType lbValue lbCurSel _vehicleType;

        diag_log _categoryIndex;

        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;

        Debug_1("MainDialog switching tab to %1.", _categoryIndex);

        private _selectedTabIDC = -1;
        switch (_categoryIndex) do 
        {
            case (0): 
            {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEMAIN;
            };
            case (1): 
            {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLECARS;
            };
            case (2): 
            {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLETRUCKS;
            };
            case (3): 
            {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEBOATS;
            };
            case (4): 
            {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEHELI;
            };
            case (5): 
            {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEPLANE;
            };
        };

        if (_selectedTabIDC == -1) exitWith {
            Error("Attempted to access tab without permission : %1", _selectedTab);
        };

        private _allTabs = [
            A3A_IDC_BUYCIVVEHICLEMAIN,
            A3A_IDC_BUYCIVVEHICLECARS,
            A3A_IDC_BUYCIVVEHICLETRUCKS,
            A3A_IDC_BUYCIVVEHICLEBOATS,
            A3A_IDC_BUYCIVVEHICLEHELI,
            A3A_IDC_BUYCIVVEHICLEPLANE,
            A3A_IDC_BUYVEHICLEPREVIEW
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

        private _displayCV = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _cvTable = _displayCV displayCtrl A3A_IDC_SETUP_CVTABLE;

        private _vehicleTypes = ["all","cars","trucks","boats","heli","planes"];
        private _vals = ["civall", "civcars", "civtrucks", "civboats", "civheli", "civplane"];

        private _valsCtrl = _cvTable;
        /* _valsCtrl ctrlSetPosition [GRID_W * -30.4, GRID_H*-17.9, GRID_W*125, GRID_H*5]; */
        _valsCtrl ctrlCommit 0;
        {
            private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
            _valsCtrl lbSetValue [_index, (_vals find _x)];
        } forEach _vals;
        
        private _default = "civall";
        _valsCtrl lbSetCurSel (_vals find _default);
        _valsCtrl lbSetSelected [0, true];

        uiNamespace setVariable ["cv_vehicleTypeBox", _valsCtrl];

        ["vehicles", [A3A_IDC_BUYCIVVEHICLEMAIN, A3A_IDC_CIVVEHICLESGROUP, "civall"]] call A3A_fnc_buyVehicleTabs; ///show all?
        ["vehicles", [A3A_IDC_BUYCIVVEHICLECARS, A3A_IDC_CIVVEHICLESGROUPTRUCKSCARS, "civcars"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLETRUCKS, A3A_IDC_CIVVEHICLESGROUPTRUCKS, "civtrucks"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEBOATS, A3A_IDC_CIVVEHICLESGROUPBOATS, "civboats"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEHELI, A3A_IDC_CIVVEHICLESGROUPHELI, "civheli"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEPLANE, A3A_IDC_CIVVEHICLESGROUPPLANE, "civplane"]] call A3A_fnc_buyVehicleTabs;
    };

    case ("onUnload"): 
    {
        ['off'] call SCRT_fnc_ui_toggleMenuBlur;
    };

    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("BuyVehicle mode does not exist: %1", _mode);
    };
};
/* private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _selectedTab = _params select 0;

        Debug_1("MainDialog switching tab to %1.", _selectedTab);

        private _selectedTabIDC = -1;
        switch (_selectedTab) do 
        {
            case ("civilian"): {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEMAIN;
            };
            case("rebel"): {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEMAIN;};
            case ("static"): {
                _selectedTabIDC = A3A_IDC_BUYSTATICMAIN;
            };
            case("other"): {
                _selectedTabIDC = A3A_IDC_BUYOTHERMAIN;
            };
        };

        if (_selectedTabIDC == -1) exitWith {
            Error("Attempted to access tab without permission : %1", _selectedTab);
        };

        private _allTabs = [
            A3A_IDC_BUYCIVVEHICLEMAIN,
            A3A_IDC_BUYREBVEHICLEMAIN,
            A3A_IDC_BUYSTATICMAIN,
            A3A_IDC_BUYOTHERMAIN,
            A3A_IDC_BUYVEHICLEPREVIEW
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
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEMAIN, A3A_IDC_CIVVEHICLESGROUP, "civilian"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEMAIN, A3A_IDC_REBVEHICLESGROUP, "military"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYSTATICMAIN, A3A_IDC_STATICSGROUP, "static"]] call A3A_fnc_buyVehicleTabs;
        ["other"] call A3A_fnc_buyVehicleTabs;

        // show the vehicle tab so that user don't freak out
        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _selectedTabCtrl = _display displayCtrl A3A_IDC_BUYCIVVEHICLEMAIN;
        _selectedTabCtrl ctrlShow true;
    }; */
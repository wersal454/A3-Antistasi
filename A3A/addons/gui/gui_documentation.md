Function Name: fn_setupConfirmDialog.sqf
What it does: Handles the initialization and tab switching on the setup dialog. This function manages the confirmation dialog that appears when users are about to make changes or start a new game.

How it does that: The function processes different modes (onLoad, confirm) to handle dialog initialization and execution of confirmed actions.

Implementation:

Sqf

Apply
/*
    Handles the initialization and tab switching on the setup dialog.
    This function should only be called from setupDialog onLoad and control activation EHs.

Environment: Scheduled for onLoad mode / Unscheduled for everything else unless specified

Arguments:
    <STRING> Mode, e.g. "onLoad", "switchTab"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_mode", "_params"];
Includes necessary header files for dialog IDs, defines, textures, and script component
Validates parameters: _mode (string) and _params (array)
Sqf

Apply
Debug_1("Confirm dialog called with mode %1", _mode);
Logs the mode being called for debugging purposes
Sqf

Apply
private _display = findDisplay A3A_IDD_SETUPCONFIRMDIALOG;
private _parent = displayParent _display;           // just in case we want to use this garbage with other dialogs?
Finds the confirm dialog display using its ID
Gets the parent display to access data stored there
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        // fetch text from parent
        private _textCtrl = displayCtrl A3A_IDC_SETUP_CONFIRMTEXT;
        _textCtrl ctrlSetText (_parent getVariable "confirmData" select 0);
    };
onLoad case: Sets the confirmation text by retrieving it from the parent dialog's confirmData variable
displayCtrl gets the text control element
ctrlSetText sets the text content to the first element of parent's confirmData
Sqf

Apply
    case ("confirm"):
    {
        private _confirmData = _parent getVariable "confirmData";
        [_confirmData#2] spawn (_confirmData#1);            // Needs to be spawn otherwise displayCtrl doesn't always work? wack
        closeDialog 0;
    };
};
confirm case: Executes the confirmed action
Retrieves the full confirm data array from parent
Spawns the function at index 2 (the action to execute) with the function at index 1 as parameter
Closes the dialog after execution
Where it leads:

Called by setupDialog function when switching to confirm mode
Calls setupLoadgameTab with mode "startGameConfirm" when confirming a game start
Depends on setupDialog and setupLoadgameTab for data flow
Modifies global state through closeDialog and spawn operations
Uses A3A_IDD_SETUPCONFIRMDIALOG and A3A_IDC_SETUP_CONFIRMTEXT constants
Function Name: fn_setupContentTab.sqf
What it does: Manages the content tab in the setup dialog, handling addon and DLC selection for game content.

How it does that: Initializes the addon and DLC selection controls, fills them with available options, and manages user selections.

Implementation:

Sqf

Apply
/*
Function: A3A_fnc_setupRivalsTab
    Handles the initialization and tab switching on the setup dialog.
    This function should only be called from setupDialog onLoad and control activation EHs.
Author: John Jordan (jaj22)

Environment: Scheduled for onLoad, sendData and serverClose modes. Unscheduled for everything else.

Arguments:
    <STRING> Mode, e.g. "onLoad", "switchTab"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.


Modes:
    - update does nothing
    - factionSelected called no new item selectionNames
    - fillFactions fills faction tab with the factions
    - getFactions getter for selected items in tab

Return Value:
    on mode getFactions - returns array of selected items in dialog in form [_factions, _addons, _dlc]

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
Debug_1("setupFactionsTab called with mode %1", _mode);
Logs the mode being executed for debugging
Sqf

Apply
private _display = findDisplay A3A_IDD_SETUPDIALOG;
Finds the main setup dialog display
Sqf

Apply
if (isNil "A3A_setup_loadedPatches") exitWith { Error("No patch data. Load order fuckup?") };
Checks for required patch data and exits with error if missing
Sqf

Apply
// Input: faction config, output: true/false
private _fnc_factionLoaded = {
    getArray (_this/"requiredAddons") findIf { !(_x in A3A_setup_loadedPatches) } == -1
};
Creates a closure function that checks if a faction's required addons are loaded
Uses findIf to locate any missing addons, returns true if all are present
Sqf

Apply
if (isNil {_display getVariable "isContentInitialized"}) then {
    // Fill the addon vics
    private _addonTable = _display displayCtrl A3A_IDC_SETUP_ADDONVICSBOX;
    private _checkCtrls = [];
    {
        private _textCtrl = _display ctrlCreate ["A3A_Text_Small", -1, _addonTable];
        _textCtrl ctrlSetPosition [GRID_W*4, count _checkCtrls*GRID_H*4, GRID_W*40, GRID_H*4];
        _textCtrl ctrlCommit 0;
        if !(_x call _fnc_factionLoaded) then { _textCtrl ctrlSetTextColor A3A_COLOR_TEXT_DARKER_SQF };
        _textCtrl ctrlSetText getText (_x/"displayName");
        _textCtrl ctrlSetTooltip getText (_x/"description");

        private _checkCtrl = _display ctrlCreate ["A3A_Checkbox", -1, _addonTable];
        _checkCtrl ctrlSetPosition [0, count _checkCtrls*GRID_H*4, GRID_W*4, GRID_H*4];
        _checkCtrl ctrlCommit 0;
        _checkCtrl ctrlEnable (_x call _fnc_factionLoaded);				// disable if requirement failed
        _checkCtrl setVariable ["name", configName _x];
        _checkCtrls pushBack _checkCtrl;

    } forEach ("true" configClasses (A3A_SETUP_CONFIGFILE/"A3A"/"AddonVics"));
Initializes the addon vics table if not already done
Creates text controls for each addon vic with display names and descriptions
Creates checkbox controls for each addon vic
Sets checkbox enable state based on whether required addons are loaded
Stores checkbox references in _checkCtrls array for later access
Sqf

Apply
    // Fill the DLC
    // Fetch these automatically but remove DLC without equipment and vehicles
    //private _loadedDLC = getLoadedModsInfo select {_x#3 and !(_x#1 in ["A3","curator","argo","tacops"])}; // TODO: Enable this when the DLC system is properly implemented
    private _dlcTable = _display displayCtrl A3A_IDC_SETUP_DLCBOX;
    _checkCtrls = [];
    {
        private _textCtrl = _display ctrlCreate ["A3A_Text_Small", -1, _dlcTable];
        _textCtrl ctrlSetPosition [GRID_W*4, count _checkCtrls*GRID_H*4, GRID_W*40, GRID_H*4];
        _textCtrl ctrlCommit 0;
        _textCtrl ctrlSetText _x#0;

        private _checkCtrl = _display ctrlCreate ["A3A_Checkbox", -1, _dlcTable];
        _checkCtrl ctrlSetPosition [0, count _checkCtrls*GRID_H*4, GRID_W*4, GRID_H*4];
        _checkCtrl ctrlCommit 0;
        _checkCtrl setVariable ["name", _x#1];
        _checkCtrls pushBack _checkCtrl;

    } forEach A3A_setup_loadedDLC;
    _dlcTable setVariable ["checkCtrls", _checkCtrls];
Initializes DLC table with available DLCs
Creates text and checkbox controls for each DLC
Stores checkbox references in _checkCtrls array
Sets the table's variable to store checkbox references
Sqf

Apply
    _display setVariable ["isContentInitialized", true];
};
Marks the content tab as initialized
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("update"): {};			// Don't hide anything here, nothing to do

    case ("getContent"):
    {
        private _addons = [];
        {
            if (cbChecked _x) then { _addons pushBack (_x getVariable "name") };
        } forEach ((_display displayCtrl A3A_IDC_SETUP_ADDONVICSBOX) getVariable "checkCtrls");

        private _dlc = [];
        {
            if (cbChecked _x) then { _dlc pushBack (_x getVariable "name") };
        } forEach ((_display displayCtrl A3A_IDC_SETUP_DLCBOX) getVariable "checkCtrls");


        [_addons, _dlc];
    };
update case: Does nothing (no updates needed)
getContent case: Returns array of selected addons and DLCs
Collects checked addon names from addon table
Collects checked DLC names from DLC table
Sqf

Apply
    case ("fillContent"):
    {
        // Add saved factions if valid
        // configNames of the occ/inv/reb/civ factions, written by setupLoadgameTab
        (_display getVariable "savedFactions") params ["_savedFactions", "_savedAddons", "_savedDLC"];
        Debug_3("Saved factions: %1 Addons: %2 DLC: %3", _savedFactions, _savedAddons, _savedDLC);

        // Should now set the addonvics & DLC tickboxes according to the save data
        private _addonCtrls = (_display displayCtrl A3A_IDC_SETUP_ADDONVICSBOX) getVariable "checkCtrls";
        private _dlcCtrls = (_display displayCtrl A3A_IDC_SETUP_DLCBOX) getVariable "checkCtrls";
        { _x cbSetChecked false } forEach _addonCtrls + _dlcCtrls;

        {
            private _addon = _x;
            private _index = _addonCtrls findIf { _x getVariable "name" == _addon };
            if (_index == -1) then { Error_1("Addon vics template %1 not found", _x); continue };
            if !(ctrlEnabled (_addonCtrls#_index)) then { Error_1("Addon vics template %1 not loaded", _x); continue };
            (_addonCtrls#_index) cbSetChecked true;
        } forEach _savedAddons;

        {
            private _dlc = _x;
            private _index = _dlcCtrls findIf { _x getVariable "name" == _dlc };
            if (_index == -1) then { Error_1("DLC %1 not loaded", _x); continue };
            (_dlcCtrls#_index) cbSetChecked true;
        } forEach _savedDLC;
    };
fillContent case: Sets checkbox states based on saved data
Retrieves saved addon and DLC data from display variable
Clears all checkboxes
Sets checkboxes for saved addons and DLCs
Handles errors for missing addons or DLCs
Sqf

Apply
    default {
        Error_1("Called with unknown mode %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by setupDialog with modes "fillContent" and "getContent"
Called by setupLoadgameTab for saving/loading content selections
Depends on setupDialog and setupLoadgameTab for data flow
Modifies global state through display control updates
Uses A3A_SETUP_CONFIGFILE, A3A_IDC_SETUP_ADDONVICSBOX, A3A_IDC_SETUP_DLCBOX constants
Synchronization: Updates UI controls on display
Function Name: fn_setupDialog.sqf
What it does: Handles the main setup dialog initialization and tab switching logic.

How it does that: Manages the entire setup dialog lifecycle including initialization, tab switching, and data handling.

Implementation:

Sqf

Apply
/*
    Handles the initialization and tab switching on the setup dialog.
    This function should only be called from setupDialog onLoad and control activation EHs.

Environment: Scheduled for onLoad, sendData and serverClose modes. Unscheduled for everything else.

Arguments:
    <STRING> Mode, e.g. "onLoad", "switchTab"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
Debug_1("Setup dialog called with mode %1", _mode);
Logs the mode being executed
Sqf

Apply
// Function to give a short time difference string from two serverTimeUTC inputs
private _fnc_getTimeDiffString = {
    params ["_oldTime", "_newTime"];
    private _text = ["yr", "mon", "day", "hr", "min"];
    private _range = [0, 12, 30, 24, 60];		// lazy but close enough

    private _diffTime = [0, 0, 0, 0, 0];
    for "_i" from 4 to 0 step -1 do {
        _diffTime set [_i, _diffTime#_i + _newTime#_i - _oldTime#_i];
        if (_i == 0 or _diffTime#_i >= 0) then { continue };
        _diffTime set [_i, _diffTime#_i + _range#_i];
        _diffTime set [_i-1, -1];
    };

    // now find first non-zero
    private _nzi = _diffTime findif {_x!=0};
    if (_nzi == -1) exitWith { "0min" };									// zero time diff
    if (_diffTime#_nzi < 0) exitWith { "???" };							// negative time diff
    if (_nzi == 4) exitWith { format ["%1min", _diffTime#4] };		// just minutes
    format ["%1%2 %3%4", _diffTime#_nzi, _text#_nzi, _diffTime#(_nzi+1), _text#(_nzi+1)];
};
Creates a closure function to calculate time differences
Uses a 5-element array for time components (years, months, days, hours, minutes)
Handles negative time differences and zero differences
Formats output to show meaningful time differences
Sqf

Apply
// Get display
private _display = findDisplay A3A_IDD_SETUPDIALOG;
Finds the setup dialog display
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        if (isNil "A3A_setup_saveData") exitWith { Error("onLoad somehow called without save data") };
        ["fillFactions"] call A3A_fnc_setupFactionsTab;
        ["fillContent"] call A3A_fnc_setupContentTab; 

        ["setSaveData"] call A3A_fnc_setupLoadgameTab;
        ["switchTab", ["loadgame"]] call A3A_fnc_setupDialog;

        ["enableParamsTab"] call A3A_fnc_setupDialog;
    };
onLoad case: Initializes the dialog
Validates save data exists
Calls faction tab to fill factions
Calls content tab to fill content
Sets save data in loadgame tab
Switches to loadgame tab
Enables parameters tab
Sqf

Apply
    case ("onUnload"):
    {
        // Restart if it wasn't server-closed
        if (isNil "A3A_setup_saveData") exitWith {};
        0 spawn {
            sleep 4;
            Debug("Waiting until escape menu is closed");
            waitUntil { sleep 1; isNull findDisplay 49 and !dialog };       // escape menu or user dialog
            if (isNil "A3A_setup_saveData") exitWith {};                        // might have been server-closed during the sleep
            Debug("Restarting setup dialog");
            createDialog "A3A_setupDialog";
        };
    };
onUnload case: Handles dialog closure and restart
Spawns a background task to wait for escape menu to close
Restarts dialog if not server-closed
Uses waitUntil to check for escape menu or dialog closure
Sqf

Apply
    case ("enableParamsTab"):
    {
        private _newGameCtrl = _display displayCtrl A3A_IDC_SETUP_NEWGAMECHECKBOX;
        private _savesLBCtrl = _display displayCtrl A3A_IDC_SETUP_SAVESLISTBOX;
        private _paramsTabCtrl = _display displayCtrl A3A_IDC_SETUP_PARAMSTABBUTTON;
        private _enabled = cbChecked _newGameCtrl || {_savesLBCtrl getVariable ["rowIndex", -1] isNotEqualTo -1};

        _paramsTabCtrl ctrlEnable _enabled;
        _paramsTabCtrl ctrlSetTooltip ([localize "STR_antistasi_dialogs_setup_params_tab_button_disabled", ""] select _enabled);
    };
enableParamsTab case: Enables/disables parameters tab
Checks if new game or save is selected
Enables tab if either condition is true
Sets appropriate tooltip text
Sqf

Apply
    case ("switchTab"):
    {
        _params params ["_selectedTab"];

        Debug_1("SetupDialog switching tab to %1.", _selectedTab);

        private _selectedTabIDC = switch (_selectedTab) do
        {
            case "loadgame": { A3A_IDC_SETUP_LOADGAMETAB };
            case "factions": { A3A_IDC_SETUP_FACTIONSTAB };
            case "params": { A3A_IDC_SETUP_PARAMSTAB };
            case "content": { A3A_IDC_SETUP_CONTENTTAB };
        };

        {
            private _ctrl = _display displayCtrl _x;
            _ctrl ctrlShow (_x == _selectedTabIDC);
        } forEach [A3A_IDC_SETUP_LOADGAMETAB, A3A_IDC_SETUP_FACTIONSTAB, A3A_IDC_SETUP_PARAMSTAB, A3A_IDC_SETUP_CONTENTTAB];

        switch (_selectedTab) do
        {
            case ("loadgame"): { ["update"] call A3A_fnc_setupLoadgameTab };
            case ("factions"): { ["update"] call A3A_fnc_setupFactionsTab };
            case ("params"): { ["update"] call A3A_fnc_setupParamsTab };
            case ("content"): { ["update"] call A3A_fnc_setupContentTab };
        };
    };
switchTab case: Switches between different setup tabs
Determines tab ID based on selected tab name
Shows only the selected tab
Calls update function for the selected tab
Sqf

Apply
    case ("sendData"):
    {
        _params params ["_saveData", "_loadedPatches", "_loadedDLC", "_platform"];

        // Generate user map names
        private _prettyMapHM = createHashMapFromArray [
            ["vt7", "Virolahti"]
            ,["sara", "Sahrani"]
            ,["Cam_Lao_Nam", "Cam Lao Nam"]
            ,["vn_khe_sanh", "Khe Sanh"]
            ,["chernarus_autumn", "Chernarus (A)"]
            ,["chernarus_summer", "Chernarus (S)"]
            ,["chernarus_winter", "Chernarus (W)"]
            ,["Enoch", "Livonia"]
            ,["tem_anizay", "Anizay"]
            ,["cup_chernarus_A3", "Chernarus 2020"]
            ,["brf_sumava", "Šumava"]
        ];
        {
            private _realMap = _x get "map";
            _x set ["mapStr", _prettyMapHM getOrDefault [_realMap, _realMap]];
            _x set ["fileStr", ["Old", "New"] select ((_x get "serverID") isEqualType false)];
            if (!isNil {_x get "ended"}) then { _x set ["timeStr", "Ended"]; continue };
            if (!isNil {_x get "saveTime"}) then {
                _x set ["timeStr", [_x get "saveTime", systemTimeUTC] call _fnc_getTimeDiffString];
            };
            if (!isNil {_x get "version"}) then {
                _x set ["verStr", (_x get "version") splitString "." select [0, 3] joinString "."];        // cap to a.b.c
            };
        } forEach _saveData;

        A3A_setup_saveData = _saveData;
        A3A_setup_loadedPatches = _loadedPatches;
        A3A_setup_loadedDLC = _loadedDLC;
        A3A_setup_platform = _platform;

        if (!isNull _display) exitWith {
            Error("Server sent data while dialog is open? Curious");
            ["onLoad"] spawn A3A_fnc_setupDialog;                                // Should rebuild dialog with new data. Hopefully.
        };

        if (isNull findDisplay 46 or !isNull findDisplay 49 or dialog) then {
            Debug("Waiting until main game display is open and other dialogs are closed");
            waitUntil { sleep 1; !isNull findDisplay 46 and isNull findDisplay 49 and !dialog };
        };
        Debug("Creating setup dialog");
        createDialog "A3A_setupDialog";
    };
sendData case: Processes server-sent data and recreates dialog
Generates user-friendly map names from internal map IDs
Calculates time differences for save files
Updates global variables with new data
Waits for appropriate conditions before recreating dialog
Sqf

Apply
    case ("serverClose"):
    {
        Debug("Server requested dialog close");
        A3A_setup_saveData = nil;
        if (!isNull _display) then { closeDialog 0 };
    };
serverClose case: Handles server-initiated dialog closure
Clears global save data
Closes dialog if open
Sqf

Apply
    default {
    // Log error if attempting to call a mode that doesn't exist
        Error_1("Mode %1 does not exist", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by setupFactionsTab, setupLoadgameTab, setupContentTab, setupParamsTab for tab switching
Called by setupConfirmDialog for confirmation handling
Depends on all setup tab functions for data flow
Modifies global variables A3A_setup_saveData, A3A_setup_loadedPatches, A3A_setup_loadedDLC, A3A_setup_platform
Uses A3A_IDD_SETUPDIALOG, A3A_IDC_SETUP_* constants for UI control references
Synchronization: Uses spawn for background tasks, waitUntil for coordination
Function Name: fn_setupFactionsTab.sqf
What it does: Manages the faction selection tab in the setup dialog, handling faction filtering and selection logic.

How it does that: Initializes faction data, creates faction selection controls, handles faction selection events, and manages faction filtering based on game settings.

Implementation:

Sqf

Apply
/*
Function: A3A_fnc_setupFactionsTab
    Handles the initialization and tab switching on the setup dialog.
    This function should only be called from setupDialog onLoad and control activation EHs.
Author: John Jordan (jaj22)

Environment: Scheduled for onLoad, sendData and serverClose modes. Unscheduled for everything else.

Arguments:
    <STRING> Mode, e.g. "onLoad", "switchTab"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.


Modes:
    - update does nothing
    - factionSelected called no new item selectionNames
    - fillFactions fills faction tab with the factions
    - getFactions getter for selected items in tab

Return Value:
    on mode getFactions - returns array of selected items in dialog in form [_factions, _addons, _dlc]

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
Debug_1("setupFactionsTab called with mode %1", _mode);
Logs the mode being executed
Sqf

Apply
private _display = findDisplay A3A_IDD_SETUPDIALOG;
private _worldName = toLower worldName;
Finds the setup dialog display
Converts world name to lowercase for comparison
Sqf

Apply
if (isNil "A3A_setup_loadedPatches") exitWith { Error("No patch data. Load order fuckup?") };
Validates patch data exists
Sqf

Apply
// Input: faction config, output: true/false
private _fnc_factionLoaded = {
    getArray (_this/"requiredAddons") findIf { !(_x in A3A_setup_loadedPatches) } == -1
};
Creates closure function to check if faction requirements are met
Uses findIf to locate any missing required addons
Sqf

Apply
// Split factions by side and priority-sort
if (isNil {_display getVariable "validFactions"}) then
{
    private _fnc_prioritySort = {
        params ["_factions"];
        private _factionSort = [];
        {
            private _priority = getNumber (_x/"priority") + 0.01*_forEachIndex;
            private _maps = getArray (_x/"maps");
            if (count _maps > 0) then { _priority = _priority + ([-2, 2] select (_worldName in _maps)) };
            if !(_x call _fnc_factionLoaded) then { _priority = _priority - 100 };
            _factionSort pushBack [_priority, _x];
        } forEach _factions;

        _factionSort sort false;
        _factionSort apply { _x#1 };
    };
Creates priority sorting function for factions
Calculates priority based on faction priority, map compatibility, and load status
Sorts factions by priority (descending)
Sqf

Apply
    // prep the valid factions for current modset
    private _factions = [[], [], [], [], []];
    private _factTypeHM = createHashMapFromArray [["Occ", 0], ["Inv", 1], ["Reb", 2], ["Civ", 3], ["Riv", 4]];
    {
        if (getText (_x/"side") == "") then { continue };
        private _factIndex = _factTypeHM get getText (_x/"side");
        (_factions select _factIndex) pushBack _x;
    } forEach ("true" configClasses (A3A_SETUP_CONFIGFILE/"A3A"/"Templates"));
Organizes factions by side (Occupants, Invaders, Rebels, Civilians, Rivals)
Uses hash map for side-to-index mapping
Filters out factions with no side defined
Sqf

Apply
    _factions = _factions apply { [_x] call _fnc_prioritySort };
    _display setVariable ["validFactions", _factions];
};
Applies priority sorting to each faction group
Stores valid factions in display variable
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("update"): {
        _params params ["_listboxes"];

        private _rebLBCtrl = _display displayCtrl A3A_IDC_SETUP_REBELSLISTBOX;
        private _civLBCtrl = _display displayCtrl A3A_IDC_SETUP_CIVILIANSLISTBOX;
        private _invLBCtrl = _display displayCtrl A3A_IDC_SETUP_INVADERSLISTBOX;
        private _rivLBCtrl = _display displayCtrl A3A_IDC_SETUP_RIVALSLISTBOX;

        
        private _rebLBHandler =_rebLBCtrl getVariable "LBHandler";
        if (!isNil "_rebLBHandler") then { _rebLBCtrl ctrlRemoveEventHandler ["MouseMoving", _rebLBHandler] };
        if (_rebLBCtrl in _listboxes) then {
            _rebLBHandler = _rebLBCtrl ctrlAddEventHandler ["MouseMoving", {
                params ["_rebLBCtrl", "_xPos", "_yPos", "_mouseOver"];

                private _display = findDisplay A3A_IDD_SETUPDIALOG;
                private _civLabelCtrl = _display displayCtrl A3A_IDC_SETUP_CIVILIANSLABEL;
                private _civLBCtrl = _display displayCtrl A3A_IDC_SETUP_CIVILIANSLISTBOX;

                if (_mouseOver) then {
                    if (_rebLBCtrl getVariable "Expanded") exitWith {};
                    _rebLBCtrl setVariable ["Expanded", true];
                    
                    private _rebLBSize = lbSize _rebLBCtrl;
                    private _LBx = 4 * GRID_W;
                    private _rebLBy = 8 * GRID_H;
                    private _LBw = 38 * GRID_W;
                    private _Lh = 4 * GRID_H;
                    private _rebLBh = ((_rebLBSize * 3.25) min 66) * GRID_H;
                    private _civLy = (_rebLBy + _rebLBh + 2 * GRID_H);
                    private _civLBy = (_civLy + 4 * GRID_H);
                    private _civLBh = (92 * GRID_H - _civLy);
                    _rebLBCtrl ctrlSetPosition [_LBx, _rebLBy, _LBw, _rebLBh];
                    _civLabelCtrl ctrlSetPosition [_LBx, _civLy, _LBw, _Lh];
                    _civLBCtrl ctrlSetPosition [_LBx, _civLBy, _LBw, _civLBh];
                    { _x ctrlCommit 0.4 } forEach [_rebLBCtrl, _civLabelCtrl, _civLBCtrl];
                } else {
                    _rebLBCtrl ctrlSetPosition [4 * GRID_W, 8 * GRID_H, 38 * GRID_W, 40 * GRID_H];
                    _civLabelCtrl ctrlSetPosition [4 * GRID_W, 50 * GRID_H, 38 * GRID_W, 4 * GRID_H];
                    _civLBCtrl ctrlSetPosition [4 * GRID_W, 54 * GRID_H, 38 * GRID_W, 42 * GRID_H];
                    { _x ctrlCommit 0.4 } forEach [_rebLBCtrl, _civLabelCtrl, _civLBCtrl];
                    _rebLBCtrl setVariable ["Expanded", false];
                };
            }];
            _rebLBCtrl setVariable ["LBHandler", _rebLBHandler];
        };
update case: Manages listbox expansion behavior
Handles mouse movement events for rebel listbox to expand/collapse
Adjusts positions of related controls when expanding
Uses ctrlSetPosition and ctrlCommit to animate changes
Sqf

Apply
        private _civLBHandler = _civLBCtrl getVariable "LBHandler";
        if (!isNil "_civLBHandler") then { _civLBCtrl ctrlRemoveEventHandler ["MouseMoving", _civLBHandler] };
        if (_civLBCtrl in _listboxes) then {
            _civLBHandler = _civLBCtrl ctrlAddEventHandler ["MouseMoving", {
                params ["_civLBCtrl", "_xPos", "_yPos", "_mouseOver"];

                private _display = findDisplay A3A_IDD_SETUPDIALOG;
                private _civLabelCtrl = _display displayCtrl A3A_IDC_SETUP_CIVILIANSLABEL;
                private _rebLBCtrl = _display displayCtrl A3A_IDC_SETUP_REBELSLISTBOX;

                if (_mouseOver) then {
                    if (_civLBCtrl getVariable "Expanded") exitWith {};
                    _civLBCtrl setVariable ["Expanded", true];
                    
                    _rebLBCtrl ctrlSetPosition [4 * GRID_W, 8 * GRID_H, 38 * GRID_W, 16 * GRID_H];
                    _civLabelCtrl ctrlSetPosition [4 * GRID_W, 26 * GRID_H, 38 * GRID_W, 4 * GRID_H];
                    _civLBCtrl ctrlSetPosition [4 * GRID_W, 30 * GRID_H, 38 * GRID_W, 66 * GRID_H];
                    { _x ctrlCommit 0.4 } forEach [_rebLBCtrl, _civLabelCtrl, _civLBCtrl];
                } else {
                    _rebLBCtrl ctrlSetPosition [4 * GRID_W, 8 * GRID_H, 38 * GRID_W, 40 * GRID_H];
                    _civLabelCtrl ctrlSetPosition [4 * GRID_W, 50 * GRID_H, 38 * GRID_W, 4 * GRID_H];
                    _civLBCtrl ctrlSetPosition [4 * GRID_W, 54 * GRID_H, 38 * GRID_W, 42 * GRID_H];
                    { _x ctrlCommit 0.4 } forEach [_rebLBCtrl, _civLabelCtrl, _civLBCtrl];
                    _civLBCtrl setVariable ["Expanded", false];
                };
            }];
            _civLBCtrl setVariable ["LBHandler", _civLBHandler];
        };
Manages mouse movement for civilian listbox expansion
Similar logic to rebel listbox but with different positioning
Sqf

Apply
        private _invLBHandler = _invLBCtrl getVariable "LBHandler";
        if (!isNil "_invLBHandler") then { _invLBCtrl ctrlRemoveEventHandler ["MouseMoving", _invLBHandler] };
        if (_invLBCtrl in _listboxes) then {
            _invLBHandler = _invLBCtrl ctrlAddEventHandler ["MouseMoving", {
                params ["_invLBCtrl", "_xPos", "_yPos", "_mouseOver"];

                private _display = findDisplay A3A_IDD_SETUPDIALOG;
                private _rivLabelCtrl = _display displayCtrl A3A_IDC_SETUP_RIVALSLABEL;
                private _rivLBCtrl = _display displayCtrl A3A_IDC_SETUP_RIVALSLISTBOX;

                if (_mouseOver) then {
                    if (_invLBCtrl getVariable "Expanded") exitWith {};
                    _invLBCtrl setVariable ["Expanded", true];
                    
                    private _invLBSize = lbSize _invLBCtrl;
                    private _LBx = 84 * GRID_W;
                    private _invLBy = 8 * GRID_H;
                    private _LBw = 38 * GRID_W;
                    private _Lh = 4 * GRID_H;
                    private _invLBh = ((_invLBSize * 3.25) min 66) * GRID_H;
                    private _rivLy = (_invLBy + _invLBh + 2 * GRID_H);
                    private _rivLBy = (_rivLy + 4 * GRID_H);
                    private _rivLBh = (92 * GRID_H - _rivLy);
                    _invLBCtrl ctrlSetPosition [_LBx, _invLBy, _LBw, _invLBh];
                    _rivLabelCtrl ctrlSetPosition [_LBx, _rivLy, _LBw, _Lh];
                    _rivLBCtrl ctrlSetPosition [_LBx, _rivLBy, _LBw, _rivLBh];
                    { _x ctrlCommit 0.4 } forEach [_invLBCtrl, _rivLabelCtrl, _rivLBCtrl];
                } else {
                    _invLBCtrl ctrlSetPosition [84 * GRID_W, 8 * GRID_H, 38 * GRID_W, 40 * GRID_H];
                    _rivLabelCtrl ctrlSetPosition [84 * GRID_W, 50 * GRID_H, 38 * GRID_W, 4 * GRID_H];
                    _rivLBCtrl ctrlSetPosition [84 * GRID_W, 54 * GRID_H, 38 * GRID_W, 42 * GRID_H];
                    { _x ctrlCommit 0.4 } forEach [_invLBCtrl, _rivLabelCtrl, _rivLBCtrl];
                    _invLBCtrl setVariable ["Expanded", false];
                };
            }];
            _invLBCtrl setVariable ["LBHandler", _invLBHandler];
        };
Manages mouse movement for invader listbox expansion
Positions rival listbox controls when expanded
Sqf

Apply
        private _rivLBHandler = _rivLBCtrl getVariable "LBHandler";
        if (!isNil "_rivLBHandler") then { _rivLBCtrl ctrlRemoveEventHandler ["MouseMoving", _rivLBHandler] };
        if (_rivLBCtrl in _listboxes) then {
            _rivLBHandler = _rivLBCtrl ctrlAddEventHandler ["MouseMoving", {
                params ["_rivLBCtrl", "_xPos", "_yPos", "_mouseOver"];

                private _display = findDisplay A3A_IDD_SETUPDIALOG;
                private _rivLabelCtrl = _display displayCtrl A3A_IDC_SETUP_RIVALSLABEL;
                private _invLBCtrl = _display displayCtrl A3A_IDC_SETUP_INVADERSLISTBOX;

                if (_mouseOver) then {
                    if (_rivLBCtrl getVariable "Expanded") exitWith {};
                    _rivLBCtrl setVariable ["Expanded", true];
                    
                    _invLBCtrl ctrlSetPosition [84 * GRID_W, 8 * GRID_H, 38 * GRID_W, 16 * GRID_H];
                    _rivLabelCtrl ctrlSetPosition [84 * GRID_W, 26 * GRID_H, 38 * GRID_W, 4 * GRID_H];
                    _rivLBCtrl ctrlSetPosition [84 * GRID_W, 30 * GRID_H, 38 * GRID_W, 66 * GRID_H];
                    { _x ctrlCommit 0.4 } forEach [_invLBCtrl, _rivLabelCtrl, _rivLBCtrl];
                } else {
                    _invLBCtrl ctrlSetPosition [84 * GRID_W, 8 * GRID_H, 38 * GRID_W, 40 * GRID_H];
                    _rivLabelCtrl ctrlSetPosition [84 * GRID_W, 50 * GRID_H, 38 * GRID_W, 4 * GRID_H];
                    _rivLBCtrl ctrlSetPosition [84 * GRID_W, 54 * GRID_H, 38 * GRID_W, 42 * GRID_H];
                    { _x ctrlCommit 0.4 } forEach [_invLBCtrl, _rivLabelCtrl, _rivLBCtrl];
                    _rivLBCtrl setVariable ["Expanded", false];
                };
            }];
            _rivLBCtrl setVariable ["LBHandler", _rivLBHandler];
        };
    };
Manages mouse movement for rival listbox expansion
Positions invader listbox controls when expanded
Sqf

Apply
    case ("factionSelected"):
    {
        _params params ["_listbox", "_rowIndex"];
        if (_rowIndex == -1) exitWith {};
        if (_listbox lbData _rowIndex != "") then {
            _listBox setVariable ["lastSel", _rowIndex];
        } else {
            _listbox lbSetCurSel (_listbox getVariable ["lastSel", 0]);
        };
    };
factionSelected case: Handles faction selection events
Saves last selected index for listbox
Restores previous selection if current selection is empty
Sqf

Apply
    case ("fillFactions"):
    {
        private _expandLBs = [];
        
        private _fnc_fillListBox = {
            params ["_listboxIDC", "_factions", "_selected"];
            Debug_1("fillListBox called with %1 selected", _selected);
            private _listbox = _display displayCtrl _listboxIDC;
            if (_selected == "") then { _selected = _listBox lbData lbCurSel _listBox };		// remember previous faction selected
            _listBox lbSetCurSel -1;
            lbClear _listBox;
            {
                private _index = _listBox lbAdd getText(_x/"name");
                if (_x call _fnc_factionLoaded) then {
                    _listBox lbSetPicture [_index, getText(_x/"flagTexture")];
                    _listBox lbSetPictureRight [_index, getText(_x/"logo")]; // Perhaps remove this because it looks like a cluster fuck with mods loaded
                    _listBox lbSetData [_index, configName _x];
                    _listBox lbSetTooltip [_index, getText(_x/"description")];
                    if (_selected == configName _x) then { _listBox lbSetCurSel (lbSize _listBox - 1) };
                } else {
                    _listBox lbSetPicture [_index, "a3\data_f\flags\flag_white_dmg_co.paa"];
                    _listBox lbSetPictureColor [_index, [1,1,1,0.3]];
                    _listBox lbSetTooltip [_index, format[localize "STR_A3AP_setupFactionsTab_noLoaded", (getArray(_x/"requiredAddons")) joinString ", "]];
                    _listBox lbSetColor [_index, A3A_COLOR_TEXT_DARKER_SQF];
                    _listBox lbSetSelectColor [_index, A3A_COLOR_TEXT_DARKER_SQF];
                };
            } forEach _factions;
            if (lbCurSel _listBox == -1) then { _listBox lbSetCurSel 0 };				// Should always exist

            if (count _factions > 12) then { _expandLBs pushBack _listbox };
        };
fillFactions case: Populates faction listboxes with available factions
Creates a closure function to fill individual listboxes
Handles both loaded and un-loaded factions with different display properties
Preserves previous selection when possible
Sqf

Apply
        // Fetch valid factions and filter based on checkboxes
        private _factions = +(_display getVariable "validFactions");
        if (!cbChecked (_display displayCtrl A3A_IDC_SETUP_IGNORECAMOCHECK)) then {
            _factions = _factions apply { _x select { getArray (_x/"climate") isEqualTo [] or A3A_climate in getArray (_x/"climate") } };
        };
        private _missingFactions = _factions apply { _x select { !(_x call _fnc_factionLoaded) } };
        _factions = _factions apply { _x select { _x call _fnc_factionLoaded } };

        if (cbChecked (_display displayCtrl A3A_IDC_SETUP_SWITCHENEMYCHECK)) then {
            _factions = [_factions#1, _factions#0, _factions#2, _factions#3, _factions#4];
        };
        if (cbChecked (_display displayCtrl A3A_IDC_SETUP_ANYENEMYCHECK)) then {
            _factions = [_factions#0 + _factions#1, _factions#1 + _factions#0, _factions#2, _factions#3, _factions#4];
        };
Filters factions based on game settings and checkbox selections
Handles climate filtering, enemy switching, and any enemy options
Sqf

Apply
        // Add saved factions if valid
        // configNames of the occ/inv/reb/civ factions, written by setupLoadgameTab
        (_display getVariable "savedFactions") params ["_savedFactions", "_savedAddons", "_savedDLC"];
        Debug_3("Saved factions: %1 Addons: %2 DLC: %3", _savedFactions, _savedAddons, _savedDLC);

        private _failedFactions = [];
        {
            _sfact = A3A_SETUP_CONFIGFILE/"A3A"/"Templates"/_x;
            if !(isClass _sfact) then { Info_1("Bad saved faction name %1", _x); _failedFactions pushBack _x };
            if !(_sfact call _fnc_factionLoaded) then { Info_1("Saved faction %1 not loadable", _x); _failedFactions pushBack _x };
            _factions#_forEachIndex pushBackUnique _sfact;				// does nothing if already in list
        } forEach _savedFactions;

        if (_failedFactions isNotEqualTo []) then {
            private _msg = "Couldn't load factions from save:";
            { _msg = _msg + endl + _x } forEach _failedFactions;
            ["Setup", _msg] spawn A3A_fnc_customHint;
        };

        // Add the non-loadable factions back in
        if (cbChecked (_display displayCtrl A3A_IDC_SETUP_SHOWMISSINGCHECK)) then {
            { _x append _missingFactions#_forEachIndex } forEach _factions;
        };

        if (_savedFactions isEqualTo []) then { _savedFactions = ["", "", "", "", ""] };
        [A3A_IDC_SETUP_OCCUPANTSLISTBOX, _factions#0, _savedFactions#0] call _fnc_fillListBox;
        [A3A_IDC_SETUP_INVADERSLISTBOX, _factions#1, _savedFactions#1] call _fnc_fillListBox;
        [A3A_IDC_SETUP_REBELSLISTBOX, _factions#2, _savedFactions#2] call _fnc_fillListBox;
        [A3A_IDC_SETUP_CIVILIANSLISTBOX, _factions#3, _savedFactions#3] call _fnc_fillListBox;
        [A3A_IDC_SETUP_RIVALSLISTBOX, _factions#4, _savedFactions#4] call _fnc_fillListBox;

        ["update", [_expandLBs]] call A3A_fnc_setupFactionsTab;
    };
Processes saved faction data and populates all faction listboxes
Handles missing faction errors and displays warnings
Applies faction filtering and expansion logic
Sqf

Apply
    case ("getFactions"):
    {
        private _factions = [A3A_IDC_SETUP_OCCUPANTSLISTBOX, A3A_IDC_SETUP_INVADERSLISTBOX, A3A_IDC_SETUP_REBELSLISTBOX, A3A_IDC_SETUP_CIVILIANSLISTBOX, A3A_IDC_SETUP_RIVALSLISTBOX] apply {
            private _factCtrl = _display displayCtrl _x;
            _factCtrl lbData lbCurSel _factCtrl;
        };

        _factions;
    };
getFactions case: Returns currently selected factions from all listboxes
Gets data (config names) from each listbox's current selection
Sqf

Apply
    default {
        Error_1("Called with unknown mode %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by setupDialog with modes "fillFactions", "getFactions", and "update"
Called by setupLoadgameTab for faction loading
Depends on setupDialog and setupLoadgameTab for data flow
Modifies global state through display control updates
Uses A3A_SETUP_CONFIGFILE, A3A_IDC_SETUP_* constants for UI control references
Synchronization: Uses spawn for background tasks, waitUntil for coordination
Function Name: fn_setupHQPosDialog.sqf
What it does: Handles the HQ position selection dialog, allowing users to choose where to place the HQ on the map.

How it does that: Manages the dialog lifecycle, draws danger zones, and handles mouse clicks for position selection.

Implementation:

Sqf

Apply
/*
function: A3A_fnc_setupHQPosDialog
    Handles the initialization and tab switching on the setup dialog.
    This function should only be called from setupDialog onLoad and control activation EHs.

Author: John Jordan (jaj22)

Environment: Scheduled for onLoad mode / Unscheduled for everything else unless specified

Arguments:
    <STRING> Mode, e.g. "onLoad", "switchTab"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Modes:
    - onload called on creation to setup dialog
    - onUnload called on deletion to handle deletion of dialog
    - mouseUp called on mouseUp event from the dialog, handles pos not allowed

Return Value:
    Nothing

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
Debug_1("HQ pos dialog called with mode %1", _mode);
Logs the mode being executed
Sqf

Apply
private _display = findDisplay A3A_IDD_SETUPHQPOSDIALOG;
private _parent = displayParent _display;
Finds the HQ position dialog display
Gets the parent display for reference
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        // Draw hatched danger zones
        private _mainMarkers = (markersX - controlsX - ["Synd_HQ"]);
        private _mrkDangerZone = [];
        {
            _mrk = createMarkerLocal [format ["dangerzone%1", count _mrkDangerZone], markerPos _x];
            _mrk setMarkerShapeLocal "ELLIPSE";
            _mrk setMarkerSizeLocal [500,500];
            _mrk setMarkerTypeLocal "hd_warning";
            _mrk setMarkerColorLocal "ColorRed";
            _mrk setMarkerBrushLocal "DiagGrid";
            _mrkDangerZone pushBack _mrk;
        } forEach _mainMarkers;
        _display setVariable ["dangerZones", _mrkDangerZone];
    };
onLoad case: Draws danger zones on the map
Creates local markers for enemy positions
Uses ellipse shape with diagonal grid brush for visual effect
Stores marker references in display variable for cleanup
Sqf

Apply
    case ("onUnload"):
    {
        private _mrkDangerZone = _display getVariable "dangerZones";
        { deleteMarkerLocal _x } forEach _mrkDangerZone;
    };
onUnload case: Cleans up danger zone markers
Deletes all local markers created during dialog initialization
Sqf

Apply
    case ("mouseUp"):
    {
        _params params ["_mapCtrl", "_button", "_xPos", "_yPos"];
        if (_button != 0) exitWith {};          // left mouse button only

        private _posClicked = _mapCtrl posScreenToWorld [_xPos, _yPos];
        private _posInvalid = true;
        private _titleStr = localize "STR_antistasi_dialogs_hqpos_feedback_title";

        private _nearMarker = [_display getVariable "dangerZones", _posClicked] call BIS_fnc_nearestPosition;
        if (markerPos _nearMarker distance2d _posClicked < 500) exitWith {
            [_titleStr, localize "STR_antistasi_dialogs_hqpos_feedback_nearenemy"] call A3A_fnc_customHint;
        };

        if (surfaceIsWater _posClicked) exitWith {
            [_titleStr, localize "STR_antistasi_dialogs_hqpos_feedback_inwater"] call A3A_fnc_customHint;
        };

        if (_posClicked findIf { (_x < 0) || (_x > worldSize) } != -1) exitWith {
            [_titleStr, localize "STR_antistasi_dialogs_hqpos_feedback_outsidemap"] call A3A_fnc_customHint;
        };

        "Synd_HQ" setMarkerPosLocal _posClicked;
        respawnTeamPlayer setMarkerPosLocal markerPos "Synd_HQ";
    };
mouseUp case: Handles position selection when user clicks on map
Validates mouse button is left-click
Converts screen position to world position
Checks for various invalid positions (near enemies, in water, outside map)
Sets HQ marker position if valid
Where it leads:

Called by setupLoadgameTab when setting HQ position
Called by setupDialog for dialog management
Depends on setupLoadgameTab for data flow
Modifies global marker positions
Uses A3A_IDD_SETUPHQPOSDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses createMarkerLocal, deleteMarkerLocal for marker management
Function Name: fn_setupLoadgameTab.sqf
What it does: Manages the load game tab in the setup dialog, handling save game selection, game creation, and game loading.

How it does that: Handles save game data display, selection, game creation, and execution of game start actions.

Implementation:

Sqf

Apply
/*
    Handles the initialization and tab switching on the setup dialog.
    This function should only be called from setupDialog onLoad and control activation EHs.

Environment: Scheduled for onLoad mode / Unscheduled for everything else unless specified

Arguments:
    <STRING> Mode, e.g. "onLoad", "switchTab"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
Debug_1("Loadgame dialog called with mode %1", _mode);
Logs the mode being executed
Sqf

Apply
// Get display
private _display = findDisplay A3A_IDD_SETUPDIALOG;
Finds the setup dialog display
Sqf

Apply
private _listboxCtrl = _display displayCtrl A3A_IDC_SETUP_SAVESLISTBOX;
private _startCtrl = _display displayCtrl A3A_IDC_SETUP_STARTBUTTON;
private _newGameCtrl = _display displayCtrl A3A_IDC_SETUP_NEWGAMECHECKBOX;
private _copyGameCtrl = _display displayCtrl A3A_IDC_SETUP_COPYGAMECHECKBOX;
private _oldParamsCtrl = _display displayCtrl A3A_IDC_SETUP_OLDPARAMSCHECKBOX;
private _newSaveCtrl = _display displayCtrl A3A_IDC_SETUP_NAMESPACECHECKBOX;
private _saveInfoCtrl = _display displayCtrl A3A_IDC_SETUP_SAVEINFOTEXT;
Gets references to all UI controls in the load game tab
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        _display setVariable ["savedFactions", [[], [], []]];
        _display setVariable ["savedParams", []];
        _listboxCtrl setVariable ["rowIndex", -1];

        private _platformIsWindows = A3A_setup_platform isEqualTo "Windows";
        _newSaveCtrl cbSetChecked _platformIsWindows;
        // _newSaveCtrl ctrlEnable _platformIsWindows; // ! Outright disable the control if platform isn't Windows
        if !(_platformIsWindows) then { _newSaveCtrl ctrlSetTooltip localize "STR_antistasi_dialogs_setup_use_new_namespace_warning" };

        // Do these programmatically so that we can reuse the column data
        private _headerCtrl = _display displayCtrl A3A_IDC_SETUP_SAVESHEADER;
        {
                private _ctrl = _display ctrlCreate ["A3A_Text_Small", -1, _headerCtrl];
                _ctrl ctrlSetPosition [GRID_W*(_x#2), 0, GRID_W*(_x#3), GRID_H*4];
                _ctrl ctrlCommit 0;
                _ctrl ctrlSetText (_x#1);
        } forEach _saveBoxColumns;
    };
onLoad case: Initializes the load game tab
Sets up display variables for saved data
Configures namespace checkbox based on platform
Creates column headers programmatically
Sqf

Apply
    case ("update"):
    {
        private _rowIndex = _listboxCtrl getVariable "rowIndex";
        private _saveData = if (_rowIndex == -1) then {
            createHashMapFromArray [["map", ""]];
        } else {
            A3A_setup_saveData select _rowIndex;
        };
        private _sameMap = (worldName == _saveData get "map");
        private _newGame = cbChecked _newGameCtrl;

        // Update the controls according to selections
        _copyGameCtrl ctrlEnable (_sameMap and _newGame);
        if (!_sameMap and cbChecked _copyGameCtrl) exitWith { _copyGameCtrl cbSetChecked false };       // will re-call update
        _startCtrl ctrlEnable (_sameMap or _newGame);
        _copyGameCtrl ctrlShow _newGame;
        _oldParamsCtrl ctrlShow _newGame;
        _newSaveCtrl ctrlShow _newGame;
        (_display displayCtrl A3A_IDC_SETUP_COPYGAMETEXT) ctrlShow _newGame;
        (_display displayCtrl A3A_IDC_SETUP_OLDPARAMSTEXT) ctrlShow _newGame;
        (_display displayCtrl A3A_IDC_SETUP_NAMESPACETEXT) ctrlShow _newGame;
        (_display displayCtrl A3A_IDC_SETUP_HQPOSBUTTON) ctrlShow (_newGame && !cbChecked _copyGameCtrl);

        // If we're selecting a game to load, load factions if available
        private _factions = [_saveData get "factions", _saveData get "addonVics", _saveData get "DLC"];
        if (isNil {_factions#0}) then { _factions = [[], [], []] };
        if ((cbChecked _newGameCtrl and !cbChecked _copyGameCtrl) or !_sameMap) then { _factions = [[], [], []] };
        if (_factions isNotEqualTo (_display getVariable "savedFactions")) then {
            _display setVariable ["savedFactions", _factions];
            ["fillFactions"] call A3A_fnc_setupFactionsTab;
            ["fillContent"] call A3A_fnc_setupContentTab;
        };

        // If it's not a new game or load params or copy game is checked, load params
        private _params = _saveData get "params";
        if (isNil "_params") then { _params = [] };               // getOrDefault doesn't work because input code may set nils
        if ((_sameMap and !cbChecked _newGameCtrl) or cbChecked _copyGameCtrl or cbChecked _oldParamsCtrl) then {
            if (count _params > 0 and _params isNotEqualTo (_display getVariable "savedParams")) then {
                _display setVariable ["savedParams", _params];
                ["fillParams"] call A3A_fnc_setupParamsTab;
            };
        } else {
            if (cbChecked _newGameCtrl && {!(_display getVariable ["paramsChangedSinceReset", false])}) then {
                //_display setVariable ["paramsChangedSinceReset", true];
                _display setVariable ["savedParams", []];
                ["fillParams"] call A3A_fnc_setupParamsTab;
            };
        };
    };
update case: Updates UI controls based on current selections
Handles enable/disable logic for various controls
Loads factions and parameters when appropriate
Manages parameter change tracking
Sqf

Apply
    case ("setSaveData"):
    {
        { ctrlDelete _x } forEach allControls _listboxCtrl;             // doesn't touch config controls
        {
            _x params ["_varname", "", "_xpos", "_width"];
            private _ctrls = [];
            {
                private _ctrl = _display ctrlCreate ["A3A_Text_Small", -1, _listboxCtrl];
                _ctrl ctrlSetPosition [GRID_W*_xpos, GRID_H*_forEachIndex*4, GRID_W*_width, GRID_H*4];
                _ctrl ctrlCommit 0;
                _ctrl ctrlSetText (_x getOrDefault [_varname, ""]);
                if (_x get "map" != worldName) then { _ctrl ctrlSetTextColor [0.6,0.6,0.6,1] };
                _ctrls pushBack _ctrl;
            } forEach A3A_setup_saveData;
            if (_varname == "name") then { _listboxCtrl setVariable ["nameCtrls", _ctrls] };
        } forEach _saveBoxColumns;

        ["selectSave", [-1]] call A3A_fnc_setupLoadgameTab;
    };
setSaveData case: Populates the save game listbox with data
Creates text controls for each save game entry
Sets up column headers and data display
Selects first save by default
Sqf

Apply
    case ("saveListClick"):
    {
        if (_params#1 != 0) exitWith {};                                            // ignore non-LMB clicks
        private _mpos = ctrlMousePosition _listBoxCtrl;
        if (_mpos#0 > (ctrlPosition _listBoxCtrl # 2) - 2*GRID_W) exitWith {};      // ignore scroll-bar region
        private _rowIndex = floor (_mpos#1 / (4*GRID_H));
        if (_rowIndex >= count A3A_setup_saveData) exitWith {};                      // ignore clicks below saves
        if (_rowIndex == _listboxCtrl getVariable "rowIndex") exitWith {};          // ignore if already selected
        ["selectSave", [_rowIndex]] call A3A_fnc_setupLoadgameTab;
        ["enableParamsTab"] call A3A_fnc_setupDialog;
    };
saveListClick case: Handles clicks on save game list
Validates click is on a save entry
Updates selection and enables parameters tab
Sqf

Apply
    case ("saveListDoubleClick"):
    {
        if (_params#1 != 0) exitWith {};                                            // ignore non-LMB clicks
        private _mpos = ctrlMousePosition _listBoxCtrl;
        if (_mpos#0 > (ctrlPosition _listBoxCtrl # 2) - 2*GRID_W) exitWith {};      // ignore scroll-bar region
        private _rowIndex = floor (_mpos#1 / (4*GRID_H));
        if (_rowIndex >= count A3A_setup_saveData) exitWith {};                      // ignore clicks below saves
        if (cbChecked _newGameCtrl) exitWith {};                                    // ignore new game clicks

        private _saveData = if (_rowIndex == -1) then {
            createHashMapFromArray [["map", ""]];
        } else {
            A3A_setup_saveData select _rowIndex;
        };
        if (!(worldName == _saveData get "map")) exitWith {};

        ["startGame"] call A3A_fnc_setupLoadgameTab;
    };
saveListDoubleClick case: Handles double-clicks on save game list
Starts game when double-clicking a valid save
Validates map compatibility
Sqf

Apply
    case ("selectSave"):
    {
        _params params ["_rowIndex"];
        Debug_1("SelectSave called with index %1", _rowIndex);

        private _selectBar = _display displayCtrl A3A_IDC_SETUP_GAMESELECTBOX;
        _selectBar ctrlShow (_rowIndex != -1);
        _selectBar ctrlSetPositionY _rowIndex*GRID_H*4;
        _selectBar ctrlCommit 0;

        _listBoxCtrl setVariable ["rowIndex", _rowIndex];
        ["updateSaveInfoText"] call A3A_fnc_setupLoadgameTab;
        ["update"] call A3A_fnc_setupLoadgameTab;
    };
selectSave case: Updates selection state and UI
Shows selection bar and updates save info text
Sqf

Apply
    case ("startGame"):
    {
        private _saveData = createHashMap;
        private _confirmText = "";
        if (cbChecked _newGameCtrl and !cbChecked _copyGameCtrl) then {
            _saveData set ["startType", "new"];
            _saveData set ["name", ctrlText (_display displayCtrl A3A_IDC_SETUP_NAMEEDITBOX)];
            _saveData set ["startPos", markerPos "Synd_HQ"];
            _confirmText = localize "STR_antistasi_dialogs_setup_confirm_start_create";
        } else {
            private _oldSave = A3A_setup_saveData select (_listboxCtrl getVariable "rowIndex");
            _saveData set ["gameID", _oldSave get "gameID"];
            _saveData set ["serverID", _oldSave get "serverID"];
            if (cbChecked _copyGameCtrl) then {
                _saveData set ["startType", "copy"];
                _saveData set ["name", ctrlText (_display displayCtrl A3A_IDC_SETUP_NAMEEDITBOX)];
                _confirmText = format [localize "STR_antistasi_dialogs_setup_confirm_start_copy", _oldSave get "gameID"];
            } else {
                _saveData set ["startType", "load"];
                _saveData set ["name", _oldSave getOrDefault ["name", ""]]; 
                _confirmText = format [localize "STR_antistasi_dialogs_setup_confirm_start_load", _oldSave get "gameID"];
            };
        };
        if (_saveData get "name" != "") then {
            _confirmText = _confirmText + format [localize "STR_antistasi_dialogs_setup_confirm_game_name", _saveData get "name"];
        };
        _saveData set ["useNewNamespace", cbChecked _newSaveCtrl];

        // Factions tab: [factions, addonvics, DLC]
        private _factions = ["getFactions"] call A3A_fnc_setupFactionsTab;
        private _contentData = ["getContent"] call A3A_fnc_setupContentTab;
        _saveData set ["factions", _factions];
        _saveData set ["addonVics", _contentData#0];
        _saveData set ["DLC", _contentData#1];

        private _invEnabled = ctrlEnabled A3A_IDC_SETUP_INVADERSLISTBOX;
        private _rivEnabled = ctrlEnabled A3A_IDC_SETUP_RIVALSLISTBOX;
        private _factionNames = [
            getText (A3A_SETUP_CONFIGFILE/"A3A"/"Templates"/_factions#2/"name"),
            getText (A3A_SETUP_CONFIGFILE/"A3A"/"Templates"/_factions#3/"name"),
            getText (A3A_SETUP_CONFIGFILE/"A3A"/"Templates"/_factions#0/"name"),
            [(localize "STR_params_afk_disabled"), getText (A3A_SETUP_CONFIGFILE/"A3A"/"Templates"/_factions#1/"name")] select (_invEnabled),
            [(localize "STR_params_afk_disabled"), getText (A3A_SETUP_CONFIGFILE/"A3A"/"Templates"/_factions#4/"name")] select (_rivEnabled)
        ];
        _confirmText = _confirmText + endl + format [localize "STR_antistasi_dialogs_setup_confirm_factions", _factionNames#0, _factionNames#1, _factionNames#2, _factionNames#3, _factionNames#4];

        // Params tab: Array of [name, value]
        private _paramsData = ["getParams"] call A3A_fnc_setupParamsTab;
        _saveData set ["params", _paramsData];

        // Set data & function for confirmation, then open confirmation box
        _display setVariable ["confirmData", [_confirmText, A3A_fnc_setupLoadgameTab, "startGameConfirm"]];
        _display setVariable ["newSaveData", _saveData];
        Debug_1("Prepared save data: %1", _saveData);
        createDialog "A3A_SetupConfirmDialog";
    };
startGame case: Prepares game start data and opens confirmation dialog
Collects faction, content, and parameter data
Builds confirmation text with all game details
Sets up confirmation dialog data
Sqf

Apply
    case ("startGameConfirm"):
    {
        // Send the start request to the server and close dialog

        (_display getVariable "newSaveData") remoteExec ["A3A_fnc_startGame", 2];
        ["serverClose"] call A3A_fnc_setupDialog;          // make sure the confirm dialog is closed first
    };
startGameConfirm case: Executes the confirmed game start
Sends game start data to server via remote execution
Closes the setup dialog
Sqf

Apply
    case ("updateSaveInfoText"):
    {
        private _lbCurSel = _listboxCtrl getVariable "rowIndex";
        switch (true) do {
            case (_lbCurSel isEqualTo -1): { _saveInfoCtrl ctrlSetText localize "STR_antistasi_dialogs_setup_new_save" };
            case (cbChecked _copyGameCtrl): { _saveInfoCtrl ctrlSetText format [localize "STR_antistasi_dialogs_setup_copy_save", A3A_setup_saveData select _lbCurSel get "gameID"] };
            case (cbChecked _newGameCtrl): { _saveInfoCtrl ctrlSetText localize "STR_antistasi_dialogs_setup_new_save" };
            default { _saveInfoCtrl ctrlSetText format [localize "STR_antistasi_dialogs_setup_edit_save", A3A_setup_saveData select _lbCurSel get "gameID"] };
        };
    };
updateSaveInfoText case: Updates the save information text
Shows different messages based on selection state
Sqf

Apply
    case ("newGameCheck"):
    {
        ["updateSaveInfoText"] call A3A_fnc_setupLoadGameTab;
        ["update"] call A3A_fnc_setupLoadgameTab;
        ["enableParamsTab"] call A3A_fnc_setupDialog;
    };
newGameCheck case: Handles new game checkbox changes
Updates UI and enables parameters tab
Sqf

Apply
    case ("copyGameCheck"):
    {
        // exitWith so that we don't infinite loop
        if (cbChecked _copyGameCtrl && cbChecked _oldParamsCtrl) exitWith { _oldParamsCtrl cbSetChecked false; ["updateSaveInfoText"] call A3A_fnc_setupLoadGameTab };
        ["updateSaveInfoText"] call A3A_fnc_setupLoadGameTab;
        ["update"] call A3A_fnc_setupLoadgameTab;
    };
copyGameCheck case: Handles copy game checkbox changes
Prevents conflicts between copy and old params checkboxes
Sqf

Apply
    case ("oldParamsCheck"):
    {
        if (cbChecked _copyGameCtrl && cbChecked _oldParamsCtrl) exitWith { _copyGameCtrl cbSetChecked false;  ["updateSaveInfoText"] call A3A_fnc_setupLoadGameTab };
        ["updateSaveInfoText"] call A3A_fnc_setupLoadGameTab;
        ["update"] call A3A_fnc_setupLoadgameTab;
    };
oldParamsCheck case: Handles old parameters checkbox changes
Prevents conflicts between copy and old params checkboxes
Sqf

Apply
    case ("oldNamespaceCheck"):
    {
        // Doesn't need to do anything here
    };
oldNamespaceCheck case: Placeholder for namespace checkbox changes
Sqf

Apply
    case ("setHQPos"):
    {
        createDialog "A3A_SetupHQPosDialog";
    };
setHQPos case: Opens HQ position dialog
Allows user to select where to place HQ
Sqf

Apply
    case ("deleteGame"):
    {
        private _index = _listboxCtrl getVariable ["rowIndex", -1];
        if (_index == -1) exitWith {};

        private _saveData = A3A_setup_saveData select _index;
        private _str = format [localize "STR_antistasi_dialogs_setup_confirm_delete", _saveData get "gameID", _saveData get "mapStr"];
        _display setVariable ["confirmData", [_str, A3A_fnc_setupLoadgameTab, "deleteGameConfirmed"]];
        createDialog "A3A_SetupConfirmDialog";
    };
deleteGame case: Prepares game deletion confirmation
Builds deletion confirmation text and opens confirmation dialog
Sqf

Apply
    case ("deleteGameConfirmed"):
    {
        private _index = _listboxCtrl getVariable "rowIndex";
        private _saveData = A3A_setup_saveData select _index;
        [_saveData get "serverID", _saveData get "gameID", _saveData get "map"] remoteExecCall ["A3A_fnc_deleteSave", 2];

        A3A_setup_saveData deleteAt _index;
        ["setSaveData"] call A3A_fnc_setupLoadgameTab;
    };
deleteGameConfirmed case: Executes confirmed game deletion
Sends deletion request to server
Removes save data from local array
Refreshes save list display
Sqf

Apply
    case ("renameGame"):
    {
        private _index = _listboxCtrl getVariable ["rowIndex", -1];
        if (_index == -1) exitWith {};
        private _newName = ctrlText (_display displayCtrl A3A_IDC_SETUP_NAMEEDITBOX);

        // Set name in save data
        private _saveData = A3A_setup_saveData select _index;
        _saveData set ["name", _newName];

        // Set immediately on server too
        private _saveTarget = [_saveData get "serverID", _saveData get "gameID", _saveData get "map"];
        ["name", _newName, _saveTarget] remoteExecCall ["A3A_fnc_writebackSaveVar", 2];

        // Set name in the displayed table
        private _nameCtrl = _listboxCtrl getVariable "nameCtrls" select _index;
        _nameCtrl ctrlSetText _newName;
    };
renameGame case: Renames a save game
Updates both local and server save data
Refreshes display with new name
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("Mode %1 does not exist", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by setupDialog with various modes for tab management
Called by setupConfirmDialog for confirmation handling
Called by setupFactionsTab and setupContentTab for data loading
Called by setupParamsTab for parameter loading
Depends on setupDialog, setupConfirmDialog, setupFactionsTab, setupContentTab, and setupParamsTab for data flow
Modifies global variables A3A_setup_saveData, A3A_setup_loadedPatches, A3A_setup_loadedDLC, A3A_setup_platform
Uses A3A_IDD_SETUPDIALOG, A3A_IDC_SETUP_* constants for UI control references
Synchronization: Uses remoteExec for server communication, spawn for background tasks

Function Name: fn_setupParamsTab.sqf
What it does: Manages the parameters tab in the setup dialog, handling game parameter configuration and display.

How it does that: Initializes parameter controls, populates dropdowns, handles parameter selection, and manages parameter data flow.

Implementation:

Sqf

Apply
/*

*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
Debug("Params dialog called with mode %1", _mode);
Logs the mode being executed
Sqf

Apply
// Get display
private _display = findDisplay A3A_IDD_SETUPDIALOG;
private _paramsTable = _display displayCtrl A3A_IDC_SETUP_PARAMSTABLE;
private _paramsType = _display displayCtrl A3A_IDC_SETUP_PARAMSTYPE;
Finds the setup dialog display
Gets references to parameter table and type dropdown controls
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        // * Populate the Parameter Type Dropdown
        private _basicParamsIndex =  _paramsType lbAdd (localize "STR_antistasi_dialogs_setup_params_basic_label");
        private _balParamsIndex = _paramsType lbAdd (localize "STR_antistasi_dialogs_setup_params_bal_label");
        private _eqpParamsIndex = _paramsType lbAdd (localize "STR_antistasi_dialogs_setup_params_eqp_label");
        private _bldParamsIndex = _paramsType lbAdd (localize "STR_antistasi_dialogs_setup_params_bld_label");
        private _devParamsIndex = _paramsType lbAdd (localize "STR_antistasi_dialogs_setup_params_dev_label");
        private _extParamsIndex = _paramsType lbAdd (localize "STR_antistasi_dialogs_setup_params_ext_label");

        _paramsType lbSetValue [_basicParamsIndex, 0];
        _paramsType lbSetValue [_balParamsIndex, 1];
        _paramsType lbSetValue [_eqpParamsIndex, 2];
        _paramsType lbSetValue [_bldParamsIndex, 3];
        _paramsType lbSetValue [_devParamsIndex, 4];
        _paramsType lbSetValue [_extParamsIndex, 5];
        
        _paramsType lbSetCurSel _basicParamsIndex;

        // * Create ALL the param controls
        private _allCtrls = [];
        private _allTextCtrls = [];
        private _allValsCtrls = [];
        {
            private _type = getText (_x/"type");
            private _title = getText (_x/"title");
            private _tooltip = getText (_x/"tooltip");
            private _texts = getArray (_x/"texts");
            private _vals = getArray (_x/"values");
            private _default = getNumber (_x/"default");
            private _defaultIndex = _vals find _default;

            if (!isNil "_title") then {
                private _textCtrl = _display ctrlCreate ["A3A_Text_Small", A3A_IDC_SETUP_PARAMSTEXT + _forEachIndex, _paramsTable];
                _allTextCtrls pushBack [configName _x, _textCtrl];
                _textCtrl ctrlEnable false;
                _textCtrl ctrlSetFade 1;
                _textCtrl ctrlSetText _title;
                if (_tooltip isNotEqualTo "") then {
                    _textCtrl ctrlSetTooltip _tooltip;
                };
                _textCtrl setVariable ["type", _type];
                _textCtrl ctrlCommit 0;
            };

            if (_title isNotEqualTo "" && {_texts isNotEqualTo [""]}) then {
                private _valsCtrl = _display ctrlCreate ["A3A_ComboBox_Small", A3A_IDC_SETUP_PARAMSVALS + _forEachIndex, _paramsTable];
                _allValsCtrls pushBack [configName _x, _valsCtrl];
                _valsCtrl ctrlEnable false;
                _valsCtrl ctrlSetFade 1;
                _valsCtrl setVariable ["config", _x];
                _valsCtrl setVariable ["locked", false];
                {
                    private _index = _valsCtrl lbAdd (_texts select _forEachIndex);
                    _valsCtrl lbSetValue [_index, _x];
                    if (_index isNotEqualTo _defaultIndex) then { _valsCtrl lbSetColor [_index, [0.85, 0.85, 0, 1]] };
                } forEach (_vals);
                _valsCtrl lbSetCurSel _defaultIndex;
                _valsCtrl ctrlCommit 0;
                _allCtrls pushBack _valsCtrl;

                _valsCtrl ctrlAddEventHandler ["LBSelChanged", {
                    private _display = findDisplay A3A_IDD_SETUPDIALOG;
                    private _newGame = cbChecked (_display displayCtrl A3A_IDC_SETUP_NEWGAMECHECKBOX);
                    _display setVariable ["paramsChangedSinceReset", _newGame];
                }];

                if (configName _x isEqualTo "gameMode") then {
                    _valsCtrl ctrlAddEventHandler ["LBSelChanged", {
                        params ["_thisCtrl", "_index"];
                        private _display = findDisplay A3A_IDD_SETUPDIALOG;
                        private _invDisabled = (_thisCtrl lbValue _index) isEqualTo 3;
                        private _invSelCtrl = _display displayCtrl A3A_IDC_SETUP_INVADERSLISTBOX;
                        private _rivEnaCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 1);

                        if (_invDisabled) then {
                            _invSelCtrl ctrlEnable false;
                            _invSelCtrl ctrlSetTooltip (localize "STR_antistasi_dialogs_setup_inv_disabled");
                            _rivEnaCtrl lbSetCurSel 0;
                            _rivEnaCtrl ctrlSetTooltip (localize "STR_antistasi_dialogs_setup_riv_param_warning");
                        } else {
                            _invSelCtrl ctrlEnable true;
                            _invSelCtrl ctrlSetTooltip "";
                            _rivEnaCtrl ctrlSetTooltip "";
                        };
                    }];
                };

                if (configName _x isEqualTo "areRivalsEnabled") then {
                    _valsCtrl ctrlAddEventHandler ["LBSelChanged", {
                        params ["_thisCtrl", "_index"];
                        private _display = findDisplay A3A_IDD_SETUPDIALOG;
                        private _rivDisabled = (_thisCtrl lbValue _index) isEqualTo 0;
                        private _rivSelCtrl = _display displayCtrl A3A_IDC_SETUP_RIVALSLISTBOX;

                        if (_rivDisabled) then {
                            _rivSelCtrl ctrlEnable false;
                            _rivSelCtrl ctrlSetTooltip (localize "STR_antistasi_dialogs_setup_riv_disabled");
                        } else {
                            _rivSelCtrl ctrlEnable true;
                            _rivSelCtrl ctrlSetTooltip "";
                        };
                    }];
                };

                if (configName _x isEqualTo "minWeaps") then {
                    _valsCtrl ctrlAddEventHandler ["LBSelChanged", {
                        params ["_thisCtrl", "_index"];
                        private _display = findDisplay A3A_IDD_SETUPDIALOG;
                        private _unlocksDisabled = (_thisCtrl lbValue _index) isEqualTo -1;
                        private _unlockMagazinesCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 2);
                        private _unlockGLaunchersCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 3);
                        private _unlockExplosivesCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 4);

                        if (_unlocksDisabled) then {
                            for "_i" from 2 to 4 do {
                                private _ctrl = _display displayCtrl (ctrlIDC _thisCtrl + _i);
                                _ctrl lbSetCurSel 1;
                                _ctrl ctrlSetTooltip (localize "STR_antistasi_dialogs_setup_unlocks_disabled");
                                _ctrl setVariable ["locked", true];
                                _ctrl ctrlEnable false;
                            };
                        } else {
                            for "_i" from 2 to 4 do {
                                private _ctrl = _display displayCtrl (ctrlIDC _thisCtrl + _i);
                                _ctrl ctrlSetTooltip "";
                                _ctrl setVariable ["locked", false];
                                _ctrl ctrlEnable true;
                            };
                        };
                    }];
                };

                if (configName _x isEqualTo "minWeaps") then {
                    _valsCtrl ctrlAddEventHandler ["LBSelChanged", {
                        params ["_thisCtrl", "_index"];
                        private _display = findDisplay A3A_IDD_SETUPDIALOG;
                        private _unlocksDisabled = (_thisCtrl lbValue _index) isEqualTo -1;
                        private _unlockMagazinesCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 2);
                        private _unlockGLaunchersCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 3);
                        private _unlockExplosivesCtrl = _display displayCtrl (ctrlIDC _thisCtrl + 4);

                        if (_unlocksDisabled) then {
                            for "_i" from 2 to 4 do {
                                private _ctrl = _display displayCtrl (ctrlIDC _thisCtrl + _i);
                                _ctrl lbSetCurSel 1;
                                _ctrl ctrlSetTooltip (localize "STR_antistasi_dialogs_setup_unlocks_disabled");
                                _ctrl setVariable ["locked", true];
                                _ctrl ctrlEnable false;
                            };
                        } else {
                            for "_i" from 2 to 4 do {
                                private _ctrl = _display displayCtrl (ctrlIDC _thisCtrl + _i);
                                _ctrl ctrlSetTooltip "";
                                _ctrl setVariable ["locked", false];
                                _ctrl ctrlEnable true;
                            };
                        };
                    }];
                };
            };
        } forEach ("true" configClasses (A3A_SETUP_CONFIGFILE/"A3A"/"Params"));

        _paramsTable setVariable ["allCtrls", _allCtrls];
        _paramsTable setVariable ["allTextCtrls", _allTextCtrls];
        _paramsTable setVariable ["allValsCtrls", _allValsCtrls];

        ["update"] call A3A_fnc_setupParamsTab;
    };
onLoad case: Initializes parameter controls and dropdowns
Creates dropdown menu with parameter categories
Creates text and value controls for each parameter
Sets up event handlers for parameter changes
Configures parameter-specific event handlers for game mode, rival settings, and weapon unlocks
Sqf

Apply
	case ("update"):
    {
        private _shownTypes = switch (lbCurSel A3A_IDC_SETUP_PARAMSTYPE) do {
            case (-1): { [] }; // lbCurSel is -1 until params tab is loaded
            case (0): { ["Basic", "Scenario", "Member", "Script", "Timer"] };
            case (1): { ["AI", "Balance", "RebelBalance", "AIBalance", "MiscBalance"] };
            case (2): { ["BlackMarket", "Loot", "Unlocks", "Crates", "VehicleLoot", "MiscLoot"] };
            case (3): { ["Builder"] };
            case (4): { ["Experimental", "Development"] };
            case (5): { ["Extender"] };
        };

        private _rowCount = -1;
        private _allValsCtrls = createHashMapFromArray (_paramsTable getVariable "allValsCtrls");
        {
            private _textCtrl = _x select 1;
            private _valsCtrl = _allValsCtrls get (_x select 0);

            if ((_textCtrl getVariable "type") in _shownTypes) then {
                _rowCount = _rowCount + 1;
                _textCtrl ctrlEnable true;
                _textCtrl ctrlSetPosition [0, GRID_H*_rowCount*4, GRID_W*112, GRID_H*4];
                _textCtrl ctrlSetFade 0;

                if (!isNil "_valsCtrl") then {
                    _valsCtrl ctrlEnable !(_valsCtrl getVariable "locked");
                    _valsCtrl ctrlSetPosition [GRID_W*116, GRID_H*_rowCount*4, GRID_W*32, GRID_H*4];
                    _valsCtrl ctrlSetFade 0;
                };
            } else {
                _textCtrl ctrlEnable false;
                _textCtrl ctrlSetPosition [0, 0, 0, 0];
                _textCtrl ctrlSetFade 1;

                if (!isNil "_valsCtrl") then {
                    _valsCtrl ctrlEnable false;
                    _valsCtrl ctrlSetPosition [0, 0, 0, 0];
                    _valsCtrl ctrlSetFade 1;
                };
            };
            _textCtrl ctrlCommit 0;
            if (!isNil "_valsCtrl") then { _valsCtrl ctrlCommit 0 };
        } forEach (_paramsTable getVariable "allTextCtrls");

        _paramsTable ctrlSetScrollValues [0,-1];
    };
update case: Updates parameter visibility based on selected category
Shows/hides parameters based on dropdown selection
Adjusts positions and fade states of controls
Sets scroll values for parameter table
Sqf

Apply
    case ("fillParams"):
    {
        // Should be array of [varname, value] pairs
        // Written by setupLoadgameTab
		private _savedParams = _display getVariable ["savedParams", []];
        private _savedParamsHM = createHashMapFromArray _savedParams;
        //diag_log format ["Saved params %1", _savedParamsHM];

        private _newGameCtrl = _display displayCtrl A3A_IDC_SETUP_NEWGAMECHECKBOX;
        private _copyGameCtrl = _display displayCtrl A3A_IDC_SETUP_COPYGAMECHECKBOX;

        {
            private _thisCtrl = _x;
            private _cfg = _x getVariable "config";
            private _vals = getArray (_cfg/"values");
            // clear old saved value if not in config options
            if (lbSize _x > count _vals) then { _x lbDelete (lbSize _x - 1) };

            //diag_log format ["Configname %1, default %2, vals %3", configName _cfg, getNumber (_cfg/"default"), _vals];

            private _saved = _savedParamsHM getOrDefault [configName _cfg, getNumber (_cfg/"default")];
            if (_saved isEqualType true) then { _saved = [0, 1] select _saved };            // bool -> number conversion

            private "_index";
            if !(_saved in _vals) then {
                // add saved value if not in config options 
                _index = _x lbAdd str _saved;
                _x lbSetValue [_index, _saved];
                _x lbSetCurSel _index;
            } else {
                _index = _vals find _saved; 
                _x lbSetCurSel _index;
            };

            {
                _thisCtrl lbSetColor [_forEachIndex, [[0.85, 0.85, 0, 1], [1, 1, 1, 1]] select (_forEachIndex isEqualTo _index)]
            } forEach _vals;

            if (_savedParams isNotEqualTo [] && {!cbChecked _newGameCtrl || cbChecked _copyGameCtrl}) then { // we're loading an existing save
                private _lockOnSave = (getNumber (_cfg/"lockOnSave")) isNotEqualTo 0;
                private _lockInGame = !isNil {serverInitDone} && {(getNumber (_cfg/"lockInGame")) isNotEqualTo 0};
                _x setVariable ["locked", _lockOnSave || _lockInGame];

                if (_lockOnSave || _lockInGame) then {
                    _x ctrlEnable false;
                    _x ctrlSetTooltip (localize (["STR_antistasi_dialogs_setup_param_locked", "STR_antistasi_dialogs_setup_param_locked_ingame"] select (_lockInGame)));
                };
            } else {
                // reset params to enabled if we're creating a new game or if all we did was load old params (to create a new game)
                _x setVariable ["locked", false];
                _x ctrlEnable true;
                _x ctrlSetTooltip "";
            };
        } forEach (_paramsTable getVariable "allCtrls");
    };
fillParams case: Loads saved parameter values into controls
Handles boolean to number conversion
Updates control states based on save data and game state
Sets appropriate tooltips and enables/disables controls
Sqf

Apply
    case ("getParams"):
    {
        private _params = (_paramsTable getVariable "allCtrls") apply {
            private _cfg = _x getVariable "config";
            private _val = _x lbValue lbCurSel _x;
            [configName _cfg, _val];
        };
        _params;
    };
getParams case: Returns current parameter values from controls
Collects all parameter values for saving
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("Mode %1 does not exist", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by setupDialog with modes "fillParams", "getParams", and "update"
Called by setupLoadgameTab for parameter loading and saving
Called by setupConfirmDialog for confirmation handling
Depends on setupDialog, setupLoadgameTab, and setupConfirmDialog for data flow
Modifies global state through display control updates
Uses A3A_SETUP_CONFIGFILE, A3A_IDC_SETUP_* constants for UI control references
Synchronization: Uses ctrlAddEventHandler for control interaction, remoteExec for server communication
Function Name: fn_sizeOf.sqf
What it does: Calculates the bounding-box diameter of a vehicle class, providing accurate size measurements for UI and placement purposes.

How it does that: Attempts to get size from existing cache, creates temporary vehicle if needed, and caches results for future use.

Implementation:

Sqf

Apply
/*
Maintainer: Caleb Serafin
    Similar to sizeOf, but it will always return the accurate size.
    The bounding-box diameters are cached after the first sizeOf call.
    If sizeOf returns 0, a vehicle will be created temporally for measurement.

Arguments:
    <STRING> Vehicle Classname.

Return Value:
    <SCALAR> The bounding-box diameter of the vehicle.

Scope: Any, Local Effect
Environment: Any
Public: Yes

Example:
    ["C_Offroad_01_F"] call A3A_GUI_fnc_sizeOf;  // 11.4563
    ["C_Heli_Light_01_civil_F"] call A3A_GUI_fnc_sizeOf;  // 12.6111
    // Within GUI
    ["C_Offroad_01_F"] call FUNC(sizeOf);  // 11.4563

*/
Code Breakdown:

Sqf

Apply
params [
    ["_classname", "", [""]]
];
Validates parameter: vehicle class name (string)
Sqf

Apply
if (isNil "A3A_GUI_sizeOf_cache") then {
    A3A_GUI_sizeOf_cache = createHashMap;
};
Creates cache hash map if it doesn't exist
Stores previous size measurements for efficiency
Sqf

Apply
if (_classname in A3A_GUI_sizeOf_cache) exitWith {
    A3A_GUI_sizeOf_cache get _classname;  // Object is cached.
};
Returns cached size if available
Uses get to retrieve stored value
Sqf

Apply
private _diameter = sizeOf _classname;
if (_diameter != 0) exitWith {
    A3A_GUI_sizeOf_cache set [_classname, _diameter];
    _diameter;  // Object was not cached but did exist.
};
Attempts to get size directly from game engine
If successful (non-zero), caches the result and returns it
Sqf

Apply
private _object =  createVehicle [_classname, [random 1000, random 1000, 1000 + random 1000], [], 0, "CAN_COLLIDE"];
Creates temporary vehicle for measurement if direct sizeOf returns 0
Places vehicle at random coordinates to avoid conflicts
Uses "CAN_COLLIDE" to ensure proper collision detection
Sqf

Apply
if (isNull _object) exitWith {
    0;  // Object does not exist.
};
Handles case where vehicle creation fails
Returns 0 to indicate invalid object
Sqf

Apply
_diameter = sizeOf _classname;
deleteVehicle _object;
A3A_GUI_sizeOf_cache set [_classname, _diameter];
_diameter;  // Object was not cached and did not exist.
Gets final diameter measurement after vehicle creation
Deletes temporary vehicle
Caches result for future use
Returns calculated diameter
Where it leads:

Called by various GUI functions for vehicle size calculations
Used by teamLeaderRTSPlacerDialog for building placement
Used by buyVehicleTabs for UI positioning
Depends on createVehicle and sizeOf engine functions
Modifies global A3A_GUI_sizeOf_cache hash map
Synchronization: Uses createVehicle and deleteVehicle for temporary object management

Function Name: fn_adminTab.sqf
What it does: Manages the admin tab in the main dialog, handling administrative controls and displaying debug information.

How it does that: Updates tab controls, handles slider interactions, and manages administrative actions.

Implementation:

Sqf

Apply
/*
Maintainer: DoomMetal
    Handles updating and controls on the Admin tab of the Main dialog.

Arguments:
    <STRING> Mode
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

Scope: Clients, Local Arguments, Local Effect
Environment: Scheduled for control changes / Unscheduled for update
Public: No
Dependencies:
    None

Example:
    ["update"] call A3A_fnc_adminTab;
*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params[["_mode","onLoad"], ["_params",[]]];
Includes required headers and validates parameters
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("update"):
    {
        Trace("Updating admin tab");
        private _display = findDisplay A3A_IDD_MAINDIALOG;

        _spawnDistanceSlider = _display displayCtrl A3A_IDC_SPAWNDISTANCESLIDER;
        _spawnDistanceSlider sliderSetRange [_spawnDistanceMin, _spawnDistanceMax];
        _spawnDistanceSlider sliderSetSpeed [100, 100];
        _spawnDistance = missionNamespace getVariable ["distanceSPWN",0];
        _spawnDistanceSlider sliderSetPosition _spawnDistance;
        ctrlSetText [A3A_IDC_SPAWNDISTANCEEDITBOX, str _spawnDistance];
update case: Updates admin tab UI controls
Sets slider range and speed parameters
Gets current spawn distance from mission namespace
Updates slider position and edit box text
Sqf

Apply
        // Get Debug info
        // TODO UI-update: change this to get server values instead when merging
        private _debugText = _display displayCtrl A3A_IDC_DEBUGINFO;
        private _missionTime = [time] call A3A_fnc_formatTime;
        private _serverFps = (round (diag_fps * 10)) / 10; // TODO UI-update: Get actual server FPS, not just client
        private _connectedHCs = 0; // TODO UI-update: get actual number of connected headless clients
        private _players = 0; // TODO UI-update: get actual number of players connected

        // TODO UI-update: get actual unit counts
        private _allUnits = count allUnits;
        private _deadUnits = 1349;
        private _countGroups = count allGroups;
        private _countRebels = 16;
        private _countInvaders = 5;
        private _countOccupants = 37;
        private _countCiv = 4096;
        private _destroyedVehicles = 2;

        // TODO UI-update: localize later, not final yet
        private _formattedString = format [
        "<t font='EtelkaMonospacePro' size='0.8'>
        <t>Mission time:</t><t align='right'>%1</t><br />
        <t>Server FPS:</t><t align='right'>%2</t><br />
        <t>Connected HCs:</t><t align='right'>%3</t><br />
        <t>Players:</t><t align='right'>%4</t><br />
        <t>Groups</t><t align='right'>%5</t><br />
        <t>Units:</t><t align='right'>%6</t><br />
        <t>Dead units:</t><t align='right'>%7</t><br />
        <t>Rebels:</t><t align='right'>%8</t><br />
        <t>Invaders:</t><t align='right'>%9</t><br />
        <t>Occupants:</t><t align='right'>%10</t><br />
        <t>Civs:</t><t align='right'>%11</t><br />
        <t>Wrecks:</t><t align='right'>%12</t>
        </t>",
        _missionTime,
        _serverFps,
        _connectedHCs,
        _players,
        _countGroups,
        _allUnits,
        _deadUnits,
        _countRebels,
        _countInvaders,
        _countOccupants,
        _countCiv,
        _destroyedVehicles
        ];

        _debugText ctrlSetStructuredText parseText _formattedString;
    };
Updates debug information display
Formats and displays various game statistics
Uses placeholder values for actual server data
Formats text with proper alignment and structure
Sqf

Apply
    case ("spawnDistanceSliderChanged"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _spawnDistanceSlider = _display displayCtrl A3A_IDC_SPAWNDISTANCESLIDER;
        private _spawnDistanceEditBox = _display displayCtrl A3A_IDC_SPAWNDISTANCEEDITBOX;
        private _sliderValue = sliderPosition _spawnDistanceSlider;
        _spawnDistanceEditBox ctrlSetText str floor _sliderValue;
    };
spawnDistanceSliderChanged case: Handles slider position changes
Updates edit box text to match slider value
Rounds value to integer for display
Sqf

Apply
    case ("spawnDistanceEditBoxChanged"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _spawnDistanceEditBox = _display displayCtrl A3A_IDC_SPAWNDISTANCEEDITBOX;
        private _spawnDistanceSlider = _display displayCtrl A3A_IDC_SPAWNDISTANCESLIDER;
        private _spawnDistanceEditBoxValue = floor parseNumber ctrlText _spawnDistanceEditBox;
        _spawnDistanceEditBox ctrlSetText str _spawnDistanceEditBoxValue; // Strips non-numeric characters
        _spawnDistanceSlider sliderSetPosition _spawnDistanceEditBoxValue;
        if (_spawnDistanceEditBoxValue < _spawnDistanceMin) then {_spawnDistanceEditBox ctrlSetText str _spawnDistanceMin};
        if (_spawnDistanceEditBoxValue > _spawnDistanceMax) then {_spawnDistanceEditBox ctrlSetText str _spawnDistanceMax};
    };
spawnDistanceEditBoxChanged case: Handles edit box value changes
Validates and clamps values to range
Updates slider position to match edit box value
Sqf

Apply
    case ("confirmAILimit"):
    {
        Trace("Showing AI Settings confirm button");
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _commitAiButton = _display displayCtrl A3A_IDC_COMMITAIBUTTON;
        _commitAiButton ctrlRemoveAllEventHandlers "ButtonClick";
        _commitAiButton ctrlSetText localize "STR_antistasi_dialogs_main_admin_ai_confirm_button";
        _commitAiButton ctrlAddEventHandler ["ButtonClick", {
            Trace("Confirmed AI Settings");
            hint "Oh no you broke the server :(";

            private _display = findDisplay A3A_IDD_MAINDIALOG;
            private _spawnDistanceEditBox = _display displayCtrl A3A_IDC_SPAWNDISTANCEEDITBOX;
            private _distanceSPWN = floor parseNumber ctrlText _spawnDistanceEditBox;
            // TODO UI-update: Placeholder routine, don't merge! Has no security checks whatsoever
            // missionNamespace setVariable ["distanceSPWN", _distanceSPWN];


            closeDialog 2;
        }];
    };
confirmAILimit case: Sets up confirm button for AI settings
Adds event handler to button that processes AI settings
Shows confirmation message and closes dialog
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("Admin tab mode does not exist: %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by mainDialog for tab switching
Called by setupDialog for parameter handling
Depends on mainDialog for data flow
Modifies global UI controls
Uses A3A_IDD_MAINDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses ctrlAddEventHandler for control interaction
Function Name: fn_aiManagementTab.sqf
What it does: Manages the AI management tab in the main dialog, handling AI group selection and control.

How it does that: Updates AI listboxes, handles selection changes, and manages AI control actions.

Implementation:

Sqf

Apply
/*
Maintainer: DoomMetal
Handles updating and controls on the AI Management tab of the Main dialog.

Arguments:
<STRING> Mode
<ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
Nothing

Scope: Clients, Local Arguments, Local Effect
Environment: Scheduled for control changes / Unscheduled for update
Public: No
Dependencies:
None

Example:
["update"] call A3A_fnc_aiManagementTab;
*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params[["_mode","onLoad"], ["_params",[]]];
Includes required headers and validates parameters
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("update"):
    {
        Trace("Updating AI Management Tab");
        // Show back button
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _backButton = _display displayCtrl A3A_IDC_MAINDIALOGBACKBUTTON;
        _backButton ctrlRemoveAllEventHandlers "MouseButtonClick";
        _backButton ctrlAddEventHandler ["MouseButtonClick", {
            ["switchTab", ["player"]] call A3A_fnc_mainDialog;
        }];
        _backButton ctrlShow true;
update case: Updates AI management tab UI
Sets up back button to return to player tab
Uses event handler for tab switching
Sqf

Apply
        // Get list of AI group members
        _aisInGroup = [];
        {
            if (!isPlayer _x) then {_aisInGroup pushBackUnique _x};
        } forEach units group player;
Collects AI units in player's group
Excludes player units from list
Sqf

Apply
        // Update AI listBox
        private _aiListBox = _display displayCtrl A3A_IDC_AILISTBOX;
        lbClear _aiListBox;

        // If there are no AI just add a message and disable the listBox
        if (count _aisInGroup < 1) then {
            // This should not happen, the button on the playertab is disabled if you have no AI
            _aiListBox ctrlEnable false;
            _aiListBox lbAdd "No AIs in group. You can recruit them at the flag.";
        } else {
            // Else add units to the listbox
            _aiListBox ctrlEnable true;
            {
                _index = _aiListBox lbAdd name _x;
                _netId = _x call BIS_fnc_netId; // TODO UI-update: can be only netId command instead of function in MP-only
                Trace_1("Adding unit: %1", _netId);
                _aiListBox lbSetData [_index, _netId];
            } forEach _aisInGroup;
        };
Updates AI listbox with current units
Enables/disables listbox based on AI presence
Uses net IDs for unit identification
Sqf

Apply
        // If any units are selected on the command bar select those in the list
        {
            _netId = _x call BIS_fnc_netId; // TODO UI-update: can be only netId command instead of function in MP-only
            Trace_1("Selecting unit: %1", _netId);
            _lbSize = lbSize _aiListBox;
            for "_i" from 0 to (_lbSize - 1) do
            {
                _listNetId = _aiListBox lbData _i;
                Trace_2("LB netID: %1, Sel netId: %2", _listNetId, _netId);
                if (_listNetId isEqualTo _netId) then
                {
                    _aiListBox lbSetSelected [_i, true];
                };
            };
        } forEach groupSelectedUnits player;

        ["aiListBoxSelectionChanged"] spawn A3A_fnc_aiManagementTab;
    };
Selects units that are currently selected in command bar
Spawns selection change handler for UI updates
Sqf

Apply
    case ("clearAIListboxSelection"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _aiListBox = _display displayCtrl A3A_IDC_AILISTBOX;
        _lbSize = lbSize _aiListBox;
        for "_i" from 0 to _lbSize - 1 do
        {
            _aiListBox lbSetSelected [_i, false];
        };

        // Update Selection
        ["aiListBoxSelectionChanged"] spawn A3A_fnc_aiManagementTab;
    };
clearAIListboxSelection case: Clears all listbox selections
Resets selection state and updates UI
Sqf

Apply
    case ("aiListBoxSelectionChanged"):
    {
        // Needs scheduled environment

        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _aiListBox = _display displayCtrl A3A_IDC_AILISTBOX;

        // Disable remote control button if more than 1 AI is selected
        private _aiControlButton = _display displayCtrl A3A_IDC_AICONTROLBUTTON;
        private _aiControlIcon = _display displayCtrl A3A_IDC_AICONTROLICON;
        _lbSelection = lbSelection _aiListBox;
        Trace_1("AI LB selection changed: %1", _lbSelection);
        // TODO UI-update: disable AI control button when petros is selected
        if (count _lbSelection == 1) then
        {
            _aiControlButton ctrlEnable true;
            _aiControlButton ctrlSetTooltip "";
            _aiControlIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
        } else {
            _aiControlButton ctrlEnable false;
            _aiControlButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_ai_management_no_ai_control_tooltip";
            _aiControlIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };

        // If none are selected, disable all the other buttons
        private _aiDismissButton = _display displayCtrl A3A_IDC_AIDISMISSBUTTON;
        private _aiDismissIcon = _display displayCtrl A3A_IDC_AIDISMISSICON;
        private _aiAutoLootButton = _display displayCtrl A3A_IDC_AIAUTOLOOTBUTTON;
        private _aiAutoLootIcon = _display displayCtrl A3A_IDC_AIAUTOLOOTICON;
        private _aiAutoHealButton = _display displayCtrl A3A_IDC_AIAUTOHEALBUTTON;
        private _aiAutoHealIcon = _display displayCtrl A3A_IDC_AIAUTOHEALICON;
        if (count _lbSelection > 0) then {
            _aiDismissButton ctrlEnable true;
            _aiDismissButton ctrlSetTooltip "";
            _aiDismissIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
            _aiAutoLootButton ctrlEnable true;
            _aiAutoLootButton ctrlSetTooltip "";
            _aiAutoLootIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
            _aiAutoHealButton ctrlEnable true;
            _aiAutoHealButton ctrlSetTooltip "";
            _aiAutoHealIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
        } else {
            _aiDismissButton ctrlEnable false;
            _aiDismissButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_ai_management_select_ai_tooltip";
            _aiDismissIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _aiAutoLootButton ctrlEnable false;
            _aiAutoLootButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_ai_management_select_ai_tooltip";
            _aiAutoLootIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _aiAutoHealButton ctrlEnable false;
            _aiAutoHealButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_ai_management_select_ai_tooltip";
            _aiAutoHealIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
    };
aiListBoxSelectionChanged case: Handles selection changes in AI listbox
Enables/disables buttons based on selection count
Updates button tooltips and colors appropriately
Sqf

Apply
    case ("aiControlButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _aiListBox = _display displayCtrl A3A_IDC_AILISTBOX;
        private _unit = objectFromNetId (_aiListBox lbData ((lbSelection _aiListBox) # 0));

        closeDialog 1;
        [[_unit]] spawn A3A_fnc_controlUnit;
    };
aiControlButtonClicked case: Handles AI control button click
Gets selected unit and starts control process
Closes dialog and spawns control function
Sqf

Apply
    case ("dismissButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _aiListBox = _display displayCtrl A3A_IDC_AILISTBOX;
        private _units = [];
        {
            _units pushBack (objectFromNetId (_aiListBox lbData _x));
        } forEach lbSelection _aiListBox;
        [_units] spawn A3A_fnc_dismissPlayerGroup;
    };
dismissButtonClicked case: Handles dismiss AI button click
Collects selected units and dismisses them
Uses spawn for background execution
Sqf

Apply
    case ("autoLootButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _aiListBox = _display displayCtrl A3A_IDC_AILISTBOX;
        private _units = [];
        {
            _units pushBack (objectFromNetId (_aiListBox lbData _x));
        } forEach lbSelection _aiListBox;
        _units spawn A3A_fnc_rearmCall;
    };
autoLootButtonClicked case: Handles auto-loot button click
Collects selected units and starts rearming process
Sqf

Apply
    case ("autoHealButtonClicked"):
    {
    };
autoHealButtonClicked case: Placeholder for auto-heal functionality
Currently does nothing
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("AI Management tab mode does not exist: %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by mainDialog for tab switching
Called by controlUnit, dismissPlayerGroup, and rearmCall for AI actions
Depends on mainDialog for data flow
Modifies global UI controls
Uses A3A_IDD_MAINDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses spawn for background execution, objectFromNetId for unit lookup
Function Name: fn_airSupportTab.sqf
What it does: Manages the air support tab in the main dialog, displaying air support information and handling air support actions.

How it does that: Updates air support display, shows available points, and handles air support button interactions.

Implementation:

Sqf

Apply
/*
Maintainer: DoomMetal
    Handles updating and controls on the Air Support tab of the Main dialog.

Arguments:
    <STRING> Mode
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

Scope: Clients, Local Arguments, Local Effect
Environment: Unscheduled
Public: No
Dependencies:
    None

Example:
    ["update"] call A3A_fnc_airSupportTab;
*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params[["_mode","onLoad"], ["_params",[]]];
Includes required headers and validates parameters
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("update"):
    {
        Trace("Updating Air Support tab");
        // Show back button
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _backButton = _display displayCtrl A3A_IDC_MAINDIALOGBACKBUTTON;
        _backButton ctrlRemoveAllEventHandlers "MouseButtonClick";
        _backButton ctrlAddEventHandler ["MouseButtonClick", {
            ["switchTab", ["commander"]] call A3A_fnc_mainDialog;
        }];
        _backButton ctrlShow true;
update case: Updates air support tab UI
Sets up back button to return to commander tab
Sqf

Apply
        // Display remaining air support points
        private _airSupportPoints = bombRuns;
        private _airSupportPointsText = _display displayCtrl A3A_IDC_AIRSUPPORTPOINTSTEXT;
        _airSupportPointsText ctrlSetText str _airSupportPoints;
Displays current air support points
Uses bombRuns variable for point count
Sqf

Apply
        // Display name of aircraft used
        private _aircraftName = getText (configFile >> "CfgVehicles" >> vehSDKPlane >> "displayName");
        private _airSupportAircraftText = _display displayCtrl A3A_IDC_AIRSUPPORTAIRCRAFTTEXT;
        _airSupportAircraftText ctrlSetText _aircraftName;
Displays aircraft name for air support
Uses vehSDKPlane for aircraft type
Sqf

Apply
        // If there are 0 air support points, disable buttons and set tooltip
        private _heIcon = _display displayCtrl A3A_IDC_AIRSUPPORTHEICON;
        private _heButton = _display displayCtrl A3A_IDC_AIRSUPPORTHEBUTTON;
        private _carpetIcon = _display displayCtrl A3A_IDC_AIRSUPPORTCARPETICON;
        private _carpetButton = _display displayCtrl A3A_IDC_AIRSUPPORTCARPETBUTTON;
        private _napalmIcon = _display displayCtrl A3A_IDC_AIRSUPPORTNAPALMICON;
        private _napalmButton = _display displayCtrl A3A_IDC_AIRSUPPORTNAPALMBUTTON;

        // Check if there are enough air support points
        if (_airSupportPoints < 1) then
        {
            Trace("No air support points, disabling buttons");
            _heIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _heIcon ctrlSetTooltip localize "STR_antistasi_dialogs_main_air_support_no_points_tooltip";
            _heButton ctrlEnable false;
            _heButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_air_support_no_points_tooltip";
            _carpetIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _carpetIcon ctrlSetTooltip localize "STR_antistasi_dialogs_main_air_support_no_points_tooltip";
            _carpetButton ctrlEnable false;
            _carpetButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_air_support_no_points_tooltip";
            _napalmIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _napalmIcon ctrlSetTooltip localize "STR_antistasi_dialogs_main_air_support_no_points_tooltip";
            _napalmButton ctrlEnable false;
            _napalmButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_air_support_no_points_tooltip";
        };
Updates air support buttons based on available points
Disables buttons and sets tooltips when points are insufficient
Uses color arrays for visual feedback
Sqf

Apply
        // TODO UI-update: Check for controlled airbases
        // {sidesX getVariable [_x,sideUnknown] == teamPlayer} count airportsX == 0
    };
Placeholder for airbase control check
Commented out code for future implementation
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("Air Support tab mode does not exist: %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by mainDialog for tab switching
Called by artySupport for air support actions
Depends on mainDialog for data flow
Modifies global UI controls
Uses A3A_IDD_MAINDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses bombRuns variable for point tracking
Function Name: fn_arsenalLimitsDialog.sqf
What it does: Manages the arsenal limits dialog, allowing users to configure item limits for the arsenal.

How it does that: Handles dialog initialization, category selection, and limit adjustments.

Implementation:

Sqf

Apply
/*
    Handles the initialization and updating of the arsenal guest limits dialog.

Arguments:
    0. <STRING> Mode, currently "typeSelect", "listButton", "resetButton" and "stepButton"
    1. <ARRAY<ANY>> Array of params for the mode when applicable.

Returns:
    Nothing

Environment: 
    Should not be called by onLoad because findDisplay and ctrlParent do not work in that context.
*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params ["_mode", "_params"];
Includes required headers and validates parameters
Sqf

Apply
private _fnc_defaultLimit = { [A3A_guestItemLimit, 3*A3A_guestItemLimit] select (_this == 26) };
Creates closure function to determine default limits based on item type
Uses index 26 for magazines to apply different limit
Sqf

Apply
private _display = findDisplay A3A_IDD_ARSENALLIMITSDIALOG;
private _listBox = _display displayCtrl A3A_IDC_ARSLIMLISTBOX;
Finds the arsenal limits dialog display
Gets reference to listbox control
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("typeSelect"):
    {
        private _typeIndex = if (isNil "_params") then { 0 } else { (_params#0) - A3A_IDC_ARSLIMTYPESBASE };
        _display setVariable ["typeIndex", _typeIndex];
        private _defaultLimit = _typeIndex call _fnc_defaultLimit;

        private _cfgCat = switch (_typeIndex) do {
            case 5: { configFile / "cfgVehicles" };
            case 22; case 23; case 26: { configFile / "cfgMagazines" };
            default { configFile / "cfgWeapons" };
        };

        lnbClear _listBox;
        {
            _x params ["_class", "_count"];
            if (_count == -1) then { continue };
            private _itemName = getText (_cfgCat / _class / "displayName");
            private _limit = A3A_arsenalLimits getOrDefault [_class, _defaultLimit];
            if (_typeIndex == 26) then {
                private _capacity = 1 max getNumber (_cfgCat / _class / "count");
                _count = round (_count / _capacity);
            };
            private _rowIndex = _listBox lnbAddRow [_itemName, str _count, str _limit];
            _listBox lnbSetValue [[_rowIndex, 2], _limit];
            _listBox lnbSetData [[_rowIndex, 0], _class];           // store original classname for updating
        } forEach (jna_datalist#_typeIndex);

        // color-invert the selected button, restore the others 
        {
            private _ctrl = _display displayctrl (A3A_IDC_ARSLIMTYPESBASE + _x);
            _ctrl ctrlEnable ([true, false] select (_x == _typeIndex));
        } forEach [0,1,2,3,4,5,6,8,9,11,12,18,19,20,22,23,24,25,26];
    };
typeSelect case: Handles category selection in arsenal limits dialog
Determines which item type is selected
Gets appropriate config category for items
Populates listbox with items of selected type
Updates button states to reflect selection
Sqf

Apply
    case ("listButton"):
    {
        if (isNil {_display getVariable "stepSize"}) exitWith {};
        private _stepSize = _display getVariable "stepSize";
        private _curRow = lnbCurSelRow _listBox;
        private _class = _listBox lnbData [_curRow, 0];

        private _curVal = _listBox lnbValue [_curRow, 2];
        private _newVal = 0 max (_curVal + _stepSize*(_params#0));
        _listBox lnbSetText [[_curRow, 2], str _newVal];
        _listBox lnbSetValue [[_curRow, 2], _newVal];
        A3A_arsenalLimits set [_class, _newVal];
    };
listButton case: Handles limit adjustment via listbox buttons
Calculates new limit value based on step size and direction
Updates listbox display and global limit variable
Sqf

Apply
    case ("resetButton"):
    {
        if (isNil {_display getVariable "typeIndex"}) exitWith {};
        private _defaultLimit = (_display getVariable "typeIndex") call _fnc_defaultLimit;

        private _rowCount = lnbSize _listBox select 0;
        for "_row" from 0 to (_rowCount-1) do {
            _listBox lnbSetText [[_row, 2], str _defaultLimit];
            _listBox lnbSetValue [[_row, 2], _defaultLimit];
            A3A_arsenalLimits deleteAt (_listBox lnbData [_row, 0]);
        };
    };
resetButton case: Resets all limits to default values
Clears specific limit entries from global variable
Updates listbox display to default values
Sqf

Apply
    case ("stepButton"):
    {
        private _stepSize = _display getVariable ["stepSize", 1];
        private _newstepSize = [1, 5] select (_stepSize == 1);
        _display setVariable ["stepSize", _newstepSize];
        private _newText = localize "STR_antistasi_arsenal_limits_dialog_step" + " ±" + str _newStepSize;
        ctrlSetText [A3A_IDC_ARSLIMSTEPBUTTON, _newText];
    };
stepButton case: Toggles step size for limit adjustments
Changes between step sizes of 1 and 5
Updates button text to reflect current step size
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("Arsenal Limits Dialog mode does not exist: %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by mainDialog for tab switching
Called by setupDialog for parameter handling
Depends on mainDialog for data flow
Modifies global A3A_arsenalLimits hash map
Uses A3A_IDD_ARSENALLIMITSDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses lnbAddRow, lnbSetText, lnbSetValue for listbox manipulation

Function Name: fn_blackMarketDialog.sqf
What it does: Manages the black market dialog, handling vehicle category switching and UI initialization.

How it does that: Initializes vehicle categories, handles tab switching, and manages vehicle selection.

Implementation:

Sqf

Apply
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
Code Breakdown:

Sqf

Apply
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
Includes required headers and validates parameters
Sets default values for optional parameters
Switch Cases:

Sqf

Apply
switch (_mode) do
{
    case ("switchTab"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;

        private _vehicleType = (uiNamespace getVariable ["bm_vehicleTypeBox", ""]);
        private _cursel = lbCurSel _vehicleType;
        private _categoryIndex = _vehicleType lbValue _cursel;

        private _display = findDisplay A3A_IDD_BLACKMARKETVEHICLEDIALOG;

        Debug_1("MainDialog switching tab to %1.", _categoryIndex);

        private _selectedTabIDC = -1;
        switch (_categoryIndex) do 
        {
            case (0): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETMAIN;
            };
            case (1): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETARTY;
            };
            case (2): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETAPC;
            };
            case (3): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETAA;
            };
            case (4): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETUAV;
            };
            case (5): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETTANK;
            };
            case (6):
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETSTATICS;
            };
            case (7): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETHELI;
            };
            case (8): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETPLANE;
            };
            case (9): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETARMEDCAR;
            };
            case (10): 
            {
                _selectedTabIDC = A3A_IDC_BLACKMARKETUNARMEDCAR;
            };
            case (11): 
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
switchTab case: Handles vehicle category tab switching
Determines selected category from dropdown
Shows appropriate tab based on category
Hides all other tabs
Sqf

Apply
    case ("onLoad"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;

        private _displayBM = findDisplay A3A_IDD_BLACKMARKETVEHICLEDIALOG;
        private _bmTable = _displayBM displayCtrl A3A_IDC_SETUP_BMTABLE;

        private _vehicleTypes = [localize "STR_antistasi_dialogs_vehicle_tab_all", localize "STR_antistasi_dialogs_vehicle_tab_arty", localize "STR_antistasi_dialogs_vehicle_tab_apc", localize "STR_antistasi_dialogs_vehicle_tab_AA",
        localize "STR_antistasi_dialogs_vehicle_tab_uav", localize "STR_antistasi_dialogs_vehicle_tab_tank",localize "STR_antistasi_dialogs_vehicle_tab_statics", localize "STR_antistasi_dialogs_vehicle_tab_heli", 
        localize "STR_antistasi_dialogs_vehicle_tab_plane", localize "STR_antistasi_dialogs_vehicle_tab_armedcar", localize "STR_antistasi_dialogs_vehicle_tab_unarmedcar", localize "STR_antistasi_dialogs_vehicle_tab_boat"];
        private _vals = ["all", "artillery", "apc", "aa", "uav", "tank", "statics", "heli", "plane", "armedcar", "unarmedcar", "boat"];

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

        waitUntil {sleep 1; uiNamespace getVariable ["A3U_BM_isTabsComplete", false]};

        private _valsCtrl = _bmTable;
        /* _valsCtrl ctrlSetPosition [GRID_W * -30.4, GRID_H*-17.9, GRID_W*125, GRID_H*5]; */
        _valsCtrl ctrlCommit 0;
        {
            private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
            _valsCtrl lbSetValue [_index, (_vals find _x)];
        } forEach _vals;
        
        private _default = "all";
        _valsCtrl lbSetCurSel (_vals find _default);
        _valsCtrl lbSetSelected [0, true];

        uiNamespace setVariable ["bm_vehicleTypeBox", _valsCtrl];
    };
onLoad case: Initializes black market dialog
Sets up vehicle type dropdown with all categories
Calls vehicle tab functions for each category
Waits for tabs to complete loading
Sets up default selection
Sqf

Apply
    case ("onUnload"): 
    {
        ['off'] call SCRT_fnc_ui_toggleMenuBlur;
    };
onUnload case: Cleans up black market dialog
Removes blur effect from UI
Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("BlackMarketDialog mode does not exist: %1", _mode);
    };
};
Handles unknown modes with error logging
Where it leads:

Called by mainDialog for tab switching
Called by blackMarketTabs for vehicle category loading
Depends on mainDialog and blackMarketTabs for data flow
Modifies global UI state
Uses A3A_IDD_BLACKMARKETVEHICLEDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses waitUntil for tab loading completion

Function Name: fn_blackMarketTabs.sqf
What it does: Manages vehicle tabs in the black market dialog, handling vehicle display and selection.

How it does that: Populates vehicle categories with vehicle data, creates UI controls, and handles vehicle selection.

Implementation:

Sqf

Apply
/*
Maintainer: DoomMetal, killerswin2
    Handles the initialization and updating of the Buy item dialog.
    This function should only be called from Buyvehicle onLoad and control activation EHs.

Arguments:
    <STRING> Mode, only possible value for this dialog is "onLoad"
    <ARRAY<ANY>> Array of params for the mode when applicable. Params for specific modes are documented in the modes.

Return Value:
    Nothing

Scope: Clients, Local Arguments, Local Effect
Environment: Scheduled for onLoad mode 
Public: No
Dependencies:
    None

Example:
    ["logistics"] call A3A_fnc_blackMarketTab;
*/
Code Breakdown:

Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

params[
    ["_tab","_vehicles"], 
    ["_params",[]]
];
Includes required headers and validates parameters
Sqf

Apply
private _display = findDisplay A3A_IDD_BLACKMARKETVEHICLEDIALOG;
Finds the black market dialog display
Sqf

Apply
if (_tab isEqualTo "vehicles") then 
{
    _params params ["_tab", "_selectedTab", "_category"];
    Debug("BuyVehicleTab starting...");

    // show the vehicle tab so that user don't freak out
    private _selectedTabCtrl = _display displayCtrl A3A_IDC_BLACKMARKETMAIN;
    _selectedTabCtrl ctrlShow true;

    // Setup Object render
    private _objPreview = _display displayCtrl A3A_IDC_BLACKMARKETBUYOBJECTRENDER;
    _objPreview ctrlShow false;

    // Add stuff to the buyable vehicles list
    private _buyableVehiclesList = [_category] call SCRT_fnc_ui_populateBlackMarket;
    private _vehiclesControlsGroup = _display displayCtrl _selectedTab;

    private _added = 0;
    {
        _x params ["_className", "_price", "_canGoUndercover"];
        private _configClass = (configFile >> "CfgVehicles" >> _className);
        if (!isClass _configClass) then { continue };

        private _crewCount = [_className] call A3A_fnc_getVehicleCrewCount;
        _crewCount params ["_driver", "_coPilot", "_commander", "_gunners", "_passengers", "_passengersFFV"];
        
        private _configClass = configFile >> "CfgVehicles" >> _className;
        private _displayName = getText (_configClass >> "displayName");
        private _editorPreview = getText (_configClass >> "editorPreview");
        //private _vehicleIcon= getText (_configClass >> "Icon");
        private _model = getText (_configClass >> "model");

        private _hasVehiclePreview = fileExists _editorPreview;
        if (!_hasVehiclePreview) then {_editorPreview = A3A_PlaceHolder_NoVehiclePreview; _hasVehiclePreview = true}; // Remove this line to re-add "object" renders
        /* Turn on if you want the icons as a midway fallback
        if (!_hasVehiclePreview && fileExists _vehicleIcon) then {
            _editorPreview = _vehicleIcon;
            _hasVehiclePreview = true;
        };
        */

        // Add some extra padding to the top if there are 2 rows or less
        private _topPadding = if (count _buyableVehiclesList < 7) then {5 * GRID_H} else {1 * GRID_H};

        private _itemXpos = 7 * GRID_W + ((7 * GRID_W + 44 * GRID_W) * (_added mod 3)); /// space between first row(?) and left border
        private _itemYpos = (floor (_added / 3)) * (38 * GRID_H) + _topPadding; ///spacer between vehicles

        private _itemControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _vehiclesControlsGroup];
        _itemControlsGroup ctrlSetPosition[_itemXpos, _itemYpos, 44 * GRID_W, 37 * GRID_H];
        _itemControlsGroup ctrlSetFade 1;
        _itemControlsGroup ctrlCommit 0;

        private _previewPicture = _display ctrlCreate ["A3A_Picture", A3A_IDC_BLACKMARKETPREVIEW, _itemControlsGroup];
        _previewPicture ctrlSetPosition [0, 0, 44 * GRID_W, 25 * GRID_H];
        _previewPicture ctrlSetText _editorPreview;
        _previewPicture ctrlCommit 0;

        private _label = _display ctrlCreate ["A3A_SectionStructuredLabelLeft", -1, _itemControlsGroup];
        _label ctrlSetPosition [0, 0, 44 * GRID_W, 6 * GRID_H];
        private _dlc = "";
        private _addons = configsourceaddonlist _configClass;
        if (count _addons > 0) then {
        	private _mods = configsourcemodlist (configfile >> "CfgPatches" >> _addons select 0);
        	if (count _mods > 0) then {
        		_dlc = _mods select 0;
        	};
        };
        private _dlcParams = modParams [_dlc,["logo","logoOver"]];
        private _logo = _dlcParams param [0,""];
        private _logoOver = _dlcParams param [1,""];
        private _fieldManualTopicAndHint = getarray (configfile >> "cfgMods" >> _dlc >> "fieldManualTopicAndHint");
        _label ctrlseteventhandler ["buttonclick",format ["if (count %1 > 0) then {(%1 + [ctrlparent (_this select 0)]) call bis_fnc_openFieldManual;};",_fieldManualTopicAndHint]];
        private _OriginsText = composeText [
            _displayName," ",image _logo
        ];
        _label ctrlSetStructuredText _OriginsText;
        _label ctrlSetBackgroundColor [0,0,0,0.5];
        _label ctrlCommit 0;

        private _buttonTakeout = _display ctrlCreate ["A3A_ShortcutButtonSmall", -1, _itemControlsGroup];
        _buttonTakeout ctrlSetPosition [0, 25 * GRID_H, 22 * GRID_W, 6 * GRID_H];
        _buttonTakeout ctrlSetText (localize "STR_antistasi_dialogs_buy_vehicle_button");
        _buttonTakeout ctrlSetTooltip format [localize "STR_antistasi_dialogs_buy_vehicle_button_tooltip", _displayName, _price, A3A_faction_civ get "currencySymbol"];
        _buttonTakeout setVariable ["className", _className];
        _buttonTakeout setVariable ["model", _model];
        _buttonTakeout ctrlAddEventHandler ["ButtonClick", {
            closeDialog 2; [(_this # 0) getVariable "className", false] spawn A3A_fnc_addBlackMarketVeh;
        }];
         _buttonTakeout ctrlCommit 0;

        private _buttonInfo = _display ctrlCreate ["A3A_ShortcutButtonSmall", -1, _itemControlsGroup];
        _buttonInfo ctrlSetPosition [22 * GRID_W, 25 * GRID_H, 22 * GRID_W, 6 * GRID_H];
        _buttonInfo ctrlSetText (localize "STR_antistasi_dialogs_buy_vehicle_info_button");
        _buttonInfo ctrlSetTooltip (localize "STR_antistasi_dialogs_buy_vehicle_info_button_tooltip");
        _buttonInfo setVariable ["className", _className];
        _buttonInfo ctrlAddEventHandler ["ButtonClick", {
            [(_this # 0) getVariable "className"] call A3A_fnc_vehicleInfoDialog;
        }];
        _buttonInfo ctrlCommit 0;

        private _priceText = _display ctrlCreate ["A3A_Text_Small", -1, _itemControlsGroup];
        _priceText ctrlSetPosition [0, 31 * GRID_H, 44 * GRID_W, 6 * GRID_H];
        _priceText ctrlSetText format [localize "STR_antistasi_dialogs_buy_vehicle_price", _price, A3A_faction_civ get "currencySymbol"];
        _priceText ctrlSetBackgroundColor [0,0,0,0.5];
        _priceText ctrlCommit 0;

        private _crewText = _display ctrlCreate ["A3A_Text_Small", -1, _itemControlsGroup];
        _crewText ctrlSetPosition [0, 37 * GRID_H, 44 * GRID_W, 6 * GRID_H];
        _crewText ctrlSetText format [localize "STR_antistasi_dialogs_buy_vehicle_crew", _driver, _coPilot, _commander, _gunners, _passengers, _passengersFFV];
        _crewText ctrlSetBackgroundColor [0,0,0,0.5];
        _crewText ctrlCommit 0;

        _added = _added + 1;
    } forEach _buyableVehiclesList;

    uiNamespace setVariable ["A3U_BM_isTabsComplete", true];
};

vehicles case: Populates vehicle tabs with vehicle data
Creates UI controls for each vehicle including preview, name, price, and crew info
Sets up buy and info buttons with appropriate event handlers
Uses SCRT_fnc_ui_populateBlackMarket to get vehicle list
Handles vehicle preview images and DLC information
Sets up proper positioning and styling for vehicle items
Where it leads:

Called by blackMarketDialog for tab initialization
Depends on blackMarketDialog for data flow
Modifies global UI controls
Uses A3A_IDD_BLACKMARKETVEHICLEDIALOG, A3A_IDC_* constants for UI control references
Synchronization: Uses uiNamespace for tab completion tracking, ctrlCreate for UI element creation

Function Name: fn_buyVehicleDialog.sqf
What it does:
Handles the initialization and updating of the Buy Vehicle dialog. This function manages the tab switching logic, category selection, and dialog setup for the vehicle purchasing system in the Antistasi mod.

How it does that:
The function operates as a switch statement that handles different modes: "onLoad", "onUnload", "switchTab", and "selectCategory". It manages the display of different vehicle tabs (civilian, rebel, static, other) and populates vehicle lists based on category selection.

Implementation:
Sqf

Apply
params[
    ["_mode","onLoad"], ["_params",[]]
];
Initializes parameters with default mode "onLoad" and empty params array.

Sqf

Apply
switch (_mode) do
{
    case ("switchTab"):
    {   
        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG; 
        private _selectedTab = _params select 0;
        lnbClear A3A_IDC_SETUP_CVTABLE;
When switching tabs, retrieves the display and selected tab, clears the table, and initializes tab-specific variables.

Sqf

Apply
        Debug_1("MainDialog switching tab to %1.", _selectedTab);

        private _selectedTabIDC = -1;
        switch (_selectedTab) do 
        {
            case ("civil"): {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEMAIN;
                lnbClear _valsCtrl;
Handles the civilian tab case, setting up tab ID and clearing existing controls.

Sqf

Apply
                private _displayCV = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
                private _cvTable = _displayCV displayCtrl A3A_IDC_SETUP_CVTABLE;
                private _valsCtrl = _cvTable;
                private _vehicleTypes = [localize "STR_antistasi_dialogs_vehicle_tab_civall",
                localize "STR_antistasi_dialogs_vehicle_tab_civcars",
                localize "STR_antistasi_dialogs_vehicle_tab_civtrucks",
                localize "STR_antistasi_dialogs_vehicle_tab_civboats",
                localize "STR_antistasi_dialogs_vehicle_tab_civheli",
                localize "STR_antistasi_dialogs_vehicle_tab_civplanes"
                ];
                private _vals = ["civilian", "civcars", "civtrucks", "civboats", "civheli", "civplane"];

                _valsCtrl ctrlCommit 0;
                {
                    private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
                    _valsCtrl lbSetValue [_index, (_vals find _x)];
                } forEach _vals;
Populates the vehicle type list box with civilian vehicle categories and their corresponding values.

Sqf

Apply
                private _default = "civilian";
                _valsCtrl lbSetCurSel (_vals find _default);
                _valsCtrl lbSetSelected [0, true];
            
                uiNamespace setVariable ["cv_vehicleTypeBox", _valsCtrl];
            };
Sets the default selection to "civilian" and stores the control in the UI namespace.

Sqf

Apply
            case("rebel"): {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEMAIN;
                lnbClear _valsCtrl;

                private _displayCV = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
                private _cvTable = _displayCV displayCtrl A3A_IDC_SETUP_CVTABLE;
                private _valsCtrl = _cvTable;
                private _vehicleTypes = [localize "STR_antistasi_dialogs_vehicle_tab_reball",
                localize "STR_antistasi_dialogs_vehicle_tab_rebbasic",
                localize "STR_antistasi_dialogs_vehicle_tab_rebtrucks",
                localize "STR_antistasi_dialogs_vehicle_tab_reblightunarmed",
                localize "STR_antistasi_dialogs_vehicle_tab_rebboats",
                localize "STR_antistasi_dialogs_vehicle_tab_rebmedical",
                localize "STR_antistasi_dialogs_vehicle_tab_reblightarmed",
                localize "STR_antistasi_dialogs_vehicle_tab_rebat",
                localize "STR_antistasi_dialogs_vehicle_tab_rebaa",
                localize "STR_antistasi_dialogs_vehicle_tab_rebplane"
                ];
                private _vals = ["military","militarybasic","militarytrucks","militarylightunarmed","militaryboats","militarymedical","militarylightarmed","militaryat","militaryaa","militaryplane"];
                
                _valsCtrl ctrlCommit 0;
                {
                    private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
                    _valsCtrl lbSetValue [_index, (_vals find _x)];
                } forEach _vals;
Handles the rebel tab case, populating the list box with rebel vehicle categories.

Sqf

Apply
                private _default = "military";
                _valsCtrl lbSetCurSel (_vals find _default);
                _valsCtrl lbSetSelected [0, true];
            
                uiNamespace setVariable ["cv_vehicleTypeBox", _valsCtrl];
            };
Sets the default selection to "military" and stores the control in the UI namespace.

Sqf

Apply
            case ("static"): {
                _selectedTabIDC = A3A_IDC_BUYSTATICMAIN;
                lnbClear _valsCtrl;
    
                private _displayCV = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
                private _cvTable = _displayCV displayCtrl A3A_IDC_SETUP_CVTABLE;
                private _valsCtrl = _cvTable;
                private _vehicleTypes = [localize "STR_antistasi_dialogs_vehicle_tab_statics",
                localize "STR_antistasi_dialogs_vehicle_tab_staticMG",
                localize "STR_antistasi_dialogs_vehicle_tab_staticAT",
                localize "STR_antistasi_dialogs_vehicle_tab_staticAA",
                localize "STR_antistasi_dialogs_vehicle_tab_staticmortars"
                ];
                private _vals = ["static","staticMG","staticAT","staticAA","staticMORTAR"];

                _valsCtrl ctrlCommit 0;
                {
                    private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
                    _valsCtrl lbSetValue [_index, (_vals find _x)];
                } forEach _vals;
Handles the static tab case, populating the list box with static weapon categories.

Sqf

Apply
                private _default = "static";
                _valsCtrl lbSetCurSel (_vals find _default);
                _valsCtrl lbSetSelected [0, true];
            
                uiNamespace setVariable ["cv_vehicleTypeBox", _valsCtrl];
            };
Sets the default selection to "static" and stores the control in the UI namespace.

Sqf

Apply
            case("other"): {
                _selectedTabIDC = A3A_IDC_BUYOTHERMAIN;
                lnbClear _valsCtrl;

                private _displayCV = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
                private _cvTable = _displayCV displayCtrl A3A_IDC_SETUP_CVTABLE;
                private _valsCtrl = _cvTable;
                private _vehicleTypes = [localize "STR_antistasi_dialogs_vehicle_tab_other"];
                private _vals = ["other"];

                _valsCtrl ctrlCommit 0;
                {
                    private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
                    _valsCtrl lbSetValue [_index, (_vals find _x)];
                } forEach _vals;
Handles the other tab case, populating the list box with the "other" category.

Sqf

Apply
                private _default = "other";
                _valsCtrl lbSetCurSel (_vals find _default);
                _valsCtrl lbSetSelected [0, true];
            
                uiNamespace setVariable ["cv_vehicleTypeBox", _valsCtrl];
            };
        };
Sets the default selection to "other" and stores the control in the UI namespace.

Sqf

Apply
        if (_selectedTabIDC == -1) exitWith {
            Error("Attempted to access tab without permission : %1", _selectedTab);
        };
Exits with error if no valid tab ID was set.

Sqf

Apply
        private _allTabs = [
            A3A_IDC_BUYCIVVEHICLEMAIN,
            A3A_IDC_BUYCIVVEHICLECARS,
            A3A_IDC_BUYCIVVEHICLETRUCKS,
            A3A_IDC_BUYCIVVEHICLEBOATS,
            A3A_IDC_BUYCIVVEHICLEHELI,
            A3A_IDC_BUYCIVVEHICLEPLANE,
            A3A_IDC_BUYREBVEHICLEBASIC,
            A3A_IDC_BUYREBVEHICLETRUCKS,
            A3A_IDC_BUYREBVEHICLELIGHTUNARMED,
            A3A_IDC_BUYREBVEHICLEBOATS,
            A3A_IDC_BUYREBVEHICLEMEDICAL,
            A3A_IDC_BUYREBVEHICLELIGHTARMED,
            A3A_IDC_BUYREBVEHICLEAT,
            A3A_IDC_BUYREBVEHICLEAA,
            A3A_IDC_BUYREBVEHICLEPLANE,
            A3A_IDC_BUYSTATICVEHICLEMG,
            A3A_IDC_BUYSTATICVEHICLEAT,
            A3A_IDC_BUYSTATICVEHICLEAA,
            A3A_IDC_BUYSTATICVEHICLEMORTAR,
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
Creates a list of all tabs and hides them, then shows the selected tab.

Sqf

Apply
        // Show selected tab
        Debug("Showing selected tab");
        private _selectedTabCtrl = _display displayCtrl _selectedTabIDC;
        _selectedTabCtrl ctrlShow true;
    };
Shows the selected tab control.

Sqf

Apply
    case ("selectCategory"):
    {
        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _selectedCategory = _params select 0;

        private _selectedTabIDC = -1;
        switch (_selectedCategory) do
        {
            case localize "STR_antistasi_dialogs_vehicle_tab_civall": {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEMAIN; 
            };
Handles category selection by mapping localized category names to tab IDs.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_civcars": {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLECARS;
            };
Maps civilian cars category to the cars tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_civtrucks": {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLETRUCKS;
            };
Maps civilian trucks category to the trucks tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_civboats": {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEBOATS;
            };
Maps civilian boats category to the boats tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_civheli": {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEHELI;
            };
Maps civilian helicopters category to the helicopters tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_civplanes": {
                _selectedTabIDC = A3A_IDC_BUYCIVVEHICLEPLANE;
            };
Maps civilian planes category to the planes tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebbasic": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEBASIC;
            };
Maps rebel basic vehicles category to the basic tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebtrucks": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLETRUCKS;
            };
Maps rebel trucks category to the trucks tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_reball": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEMAIN;
            };
Maps rebel all vehicles category to the main rebel tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_reblightunarmed": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLELIGHTUNARMED;
            };
Maps rebel light unarmed vehicles category to the light unarmed tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebboats": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEBOATS;
            };
Maps rebel boats category to the boats tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebmedical": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEMEDICAL;
            };
Maps rebel medical vehicles category to the medical tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_reblightarmed": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLELIGHTARMED;
            };
Maps rebel light armed vehicles category to the light armed tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebat": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEAT;
            };
Maps rebel AT vehicles category to the AT tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebaa": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEAA;
            };
Maps rebel AA vehicles category to the AA tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_rebplane": {
                _selectedTabIDC = A3A_IDC_BUYREBVEHICLEPLANE;
            };
Maps rebel planes category to the planes tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_statics": {
                _selectedTabIDC = A3A_IDC_BUYSTATICMAIN;
            };
Maps static weapons category to the static main tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_staticMG": {
                _selectedTabIDC = A3A_IDC_BUYSTATICVEHICLEMG;
            };
Maps static MG weapons category to the MG tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_staticAT": {
                _selectedTabIDC = A3A_IDC_BUYSTATICVEHICLEAT;
            };
Maps static AT weapons category to the AT tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_staticAA": {
                _selectedTabIDC = A3A_IDC_BUYSTATICVEHICLEAA;
            };
Maps static AA weapons category to the AA tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_staticmortars": {
                _selectedTabIDC = A3A_IDC_BUYSTATICVEHICLEMORTAR;
            };
Maps static mortars category to the mortars tab.

Sqf

Apply
            case localize "STR_antistasi_dialogs_vehicle_tab_other": {
                _selectedTabIDC = A3A_IDC_BUYOTHERMAIN;
            };
        };
Maps other category to the other tab.

Sqf

Apply
        private _allTabs = [
            A3A_IDC_BUYCIVVEHICLEMAIN,
            A3A_IDC_BUYCIVVEHICLECARS,
            A3A_IDC_BUYCIVVEHICLETRUCKS,
            A3A_IDC_BUYCIVVEHICLEBOATS,
            A3A_IDC_BUYCIVVEHICLEHELI,
            A3A_IDC_BUYCIVVEHICLEPLANE,
            A3A_IDC_BUYREBVEHICLEBASIC,
            A3A_IDC_BUYREBVEHICLETRUCKS,
            A3A_IDC_BUYREBVEHICLELIGHTUNARMED,
            A3A_IDC_BUYREBVEHICLEBOATS,
            A3A_IDC_BUYREBVEHICLEMEDICAL,
            A3A_IDC_BUYREBVEHICLELIGHTARMED,
            A3A_IDC_BUYREBVEHICLEAT,
            A3A_IDC_BUYREBVEHICLEAA,
            A3A_IDC_BUYREBVEHICLEPLANE,
            A3A_IDC_BUYSTATICVEHICLEMG,
            A3A_IDC_BUYSTATICVEHICLEAT,
            A3A_IDC_BUYSTATICVEHICLEAA,
            A3A_IDC_BUYSTATICVEHICLEMORTAR,
            A3A_IDC_BUYREBVEHICLEMAIN,
            A3A_IDC_BUYSTATICMAIN,
            A3A_IDC_BUYOTHERMAIN,
            A3A_IDC_BUYVEHICLEPREVIEW
        ];

        {
            private _ctrl = _display displayCtrl _x;
            _ctrl ctrlShow false;
        } forEach _allTabs;
Hides all tabs and then shows the selected one.

Sqf

Apply
        // Show selected tab
        Debug("Showing selected tab");
        private _selectedTabCtrl = _display displayCtrl _selectedTabIDC;
        _selectedTabCtrl ctrlShow true;
    };
Shows the selected tab control.

Sqf

Apply
    case ("onLoad"):
    {
        ['on'] call SCRT_fnc_ui_toggleMenuBlur;

        ["vehicles", [A3A_IDC_BUYCIVVEHICLECARS, A3A_IDC_CIVVEHICLESGROUPCARS, "civcars"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLETRUCKS, A3A_IDC_CIVVEHICLESGROUPTRUCKS, "civtrucks"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEBOATS, A3A_IDC_CIVVEHICLESGROUPBOATS, "civboats"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEHELI, A3A_IDC_CIVVEHICLESGROUPHELI, "civheli"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYCIVVEHICLEPLANE, A3A_IDC_CIVVEHICLESGROUPPLANE, "civplane"]] call A3A_fnc_buyVehicleTabs;
        
        ["vehicles", [A3A_IDC_BUYREBVEHICLEBASIC, A3A_IDC_REBVEHICLESGROUPBASIC, "militarybasic"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLETRUCKS, A3A_IDC_REBVEHICLESGROUPTRUCKS, "militarytrucks"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLELIGHTUNARMED, A3A_IDC_REBVEHICLESGROUPLIGHTUNARMED, "militarylightunarmed"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEBOATS, A3A_IDC_REBVEHICLESGROUPBOATS, "militaryboats"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEMEDICAL, A3A_IDC_REBVEHICLESGROUPMEDICAL, "militarymedical"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLELIGHTARMED, A3A_IDC_REBVEHICLESGROUPLIGHTARMED, "militarylightarmed"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEAT, A3A_IDC_REBVEHICLESGROUPAT, "militaryat"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEAA, A3A_IDC_REBVEHICLESGROUPAA, "militaryaa"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEPLANE, A3A_IDC_REBVEHICLESGROUPPLANE, "militaryplane"]] call A3A_fnc_buyVehicleTabs;

        ["vehicles", [A3A_IDC_BUYSTATICVEHICLEMG, A3A_IDC_STATICVEHICLESGROUPMG, "staticMG"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYSTATICVEHICLEAT, A3A_IDC_STATICVEHICLESGROUPAT, "staticAT"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYSTATICVEHICLEAA, A3A_IDC_STATICVEHICLESGROUPAA, "staticAA"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYSTATICVEHICLEMORTAR, A3A_IDC_STATICVEHICLESGROUPMORTAR, "staticMORTAR"]] call A3A_fnc_buyVehicleTabs;

        ["vehicles", [A3A_IDC_BUYCIVVEHICLEMAIN, A3A_IDC_CIVVEHICLESGROUP, "civilian"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYREBVEHICLEMAIN, A3A_IDC_REBVEHICLESGROUP, "military"]] call A3A_fnc_buyVehicleTabs;
        ["vehicles", [A3A_IDC_BUYSTATICMAIN, A3A_IDC_STATICSGROUP, "static"]] call A3A_fnc_buyVehicleTabs;
        ["other"] call A3A_fnc_buyVehicleTabs;
Initializes the dialog by calling buyVehicleTabs for all vehicle categories and the other tab.

Sqf

Apply
        // show the vehicle tab so that user don't freak out
        private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _selectedTabCtrl = _display displayCtrl A3A_IDC_BUYCIVVEHICLEMAIN;
        _selectedTabCtrl ctrlShow true;

        private _displayCV = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
        private _cvTable = _displayCV displayCtrl A3A_IDC_SETUP_CVTABLE;
        private _valsCtrl = _cvTable;
        private _vehicleTypes = [localize "STR_antistasi_dialogs_vehicle_tab_civall",
        localize "STR_antistasi_dialogs_vehicle_tab_civcars",
        localize "STR_antistasi_dialogs_vehicle_tab_civtrucks",
        localize "STR_antistasi_dialogs_vehicle_tab_civboats",
        localize "STR_antistasi_dialogs_vehicle_tab_civheli",
        localize "STR_antistasi_dialogs_vehicle_tab_civplanes"
        ];
        private _vals = ["civilian", "civcars", "civtrucks", "civboats", "civheli", "civplane"];

        _valsCtrl ctrlCommit 0;
        {
            private _index = _valsCtrl lbAdd (_vehicleTypes#_forEachIndex);
            _valsCtrl lbSetValue [_index, (_vals find _x)];
        } forEach _vals;
        
        private _default = "civilian";
        _valsCtrl lbSetCurSel (_vals find _default);
        _valsCtrl lbSetSelected [0, true];
        
        uiNamespace setVariable ["cv_vehicleTypeBox", _valsCtrl];
    };
Shows the civilian vehicle tab by default and sets up the vehicle type selection box.

Sqf

Apply
    case ("onUnload"): 
    {
        ['off'] call SCRT_fnc_ui_toggleMenuBlur;
    };
Removes the blur effect when the dialog is closed.

Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("BuyVehicleDialog mode does not exist: %1", _mode);
    };
};
Logs an error if an invalid mode is attempted to be called.

Where it leads:
This function calls SCRT_fnc_ui_toggleMenuBlur to control UI blur effects, A3A_fnc_buyVehicleTabs to populate vehicle lists, and A3A_fnc_addFIAveh when a vehicle is purchased. It also depends on A3A_fnc_getVehicleCrewCount for vehicle information.

Requirements:
Requires SCRT_fnc_ui_toggleMenuBlur function to be available
Requires A3A_fnc_buyVehicleTabs function to be available
Requires A3A_fnc_addFIAveh function to be available
Requires A3A_fnc_getVehicleCrewCount function to be available
Uses global variables like A3A_IDD_BUYVEHICLEDIALOG, A3A_IDC_SETUP_CVTABLE, etc.
Uses localization strings for vehicle tab names
Function Name: fn_buyVehicleTabs.sqf
What it does:
Handles the initialization and updating of vehicle tabs in the Buy Vehicle dialog. It populates vehicle lists based on categories and displays vehicle information including previews, prices, and crew requirements.

How it does that:
The function operates as a switch statement handling the "vehicles" and "other" modes. For vehicle mode, it populates lists of vehicles based on category and creates UI controls for each vehicle with previews, prices, and crew information. For other mode, it handles utility items.

Implementation:
Sqf

Apply
params[
    ["_tab","_vehicles"],["_params",[]]
];
Initializes parameters with default tab "_vehicles" and empty params array.

Sqf

Apply
private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;
Retrieves the main display for the buy vehicle dialog.

Sqf

Apply
if (_tab isEqualTo "vehicles") then 
{
    _params params ["_tab", "_selectedTab", "_category"];
    Debug("BuyVehicleTab starting. ..");
Handles the vehicle tab case by extracting parameters and logging start.

Sqf

Apply
    // show the vehicle tab so that user don't freak out
    private _selectedTabCtrl = _display displayCtrl A3A_IDC_BUYCIVVEHICLEMAIN;
    _selectedTabCtrl ctrlShow true;
Shows the civilian vehicle tab by default to prevent UI confusion.

Sqf

Apply
    // Setup Object render
    private _objPreview = _display displayCtrl A3A_IDC_BUYOBJECTRENDER;  // 9303;
    _objPreview ctrlShow false;
Initializes the object preview control and hides it.

Sqf

Apply
    // Add stuff to the buyable vehicles list
    private _buyableVehiclesList = [_category] call SCRT_fnc_ui_populateVehicleBox;
    private _vehiclesControlsGroup = _display displayCtrl _selectedTab;
Retrieves the list of buyable vehicles for the selected category and gets the vehicles controls group.

Sqf

Apply
    private _added = 0;
    {
        _x params ["_className", "_price", "_canGoUndercover"];
        private _configClass = configFile >> "CfgVehicles" >> _className;
        if (!isClass _configClass) then { continue };
Iterates through the vehicles list, extracting parameters and checking if the config class exists.

Sqf

Apply
        private _crewCount = [_className] call A3A_fnc_getVehicleCrewCount;
        _crewCount params ["_driver", "_coPilot", "_commander", "_gunners", "_passengers", "_passengersFFV"];
Gets the crew count information for the vehicle.

Sqf

Apply
        private _displayName = getText (_configClass >> "displayName");
        private _editorPreview = getText (_configClass >> "editorPreview");
        //private _vehicleIcon= getText (_configClass >> "Icon");
        private _model = getText (_configClass >> "model");
Retrieves vehicle display name, preview image, and model.

Sqf

Apply
        private _hasVehiclePreview = fileExists _editorPreview;
Checks if a preview file exists for the vehicle.

Sqf

Apply
        // Add some extra padding to the top if there are 2 rows or less
        private _topPadding = if (count _buyableVehiclesList < 7) then {5 * GRID_H} else {0};
Adds padding for better visual layout when there are fewer vehicles.

Sqf

Apply
        private _itemXpos = 7 * GRID_W + ((7 * GRID_W + 44 * GRID_W) * (_added mod 3));
        private _itemYpos = (floor (_added / 3)) * (44 * GRID_H) + _topPadding;
Calculates position for the vehicle item control.

Sqf

Apply
        private _itemControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _vehiclesControlsGroup];
        _itemControlsGroup ctrlSetPosition[_itemXpos, _itemYpos, 44 * GRID_W, 37 * GRID_H];
        _itemControlsGroup ctrlSetFade 1;
        _itemControlsGroup ctrlCommit 0;
Creates the main controls group for the vehicle item.

Sqf

Apply
        private _previewPicture = _display ctrlCreate ["A3A_Picture", A3A_IDC_BUYVEHICLEPREVIEW, _itemControlsGroup];
        _previewPicture ctrlSetPosition [0, 0, 44 * GRID_W, 25 * GRID_H];
        _previewPicture ctrlSetText _editorPreview;
        _previewPicture ctrlCommit 0;
Creates and positions the preview picture control.

Sqf

Apply
        private _label = _display ctrlCreate ["A3A_SectionStructuredLabelLeftHQstore", -1, _itemControlsGroup]; ///A3A_PictureStroke
        _label ctrlSetPosition [36 * GRID_W, 0.55 * GRID_H, 8 * GRID_W, 8 * GRID_H];
        private _dlc = "";
        private _addons = configsourceaddonlist _configClass;
        if (count _addons > 0) then {
        	private _mods = configsourcemodlist (configfile >> "CfgPatches" >> _addons select 0);
        	if (count _mods > 0) then {
        		_dlc = _mods select 0;
        	};
        };
        private _dlcParams = modParams [_dlc,["logo","logoOver"]];
        private _logo = _dlcParams param [0,""];
        private _logoOver = _dlcParams param [1,""];
        private _fieldManualTopicAndHint = getarray (configfile >> "cfgMods" >> _dlc >> "fieldManualTopicAndHint");
        _label ctrlseteventhandler ["buttonclick",format ["if (count %1 > 0) then {(%1 + [ctrlparent (_this select 0)]) call bis_fnc_openFieldManual;};",_fieldManualTopicAndHint]];
        private _OriginsText = composeText [
            "",image _logo
        ];
        _label ctrlSetStructuredText _OriginsText;
        _label ctrlCommit 0;
Creates a label with DLC information and field manual integration.

Sqf

Apply
        private _button = _display ctrlCreate ["A3A_ShortcutButton", -1, _itemControlsGroup];
        _button ctrlSetPosition [0, 25 * GRID_H, 44 * GRID_W, 12 * GRID_H];
        _button ctrlSetText _displayName;
        _button ctrlSetTooltip format [localize "STR_antistasi_dialogs_buy_vehicle_button_tooltip", _displayName, _price, A3A_faction_civ get "currencySymbol"];
        _button setVariable ["className", _className];
        _button setVariable ["model", _model];
        _button ctrlAddEventHandler ["ButtonClick", {
            closeDialog 2; [(_this # 0) getVariable "className"] spawn A3A_fnc_addFIAveh;
        }];
        _button ctrlCommit 0;
Creates the vehicle purchase button with tooltip and click handler.

Sqf

Apply
        // Object Render
        if (!_hasVehiclePreview) then {
            _button ctrlAddEventHandler ["MouseEnter", {
                params ["_control"];
                if (true || isNil "Dev_GUI_prevInjectEnter") then {
                    params ["_control"];
                    private _UIScaleAdjustment = (0.55/getResolution#5);  // I tweaked this on UI Small, so that's why the 0.55 is the base size.
                    private _model = _control getVariable "model";
                    private _className = _control getVariable "className";
                    private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;  // 9300;
                    private _objPreview = _display displayCtrl A3A_IDC_BUYOBJECTRENDER;  // 9303;
                    _objPreview ctrlSetModel _model;
                    private _boundingDiameter = [_className] call FUNC(sizeOf);
                    _objPreview ctrlSetModelScale (2.25/(_boundingDiameter) * _UIScaleAdjustment);
                    _objPreview ctrlSetModelDirAndUp [[-0.6283,0.3601,0.6896],[-0.0125,-0.5015,0.8651]];  // x y z

                    private _editorPreviewPicture = ctrlParentControlsGroup _control controlsGroupCtrl A3A_IDC_BUYVEHICLEPREVIEW;  // 9304;

                    private _mouseAbsolutePos = getMousePosition;
                    private _mouseRelativePos = ctrlMousePosition _editorPreviewPicture;
                    _mouseAbsolutePos vectorDiff _mouseRelativePos params ["_objPreview_x", "_objPreview_y"];


                    private _yAdjustment = 0.25 * _UIScaleAdjustment;
                    _objPreview ctrlSetPosition [_objPreview_x + 0.5 * (22 * pixelW * pixelGridNoUIScale), 4, _objPreview_y - 0.5 * (12.5 * pixelW * pixelGridNoUIScale) + _yAdjustment];
                    _editorPreviewPicture ctrlShow false;
                    _editorPreviewPicture ctrlCommit 1;
                    _objPreview ctrlShow true;
                    _objPreview ctrlEnable false;  // Prevent the user dragging it.
                } else {
                    _control call Dev_GUI_prevInjectEnter;
                };
            }];
            _button ctrlAddEventHandler ["MouseExit", {
                params ["_control"];
                if (true || isNil "Dev_GUI_prevInjectExit") then {
                    params ["_control"];
                    private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;  // 9300;
                    private _objPreview = _display displayCtrl A3A_IDC_BUYOBJECTRENDER;  // 9303;

                    private _editorPreviewPicture = ctrlParentControlsGroup _control controlsGroupCtrl A3A_IDC_BUYVEHICLEPREVIEW;  // 9304;

                    _editorPreviewPicture ctrlShow true;
                    _editorPreviewPicture ctrlCommit 1;

                    _objPreview ctrlShow false;
                } else {
                    _control call Dev_GUI_prevInjectExit;
                };
            }];
        };
Handles mouse enter/exit events to show 3D model previews when no preview image exists.

Sqf

Apply
        private _priceText = _display ctrlCreate ["A3A_InfoTextRight", -1, _itemControlsGroup];
        _priceText ctrlSetPosition [23 * GRID_W, 21 * GRID_H, 20 * GRID_W, 3 * GRID_H];
        _priceText ctrlSetText format ["%1 %2",_price, A3A_faction_civ get "currencySymbol"];
        _priceText ctrlCommit 0;
Creates and positions the price text control.

Sqf

Apply
        // Undercover icon
        if (_canGoUndercover) then
        {
            private _undercoverIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _itemControlsGroup];
            _undercoverIcon ctrlSetPosition [1 * GRID_W, 1 * GRID_H, 4 * GRID_W, 4 * GRID_H];
            _undercoverIcon ctrlSetText A3A_Icon_HideVic;
            _underCoverIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_undercover_tooltip";
            _undercoverIcon ctrlCommit 0;
        };
Adds an undercover icon if the vehicle can go undercover.

Sqf

Apply
        // Crew icons and counts
        private _hasGunners = if (_gunners > 0) then {1} else {0}; // Is there a better way to just return all positive numbers as 1?
        private _hasPassengers = if (_passengers > 0) then {1} else {0}; // Too sleepy to think of one right now...
        private _numberOfCrewTypes = (_driver + _commander + _hasGunners + _hasPassengers);
        private _crewCountHeight = _numberOfCrewTypes * 4.5 * GRID_H;
        private _crewCountYpos = 24 * GRID_H - _crewCountHeight;
Calculates crew information and positions for crew icons.

Sqf

Apply
        // Using an inner controlsGroup here so the coordinate calculations don't get completely unreadable
        private _crewControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _itemControlsGroup];
        _crewControlsGroup ctrlSetPosition[1 * GRID_W, _crewCountYpos, 20 * GRID_W, _crewCountHeight];
        _crewControlsGroup ctrlCommit 0;
Creates a controls group for crew information.

Sqf

Apply
        private _crewInfoAdded = 0;
        if (_driver > 0) then
        {
            private _driverIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _crewControlsGroup];
            _driverIcon ctrlSetPosition [0, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
            _driverIcon ctrlSetText A3A_Icon_Driver;
            _driverIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_driver_tooltip";
            _driverIcon ctrlCommit 0;
        };
Creates driver icon if driver is required.

Sqf

Apply
        if (_coPilot > 0) then
        {
            private _coPilotIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _crewControlsGroup];
            _coPilotIcon ctrlSetPosition [5 * GRID_W, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
            _coPilotIcon ctrlSetText A3A_Icon_Driver;
            _coPilotIcon ctrlSetTextColor [0.8,0.8,0.8,1];
            _coPilotIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_copilot_tooltip";
            _coPilotIcon ctrlCommit 0;
        };
Creates copilot icon if copilot is required.

Sqf

Apply
        if (_driver > 0 || _coPilot > 0) then
        {
            _crewInfoAdded = _crewInfoAdded + 1;
        };
Updates crew info counter.

Sqf

Apply
        if (_commander > 0) then
        {
            private _commanderIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _crewControlsGroup];
            _commanderIcon ctrlSetPosition [0, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
            _commanderIcon ctrlSetText A3A_Icon_Commander;
            _commanderIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_commander_tooltip";
            _commanderIcon ctrlCommit 0;

            _crewInfoAdded = _crewInfoAdded + 1;
        };
Creates commander icon if commander is required.

Sqf

Apply
        if (_gunners > 0) then
        {
            private _gunnerIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _crewControlsGroup];
            _gunnerIcon ctrlSetPosition [0, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
            _gunnerIcon ctrlSetText A3A_Icon_Gunner;
            _gunnerIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_gunner_tooltip";
            _gunnerIcon ctrlCommit 0;

            if (_gunners > 1) then
            {
                private _gunnersText = _display ctrlCreate ["A3A_InfoTextLeft", -1, _crewControlsGroup];
                _gunnersText ctrlSetPosition [3 * GRID_W, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
                _gunnersText ctrlSetText str _gunners;
                _gunnersText ctrlCommit 0;
                _gunnerIcon ctrlSetTooltip format[localize "STR_antistasi_dialogs_buy_vehicle_gunner_amount_tooltip", _gunners];
                _gunnerIcon ctrlCommit 0;
            };
            _crewInfoAdded = _crewInfoAdded + 1;
        };
Creates gunner icon(s) with quantity display if gunners are required.

Sqf

Apply
        if (_passengers > 0) then
        {
            private _passengerIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _crewControlsGroup];
            _passengerIcon ctrlSetPosition [0, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
            _passengerIcon ctrlSetText A3A_Icon_Cargo;
            _passengerIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_passenger_tooltip";
            _passengerIcon ctrlCommit 0;

            if (_passengers > 1) then
            {
                private _passengersText = _display ctrlCreate ["A3A_InfoTextLeft", -1, _crewControlsGroup];
                _passengersText ctrlSetPosition [3 * GRID_W, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
                _passengersText ctrlSetText str _passengers;
                _passengersText ctrlCommit 0;
                _passengerIcon ctrlSetTooltip format[localize "STR_antistasi_dialogs_buy_vehicle_passenger_amount_tooltip", _passengers];
                _passengerIcon ctrlCommit 0;
            };
            // _crewInfoAdded placement incremented later
        };
Creates passenger icon(s) with quantity display if passengers are required.

Sqf

Apply
        if (_passengersFFV > 0) then
        {
            private _ffvIcon = _display ctrlCreate ["A3A_PictureStroke", -1, _crewControlsGroup];
            _ffvIcon ctrlSetPosition [7 * GRID_W, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
            _ffvIcon ctrlSetText A3A_Icon_FFV;
            _ffvIcon ctrlSetTextColor [0.8,0.8,0.8,1];
            _ffvIcon ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_ffv_tooltip";
            _ffvIcon ctrlCommit 0;

            if (_passengersFFV > 1) then
            {
                private _ffvText = _display ctrlCreate ["A3A_InfoTextLeft", -1, _crewControlsGroup];
                _ffvText ctrlSetPosition [10 * GRID_W, _crewInfoAdded * 4.5 * GRID_H, 3 * GRID_W, 3 * GRID_H];
                _ffvText ctrlSetText str _passengersFFV;
                _ffvText ctrlSetTextColor [0.8,0.8,0.8,1];
                _ffvText ctrlCommit 0;
                _ffvIcon ctrlSetTooltip format[localize "STR_antistasi_dialogs_buy_vehicle_ffv_amount_tooltip", _passengersFFV];
                _ffvIcon ctrlCommit 0;
            };
                // _crewInfoAdded placement incremented later
        };
Creates FFV icon(s) with quantity display if FFV passengers are required.

Sqf

Apply
        if (_passengers > 0 || _passengersFFV > 0) then
        {
            _crewInfoAdded = _crewInfoAdded + 1;
        };
Updates crew info counter for passengers.

Sqf

Apply
        // Show item
        _itemControlsGroup ctrlSetFade 0;
        _itemControlsGroup ctrlCommit 0.1;

        _added = _added + 1;
    } forEach _buyableVehiclesList;
Shows the item and increments the counter.

Sqf

Apply
    Debug("BuyVehicleTab complete.");
};
Logs completion of the vehicle tab.

Sqf

Apply
if  (_tab in ["other"]) then
{
    Debug("BuyLogisticsTab starting...");
    private _selectedTab = -1;

    if(_tab isEqualTo "other") then
    {
        _selectedTab = A3A_IDC_OTHERGROUP;
    };
Handles the "other" tab case for utility items.

Sqf

Apply
    // Setup Object render
    private _objPreview = _display displayCtrl A3A_IDC_BUYOBJECTRENDER;  // 9303;
    _objPreview ctrlShow false;
Initializes the object preview control.

Sqf

Apply
    private _itemControlsGroup = _display displayCtrl _selectedTab;

    private _added = 0;
    {
        (A3A_utilityItemHM get _x) params [
            ["_className", ""],
            ["_price", 0],
            ["_buttonText", ""],
            ["_iconType", ""],
            ["_flags", []]
        ];
        private _configClass = configFile >> "CfgVehicles" >> _className;
        if (!isClass _configClass) then { continue };
Iterates through utility items, extracting parameters and checking config class.

Sqf

Apply
        private _displayName = if (_buttonText isNotEqualTo "") then {_buttonText} else {getText (_configClass >> "displayName")};
        private _editorPreview = getText (_configClass >> "editorPreview");
        //private _vehicleIcon= getText (_configClass >> "Icon");
        private _model = getText (_configClass >> "model");

        private _hasVehiclePreview = fileExists _editorPreview;
Retrieves display name, preview, and model for utility items.

Sqf

Apply
        // Add some extra padding to the top if there are 2 rows or less
        private _topPadding = if (count A3A_utilityItemList < 7) then {5 * GRID_H} else {0};

        private _itemXpos = 7 * GRID_W + ((7 * GRID_W + 44 * GRID_W) * (_added mod 3));
        private _itemYpos = (floor (_added / 3)) * (44 * GRID_H) + _topPadding;

        private _itemControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _itemControlsGroup];
        _itemControlsGroup ctrlSetPosition[_itemXpos, _itemYpos, 44 * GRID_W, 37 * GRID_H];
        _itemControlsGroup ctrlSetFade 1;
        _itemControlsGroup ctrlCommit 0;
Creates item controls group for utility items.

Sqf

Apply
        private _previewPicture = _display ctrlCreate ["A3A_Picture", A3A_IDC_BUYVEHICLEPREVIEW, _itemControlsGroup];
        _previewPicture ctrlSetPosition [0, 0, 44 * GRID_W, 25 * GRID_H];
        _previewPicture ctrlSetText _editorPreview;
        _previewPicture ctrlCommit 0;
Creates preview picture for utility items.

Sqf

Apply
        private _button = _display ctrlCreate ["A3A_ShortcutButton", -1, _itemControlsGroup];
        _button ctrlSetPosition [0, 25 * GRID_H, 44 * GRID_W, 12 * GRID_H];
        _button ctrlSetText _displayName;
        _button ctrlSetTooltip format [localize "STR_antistasi_dialogs_buy_item_tooltip", _displayName, _price, A3A_faction_civ get "currencySymbol"];
        _button setVariable ["className", _className];
        _button setVariable ["model", _model];

        switch (true) do {
            case (_className isEqualTo (A3A_faction_reb get "lootCrate")): {
                _button ctrlAddEventHandler ["ButtonClick", {
                    closeDialog 2; 
                    [] call SCRT_fnc_loot_createLootCrate;
                }];
            };
            default {
                _button ctrlAddEventHandler ["ButtonClick", { 
                    closeDialog 2; 
                    [player, _this#0 getVariable "className"] call A3A_fnc_buyItem 
                }];
            };
        };

        _button ctrlAddEventHandler ["ButtonClick", { closeDialog 2; [player, _this#0 getVariable "className"] call A3A_fnc_buyItem }];
        _button ctrlCommit 0;
Creates purchase button for utility items with special handling for loot crates.

Sqf

Apply
        // Object Render
        if (!_hasVehiclePreview) then {
            _button ctrlAddEventHandler ["MouseEnter", {
                params ["_control"];

                if (true || isNil "Dev_GUI_prevInjectEnter") then {
                    params ["_control"];
                    private _UIScaleAdjustment = (0.55/getResolution#5);  // I tweaked this on UI Small, so that's why the 0.55 is the base size.

                    private _model = _control getVariable "model";
                    private _className = _control getVariable "className";
                    private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;  // 9300;
                    private _objPreview = _display displayCtrl A3A_IDC_BUYOBJECTRENDER;  // 9303;
                    _objPreview ctrlSetModel _model;
                    private _boundingDiameter = [_className] call FUNC(sizeOf);
                    _objPreview ctrlSetModelScale (2.25/(_boundingDiameter) * _UIScaleAdjustment);
                    _objPreview ctrlSetModelDirAndUp [[-0.6283,0.3601,0.6896],[-0.0125,-0.5015,0.8651]];  // x y z
                    private _editorPreviewPicture = ctrlParentControlsGroup _control controlsGroupCtrl A3A_IDC_BUYVEHICLEPREVIEW;  // 9304;
                    private _mouseAbsolutePos = getMousePosition;
                    private _mouseRelativePos = ctrlMousePosition _editorPreviewPicture;
                    _mouseAbsolutePos vectorDiff _mouseRelativePos params ["_objPreview_x", "_objPreview_y"];


                    private _yAdjustment = 0.25 * _UIScaleAdjustment;
                    _objPreview ctrlSetPosition [_objPreview_x + 0.5 * (22 * pixelW * pixelGridNoUIScale), 4, _objPreview_y - 0.5 * (12.5 * pixelW * pixelGridNoUIScale) + _yAdjustment];
                    _editorPreviewPicture ctrlShow false;
                    _editorPreviewPicture ctrlCommit 1;
                    _objPreview ctrlShow true;
                    _objPreview ctrlEnable false;  // Prevent the user dragging it.
                } else {
                    _control call Dev_GUI_prevInjectEnter;
                };
            }];
            _button ctrlAddEventHandler ["MouseExit", {
                params ["_control"];
                if (true || isNil "Dev_GUI_prevInjectExit") then {
                    params ["_control"];
                    private _display = findDisplay A3A_IDD_BUYVEHICLEDIALOG;  // 9300;
                    private _objPreview = _display displayCtrl A3A_IDC_BUYOBJECTRENDER;  // 9303;

                    private _editorPreviewPicture = ctrlParentControlsGroup _control controlsGroupCtrl A3A_IDC_BUYVEHICLEPREVIEW;  // 9304;

                    _editorPreviewPicture ctrlShow true;
                    _editorPreviewPicture ctrlCommit 1;

                    _objPreview ctrlShow false;
                } else {
                    _control call Dev_GUI_prevInjectExit;
                };
            }];
        };
Handles mouse enter/exit events for 3D model previews for utility items.

Sqf

Apply
        private _priceText = _display ctrlCreate ["A3A_InfoTextRight", -1, _itemControlsGroup];
        _priceText ctrlSetPosition[23 * GRID_W, 21 * GRID_H, 20 * GRID_W, 3 * GRID_H];
        _priceText ctrlSetText format ["%1 %2",_price, A3A_faction_civ get "currencySymbol"];
        _priceText ctrlCommit 0;

        private _itemPic = _display ctrlCreate ["A3A_PictureStroke", -1, _itemControlsGroup];
        _itemPic ctrlSetPosition [1 * GRID_W, 1 * GRID_H, 3 * GRID_W, 3 * GRID_H];
        private _iconPath = switch (_iconType) do {
            case "light": { A3A_Icon_Light };
            case "revivebox": { A3A_Icon_HealKit };
            case "lootbox": { A3A_Icon_Box };
            case "gear": { A3A_Icon_Gear };
            case "heal": { A3A_Icon_Heal };
            case "refuel": { A3A_Icon_Refuel }; 
            case "repair": { A3A_Icon_Repair };
            case "rearm": { A3A_Icon_Rearm };
            default { "" };
        };
        _itemPic ctrlSetText _iconPath;

        if (_className in [(A3A_faction_reb get 'vehicleFuelTank')#0, (A3A_faction_reb get 'vehicleFuelDrum')#0]) then {
            private _refuelCount = if (A3A_hasACE) then {getNumber (_configClass >> "ace_refuel_fuelCargo")} else {getNumber (_configClass >> "transportFuel")};
            _itemPic ctrlSetTooltip format [localize "STR_antistasi_dialogs_buy_vehicle_refuel_tooltip", _displayName, _refuelCount];
        };
        if (_className in [(A3A_faction_reb get 'vehicleMedicalBox')#0, (A3A_faction_reb get 'vehicleHealthStation')#0]) then {
            _itemPic ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_med_tooltip";
        };
        if (_className isEqualTo (FactionGet(reb,"vehicleAmmoStation")#0)) then {
            _itemPic ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_ammo_tooltip";
        };
        if (_className isEqualTo (A3A_faction_reb get 'vehicleRepairStation')#0)) then {
            _itemPic ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_repair_tooltip";
        };
        if (_className isEqualTo (A3A_faction_reb get 'lootCrate')) then
        {
            _itemPic ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_loot_tooltip";
        };
        if (_className isEqualTo (A3A_faction_reb get 'vehicleLightSource')) then
        {
            _itemPic ctrlSetTooltip localize "STR_antistasi_dialogs_buy_vehicle_light_tooltip";
        };
        _itemPic ctrlCommit 0;
Creates item icon with appropriate tooltips based on item type.

Sqf

Apply
        // Show item
        _itemControlsGroup ctrlSetFade 0;
        _itemControlsGroup ctrlCommit 0.1;

        _added = _added + 1;
    } forEach A3A_utilityItemList;
Shows the item and increments the counter.

Sqf

Apply
    Debug("BuyLogisticsTab complete.");
};
Logs completion of the logistics tab.

Where it leads:
This function calls SCRT_fnc_ui_populateVehicleBox to get vehicle lists, A3A_fnc_getVehicleCrewCount to get crew information, A3A_fnc_addFIAveh for vehicle purchases, and A3A_fnc_buyItem for utility purchases. It also calls FUNC(sizeOf) for 3D model sizing.

Requirements:
Requires SCRT_fnc_ui_populateVehicleBox function to be available
Requires A3A_fnc_getVehicleCrewCount function to be available
Requires A3A_fnc_addFIAveh function to be available
Requires A3A_fnc_buyItem function to be available
Requires FUNC(sizeOf) function to be available
Uses global variables like A3A_IDD_BUYVEHICLEDIALOG, A3A_IDC_BUYOBJECTRENDER, etc.
Uses localization strings for tooltips and labels
Uses A3A_utilityItemHM and A3A_utilityItemList global variables
Function Name: fn_commanderTab.sqf
What it does:
Handles updating and controls on the Commander tab of the Main dialog. This function manages the display of group information, fire missions, and various commander actions like air support and garbage cleanup.

How it does that:
The function operates as a switch statement handling different modes: "update", "updateSingleGroupView", "updateMultipleGroupsView", "updateFireMissionView", "commanderMapClicked", "groupNameLabelClicked", "groupRemoteControlButtonClicked", "groupDismissButtonClicked", "groupFastTravelButtonClicked", "fireMissionSelectionChanged", "fireMissionButtonClicked", "showGarbageCleanOptions", and "garbageCleanMapButtonClicked". It manages UI updates, group selection, fire mission setup, and various commander actions.

Implementation:
Sqf

Apply
params[["_mode","update"], ["_params",[]]];
Initializes parameters with default mode "update" and empty params array.

Sqf

Apply
// Get display and common controls
private _display = findDisplay A3A_IDD_MAINDIALOG;
private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
private _multipleGroupsView = _display displayCtrl A3A_IDC_HCMULTIPLEGROUPSVIEW;
private _multipleGroupsBackground = _display displayCtrl A3A_IDC_HCMULTIPLEGROUPSBACKGROUND;
private _multipleGroupsLabel = _display displayCtrl A3A_IDC_HCMULTIPLEGROUPSLABEL;
private _singleGroupView = _display displayCtrl A3A_IDC_HCSINGLEGROUPVIEW;
private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;
private _noRadioControlsGroup = _display displayCtrl A3A_IDC_NORADIOCONTROLSGROUP;
private _garbageCleanControlsGroup = _display displayCtrl A3A_IDC_GARBAGECLEANCONTROLSGROUP;
private _airSupportButton = _display displayCtrl A3A_IDC_AIRSUPPORTBUTTON;
private _garbageCleanButton = _display displayCtrl A3A_IDC_GARBAGECLEANBUTTON;
Retrieves all necessary display controls for the commander tab.

Sqf

Apply
switch (_mode) do
{
    case ("update"):
    {
        Trace("Updating Commander tab");

        // Show map if not already visible
        if (!ctrlShown _commanderMap) then {_commanderMap ctrlShow true;};
Handles the update mode by showing the map and initializing UI elements.

Sqf

Apply
        // Hide all views initially
        _multipleGroupsView ctrlShow false;
        _multipleGroupsBackground ctrlShow false;
        _multipleGroupsLabel ctrlShow false;
        _singleGroupView ctrlShow false;
        _fireMissionControlsGroup ctrlShow false;
        _noRadioControlsGroup ctrlShow false;
        _garbageCleanControlsGroup ctrlShow false;
Hides all views initially.

Sqf

Apply
        // Show Air Support and Garbage Clean buttons
        _airSupportButton ctrlShow true;
        _garbageCleanButton ctrlShow true;
Shows the air support and garbage clean buttons.

Sqf

Apply
        // Check for radio, most of this isn't usable without one
        if !([player] call A3A_fnc_hasRadio) exitWith
        {
            _noRadioControlsGroup ctrlShow true;
            _airSupportButton ctrlEnable false;
            _airSupportButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_commander_no_radio";
        };
Checks for radio and disables air support if none is available.

Sqf

Apply
        // Initialize fire mission vars
        _fireMissionControlsGroup setVariable ["heSelected", true];
        _fireMissionControlsGroup setVariable ["pointSelected", true];
        _fireMissionControlsGroup setVariable ["roundsNumber", 1];
        _fireMissionControlsGroup setVariable ["availableHeRounds", 0];
        _fireMissionControlsGroup setVariable ["availableSmokeRounds", 0];
        _fireMissionControlsGroup setVariable ["startPos", nil];
        _fireMissionControlsGroup setVariable ["endPos", nil];

        // Set map to group selection mode
        _commanderMap setVariable ["selectFireMissionPos", false];
        _commanderMap setVariable ["selectFireMissionEndPos", false];
Initializes fire mission variables and map selection modes.

Sqf

Apply
        // Check for selected groups
        private _selectedGroup = _commanderMap getVariable ["selectedGroup", grpNull];
        if !(_selectedGroup isEqualTo grpNull) then
        {
            // If a group is selected show the single group view
            ["updateSingleGroupView"] call A3A_fnc_commanderTab;
        } else {
            // If no group is selected show the multiple groups view
            ["updateMultipleGroupsView"] call A3A_fnc_commanderTab;
        };
Determines whether to show single group or multiple groups view based on selection.

Sqf

Apply
    case ("updateSingleGroupView"):
    {
        _multipleGroupsView ctrlShow false;
        _multipleGroupsBackground ctrlShow false;
        _multipleGroupsLabel ctrlShow false;
        _singleGroupView ctrlShow true;

        // Hide fire mission button initially
        private _fireMissionButton = _display displayCtrl A3A_IDC_HCFIREMISSIONBUTTON;
        _fireMissionButton ctrlShow false;
Handles the single group view update by showing the single group view and hiding fire mission button.

Sqf

Apply
        private _groupInfo = [_selectedGroup] call A3A_fnc_getGroupInfo;
        _groupInfo params [
            "_group",
            "_groupID",
            "_groupLeader",
            "_units",
            "_aliveUnits",
            "_ableToCombat",
            "_task",
            "_combatMode",
            "_hasOperativeMedic",
            "_hasAt",
            "_hasAa",
            "_hasMortar",
            "_mortarDeployed",
            "_hasStatic",
            "_staticDeployed",
            "_groupVehicle",
            "_groupIcon",
            "_groupIconColor"
        ];
Retrieves group information using A3A_fnc_getGroupInfo.

Sqf

Apply
        private _position = getPos leader _group;

        // Update select marker
        _commanderMap setVariable ["selectMarkerData", [_position]];
Updates the map marker for the selected group.

Sqf

Apply
        // Update controls
        private _groupNameText = _display displayCtrl A3A_IDC_HCGROUPNAME;
        _groupNameText ctrlSetText _groupID;

        private _groupFastTravelButton = _display displayCtrl A3A_IDC_HCFASTTRAVELBUTTON;
        private _canFastTravel = [_group] call A3A_fnc_canFastTravel;
        if (_canFastTravel # 0) then {
            _groupFastTravelButton ctrlEnable true;
            // ShortcutButtons doesn't change texture color when disabled so we have to use fade
            _groupFastTravelButton ctrlSetFade 0;
            _groupFastTravelButton ctrlCommit 0;
            _groupFastTravelButton ctrlSetTooltip ""; // TODO: descriptive tooltip?
        } else {
            _groupFastTravelButton ctrlEnable false;
            // ShortcutButtons doesn't change texture color when disabled so we have to use fade
            _groupFastTravelButton ctrlSetFade 0.5;
            _groupFastTravelButton ctrlCommit 0;
            _groupFastTravelButton ctrlSetTooltip (_canFastTravel # 1);
        };
Updates group name and fast travel button based on group status.

Sqf

Apply
        private _groupCountText = _display displayCtrl A3A_IDC_HCGROUPCOUNT;
        _groupCountText ctrlSetText format ["%1 / %2", _ableToCombat, _aliveUnits];
Updates group count text.

Sqf

Apply
        // Delete any previous status icons
        private _iconsControlsGroup = _display displayCtrl A3A_IDC_HCGROUPSTATUSICONS;
        {
            ctrlDelete _x;
        } forEach allControls _iconsControlsGroup;
Deletes previous status icons.

Sqf

Apply
        // Get the status icons to display
        private _statusIcons = [];
        if _hasOperativeMedic then {_statusIcons pushBack "medic"};
        if _hasAt then {_statusIcons pushBack "at"};
        if _hasAa then {_statusIcons pushBack "aa"};
        if _hasMortar then {
            if _mortarDeployed then {
                _statusIcons pushBack "mortarDeployed";

                // also show fire mission button
                _fireMissionButton ctrlShow true;
            } else {
                _statusIcons pushBack "mortar";

                // show fire mission button, disable and show tooltip
                _fireMissionButton ctrlShow true;
                _fireMissionButton ctrlEnable false;
                _fireMissionButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_hc_fire_mission_not_deployed_tooltip";
            };
        };
        if _hasStatic then {
                if _staticDeployed then {
                _statusIcons pushBack "staticDeployed";
            } else {
                _statusIcons pushBack "static";
            };
        };
Determines which status icons to display based on group capabilities.

Sqf

Apply
        // Create icons, right justified
        {
            private _iconXpos = (30 * GRID_W) - ((count _statusIcons) * 5 * GRID_W) + (_forEachIndex * 5 * GRID_W);
            private _iconPath = "";
            private _toolTipText = "";
            private _iconFade = 0;
            switch (_x) do {
                case ("medic"): {
                    _iconPath = A3A_Icon_Heal;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_medic";
                };

                case ("at"): {
                    _iconPath = A3A_Icon_Has_AT;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_at";
                };

                case ("aa"): {
                    _iconPath = A3A_Icon_Has_AA;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_aa";
                };

                case ("mortarDeployed"): {
                    _iconPath = A3A_Icon_Has_Mortar;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_mortar_deployed";
                };

                case ("mortar"): {
                    _iconPath = A3A_Icon_Has_Mortar;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_mortar_not_deployed";
                    _iconFade = 0.25;
                };

                case ("staticDeployed"): {
                    _iconPath = A3A_Icon_Has_Static;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_static_weapon_deployed";
                };

                case ("static"): {
                    _iconPath = A3A_Icon_Has_Static;
                    _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_static_weapon_not_deployed";
                    _iconFade = 0.25;
                };
            };

            private _icon = _display ctrlCreate ["A3A_Picture", -1, _iconsControlsGroup];
            _icon ctrlSetPosition [_iconXpos, 0, 4 * GRID_W, 4 * GRID_H];
            _icon ctrlSetText _iconPath;
            _icon ctrlSetTooltip _toolTipText;
            _icon ctrlSetFade _iconFade;
            _icon ctrlCommit 0;
        } forEach _statusIcons;
Creates status icons with appropriate tooltips and positioning.

Sqf

Apply
        private _groupCombatModeText = _display displayCtrl A3A_IDC_HCGROUPCOMBATMODE;
        _groupCombatModeText ctrlSetText _combatMode;

        private _groupVehicleText = _display displayCtrl A3A_IDC_HCGROUPVEHICLE;
        _groupVehicleText ctrlSetStructuredText parseText "<t align='right'>Super long vehicle name bla bla</t>"; // TODO UI-update: Update with actual vehicle name

        // Pan to group location
        _commanderMap ctrlMapAnimAdd [0.2, ctrlMapScale _commanderMap, getPos _groupLeader];
        ctrlMapAnimCommit _commanderMap;
Updates combat mode and vehicle text, then pans the map to the group location.

Sqf

Apply
    case ("updateMultipleGroupsView"):
    {
        _singleGroupView ctrlShow false;
        _multipleGroupsView ctrlShow true;
        _multipleGroupsBackground ctrlShow true;
        _multipleGroupsLabel ctrlShow true;

        // Get data
        private _hcGroupData = _commanderMap getVariable "hcGroupData";
Handles the multiple groups view update by showing multiple groups view.

Sqf

Apply
        // Generate list of groups.。。

        // Clear controlsGroup first
        {
            ctrlDelete _x;
        } forEach allControls _multipleGroupsView;
Clears existing controls before generating new ones.

Sqf

Apply
        {
            // Get group info
            _x params [
                "_group",
                "_groupID",
                "_groupLeader",
                "_units",
                "_aliveUnits",
                "_ableToCombat",
                "_task",
                "_combatMode",
                "_hasOperativeMedic",
                "_hasAt",
                "_hasAa",
                "_hasMortar",
                "_mortarDeployed",
                "_hasStatic",
                "_staticDeployed",
                "_groupVehicle",
                "_groupIcon",
                "_groupIconColor"
            ];

            private _position = getPos leader _group;

            // Hide select marker
            _commanderMap setVariable ["selectMarkerData", []];

            // Set up controls
            private _itemYpos = 16 * _forEachIndex * GRID_H;
            private _itemControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _multipleGroupsView];
            _itemControlsGroup ctrlSetPosition [0, _itemYpos, 54 * GRID_W, 14 * GRID_H];
            _itemControlsGroup ctrlCommit 0;

            // Background
            _groupCountIcon ctrlSetPosition [2 * GRID_W, 8 * GRID_H, 4 * GRID_W, 4 * GRID_H];
            _groupCountIcon ctrlSetText A3A_Icon_GroupUnitCount;
            _groupCountIcon ctrlSetTooltip localize "STR_antistasi_dialogs_main_hc_unit_count_tooltip";
            _groupCountIcon ctrlCommit 0;

            private _groupCountText = _display ctrlCreate ["A3A_Text", -1, _itemControlsGroup];
            _groupCountText ctrlSetPosition [6 * GRID_W, 8 * GRID_H, 16 * GRID_W, 4 * GRID_H];
            _groupCountText ctrlSetText format["%1 / %2", _aliveUnits, count _units];
            _groupCountText ctrlSetTooltip localize "STR_antistasi_dialogs_main_hc_unit_count_tooltip";
            _groupCountText ctrlCommit 0;

            // Subgroup for status icons
            private _iconsControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _itemControlsGroup];
            _iconsControlsGroup ctrlSetPosition [22 * GRID_W, 8 * GRID_H, 30 * GRID_W, 6 * GRID_H];
            _iconsControlsGroup ctrlCommit 0;

            // Get the status icons to display
            private _statusIcons = [];
            if _hasOperativeMedic then {_statusIcons pushBack "medic"};
            if _hasAt then {_statusIcons pushBack "at"};
            if _hasAa then {_statusIcons pushBack "aa"};
            if _hasMortar then {
                if _mortarDeployed then {
                    _statusIcons pushBack "mortarDeployed";
                } else {
                    _statusIcons pushBack "mortar";
                };
            };
            if _hasStatic then {
                if _staticDeployed then {
                    _statusIcons pushBack "staticDeployed";
                } else {
                    _statusIcons pushBack "static";
                };
            };

            // Create icons, right justified
            {
                private _iconXpos = (30 * GRID_W) - ((count _statusIcons) * 5 * GRID_W) + (_forEachIndex * 5 * GRID_W);
                private _iconPath = "";
                private _toolTipText = "";
                switch (_x) do {
                    case ("medic"): {
                        _iconPath = "\A3\ui_f\data\igui\cfg\actions\heal_ca.paa";
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_medic";
                    };

                    case ("at"): {
                        _iconPath = A3A_Icon_Has_AT;
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_at";
                    };

                    case ("aa"): {
                        _iconPath = A3A_Icon_Has_AA;
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_aa";
                    };

                    case ("mortarDeployed"): {
                        _iconPath = A3A_Icon_Has_Mortar;
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_mortar_deployed";
                    };

                    case ("mortar"): {
                        _iconPath = A3A_Icon_Has_Mortar;
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_mortar_not_deployed";
                    };

                    case ("staticDeployed"): {
                        _iconPath = A3A_Icon_Has_Static;
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_static_weapon_deployed";
                    };

                    case ("static"): {
                        _iconPath = A3A_Icon_Has_Static;
                        _toolTipText = localize "STR_antistasi_dialogs_main_hc_has_static_weapon_not_deployed";
                    };
                };

                private _icon = _display ctrlCreate ["A3A_Picture", -1, _iconsControlsGroup];
                _icon ctrlSetPosition [_iconXpos, 0, 4 * GRID_W, 4 * GRID_H];
                _icon ctrlSetText _iconPath;
                _icon ctrlSetTooltip _toolTipText;
                _icon ctrlCommit 0;
            } forEach _statusIcons;

        } forEach _hcGroupData;

        // If no high command groups show how to get them
        if (count _hcGroupData < 1) then
        {
            private _noHcGroupsText = _display ctrlCreate ["A3A_StructuredText", -1, _multipleGroupsView];
            _noHcGroupsText ctrlSetPosition [0, 10 * GRID_H, 54 * GRID_W, 14 * GRID_H];
            _noHcGroupsText ctrlSetStructuredText parseText localize "STR_antistasi_dialogs_main_hc_no_groups";
            _noHcGroupsText ctrlCommit 0;
        };
Creates controls for each group in the multiple groups view with status icons and information.

Sqf

Apply
    case ("updateFireMissionView"):
    {
        Trace("Updating Fire Mission View");
        private _display = findDisplay A3A_IDD_MAINDIALOG;

        // Hide group views
        private _multipleGroupsView = _display displayCtrl A3A_IDC_HCMULTIPLEGROUPSVIEW;
        private _singleGroupView = _display displayCtrl A3A_IDC_HCSINGLEGROUPVIEW;
        _multipleGroupsView ctrlShow false;
        _singleGroupView ctrlShow false;

        // Show fire mission view if not already shown
        private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;
        if !(ctrlShown _fireMissionControlsGroup) then {
            _fireMissionControlsGroup ctrlShow true;
        };
Handles the fire mission view update by showing the fire mission controls.

Sqf

Apply
        // Update rounds count
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        private _group = _commanderMap getVariable ["selectedGroup", grpNull];
        private _units = units _group;

        SDKMortarHEMag;
        SDKMortarSmokeMag;

        private _heRoundsCount = 0;
        private _smokeRoundsCount = 0;

        private _checkedVehicles = [];

        {
            private _veh = vehicle _x;
            if ((_veh != _x) and (not(_veh in _checkedVehicles))) then
            {
                if (( "Artillery" in (getArray (configfile >> "CfgVehicles" >> typeOf _veh >> "availableForSupportTypes")))) then
                {
                    if ((canFire _veh) and (alive _veh)) then
                    {
                        {
                            if (_x # 0 == SDKMortarHEMag) then
                            {
                                _heRoundsCount = _heRoundsCount + _x # 1;
                            };

                            if (_x # 0 == SDKMortarSmokeMag) then
                            {
                                _smokeRoundsCount = _smokeRoundsCount + _x # 1;
                            };
                        } forEach magazinesAmmo _veh;

                        _checkedVehicles pushBack _veh;
                    };
                };
            };
        } forEach _units;
Calculates available rounds for HE and smoke munitions.

Sqf

Apply
        _fireMissionControlsGroup setVariable ["availableHeRounds", _heRoundsCount];
        _fireMissionControlsGroup setVariable ["availableSmokeRounds", _smokeRoundsCount];

        private _heRoundsText = _display displayCtrl A3A_IDC_HEROUNDSTEXT;
        private _smokeRoundsText = _display displayCtrl A3A_IDC_SMOKEROUNDSTEXT;

        _heRoundsText ctrlSetText str _heRoundsCount;
        _smokeRoundsText ctrlSetText str _smokeRoundsCount;
Updates the rounds count text fields.

Sqf

Apply
        // States for selecting shell type, mission type and round counts are initialized
        // in update, we get them here
        private _heShell = _fireMissionControlsGroup getVariable ["heSelected", true];
        private _pointStrike = _fireMissionControlsGroup getVariable ["pointSelected", true];
        private _roundsCount = _fireMissionControlsGroup getVariable ["roundsNumber", 1];
        private _startPos = _fireMissionControlsGroup getVariable ["startPos", nil];
        private _endPos = _fireMissionControlsGroup getVariable ["endPos", nil];
Retrieves current fire mission settings.

Sqf

Apply
        // Update controls based on what is selected
        private _heButton = _display displayCtrl A3A_IDC_HEBUTTON;
        private _smokeButton = _display displayCtrl A3A_IDC_SMOKEBUTTON;
        private _pointStrikeButton = _display displayCtrl A3A_IDC_POINTSTRIKEBUTTON;
        private _barrageButton = _display displayCtrl A3A_IDC_BARRAGEBUTTON;
        private _roundsControlsGroup = _display displayCtrl A3A_IDC_ROUNDSCONTROLSGROUP;
        private _roundsEditBox = _display displayCtrl A3A_IDC_ROUNDSEDITBOX;
        private _addRoundsButton = _display displayCtrl A3A_IDC_ADDROUNDSBUTTON;
        private _subRoundsButton = _display displayCtrl A3A_IDC_SUBROUNDSBUTTON;

        private _startPosControlsGroup = _display displayCtrl A3A_IDC_STARTPOSITIONCONTROLSGROUP;
        private _startPosLabel = _display displayCtrl A3A_IDC_STARTPOSITIONLABEL;
        private _startPosEditBox = _display displayCtrl A3A_IDC_STARTPOSITIONEDITBOX;

        private _endPosControlsGroup = _display displayCtrl A3A_IDC_ENDPOSITIONCONTROLSGROUP;
        private _endPosLabel = _display displayCtrl A3A_IDC_ENDPOSITIONLABEL;
        private _endPosEditBox = _display displayCtrl A3A_IDC_ENDPOSITIONEDITBOX;

        private _fireButton = _display displayCtrl A3A_IDC_FIREBUTTON;

        // Disable fire button initially
        _fireButton ctrlEnable false;

        if (_heShell) then
        {
            // HE
            _heButton ctrlEnable false;
            _smokeButton ctrlEnable true;

        } else {
            // Smoke
            _smokeButton ctrlEnable false;
            _heButton ctrlEnable true;
        };

        if (_pointStrike) then
        {
            // Point strike

            _pointStrikeButton ctrlEnable false;
            _barrageButton ctrlEnable true;

            // Change text on start position label
            _startPosLabel ctrlSetText localize "STR_antistasi_dialogs_main_hc_fire_mission_position_label";

            // Hide endPos controlsGroup
            _endPosControlsGroup ctrlShow false;

            // Enable rounds buttons, remove tooltips
            _addRoundsButton ctrlEnable true;
            _addRoundsButton ctrlSetTooltip "";
            _subRoundsButton ctrlEnable true;
            _subRoundsButton ctrlSetTooltip "";
            _roundsEditBox ctrlSetTooltip "";


        } else {
            // Barrage

            _barrageButton ctrlEnable false;
            _pointStrikeButton ctrlEnable true;

            // Show endPos controlsGroup
            _endPosControlsGroup ctrlShow true;

            // Change text on start position label
            _startPosLabel ctrlSetText localize "STR_antistasi_dialogs_main_hc_fire_mission_position_start_label";

            // Disable rounds buttons and editBox, show tooltip
            _tooltipText = localize "STR_antistasi_dialogs_main_hc_fire_mission_rounds_barrage_tooltip";
            _addRoundsButton ctrlEnable false;
            _addRoundsButton ctrlSetTooltip _tooltipText;
            _subRoundsButton ctrlEnable false;
            _subRoundsButton ctrlSetTooltip _tooltipText;
            _roundsEditBox ctrlSetTooltip _tooltipText;

            // If mission type is barrage and both positions are set, calculate number of rounds
            // One round per 10m
            // _rounds = round (_positionTel distance _positionTel2) / 10; // <- from Antistasi
            if (!isNil "_startPos" && !isNil "_endPos") then
            {
                _roundsCount = round ((_startPos distance _endPos) / 10);
            };
        };

        _roundsEditBox ctrlSetText str _roundsCount;
Updates UI controls based on fire mission settings.

Sqf

Apply
        // Update position editBoxes
        Trace("Updating fire mission position edit box...");
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        _selectFireMissionPos = _commanderMap getVariable ["selectFireMissionPos", false];
        _selectFireMissionEndPos = _commanderMap getVariable ["selectFireMissionEndPos", false];

        // Start pos
        switch (true) do
        {
            // Selecting position on map
            case (_selectFireMissionPos):
            {
                _startPosEditBox ctrlSetText localize "STR_antistasi_dialogs_main_hc_fire_mission_click_map";
            };

            // Position is already set
            case (!isNil "_startPos"):
            {
                private _gridPos = mapGridPosition _startPos;
                _startPosEditBox ctrlSetText _gridPos;
            };

            // No position set
            default
            {
                _startPosEditBox ctrlSetText localize "STR_antistasi_dialogs_main_hc_fire_mission_not_set";
            };
        };

        // End pos
        switch (true) do
        {
            case (_selectFireMissionEndPos):
            {
                _endPosEditBox ctrlSetText localize "STR_antistasi_dialogs_main_hc_fire_mission_click_map";
            };

            case (!isNil "_endPos"):
            {
                private _gridPos = mapGridPosition _endPos;
                _endPosEditBox ctrlSetText _gridPos;
            };

            default
            {
                _endPosEditBox ctrlSetText localize "STR_antistasi_dialogs_main_hc_fire_mission_not_set";
            };
        };

        // Add tooltip to fire button when unable to fire
        private _firebuttonTooltipText = "";
        private _availableRounds = [_smokeRoundsCount, _heRoundsCount] select _heShell;
        switch (true) do
        {
            case (isNil "_startPos" || (!_pointStrike && isNil "_endPos")):
            {
                _firebuttonTooltipText = _firebuttonTooltipText + localize "STR_antistasi_dialogs_main_hc_fire_mission_position_not_set_tooltip" + "\n"
            };
            case (_roundsCount > _availableRounds):
            {
                _firebuttonTooltipText = _firebuttonTooltipText + localize "STR_antistasi_dialogs_main_hc_fire_misison_no_ammo_tooltip" + "\n"
            };
        };

        _fireButton ctrlSetTooltip _firebuttonTooltipText;

        // Enable fire button when able to fire
        if (_firebuttonTooltipText isEqualTo "") then
        {
            _fireButton ctrlEnable true;
        };
Updates position edit boxes and fire button state based on current settings.

Sqf

Apply
    case ("commanderMapClicked"):
    {
        Trace("Commander map clicked");
        // Get display and map control
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        _params params ["_clickedPosition"];
        private _clickedWorldPosition = _commanderMap ctrlMapScreenToWorld _clickedPosition;

        // Special cases for selecting fire mission position(s)
        private _selectFireMissionPos = _commanderMap getVariable ["selectFireMissionPos", false];
        if (_selectFireMissionPos) exitWith
        {
            Trace("Selecting fire mission position");
            private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;
            _fireMissionControlsGroup setVariable ["startPos", _clickedWorldPosition];
            _commanderMap setVariable ["selectFireMissionPos", false];
            ["updateFireMissionView"] call A3A_fnc_commanderTab;
            Trace_1("Set fire mission startPos: %1", _clickedWorldPosition);
        };

        private _selectFireMissionEndPos = _commanderMap getVariable ["selectFireMissionEndPos", false];
        if (_selectFireMissionEndPos) exitWith
        {
            Trace("Selecting fire mission end position");
            private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;
            _fireMissionControlsGroup setVariable ["endPos", _clickedWorldPosition];
            _commanderMap setVariable ["selectFireMissionEndPos", false];
            ["updateFireMissionView"] call A3A_fnc_commanderTab;
            Trace_1("Set fire mission endPos: %1", _clickedWorldPosition);
        };

        if (count hcAllGroups player < 1) exitWith {
            Debug("CommanderMap clicked but there are no HC groups to select.");
            _commanderMap setVariable ["selectedGroup", grpNull];
        };

        // Find closest HC squad to the clicked position
        Trace("Selecting HC group");
        private _selectedGroup = [hcAllGroups player, _clickedWorldPosition] call BIS_fnc_nearestPosition;
        Trace_1("_selectedGroup: %1", groupId _selectedGroup);
        private _selectedGroupMapPos = _commanderMap ctrlMapScreenToWorld getPos leader _selectedGroup;
        private _maxDistance = 6 * GRID_W; // TODO UI-update: Move somewhere else?
        private _distance = _selectedGroupMapPos distance _clickedPosition;
        Trace_4("_selectedGroupMapPos %1, _clickedPosition %2, _maxDistance %3, _distance %4", _selectedGroupMapPos, _clickedPosition, _maxDistance, _distance);

        // If clicked position is nowhere near any hc groups, deselect all units
        // and show list view
        if (_distance > _maxDistance) exitWith {
            Debug("Distance too large, deselecting group");
            _commanderMap setVariable ["selectedGroup", grpNull];
            ["update"] call A3A_fnc_commanderTab;
        };

        _commanderMap setVariable ["selectedGroup", _selectedGroup];

        // Update single group view
        ["update"] call A3A_fnc_commanderTab;
    };
Handles commander map clicks for position selection and group selection.

Sqf

Apply
    case ("groupNameLabelClicked"):
    {
        // This is here to prevent hardcoded IDCs in the configs
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        _commanderMap setVariable ["selectedGroup", grpNull];
        ["update"] call A3A_fnc_commanderTab;
    };
Handles clicking on group name labels to deselect groups.

Sqf

Apply
    case ("groupRemoteControlButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        private _group = _commanderMap getVariable ["selectedGroup", grpNull];
        closeDialog 1;
        [_group] spawn A3A_fnc_controlHCsquad;
    };
Handles remote control button click to control selected squad.

Sqf

Apply
    case ("groupDismissButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        private _group = _commanderMap getVariable ["selectedGroup", grpNull];
        _commanderMap setVariable ["selectedGroup", grpNull];
        // dismissSquad expects an array of groups since it originally used hcSelected to get them
        [[_group]] spawn A3A_fnc_dismissSquad;
        // TODO UI-update: might need a slight delay here, tab gets updated before squad has been completely dismissed
        // leaving it visible in the list even though it should be gone
        ["update"] call A3A_fnc_commanderTab;
    };
Handles dismiss button click to dismiss selected squad.

Sqf

Apply
    case ("groupFastTravelButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
        private _fastTravelMap = _display displayCtrl A3A_IDC_FASTTRAVELMAP;
        private _selectedGroup = _commanderMap getVariable "selectedGroup";
        ["setHcMode", [true, _selectedGroup]] call A3A_fnc_fastTravelTab;
        ["switchTab", ["fasttravel"]] call A3A_fnc_mainDialog;
    };
Handles fast travel button click to open fast travel dialog.

Sqf

Apply
    case ("fireMissionSelectionChanged"):
    {
        private _selection = _params select 0;
        Trace_1("Fire Mission selection changed: %1", _selection);

        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;


        switch (_selection) do
        {
            case ("he"):
            {
                _fireMissionControlsGroup setVariable ["heSelected", true];
                // Set rounds number back to 1 or 0 depending on point/barrage mode
                if (_fireMissionControlsGroup getVariable ["pointSelected", false]) then
                {
                    _fireMissionControlsGroup setVariable ["roundsNumber", 1];
                } else {
                    _fireMissionControlsGroup setVariable ["roundsNumber", 0];
                };
            };

            case ("smoke"):
            {
                _fireMissionControlsGroup setVariable ["heSelected", false];
                // Set rounds number back to 1 or 0 depending on point/barrage mode
                if (_fireMissionControlsGroup getVariable ["pointSelected", false]) then
                {
                    _fireMissionControlsGroup setVariable ["roundsNumber", 1];
                } else {
                    _fireMissionControlsGroup setVariable ["roundsNumber", 0];
                };
            };

            case ("point"):
            {
                _fireMissionControlsGroup setVariable ["pointSelected", true];
                // Set rounds number back to 1
                _fireMissionControlsGroup setVariable ["roundsNumber", 1];
            };

            case ("barrage"):
            {
                _fireMissionControlsGroup setVariable ["pointSelected", false];
                // Set rounds number to 0, nubmer decided by barrage length
                _fireMissionControlsGroup setVariable ["roundsNumber", 0];
            };

            case ("addround"):
            {
                // Check for available ammo
                private _availableAmmo = 0;
                if (_fireMissionControlsGroup getVariable ["heSelected", true]) then {
                    _availableAmmo = _fireMissionControlsGroup getVariable ["availableHeRounds", 0];
                } else {
                    _availableAmmo = _fireMissionControlsGroup getVariable ["availableSmokeRounds", 0];
                };

                Trace_1("Available ammo: %1", _availableAmmo);

                // Add 1
                private _previousNumber = _fireMissionControlsGroup getVariable ["roundsNumber", 1];
                private _newNumber = _previousNumber + 1;

                // Check if num exceeds available ammo
                if (_newNumber > _availableAmmo) then {_newNumber = _availableAmmo};

                // Set new rounds count
                _fireMissionControlsGroup setVariable ["roundsNumber", _newNumber];

                Trace_1("Rounds count now at %1", _newNumber);
            };

            case ("subround"):
            {
                // Subtract 1
                private _previousNumber = _fireMissionControlsGroup getVariable ["roundsNumber", 1];
                private _newNumber = _previousNumber - 1;

                // Check if number is at least 1
                // We clamp it to 1 here and then check if we actually have that 1 round in updateFireMissionView
                if (_newNumber < 1) then {_newNumber = 1};

                // Set new rounds count
                _fireMissionControlsGroup setVariable ["roundsNumber", _newNumber];

                Trace_1("Rounds count now at %1", _newNumber);
            };

            case ("setstart"):
            {
                private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
                _commanderMap setVariable ["selectFireMissionPos", true];
            };

            case ("setend"):
            {
                private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
                _commanderMap setVariable ["selectFireMissionEndPos", true];
            };
        };

        // Update fire mission view to show changes
        ["updateFireMissionView"] call A3A_fnc_commanderTab;
    };
Handles changes to fire mission selections.

Sqf

Apply
    case ("fireMissionButtonClicked"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;
        private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;

        // Get params for fire mission from controlsGroup
        private _group = _commanderMap getVariable ["selectedGroup", grpNull];
        private _heSelected = _fireMissionControlsGroup getVariable ["heSelected", true];
        private _pointSelected = _fireMissionControlsGroup getVariable ["pointSelected", true];
        private _roundsNumber = _fireMissionControlsGroup getVariable ["roundsNumber", 0];
        private _startPos = _fireMissionControlsGroup getVariable ["startPos", []];
        private _endPos = _fireMissionControlsGroup getVariable ["endPos", []];

        // Debug stuff
        private _shell = if (_heSelected) then {"HE"} else {"Smoke"};
        private _type = if (_pointSelected) then {"Point"} else {"Barrage"};

        // private _debugStr = format["FIRE MISSION- Shell: %1, Type: %2, Rounds: %3, StartPos: %4, EndPos: %5", _shell, _type, _roundsNumber, _startPos, _endPos];
        // Debug(_debugStr);

        // Set the necessary global variables
        Debug_1("_heSelected: %1", _heSelected);
        if (_heSelected) then
        {
            typeAmmunition = SDKMortarHEMag;
        } else {
            typeAmmunition = SDKMortarSmokeMag;
        };
        if (_pointSelected) then
        {
            typeArty = "NORMAL";
        } else {
            typeArty = "BARRAGE";
        };
        roundsX = _roundsNumber;

        positionTel = _startPos;
        if (typeArty == "BARRAGE") then {
            positionTel2 = _endPos;
        };

        [[_group]] spawn A3A_fnc_artySupport;
    };
Handles fire mission button click to execute fire mission.

Sqf

Apply
    case ("showGarbageCleanOptions"):
    {
        Trace("Showing garbage clean options");
        private _display = findDisplay A3A_IDD_MAINDIALOG;

        // Hide overlapping buttons
        private _airSupportButton = _display displayCtrl A3A_IDC_AIRSUPPORTBUTTON;
        private _garbageCleanButton = _display displayCtrl A3A_IDC_GARBAGECLEANBUTTON;
        _airSupportButton ctrlShow false;
        _garbageCleanButton ctrlShow false;
        // Show garbage clean controlsGroup
        private _garbageCleanControlsGroup = _display displayCtrl A3A_IDC_GARBAGECLEANCONTROLSGROUP;
        _garbageCleanControlsGroup ctrlShow true;
    };
Shows garbage clean options.

Sqf

Apply
    case ("garbageCleanMapButtonClicked"):
    {
        closedialog 1;
        if (player == theBoss) then
        {
            [] remoteExec ["A3A_fnc_garbageCleaner",2];
        } else {
            ["Garbage Cleaner", "Only Player Commander has access to this function."] call A3A_fnc_customHint; // TODO UI-update: stringtable this
        };
    };
Handles garbage clean map button click to execute garbage cleaner.

Sqf

Apply
    case ("garbageCleanHqButtonClicked"):
    {
        closeDialog 2;
        ["Garbage Cleaner", "HQ only garbage clean yet to be implemented."] call A3A_fnc_customHint;
    };
Handles garbage clean HQ button click.

Sqf

Apply
    default
    {
        // Log error if attempting to call a mode that doesn't exist
        Error_1("Commander tab mode does not exist: %1", _mode);
    };
};
Logs error for invalid mode.

Where it leads:
This function calls A3A_fnc_hasRadio to check for radio, A3A_fnc_getGroupInfo to get group information, A3A_fnc_canFastTravel to check fast travel capabilities, A3A_fnc_controlHCsquad to control squads, A3A_fnc_dismissSquad to dismiss squads, A3A_fnc_fastTravelTab to open fast travel, A3A_fnc_artySupport to execute fire missions, A3A_fnc_garbageCleaner to clean garbage, and A3A_fnc_customHint to show hints.

Requirements:
Requires A3A_fnc_hasRadio function to be available
Requires A3A_fnc_getGroupInfo function to be available
Requires A3A_fnc_canFastTravel function to be available
Requires A3A_fnc_controlHCsquad function to be available
Requires A3A_fnc_dismissSquad function to be available
Requires A3A_fnc_fastTravelTab function to be available
Requires A3A_fnc_artySupport function to be available
Requires A3A_fnc_garbageCleaner function to be available
Requires A3A_fnc_customHint function to be available
Uses global variables like A3A_IDD_MAINDIALOG, A3A_IDC_COMMANDERMAP, etc.
Uses localization strings for tooltips and labels
Uses hcAllGroups global variable
Uses BIS_fnc_nearestPosition function for group selection
Uses SDKMortarHEMag and SDKMortarSmokeMag global variables
Function Name: fn_configColorToArray.sqf
What it does:
Converts colors defined in mission config to arrays usable in SQF. This function transforms string representations of colors (like {1,0,0,1}) into actual arrays ([1,0,0,1]) that can be used in SQF code.

How it does that:
The function takes a config color as input, converts it to a string, extracts the content between the braces, and then compiles it as an array.

Implementation:
Sqf

Apply
private _configColor = _this select 0;
private _configColorAsString = str _configColor;
private _colorArrayString = "[" + (_configColorAsString select [1, (count _configColorAsString) -2]) + "]";
call compile _colorArrayString;
First line extracts the config color from input parameters. Second line converts the color to string representation. Third line constructs an array string by extracting content between braces and adding brackets. Fourth line compiles and executes the array string to return the actual array.

Where it leads:
This function is a utility function that doesn't call other functions directly, but it's used by other functions that need to convert config colors to arrays for use in SQF.

Requirements:
No external dependencies
Uses standard SQF functions: str, select, count, call, compile
Works with any color format defined in config files as long as it's a valid array format

Function Name: fn_constructTab.sqf
What it does:
Handles updating and controls on the Construct tab of the Main dialog. This function manages the display and interaction of building construction options within the main interface, allowing players to select and build various structures.

How it does that:
The function processes different modes (update, default) and manages UI elements for building construction. It retrieves a list of buildable objects, creates UI controls for each item, and sets up event handlers for building selection.

Implementation:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Initializes parameters with default values. _mode defaults to "onLoad" and _params defaults to an empty array.

Sqf

Apply
switch (_mode) do
{
    case ("update"):
Handles the update mode for the construct tab.

Sqf

Apply
{
    private _className = _x select 0;
    private _buildTime = _x select 1;
    private _price = _x select 2;
    private _configClass = configFile >> "CfgVehicles" >> _className;
    private _displayName = getText (_configClass >> "displayName");
    private _editorPreview = getText (_configClass >> "editorPreview");
Iterates through the construction list and extracts class name, build time, price, display name, and preview image for each buildable item.

Sqf

Apply
private _topPadding = if (count _constructionsList < 7) then {5 * GRID_H} else {0};
private _itemXpos = 7 * GRID_W + ((7 * GRID_W + 44 * GRID_W) * (_added mod 3));
private _itemYpos = (floor (_added / 3)) * (44 * GRID_H) + _topPadding;
Calculates positioning for UI controls based on item count and grid system, with special padding for fewer items.

Sqf

Apply
private _itemControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", -1, _constructControlsGroup];
_itemControlsGroup ctrlSetPosition [_itemXpos, _itemYpos, 44 * GRID_W, 37 * GRID_H];
Creates a control group for each building item with specified positioning and dimensions.

Sqf

Apply
private _previewPicture = _display ctrlCreate ["A3A_Picture", -1, _itemControlsGroup];
_previewPicture ctrlSetPosition [0, 0, 44 * GRID_W, 25 * GRID_H];
_previewPicture ctrlSetText _editorPreview;
_previewPicture ctrlCommit 0;
Creates and positions a preview picture control for the building item.

Sqf

Apply
private _button = _display ctrlCreate ["A3A_ShortcutButton", -1, _itemControlsGroup];
_button ctrlSetPosition [0, 25 * GRID_H, 44 * GRID_W, 12 * GRID_H];
_button ctrlSetText _displayName;
_button setVariable ["className", _className];
_button ctrlAddEventHandler ["ButtonClick", {
    private _className = (_this # 0) getVariable "className";
    closeDialog 1;
    [_className] call A3A_fnc_build;
}];
_button ctrlCommit 0;
Creates a button control with event handler for building selection, which closes the dialog and calls the build function.

Sqf

Apply
if (_price > 0) then
{
    private _priceText = _display ctrlCreate ["A3A_InfoTextRight", -1, _itemControlsGroup];
    _priceText ctrlSetPosition[23 * GRID_W, 18 * GRID_H, 20 * GRID_W, 3 * GRID_H];
    _priceText ctrlSetText format ["%1 %2",_price, A3A_faction_civ get "currencySymbol"];
    _priceText ctrlCommit 0;
};
Displays price information for buildings that have a cost, formatted with currency symbol.

Sqf

Apply
private _timeText = _display ctrlCreate ["A3A_InfoTextRight", -1, _itemControlsGroup];
_timeText ctrlSetPosition[23 * GRID_W, 21 * GRID_H, 20 * GRID_W, 3 * GRID_H];
_timeText ctrlSetText format ["%1 s",_buildTime];
_timeText ctrlCommit 0;
Displays build time information for each building item.

Where it leads:
Calls A3A_fnc_initBuildableObjects to get the list of buildable objects. Calls A3A_fnc_build when a building is selected. Depends on: A3A_fnc_initBuildableObjects, A3A_fnc_build Uses: A3A_IDD_MAINDIALOG, A3A_IDC_CONSTRUCTGROUP, A3A_IDC_MAINDIALOGBACKBUTTON Modifies: UI controls in the main dialog

Function Name: fn_donateTab.sqf
What it does:
Handles updating and controls on the Donate tab of the Main dialog. This function manages the donation interface where players can transfer money to other players.

How it does that:
The function processes multiple modes (update, moneySliderChanged, moneyEditBoxChanged, donationAdd) to manage the donation interface. It sets up UI controls for money transfer, handles slider and text box interactions, and processes donation actions.

Implementation:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Initializes parameters with default values. _mode defaults to "onLoad" and _params defaults to an empty array.

Sqf

Apply
switch (_mode) do
{
    case ("update"):
Handles the update mode for the donate tab.

Sqf

Apply
private _money = player getVariable "moneyX";
private _moneySlider = _display displayCtrl A3A_IDC_MONEYSLIDER;
_moneySlider sliderSetRange [0,_money];
_moneySlider sliderSetSpeed [10, 10];
_moneySlider sliderSetPosition 0;
Initializes the money slider with range from 0 to player's money and sets initial position.

Sqf

Apply
private _moneyText = _display displayCtrl A3A_IDC_DONATIONMONEYTEXT;
_moneyText ctrlSetText format ["%1 %2", _money, A3A_faction_civ get "currencySymbol"];
Displays the player's current money amount with currency symbol.

Sqf

Apply
private _playerList = _display displayCtrl A3A_IDC_DONATEPLAYERLIST;
{
    if !(_x == player) then
    {
        _playerList lbAdd name _x;
        if !(_target == objNull) then
        {
            if (_target == _x) then
            {
                _playerList lbSetCurSel _forEachIndex;
            };
        };
    };
} forEach fakePlayers;
Populates the player list with names of other players, selecting the current target if it exists.

Sqf

Apply
case ("moneySliderChanged"):
{
    private _display = findDisplay A3A_IDD_MAINDIALOG;
    private _moneySlider = _display displayCtrl A3A_IDC_MONEYSLIDER;
    private _moneyEditBox = _display displayCtrl A3A_IDC_MONEYEDITBOX;
    _sliderValue = sliderPosition _moneySlider;
    _moneyEditBox ctrlSetText str floor _sliderValue;
};
Updates the edit box when the slider value changes, converting slider position to text.

Sqf

Apply
case ("moneyEditBoxChanged"):
{
    private _money = player getVariable "moneyX";
    private _display = findDisplay A3A_IDD_MAINDIALOG;
    private _moneyEditBox = _display displayCtrl A3A_IDC_MONEYEDITBOX;
    private _moneySlider = _display displayCtrl A3A_IDC_MONEYSLIDER;
    _moneyEditBoxValue = floor parseNumber ctrlText _moneyEditBox;
    _moneyEditBox ctrlSetText str _moneyEditBoxValue;
    if (_moneyEditBoxValue < 0) then {_moneyEditBox ctrlSetText str 0};
    if (_moneyEditBoxValue > _money) then {_moneyEditBox ctrlSetText str _money};
    _moneySlider sliderSetPosition _moneyEditBoxValue;
};
Handles text box changes by validating input and updating slider position accordingly.

Sqf

Apply
case ("donationAdd"):
{
    private _moneyToAdd = _params select 0;
    private _money = player getVariable "moneyX";
    private _display = findDisplay A3A_IDD_MAINDIALOG;
    private _moneyEditBox = _display displayCtrl A3A_IDC_MONEYEDITBOX;
    private _moneySlider = _display displayCtrl A3A_IDC_MONEYSLIDER;
    private _moneyEditBoxValue = floor parseNumber ctrlText _moneyEditBox;
    _newValue = _moneyEditBoxValue + _moneyToAdd;
    if (_newValue < 0) then {_newValue = 0};
    if (_newValue > _money) then {_newValue = _money};
    _moneyEditBox ctrlSetText str _newValue;
    _moneySlider sliderSetPosition _newValue;
};
Handles adding money to the donation amount, with bounds checking.

Where it leads:
Depends on: A3A_fnc_mainDialog for tab switching Uses: A3A_IDD_MAINDIALOG, A3A_IDC_MONEYSLIDER, A3A_IDC_MONEYEDITBOX, A3A_IDC_DONATIONMONEYTEXT, A3A_IDC_DONATEPLAYERLIST Modifies: UI controls in the main dialog, slider and text box values

Function Name: fn_fastTravelTab.sqf
What it does:
Handles updating and controls on the Fast Travel tab of the Main dialog. This function manages the fast travel interface where players can select locations to travel to on the map.

How it does that:
The function processes multiple modes (update, mapClicked, clearSelectedLocation, setHcMode, commitButtonClicked) to manage the fast travel interface. It handles map interaction, location selection, and travel execution.

Implementation:
Sqf

Apply
params[["_mode","update"], ["_params",[]]];
Initializes parameters with default values. _mode defaults to "update" and _params defaults to an empty array.

Sqf

Apply
switch (_mode) do
{
    case ("update"):
Handles the update mode for the fast travel tab.

Sqf

Apply
private _display = findDisplay A3A_IDD_MAINDIALOG;
private _backButton = _display displayCtrl A3A_IDC_MAINDIALOGBACKBUTTON;
private _fastTravelMap = _display displayCtrl A3A_IDC_FASTTRAVELMAP;
private _hcMode = _fastTravelMap getVariable ["hcMode", false];
Initializes display controls and checks if high command mode is enabled.

Sqf

Apply
if (_hcMode) then {
    _backButton ctrlAddEventHandler ["MouseButtonClick", {
        ["switchTab", ["commander"]] call A3A_fnc_mainDialog;
    }];
} else {
    _backButton ctrlAddEventHandler ["MouseButtonClick", {
        ["switchTab", ["player"]] call A3A_fnc_mainDialog;
    }];
};
Sets up back button event handler based on high command mode.

Sqf

Apply
private _selectedMarker = _fastTravelMap getVariable ["selectedMarker", ""];
Retrieves the currently selected marker from the map variable.

Sqf

Apply
if !(_selectedMarker isEqualTo "") then {
    // Location is selected
    private _locationName = [_selectedMarker] call A3A_fnc_getLocationMarkerName;
Handles the case when a location is selected, retrieving location name.

Sqf

Apply
private _canFastTravelToLocation = nil;
if (_hcMode) then {
    private _hcGroup = _fastTravelMap getVariable "hcGroup";
    _canFastTravelToLocation = [_hcGroup, _selectedMarker] call A3A_fnc_canFastTravelToLocation;
} else {
    _canFastTravelToLocation = [player, _selectedMarker] call A3A_fnc_canFastTravelToLocation;
};
if !(_canFastTravelToLocation # 0) exitWith {
    // Not a valid location for fast travel
    _infoText = _canFastTravelToLocation # 1;
    _fastTravelCommitButton ctrlEnable false;
    _fastTravelSelectText ctrlShow false;
    _fastTravelInfoText ctrlShow true;
    _fastTravelInfoText ctrlSetStructuredText parseText _infoText;
Validates if the selected location is suitable for fast travel and handles invalid locations.

Sqf

Apply
private _fastTravelTime = [player, _selectedMarker] call A3A_fnc_getFastTravelTime;
private _timeString = [_fastTravelTime] call A3A_fnc_formatTime;
_infoText = _infoText + localize "STR_antistasi_dialogs_main_fast_travel_time" + " " + _timeString + ".<br/><br/>";
Calculates and displays travel time to the selected location.

Sqf

Apply
case ("mapClicked"):
{
    Debug_1("Fast Travel map clicked: %1", _params);
    private _display = findDisplay A3A_IDD_MAINDIALOG;
    private _fastTravelMap = _display displayCtrl A3A_IDC_FASTTRAVELMAP;
    // Find closest marker to the clicked position
    _params params ["_clickedPosition"];
    private _clickedWorldPosition = _fastTravelMap ctrlMapScreenToWorld _clickedPosition;
    private _locations = airportsX + resourcesX + milbases + factories + outposts + seaports + citiesX + ["Synd_HQ"];
    private _selectedMarker = [_locations, _clickedWorldPosition] call BIS_fnc_nearestPosition;
Handles map click events to select locations, finding the nearest marker to the clicked position.

Sqf

Apply
private _maxDistance = 8 * GRID_W;
private _distance = _clickedPosition distance _markerMapPosition;
if (_distance > _maxDistance) exitWith
{
    Debug("Distance too large, deselecting");
    ["clearSelectedLocation"] call A3A_fnc_fastTravelTab;
    ["update"] call A3A_fnc_fastTravelTab;
};
Validates click distance and deselects if too far from a marker.

Sqf

Apply
case ("commitButtonClicked"):
{
    private _display = findDisplay A3A_IDD_MAINDIALOG;
    private _fastTravelMap = _display displayCtrl A3A_IDC_FASTTRAVELMAP;
    private _marker = _fastTravelMap getVariable ["selectedMarker", ""];
    private _hcMode = _fastTravelMap getVariable ["hcMode", false];
    if (_hcMode) then {
        private _hcGroup = _fastTravelMap getVariable ["hcGroup", grpNull];
        closeDialog 1;
        [_hcGroup, _marker] spawn A3A_fnc_fastTravel;
    } else {
        closeDialog 1;
        [player, _marker] spawn A3A_fnc_fastTravel;
    };
};
Handles commit button click to execute fast travel for either player or high command group.

Where it leads:
Calls A3A_fnc_getLocationMarkerName to get location name. Calls A3A_fnc_canFastTravelToLocation to validate travel location. Calls A3A_fnc_getFastTravelTime to calculate travel time. Calls A3A_fnc_formatTime to format travel time. Calls A3A_fnc_fastTravel to execute travel. Depends on: A3A_fnc_mainDialog for tab switching Uses: A3A_IDD_MAINDIALOG, A3A_IDC_FASTTRAVELMAP, A3A_IDC_FASTTRAVELSELECTTEXT, A3A_IDC_FASTTRAVELLOCATIONGROUP, A3A_IDC_FASTTRAVELCOMMITBUTTON Modifies: UI controls in the main dialog, map variables

Function Name: fn_fireMissionEH.sqf
What it does:
Event Handler for drawing fire mission markers to the commander map. This function draws markers on the commander map to visualize fire mission start and end points.

How it does that:
The function retrieves UI controls and variables from the commander map, then draws appropriate markers based on whether it's a point strike or barrage mission.

Implementation:
Sqf

Apply
private _display = findDisplay A3A_IDD_MAINDIALOG;
private _commanderMap = _display displayCtrl A3A_IDC_COMMANDERMAP;
private _fireMissionControlsGroup = _display displayCtrl A3A_IDC_FIREMISSONCONTROLSGROUP;
Initializes display controls for the commander map and fire mission controls group.

Sqf

Apply
private _startPos = _fireMissionControlsGroup getVariable ["startPos", nil];
private _endPos = _fireMissionControlsGroup getVariable ["endPos", nil];
private _pointStrike = _fireMissionControlsGroup getVariable ["pointSelected", true];
Retrieves the start position, end position, and point strike flag from the fire mission controls group variables.

Sqf

Apply
if (_pointStrike && !isNil "_startPos") then {
    // Draw icon
    _commanderMap drawIcon [
        "\A3\ui_f\data\Map\Markers\Military\destroy_CA.paa", // icon path
        [0.8,0,0,1], // color
        _startPos, // position
        32, // width
        32, // height
        0, // angle
        "", // text
        2 // shadow, outline if 2
    ];
};
Draws a single icon marker for point strike missions at the start position.

Sqf

Apply
if (!_pointStrike) then {
    if (!isNil "_startPos") then {
        // Draw start pos marker
        _commanderMap drawIcon [
            "\A3\ui_f\data\Map\Markers\Military\destroy_CA.paa", // icon path
            [0.8,0,0,1], // color
            _startPos, // position
            32, // width
            32, // height
            0, // angle
            "Barrage start", // text
            2 // shadow, outline if 2
        ];
    };
Draws start position marker for barrage missions.

Sqf

Apply
if (!_pointStrike) then {
    if (!isNil "_endPos") then {
        // Draw end pos marker
        _commanderMap drawIcon [
            "\A3\ui_f\data\Map\Markers\Military\destroy_CA.paa", // icon path
            [0.8,0,0,1], // color
            _endPos, // position
            32, // width
            32, // height
            0, // angle
            "Barrage end", // text
            2 // shadow, outline if 2
        ];
    };
Draws end position marker for barrage missions.

Sqf

Apply
if (!_pointStrike) then {
    if (!isNil "_startPos" && !isNil "_endPos") then {
        // If both markers are present draw a line between them
        _commanderMap drawLine [_startPos, _endPos, [0.8,0,0,1]];
    };
};
Draws a line between start and end positions for barrage missions.

Where it leads:
Depends on: A3A_fnc_mainDialog for dialog management Uses: A3A_IDD_MAINDIALOG, A3A_IDC_COMMANDERMAP, A3A_IDC_FIREMISSONCONTROLSGROUP Modifies: Commander map drawing (adds icons and lines)

Function Name: fn_getGroupInfo.sqf
What it does:
Returns comprehensive information about a group including name, position, unit counts, vehicle status, and other group characteristics. This function provides detailed group statistics for UI display.

How it does that:
The function takes a group as input and returns an array containing various properties of that group including unit counts, combat readiness, vehicle status, and icon information.

Implementation:
Sqf

Apply
params[["_group", grpNull]];
if (_group isEqualTo grpNull) exitWith {
  Error("No group specified");
};
Validates that a group is provided, exits with error if null.

Sqf

Apply
private _groupID = groupID _group;
private _groupLeader = leader _group;
private _units = units _group;
private _aliveUnits = {alive _x} count _units;
private _ableToCombat = {[_x] call A3A_fnc_canFight} count _units;
Initializes group information including ID, leader, units, and counts of alive and combat-ready units.

Sqf

Apply
private _hasOperativeMedic = {[_x] call A3A_fnc_isMedic} count _units > 0;
private _hasAt = {_x call A3A_fnc_typeOfSoldier == "ATMan"} count _units > 0;
private _hasAa = {_x call A3A_fnc_typeOfSoldier == "AAMan"} count _units > 0;
Checks for specific unit types within the group (medics, AT soldiers, AA soldiers).

Sqf

Apply
private _hasMortar = false;
private _mortarDeployed = false;
private _hasStatic = false;
private _staticDeployed = false;
Initializes variables to track mortar and static weapon status.

Sqf

Apply
if (!(isNull(_group getVariable ["mortarsX",objNull])) or ({_x call A3A_fnc_typeOfSoldier == "StaticMortar"} count _units > 0)) then {
  _hasMortar = true;
	if ({vehicle _x isKindOf "StaticWeapon"} count _units > 0) then {
    _mortarDeployed = true;
  };
} else {
  // Check for static weapons
	if ({_x call A3A_fnc_typeOfSoldier == "StaticGunner"} count _units > 0) then {
    _hasStatic = true;
		if ({vehicle _x isKindOf "StaticWeapon"} count _units > 0) then {
			_staticDeployed = true;
		};
	};
};
Determines if the group has mortars or static weapons and whether they are deployed.

Sqf

Apply
private _groupVehicle = [_group] call A3A_fnc_getGroupVehicle;
Retrieves the group's vehicle using the getGroupVehicle function.

Sqf

Apply
private _groupIconId = _group getVariable "BIS_MARTA_ICON_TYPE";
private _groupIcon = "n_unknown";
if !(isNil "_groupIconId") then {
  _groupIcon = (_group getGroupIcon _groupIconId) # 0;
};
if (_groupIcon isEqualTo "dummy") then {
  _groupIcon = "n_unknown";
};
Retrieves and formats the group's icon for display.

Sqf

Apply
private _groupIconColor = getGroupIconParams _group # 0;
Retrieves the group's icon color.

Sqf

Apply
[_group, _groupID, _groupLeader, _units, _aliveUnits, _ableToCombat, _task, _combatMode, _hasOperativeMedic, _hasAt, _hasAa, _hasMortar, _mortarDeployed, _hasStatic, _staticDeployed, _groupVehicle, _groupIcon, _groupIconColor];
Returns the complete group information array.

Where it leads:
Calls A3A_fnc_canFight to check combat readiness. Calls A3A_fnc_isMedic to check for medic units. Calls A3A_fnc_typeOfSoldier to identify unit types. Calls A3A_fnc_getGroupVehicle to get group vehicle. Depends on: A3A_fnc_canFight, A3A_fnc_isMedic, A3A_fnc_typeOfSoldier, A3A_fnc_getGroupVehicle Uses: Group variables and functions from core system Modifies: No direct variable modifications

Function Name: fn_getGroupVehicle.sqf
What it does:
Gets a high command groups assigned vehicle. This function searches for vehicles assigned to a high command group.

How it does that:
The function searches through all vehicles to find one assigned to the specified group, checking both vehicle owner variables and unit assignments.

Implementation:
Sqf

Apply
params [["_groupX",grpNull]];
Initializes parameter with default value of grpNull.

Sqf

Apply
if !((typeName _groupX) isEqualTo "GROUP") exitWith
{
    Error_1("%1 is not a group", _groupX);
    objNull;
};
Validates that the input is a group, exits with error if not.

Sqf

Apply
if (isNull _groupX) exitWith
{
    Error("Group is null");
    objNull;
};
Validates that the group is not null, exits with error if null.

Sqf

Apply
_vehicle = objNull;
{
    _owner = _x getVariable "owner";
    if (!isNil "_owner") then {if (_owner == _groupX) exitWith {_vehicle = _x}};
} forEach vehicles;
Searches through all vehicles to find one with matching owner variable.

Sqf

Apply
if (isNull _vehicle) then
{
    {
        if ((vehicle _x != _x) and (_x == driver _x) and !(vehicle _x isKindOf "StaticWeapon")) exitWith {_vehicle = vehicle _x};
    } forEach units _groupX;
};
If no vehicle found by owner, searches through units to find a driver with a non-static vehicle.

Where it leads:
Depends on: Core vehicle and group management functions Uses: vehicles array, group variables, unit vehicle assignments Modifies: No direct variable modifications

Function Name: fn_getVehicleCrewCount.sqf
What it does:
Returns an array with numbers of vehicle positions including driver, copilot, commander, gunners, passengers, and FFV seats. This function analyzes vehicle configuration to determine crew capacity.

How it does that:
The function parses vehicle configuration files to extract information about crew positions, including driver, copilot, commander, gunners, and passenger positions.

Implementation:
Sqf

Apply
params ["_class"];
Initializes parameter with vehicle class name.

Sqf

Apply
private _cfg = configFile >> "CfgVehicles" >> _class;
Retrieves configuration for the specified vehicle class.

Sqf

Apply
private _driver = getNumber (_cfg >> "hasDriver");
private _coPilot = 0;
private _commander = 0;
private _transportSoldier = getNumber (_cfg >> "transportSoldier");
private _turrets = 0;
private _ffvTurrets = 0;
private _allTurrets = 0;
Initializes variables for different vehicle crew positions.

Sqf

Apply
private _fnc_turrets =
{
	{
    _allTurrets = _allTurrets + 1;
		if !(getNumber (_x >> "showAsCargo") > 0) then
		{
			if (getNumber (_x >> "isCopilot") > 0 ) then
			{
				_coPilot = _coPilot + 1;
			};
			_turrets = _turrets + 1
		} else {
			_ffvTurrets = _ffvTurrets + 1
		};
    if (getNumber (_x >> "primaryObserver") > 0) then {_commander = _commander + 1};
		if (isClass (_x >> "Turrets")) then {_x call _fnc_turrets};
	}
	forEach ("true" configClasses (_this >> "Turrets"));
};
_cfg call _fnc_turrets;
Recursive function that iterates through turrets to count different crew positions.

Sqf

Apply
_gunners = _turrets - _commander - _coPilot;
_passengers = _allTurrets + _transportSoldier - _commander - _gunners - _coPilot;
_passengersFFV = _passengers - _transportSoldier;
Calculates final counts for gunners and passengers based on turret counts.

Sqf

Apply
[_driver, _coPilot, _commander, _gunners, _passengers, _passengersFFV];
Returns array with all crew position counts.

Where it leads:
Depends on: Core vehicle configuration parsing Uses: CfgVehicles configuration files Modifies: No direct variable modifications

Function Name: A3A_fnc_hqDialog.sqf
What it does:
Handles the initialization and updating of the HQ Dialog, managing tab switching, UI updates, map interactions, and resource management for the faction's headquarters. This function serves as the central control point for all HQ-related UI operations, coordinating between different tabs (main, garrison, minefields) and handling user interactions with the map and controls.

How it does that:
The function implements a switch-case structure that handles different modes of operation:

onLoad: Initializes the dialog, sets up map event handlers, and configures initial UI state
onUnload: Cleans up event handlers and restores map state when dialog closes
switchTab: Switches between different tabs (main, garrison, minefields) and manages tab-specific UI updates
updateMainTab: Updates the main tab content with campaign status, resources, and population data
updateGarrisonTab: Updates garrison information, displays unit counts, and manages recruitment controls
updateMinefieldsTab: Updates minefields tab content and UI elements
restSliderChanged: Handles time rest slider changes and updates display text
factionMoneySliderChanged: Updates money edit box when slider value changes
factionMoneyEditBoxChanged: Validates and updates slider when edit box value changes
factionMoneyButtonClicked: Processes money transfer when button is clicked
garrisonMapClicked: Handles map clicks to select garrison locations
garrisonAdd: Adds units to selected garrison
garrisonRemove: Removes units from selected garrison
dismissGarrison: Dismisses selected garrison
skipTime: Handles time rest/skip functionality with validation
buildWatchpost: Opens outpost creation dialog
removeWatchpost: Handles watchpost removal functionality
Implementation Details:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Parameter validation: Extracts mode and parameters with default values. Mode defaults to "onLoad", parameters default to empty array.

Sqf

Apply
private _display = findDisplay A3A_IDD_HQDIALOG;
private _garrisonMap = _display displayCtrl A3A_IDC_GARRISONMAP;
Variable initialization: Gets the main dialog display and garrison map control for UI manipulation.

Where it leads:
Calls A3A_fnc_mapDrawSelectEH for map drawing event handling
Calls A3A_fnc_mapDrawOutpostsEH for outpost drawing on map
Calls A3A_fnc_canMoveHQ for HQ movement permission checks
Calls A3A_fnc_getAggroLevelString for aggression level text formatting
Calls A3A_fnc_getLocationMarkerName for marker name retrieval
Calls A3A_fnc_vehiclePrice for vehicle pricing calculations
Calls A3A_fnc_garrisonAdd for adding units to garrison
Calls A3A_fnc_garrisonRemove for removing units from garrison
Calls A3A_fnc_dismissGarrison for dismissing garrisons
Calls A3A_fnc_resourceCheckSkipTime for time skipping
Calls A3A_fnc_outpostDialog for outpost creation
Calls A3A_fnc_customHint for displaying hints to players
Requirements:
Requires A3A_IDD_HQDIALOG and A3A_IDC_GARRISONMAP constants
Depends on server variable for faction resources
Requires garrison variable for garrison data
Uses teamPlayer for faction identification
Relies on sidesX for territory control information
Requires citiesX, outposts, airportsX, resourcesX, factories, seaports for location data
Depends on A3A_faction_occ, A3A_faction_inv, A3A_faction_civ for faction data
Requires aggressionLevelOccupants, aggressionLevelInvaders for aggression levels
Uses tierWar for war level information
Depends on SDKMil, SDKSL, SDKMG, SDKGL, SDKMedic, SDKSniper, SDKATman, staticCrewTeamPlayer for unit definitions
Requires NATOFlagTexture, CSATFlagTexture for flag textures
Uses destroyedSites for destroyed city tracking
Depends on theBoss for commander identification
Requires A3A_activeTasks for active task tracking
Uses respawnTeamPlayer for HQ position
Function Name: A3A_fnc_mainDialog.sqf
What it does:
Manages the initialization and tab switching for the Main Dialog (Y-Menu), handling different user interface tabs and their respective content updates. This function coordinates the display of player, commander, admin, fast travel, construction, AI management, donation, air support, and player management tabs.

How it does that:
The function implements a switch-case structure that handles different modes of operation:

onLoad: Initializes the main dialog, sets up tab permissions, caches group information, and configures map event handlers
onUnload: Cleans up event handlers and restores map state when dialog closes
switchTab: Switches between different tabs and manages tab-specific UI updates
Implementation Details:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Parameter validation: Extracts mode and parameters with default values. Mode defaults to "onLoad", parameters default to empty array.

Sqf

Apply
private _display = findDisplay A3A_IDD_MAINDIALOG;
Variable initialization: Gets the main dialog display for UI manipulation.

Where it leads:
Calls A3A_fnc_getGroupInfo for group information retrieval
Calls A3A_fnc_fireMissionEH for fire mission marker drawing
Calls A3A_fnc_mapDrawSelectEH for map selection drawing
Calls A3A_fnc_mapDrawHcGroupsEH for high command group drawing
Calls A3A_fnc_mapDrawOutpostsEH for outpost drawing
Calls A3A_fnc_mapDrawUserMarkersEH for user marker drawing
Calls A3A_fnc_playerTab for player tab updates
Calls A3A_fnc_commanderTab for commander tab updates
Calls A3A_fnc_adminTab for admin tab updates
Calls A3A_fnc_fastTravelTab for fast travel tab updates
Calls A3A_fnc_constructTab for construct tab updates
Calls A3A_fnc_aiManagementTab for AI management tab updates
Calls A3A_fnc_donateTab for donate tab updates
Calls A3A_fnc_airSupportTab for air support tab updates
Calls A3A_fnc_playerManagementTab for player management tab updates
Requirements:
Requires A3A_IDD_MAINDIALOG constant
Depends on player variable for player identification
Requires theBoss for commander identification
Uses hcallGroups for group data retrieval
Requires hcSelected for selected group tracking
Depends on A3A_IDC_COMMANDERMAP, A3A_IDC_FASTTRAVELMAP for map controls
Uses groupIconsVisible for group icon visibility management
Requires A3A_fnc_getGroupInfo for group information
Depends on A3A_activeTasks for active task tracking
Uses A3A_fnc_fireMissionEH, A3A_fnc_mapDrawSelectEH, A3A_fnc_mapDrawHcGroupsEH, A3A_fnc_mapDrawOutpostsEH, A3A_fnc_mapDrawUserMarkersEH for map drawing event handlers

Function Name: fn_mapDrawHcGroupsEH.sqf
What it does:
This function serves as an event handler that draws High Command group markers onto map controls. It updates group data and renders visual indicators for each High Command group on the map, including group type icons, size indicators, and group names.

How it does that:
The function first retrieves existing High Command group data from the map control's variable storage, then updates this data by calling A3A_fnc_getGroupInfo for each group in hcallGroups player. It then iterates through the updated group data to draw three distinct elements for each group: a group type icon, a size indicator, and a group name text.

Implementation:
Sqf

Apply
params ["_map"];
This line extracts the map control parameter passed to the event handler.

Sqf

Apply
private _oldHcGroupData = _map getVariable "hcGroupData";
private _hcGroupData = [];
{
    private _groupData = [_x] call A3A_fnc_getGroupInfo;
    _hcGroupData pushBack _groupData;
} forEach hcallGroups player;
_map setVariable ["hcGroupData", _hcGroupData];
This section retrieves the previous High Command group data from the map variable, initializes a new empty array for group data, and populates it by calling A3A_fnc_getGroupInfo for each group in hcallGroups player. Finally, it stores the updated group data back to the map variable.

Sqf

Apply
{
    _x params [
        "_group",
        "_groupID",
        "_groupLeader",
        "_units",
        "_aliveUnits",
        "_ableToCombat",
        "_task",
        "_combatMode",
        "_hasOperativeMedic",
        "_hasAt",
        "_hasAa",
        "_hasMortar",
        "_mortarDeployed",
        "_hasStatic",
        "_staticDeployed",
        "_groupVehicle",
        "_groupIcon",
        "_groupIconColor"
    ];
This block unpacks the group data array into individual variables for processing each group's information.

Sqf

Apply
private _position = getPos leader _group;
This retrieves the position of the group leader for marker placement.

Sqf

Apply
if (count _groupID > 16) then
{
    _groupID = (_groupId select [0, 15]) + "...";
};
This truncates group names that exceed 16 characters by taking the first 15 characters and appending "..." to ensure readability on the map.

Sqf

Apply
_map drawIcon [
    "\A3\ui_f\data\Map\Markers\NATO\" + _groupIcon, // icon type
    _groupIconColor, // colour
    _position, // position
    32, // width
    32, // height
    0, // angle
    "", // text, no text for this
    0 // shadow (outline if 2)
];
This draws the group type icon using the marker's icon type, color, position, and dimensions.

Sqf

Apply
private _size = 0;
switch (true) do
{
    case (_aliveUnits < 4): {_size = 0};
    case (_aliveUnits >= 4 && _aliveUnits < 8): {_size = 1};
    case (_aliveUnits >= 12 && _aliveUnits < 25): {_size = 2};
    case (_aliveUnits >= 25 && _aliveUnits < 60): {_size = 3};
    case (_aliveUnits >= 60 && _aliveUnits < 240): {_size = 4};
};
private _sizeIcon = "\A3\ui_f\data\Map\Markers\NATO\group_" + str _size;
_map drawIcon [
    _sizeIcon, // icon type
    [0,0,0,1], // colour
    _position, // position
    38, // width
    38, // height
    0, // angle
    "", // text, no text for this
    0 // shadow (outline if 2)
];
This calculates the group size indicator based on the number of alive units and draws the corresponding size icon.

Sqf

Apply
_map drawIcon [
    "#(rgb,1,1,1)color(0,0,0,0)", // transparent
    _groupIconColor, // colour
    _position, // position
    32, // width
    32, // height
    0, // angle
    _groupID, // text
    2 // shadow (outline if 2)
];
This draws the group name text using the group's ID, color, and position.

Where it leads:
This function calls:

A3A_fnc_getGroupInfo - retrieves detailed information about each group
A3A_fnc_commanderTab - updates the commander tab UI (commented out)
This function depends on:

hcallGroups player - provides the list of High Command groups
A3A_fnc_getGroupInfo - required for group data processing
Global variables like hcallGroups and player
The function is part of the map drawing system and integrates with the main GUI to provide visual representation of High Command groups. It modifies the map control's hcGroupData variable and is triggered by map draw events.

Requirements:
Map control must be open and have the event handler attached
hcallGroups player must contain valid High Command groups
A3A_fnc_getGroupInfo function must be available
player variable must be accessible and valid
Function Name: fn_mapDrawOutpostsEH.sqf
What it does:
This function serves as an event handler that draws map markers for outposts, airports, resources, factories, seaports, and cities. It dynamically adjusts marker size and transparency based on map zoom level and displays appropriate icons and names for each location type.

How it does that:
The function first calculates zoom-dependent transparency and marker size. It then collects all location data from various global arrays, determines appropriate colors based on location side, and creates marker data arrays. Finally, it draws each marker using the map's drawIcon function with appropriate scaling and text.

Implementation:
Sqf

Apply
#include "..\..\dialogues\textures.inc"
This includes texture definitions for map markers.

Sqf

Apply
params ["_map"];
This extracts the map control parameter passed to the event handler.

Sqf

Apply
private _mapScale = ctrlMapScale _map;
private _fadeStart = 0.5;
private _fadeEnd = 0.75;
private _alpha = ((1 - ((_mapScale - _fadeStart) / (_fadeEnd - _fadeStart))) max 0) min 1;
This calculates the alpha transparency value based on map zoom level, where 0.5 is the start of fading and 0.75 is fully transparent.

Sqf

Apply
private _minMarkerSize = 12;
private _maxMarkerSize = 32;
private _markerSize = ((_maxMarkerSize + (_minMarkerSize - _maxMarkerSize) * ((_mapScale - _fadeStart) / (_fadeEnd - _fadeStart))) max _minMarkerSize) min _maxMarkerSize;
This calculates the marker size based on map zoom, where smaller markers are shown at higher zoom levels.

Sqf

Apply
private _outpostIconData = [];
{
    private _marker = _x;
    private _type = _marker call A3A_fnc_getLocationMarkerType;
    private _name = [_marker] call A3A_fnc_getLocationMarkerName;
    private _pos = getMarkerPos _marker;
    private _side = sidesX getVariable [_marker,sideUnknown];
    private _color = [1,1,1,1];
This section iterates through all location markers and collects data for each, including type, name, position, and side information.

Sqf

Apply
switch (_side) do {
    case (teamPlayer): {
        _color = ["Map", "Independent"] call BIS_fnc_displayColorGet;
    };

    case (Occupants): {
        _color = ["Map", "BLUFOR"] call BIS_fnc_displayColorGet;
    };

    case (Invaders): {
        _color = ["Map", "OPFOR"] call BIS_fnc_displayColorGet;
    };

    case (civilian): {
        _color = ["Map", "Civilian"] call BIS_fnc_displayColorGet;
    };

    case (sideUnknown): {
        _color = ["Map", "Unknown"] call BIS_fnc_displayColorGet;
    };
};
This assigns appropriate colors to locations based on their side affiliation using BIS color functions.

Sqf

Apply
private _fadedColor = [_color # 0, _color # 1, _color # 2, _alpha];
This creates a faded version of the color with the calculated alpha value.

Sqf

Apply
private _icon = A3A_missionRootPath + A3A_Icon_Map_Blank;
if (_mapScale < _fadeEnd) then {
    _icon = switch (_type) do {
        case ("hq"): {
            A3A_missionRootPath + A3A_Icon_Map_HQ;
        };

        case ("city"): {
            A3A_missionRootPath + A3A_Icon_Map_City;
        };

        case ("factory"): {
            A3A_missionRootPath + A3A_Icon_Map_Factory;
        };

        case ("resource"): {
            A3A_missionRootPath + A3A_Icon_Map_Resource;
        };

        case ("seaport"): {
            A3A_missionRootPath + A3A_Icon_Map_Seaport;
        };

        case ("airport"): {
            A3A_missionRootPath + A3A_Icon_Map_Airport;
        };

        case ("outpost"): {
            A3A_missionRootPath + A3A_Icon_Map_Outpost;
        };

        case ("watchpost"): {
            A3A_missionRootPath + A3A_Icon_Map_Watchpost;
        };

        case ("roadblock"): {
            A3A_missionRootPath + A3A_Icon_Map_Roadblock;
        };

        default {
            "\A3\ui_f\data\Map\Markers\Military\flag_CA.paa";
        };
    };
};
This determines the appropriate icon texture based on the marker type and mission root path, using a fallback default icon.

Sqf

Apply
_outpostIconData pushBack [_name, _pos, _type, _icon, _color, _fadedColor];
} forEach airportsX + resourcesX + factories + outposts + seaports + citiesX + milbases + hmgpostsFIA + atpostsFIA + aapostsFIA + roadblocksFIA + watchpostsFIA + ["Synd_HQ"];
This iterates through all location arrays and builds the complete marker data array.

Sqf

Apply
{
    _x params ["_name", "_pos", "_type", "_icon", "_color", "_fadedColor"];
    _map drawIcon [
        _icon, // texture
        _color,
        _pos,
        _markerSize, // width
        _markerSize, // height
        0, // angle
        "", // text
        0 // shadow (outline if 2)
    ];
This draws the marker icon using the calculated size and color.

Sqf

Apply
if !(_type isEqualTo "city") then {_color = _fadedColor};
_map drawIcon [
    "#(rgb,1,1,1)color(0,0,0,0)", // the icon itself is transparent
    _color, // colour
    _pos, // position
    _markerSize, // width
    _markerSize, // height
    0, // angle
    _name, // text
    2 // shadow (outline if 2)
];
This draws the marker name text with appropriate color and transparency.

Where it leads:
This function calls:

A3A_fnc_getLocationMarkerType - determines marker type
A3A_fnc_getLocationMarkerName - retrieves marker name
This function depends on:

Multiple global arrays: airportsX, resourcesX, factories, outposts, seaports, citiesX, milbases, hmgpostsFIA, atpostsFIA, aapostsFIA, roadblocksFIA, watchpostsFIA
Global variable sidesX - contains side information for markers
Global variables A3A_missionRootPath, A3A_Icon_Map_Blank, etc. - texture paths
BIS functions: BIS_fnc_displayColorGet, BIS_fnc_colorConfigToRGBA
The function is part of the map drawing system and integrates with the main GUI to provide visual representation of various locations. It modifies map control drawing elements and is triggered by map draw events.

Requirements:
Map control must be open and have the event handler attached
Global arrays containing location markers must be populated
A3A_fnc_getLocationMarkerType and A3A_fnc_getLocationMarkerName functions must be available
sidesX variable must contain side information for markers
Texture paths must be defined in global variables
Function Name: fn_mapDrawSelectEH.sqf
What it does:
This function serves as an event handler that draws a pulsing selection marker on the map at a specified position. It manages the animation of the selection marker and updates its state between different sizes to create a pulsing effect.

How it does that:
The function first initializes pulsing parameters and retrieves the selection marker data from the map control. If no data exists, it initializes the marker with default values. It then updates the marker's radius and direction based on the pulsing animation logic, and finally draws the marker using the map's drawIcon function.

Implementation:
Sqf

Apply
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
This includes necessary definitions and textures for the selection marker.

Sqf

Apply
params ["_map"];
This extracts the map control parameter passed to the event handler.

Sqf

Apply
private _minRadius = 48;
private _maxRadius = 64;
private _pulseSpeed = 0.5;
This sets up the parameters for the pulsing animation: minimum radius, maximum radius, and pulse speed.

Sqf

Apply
private _data = _map getVariable ["selectMarkerData", []];
This retrieves the selection marker data from the map variable, or initializes an empty array if none exists.

Sqf

Apply
if (count _data == 1) then
{
    _data pushBack _minRadius;
    _data pushBack 0;
};
This initializes the marker data with default radius and direction if only position is specified.

Sqf

Apply
if (count _data != 3) exitWith {nil};
_data params ["_position", "_radius", "_dir"];
This validates that the data contains exactly 3 elements (position, radius, direction) and unpacks them.

Sqf

Apply
if (_dir == 0) then
{
    _radius = _radius - _pulseSpeed;
    if (_radius < _minRadius) then {
        _dir = 1; // Reverse direction
    };
} else {
    _radius = _radius + _pulseSpeed;
    if (_radius > _maxRadius) then
    {
        _dir = 0;
    };
};
_map setVariable ["selectMarkerData", [_position, _radius, _dir]];
This updates the marker's animation state by adjusting the radius and direction based on the pulsing speed, reversing direction when limits are reached.

Sqf

Apply
private _color = [A3A_COLOR_SELECT_MARKER] call A3A_fnc_configColorToArray;
This converts the selection marker color from configuration to array format.

Sqf

Apply
_map drawIcon [
A3A_Select_Marker,
_color,
_position,
_radius,
_radius,
0
];
This draws the selection marker using the calculated radius and color at the specified position.

Where it leads:
This function calls:

A3A_fnc_configColorToArray - converts configuration color to array format
This function depends on:

Global variable A3A_Select_Marker - texture for selection marker
Global variable A3A_COLOR_SELECT_MARKER - color configuration for selection marker
Global variable selectMarkerData - stored selection marker data on map control
The function is part of the map drawing system and integrates with the main GUI to provide visual selection feedback. It modifies map control drawing elements and is triggered by map draw events.

Requirements:
Map control must be open and have the event handler attached
A3A_Select_Marker and A3A_COLOR_SELECT_MARKER must be defined globally
A3A_fnc_configColorToArray function must be available
The map control must have selectMarkerData variable set to an array of position, radius, and direction
Function Name: fn_mapDrawUserMarkersEH.sqf
What it does:
This function serves as an event handler that draws user-created markers to map controls. It filters markers based on whether they are user-defined and channel, then draws either individual markers or line segments based on marker type.

How it does that:
The function iterates through all map markers, filtering for user-defined markers in channels 0, 1, or 2. For each valid marker, it determines the marker color, and then either draws an icon for point markers or line segments for polyline markers.

Implementation:
Sqf

Apply
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
This includes necessary textures and script component definitions.

Sqf

Apply
params ["_map"];
This extracts the map control parameter passed to the event handler.

Sqf

Apply
{
    if !("_USER_DEFINED" in _x) then {continue};
This filters markers to only process those marked as user-defined.

Sqf

Apply
private _channel = markerChannel _x;
    if !(_channel in [0,1,2]) then {continue};
This filters markers to only process those in channels 0, 1, or 2.

Sqf

Apply
_markerColor = (configFile >> "CfgmarkerColors" >> getmarkerColor _x >> "color") call BIS_fnc_colorConfigToRGBA;
This retrieves the marker color from configuration and converts it to RGBA array format.

Sqf

Apply
private _markerPolyline = markerPolyline _x;
    if (_markerPolyline isEqualto []) then
    {
        // not a line marker
        _markerTexture = (getmarkertype _x) call BIS_fnc_textureMarker;
        _markerPos = getmarkerPos _x;
        _markertext = markertext _x;
        _map drawIcon [
            _markerTexture, // texture
            _markerColor,
            _markerPos,
            32, // width
            32, // height
            0, // angle
            _markertext, // text
            1 // shadow (outline if 2)
        ];
    } else {
        // Marker is a line marker
        _lineCoords = [];
        for [{ _i = 0 }, { _i < ((count _markerPolyline) - 1)}, { _i = _i + 2 }] do
        {
            _lineCoords pushBack [_markerPolyline # _i, _markerPolyline # (_i + 1)];
        };
        for [{ _i = 0 }, { _i < ((count _lineCoords) - 2)}, { _i = _i + 1 }] do
        {
            _map drawLine [_lineCoords # _i, _lineCoords # (_i + 1), _markerColor];
        };
    };
This processes point markers by drawing icons and polyline markers by drawing line segments.

Where it leads:
This function calls:

BIS_fnc_colorConfigToRGBA - converts color configuration to RGBA array
BIS_fnc_textureMarker - retrieves texture for marker type
This function depends on:

Global variables: allMapMarkers - contains all map markers
BIS functions: markerChannel, getmarkerColor, getmarkertype, getmarkerPos, markertext, markerPolyline
Global variable configFile - contains configuration data
The function is part of the map drawing system and integrates with the main GUI to provide visual representation of user-created markers. It modifies map control drawing elements and is triggered by map draw events.

Requirements:
Map control must be open and have the event handler attached
allMapMarkers must contain valid map markers
BIS functions must be available
Marker configuration must be properly defined in CfgmarkerColors
Function Name: fn_playerManagementTab.sqf
What it does:
This function handles updating and controls on the Player Management tab of the Main dialog. It manages the player list display, handles player selection changes, and updates UI elements for adding/removing members.

How it does that:
The function implements multiple modes for handling different aspects of the player management tab. The "update" mode refreshes the player list, "playerLbSelectionChanged" handles selection changes, and debug modes simulate adding/removing members.

Implementation:
Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
This includes necessary definitions and components for the function.

Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
This extracts the mode and parameters from the function call.

Sqf

Apply
switch (_mode) do
{
    case ("update"):
    {
        Trace("Updating Player Management tab");
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _backButton = _display displayCtrl A3A_IDC_MAINDIALOGBACKBUTTON;
        _backButton ctrlRemoveAllEventHandlers "MouseButtonClick";
        _backButton ctrlAddEventHandler ["MouseButtonClick", {
            ["switchTab", ["admin"]] call A3A_fnc_mainDialog;
        }];
        _backButton ctrlShow true;
This handles the update mode by finding the dialog and setting up the back button.

Sqf

Apply
private _listBox = _display displayCtrl A3A_IDC_ADMINPLAYERLIST;
        lbClear _listBox;
        {
            private _name = name _x;
            private _isMember = [_x] call A3A_fnc_isMember;
            private _playerUID = getPlayerUID _x;
            private _distance = format["%1 m", floor (player distance _x)];

            private _index = _listBox lnbAddRow [_name, _distance, _playerUID];
            if (_isMember) then {
                _listBox lnbSetColor [[_index,0], [0.2,0.6,0.2,1]]; // TODO UI-update: use defined color
            } else {
                _listBox lnbSetColor [[_index,0], [0.7,0.7,0.7,1]]; // TODO UI-update: use defined color
            };
        } forEach allPlayers;
This populates the player list box with all players, showing their name, distance, and UID, and coloring them based on membership status.

Sqf

Apply
_listBox lnbSetCurSelRow 0;
        ["playerLbSelectionChanged"] spawn A3A_fnc_playerManagementTab;
This selects the first player in the list and triggers the selection changed handler.

Sqf

Apply
case ("playerLbSelectionChanged"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _listBox = _display displayCtrl A3A_IDC_ADMINPLAYERLIST;
        private _index = lnbCurSelRow _listBox;
        private _playerUID = _listBox lnbText [_index, 2];
        Debug_1("_playerUID: %1", _playerUID);
        private _addButton = _display displayCtrl A3A_IDC_ADDMEMBERBUTTON;
        private _removeButton = _display displayCtrl A3A_IDC_REMOVEMEMBERBUTTON;

        private _player = (str _playerUID) call BIS_fnc_getUnitByUID;
        Debug_1("_player: %1", _player);
        if ([_player] call A3A_fnc_isMember) then {
            _addButton ctrlShow false;
            _removeButton ctrlShow true;
        } else {
            _addButton ctrlShow true;
            _removeButton ctrlShow false;
        };
    };
This handles player selection changes by finding the selected player and updating the add/remove buttons.

Sqf

Apply
case ("adminAddMember"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _listBox = _display displayCtrl A3A_IDC_ADMINPLAYERLIST;
        private _index = lbCurSel _listBox;
        _listBox lnbSetColor [[_index,0], [0.2,0.6,0.2,1]];
        ["playerLbSelectionChanged"] spawn A3A_fnc_playerManagementTab;
    };
This simulates adding a member to the player list.

Sqf

Apply
case ("adminRemoveMember"):
    {
        private _display = findDisplay A3A_IDD_MAINDIALOG;
        private _listBox = _display displayCtrl A3A_IDC_ADMINPLAYERLIST;
        private _index = lbCurSel _listBox;
        _listBox lnbSetColor [[_index,0], [0.7,0.7,0.7,1]];
        ["playerLbSelectionChanged"] spawn A3A_fnc_playerManagementTab;
    };
This simulates removing a member from the player list.

Sqf

Apply
default
    {
        Error_1("Player management tab mode does not exist: %1", _mode);
    };
This handles invalid modes by logging an error.

Where it leads:
This function calls:

A3A_fnc_mainDialog - switches tabs in the main dialog
A3A_fnc_isMember - checks if a player is a member
BIS_fnc_getUnitByUID - retrieves unit by UID
This function depends on:

Global variables: allPlayers, A3A_IDD_MAINDIALOG, A3A_IDC_ADMINPLAYERLIST, A3A_IDC_ADDMEMBERBUTTON, A3A_IDC_REMOVEMEMBERBUTTON
Functions: A3A_fnc_isMember, BIS_fnc_getUnitByUID
UI controls and IDs defined in ids.inc
The function integrates with the main dialog system to manage player membership. It modifies UI elements and requires the main dialog to be open.

Requirements:
Main dialog must be open
Global variables for dialog IDs must be defined
A3A_fnc_isMember function must be available
BIS_fnc_getUnitByUID function must be available
allPlayers must contain valid player units
Function Name: fn_playerTab.sqf
What it does:
This function handles updating and controls on the Player tab of the Main dialog. It manages UI elements related to player capabilities, stats, commander status, and vehicle information.

How it does that:
The function implements multiple modes for handling different aspects of the player tab. The "update" mode refreshes all UI elements including buttons, player stats, commander status, and vehicle information.

Implementation:
Sqf

Apply
#include "..\..\dialogues\ids.inc"
#include "..\..\dialogues\defines.hpp"
#include "..\..\dialogues\textures.inc"
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()
This includes necessary definitions and components for the function.

Sqf

Apply
params[["_mode","update"], ["_params",[]]];
This extracts the mode and parameters from the function call.

Sqf

Apply
switch (_mode) do
{
    case ("update"):
    {
        Trace("Updating Player tab");
        private _display = findDisplay A3A_IDD_MAINDIALOG;
This handles the update mode by finding the dialog.

Sqf

Apply
private _undercoverButton = _display displayCtrl A3A_IDC_UNDERCOVERBUTTON;
        private _undercoverIcon = _display displayCtrl A3A_IDC_UNDERCOVERICON;
        private _canGoUndercover = [] call A3A_fnc_canGoUndercover;
        private _isUndercover = captive player;
        if (_isUndercover) then {
            _undercoverButton ctrlEnable true;
            _undercoverButton ctrlSetTooltip "";
            _undercoverButton ctrlSetText "Go Overt";
            _undercoverButton ctrlRemoveAllEventHandlers "MouseButtonClick";
            _undercoverButton ctrlAddEventHandler ["MouseButtonClick", {player setCaptive false; ["update"] spawn A3A_fnc_playerTab}];
            _undercoverIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
            _undercoverIcon ctrlSetTooltip "";
        } else {
            if (_canGoUndercover # 0) then {
                _undercoverButton ctrlEnable true;
                _undercoverButton ctrlSetTooltip "";
                _undercoverButton ctrlSetText localize "STR_antistasi_dialogs_main_undercover";
                _undercoverButton ctrlRemoveAllEventHandlers "MouseButtonClick";
                _undercoverButton ctrlAddEventHandler ["MouseButtonClick", {[] spawn A3A_fnc_goUndercover; ["update"] spawn A3A_fnc_playerTab}];
                _undercoverIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
                _undercoverIcon ctrlSetTooltip "";
            } else {
                _undercoverButton ctrlEnable false;
                _undercoverButton ctrlSetTooltip (_canGoUndercover # 1);
                _undercoverButton ctrlSetText localize "STR_antistasi_dialogs_main_undercover";
                _undercoverIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
                _undercoverIcon ctrlSetTooltip (_canGoUndercover # 1);
            };
        };
This handles the undercover button state and functionality, enabling/disabling based on conditions.

Sqf

Apply
private _fastTravelButton = _display displayCtrl A3A_IDC_FASTTRAVELBUTTON;
        private _fastTravelIcon = _display displayCtrl A3A_IDC_FASTTRAVELICON;
        private _canFastTravel = [player] call A3A_fnc_canFastTravel;
        if (_canFastTravel # 0) then {
            _fastTravelButton ctrlEnable true;
            _fastTravelButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_fast_travel_tooltip";
            _fastTravelIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
            _fastTravelIcon ctrlSetTooltip localize "STR_antistasi_dialogs_main_fast_travel_tooltip";

        } else {
            _fastTravelButton ctrlEnable false;
            _fastTravelButton ctrlSetTooltip (_canFastTravel # 1);
            _fastTravelIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _fastTravelIcon ctrlSetTooltip (_canFastTravel # 1);
        };
This handles the fast travel button state and functionality.

Sqf

Apply
private _constructButton = _display displayCtrl A3A_IDC_CONSTRUCTBUTTON;
        private _constructIcon = _display displayCtrl A3A_IDC_CONSTRUCTICON;
        private _canBuild = [] call A3A_fnc_canBuild;
        if (_canBuild # 0) then
        {
            _constructButton ctrlEnable true;
            _constructButton ctrlSetTooltip "";
            _constructIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
            _constructIcon ctrlSetTooltip "";
        } else {
            _constructButton ctrlEnable false;
            _constructButton ctrlSetTooltip (_canBuild # 1);
            _constructIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
            _constructIcon ctrlSetTooltip (_canBuild # 1);
        };
This handles the construct button state and functionality.

Sqf

Apply
private _aiManagementTooltipText = "";
        _canManageAi = false;

        switch (true) do
        {
            case !(leader player == player):
            {
                _aiManagementTooltipText = localize "STR_antistasi_dialogs_main_ai_management_sl_tooltip";
            };

            case ({!isPlayer _x} count units group player < 1):
            {
                _aiManagementTooltipText = localize "STR_antistasi_dialogs_main_ai_management_no_ai_tooltip";
            };

            default
            {
                _canManageAi = true;
            };
        };
This determines if AI management is available based on player leadership and AI units.

Sqf

Apply
private _aiManagementButton = _display displayCtrl A3A_IDC_AIMANAGEMENTBUTTON;
        private _aiManagementIcon = _display displayCtrl A3A_IDC_AIMANAGEMENTICON;

        if (_canManageAi) then {
            _aiManagementButton ctrlEnable true;
            _aiManagementButton ctrlSetTooltip "";
            _aiManagementIcon ctrlSetTextColor ([A3A_COLOR_WHITE] call A3A_fnc_configColorToArray);
        } else {
            _aiManagementButton ctrlEnable false;
            _aiManagementButton ctrlSetTooltip _aiManagementTooltipText;
            _aiManagementIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
This handles the AI management button state and functionality.

Sqf

Apply
private _playerNameText = _display displayCtrl A3A_IDC_PLAYERNAMETEXT;
        private _playerRankText = _display displayCtrl A3A_IDC_PLAYERRANKTEXT;
        private _playerRankPicture = _display displayCtrl A3A_IDC_PLAYERRANKPICTURE;
        private _aliveText = _display displayCtrl A3A_IDC_ALIVETEXT;
        private _missionsText = _display displayCtrl A3A_IDC_MISSIONSTEXT;
        private _killsText = _display displayCtrl A3A_IDC_KILLSTEXT;
        private _commanderPicture = _display displayCtrl A3A_IDC_COMMANDERPICTURE;
        private _commanderText = _display displayCtrl A3A_IDC_COMMANDERTEXT;
        private _commanderButton = _display displayCtrl A3A_IDC_COMMANDERBUTTON;
        private _moneyText = _display displayCtrl A3A_IDC_MONEYTEXT;

        _playerNameText ctrlSetText name player;

        _playerRankText ctrlSetText ([player, "displayName"] call BIS_fnc_rankParams);
        _playerRankPicture ctrlSetText ([player, "texture"] call BIS_fnc_rankParams);

        private _time = time;
        _aliveText ctrlSetText format [[_time] call A3A_fnc_formatTime];

        private _missions = 0;
        _missionsText ctrlSetText str _missions;

        private _kills = 0;
        _killsText ctrlSetText str _kills;
This updates player stats and information displays.

Sqf

Apply
if (theBoss == player) then {
            // Player is commander
            _commanderPicture ctrlSetText A3A_Icon_PlayerCommander;
            _commanderPicture ctrlSetTextColor ([A3A_COLOR_COMMANDER] call A3A_fnc_configColorToArray);
            _commanderText ctrlSetText localize "STR_antistasi_dialogs_main_commander_text_commander";
            _commanderText ctrlSetTextColor ([A3A_COLOR_COMMANDER] call A3A_fnc_configColorToArray);
            _commanderButton ctrlSetText localize "STR_antistasi_dialogs_main_commander_button_resign";
        } else {
            if (player getVariable ["eligible", false]) then {
                // Player is eligible for commander
                _commanderPicture ctrlSetText A3A_Icon_PlayerEligible;
                _commanderPicture ctrlSetTextColor ([A3A_COLOR_ELIGIBLE] call A3A_fnc_configColorToArray);
                _commanderText ctrlSetText localize "STR_antistasi_dialogs_main_commander_text_eligible";
                _commanderText ctrlSetTextColor ([A3A_COLOR_ELIGIBLE] call A3A_fnc_configColorToArray);
                _commanderButton ctrlSetText localize "STR_antistasi_dialogs_main_commander_button_set_ineligible";
            } else {
                // Player is not eligible for commander
                _commanderPicture ctrlSetText A3A_Icon_PlayerIneligible;
                _commanderPicture ctrlSetTextColor ([A3A_COLOR_INELIGIBLE] call A3A_fnc_configColorToArray);
                _commanderText ctrlSetText localize "STR_antistasi_dialogs_main_commander_text_ineligible";
                _commanderText ctrlSetTextColor ([A3A_COLOR_INELIGIBLE] call A3A_fnc_configColorToArray);
                _commanderButton ctrlSetText localize "STR_antistasi_dialogs_main_commander_button_set_eligible";
            };

        };
This updates commander status displays and buttons.

Sqf

Apply
private _money = player getVariable "moneyX";
        _moneyText ctrlSetText format[localize "STR_antistasi_dialogs_main_player_money_text", A3A_faction_civ get "currencySymbol", _money];
This updates the money display.

Sqf

Apply
private _vehicleGroup = _display displayCtrl A3A_IDC_PLAYERVEHICLEGROUP;
        private _noVehicleGroup = _display displayCtrl A3A_IDC_NOVEHICLEGROUP;

        if ([player] call A3A_fnc_isMember) then {

            _vehicle = cursorObject;
            if !(isNull _vehicle) then {
                if (_vehicle isKindOf "Air" or _vehicle isKindOf "LandVehicle") then {
                    private _className = typeOf _vehicle;
                    private _configClass = configFile >> "CfgVehicles" >> _className;
                    private _displayName = getText (_configClass >> "displayName");
                    private _editorPreview = getText (_configClass >> "editorPreview");

                    private _vehicleNameLabel = _display displayCtrl A3A_IDC_VEHICLENAMELABEL;
                    _vehicleNameLabel ctrlSetText _displayName;
                    _vehicleNameLabel ctrlEnable false;

                    private _vehiclePicture = _display displayCtrl A3A_IDC_VEHICLEPICTURE;
                    _vehiclePicture ctrlSetText _editorPreview;

                    if (player == theBoss) then {
                        if !(_vehicle isKindOf "Air") then {
                            private _addToAirSupportButton = _display displayCtrl A3A_IDC_ADDTOAIRSUPPORTBUTTON;
                            _addToAirSupportButton ctrlEnable false;
                            _addToAirSupportButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_not_eligible_vehicle_tooltip";
                        };
                    } else {
                        private _sellVehicleButton = _display displayCtrl A3A_IDC_SELLVEHICLEBUTTON;
                        _sellVehicleButton ctrlEnable false;
                        _sellVehicleButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_commander_only_tooltip";
                        private _addToAirSupportButton = _display displayCtrl A3A_IDC_ADDTOAIRSUPPORTBUTTON;
                        _addToAirSupportButton ctrlEnable false;
                        _addToAirSupportButton ctrlSetTooltip localize "STR_antistasi_dialogs_main_commander_only_tooltip";
                    };
                    _noVehicleGroup ctrlShow false;
                    _vehicleGroup ctrlShow true;
                } else {
                    _vehicleGroup ctrlShow false;
                    _noVehicleGroup ctrlShow true;
                };
            } else {
                _vehicleGroup ctrlShow false;
                _noVehicleGroup ctrlShow true;
            };
        } else {
            _vehicleGroup ctrlShow false;
            _noVehicleGroup ctrlShow true;
            private _noVehicleText = _display displayCtrl A3A_IDC_NOVEHICLETEXT;
            _noVehicleText ctrlSetText localize "STR_antistasi_dialogs_main_members_only";
        };
This handles vehicle information display and button enable/disable logic.

Where it leads:
This function calls:

A3A_fnc_canGoUndercover - checks if player can go undercover
A3A_fnc_goUndercover - handles going undercover
A3A_fnc_canFastTravel - checks if player can fast travel
A3A_fnc_canBuild - checks if player can build
A3A_fnc_isMember - checks if player is a member
A3A_fnc_formatTime - formats time display
BIS_fnc_rankParams - retrieves rank information
BIS_fnc_colorConfigToRGBA - converts color configuration to array
This function depends on:

Global variables: theBoss, A3A_IDD_MAINDIALOG, A3A_IDC_* IDs, A3A_Icon_* textures, A3A_COLOR_* colors, A3A_faction_civ
Functions: A3A_fnc_canGoUndercover, A3A_fnc_goUndercover, A3A_fnc_canFastTravel, A3A_fnc_canBuild, A3A_fnc_isMember, A3A_fnc_formatTime
UI controls and IDs defined in ids.inc
The function integrates with the main dialog system to display player information and capabilities. It modifies UI elements and requires the main dialog to be open.

Requirements:
Main dialog must be open
Global variables for dialog IDs and textures must be defined
Functions for checking player capabilities must be available
BIS_fnc_rankParams and BIS_fnc_colorConfigToRGBA functions must be available
Player must be in a valid state for the operations to work

Function Name: fn_recruitDialog.sqf
What it does:
Handles the initialization and updating of the Recruit Units dialog. This function manages the recruitment of individual soldier types for the player's faction, including updating prices, enabling/disabling buttons based on available resources, and setting tooltips for disabled controls.

How it does that:
The function operates in two main modes: "onLoad" for initial dialog setup and default mode for error handling. During "onLoad", it retrieves all UI controls, fetches unit prices from server variables, updates price labels, and disables buttons when insufficient funds or HR are available.

Implementation:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Initializes parameters with default mode "onLoad" and empty params array.

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        Debug("RecruitDialog onLoad starting. ..");
Starts the onLoad case, logging the beginning of initialization.

Sqf

Apply
        private _display = findDisplay A3A_IDD_RECRUITDIALOG;
Finds the recruit dialog display using the defined ID.

Sqf

Apply
        private _militiamanIcon = _display displayCtrl A3A_IDC_RECRUITMILITIAMANICON;
        private _militiamanPriceText = _display displayCtrl  A3A_IDC_RECRUITMILITIAMANPRICE;
        private _militiamanButton = _display displayCtrl  A3A_IDC_RECRUITMILITIAMANBUTTON;
        private _autoriflemanIcon = _display displayCtrl  A3A_IDC_RECRUITAUTORIFLEMANICON;
        private _autoriflemanPriceText = _display displayCtrl  A3A_IDC_RECRUITAUTORIFLEMANPRICE;
        private _autoriflemanButton = _display displayCtrl  A3A_IDC_RECRUITAUTORIFLEMANBUTTON;
        private _grenadierIcon = _display displayCtrl  A3A_IDC_RECRUITGRENADIERICON;
        private _grenadierPriceText = _display displayCtrl  A3A_IDC_RECRUITGRENADIERPRICE;
        private _grenadierButton = _display displayCtrl  A3A_IDC_RECRUITGRENADIERBUTTON;
        private _antitankIcon = _display displayCtrl  A3A_IDC_RECRUITANTITANKICON;
        private _antitankPriceText = _display displayCtrl  A3A_IDC_RECRUITANTITANKPRICE;
        private _antitankButton = _display displayCtrl  A3A_IDC_RECRUITANTITANKBUTTON;
        private _medicIcon = _display displayCtrl  A3A_IDC_RECRUITMEDICICON;
        private _medicPriceText = _display displayCtrl  A3A_IDC_RECRUITMEDICPRICE;
        private _medicButton = _display displayCtrl  A3A_IDC_RECRUITMEDICBUTTON;
        private _marksmanIcon = _display displayCtrl  A3A_IDC_RECRUITMARKSMANICON;
        private _marksmanPriceText = _display displayCtrl  A3A_IDC_RECRUITMARKSMANPRICE;
        private _marksmanButton = _display displayCtrl  A3A_IDC_RECRUITMARKSMANBUTTON;
        private _engineerIcon = _display displayCtrl  A3A_IDC_RECRUITENGINEERICON;
        private _engineerPriceText = _display displayCtrl  A3A_IDC_RECRUITENGINEERPRICE;
        private _engineerButton = _display displayCtrl  A3A_IDC_RECRUITENGINEERBUTTON;
        private _bombSpecialistIcon = _display displayCtrl  A3A_IDC_RECRUITBOMBSPECIALISTICON;
        private _bombSpecialistPriceText = _display displayCtrl  A3A_IDC_RECRUITBOMBSPECIALISTPRICE;
        private _bombSpecialistButton = _display displayCtrl  A3A_IDC_RECRUITBOMBSPECIALISTBUTTON;
Retrieves all UI controls for the recruit dialog, including icons, price texts, and buttons for each unit type.

Sqf

Apply
        private _militiamanPrice = server getVariable FactionGet(reb,"unitRifle");
        private _autoriflemanPrice = server getVariable FactionGet(reb,"unitMG");
        private _grenadierPrice = server getVariable FactionGet(reb,"unitGL");
        private _antitankPrice = server getVariable FactionGet(reb,"unitLAT");
        private _medicPrice = server getVariable FactionGet(reb,"unitMedic");
        private _marksmanPrice = server getVariable FactionGet(reb,"unitSniper");
        private _engineerPrice = server getVariable FactionGet(reb,"unitEng");
        private _bombSpecialistPrice = server getVariable FactionGet(reb,"unitExp");
Fetches unit prices from server variables using FactionGet function with different unit types.

Sqf

Apply
        _militiamanPriceText ctrlSetText ((str _militiamanPrice) + A3A_faction_civ get "currencySymbol");
        _autoriflemanPriceText ctrlSetText ((str _autoriflemanPrice) + A3A_faction_civ get "currencySymbol");
        _grenadierPriceText ctrlSetText ((str _grenadierPrice) + A3A_faction_civ get "currencySymbol");
        _antitankPriceText ctrlSetText ((str _antitankPrice) + A3A_faction_civ get "currencySymbol");
        _medicPriceText ctrlSetText ((str _medicPrice) + A3A_faction_civ get "currencySymbol");
        _marksmanPriceText ctrlSetText ((str _marksmanPrice) + A3A_faction_civ get "currencySymbol");
        _engineerPriceText ctrlSetText ((str _engineerPrice) + A3A_faction_civ get "currencySymbol");
        _bombSpecialistPriceText ctrlSetText ((str _bombSpecialistPrice) + A3A_faction_civ get "currencySymbol");
Updates the price labels on the UI with formatted strings including currency symbols.

Sqf

Apply
        private _money = player getVariable "moneyX";
        private _hr = server getVariable "hr";
        if (_money < _militiamanPrice || _hr < 1) then {
            _militiamanButton ctrlEnable false;
            _militiamanButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _militiamanIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Checks if player has sufficient money and HR for each unit type. If not, disables the button and sets tooltip and color.

Sqf

Apply
        if (_money < _autoriflemanPrice || _hr < 1) then {
            _autoriflemanButton ctrlEnable false;
            _autoriflemanButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _autoriflemanIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for autorifleman unit.

Sqf

Apply
        if (_money < _grenadierPrice || _hr < 1) then {
            _grenadierButton ctrlEnable false;
            _grenadierButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _grenadierIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for grenadier unit.

Sqf

Apply
        if (_money < _antitankPrice || _hr < 1) then {
            _antitankButton ctrlEnable false;
            _antitankButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _antitankIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for antitank unit.

Sqf

Apply
        if (_money < _medicPrice || _hr < 1) then {
            _medicButton ctrlEnable false;
            _medicButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _medicIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for medic unit.

Sqf

Apply
        if (_money < _marksmanPrice || _hr < 1) then {
            _marksmanButton ctrlEnable false;
            _marksmanButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _marksmanIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for marksman unit.

Sqf

Apply
        if (_money < _engineerPrice || _hr < 1) then {
            _engineerButton ctrlEnable false;
            _engineerButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _engineerIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for engineer unit.

Sqf

Apply
        if (_money < _bombSpecialistPrice || _hr < 1) then {
            _bombSpecialistButton ctrlEnable false;
            _bombSpecialistButton ctrlSetTooltip "You do not have enough money or HR for this unit type";
            _bombSpecialistIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for bomb specialist unit.

Sqf

Apply
        Debug("RecruitDialog onLoad complete.");
    };
Logs completion of the onLoad process.

Where it leads:
This function calls no other functions directly. It depends on:

A3A_fnc_configColorToArray for color conversion
FactionGet for retrieving faction-specific variables
Server variables for unit pricing and HR
UI controls for updating display elements
Function Name: fn_recruitSquadDialog.sqf
What it does:
Handles the initialization and updating of the Recruit Squad dialog. This function manages the recruitment of squad units including infantry squads, teams, and vehicles, updating prices, enabling/disabling buttons based on available resources, and setting tooltips for disabled controls.

How it does that:
The function operates in three modes: "onLoad" for initial dialog setup, "update" for refreshing the dialog state, and "buySquad" for processing squad purchases. During "onLoad", it initializes the dialog and calls "update" in a scheduled environment. During "update", it retrieves all UI controls, fetches squad prices, updates price labels, and disables buttons when insufficient funds or HR are available.

Implementation:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Initializes parameters with default mode "onLoad" and empty params array.

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        Debug("RecruitSquadDialog onLoad starting. ..");
Starts the onLoad case, logging the beginning of initialization.

Sqf

Apply
        vehQuery = nil;
Sets the global variable vehQuery to nil as part of a temporary fix.

Sqf

Apply
        ["update"] call A3A_fnc_recruitSquadDialog;
Calls the update mode to refresh the dialog state.

Sqf

Apply
        Debug("RecruitSquadDialog onLoad complete.");
    };
Logs completion of the onLoad process.

Sqf

Apply
    case ("update"):
    {
        private _display = findDisplay A3A_IDD_RECRUITSQUADDIALOG;
Finds the recruit squad dialog display using the defined ID.

Sqf

Apply
        private _infSquadIcon = _display displayCtrl A3A_IDC_RECRUITINFSQUADICON;
        private _infSquadPriceText = _display displayCtrl A3A_IDC_RECRUITINFSQUADPRICE;
        private _infSquadButton = _display displayCtrl A3A_IDC_RECRUITINFSQUADBUTTON;
        // TODO UI-update: add engineer squad back in
        // private _engSquadIcon = _display displayCtrl A3A_IDC_RECRUITENGSQUADICON;
        // private _engSquadPriceText = _display displayCtrl A3A_IDC_RECRUITENGSQUADPRICE;
        // private _engSquadButton = _display displayCtrl A3A_IDC_RECRUITENGSQUADBUTTON;
        private _infTeamIcon = _display displayCtrl A3A_IDC_RECRUITINFTEAMICON;
        private _infTeamPriceText = _display displayCtrl A3A_IDC_RECRUITINFTEAMPRICE;
        private _infTeamButton = _display displayCtrl A3A_IDC_RECRUITINFTEAMBUTTON;
        private _mgTeamIcon = _display displayCtrl A3A_IDC_RECRUITMGTEAMICON;
        private _mgTeamPriceText = _display displayCtrl A3A_IDC_RECRUITMGTEAMPRICE;
        private _mgTeamButton = _display displayCtrl A3A_IDC_RECRUITMGTEAMBUTTON;
        private _atTeamIcon = _display displayCtrl A3A_IDC_RECRUITATTEAMICON;
        private _atTeamPriceText = _display displayCtrl A3A_IDC_RECRUITATTEAMPRICE;
        private _atTeamButton = _display displayCtrl A3A_IDC_RECRUITATTEAMBUTTON;
        private _mortarTeamIcon = _display displayCtrl A3A_IDC_RECRUITMORTARTEAMICON;
        private _mortarTeamPriceText = _display displayCtrl A3A_IDC_RECRUITMORTARTEAMPRICE;
        private _mortarTeamButton = _display displayCtrl A3A_IDC_RECRUITMORTARTEAMBUTTON;
        private _sniperTeamIcon = _display displayCtrl A3A_IDC_RECRUITSNIPERTEAMICON;
        private _sniperTeamPriceText = _display displayCtrl A3A_IDC_RECRUITSNIPERTEAMPRICE;
        private _sniperTeamButton = _display displayCtrl A3A_IDC_RECRUITSNIPERTEAMBUTTON;
        private _atCarIcon = _display displayCtrl A3A_IDC_RECRUITATCARICON;
        private _atCarPriceText = _display displayCtrl A3A_IDC_RECRUITATCARPRICE;
        private _atCarButton = _display displayCtrl A3A_IDC_RECRUITATCARBUTTON;
        private _aaTruckIcon = _display displayCtrl A3A_IDC_RECRUITAATRUCKICON;
        private _aaTruckPriceText = _display displayCtrl A3A_IDC_RECRUITAATRUCKPRICE;
        private _aaTruckButton = _display displayCtrl A3A_IDC_RECRUITAATRUCKBUTTON;
Retrieves all UI controls for the recruit squad dialog, including icons, price texts, and buttons for each squad type.

Sqf

Apply
        private _includeVehicleCheckbox = _display displayCtrl A3A_IDC_SQUADINCLUDEVEHICLECHECKBOX;
Retrieves the checkbox control for including vehicles in squad recruitment.

Sqf

Apply
        private _includeVehicle = cbChecked _includeVehicleCheckbox;
Gets the checked state of the vehicle inclusion checkbox.

Sqf

Apply
        private _infSquadVehicle = "";
        // private _engSquadVehicle = "";
        private _infTeamVehicle = "";
        private _mgTeamVehicle = "";
        private _atTeamVehicle = "";
        private _mortarTeamVehicle = "";
        private _sniperTeamVehicle = "";
Initializes vehicle classnames for different squad types.

Sqf

Apply
        if (_includeVehicle) then {
            _infSquadVehicle = [groupsSDKSquad] call A3A_fnc_getHCSquadVehicleType;
            // _engSquadVehicle = [groupsSDKSquadEng] call A3A_fnc_getHCSquadVehicleType;
            _infTeamVehicle = [groupsSDKmid] call A3A_fnc_getHCSquadVehicleType;
            _mgTeamVehicle = [SDKMGStatic] call A3A_fnc_getHCSquadVehicleType;
            _atTeamVehicle = [groupsSDKAT] call A3A_fnc_getHCSquadVehicleType;
            _mortarTeamVehicle = [SDKMortar] call A3A_fnc_getHCSquadVehicleType;
            _sniperTeamVehicle = [groupsSDKSniper] call A3A_fnc_getHCSquadVehicleType;
        };
If vehicle inclusion is checked, retrieves vehicle types for each squad using the getHCSquadVehicleType function.

Sqf

Apply
        _infSquadButton setVariable ["squadType", groupsSDKSquad];
        _infSquadButton setVariable ["vehicle", _infSquadVehicle];
        _infTeamButton setVariable ["squadType", groupsSDKmid];
        _infTeamButton setVariable ["vehicle", _infTeamVehicle];
        _mgTeamButton setVariable ["squadType", SDKMGStatic];
        _mgTeamButton setVariable ["vehicle", _mgTeamVehicle];
        _atTeamButton setVariable ["squadType", groupsSDKAT];
        _atTeamButton setVariable ["vehicle", _atTeamVehicle];
        _mortarTeamButton setVariable ["squadType", SDKMortar];
        _mortarTeamButton setVariable ["vehicle", _mortarTeamVehicle];
        _sniperTeamButton setVariable ["squadType", groupsSDKSniper];
        _sniperTeamButton setVariable ["vehicle", _sniperTeamVehicle];
        _atCarButton setVariable ["squadType", vehSDKAT];
        _atCarButton setVariable ["vehicle", ""];
        _aaTruckButton setVariable ["squadType", staticAAteamPlayer];
        _aaTruckButton setVariable ["vehicle", ""];
Sets variables on each button containing squad type and vehicle information for later use in purchase processing.

Sqf

Apply
        private _infSquadPrice = [groupsSDKSquad, _infSquadVehicle] call A3A_fnc_getHCSquadPrice;
        // private _engSquadPrice = [groupsSDKSquadEng, _engSquadVehicle] call A3A_fnc_getHCSquadPrice;
        private _infTeamPrice = [groupsSDKmid, _infTeamVehicle] call A3A_fnc_getHCSquadPrice;
        private _mgTeamPrice = [SDKMGStatic, _mgTeamVehicle] call A3A_fnc_getHCSquadPrice;
        private _atTeamPrice = [groupsSDKAT, _atTeamVehicle] call A3A_fnc_getHCSquadPrice;
        private _mortarTeamPrice = [SDKMortar, _mortarTeamVehicle] call A3A_fnc_getHCSquadPrice;
        private _sniperTeamPrice = [groupsSDKSniper, _sniperTeamVehicle] call A3A_fnc_getHCSquadPrice;
        private _atCarPrice = [vehSDKAT] call A3A_fnc_getHCSquadPrice;
        private _aaTruckPrice = [staticAAteamPlayer] call A3A_fnc_getHCSquadPrice;
Retrieves prices for each squad type using the getHCSquadPrice function.

Sqf

Apply
        _infSquadPrice params ["_infSquadMoney", "_infSquadHr"];
        // _engSquadPrice params ["_engSquadMoney", "_engSquadHr"];
        _infTeamPrice params ["_infTeamMoney", "_infTeamHr"];
        _mgTeamPrice params ["_mgTeamMoney", "_mgTeamHr"];
        _atTeamPrice params ["_atTeamMoney", "_atTeamHr"];
        _mortarTeamPrice params ["_mortarTeamMoney", "_mortarTeamHr"];
        _sniperTeamPrice params ["_sniperTeamMoney", "_sniperTeamHr"];
        _atCarPrice params ["_atCarMoney", "_atCarHr"];
        _aaTruckPrice params ["_aaTruckMoney", "_aaTruckHr"];
Splits the price arrays into money and HR components.

Sqf

Apply
        _infSquadPriceText ctrlSetText (format ["%1 %2 %3 HR", _infSquadMoney, A3A_faction_civ get "currencySymbol", _infSquadHr]);
        // _engSquadPriceText ctrlSetText (format ["%1 %2, %3 HR", _engSquadPrice, A3A_faction_civ get "currencySymbol", _engSquadHr]);
        _infTeamPriceText ctrlSetText (format ["%1 %2 %3 HR", _infTeamMoney, A3A_faction_civ get "currencySymbol", _infTeamHr]);
        _mgTeamPriceText ctrlSetText (format ["%1 %2 %3 HR", _mgTeamMoney, A3A_faction_civ get "currencySymbol", _mgTeamHr]);
        _atTeamPriceText ctrlSetText (format ["%1 %2 %3 HR", _atTeamMoney, A3A_faction_civ get "currencySymbol", _atTeamHr]);
        _mortarTeamPriceText ctrlSetText (format ["%1 %2 %3 HR", _mortarTeamMoney, A3A_faction_civ get "currencySymbol", _mortarTeamHr]);
        _sniperTeamPriceText ctrlSetText (format ["%1 %2 %3 HR", _sniperTeamMoney, A3A_faction_civ get "currencySymbol", _sniperTeamHr]);
        _atCarPriceText ctrlSetText (format ["%1 %2 %3 HR", _atCarMoney, A3A_faction_civ get "currencySymbol", _atCarHr]);
        _aaTruckPriceText ctrlSetText (format ["%1 %2 %3 HR", _aaTruckMoney, A3A_faction_civ get "currencySymbol", _aaTruckHr]);
Updates the price labels on the UI with formatted strings including currency symbols and HR requirements.

Sqf

Apply
        private _money = server getVariable "resourcesFIA";
        private _hr = server getVariable "hr";
        if (_money < _infSquadMoney || _hr < _infSquadHr) then {
            _infSquadButton ctrlEnable false;
            _infSquadButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _infSquadIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Checks if player has sufficient money and HR for infantry squad. If not, disables the button and sets tooltip and color.

Sqf

Apply
        /* if (_money < _engSquadMoney || _hr < _engSquadHr) then {
            _engSquadButton ctrlEnable false;
            _engSquadButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _engSquadIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        }; */
Commented out logic for engineer squad (temporarily disabled).

Sqf

Apply
        if (_money < _infTeamMoney || _hr < _infTeamHr) then {
            _infTeamButton ctrlEnable false;
            _infTeamButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _infTeamIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for infantry team.

Sqf

Apply
        if (_money < _mgTeamMoney || _hr < _mgTeamHr) then {
            _mgTeamButton ctrlEnable false;
            _mgTeamButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _mgTeamIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for MG team.

Sqf

Apply
        if (_money < _atTeamMoney || _hr < _atTeamHr) then {
            _atTeamButton ctrlEnable false;
            _atTeamButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _atTeamIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for AT team.

Sqf

Apply
        if (_money < _mortarTeamMoney || _hr < _mortarTeamHr) then {
            _mortarTeamButton ctrlEnable false;
            _mortarTeamButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _mortarTeamIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for mortar team.

Sqf

Apply
        if (_money < _sniperTeamMoney || _hr < _sniperTeamHr) then {
            _sniperTeamButton ctrlEnable false;
            _sniperTeamButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _sniperTeamIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for sniper team.

Sqf

Apply
        if (_money < _atCarMoney || _hr < _atCarHr) then {
            _atCarButton ctrlEnable false;
            _atCarButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _atCarIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for AT car.

Sqf

Apply
        if (_money < _aaTruckMoney || _hr < _aaTruckHr) then {
            _aaTruckButton ctrlEnable false;
            _aaTruckButton ctrlSetTooltip "You do not have enough money or HR for this group type";
            _aaTruckIcon ctrlSetTextColor ([A3A_COLOR_BUTTON_BACKGROUND_DISABLED] call A3A_fnc_configColorToArray);
        };
Same logic for AA truck.

Sqf

Apply
    case ("buySquad"):
    {
        private _button = (_params # 0) # 0;
        private _squadType = _button getVariable ["squadType", []];
        private _vehicle = _button getVariable ["vehicle", ""];
        // TODO UI-update: Temporary fix so this just works, to be replaced with something more sensible
        if (_vehicle isNotEqualTo "") then {vehQuery = true};
        closeDialog 1;
        // Previous format, to be changed back to this
        // [_squadType, _vehicle] spawn A3A_fnc_addFIAsquadHC;
        [_squadType] spawn A3A_fnc_addFIAsquadHC;
    };
Handles the purchase of squads by retrieving squad type and vehicle information from button variables, setting a temporary global variable, closing the dialog, and spawning the addFIAsquadHC function.

Where it leads:
This function calls:

A3A_fnc_getHCSquadVehicleType for vehicle type retrieval
A3A_fnc_getHCSquadPrice for price calculation
A3A_fnc_configColorToArray for color conversion
A3A_fnc_addFIAsquadHC for squad creation
Server variables for resource and HR information
UI controls for updating display elements
Function Name: fn_requestMissionDialog.sqf
What it does:
Handles controls on the Request Mission dialog, specifically processing mission requests from players. This function validates player permissions, mission types, and then sends a remote execution request to the server to process the mission.

How it does that:
The function operates in one mode: "missionButtonClicked". It validates that the player is either a member or commander, checks that the mission type parameter is valid, and then sends a remote execution request to the server to process the mission request.

Implementation:
Sqf

Apply
params[["_mode",""], ["_params",[]]];
Initializes parameters with default empty mode and empty params array.

Sqf

Apply
switch (_mode) do
{
    case ("missionButtonClicked"):
    {
        Trace("Request mission button clicked");
Starts the missionButtonClicked case, logging the button click event.

Sqf

Apply
        if !(([player] call A3A_fnc_isMember) or (not(isPlayer theBoss))) exitWith
        {
            [localize "STR_mission_request_header", localize "STR_generic_commander_only"] call A3A_fnc_customHint;
            closeDialog 2;
        };
Checks if player is either a member or commander. If not, shows a hint and closes the dialog.

Sqf

Apply
        if (count _params != 1) exitWith {Error("Invalid parameter count for missionButtonClicked. Got %1, expected 1", count _params)};
Validates that exactly one parameter was passed.

Sqf

Apply
        private _missionType = _params select 0;
Retrieves the mission type from parameters.

Sqf

Apply
        private _missionTypes = [
            "AS",
            "CONVOY",
            "DES",
            "CON",
            "LOG",
            "SUPP",
            "RES"
        ];
Defines valid mission types.

Sqf

Apply
        if !(_missionType in _missionTypes) exitWith
        {
            Error_1("Mission type does not exist: %1", _missionType);
            closeDialog 2;
        };
Checks if the mission type is valid. If not, logs error and closes dialog.

Sqf

Apply
        [_missionType, clientOwner] remoteExec ["A3A_fnc_missionRequest", 2];
Sends a remote execution request to the server to process the mission request.

Sqf

Apply
        closeDialog 1;
Closes the dialog.

Where it leads:
This function calls:

A3A_fnc_isMember for player membership validation
A3A_fnc_customHint for displaying hints
A3A_fnc_missionRequest for processing the mission request
Server variables for clientOwner information
Remote execution for network communication
Function Name: fn_setUpPlacerHints.sqf
What it does:
Creates and manages the controls for the placer hints dialog, displaying keyboard shortcuts for building placement actions. This function handles both initial setup and context-specific updates for the hints display.

How it does that:
The function operates in two modes: "onLoad" for initial dialog setup and "setContextKey" for updating context-specific hints. During "onLoad", it initializes the hint text controls with keyboard shortcuts. During "setContextKey", it updates the display based on the current context.

Implementation:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Initializes parameters with default mode "onLoad" and empty params array.

Sqf

Apply
switch (_mode) do
{
    case ("onLoad"):
    {
        _params params[["_display", displayNull, [displayNull]]];
Starts the onLoad case, extracting the display parameter.

Sqf

Apply
        private _altText = (_display displayCtrl IDC_PLACERHINT_ALT_TEXT);
        private _eText = (_display displayCtrl IDC_PLACERHINT_E_TEXT);
        private _rText = (_display displayCtrl IDC_PLACERHINT_R_TEXT);
        private _shiftText = (_display displayCtrl IDC_PLACERHINT_SHIFT_TEXT);
        private _spaceText = (_display displayCtrl IDC_PLACERHINT_SPACE_TEXT);
Retrieves all text controls for the hint display.

Sqf

Apply
        _altText ctrlSetText format ["%1 %2", ACTION_KEY(buildingPlacerSnapToSurface), localize "str_3den_display3den_entitymenu_movesurface_text"];
        _eText ctrlSetText format["%1: Rotate counter-clockwise", ACTION_KEY(buildingPlacerRotateCCW)];
        _rText ctrlSetText format["%1: Rotate clockwise", ACTION_KEY(buildingPlacerRotateCW)];
        _shiftText ctrlSetText format["%1: Unsafe placement mode", ACTION_KEY(buildingPlacerUnsafeMode)];
        _spaceText ctrlSetText format["%1: Place object", ACTION_KEY(buildingPlacerPlace)];
Sets text for each hint control with keyboard shortcuts and localized descriptions.

Sqf

Apply
        uiNamespace setVariable ["A3A_placerHint_display", _display];
Stores the display in the UI namespace for later access.

Sqf

Apply
    case ("setContextKey"):
    {
        private _display = uiNamespace getVariable "A3A_placerHint_display";
        if (isNil "_display") exitWith {};
Starts the setContextKey case, retrieving the stored display and exiting if not found.

Sqf

Apply
        _params params ["_keyType", "_keyData"];
Extracts key type and data from parameters.

Sqf

Apply
        (_display displayCtrl IDC_PLACERHINT_C) ctrlShow false;
        (_display displayCtrl IDC_PLACERHINT_T) ctrlShow false;
        private _textCtrl = (_display displayCtrl IDC_PLACERHINT_C_TEXT);
Hides context-specific controls and retrieves the text control.

Sqf

Apply
        if (_keyType == "cancel") exitWith {
            (_display displayCtrl IDC_PLACERHINT_C) ctrlShow true;
            _textCtrl ctrlSetText format ["%1: Cancel %2", ACTION_KEY(buildingPlacerDelete), _keyData];
        };
Handles cancel context by showing cancel control and setting appropriate text.

Sqf

Apply
        if (_keyType == "rebuild") exitWith {
            (_display displayCtrl IDC_PLACERHINT_T) ctrlShow true;
            _textCtrl ctrlSetText format ["%1: Rebuild for %2 %3", ACTION_KEY(buildingPlacerRepair), _keyData, A3A_faction_civ get "currencySymbol"];
        };
Handles rebuild context by showing rebuild control and setting appropriate text with currency symbol.

Sqf

Apply
        _textCtrl ctrlSetText "";
Sets empty text if neither cancel nor rebuild context.

Where it leads:
This function calls:

ACTION_KEY for retrieving keyboard shortcuts
localize for localized text
uiNamespace for storing/retrieving display reference
Control functions for showing/hiding and setting text
Server variables for faction currency symbol
Function Name: fn_teamLeaderRTSPlacerDialog.sqf
What it does:
Creates and manages the controls for the team leader RTS placer dialog, displaying buildable objects with prices and handling object placement. This function dynamically generates UI elements for each buildable object based on configuration data.

How it does that:
The function operates in two modes: "updateMoney" for updating money display and "onLoad" for creating UI controls. During "onLoad", it creates controls for each buildable object, sets up event handlers, and manages the layout of the buildable items.

Implementation:
Sqf

Apply
params[["_mode","onLoad"], ["_params",[]]];
Initializes parameters with default mode "onLoad" and empty params array.

Sqf

Apply
switch (_mode) do
{
	case ("updateMoney"):
	{
		private _display = findDisplay A3A_IDD_TEAMLEADERDIALOG;
		private _moneyCtrl = _display displayCtrl A3A_IDC_TEAMLEADERBUILDERMONEY;
Starts the updateMoney case, finding the dialog and money control.

Sqf

Apply
		_moneyCtrl ctrlSetText format ["%1 %2", A3A_building_EHDB # AVAILABLE_MONEY, A3A_faction_civ get "currencySymbol"];
Updates the money display with formatted currency string.

Sqf

Apply
	case ("onLoad"):
    {
		private _display = findDisplay A3A_IDD_TEAMLEADERDIALOG;
		private _parent = (_display displayCtrl A3A_IDC_TEAMLEADERBUILDERMAIN);
		private _buildControlsGroup = _parent controlsGroupCtrl A3A_IDC_TEAMLEADERBUILDINGGROUP;
Starts the onLoad case, finding the dialog and parent controls.

Sqf

Apply
		private _moneyCtrl = _display displayCtrl A3A_IDC_TEAMLEADERBUILDERMONEY;
		_moneyCtrl ctrlSetText format ["%1 %2", A3A_building_EHDB # AVAILABLE_MONEY, A3A_faction_civ get "currencySymbol"];
Initializes money display with current available money.

Sqf

Apply
		private _buildableObjects = A3A_buildableObjects;
Retrieves the list of buildable objects from global variable.

Sqf

Apply
		private _boxWidth = round ((ctrlPosition _buildControlsGroup # 2) / GRID_W);
		private _itemsPerRow = floor ((_boxWidth - 6) / 36);
		private _itemWidth = floor ((_boxWidth - 6 - 4*_itemsPerRow) / _itemsPerRow);
Calculates layout parameters for the buildable items grid.

Sqf

Apply
		{
			_x params [
				["_className", "Land_Tyres_F"],
				["_price", 0]
			];
Iterates through buildable objects, extracting class name and price.

Sqf

Apply
			private _configClass = configFile >> "CfgVehicles" >> _className;
			private _displayName = getText (_configClass >> "displayName");
			private _editorPreview = getText (_configClass >> "editorPreview");
			private _model = getText (_configClass >> "model");
Retrieves configuration data for the buildable object.

Sqf

Apply
			private _hasVehiclePreview = fileExists _editorPreview;
            if (!_hasVehiclePreview) then {
                _editorPreview = A3A_PlaceHolder_NoVehiclePreview;
            };
Checks for preview file and uses placeholder if not found.

Sqf

Apply
			private _itemXpos = (4 + (4 + _itemWidth) * (_forEachIndex % _itemsPerRow)) * GRID_W;
			private _itemYpos = (floor (_forEachIndex / _itemsPerRow)) * (34 * GRID_H);
Calculates position for the current item in the grid.

Sqf

Apply
			private _itemControlsGroup = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", A3A_IDC_TEAMLEADERBUILDITEMGROUP, _buildControlsGroup];
			_itemControlsGroup ctrlSetPosition[_itemXpos, _itemYpos, _itemWidth * GRID_W, 30 * GRID_H];
			_itemControlsGroup ctrlSetFade 1;
			_itemControlsGroup ctrlCommit 0;
Creates and positions the item controls group.

Sqf

Apply
			private _previewPicture = _display ctrlCreate ["A3A_Picture", A3A_IDC_TEAMLEADERBUILDIMAGEPREVIEW, _itemControlsGroup];
			_previewPicture ctrlSetPosition [0, 0, _itemWidth * GRID_W, 24 * GRID_H];
			_previewPicture ctrlSetText _editorPreview;
			_previewPicture ctrlCommit 0;
Creates and positions the preview picture control.

Sqf

Apply
			private _button = _display ctrlCreate ["A3A_ButtonSmallText", A3A_IDC_TEAMLEADERBUILDBUTTON, _itemControlsGroup];
			_button ctrlSetPosition [0, 24 * GRID_H, _itemWidth * GRID_W, 6 * GRID_H];
			_button ctrlSetText _displayName;
			_button setVariable ["className", _className];
			_button setVariable ["model", _model];
			_button setVariable ["price", _price];
			_button ctrlCommit 0;
Creates and positions the button control, setting variables for later use.

Sqf

Apply
			_button ctrlAddEventHandler ["ButtonDown", {
				params ["_control"];

				if(isNil "A3A_building_EHDB") then {
					// how the fuck did you do this? No databases?
					call A3A_initBuildingDB;
				};

				private _object = (A3A_building_EHDB # BUILD_OBJECT_TEMP_OBJECT);
				private _className = _control getVariable ["className", "Land_Tyres_F"];
				if (_className == typeof _object) exitWith {};
Adds event handler for button click, initializing database if needed.

Sqf

Apply
				private _price = _control getVariable ["price", 0];
				private _supply = A3A_building_EHDB # AVAILABLE_MONEY;
				if (_price > _supply) exitWith {};
Retrieves price and checks if player has sufficient funds.

Sqf

Apply
				A3A_building_EHDB set [BUILD_OBJECT_SELECTED_STRING, _className];
				A3A_building_EHDB set [OBJECT_PRICE, _price];

				private _vehPos =  getPosATL _object;
				private _vehDir = getDir _object;
				deleteVehicle _object;

				_object = _className createVehicleLocal [0,0,0];
				_object enableSimulation false;
				_object hideObject true;
				_object setPos _vehPos;
				_object setDir _vehDir;
				_object setVariable[QEGVAR(core,isTempObject), true, true];
				A3A_building_EHDB set [BUILD_OBJECT_TEMP_OBJECT, _object];
				call (A3A_building_EHDB # UPDATE_BB);
Sets selected object, creates new temporary object, and updates the database.

Sqf

Apply
			if (_price isNotEqualTo 0) then {
				private _priceText = _display ctrlCreate ["A3A_InfoTextRight", -1, _itemControlsGroup];
				_priceText ctrlSetPosition[(_itemWidth - 21) * GRID_W, 20 * GRID_H, 20 * GRID_W, 3 * GRID_H];
				_priceText ctrlSetText format ["%1 %2",_price,A3A_faction_civ get "currencySymbol"];
				_priceText ctrlCommit 0;
			};
Creates and positions price text if price is not zero.

Sqf

Apply
			private _buildTime = _display ctrlCreate ["A3A_PictureStroke", -1, _itemControlsGroup];
			_buildTime ctrlSetPosition[1 * GRID_W, 19 * GRID_H, 4 * GRID_W, 4 * GRID_H];
			_buildTime ctrlSetText A3A_Icon_Construct;
			_buildTime ctrlCommit 0;
Creates and positions the build time icon.

Sqf

Apply
			_itemControlsGroup ctrlSetFade 0;
            _itemControlsGroup ctrlCommit 0.1;
Makes the item controls group visible with animation.

Sqf

Apply
		} forEach _buildableObjects;
Ends the forEach loop through buildable objects.

Sqf

Apply
		// EH to block camera zoom while mouse is over the selection dialog
		_display displayAddEventHandler ["MouseMoving", {
Adds mouse moving event handler to block camera zoom.

Sqf

Apply
			params[ "_display" ];

			private _scrollArea = _display displayCtrl A3A_IDC_TEAMLEADERBUILDERMAIN;
			ctrlPosition _scrollArea params ["_xpos", "_ypos", "_width", "_height"];

			private _isMouseInArea = getMousePosition inArea [[_xpos + _width/2, _ypos + _height/2], _width/2, _height/2, 0, true];

			if (_isMouseInArea) then {
				A3A_cam camCommand "manual off";
			} else {
				A3A_cam camCommand "manual on";
			};
Handles mouse movement to control camera zoom behavior.

Where it leads:
This function calls:

A3A_initBuildingDB for database initialization
A3A_building_EHDB for database access
Control creation functions for UI elements
Event handlers for button interactions
Server variables for faction currency symbol
Database functions for building object management
Camera control functions for UI interaction

Function Name: fn_directChildCtrls.sqf What it does: Returns a list of controls that are the direct children controls of a controlsGroup. This function filters all controls in a given control group to only include those whose parent control group matches the input control group.

How it does that:

The function takes a single parameter _this which represents the control group to query
It retrieves all controls in the mission using allControls _this
It filters these controls using a select statement to only include those where ctrlParentControlsGroup _x isEqualTo _this is true
This ensures only direct children of the specified control group are returned
Implementation:

Sqf

Apply
(allControls _this) select {ctrlParentControlsGroup _x isEqualTo _this};
The function uses the built-in allControls function to get all controls in the mission, then filters them using the select statement. For each control _x in the list, it checks if the parent control group of that control (ctrlParentControlsGroup _x) is equal to the input control group (_this). This ensures only direct children are returned.

Where it leads: This function is called by 
fn_emplaceControl.sqf
 and 
fn_sortCGList.sqf
 to get the list of child controls for a given control group.

Requirements:

Input parameter _this must be a valid control group control
The function returns an array of controls or an empty array if no children exist
No global variables are modified
No network synchronization is required
Function Name: fn_emplaceControl.sqf What it does: Creates a new control of a specified type and places it at the bottom of a controls group list. This function is used to dynamically add controls to a control group container.

How it does that:

Validates input parameters including the parent control group and control class name
Gets the list of existing child controls using directChildCtrls function
Calculates the Y position for the new control based on the last existing child's position
Creates the new control using ctrlCreate with the specified class and parent
Sets the new control's Y position and commits the change
Implementation:

Sqf

Apply
//validate arguments
if (!params [
    ["_parent", controlNull, [controlNull]]
    , ["_ctrlClass", "", [""]]
]) exitWith {controlNull};
This validates that _parent is a control and _ctrlClass is a string. If validation fails, it exits with controlNull.

Sqf

Apply
//get the position to place at the bottom of the list
private _children = _parent call FUNC(directChildCtrls);
private _count = count _children -1;
private _yNew = if (_count < 0 ) then {0} else {
    ctrlPosition (_children # _count) params ["", "_y", "", "_h"];
    SPACER + _y + _h;
};
This gets all direct child controls, calculates the count, and determines the Y position for the new control. If there are no children, it starts at Y=0. Otherwise, it gets the position of the last child and adds the spacer and height to position the new control below it.

Sqf

Apply
// create new control and place it
private _ctrl = (ctrlParent _parent) ctrlCreate [_ctrlClass, -1, _parent];
_ctrl ctrlSetPositionY _yNew;
_ctrl ctrlCommit 0;
This creates the new control using ctrlCreate with the parent control, control class, and parent control group. It then sets the Y position and commits the change.

Where it leads: This function calls directChildCtrls to get the list of existing children. It is called by functions that need to dynamically add controls to control groups.

Requirements:

_parent must be a valid control group control
_ctrlClass must be a valid control class string
Returns the created control or controlNull if failed
No global variables are modified
No network synchronization is required
Function Name: fn_sortCGList.sqf What it does: Sorts a controls group list by repositioning all child controls to maintain proper vertical spacing. This function is used after mid-list deletions to correct the positions of controls in a control group.

How it does that:

Validates the input control group parameter
Iterates through all direct child controls of the control group
For each control, sets its Y position to the current cumulative Y position
Updates the cumulative Y position by adding the control's height plus a spacer value
Commits each control's position change
Implementation:

Sqf

Apply
//validate arguments
if (!params [
    ["_ctrlGroup", controlNull, [controlNull]]
]) exitWith {false};
This validates that _ctrlGroup is a valid control. If validation fails, it exits with false.

Sqf

Apply
private _posY = 0;
{
    _x ctrlSetPositionY _posY;
    _posY = _posY + ((ctrlPosition _x) #3) + SPACER;
    _x ctrlCommit 0;
} forEach (_ctrlGroup call FUNC(directChildCtrls));
This initializes _posY to 0, then iterates through all direct child controls. For each control, it sets the Y position to the current _posY, then updates _posY by adding the control's height (index 3 of position array) plus the SPACER value. Finally, it commits the position change.

Where it leads: This function calls directChildCtrls to get the list of child controls to sort. It is called by functions that need to maintain proper control positioning after modifications.

Requirements:

_ctrlGroup must be a valid control group control
Returns true if successful, false if failed
No global variables are modified
No network synchronization is required
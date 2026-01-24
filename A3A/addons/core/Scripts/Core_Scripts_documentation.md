File: A3A/addons/core/Scripts/MagRepack/Scripts/MagRepack_Keybindings.sqf
Function Name: outlw_MR_openKeybindings What it does: This function initializes and displays the Mag Repack keybindings configuration dialog. It populates the dialog with the player's current keybinding settings (shift, ctrl, alt, and the key itself) and visually indicates which modifiers are active. It is triggered when the user clicks the "Keybindings" button in the main Mag Repack dialog. How it does that:

Dialog Creation: It creates the MagRepack_Dialog_Keybindings dialog.
State Flag: It sets the global variable outlw_MR_keybindingMenuActive to true to indicate the keybindings menu is open.
Local Caching: It copies the current global keybinding settings (outlw_MR_shift, outlw_MR_ctrl, outlw_MR_alt, outlw_MR_keybinding) into local variables (outlw_KB_cShift, etc.) used during the editing session.
UI Update: It calls outlw_KB_updateKeyText to display the name of the current key.
Button State: It disables the "Apply" button (IDC 2401) initially because no changes have been made.
Visual Feedback: It checks the boolean values of the modifiers and changes the background color of the corresponding UI buttons (IDCs 2500, 2501, 2502) to indicate they are active.
Sqf

Apply
// Creates the dialog and sets the active state flag
createDialog "MagRepack_Dialog_Keybindings";
outlw_MR_keybindingMenuActive = true;

// Caches current global settings into local variables for the editing session
outlw_KB_cShift = outlw_MR_shift;
outlw_KB_cCtrl = outlw_MR_ctrl;
outlw_KB_cAlt = outlw_MR_alt;
outlw_KB_cKey = outlw_MR_keybinding;

// Updates the text display to show the current key
call outlw_KB_updateKeyText;

// Disables the Apply button initially (IDC 2401)
((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2401) ctrlEnable false;

// Visualizes active modifiers by changing background color
// Shift Button (IDC 2500)
if (outlw_KB_cShift) then {
    ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2500) ctrlSetBackgroundColor [1, 1, 1, 0.25];
};
// Ctrl Button (IDC 2501)
if (outlw_KB_cCtrl) then {
    ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2501) ctrlSetBackgroundColor [1, 1, 1, 0.25];
};
// Alt Button (IDC 2502)
if (outlw_KB_cAlt) then {
    ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2502) ctrlSetBackgroundColor [1, 1, 1, 0.25];
};
Where it leads:

Calls: outlw_KB_updateKeyText, outlw_KB_enableApply.
Depended on by: outlw_MR_keyDown (triggered by the main menu button click).
Global Variables Modified: outlw_MR_keybindingMenuActive.
UI Dependencies: Requires MagRepack_Dialog_Keybindings with controls 2401, 2499, 2500, 2501, 2502.
Function Name: outlw_MR_applyKeybinding What it does: This function saves the new keybinding configuration to the profile namespace and updates the active keybinding variables. It handles the logic for distinguishing between a user clicking "Apply" versus clicking "Reset to Default." How it does that:

Input Handling: Accepts an array argument. The first element is the new keybinding list [shift, ctrl, alt, key]. The second element (if present) is a boolean flag indicating if this is a reset operation.
Global Update: Copies the input array to the global outlw_MR_keyList and saves it to the profileNamespace for persistence.
Runtime Update: Extracts the individual components (shift, ctrl, alt, key) from the list and updates the global state variables (outlw_MR_shift, outlw_MR_ctrl, etc.).
Feedback Determination: Checks the reset flag. If true, it uses the localized "reset" string; otherwise, it uses the "update" string.
UI Closure: If not a reset (standard Apply), it closes the dialog (ID 0).
System Notification: Sends a chat message confirming the action and displaying the new keybinding string.
Sqf

Apply
// Takes the new keylist as argument, optionally a reset flag
private ["_systemString"];

// Update the global keylist array
outlw_MR_keyList =+ (_this select 0);
// Persist to profile
profileNamespace setVariable ["outlw_MR_keyList_profile", outlw_MR_keyList];

// Update individual runtime variables
outlw_MR_shift = outlw_MR_keyList select 0;
outlw_MR_ctrl = outlw_MR_keyList select 1;
outlw_MR_alt = outlw_MR_keyList select 2;
outlw_MR_keybinding = outlw_MR_keyList select 3;

// Determine message type based on reset flag (optional second argument)
if (count _this > 1 && {_this select 1}) then {
    _systemString = localize "STR_magRepack_keybind_reset";
} else {
    _systemString = localize "STR_magRepack_keybind_update";
    closeDialog 0;
};

// Display confirmation
systemChat (_systemString + (call outlw_MR_keyListToString));
Where it leads:

Calls: outlw_MR_keyListToString.
Depended on by: outlw_MR_keyDown (via backspace reset), UI "Apply" button click event.
Global Variables Modified: outlw_MR_keyList, outlw_MR_shift, outlw_MR_ctrl, outlw_MR_alt, outlw_MR_keybinding.
Network Implications: None (local only).
Function Name: outlw_KB_keyDown What it does: This is the event handler triggered when a key is pressed while the keybindings dialog is open. It captures the new key assignment (ignoring the modifier keys), updates the UI, and enables the Apply button if the key differs from the current setting. How it does that:

Key Filter: Checks if the pressed key (_this select 1) is not the Escape key (DIK code 1). If it is Escape, the function does nothing, allowing the dialog to close normally.
State Update: Updates the local edit variable outlw_KB_cKey with the new key code.
UI Refresh: Calls outlw_KB_updateKeyText to show the new key name in the UI.
Validation: Calls outlw_KB_enableApply to check if the new combination differs from the saved configuration. If it does, the Apply button is enabled.
Event Consumption: Returns true to prevent the key press from propagating to other handlers (like closing the dialog accidentally).
Sqf

Apply
// Check if the pressed key is not Escape (DIK code 1)
if ((_this select 1) != 1) then {
    // Update the local key variable with the new key code
    outlw_KB_cKey = _this select 1;
    
    // Update UI text and button state
    call outlw_KB_updateKeyText;
    call outlw_KB_enableApply;
    
    // Consume the event
    true;
};
Where it leads:

Calls: outlw_KB_updateKeyText, outlw_KB_enableApply.
Depended on by: The dialog's KeyDown event handler (likely defined in the RscDisplay or via findDisplay logic in outlw_MR_init).
Global Variables Modified: outlw_KB_cKey.
UI Dependencies: Requires control 2499 (Key text display).
Function Name: outlw_KB_enableApply What it does: This function compares the currently edited keybinding (stored in local variables) with the previously saved keybinding (stored in global variables). It enables or disables the "Apply" button based on whether a change has been detected. How it does that:

Array Construction: Creates a temporary array outlw_MR_keyList representing the current edit state: [outlw_KB_cShift, outlw_KB_cCtrl, outlw_KB_cAlt, outlw_KB_cKey].
Comparison: Uses BIS_fnc_areEqual to compare the global saved key list with the temporary edit list.
UI Logic: If the arrays are not equal (a change exists), it enables the Apply button (IDC 2401). If they are equal (no change), it disables the button.
Sqf

Apply
// Compare global saved list with local edited list
if !([outlw_MR_keyList, [outlw_KB_cShift, outlw_KB_cCtrl, outlw_KB_cAlt, outlw_KB_cKey]] call BIS_fnc_areEqual) then {
    // Enable Apply button (IDC 2401) if different
    ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2401) ctrlEnable true;
} else {
    // Disable if same
    ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2401) ctrlEnable false;
};
Where it leads:

Calls: BIS_fnc_areEqual.
Depended on by: outlw_KB_keyDown, outlw_KB_modifierSwitch.
Global Variables Modified: None.
UI Dependencies: Control 2401.
Function Name: outlw_KB_updateKeyText What it does: Updates the text label in the keybindings dialog to display the name of the key currently selected for assignment (e.g., "F", "R", "Space"). How it does that:

Key Name Lookup: Uses the engine command keyName with the integer key code outlw_KB_cKey.
UI Update: Sets the text of control 2499 to the result.
Sqf

Apply
// Set control 2499 text to the name of the key code
((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2499) ctrlSetText (keyName outlw_KB_cKey);
Where it leads:

Calls: keyName (engine command).
Depended on by: outlw_MR_openKeybindings, outlw_KB_keyDown, outlw_KB_modifierSwitch.
Global Variables Modified: None.
UI Dependencies: Control 2499.
Function Name: outlw_KB_modifierSwitch What it does: Toggles the state (active/inactive) of a modifier key (Shift, Ctrl, or Alt) based on user input. It updates the visual appearance of the corresponding button and re-evaluates the Apply button state. How it does that:

Parameter Parsing: Takes the modifier index (0=Shift, 1=Ctrl, 2=Alt) via _this select 0.
Logic Branching: Uses if/else blocks to handle each modifier.
State Toggling:
Checks the current boolean value of the local modifier variable (e.g., outlw_KB_cShift).
If false: Sets it to true and changes the button background color to a "selected" state ([1, 1, 1, 0.25]).
If true: Sets it to false and changes the button background color to a "deselected" state ([0, 0, 0, 0.8]).
UI Refresh: Calls outlw_KB_updateKeyText (though strictly speaking, modifiers don't change the key name, it's a safe refresh) and outlw_KB_enableApply to update the Apply button status.
Sqf

Apply
// Take modifier index (0, 1, 2)
private _mod = _this select 0;

// Handle Shift (0)
if (_mod == 0) then {
    if (!outlw_KB_cShift) then {
        ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2500) ctrlSetBackgroundColor [1, 1, 1, 0.25];
        outlw_KB_cShift = true;
    } else {
        ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2500) ctrlSetBackgroundColor [0, 0, 0, 0.8];
        outlw_KB_cShift = false;
    };
}
// Handle Ctrl (1)
else {
    if (_mod == 1) then {
        if (!outlw_KB_cCtrl) then {
            ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2501) ctrlSetBackgroundColor [1, 1, 1, 0.25];
            outlw_KB_cCtrl = true;
        } else {
            ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2501) ctrlSetBackgroundColor [0, 0, 0, 0.8];
            outlw_KB_cCtrl = false;
        };
    }
    // Handle Alt (2)
    else {
        if (_mod == 2) then {
            if (!outlw_KB_cAlt) then {
                ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2502) ctrlSetBackgroundColor [1, 1, 1, 0.25];
                outlw_KB_cAlt = true;
            } else {
                ((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2502) ctrlSetBackgroundColor [0, 0, 0, 0.8];
                outlw_KB_cAlt = false;
            };
        };
    };
};

// Refresh UI elements
call outlw_KB_updateKeyText;
call outlw_KB_enableApply;
Where it leads:

Calls: outlw_KB_updateKeyText, outlw_KB_enableApply.
Depended on by: UI button clicks (likely mapped to IDCs 2500, 2501, 2502).
Global Variables Modified: outlw_KB_cShift, outlw_KB_cCtrl, outlw_KB_cAlt.
UI Dependencies: Controls 2500, 2501, 2502.
File: A3A/addons/core/Scripts/MagRepack/Scripts/MagRepack_Main.sqf
Function Name: outlw_MR_createDialog What it does: Initializes and displays the main Mag Repack dialog. It handles the UI setup, filtering, visual effects, and background monitoring of player inventory. How it does that:

Variable Reset: Resets all internal tracking variables (source/target types, counts, filters) to their default states.
Dialog Creation: Creates MagRepack_Dialog_Main.
UI Header: Sets the title text to include the version number.
Visual Effects: Applies a blur effect (DynamicBlur) to the screen to focus attention on the dialog.
Animation: Checks if the player is on foot. If so, it plays an appropriate weapon handling animation based on stance and weapon type.
Filter Setup: Populates the ammo filter combo box (IDC 22170) and initializes it.
Inventory Population: Populates the magazine list box (IDC 1500) with player magazines.
Button States: Enables source and target drop zones.
Info Bar: Updates the debug info, full magazine visibility toggle text, and adds links to Keybindings and About dialogs.
Monitor Loop: Spawns a background loop that runs as long as the dialog is open. It constantly checks magazinesAmmo player. If the inventory changes, it refreshes the list box automatically.
Sqf

Apply
// Reset internal state
private ["_stance", "_raised", "_weapon"];
// ... (initialization of outlw_MR_sourceType, outlw_MR_targetType, etc. to default values) ...

// Create main dialog
createDialog "MagRepack_Dialog_Main";

// Set version text
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1001) ctrlSetText ("Mag Repack [" + outlw_MR_version + "]");

// Create and apply screen blur
outlw_MR_blur = ppEffectCreate ["DynamicBlur", 401];
outlw_MR_blur ppEffectEnable true;
outlw_MR_blur ppEffectAdjust [1.5];
outlw_MR_blur ppEffectCommit 0;

// Player animation logic (if on foot)
if (vehicle player == player) then {
    _stance = "Pknl"; _raised = "Sras"; _weapon = "Wpst";
    if (stance player == "PRONE") then { _stance = "Ppne"; };
    switch (currentWeapon player) do {
        case (""): { _raised = "Snon"; _weapon = "Wnon"; };
        case (primaryWeapon player): { _weapon = "Wrfl"; };
        case (secondaryWeapon player): { _weapon = "Wlnr"; };
    };
    player playMove ("Ainv" + _stance + "Mstp" + _raised + _weapon + "Dnon");
};

// Populate UI elements
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbAdd (localize "STR_magRepack_all_ammo");
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbSetData [0, ""];
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbSetCurSel 0;

call outlw_MR_populateMagListBox;
call outlw_MR_populateMagComboBox;

[true] call outlw_MR_sourceEnabled;
[true] call outlw_MR_targetEnabled;

// Update Info Bars (Debug, Full Mag Hide, Keybindings, About)
// ... (Logic to set structured text on controls 9002, 9004, 9003, 9005) ...

// Store initial debug info
outlw_MR_startingInfo = call outlw_MR_debugInfo;

// Spawn background monitor loop
[] spawn {
    private ["_a", "_b"];
    _a = magazinesAmmo player;
    while {!(IsNull (uiNamespace getVariable "outlw_MR_Dialog_Main"))} do {
        UIsleep 0.05;
        _b = magazinesAmmo player;
        if !([_a, _b] call BIS_fnc_areEqual) then {
            call outlw_MR_populateMagListBox;
            _a =+ _b;
        };
        if !(alive player) then { closeDialog 0; };
    };
};
Where it leads:

Calls: outlw_MR_populateMagComboBox, outlw_MR_populateMagListBox, outlw_MR_sourceEnabled, outlw_MR_targetEnabled, outlw_MR_debugInfo, BIS_fnc_areEqual.
Depended on by: Usually triggered by the main keybinding or action menu.
Global Variables Modified: outlw_MR_blur, outlw_MR_startingInfo, and all internal state variables.
Network Implications: None.
Function Name: outlw_MR_populateMagComboBox What it does: Populates the filter combo box (IDC 22170) with unique ammo types available in the player's inventory. How it does that:

Data Retrieval: Calls outlw_MR_magInfo to get a list of magazine types the player possesses.
Iteration: Loops through every magazine type found.
Uniqueness Check: Checks if the ammo type of the current magazine is already in the _ammoTypes array.
UI Addition: If the ammo type is unique, it adds the ammo's display name (shortened) to the combo box and stores the raw ammo classname in the listbox data field for later filtering.
Sqf

Apply
private ["_magTypes", "_ammoTypes", "_n", "_a"];
_magTypes = (call outlw_MR_magInfo) select 0;
_ammoTypes = [];
_a = 0;

for "_n" from 0 to ((count _magTypes) - 1) do {
    // Get ammo class
    private _ammoClass = getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "ammo");
    
    // Check if already added
    if !(_ammoClass in _ammoTypes) then {
        // Add display name (shortened) to list
        private _displayName = ([(getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "ammo"))] call outlw_MR_ammoDisplayName);
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbAdd ([_displayName, 25] call outlw_MR_shortString);
        
        // Store ammo class in data
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbSetData [_a, _ammoClass];
        
        // Add to local tracking array
        _ammoTypes set [count _ammoTypes, _ammoClass];
        _a = _a + 1;
    };
};
Where it leads:

Calls: outlw_MR_magInfo, outlw_MR_ammoDisplayName, outlw_MR_shortString.
Depended on by: outlw_MR_createDialog.
Global Variables Modified: None.
UI Dependencies: Control 22170.
Function Name: outlw_MR_populateMagListBox What it does: Populates the main listbox (IDC 1500) with the player's magazines, applying filters for ammo type, source/target compatibility, and hiding full magazines if enabled. How it does that:

Data Retrieval: Calls outlw_MR_magInfo to get all magazines.
Filtering: Checks if filtering is needed (source/target selected or specific ammo filter active). If so, calls outlw_MR_filter.
Duplicate Grouping: Calls outlw_MR_uniqueMags to group identical magazines (same type and ammo count) to avoid clutter.
Full Hiding: If outlw_MR_doHideFull is true, calls outlw_MR_hideFull to remove magazines that are at maximum capacity.
UI Layout Calculation: Checks the number of resulting items. If > 9, it adjusts the column width to make room for a scrollbar.
Iteration: Loops through the processed list.
List Item Creation: For each item, it constructs a string (count + name) and adds it to the listbox.
Visuals: Sets a "bullet count" picture based on fill percentage and sets list item data/value.
Sqf

Apply
private ["_args", "_magListTitle"];
_args = call outlw_MR_magInfo;

// Determine title and apply filters
_magListTitle = localize "STR_magRepack_all_mags";
if (outlw_MR_sourceType != "" || {outlw_MR_targetType != ""} || {outlw_MR_currentFilter != ""}) then {
    _args = (_args) call outlw_MR_filter;
    _magListTitle = localize "STR_magRepack_compatible_mags";
};

// Clear list
lnbClear ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500);

// Group duplicates
_args = (_args) call outlw_MR_uniqueMags;

// Hide full mags if enabled
if (outlw_MR_doHideFull) then {
    _args = (_args) call outlw_MR_hideFull;
    _magListTitle = localize "STR_magRepack_nonfull_mags";
    if (outlw_MR_sourceType != "" || {outlw_MR_targetType != ""} || {outlw_MR_currentFilter != ""}) then {
        _magListTitle = localize "STR_magRepack_nonfullcompat_mags";
    };
};

// Extract processed arrays
_magTypes = _args select 0;
_magAmmoCounts = _args select 1;
_magAmmoCaps = _args select 2;
_magCounts = _args select 3;

// Update header
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1000) ctrlSetStructuredText parseText _magListTitle;

// Adjust UI layout based on item count
_bgrndPos = ctrlPosition ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500);
if (count _magTypes > 9) then {
    // Wide layout for scrollbar
    ["outlw_MR_Dialog_Main", 1500, [(_bgrndPos select 0), (_bgrndPos select 1), 0.3375, (_bgrndPos select 3)], 0] call outlw_MR_ctrlSetPos;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lnbDeleteColumn 3;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lnbAddColumn 0.83;
} else {
    // Narrow layout
    ["outlw_MR_Dialog_Main", 1500, [(_bgrndPos select 0), (_bgrndPos select 1), 0.325, (_bgrndPos select 3)], 0] call outlw_MR_ctrlSetPos;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lnbDeleteColumn 3;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lnbAddColumn 0.89;
};

// Populate listbox
for "_n" from 0 to ((count _magTypes) - 1) do {
    // Format count string
    _magCountStr = str(_magCounts select _n);
    if (_magCounts select _n < 10) then { _magCountStr = " " + _magCountStr; };
    
    // Format text line
    private _magname = ([(getText(configFile >> "cfgMagazines" >> _magTypes select _n >> "DisplayName")), 25] call outlw_MR_shortString);
    private _text = (format ["%1x  %2 %3",_magCountStr,_magname]);
    
    // Add to list
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lbadd _text;
    
    // Set picture (bullet fill)
    private _fillRatio = round((_magAmmoCounts select _n)/(_magAmmoCaps select _n)*30);
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lbSetPicture [_n, format [QPATHTOFOLDER(Scripts\MagRepack\Images\bulletCount\%1.paa), _fillRatio]];
    
    // Set data (ammo count and class)
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lbSetValue [_n, _magAmmoCounts select _n];
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500) lbSetData [_n, _magTypes select _n];
};
Where it leads:

Calls: outlw_MR_magInfo, outlw_MR_filter, outlw_MR_uniqueMags, outlw_MR_hideFull, outlw_MR_ctrlSetPos, outlw_MR_shortString.
Depended on by: outlw_MR_createDialog, outlw_MR_addSource, outlw_MR_addTarget, outlw_MR_clearSource, outlw_MR_clearTarget, outlw_MR_showFullSwitch.
UI Dependencies: Control 1500.
Function Name: outlw_MR_filter What it does: Filters the magazine list to show only magazines compatible with the currently selected source or target magazine (same ammo type and tracer configuration). How it does that:

Target Ammo Determination: Determines the target ammo type based on the selected source or target, or the user-selected filter.
Tracer Check: Retrieves the tracer interval (tracersEvery) of the source/target magazine to ensure compatibility (e.g., tracers every 4 rounds vs tracers every 1 round).
Iteration: Loops through all input magazines.
Matching: Checks if the magazine's ammo class matches the target ammo.
Tracer Validation: Checks if the magazine's tracer interval matches the target's. (If a specific user filter is active via the combo box, tracer checks are bypassed).
Result Construction: Adds matching magazines to return arrays.
Sqf

Apply
private ["_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_ammoType", "_ammoTracer", "_userFilter"];
_magTypes = _this select 0;
_magAmmoCounts = _this select 1;
_magAmmoCaps = _this select 2;

// Determine base ammo type
_ammoType = (getText(configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "ammo"));
if (_ammoType == "") then { _ammoType = (getText(configFile >> "cfgMagazines" >> outlw_MR_targetType >> "ammo")); };
if (_ammoType == "") then { _ammoType = outlw_MR_currentFilter; _userFilter = true; };

// Determine tracer count
_ammoTracer = (getNumber(configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "tracersEvery"));
if (outlw_MR_sourceType == "") then { _ammoTracer = (getNumber(configFile >> "cfgMagazines" >> outlw_MR_targetType >> "tracersEvery")); };

// Initialize result arrays
_returnTypes = [];
_returnCounts = [];
_returnCaps = [];

// Filter loop
for "_n" from 0 to ((count _magTypes) - 1) do {
    private _currentMag = _magTypes select _n;
    private _currentAmmo = getText(configFile >> "cfgMagazines" >> _currentMag >> "ammo");
    private _currentTracer = getNumber(configFile >> "cfgMagazines" >> _currentMag >> "tracersEvery");
    
    // Match Ammo AND (Match Tracers OR User Filter Active)
    if (_currentAmmo == _ammoType && {(_currentTracer == _ammoTracer) || {_userFilter}}) then {
        _returnTypes set [count _returnTypes, _currentMag];
        _returnCounts set [count _returnCounts, _magAmmoCounts select _n];
        _returnCaps set [count _returnCaps, _magAmmoCaps select _n];
    };
};

[_returnTypes, _returnCounts, _returnCaps];
Where it leads:

Calls: None (internal logic).
Depended on by: outlw_MR_populateMagListBox.
Global Variables Used: outlw_MR_sourceType, outlw_MR_targetType, outlw_MR_currentFilter.
Logic Note: This function highlights a specific design choice to prevent repacking between magazines of the same ammo but different tracer patterns (e.g., mixed tracer/non-tracer).
Function Name: outlw_MR_hideFull What it does: Removes magazines that are at 100% capacity from the list. How it does that:

Iteration: Loops through the input magazine arrays.
Comparison: Checks if the current ammo count (_magAmmoCounts select _n) is strictly less than the capacity (_magAmmoCaps select _n).
Result Construction: Only adds magazines to the return arrays if they are not full.
Sqf

Apply
private ["_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_magCounts"];
_magTypes = _this select 0;
_magAmmoCounts = _this select 1;
_magAmmoCaps = _this select 2;
_magCounts = _this select 3;

// Initialize result arrays
_returnMagTypes = [];
_returnAmmoCounts = [];
_returnAmmoCaps = [];
_returnMagCounts = [];
_a = 0;

// Filter loop
for "_n" from 0 to ((count _magTypes) - 1) do {
    // Check if ammo count is less than capacity
    if ((_magAmmoCounts select _n) != (_magAmmoCaps select _n)) then {
        _returnMagTypes set [_a, _magTypes select _n];
        _returnAmmoCounts set [_a, _magAmmoCounts select _n];
        _returnAmmoCaps set [_a, _magAmmoCaps select _n];
        _returnMagCounts set [_a, _magCounts select _n];
        _a = _a + 1;
    };
};

[_returnMagTypes, _returnAmmoCounts, _returnAmmoCaps, _returnMagCounts];
Where it leads:

Calls: None.
Depended on by: outlw_MR_populateMagListBox.
Global Variables Used: None.
Function Name: outlw_MR_repack What it does: Handles the actual repacking logic. It moves ammo from the source magazine to the target magazine over time, updating visual progress bars and managing the source/target counts. How it does that:

State Update: Sets outlw_MR_isRepacking to true.
Speed Configuration: Determines repacking speed based on magazine type (bullets vs belt magazines).
Repack Logic Definition: Defines a code block _magCode that updates the source/target counts.
Standard Magazines: Decreases source by 1, increases target by 1.
Belt Magazines: Uses a bulk transfer logic (transferring the difference needed to fill the target or empty the source).
Progress Bar Setup: Calculates the total refresh count and sets up the progress bar animation.
Repacking Loop:
Checks if repacking is still valid (source has ammo, target has space).
Executes _magCode to update counts.
Updates UI progress bars (IDC 22180 for source, 22190 for target).
Sleeps to create the delay between transfers.
Cleanup: If source empties or target fills, calls the respective clear function.
Completion: Resets state and hides UI elements.
Sqf

Apply
outlw_MR_isRepacking = true;

// Configure speeds
_refreshRate = outlw_MR_bulletTime;
_magCode = {
    outlw_MR_sourceCount = outlw_MR_sourceCount - 1;
    outlw_MR_targetCount = outlw_MR_targetCount + 1;
};

// Belt specific logic
if ([outlw_MR_sourceType] call outlw_MR_isBeltMagazine && {[outlw_MR_targetType] call outlw_MR_isBeltMagazine}) then {
    _refreshRate = outlw_MR_beltTime;
    _magCode = {
        outlw_MR_sourceCount = outlw_MR_sourceCount - (outlw_MR_targetCap - outlw_MR_targetCount);
        outlw_MR_targetCount = outlw_MR_targetCount + (outlw_MR_targetCap - outlw_MR_targetCount) + outlw_MR_sourceCount;
        if (outlw_MR_targetCount > outlw_MR_targetCap) then {outlw_MR_targetCount = outlw_MR_targetCap};
        if (outlw_MR_sourceCount < 0) then {outlw_MR_sourceCount = 0};
    };
} else {
    // Calculate refresh count for standard bullets
    if (outlw_MR_sourceCount >= (outlw_MR_targetCap - outlw_MR_targetCount)) then {
        _refreshCount = (outlw_MR_targetCap - outlw_MR_targetCount);
    } else {
        _refreshCount = outlw_MR_sourceCount;
    };
};

// Start visual text update
[] spawn outlw_MR_repackingText;

// Start progress bar animation
["outlw_MR_Dialog_Main", 10002, [0,0], (_refreshCount * _refreshRate)] call outlw_MR_ctrlSetPos;

// Define loop condition
_keepRepacking = {outlw_MR_sourceType != "" && outlw_MR_targetType != "" && outlw_MR_sourceCount > 0 && outlw_MR_targetCount < outlw_MR_targetCap};

// Initial sleep (delay before first transfer)
_sleepTime = (time + (_refreshRate));
while {time < _sleepTime && call _keepRepacking} do { UIsleep 0.05; };

// Main Repacking Loop
while _keepRepacking do {
    // Execute transfer logic
    call _magCode;
    
    // Update Source UI Bar (Visualizing depletion)
    ["outlw_MR_Dialog_Main", 22180, [0,((0.12/outlw_MR_sourceCap) * (outlw_MR_sourceCap - outlw_MR_sourceCount))], 0] call outlw_MR_ctrlSetPos;
    
    // Update Target UI Bar (Visualizing fill)
    ["outlw_MR_Dialog_Main", 22190, [0,((0.12/outlw_MR_targetCap) * (outlw_MR_targetCap - outlw_MR_targetCount))], 0] call outlw_MR_ctrlSetPos;
    
    // Wait for next tick
    _sleepTime = (time + (_refreshRate));
    while {time < _sleepTime && call _keepRepacking} do { UIsleep 0.05; };
};

// Cleanup if source is empty
if (outlw_MR_sourceCount <= 0) then { call outlw_MR_clearSource; };
// Cleanup if target is full
if (outlw_MR_targetCount == outlw_MR_targetCap) then { call outlw_MR_clearTarget; };

// Reset state
outlw_MR_isRepacking = false;
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1008) ctrlSetText "";
// Reset progress bar position
["outlw_MR_Dialog_Main", 10002, [-0.325,0], 0] call outlw_MR_ctrlSetPos;
Where it leads:

Calls: outlw_MR_isBeltMagazine, outlw_MR_repackingText, outlw_MR_ctrlSetPos, outlw_MR_clearSource, outlw_MR_clearTarget.
Depended on by: outlw_MR_addSource, outlw_MR_addTarget.
Global Variables Modified: outlw_MR_isRepacking, outlw_MR_sourceCount, outlw_MR_targetCount.
UI Dependencies: Controls 10002, 22180, 22190.
Function Name: outlw_MR_repackingText What it does: Updates the text element in the main dialog to show "Repacking..." with animated dots while a repack is in progress. How it does that:

Loop: Runs as long as outlw_MR_isRepacking is true.
String Manipulation: Appends a dot to the text string.
State Cycle: Cycles between two localized strings to prevent the text from getting too long ("Repacking" -> "Repacking." -> ... -> "Repacking.." -> "Repacking..." -> back to "Repacking").
UI Update: Updates control 1008 every second.
Cleanup: Clears the text when the loop exits.
Sqf

Apply
private ["_repacking"];
_repacking = localize "STR_magRepack_repacking";

while {outlw_MR_isRepacking} do {
    _repacking = _repacking + ".";
    
    // Reset to prevent infinite dots
    if (_repacking == localize "STR_magRepack_repacking") then {
        _repacking = localize "STR_magRepack_repacking2";
    };
    
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1008) ctrlSetText _repacking;
    
    UIsleep 1;
};

((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1008) ctrlSetText "";
Where it leads:

Depended on by: outlw_MR_repack.
UI Dependencies: Control 1008.
Function Name: outlw_MR_block What it does: Disables the "Source" and "Target" drop zones (IDCs 2215 and 2216) based on validity rules. It also sets tooltips explaining why they are disabled. How it does that:

Source Validation: Checks various conditions:
Source already defined?
Drag count is 0 (empty source)?
Incompatible size (e.g., trying to pour a small mag into a huge belt mag)?
If any condition fails, sets _doBlockSource to true.
Source UI Update: If blocked, disables the button and changes color to red. If dragging, it changes color to white. Sets tooltips.
Target Validation: Checks conditions:
Target already defined?
Drag count equals capacity (full target)?
Incompatible size (e.g., trying to pour a huge belt mag into a small mag)?
Target UI Update: Similar to source logic.
Filter Button: Disables the filter button (IDC 2217) visually.
Sqf

Apply
private ["_doBlockSource", "_doBlockTarget"];
_doBlockSource = true;
_doBlockTarget = true;

// Source Check
switch (true) do {
    case (outlw_MR_sourceType != ""): { ... tooltip ... };
    case (outlw_MR_dragCount == 0): { ... tooltip ... };
    case (outlw_MR_dragCap < 100 && (outlw_MR_targetType != "" && outlw_MR_targetCap >= 100)): { ... tooltip (Belt logic) ... };
    default {_doBlockSource = false;};
};

// Apply Source UI
if (_doBlockSource) then {
    if (outlw_MR_sourceDragging) then { ... white ... } else { ... red ... };
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable false;
} else {
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetBackgroundColor [1,1,1,0.3];
};

// Target Check
switch (true) do {
    case (outlw_MR_targetType != ""): { ... tooltip ... };
    case (outlw_MR_dragCount == outlw_MR_dragCap && outlw_MR_dragCap != 1): { ... tooltip ... };
    case (outlw_MR_dragCap >= 100 && (outlw_MR_sourceType != "" && outlw_MR_sourceCap < 100)): { ... tooltip ... };
    default {_doBlockTarget = false;};
};

// Apply Target UI
if (_doBlockTarget) then { ... logic similar to source ... } else { ... };

((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlSetBackgroundColor [1,1,1,0.3];
Where it leads:

Calls: None.
Depended on by: outlw_MR_onDrag, outlw_MR_sourceEnabled, outlw_MR_targetEnabled.
UI Dependencies: Controls 2215, 2216, 2217.
Function Name: outlw_MR_onDrag What it does: Triggered when a drag operation starts (mouse down on a list item or drop zone). It identifies what is being dragged and updates the UI state to allow dropping. How it does that:

Reset: Resets dragging flags (list, source, target).
Context Check: The third argument (_this select 2) determines the source:
"source": Dragging from the Source zone.
"target": Dragging from the Target zone.
Default: Dragging from the List.
State Update: Sets the relevant dragging flag to true and updates outlw_MR_dragType, outlw_MR_dragCount, and outlw_MR_dragCap with the data of the item being dragged.
UI Trigger: Enables the filter drop zone (IDC 2217) to allow dropping.
Validation: Calls outlw_MR_block to calculate which drop zones are valid targets for this drag operation.
Sqf

Apply
// Reset flags
outlw_MR_listDragging = false;
outlw_MR_sourceDragging = false;
outlw_MR_targetDragging = false;

// Get drag data
outlw_MR_dragType = _this select 1;
outlw_MR_dragCount = _this select 0;
outlw_MR_dragCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_dragType >> "count");

// Identify source
switch (_this select 2) do {
    case "source": {
        outlw_MR_dragCount = outlw_MR_sourceCount;
        outlw_MR_dragCap = outlw_MR_sourceCap;
        outlw_MR_sourceDragging = true;
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlEnable true;
    };
    case "target": {
        outlw_MR_dragCount = outlw_MR_targetCount;
        outlw_MR_dragCap = outlw_MR_targetCap;
        outlw_MR_targetDragging = true;
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlEnable true;
    };
    default {
        outlw_MR_listDragging = true;
    };
};

call outlw_MR_block;
Where it leads:

Calls: outlw_MR_block.
Depended on by: UI Mouse Button Down events.
Global Variables Modified: outlw_MR_listDragging, outlw_MR_sourceDragging, outlw_MR_targetDragging, outlw_MR_dragType, outlw_MR_dragCount, outlw_MR_dragCap.
Function Name: outlw_MR_onMouseButtonUp What it does: Triggered when the mouse button is released. It resets the dragging state and re-enables drop zones if the source/target was cleared. How it does that:

Reset: Clears drag variables (dragType, dragCount, dragCap).
UI Reset:
Resets background colors of drop zones (IDCs 2215, 2216, 2217).
Removes tooltips.
Re-enable Logic:
If outlw_MR_sourceType is empty, re-enables the Source drop zone (IDC 2215).
If outlw_MR_targetType is empty, re-enables the Target drop zone (IDC 2216).
Disable Filter Zone: Disables the filter drop zone (IDC 2217) as it is only active during a drag.
Sqf

Apply
// Reset drag state
outlw_MR_dragType = "";
outlw_MR_dragCount = 0;
outlw_MR_dragCap = 0;

// Reset Source UI
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetBackgroundColor [1,0,0,0];
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "";
if (outlw_MR_sourceType == "") then {
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable true;
};

// Reset Target UI
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetBackgroundColor [1,0,0,0];
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "";
if (outlw_MR_targetType == "") then {
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable true;
};

// Reset Filter UI
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlSetBackgroundColor [0,0,0,0];
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlEnable false;
Where it leads:

Depended on by: UI Mouse Button Up events.
UI Dependencies: Controls 2215, 2216, 2217.
Function Name: outlw_MR_sourceEnabled What it does: Manages the visual state of the Source drop zone based on whether a source magazine is currently selected. How it does that:

If Enabled (No Source Selected):
Enables the drop zone (IDC 2215).
Clears and disables the "Convert" button (IDC 1600).
Clears text fields for the source.
If Disabled (Source Selected):
Disables the drop zone (IDC 2215).
Checks if the selected source is "convertable" (e.g., a 1-round grenade). If so, enables the Convert button (IDC 1600) and sets its tooltip.
Block Update: Calls outlw_MR_block if a drag is currently in progress to refresh validity.
Sqf

Apply
if (_this select 0) then {
    // Enabled (No Source)
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable true;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlEnable false;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetText "";
    // ... (Clear other source fields) ...
} else {
    // Disabled (Source Selected)
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable false;
    
    if ([outlw_MR_sourceType] call outlw_MR_isConvertable) then {
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetText "Convert";
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetTooltip (getText(configFile >> "CfgMagazines" >> ([outlw_MR_sourceType] call outlw_MR_getConversion) >> "DisplayName"));
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlEnable true;
    };
};

if (outlw_MR_dragType != "") then { call outlw_MR_block; };
Where it leads:

Calls: outlw_MR_isConvertable, outlw_MR_getConversion, outlw_MR_block.
Depended on by: outlw_MR_createDialog, outlw_MR_addSource, outlw_MR_clearSource.
UI Dependencies: Controls 2215, 1600, 1201, 1100.
Function Name: outlw_MR_targetEnabled What it does: Manages the visual state of the Target drop zone based on whether a target magazine is currently selected. Functionally identical to outlw_MR_sourceEnabled but for the target side. How it does that:

If Enabled (No Target Selected):
Enables the drop zone (IDC 2216).
Clears and disables the "Convert" button (IDC 1601).
Clears text fields.
If Disabled (Target Selected):
Disables the drop zone (IDC 2216).
Checks if the selected target is "convertable". If so, enables the Convert button (IDC 1601).
Block Update: Calls outlw_MR_block if a drag is in progress.
Sqf

Apply
// Logic mirrors outlw_MR_sourceEnabled
if (_this select 0) then {
    // Enabled
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable true;
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlEnable false;
    // ... clear fields ...
} else {
    // Disabled
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable false;
    
    if ([outlw_MR_targetType] call outlw_MR_isConvertable) then {
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlSetText "Convert";
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlSetTooltip (...);
        ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlEnable true;
    };
};

if (outlw_MR_dragType != "") then { call outlw_MR_block; };
Where it leads:

Calls: outlw_MR_isConvertable, outlw_MR_getConversion, outlw_MR_block.
Depended on by: outlw_MR_createDialog, outlw_MR_addTarget, outlw_MR_clearTarget.
UI Dependencies: Controls 2216, 1601, 1203, 1101.
Function Name: outlw_MR_addSource What it does: Assigns a magazine from the list or the current target as the new Source magazine. It handles removing the magazine from the player's inventory (temporarily) and updating the UI. How it does that:

Drag Check: Verifies if the operation is a drag from the list (outlw_MR_listDragging).
Validation: Calls outlw_MR_magVerified to ensure the magazine still exists in the player's inventory with the specified ammo count.
Assignment:
Sets outlw_MR_sourceType, outlw_MR_sourceCount, outlw_MR_sourceCap.
Calls outlw_MR_removeMag to physically remove the magazine from the player.
Refreshes the main list (outlw_MR_populateMagListBox) to remove the dragged item.
Swap Logic: If not dragging from the list (dragging from the Target zone), it swaps Source and Target data and clears the Target zone.
UI Update: Adds the source name to the listbox (IDC 1501), sets the picture (IDC 1201), updates the progress bar (IDC 22180), and updates the description text (IDC 1100).
Trigger Repack: If a target is already selected, immediately starts the repack process.
Sqf

Apply
private ["_doExit"];
_doExit = false;

// Case: Dragging from Main List
if (outlw_MR_listDragging) then {
    if ([_this select 2, _this select 1] call outlw_MR_magVerified) then {
        // Assign data
        outlw_MR_sourceType = _this select 2;
        outlw_MR_sourceCount = _this select 1;
        outlw_MR_sourceCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_sourceType >> "count");
        
        // Remove from inventory
        [outlw_MR_sourceType, outlw_MR_sourceCount] call outlw_MR_removeMag;
        call outlw_MR_populateMagListBox;
    } else {
        _doExit = true;
    };
} else {
    // Case: Swapping (Dragging from Target to Source)
    outlw_MR_sourceType = outlw_MR_targetType;
    outlw_MR_sourceCount = outlw_MR_targetCount;
    outlw_MR_sourceCap = outlw_MR_targetCap;
    outlw_MR_doAddToMagazines = false; // Don't return to inv when clearing
    call outlw_MR_clearTarget;
};

if (_doExit) exitWith {};

// UI Updates
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1501) lbAdd (getText (configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "DisplayName"));
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1201) ctrlSetText (getText (configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "picture"));
["outlw_MR_Dialog_Main", 22180, [0,((0.12/outlw_MR_sourceCap) * (outlw_MR_sourceCap - outlw_MR_sourceCount))], 0] call outlw_MR_ctrlSetPos;
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1100) ctrlSetStructuredText parseText format [...];

[false] call outlw_MR_sourceEnabled;

// Auto start
if (outlw_MR_targetType != "") then { [] spawn outlw_MR_repack; };
Where it leads:

Calls: outlw_MR_magVerified, outlw_MR_removeMag, outlw_MR_populateMagListBox, outlw_MR_clearTarget, outlw_MR_ctrlSetPos, outlw_MR_sourceEnabled, outlw_MR_repack.
Depended on by: Drop zone release event (IDC 2215).
Global Variables Modified: outlw_MR_sourceType, outlw_MR_sourceCount, outlw_MR_sourceCap, outlw_MR_doAddToMagazines.
Function Name: outlw_MR_clearSource What it does: Clears the selected Source magazine, returning it to the player's inventory if necessary, and resets the UI. How it does that:

Inventory Return: Checks outlw_MR_doAddToMagazines. If true (user cleared manually), it adds the magazine back to the player using player addMagazine.
UI Reset: Clears the source listbox (IDC 1501) and resets internal variables.
Re-enable: Calls outlw_MR_sourceEnabled with true to enable the drop zone.
Visual Reset: Resets the progress bar position.
Sqf

Apply
private ["_doPopulate"];
_doPopulate = false;

// Return item to inventory if user cancelled
if (outlw_MR_doAddToMagazines) then {
    if (outlw_MR_sourceCount > 0) then {
        player addMagazine [outlw_MR_sourceType, outlw_MR_sourceCount];
        _doPopulate = true;
    };
};

// Clear UI
lnbClear ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1501);
outlw_MR_sourceType = "";
outlw_MR_sourceCount = 0;

// Refresh inventory list if item was returned
if (_doPopulate) then { call outlw_MR_populateMagListBox; };

// Reset UI state
[true] call outlw_MR_sourceEnabled;
outlw_MR_doAddToMagazines = true;

// Reset progress bar
["outlw_MR_Dialog_Main", 22180, [0,0.12], 0] call outlw_MR_ctrlSetPos;
Where it leads:

Calls: outlw_MR_populateMagListBox, outlw_MR_sourceEnabled, outlw_MR_ctrlSetPos.
Depended on by: outlw_MR_addTarget, outlw_MR_onMouseButtonUp, outlw_MR_convert.
Global Variables Modified: outlw_MR_sourceType, outlw_MR_sourceCount, outlw_MR_doAddToMagazines.
Function Name: outlw_MR_addTarget What it does: Assigns a magazine from the list or the current source as the new Target magazine. Similar to outlw_MR_addSource but includes logic for magazine conversion if the target capacity is 1. How it does that:

Drag/Swap Logic: Handles drag from list or swap from source zone.
Capacity Check: If the target magazine has a capacity of 1 (e.g., a grenade), it checks if it's convertable. If so, it swaps the type to the converted type (e.g., 1Rnd -> 3Rnd) and updates capacity.
UI Update: Updates the target listbox (IDC 1502), picture (IDC 1203), progress bar (IDC 22190), and description (IDC 1101).
Disable: Calls outlw_MR_targetEnabled to disable the drop zone.
Trigger Repack: If a source is already selected, starts the repack process.
Sqf

Apply
// Logic mirrors outlw_MR_addSource with specific conversions
private ["_doExit"];
_doExit = false;

// ... (Drag/Swap logic similar to addSource) ...

if (_doExit) exitWith {};

// Conversion Logic for 1-capacity magazines (like grenades)
if (outlw_MR_targetCap == 1) then {
    if ([outlw_MR_targetType] call outlw_MR_isConvertable) then {
        outlw_MR_targetType = [outlw_MR_targetType] call outlw_MR_getConversion;
        outlw_MR_targetCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_targetType >> "count");
    };
};

// UI Updates
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1502) lbAdd (...);
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1203) ctrlSetText (...);
["outlw_MR_Dialog_Main", 22190, [0,((0.12/outlw_MR_targetCap) * (outlw_MR_targetCap - outlw_MR_targetCount))], 0] call outlw_MR_ctrlSetPos;
((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1101) ctrlSetStructuredText parseText format [...];

[false] call outlw_MR_targetEnabled;

// Auto start
if (outlw_MR_sourceType != "") then { [] spawn outlw_MR_repack; };
Where it leads:

Calls: outlw_MR_magVerified, outlw_MR_removeMag, outlw_MR_populateMagListBox, outlw_MR_clearSource, outlw_MR_isConvertable, outlw_MR_getConversion, outlw_MR_ctrlSetPos, outlw_MR_targetEnabled, outlw_MR_repack.
Depended on by: Drop zone release event (IDC 2216).
Global Variables Modified: outlw_MR_targetType, outlw_MR_targetCount, outlw_MR_targetCap, outlw_MR_doAddToMagazines.
Function Name: outlw_MR_clearTarget What it does: Clears the selected Target magazine, returning it to the player's inventory, and resets the UI. How it does that:

Inventory Return: Adds the magazine back to the player if outlw_MR_doAddToMagazines is true.
UI Reset: Clears the target listbox (IDC 1502) and resets variables.
Re-enable: Calls outlw_MR_targetEnabled with true.
Visual Reset: Resets the progress bar.
Sqf

Apply
if (outlw_MR_doAddToMagazines) then {
    player addMagazine [outlw_MR_targetType, outlw_MR_targetCount];
};

lnbClear ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1502);
outlw_MR_targetType = "";
outlw_MR_targetCount = 0;

call outlw_MR_populateMagListBox;

[true] call outlw_MR_targetEnabled;
outlw_MR_doAddToMagazines = true;

["outlw_MR_Dialog_Main", 22190, [0,0.12], 0] call outlw_MR_ctrlSetPos;
Where it leads:

Calls: outlw_MR_populateMagListBox, outlw_MR_targetEnabled, outlw_MR_ctrlSetPos.
Depended on by: outlw_MR_addSource, outlw_MR_onMouseButtonUp, outlw_MR_convert.
Global Variables Modified: outlw_MR_targetType, outlw_MR_targetCount.
Function Name: outlw_MR_moveToList What it does: Helper function to clear the active drag source (Source or Target) when the item is dropped back onto the main list area. How it does that:

Check Active Drag: Determines if the user was dragging from the Source zone or the Target zone.
Action: Calls the respective clear function (outlw_MR_clearSource or outlw_MR_clearTarget).
Sqf

Apply
switch (true) do
{
    case (outlw_MR_sourceDragging): {call outlw_MR_clearSource;};
    case (outlw_MR_targetDragging): {call outlw_MR_clearTarget;};
};
Where it leads:

Calls: outlw_MR_clearSource, outlw_MR_clearTarget.
Depended on by: Drop event on the main list control (IDC 1500).
Function Name: outlw_MR_optionsMenu What it does: Animates the opening and closing of the options menu overlay within the main dialog. How it does that:

State Check: Checks outlw_MR_optionsOpen. If true, it calculates positions to close the menu; if false, to open it.
Animation Prep: Retrieves current positions of UI controls involved in the animation.
IsAnimating Check: Calls outlw_MR_isAnimating to prevent glitching if an animation is already running.
Position Setting: Sets new positions for controls (IDCs 9006, 9001, 9000, 8999, 8998, 8997) to slide them in/out.
Commit: Spawns a loop to commit the position changes over time (0.15s for sliding, 0.1s for background).
Sqf

Apply
// Get current positions
_posGroup = ctrlPosition ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9000);
// ... (others) ...

// Check if currently animating
if ([9006,9001,9000,8999,8998,8997] call outlw_MR_isAnimating) exitWith {};

if (outlw_MR_optionsOpen) then {
    // CLOSE LOGIC: Set target positions to hidden/offset
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9006) ctrlSetPosition [0,0.21];
    // ... (other control movements) ...
    
    outlw_MR_optionsOpen = false;
    
    // Commit animation
    [] spawn {
        {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl _x) ctrlCommit 0.15;} forEach [9006,9001,9000,8999];
        UIsleep 0.15;
        {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl _x) ctrlCommit 0.1;} forEach [8998,8997];
    };
} else {
    // OPEN LOGIC: Set target positions to visible
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9006) ctrlSetPosition [0.1125,0.21];
    // ... (other control movements) ...
    
    outlw_MR_optionsOpen = true;
    
    // Commit animation
    [] spawn {
        {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl _x) ctrlCommit 0.1;} forEach [8998,8997];
        UIsleep 0.1;
        {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl _x) ctrlCommit 0.15;} forEach [9006,9001,9000,8999];
    };
};
Where it leads:

Calls: outlw_MR_isAnimating.
Depended on by: Click event on "Options" button (IDC 9003).
Global Variables Modified: outlw_MR_optionsOpen.
UI Dependencies: Controls 9006, 9001, 9000, 8999, 8998, 8997.
Function Name: outlw_MR_debugSwitch What it does: Toggles the debug mode flag and updates the UI text in the info bar. How it does that:

Toggle: Inverts the boolean outlw_MR_debugMode.
Persist: Saves the new state to profileNamespace.
UI Update: Updates control 9002 with the new status ("On" or "Off").
Sqf

Apply
if (outlw_MR_debugMode) then {
    outlw_MR_debugMode = false;
    profileNamespace setVariable ["outlw_MR_debugMode_profile", false];
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9002) ctrlSetStructuredText parseText ([localize "STR_magRepack_debug", ": ", format ["<t align='right'>%1</t>", localize "STR_info_bar_off"]] joinString "");
} else {
    outlw_MR_debugMode = true;
    profileNamespace setVariable ["outlw_MR_debugMode_profile", true];
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9002) ctrlSetStructuredText parseText ([localize "STR_magRepack_debug", ": ", format ["<t align='right'>%1</t>", localize "STR_info_bar_on2"]] joinString "");
};
Where it leads:

Depended on by: Click event on the Debug button (likely ID 9002 or a hidden toggle in options).
Global Variables Modified: outlw_MR_debugMode.
Function Name: outlw_MR_showFullSwitch What it does: Toggles the "Hide Full Magazines" setting and refreshes the magazine list. How it does that:

Toggle: Inverts outlw_MR_doHideFull.
Persist: Saves to profile.
UI Update: Updates control 9004 text.
Refresh: Calls outlw_MR_populateMagListBox to apply the filter immediately.
Sqf

Apply
if (outlw_MR_doHideFull) then {
    outlw_MR_doHideFull = false;
    profileNamespace setVariable ["outlw_MR_doHideFull_profile", false];
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9004) ctrlSetStructuredText parseText (... "On" ...);
} else {
    outlw_MR_doHideFull = true;
    profileNamespace setVariable ["outlw_MR_doHideFull_profile", true];
    ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9004) ctrlSetStructuredText parseText (... "Off" ...);
};

call outlw_MR_populateMagListBox;
Where it leads:

Calls: outlw_MR_populateMagListBox.
Depended on by: Click event on the Full Mag button (IDC 9004).
Global Variables Modified: outlw_MR_doHideFull.
Function Name: outlw_MR_onDialogDestroy What it does: Performs cleanup when the main dialog is closed. It handles returning items to inventory, destroying effects, and generating a debug report if enabled. How it does that:

Cleanup: Destroys the screen blur effect (ppEffectDestroy).
Inventory Return: Calls outlw_MR_clearSource and outlw_MR_clearTarget if they are currently defined, ensuring the player doesn't lose items.
Debug Report: If outlw_MR_debugMode is true:
Calls outlw_MR_debugInfo to get the final inventory state.
Compares it with the saved outlw_MR_startingInfo.
Calculates differences (ammo gained/lost).
Generates an HTML-formatted hint with details of the repacking session.
Re-enable: Spawns a short delay and sets outlw_MR_canCreateDialog to true, allowing a new dialog to be opened.
Sqf

Apply
private ["_endingInfo", "_sTCA", "_eTCA", "_output", "_dif", "_difStr"];
ppEffectDestroy outlw_MR_blur;

// Return any lingering items to inventory
if (outlw_MR_sourceType != "") then { call outlw_MR_clearSource; };
if (outlw_MR_targetType != "") then { call outlw_MR_clearTarget; };

// Debug Report Logic
if (outlw_MR_debugMode) then {
    _endingInfo = call outlw_MR_debugInfo;
    _sTCA = outlw_MR_startingInfo select 1; // Starting Type Count Ammo
    _eTCA = _endingInfo select 1;           // Ending Type Count Ammo
    _output = "";

    // Loop through starting mags
    for "_n" from 0 to ((count _sTCA) - 1) do {
        _snTCA = _sTCA select _n;
        // ... (String formatting logic) ...
        // Logic finds matching mag in ending list and calculates delta
    };
    
    // Loop through ending mags (to catch newly created mags not in start)
    for "_n" from 0 to ((count _eTCA) - 1) do {
        // ... (String formatting for new mags) ...
    };

    // Calculate total ammo difference
    _dif = ((_endingInfo select 0) select 1) - ((outlw_MR_startingInfo select 0) select 1);
    // ... (Color coding for positive/negative delta) ...

    hint parseText (... formatted report ...);
};

// Reset cooldown
[] spawn {
    UIsleep 0.5;
    outlw_MR_canCreateDialog = true;
};
Where it leads:

Calls: outlw_MR_clearSource, outlw_MR_clearTarget, outlw_MR_debugInfo.
Depended on by: Dialog onUnload event.
Global Variables Modified: outlw_MR_canCreateDialog.
File: A3A/addons/core/Scripts/MagRepack/Scripts/MagRepack_Misc.sqf
Function Name: outlw_MR_modifierCheck What it does: Validates if the current keyboard event's modifier keys (Shift, Ctrl, Alt) match the configured keybinding's modifiers. How it does that:

Input Parsing: Takes the _this array (passed from the KeyDown event handler) which contains [inputAction, key, shift, ctrl, alt].
Nested Logic: Checks each modifier.
If the keybinding requires Shift (outlw_MR_shift is true) but the event reports Shift is not pressed (!_shift), it returns false.
Repeats for Ctrl and Alt.
Return: Returns true only if all required modifiers are pressed and no prohibited modifiers are missing.
Sqf

Apply
// _this select 2 = Shift, _this select 3 = Ctrl, _this select 4 = Alt
private _shift = _this select 2;
private _ctrl = _this select 3;
private _alt = _this select 4;

// Check Shift requirement
if (outlw_MR_shift && {!_shift}) then {
    false;
} else {
    // Check Ctrl requirement
    if (outlw_MR_ctrl && {!_ctrl}) then {
        false;
    } else {
        // Check Alt requirement
        if (outlw_MR_alt && {!_alt}) then {
            false;
        } else {
            true;
        };
    };
};
Where it leads:

Depended on by: outlw_MR_keyDown.
Global Variables Used: outlw_MR_shift, outlw_MR_ctrl, outlw_MR_alt.
Function Name: outlw_MR_keyDown What it does: The main keyboard event handler. It handles opening the Mag Repack dialog and resetting keybindings via a specific key combination. How it does that:

Wounded Check: Checks if the player is incapacitated. If so, prevents opening the dialog.
Main Key Check: Compares the pressed key (_this select 1) with the configured keybinding (outlw_MR_keybinding) and validates modifiers via outlw_MR_modifierCheck.
True: Attempts to open the dialog. Checks outlw_MR_canCreateDialog (cooldown/prevent double-open) and player alive status. If valid, calls outlw_MR_createDialog.
False (Already Open): If the key matches but the dialog is already open (outlw_MR_keybindingMenuActive is false, meaning the main dialog is open), it closes the dialog (ID 0).
Reset Combination Check: Checks for Shift + Ctrl + Alt + Backspace (Key 14).
If all modifiers are pressed and the key is Backspace, it calls outlw_MR_applyKeybinding with the default key list and the reset flag true.
Sqf

Apply
private _isWounded = player getVariable ["incapacitated", false];
private _key = _this select 1;

// Check if the configured keybinding was pressed with correct modifiers
if (_key == outlw_MR_keybinding && {_this call outlw_MR_modifierCheck}) then {
    // Check if dialog can be created (and not wounded)
    if (outlw_MR_canCreateDialog && !(_isWounded)) then {
        call outlw_MR_createDialog;
        true;
    } else {
        // If dialog is already open, close it
        if (!outlw_MR_keybindingMenuActive) then {
            closeDialog 0;
            true;
        };
    };
} else {
    // Check for Reset Key Combination (Shift+Ctrl+Alt+Backspace)
    if (_key == 14 && {_this select 2} && {_this select 3} && {_this select 4} && {outlw_MR_canCreateDialog}) then {
        [outlw_MR_defaultKeybinding, true] call outlw_MR_applyKeybinding;
        true;
    };
};
Where it leads:

Calls: outlw_MR_modifierCheck, outlw_MR_createDialog, outlw_MR_applyKeybinding.
Depended on by: findDisplay 46 event handler (set in 
MagRepack_init_sv.sqf
).
Global Variables Modified: None (logic only).
Function Name: outlw_MR_getIDCs What it does: Recursively retrieves all control IDs (IDCs) from a dialog configuration class structure. How it does that:

Input: Takes a config path (e.g., missionConfigFile >> "MR_Dialog" >> "Controls") and an optional filter code block.
Iteration: Loops through all sub-classes in the config.
Extraction: Gets the idc value of each class.
Recursion: If a class has a "Controls" subclass, it calls itself on that subclass to find nested controls.
Filtering: Applies the filter code block if provided.
Return: Returns an array of integers (IDCs).
Sqf

Apply
private ["_config", "_filter", "_ctrlCount", "_returnList", "_ctrl", "_n"];
_config = _this select 0;
_filter = {true};

if (count _this > 1) then { _filter = _this select 1; };

_ctrlCount = count(_config);
_returnList = [];

for "_n" from 0 to (_ctrlCount - 1) do {
    _ctrl = configName((_config) select _n);
    
    if (call _filter) then {
        _returnList = _returnList + [getNumber(_config >> _ctrl >> "idc")];
    };
    
    if (isClass(_config >> _ctrl >> "Controls")) then {
        _returnList = _returnList + ([(_config >> _ctrl >> "Controls"), _filter] call outlw_MR_getIDCs);
    };
};

_returnList;
Where it leads:

Calls: Recursively calls itself.
Depended on by: 
MagRepack_init_sv.sqf
 (to set outlw_MR_listIDCs).
Return Value: Array of integers.
Function Name: outlw_MR_isAnimating What it does: Checks if any UI controls (identified by their IDCs) are currently animating (committing position changes). How it does that:

Input: Takes an array of IDCs. Defaults to outlw_MR_listIDCs if none provided.
Iteration: Loops through the IDCs.
Check: Uses ctrlCommitted on the control. If false (animation in progress), it sets the return flag to true and breaks the loop.
Return: Returns true if any control is animating, false otherwise.
Sqf

Apply
private ["_listIDCs", "_ctrlCount", "_returnBool", "_idc", "_n"];
_listIDCs = outlw_MR_listIDCs;

if ((count _this) > 0) then { _listIDCs = _this; };

_ctrlCount = count _listIDCs;
_returnBool = false;

for "_n" from 0 to (_ctrlCount - 1) do {
    _idc = _listIDCs select _n;
    
    if !(ctrlCommitted ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl _idc)) then {
        _n = _ctrlCount;
        _returnBool = true;
    };
};

_returnBool;
Where it leads:

Calls: None.
Depended on by: outlw_MR_optionsMenu.
Global Variables Used: outlw_MR_listIDCs.
Function Name: outlw_MR_ctrlSetPos What it does: A helper function to set a control's position and commit the animation immediately. How it does that:

Input: Takes dialog name, control IDC, position array, and commit time.
Execution: Gets the control via uiNamespace, calls ctrlSetPosition, then ctrlCommit.
Sqf

Apply
((uiNamespace getVariable (_this select 0)) displayCtrl (_this select 1)) ctrlSetPosition (_this select 2);
((uiNamespace getVariable (_this select 0)) displayCtrl (_this select 1)) ctrlCommit (_this select 3);
Where it leads:

Depended on by: outlw_MR_populateMagListBox, outlw_MR_repack, outlw_MR_clearSource, outlw_MR_clearTarget, outlw_MR_addSource, outlw_MR_addTarget.
Function Name: outlw_MR_shortString What it does: Truncates a string to a specified length and appends "..." if it exceeds the limit. How it does that:

Input: String and length limit.
Conversion: Converts string to character array (toArray).
Trimming: If array length > limit, it sets characters from the limit to the end to ASCII -42 (a placeholder).
Cleanup: Removes the placeholder characters from the array.
Reconstruction: Converts back to string and appends "..." if trimmed.
Sqf

Apply
private ["_inputString", "_limit", "_uniray", "_n"];
_inputString = _this select 0;
_limit = _this select 1;
_uniray = toArray(_inputString);

if (count(_uniray) > _limit) then {
    // Mark characters for removal
    for [{_n = (count(_uniray) - 1);}, {_n >= _limit}, {_n = _n - 1}] do {
        _uniray set [_n, -42];
    };
    
    // Remove marked characters
    _uniray = _uniray - [-42];
    
    // Return truncated + ellipsis
    (toString(_uniray) + "...");
} else {
    _inputString;
};
Where it leads:

Depended on by: outlw_MR_populateMagListBox, outlw_MR_populateMagComboBox.
Function Name: outlw_MR_ammoDisplayName What it does: Cleans up ammo classnames for display. It removes the first two characters (usually caliber prefixes like "B_") and replaces underscores with spaces. How it does that:

Input: Ammo classname string.
Conversion: Converts to character array.
Modification: Iterates through the array.
Replaces first two characters with a removal marker (-42).
Replaces underscores (ASCII 95) with spaces (ASCII 32).
Cleanup: Removes markers and converts back to string.
Sqf

Apply
private ["_uniray", "_n"];
_uniray = toArray(_this select 0);

for "_n" from 0 to ((count _uniray) - 1) do {
    if (_n < 2) then { _uniray set [_n, -42]; }; // Remove first 2 chars
    if ((_uniray select _n) == 95) then { _uniray set [_n, 32]; }; // _ -> Space
};

_uniray = _uniray - [-42];
toString(_uniray);
Where it leads:

Depended on by: outlw_MR_populateMagComboBox.
Function Name: outlw_MR_magInfo What it does: Scans the player's inventory (magazinesAmmo) and returns a processed list of magazines that are capable of being repacked (count > 1 or convertable). How it does that:

Input: None (reads global player state).
Retrieval: Gets magazinesAmmo player.
Filtering: Loops through every magazine.
Checks if magazine count > 1 OR if the magazine is convertable (via outlw_MR_isConvertable).
If valid, adds the magazine type, current ammo count, and max capacity to respective arrays.
Return: Returns an array [magTypes, magAmmoCounts, magAmmoCaps].
Sqf

Apply
private ["_magsAmmo", "_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_magType", "_n", "_a"];
_magsAmmo = magazinesAmmo player;
_magTypes = [];
_magAmmoCounts = [];
_magAmmoCaps = [];
_a = 0;

for "_n" from 0 to ((count _magsAmmo) - 1) do {
    _magType = ((_magsAmmo select _n) select 0);
    
    // Check if magazine is relevant for repacking
    if (getNumber(configFile >> "CfgMagazines" >> _magType >> "count") > 1 || {[_magType] call outlw_MR_isConvertable}) then {
        _magTypes set [_a, _magType];
        _magAmmoCounts set [_a, ((_magsAmmo select _n) select 1)];
        _magAmmoCaps set [_a, getNumber(configFile >> "CfgMagazines" >> _magType >> "count")];
        _a = _a + 1;
    };
};

[_magTypes, _magAmmoCounts, _magAmmoCaps];
Where it leads:

Calls: outlw_MR_isConvertable.
Depended on by: outlw_MR_populateMagListBox, outlw_MR_populateMagComboBox, outlw_MR_filter.
Global Variables Used: None.
Function Name: outlw_MR_removeMag What it does: Safely removes a specific magazine with a specific ammo count from the player's inventory. It removes all mags of that type first, then re-adds everything except the one specified. How it does that:

Input: Magazine type and ammo count to remove.
Snapshot: Gets current full inventory via outlw_MR_magInfo.
Bulk Remove: Removes all magazines of the specified type from the player (this is a side-effect of the specific implementation logic, usually handled by iterating removeMagazine but here it's done in bulk to manage specific ammo counts safely).
Selective Re-add: Loops through the snapshot.
If the magazine matches the target type AND ammo count, it skips re-adding it (effectively deleting it).
Otherwise, it re-adds the magazine to the player.
Sqf

Apply
private ["_toRemove", "_ammoCount", "_magInfo", "_n"];
_toRemove = _this select 0;
_ammoCount = _this select 1;
_magInfo = call outlw_MR_magInfo; // Get snapshot of current mags

// Remove all mags of this type (simpler than finding specific count ones)
{player removeMagazine _x} forEach (_magInfo select 0);

// Re-add all except the one to remove
for "_n" from 0 to ((count (_magInfo select 0)) - 1) do {
    if (((_magInfo select 0) select _n) != _toRemove || {((_magInfo select 1) select _n) != _ammoCount}) then {
        player addMagazine [((_magInfo select 0) select _n), ((_magInfo select 1) select _n)];
    } else {
        _toRemove = ""; // Mark as removed to handle duplicates?
    };
};
Where it leads:

Calls: outlw_MR_magInfo.
Depended on by: outlw_MR_addSource, outlw_MR_addTarget.
Function Name: outlw_MR_magVerified What it does: Checks if a specific magazine with a specific ammo count actually exists in the player's inventory. How it does that:

Input: Magazine type and ammo count.
Snapshot: Gets current inventory via outlw_MR_magInfo.
Search: Loops through the snapshot.
Match: If a magazine type and ammo count match the inputs, returns true.
No Match: Returns false.
Sqf

Apply
private ["_toVerify", "_ammoCount", "_magInfo", "_returnBool", "_n"];
_toVerify = _this select 0;
_ammoCount = _this select 1;
_magInfo = call outlw_MR_magInfo;
_returnBool = false;

for "_n" from 0 to ((count (_magInfo select 0)) - 1) do {
    if (((_magInfo select 0) select _n) == _toVerify && {((_magInfo select 1) select _n) == _ammoCount}) then {
        _n = count (_magInfo select 0);
        _returnBool = true;
    };
};

_returnBool;
Where it leads:

Calls: outlw_MR_magInfo.
Depended on by: outlw_MR_addSource, outlw_MR_addTarget.
Function Name: outlw_MR_uniqueMags What it does: Groups identical magazines (same type and ammo count) together and counts them. It aggregates the data into a list of unique entries. How it does that:

Input: Arrays of types, counts, caps.
Iteration: Loops through all input magazines.
Uniqueness Check: Checks if the magazine (type + ammo count) is already in the return list.
Grouping:
If unique: Adds it to the return list with a count of 1.
If not unique (duplicate): Finds the existing entry in the return list and increments its count.
Return: Returns arrays for unique types, ammo counts, caps, and the aggregated counts.
Sqf

Apply
private ["_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_returnMagTypes", "_returnAmmoCaps", "_returnMagCounts", "_n", "_a", "_p"];
_magTypes = _this select 0;
_magAmmoCounts = _this select 1;
_magAmmoCaps = _this select 2;

_returnMagTypes = [];
_returnAmmoCounts = [];
_returnAmmoCaps = [];
_returnMagCounts = [];

_isUnique = true;
_a = 0;
_p = 0;

for "_n" from 0 to ((count _magTypes) - 1) do {
    _isUnique = true;
    
    // Check if already exists in return list
    for [{_a = 0}, {(_a < count _returnMagTypes) && _isUnique}, {_a = _a + 1}] do {
        if ((_magTypes select _n) == (_returnMagTypes select _a) && {(_magAmmoCounts select _n) == (_returnAmmoCounts select _a)}) then {
            _isUnique = false;
        };
    };
    
    if (_isUnique) then {
        // New unique item
        _returnMagTypes set [_p, _magTypes select _n];
        _returnAmmoCounts set [_p, _magAmmoCounts select _n];
        _returnAmmoCaps set [_p, _magAmmoCaps select _n];
        _returnMagCounts set [_p, 1];
        _p = _p + 1;
    } else {
        // Duplicate found, increment count of the previous entry
        _returnMagCounts set [(_a - 1), ((_returnMagCounts select (_a - 1)) + 1)];
    };
};

[_returnMagTypes, _returnAmmoCounts, _returnAmmoCaps, _returnMagCounts];
Where it leads:

Depended on by: outlw_MR_populateMagListBox.
Function Name: outlw_MR_isBeltMagazine What it does: Determines if a magazine is a belt magazine (large capacity, typically used in machine guns). How it does that:

Input: Magazine classname.
Check 1: Reads nameSound config. If "mGun", it's a belt.
Check 2: Reads count config. If >= 100, it's a belt.
Return: Boolean result.
Sqf

Apply
private ["_magType", "_cap", "_nameSound", "_returnBool"];
_magType = _this select 0;
_cap = getNumber(configFile >> "CfgMagazines" >> _magType >> "count");
_nameSound = getText(configFile >> "CfgMagazines" >> _magType >> "nameSound");
_returnBool = false;

if (_nameSound == "mGun" || {_cap >= 100}) then {
    _returnBool = true;
};

_returnBool;
Where it leads:

Depended on by: outlw_MR_repack.
Function Name: outlw_MR_isConvertable What it does: Checks if a magazine has a convertible counterpart (e.g., 1Rnd HE Grenade vs 3Rnd HE Grenade). How it does that:

Input: Magazine classname.
Logic: Calls outlw_MR_getConversion.
Check: If the result is not an empty string, the magazine is convertable.
Sqf

Apply
(([_this select 0] call outlw_MR_getConversion) != "");
Where it leads:

Calls: outlw_MR_getConversion.
Depended on by: outlw_MR_magInfo, outlw_MR_sourceEnabled, outlw_MR_targetEnabled, outlw_MR_addTarget.
Function Name: outlw_MR_getConversion What it does: Calculates the classname of the convertible counterpart of a magazine. How it does that:

Input: Magazine classname.
Logic 1 (Inheritance): If the magazine count is 3, it might be a 3-round burst version. It tries to get the parent config class (usually the 1-round version).
Logic 2 (String Manipulation):
Checks if the name starts with "1". If so, replaces "1" with "3" (e.g., "1Rnd" -> "3Rnd").
Otherwise, prepends "3Rnd_" to the name.
Validation: Checks if the resulting class exists in CfgMagazines. If not, returns empty string.
Sqf

Apply
private ["_magType", "_returnType", "_magTypeArray"];
_magType = _this select 0;
_returnType = "";

if (getNumber(configFile >> "CfgMagazines" >> _magType >> "count") == 3) then {
    _returnType = configName(inheritsFrom(configFile >> "CfgMagazines" >> _magType));
} else {
    _magTypeArray = toArray(_magType);
    
    if ((_magTypeArray select 0) == 49) then { // ASCII '1'
        _magTypeArray set [0, 51]; // Replace with '3'
        _returnType = toString(_magTypeArray);
    } else {
        _returnType = ("3Rnd_" + _magType);
    };
};

if !(isClass(configFile >> "CfgMagazines" >> _returnType)) then {
    _returnType = "";
};

_returnType;
Where it leads:

Depended on by: outlw_MR_isConvertable, outlw_MR_addTarget.
Function Name: outlw_MR_convert What it does: Converts a magazine (Source or Target) into its counterpart. This is usually a bulk operation (e.g., converting 10x 1Rnd to 10x 1Rnd in the conversion target, or actually swapping the type). Note: The code snippet provided implies it adds the converted mags to the player's inventory and clears the slot, but it's a bit ambiguous in the snippet provided. It appears to be a "Disassemble/Convert" action. How it does that:

Input: String "Source" or "Target".
Determination: Sets local variables based on input.
Conversion: Calls outlw_MR_getConversion to find the target class.
Inventory Manipulation:
Sets outlw_MR_doAddToMagazines to false (to prevent double-adding).
Loops for the ammo count, adding the new magazine (usually with ammo count 1).
Cleanup: Refreshes the list and calls the clear function for the original item.
Sqf

Apply
private ["_magType", "_ammoCount", "_toAdd", "_n"];
_magType = outlw_MR_sourceType;
_ammoCount = outlw_MR_sourceCount;

if ((_this select 0) == "Target") then {
    _magType = outlw_MR_targetType;
    _ammoCount = outlw_MR_targetCount;
};

_toAdd = [_magType] call outlw_MR_getConversion;
outlw_MR_doAddToMagazines = false;

// Add converted mags
for "_n" from 0 to (_ammoCount - 1) do {
    player addMagazine [_toAdd, 1];
};

call outlw_MR_populateMagListBox;

// Clear the original slot
if ((_this select 0) == "Source") then {
    call outlw_MR_clearSource;
} else {
    call outlw_MR_clearTarget;
};
Where it leads:

Calls: outlw_MR_getConversion, outlw_MR_populateMagListBox, outlw_MR_clearSource, outlw_MR_clearTarget.
Depended on by: Convert button clicks (IDCs 1600, 1601).
Function Name: outlw_MR_keyListToString What it does: Converts the keybinding array ([shift, ctrl, alt, key]) into a human-readable string (e.g., "Ctrl+R"). How it does that:

Input: Takes an optional array. If provided, uses it; otherwise uses the global outlw_MR_keyList.
String Building:
Checks boolean flags for Shift, Ctrl, Alt. If true, appends "Shift+", "Ctrl+", "Alt+".
Appends the key name using keyName.
Cleanup: Removes potential quote characters from the result.
Return: Returns the formatted string surrounded by quotes.
Sqf

Apply
private ["_shift", "_ctrl", "_alt", "_key", "_returnString", "_q"];
if (count _this == 4) then {
    _shift = (_this select 0);
    _ctrl = (_this select 1);
    _alt = (_this select 2);
    _key = (_this select 3);
} else {
    _shift = outlw_MR_shift;
    _ctrl = outlw_MR_ctrl;
    _alt = outlw_MR_alt;
    _key = outlw_MR_keybinding;
};

_returnString = "";
_q = '"';

if (_shift) then { _returnString = _returnString + "Shift+"; };
if (_ctrl) then { _returnString = _returnString + "Ctrl+"; };
if (_alt) then { _returnString = _returnString + "Alt+"; };

_returnString = (_returnString + (keyName _key));

// Remove quotes if present in keyName and wrap in quotes
(_q + toString(toArray(_returnString) - [34]) + _q);
Where it leads:

Calls: keyName.
Depended on by: outlw_MR_applyKeybinding, 
MagRepack_init_sv.sqf
.
Function Name: outlw_MR_openAbout What it does: Creates the "About" dialog and populates it with version and date information. How it does that:

Dialog Creation: Creates MagRepack_Dialog_About.
UI Population: Sets text for controls (Version, Date, Author).
Sqf

Apply
createDialog "MagRepack_Dialog_About";
((uiNamespace getVariable "outlw_MR_Dialog_About") displayCtrl 1001) ctrlSetText ("Version: " + outlw_MR_version);
((uiNamespace getVariable "outlw_MR_Dialog_About") displayCtrl 1003) ctrlSetText ("Updated: " + outlw_MR_date);
((uiNamespace getVariable "outlw_MR_Dialog_About") displayCtrl 2400) ctrlSetStructuredText parseText "M<t size='0.8'>MKAY</t>";
Where it leads:

Depended on by: Click event on "About" button in main dialog.
File: A3A/addons/core/Scripts/MagRepack/MagRepack_init_sv.sqf
Function Name: N/A (Initialization Script) What it does: Initializes the Mag Repack system. It loads settings, executes the core scripts, and attaches the keydown event handler. How it does that:

Config Check: Exits if outlw_magRepack config patch exists (presumably to prevent double-loading if using mod version).
Default Settings: Sets default repack speeds (outlw_MR_bulletTime, outlw_MR_beltTime).
Persistence: Loads debug mode, hide full setting, and keybinding list from profileNamespace. Validates the keylist type.
Script Execution: execVMs the three main script files: 
MagRepack_Main.sqf
, 
MagRepack_Keybindings.sqf
, 
MagRepack_Misc.sqf
.
Wait for Load: Waits until outlw_MR_getIDCs exists (meaning Misc.sqf has executed).
IDC Caching: Calls outlw_MR_getIDCs to build a list of all UI control IDs for animation purposes (outlw_MR_listIDCs).
Event Handler: Waits for the display 46 (main game display) to exist, then adds the KeyDown event handler calling outlw_MR_keyDown.
Feedback: Sends system chat messages confirming initialization and displaying the current keybinding.
Sqf

Apply
// Config check
if (isClass(configFile >> "CfgPatches" >> "outlw_magRepack")) exitWith {};

disableSerialization;

// Constants
outlw_MR_bulletTime = 0.8;
outlw_MR_beltTime = 4;

// Version Info
outlw_MR_version = "3.1.3";
outlw_MR_date = "31 August 2015";

// Defaults
outlw_MR_defaultKeybinding = [false, true, false, 19]; // Ctrl + R

// State Initialization
outlw_MR_canCreateDialog = true;
outlw_MR_keybindingMenuActive = false;
outlw_MR_debugMode = profileNamespace getVariable ["outlw_MR_debugMode_profile", false];
outlw_MR_doHideFull = profileNamespace getVariable ["outlw_MR_doHideFull_profile", false];
outlw_MR_keyList = profileNamespace getVariable ["outlw_MR_keyList_profile", outlw_MR_defaultKeybinding];

// Validate Keylist (prevent corruption)
if (typeName(outlw_MR_keyList select 0) != "BOOL") then {
    profileNamespace setVariable ["outlw_MR_keyList_profile", outlw_MR_defaultKeybinding];
    outlw_MR_keyList =+ outlw_MR_defaultKeybinding;
};

// Set runtime variables from saved list
outlw_MR_shift = outlw_MR_keyList select 0;
outlw_MR_ctrl = outlw_MR_keyList select 1;
outlw_MR_alt = outlw_MR_keyList select 2;
outlw_MR_keybinding = outlw_MR_keyList select 3;

// Load Core Scripts
[] execVM QPATHTOFOLDER(Scripts\MagRepack\Scripts\MagRepack_Main.sqf);
[] execVM QPATHTOFOLDER(Scripts\MagRepack\Scripts\MagRepack_Keybindings.sqf);
[] execVM QPATHTOFOLDER(Scripts\MagRepack\Scripts\MagRepack_Misc.sqf);

// Wait for Misc script to load function
waitUntil {!(isNil "outlw_MR_getIDCs")};

// Cache all Control IDs for animation checks
outlw_MR_listIDCs = [(missionConfigFile >> "MR_Dialog" >> "Controls")] call outlw_MR_getIDCs;

// Wait for Display 46 (Game Display)
waitUntil {!(isNull (findDisplay 46))};

// Add Global Keydown Handler
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call outlw_MR_keyDown;"];

// Feedback
systemChat (localize "STR_magRepack_init");
systemChat ([localize "STR_magRepack_keybind","", (call outlw_MR_keyListToString)] joinString "");
Where it leads:

Calls: outlw_MR_getIDCs, outlw_MR_keyDown.
Global Variables Modified: All outlw_MR_ globals.
UI Dependencies: missionConfigFile >> "MR_Dialog" >> "Controls".
Function Name: fn_keyActions.sqf
What it does:
This function processes key binding actions triggered by user input in the Arma 3 Antistasi Ultimate mod. It handles various in-game actions such as dismissing hints, opening battle/arty menus, toggling the info bar, activating ear plugs, accessing commander rebel menus, and managing building placer actions. The function is designed to run on the client side only within A3A-specific missions, ensuring it aborts if the mission config doesn't exist or if the client isn't fully initialized. It acts as a central hub for key-based interactions, integrating with other subsystems like UI elements (dialogs, hints), gameplay mechanics (incapacitation checks), and mod-specific features (ACE hearing).
When called: This function is invoked whenever a key binding from CfgUserActions is activated (e.g., via the game's key input system). It's registered through CBA keybinds and will execute in response to the onActivate event defined in 
CfgUserActions.hpp
. It's always called with the key's internal name as a string parameter (e.g., QGVAR(battleMenu)). It must be called from the client's event handler; server-side or headless clients may skip or fail execution.

How it does that:
The function follows a structured flow: parameter validation, early exit conditions, state checks, and action execution. It uses a switch-case statement for routing based on the key action, with conditional guards for player state and mission context. It also handles dialog visibility and mouse cursor positioning for UI consistency.

fn_keyActions.sqf

Apply
#include "..\script_component.hpp"
FIX_LINE_NUMBERS()
params ["_key"];
if !(isClass (missionConfigFile/"A3A")) exitWith {}; //not a3a mission

private _hadDialog = dialog;
Parameter validation:
The params ["_key"]; statement declares and assigns the incoming parameter _key to the local variable _key. This is a standard CBA params array for single-parameter input, ensuring _key holds the string representation of the key action (e.g., GVAR(battleMenu)). No explicit type validation is performed, but it's assumed to be a string.
If the mission config class A3A doesn't exist in missionConfigFile, the function exits immediately via exitWith {}. This prevents execution in non-A3A missions, avoiding errors from accessing undefined A3A-specific variables or functions. It's a safeguard against mod conflicts or unintended calls.

Dialog state check:
The private _hadDialog = dialog; line creates a local variable _hadDialog that records whether a dialog was open before this key action. The dialog command returns a boolean (true/false) indicating if any GUI dialog is currently displayed. This is used later to decide whether to reposition the mouse cursor (only if no prior dialog existed). It's a non-essential optimization to avoid unnecessary UI operations.

fn_keyActions.sqf

Apply
// ... existing code ...

switch (_key) do {
    case QGVAR(customHintDismiss): {
        [] call A3A_fnc_customHintDismiss;
    };

    // Actions below here aren't valid until the game is started and client init is complete
    if (isNil "initClientDone") exitWith {};
Switch statement routing:
The switch (_key) do { ... } structure routes the execution based on the _key string. It uses case for each key action, matching the exact global variable names (e.g., QGVAR(customHintDismiss) expands to a string literal). For QGVAR(customHintDismiss), it calls A3A_fnc_customHintDismiss with no parameters ([] call). This function dismisses all custom hints on screen. If no matching case is found, execution falls through to the default case (handled later).

Client initialization check:
The if (isNil "initClientDone") exitWith {}; line checks if the global variable initClientDone (set during client initialization) exists. If it's nil (uninitialized), the function exits immediately. This ensures actions that depend on game state (e.g., player variables, UI elements) only run after the client is fully set up. It's a critical error-handling measure to prevent crashes from uninitialized dependencies.

fn_keyActions.sqf

Apply
// ... existing code ...

    case QGVAR(battleMenu): {
        if (player getVariable ["incapacitated",false]) exitWith {};
        if (player getVariable ["owner",player] != player) exitWith {};
        GVAR(keys_battleMenu) = true; //used to block certain actions when menu is open
    #ifdef UseDoomGUI
        ERROR("Disabled due to UseDoomGUI Switch.")
    #else
        closeDialog 0;
        createDialog "radioComm";
    #endif
        [] spawn { sleep 1; GVAR(keys_battleMenu) = false; };
    };
Battle menu action:

Player state checks: Uses player getVariable ["incapacitated",false] to retrieve the "incapacitated" variable (defaults to false if missing). If true, the action exits immediately, preventing menu access while downed. Similarly, player getVariable ["owner",player] != player checks if the player is the "owner" (e.g., for AI-controlled units or dogs); if not, it exits, ensuring only living players can trigger this.
Global variable set: GVAR(keys_battleMenu) = true; sets a global flag (via CBA's GVAR macro) to true, blocking conflicting actions (e.g., other keybinds) while the menu is open.
Compilation switch: The #ifdef UseDoomGUI preprocessor directive checks if the UseDoomGUI macro is defined (from mod config). If so, it logs an error with ERROR("Disabled due to UseDoomGUI Switch.") and skips the dialog creation. Otherwise, closeDialog 0 closes any open dialog, and createDialog "radioComm" opens the "radioComm" resource (an Arma dialog class for battle menu).
Timer spawn: [] spawn { sleep 1; GVAR(keys_battleMenu) = false; }; spawns a new script (via spawn) to sleep for 1 second, then set GVAR(keys_battleMenu) back to false. This is asynchronous and allows the menu to open without blocking the main thread.
fn_keyActions.sqf

Apply
// ... existing code ...

    case QGVAR(artyMenu): {
        if (player getVariable ["incapacitated",false]) exitWith {};
        if (player getVariable ["owner",player] != player) exitWith {};
        if (player isEqualTo theBoss) then {
            GVAR(keys_battleMenu) = true; //used to block certain actions when menu is open
            [] spawn A3A_fnc_artySupport;
            [] spawn { sleep 1; GVAR(keys_battleMenu) = false; };
        };
    };
Artillery menu action:

Player state checks: Same as battle menu: checks incapacitation and ownership, exiting if conditions aren't met.
Boss-only gate: if (player isEqualTo theBoss) then { ... } verifies if the local player is theBoss (global variable for the mission leader). If not, the action does nothing, restricting artillery access to commanders.
Global variable and function spawn: Sets GVAR(keys_battleMenu) = true; to block conflicts, then spawns A3A_fnc_artySupport (no parameters) to handle artillery support logic (e.g., UI for targeting).
Timer spawn: Same as battle menu, spawns a script to reset the flag after 1 second.
fn_keyActions.sqf

Apply
// ... existing code ...

    case QGVAR(infoBar): {
    #ifdef UseDoomGUI
        ERROR("Disabled due to UseDoomGUI Switch.")
    #else
        if (isNull (uiNameSpace getVariable "H8erHUD")) exitWith {};

        private _display = uiNameSpace getVariable "H8erHUD";
        private _infoBarControl = _display displayCtrl 1001;
        private _keyName = actionKeysNames QGVAR(infoBar);
        _keyName = _keyName select [1, count _keyName - 2];

        if (ctrlShown _infoBarControl) then {
            ["KEYS", true] call A3A_fnc_disableInfoBar;
            [localize "STR_antistasi_dialogs_toggle_info_bar_title", format [localize "STR_antistasi_dialogs_toggle_info_bar_body_off", _keyName], false] call A3A_fnc_customHint;
        } else {
            ["KEYS", false] call A3A_fnc_disableInfoBar;
            [localize "STR_antistasi_dialogs_toggle_info_bar_title", format [localize "STR_antistasi_dialogs_toggle_info_bar_body_on", _keyName] , false] call A3A_fnc_customHint;
        };
    #endif
    };
Info bar toggle action:

Compilation switch: #ifdef UseDoomGUI disables this action if UseDoomGUI is defined, logging an error.
UI validation: if (isNull (uiNameSpace getVariable "H8erHUD")) exitWith {}; checks if the "H8erHUD" display (global namespace) is null. If so, it exits, as the info bar depends on this HUD.
Display and control retrieval: Retrieves _display from uiNamespace and _infoBarControl as display control 1001 (assumed to be the info bar element).
Key name extraction: actionKeysNames QGVAR(infoBar) gets the user-bound key name (e.g., "Home") as a string with brackets (e.g., "[Home]"). _keyName = _keyName select [1, count _keyName - 2]; extracts the inner text by slicing from index 1 to the second-to-last character, removing brackets.
Toggle logic: Checks ctrlShown _infoBarControl. If visible, calls ["KEYS", true] on A3A_fnc_disableInfoBar (enables the disable flag) and shows a custom hint saying it's off. If hidden, calls with false to disable the flag and shows a hint saying it's on. Both use localize for string tables and format to insert _keyName.
fn_keyActions.sqf

Apply
// ... existing code ...

    case QGVAR(earPlugs): {
        if (!A3A_hasACEHearing) then {
            if (soundVolume <= 0.5) then {
                0.5 fadeSound 1;
                [localize "STR_A3A_keyActions_ear_plugs_header", localize "STR_A3A_keyActions_ear_plugs_off", true] call A3A_fnc_customHint;
            } else {
                0.5 fadeSound 0.1;
                [localize "STR_A3A_keyActions_ear_plugs_header", localize "STR_A3A_keyActions_ear_plugs_on", true] call A3A_fnc_customHint;
            };
        };
    };
Ear plugs action:

ACE check: if (!A3A_hasACEHearing) then { ... } uses the global boolean A3A_hasACEHearing (set during mod init) to skip execution if ACE hearing is active (as ACE has its own ear plug system). If false, proceed.
Volume toggling: Checks soundVolume (global audio level, 0.0-1.0). If <= 0.5, fades sound to 1.0 over 0.5 seconds via 0.5 fadeSound 1; and shows a hint that ear plugs are off. Otherwise, fades to 0.1 (quiet) and shows an "on" hint. Both use localize for localized strings and call A3A_fnc_customHint to display them.
fn_keyActions.sqf

Apply
// ... existing code ...

    case QGVAR(commanderRebelMenu): {
        if (player getVariable ["incapacitated",false]) exitWith {
            if (isMenuOpen) then {
                closeDialog 0;closeDialog 0;
            };
        };
        if (player getVariable ["owner",player] != player) exitWith {
            if (isMenuOpen) then {
                closeDialog 0;closeDialog 0;
            };
        };

        [] call SCRT_fnc_ui_toggleCommanderMenu;
    };
Commander rebel menu action:

Incapacitation exit: Checks incapacitated variable; if true, exits while closing any open menu (isMenuOpen global check) twice (Arma quirk for full closure).
Ownership exit: Same as above, checks ownership and closes menu if open.
Menu toggle: If checks pass, calls [] call SCRT_fnc_ui_toggleCommanderMenu; (no parameters). This function (likely from SCRT mod) toggles the rebel commander menu UI. Note: SCRT is an external mod prefix, so this relies on its availability.
fn_keyActions.sqf

Apply
// ... existing code ...

    default {
        Error_1("Key action not registered: %1", _key)
    };
};

if (!_hadDialog) then {
    // Have to spawn the mouse cursor center function because arty menu is spawned, too
    [
        {
            if (dialog) then {
                setMousePosition [0.5, 0.5];
            };
        },
        [],
        0.05
    ] call CBA_fnc_waitAndExecute;
};

nil;
Default case: If no case matches _key, logs an error via Error_1("Key action not registered: %1", _key). The Error_1 macro (from script_component.hpp) likely formats and prints the error message. This catches unregistered keys.

Post-action UI handling:

Conditional block: if (!_hadDialog) then { ... } executes only if no dialog was open initially (i.e., _hadDialog is false).
Wait-and-execute: Uses CBA_fnc_waitAndExecute to schedule a block after 0.05 seconds. The code checks if dialog is true (UI opened since), then setMousePosition [0.5, 0.5]; centers the cursor. This is spawned (indirectly via CBA) because actions like artyMenu may open dialogs asynchronously.
Return value: nil; returns nothing, as SQF functions default to nil if no explicit return is used.
Where it leads:
This function calls several dependent functions:

A3A_fnc_customHintDismiss: Clears all on-screen custom hints (UI subsystem).
A3A_fnc_disableInfoBar: Manages the visibility flag for the info bar (UI/mod control).
A3A_fnc_customHint: Displays localized hint messages (UI/subsystem feedback).
A3A_fnc_artySupport: Handles artillery support targeting (Supports subsystem).
SCRT_fnc_ui_toggleCommanderMenu: Toggles the commander menu (External mod integration, likely Rebel Commander menu).
CBA_fnc_waitAndExecute: Schedules UI updates (CBA library function).
Global variables modified: GVAR(keys_battleMenu) (set to true/false to block actions); initClientDone (read only, but function exits if nil); theBoss, A3A_hasACEHearing, soundVolume (read-only globals).
Dependencies: Relies on CfgDefaultKeysPresets (key bindings) and CfgUserActions (action definitions). Called by Arma's input system after keypress.
Network implications: All operations are client-side only; no server calls or synchronization. Variables like GVAR(keys_battleMenu) are local to the client (CBA global).
System integration: Fits into the keybinds module as the central handler. It depends on client initialization (initClientDone from fn_initClient.sqf) and mission-specific checks. Edge cases: Handles non-A3A missions (early exit), disabled GUIs (conditional compilation), and missing UI elements (null checks). Error handling: Logs unregistered keys; exits on state violations (incapacitated, ownership). No direct input validation for _key beyond switch matching.